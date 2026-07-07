#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'Protheus.ch' 
#include "rwmake.ch"
#include "TOPCONN.ch"
#include "APWEBEX.CH"
#include "TBICONN.ch"

//-------------------------------------------------------------------------------------------------------------------------------------------------
WSRESTFUL wscyberlog DESCRIPTION "API Rest de Integracao com WMS CyberLog" 
	WSData json_dados	As String

	WSMethod POST	RecebePedidoVendas	DESCRIPTION "Metodo POST para receber o Retorno do Pedido de Venda" 		PATH '/rest/wscyberlog/RecebePedidoVendas'	WSSYNTAX "/rest/wscyberlog/RecebePedidoVendas/{JSON}"
	WSMethod POST	RecNota				DESCRIPTION "Metodo POST para receber o Retorno da Pre-Nota de Entrada" 	PATH '/rest/wscyberlog/RecNota' 			WSSYNTAX "/rest/wscyberlog/RecNota/{JSON}"
	WSMethod POST	RecMInterno			DESCRIPTION "Metodo POST para receber o Retorno da Movimentacao Interna" 	PATH '/rest/wscyberlog/RecMInterno' 		WSSYNTAX "/rest/wscyberlog/RecMInterno/{JSON}"
	WSMethod POST	RecInvent			DESCRIPTION "Metodo POST para receber o Inventario " 						PATH '/rest/wscyberlog/RecInvent'			WSSYNTAX "/rest/wscyberlog/RecInvent/{JSON}"
	WSMethod POST	RecAvarias			DESCRIPTION "Metodo POST para receber o Produtos Avariados "				PATH '/rest/wscyberlog/RecAvarias'			WSSYNTAX "/rest/wscyberlog/RecAvarias/{JSON}"
	WSMethod POST	RecRomaneio			DESCRIPTION "Metodo POST para receber o Romaneio "							PATH '/rest/wscyberlog/RecRomaneio'			WSSYNTAX "/rest/wscyberlog/RecRomaneio/{JSON}"


