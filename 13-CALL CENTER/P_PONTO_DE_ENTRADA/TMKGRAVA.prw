#include 'protheus.ch'
#include 'parmtype.ch'
#include "AP5MAIL.CH"
#include "TMKA272A.CH"
//#INCLUDE "TMKDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMKGRAVA
Ponto de entrada na gravação do atendimmento de telemarketing.
Utilizado para disparar e-mail de aviso
                

@author		Thiago Henrique dos santos
@since		31/08/2017     
@version 	P11  
/*/
//-------------------------------------------------------------------
user function TMKGRAVA(cPendente,cCodigo,aCampos,nOpc)
//Local lRet := .T.
Local cTipSta := ""
Local cDescCnt:= ""
Local cCidade := ""
Local cEst	  := ""
Local cTelRes := ""
Local cTelCom1:= ""
Local cTelCel := ""
Local cEnd	  := ""
Local cDDD	  := ""
Local cBairro := ""
Local aSx3SUC := Tk273Sx3("SUC")
Local cEncerra:= ""
Local cMotivo := ""
Local aParScript := {}
Local aUDStatus  := {}
Local nY		:= 0
local lNovo		:= .F.
Local nPosItem	 := aScan( aHeader, { |x| AllTrim(x[2]) == "UD_ITEM" } )
Local nPosStat	 := aScan( aHeader, { |x| AllTrim(x[2]) == "UD_STATUS" } )
Local cI		 := "00"

If M->UC_STATUS == "1"
	cTipSta:= "Planejada"
ElseIf M->UC_STATUS == "2"
	cTipSta:= "Pendente"
ElseIf M->UC_STATUS == "3"
	cTipSta:= "Encerrada"
	cEncerra := M->UC_CODENCE
	cMotivo := MSMM(M->UC_CODMOT,TamSx3("UC_OBSMOT")[1])
Endif

DbSelectArea("SUD")
DbSetOrder(1)

If M->UC_STATUS <> "3"

	For nY:=1 To Len(aCols)

		If ! aCols[nY][Len(aHeader)+1]
			cI := SomaIt(cI)
	
			
			If SUD->(DbSeek(xFilial("SUD") + M->UC_CODIGO + Iif(nPosItem>0,aCols[nY][nPosItem],cI)))
				lNovo := .F.
				AAdd(aUDStatus,{SUD->UD_STATUS,aCols[nY][nPosStat],lNovo})			
			Else		
				lNovo := .T.
				AAdd(aUDStatus,{aCols[nY][nPosStat],aCols[nY][nPosStat],lNovo})			
			Endif
		Endif

	Next nY

Endif

If !Empty(M->UC_CODCONT)
	DbSelectArea("SU5")
	SU5->(DbSetOrder(1))
	If SU5->(DbSeek(xFilial("SU5") + M->UC_CODCONT))
			
		cDescCnt:= SU5->U5_CONTAT
		cCidade	:= SU5->U5_MUN
		cEst	:= SU5->U5_EST
		cTelRes := SU5->U5_FCOM1
		cTelCom1:= SU5->U5_FONE
		cTelCel := SU5->U5_CELULAR
		cEnd	:= SU5->U5_END
		cDDD	:= SU5->U5_DDD
		cBairro := SU5->U5_BAIRRO
	Endif
endif


EnvTmk(cTimeIni	,cTipSta	,cCidade	,cEst		,;
				cTelRes 	,cTelCom1	,cEnd		,cDescCnt	,;
				nOpc		,aSx3SUC	,cDDD		,cEncerra	,;
				cMotivo		,cBairro	,aParScript	,cTelCel	,;
				aUDStatus)
	
return




//-------------------------------------------------------------------
/*/{Protheus.doc} EnvTmk
Prepara o email e assuntos a serem enviados
                

@author		Thiago Henrique dos santos
@since		31/08/2017     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function EnvTmk(cTimeIni	,cTipSta	,cCidade	,cEst		,;
							cTelRes 	,cTelCom1	,cEnd		,cDescCnt	,;
							nOpc		,aSx3SUC	,cDDD		,cEncerra	,;
							cMotivo		,cBairro	,aParScript	,cTelCel	,;
							aUDStatus)

