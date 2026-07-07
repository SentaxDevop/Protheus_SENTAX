#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "DIRECTRY.CH"    
#INCLUDE "FILEIO.CH"  
#INCLUDE "AP5MAIL.CH"      
#DEFINE CRLF (chr(13)+chr(10)) 
//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC007
Rotina para chamar o envio de e-mails para controle 
de ordens de serviço no Field Service 

@sample		U_RTEC007()

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
User Function RTEC007()

Local cPerg := "RTEC007"
                       
fCriaSX1(cPerg)  

If Pergunte(cPerg,.t.)
	
	If !Empty( MV_PAR01 )
		
		Processa( { || fGeraHtml( MV_PAR01, .T. ) },"Aguarde... ", "Verificando Ordens de Serviço",.T. )
		
	EndIf

EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC007S
Rotina chamada via schedule para envio de e-mails para controle 
de ordens de serviço no Field Service 

@sample		U_RTEC007S()

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
User Function RTEC007S(aParStx)

Conout(Replicate("-",60))
ConOut("[RTEC007S] Schedule Iniciado: "+DtoC(Date())+" "+Time() )
Conout(Replicate("-",60))

RpcSetType(3)

PREPARE ENVIRONMENT EMPRESA aParStx[1] FILIAL aParStx[2] TABLES "AB6,AB7" MODULO "SIGATEC"
    
	fGeraHtml( dDataBase, .F. )
	
RESET ENVIRONMENT

Conout(Replicate("-",60))
ConOut("[RTEC007S] Schedule Finalizado: "+DtoC(Date())+" "+Time() )
Conout(Replicate("-",60))

Return  


