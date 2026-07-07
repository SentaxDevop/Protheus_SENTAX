#Include 'Protheus.ch'
#Include 'TOPCONN.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} AFAT002
Valida marcação dos itens a serem faturados, na rotina de documento 
de saída.
Utilizado para validar se todos os itens de um determinado pedido foram
marcados.

@author Henrique Baldin
@return lRetOk		.T.  se permite, .F. caso contrário
@since 21/05/2012
@version 1.0

/*/
//-------------------------------------------------------------------
User Function AFAT002()
Local aArea 	:= GetArea()
Local aAreaSC9 	:= SC9->(GetArea())
Local _nRecSC9  := SC9->(Recno())
Local nI 		:= 0
Local lRetOk    :=.T.  

Local cTes     := GetMV("ST_TESSERC")        
Local cPed     := "Não é permitido faturar Vendas e Serviço no mesmo Pedido."
Local lTesServ := .F.  
Local cPedSer  := "Pedidos com Tes de Serviço: "
Local lTesVend := .F.
Local cPedVend := "Pedidos com Tes de Produto: "
Local aTesS    := {}
Local i        := 0
Private cMark 		:= ""
Private lInverte    := .f.
Private aCargas 	:= {}
Private nVendor 	:= 0
Private nComum  	:=0
Private aNaoMark 	:= {}        


//No MATA410
If IsInCallStack("U_M410PVNF")

	lRetOk := FatParcPHen(SC5->C5_NUM) 

// Faturamento por pedidos	
ElseIf Funname() == "MATA460A" 

	cMark 		:= PARAMIXB[1] //MARCA UTILIZADA
	lInverte    := PARAMIXB[2] //SELECIONOU "MARCA TODOS"

	cQuery := " SELECT C9_FILIAL, C9_PEDIDO "
	cQuery += " FROM " + RetSQLName("SC9") + " "
	cQuery += " WHERE C9_FILIAL = '"+ FWxFilial("SC9") +"' 
	cQuery += " AND C9_OK "+ IIF(lInverte, "<>", "=")+ "'"+cMark+"' " 
	
	If lInverte
		Pergunte("MT461A", .F.)
		
		cQuery += "  AND C9_CLIENTE >= '" + MV_PAR07 + "' AND C9_CLIENTE <= '" + MV_PAR08 + "' "                                 
		cQuery += "  AND C9_LOJA >= '" + MV_PAR09 + "' AND C9_LOJA <= '" + MV_PAR10 + "' "                                        
		cQuery += "  AND C9_DATALIB >= '" + dToS(MV_PAR11) + "' AND C9_DATALIB <= '" + dToS(MV_PAR12) + "' "                
		cQuery += "  AND C9_PEDIDO >= '" + MV_PAR05 + "' AND C9_PEDIDO <= '" + MV_PAR06 + "' "                                
		cQuery += "  AND C9_BLEST = '' AND C9_BLCRED = ''"   
		
		//Restaurando a pergunta do botão Prep.Doc.
    	Pergunte("MT460A", .F.) 
	EndIf 

	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY C9_FILIAL, C9_PEDIDO "
		
	//cQuery := ChangeQuery(cQuery)
				
	If ( SELECT("TRB") ) > 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf
		
	TcQuery cQuery NEW ALIAS "TRB"
				
	//Adicionando pedidos marcados
	While !TRB->(Eof())
			
		AADD(aCargas,TRB->C9_PEDIDO)
		If !FatParcPHen(TRB->C9_PEDIDO)
			Return .F.
		EndIf

			
		TRB->(DbSkip())
	Enddo

	If !lInverte
		If !AllItemPed()
						
			cMensagem := "Existe(m) item(s) não selecionado(s) para o(s) pedido(s) abaixo." + CRLF
			cMensagem += "O faturamento só ocorrerá se todos os itens estiverem selecionados." + CRLF + CRLF
			cMensagem += "Pedido  | Produto" + CRLF 		
			For nI := 1 TO LEN(aNaoMark)
				cMensagem += aNaoMark[nI,1]+"    " +aNaoMark[nI,2] +CRLF
			Next nI
			
			Aviso("Itens não selecionados",cMensagem,{"OK"},3)
				
			Return .F.
		EndIf

	EndIf

	If !FatParcSent()
		Return .F.
	EndIf
					
		
	SC9->(DbGoto(_nRecSC9))
	RestArea(aAreaSC9)
	RestArea(aArea)   
	
ElseIf Funname() == "MATA460B"
	
	aArea 	  := GetArea()	  
	aAreaSC9 := SC9->(GetArea())
	aAreaDAK := DAK->(GetArea())
	aAreaSC6 := SC6->(GetArea()) 
		
	cMark 	:= PARAMIXB[1]
	nI 		:= 0		
	aCargas	:= {}
		
	cQuery := " SELECT DAK_FILIAL, DAK_COD, DAK_SEQCAR "
	cQuery += " FROM " + RetSQLName("DAK") + " "
	cQuery += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"' AND "
	cQuery += " DAK_OK = '"+cMark+"' AND "
	cQuery += " D_E_L_E_T_ <> '*'"
	cQuery += " GROUP BY DAK_FILIAL, DAK_COD, DAK_SEQCAR "
		
	If ( SELECT("TRB") ) > 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf
		
	TCQUERY cQuery NEW ALIAS "TRB"
	
	TRB->(DbGoTop())
		
	// Adicionando pedidos marcados
	While !TRB->(Eof())
		AADD(aCargas,{TRB->DAK_COD,TRB->DAK_SEQCAR})
		TRB->(DbSkip())
	Enddo 

		  			
	DbSelectArea("SC9")
	SC9->(DbSetOrder(5)) // C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT
		
	For nI := 1 To Len(aCargas)	
		cCarga := aCargas[nI][1]
		cSeque := aCargas[nI][2]	    
	    If SC9->(DbSeek(xFilial("SC9")+cCarga+cSeque))
	    	cPedErr  := ""   
			While !SC9->(Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_CARGA == cCarga .AND. SC9->C9_SEQCAR == cSeque
				cPedido  := Alltrim(SC9->C9_PEDIDO)
				// Verifico se tem algum item no pedido que nao seteja nessa carga >> SC9
				cQuery1 := "SELECT C9_PEDIDO FROM " + RetSQLName("SC9") + " " 
				cQuery1 += "WHERE C9_FILIAL ='"+SC9->C9_FILIAL+"' "
				cQuery1 += "AND  C9_PEDIDO = '"+SC9->C9_PEDIDO+"' "
				cQuery1 += "AND  C9_CARGA <> '"+SC9->C9_CARGA +"' "
				cQuery1 += "AND D_E_L_E_T_ =' '       "
					
				If ( SELECT("TRC") ) > 0
					dbSelectArea("TRC")
					TRC->(dbCloseArea())
				EndIf            
		
				TCQUERY cQuery1 NEW ALIAS "TRC"
				
				TRC->(DbGoTop())
					
				While !TRC->(Eof())
					If !cPedido $ cPedErr
			    		cPedErr += IIF(Empty(cPedErr),"",", ")+Alltrim(SC9->C9_PEDIDO)
			    	EndIf
			    	
			    	lRetOk := .F.
			  		TRC->(DbSkip())
				Enddo 
					
				// Verifico se tem algum item no pedido que nao seteja na sc9 >> SC6
				 
				cQuery2 := "SELECT C6_FILIAL FROM " + RetSQLName("SC6") + " C6" 
				cQuery2 += "  WHERE C6_FILIAL = '"+SC9->C9_FILIAL+"'  "
				cQuery2 += "   AND  C6_NUM = '"+SC9->C9_PEDIDO+"'  "
				cQuery2 += "   AND C6_PRODUTO NOT IN (Select C9_PRODUTO from " + RetSQLName("SC9") + " C9" 
				cQuery2 += "							  WHERE C9_FILIAL = '"+SC9->C9_FILIAL+"'  "
				cQuery2 += "							   AND  C9_PEDIDO = '"+SC9->C9_PEDIDO+"'  " 
				cQuery2 += "							   AND C9.D_E_L_E_T_ =' ') "
				cQuery2 += "   AND C6.D_E_L_E_T_ =' ' " 
				If ( SELECT("TRD") ) > 0
					dbSelectArea("TRD")
					TRD->(dbCloseArea())
				EndIf
					
				TCQUERY cQuery2 NEW ALIAS "TRD"
				
				TRD->(DbGoTop())
					
				While !TRD->(Eof())
					If !cPedido $ cPedErr
			    		cPedErr += IIF(Empty(cPedErr),"",", ")+cPedido
			    	EndIf
			    	
			    	lRetOk := .F. 
			  		TRD->(DbSkip())
				Enddo
					 
				DbSelectArea("SC6")
				SC6->(DbSetOrder(1))
				
				If SC6->(DbSeek( SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM ))
					
						AAdd(aTesS,{SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_TES, SC9->C9_CARGA})				
        			
     			Endif				 
					
				SC9->(DbSkip())
					
			EndDo
				 
			If !Empty(cPedErr)	   
				
				AVISO( "FATURAMENTO BLOQUEADO", "Divergencias com o(s) Pedido(s) "+cPedErr+" da Carga "+cCarga+"  Verifique!"+CHR(13)+CHR(10)+;
				  							    "Posiveis Causas :"+CHR(13)+CHR(10)+;
				  							    "Pedido nao esta totalmente Liberado"+CHR(13)+CHR(10)+;
				  							    "Ou"+CHR(13)+CHR(10)+;
				  							    "Nao foram selecionados todos os itens do Pedido para Carga", {"OK"},3)					 				
			EndIf
				
		EndIf
					
	Next nI   
		
	// Valida tes...
	For i := 1 To Len(aTesS)
		 
		If aTesS[i,3] $ cTes
		
						
			lTesServ := .T. 
			If ! ("Pedido "+aTesS[i,2] $ cPedSer)
				cPedSer  +=  CRLF + "Pedido "+aTesS[i,2]+" da Carga "+aTesS[i,4]
			Endif  
		Else
			lTesVend := .T.
			If ! ("Pedido "+aTesS[i,2] $ cPedVend)
				cPedVend  +=  CRLF + "Pedido "+aTesS[i,2]+" da Carga: "+aTesS[i,4]
			Endif 
		EndIf
	next i

	
	If lTesServ .AND. lTesVend
	
		lRetOk := .F.
	    Aviso("Faturamento Bloqueado", cPed +CRLF +cPedSer+CRLF +cPedVend ,{"OK"},3)
	    
	endif 
	
	If !IsInCallStack("U_M410PVNF")
	
		/*
//		If lTesVend  .AND. Trim(PadR(SX5->X5_CHAVE,3)) == "2"  .and. lRetOk
		If lTesVend  .AND.  lRetOk		 	
			lRetOk := .F.
   			Aviso("Faturamento Bloqueado", "Esta sendo Faturado Produtos com Serie 2 que é exclusiva de Serviço" ,{"OK"},3)
   			
		Endif
		
//		If lTesServ  .AND. Trim(PadR(SX5->X5_CHAVE,3)) <> "2"  .and. lRetOk	
		If lTesServ  .AND. lRetOk	
			lRetOk := .F.
   			Aviso("Faturamento Bloqueado", "Esta sendo Faturado Serviço com Serie diferente de 2." ,{"OK"},3)
		Endif
		*/
	Endif		
	
	// FINAL VALIDAÇÃO TES		
			
	RestArea(aAreaSC9)
	RestArea(aAreaDAK)
	RestArea(aAreaSC6)
	RestArea(aArea)
		    
