#INCLUDE "TOTVS.CH"
#INCLUDE "REPORT.CH"    
#INCLUDE "TOPCONN.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} RCOM002
Relatório análise de ponto de pedido
                
@sample		U_RCOM002()

@author		Alessandro Smaha
@since		16/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function RCOM002()        

	Local oReport      
	
	Private cPerg := "RCOM002"   
	Private lWeb  := .F. //Valida se o relatorio é para WEB
			
	AjustaSX1()
	If ! Pergunte(cPerg,.T.) 	
		Return     	
	EndIf

	oReport := fRelFonDef()
		
	If !lWeb
		oReport:PrintDialog()
	Endif
         
Return             


//-------------------------------------------------------------------
/*/{Protheus.doc} fRelFonDef
Definição do relatorio
                
@sample		fRelFonDef()

@author		Alessandro Smaha
@since		16/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fRelFonDef()   

	Local cTitle    := OemToAnsi("Análise de Ponto de Pedido")
	Local cHelp     := OemToAnsi("Impressão do Relatório de Análise de Ponto de Pedido")
	
	Local oReport   := Nil
	Local oSection1 := Nil
		                                        
	oReport := tReport():New(cPerg,cTitle,cPerg,{|oReport| fReportPrint(oReport)},cHelp)
	
	oReport:SetLandscape()
	//oReport:HideParamPage()
		
	oSection1 := trSection():New(oReport,cTitle,{"SB1"})   
	 
	trCell():New(oSection1,"BM_GRUPO","SBM","Grupo",PesqPict("SBM","BM_GRUPO"),6,,{|| aItens[nI][1] })
	trCell():New(oSection1,"B1_COD","SB1","Código",PesqPict("SB1","B1_COD"),16,,{||  aItens[nI][2] })	
	trCell():New(oSection1,"B1_DESC","SB1","Descrição",PesqPict("SB1","B1_DESC"),33,,{||  aItens[nI][3] })	
	trCell():New(oSection1,"B1_UM","SB1","UM",PesqPict("SB1","B1_UM"),TamSX3("B1_UM")[1]+1,,{||  aItens[nI][4] })  
	
	trCell():New(oSection1,"SALDO_ATUAL","SB2","Saldo Atual",PesqPict("SB2","B2_QATU"),18,,{||  aItens[nI][11] },,,"RIGHT")
	trCell():New(oSection1,"ENT_PREVISTA","","Entrada Prevista",PesqPict("SB2","B2_QATU"),18,,{||  aItens[nI][12] },,,"RIGHT") 
	trCell():New(oSection1,"SLD_PREVISTO","","Saldo Previsto",PesqPict("SB2","B2_QATU"),18,,{||  aItens[nI][13] },,,"RIGHT") 
	trCell():New(oSection1,"BZ_EMIN","SBZ","Ponto Pedido",PesqPict("SBZ","BZ_EMIN"),18,,{||  aItens[nI][10] },,,"RIGHT") 
	trCell():New(oSection1,"PONTO_PEDIDO_LBL","","Novo Ponto Pedido","",19,,{|| Replicate("_",15) },"RIGHT",,"RIGHT")            
	trCell():New(oSection1,"DATA_COMP","","Dt Ult Compra","",13,,{||  aItens[nI][5] })
	trCell():New(oSection1,"QTDE_COMP","","Qt Ult Compra",PesqPict("SD1","D1_QUANT"),18,,{||  aItens[nI][6] },,,"RIGHT") 
	trCell():New(oSection1,"CONS_M3","","Cons - M3",PesqPict("SD1","D1_QUANT"),15,,{||  aItens[nI][7] },,,"RIGHT")                       
	trCell():New(oSection1,"CONS_M2","","Cons - M2",PesqPict("SD1","D1_QUANT"),15,,{||  aItens[nI][8] },,,"RIGHT")  
	trCell():New(oSection1,"CONS_M1","","Cons - M1",PesqPict("SD1","D1_QUANT"),15,,{||  aItens[nI][9] },,,"RIGHT")
	trCell():New(oSection1,"CONS_M0","","Cons - M0",PesqPict("SD1","D1_QUANT"),15,,{||  aItens[nI][15] },,,"RIGHT")
	 
	lTSecao := .F.
	lTGeral := .T.
		
	TRFunction():New(oSection1:Cell("B1_COD"),NIL,"COUNT",,,,,lTSecao,lTGeral)	

	oReport:SetTotalInLine(.F.) 
	
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} fReportPrint
Impressao do relatorio
                
@sample		fReportPrint(oReport)

@author		Alessandro Smaha
@since		16/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fReportPrint(oReport)
                                          
	Local cQuery := ""                             
	Local oSection1 := oReport:Section(1)  
		
	Local cLocCQ    := GetMV("MV_CQ")
	Local nNeces    := 0
	Local nAuxQuant := 0
	Local nSaldAux	:= 0
	Local nX        := 0
	Local lValidSB1 := .T.  
	Local lQtdPrev  := SuperGetMV('MV_QTDPREV')

	// Variaveis utilizadas para Tratamento da impressao por Filiais
	Local aFilsCalc :={}
	Local nForFilial:= 0
	Local cFilBack  := cFilAnt  
	Local cCpoMes 	:= "" 
	Local cCpo3o 	:= ""
	Local cCpo2o 	:= ""
	Local cCpo1o 	:= ""
	Local cTitForn  := ""
	Local nMesRel	:= 0   
	Local lTodos 	:= .T.  
	Local lImpOk 	:= .T.	
	Local cSimbolo  := ">" 
	Local cOrdem1   := ""   
	Local cDescPro  := ""
	
	Private cTipoVal := ""
	Private nQuant   := 0
	Private nSaldo   := 0
	Private nValUnit := 0
	Private nValor   := 0
	Private nPrazo   := 0
	Private nToler   := 0
	Private nEstSeg  := 0
	Private nPrevis  := 0  
	Private nQtdeCom := 0     
	Private nCons0o	 := 0
	Private nCons1o	 := 0
	Private nCons2o	 := 0
	Private nCons3o	 := 0
	Private dDataCom := CtoD("  /  /  ")   
	Private nPontoPed := 0         
	Private aItens	 := {}    
	Private nI		 := 0
		
	nMesRel := Month(dDataBase) 			
	If nMesRel < 4
		If nMesRel == 3  		
			cCpo3o := "B3_Q12"
			cCpo2o := "B3_Q01"
			cCpo1o := "B3_Q02"
			cCpo0o := "B3_Q03"
		ElseIf nMesRel == 2
			cCpo3o := "B3_Q11"
			cCpo2o := "B3_Q12"
			cCpo1o := "B3_Q01"
			cCpo0o := "B3_Q02"			
		Else // nMesRel == 1		
			cCpo3o := "B3_Q10"
			cCpo2o := "B3_Q11"
			cCpo1o := "B3_Q12"
			cCpo0o := "B3_Q01"
		EndIf	
	Else  
		cCpo3o := "B3_Q"+StrZero(nMesRel-3,2)
		cCpo2o := "B3_Q"+StrZero(nMesRel-2,2)
		cCpo1o := "B3_Q"+StrZero(nMesRel-1,2)					
		cCpo0o := "B3_Q"+StrZero(nMesRel,2)
	EndIf
	
	If ( Select("TQRY") ) > 0
		DbSelectArea("TQRY")
		TQRY->(dbCloseArea())
	EndIf    
	
	DbSelectArea("SA2") 
	SA2->(DbSetOrder()) // A2_FILIAL+A2_COD+A2_LOJA
	
	DbSelectArea("SB1") 
	SB1->(DbSetOrder()) // B1_FILIAL+B1_COD
	
	DbSelectArea("SB2") 
	SB2->(DbSetOrder()) // B2_FILIAL+B2_COD+B2_LOCAL
	
	DbSelectArea("SB3") 
	SB3->(DbSetOrder()) // B3_FILIAL+B3_COD
		
	DbSelectArea("SD1") 
	SD1->(DbSetOrder()) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		
	DbSelectArea("SBZ") 
	SBZ->(DbSetOrder()) // BZ_FILIAL+BZ_COD
        
   	If Empty(mv_Par21) // Fornecedor ?
	   				
		cQuery := " SELECT SB1.* FROM " + RetSqlName("SB1")+" SB1 "
		cQuery += " WHERE SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
		cQuery += " SB1.B1_COD    >='" +mv_Par01+"' AND SB1.B1_COD <='"   +mv_Par02+"' AND "
		cQuery += " SB1.B1_GRUPO  >='" +mv_Par03+"' AND SB1.B1_GRUPO <='" +mv_Par04+"' AND "
		cQuery += " SB1.B1_TIPO   >='" +mv_Par05+"' AND SB1.B1_TIPO <='"  +mv_Par06+"' AND "
		cQuery += " SB1.B1_LOCPAD >='" +mv_Par07+"' AND SB1.B1_LOCPAD <='"+mv_Par08+"' AND " 
		cQuery += " SB1.B1_MSBLQL  <> '1' AND "
		cQuery += " SB1.B1_CONTRAT <> 'S' AND "
		cQuery += " SB1.B1_TIPO    <> 'BN' AND "
		cQuery += " SB1.D_E_L_E_T_ = ' ' "    
		cQuery += " ORDER BY SB1.B1_FILIAL, SB1.B1_COD "
		 
   	Else   
   	
  		cQuery := " SELECT '" + MV_PAR21 + "' D1_FORNECE, " 
		cQuery += "        '" + MV_PAR22 + "' D1_LOJA, " 
		cQuery += "        SB1A.* " 
		cQuery += " FROM   (SELECT D1_FILIAL, " 
		cQuery += "                D1_COD " 
		cQuery += "         FROM   " + RetSqlName("SD1") + " SD1 " 
		cQuery += "                INNER JOIN " + RetSqlName("SB1") + " SB1 " 
		cQuery += "                        ON B1_COD = D1_COD " 
		cQuery += "                           AND B1_MSBLQL  <> '1' " 
		cQuery += "                           AND B1_CONTRAT <> 'S' " 
		cQuery += "                           AND B1_TIPO <> 'BN' " 
		cQuery += "                           AND SB1.D_E_L_E_T_ <> '*' " 
		cQuery += "         WHERE  SD1.D_E_L_E_T_ <> '*' " 
		cQuery += "                AND D1_FILIAL = '" + xFilial("SD1") + "' " 
		cQuery += "                AND D1_FORNECE = '" + MV_PAR21 + "' " 
		cQuery += "                AND D1_LOJA    = '" + MV_PAR22 + "' " 
		cQuery += "         GROUP  BY D1_FILIAL, " 
		cQuery += "                   D1_COD) AS TRABA " 
		cQuery += "        INNER JOIN " + RetSqlName("SB1") + " SB1A " 
		cQuery += "                ON SB1A.B1_COD = D1_COD " 
		cQuery += "                   AND SB1A.D_E_L_E_T_ <> '*' " 
		cQuery += " ORDER  BY D1_COD " 
  		        
		If SA2->(DbSeek(xFilial("SA2")+mv_Par21+mv_Par22))
			cTitForn := oReport:Title()+" - "+Alltrim(SA2->A2_NREDUZ)  
			oReport:SetTitle(cTitForn)
		EndIf		

	EndIf
	                

	TCQUERY cQuery NEW ALIAS "TQRY" 
		
	DbSelectArea("TQRY")
	
	oReport:SetMeter(0) 
	
	If mv_Par23 == 1 //Imprime Itens ? 1="Todos os Itens",2="Ponto de pedido"
	
	EndIf
	 	 
	TQRY->(DbGoTop()) 
	
	While !oReport:Cancel() .And. !TQRY->(Eof())  
	
		oReport:IncMeter()  
		
		If Alltrim(TQRY->B1_COD) == "3844"   
			cTeste := ""		
		EndIf
	
		SB1->(DbSeek(xFilial("SB1")+TQRY->B1_COD))  

		// Calcula o saldo atual de todos os almoxarifados
		DbSelectArea("SB2")
		DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
		DbSeek( xFilial("SB2") + TQRY->B1_COD )
	
		While !SB2->(Eof()) .And. SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2") + TQRY->B1_COD
	
	        If ( SB2->B2_LOCAL >= mv_par16 .And. SB2->B2_LOCAL <= mv_par17 ) .And. !( SB2->B2_LOCAL == cLocCQ .And. mv_par11 == 2 )
				nSaldo +=(SaldoSB2(Nil,Nil,If(Empty(mv_par18),dDataBase,mv_par18),mv_par12==1,mv_par13==1)+SB2->B2_SALPEDI+SB2->B2_QACLASS+IIF(lQtdPrev="S",SB2->B2_SALPPRE,0))
				If mv_par14 == 1
					nSaldo -= SB2->B2_QPEDVEN
				EndIf
				nPrevis += SB2->B2_SALPEDI
	        EndIf
	        
			SB2->(DbSkip())
		EndDo
	               
		nEstSeg := CalcEstSeg( RetFldProd(TQRY->B1_COD,"B1_ESTFOR","TQRY"),"TQRY" )

		If mv_par20 == 1
			nSaldo -= nEstSeg
		EndIf
	       
		If (Round(nSaldo,4) <> 0) .Or. (mv_par09 == 1)
			Do Case
				Case ( RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY") != 0 .And. MV_PAR09 == 1 )
	
					If ( mv_par10 == 2 .And. nSaldo < 0 )
						nSaldo -= RetFldProd(TQRY->B1_COD,"B1_LE","TQRY")
					EndIf
		
					nNeces := If((nSaldo < 0),Abs(nSaldo)+RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY"),;
							(If(QtdComp(nSaldo)==QtdComp(RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY")),1,0);
							+RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY")-nSaldo))
	          
				    //-- Soma 1 na quantidade da necessidade:
				    //-- Ex: Ponto Pedido = 10 e Estoque = 9, ao inves de gerar 2 SCs de 1 pc ira gera 1 SC de 2 pcs (para sair do ponto de pedido) 										
					If nSaldo <  QtdComp(RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY")) //-- Se o Saldo for menor que o Ponto do Pedido
						nNeces += 1 
					EndIf
	
				Case ( RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY") != 0 .And. MV_PAR09 == 2 )
	
					If ( mv_par10 == 2 .And. nSaldo < 0 )
						nSaldo -= RetFldProd(TQRY->B1_COD,"B1_LE","TQRY")
					EndIf
	
					nNeces := If((nSaldo < 0),Abs(nSaldo),;
								(If(QtdComp(nSaldo) ==  QtdComp(RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY")),1,0);
								+RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY")-nSaldo))
	
				    //-- Soma 1 na quantidade da necessidade:
				    //-- Ex: Ponto Pedido = 10 e Estoque = 9, ao inves de gerar 2 SCs de 1 pc ira gera 1 SC de 2 pcs (para sair do ponto de pedido) 										 										
					If nSaldo <  QtdComp(RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY")) //-- Se o Saldo for menor que o Ponto do Pedido
						nNeces += 1 
					EndIf           
				
				Case ( RetFldProd(TQRY->B1_COD,"B1_LE","TQRY") != 0 .And. (nSaldo < 0  .or. mv_par09 == 2) )
	
					If ( mv_par10 == 2 .And. nSaldo < 0 )
						nNeces := Abs(nSaldo)+RetFldProd(TQRY->B1_COD,"B1_LE","TQRY")
					Else
						nNeces := If( Abs(nSaldo)<RetFldProd(TQRY->B1_COD,"B1_LE","TQRY"),RetFldProd(TQRY->B1_COD,"B1_LE","TQRY"),if(nSaldo<0,Abs(nSaldo),0))
					EndIf

				OtherWise

					nNeces := IF(mv_par09 == 1,IIf(nSaldo<0,Abs(nSaldo)+1,0),0)
			EndCase
		Else
			If RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY") != 0
				nNeces := ( RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY") )
				nNeces += 1 
			Else
				nNeces := 0
			EndIf
		EndIf

		fUltCompra( TQRY->B1_COD, @dDataCom, @nQtdeCom ) 
		
		If SB3->(DbSeek(xFilial("SB3")+TQRY->B1_COD))   			
	  		nCons0o	 := SB3->&cCpo0o
			nCons1o	 := SB3->&cCpo1o
			nCons2o	 := SB3->&cCpo2o
			nCons3o	 := SB3->&cCpo3o
		Else 
			nCons0o	 := 0
			nCons1o	 := 0
			nCons2o	 := 0
			nCons3o	 := 0		
		EndIf
		      
		If nNeces > 0
			// Verifica se o produto tem estrutura 
			DbSelectArea("SG1")
			If SG1->(DbSeek( xFilial("SG1")+TQRY->B1_COD ))
				aQtdes := CalcLote(TQRY->B1_COD,nNeces,"F")
			Else                  
				aQtdes := CalcLote(TQRY->B1_COD,nNeces,"C")
			Endif
			For nX := 1 to Len(aQtdes)
				nQuant += aQtdes[nX]
			Next
		EndIf
		
		nPontoPed := RetFldProd(TQRY->B1_COD,"B1_EMIN","TQRY")
		
		If MV_PAR23 == 2 // 1=Todos os Itens,2=Ponto de pedido  
		       
			// Alterado, solicitado por Mauricio. Antes estava -> nSaldo - nPrevis < nPontoPed // Saldo atual < ponto de pedido
			If nSaldo < nPontoPed // Saldo Previsto < ponto de pedido
			
				lTodos := .T.
				
			Else
			
				lTodos := .F.
				
			EndIf
			
		EndIf  
		
		lImpOk := .T.
				
		If MV_PAR26 == 2 // Imprime Ponto de Pedido zerado ? 1=Sim;2=Não
			
			If nPontoPed == 0 .AND. nSaldo - nPrevis == 0
				
				lImpOk := .F.
				
			EndIf
			
		EndIf
		
		If lTodos .AND. lImpOk    
		                  
			If mv_par15 == 1 // Descricao completa produto ?  1=Não,2=Sim
				cDescPro := SubStr(SB1->B1_DESC,1,20)
			Else
				cDescPro := SubStr(SB1->B1_DESC,1,60)
			EndIf			
			
			aAdd(aItens,{	SB1->B1_GRUPO,;  
							SUBSTR(SB1->B1_COD,1,15),;
							cDescPro,;
							SB1->B1_UM,;     
							dDataCom,;
							nQtdeCom,;
							nCons3o,;
							nCons2o,;
							nCons1o,;
							nPontoPed,;
							nSaldo - nPrevis,;
							nPrevis,;
							nSaldo,;
							(nSaldo - nPrevis) - nPontoPed,;
							nCons0o}) // Saldo Atual - Ponto de Pedido (utilizado apenas para ordenação do relatório)
										
		EndIf
	
		nSaldo := 0
		nQuant := 0
		nPrevis:= 0
		       
		TQRY->(DbSkip())
	EndDo 
	
	// Ordem Crescente ou Decrescente	
	If MV_PAR25 == 1 // Crescente
		
		cSimbolo := "<"
	
	Else // Decrescente  
	
		cSimbolo := ">"
	
	EndIf  
	
	// Ordem por (Saldo - Ponto de Pedido)
	If MV_PAR24 == 1 //  1=(Saldo Atual - Ponto de Pedido)
	
		cOrdem1 := " x[14] "+cSimbolo+" y[14] "

	ElseIf MV_PAR24 == 2 // 2=Saldo Atual  
	
		cOrdem1 := " x[11] "+cSimbolo+" y[11] "
	
	Else // Descrição
	
		cOrdem1 := " x[3] "+cSimbolo+" y[3] "
		
	EndIf  
	
	aItens := aSort(aItens,,,&("{ |x,y| "+cOrdem1+"}"))

	oSection1:Init()	   
	
	For nI := 1 to Len(aItens) 
	
		If oReport:Cancel()
			Exit
		EndIf 
	     
		oSection1:PrintLine()
		
	Next nI
	
	oSection1:Finish()	
	
Return      


//-------------------------------------------------------------------
/*/{Protheus.doc} fUltCompra
Busca a data e quantidade da ultima compra do produto 
                