//-------------------------------------------------------------------
/*/{Protheus.doc} fGeraHtml
Gera o arquivo HTML para envio por e-mail

@sample		fGeraHtml( dDataAtu, lMenu )

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fGeraHtml( dDataAtu, lMenu )

Local cHtml		:= ""
Local cQuery	:= "" 
Local cItens	:= "" 
Local cStatus	:= ""
Local cOsPosi	:= ""
Local nTotPre	:= 0 
Local nTotAtu	:= 0 
Local nTotPos	:= 0 
Local cDirHtm 	:= "\temp\"  
Local cArqHtm	:= cArqHtm	:= "OS_ABERTO_"+StrZero(Year(dDataBase),4)+"_"+StrZero(Month(dDataBase),2)+"_"+StrTran(Time(),":")+".HTML"  
Local cDataPre 	:= DtoC(DataValida(dDataAtu-1,.F.))
Local sDataPre 	:= DtoS(DataValida(dDataAtu-1,.F.)) 
Local cDataAtu 	:= DtoC(DataValida(dDataAtu,.T.))
Local sDataAtu 	:= DtoS(DataValida(dDataAtu,.T.))   
Local cDataPos 	:= DtoC(DataValida(dDataAtu+1,.T.))
Local sDataPos 	:= DtoS(DataValida(dDataAtu+1,.T.))
 
MontaDir(cDirHtm) // Cria o diretorio se não existir
 		 
cHtml := fCabHtml( cDataAtu ) 

If lMenu 
	ProcRegua(0)
EndIf
   
   
// OS EM ATRASO

cHtml += '<h3>ORDENS DE SERVIÇO EM ATRASO - PREVISÃO DE ATEDIMENTO ATÉ '+cDataPre+'</h3>'

If Select("QTMP") <> 0
	DbSelectArea("QTMP")
	QTMP->(DbCloseArea())
EndIf 

cQuery := fMontaQry( sDataPre, 1 ) 

TCQUERY cQuery NEW ALIAS "QTMP"

DbSelectArea("QTMP")
QTMP->(DbGotop())

cOsPosi := ""

If !QTMP->(EOF())
        		
	cHtml += '<table>'+CRLF 
	cHtml += fCabTab() 
	
	fGravaArq( cDirHtm, cArqHtm, cHtml )
	
	While !QTMP->(EOF())
	
		If lMenu 
			IncProc("Preparando arquivo para envio por e-mail..."+CRLF+"OS em Atraso") 
		EndIf 
		
		If cOsPosi <> QTMP->AB6_NUMOS+QTMP->AB7_ITEM
			
			nTotPre++ 
		
			cMunCli := "" 
			cEstCli := ""
			
			SA1->(DbSeek(xFilial("SA1")+QTMP->A1_COD+QTMP->A1_LOJA))
		
			If QTMP->AB6_XCDEND == "000"        
			
				cMunCli := Alltrim(SA1->A1_MUN) 
				cEstCli := Alltrim(SA1->A1_EST)
						
			Else // "999" // O Kaminski pediu para considerar o endereço de entrega do cliente para os 001 a 999
	
				cMunCli := Alltrim(SA1->A1_MUNE)
				cEstCli := Alltrim(SA1->A1_ESTE)
				
			EndIf
			
			If QTMP->AB7_TIPO == "1" // 1=O.S.;2=Pedido Gerado;3=Em Atendimento;4=Atendido;5=Encerrado
				cStatus := "O.S"
			ElseIf QTMP->AB7_TIPO == "3"   
				cStatus := "Em Atendimento"
			Else
				cStatus := ""		
			EndIf
			
			cHtml := '  <tr>'+CRLF 					
			cHtml += '    <td>'+QTMP->AB6_NUMOS+'</td>'+CRLF 		// Num.Os.
		    cHtml += '    <td>'+QTMP->A1_COD+'</td>'+CRLF	   		// Cliente	
			cHtml += '    <td>'+QTMP->A1_NOME+'</td>'+CRLF   		// Nome do Cliente 
			cHtml += '    <td>'+cStatus+'</td>'+CRLF   	   			// Status 
			cHtml += '    <td>'+cMunCli+'</td>'+CRLF   	 			// Municipo
			cHtml += '    <td>'+cEstCli+'</td>'+CRLF 	   			// UF
			cHtml += '    <td>'+QTMP->DESC_REG+'</td>'+CRLF	   		// Região
			cHtml += '    <td>'+QTMP->DESC_PRO+'</td>'+CRLF	   		// Tipo de Os		
			cHtml += '    <td>'+DtoC(StoD(QTMP->AB6_EMISSA))+'</td>'+CRLF	// Data Emissão
			cHtml += '    <td>'+DtoC(StoD(QTMP->AB6_XDATPR))+'</td>'+CRLF	// Previsão Atendimento
			cHtml += '    <td>'+DtoC(StoD(QTMP->ABB_DTINI))+'</td>'+CRLF	// Data Agendamento
			cHtml += '    <td>'+QTMP->AA1_NOMTEC+'</td>'+CRLF 	 	// Nome do Técnico	 	
			cHtml += '    <td>'+QTMP->BM_DESC+'</td>'+CRLF 			// Linha do Equipamento
			cHtml += '    <td>'+QTMP->AB1_ATEND+'</td>'+CRLF 		// Aberto por			
			cHtml += '  </tr>'+CRLF 
			 
			fGravaArq( cDirHtm, cArqHtm, cHtml ) 
			
		EndIf
		
		cOsPosi := QTMP->AB6_NUMOS+QTMP->AB7_ITEM
					
		QTMP->(dbSkip())
		
	EndDo 
	
	cHtml := '</table>'+CRLF
			
Else 

	cHtml += '<table>'+CRLF
	cHtml += '  <tr>'+CRLF
    cHtml += '  	<th width="100%" align="left">Não possui Ordens de Serviço.</th>'+CRLF
  	cHtml += '  </tr>'+CRLF
	cHtml += '  </table>'+CRLF
	
EndIf 

fGravaArq( cDirHtm, cArqHtm, cHtml )
						 
// OS PARA HOJE

cHtml := '<br><br>'+CRLF
cHtml += '<h3>ORDENS DE SERVIÇO PARA HOJE - PREVISÃO DE ATENDIMENTO ATÉ '+cDataAtu+'</h3>'

If Select("QTMP") <> 0
	DbSelectArea("QTMP")
	QTMP->(DbCloseArea())
EndIf 

cQuery := fMontaQry( sDataAtu, 2 ) 

TCQUERY cQuery NEW ALIAS "QTMP"

DbSelectArea("QTMP")
QTMP->(DbGotop())

cOsPosi := ""

If !QTMP->(EOF())
        		
	cHtml += '<table>'+CRLF 
	cHtml += fCabTab() 
	
	fGravaArq( cDirHtm, cArqHtm, cHtml )
	
	While !QTMP->(EOF())
	     	
		If lMenu 
			IncProc("Preparando arquivo para envio por e-mail..."+CRLF+"OS para Hoje") 
		EndIf
		
		If cOsPosi <> QTMP->AB6_NUMOS+QTMP->AB7_ITEM
			
			nTotAtu++ 
		
			cMunCli := "" 
			cEstCli := "" 
			
			SA1->(DbSeek(xFilial("SA1")+QTMP->A1_COD+QTMP->A1_LOJA))
		
			If QTMP->AB6_XCDEND == "000"        
			
				cMunCli := Alltrim(SA1->A1_MUN) 
				cEstCli := Alltrim(SA1->A1_EST)
						
			Else // "999" // O Kaminski pediu para considerar o endereço de entrega do cliente para os 001 a 999
	
				cMunCli := Alltrim(SA1->A1_MUNE)
				cEstCli := Alltrim(SA1->A1_ESTE)
				
			EndIf
			
			If QTMP->AB7_TIPO == "1" // 1=O.S.;2=Pedido Gerado;3=Em Atendimento;4=Atendido;5=Encerrado
				cStatus := "O.S"
			ElseIf QTMP->AB7_TIPO == "3"   
				cStatus := "Em Atendimento"
			Else
				cStatus := ""		
			EndIf
			
			cHtml := '  <tr>'+CRLF 					
			cHtml += '    <td>'+QTMP->AB6_NUMOS+'</td>'+CRLF 		// Num.Os.
		    cHtml += '    <td>'+QTMP->A1_COD+'</td>'+CRLF	   		// Cliente	
			cHtml += '    <td>'+QTMP->A1_NOME+'</td>'+CRLF   		// Nome do Cliente  
			cHtml += '    <td>'+cStatus+'</td>'+CRLF   	   			// Status
			cHtml += '    <td>'+cMunCli+'</td>'+CRLF   	 			// Municipo
			cHtml += '    <td>'+cEstCli+'</td>'+CRLF 	   			// UF
			cHtml += '    <td>'+QTMP->DESC_REG+'</td>'+CRLF	   		// Região
			cHtml += '    <td>'+QTMP->DESC_PRO+'</td>'+CRLF	   		// Tipo de Os		
			cHtml += '    <td>'+DtoC(StoD(QTMP->AB6_EMISSA))+'</td>'+CRLF	// Data Emissão
			cHtml += '    <td>'+DtoC(StoD(QTMP->AB6_XDATPR))+'</td>'+CRLF	// Previsão Atendimento
			cHtml += '    <td>'+DtoC(StoD(QTMP->ABB_DTINI))+'</td>'+CRLF	// Data Agendamento
			cHtml += '    <td>'+QTMP->AA1_NOMTEC+'</td>'+CRLF 	 	// Nome do Técnico	 	
			cHtml += '    <td>'+QTMP->BM_DESC+'</td>'+CRLF 			// Linha do Equipamento
			cHtml += '    <td>'+QTMP->AB1_ATEND+'</td>'+CRLF 		// Aberto por			
			cHtml += '  </tr>'+CRLF 
			 
			fGravaArq( cDirHtm, cArqHtm, cHtml )
			
		EndIf
		
		cOsPosi := QTMP->AB6_NUMOS+QTMP->AB7_ITEM 
						
		QTMP->(dbSkip())
		
	EndDo 
	
	cHtml := '</table>'+CRLF
			
Else 

	cHtml += '<table>'+CRLF
	cHtml += '  <tr>'+CRLF
    cHtml += '  	<th width="100%" align="left">Não possui Ordens de Serviço.</th>'+CRLF
  	cHtml += '  </tr>'+CRLF
	cHtml += '  </table>'+CRLF
	
EndIf 

fGravaArq( cDirHtm, cArqHtm, cHtml )
			 
// OS PARA AMANHÃ

cHtml := '<br><br>'+CRLF 
cHtml += '<h3>ORDENS DE SERVIÇO PARA AMANHÃ - PREVISÃO DE ATENDIMENTO ATÉ '+cDataPos+'</h3>'

If Select("QTMP") <> 0
	DbSelectArea("QTMP")
	QTMP->(DbCloseArea())
EndIf 

cQuery := fMontaQry( sDataPos, 2 ) 

TCQUERY cQuery NEW ALIAS "QTMP"

DbSelectArea("QTMP")
QTMP->(DbGotop())

cOsPosi := ""

If !QTMP->(EOF())
        		
	cHtml += '<table>'+CRLF 
	cHtml += fCabTab() 
	
	fGravaArq( cDirHtm, cArqHtm, cHtml )
	
	While !QTMP->(EOF()) 
	    
		If lMenu 
			IncProc("Preparando arquivo para envio por e-mail..."+CRLF+"OS para amanhã") 
		EndIf 
		
		If cOsPosi <> QTMP->AB6_NUMOS+QTMP->AB7_ITEM
			
			nTotPos++ 
		
			cMunCli := "" 
			cEstCli := "" 
			
			SA1->(DbSeek(xFilial("SA1")+QTMP->A1_COD+QTMP->A1_LOJA))
		
			If QTMP->AB6_XCDEND == "000"        
			
				cMunCli := Alltrim(SA1->A1_MUN) 
				cEstCli := Alltrim(SA1->A1_EST)
						
			Else // "999" // O Kaminski pediu para considerar o endereço de entrega do cliente para os 001 a 999
	
				cMunCli := Alltrim(SA1->A1_MUNE)
				cEstCli := Alltrim(SA1->A1_ESTE)
				
			EndIf
			
			If QTMP->AB7_TIPO == "1" // 1=O.S.;2=Pedido Gerado;3=Em Atendimento;4=Atendido;5=Encerrado
				cStatus := "O.S"
			ElseIf QTMP->AB7_TIPO == "3"   
				cStatus := "Em Atendimento"
			Else
				cStatus := ""		
			EndIf
			
			cHtml := '  <tr>'+CRLF 					
			cHtml += '    <td>'+QTMP->AB6_NUMOS+'</td>'+CRLF 		// Num.Os.
		    cHtml += '    <td>'+QTMP->A1_COD+'</td>'+CRLF	   		// Cliente	
			cHtml += '    <td>'+QTMP->A1_NOME+'</td>'+CRLF   		// Nome do Cliente
			cHtml += '    <td>'+cStatus+'</td>'+CRLF   	   			// Status
			cHtml += '    <td>'+cMunCli+'</td>'+CRLF   	 			// Municipo
			cHtml += '    <td>'+cEstCli+'</td>'+CRLF 	   			// UF
			cHtml += '    <td>'+QTMP->DESC_REG+'</td>'+CRLF	   		// Região
			cHtml += '    <td>'+QTMP->DESC_PRO+'</td>'+CRLF	   		// Tipo de Os		
			cHtml += '    <td>'+DtoC(StoD(QTMP->AB6_EMISSA))+'</td>'+CRLF	// Data Emissão
			cHtml += '    <td>'+DtoC(StoD(QTMP->AB6_XDATPR))+'</td>'+CRLF	// Previsão Atendimento
			cHtml += '    <td>'+DtoC(StoD(QTMP->ABB_DTINI))+'</td>'+CRLF	// Data Agendamento
			cHtml += '    <td>'+QTMP->AA1_NOMTEC+'</td>'+CRLF 	 	// Nome do Técnico	 	
			cHtml += '    <td>'+QTMP->BM_DESC+'</td>'+CRLF 			// Linha do Equipamento
			cHtml += '    <td>'+QTMP->AB1_ATEND+'</td>'+CRLF 		// Aberto por			
			cHtml += '  </tr>'+CRLF 
			 
			fGravaArq( cDirHtm, cArqHtm, cHtml ) 
			
		EndIf
		
		cOsPosi := QTMP->AB6_NUMOS+QTMP->AB7_ITEM
						
		QTMP->(dbSkip())
		
	EndDo 
	
	cHtml := '</table>'+CRLF
			
Else 

	cHtml += '<table>'+CRLF
	cHtml += '  <tr>'+CRLF
    cHtml += '  	<th width="100%" align="left">Não possui Ordens de Serviço.</th>'+CRLF
  	cHtml += '  </tr>'+CRLF
	cHtml += '  </table>'+CRLF
	
EndIf 

cHtml += fRodHtml()          

fGravaArq( cDirHtm, cArqHtm, cHtml )
	
fEnviaMail( cDirHtm, cArqHtm, cDataAtu, nTotPre, nTotAtu, nTotPos, lMenu )

QTMP->(DbCloseArea()) 
    
Sleep(3000) 
FERASE( cDirHtm + cArqHtm )
 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fEnviaMail
Rotina reenviar inventário da Roche para o webService

@sample		fEnviaMail( cDirHtm, cArqHtm, cDataAtu, nTotPre, nTotAtu, nTotPos, lMenu )

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fEnviaMail( cDirHtm, cArqHtm, cDataAtu, nTotPre, nTotAtu, nTotPos, lMenu )

Local _cServer   	:= Alltrim(GetMV("MV_RELSERV",,""))
Local _cAccount  	:= Alltrim(GetMV("MV_RELACNT",,""))
Local _cPassword 	:= Alltrim(GetMV("MV_RELPSW",,""))
Local _cEnvia    	:= Alltrim(GetMV("MV_RELFROM",,""))
Local _cMail     	:= Alltrim(GetMV("ST_OSEMAIL",,""))
Local _cMailCco  	:= "suelen@afsouza.com.br"
Local _lConectou	:= .F.
Local cBody 		:= ""
Local _cAssunto  	:= "Ordens de Serviço em Aberto - "+cDataAtu

If Empty(_cMail)
	Return
EndIf

cBody := '<html>'
cBody += '<head>'
cBody += '<style>'
cBody += 'body {'
cBody += '  font-family: "Calibri", sans-serif;'
cBody += '	}'
cBody += 'p 	{'
cBody += '	font-family: "Calibri", sans-serif;'
cBody += '	font-size: 14px;'
cBody += '	}'
cBody += '</style>'
cBody += '</head>'
cBody += '<body>'
cBody += '<h2>'+_cAssunto+'.</h3>' 
cBody += '<br><br>'
cBody += '<h3>Ordens de Serviço em Atraso: '+cValToChar(nTotPre)+'</h3>'
cBody += '<h3>Ordens de Serviço para Hoje: '+cValToChar(nTotAtu)+'</h3>'
cBody += '<h3>Ordens de Serviço para Amanhã: '+cValToChar(nTotPos)+'</h3>'
cBody += '<br>'
cBody += '<h3>Relação de Ordens de Serviço Anexo.</h3>'
cBody += '<br><br><br><br>'
cBody += '<p>ATENÇÃO! Esta mensagem foi enviada por um sistema automático. Por favor, não responda a este e-mail diretamente. Via '+IIF(lMenu,"Menu","Schedule")+'.</p>'
cBody += '</body>'
cBody += '</html>'
 
// Manda e-mail

If !_lConectou
	CONNECT SMTP SERVER _cServer ACCOUNT _cAccount PASSWORD _cPassword Result _lConectou
EndIf

While !_lConectou
	CONNECT SMTP SERVER _cServer ACCOUNT _cAccount PASSWORD _cPassword Result _lConectou
End

If _lConectou
	mailauth(_cAccount, _cPassword)
	SEND MAIL FROM _cEnvia TO _cMail BCC _cMailCco SUBJECT _cAssunto BODY cBody ATTACHMENT cDirHtm+cArqHtm RESULT lEnvioOk
	If !lEnvioOk
		MostraErro()
	EndIf
	
	If _lConectou
		DISCONNECT SMTP SERVER
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaQry
Monta a query para buscar ordens de serviço

@sample		fMontaQry( sDataPos, nTipoQry ) 

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fMontaQry( sDataPos, nTipoQry ) 

Local cQuery 	:= ""

cQuery := " SELECT	AB6_NUMOS, AB7.AB7_ITEM, A1_COD, A1_LOJA, A1_NOME, AB6_XCDEND, A1_REGIAO, "+CRLF
cQuery += " 		A1_MUN, A1_EST, A1_MUNE, A1_ESTE, "+CRLF
cQuery += " 		SX5A.X5_DESCRI DESC_REG, AB6_XCLASS, SX5B.X5_DESCRI DESC_PRO, AB6_EMISSA, AB6_XDATPR, ABB_DTINI, ABB_CODTEC, AA1_NOMTEC, "+CRLF
cQuery += " 		B1_GRUPO, BM_DESC, AB6_ATEND, AB7.AB7_TIPO, AB1_ATEND "+CRLF		
cQuery += " FROM "+RetSqlName('AB7')+" AB7 "+CRLF
cQuery += " INNER JOIN "+RetSqlName('AB6')+" AB6 ON AB6_FILIAL = AB7_FILIAL AND AB6_NUMOS = AB7_NUMOS AND AB6.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " INNER JOIN "+RetSqlName('SA1')+" SA1 ON A1_COD = AB6_CODCLI AND A1_LOJA = AB6_LOJA AND SA1.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " INNER JOIN "+RetSqlName('SB1')+" SB1 ON B1_COD = AB7_CODPRO AND SB1.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " INNER JOIN "+RetSqlName('SBM')+" SBM ON BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_ <> '*' "+CRLF  

cQuery += " INNER JOIN (	SELECT AB7_FILIAL, AB7_NUMOS, MAX(AB7_ITEM) AB7_ITEM "+CRLF
cQuery += " 		   		FROM "+RetSqlName('AB7')+" B "+CRLF
cQuery += " 		   		WHERE B.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " 		   		GROUP BY AB7_FILIAL, AB7_NUMOS) A ON AB6_FILIAL = A.AB7_FILIAL "+CRLF 
cQuery += " 		 										AND AB7.AB7_NUMOS = A.AB7_NUMOS "+CRLF
cQuery += " 		 										AND AB7.AB7_ITEM = A.AB7_ITEM "+CRLF
 
cQuery += " LEFT JOIN  "+RetSqlName('ABB')+" ABB ON ABB_FILIAL = AB6_FILIAL AND ABB_NUMOS = AB6_NUMOS AND ABB.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " LEFT JOIN  "+RetSqlName('AA1')+" AA1 ON AA1_CODTEC = ABB_CODTEC AND AA1.D_E_L_E_T_ <> '*' "+CRLF  
cQuery += " LEFT JOIN  "+RetSqlName('AB1')+" AB1 ON AB6_FILIAL = AB1_FILIAL AND AB1_NRCHAM = SUBSTRING(AB7_NRCHAM,1,8)  AND AB1.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " LEFT JOIN  "+RetSqlName('SX5')+" SX5A ON SX5A.X5_TABELA = 'A2' AND SX5A.X5_CHAVE = A1_REGIAO AND SX5A.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " LEFT JOIN  "+RetSqlName('SX5')+" SX5B ON SX5B.X5_TABELA = 'A3' AND SX5B.X5_CHAVE = AB6_XCLASS AND SX5B.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " WHERE AB6_FILIAL = '"+xFilial("AB6")+"' "+CRLF
cQuery += " 	AND AB7_TIPO IN ('1','3') "+CRLF// 1=O.S.;2=Pedido Gerado;3=Em Atendimento;4=Atendido;5=Encerrado
If nTipoQry == 1
	cQuery += " 	AND AB6_XDATPR <= '"+sDataPos+"' "+CRLF // Data de ontem
Else 
	cQuery += " 	AND AB6_XDATPR  = '"+sDataPos+"' "+CRLF 
EndIf
cQuery += " 	AND AB7.D_E_L_E_T_ <> '*' "+CRLF
cQuery += " ORDER BY AB7.AB7_NUMOS, AB7.AB7_ITEM, ABB_DTINI DESC "

cQuery := ChangeQuery(cQuery)

Return cQuery



//-------------------------------------------------------------------
/*/{Protheus.doc} fCabHtml
Monta o cabeçalho do HTML

