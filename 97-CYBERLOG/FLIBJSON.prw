#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de Funções para Conexão do WS CyberLog
-------------------------------------------------------------------------------
*/ 


User Function fIDWmsErp
Local cNrTrans:= soma1(GetMV("FZ_WSTRANS"))

PutMV("FZ_WSTRANS", cNrTrans) 

Return cNrTrans



User Function fLgInJson()
Local cIpSrv	:= Iif((Upper(AllTrim(GetPvProfString(UPPER((Alltrim(GetEnvServer()))), "dbALIAS", "", GetsRVIniName()))) == "CZ2O05_152804_PR_PD"),GetMV("ST_IPWMS"),"http://189.45.131.206:9393") //Se o banco de dados for de produção, pega os dados do parâmetro
Local cNameSrv	:= "/cyberweb/api/autenticador/login"
Local cChave	:= "jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI" //GetMV("FZ_WSCHWMS")
Local cUserWS	:= "PROTHEUS"
Local cPwdWS	:= "365D16DBD2E29166ACBDD9DAD8D31FAF"

Local cBody		:= ''
Local cMsg		:= ''
Local cRet		:= ''
Local cToken	:= '' 
Local aHeader	:= {}
Local aRet		:= array(3)
Local lRet		:= .T.
Local oJson		:= JsonObject():New()
Local oRest
Local oObj

Local cError	:= ''
Local cJson		:= ''
Local nStatus	:= 0

//aAdd(aHeader,'Accept-Encoding: UTF-8')
AAdd(aHeader,'Accept: application/json')
aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')
aAdd(aHeader,'chave: '+ 'jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI' )
//aAdd(aHeader,'chave: '+ cChave )

cBody:= 'conta=' + Alltrim(cUserWS) + '&'
cBody+= 'senha=' + Alltrim(cPwdWS) + '&'
cBody+= 'modulo=SYNC&'
cBody+= 'numeroDeposito=1&'
cBody+= 'address=192.168.7.210&'  

//Monta a conexão com o servidor REST
oRest := FWRest():New(cIpSrv) 
oRest:setPath(cNameSrv)
	
//Definindo o parâmetro a ser usado no POST
cBody := FWNoAccent(cBody)

Conout("")
Conout(cBody)

oRest:SetPostParams(cBody)
oRest:SetChkStatus(.F.)
	
//Publica a alteração, e caso não dê certo, mostra erro
If ! oRest:Post(aHeader)
	cMsg:= 'Atenção !!! Houve erro na atualização no servidor!' + CRLF + ;
		'Contate o Administrador!' + CRLF + ;
		"Erro: " + oRest:GetLastError() + CRLF + "Result: " + If(Valtype(oRest:GetResult())=="U", "",oRest:GetResult())
		lRet:= .F.
Else

	FWJsonDeserialize(oRest:GetResult(),@oObj)
	cError := ""
	nStatus := HTTPGetStatus(@cError)

	if nStatus >= 200 .And. nStatus <= 299
		if Empty(oRest:getResult())
			lRet:= .F.
			cMsg:= "GetStatus: " + str(nStatus)
		else
			cJson:= oJson:fromJson(oRest:GetResult())
			If !Empty(oJson["token"])
				cToken:=Alltrim(oJson["token"]) 			
				cMsg:= "Autenticação OK. Token "+ cToken
			Else
				lRet:= .F.
				cMsg:= "Token em Branco"
			Endif
		endif
	else
		lRet:= .F.
		cMsg:= Alltrim(cError)
	endif

EndIf

//Aviso( "Mensagem WS", cMsg, {'OK'}, 03)
cRet:= cMsg

FreeObj(oObj)
FreeObj(oRest)
FreeObj(oJSON)

aRet[1]:= lRet
aRet[2]:= cMsg
aRet[3]:= cToken

Return aRet

