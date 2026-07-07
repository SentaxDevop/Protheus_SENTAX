#INCLUDE "PROTHEUS.CH"          
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"     
#INCLUDE "FWMVCDEF.CH"   
//#INCLUDE "DIRECTRY.CH"    
#INCLUDE "FILEIO.CH"  
#INCLUDE "AP5MAIL.CH"
//---------------------------------------------------------------------
/*/{Protheus.doc} MFAT006
Cadastro de e-mails para envio de workflows de notas devolvidas 
 
@sample		U_MFAT006()
 
@return 	oBrowse - Objeto do Browse

@author 	Alessandro Smaha
@since 		13/10/2014
@version 	P11
/*/
//--------------------------------------------------------------------- 
User Function MFAT006()  

Local oBrowse 		:= Nil

Private cCadastro	:= "E-mails para devolução de Notas"
Private nOpca      	:= 0
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z09")
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

Return oBrowse      


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados
                
@sample		ModelDef()

@return 	oModel - Objeto do Modelo de Dados

@author		Alessandro Smaha
@since		03/09/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStru 	:= FWFormStruct(1,"Z09" )

oModel := MPFormModel():New('MFAT006P')
oModel:AddFields( "Z09MASTER", /*cOwner*/, oStru )
oModel:SetPrimaryKey( { "Z09_FILIAL", "Z09_CODIGO"} )
oModel:SetDescription(cCadastro)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface 
                
@sample		ViewDef()

@return 	oView - Objeto da Interface

@author		Alessandro Smaha
@since		03/09/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
 
Local oModel	:= FWLoadModel( 'SENTAX_MFAT006' )
Local oStru		:= FWFormStruct( 2, "Z09" )
Local oView		:= Nil

