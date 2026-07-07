#INCLUDE "PROTHEUS.CH"      
#INCLUDE "TOPCONN.CH"
//------------------------------------------------------------------- 
/*/{Protheus.doc} REST002 
Rotina para preparar log completo

@author Alessandro Smaha 
@since 07/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function REST002()

	Private cPerg 		:= "" 
	Private _dDataBse 	:= CtoD("  /  /  ")
	Private _cHorInic 	:= Time()    
	Private _cCusFil 	:= Alltrim(GetMv("MV_CUSFIL",,""))
	Private _cTxtAux	:= "" 
	Private _cFilCons	:= ""
	
	// MV_CUSFIL	
	// F – Custo unificado por filial (aglutina o custo no cálculo por filial);
	// A – Custo unificado por armazém (aglutina o custo no cálculo por armazém);
	// E – Custo unificado por empresa (aglutina o custo no cálculo por empresa);
		
	fAjustaSx1()   
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf 
	
	If Empty(MV_PAR01) 
	
		MsgAlert("Todos os parâmetros devem ser informados!","Atenção")
	
	Else  

		_dDataBse := MV_PAR01 

   		Processa( {|lEnd| fProcessa( MV_PAR01, @lEnd ) },"Log para Fechamento de Estoque...","Análisando Quantidade e Valores",.T.)
	
	EndIf

Return                


//------------------------------------------------------------------- 
/*/{Protheus.doc} fProcessa()
Processa a importação do inventário  

@param dDataInv - Data utilizada como database para ajuste valorizado
@param lEnd     - Variavel logica para controle de cancelamento

