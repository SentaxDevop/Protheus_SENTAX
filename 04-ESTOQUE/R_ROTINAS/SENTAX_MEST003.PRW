#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
//------------------------------------------------------------------- 
/*/{Protheus.doc} MEST003 
Rotina para criar o inventário a partir do arquivo .CSV informado.

@author 	Alessandro Smaha 
@since 		05/12/2014
@version 	P11 
/*/ 
//-------------------------------------------------------------------
User Function MEST003() 

	Local cArqPlan	:= "" 
	Local cLogMsg	:= ""  

	Private cPerg := "MEST003" 
	
	Private _cHorInic := Time() 
	
	cArqPlan := cGetFile( 'Arquivos CSV|*.csv',"Selecione a planilha", ,"" ,.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD,.T.) 
	  			
	If ! Empty(cArqPlan) 
			
		If ! File(cArqPlan)
		          
			MsgInfo("Arquivo "+cArqPlan+" não existe!","Atenção")
			
		Else		
					
			fAjustaSx1()   
			
			If Pergunte(cPerg,.T.)
				
				If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .OR. Empty(MV_PAR03) .OR. Empty(MV_PAR04)  
				
					MsgAlert("Todos os parâmetros devem ser informados!","Atenção")
					
				ElseIf MV_PAR01 <> cFilAnt
				
					MsgAlert("Filial logada é diferente da filial informada!","Atenção")
				
				Else  
				
					If MsgYesNo("O arquivo "+Alltrim(cArqPlan)+" é referente ao mês de "+Alltrim(MesExtenso(MV_PAR03))+"/"+cValToChar(Year(MV_PAR03))+"? "+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
								"Deseja prosseguir?","Confirma")
				        
						Processa({|| fValidaPln( MV_PAR01, MV_PAR02, MV_PAR03, UPPER(MV_PAR04), cArqPlan, @cLogMsg ) },"Inventário") 
							     
						fTelaLog(cLogMsg,.T.)
						
					EndIf
					
				EndIf  
			
			EndIf
		
		EndIf
		
	EndIf
	
Return                
   

//------------------------------------------------------------------- 
/*/{Protheus.doc} fValidaPln()
Processa a importação do inventário     

@param 		cFilInv - Filial para o inventário 
			cArmazem - Armazem para o inventário 
			dDataInv - Data do inventário 
			cDocInv - Nome do documento do inventário 
			cArquivo - Arquivo do CSV 
			cMsg - Mensagem para o log

@author 	Alessandro Smaha 
@since 		05/12/2014
@version 	P11 
/*/ 
//-------------------------------------------------------------------
Static Function fValidaPln( cFilInv, cArmazem, dDataInv, cDocInv, cArquivo, cMsg )
       
Local lRetOk 	:= .T.  
Local cChar    	:= ""
Local nI 	   	:= 0 
Local nCntPro  	:= 0  
Local nContLin	:= 0
Local aProduto 	:= {}   
Local aErros   	:= {}
Local aImpOk   	:= {}
Local aImpVr   	:= {}   
Local aImpBl	:= {}
Local lPrimLin 	:= .T. 

Local cCodPro 	:= ""
Local cTipPro	:= ""
Local cGrpPro	:= ""
Local cDesPro	:= ""
Local cUnMPro	:= ""
Local cFilPro	:= ""
Local cAmzPro	:= ""
Local cQntPro 	:= ""
Local cQFsPro 	:= ""  

Local lBlqPar	:= GetMV("ST_XBLQSB7",,.F.)

Local aProdInv	:= {}

DbSelectArea("SB1")  // Produtos
SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD 

DbSelectArea("SB2")  // Saldos Fisicos e Financeiro
SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL  
  
DbSelectArea("SB7")  // Lançamentos do Inventário
SB7->(DbSetOrder(3)) //	B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL

FT_FUse(cArquivo) //abre o arquivo
FT_FGOTOP()       //posiciona na primeira linha do arquivo

ProcRegua(FT_FLASTREC())