oView:= FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW', oStru, "Z09MASTER" )
oView:CreateHorizontalBox( 'TELA', 100 )
oView:SetOwnerView( 'VIEW', 'TELA' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de opções
                
@sample		ViewDef()

@return 	aRotina - Array com opções do menu

@author		Alessandro Smaha
@since		03/09/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
       
ADD OPTION aRotina TITLE "Pesquisar"   			ACTION 'VIEWDEF.SENTAX_MFAT006' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"  			ACTION 'VIEWDEF.SENTAX_MFAT006' 	OPERATION 2 ACCESS 0  
ADD OPTION aRotina TITLE "Incluir"     			ACTION 'VIEWDEF.SENTAX_MFAT006' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     			ACTION 'VIEWDEF.SENTAX_MFAT006' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     			ACTION 'VIEWDEF.SENTAX_MFAT006' 	OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Teste Envio E-mail"   ACTION 'U_MFAT006A' OPERATION 2 ACCESS 0 

Return aRotina   


//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT006A
Rotina realizar teste de envio de e-mail via menu

@author  Alessandro Smaha
@since   17/11/2014
@return  NIL
/*/
//-------------------------------------------------------------------  
User Function MFAT006A() 
     
	Local cTextoAd := "Teste para envio de e-mail [MFAT006]."  	
	Local cEnvMail := Alltrim(Z09->Z09_EMAIL)
	Local cTitMail := fDescricao(Z09->Z09_TIPO)
	   	                           
	fProcEmail( cEnvMail, cTitMail, cTextoAd )

Return 
        

//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT006B
Rotina buscar os e-mails referente as notas devolvidas

@author  Alessandro Smaha
@since   17/11/2014
@return  NIL
/*/
//-------------------------------------------------------------------  
User Function MFAT006B( cDoc, cSerie, cTipo, cFornece, cLojaFor, cUsrDev, cMotDev, nValFrete, nValTrans ) 
    
	Local cTextoAd 	:= ""
	Local cQuery 	:= ""  
	Local cEnvMail	:= ""  
	Local cTiposAux	:= ""  
	Local cBlkList	:= ""
	Local aMailsEnv := {}  
	Local aRecnoTp1	:= {}
	Local aRecnoTp2	:= {}
	Local aRecnoTp3	:= {}
	Local aRecnoTp4	:= {}  
	Local cTipo1Env := ""
	Local cTipo2Env := ""
	Local cTipo3Env := ""
	Local cTipo4Env := ""    
	Local cDescCli	:= ""
	Local cTitMail  := ""  
	Local cDesTipo	:= ""
	Local nK		:= 0  
	
	Private cTxtLog	:= ""
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1)) // F4_FILIAL+F4_CODIGO 
	
	DbSelectArea("Z09")
	Z09->(DbSetOrder(3)) // Z09_FILIAL+Z09_EMAIL
	
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	
	If (Select("QRYN") <> 0)
		
		DbSelectArea("QRYN")
		QRYN->(DbCloseArea())
		
	Endif
	
	cQuery := " SELECT A1_NOME, D1_DOC, D1_SERIE, D1_ITEM, D1_NFORI, D1_SERIORI, D1_QUANT, D2_QUANT, D1_VALFRE, D1_COD, B1_DESC, D1_TES, " 
	cQuery += "        (SELECT Count(*) " 
	cQuery += "         FROM   " + RetSQLName("SD1") + " SD1B " 
	cQuery += "         WHERE  SD1B.D1_FILIAL = SD1.D1_FILIAL " 
	cQuery += "                AND SD1B.D1_DOC = '"+cDoc+"' " 
	cQuery += "                AND SD1B.D1_SERIE = '" + cSerie + "' " 
	cQuery += "                AND SD1B.D1_FORNECE = SD1.D1_FORNECE " 
	cQuery += "                AND SD1B.D1_LOJA = SD1.D1_LOJA " 
	cQuery += "                AND SD1B.D_E_L_E_T_ <> '*') AS TOT_DEV, " 
	cQuery += "        (SELECT Count(*) " 
	cQuery += "         FROM   " + RetSQLName("SD2") + " SD2B " 
	cQuery += "         WHERE  SD2B.D2_FILIAL = SD1.D1_FILIAL " 
	cQuery += "                AND SD2B.D2_DOC = SD1.D1_NFORI " 
	cQuery += "                AND SD2B.D2_SERIE = SD1.D1_SERIORI " 
	cQuery += "                AND SD2B.D2_CLIENTE = SD1.D1_FORNECE " 
	cQuery += "                AND SD2B.D2_LOJA = SD1.D1_LOJA " 
	cQuery += "                AND SD2B.D_E_L_E_T_ <> '*') AS TOT_ORI " 
	cQuery += " FROM   " + RetSQLName("SD1") + " SD1 " 
	cQuery += "        INNER JOIN " + RetSQLName("SF2") + " SF2 " 
	cQuery += "                ON F2_FILIAL = D1_FILIAL " 
	cQuery += "                   AND F2_DOC = D1_NFORI " 
	cQuery += "                   AND F2_SERIE = D1_SERIORI " 
	cQuery += "                   AND F2_CLIENTE = D1_FORNECE " 
	cQuery += "                   AND F2_LOJA = D1_LOJA " 
	cQuery += "                   AND SF2.D_E_L_E_T_ <> '*' " 
	cQuery += "        INNER JOIN " + RetSQLName("SD2") + " SD2 " 
	cQuery += "                ON D2_FILIAL = D1_FILIAL " 
	cQuery += "                   AND D2_DOC = D1_NFORI " 
	cQuery += "                   AND D2_SERIE = D1_SERIORI " 
	cQuery += "                   AND D2_CLIENTE = D1_FORNECE " 
	cQuery += "                   AND D2_LOJA = D1_LOJA " 
	cQuery += "                   AND D2_ITEM = D1_ITEMORI "
	cQuery += "                   AND D2_COD = D1_COD " 
	cQuery += "                   AND SD2.D_E_L_E_T_ <> '*' "
	cQuery += "        INNER JOIN " + RetSQLName("SA1") + " SA1 " 
	cQuery += "                ON A1_COD = D1_FORNECE " 
	cQuery += "                   AND A1_LOJA = D1_LOJA " 
	cQuery += "                   AND SA1.D_E_L_E_T_ <> '*' " 
	cQuery += "        INNER JOIN " + RetSQLName("SB1") + " SB1 " 
	cQuery += "                ON B1_COD = D1_COD " 
	cQuery += "                   AND SB1.D_E_L_E_T_ <> '*' " 
	cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
	cQuery += "        AND D1_DOC = '"+cDoc+"' " 
	cQuery += "        AND D1_SERIE = '" + cSerie + "' " 
	cQuery += "        AND D1_FORNECE = '" + cFornece + "' " 
	cQuery += "        AND D1_LOJA = '" + cLojaFor + "' " 
	cQuery += "        AND D1_NFORI <> '' " 
	cQuery += "        AND SD1.D_E_L_E_T_ <> '*' " 
	cQuery += " ORDER  BY D1_DOC, D1_ITEM " 
		
	TCQuery cQuery new Alias "QRYN"
	
	QRYN->(DbGoTop())
	
	If QRYN->(!Eof())
	    
		If cTipo $ "D"
			cDesTipo := "DEVOLUÇÕES"
		Else
			cDesTipo := "COMODATOS"
		EndIF
		
		cTitMail := cDesTipo+" - Cliente: "+Alltrim(cFornece)+" / "+Alltrim(cLojaFor)+" - NF: "+Alltrim(cDoc)+" / "+Alltrim(cSerie) 
		
		cTxtLog  := cTitMail
			 
		cDescCli := '			<div>'
		cDescCli += '			<table cellpadding="1" cellspacing="2" border="0" style="font-family: Verdana, Arial;color: #000000; font-size: 12px;">'
		cDescCli += '				<tr style="font-family: Verdana, Arial;font-weight: bold;color: #000000;text-align: left;font-size: 14px;background-color: #FFFFFF;" height="20">'				
		cDescCli += '					<td width="400">Cliente: '+Alltrim(cFornece)+" / "+Alltrim(cLojaFor)+'</td>'
		cDescCli += '					<td width="800">Nome: '+Alltrim(QRYN->A1_NOME)+'</td>'							
		cDescCli += '				</tr>'			
		cDescCli += '			</table>'
		cDescCli += '			</div>'	
		cDescCli += '			<div>'
		cDescCli += '			<table cellpadding="1" cellspacing="2" border="0" style="font-family: Verdana, Arial;color: #000000; font-size: 12px;">'
		cDescCli += '				<tr style="font-family: Verdana, Arial;font-weight: bold;color: #000000;text-align: left;font-size: 14px;background-color: #FFFFFF;" height="20">'				
		cDescCli += '					<td width="400">Tipo: '+cDesTipo+'</td>'
		cDescCli += '					<td width="800">Responsável: '+Upper(Alltrim(UsrFullName(cUsrDev)))+'</td>'									
		cDescCli += '				</tr>'				
		cDescCli += '			</table>'
		cDescCli += '			</div>'	
		cDescCli += '			<div>'
		cDescCli += '			<table cellpadding="1" cellspacing="2" border="0" style="font-family: Verdana, Arial;color: #000000; font-size: 12px;">'
		cDescCli += '				<tr style="font-family: Verdana, Arial;font-weight: bold;color: #000000;text-align: left;font-size: 14px;background-color: #FFFFFF;" height="20">'				
		cDescCli += '					<td width="400">Nota de Devolução: '+Alltrim(cDoc)+" / "+Alltrim(cSerie)+'</td>'
		cDescCli += '					<td width="300">Frete Devolução: '+Transform( nValFrete , "@E 99,999,999,999.99" )+'</td>'
		cDescCli += '					<td width="300">Custo Transporte: '+Transform( nValTrans , "@E 99,999,999,999.99" )+'</td>'								
		cDescCli += '				</tr>'
		cDescCli += '			</table>'
		cDescCli += '			</div>'
														
		While QRYN->(!Eof())
					 
			If !Empty(QRYN->D1_TES) .AND. SF4->(DbSeek(xFilial("SF4")+Alltrim(QRYN->D1_TES)))
			       				
				cDocOri		:= ""
				cSerOri		:= ""
				cItens		:= "" 
				cTotParc	:= "Total" 	 
				cChave		:= QRYN->( D1_DOC + D1_SERIE )	       
				                
				If QRYN->TOT_ORI <> QRYN->TOT_DEV 
				 	cTotParc := "Parcial"
				EndIf  
				
				While QRYN->(!Eof()) .AND. cChave == QRYN->( D1_DOC + D1_SERIE ) 
				
					cDocOri		:= QRYN->D1_NFORI
			   		cSerOri		:= QRYN->D1_SERIORI 
			   		
			   		cItens += IIF(!Empty(cItens),"<br><br>","") 				     
				 	cItens += Alltrim(QRYN->D1_COD) + " - " + Alltrim(QRYN->B1_DESC)+ " / " + cValToChar(QRYN->D1_QUANT) + CHR(13)+CHR(10) 
				     
				 	If QRYN->D1_QUANT <> QRYN->D2_QUANT 
					 	cTotParc := "Parcial"
					EndIf 
					
					QRYN->(DbSkip())
				EndDo
				
				cTextoAd := '<tr style="font-family: Verdana, Arial;font-size: 12px;color: #000000;background-color: #D1EBF1;" height="20">'				
				cTextoAd += '	<td width="150">'+Alltrim(cDocOri)+" / "+Alltrim(cSerOri)+'</td>'
				cTextoAd += '	<td width="150">'+cTotParc+'</td>'
				cTextoAd += '	<td width="1200">'+cItens+'</td>'									
				cTextoAd += '</tr>'
 			
				If cTipo $ "D" .AND. SF4->F4_DUPLIC == "S"	// Devolução com financeiro				
					cTipoEnv := "1"	
					cTipo1Env += cTextoAd
				ElseIf cTipo $ "D" 							// Qualquer devolução				
					cTipoEnv := "2" 
					cTipo2Env += cTextoAd					
				ElseIf SF4->F4_DUPLIC == "S"				// Beneficiamento com financeiro				
					cTipoEnv := "3" 
					cTipo3Env += cTextoAd					
				Else 				               			// Qualquer beneficiamento
					cTipoEnv := "4"	
					cTipo4Env += cTextoAd											
				EndIf 
				
				If ! cTipoEnv $ cTiposAux 				
				 	cTiposAux += cTipoEnv				
				EndIf 
				 
			Else    
			
				QRYN->(DbSkip())
			
			EndIf
			
		EndDo 
				
		QRYN->(DbGoTop())    
		
		Z09->(DbGoTop())
		
		If Z09->(!Eof())  
		
			While Z09->(!Eof()) 
			    
				If Z09->Z09_TIPO $ cTiposAux
				
					aMailsSep := Separa(Alltrim(Z09->Z09_EMAIL),";")
					
					For nK := 1 to Len(aMailsSep)
					    
						nPos := aScan(aMailsEnv,{|x| AllTrim(x[1]) == Alltrim(aMailsSep[nK])}) 
						
						If nPos > 0   
							If ! Z09->Z09_TIPO $ aMailsEnv[nK][2]
						   		aMailsEnv[nK][2] += Z09->Z09_TIPO
						 	EndIf
						Else
						 	aAdd(aMailsEnv,{aMailsSep[nK],Z09->Z09_TIPO}) // aMailsSep
						EndIf
						
					Next nK
				
				EndIf
				
				Z09->(DbSkip())
			EndDo
		
		EndIf  
		
		If Len(aMailsEnv) > 0 
		
			For nK := 1 to Len(aMailsEnv) 
			
				cTextMail := '<html>'
				cTextMail += '<head></head>'
				cTextMail += '<body>'
				cTextMail += '	<div>'
				cTextMail += '		<div>'	
				cTextMail += '			<br />'	
				cTextMail += '			<p style="font-family: Verdana, Arial;font-weight: bold;color: #FF0000;text-align: left;font-size: 18px;">Fazer compensação '+cTotParc+' da NFE abaixo</p>'	
				cTextMail += '		</div>'
				cTextMail += '		<br />'
				cTextMail += '		<div>'			
				cTextMail += '			<div>'
				cTextMail += cDescCli
				cTextMail += '			</div>'	
				cTextMail += '			<div>'
				cTextMail += '			<table cellpadding="1" cellspacing="2" border="0" style="font-family: Verdana, Arial;color: #000000; font-size: 12px;">'
				cTextMail += '				<tr style="font-family: Verdana, Arial;font-weight: bold;color: #000000;text-align: left;font-size: 14px;background-color: #FFFFFF;" height="20">'				
				cTextMail += '					<td width="1600">Motivo: '+Alltrim(cMotDev)+'</td>'					
				cTextMail += '				</tr>'
				cTextMail += '			</table>'
				cTextMail += '			</div>'			
				cTextMail += '		</div>'
				cTextMail += '		<br />'
				cTextMail += '		<div>'			
				cTextMail += '			<div>'                                                                                                                 
				cTextMail += '			<table cellpadding="1" cellspacing="2" border="0" style="font-family: Verdana, Arial;color: #000000; font-size: 12px;">'
				cTextMail += '				<tr style="font-family: Verdana, Arial; font-size: 12px; color: #FFFFFF;background-color: #0070C0;text-align: center;" height="20">'
				cTextMail += '					<th>NFE (Venda)</th>'
				cTextMail += '					<th>Devolução</th>'
				cTextMail += '					<th>Item / Quantidade</th>'						
				cTextMail += '				</tr>'				

				cEnvMail  := aMailsEnv[nK][1] 
				cTipoEnv  := aMailsEnv[nK][2]
						
				If "1" $ cTipoEnv
					cTextMail += cTipo1Env
				EndIf
				
				If "2" $ cTipoEnv
			  		cTextMail += cTipo2Env
				EndIf
				
				If "3" $ cTipoEnv
			  		cTextMail += cTipo3Env
				EndIf
				
				If "4" $ cTipoEnv
			  		cTextMail += cTipo4Env
				EndIf  
								
				cTextMail += '			</table>'
				cTextMail += '			</div>'			
				cTextMail += '		</div>'	
				cTextMail += '	<div>'
				cTextMail += '</body>'
				cTextMail += '</html>'  
							
				If !Empty(cTextMail)
				 	
				 	fProcEmail( cEnvMail, cTitMail, cTextMail )	
				 	
				EndIf				
				
			Next nK
			
		EndIf
				
	EndIf
	
	QRYN->(DbCloseArea())
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fProcEmail()
Rotina processar envio de e-mail