@author Alessandro Smaha 
@since 07/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fProcessa(dDataInv,lEnd)   
         
	Local cMsg	   := "" 
	Local cArmaz   := ""
	Local cBkpFil  := cFilAnt
	Local nI 	   := 0
	Local nCntPro  := 0    
	Local aArmaz   := {} 
	Local aFilMv   := {}
	
	Local a_C_QP_VP	:= {}
	Local a_C_QP_V0	:= {}
	Local a_C_QP_VN	:= {}
	Local a_C_QN_VP	:= {}
	Local a_C_QN_V0	:= {}
	Local a_C_QN_VN	:= {}
	Local a_C_Q0_VP	:= {}
	Local a_C_Q0_V0	:= {}
	Local a_C_Q0_VN	:= {}
	
	Local aProdBlq	:= {}
	
	Local aSldPro	:= {} 
	Local nK	    := 0
	Local nSldPro 	:= 0
	Local nVlrPro 	:= 0
	
	Local nVlrTot	:= 0
	
	Private _aProdVlr := {}
	
	If _cCusFil <> "A" 
   		aFilMv := fBuscaFil()   
 	EndIf
	
	DbSelectArea("SB1")  // Produtos
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
	
	DbSelectArea("SB2")  // Saldos Fisicos e Financeiro
	SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
	 
	ProcRegua(0)

	SB1->(DbGoTop())

	While !SB1->(EOF()) .AND. !lEnd 

		nCntPro++
		
		IncProc("Verificando Cadastros de Produtos... ("+cValToChar(nCntPro)+")")
		
		If SB1->B1_MSBLQL <> "1" .OR. MV_PAR03 == 2 // 1=Não; 2=Sim
		
			_cTxtAux := "Parâmetros:" + CHR(13) + CHR(10) + "MV_CUSFIL: " + _cCusFil + CHR(13) + CHR(10) + "Data: " + DtoC(MV_PAR01) 
		
			If _cCusFil == "A" 
			
				aArmaz := fBuscaAmz( SB1->B1_COD )
				
				For nK := 1 to Len(aArmaz)   
				
					cArmaz   := aArmaz[nK]
					
					aSldPro := CalcEst( SB1->B1_COD , cArmaz, dDataInv + 1)
					nSldPro := 0
					nVlrPro := 0
					
					If !Empty(aSldPro)
						
						nSldPro := ROUND(aSldPro[1],2)
						nVlrPro := ROUND(aSldPro[2],2)
						
						nVlrTot += nVlrPro
						
					EndIf
				
					fAnalise(	nSldPro,nVlrPro,;
								@a_C_QP_VP, @a_C_QP_V0, @a_C_QP_VN,;
								@a_C_QN_VP, @a_C_QN_V0, @a_C_QN_VN,;
								@a_C_Q0_VP, @a_C_Q0_V0, @a_C_Q0_VN, cArmaz)
				
				Next nK
				
			Else
			
				_cTxtAux += "   Filial de: "+MV_PAR04+"   Filial até: "+MV_PAR05 + CHR(13) + CHR(10)
				_cTxtAux += "Lista Produtos Bloq.: "+IIF(MV_PAR02==1,"NÃO","SIM")+"   Considera Produtos Bloq.: "+IIF(MV_PAR03==1,"NÃO","SIM")
		
				aSldPro := {}
				nSldPro := 0
				nVlrPro := 0 
									
				For nL := 1 to Len(aFilMv)
				
					cFilAnt := aFilMv[nL]
													
					aArmaz := fBuscaAmz( SB1->B1_COD )
							
					For nK := 1 to Len(aArmaz)   
					
						cArmaz   := aArmaz[nK]
						
						aSldPro := CalcEst( SB1->B1_COD , cArmaz, dDataInv + 1)
							
						If !Empty(aSldPro)
							
							nSldPro += ROUND(aSldPro[1],2)
							nVlrPro += ROUND(aSldPro[2],2)  
							
						EndIf
						
					Next nK
					
				Next nL
				
				nVlrTot += nVlrPro 
				
				fAnalise(	nSldPro,nVlrPro,;
							@a_C_QP_VP, @a_C_QP_V0, @a_C_QP_VN,;
							@a_C_QN_VP, @a_C_QN_V0, @a_C_QN_VN,;
							@a_C_Q0_VP, @a_C_Q0_V0, @a_C_Q0_VN, "**")
			
				
			EndIf
			
		EndIf
		
		If SB1->B1_MSBLQL == "1" 

			aAdd(aProdBlq,Alltrim(SB1->B1_COD))
		
		EndIf
		
		SB1->(DbSkip())
		
	EndDo 
	
	// Restaura Filial
	cFilAnt := cBkpFil
	
	// CORPO DO LOG
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)               
	cMsg += Replicate("/",60) + CHR(13) + CHR(10)
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)	
	cMsg += "Total de Produtos (Cad. Produtos): "+cValToChar(nCntPro) + CHR(13) + CHR(10)	
	cMsg += _cTxtAux + CHR(13) + CHR(10)  
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)
	cMsg += "Filiais Consideradas: "+_cFilCons + CHR(13) + CHR(10) 
				
	If Len(aProdBlq) > 0
		If MV_PAR02 <> 1 // 1=Não; 2=Sim
	   		cMsg += fAtuTexto(aProdBlq,"Produtos Bloqueados (Cad. Produtos): " + cValToChar(Len(aProdBlq)) + CHR(13) + CHR(10) )
	 	Else     
	 		cMsg += Replicate("-",60)+ CHR(13) + CHR(10) 
	 		cMsg += "Produtos Bloqueados (Cad. Produtos): " + cValToChar(Len(aProdBlq)) + CHR(13) + CHR(10) 
	 	EndIf
	Else
		cMsg += Replicate("-",60)+ CHR(13) + CHR(10)
		cMsg += "Não possui Produtos Bloqueados (Cad. Produtos)." + CHR(13) + CHR(10)
	EndIf
	
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)	
	cMsg += "Valor Total do Estoque: " + cValToChar(nVlrTot) + CHR(13) + CHR(10)	
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)               
	cMsg += Replicate("/",60) + CHR(13) + CHR(10)
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)
	
	// DETALHE DO LOG    
	cMsg += "Quantidade Positiva/Valor Positivo: " + cValToChar(Len(a_C_QP_VP)) + CHR(13) + CHR(10)		
	cMsg += "Quantidade Zerada / Valor Zerado  : " + cValToChar(Len(a_C_Q0_V0)) + CHR(13) + CHR(10)	  
	cMsg += CHR(13) + CHR(10)  
	cMsg += "INCONSISTÊNCIAS: " + CHR(13) + CHR(10)     
	cMsg += "Quantidade Negativa/Valor Zerado  : " + cValToChar(Len(a_C_QN_V0)) + CHR(13) + CHR(10)
	cMsg += "Quantidade Negativa/Valor Positivo: " + cValToChar(Len(a_C_QN_VP)) + CHR(13) + CHR(10)
	cMsg += "Quantidade Negativa/Valor Negativo: " + cValToChar(Len(a_C_QN_VN)) + CHR(13) + CHR(10)
	cMsg += "Quantidade Positiva/Valor Zerada:   " + cValToChar(Len(a_C_QP_V0)) + CHR(13) + CHR(10)
	cMsg += "Quantidade Positiva/Valor Negativo: " + cValToChar(Len(a_C_QP_VN)) + CHR(13) + CHR(10)
	cMsg += "Quantidade Zerada / Valor Positivo: " + cValToChar(Len(a_C_Q0_VP)) + CHR(13) + CHR(10)
	cMsg += "Quantidade Zerada / Valor Negativo: " + cValToChar(Len(a_C_Q0_VN)) + CHR(13) + CHR(10)
    
   	cMsg += Replicate("-",60) + CHR(13) + CHR(10)               
	cMsg += Replicate("/",60) + CHR(13) + CHR(10)
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)
	
	cMsg += "DETALHES DAS INCONSISTÊNCIAS " + CHR(13) + CHR(10)   
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)		
								
	cMsg += 	"Total de Inconsistencias de Produtos: " + cValToChar(Len(a_C_QN_V0)+Len(a_C_QN_VN)+Len(a_C_QN_VP)+Len(a_C_QP_V0)+;
				Len(a_C_QP_VN)+Len(a_C_Q0_VP)+Len(a_C_Q0_VN)) + CHR(13) + CHR(10)
	
	
	cMsg += fAtuTexto(a_C_QN_V0,"Quantidade Negativa/Valor Zerado: "   + cValToChar(Len(a_C_QN_V0)) + CHR(13) + CHR(10) )
	cMsg += fAtuTexto(a_C_QN_VP,"Quantidade Negativa/Valor Positivo: " + cValToChar(Len(a_C_QN_VP)) + CHR(13) + CHR(10) )	
	cMsg += fAtuTexto(a_C_QN_VN,"Quantidade Negativa/Valor Negativo: " + cValToChar(Len(a_C_QN_VN)) + CHR(13) + CHR(10) )
	cMsg += fAtuTexto(a_C_QP_V0,"Quantidade Positiva/Valor Zerado: "   + cValToChar(Len(a_C_QP_V0)) + CHR(13) + CHR(10) )
	cMsg += fAtuTexto(a_C_QP_VN,"Quantidade Positiva/Valor Negativo: " + cValToChar(Len(a_C_QP_VN)) + CHR(13) + CHR(10) ) 
	cMsg += fAtuTexto(a_C_Q0_VP,"Quantidade Zerada/Valor Positivo: "   + cValToChar(Len(a_C_Q0_VP)) + CHR(13) + CHR(10) )
	cMsg += fAtuTexto(a_C_Q0_VN,"Quantidade Zerada/Valor Negativo: "   + cValToChar(Len(a_C_Q0_VN)) + CHR(13) + CHR(10) )
	
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)               
	cMsg += Replicate("/",60) + CHR(13) + CHR(10)
	cMsg += Replicate("-",60) + CHR(13) + CHR(10) 
	cMsg += " * OBS: () Indicam o armazém do produto" + CHR(13) + CHR(10)  
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)               
	cMsg += Replicate("/",60) + CHR(13) + CHR(10)
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)
	cMsg += "FIM DO LOG" + CHR(13) + CHR(10)
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)               
	cMsg += Replicate("/",60) + CHR(13) + CHR(10)
	cMsg += Replicate("-",60) + CHR(13) + CHR(10)
	
	If lEnd
		
		cMsg := CHR(13) + CHR(10) + "Operação cancelada pelo usuário!" 
		
	EndIf
	
	fTelaLog(cMsg)
	
