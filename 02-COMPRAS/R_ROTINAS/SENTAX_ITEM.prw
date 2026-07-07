#Include 'totvs.ch'
#Include 'FWMVCDEF.ch'
Static __lBloq := .F.



//-------------------------------------------------------------------
/*/{Protheus.doc} ITEM
PE MVC para cadastro de produto MATA010
@author		Thiago Henrique dos Santos
@since		12/07/2019
@version	P12

30227967RL                    
/*/
User Function Item()
Local aParam 		:= PARAMIXB
Local xRet 			:= .T.
Local oObj 			:= ""
Local cIdPonto 		:= ""
Local cIdModel 		:= ""
Local oModel
Local nOperation  
Local cUsrblq		:=Alltrim(supergetmv('ST_USRBLOQ',.f.,'000070/000217/000240' ))
Local cCampBloq		:=Alltrim(supergetmv('MV_CAMPWF',.f.,'B1_SELLOUT/B1_EMIN ' ))
Local lBloqsb1 		:= .F.
Local nX
Local aCampos 		:= {}
Local  nI 			:= 1

If aParam <> NIL
	oObj := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]  
	oModel 	   := oObj:GetModel()
	nOperation := oModel:GetOperation()
	
	If cIdPonto == "MODELPRE" 
		__lBloq := .F.
	
	ElseIf cIdPonto == "MODELPOS" .and. !(__lBloq)       
	
		If nOperation == MODEL_OPERATION_INSERT                 
			__lBloq := .T.      

			EnvMail(.T.,Alltrim(oModel:GetValue("SB1MASTER","B1_COD")),Alltrim(oModel:GetValue("SB1MASTER","B1_DESC")),aCampos)

		ElseIF nOperation == MODEL_OPERATION_UPDATE     
			oStrusSB1 := FWFormStruct( 1, 'SB1'  )  
			oStrusSB5 := FWFormStruct( 1, 'SB5'  )  
			oStrusSBZ := FWFormStruct( 1, 'SBZ'  )  
			
			if(Valtype(oModel:GetModel("SB1MASTER"))!= "U")     
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				if SB1->(DbSeek(xFilial("SB1")+oModel:GetValue("SB1MASTER","B1_COD")))
					
					For nX := 1 to Len(oStrusSB1:aFields)
						
						If !(Alltrim(oStrusSB1:aFields[nX][3]) == "B1_CODBAR") //08-11-2021 - Kleber pediu para por enquanto desconsiderar o campo de cod bar
							
							If  !(oModel:GetValue("SB1MASTER",oStrusSB1:aFields[nX][3]) == SB1->&(oStrusSB1:aFields[nX][3]))   
								
								AAdd(aCampos,{oStrusSB1:aFields[nX][3],SB1->&(oStrusSB1:aFields[nX][3]),oModel:GetValue("SB1MASTER",oStrusSB1:aFields[nX][3])})
								if (Alltrim(oStrusSB1:aFields[nX][3]) $ cCampBloq) .and. !lBloqsb1  
									__lBloq := .F.
								Else 
									__lBloq  := .T.
									lBloqsb1 := .T.
								Endif 
				
							EndIf

						EndIf

					Next nX

				Endif 
			Endif 
			
			if (Valtype(oModel:GetModel("SB5DETAIL"))!= "U") 
				DbSelectArea("SB5")
				SB5->(DbSetOrder(1))
				if SB5->(DbSeek(xFilial("SB5")+oModel:GetValue("SB1MASTER","B1_COD")))
					For nX := 1 to Len(oStrusSB5:aFields)
						If !(Alltrim(oStrusSB5:aFields[nX][3]) $ "B5_COD") .and. !(oModel:GetValue("SB5DETAIL",oStrusSB5:aFields[nX][3]) == SB5->&(oStrusSB5:aFields[nX][3]))    
							AAdd(aCampos,{oStrusSB5:aFields[nX][3],SB5->&(oStrusSB5:aFields[nX][3]),oModel:GetValue("SB5DETAIL",oStrusSB5:aFields[nX][3])})
							__lBloq := .T.
						EndIf				
					Next nX
				Endif 
			Endif  
			
			if (Valtype(oModel:GetModel("SBZDETAIL"))!= "U")
				DbSelectArea("SBZ")
				SBZ->(DbSetOrder(1))
				
				For nI := 1 To oModel:GetModel("SBZDETAIL"):Length()
					if oModel:GetModel("SBZDETAIL"):GoLine( nI ) .AND. !oModel:GetModel("SBZDETAIL"):IsDeleted()
						if SBZ->(DbSeek(oModel:GetValue("SBZDETAIL","BZ_FILIAL")+oModel:GetValue("SB1MASTER","B1_COD")))								
							For nX := 1 to Len(oStrusSBZ:aFields)									
								If !(Alltrim(oStrusSBZ:aFields[nX][3]) $ "BZ_COD/BZ_FILIAL/BZ_XBLOQ/BZ_XDESC") .and. !(oModel:GetValue("SBZDETAIL",oStrusSBZ:aFields[nX][3]) == SBZ->&(oStrusSBZ:aFields[nX][3])) 
									AAdd(aCampos,{oStrusSBZ:aFields[nX][3],SBZ->&(oStrusSBZ:aFields[nX][3]),oModel:GetValue("SBZDETAIL",oStrusSBZ:aFields[nX][3])})
								
									if !(Alltrim(oStrusSBZ:aFields[nX][3]) $ "BZ_EMIN")
										__lBloq := .T.
									Endif
								EndIf				
							Next nX
						Endif
					Endif
				Next nI 
			Endif
				if !Empty(aCampos)
					EnvMail(.F.,Alltrim(oModel:GetValue("SB1MASTER","B1_COD")),Alltrim(oModel:GetValue("SB1MASTER","B1_DESC")),aCampos)
				Endif
		Endif
		

	ElseIf cIdPonto == "MODELCOMMITTTS" .and. __lBloq
		if !(Alltrim(__cUserID) $ cUsrblq)
			RecLock("SB1",.F.)
			SB1->B1_MSBLQL := "1"
			SB1->(MsUnlock())
		Endif
	
	Endif  