@sample		fCabHtml(cDataPos) 

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fCabHtml( cDataPos ) 

Local cHtml := ""

cHtml += '<html>'+CRLF
cHtml += '<head>'+CRLF
cHtml += '<style>'+CRLF
cHtml += 'body {'+CRLF
cHtml += '    font-family: "Calibri", sans-serif;'+CRLF
cHtml += '}'+CRLF
cHtml += 'table {'+CRLF
cHtml += '    font-family: "Calibri", sans-serif;'+CRLF
cHtml += '    border-collapse: collapse;'+CRLF
cHtml += '    width: 100%;'+CRLF
cHtml += '}'+CRLF
cHtml += 'td, th {'+CRLF
cHtml += '    border: 1px solid #dddddd;'+CRLF
cHtml += '    text-align: left;'+CRLF
cHtml += '    padding: 8px;'+CRLF
cHtml += '}'+CRLF
cHtml += 'tr:nth-child(even) {'+CRLF
cHtml += '    background-color: #dddddd;'+CRLF
cHtml += '}'+CRLF
cHtml += '</style>'+CRLF
cHtml += '</head>'+CRLF
cHtml += '<body>'+CRLF    
cHtml += '<h2>ORDENS DE SERVIÇO - STATUS ABERTO - '+cDataPos+'</h2>'+CRLF 