EndIf	

Return(lRetOk) 
	
		

//-------------------------------------------------------------------
/*/{Protheus.doc} AllItemPed
Verifica se ficou algum item para traz sem marcar

@author Leandro Natan Bonette Santos
@since  18/06/2012
@return lRet                  
                  
/*/
//-------------------------------------------------------------------
Static Function AllItemPed()

Local aArea 	:= GetArea()
Local aAreaSC9 	:= SC9->(GetArea())
Local _nRecSC9  := SC9->(Recno())
Local lRet 		:= .T.
Local nI

SC9->(DbSetOrder(1))                                                                             
		
For nI := 1 to LEN(aCargas)
	If SC9->(DbSeek(xFilial("SC9")+aCargas[nI]))    
		While SC9->(!Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == aCargas[nI]
			If SC9->C9_OK <> cMark                  
				//verifica se é um pedido que pode ser faturado parcialmente. Se for não deixa registrar o reotorno.
				If SC5->(DbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO))
					If !Empty(Alltrim(SC5->C5_xPEDOR))     
						SC9->(DbSkip())
						Loop
					EndIf	
				EndIf
				aAdd(aNaoMark,{SC9->C9_PEDIDO,SC9->C9_PRODUTO})
				lRet := .F.			
			Endif
			SC9->(DbSkip())
		End
	Endif