Return 


//------------------------------------------------------------------- 
/*/{Protheus.doc} fAtuTexto()
Atualiza Texto da msg

@param aArrayRec - Array com o conteudo para alimentar string de retorno  
@param cTituloTx - Titulo utilizado para identificar conteudo

@author Alessandro Smaha 
@since 07/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fAtuTexto( aArrayRec, cTituloTx )

	Local nI := 0 
	Local cAuxTxt := ""  
	
	If Len(aArrayRec) > 0	

		cAuxTxt += Replicate("-",60)+ CHR(13) + CHR(10)  
		cAuxTxt += cTituloTx
		
		For nI := 1 to Len(aArrayRec) 
		
	   		cAuxTxt += IIF(nI > 1,", ","") + aArrayRec[nI]
			
		Next nI 
		
		cAuxTxt += CHR(13) + CHR(10)
		
	EndIf

Return cAuxTxt  


//------------------------------------------------------------------- 
/*/{Protheus.doc} fAnalise()
Verifica e analisa o produto

@param cMsg - String para exibir log de erro

@author Alessandro Smaha 
@since 07/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fAnalise(nQtdPro,nVlrPro,a_QP_VP,a_QP_V0,a_QP_VN,a_QN_VP,a_QN_V0,a_QN_VN,a_Q0_VP,a_Q0_V0,a_Q0_VN,cArmaz)
	        
	// Regras
	If nQtdPro < 0
		
		If nVlrPro < 0
			
			aAdd(a_QN_VN,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		ElseIf nVlrPro > 0
			
			aAdd(a_QN_VP,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		Else // nVlrPro == 0
			
			aAdd(a_QN_V0,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		EndIf
		
	ElseIf nQtdPro > 0
		
		If nVlrPro < 0
			
			aAdd(a_QP_VN,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		ElseIf nVlrPro > 0
			
			aAdd(a_QP_VP,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		Else // nVlrPro == 0
			
			aAdd(a_QP_V0,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		EndIf
		
		
	Else // nQtdPro == 0
		
		If nVlrPro < 0
			
			aAdd(a_Q0_VN,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		ElseIf nVlrPro > 0
			
			aAdd(a_Q0_VP,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		Else // nVlrPro == 0
			
			aAdd(a_Q0_V0,Alltrim(SB1->B1_COD) + " (" + Alltrim(cArmaz) + ")" )
			
		EndIf
		
	EndIf
	
Return  


//------------------------------------------------------------------- 
/*/{Protheus.doc} fTelaLog()
Exibe a tela de log após a atualização de saldos   

@param cMsg - String para exibir log de erro

@author Alessandro Smaha 
@since 07/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fTelaLog(cMsg)

	Local  cMask	:= "Arquivos Texto (*.TXT) |*.txt|"
	Local _cFile	:= ""   
	Local nOpcao	:= 0 
	Local cNomeFil  := Alltrim(FWFilialName()) // Retorna o nome da filial 
	Local oBtnProc   

	cMsg := "LOG DE FECHAMENTO SENTAX (REST002)" + CHR(13) + CHR(10) + DtoC(Date())+" Hora Inicio: "+_cHorInic+" Hora Fim: "+Time() +;
			 CHR(13) + CHR(10) +;
			 "Filial "+FWCodFil()+" - " + cNomeFil + CHR(13) + CHR(10)+ cMsg

	__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cMsg)
	
	DEFINE FONT oFont NAME "Mono AS" SIZE 6,15      
	
	DEFINE MSDIALOG oDlg TITLE "Atualização concluida." From 3,0 to 340,417 PIXEL   
	
		@ 5,5 GET oMemo  VAR cMsg MEMO SIZE 200,145 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		DEFINE SBUTTON  FROM 153,175 TYPE 01 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
		DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (_cFile:=cGetFile(cMask,""),If(_cFile="",.t.,MemoWrite(_cFile,cMsg))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
	
	ACTIVATE MSDIALOG oDlg CENTER
		
Return

    
//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaAmz
Rotina para buscar os armazens do produto

@author  Alessandro Smaha
@since   07/11/2014 
@return  NIL
/*/
//-------------------------------------------------------------------
Static Function fBuscaAmz(cCdPro)

Local cQuery 	:= ""  
Local aArmazens	:= {} 

cCdPro := Alltrim(cCdPro)

If (Select("ARMZ") <> 0)
	
	DbSelectArea("ARMZ")
	ARMZ->(DbCloseArea())
	
Endif

cQuery := " SELECT B2_LOCAL " 
cQuery += " FROM " + RetSQLName("SB2") + " " 
cQuery += " WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
cQuery += " 	AND B2_COD = '" + cCdPro + "' " 
cQuery += " 	AND D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY B2_LOCAL "
cQuery += " ORDER BY B2_LOCAL "

TCQuery cQuery new Alias "ARMZ"

ARMZ->(DbGoTop())

If ARMZ->(!Eof())  
	While ARMZ->(!Eof())
		aAdd( aArmazens, ARMZ->B2_LOCAL )	 
		ARMZ->(DbSkip()) 
	EndDo
EndIf

ARMZ->(DbCloseArea())

Return aArmazens
                 


    
//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaFil
Rotina para buscar as Filiais

@author  Alessandro Smaha
@since   07/11/2014 
@return  NIL
/*/
//-------------------------------------------------------------------
Static Function fBuscaFil()

Local aFils		:= {}
Local cQuery 	:= ""
Local lFilAux	:= ""  
Local aSM0Emps  := FWLoadSM0()

If (Select("TQRY") <> 0)	
	DbSelectArea("TQRY")
	TQRY->(DbCloseArea())	
Endif   

_cFilCons := ""

For nK := 1 to Len(aSM0Emps)
	If aSM0Emps[nK][2] >= MV_PAR04 .AND. aSM0Emps[nK][2] <= MV_PAR05
		If cEmpAnt == aSM0Emps[nK][1] .AND. SUBSTR(cFilAnt,1,4)==SUBSTR(aSM0Emps[nK][2],1,4)
			_cFilCons += IIF(Empty(_cFilCons),"",",")+aSM0Emps[nK][2]	
		EndIf	
	EndIf
Next nK

cQuery := " SELECT B2_FILIAL " 
cQuery += " FROM " + RetSQLName("SB2") + " " 
cQuery += " WHERE B2_FILIAL IN ('"+StrTran(_cFilCons,",","','")+"')"
cQuery += " 	AND D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY B2_FILIAL "
cQuery += " ORDER BY B2_FILIAL "

TCQuery cQuery new Alias "TQRY"

TQRY->(DbGoTop())

If TQRY->(!Eof())  
	While TQRY->(!Eof())
		aAdd( aFils, TQRY->B2_FILIAL )	 
		TQRY->(DbSkip()) 
	EndDo
EndIf

TQRY->(DbCloseArea())

Return aFils


//------------------------------------------------------------------- 
/*/{Protheus.doc} AjustaSx1()
Cria as perguntas para o SX1

@author Alessandro Smaha 
@since 07/04/2014
@version P11                                                                                                          

/*/ 
//-------------------------------------------------------------------
Static Function fAjustaSx1() 

	If _cCusFil == "A"
	
		cPerg := "REST002"

   		PutSx1(cPerg,"01","Data para Consulta?","Data para Consulta?","Data para Consulta?","MV_CH1","D",08,0,0,"G","","   ","","","MV_PAR01","","","","","","","","","","","","","","","","",{"Data para consulta","","",""},{"Data para consulta","","",""},{"Data para consulta","",""},"")
   		PutSx1(cPerg,"02","Lista Bloqueados?","Lista Bloqueados?","Lista Bloqueados?","MV_CH2","N", 1, 0, 3, "C", "", "   ","","","MV_PAR02",;
					 "Não", "Não", "Não", "Não", "Sim", "Sim", "Sim","","","","","","","","","",{"Lista produtos bloqueados no log?","","",""},{"Lista produtos bloqueados no log?","","",""},{"Lista produtos bloqueados no log?","",""},"")
        PutSx1(cPerg,"03","Considera Bloqueados?","Considera Bloqueados?","Considera Bloqueados?","MV_CH3","N", 1, 0, 3, "C", "", "   ","","","MV_PAR03",;
					 "Não", "Não", "Não", "Não", "Sim", "Sim", "Sim","","","","","","","","","",{"Considera produtos bloqueados no log?","","",""},{"Considera produtos bloqueados no log?","","",""},{"Considera produtos bloqueados no log?","",""},"")
        
	Else 
	
  		cPerg := "REST002N"		
	
   		PutSx1(cPerg,"01","Data para Consulta?","Data para Consulta?","Data para Consulta?","MV_CH1","D",08,0,0,"G","","   ","","","MV_PAR01","","","","","","","","","","","","","","","","",{"Data para consulta","","",""},{"Data para consulta","","",""},{"Data para consulta","",""},"")
   		PutSx1(cPerg,"02","Lista Bloqueados?","Lista Bloqueados?","Lista Bloqueados?","MV_CH2","N", 1, 0, 3, "C", "", "   ","","","MV_PAR02",;
					 "Não", "Não", "Não", "Não", "Sim", "Sim", "Sim","","","","","","","","","",{"Lista produtos bloqueados no log?","","",""},{"Lista produtos bloqueados no log?","","",""},{"Lista produtos bloqueados no log?","",""},"")
   		PutSx1(cPerg,"03","Considera Bloqueados?","Considera Bloqueados?","Considera Bloqueados?","MV_CH3","N", 1, 0, 3, "C", "", "   ","","","MV_PAR03",;
					 "Não", "Não", "Não", "Não", "Sim", "Sim", "Sim","","","","","","","","","",{"Considera produtos bloqueados no log?","","",""},{"Considera produtos bloqueados no log?","","",""},{"Considera produtos bloqueados no log?","",""},"")
        PutSx1(cPerg,"04","Filial de?","Filial de?","Filial de?","mv_ch4","C",06,0,0,"G","","SM0STX","","","MV_PAR04","","","","","","","","","","","","","","","","",{"Informe a partir da Filial","","",""},{"Informe a partir da Filial","","",""},{"Informe a partir da Filial","",""},"")
   		PutSx1(cPerg,"05","Filial ate?","Filial ate?","Filial ate?","mv_ch5","C",06,0,0,"G","","SM0STX","","","MV_PAR05","","","","","","","","","","","","","","","","",{"Informe até a Filial","","",""},{"Informe até a Filial","","",""},{"Informe até a Filial","",""},"")

	EndIf
	
Return