@author  Alessandro Smaha
@since   17/11/2014
@return  NIL
/*/
//------------------------------------------------------------------- 
Static Function fProcEmail( cEnvMail, cTitMail, cTextoAd )

	U_MFAT006E( cEnvMail, cTitMail, cTextoAd )

Return      


//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT006E
Rotina para enviar e-mail

@param		cToEnv - Email do destinatário
			cTitEmail - Titulo do e-mail
			cTextBody - Conteúdo do e-mail

@author  Alessandro Smaha
@since   17/11/2014
@return  NIL
/*/
//-------------------------------------------------------------------  
User Function MFAT006E( cToEnv, cTitEmail, cTextBody )

Local cConMail   := Alltrim( SuperGetMv("MV_RELACNT",,"") )	// Conta a ser utilizada no envio de E-Mail para os relatorios                                        
Local cSenMail   := Alltrim( SuperGetMv("MV_RELPSW",,"") )	// Senha da Conta de E-Mail para envio de relatorios 
Local cSmtpMail  := Alltrim( SuperGetMv("MV_RELSERV",,"") )	// Nome do Servidor de Envio de E-mail utilizado nos relatorios                                        
Local lAutentic  := SuperGetMv("MV_RELAUTH",,.T.) 	   	  	// Servidor de EMAIL necessita de Autenticacao?      
Local cUsrAuth   := Alltrim( SuperGetMv("MV_RELAUSR",,"") ) // Usuario para Autenticacao no Servidor de Email    
Local cSenAuth   := Alltrim( SuperGetMv("MV_RELAPSW",,"") ) // Senha para autenticacäo no servidor de e-mail     
Local lUseTls    := SuperGetMv("MV_RELTLS",,.T.)			// Informe se o servidor de SMTP possui conexao do tipo segura ( SSL/TLS ).                          
Local lUseSsl    := SuperGetMv("MV_RELSSL",,.F.) 			// Define se o envio e recebimento de e-mails na rotina SPED utilizara conexao segura (SSL).       
Local cMsgLog	 := ""
Local nPortaSmtp := 0
Local nRet 		 := 0
Local lRetOk 	 := .F.
Local aSmtSrvPt  := {}
Local oMail
Local oMessage
Local cEmailCCo  := Alltrim( SuperGetMv("ST_RETDOCM",,"smaha@afsouza.com.br;suelen@afsouza.com.br") ) // E-mail copia oculta para devoluções