Return cHtml


//-------------------------------------------------------------------
/*/{Protheus.doc} fCabTab
Monta o cabeçalho da tabela do HTML

@sample		fCabTab() 

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fCabTab()

Local cCabTab := ""   

cCabTab += '  <tr>'+CRLF
cCabTab += '    <th width="06%" align="left">Num. O.S.</th>'+CRLF
cCabTab += '    <th width="03%" align="left">Cliente</th>'+CRLF
cCabTab += '    <th width="24%" align="left">Nome</th>'+CRLF
cCabTab += '    <th width="05%" align="left">Status OS</th>'+CRLF
cCabTab += '    <th width="10%" align="left">Municipio</th>'+CRLF
cCabTab += '    <th width="02%" align="left">UF</th>'+CRLF
cCabTab += '    <th width="05%" align="left">Região</th>'+CRLF
cCabTab += '    <th width="08%" align="left">Tipo de O.S.</th>'+CRLF
cCabTab += '    <th width="05%" align="left">Dt. Emissão</th>'+CRLF
cCabTab += '    <th width="05%" align="left">Prazo Atendim.</th>'+CRLF
cCabTab += '    <th width="05%" align="left">Dt. Agenda</th>'+CRLF
cCabTab += '    <th width="05%" align="left">Técnico</th>'+CRLF
cCabTab += '    <th width="10%" align="left">Linha de Equipamento</th>'+CRLF
cCabTab += '    <th width="07%" align="left">Aberto por</th>'+CRLF
cCabTab += '  </tr>'+CRLF

Return cCabTab 


//-------------------------------------------------------------------
/*/{Protheus.doc} fRodHtml
Monta o rodapé do HTML

