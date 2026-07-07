#include 'protheus.ch'
#include 'totvs.ch'
#include 'ap5mail.ch'

static cBlq := ''
/*/{Protheus.doc} MCOM004
Workflow de campos alterados no cadastro de Clientes, Fornecedores, Produtos
e Tipo Entrada/Saída.

@author		dirlei@afsouza
@since		08/05/2019
@version	P12

@return		nil, nenhum

@type		function
/*/
user function MCOM004()
local aArea	 	:= GetArea()
local cDestInf	:= ""
local cDestObs	:= ""
local cDest     := SuperGetMV('ST_WFCAD',.f.,'contabilidade@sentax.com.br')
local lAuth     := GetMV("MV_RELAUTH")
local cServer	:= GetMV("MV_RELSERV")
local cAccount	:= GetMV("MV_RELACNT")
local cRemet 	:= GetMV("MV_RELACNT")
local cPassword	:= GetMV("MV_RELPSW")
local cMensagem	:= ""
local cAssunto	:= ""
local oMail     := nil
local lAltera	:= .F.
local aCAlt		:= {}
local cTab		:= ""
local cTbName	:= ""
local nPos		:= 0
local cCmpBlq	:= ""
local cCmpInf	:= ""
local cCmpAlt	:= ""
local cCmpAnt	:= ""
local cCampo	:= ""
local cCod		:= ""
local cLoj		:= ""
local cProd		:= ""
local cTes		:= ""
local cNomeCad	:= ""
local lIncl		:= .T.
local cInf		:= ""
local cTitulo	:= ""
local cCombo	:= ""
local cCab		:= ""
local cStr 	    := '' //Alltrim(GetMV("MV_AVALTB1"))
local cAux		:= ""
local nCont  	:= 0
local nX		:= 1
local cCBlq     := ""
Local i 		:= 1
Local _cDescri	:= ""