cMsgLog := "Inicio Envio de e-mails ---------------"
U_MFAT006T(cMsgLog)
                  
//U_MFAT006T(cTxtLog)  

aSmtSrvPt  := Separa(cSmtpMail,':',.F.)

If Len(aSmtSrvPt) <> 2
	cMsgLog := "Verificar o servidor SMTP e a porta informada! Ex: smtp.servidor.com:992"
	U_MFAT006T(cMsgLog)
	Return lRetOk
Else
	cSmtpMail  := Alltrim(aSmtSrvPt[1])
	nPortaSmtp := Val(aSmtSrvPt[2])
EndIf

oMail := tMailManager():New()
oMessage := TMailMessage():New()

oMail:SetUseTLS(lUseTls) // oMail:SetUseTLS(.T.)   // 587
//oMail:SetUseSSL(.T.) // 465

oMail:Init("", cSmtpMail, cConMail, cSenMail, , nPortaSmtp )

If oMail:SetSMTPTimeout(120) <> 0 // 2 min
	cMsgLog := "SetTimeOut ERRO"
	U_MFAT006T(cMsgLog)
	Return lRetOk
Endif

nRet := oMail:SMTPConnect()

If nRet <> 0
	cMsgLog := "Conexao ERRO - "+oMail:GetErrorString(nRet)
	U_MFAT006T(cMsgLog)