Local aCabecalho:= {}                                         					// Array que carrega a descricao do atendimento
Local aItens	:= {}															// Array para compor os itens do atendimento
Local nLinhas	:= 0                                                            // Percorre as linhas do acols para montar a descricao
Local cMensagem := ""                                                           // Monta a descricao do atendimento
Local aSend		:= {}                                                           // Monta um array com os destinatarios de cada linha do acols
Local cEmail	:= ""															// email do remetente
Local cAssunto	:= ""                                                           // Assunto do email
Local nCont		:= 0															// Contador	

Local nPAssunto := aPosicoes[1][2]												// Assunto
Local nPDescAss := aPosicoes[2][2]												// Descricao do Assunto
Local nPProd 	:= aPosicoes[3][2]												// Produto
Local nPDescPro := aPosicoes[4][2]												// Descricao do produto
Local nPOcorren	:= aPosicoes[5][2]												// Ocorrencia	
Local nPDescOco	:= aPosicoes[6][2]                                              // Descricao da Ocorrencia
Local nPCodOpe 	:= aPosicoes[7][2]												// Codigo do Operador
Local nPDescOpe	:= aPosicoes[8][2]												// Descricao do Operador		
Local nPData	:= aPosicoes[9][2]												// Data			
Local nPAcao   	:= aPosicoes[10][2]												// Acao
Local nPDescAca	:= aPosicoes[11][2]												// Descricao da Acao
Local nPObs		:= aPosicoes[12][2]												// Observacao
Local nPStatus  := aPosicoes[13][2]												// Status
Local nPDtExec  := aPosicoes[14][2]												// Data de Execucao
Local nPObsExec := aPosicoes[15][2]												// Observacao da Execucao

Local cAccount	:= IIF( GetMV("MV_RELAUTH"),GetMV("MV_RELAUSR"),Posicione("SU7",1,xFilial("SU7") + M->UC_OPERADO,"U7_CONTA")) // Conta do remetente
Local cPassword	:= IIF( GetMV("MV_RELAUTH"),GetMV("MV_RELAPSW"),Posicione("SU7",1,xFilial("SU7") + M->UC_OPERADO,"U7_SENHA")	)// Senha do remetente
Local lUsaEmail := TkPosto(M->UC_OPERADO,"U0_CODIGO") <> "13"							// Validacao se o operador pode mandar email