Next nI

SC9->(DbGoto(_nRecSC9))
RestArea(aAreaSC9)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FatParcSent
Verifica se ficou algum item sem marcar para faturar

@author Henrique Baldin
@since  21/05/2014
@return lRet                  
                  
/*/
//-------------------------------------------------------------------

Static Function FatParcSent()

Local lRet := .T.           
Local cMensg := " "
Local cMensagem := " "
Local cQuery1 := ""
Local nI := 1

If len(aCargas) > 0 

	cQuery := " SELECT C6_FILIAL, C6_NUM, C6_PRODUTO FROM " + RetSQLName("SC6") + " SC6 "
	cQuery += "  WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
	
	cQuery += "    AND C6_NUM  IN ("
	
	For nI:= 1 to len(aCargas)
		If !Empty(Alltrim(Posicione('SC5',1,xFilial('SC5')+aCargas[nI],"C5_XPEDOR")))  
			Loop
		EndIf
	
		If nI == 1     			
		
			cQuery1+="'"+aCargas[nI]+"'"
		
		Else
		
			cQuery1+=",'"+aCargas[nI]+"'"
		
		Endif			
	
	Next nI        
	If Empty(Alltrim(cQuery1))
		cQuery1 := "''"
	EndIf
	
	cQuery += cQuery1+")"
	
	cQuery += "    AND( C6_PRODUTO NOT IN ( select C9_PRODUTO from " + RetSQLName("SC9") +;
						 " SC9 WHERE C9_FILIAL = C6_FILIAL AND C9_PEDIDO =C6_NUM and SC9.D_E_L_E_T_ = ' ' ) "
	cQuery += " 		OR C6_QTDVEN <> (select C9_QTDLIB from " + RetSQLName("SC9") +;
						 " SC9 WHERE C9_FILIAL = C6_FILIAL AND C9_PEDIDO =C6_NUM and SC9.D_E_L_E_T_ = ' 'AND"+;
						 "  C9_PRODUTO = C6_PRODUTO and  C9_ITEM   = C6_ITEM  )) "						 
	cQuery += "    AND SC6.D_E_L_E_T_ = ' '"
			
  
	If ( SELECT("TRB1") ) > 0
		dbSelectArea("TRB1")
		TRB1->(dbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TRB1"
	
	TRB1->(DbGoTop())
	 
		
			
	If TRB1->(!Eof()) .AND. !GetMV("MV_STPARC",,".F.")
	
			While TRB1->(!Eof()) .AND.  TRB1->C6_FILIAL == xFilial("SC9") 
				
				cMensg += TRB1->C6_NUM+"    "+TRB1->C6_PRODUTO + CRLF
				
				TRB1->(DbSkip())
			End
			
		lRet := .F. 
		cMensagem := "Não é permitido o Faturamento Parcial de Pedidos de Venda" +CRLF
		cMensagem += "Pedidos/ produtos que nao estao liberados:" +CRLF
		cMensagem += " Pedido  | Produto" + CRLF  
		cMensagem += cMensg  
			
		Aviso("Boqueio Fat Parcial - MV_STPARC",cMensagem,{"OK"},3)
		
		If !lRet
		
			Return .F.
		Endif	
		 
	Endif 	
	
Endif
 
 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FatParcPHen
Verifica se ficou algum item sem marcar para faturar

@param 	cPedido, Pedido de venda 

@author Henrique Baldin
@since  21/05/2014
@return lRet                  
                  
/*/
//-------------------------------------------------------------------

