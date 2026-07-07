#include "Protheus.ch"
#include "FWMVCDEF.CH" 
//==================================================================================================//
//	Programa: A261TOK		|	Autor: Luis Paulo							|	Data: 24/05/2022	//
//==================================================================================================//
//	Descrição: PE do cadastro de cliente new														//
//	-																								//
//==================================================================================================//
User Function A261TOK()
Local lRet      := .f.
Local cUsrTrf   := SuperGetMv('ST_USRTRF',,"999999/")
Local __cMsg    := ""
Local cNomeCad  := "MATA261 - Transferência Mult"

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

Return(lRet)