Endif

If lAutentic
	
	nRet := oMail:SMTPAuth( cUsrAuth, cSenAuth )
	
	If nRet  <> 0
		cMsgLog := "Autenticacao ERRO - "+oMail:GetErrorString(nRet)
 		U_MFAT006T(cMsgLog)
		oMail:SmtpDisconnect()
		Return lRetOk
	Else
		cMsgLog := "Autenticacao OK"
 		U_MFAT006T(cMsgLog)
	EndIf
Else
	cMsgLog := "Nao possui autenticacao"
 	U_MFAT006T(cMsgLog)
EndIf

oMessage:Clear()
oMessage:cFrom           := cConMail
oMessage:cTo             := cToEnv
oMessage:cCc             := ""
oMessage:cBcc            := cEmailCCo
oMessage:cSubject        := cTitEmail
oMessage:cBody           := cTextBody   

oMessage:MsgBodyType( "text/html" )

nRet := oMessage:Send( oMail )

If nRet <> 0
	cMsgLog := "Erro ao enviar e-mail: "+oMail:GetErrorString( nRet )
 	U_MFAT006T(cMsgLog)
Else
	lRetOk := .T.                                 	
	cMsgLog := "Enviou e-mail para: ("+cToEnv+")"
 	U_MFAT006T(cMsgLog)