@sample		fUltCompra( cCodPro, dDataCom, nQtdeCom ) 

@author		Alessandro Smaha
@since		17/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fUltCompra( cCodPro, dDataCom, nQtdeCom )  
     
 	Local cQuery := ""
 	
	If ( Select("QSD1") ) > 0
		DbSelectArea("QSD1")
		QSD1->(dbCloseArea())
	EndIf    
		
	cQuery += " SELECT D1_FILIAL, D1_COD, D1_QUANT, D1_DTDIGIT "
	cQuery += " FROM " + RetSqlName("SD1")+" "
	cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
	cQuery += " 	AND D1_COD = '"+cCodPro+"' "    
	cQuery += "		AND D1_TIPO = 'N' "
	cQuery += " 	AND D_E_L_E_T_ <> '*' " 
	cQuery += " ORDER BY D1_DTDIGIT DESC "

 
	TCQUERY cQuery NEW ALIAS "QSD1" 
		
	DbSelectArea("QSD1")		
	QSD1->(DbGoTop())  
	
	If ! QSD1->(Eof()) 
   		dDataCom := StoD(QSD1->D1_DTDIGIT)
   		nQtdeCom := QSD1->D1_QUANT
	Else
   		dDataCom := CtoD("  /  /  ")
   		nQtdeCom := 0				
	EndIf	
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas para impressão do relatório
                