Local aStatus 	:= IIF(nPStatus > 0,TkSX3Box("UD_STATUS"),{})					// Array com o conteudo do campo UD_STATUS
Local cStatus	:= ""      
Local lTK272Acc	:= ExistBlock("TK272ACC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³trata antes de atribuir³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len(aStatus) > 0
	cStatus := aStatus[1]
Endif

// Captur	a a senha do operador sem criptografia
If !Empty(cPassword) .And. !GetMV("MV_RELAUTH")
	cPassword := Embaralha(cPassword,1)
Endif
                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o operador pode mandar email para os clientes   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaEmail 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o ARRAY  com o cabecalho do atendimento de Telemarketing ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aCabecalho,M->UC_CODIGO )							// Atendimento			-01
	Aadd(aCabecalho,M->UC_CHAVE + "-" + M->UC_DESCCHA)		// Entidade             -02
	Aadd(aCabecalho,cDescCnt)     							// Contato              -03
	Aadd(aCabecalho,cCidade + "-" + cEst)					// Cidade - Estado 		-04
	Aadd(aCabecalho,cEnd)									// Endereco				-05
	Aadd(aCabecalho,"(" + AllTrim(Transform(cDDD,PesqPict("SU5","U5_DDD"))) + ") " + Transform(cTelRes ,PesqPict("SU5","U5_FONE")) + " / " +;
					"(" + AllTrim(Transform(cDDD,PesqPict("SU5","U5_DDD"))) + ") " + Transform(cTelCom1,PesqPict("SU5","U5_FCOM1"))+ " / " +;
					"(" + AllTrim(Transform(cDDD,PesqPict("SU5","U5_DDD"))) + ") " + Transform(cTelCel ,PesqPict("SU5","U5_CELULAR")))				// Telefone Resid/Comer e Celular -06
	Aadd(aCabecalho,M->UC_DATA)	          					// Data da ligacao      -07
	Aadd(aCabecalho,cTimeIni)								// Hora inicial         -08
	Aadd(aCabecalho,M->UC_OPERADO + "-" + M->UC_DESCOPE)	// Codigo - Operador    -09
	Aadd(aCabecalho,M->UC_DESCTIP)							// Tipo de comunicacao  -10
	Aadd(aCabecalho,cTipSta)		           				// Status               -11
	Aadd(aCabecalho,M->UC_MIDIA + "-" + M->UC_DESCMID) 	// Midia                -12
	Aadd(aCabecalho,M->UC_OBS)				 				// Observacao TMK       -13
	Aadd(aCabecalho,cBairro)								// Bairro				-14
	If M->UC_STATUS == "3"
		Aadd(aCabecalho,cEncerra + " - " + Posicione("SUN",1,xFilial("SUN") + cEncerra,"UN_DESC"))	// Motivo do encerramento 		-15
		Aadd(aCabecalho,cMotivo)								// Descricao do encerramento	-16
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o ARRAY  com os itens do atendimento do Telemarketing 	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLinhas := 1 TO len(aCols)

		If !(aCols[nLinhas][Len(aHeader)+1])	// Se a linha nao estiver apagada.
			If !Empty(aCols[nLinhas][nPCodOpe])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento do Box do campo UD_STATUS, pois o inicilizador padrao³
			//³nao esta sendo executado (TKCONFIG()).	    				   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               If Val(aCols[nLinhas][nPStatus])= 0 .OR. Val(aCols[nLinhas][nPStatus])>Len(aStatus)
                                    

			   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   		//³Trata antes de Atribuir³
			   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                  If Len(aStatus) > 0
                  	cStatus := aStatus[1]
                  Endif	
               Else   
                  cStatus := aStatus[Val(aCols[nLinhas][nPStatus])]
               Endif   
			   Aadd(aItens,{ aCols[nLinhas][nPAssunto]		,;				// 01- Assunto 
			   				 aCols[nLinhas][nPDescAss]		,;				// 02- Descricao do Assunto
							 aCols[nLinhas][nPProd]   		,;				// 03- Produto
							 aCols[nLinhas][nPDescPro]		,;				// 04- Descricao do Produto
							 aCols[nLinhas][nPOcorren]		,;				// 05- Ocorrencia
							 aCols[nLinhas][nPDescOco]		,;				// 06- Descricao da Ocorrencia
							 aCols[nLinhas][nPAcao]   		,;				// 07- Acao
							 aCols[nLinhas][nPDescAca]		,;				// 08- Descricao da Acao
							 aCols[nLinhas][nPCodOpe] 		,;				// 09- Codigo do Operador
							 aCols[nLinhas][nPDescOpe]		,;				// 10- Descricao do Operador	
							 DTOC(aCols[nLinhas][nPData])	,;				// 11- Data
							 aCols[nLinhas][nPObs]	   		,;  			// 12- Observacao
							 cStatus						,;				// 13- Status
							 DTOC(aCols[nLinhas][nPDtExec])	,;				// 14- Data de Execucao
							 aCols[nLinhas][nPObsExec]	})					// 15- Memo da Execucao	

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o ARRAY para o numero de usuarios que vao receber³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
				If Len(aUDStatus) <> 0 .AND. !aUDStatus[nLinhas][3]
					If aUDStatus[nLinhas][2] == "1" .OR.;
					  (aUDStatus[nLinhas][2] == "2" .AND. aUDStatus[nLinhas][1] <> aUDStatus[nLinhas][2])				
						cEmail 	 := UsrRetMail(aCols[nLinhas][nPCodOpe])+";" //+=					
					EndIf
				Else
                    cEmail 	 := UsrRetMail(aCols[nLinhas][nPCodOpe])+";" //+=
				EndIf

				cAssunto := "Atendimento" + " " + M->UC_CODIGO + " " +"realizado pelo CALL CENTER" //"Atendimento"###"realizado pelo CALL CENTER"

				If (At("@",cEmail) > 0)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³So serao somados os e-mails diferentes.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (Ascan(aSend,{|x| AllTrim(x[1]) == Alltrim(cEmail)}) == 0 )
						Aadd(aSend,{cEmail,cAssunto,"",""})
					Endif
				Endif
			
			Endif      
		Endif
		
	Next nLinhas
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega a conta e a senha do email do usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aSend) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para permitir a alteração da conta e senha do usuário. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	   	If lTK272Acc
			aRet := ExecBlock("TK272ACC",.F.,.F.,{M->UC_OPERADO})
			If ValType(aRet) == "A"
				cAccount  := aRet[1]
				cPassword := aRet[2]
			EndIf
		EndIf		

		If TkAccount(@cAccount,@cPassword)
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o corpo do E-mail                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Tk272Body(@cMensagem,aCabecalho,aItens,nOpc,aSx3SUC,aParScript)

			For nCont := 1 TO Len(aSend)
				aSend[nCont][3] := cMensagem
			Next nCont
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envio de E-mail³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCont:= 1 To Len(aSend)              
				//"Enviando E-Mail para as acoes..."
				MsgRun(  "Enviando E-Mail para as acoes...","",;
						{ ||lSend:= SendMail(	Alltrim( GetMV("MV_RELACNT",,"") )			,Alltrim( GetMV("MV_RELPSW",,"") )	,GetMV("MV_RELSERV")	,UsrRetMail(__cUserID),;
												aSend[nCont][1]	,aSend[nCont][2]	,aSend[nCont][3]		,aSend[nCont][4]) })
			Next nCont
		Endif
	Endif
