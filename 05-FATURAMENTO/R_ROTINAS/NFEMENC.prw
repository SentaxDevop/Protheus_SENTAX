/*****************************************************************************************************/
/***************** PONTO DE ENTRADA EXECUTADO NA GERACAO DO XML DA NOTA FISCAL ELETRONICA ************/
/************** COLOCA NAS INFORMACOES O ENDERECO DE COBRANCA, CODIGO CLIENTE E RAZAO SOCIAL *********/
/*****************************************************************************************************/
//Nota fiscal de saída
//Raphael D. PILATTI
//07.12.2011
//Incluído conforme solicitação do cliente.

//--------------------
#include "protheus.ch"

User Function NFEMENC()
Local _cFilAtu	:= xFilial("SD2")
Local _aArea 	:= GetArea()
Local _aAreaA1 	:= SA1->(GetArea())
Local _aAreaC5 	:= SC5->(GetArea())
Local _aAreaF2 	:= SF2->(GetArea())
Local _aAreaD2 	:= SD2->(GetArea())

Private cMen 	:= ""

If ParamIXB[1] == "1"

	//Obs: A Sentax nao usa o padrao que é o cliente entrega do pedido, alguem no passado mudou isso....

	SD2->(DBSelectArea("SD2"))
	SD2->(DBSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_
	SD2->(DBGoTop())
	If SD2->(DbSeek(_cFilAtu+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))

		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		SC5->(DbGoTop())
		If SC5->(DbSeek(_cFilAtu + SD2->D2_PEDIDO))

			If Empty(SC5->C5_XENDENT)
					DbSelectArea("SA1")
					SA1->(DbSetOrder(1))
					SA1->(DbGoTop())
					SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA ))

					cMen := " Cliente: " 		+ Alltrim(SA1->A1_COD)
					cMen += "-" 				+ Alltrim(SA1->A1_NREDUZ) 
					cMen += " End Entrega: "	+ Alltrim(SA1->A1_ENDENT)  
					cMen += " Bairro: " 		+ Alltrim(SA1->A1_BAIRROE)  
					
					If !Empty(SA1->A1_XCOMPEN)
						cMen += " Complem: " 		+ Alltrim(SA1->A1_XCOMPEN)
					End
					
					cMen += " Cidade: " 		+ If(!Empty(SA1->A1_MUNENT),Alltrim(SA1->A1_MUNENT),Alltrim(SA1->A1_MUNE))
					cMen += " CEP: " 			+ Alltrim(Transform(SA1->A1_CEPE,"@R 99999-999"))

				Else
					DbSelectArea("SA1")
					SA1->(DbSetOrder(1))
					SA1->(DbGoTop())
					SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA ))

					cMen := " Cliente: " 		+ Alltrim(SA1->A1_COD)
					cMen += "-" 				+ Alltrim(SA1->A1_NREDUZ) 
					cMen += " End Entrega: "	+ Alltrim(SC5->C5_XENDENT)  
					cMen += " Bairro: " 		+ Alltrim(SC5->C5_XBAIENT)  
					cMen += " Cidade: " 		+ Alltrim(SC5->C5_XMUNENT) + " - " + Alltrim(SC5->C5_XESTENT)
					cMen += " CEP: " 			+ Alltrim(Transform(SC5->C5_XCEPENT,"@R 99999-999"))

			EndIf 

			cMen += " Operador: "		+ Alltrim(SC5->C5_OPERADO)
			cMen += " Pedido: " 		+ Alltrim(SC5->C5_NUM)

			cMen += " Vendedor: "		+ Alltrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_NOME")) 
		EndIf 

	EndIf 

Endif

RestArea(_aAreaA1)
RestArea(_aAreaC5)
RestArea(_aAreaF2)
RestArea(_aAreaD2)
RestArea(_aArea)
Return(cMen)
