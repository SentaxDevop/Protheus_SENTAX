#Include 'Protheus.ch'
#Include 'TOPCONN.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} AFAT001
Verifica se transportadora foi preenchida no pedido no momento da 
preparação do documento de saída

@return 	lRet	.T. se 
@author 	Alessandro Smaha
@since 	 	18/03/2014
@version 	P11

@obs		13/08/2014 Incluido tratamento na chammada do MATA410
/*/
//-------------------------------------------------------------------	
User Function AFAT001()

Local lRetOk   := .T.
Local cPedido  := ""
Local aAreaSC5 := {}
Local aAreaSC9 := {}
Local aAreaDAK := {}
Local cFilnFat := SuperGetMv('ST_XEMPTRP',,'')
Local nI 		 := 0
   
// Verifica se a filial logada consta no parametro para validar	 	
If cFilAnt $ cFilnFat
		
	// Faturamento por pedidos	
	If Funname() == "MATA460A" 
			
		aAreaSC5 := SC5->(GetArea())
		aAreaSC9 := SC9->(GetArea())
		      	
		cMark 	:= PARAMIXB[1]
		nI 		:= 0		
		aCargas	:= {} 
		cPedErr := ""
		
		cQuery := " SELECT C9_FILIAL, C9_PEDIDO "
		cQuery += " FROM " + RetSQLName("SC9") + " "
		cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND "
		cQuery += " C9_OK = '"+cMark+"' AND "
		cQuery += " D_E_L_E_T_ <> '*'"
		cQuery += " GROUP BY C9_FILIAL, C9_PEDIDO "
		
		cQuery := ChangeQuery(cQuery)
			
		If ( SELECT("TRB") ) > 0
			dbSelectArea("TRB")
			TRB->(dbCloseArea())
		EndIf
			
		cQuery := ChangeQuery(cQuery)
		TCQUERY cQuery NEW ALIAS "TRB"
		
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM  
		
		// Verifica os pedidos que foram marcados
		While !TRB->(Eof())
			cPedido := TRB->C9_PEDIDO
			If SC5->(DbSeek(xFilial("SC5")+cPedido))
		    	If Empty(SC5->C5_TRANSP) 
		    		If !cPedido $ cPedErr
		    			cPedErr += IIF(Empty(cPedErr),"",", ")+cPedido
		    		EndIf
		    		lRetOk := .F.
				EndIf		
			EndIf
			TRB->(DbSkip())
		Enddo
			
		If !Empty(cPedErr)
			MsgAlert("Trasportadora não Informada para o(s) Pedido(s) "+cPedErr+"!","Aviso")  				
		EndIf 
			
		RestArea(aAreaSC5)
		RestArea(aAreaSC9)
   
	// Faturamento de cargas	 
	ElseIf Funname() == "MATA460B"
		  
		aAreaSC5 := SC5->(GetArea()) 
		aAreaSC9 := SC9->(GetArea())
		aAreaDAK := DAK->(GetArea()) 
		
		cMark 	:= PARAMIXB[1]
		nI 		:= 0		
		aCargas	:= {}
			
		cQuery := " SELECT DAK_FILIAL, DAK_COD, DAK_SEQCAR "
		cQuery += " FROM " + RetSQLName("DAK") + " "
		cQuery += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"' AND "            
		cQuery += " DAK_OK = '"+cMark+"' AND "
		cQuery += " D_E_L_E_T_ <> '*'"
		cQuery += " GROUP BY DAK_FILIAL, DAK_COD, DAK_SEQCAR "
			
		cQuery := ChangeQuery(cQuery)
			
		If ( SELECT("TRB") ) > 0
			dbSelectArea("TRB")
			TRB->(dbCloseArea())
		EndIf
			
		cQuery := ChangeQuery(cQuery)
		TCQUERY cQuery NEW ALIAS "TRB"
			
		// Adicionando pedidos marcados
		While !TRB->(Eof())
			AADD(aCargas,{TRB->DAK_COD,TRB->DAK_SEQCAR})
			TRB->(DbSkip())
		Enddo 
		
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM 
			  			
		DbSelectArea("SC9")
		SC9->(DbSetOrder(5)) // C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT
			
		For nI := 1 To Len(aCargas)	
			cCarga := aCargas[nI][1]
			cSeque := aCargas[nI][2]	    
		    If SC9->(DbSeek(xFilial("SC9")+cCarga+cSeque))
		    	cPedErr  := ""   
				While !SC9->(Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_CARGA == cCarga .AND. SC9->C9_SEQCAR == cSeque
					cPedido  := Alltrim(SC9->C9_PEDIDO)					
					If SC5->(DbSeek(xFilial("SC5")+cPedido))
				    	If Empty(SC5->C5_TRANSP) 
				    		If !cPedido $ cPedErr
				    			cPedErr += IIF(Empty(cPedErr),"",", ")+cPedido
				    		EndIf
				    		lRetOk := .F.
						EndIf						
					EndIf
					SC9->(DbSkip())
				EndDo 
				If !Empty(cPedErr)
					MsgAlert("Trasportadora não Informada para o(s) Pedido(s) "+cPedErr+" da Carga "+cCarga+" Seq. "+cSeque+"!","Aviso")  				
				EndIf
			EndIf		
		Next nI
				
		RestArea(aAreaSC5) 
		RestArea(aAreaSC9)
		RestArea(aAreaDAK)
		
	
	ElseIf IsInCallStack("U_M410PVNF") 
	
		If Empty(SC5->C5_TRANSP)
		
			MsgAlert("Trasportadora não Informada para o(s) Pedido(s) "+Alltrim(SC5->C5_NUM)+"!","Aviso")
			lRetOk := .F.
		
		Endif
		    
	EndIf
		
EndIf
		                                                                                            
Return lRetOk 