END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------------------------------------------
WSMethod POST RecebePedidoVendas WSReceive json_dados WSService wscyberlog

	Local aSaldoLib	:= {}
	Local aSaldos	:= {}
	Local aVldSC9	:= {}
	Local cJson 	:= self:getContent()
	Local cChvPedido:= ''
	Local cNumPedido:= ''
	Local cItePedido:= ''
	Local cProduto	:= ''
	Local cErpID	:= ''
	Local cSeqItem	:= ''
	Local cMsg		:= ''
	Local cMsgPnl	:= ''
	Local nQtdSC9	:= 0
	Local nSaldo	:= 0

	Local lRet		:= .T.
	Local oJson		:= Nil 
	Local nX1
	Local cLote 	:= ''
	Local oJsonIt	:= ""
	Local oJsonSer

	Local nXt 		:= 1
	Local cLoteWms	:= ""
	Local nQtdLt  	:= 0
	Local dValidLt	

	Private lWSCyberLog:= .T.


	::SetContentType("application/json")	
		
	If !FWJsonDeserialize(cJson, @oJSON)
		cMsg:= 'Ocorreu erro no processamento do JSON.'
		lRet := .F.

	Else
		ZC6->(DbSetOrder(1))
		DbSelectArea("ZC6")

		oJsonA := JSONObject():New()
		If ValType(oJsonA:FromJSON(cJson)) == "C"
			Conout("Problema no retorno JSon")
		EndIf

		aArrayA := oJsonA:GetNames()

		cOperacao := oJSON:OPERACAO

		If cOperacao != "RETURN"
			cMsg:= 'Operacao de retorno nao e valida para retorno do Pedido no Protheus'	
			lRet:= .F.
		Else

			cChvPedido	:= Alltrim(oJSON:ErpID)
			cNumPedido	:= Padr(Substr(cChvPedido, TamSX3("C9_FILIAL")[1]+1 	, TamSX3("C9_PEDIDO")[1]) ,  TamSX3("C5_NUM")[1])
			__cFil		:= Substr(cChvPedido,1,6)

			Conout("")
			Conout("Filial --> " + __cFil)

			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If ! SC5->(dbSeek(__cFil + cNumPedido ))
				cMsg:= 'Pedido Nr. ' + cNumPedido + ' nao encontrado no Protheus.'
				Conout("")
				Conout(cMsg)

				lRet := .F.
			else
				Reclock('SC5',.F.)
					SC5->C5_TRANSP := cValtoChar(STRZERO(oJSON:noRota,6))	
					SC5->C5_VOLUME1 := oJSON:Volumes
				SC5->(MSUNLOCK())
			EndIf			
	
			Conout("Inicio Json - cJson")
			Conout("")
			Conout(cJson)
			Conout("")
			Conout("Fim Json - cJson")

			If lRet

				For nX1:=1 to Len(oJSON:itensPedido)

				Conout(oJSON:itensPedido[nX1])
					
					nVolumes	:= oJSON:volumes

					cErpID	:= oJSON:itensPedido[nX1]:erpID
					

					cSeqItem	:= substr(cErpID, TamSX3("C6_FILIAL")[1]+TamSX3("C6_NUM")[1]+1, TamSX3("C6_ITEM")[1])
					cItePedido	:= StrZero(oJSON:itensPedido[nX1]:sequenciaERP,2) //substr(cErpID, TamSX3("C9_FILIAL")[1]+TamSX3("C9_PEDIDO")[1]+TamSX3("C9_ITEM")[1]+1							, TamSX3("C9_ITEM")[1])
					cProduto	:= oJSON:itensPedido[nX1]:codigoReduzido//padr(substr(cErpID, TamSX3("C9_FILIAL")[1]+TamSX3("C9_PEDIDO")[1]+TamSX3("C9_SEQUEN")[1]+TamSX3("C9_ITEM")[1]+1	, len(cErpID)), TamSX3("B1_COD")[1])
					
					//Verifica os lotes de cada item do pedido
					oJsonIt :=  oJSON:itensPedido[nX1]:loteItensPedido //oJson:GetJsonObject("loteItensPedido") oJSON:itensPedido[nX1]:GetJsonText("loteItensPedido")
					For nXt := 1 To Len(oJsonIt)
						cLoteWms:= oJSON:itensPedido[nX1]:loteItensPedido[nXt]:NOLOTE
						nQtdLt  := oJSON:itensPedido[nX1]:loteItensPedido[nXt]:QUANTIDADE
						dValidLt:= STOD(oJSON:itensPedido[nX1]:loteItensPedido[nXt]:VALIDADELOTE)

						//Posiciona e caso na exista, grava na ZC6
						DbSelectArea("ZC6")
						ZC6->(DbSetOrder(1))
						ZC6->(DbGoTop())
						If !ZC6->(DbSeek( __cFil + cNumPedido + cItePedido + cLoteWms))
							RecLock("ZC6", .t.)
							ZC6->ZC6_FILIAL	:= __cFil
							ZC6->ZC6_NUM	:= cNumPedido
							ZC6->ZC6_ITEM	:= cItePedido
							ZC6->ZC6_LOTE	:= cLoteWms
							ZC6->ZC6_DTVALI	:= dValidLt
							ZC6->ZC6_QUANT	:= nQtdLt
							ZC6->(MsUnlock())
						EndIf

					Next 

					nXt    := 0
					cSerie := ""

					//Verifica os seriais
					oJsonSer :=  oJSON:itensPedido[nX1]:seriais

					For nXt := 1 To Len(oJsonSer)

						If !Empty(cSerie)
							cSerie := cSerie + "/"
						End

						cSerie += oJsonSer[nXt]

					Next 

					If !Empty(cSerie)

						DbSelectArea("ZC7")
						ZC7->(DbSetOrder(1))
						ZC7->(DbGoTop())
						If !ZC7->(DbSeek( "020201" + cNumPedido + cItePedido))

							Conout("Controle de série para o Item" + cItePedido + " séries: " + cSerie)

							RecLock("ZC7", .T.)
								ZC7->ZC7_FILIAL	:= "020201"
								ZC7->ZC7_NUM	:= cNumPedido
								ZC7->ZC7_ITEM	:= cItePedido
								ZC7->ZC7_SERIES	:= cSerie
							ZC7->(MsUnlock())

						EndIf

					End

					nSaldo	:= 0
					aSaldos	:= {}
					aSaldoLib:= {}

					If Alltrim(oJSON:itensPedido[nX1]:operacao) != "RETURN"
						cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' operacao de retornonao e valida .'
						lRet:= .F.
						Exit
					Endif										

					//Posiciona na SC9 e faz as validacões iniciais da Liberacao
					lContinua:= .F.
					dbSelectArea("SC9")
					SC9->(dbSetOrder(1))
					If ! SC9->(dbSeek(cErpID+Strzero(oJSON:itensPedido[nX1]:sequenciaERP,2)+'01',.T. ))
						cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' nao encontrado na liberacao do Pedido no Protheus.'
						lRet := .F.
						exit
					Endif 

					aVldSC9:= fVldSC9()
					If ! aVldSC9[1]
						lRet:= aVldSC9[1]
						cMsg:= aVldSC9[2]
						exit
					Endif

					SC6->(dbSetOrder(1))
					If ! SC6->(dbSeek(cErpID+Strzero(oJSON:itensPedido[nX1]:sequenciaERP,2),.T. ))
						nQtdSC9:= SC6->C6_QTDLIB
						cMsgPnl:= SC5->C5_XMSGWMS + CRLF
					Else
						nQtdSC9:= SC9->C9_QTDLIB
						cMsgPnl:= SC9->C9_XMSGWMS + CRLF
					Endif 

					If SC5->C5_TIPO $ "DB"
						dbSelectArea("SA2")
						SA2->(dbSetOrder(1))
						SA2->(dbSeek(FWxFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.))
					Else
						dbSelectArea("SA1")
						SA1->(dbSetOrder(1))
						SA1->(dbSeek(FWxFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.))
					EndIf

					If lRet
						cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
						cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

						RecLock("SC5",.F.)
						SC5->C5_XSTAWMS:= "O" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
						SC5->C5_XDTIWMS:= dDataBase
						SC5->C5_XHRIWMS:= Time()
						SC5->C5_XMSGWMS:= cMsgPnl
						SC5->(MsUnlock())

						RecLock("SC9",.F.)
						SC9->C9_XSTAWMS:= "O" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
						SC9->C9_XDTIWMS:= dDataBase
						SC9->C9_XHRIWMS:= Time()
						SC9->C9_XMSGWMS:= cMsgPnl
						SC9->C9_LOTECTL:= cLote
						SC9->(MsUnlock())
					else
						cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
						cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

						cMsgPnl+= CRLF 
						
						RecLock("SC5",.F.)
						SC5->C5_XSTAWMS:= "O" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
						SC5->C5_XDTIWMS:= dDataBase
						SC5->C5_XHRIWMS:= Time()
						SC5->C5_XMSGWMS:= cMsgPnl
						SC5->(MsUnlock())

						RecLock("SC9",.F.)
						SC9->C9_XSTAWMS:= "X" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
						SC9->C9_XDTIWMS:= dDataBase
						SC9->C9_XHRIWMS:= Time()
						SC9->C9_XMSGWMS:= cMsgPnl
						SC9->(MsUnlock())
					endIf

				Next nX1

			Endif
		Endif

	Endif

	If lRet
			cMsg:= '{"Resultado": "T", "msg": "Recepcao com Sucesso" }'
			::SetResponse( cMsg )
			cJson+=CRLF+CRLF+ cMsg + CRLF

		Else
			cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
			cMsgPnl+= "Data: "+ Dtoc(Date()) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF


			cMsgPnl+= cMsg 

			cJson+=CRLF+CRLF+'{ "Resultado":"F", "msg":"' + cMsg + '"} '

			cMsgPnl+= CRLF 
			
			DbSelectArea("ZA1")
			RecLock("ZA1",.T.)
			ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
			ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
			ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
			ZA1->ZA1_TIPOTR:= "R"
			ZA1->ZA1_ORIGEM:= "WS_PEDVEN"
			ZA1->ZA1_DATATR:= date()
			ZA1->ZA1_HORATR:= time()
			ZA1->ZA1_USERTR:= 'CyberLog'//upper(UsrRetName(__cUserId))
			ZA1->ZA1_JSON  := cJson
			ZA1->ZA1_TPMOV := '5'
			ZA1->(MsUnlock())

			SetRestFault(400, cMsg )
	Endif

	FreeObj(oJSON)

