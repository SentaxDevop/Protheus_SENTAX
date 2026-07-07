#INCLUDE "totvs.ch"   
#INCLUDE "protheus.ch"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Antes da validação da linha atual do atendimento pela rotina de Televendas          						//
// Autor    : alyson                                                                        				//
// Objetivo : Validações de duplicidade de produtos                                        					//
//                                                                                                        	//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function TKEVALI()

	Local lRet		:= .T.
	Local _nPOpe 	:= aScan(aHeader,{|x|Alltrim(x[2])=="UB_OPER"})
	Local _nPosPrd	:= aScan(aHeader,{|x|Alltrim(x[2])=="UB_PRODUTO"})
	Local _nPItem	:= aScan(aHeader,{|x|Alltrim(x[2])=="UB_ITEM"})
	Local _nPosQtd  := Ascan(aHeader,{|x|AllTrim(x[2])=="UB_QUANT" })

	Local nLinhaAtual := n 
	Local nLoop       := 0 
	Local aArea       := GetArea()

	If FWIsInCallStack("U_AFAT008")
		
		cLogTxt := "ROTINA AUTOMATICA DE GERACAO DO ATENDIMENTO VIA SIGAFAT. VALIDACAO NAO NECESSARIA! - [TKEVALI]"
		Conout(cLogTxt)	

		Return(lRet)

	End


	If FWIsInCallStack("Tk273GetOK") //Funcao geral da validacao
		If (M->UA_CLIENTE +  M->UA_LOJA) != (M->UA_CLIENT +  M->UA_LOJAENT)
			If IsBlind()
				cLogTxt := "Cliente e loja de entrega diferente do pedido/atendimento - [TKEVALI]"
				Conout(cLogTxt)		
			Else
				If !MsgYesNo("Cliente e loja de entrega diferente do pedido/atendimento, tem certeza que deseja continuar???", "Sentax")
					Return .f.
				EndIf 
			End
		EndIf 
	EndIf 

	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(DbGoTop())
	If SB1->(DbSeek( xFilial("SB1") + aCols[n,_nPosPrd]  )) //Acols[n][_nPosPrd]
		
		If SB1->B1_XQTDMUL > 0
			If !(MOD( aCols[n,_nPosQtd] ,SB1->B1_XQTDMUL)  == 0) //Acols[n][_nPosQtd]
				lRet := .F.
				If IsBlind()
					cLogTxt := "Este produto tem configuração para quantidades multiplas, ajuste a quantidade para ser multipla de "+ cValToChar(SB1->B1_XQTDMUL) +" - [TKEVALI]"
					Conout(cLogTxt)		
				Else
					MsgAlert("Este produto tem configuração para quantidades multiplas, ajuste a quantidade para ser multipla de "+ cValToChar(SB1->B1_XQTDMUL) +" ","SENTAX")
				End
			EndIf
			
		EndIf

	EndIf

	For nLoop := 1 to Len( aCols ) 

		// verifica se não é deletado itens do Acols
		If !aCols[n,Len(aHeader)+1]	

			// Verifica se UB_OPER é a mesma da linha anterior
			If n > 1
				If aCols[n,_nPOpe] != aCols[n-1,_nPOpe]
					If IsBlind()
						cLogTxt := "A Operação deste item não pode ser diferente! - [TKEVALI]"
						Conout(cLogTxt)		
					Else
						MsgAlert("A Operação deste item não pode ser diferente!")
					End
					Return(.f.)
				EndIf
			EndIf

			// Não deve validar a linha atual. 
			If nLoop == nLinhaAtual 
				Loop 
			EndIf 
			
			If (aCols[n,_nPosPrd] == aCols[nLoop,_nPosPrd]) .and. (aCols[n,_nPOpe] == aCols[nLoop,_nPOpe]) 
				If IsBlind()
					cLogTxt := "Este produto e operação já foram digitados no item " + aCols[nLoop,_nPOpe] + " - [TKEVALI]"
					Conout(cLogTxt)		
				Else
					MsgAlert("Este produto e operação já foram digitados no item " + aCols[nLoop,_nPOpe] ) 
				End
				Return(.f.) 
			EndIf 

		EndIf

	Next nLoop 

	RestArea(aArea)
Return(lRet)