Endif

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} Tk272Body
Prepara o corpo do E-mail
                

@author		Thiago Henrique dos santos
@since		31/08/2017     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function Tk272Body(	cMensagem	,aCabecalho	,aItens		,nOpc		,;
							aSx3SUC		,aParScript		)

Local nCont  		:= 0			// Contador
Local cAtend		:= ""			// Descricao do campo "UC_CODIGO"
Local cCliente		:= ""			// Descricao do campo "UC_CHAVE"
Local cContato		:= ""			// Descricao do campo "UC_CODCONT"
Local cData			:= ""			// Descricao do campo "UC_DATA"
Local cHoraIni		:= ""			// Descricao do campo "UC_HRPEND"
Local cOperador		:= ""			// Descricao do campo "UC_OPERADO"
Local cComunica 	:= ""			// Descricao do campo "UC_TIPO"
Local cSTatusSUC	:= ""			// Descricao do campo "UC_STATUS"
Local cMotEnc		:=  "Motivo do encerramento"
Local cDesEnc		:=  "Descrição do encerramento"
Local cMidia        := ""			// Descricao do campo "UC_MIDIA"
Local cObsSUC		:= ""			// Observacao do atendimento
Local cItem			:= ""			// Descricao do campo "UD_ITEM"
Local cAssunto		:= ""			// Descricao do campo "UD_ASSUNTO"
Local cProduto		:= ""			// Descricao do campo "UD_PRODUTO"
Local cOcorren		:= ""			// Descricao do campo "UD_OCORREN"
Local cAcao			:= ""			// Descricao do campo "UD_SOLUCAO"
Local cResp			:= ""			// Descricao do campo "UD_OPERADO"
Local cDataAcao	    := ""			// Descricao do campo "UD_DATA"
Local cObsSUD       := ""			// Descricao do campo "UD_OBS"
Local cStatusSUD    := ""			// Descricao do campo "UD_STATUS"
Local cDataExec	    := ""			// Descricao do campo "UD_DTEXEC"
Local cCompl	    := ""			// Descricao do campo "UD_OBSEXEC"
Local lTK272HTM		:= ExistBlock("TK272HTM") 
Local cTiposTels	:= ""
                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa no SX3 qual a descricao dos campos, caso o usuario tenha alterado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan(aSx3SUC,{|x| x[4] $ "UC_CODIGO"})
If (nPos > 0)
	cAtend	:= aSx3SUC[nPos][4]
Else
	cAtend	:= STR0030
Endif
	
nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_CHAVE"})
If (nPos > 0)
	cCliente := aSx3SUC[nPos][4]
Else	
	cCliente := STR0031
Endif	

nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_CODCONT"})
If (nPos > 0)
	cContato := aSx3SUC[nPos][4]
Else
	cContato :=STR0033
Endif

nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_DATA"})
If (nPos > 0)
	cData := aSx3SUC[nPos][4]
Else
	cData := STR0009
Endif

nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_HRPEND"})
If (nPos > 0)
	cHoraIni := aSx3SUC[nPos][4]
Else
	cHoraIni :=STR0034   
