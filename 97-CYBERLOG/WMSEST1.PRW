#include "protheus.ch"
#include "rwmake.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#Include "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch" 


// @author Layze Fuzinato
// @date 15/04/2021
// @description Consulta Estoque


User Function fExpIteX() 
Local aSC9		:= GetArea()
Local aRet		:= array(3)
Local lEDIOk	:= .T.
Local lIntegra	:= ''
Local cMsgPnl	:= ''
Local cRet 		:= ''
Local nX
Local cIntegra  := '' 
Local lentra    := .T.
Private cMsg      := ''

Private cOpera	:= "E" //Variavel do Tipo Private que sera usada no Layout do Envio do Pedido na Tabla ZA3, para definir se é uma inclusao ou exclusao
Private cLayOut := ''
Private cTab	:= ''
Private nIndice 
Private cCpsPesq:= ''
Private cChvPesq:= ''

	If Select( "TMP" ) != 0 
          TMP->( dbCloseArea() )
    EndIf 

	cQry:= " SELECT TOP 1 * FROM "+RETSQLNAME('DAI')+" "
	cQry+= " WHERE D_E_L_E_T_ = '' "
	cQry+= " AND DAI_COD = '"+DAK->DAK_COD+"' "
	cQry+= " AND DAI_FILIAL = '"+DAK->DAK_FILIAL+"' "

	TCQuery cQry New Alias "TMP"

    dbSelectArea("TMP") 
    dbGoTop()
	While TMP->(!EOF())
		IncProc("Enviando Itens...")
		DbSelectArea('DAI')
		DbSetOrder(1)
		If DbSeek(TMP->DAI_FILIAL+TMP->DAI_COD+TMP->DAI_SEQCAR+TMP->DAI_SEQUEN)
			aRet:= U_xWMSEST( '018', 'DAI', 7, 'DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN', DAI->DAI_FILIAL+DAI->DAI_COD+DAI->DAI_SEQCAR+DAI->DAI_SEQUEN) 
		EndIf
		TMP->(DbSkip())
	EndDo

RestArea(aSC9)

MsgInfo("Carga enviada com sucesso!")

Return


