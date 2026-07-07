//--------------------------------------------------------------------------------------------------------------
//Verifica e avisa ao usuário quando o produto digitado no atendimento call center não possui estoque disponível
//--------------------------------------------------------------------------------------------------------------
#include "totvs.ch"

User Function TMKA1001()

Local aArea   := GetArea()
Local cCodigo := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_PRODUTO"})]
Local cLocal  := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_LOCAL"})]
Local nQtdVen := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_QUANT"})]

DBSelectArea("SB2")
SB2->(dbSetOrder(1))
SB2->(DbGoTop())
If SB2->(dbSeek(xFilial("SB2")+cCodigo+cLocal,.F.))
		If SaldoMov() < nQtdVen  //SALDOSB2()
		    If IsBlind()
				cLogTxt := "Saldo indisponivel para faturamento. Verifique as reservas, empenhos e previsão de compras. - [TMKA1001]"
				Conout(cLogTxt)		
			Else
				ShowHelpDlg("Aviso", {"Saldo indisponivel para faturamento.",""},5,{"Verifique as reservas, empenhos e previsão de compras." ,""},5)
			End
		Endif

	Else 
		If IsBlind()
			cLogTxt := "Saldo inexistente para faturamento. Verifique saldo inicial. - [TMKA1001]"
			Conout(cLogTxt)		
		Else
			ShowHelpDlg("Aviso", {"Saldo inexistente para faturamento.",""},5,{"Verifique saldo inicial." ,""},5)
		End
		nQtdVen := 0
EndIf 

RestArea(aArea)
Return(nQtdVen)