Endif

nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_OPERADO"})
If (nPos > 0)
	cOperador := aSx3SUC[nPos][4]
Else
	cOperador := STR0011   
Endif

	
nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_TIPO"})
If (nPos > 0)
	cComunica := aSx3SUC[nPos][4]
Else
	cComunica := STR0014  
Endif

nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_STATUS"})
If (nPos > 0)
	cSTatusSUC	:= aSx3SUC[nPos][4]
Else
	cSTatusSUC	:=STR0013
Endif

nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_MIDIA"})
If (nPos > 0)
	cMidia := aSx3SUC[nPos][4]
Else
	cMidia := STR0016         
Endif
	
nPos := Ascan(aSx3SUC,{|x| x[1] $ "UC_OBS"})
If (nPos > 0)
	cObsSUC	:= aSx3SUC[nPos][4]
Else
	cObsSUC	:= STR0018
Endif

DbSelectArea("SX3")
DbSetOrder(2)

If DbSeek("UD_ITEM")
	cItem		:= Alltrim(X3Titulo())       
Endif

If DbSeek("UD_ASSUNTO")
	cAssunto	:= Alltrim(X3Titulo())       
Endif

If DbSeek("UD_PRODUTO")
	cProduto	:= Alltrim(X3Titulo())       
Endif
	
If DbSeek("UD_OCORREN")
	cOcorren	:= Alltrim(X3Titulo())       
Endif

If DbSeek("UD_SOLUCAO")
	cAcao := Alltrim(X3Titulo())       
Endif

If DbSeek("UD_OPERADO")
	cResp		:= Alltrim(X3Titulo())       	
Endif
	
If DbSeek("UD_DATA")
	cDataAcao	:= Alltrim(X3Titulo())       
Endif
	
If DbSeek("UD_OBS")
	cObsSUD     := Alltrim(X3Titulo())       
Endif
	
If DbSeek("UD_STATUS")
	cStatusSUD  := Alltrim(X3Titulo())       
Endif
	
If DbSeek("UD_DTEXEC")
	cDataExec	:= Alltrim(X3Titulo())       
Endif
	
If DbSeek("UD_OBSEXEC")
	cCompl := Alltrim(X3Titulo())     
Endif

If DbSeek("U5_FONE")
	cTiposTels := "  (" + Alltrim(X3Titulo()) + "/" 
EndIf

If DbSeek("U5_FCOM1")
	cTiposTels += Alltrim(X3Titulo()) + "/" 
EndIf

If DbSeek("U5_CELULAR")
	cTiposTels += Alltrim(X3Titulo()) + ")"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara o cabecalho do atendimento - SUC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem += "<html>"  
cMensagem += "<body>"  

cMensagem += '<p align="center"><b><font color="#000080" face="Arial" size="4">'   // Alinhamento e tamanho do fonte titulo
If nOpc == 3 // Inclusao
	cMensagem += "Inclusão de Atendimento - Call Center - Telemarketing" // "Inclusão de Atendimento - Call Center - Telemarketing"
ElseIf nOpc == 4 // Alteracao
	cMensagem += "Alteração no Atendimento - Call Center - Telemarketing" // "Alteração no Atendimento - Call Center - Telemarketing"
Endif	
cMensagem += '</font></b></p>'

cMensagem += '<hr>'                	// Linha horizontal do corpo do email

cMensagem += '<p><font face="Arial"><b>'
cMensagem +=  "Dados do Atendimento" // Dados do Atendimento
cMensagem += '</b></font></p>'

