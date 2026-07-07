//-----------------------------------------------------------
//Verifica se o cadastro do cliente permite venda de serviços
//-----------------------------------------------------------
#include "totvs.ch"

User Function TMKA1003()

Local aArea   := GetArea()
Local cOper   := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_OPER"})]
Local cTpServ := GETMV("MV_TPSERV")

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+UA_CLIENTE+UA_LOJA,.F.))

If cOPer $ cTpServ .AND. SA1->A1_XPNFSER <> "S"
	If IsBlind()
		cLogTxt := "Não é possível emitir NF de serviço para este cliente - [TMKA1003]"
		Conout(cLogTxt)		
	Else
		ShowHelpDlg("Aviso", {"Não é possível emitir NF de serviço para este cliente.",""},5,{"Contate o administrador." ,""},5)
	End
	cOper := "  "
Endif

RestArea(aArea)

Return(cOper)