Static Function FatParcPHen(cPedido)
Local lRet 		:= .T.           
Local aPedFat   := {}
Local cTes     	:= GetMV("ST_TESSERC")        
Local cPed     	:= "Não é permitido faturar Vendas e Serviço no mesmo Pedido. "
Local lTesServ 	:= .F.  
Local cPedSer  	:= "Pedidos com Tes de Serviço: "
Local lTesVend 	:= .F.
Local cPedVend 	:= "Pedidos com Tes de Produto: "
Local aTesS    	:= {}
Local aArea	 	:= GetArea()
Local aAreaSC5 	:= SC5->(GetArea())
Local aAreaSC6 	:= SC6->(GetArea())
Local aAreaSC9 	:= SC9->(GetArea())
Local nIndPed  	:= 0
Local i		 	:= 0  
Local nQtdePed 	:= 0
Local nQtdeLib 	:= 0
Local lRemessa	:= .F.


If IsInCallStack("U_M410PVNF")

	AAdd(aPedFat, { SC5->C5_FILIAL ,;
					  SC5->C5_NUM,;
					  SC5->C5_CLIENTE,;
					  SC5->C5_LOJACLI } )

	
	If SC5->C5_XBLCOM == '1'
		MsgAlert("O Pedido '"+Trim(SC9->C9_PEDIDO) +"' esta Bloqueado comercialemente! Favor solicitar o desbloqueio para faturamento! " )
		Return .F.			
	Endif   