@sample		AjustaSX1()

@author		Alessandro Smaha
@since		16/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function AjustaSX1()

	Local aHelpPor01 := {"A partir do código do Produto."}
	Local aHelpPor02 := {"Até o código do Produto."}
	Local aHelpPor03 := {"A partir do código do Grupo."}
	Local aHelpPor04 := {"Até o código do Grupo."}
	Local aHelpPor05 := {"A partir do Tipo de Produto."}
	Local aHelpPor06 := {"Até o Tipo de Produto."}
	Local aHelpPor07 := {"A partir do Armazem Padrao."}
	Local aHelpPor08 := {"Até o Armazem Padrao."}	
	Local aHelpPor09 := {"Considerar Necessidade Bruta ?","Sim ou Não"}
	Local aHelpPor10 := {"Saldo Negativo a Considerar ?","Sim ou Não"}
	Local aHelpPor11 := {"Listar Produtos do C.Q. ?","Sim ou Não"}
	Local aHelpPor12 := {"Listar Qtde 3o. Nosso Poder ?","Sim ou Não"}
	Local aHelpPor13 := {"Listar Qtde Nossa Poder 3o. ?","Sim ou Não"}
	Local aHelpPor14 := {"Qtd. PV nao Liberado ?","Subtrai ou Ignora"}
	Local aHelpPor15 := {"Descricao completa produto ?","Não ou Sim"}
	Local aHelpPor16 := {"Considera Saldo Armazem a partir de."}
	Local aHelpPor17 := {"Considera Saldo Armazem até."}
	Local aHelpPor18 := {"Data Limite para Empenho."}
	Local aHelpPor19 := {"Seleciona Filiais ?","Sim ou Não"}
	Local aHelpPor20 := {"Considera Est. Seguranca ?","Sim ou Não"}
	Local aHelpPor21 := {"Apenas para o código do Fornecedor.","Para todos deixar em branco."}
	Local aHelpPor22 := {"Apenas para a loja do Fornecedor."}
	Local aHelpPor23 := {"Imprime Itens ?","Todos os Itens ou ","Itens em ponto de Pedido"}
	Local aHelpPor24 := {"Imprime na ordem selecionada.","Ordem saldo atual - ponto pedido,","saldo atual ou descrição"}
	Local aHelpPor25 := {"Imprime na ordem selecionada.","Ordem crescente ou decrescente."}        
	Local aHelpPor26 := {"Imprime itens do Ponto de","Pedido Zerados ?","Sim ou Não."}  
		
	PutSx1(cPerg,"01","Produto de ?","","" 	  	   				,"MV_CH1","C",TamSx3("B1_COD")[1]	,0,0,"G",,"SB1"  ,,,"MV_PAR01",,,,"",,,,,,,,,,,,,aHelpPor01)
	PutSx1(cPerg,"02","Produto ate ?","",""	  	   				,"MV_CH2","C",TamSx3("B1_COD")[1]	,0,0,"G",,"SB1"  ,,,"MV_PAR02",,,,"",,,,,,,,,,,,,aHelpPor02)
	
	PutSx1(cPerg,"03","Grupo de ?","",""   	  	   				,"MV_CH3","C",TamSx3("BM_GRUPO")[1]	,0,0,"G",,"SBM"  ,,,"MV_PAR03",,,,"",,,,,,,,,,,,,aHelpPor03)
	PutSx1(cPerg,"04","Grupo ate ?","",""  	 	   				,"MV_CH4","C",TamSx3("BM_GRUPO")[1]	,0,0,"G",,"SBM"  ,,,"MV_PAR04",,,,"",,,,,,,,,,,,,aHelpPor04)
	                                          	   	
	PutSx1(cPerg,"05","Tipo de ?","",""	   	  	  				,"MV_CH5","C",TamSx3("B1_TIPO")[1]	,0,0,"G",,"02"   ,,,"MV_PAR05",,,,"",,,,,,,,,,,,,aHelpPor05)
	PutSx1(cPerg,"06","Tipo ate ?","",""		  				,"MV_CH6","C",TamSx3("B1_TIPO")[1]	,0,0,"G",,"02"   ,,,"MV_PAR06",,,,"",,,,,,,,,,,,,aHelpPor06)
	
	PutSx1(cPerg,"07","Armazem Padrao de ?","",""  				,"MV_CH7","C",TamSx3("B1_LOCPAD")[1],0,0,"G",,"NNR"  ,,,"MV_PAR07",,,,"",,,,,,,,,,,,,aHelpPor07)
	PutSx1(cPerg,"08","Armazem Padrao ate ?","","" 				,"MV_CH8","C",TamSx3("B1_LOCPAD")[1],0,0,"G",,"NNR"  ,,,"MV_PAR08",,,,"",,,,,,,,,,,,,aHelpPor08)
	     
	PutSx1(cPerg,"09","Considerar Necessidade Bruta ?","",""	,"MV_CH9","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR09",;
				 		"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor09)   
		
   	PutSx1(cPerg,"10","Saldo Negativo a Considerar ? ","",""	,"MV_CHA","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR10",;
				 		"Saldo","Saldo","Saldo","","Saldo+LE","Saldo+LE","Saldo+LE",,,,,,,,,,aHelpPor10)   
		
	PutSx1(cPerg,"11","Listar Produtos do C.Q. ?","",""			,"MV_CHB","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR11",;
				 		"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor11)   
				
	PutSx1(cPerg,"12","Listar Qtde 3o. Nosso Poder ?","",""		,"MV_CHC","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR12",;
				 		"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor12)   
				
	PutSx1(cPerg,"13","Listar Qtde Nossa Poder 3o. ?","",""		,"MV_CHD","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR13",;
				 		"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor13)   
		
	PutSx1(cPerg,"14","Qtd. PV nao Liberado ?","",""			,"MV_CHE","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR14",;
				 		"Subtrai","Subtrai","Subtrai","","Ignora","Ignora","Ignora",,,,,,,,,,aHelpPor14)   
		                             
	PutSx1(cPerg,"15","Descricao completa produto ?","",""		,"MV_CHF","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR15",;
				 		"Não","Não","Não","","Sim","Sim","Sim",,,,,,,,,,aHelpPor15)   
	
	PutSx1(cPerg,"16","Considera Saldo Armazem de ?","",""  	,"MV_CHG","C",TamSx3("B1_LOCPAD")[1],0,0,"G",,"NNR"  ,,,"MV_PAR16",,,,"",,,,,,,,,,,,,aHelpPor16)
	PutSx1(cPerg,"17","Considera Saldo Armazem ate ?","","" 	,"MV_CHH","C",TamSx3("B1_LOCPAD")[1],0,0,"G",,"NNR"  ,,,"MV_PAR17",,,,"",,,,,,,,,,,,,aHelpPor17)
	
	PutSx1(cPerg,"18","Data Limite para Empenho ?","",""   		,"MV_CHI","D",8						,0,0,"G",,/*cF3*/,,,"MV_PAR18",,,,"",,,,,,,,,,,,,aHelpPor18)
	      
	PutSx1(cPerg,"19","Seleciona Filiais ?","",""	  			,"MV_CHJ","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR19",;
				 		"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor19)   
	                                                                   
	PutSx1(cPerg,"20","Considera Est. Seguranca ?","",""		,"MV_CHK","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR20",;
				 		"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor20)   
			
	PutSx1(cPerg,"21","Fornecedor ?","",""  					,"MV_CHL","C",TamSx3("A2_COD")[1]	,0,0,"G",,"SA2"  ,,,"MV_PAR21",,,,"",,,,,,,,,,,,,aHelpPor21)
	PutSx1(cPerg,"22","Loja ?","",""  			 		  		,"MV_CHM","C",TamSx3("A2_LOJA")[1]	,0,0,"G",,/*cF3*/,,,"MV_PAR22",,,,"",,,,,,,,,,,,,aHelpPor22)
                                    
	PutSx1(cPerg,"23","Imprime Itens ?","",""	   				,"MV_CHN","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR23",;
				 		"Todos os Itens","Todos os Itens","Todos os Itens","","Ponto de pedido","Ponto de pedido","Ponto de pedido",,,,,,,,,,aHelpPor23)   
	                               
	PutSx1(cPerg,"24","Classificação ?","",""	   				,"MV_CHO","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR24",;
				 		"Saldo - Pt. Ped.","Saldo - Pt. Ped.","Saldo - Pt. Ped.","","Saldo Atual","Saldo Atual","Saldo Atual","Descrição","Descrição","Descrição",,,,,,,aHelpPor24)   
	                               
	PutSx1(cPerg,"25","Ordem ?","",""	   			   			,"MV_CHP","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR25",;
				 		"Crescente","Crescente","Crescente","","Decrescente","Decrescente","Decrescente",,,,,,,,,,aHelpPor25)   
                           
	PutSx1(cPerg,"26","Ponto Ped. Zerados ?","",""	   			,"MV_CHQ","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR26",;
				 		"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor26)   
	 	                        
Return
