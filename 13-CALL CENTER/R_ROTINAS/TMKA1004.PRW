//--------------------------------------------------------------------------------------------------
//Grava no campo do usuário o estoque do produto quando digitado o código no atendimento call center
//--------------------------------------------------------------------------------------------------
#include "totvs.ch"

User Function TMKA1004()

Local aArea   := GetArea()
Local cCodigo := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_PRODUTO"})]
Local cLocal  := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_LOCAL"})]
Local nSaldo  := 0

If Empty(cLocal)
	cLocal := Posicione("SB1",1,xFilial("SB1")+cCodigo,"B1_LOCAL")
Endif

DbSelectArea("SB2")
SB2->(dbSetOrder(1))
SB2->(DbGoTop())
If SB2->(dbSeek(xFilial("SB2")+cCodigo+cLocal,.F.))
		nSaldo := SaldoMov() //SALDOSB2()  MV_TPSALDO = 'C'

	Else 
		If IsBlind()
			cLogTxt := "Saldo inexistente para faturamento. Verifique saldo inicial(SALDO). - [TMKA1004]"
			Conout(cLogTxt)		
		Else
			ShowHelpDlg("Aviso", {"Saldo inexistente para faturamento.",""},5,{"Verifique saldo inicial(SALDO)." ,""},5)
		End
		nSaldo := 0
EndIf  

RestArea(aArea)

Return(nSaldo)
