#INCLUDE "rwmake.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT260TOK()
@ Descri: Ponto de Entrada localizado na confirmação da Dialog na
função A260TudoOK.EM QUE PONTO :  É executada ao pressionar o botão
da EnchoiceBar.FINALIDADE : Validar as informações inseridas pelo
Usuário

@return 	lógico
@author João E. Lopes
@since 12/08/2019
@version P12
/*/
//-------------------------------------------------------------------

User Function MT260TOK()
Local cLoteDigiD	:= PARAMIXB[1]
Local _cDoc         := cDocto
Local cNomeCad      := "MATA260 - Transferência"
Local aCampos 		:= {}
Local lUsrOk   		:= RetCodUsr() $ GETMV("SX_USRTRAN", , "000000" )

Local lRet      	:= .f.
Local cUsrTrf   	:= SuperGetMv('ST_USRTRF',,"999999/")
Local __cMsg    	:= ""

/*
// VARIAVEIS DISPONIVEIS
//cCodOrig
//cLocOrig
//cCodDest
//cLocDest
//nQuant260
//cDocto

If !lUsrOk

	// Mesmo os usuário tendo permissao para transferência, não poderá executar se o Armazém de origem for 80.
	If alltrim(cLocOrig) == "80"
		MsgAlert("Não é possivel realizar transferência de estoque cujo o local de origem é "+ALLTRIM(cLocOrig)+" !","AMZORIG-MA260LINB")
		lRet := .F.
	EndIf

	// Coferi se Produto de origem e destino são diferente.
	If (alltrim(cCodOrig) <> alltrim(cCodDest)) 

		// Se usuário estiver permitido a realizar transferência no parâmetro ST_XUSRTRO e Codigo de origem e destino for diferente, permite a transferência.
		If  !(__CUserId $ ALLTRIM(GETMV("ST_XUSRTRF")))
			MsgAlert("Produto de origem: "+alltrim(cCodOrig)+" diferente do produto de destino: " +alltrim(cCodDest)+", transferência não permitida para usuário: "+__CUserId+"!","PRODDIF-MA261LINC")
			lRet := .F.
		EndIf
		
	EndIf

EndIf

//If lRet
//	AAdd(aCampos,{cCodOrig,cCodDest,cLocOrig,cLocDest,nQuant260})
//	EnvMtrf()
//Endif
*/


If !IsBlind()
    If __cUserId $  cUsrTrf
        	lRet := .T.
        
		Else
			Conout("")
			MsgAlert("Transferencia nao autorizada", "Sentax")
    EndIf
EndIf

 __cMsg    := FunName() + " - " + cNomeCad + " - " + __cUserId + " - " + UsrRetName(__cUserID)
U_MailTo("contabilidade@sentax.com.br",  "BLOQUEIO DE TRANSFERENCIAS ", "", "", __cMsg,,"contabilidade@sentax.com.br")

Return lRet

//--------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function EnvMtrf(_cDoc,cNomeCad,aCampos)

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
local lIncl		:= .T.
local cInf		:= ""
local cTitulo	:= ""
local cCombo	:= ""
local cCab		:= ""
local cStr 	    := '' //alltrim(GetMV("MV_AVALTB1"))
local cAux		:= ""
local nCont  	:= 0
local nX		:= 1
local cCBlq     := ""
local cCab := "Transferência"

cAssunto := "Transferência de Produtos - Estoque - " + GetEnvServer()

cAssunto += " - " + _cDoc
//cDescri  := cProd

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