cMensagem += '<table border="1" width="100%">'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">' 	//Cor azul
cMensagem += cAtend //Atendimento
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font face="Verdana" size="2">'
cMensagem += aCabecalho[1]
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
cMensagem += IIF(!lProspect,"Cliente","Prospect")//Cliente , Prospect 
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font face="Verdana" size="2">'
cMensagem += aCabecalho[2]
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
cMensagem += cContato //Contato
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[3]),aCabecalho[3],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'					
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
cMensagem += "Cidade" //Cidade
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[4]),aCabecalho[4],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
cMensagem += "Endereço" 
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[5]),aCabecalho[5],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
cMensagem += "Bairro" 
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[14]),aCabecalho[14],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#FF0000" face="Verdana">'
cMensagem += "Telefones" + cTiposTels	
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[6]),aCabecalho[6],'&nbsp;') //Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
cMensagem += cData //Data
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[7]),DTOC(aCabecalho[7]),'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
cMensagem += cHoraIni //Hora Inicial
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[8]),aCabecalho[8],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
cMensagem += cOperador //Operador
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[9]),aCabecalho[9],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
cMensagem += cComunica //Comunicacao
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[10]),aCabecalho[10],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
cMensagem += cStatusSUC //Status
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[11]),aCabecalho[11],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Status do chamado for "Encerrada", adiciona o   ³
//³Motivo do encerramento e a Descrição do encerramento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->UC_STATUS == "3"
	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cMotEnc //Motivo do encerramento
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[15]),aCabecalho[15],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'

	cMensagem += '<tr>'
	cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += cDesEnc //Descrição do encerramento
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="67%"><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[16]),aCabecalho[16],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
EndIf

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
cMensagem += cMidia //Midia
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[12]),aCabecalho[12],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

cMensagem += '<tr>'
cMensagem += '<td width="33%"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
cMensagem += cObsSUC //Observacao do atendimento
cMensagem += '</font>&nbsp;</font></b></td>'
cMensagem += '<td width="67%"><font face="Verdana" size="2">'
cMensagem += IIF(!Empty(aCabecalho[13]),aCabecalho[13],'&nbsp;')//Se estiver vazio cria o 'espaco' onde estaria o dado.
cMensagem += '</font></td>'
cMensagem += '</tr>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara o corpo dos itens do atendimento - SUD   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem +='<tr>'
cMensagem += '<td width="50%">&nbsp;</td>'
cMensagem += '<td width="50%">&nbsp;</td>'
cMensagem += '</tr>'

cMensagem += '</table>'
cMensagem += '<table border="1" width="100%">'
cMensagem += '<tr>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size=2>'
cMensagem += cItem//"Item"
cMensagem += '</font></b></td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cAssunto//"Assunto"
cMensagem += '</font></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cProduto //"Produto"
cMensagem += '</font></b></td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cOcorren //"Ocorrencia"
cMensagem += '</font></b></td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cAcao //"Acao"
cMensagem += '</font></b>&nbsp;&nbsp;&nbsp;</td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cResp //"Responsavel"
cMensagem += '&nbsp;</font></b></td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cDataAcao //"Data da Acao"
cMensagem += '&nbsp;&nbsp;</font></b></td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cObsSUD //"Observacao"
cMensagem += '&nbsp;&nbsp;</font></b></td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cStatusSUD
cMensagem += '&nbsp;&nbsp;</font></b></td>'

cMensagem += '<td><b><font color="#0000FF" face="Verdana" size="2">'
cMensagem += cDataExec
cMensagem += '&nbsp;&nbsp;</font></b></td>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara a impressao do conteudo dos itens - SUD  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCont := 1 To Len(aItens)
	cMensagem += '<tr>'
	
	cMensagem += '<th rowspan=2><font face="Verdana" size=2>'
	cMensagem += StrZero(nCont,3)
	cMensagem += '</font></th>'
	
	cMensagem += '<td><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][2]),AllTrim(aItens[nCont][2]),'&nbsp;') // Assunto - somente descricao
	cMensagem += '</font></td>'
	
	cMensagem += '<td><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][3]),AllTrim(aItens[nCont][3]) + " - " + AllTrim(aItens[nCont][4]),'&nbsp;') //Produto
	cMensagem += '</font></td>'
	
	cMensagem += '<td><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][6]),AllTrim(aItens[nCont][6]),'&nbsp;') // Ocorrencia - somente descricao
	cMensagem += '</font></td>'
	
	cMensagem += '<td><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][8]),AllTrim(aItens[nCont][8]),'&nbsp;') // Acao - Somente descricao
	cMensagem += '</font></td>'
	
	cMensagem += '<td><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][10]),AllTrim(aItens[nCont][10]),'&nbsp;') //Responsavel - somente descricao
	cMensagem += '</font></td>'
	
	cMensagem += '<td><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][11]),AllTrim(aItens[nCont][11]),'&nbsp;')  //Data da acao
	cMensagem +='</font></td>'
	
	cMensagem += '<td><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][12]),AllTrim(aItens[nCont][12]),'&nbsp;')  //Observacao
	cMensagem += '</font></td>'

	cMensagem += '<td><font color ="#FF0000" face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][13]),AllTrim(aItens[nCont][13]),'&nbsp;')  //Status
	cMensagem += '</font></td>'

	cMensagem += '<td><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aItens[nCont][14]),AllTrim(aItens[nCont][14]),'&nbsp;')  //Data
	cMensagem += '</font></td>'

	cMensagem += '</tr>'
	
	cMensagem += '<tr><th colspan=9><font face="Verdana" color="#0000FF" size=1>'
	cMensagem += IIF(!Empty(aItens[nCont][15]),cCompl + ": ","")
	cMensagem += '</font><font face="Verdana" size=1>'
	cMensagem += IIF(!Empty(aItens[nCont][15]),AllTrim(aItens[nCont][15]),'&nbsp;') //Memo
	cMensagem += '</font></th></tr>'
	