While !FT_FEOF() 

	nContLin++ 
    
	If !lPrimLin
		
		nCntPro++
		
		IncProc("Verificando produtos para lançamento do inventário... ("+cValToChar(nCntPro)+")")
		
		cLinha := FT_FREADLN()
		
		aProduto := Separa(cLinha,';',.F.)  
		
		If Len(aProduto) <> 9  
				
			cMsg += " - Linha "+StrZero(nContLin,4)+": "+"Verificar célula(s) vazia(s)." + CHR(13) + CHR(10)  
			lRetOk := .F.
		
		Else
		   
			cCodPro := Padr(Alltrim(aProduto[1]),TamSx3("B1_COD")[1])
			cTipPro	:= Alltrim(aProduto[2])
			cGrpPro	:= Alltrim(aProduto[3])
			cDesPro	:= Alltrim(aProduto[4])
			cUnMPro	:= Alltrim(aProduto[5])
			cFilPro	:= Alltrim(aProduto[6])
			cAmzPro	:= Alltrim(aProduto[7])
			cQntPro := Alltrim(aProduto[8])
			cQFsPro := Alltrim(aProduto[9])
			
			If ! SB1->(DbSeek(xFilial("SB1")+cCodPro))   
			    
				cMsg += " - Linha "+StrZero(nContLin,4)+": "+"Produto ("+Alltrim(cCodPro)+") não cadastrado." + CHR(13) + CHR(10)
				lRetOk := .F.  
				
			EndIf
			
			If cFilPro <> cFilAnt   
			
				cMsg += " - Linha "+StrZero(nContLin,4)+": "+"Filial ("+cFilPro+") é diferente do parâmetro." + CHR(13) + CHR(10) 
				lRetOk := .F.    
				
			EndIf
			    			
			If cAmzPro <> cArmazem   
			
				cMsg += " - Linha "+StrZero(nContLin,4)+": "+"Armazém ("+cAmzPro+") é diferente do parâmetro." + CHR(13) + CHR(10)
				lRetOk := .F.
				
			EndIf
								
			If SB7->(DbSeek(xFilial("SB7")+cDocInv+cCodPro+cAmzPro))  // B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL 
			    
				cMsg += " - Linha "+StrZero(nContLin,4)+": "+"Inventário já foi realizado. Doc.: "+Alltrim(cDocInv)+"." + CHR(13) + CHR(10)
				lRetOk := .F.
			
			EndIf 
			
			If lBlqPar 
			
				// Verifica se existe inventário para p a chave produto + quantidade + data   
				cDocExist := fValChave(cCodPro,cValToChar(Val(cQFsPro)),dDataInv)
				
				If !Empty(cDocExist)
					
					cMsg += " - Linha "+StrZero(nContLin,4)+": "+"Produto já importado nesta data. Data: " + DtoC(dDataInv) + " Doc: " + cDocExist + CHR(13) + CHR(10)
					lRetOk := .F.
				
				EndIf								     
			
			EndIf
			
			aAdd(aProdInv,aProduto)
					 	
		EndIf	
		
	Else
	
		lPrimLin := .F.
		
	EndIf
		           
	FT_FSKIP()
	
EndDo
			
FT_FUSE() 

If lRetOk  
      
	Processa({|| fProcessa( cFilInv, cArmazem, dDataInv, cDocInv, aProdInv, @cMsg ) },"Inventário")

Else 

	cMsg := "A planilha possui erros e não será possível a importação para lançamentos do inventário!" + ;
			 CHR(13) + CHR(10) + CHR(13) + CHR(10) + cMsg 
    
EndIf

Return     