User Function fLgOuJson(cToken)
Local cIpSrv	:= Iif((Upper(AllTrim(GetPvProfString(UPPER((Alltrim(GetEnvServer()))), "dbALIAS", "", GetsRVIniName()))) == "CZ2O05_152804_PR_PD"),GetMV("ST_IPWMS"),"http://189.45.131.206:9393") //Se o banco de dados for de produção, pega os dados do parâmetro
Local cNameSrv	:= "/cyberweb/api/autenticador/logout"
Local cChave	:= "jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI" //GetMV("FZ_WSCHWMS")
Local cBody		:= ''
Local cMsg		:= ''
Local cRet		:= ''
Local aHeader	:= {}
Local lRet		:= .T.
Local oJson		:= JsonObject():New()
Local oRest
Local oObj

Local cError	:= ''
Local cJson		:= ''
Local nStatus	:= 0

AAdd(aHeader,'Accept: application/json')
aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')
//jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI
aAdd(aHeader,'Chave: '+ 'jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI' )
//aAdd(aHeader,'Chave: '+ cChave )
aAdd(aHeader,"token: "+ cToken)

cBody:= ''

//Monta a conexão com o servidor REST
oRest := FWRest():New(cIpSrv) 
oRest:setPath(cNameSrv)
	
//Definindo o parâmetro a ser usado no POST
cBody := FWNoAccent(cBody)
oRest:SetPostParams(cBody)
oRest:SetChkStatus(.F.)
	
//Publica a alteração, e caso não dê certo, mostra erro
If ! oRest:Post(aHeader)
	cMsg:= 'Atenção !!! Houve erro na atualização no servidor!' + CRLF + ;
		'Contate o Administrador!' + CRLF + ;
		"Erro: " + oRest:GetLastError() + CRLF + "Result: " + oRest:GetResult()
	lRet:= .F.
Else

	FWJsonDeserialize(oRest:GetResult(),@oObj)
	cError := ""
	nStatus := HTTPGetStatus(@cError)

	if nStatus >= 200 .And. nStatus <= 299
		if Empty(oRest:getResult())
			lret:= .F.
			cMsg:= "GetStatus: " + str(nStatus)
		else
			cJson:= oJson:fromJson(oRest:GetResult())
			If !Empty(oJson["CyberWeb"])
				cMsg:=Alltrim(oJson["CyberWeb"]) 			
			Else
				lRet:= .F.
				cMsg:= ""
			Endif
		endif
	else
		lRet:= .F.
		cMsg:= cError
	endif
	
EndIf

cRet:= cMsg

FreeObj(oObj)
FreeObj(oRest)
FreeObj(oJSON)

Return cRet