@sample		fRodHtml() 

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fRodHtml() 

Local cHtml := ""

cHtml += '</body>'+CRLF
cHtml += '</html>'+CRLF

Return cHtml     


//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaArq
Grava conteudo do HTML

@sample		fGravaArq( cDirHtm, cArqHtm, cHtml ) 

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fGravaArq( cDirHtm, cArqHtm, cHtml )
 
Local nHandle := 0 

If File( cDirHtm + cArqHtm ) 
	nHandle := fOpen( cDirHtm + cArqHtm, FO_READWRITE+FO_SHARED ) 
Else
	nHandle := FCreate( cDirHtm + cArqHtm ) 
EndIf 

If nHandle == -1   
	Conout("[RTEC007]"+"Não foi possível abrir ou criar o arquivo: " + cArqHtm )			
Else  	
	FSeek(nHandle,0,2)
	FWrite(nHandle, cHtml)   
	FClose(nHandle)
EndIf								
 
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaSX1()
Cria as perguntas do SX1

@sample		fCriaSX1(cPerg)

@author		Alessandro Smaha
@since		23/01/2017
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fCriaSX1(cPerg)    

Local aHelpPor01 := {"Informe a data para consultar","ordens de serviço em atraso,","de hoje e de amanhã.","Será enviado por e-mail (ST_OSEMAIL)."}

PutSX1(cPerg, "01", "Database", "", "", "MV_CH1", "D", 06,  0, 0, "G", "", ""   , "", "", "MV_PAR01",,,,"",,,,,,,,,,,,,aHelpPor01)

Return