Return lRet

//-------------------------------------------------------------------------------------------------------------------------------------------------
WSMethod POST RecNota WSReceive json_dados WSService wscyberlog

	Local cJson 	:= self:getContent()
	Local cAlmox	:= ''
	Local cChv		:= ''
	Local cDoc		:= ''
	Local cItemNF	:= ''
	Local cProduto	:= ''
	Local cErpID	:= ''
	Local cMsg		:= ''
	Local cMsgPnl	:= ''
	Local nQtdSD1	:= ''
	Local nQtd		:= 0

	Local lRet		:= .T.
	Local lRastro	:= .F.
	Local oJson		:= Nil 
	Local nX1
	Local nX2

	/*TAGs do Retorno Nota Fiscal
	oJSON:operacao
	oJSON:erpId
	oJSON:empresa
	oJSON:data
	oJSON:documento
	oJSON:codFornecedor
	oJSON:avaria
	oJSON:confCega
	oJSON:tipo
	oJSON:doca
	oJSON:prioridade
	oJSON:devolucao
	itensRecebimento->	oJSON:itensRecebimento[nX]:codigoReduzido
						oJSON:itensRecebimento[nX]:erpId
						oJSON:itensRecebimento[nX]:quantidade
						oJSON:itensRecebimento[nX]:qtdAvaria
						oJSON:itensRecebimento[nX]:noLayout
						loteItensRecebimento-> 	oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:quantidade
												oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:qtdAvaria
												oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:lote
												oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:validade
												oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:fabricacao
	*/

	::SetContentType("application/json")	
		
	If !FWJsonDeserialize(cJson, @oJSON)
		cMsg:= 'Ocorreu erro no processamento do JSON.'
		lRet := .F.
	Else

		Conout("Inicio Json - cJson - RecNota")
		Conout("")
		Conout(cJson)
		Conout("")
		Conout("Fim Json - cJson - RecNota")

		cOperacao := oJSON:OPERACAO

		If cOperacao != "RETURN"
			cMsg:= 'Operacao de retorno nao e valida para retorno do Pedido no Protheus'	
			lRet:= .F.
		Else

			cChv	:= Alltrim(oJSON:ERPID)
			cDoc	:= substr(cChv, 1, 15)
			
			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			If ! SD1->(dbSeek(cDoc,.T. ))
				cMsg:= 'Nr. Doc ' + cDoc + ' nao encontrado no Protheus.'
				lRet := .F.
			EndIf			

			If lRet

				For nX1 := 1 to Len(oJSON:itensRecebimento)

					//cErpID	:= oJSON:itensRecebimento[nX1]:erpId 
					cErpID	    := oJSON:erpId 
					cProduto	:= padr( substr(cErpID	, TamSX3("D1_FILIAL")[1]+TamSX3("D1_DOC")[1]+TamSX3("D1_SERIE")[1]+TamSX3("D1_FORNECE")[1]+TamSX3("D1_LOJA")[1], TamSX3("D1_COD")[1] ), TamSX3("D1_COD")[1] )
					cItemNF		:= substr(cErpID	, TamSX3("D1_FILIAL")[1]+TamSX3("D1_DOC")[1]+TamSX3("D1_SERIE")[1]+TamSX3("D1_FORNECE")[1]+TamSX3("D1_LOJA")[1]+TamSX3("D1_COD")[1]+1, TamSX3("D1_ITEM")[1])
					
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbGoTop())
					If ! SB1->(dbSeek(xFilial("SB1")+Alltrim(cProduto)))
						cMsg:= 'Produto '+ cProduto + ' do Pedido Nr. ' + cDoc + ' nao existe no cadastro do Protheus.'
						lRet:= .F.
						Exit
					Endif

					lRastro:= SB1->B1_RASTRO == 'L'

					nQtdSD1	:= SD1->D1_QUANT
					//cMsgPnl	:= SD1->D1_XMSGWMS + CRLF
					cAlmox	:= SD1->D1_LOCAL

					If lRastro
						For nX2:=1 to len(oJSON:itensRecebimento[nX1]:loteItensRecebimento)

							nQtd	:= oJSON:itensRecebimento[nX1]:loteItensRecebimento[nX2]:quantidade
							cLoteCtl:= padr(oJSON:itensRecebimento[nX1]:loteItensRecebimento[nX2]:lote, TamSX3("D3_LOTECTL")[1])

							If Empty(cLoteCtl) 
								cMsg:= 'Item '+ cItemNF +' Produto '+ cProduto + ' do Pedido Nr. ' + cDoc + ' controle lote. Lote igual a branco .'
								lRet := .F.
								exit
							Else

								If nQtd != nQtdSD1
									cMsg:= 'Item '+ cItemNF +' Produto '+ cProduto + ' do Pedido Nr. ' + cDoc + ' quantidades de conferencia(s) diferente(s) da Pre-Nota .'
									lRet := .F.
									exit									
								Endif

							Endif

						Next nX2
					Else

						//nQtd	:= oJSON:itensRecebimento[nX1]:loteItensRecebimento[nX2]:quantidade
						//cLoteCtl:= padr(oJSON:itensRecebimento[nX1]:loteItensRecebimento[nX2]:lote, TamSX3("D3_LOTECTL")[1])

						/*If nQtd != nQtdSD1
							cMsg:= 'Item '+ cItemNF +' Produto '+ cProduto + ' do Pedido Nr. ' + cDoc + ' quantidades de conferencia(s) diferente(s) da Pre-Nota .'
							lRet := .F.
						Endif */

					Endif

				Next nX1
			
			Endif

		Endif

	Endif

	If lRet
			cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
			cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

			cMsg:= '{"Resultado": "T", "msg": "Recepcao com Sucesso" }'
				
			::SetResponse( cMsg )

			cJson+=CRLF+CRLF+ cMsg + CRLF

			cMsgPnl+= cMsg 
			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			If SD1->(dbSeek(cDoc,.T. ))
				While SD1->D1_FILIAL+SD1->D1_DOC == Alltrim(cDoc)
					RecLock("SD1",.F.)
						SD1->D1_XSTAWMS:= "O" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
					SD1->(MsUnlock())
					SD1->(DbSkip())
				EndDo
			EndIf

		Else
			cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
			cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

			cMsgPnl+= cMsg 

			SetRestFault(400, cMsg )

			cJson+=CRLF+CRLF+'{ "Resultado":"F", "msg":"' + cMsg + '"} '

			cMsgPnl+= CRLF 
			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			If SD1->(dbSeek(cDoc,.T. ))
				While SD1->D1_FILIAL+SD1->D1_DOC == Alltrim(cDoc)
					RecLock("SD1",.F.)
						SD1->D1_XSTAWMS:= "X" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
					SD1->(MsUnlock())
					SD1->(DbSkip())
				EndDo
			EndIf

			DbSelectArea("ZA1")
			RecLock("ZA1",.T.)
			ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
			ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
			ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
			ZA1->ZA1_TIPOTR:= "R"
			ZA1->ZA1_ORIGEM:= "WS_NOTAF"
			ZA1->ZA1_DATATR:= date()
			ZA1->ZA1_HORATR:= time()
			ZA1->ZA1_USERTR:= 'CyberLog'//upper(UsrRetName(__cUserId))
			ZA1->ZA1_JSON  := cJson
			ZA1->ZA1_TPMOV := '6'
			ZA1->(MsUnlock())

	Endif

	FreeObj(oJSON)

