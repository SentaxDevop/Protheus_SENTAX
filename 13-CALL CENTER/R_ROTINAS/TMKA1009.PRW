//--------------------------------------------------------------------------------------------------
//Não permite cadastrar telefone com "-" 
//solicitado pela Sra. Denise e Sra. Andreia Comerial
//--------------------------------------------------------------------------------------------------
#include "totvs.ch"

User Function  TMKA1009(cConteudo)
Local lRet	:= .T.											

IF "-" $ cConteudo 
	If IsBlind()
		cLogTxt := "Não é permitido colocar hífen '-' no cadastro do telefone - [TMKA1009]"
		Conout(cLogTxt)		
	Else                                                                  
		MSGALERT("Não é permitido colocar hífen '-' no cadastro do telefone")
	End
	lRet := .F.
ENDIF

Return lRet