//------------------------------------------------------------------- 
/*/{Protheus.doc} fProcessa()
Processa a importação do inventário     

@param 		cFilInv - Filial para o inventário
			cArmazem - Armazém para o inventário
			dDataInv - Data do inventário
			cDocInv - Nome do documento do inventário
			aProdInv - Produtos para inventário
			cMsg - Mensagens para o log

@author 	Alessandro Smaha 
@since 		05/12/2014
@version 	P11 
/*/ 
//-------------------------------------------------------------------
Static Function fProcessa( cFilInv, cArmazem, dDataInv, cDocInv, aProdInv, cMsg )   
                     
	Local cChar    := ""
	Local nI 	   := 0 
	Local nCntPro  := 0 
	Local aProduto := {}   
	Local aErros   := {}
	Local aImpOk   := {}
	Local aImpVr   := {}   
	Local aImpBl   := {}
	Local lPrimLin := .T.

	DbSelectArea("SB1")  // Produtos
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD 
	
	DbSelectArea("SB2")  // Saldos Fisicos e Financeiro
	SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL  
	  
	DbSelectArea("SB7")  // Lançamentos do Inventário
	SB7->(DbSetOrder(3)) //	B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL
	        
	nCntPro := Len(aProdInv)
	
	ProcRegua(nCntPro)
	   
	If !Empty(aProdInv)
		
		Begin Transaction
			
			For nI := 1 to Len(aProdInv)
			     
				IncProc("Verificando produtos para lançamento do inventário... ("+cValToChar(nI)+")")
				
			 	fImporta( aProdInv[nI], cFilInv, cArmazem, dDataInv, cDocInv, @aErros, @aImpOk, @aImpVr, @aImpBl ) 
			 	
			 	If !Empty(aErros)
			 	    Disarmtransaction()	 	     
			 		Exit
			 	EndIf
			
			Next nI	  
			
		End Transaction	
		
	EndIf
	
	If !Empty(aErros) .OR. !Empty(aImpOk) .OR. !Empty(aImpVr) .OR. !Empty(aImpBl)
	
		cMsg += "Total de Linhas Verificadas no Arquivo: "+cValToChar(nCntPro)
    	
		cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)
		cMsg += "Lançamentos do Inventário Criados ("+cValToChar(Len(aImpOk))+"):"+ CHR(13) + CHR(10)  
	
	    // Arquivos de saldos criados         		       
		If !Empty(aImpOk) 
				
		    For nI := 1 to Len(aImpOk) 
		    	
		    	cMsg  += cChar + aImpOk[nI]		    	
		    	cChar := ", "
		    
		    Next nI
		    
		EndIf 
    	
		cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)				
		cMsg += "Produtos que já foram inventariados ("+cValToChar(Len(aImpVr))+"):"+ CHR(13) + CHR(10) 
		    
		// Arquivos que estão ok
		If !Empty(aImpVr) 
		
			cChar := ""
		
		    For nI := 1 to Len(aImpVr) 
		    	
		    	cMsg  += cChar + aImpVr[nI]		    	
		    	cChar := ", "
		    
		    Next nI
		    
		EndIf 	
	
		cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)
		cMsg += "Erros ao lançar inventário ("+cValToChar(Len(aErros))+"):"+ CHR(13) + CHR(10)  
		
	   // Arquivos com erros			
		If !Empty(aErros) 
		   
			cChar := ""
		
		    For nI := 1 to Len(aErros) 
		    	
		    	cMsg  += cChar + aErros[nI]		    	
		    	cChar := ", "
		    
		    Next nI
		    
		EndIf    
		
		cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)				
		cMsg += "Produtos bloqueados ("+cValToChar(Len(aImpBl))+"):"+ CHR(13) + CHR(10) 
				
		// Itens bloqueados
		If !Empty(aImpBl) 
		
			cChar := ""
		
		    For nI := 1 to Len(aImpBl) 
		    	
		    	cMsg  += cChar + aImpBl[nI]		    	
		    	cChar := ", "
		    
		    Next nI
		    
		EndIf 	
			
	Else
	
		cMsg += "Nenhum registro foi encontrado!"
					
	EndIf 
	
Return 