Return lRet

//-------------------------------------------------------------------------------------------------------------------------------------------------
WSMethod POST RecInvent WSReceive json_dados WSService wscyberlog

	Local aAuto    := {}
	Local cJson    := self:getContent()
	Local cMsgPnl  := ''
	Local cMsg     := ''
	Local oJson    := Nil
	Local nX1      := 0
	Local nX2      := 0
	Local lRet     := .T.
	Local nOpc     := 0
	Local lExecuta := GetNewPar("SF_WMSINV",.F.)

	Private lMSErroAuto := .F.

	/*TAGs do Retorno Inventario

	oJSON:empresa
	oJSON:documento
	oJSON:data
	oJSON:status
	itensInventario->	oJSON:itensInventario[nX]:codigoReduzido
						oJSON:itensInventario[nX]:quantidade": "10.0"
						oJSON:itensInventario[nX]:noLayout": 1
						loteItensInventario->	oJSON:itensInventario[nX]:loteItensInventario[nY]:noLote
												oJSON:itensInventario[nX]:loteItensInventario[nY]:quantidade
												oJSON:itensInventario[nX]:loteItensInventario[nY]:validadeLote
												oJSON:itensInventario[nX]:loteItensInventario[nY]:dataFabricacao

	*/

	::SetContentType("application/json")	

	MakeDir("\WEB\WSCYBERLOG\")

	If lExecuta
	
		If !FWJsonDeserialize(cJson, @oJSON)
			cMsg:= 'Ocorreu erro no processamento do JSON.'
			lRet := .F.
		Else

			cDocumen:= oJSON:documento
			dData	:= U_DtJsonERP(oJSON:data)[1]

			If lRet

				For nX1:=1 to len(oJSON:itensInventario)

					cProduto:= padr(oJSON:itensInventario[nX1]:codigoReduzido, TamSX3("B1_COD")[1])

					dbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					If ! SB1->(dbSeek(xFilial("SB1")+Alltrim(cProduto)))
						cMsg:= 'Produto '+ Alltrim(cProduto) + ' nao existe no cadastro do Protheus.'
						lRet:= .F.
					Endif

					lRastro:= SB1->B1_RASTRO == 'L'

					If lRastro .And. lRet

						For nX2:=1 to len(oJSON:itensInventario[nX1]:loteItensInventario)

							nQtd	:= oJSON:itensInventario[nX1]:loteItensInventario[nX2]:quantidade
							
							aAuto	:= {}
							Aadd(aAuto,{"B7_FILIAL"  ,FWxFilial("SB7")	, Nil}) // 1
							Aadd(aAuto,{"B7_COD"     ,cProduto			, Nil}) // 2 
							Aadd(aAuto,{"B7_LOCAL"   ,SB1->B1_LOCPAD	, Nil}) // 3
							Aadd(aAuto,{"B7_TIPO"    ,SB1->B1_TIPO		, Nil}) // 3
							Aadd(aAuto,{"B7_DOC"     ,cDocumen			, Nil}) // 4
							Aadd(aAuto,{"B7_QUANT"   ,nQtd				, Nil}) // 5
							Aadd(aAuto,{"B7_DATA"    ,dData				, Nil}) // 6
							Aadd(aAuto,{"B7_ORIGEM" , "WS_RECINVENT"	, NIL})
							Aadd(aAuto,{"B7_STATUS" , "1" 				, NIL})						
							Aadd(aAuto,{"INDEX" ,1						, Nil}) // 7

							dbSelectArea("SB7")
							dbSetOrder(1)

							// SE NÃO EXISTIR O REGISTRO, EXECUTA MSExecAuto() PARA INCLUIR.
							MSExecAuto({|x,y| mata270(x,y)},aAuto,3) 
								
							If lMSErroAuto 
									//MostraErro("\WEB\WSCYBERLOG\", "ERR_INVENT.TXT")
									cMsg:= ''//U_WSTxtLog("\WEB\WSCYBERLOG\ERR_INVENT.TXT")

									lRet := .F.
								
								Else
									lRet:= .T.
							Endif

						Next nX2

					Else

						If lRet

							SB7->(DbSetOrder(1))
							If SB7->(DbSeek(FWxFilial("SB7") + dData + cProduto + SB1->B1_LOCPAD))
								nQtd := SB7->B7_QUANT + oJSON:itensInventario[nX1]:quantidade
								nOpc := 4
							Else
								nQtd := oJSON:itensInventario[nX1]:quantidade
								nOpc := 3
							End

							aAuto	:= {}
							Aadd(aAuto,{"B7_FILIAL"  	,FWxFilial("SB7")	, Nil}) // 1
							Aadd(aAuto,{"B7_COD"     	,cProduto			, Nil}) // 2 
							Aadd(aAuto,{"B7_LOCAL"   	,SB1->B1_LOCPAD		, Nil}) // 3
							Aadd(aAuto,{"B7_TIPO"    	,SB1->B1_TIPO		, Nil}) // 3
							Aadd(aAuto,{"B7_DOC"     	,cDocumen			, Nil}) // 4
							Aadd(aAuto,{"B7_QUANT"   	,nQtd				, Nil}) // 5
							Aadd(aAuto,{"B7_DATA"    	,dData				, Nil}) // 6
							//Aadd(aAuto,{"B7_LOCALIZ" 	,cEndWMS			, Nil}) // 7
							Aadd(aAuto,{"B7_ORIGEM" 	, "WS_RECINVENT"	, NIL})
							Aadd(aAuto,{"B7_STATUS" 	, "1" 				, NIL})						
							Aadd(aAuto,{"INDEX"	 		,1					, Nil}) // 7
								
							dbSelectArea("SB7")
							dbSetOrder(1)

							// SE NÃO EXISTIR O REGISTRO, EXECUTA MSExecAuto() PARA INCLUIR.
							//MSExecAuto({|x,y| mata270(x,y)},aAuto,3) 
							MSExecAuto({|x,y,z| mata270(x,y,z)},aAuto,nOpc)
								
							If lMSErroAuto 
								MostraErro("\WEB\WSCYBERLOG\", "ERR_INVENT.TXT")
								cMsg:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_INVENT.TXT")

								lRet := .F.
							Else
								lRet:= .T.
							Endif
							
						End

					Endif

				Next nX1

			Endif

		Endif

		If lRet
			cMsg:= '{"Resultado": "T", "msg": "Recepcao com Sucesso" }'	
			::SetResponse( cMsg )
			cJson+=CRLF+CRLF+ cMsg + CRLF

		Else
			cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
			cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF


			cMsgPnl+= cMsg 

			SetRestFault(400, cMsg )

			cJson+=CRLF+CRLF+'{ "Resultado":"F", "msg":"' + cMsg + '"} '

			cMsgPnl+= CRLF 

			DbSelectArea("ZA1")
			RecLock("ZA1",.T.)
			ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
			ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
			ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
			ZA1->ZA1_TIPOTR:= "R"
			ZA1->ZA1_ORIGEM:= "WS_INVENT"
			ZA1->ZA1_DATATR:= date()
			ZA1->ZA1_HORATR:= time()
			ZA1->ZA1_USERTR:= 'CyberLog'//upper(UsrRetName(__cUserId))
			ZA1->ZA1_JSON  := cJson
			ZA1->ZA1_TPMOV := '1' //Inventario
			ZA1->(MsUnlock())

		Endif

		FreeObj(oJSON)

	End

	Reset Environment

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVldSC9
Funcao para validar o SC9 
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
Static Function fVldSC9()
	Local aRet:= array(2)

	aRet[1]:= .T.
	aRet[2]:= ''

	/*If Empty(SC9->C9_XSTAWMS) //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
		aRet[1]:= .F.
		aRet[2]:= 'Item do Pedido de Venda com status de não enviado ao WMS.'
	Endif

	If aRet[1] .and. SC9->C9_XSTAWMS == 'F'
		aRet[1]:= .F.
		aRet[2]:= 'Item do Pedido de Venda com falha de envio ao WMS, favor verificar LOG de envio.'
	Endif*/

	If aRet[1] .and. SC5->C5_XSTAWMS == 'O'
		aRet[1]:= .T.
		aRet[2]:= 'Item do Pedido de Venda com retorno do WMS ja processado.'
	Endif

	If aRet[1] .and. SC9->C9_BLCRED == "10" .AND. SC9->C9_BLEST == "10"
		aRet[1]:= .T.
		aRet[2]:= 'Pedido de Venda ja emitido Nota Fiscal.'
	EndIf

	If aRet[1] .and. !Empty(SC9->C9_BLCRED)
		aRet[1]:= .T.
		If SC9->C9_BLCRED == "09"
			aRet[2]:= 'A Liberacao de um Pedido Rejeitado deve ser efetuada na Liberacao Manual de Credito.'
		Else
			aRet[2]:= 'Para efetuar a Liberacao no Estoque e necesscrio que o Pedido esteja  liberado no Credito.'
		EndIf

	EndIf

	If aRet[1] .and. SC9->C9_LOCAL==SuperGetMV("MV_CQ", .F.,"98")
		aRet[1]:= .F.
		aRet[2]:= 'Nao e permitida a liberacao de estoque manual de produtos bloqueados no CQ.'
	EndIf

	/*If aRet[1] .and. SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "  " .And. SC9->C9_BLWMS == "  "
		aRet[1]:= .F.
		aRet[2]:= 'Pedido ja liberado.'
	EndIf

	If aRet[1] .and. !Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST)
		aRet[1]:= .F.
		aRet[2]:= 'Pedido bloqueado no Credito.'
	EndIf		*/						

Return aRet

/*/{Protheus.doc} RecAvarias
    Registra os produtos que tiverem avarias
    @type Restfull
    @version 1.0
    @author Alfred Andersen
    @since 8/26/2024
/*/
WSMethod POST RecAvarias WSReceive json_dados WSService wscyberlog

	Local cJson         := self:getContent()
	Local cMsgPnl       := ''
	Local cMsg          := ''
	Local oJson         := Nil
	Local lRet          := .T.

	Local aMata410c := {}
	Local aMata410i	:= {}

	Private lMSErroAuto := .F.

	/*TAGs do Retorno Inventario

	oJSON:empresa
	oJSON:descTarefa
	oJSON:tipo
	oJSON:data
	oJSON:status
	layoutEntrada->	oJSON:layoutEntrada[nX]:codigoReduzido: "PRODX"
						oJSON:layoutEntrada[nX]:erpId": "034X555"
						oJSON:layoutEntrada[nX]:quantidade":"10.0"
	*/

	::SetContentType("application/json")	

	MakeDir("\WEB\WSCYBERLOG\")
		
	If !FWJsonDeserialize(cJson, @oJSON)

		cMsg:= 'Ocorreu erro no processamento do JSON.'
		lRet := .F.

	Else

		cTarefa := oJSON:descTarefa
		dData   := STOD(oJSON:data) //U_DtJsonERP(oJSON:data)[1]

		If lRet
					
			cPedAux := GETSXENUM("SC5","C5_NUM")

			ConfirmSX8() 

			// monta cabeçalho do pedido de venda base para alteração
			aAdd( aMata410c , { "C5_NUM"  	 , cPedAux         	, nil } ) 
			aAdd( aMata410c , { "C5_TIPO"    , "N"         		, nil } ) 
			aAdd( aMata410c , { "C5_CLIENTE" , "28736"	 		, nil } ) 
			aAdd( aMata410c , { "C5_LOJACLI" , "01" 			, nil } ) 
			aAdd( aMata410c , { "C5_CONDPAG" , "01"   			, nil } ) 
			aAdd( aMata410c , { "C5_MENNOTA" , "AVARIA/AMOSTRA" , nil } ) 
			
			cCodigo := oJSON:layoutEntrada[1]:codigoReduzido
			cErpId  := oJSON:layoutEntrada[1]:erpId
			cQtd    := oJSON:layoutEntrada[1]:quantidade
				
			//adiciona a linha
			aAdd(aMata410i,{;
							{ "C6_ITEM"    , "01" 	, nil},;
							{ "C6_PRODUTO" , cErpId , nil},;
							{ "C6_QTDVEN"  , cQtd 	, nil},;
							{ "C6_OPER"     , "D" 	, nil}})


			Begin Transaction 
			
			lMsErroAuto := .F.
			lRet        := .F.

			// executa Alteração	
			msExecAuto({|x,y,z|Mata410(x,y,z)},aMata410c,aMata410i,3)
			
			//verifica se houve erro
			If lMsErroAuto
				lErro := .T.	

				MostraErro("\WEB\WSCYBERLOG\", "ERR_AVARIAS.TXT")
				cMsg:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_AVARIAS.TXT")
				
			Else           

				lRet := .T.

			Endif
			
			End Transaction


		Endif

	Endif

	If lRet
		cMsg:= '{"Resultado": "T", "msg": "Recepcao com Sucesso" }'	
		::SetResponse( cMsg )
		cJson+=CRLF+CRLF+ cMsg + CRLF

	Else
		cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
		cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF


		cMsgPnl+= cMsg 

		SetRestFault(400, cMsg )

		cJson+=CRLF+CRLF+'{ "Resultado":"F", "msg":"' + cMsg + '"} '

		cMsgPnl+= CRLF 

		DbSelectArea("ZA1")
		RecLock("ZA1",.T.)
		ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
		ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
		ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
		ZA1->ZA1_TIPOTR:= "R"
		ZA1->ZA1_ORIGEM:= "RecAvarias"
		ZA1->ZA1_DATATR:= date()
		ZA1->ZA1_HORATR:= time()
		ZA1->ZA1_USERTR:= 'CyberLog'//upper(UsrRetName(__cUserId))
		ZA1->ZA1_JSON  := cJson
		ZA1->ZA1_TPMOV := '1' //Inventario
		ZA1->(MsUnlock())

	Endif

	FreeObj(oJSON)

	Reset Environment

Return lRet

/*/{Protheus.doc} RecRomaneio
    Registra os Romaneios realizados no Cyberlog
    @type Restfull
    @version 1.0
    @author Alfred Andersen
    @since 10/06/2024
/*/
WSMethod POST RecRomaneio WSReceive json_dados WSService wscyberlog

	Local cJson     := Self:getContent()
	Local oJson     := Nil
	Local oClass    := TIntegracaoProtheusxWMSCyberlog():New()
	Local lRet      := .T.
	Local cAlias    := GetNextAlias()
	Local cSeq      := "000"
	Local cCodZ03   := ""
	Local aDadosZ03 := {}
	Local aDadosZ04 := {}
	Local nX        := 0
	Local jResponse := JsonObject():New()

	Local __cFil	:= "020201"

	Conout("01 - Filial logada" + cFilAnt)

	If cFilAnt <> __cFil
		
		lRet := .F.

		Self:setStatus(405) 
		jResponse[ 'Data' ]    := Nil
		jResponse[ 'Message' ] := 'Filial '+cFilAnt+' inválida'
		jResponse[ 'Status' ]  := lRet

		//Define o retorno
		Self:SetResponse(jResponse:toJSON())

		Return lRet		
	
	End

	Self:SetContentType("application/json")	

	MakeDir("\WEB\WSCYBERLOG\")
		
	If !FWJsonDeserialize(cJson, @oJSON)

		lRet := .F.

		Self:setStatus(400) 
		jResponse[ 'Data' ]    := Nil
		jResponse[ 'Message' ] := 'Erro ao fazer o Parse do JSON'
		jResponse[ 'Status' ]  := lRet

		//Define o retorno
		Self:SetResponse(jResponse:toJSON())

		Return lRet		

	Else

		If oJSON:expedicao

			cRomaneioWMS := cValtoChar(oJSON:numero)
			cTransp      := Padl(oJSON:noRota,6,"0")
			dData        := STOD(oJSON:data) //U_DtJsonERP(oJSON:data)[1]
			nVolTotal    := 0
			nVlrTotal    := 0

			For nX := 1 to Len(oJSON:pedidosCarga)

				cPedido  := oJSON:pedidosCarga[nX]:erpId

				If Empty(cCodZ03)
					cCodZ03 := GETSXENUM("Z03","Z03_COD")  	
					ConfirmSX8()    
				End     

				If Select(cAlias) > 0
					DbSelectArea(cAlias)
					DbCloseArea()
				EndIf                                                                                           

				BeginSql Alias cAlias
							
					SELECT
						F2_FILIAL, F2_CLIENTE, F2_LOJA, F2_VOLUME1, F2_DOC, F2_SERIE, F2_CHVNFE, F2_EMISSAO, F2_CARGA, F2_VALBRUT
					FROM 
						%Table:SC5% SC5
					INNER JOIN %Table:SF2% SF2 ON F2_FILIAL = C5_FILIAL 
						AND F2_DOC = C5_NOTA 
						AND F2_SERIE = C5_SERIE
						AND F2_CLIENTE = C5_CLIENTE
						AND F2_LOJA = C5_LOJACLI
						AND SF2.%NOTDEL%
					WHERE C5_FILIAL = %xFilial:SC5%
						AND C5_FILIAL + C5_NUM = %Exp:cPedido%
						AND SC5.%NOTDEL%
				EndSql	

				While (cAlias)->(!EOF())

					cSeq      := Soma1(cSeq)
					dData     := STOD((cAlias)->F2_EMISSAO)
					cChaveNFe := Alltrim((cAlias)->F2_CHVNFE)
					nValorNFe := (cAlias)->F2_VALBRUT
					cCarga    := (cAlias)->F2_CARGA
					cCliente  := (cAlias)->F2_CLIENTE
					cLoja     := (cAlias)->F2_LOJA
					cNota     := (cAlias)->F2_DOC
					cSerie    := (cAlias)->F2_SERIE
					nVolume   := (cAlias)->F2_VOLUME1
					//cTransp   := (cAlias)->F2_TRANSP

					aAdd(aDadosZ04,{cCodZ03, cSeq, cChaveNFe, cNota, cSerie, cCliente, cLoja, nVolume, nValorNFe, dData, cCarga})	

					lRet := oClass:Packinglist(aDadosZ03,aDadosZ04)

					nVolTotal += nVolume
					nVlrTotal += nValorNFe
					aDadosZ04 := {}

					(cAlias)->(dbSkip())        
				Enddo 

			Next nX

			If lRet

				aAdd(aDadosZ03,{cCodZ03, cTransp, nVolTotal, nVlrTotal, cRomaneioWMS})

				lRet := oClass:Packinglist(aDadosZ03,aDadosZ04)

			End

			If !lRet

				Self:setStatus(400) 
				jResponse[ 'Data' ]    := Nil
				jResponse[ 'Message' ] := 'Falha na gravação do Romaneio no Protheus. Tabelas Z03 e Z04.'
				jResponse[ 'Status' ]  := lRet

				//Define o retorno
				Self:SetResponse(jResponse:toJSON())

			Else

				Self:setStatus(200) 
				jResponse[ 'Data' ]    := cCodZ03
				jResponse[ 'Message' ] := 'Romaneio cadastrado com sucesso no Protheus"
				jResponse[ 'Status' ]  := lRet

				//Define o retorno
				Self:SetResponse(jResponse:toJSON())
			End

		Else

			lRet := .F.

			Self:setStatus(403) 
			jResponse[ 'Data' ]    := Nil
			jResponse[ 'Message' ] := 'JSON não é de Expedição, não será realizado o Romaneio no Protheus'
			jResponse[ 'Status' ]  := lRet

			//Define o retorno
			Self:SetResponse(jResponse:toJSON())

		End

	Endif

	If !lRet

		DbSelectArea("ZA1")
		RecLock("ZA1",.T.)
			ZA1->ZA1_FILIAL := FWxFilial("ZA1")
			ZA1->ZA1_STATUS := iIf(lRet,"1","0")
			ZA1->ZA1_NRTRAN := U_fIDWmsErp()
			ZA1->ZA1_TIPOTR := "R"
			ZA1->ZA1_ORIGEM := "RecRomaneio"
			ZA1->ZA1_DATATR := date()
			ZA1->ZA1_HORATR := time()
			ZA1->ZA1_USERTR := 'CyberLog' //upper(UsrRetName(__cUserId))
			ZA1->ZA1_JSON   := cJson
			ZA1->ZA1_TPMOV  := '1' //Inventario
		ZA1->(MsUnlock())

	Endif

	FreeObj(oJSON)

Return lRet