User Function xWMSEST(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
Local aZA2		:= GetArea()
Local lRet		:= .T.
Local cEndWS	:= ''
Local cMetodo	:= ''
Local cBody 	:= ''
Local cChave	:= GetMV("FZ_WSCHWMS")
Local cToken	:= ''
Local cTipoMov	:= ''
Local cOrigMov	:= ''
Local aOK 		:= array(2)
Local aRet		:= array(3)
Local aHeader	:= {}
Local aLogIn	:= {}
Local oJson		
Local oRest
Local oObj

Local cError	:= ''
Local cCodRet	:= ''
Local cRetJson	:= ''
Local cJson		:= ''
Local nStatus	:= 0

Local cWSPar1:= alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
Local cWSPar2:= alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
Local cWSPar3:= alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		
Local cWSPar4:= alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		
Local cWSPar5:= alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
Local cWSPar6:= alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	
Local cWSPar7:= alltrim(GetMv("FZ_WSWMS7"))	//"[FZ_WSWMS7] - Código do Layout de Integração do WS CyberLog WMS - [Manutencao de Lotes]"	
Local cWSPar8:= alltrim(GetMv("FZ_WSWMS8"))	//"[FZ_WSWMS8] - Código do Layout de Integração do WS CyberLog WMS - [Movimentacao de Interna]"	
Local cWSPar9:= alltrim(GetMv("FZ_WSWMS9"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Transferencias]"	
Local cWSParA:= alltrim(GetMv("FZ_WSWMSA"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Aceite]"	
Local cWSParB:= alltrim(GetMv("FZ_WSWMSB"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	
Local cWSParD:= alltrim(GetMv("FZ_WSWMSD"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	

Private cLayOut:= alltrim(cLayOut)
aLogIn:= U_fLgInJson()

If aLogIn[1] .and. !Empty(aLogIn[3]) 

	cToken:= aLogIn[3]
	AAdd(aHeader,'Accept: application/json')
	aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')
	aAdd(aHeader,"chave: "+ 'jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI')
	//aAdd(aHeader,"chave: "+ cChave)
	aAdd(aHeader,"token: "+ cToken)

	cJson:= "{Header"+ CRLF
	//cJson+= 'Content-Type: application/x-www-form-urlencoded' + CRLF 
	
	cJson+= "chave: "+ 'jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI' + CRLF
	//cJson+= "chave: "+ cChave + CRLF
	cJson+= "token: "+ cToken + "}" + CRLF + CRLF

	DbSelectArea("ZA2")
	ZA2->(DbSetOrder(1)) //Filial+Codigo Layout+Nome da TAG
	If ZA2->(DbSeek(FWxFilial("ZA2")+cLayOut,.T.))

		cEndWS:= alltrim(ZA2->ZA2_ENDWS)+":"+alltrim(ZA2->ZA2_PORWS)
		cMetodo:= alltrim(ZA2->ZA2_METWS)
		//cBody:= "'" + U_xWMSES1("018",cTab,nIndice,cCpsPesq,cChvPesq,"carga") +"&"
		cBody+= U_xWMSES1("018",cTab,nIndice,cCpsPesq,cChvPesq,ZA2->ZA2_CHVPAR) 
		//cBody+= U_xWMSES1("019",cTab,nIndice,cCpsPesq,cChvPesq,'"pedidosCarga"') 

		cJson+= cBody

		//Monta a conexão com o servidor REST
		oRest := FWRest():New(cEndWS) 
		oRest:setPath(cMetodo)  
		
		//Definindo o parâmetro a ser usado no POST
		cBody := FWNoAccent(cBody)
		oRest:SetPostParams(cBody)
		oRest:SetChkStatus(.F.)
		
		//Publica a alteração, e caso não dê certo, mostra erro
		If ! oRest:Post(aHeader)
			lret:= .F.
			cCodRet:= "999"
			cMsg:= 'Atenção !!! Houve erro na atualização no servidor!' + CRLF + ;
				'Contate o Administrador!' + CRLF 
			//	"Erro: " + oRest:GetLastError() + CRLF + "Result: " + oRest:GetResult()
		Else

			FWJsonDeserialize(oRest:GetResult(),@oObj)
			cError := ""
			nStatus := HTTPGetStatus(@cError)

			if nStatus >= 200 .And. nStatus <= 299
				if Empty(oRest:getResult())
					lret:= .F.
					cCodRet:= "ERRO: " + cvaltochar(nStatus)
					cMsg:= "GetStatus: " + str(nStatus)
				else
					oJson:= JsonObject():New()
					cRetJson:= oJson:fromJson(oRest:GetResult())
					If ValType(cRetJson) != "U"
						lRet:= .F.
						cCodRet:= "999"
						cMsg:= 'Falha ao popular JsonObject. Erro: ' + cRetJson

					Else

						If !Empty(oJson["CyberWeb"])
							cCodRet:= alltrim(oJson["CyberWeb"])
							If substr(cCodRet,1,1)=="!"
								cCodRet:= substr(cCodRet,2,len(cCodRet))
							Endif
							cMsg:= "Serviço: " + cLayOut + CRLF
							cMsg+= "Método: "+ cMetodo + CRLF

							aOk:= fRslCnx(cLayOut, val(cCodRet))
							cMsg+= "Codigo Retorno: " +  aOK[2]

							If ! aOK[1]
								lRet:= .f.
							Endif
						Else
							lRet:= .F.
							cCodRet:= "999"
							cMsg:= "ERRO: Chave Json [CYBERWEB]"
						Endif
					Endif
				endif
			else
				lRet:= .F.
				cCodRet:= "999"
				cMsg:= cError
			endif
		Endif

	Endif

	//Faz o LogOut no WS do WMS
	U_fLgOuJson(cToken)
Else
	lret:= .F.
	cCodRet:= "999"
	cMsg:= "Não foi possivel fazer o Login!!!"+ CRLF + aLogIn[2]
Endif

cJson+=CRLF+CRLF+"{ Resultado"+ CRLF
cJson+="Codigo Retorno:" + cCodRet + CRLF
cJson+="Mensagem: "+ cMsg + "}"

aRet[1]:= lRet
aRet[2]:= cCodRet
aRet[3]:= cMsg
	
If cLayOut == cWSPar1
	cTipoMov:= "1"
	cOrigMov:= "[Cadastro PRODUTOS]"

ElseIf cLayOut == cWSPar2
	cTipoMov:= "2"
	cOrigMov:= "[Cadastro FORNECEDOR]"

ElseIf cLayOut == cWSPar3
	cTipoMov:= "3"
	cOrigMov:= "[Cadastro CLIENTE]"

ElseIf cLayOut == cWSPar4
	cTipoMov:= "4"
	cOrigMov:= "[Cadastro PESSOAS]"

ElseIf cLayOut == cWSPar5
	cTipoMov:= "5"
	cOrigMov:= "[Pedido de Vendas]"

ElseIf cLayOut == cWSPar6
	cTipoMov:= "6"
	cOrigMov:= "[Recebimentos Nota Fiscal]"

ElseIf cLayOut == cWSPar7
	cTipoMov:= "7"
	cOrigMov:= "[Manutencao de Lotes]"

ElseIf cLayOut == cWSPar8
	cTipoMov:= "8"
	cOrigMov:= "[Movimentos Internos]"

ElseIf cLayOut == cWSPar9
	cTipoMov:= "9"
	cOrigMov:= "[Transferencias]"		

ElseIf cLayOut == cWSParA
	cTipoMov:= "A"
	cOrigMov:= "[Aceite]"	

ElseIf cLayOut == cWSParB
	cTipoMov:= "B"
	cOrigMov:= "[Consulta Estoque]"	

ElseIf cLayout == cWSParD
	cTipoMov:= "D"
	cOrigMov:= "[Cargas]"	

Endif

If !lRet
	DbSelectArea("ZA1")
	RecLock("ZA1",.T.)
	ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
	ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
	ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
	ZA1->ZA1_TIPOTR:= "E"
	ZA1->ZA1_ORIGEM:= cOrigMov
	ZA1->ZA1_DATATR:= date()
	ZA1->ZA1_HORATR:= time()
	ZA1->ZA1_USERTR:= upper(UsrRetName(__cUserId))
	ZA1->ZA1_JSON  := cJson
	ZA1->ZA1_TPMOV := cTipoMov
	ZA1->(MsUnlock())

EndIf 

FreeObj(oObj)
FreeObj(oRest)
FreeObj(oJSON)

RestArea(aZA2)
Return aRet


User Function xWMSES1(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq,cChvParam)
Local aZA3	:= GetArea()
Local nCont	:= 1
Local cValor:= ''
Local cCont	:= ''
Local cRet	:= ''

If !Empty(cChvParam)
	cRet := alltrim(cChvParam)+'={'
else
	cRet := '{'
Endif

DbSelectArea("ZA3")
ZA3->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
If ZA3->(DbSeek(FWxFilial("ZA3")+cLayOut,.T.))

	While !ZA3->(Eof()) .and. ZA3->ZA3_COD==cLayOut

		
		If ZA3->ZA3_TIPTAG == '1'

			If empty(ZA3->ZA3_CONTEU)
				If ZA3->ZA3_TPDADO == '2'
					cCont:= cvaltochar(0)
				Else
					cCont:= 'null'
				Endif
			Else
		
				If "->"  $ alltrim(ZA3->ZA3_CONTEU) .or. "U_"  $ upper(alltrim(ZA3->ZA3_CONTEU)) .or. ;
					( ("("  $ alltrim(ZA3->ZA3_CONTEU)) .and. (")"  $ alltrim(ZA3->ZA3_CONTEU)) )

					cValor:= &(ZA3->ZA3_CONTEU)
				Else
					cValor:= ZA3->ZA3_CONTEU
				Endif

				If ZA3->ZA3_TPDADO == '1'
					cCont:= '"' + alltrim( substr(cValor,1,ZA3->ZA3_TAMANH) ) + '"'

				elseIf ZA3->ZA3_TPDADO == '2' .and. ZA3->ZA3_DECIMA = 0
					cCont:= alltrim(cvaltochar(cValor))

				elseIf ZA3->ZA3_TPDADO == '2' .and. ZA3->ZA3_DECIMA != 0
					//cCont:= padl(strtran(strtran(cValor,".",""),",",""),nDec) 
					cCont:= alltrim(cvaltochar(cValor))

				ElseIf ZA3->ZA3_TPDADO == '3'
					cCont:= '"'+ DTOS(cValor) + '"'

				ElseIf ZA3->ZA3_TPDADO == '4'
					If Substr(cValor,1,1) $ "V|T"
						cCont:= 'True'
					Else
						cCont:= 'false'
					Endif
				Endif

			Endif

			cRet	+= '"' + alltrim(ZA3->ZA3_TAG) + '":'+ cCont
			cValor	:= ''
			cCont	:= ''
			
		else

			If !Empty(ZA3->ZA3_CODARR)
				lRet:= .T.
				cRet+= '"' + alltrim(ZA3->ZA3_TAG) + '": ['
				//cPedido:= ''
				DbSelectArea(cTab)
				(cTab)->(DbSetOrder(nIndice))
				If (cTab)->(DbSeek(cChvPesq,.T.))
					While ! (cTab)->(Eof()) .and. (cTab)->&(cCpsPesq) == cChvPesq
							cPedido:= ''
							DbSelectArea('SC9')
							DbSetOrder(12)
							If SC9->(DbSeek(cChvPesq+(cTab)->DAI_PEDIDO,.T.))
								While ! SC9->(Eof()) .and. SC9->(C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT) == cChvPesq
									If lRet .OR. cPedido <> SC9->C9_PEDIDO
										cPedido:= SC9->C9_PEDIDO
										If nCont > 1
											cRet+= ','
										Endif
										cRet+=  U_Xwmses2(ZA3->ZA3_CODARR,,,,cChvPesq) 
										lRet:= .F.
									EndIf
									SC9->(DbSkip())
									nCont++
								EndDo
							EndIf
						
						(cTab)->(DbSkip())
						
					End
				Endif

				cRet+= ']'
			Else
				cRet+= '"' + alltrim(ZA3->ZA3_TAG) + '": null'
			Endif			

		Endif

		ZA3->(DbSkip())

		If ZA3->ZA3_COD == cLayOut
			cRet+= ","
		Endif

	End
Endif

If !Empty(cChvParam)
	cRet += '}'
else
	cRet += '}'
Endif

RestArea(aZA3)
Return cRet


User Function Xwmses2(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
//Local aZA4	:= GetArea()
Local cValor:= ''
Local cCont	:= ''
Local cRet	:= '{'
Local nCont	:= 1
Private cChave:= cChvPesq
Private lRet := .T.
Private cNum:= ''


DbSelectArea("ZA4")
ZA4->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
If ZA4->(DbSeek(FWxFilial("ZA4")+cLayOut,.T.))

	If Select ("QRY") > 0
		QRY->(DbCloseArea())
	Endif	

	cQuery:= " SELECT DISTINCT(C9_PEDIDO), C9_FILIAL,C9_CARGA,C9_SEQCAR,C9_SEQENT,C9_PEDIDO FROM SC9010 "
	cQuery+= " WHERE C9_FILIAL = '020201' "
	cQuery+= " AND C9_CARGA = '"+Substr(cChave,7,6)+"' "
	cQuery+= " AND C9_SEQCAR = '"+Substr(cChave,13,2)+"' "
	cQuery+= " AND D_E_L_E_T_ = '' "

	TCQUERY cQuery NEW ALIAS "QRY"    

	DbSelectArea("QRY")
	DbGoTop()
	While QRY->(!EOF())
			If nCont > 1
				cRet+= '},{'
			Endif
			lLayout:= .T.
			If lRet .OR. cNum <> SC9->C9_PEDIDO
				cNum:= SC9->C9_PEDIDO
				DbSelectArea("ZA4")
				ZA4->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
				If ZA4->(DbSeek(FWxFilial("ZA4")+cLayOut,.T.))
					While !ZA4->(Eof()) .and. ZA4->ZA4_COD==cLayOut
						If ZA4->ZA4_TIPTAG == '1'

							If empty(ZA4->ZA4_CONTEU)

								If ZA4->ZA4_TPDADO == '2'
									cCont:= cvaltochar(0)
								Else
									cCont:= 'null'
								Endif

							Else

								If "->"  $ alltrim(ZA4->ZA4_CONTEU) .or. "U_"  $ upper(alltrim(ZA4->ZA4_CONTEU)) .or. ;
								( ("("  $ alltrim(ZA4->ZA4_CONTEU)) .and. (")"  $ alltrim(ZA4->ZA4_CONTEU)) )

									cValor:= &(ZA4->ZA4_CONTEU)
								Else
									cValor:= ZA4->ZA4_CONTEU
								Endif

								If ZA4->ZA4_TPDADO == '1'
									cCont:= '"' + alltrim( substr(cValor,1,ZA4->ZA4_TAMANH) ) + '"'

								elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA = 0
									cCont:= cvaltochar(cValor)

								elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA != 0
									cCont:= cvaltochar(cValor)

								ElseIf ZA4->ZA4_TPDADO == '3'
									cCont:= '"'+ DTOS(cValor) + '"'

								ElseIf ZA3->ZA3_TPDADO == '4'
									If Substr(cValor,1,1) $ "V|T"
										cCont:= 'True'
									Else
										cCont:= 'false'
									Endif

								Endif

							Endif

							cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '":'+ cCont
							cValor	:= ''
							cCont	:= ''			

						else

							If !Empty(ZA4->ZA4_CODARR)
								cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '":[' + U_Xwmses3("018",,,,QRY->(C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT+C9_PEDIDO)) + ']'
								lLayout:= .F.
							Else
								cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '": null'
							Endif

						Endif

						If ZA4->ZA4_COD == cLayOut .And. lLayout
							cRet+= ","
						Endif

						ZA4->(DbSkip())
					EndDo
	
					lRet:= .F.
				EndIf
			EndIf
			nCont++
		QRY->(DbSkip())
	EndDo
Endif
	
cRet+= '}'

//RestArea(aZA4)
Return cRet


User Function Xwmses3(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
//Local aZA4	:= GetArea()
Local cValor:= ''
Local cCont	:= ''
Local cRet	:= '{'
Local nCont	:= 1
Private cChave:= cChvPesq
Private lRet := .T.
Private limp := .F.

DbSelectArea('SC9')
DbSetOrder(12)
SC9->(DbGoTop())
If DbSeek(cChave)
	While ! SC9->(Eof()) .and. SC9->(C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT+C9_PEDIDO) == cChave
		If nCont > 1
			cRet+= '},{'
			limp:= .T.
		Endif
			DbSelectArea("ZAC")
			ZAC->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
			If ZAC->(DbSeek(FWxFilial("ZAC")+cLayOut,.T.))
				While !ZAC->(Eof()) .and. ZAC->ZAC_COD==cLayOut
					If ZAC->ZAC_TIPTAG == '1'

						If empty(ZAC->ZAC_CONTEU)

							If ZAC->ZAC_TPDADO == '2'
								cCont:= cvaltochar(0)
							Else
								cCont:= 'null'
							Endif

						Else

							If "->"  $ alltrim(ZAC->ZAC_CONTEU) .or. "U_"  $ upper(alltrim(ZAC->ZAC_CONTEU)) .or. ;
							( ("("  $ alltrim(ZAC->ZAC_CONTEU)) .and. (")"  $ alltrim(ZAC->ZAC_CONTEU)) )

								cValor:= &(ZAC->ZAC_CONTEU)
							Else
								cValor:= ZAC->ZAC_CONTEU
							Endif

							If ZAC->ZAC_TPDADO == '1'
								cCont:= '"' + alltrim( substr(cValor,1,ZAC->ZAC_TAMANH) ) + '"'

							elseIf ZAC->ZAC_TPDADO == '2' .and. ZAC->ZAC_DECIMA = 0
								cCont:= cvaltochar(cValor)

							elseIf ZAC->ZAC_TPDADO == '2' .and. ZAC->ZAC_DECIMA != 0
								cCont:= cvaltochar(cValor)

							ElseIf ZAC->ZAC_TPDADO == '3'
								cCont:= '"'+ DTOS(cValor) + '"'

							ElseIf ZAC->ZAC_TPDADO == '4'
								If Substr(cValor,1,1) $ "V|T"
									cCont:= 'True'
								Else
									cCont:= 'false'
								Endif

							Endif

						Endif

						cRet+= '"' + alltrim(ZAC->ZAC_TAG) + '":'+ cCont
						cValor	:= ''
						cCont	:= ''			

					else

						If !Empty(ZAC->ZAC_CODARR)
							cRet+= '"' + alltrim(ZAC->ZAC_TAG) + '":[' + U_Xwmses3("018",,,,cChave) + ']'
						Else
							cRet+= '"' + alltrim(ZAC->ZAC_TAG) + '": null'
						Endif

					Endif

					ZAC->(DbSkip())

					If ZAC->ZAC_COD == cLayOut
						cRet+= ","
					Endif
			
				Enddo
			EndIF
		SC9->(DbSkip())
		//If limp
		//	cRet+= '}'
		//EndIf
		nCont++
	EndDo
EndIf

	
cRet+= '}'

//RestArea(aZA4)
Return cRet



//-------------------------------------------------------------------------------
/*/{Protheus.doc} fResulCnx
Função para Retornar o Resultado da Integração WS
@type function
@version 12.1.27
@author Carlos Cleuber
@since 21/12/2020
@param cLayout, character, codigo do layout do WebService
/*/
Static Function fRslCnx(cSrv, nCod)
Local aCodError:= {}
Local aRet:= array(2)
Local nPos:= 0
Local cWSPar1:= alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
Local cWSPar2:= alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
Local cWSPar3:= alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		
Local cWSPar4:= alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		
Local cWSPar5:= alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
Local cWSPar6:= alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	
Local cWSPar7:= alltrim(GetMv("FZ_WSWMS7"))	//"[FZ_WSWMS7] - Código do Layout de Integração do WS CyberLog WMS - [Manutencao de Lotes]"	
Local cWSPar8:= alltrim(GetMv("FZ_WSWMS8"))	//"[FZ_WSWMS8] - Código do Layout de Integração do WS CyberLog WMS - [Movimentacao de Interna]"	
Local cWSPar9:= alltrim(GetMv("FZ_WSWMS9"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Transferencias]"	
Local cWSParA:= alltrim(GetMv("FZ_WSWMSA"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Aceite do Produto]"	
Local cWSParB:= alltrim(GetMv("FZ_WSWMSB"))	//"[FZ_WSWMSB] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	
//Produto
aAdd( aCodError, {cWSPar1, 1 , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar1, 2 , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar1, 3 , 'Excluído'														, .t. } )
aAdd( aCodError, {cWSPar1, 4 , 'Não inserido(não há configuração de depósito para a empresa)'	, .f. } )
aAdd( aCodError, {cWSPar1, 5 , 'Não inserido(depósito informado não possui configuração)'		, .f. } )
aAdd( aCodError, {cWSPar1, 6 , 'Não inserido(ERPID vazio)'										, .f. } )
aAdd( aCodError, {cWSPar1, 7 , 'Não inserido(código de barras vazio)'							, .f. } )
aAdd( aCodError, {cWSPar1, 8 , 'Não inserido(código reduzido vazio)'							, .f. } )
aAdd( aCodError, {cWSPar1, 9 , 'Não inserido(fornecedor não existe no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar1, 42 , ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

aAdd( aCodError, {cWSPar2, 1, 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar2, 2, 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar2, 3, 'Excluído'														, .t. } )
aAdd( aCodError, {cWSPar2, 4, 'Não inserido(depósito informado não possui configuração)'		, .f. } )
aAdd( aCodError, {cWSPar2, 5, 'Não inserido(ERPID vazio)'										, .f. } )
aAdd( aCodError, {cWSPar2, 6, 'Não inserido(número vazio)'										, .f. } )
aAdd( aCodError, {cWSPar2, 7, 'Não inserido(nome vazio)'										, .f. } )
aAdd( aCodError, {cWSPar2, 8, 'Não inserido(endereço vazio)'									, .f. } )
aAdd( aCodError, {cWSPar2, 9, 'Não inserido(cep vazio)'											, .f. } )
aAdd( aCodError, {cWSPar2, 10, 'Não inserido(cidade/uf vazio)'									, .f. } )
aAdd( aCodError, {cWSPar2, 42, ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

//Cliente
aAdd( aCodError, {cWSPar3, 1 ,'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar3, 2 ,'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar3, 3 ,'Excluído'														, .t. } )
aAdd( aCodError, {cWSPar3, 4 ,'Não inserido(depósito informado não possui configuração)'		, .f. } )
aAdd( aCodError, {cWSPar3, 5 ,'Não inserido(ERPID vazio)'										, .f. } )
aAdd( aCodError, {cWSPar3, 7 ,'Não inserido(nome vazio)'										, .f. } )
aAdd( aCodError, {cWSPar3, 8 ,'Não inserido(endereço vazio)'									, .f. } )
aAdd( aCodError, {cWSPar3, 9 ,'Não inserido(cep vazio)'											, .f. } )
aAdd( aCodError, {cWSPar3, 10,'Não inserido(cidade/uf vazio)'									, .f. } )
aAdd( aCodError, {cWSPar3, 42,' Erro não cadastrado(informações no log do servidor).'			, .f. } )

//Pessoas
aAdd( aCodError, {cWSPar4, 1, 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar4, 2, 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar4, 3, 'Excluído'														, .t. } )
aAdd( aCodError, {cWSPar4, 4, 'Não inserido(depósito informado não possui configuração)'		, .f. } )
aAdd( aCodError, {cWSPar4, 5, 'Não inserido(ERPID vazio)'										, .f. } )
aAdd( aCodError, {cWSPar4, 6, 'Não inserido(número vazio)'										, .f. } )
aAdd( aCodError, {cWSPar4, 7, 'Não inserido(nome vazio)'										, .f. } )
aAdd( aCodError, {cWSPar4, 8, 'Não inserido(endereço vazio)'									, .f. } )
aAdd( aCodError, {cWSPar4, 9, 'Não inserido(cep vazio)'											, .f. } )
aAdd( aCodError, {cWSPar4, 10, 'Não inserido(cidade/uf vazio)'									, .f. } )
aAdd( aCodError, {cWSPar4, 42, ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

//Pedidos
aAdd( aCodError, {cWSPar5, 1 , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar5, 2 , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar5, 3 , 'Excluído'														, .t. } )
aAdd( aCodError, {cWSPar5, 4 , 'Não alterado (processo já iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar5, 5 , 'Não alterado (conferência de separação já iniciada)'			, .f. } )
aAdd( aCodError, {cWSPar5, 6 , 'Não inserido (processo não cadastrado)'							, .f. } )
aAdd( aCodError, {cWSPar5, 7 , 'Não inserido (cliente não cadastrado)'							, .f. } )
aAdd( aCodError, {cWSPar5, 8 , 'Não inserido (rota não cadastrada)'								, .f. } )
aAdd( aCodError, {cWSPar5, 9 , 'Não inserido (recebimento com documento vazio)'					, .f. } )
aAdd( aCodError, {cWSPar5, 10 , 'Não inserido (pedido com documento vazio)'						, .f. } )
aAdd( aCodError, {cWSPar5, 11 , 'Não inserido (registro incompleto)'							, .f. } )
aAdd( aCodError, {cWSPar5, 12 , 'Não inserido (produto não consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar5, 13 , 'Inserido (pedido complementar)'								, .f. } )
aAdd( aCodError, {cWSPar5, 14 , 'Aguardando (conclusão da separação para integrar)'				, .f. } )
aAdd( aCodError, {cWSPar5, 15 , 'Executando separação'											, .f. } )
aAdd( aCodError, {cWSPar5, 16 , 'Concluída separação'											, .f. } )
aAdd( aCodError, {cWSPar5, 17 , 'Executando conferência de separação'							, .f. } )
aAdd( aCodError, {cWSPar5, 18 , 'Concluída conferência de separação'							, .f. } )
aAdd( aCodError, {cWSPar5, 19 , 'Executando consolidação'										, .f. } )
aAdd( aCodError, {cWSPar5, 20 , 'Concluída consolidação'										, .f. } )
aAdd( aCodError, {cWSPar5, 21 , 'Executando expedição'											, .f. } )
aAdd( aCodError, {cWSPar5, 22 , 'Concluída expedição'											, .f. } )
aAdd( aCodError, {cWSPar5, 42 , ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

//Recebimentos
aAdd( aCodError, {cWSPar6, 1 , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar6, 2 , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar6, 3 , 'Excluído'														, .t. } )
aAdd( aCodError, {cWSPar6, 4 , 'Não alterado (processo já iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar6, 5 , 'Não alterado (conferência de separação já iniciada)'			, .f. } )
aAdd( aCodError, {cWSPar6, 6 , 'Não inserido (Não há configuração de deposito para Empresa)'	, .f. } )
aAdd( aCodError, {cWSPar6, 7 , 'Não inserido (deposito informado não possui configuração)'		, .f. } )
aAdd( aCodError, {cWSPar6, 8 , 'Não Excluido (processo ja iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar6, 9 , 'Não inserido (documento vazio)'									, .f. } )
aAdd( aCodError, {cWSPar6, 10 , 'Não inserido (ERPID vazio)'									, .f. } )
aAdd( aCodError, {cWSPar6, 11 , 'Não inserido (fornecedor nao cadastrado)'						, .f. } )
aAdd( aCodError, {cWSPar6, 12 , 'Não inserido (fornecedor vazio)'								, .f. } )
aAdd( aCodError, {cWSPar6, 13 , 'Nao inserido (produto não consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar6, 42 , ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

//Manutenção de Lotes
aAdd( aCodError, {cWSPar7, 1 , 'Processado'														, .t. } )
aAdd( aCodError, {cWSPar7, 2 , 'Processado com pendências'										, .f. } )
aAdd( aCodError, {cWSPar7, 3 , 'Não processado(não há configuração de depósito para a empresa)' , .f. } )
aAdd( aCodError, {cWSPar7, 4 , 'Não processado(depósito informado não possui configuração)'		, .f. } )
aAdd( aCodError, {cWSPar7, 5 , 'Não processado(código reduzido vazio)'							, .f. } )
aAdd( aCodError, {cWSPar7, 6 , 'Não processado(produto não identificado no WMS)'				, .f. } )
aAdd( aCodError, {cWSPar7, 7 , 'Não processado(lote não encontrado)' 							, .f. } )
aAdd( aCodError, {cWSPar7, 8 , 'Não processado(lote não encontrado no layout especificado)' 	, .f. } )
aAdd( aCodError, {cWSPar7, 9 , 'Não processado(campo operação vazio)'							, .f. } )
aAdd( aCodError, {cWSPar7, 10 , 'Não processado(operação não identificada)'						, .f. } )
aAdd( aCodError, {cWSPar7, 11 , 'Não processado(lote não informado)'							, .f. } )
aAdd( aCodError, {cWSPar7, 42 , 'Erro não cadastrado(informações no log do servidor)'			, .f. } )

//Movimentacao Interna
aAdd( aCodError, {cWSPar8, 1  , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar8, 2  , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar8, 3  , 'Excluído'														, .t. } )
aAdd( aCodError, {cWSPar8, 4  , 'Não alterado (processo já iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar8, 6  , 'Não inserido (processo não cadastrado)'						, .f. } )
aAdd( aCodError, {cWSPar8, 10 , 'Não inserido (pedido com documento vazio)'						, .f. } )
aAdd( aCodError, {cWSPar8, 11 , 'Não inserido (registro incompleto)'							, .f. } )
aAdd( aCodError, {cWSPar8, 12 , 'Não inserido (produto não consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar8, 14 , 'Aguardando (conclusão da separação para integrar)'				, .f. } )
aAdd( aCodError, {cWSPar8, 15 , 'Executando separação'											, .f. } )
aAdd( aCodError, {cWSPar8, 16 , 'Concluída separação'											, .f. } )
aAdd( aCodError, {cWSPar8, 42 , 'Erro não cadastrado(informações no log do servidor).'			, .f. } )

//Transferencias
aAdd( aCodError, {cWSPar9, 1  , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar9, 2  , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar9, 3  , 'Excluído'														, .t. } )
aAdd( aCodError, {cWSPar9, 4  , 'Não alterado (processo já iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar9, 6  , 'Não inserido (processo não cadastrado)'						, .f. } )
aAdd( aCodError, {cWSPar9, 10 , 'Não inserido (pedido com documento vazio)'						, .f. } )
aAdd( aCodError, {cWSPar9, 11 , 'Não inserido (registro incompleto)'							, .f. } )
aAdd( aCodError, {cWSPar9, 12 , 'Não inserido (produto não consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar9, 14 , 'Aguardando (conclusão da separação para integrar)'				, .f. } ) 
aAdd( aCodError, {cWSPar9, 15 , 'Executando separação'											, .f. } )
aAdd( aCodError, {cWSPar9, 16 , 'Concluída separação'											, .f. } )
aAdd( aCodError, {cWSPar9, 42 , 'Erro não cadastrado(informações no log do servidor).'			, .f. } )

//Aceite do Produto no WMS
aAdd( aCodError, {cWSParA, 1  , 'Efetivado'														, .t. } )
aAdd( aCodError, {cWSParA, 2  , 'Não Alterado(erpId não consta no WMS)'							, .f. } )
aAdd( aCodError, {cWSParA, 3  , 'Operação inválida (operação não conforme documentação)'		, .f. } )
aAdd( aCodError, {cWSParA, 42 , 'Erro não cadastrado(informações no log do servidor).'			, .f. } )


nPos := aScan( aCodError, { |x| x[1]==AllTrim(cSrv) .and. x[2]==nCod } )
If nPos >0
	aRet[1]:= aCodError[nPos,04]
	aRet[2]:= cvaltochar(aCodError[nPos,02]) +"-"+ aCodError[nPos,03]
Else
	aRet[1]:= .F.
	aRet[2]:= cvaltochar(nCod) +"- Mensagem de Erro não encontrada."
Endif

Return aRet