Else 

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(xFilial("SC5")+cPedido))
	
		AAdd(aPedFat, { SC5->C5_FILIAL ,;
					  SC5->C5_NUM,;
					  SC5->C5_CLIENTE,;
					  SC5->C5_LOJACLI } )	

		If SC5->C5_XBLCOM == '1'
			MsgAlert("O Pedido '"+Trim(SC9->C9_PEDIDO) +"' esta Bloqueado comercialemente! Favor solicitar o desbloqueio para faturamento parcial! " )	
			Return .F.		
		Endif   

		If !Empty(Alltrim(SC5->C5_XPEDOR))   
			cQry := " SELECT * FROM "+RetSqlName('SC9')+" "
			cQry += " WHERE C9_FILIAL = '"+SC5->C5_FILIAL+"' AND C9_PEDIDO = '"+SC5->C5_XPEDOR+"' AND C9_NFISCAL != ' ' AND D_E_L_E_T_ != '*' " 
			
			If ( SELECT("QRYC9") ) > 0
				dbSelectArea("QRYC9")
				QRYC9->(dbCloseArea())
			EndIf
				
			TCQUERY cQry NEW ALIAS "QRYC9"
			
			DbSelectArea("QRYC9")
			QRYC9->(DbGoTop())
			
			If QRYC9->(EOF())
				MsgAlert("O Pedido '"+Trim(SC9->C9_PEDIDO) +"' não pode ser faturado pois a nota de faturamento antecipado não foi emitida!" )			
				QRYC9->(dbCloseArea())		
				Return .F. 			
			EndIf
			QRYC9->(dbCloseArea())
			
			lRemessa := .T.
		EndIf
	
	
	Endif	
	               	
Endif
  