Endif



Return xRet


Static Function EnvMail(lInclui,cProd,cNomeCad,aCampos)

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
local cCab := "Código"




cAssunto := "Produto - "+ iif(!lInclui,"Altera&cent;&atilde;o - ","Homologa&cent;&atilde;o - ") + GetEnvServer()





cAssunto += " - " + cProd
cDescri  := cProd

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
	cHtml += "Usuário(a) <b>"+ alltrim(substr(cUserName,1,15)) +"</b> alterou os seguintes campos do cadastro abaixo:"
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
	cHtml += "<td>"+ cProd +"</td>"				
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
		cHtml += "<td>"+ cProd +"</td>"				
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


	oMail := TMailManager():New()
	oMail:SetUseTLS(.T.)
	oMail:SetUseSSL(.f.)
	oMail:Init( '', cServer , cAccount, cPassword, 0, 587  )
	oMail:SetSmtpTimeOut( 120 )
	nRet := oMail:SmtpConnect()
	IF lAuth     
		nErro := oMail:SmtpAuth(cAccount ,cPassword)
		If nErro <> 0
			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')') //"Erro de Autenticacao "
			lRet := .F.
		Endif
	eNDIf


	if nRet != 0
		//MsgStop(oMail:GetErrorString(nRet))
		MsgStop("Não foi possivel enviar e-mail de Alteração de Cadastro: "+ oMail:GetErrorString(nRet))
		return
	endif

	If Alltrim(cRemet) == "ecommerce@sentax.com.br"
		cRemet := "sistema.erp@gruposentax.com.br"
	End
	
	//nRet := oMail:SendMail(cRemet,cDest,cAssunto,cMensagem,"",cRemet,{},0)
	nRet := oMail:SendMail(cRemet,cDest,cAssunto,cMensagem,"","",{},0)
	
	if nRet != 0
		MsgStop(oMail:GetErrorString(nRet))
	endif
	
	oMail:SMTPDisconnect()
endif


RestArea(aArea)



Return