//------------------------------------------------------------------- 
/*/{Protheus.doc} fImporta()
Importa os produtos para o inventário     

@param 		aProd - Array com os dadod do produto para inventario
			cFilInv - Filial para o inventário 
			cArmazem - Armazem para o inventário
			dDtInv - Data para o inventário 
			cCodDoc - Nome do documento do inventário 
			aErros - Array com erros ao gerar inventário  
			aImpOk - Array com os itens ok 
			aImpVr - Array com itens que já foram importados 
			aImpBl - Array com itens bloqueados 

@author 	Alessandro Smaha 
@since 		05/12/2014
@version 	P11 
/*/ 
//-------------------------------------------------------------------
Static Function fImporta( aProd, cFilInv, cArmazem, dDtInv, cCodDoc, aErros, aImpOk, aImpVr, aImpBl ) 

	Local cCodPro 	:= Padr(Alltrim(aProd[1]),TamSx3("B1_COD")[1])
	Local cTipPro	:= Alltrim(aProd[2])
	Local cGrpPro	:= Alltrim(aProd[3])
	Local cDesPro	:= Alltrim(aProd[4])
	Local cUnMPro	:= Alltrim(aProd[5])
	Local cFilPro	:= Alltrim(aProd[6])
	Local cAmzPro	:= Alltrim(aProd[7])
	Local cQntPro 	:= Alltrim(aProd[8])
	Local cQFsPro 	:= Alltrim(aProd[9])
	Local aItem   	:= {}   
	Local nQntPro	:= 0
	Local nQFsPro	:= 0 
	Local cTxtLog	:= ""
	 
	Private lMsErroAuto := .F.
	
	// 1=Produto;2=Tipo;3=Grupo;4=Descricao;5=Unidade;6=Filial;7=Armazem;8=Qtde.1a.U.M.;9=Fisico
 	
	cQntPro := StrTran(cQntPro,".", "")
	cQntPro := StrTran(cQntPro,",",".")	
	nQntPro := Val(cQntPro)   
	
	cQFsPro := StrTran(cQFsPro,".", "")
	cQFsPro := StrTran(cQFsPro,",",".")	
	nQFsPro := Val(cQFsPro)          
	
	If SB1->(DbSeek(xFilial("SB1")+cCodPro)) 
	    
		If SB1->B1_MSBLQL == "1" // 1=Sim;2=Não
			
			aAdd(aImpBl,Alltrim(cCodPro))     
			
		Else
			
			If ! SB7->(DbSeek(xFilial("SB7")+cCodDoc+cCodPro+cAmzPro)) // B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL
		              
				aItem := {	{"B7_FILIAL" , 	xFilial("SB7"),Nil},;
							{"B7_COD",		cCodPro,Nil},;
							{"B7_DOC", 		cCodDoc,Nil},;
							{"B7_QUANT",	nQFsPro,Nil},;
							{"B7_LOCAL",	cAmzPro,Nil},;
							{"B7_DATA",		dDtInv,	Nil} }
							
				MSExecAuto({|x,y| mata270(x,y)},aItem,.F.,3)  
		
				If lMsErroAuto
					cTxtLog := NomeAutoLog()
					If ValType( cTxtLog ) == 'C'
						AAdd( aErros, Memoread( cTxtLog ) )
					EndIf
				Else
					aAdd(aImpOk,Alltrim(cCodPro))	
				Endif 
				
			Else
		   	
		   		//"Produto já lançado no inventário"
		   		aAdd(aImpVr,Alltrim(cCodPro))
			
			EndIf
		    
		EndIf
		
	EndIf
			
Return 


//------------------------------------------------------------------- 
/*/{Protheus.doc} fTelaLog()
Exibe a tela de log após a atualização de saldos  

@param 		cMsg - String de mensagem de log  
			lGrava - Realiza a gravação do arquivo de log

@author 	Alessandro Smaha 
@since 		05/02/2014
@version 	P11 
/*/ 
//-------------------------------------------------------------------
Static Function fTelaLog(cMsg,lGrava)

	Local  cMask	:= "Arquivos Texto (*.TXT) |*.txt|"
	Local _cFile	:= ""   
	
	cMsg := 	"Log Inventário (MEST003) Filial " + CHR(13) + CHR(10) + cFilAnt + "-"+ FWFilialName() + CHR(13) + CHR(10) + ;
				"Data: "+DtoC(Date())+" Hora Inicio: "+_cHorInic+" Hora Fim: "+Time() +;
			 	CHR(13) + CHR(10) + Replicate("-",60) + CHR(13) + CHR(10) + cMsg
    
    If lGrava       
		U_MEST003G("MEST003_Log Inventário da planilha",cMsg)
	EndIf

	// TELA PARA MOSTRAR O LOG E DAR OPÇÃO DE SALVAR O LOG
	__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cMsg)
	DEFINE FONT oFont NAME "Mono AS" SIZE 6,15  
	DEFINE MSDIALOG oDlg TITLE "Atualização concluida." From 3,0 to 340,417 PIXEL
	@ 5,5 GET oMemo  VAR cMsg MEMO SIZE 200,145 OF oDlg PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
//	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (_cFile:=cGetFile(cMask,""),If(_cFile="",.t.,MemoWrite(_cFile,cMsg))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

	ACTIVATE MSDIALOG oDlg CENTER
	
Return                                    