If !lRemessa //valida se não for pedido de remessa. Se for pedido de remessa, verifica outras validações	
	For nIndPed := 1 To Len(aPedFat)   
		// abre a sc6, vare itens e quantiddade 	
			
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())
		SC6->(DbSeek( aPedFat[nIndPed,1] + aPedFat[nIndPed,2] ))	
		While ( SC6->(!Eof()) .AND. SC6->C6_FILIAL == aPedFat[nIndPed,1]  .AND. SC6->C6_NUM == aPedFat[nIndPed,2] )

			DbSelectArea("SC9")
			SC9->(DbSetOrder(2)) // C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM   
			SC9->(DbGoTop())
			If SC9->(DbSeek( SC6->C6_FILIAL + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_NUM + SC6->C6_ITEM ))   
				nQtdePed := SC6->C6_QTDVEN
				nQtdeLib := 0 
				
				While  SC9->(!Eof()) .AND. SC6->C6_FILIAL == SC9->C9_FILIAL .AND. SC6->C6_CLI == SC9->C9_CLIENTE .AND. SC6->C6_LOJA == SC9->C9_LOJA;
									 .AND. SC6->C6_NUM == SC9->C9_PEDIDO .AND. SC6->C6_ITEM == SC9->C9_ITEM ;
									 .AND. SC9->C9_PRODUTO == SC6-> C6_PRODUTO .AND. lRet
				
					lRet := ( Empty(SC9->C9_NFISCAL) .AND. Empty(SC9->C9_SERIENF) .AND. Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_BLCRED) )
					 
					nQtdeLib += SC9->C9_QTDLIB             
					
	            	SC9->(DbSkip())      	   
	 			EndDo    
	 			
	 			If nQtdePed <> nQtdeLib
	 				lRet := .F. 			
	 			EndIf
	 			                    
	        Else
	        	lRet := .F.
	        
	        Endif
	        
	        If !lRet
			
				cMsg := "O Pedido "+Trim(SC9->C9_PEDIDO) + " esta BLOQUEADO pelo item " + Alltrim(SC6->C6_ITEM) 
				cMsg += " e não é permitido Faturamento Parcial. faturamento bloqueado."

	            MsgAlert(cMsg)			
				Return .F. 
	        Endif   
	        
	    	AAdd(aTesS,{SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_TES})
	       	SC6->(DbSkip())
		        
	     Enddo
		     
	next nIndPed	       
EndIf
// VALIDAÇÃO TES...
	
For i := 1 To Len(aTesS)
 
	If aTesS[i,3] $ cTes
		lTesServ := .T.
		 
		If ! (aTesS[i,2] $ cPedSer) 
			cPedSer  +=  CRLF + aTesS[i,2]
		Endif  
	Else
		lTesVend := .T.		
		If ! (aTesS[i,2] $ cPedVend)
			cPedVend  +=  CRLF + aTesS[i,2]
		Endif 
	EndIf
	
next i

If lTesServ .AND. lTesVend
	lRet := .F.
    
    Aviso("Faturamento Bloqueado", cPed +CRLF +cPedSer+CRLF +cPedVend ,{"OK"},3)
endif	

If !IsInCallStack("U_M410PVNF")
	/*	
//	If lTesVend  .AND. Trim(PadR(SX5->X5_CHAVE,3)) == "2"  .and. lRet
	If lTesVend  .AND.  lRet		 	
		lRet := .F.
   		Aviso("Faturamento Bloqueado", "Esta sendo Faturado Produtos com Serie 2 que é exclusiva de Serviço" ,{"OK"},3)
   			
	Endif
		
//	If lTesServ  .AND. Trim(PadR(SX5->X5_CHAVE,3)) <> "2"  .and. lRet	
	If lTesServ  .AND. lRet
		lRet := .F.
   		Aviso("Faturamento Bloqueado", "Esta sendo Faturado Serviço com Serie diferente de 2." ,{"OK"},3)
	Endif
	*/	
Endif		

SC9->(RestArea(aAreaSC9))
SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))

RestArea(aArea)

Return lRet