Next nCont

cMensagem += '</table>'
cMensagem += '<p>&nbsp;</p>'

If lTK272HTM
	cMensagem += ExecBlock("TK272HTM",.F.,.F.,{aCabecalho,aItens,nOpc,aSx3SUC,aParScript})
EndIf

cMensagem += '</body>'
cMensagem += '</html>'

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} Tk272Body
Prepara o corpo do E-mail
                

@author		Thiago Henrique dos santos
@since		31/08/2017     
@version 	P11  
/*/
//-------------------------------------------------------------------

Static Function SendMail(cAccount	,cPassword	,cServer	,cFrom,;
					cEmail		,cAssunto	,cMensagem	,cAttach)

Local cEmailTo := ""							// E-mail de destino
Local cEmailBcc:= ""							// E-mail de copia
Local lResult  := .F.							// Se a conexao com o SMPT esta ok
Local cError   := ""							// String de erro
Local lRelauth := GetMV("MV_RELAUTH")		// Parametro que indica se existe autenticacao no e-mail
Local lRet	   := .F.							// Se tem autorizacao para o envio de e-mail
Local cConta   := ALLTRIM(cAccount)				// Conta de acesso 
Local cSenha   := ALLTRIM(cPassword)	        // Senha de acesso

Local oServer  									//Objeto para o TmailManager
Local oMessage									//Objeto para o TmailMessenger
Local nErr      := 0							//Variavel para controle de erro
Local nSMTPTime := GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO
Local lSSL 		:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS 		:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
Local nSMTPPort := GetNewPar("MV_PORSMTP",25)	// PORTA SMTP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cEmailTo := cEmail
If At(";",cEmail) > 0 // existe um segundo e-mail.
	cEmailBcc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Endif	

If lSSL .Or. lTLS

	
	// Objeto de Email
	oServer := TMailManager():New()
	
	// Usa SSL, TLS ou nenhum na inicializacao
	
	oServer:SetUseTLS(lTLS)
	
	aSmtSrvPt  := Separa(cServer,':',.F.)

	If Len(aSmtSrvPt) == 2			
		cServer  := Alltrim(aSmtSrvPt[1])
		nSMTPPort := Val(aSmtSrvPt[2])
	EndIf	
	
	// Inicializacao do objeto de Email
	nErr := oServer:init("",cServer,cConta,cSenha,,nSMTPPort)
	If nErr <> 0	
		CoNout(STR0039 + oServer:getErrorString(nErr)) // "[Init SMTP] Falha ao inicializar SMTP: " 	
		Return(.F.)
	Else
		CoNout(STR0040 + oServer:getErrorString(nErr)) //"[Init SMTP] Sucesso ao inicializar SMTP "
	Endif
	
	// Define o Timeout SMTP
	nErr := oServer:SetSMTPTimeout(nSMTPTime)
	If nErr <> 0
		CoNout(STR0041 + oServer:getErrorString(nErr)) //"[SetSMTPTimeout] Falha ao definir timeout: "
		Return(.F.)
	Else
		conout( STR0042 + oServer:getErrorString(nErr)) //"[SetSMTPTimeout] Sucesso ao definir Timeout SMTP: "
	EndIf
	
	// Conecta ao servidor
	nErr := oServer:smtpConnect()
	If nErr <> 0	
		CoNout(STR0043 + oServer:getErrorString(nErr)) // "[Connect SMTP] Falha ao conectar: "		
		oServer:SMTPDisconnect()
		Help(" ",1,STR0006,,oServer:getErrorString(nErr),4,5)      //Atencao
		Return(.F.)
	Else
		CoNout(STR0044 + oServer:getErrorString(nErr)) // "[Connect SMTP] Sucesso ao conectar SMTP"
	EndIf
	
	// Realiza autenticacao no servidor
	If lRelauth
		cFrom		:= GetNewPar("MV_RELFROM","") 	// E-mail do remetente
		nErr := oServer:smtpAuth(cConta, cSenha)
		If nErr <> 0		
			CoNout(STR0045 + oServer:getErrorString(nErr)) // Falha ao autenticar: 
			oServer:SMTPDisconnect()
			Help(" ",1,STR0017,,oServer:getErrorString(nErr),4,5)  //"Autenticacao"
			MsgStop(STR0019,STR0018) 		 //"Erro de autenticação","Verifique a conta e a senha para envio"
			Return(.F.)
		Else
			CoNout(STR0046 + oServer:getErrorString(nErr)) //"[AUTH] Sucesso ao autenticar: "	
		EndIf
	EndIf	
	
	conout( STR0047 ) //"[MESSAGE] Criando mail message"
	
	// Cria uma nova mensagem (TMailMessage)
	oMessage := TMailMessage():New()
	oMessage:clear()
	
	oMessage:cFrom		:= cFrom
	oMessage:cTo    	:= cEmailTo
	oMessage:cBCC		:= cEmailBcc
	oMessage:cSubject	:= cAssunto
	oMessage:cBody 		:= cMensagem
	
	If !Empty(cAttach)
		nErr := oMessage:AttachFile( cAttach )
  		If nErr < 0
  			Conout(STR0048 +  oServer:getErrorString(nErr)) //"[Attach] Erro ao anexar arquivo"
    		Return .F.
  		Endif
	EndIf	
	
	conout( STR0049 ) //"[SEND] Enviando ..."
	nErr := oMessage:Send( oServer )
		  
	If nErr != 0
		conout( STR0050 ) //"[SEND] Falha ao enviar"
		conout( STR0051 + str( nErr, 6 ), oServer:GetErrorString( nErr ) ) //"[SEND][ERROR] "
		Help(" ",1,STR0006,,oServer:GetErrorString( nErr )+ " " + cEmailTo,4,5)	//Atenção
	Else
		conout( STR0052 + oServer:getErrorString(nErr) ) //"[SEND] Sucesso no envio"
	EndIf
	
	conout( STR0053 ) //"[DISCONNECT] Desconectando SMTP "
	nErr := oServer:SmtpDisconnect()
	If nErr != 0
		conout( STR0054 ) //"[DISCONNECT] Falha ao Desconectar SMTP"
		conout( STR0055 + str( nErr, 6 ), oServer:GetErrorString( nErr ) ) //"[DISCONNECT][ERROR] "
	Else
		conout( STR0056 + oServer:getErrorString(nErr) ) //"[DISCONNECT] Sucesso ao desconectar SMTP"
	EndIf
	
Else
	CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenha RESULT lResult
	
	// Se a conexao com o SMPT esta ok
	If lResult
		
		// Se existe autenticacao para envio valida pela funcao MAILAUTH
		If lRelauth
			lRet := Mailauth(cConta,cSenha)	
		Else
			lRet := .T.	
	    Endif    
	
		If lRet
			SEND MAIL FROM cFrom ;
			TO      	cEmailTo;
			BCC     	cEmailBcc;
			SUBJECT 	cAssunto;
			BODY    	cMensagem;
			ATTACHMENT  cAttach  ;
			RESULT lResult
			
			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError
				Help(" ",1,STR0006,,cError+ " " + cEmailTo,4,5)	//Atenção
			Endif
	
		Else
			GET MAIL ERROR cError
			Help(" ",1,STR0017,,cError,4,5)  //"Autenticacao"
			MsgStop(STR0019,STR0018) 		 //"Erro de autenticação","Verifique a conta e a senha para envio"
		Endif
			
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Help(" ",1,STR0006,,cError,4,5)      //Atencao
	Endif
		
EndIf



Return(lResult)