//------------------------------------------------------------------- 
/*/{Protheus.doc} MEST003G()
Grava o arquivo de log na pasta logs_estoque no server 

@param 		cIdLog - Nome para o log
			cContTxt - Arquivo

@author 	Alessandro Smaha 
@since 		05/12/2014
@version 	P11 
/*/ 
//-------------------------------------------------------------------
User Function MEST003G(cIdLog,cContTxt)
             
	Local cDirLog  := "\log_estoque_afs\"
	Local cArqNovo := cDirLog+DtoS(dDataBase)+"_"+SubStr(Time(),1,2)+"H"+SubStr(Time(),4,2)+"M"+SubStr(Time(),7,2)+"S"+"_"+cIdLog+".txt"  
	
	// Cria o diretorio se não existir
	MontaDir(cDirLog)
		
	//Cria arquivo no diretório
	nHandle  := FCREATE(cArqNovo, 0) 
			
	// Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido
	If FERROR() <> 0 
		
		Conout("Não foi possível abrir ou criar o arquivo: " + cArqNovo )
	
	Else
			
		Conout("Criou o arquivo: " + cArqNovo )
		FWrite( nHandle, cContTxt )
		FCLOSE(nHandle)
		dbCommit()  
		MsgInfo("Arquivo de log salvo. "+cArqNovo,"Aviso")
					
	Endif
	
Return


//------------------------------------------------------------------- 
/*/{Protheus.doc} fValChave()
Verifica o item se já foi importado

@author 	Alessandro Smaha 
@since 		04/12/2014
@version 	P11                                                                                                          

/*/ 
//-------------------------------------------------------------------
Static Function fValChave(cCodPro,cQFsPro,dDataInv)    

Local cQuery 	:= ""
Local cDocRet	:= ""

If (Select("QSB7") <> 0)	
	DbSelectArea("QSB7")
	QSB7->(DbCloseArea())	
Endif
                               
cQuery := " SELECT B7_DOC " 
cQuery += " FROM "+RetSQLName("SB7")+" "
cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"' "
cQuery += " 	AND B7_COD = '"+cCodPro+"' "
cQuery += " 	AND B7_QUANT = "+Alltrim(cQFsPro)  
cQuery += " 	AND B7_DATA = '"+DtoS(dDataInv)+"' "
cQuery += " 	AND D_E_L_E_T_ <> '*' "
	
TCQuery cQuery new Alias "QSB7"

QSB7->(DbGoTop())

If QSB7->(!Eof())
	cDocRet	:= Alltrim(QSB7->B7_DOC)
EndIf

QSB7->(DbCloseArea())

Return cDocRet



//------------------------------------------------------------------- 
/*/{Protheus.doc} AjustaSx1()
Cria as perguntas para o SX1

@author 	Alessandro Smaha 
@since 		05/12/2014
@version 	P11                                                                                                          

/*/ 
//-------------------------------------------------------------------
Static Function fAjustaSx1()
      
 	PutSx1(cPerg,"01","Filial?","Filial?","Filial?",							"mv_ch1","C",TamSX3("B7_FILIAL")[1]	,0,0,"G","","XM0","","","mv_par01","","","","","","","","","","","","","","","","",{"Filial para importação do Inventário.","","",""},{"Filial para importação do Inventário.","","",""},{"Filial para importação do Inventário.","",""},"")
    PutSx1(cPerg,"02","Armazém?","Armazém?","Armazém?",							"mv_ch2","C",TamSX3("B7_LOCAL")[1]	,0,0,"G","","NNR","","","mv_par02","","","","","","","","","","","","","","","","",{"Armazém para importação do Inventário.","","",""},{"Armazém para importação do Inventário.","","",""},{"Armazém para importação do Inventário.","",""},"")
 	PutSx1(cPerg,"03","Data Inventário?","Data Inventário?","Data Inventário?",	"mv_ch3","D",08,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","",{"Data do Inventário.","","",""},{"Data do Inventário.","","",""},{"Data do Inventário.","",""},"")
	PutSx1(cPerg,"04","Doc. Inventário?","Doc. Inventário?","Doc. Inventário?",	"mv_ch4","C",09,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","",{"Nome do Documento para importação do Inventário.","","",""},{"Nome do Documento para importação do Inventário.","","",""},{"Nome do Documento para importação do Inventário.","",""},"")
  
Return