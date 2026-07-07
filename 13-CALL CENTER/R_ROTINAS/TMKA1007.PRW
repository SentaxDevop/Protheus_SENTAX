//--------------------------------------------------------------------------------------------------
//Grava no campo d usuário o estoque do produto acionado por ponto de entrada - SUELEN 02/01/14
//--------------------------------------------------------------------------------------------------
#include "totvs.ch"

User Function TMKA1007(cCodigo, cLocal)
Local aArea   := GetArea()
Local nSaldo  := 0

If Empty(cLocal)
	cLocal := Posicione("SB1",1,xFilial("SB1")+cCodigo,"B1_LOCPAD")
Endif

dbSelectArea("SB2")
SB2->(dbSetOrder(1))
SB2->(dbSeek(xFilial("SB2")+cCodigo+cLocal,.F.))

nSaldo := SALDOSB2()

RestArea(aArea)

Return(nSaldo)