If !Inclui
	cHtml += "<b>Atenção!</b>"
	cHtml += "<br><br>"
	cHtml += "Usuário(a) <b>"+ alltrim(substr(cUserName,1,15)) +"</b> realizou a seguinte transferência abaixo:"
	cHtml += "<br><br>"
	cHtml += "<table width='930' cellpadding='2' cellspacing='1' border='0'>"
	cHtml += "<tr>"
	cHtml += "<td><b>Empresa/Filial</b></td>"
	cHtml += "<td><b>Tabela-Nome</b></td>"
	cHtml += "<td><b>"+ cCab +"</b></td> "
	
	
	cHtml += "<td><b>Nome</b></td>"
	cHtml += "</tr>"
	cHtml += "<tr>"
	cHtml += "<td>"+ cFilAnt +"</td>"
	cHtml += "<td> SB1 - Produtos </td>"
	cHtml += "<td>"+ _cDoc +"</td>"
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
	
	
	for i := 1 to len(aCampos)
		cCampo := aCampos[i,01]
		dbSelectArea("SX3")
		dbSetOrder(2)
		if dbSeek( cCampo )
			cTitulo	:= X3Titulo()
			cCombo	:= X3CBOX()
		endif
		
		if valtype(aCampos[i,2]) == "N"
			cCmpAnt := transform(aCampos[i,2],X3Picture(cCampo))
			cCmpAlt := transform(aCampos[i,3],X3Picture(cCampo))
		elseif valtype(aCampos[i,2]) == "D"
			cCmpAnt := substr(dtos(aCampos[i,2]),7,2) +"/"+ substr(dtos(aCampos[i,2]),5,2) +"/"+ substr(dtos(aCampos[i,2]),1,4)
			cCmpAlt := substr(dtos(aCampos[i,3]),7,2) +"/"+ substr(dtos(aCampos[i,3]),5,2) +"/"+ substr(dtos(aCampos[i,3]),1,4)
		elseif valtype(aCampos[i,2]) == "C"
			cCmpAnt := iif(empty(X3Picture(cCampo)),aCampos[i,2],transform(aCampos[i,2],X3Picture(cCampo)))
			cCmpAlt := iif(empty(X3Picture(cCampo)),aCampos[i,3],transform(aCampos[i,3],X3Picture(cCampo)))
		endif
		
		cHtml += "<tr>"
		cHtml += "<td>"+ aCampos[i,1] +" / "+ cTitulo +"</td>"
		cHtml += "<td>"+ cCmpAnt +"</td>"
		cHtml += "<td>"+ cCmpAlt + iif(empty(cCombo),""," - ["+ alltrim(cCombo) +"]") +"</td>"
		cHtml += "</tr>"
	next i
	
	cHtml += "</table>"
	
	if __lBloq
		cHtml += "<td><b>Conforme determinação interna, esse cadastro será bloqueado!</b></td>"
	endif
	
	cHtml += "</body>"
	cHtml += "</html>"
else
	if lIncl == .T.
		cHtml += "<b>Atenção!</b>"
		cHtml += "<br><br>"
		cHtml += "UsuÃ¡rio(a) <b>"+ alltrim(substr(cUserName,1,15)) +"</b> incluiu o cadastro abaixo e precisa ser homologado:"
		cHtml += "<br><br>"
		cHtml += "<table width='930' cellpadding='2' cellspacing='1' border='0'>"
		cHtml += "<tr>"
		cHtml += "<td><b>Empresa/Filial</b></td> "
		cHtml += "<td><b>Tabela-Nome</b></td>"
		cHtml += "<td><b>"+ cCab +"</b></td> "
		
		
		cHtml += "<td><b>Nome</b></td>"
		cHtml += "</tr>"
		cHtml += "<tr>"
		cHtml += "<td>"+ cFilAnt +"</td> "
		cHtml += "<td> SB1 - Produtos </td>"
		cHtml += "<td>"+ _cDoc +"</td>"
		cHtml += "<td>"+ cNomeCad +"</td>"
		cHtml += "</tr>"
		cHtml += "</table>"
		cHtml += "</body>"
		cHtml += "</html>"
	endif
endif


cMensagem := cHtml
cAttach	  := ''
// remove :587 porta que teve q ser fixada no parametro.
cServer   := strtran(cServer,":587","")

if lIncl
	
	oMail := tMailManager():New()
	nRet  := 0
	
	oMail:Init("",cServer,cAccount,cPassword,,587)
	oMail:SetSMTPTimeout(60)
	
	nRet := oMail:SMTPConnect()
	nRet := oMail:SMTPAuth(cAccount, cPassword)
	
	if nRet != 0
		//MsgStop(oMail:GetErrorString(nRet))
		MsgStop("Não foi possivel enviar e-mail de transferência de Estoque: "+ oMail:GetErrorString(nRet))
		return
	endif
	
	nRet := oMail:SendMail(cRemet,cDest,cAssunto,cMensagem,"",cRemet,{},0)
	
	if nRet != 0
		MsgStop(oMail:GetErrorString(nRet))
	endif
	
	oMail:SMTPDisconnect()
endif


RestArea(aArea)



Return