Endif

nRet := oMail:SmtpDisconnect()

If nRet <> 0
	cMsgLog := "Desconectar ERRO - "+oMail:GetErrorString(nRet)
 	U_MFAT006T(cMsgLog)
Endif

cMsgLog := "--------------- Fim Envio de e-mails."
U_MFAT006T(cMsgLog)

If !lRetOk
	MsgAlert("Erro ao enviar e-mail da devolução para ("+Alltrim(cToEnv)+")! "+cMsgLog,"Atenção")
EndIf

Return lRetOk   


//-------------------------------------------------------------------
/*/{Protheus.doc} fDescricao()
Busca a Descrição do tipo

@author  Alessandro Smaha
@since   17/11/2014
@return  NIL
/*/
//-------------------------------------------------------------------  
Static Function fDescricao(cTipo)

Local cDescri := ""    

Do Case    

	Case cTipo == "1"
		cDescri := "Nota de Devolução com Financeiro"  
		
	Case cTipo == "2"
		cDescri := "Nota de Devolução"	 
				
	Case cTipo == "3"
		cDescri := "Nota de Retorno de Beneficiamento com Financeiro"	  
		
	Case cTipo == "4"
		cDescri := "Nota de Retorno de Beneficiamento" 
		
	OtherWise
		cDescri := "Tipo desconhecido." 
		
EndCase

Return cDescri


//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT006T
Rotina para gravar o log para os envios de e-mail.
                
@sample		U_MFAT006T(cConteudo)

@author		Alessandro Smaha
@since		02/03/2017     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function MFAT006T(cConteudo)

Local cDirLog	:= "\Log\Retorno\"
Local cArqLog	:= "SENTAX_RETORNO_"+StrZero(Year(dDataBase),4)+"_"+StrZero(Month(dDataBase),2)+".LOG"
Local nHandle	:= 0

MontaDir(cDirLog) // Cria o diretorio se não existir
 
If File( cDirLog + cArqLog ) 
	nHandle := fOpen( cDirLog + cArqLog, FO_READWRITE+FO_SHARED ) 
Else
	nHandle := FCreate( cDirLog + cArqLog )  
EndIf

If nHandle == -1   
	Conout("[MFAT006T]"+"Não foi possível abrir ou criar o arquivo: " + cArqLog )			
Else      
	cConteudo := DtoC(dDataBase) + " " + Time() + " " + Alltrim(cConteudo) + CHR(13) + CHR(10)
	FSeek(nHandle,0,2)
	FWrite(nHandle, cConteudo)   
	FClose(nHandle)
EndIf								
 
Return
 