//Integracao com o WMS
User Function fConJson(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)

	Local aZA2		:= GetArea()
	Local lRet		:= .T.
	Local cEndWS	:= Iif((Upper(AllTrim(GetPvProfString(UPPER((Alltrim(GetEnvServer()))), "dbALIAS", "", GetsRVIniName()))) == "CZ2O05_152804_PR_PD"),GetMV("ST_IPWMS"),"http://189.45.131.206:9393") //Se o banco de dados for de produção, pega os dados do parâmetro
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
	Local cMsgFw	:= ""

	Local cWSPar1:= Alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
	Local cWSPar2:= Alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
	Local cWSPar3:= Alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		
	Local cWSPar4:= Alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		
	Local cWSPar5:= Alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
	Local cWSPar6:= Alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	
	Local cWSPar7:= Alltrim(GetMv("FZ_WSWMS7"))	//"[FZ_WSWMS7] - Código do Layout de Integração do WS CyberLog WMS - [Manutencao de Lotes]"	
	Local cWSPar8:= Alltrim(GetMv("FZ_WSWMS8"))	//"[FZ_WSWMS8] - Código do Layout de Integração do WS CyberLog WMS - [Movimentacao de Interna]"	
	Local cWSPar9:= Alltrim(GetMv("FZ_WSWMS9"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Transferencias]"	
	Local cWSParA:= Alltrim(GetMv("FZ_WSWMSA"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Aceite]"	
	Local cWSParB:= Alltrim(GetMv("FZ_WSWMSB"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	
	Local cWSParC:= Alltrim(GetMv("FZ_WSWMSC"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	
	Local cWSParE:= Alltrim(GetMv("FZ_WSWMSE")) //Ordem de Produção 
	Local cWSParF:= Alltrim(GetMv("FZ_WSWMSF")) //Desmontagem - RE7 
	Local cWSParG:= Alltrim(GetMv("FZ_WSWMSG")) //Desmontagem - DE7 

	cLayOut	:= Alltrim(cLayOut)
	aLogIn	:= U_fLgInJson() //Faz o Login no WMS

	If cFilAnt <> "020201"
		
		Return {.F.,"403","Filial "+cFilAnt+" não autorizada para integração no Cyberlog"}

	End

	If aLogIn[1] .and. !Empty(aLogIn[3]) 

		cToken:= aLogIn[3]
		AAdd(aHeader,'Accept: application/json')
		aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')
		aAdd(aHeader,"chave: "+ ESCAPE('jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI'))
		//aAdd(aHeader,"chave: "+ cChave)
		aAdd(aHeader,"token: "+ cToken)
		
		If cLayOut == '018'
				cJson:= "{Header"+ CRLF
				cJson+= 'Content-Type: application/x-www-form-urlencoded' + CRLF
				cJson+= "chave: "+ ESCAPE('jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI') + CRLF
				//cJson+= "chave: "+ cChave + CRLF
				cJson+= "token: "+ cToken + "}" + CRLF + CRLF
			
			Else	
				cJson:= "{Header"+ CRLF
				cJson+= "chave: "+ ESCAPE('jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI') + CRLF
				//cJson+= "chave: "+ cChave + CRLF
				cJson+= "token: "+ cToken + "}" + CRLF + CRLF

		EndIf

		DbSelectArea("ZA2")
		ZA2->(DbSetOrder(1)) //Filial+Codigo Layout+Nome da TAG
		If ZA2->(DbSeek(FWxFilial("ZA2")+cLayOut,.T.))

			//cEndWS	:= Alltrim(ZA2->ZA2_ENDWS)+":" + Alltrim(ZA2->ZA2_PORWS)
			cMetodo	:= Alltrim(ZA2->ZA2_METWS)

			//Monta o corpo da requisicao conforme dicionario ZA2/ZA3
			cBody	:= U_fGrJson(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq,ZA2->ZA2_CHVPAR)

			cJson	+= cBody

			//Monta a conexão com o servidor REST
			oRest := FWRest():New(cEndWS) 
			oRest:setPath(cMetodo) 
			
			//Definindo o parâmetro a ser usado no POST
			cBody := StrTran(FWNoAccent(cBody),"%","")

			oRest:SetPostParams(cBody)
			oRest:SetChkStatus(.F.)
			
			//Publica a alteração, e caso não dê certo, mostra erro
			If !oRest:Post(aHeader)
				lret	:= .F.
				cCodRet	:= "999"
				cMsg	:= 'Atenção !!! Houve erro na atualização no servidor!' + CRLF + 'Contate o Administrador!' + CRLF 
				//"Erro: " + oRest:GetLastError() + CRLF + "Result: " + oRest:GetResult()
			
			Else
				FWJsonDeserialize(oRest:GetResult(),@oObj)
				
				cError := ""
				nStatus := HTTPGetStatus(@cError)

				If nStatus >= 200 .And. nStatus <= 299
					
					If Empty(oRest:GetResult())
						lret	:= .F.
						cCodRet	:= "ERRO: " + cValToChar(nStatus)
						cMsg	:= "GetStatus: " + str(nStatus)

					Else
						oJson		:= JsonObject():New()
						cRetJson	:= oJson:FromJson(oRest:GetResult())
						
						If ValType(cRetJson) != "U"
							lRet:= .F.
							cCodRet:= "999"
							cMsg:= 'Falha ao popular JsonObject. Erro: ' + cRetJson

						Else
							If !Empty(oJson["CyberWeb"])
									cCodRet:= Alltrim(oJson["CyberWeb"])
									If substr(cCodRet,1,1)=="!"
										cCodRet:= substr(cCodRet,2,len(cCodRet))
									Endif
									
									cMsg:= "Serviço: " + cLayOut + CRLF
									cMsg+= "Método: "+ cMetodo + CRLF

									aOk := fRslCnx(cLayOut, val(cCodRet))
									cMsg+= "Codigo Retorno: " +  aOK[2]

									If !(cLayOut $ "022|023" .And. cCodRet $ "1 - Inserido | 2 - Alterado")
										If !aOK[1]
											lRet:= .f.
										Endif
									End
								
								Else
									lRet:= .F.
									cCodRet:= "999"
									cMsg:= "ERRO: Chave Json [CYBERWEB]"
							Endif
						Endif
					endif
				
				Else
					lRet:= .F.
					cCodRet:= "999"
					cMsg:= cError + oRest:GetResult()
				
				Endif

			Endif

		Endif

		//Faz o LogOut no WS do WMS
		U_fLgOuJson(cToken)

	Else
		lret	:= .F.
		cCodRet	:= "999"
		cMsg	:= "Não foi possivel fazer o Login!!!"+ CRLF + aLogIn[2]
	Endif

	cMsg += CRLF + "IP WMS: "+ cEndWS

	cJson	+= CRLF+CRLF+"{ Resultado"+ CRLF
	cJson	+= "Codigo Retorno:" + cCodRet + CRLF
	cJson	+= "Mensagem: "+ cMsg + "}"

	//Mostra mensagem de retorno da integração 
	If (FUNNAME() $ "MATA020|MATA030" .And. !IsBlind())

		cMsgFw	+= "Codigo Retorno:" + cCodRet + CRLF
		cMsgFw	+= "Mensagem: "+ cMsg + "}"

		If lRet
			FWAlertSuccess(cMsgFw, "Integração WMS - fConJson")
		Else
			FWAlertError(cMsgFw, "Integração WMS - fConJson")
		End

	End

	aRet[1]	:= lRet
	aRet[2]	:= cCodRet
	aRet[3]	:= cMsg
		
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
		
		ElseIf cLayOut == cWSParC
			cTipoMov:= "C"
			cOrigMov:= "[Producao]"	

		ElseIf cLayOut == cWSParE
			cTipoMov:= "E"
			cOrigMov:= "[Orderm de Produção]"	

		ElseIf cLayOut == cWSParF
			cTipoMov:= "E"
			cOrigMov:= "[Desmontagem - RE7]"

		ElseIf cLayOut == cWSParG
			cTipoMov:= "E"
			cOrigMov:= "[Desmontagem - DE7]"	
	Endif

	If !lRet
		DbSelectArea("ZA1")
		RecLock("ZA1",.T.)
		ZA1->ZA1_FILIAL	:= FWxFilial("ZA1")
		ZA1->ZA1_STATUS	:= iIf(lRet,"1","0")
		ZA1->ZA1_NRTRAN	:= U_fIDWmsErp()
		ZA1->ZA1_TIPOTR	:= "E"
		ZA1->ZA1_ORIGEM	:= cOrigMov
		ZA1->ZA1_DATATR	:= date()
		ZA1->ZA1_HORATR	:= time()
		ZA1->ZA1_USERTR	:= upper(UsrRetName(__cUserId))
		ZA1->ZA1_JSON  	:= cJson
		ZA1->ZA1_TPMOV 	:= cTipoMov
		ZA1->(MsUnlock())

	EndIf

	FreeObj(oObj)
	FreeObj(oRest)
	FreeObj(oJSON)

	RestArea(aZA2)
Return aRet


//Corpo da requisicao rest
User Function fGrJson(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq,cChvParam)
Local aZA3	:= GetArea()
Local nCont	:= 1
Local cValor:= ''
Local cCont	:= ''
Local cRet	:= ''

If !Empty(cChvParam)
	cRet := Alltrim(cChvParam)+'={'
else
	cRet := '{'
Endif

DbSelectArea("ZA3")
ZA3->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
If ZA3->(DbSeek(FWxFilial("ZA3") + cLayOut ,.T.))

	While !ZA3->(Eof()) .and. ZA3->ZA3_COD == cLayOut

		
		If ZA3->ZA3_TIPTAG == '1'

			If Empty(ZA3->ZA3_CONTEU)
				If ZA3->ZA3_TPDADO == '2'
						cCont:= cValToChar(0)
					
					Else
						cCont:= 'null'
				Endif

			Else
				If "->"  $ Alltrim(ZA3->ZA3_CONTEU) .or. "U_"  $ upper(Alltrim(ZA3->ZA3_CONTEU)) .or. ;
					( ("("  $ Alltrim(ZA3->ZA3_CONTEU)) .and. (")"  $ Alltrim(ZA3->ZA3_CONTEU)) )

					cValor:= &(ZA3->ZA3_CONTEU)
				Else
					cValor:= ZA3->ZA3_CONTEU
				Endif

				If ZA3->ZA3_TPDADO == '1'
						cCont:= '"' + Alltrim( substr(cValor,1,ZA3->ZA3_TAMANH) ) + '"'

					ElseIf ZA3->ZA3_TPDADO == '2' .and. ZA3->ZA3_DECIMA = 0
						cCont:= Alltrim(cValToChar(cValor))

					ElseIf ZA3->ZA3_TPDADO == '2' .and. ZA3->ZA3_DECIMA != 0
						//cCont:= padl(strtran(strtran(cValor,".",""),",",""),nDec) 
						cCont:= Alltrim(cValToChar(cValor))

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

			cRet	+= '"' + Alltrim(ZA3->ZA3_TAG) + '":'+ cCont
			cValor	:= ''
			cCont	:= '' 
			
		Else
			If !Empty(ZA3->ZA3_CODARR)

					cRet+= '"' + Alltrim(ZA3->ZA3_TAG) + '": ['

					DbSelectArea(cTab)
					(cTab)->(DbSetOrder(nIndice))
					If (cTab)->(DbSeek(cChvPesq,.T.))
						While ! (cTab)->(Eof()) .and. (cTab)->&(cCpsPesq) == cChvPesq

							If nCont > 1
								cRet+= ','
							Endif

							cRet+=  U_fJsonArr(ZA3->ZA3_CODARR,,,,cChvPesq) 

							(cTab)->(DbSkip())
							nCont++
						End
					Endif
	
					cRet+= ']'

				Else
					cRet+= '"' + Alltrim(ZA3->ZA3_TAG) + '": null'

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
	
	Else
		cRet += '}'
Endif

RestArea(aZA3)
Return cRet


User Function fJsonArr(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
Local aZA4	:= GetArea()
Local cValor:= ''
Local cCont	:= ''
Local cRet	:= '{'
Local nContx:= 0

DbSelectArea("ZA4")
ZA4->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
If ZA4->(DbSeek(FWxFilial("ZA4")+cLayOut,.T.))

	If cLayOUt == '010'
		DbSelectArea('SD1')
		DbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                                                                                                                              
		If DbSeek(Substr(cChvPesq,1,26))  
			While !SD1->(EOF()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == Substr(cChvPesq,1,26)

				If nContx > 0
					cRet+= "},{"
				EndIf

				DbSelectArea("ZA4")
				ZA4->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
				If ZA4->(DbSeek(FWxFilial("ZA4")+cLayOut,.T.))
				While !ZA4->(Eof()) .and. ZA4->ZA4_COD==cLayOut
						

						If ZA4->ZA4_TIPTAG == '1'

							If empty(ZA4->ZA4_CONTEU)

								If ZA4->ZA4_TPDADO == '2'
									cCont:= cValToChar(0)
								Else
									cCont:= 'null'
								Endif

							Else

								If "->"  $ Alltrim(ZA4->ZA4_CONTEU) .or. "U_"  $ upper(Alltrim(ZA4->ZA4_CONTEU)) .or. ;
								( ("("  $ Alltrim(ZA4->ZA4_CONTEU)) .and. (")"  $ Alltrim(ZA4->ZA4_CONTEU)) )

									cValor:= &(ZA4->ZA4_CONTEU)
								Else
									cValor:= ZA4->ZA4_CONTEU
								Endif

								If ZA4->ZA4_TPDADO == '1'
									cCont:= '"' + Alltrim( substr(cValor,1,ZA4->ZA4_TAMANH) ) + '"'

								elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA = 0
									cCont:= cValToChar(cValor)

								elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA != 0
									cCont:= cValToChar(cValor)

								ElseIf ZA4->ZA4_TPDADO == '3'
									cCont:= '"'+ DTOS(cValor) + '"'

								ElseIf ZA3->ZA3_TPDADO == '4'
									If Substr(cValor,1,1) $ "V|T"
										cCont:= 'True'
									Else
										cCont:= 'False'
									Endif

								Endif

							Endif

							cRet+= '"' + Alltrim(ZA4->ZA4_TAG) + '":'+ cCont
							cValor	:= ''
							cCont	:= ''			

						else

							If !Empty(ZA4->ZA4_CODARR)
								cRet+= '"' + Alltrim(ZA4->ZA4_TAG) + '":[' + U_fJsonArr(ZA4->ZA4_CODARR) + ']'
							Else
								cRet+= '"' + Alltrim(ZA4->ZA4_TAG) + '": null'
							Endif

						Endif

					ZA4->(DbSkip())

					If ZA4->ZA4_COD == cLayOut
						cRet+= ","
					Endif

				End
				nContx++
			SD1->(DbSkip())
			EndIf
		EndDo
		EndIf
	else
		
		While !ZA4->(Eof()) .and. ZA4->ZA4_COD==cLayOut


				If ZA4->ZA4_TIPTAG == '1'

					If empty(ZA4->ZA4_CONTEU)

						If ZA4->ZA4_TPDADO == '2'
							cCont:= cValToChar(0)
						Else
							cCont:= 'null'
						Endif

					Else

						If "->"  $ Alltrim(ZA4->ZA4_CONTEU) .or. "U_"  $ upper(Alltrim(ZA4->ZA4_CONTEU)) .or. ;
						( ("("  $ Alltrim(ZA4->ZA4_CONTEU)) .and. (")"  $ Alltrim(ZA4->ZA4_CONTEU)) )

							cValor:= &(ZA4->ZA4_CONTEU)
						Else
							cValor:= ZA4->ZA4_CONTEU
						Endif

						If ZA4->ZA4_TPDADO == '1'
							cCont:= '"' + Alltrim( substr(cValor,1,ZA4->ZA4_TAMANH) ) + '"'

						elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA = 0
							cCont:= cValToChar(cValor)

						elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA != 0
							cCont:= cValToChar(cValor)

						ElseIf ZA4->ZA4_TPDADO == '3'
							cCont:= '"'+ DTOS(cValor) + '"'

						ElseIf ZA3->ZA3_TPDADO == '4'
							If Substr(cValor,1,1) $ "V|T"
								cCont:= 'True'
							Else
								cCont:= 'False'
							Endif

						Endif

					Endif

					cRet+= '"' + Alltrim(ZA4->ZA4_TAG) + '":'+ cCont
					cValor	:= ''
					cCont	:= ''			

				else

					If !Empty(ZA4->ZA4_CODARR)
						cRet+= '"' + Alltrim(ZA4->ZA4_TAG) + '":[' + U_fJsonArr(ZA4->ZA4_CODARR) + ']'
					Else
						cRet+= '"' + Alltrim(ZA4->ZA4_TAG) + '": null'
					Endif

				Endif

			ZA4->(DbSkip())

			If ZA4->ZA4_COD == cLayOut
				cRet+= ","
			Endif

		End
	EndIf
EndIf
	
cRet+= '}'

RestArea(aZA4)
Return cRet


Static Function fRslCnx(cSrv, nCod)
Local aCodError:= {}
Local aRet:= array(2)
Local nPos:= 0
Local cWSPar1:= Alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
Local cWSPar2:= Alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
Local cWSPar3:= Alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		
Local cWSPar4:= Alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		
Local cWSPar5:= Alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
Local cWSPar6:= Alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	
Local cWSPar7:= Alltrim(GetMv("FZ_WSWMS7"))	//"[FZ_WSWMS7] - Código do Layout de Integração do WS CyberLog WMS - [Manutencao de Lotes]"	
Local cWSPar8:= Alltrim(GetMv("FZ_WSWMS8"))	//"[FZ_WSWMS8] - Código do Layout de Integração do WS CyberLog WMS - [Movimentacao de Interna]"	
Local cWSPar9:= Alltrim(GetMv("FZ_WSWMS9"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Transferencias]"	
Local cWSParA:= Alltrim(GetMv("FZ_WSWMSA"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Aceite do Produto]"	
Local cWSParB:= Alltrim(GetMv("FZ_WSWMSB"))	//"[FZ_WSWMSB] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	
Local cWSParE:= Alltrim(GetMv("FZ_WSWMSE")) //Ordem de Produção

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

//Recebimentos
aAdd( aCodError, {cWSParE, 1 , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSParE, 2 , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSParE, 3 , 'Excluído'														, .t. } )
aAdd( aCodError, {cWSParE, 4 , 'Não alterado (processo já iniciado)'							, .f. } )
aAdd( aCodError, {cWSParE, 5 , 'Não alterado (conferência de separação já iniciada)'			, .f. } )
aAdd( aCodError, {cWSParE, 6 , 'Não inserido (Não há configuração de deposito para Empresa)'	, .f. } )
aAdd( aCodError, {cWSParE, 7 , 'Não inserido (deposito informado não possui configuração)'		, .f. } )
aAdd( aCodError, {cWSParE, 8 , 'Não Excluido (processo ja iniciado)'							, .f. } )
aAdd( aCodError, {cWSParE, 9 , 'Não inserido (documento vazio)'									, .f. } )
aAdd( aCodError, {cWSParE, 10 , 'Não inserido (ERPID vazio)'									, .f. } )
aAdd( aCodError, {cWSParE, 11 , 'Não inserido (fornecedor nao cadastrado)'						, .f. } )
aAdd( aCodError, {cWSParE, 12 , 'Não inserido (fornecedor vazio)'								, .f. } )
aAdd( aCodError, {cWSParE, 13 , 'Nao inserido (produto não consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSParE, 42 , ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

nPos := aScan( aCodError, { |x| x[1]==Alltrim(cSrv) .and. x[2]==nCod } )
If nPos >0
	aRet[1]:= aCodError[nPos,04]
	aRet[2]:= cValToChar(aCodError[nPos,02]) +"-"+ aCodError[nPos,03]
Else
	aRet[1]:= .F.
	aRet[2]:= cValToChar(nCod) +"- Mensagem de Erro não encontrada."
Endif

Return aRet


User Function DtJsonWMS(dData)
Local cRet:= ''
Local cHr:= ''
Local cMi:= ''
Local cPer:= ''
Local cData:= ''
Local cDia:= ''
Local cMes:= ''
Local cAno:= ''

If dData= Nil .or. Empty(dData)
	dData:= dDataBase
Endif

cHr:= substr(Time(),1,2)
cMi:= substr(Time(),3,6) 
If substr(cHr,1,2) >= '13' .and. substr(cHr,1,2) <= '23'
	cHr:= strzero(val(substr(cHr,1,2)) - 12, 02)
	cPer:= "PM"
Else
	cPer:= "AM"
Endif

cData:= dtos(dData)

cAno:= substr(cData,1,4)
cMes:= upper(substr(MesExtenso(substr(cData,5,2)),1,3))
cDia:= substr(cData,7,2)

/*If cMes == 'FEV'
	cMes:= 'FEB'
ElseIf cMes == 'ABR'
	cMes:= 'APR'
ElseIf cMes == 'MAI'
	cMes:= 'MAY'
ElseIf cMes == 'AGO'
	cMes:= 'AGU'
ElseIf cMes == 'SET'
	cMes:= 'SEP'
ElseIf cMes == 'OUT'
	cMes:= 'OCT'
ElseIf cMes == 'DEZ'
	cMes:= 'DEC' 
Endif*/

cRet:= cMes + ' ' + cDia + ', ' + cAno + ' ' + cHr+cMi + ' ' + cPer

Return cRet


User Function DtJsonERP(dData)
Local aRet:= array(2)
Local cHr:= ''
Local cMi:= ''
Local cSe:= ''

Local cDia:= ''
Local cMes:= ''
Local cAno:= ''


//012345678901234567890123
//Jan 06, 2021 03:57:06 PM

If dData= Nil .or. Empty(dData)

	aRet[1]:= dDataBase
	aRet[2]:= Time()

Else

	cMes:= upper(substr(dData,1,3))
	cDia:= substr(dData,5,2)
	cAno:= substr(dData,9,4)

	If cMes == 'JAN'
		cMes:= '01'
	ElseIf cMes == 'FEB'
		cMes:= '02'
	ElseIf cMes == 'MAR'
		cMes:= '03'
	ElseIf cMes == 'APR'
		cMes:= '04'
	ElseIf cMes == 'MAY'
		cMes:= '05'
	ElseIf cMes == 'JUN'
		cMes:= '06'
	ElseIf cMes == 'JUL'
		cMes:= '07'
	ElseIf cMes == 'AGU'
		cMes:= '08'
	ElseIf cMes == 'SEP'
		cMes:= '09'
	ElseIf cMes == 'OCT'
		cMes:= '10'
	ElseIf cMes == 'NOV'
		cMes:= '11'
	ElseIf cMes == 'DEC'
		cMes:= '12'
	Endif

	cHr:= substr(dData,14,2)
	cMi:= substr(dData,17,2) 
	cSe:= substr(dData,20,2) 

	If upper(substr(dData,22,2)) == "PM"
		cHr:= strzero(val(cHr) + 12, 02)
	endif

	aRet[1]:= ctod(cDia+'/'+cMes+'/'+cAno)
	aRet[2]:= cHr + ':' + cMi + ':' + cSe 

Endif

Return aRet

User Function fMovIERP(aCab,aItens,nOpcAuto)
Local aRet 		:= array(2)
Local cTxtLog	:= ''
Local lRet		:= .T.

Private lMsErroAuto := .F.

MakeDir("\WEB\WSCYBERLOG\")

If nOpcAuto == 3

	MSExecAuto({|x,y| mata241(x,y,z)},aCab,aItens)

	if lMsErroAuto
		MostraErro("\WEB\WSCYBERLOG\", "ERR_MOVINT.TXT")
		cTxtLog:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_MOVINT.TXT")

		lRet := .F.
	else
		cTxtLog:= ''
		lRet := .T.
	EndIf

EndIf

aRet[1]:= lRet
aRet[2]:= ''

Return aRet


User Function fTrfERP(aAuto,nOpcAuto)
Local aRet 		:= array(2)
Local lRet		:= .T.
Local cTxtLog	:= ''
Local nX

Private lMsErroAuto := .F.

MakeDir("\WEB\WSCYBERLOG\")
	
If nOpcAuto == 3

	MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

	if lMsErroAuto
		MostraErro("\WEB\WSCYBERLOG\", "ERR_TRANSF.TXT")
		cTxtLog:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_TRANSF.TXT")

		lRet := .F.
	else
		lRet := .T.
		cTxtLog:= ''
	EndIf

ElseIf nOpcAuto == 6 //Estornar

    //    conout("Exemplo de estorno de movimentação multipla baseado na inclusão do movimentação multipla anterior")

    lMsErroAuto := .F.

    //-- Preenchimento dos campos
    aAuto := {}
    aadd(aAuto,{"D3_DOC", cDocumen, Nil})
    aadd(aAuto,{"D3_COD", aLista[nX], Nil})
        
    DbSelectArea("SD3")
    DbSetOrder(2)
    DbSeek(xFilial("SD3")+cDocumen+aLista[nX])
    
    //MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)
        
    If lMsErroAuto
		MostraErro("\WEB\WSCYBERLOG\", "ERR_TRANSF.TXT")
		cTxtLog:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_TRANSF.TXT")
	   lRet:= .F.
	Else
		lRet:= .T.
		cTxtLog:= ''
    EndIf

EndIf

aRet[1]:= lRet
aRet[2]:= cTxtLog

Return aRet


//-----------------------------------------------------------------------------------------------------------------------
//Abre o Arquivo .LOG e retorna em uma variavel TXT    
//Programador: Carlos Cleuber Pereira 
User Function WSTXTLOG( cArqLog )

Local cTexto := ""
Local cBuffer := ""     

FT_FUse(cArqLog)
FT_FGOTOP()  
nLin:= 1

While ( !FT_FEof() )	

	cBuffer := FT_FREADLN()

	cTexto += cBuffer + " " + CRLF

	FT_FSKIP()
	nLin++

EndDo
FT_FUse()    

cTexto:= strtran( cTexto, "\r","")
cTexto:= strtran( cTexto, "\n","")

RETURN cTexto        