/*
If IsInCallStack("CRMA980")
	Return
EndIf
*/
If INCLUI .or. ALTERA

	If ALTERA
		If FUNNAME() == "MATA020"
			cTab     := "SA2"
			cCod     := "SA2->A2_COD"
			cLoj     := "SA2->A2_LOJA"
			cTbName  := "Fornecedor"
			nPos     := 3
			cNomeCad := SA2->A2_NOME
			lAltera  := .T.
			cCBlq    := "A2_MSBLQL "
			//cCmpBlq  := Formula("BA2")
			//cDest    := GetMV("MV_AVALTA2")
		
		ElseIf FUNNAME() == "MATA030" .or. FunName() == 'TMKA271' .or. FunName() == 'TMKA350' .or. ( Alltrim(FunName()) == 'RPC' .AND. 'A1_' $ Alltrim(READVAR()) )
			cTab     := "SA1"
			cCod     := "SA1->A1_COD"
			cLoj     := "SA1->A1_LOJA"
			cTbName  := "Cliente"
			nPos     := 3
			cNomeCad := SA1->A1_NOME
			lAltera  := .T.
			cCBlq    := "A1_MSBLQL "
			//cCmpBlq  := Formula("BA1")
			cBlq     := SA1->A1_MSBLQL
			//cDest    := GetMV("MV_AVALTA1")
		
		ElseIf FUNNAME() == "MATA010"
			cTab     := "SB1"
			cProd    := "SB1->B1_COD"
			cTbName  := "Produto"
			nPos     := 5
			cNomeCad := SB1->B1_DESC
			lAltera  := .T.
			cCBlq    := "B1_MSBLQL"
			//cCmpBlq  := Formula("BB1")
			//cCmpInf  := Formula("IB1")
			//cDest    := GetMV("MV_AVALTB1")

			for nX:= 1 to len(cStr)
				If(substr(cStr,nX,1)) <> ';'
					cAux += substr(cStr,nX,1)
					nCont++
				EndIf
				If nCont == 6
					If !empty(Alltrim(UsrRetMail(cAux)))
						cDest += Alltrim(UsrRetMail(cAux))+";"
					EndIf
					nCont := 0
					cAux  := ""
				EndIf
			next
			// cDest está com os emails dos codigos de usuarios preenchido no parametro MV_AVALTB1
			//cDestInf := GetMV("MV_AVINFB1")
			//cDestObs := GetMV("MV_AVOBSB1")

		ElseIf FUNNAME() == "MATA080"
			cTab	 := "SF4"
			cTes	 := "SF4->F4_CODIGO"
			cTbName	 := "TES"
			nPos	 := 6
			cNomeCad := SF4->F4_TEXTO
			lAltera  := .T.
			cCBlq    := "F4_MSBLQL"
			//cCmpBlq  := Formula("BF4")
			//cDest    := GetMV("MV_AVALTF4")

		ElseIf FUNNAME() == "GPEA040"
			cTab     := "SRV"
			cVerba   := "M->RV_COD"
			cTbName  := "Verbas"
			nPos     := 7
			cNomeCad := M->RV_DESC
			lAltera  := .T.
			cCBlq    := "RV_MSBLQL "
			//cCmpBlq  := Formula("BRV")
			//cDest    := GetMV("MV_AVALTRV")

		ElseIf FUNNAME() == "GPEA010"
			cTab	 := "SRA"
			cMat	 := "M->RA_MAT"
			cTbName	 := "Funcionario"
			nPos	 := 8
			cNomeCad := M->RA_NOME
			lAltera  := .T.
			cCBlq    := "RA_MSBLQL "
			//cCmpBlq  := Formula("BRA")
			//cDest    := GetMV("MV_AVALTRA")

		ElseIf FUNNAME() == "MATA089"
			cTab     := "SFM"
			cCab     := Alltrim(RetTitle("FM_FILIAL")) +' | '+ Alltrim(RetTitle("FM_TIPO")) +' | '+ Alltrim(RetTitle("FM_TE")) +' | '+ Alltrim(RetTitle("FM_TS")) +' | '+ Alltrim(RetTitle("FM_EST"))
			cTesI    := "M->(FM_FILIAL +' | '+ FM_TIPO +' | '+ FM_TE +' | '+ FM_TS +' | '+ FM_EST)"
			cTbName  := "Tes Inteligente"
			nPos     := 9
			cNomeCad := M->FM_TIPO
			lAltera  := .T.
			cCBlq    := "FM_MSBLQL "
			//cCmpBlq  := Formula("BFM")
			//cDest    := GetMV("MV_AVALTFM")

		EndIf
	
	ElseIf INCLUI
		If FUNNAME() == "MATA020"
			cTab     := "SA2"
			cCod     := "M->A2_COD"
			cLoj     := "M->A2_LOJA"
			cTbName  := "Fornecedor"
			nPos     := 3
			cNomeCad := M->A2_NOME
			lAltera  := .F.
			cCBlq    := "A2_MSBLQL "
			//cCmpBlq  := Formula("BA2")
			//cDest    := GetMV("MV_AVINCA2")

		//ElseIf FUNNAME() == "MATA030" .or. FunName() == 'TMKA271' .or. ( Alltrim(FunName()) == 'RPC' .AND. 'A1_' $ Alltrim(READVAR()) )
		ElseIf FUNNAME() == "CRMA980" .or. FunName() == 'TMKA271' .or. ( Alltrim(FunName()) == 'RPC' .AND. 'A1_' $ Alltrim(READVAR()) )
			lIncl    := iIf(type("M->A1_COD")=="U",.F.,.T.)
			cTab     := "SA1"
			cCod     := "M->A1_COD"
			cLoj     := "M->A1_LOJA"
			cTbName  := "Cliente"
			nPos     := 3
			cNomeCad := iIf(lIncl,M->A1_NOME,"")
			lAltera  := .F.
			cCBlq    := "A1_MSBLQL "
			//cCmpBlq  := Formula("BA1")
			//cDest    := GetMV("MV_AVINCA1")
			//cBlq	   		:= M->A1_MSBLQL
			If Alltrim(FunName()) == 'RPC' 
				M->A1_MSBLQL := "2"
			EndIf

		ElseIf FUNNAME() == "MATA010"
			cTab     := "SB1"
			cProd    := "M->B1_COD"
			cTbName  := "Produto"
			nPos     := 5
			cNomeCad := M->B1_DESC
			lAltera  := .F.
			cCBlq    := "B1_MSBLQL "
			//cCmpBlq  := Formula("BB1")
			//cDest    := GetMV("MV_AVINCB1")
			//cDestInf := GetMV("MV_AVINFB1")
			cInf	 := "1"

		ElseIf FUNNAME() == "MATA080"
			cTab     := "SF4"
			cTes     := "M->F4_CODIGO"
			cTbName  := "TES"
			nPos     := 6
			cNomeCad := M->F4_TEXTO
			lAltera  := .F.
			cCBlq    := "F4_MSBLQL "
			//cCmpBlq  := Formula("BF4")
			//cDest    := GetMV("MV_AVINCF4")

		ElseIf FUNNAME() == "GPEA040"
			cTab     := "SRV"
			cVerba   := "M->RV_COD"
			cTbName  := "Verbas"
			nPos     := 7
			cNomeCad := M->RV_DESC
			lAltera  := .F.
			cCBlq    := "RV_MSBLQL "
			//cCmpBlq  := Formula("BRV")
			//cDest    := GetMV("MV_AVINCRV")

		ElseIf FUNNAME() == "GPEA010"
			cTab     := "SRA"
			cMat     := "M->RA_MAT"
			cTbName  := "Funcionario"
			nPos     := 8
			cNomeCad := M->RA_NOME
			lAltera  := .F.
			cCBlq    := "RA_MSBLQL "
			//cCmpBlq  := Formula("BRA")
			//cDest    := GetMV("MV_AVALTRA")

		ElseIf FUNNAME() == "MATA089"
			cTab     := "SFM"
			cCab     := Alltrim(RetTitle("FM_FILIAL")) +' | '+ Alltrim(RetTitle("FM_TIPO")) +' | '+ Alltrim(RetTitle("FM_TE")) +' | '+ Alltrim(RetTitle("FM_TS")) +' | '+ Alltrim(RetTitle("FM_EST"))
			cTesI    := "M->(FM_FILIAL +' | '+ FM_TIPO +' | '+ FM_TE +' | '+ FM_TS +' | '+ FM_EST)"
			cTbName  := "Tes Inteligente"
			nPos     := 9
			cNomeCad := M->FM_TIPO
			lAltera  := .F.
			cCBlq    := "FM_MSBLQL"
			//cCmpBlq  := Formula("BFM")
			//cDest    := GetMv("MV_AVINCFM")
			
		EndIf

	EndIf

	//Encerra rotina pq a chamada ocorreu por função não maepada 
	If Empty(cTbName)
		Return
	End

	cAssunto := cTbName + " - "+ iIf(ALTERA,"Alteração - ","Homologação - ") + GetEnvServer()

	If empty(Alltrim(cCab))
		cCab := "Código"
	EndIf

	If	nPos == 3
			cAssunto += " - " + &(cCod)
			_cDescri  := &(cCod)
		
		ElseIf nPos == 5
			cAssunto += " - " + &(cProd)
			_cDescri  := &(cProd)
		
		ElseIf nPos == 6
			cAssunto += " - " + &(cTes)
			_cDescri  := &(cTes)
		
		ElseIf nPos	== 7
			cAssunto += " - " + &(cVerba)
			_cDescri  := &(cVerba)
		
		ElseIf nPos	== 8
			cAssunto += " - "+ cFilAnt +"/"+ &(cMat)
			_cDescri  := &(cMat)
		
		ElseIf nPos	== 9
			cAssunto += " - " + &(cTesI)
			_cDescri  := &(cTesI)
	EndIf

	cHtml := ""
	cHtml += "<html>"
	cHtml += "<head>"
	cHtml += "<title>"+ cAssunto +"</title>"
	cHtml += "<style type='text/css'>"
	cHtml += "body {"
	cHtml += "color: #000000;"
	cHtml += "font-family: Verdana;"
	cHtml += "font-size: 12px;"
	cHtml += "}"
	cHtml += "table {"
	cHtml += "color: #000000;"
	cHtml += "font-family: Verdana;"
	cHtml += "font-size: 12px;"
	cHtml += "}"
	cHtml += "</style>"
	cHtml += "</head>"
	cHtml += "<body>"
	cHtml += "<br>"

	If lAltera
		cHtml += "<b>Atenção!</b>"
		cHtml += "<br><br>"
		cHtml += "Usuário(a) <b>"+ Alltrim(substr(cUserName,1,15)) +"</b> alterou os seguintes campos do cadastro abaixo:"
		cHtml += "<br><br>"
		cHtml += "<table width='930' cellpadding='2' cellspacing='1' border='0'>"
		cHtml += "<tr>"
		cHtml += "<td><b>Empresa/Filial</b></td>"
		cHtml += "<td><b>Tabela-Nome</b></td>"
		cHtml += "<td><b>"+ cCab +"</b></td> "

		If !empty(Alltrim(cLoj))
			cHtml += "<td><b>Loja</b></td>"
		EndIf

		cHtml += "<td><b>Nome</b></td>"
		cHtml += "</tr>"
		cHtml += "<tr>"
		cHtml += "<td>"+ cFilAnt +"</td>"
		cHtml += "<td>"+ cTab +" - "+ cTbName +"</td>"
		cHtml += "<td>"+ _cDescri +"</td>"

		If !empty(Alltrim(cLoj))
			cHtml += "<td>"+ iIf(empty(cLoj),"",&(cLoj)) +"</td>"
		EndIf

		cHtml += "<td>"+ cNomeCad +"</td>"
		cHtml += "</tr>"
		cHtml += "</table>"
		cHtml += "<br><br>"
		cHtml += "<table width='1730' cellpadding='3' cellspacing='2' border='1'>"
		cHtml += "<tr>"
		cHtml += "<td><b>Campo/Descrição</b></td>"
		cHtml += "<td><b>Conteúdo antes da alteração</b></td> "
		cHtml += "<td><b>Conteúdo após alteração</b></td> "
		cHtml += "</tr>"

		/*
		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(dbSeek(cTab))
		While !SX3->(eof()) .and. (SX3->X3_ARQUIVO == cTab)
			If (X3Uso(SX3->X3_USADO) .and. (SX3->X3_CONTEXT # "V"))				
												
				//If "SF4" $ cTab .and. SF4->F4_CODIGO <> M->F4_CODIGO //VerIfica se desposicionou da SF4
				//	SF4->(DbSeek(cFilAnt + M->F4_CODIGO)) //Posiciona novamente
				//EndIf				
				
				If !(Alltrim(X3_CAMPO) $ "RA_CLVL/RA_ITEM") .OR. (Alltrim(X3_CAMPO) $ "RA_CLVL/RA_ITEM" .and. GetMV("MV_ITMCLVL") == '1') // Incluído para validar a tabela SRA
					If &(cTab+"->"+X3_CAMPO) <> &("M->"+X3_CAMPO)
						
						If Alltrim(X3_CAMPO) $ cCmpBlq
							cBlq := "1"
						EndIf
						
						If Alltrim(X3_CAMPO) $ cCBlq
							cBlq := &("M->"+X3_CAMPO)
						EndIf
						
						If Alltrim(X3_CAMPO) $ cCmpInf
							cInf := "1"
						EndIf
						aadd(aCAlt, {X3_CAMPO,Alltrim(&(cTab+"->"+X3_CAMPO)),Alltrim(&("M->"+X3_CAMPO))}) //3
					EndIf
				EndIf

			EndIf

			SX3->(dbSkip())
		EndDo
		*/
		//Adequação ao dicionario
		cSX3Tmp := GetNextAlias()

		OpenSxs(,,,, cEmpAnt, cSX3Tmp, "SX3", ,.F.)

		If (cSX3Tmp)->(DbSeek(cTab))
			While (cSX3Tmp)->X3_ARQUIVO == cTab .And. !(cSX3Tmp)->(EOF())

				If ((cSX3Tmp)->X3_CONTEXT == "R" .And. (cSX3Tmp)->X3_BROWSE == "S" .And. X3USO((cSX3Tmp)->X3_USADO) .And. cNivel >= (cSX3Tmp)->X3_NIVEL) .Or. ((cTab+"->"+X3_CAMPO) == "SA1->A1_X_PISCA")
					
					If (&(cTab+"->"+X3_CAMPO) <> &("M->"+X3_CAMPO)) .Or. (&("M->"+X3_CAMPO) <> &(cTab+"->"+X3_CAMPO))
						
						If Alltrim(X3_CAMPO) $ cCmpBlq 
							cBlq := "1"
						EndIf
						
						If Alltrim(X3_CAMPO) $ cCBlq
							cBlq := &("M->"+X3_CAMPO)
						EndIf
						
						If Alltrim(X3_CAMPO) $ cCmpInf
							cInf := "1"
						EndIf
						aadd(aCAlt, {X3_CAMPO,Alltrim(&(cTab+"->"+X3_CAMPO)),Alltrim(&("M->"+X3_CAMPO))}) //3
					EndIf

				EndIf

				(cSX3Tmp)->(DbSkip())
			EndDo 

		EndIf 

		If cBlq == '1'
			&("M->"+cCBlq):= cBlq
		EndIf

		for i := 1 to len(aCAlt)
			
			cCampo := aCAlt[i,01]
			
			dbSelectArea("SX3")
			dbSetOrder(2)
			If dbSeek( cCampo )
				cTitulo	:= X3Titulo()
				cCombo	:= X3CBOX()
			EndIf

			If ValType(&("M->"+cCampo)) == "N"
					cCmpAnt := transform(&(cTab+"->"+cCampo),X3Picture(cCampo))
					cCmpAlt := transform(&("M->"+cCampo),X3Picture(cCampo))
				
				ElseIf ValType(&("M->"+cCampo)) == "D"
					cCmpAnt := substr(dtos(&(cTab+"->"+cCampo)),7,2) +"/"+ substr(dtos(&(cTab+"->"+cCampo)),5,2) +"/"+ substr(dtos(&(cTab+"->"+cCampo)),1,4)
					cCmpAlt := substr(dtos(&("M->"+cCampo)),7,2) +"/"+ substr(dtos(&("M->"+cCampo)),5,2) +"/"+ substr(dtos(&("M->"+cCampo)),1,4)
				
				ElseIf ValType(&("M->"+cCampo)) == "C"
					cCmpAnt := iIf(empty(X3Picture(cCampo)),&(cTab+"->"+cCampo),transform(&(cTab+"->"+cCampo),X3Picture(cCampo)))
					cCmpAlt := iIf(empty(X3Picture(cCampo)),&("M->"+cCampo),transform(&("M->"+cCampo),X3Picture(cCampo)))
			EndIf

			If Alltrim(cCmpAlt) == "PO"
				cDest := cDest //+ ";" + cDestObs
			EndIf

			cHtml += "<tr>"
			cHtml += "<td>"+ aCAlt[i,01] +" / "+ cTitulo +"</td>"
			cHtml += "<td>"+ cCmpAnt +"</td>"
			cHtml += "<td>"+ cCmpAlt + iIf(empty(cCombo),""," - ["+ Alltrim(cCombo) +"]") +"</td>"
			cHtml += "</tr>"
		next i

		cHtml += "</table>"

		If cBlq == "1"
			cHtml += "<td><b>Conforme determinação interna, esse cadastro será bloqueado!</b></td>"
		EndIf

		cHtml += "</body>"
		cHtml += "</html>"

	else
		If lIncl == .T.
			cHtml += "<b>Atenção!</b>"
			cHtml += "<br><br>"
			cHtml += "Usuário(a) <b>"+ Alltrim(substr(cUserName,1,15)) +"</b> incluiu o cadastro abaixo e precisa ser homologado:"
			cHtml += "<br><br>"
			cHtml += "<table width='930' cellpadding='2' cellspacing='1' border='0'>"
			cHtml += "<tr>"
			cHtml += "<td><b>Empresa/Filial</b></td> "
			cHtml += "<td><b>Tabela-Nome</b></td>"
			cHtml += "<td><b>"+ cCab +"</b></td> "

			If !empty(Alltrim(cLoj))
				cHtml += "<td><b>Loja</b></td>"
			EndIf

			cHtml += "<td><b>Nome</b></td>"
			cHtml += "</tr>"
			cHtml += "<tr>"
			cHtml += "<td>"+ cFilAnt +"</td> "
			cHtml += "<td>"+ cTab +" - "+ cTbName +"</td>"
			cHtml += "<td>"+ _cDescri +"</td>"

			If !empty(Alltrim(cLoj))
				cHtml += "<td>"+ iIf(empty(cLoj),"",&(cLoj)) +"</td>"
			EndIf

			cHtml += "<td>"+ cNomeCad +"</td>"
			cHtml += "</tr>"
			cHtml += "</table>"
			cHtml += "</body>"
			cHtml += "</html>"
		EndIf
	EndIf

	If cInf == "1"
		cDest := cDest //+';'+ cDestInf
	EndIf

	If Len(aCAlt) < 1 .And. lAltera
		Return .t.
	EndIf

	cMensagem := cHtml
	cAttach	  := ''
	// remove :587 porta que teve q ser fixada no parametro.
	cServer   := strtran(cServer,":587","")

	If lIncl
		oMail := TMailManager():New()
		oMail:SetUseTLS(.T.)
		oMail:SetUseSSL(.f.)
		oMail:Init( '', cServer , cAccount, cPassword, 0, 587  )
		oMail:SetSmtpTimeOut( 120 )
		nRet := oMail:SmtpConnect()
		If lAuth     
			nErro := oMail:SmtpAuth(cAccount ,cPassword)
			If nErro <> 0
				// Recupera erro ...
				cMAilError := oMail:GetErrorString(nErro)
				DEFAULT cMailError := '***UNKNOW***'
				Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')') //"Erro de Autenticacao "
				lRet := .F.
			EndIf
		EndIf


		If nRet != 0
			//MsgStop(oMail:GetErrorString(nRet))
			MsgStop("Não foi possivel enviar e-mail de Alteração de Cadastro: "+ oMail:GetErrorString(nRet))
			return
		EndIf

		If Alltrim(cRemet) == "ecommerce@sentax.com.br"
			cRemet := "sistema.erp@gruposentax.com.br"
		End

		//nRet := oMail:SendMail(cRemet,cDest,cAssunto,cMensagem,"",cRemet,{},0)
		nRet := oMail:SendMail(cRemet,cDest,cAssunto,cMensagem,"","",{},0)
		
		If nRet != 0
			MsgStop(oMail:GetErrorString(nRet))
		EndIf
		
		oMail:SMTPDisconnect()
		// oMail := tMailManager():New()
		// nRet  := 0

		// oMail:Init("",cServer,cAccount,cPassword,,587)
		// oMail:SetSMTPTimeout(60)

		// nRet := oMail:SMTPConnect()
		// nRet := oMail:SMTPAuth(cAccount, cPassword)

		// If nRet != 0
		// 	//MsgStop(oMail:GetErrorString(nRet))
		// 	MsgStop("Não foi possivel enviar e-mail de Alteração de Cadastro: "+ oMail:GetErrorString(nRet))
		// 	return
		// EndIf

		// nRet := oMail:SendMail(cRemet,cDest,cAssunto,cMensagem,"",cRemet,{},0)

		// If nRet != 0
		// 	MsgStop(oMail:GetErrorString(nRet))
		// EndIf

		// oMail:SMTPDisconnect()
	EndIf
EndIf

RestArea(aArea)

return


/*/{Protheus.doc} M030PALT
Bloqueio cadastro Cliente

@author		dirlei@afsouza
@since		08/05/2019
@version	P12

@return		nil, nenhum

@type		function
/*/

/*
user function M030PALT()

local nOpcao := PARAMIXB[1]
local lRet   := .T.

If nOpcao == 1
reclock("SA1", .F.)
SA1->A1_MSBLQL := cBlq
msunlock()
EndIf

return lRet
