//----------------------------------------------------------
//Verifica o estoque do produto digitado no pedido de vendas
//----------------------------------------------------------
#include "totvs.ch"

User Function FATA1002()

Local aArea   := GetArea()
Local cCodigo := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "C6_PRODUTO"})]
Local cLocal  := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "C6_LOCAL"})]
Local nQtdVen := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "C6_QTDVEN"})]

dbSelectArea("SB2")
SB2->(dbSetOrder(1))
SB2->(dbSeek(xFilial("SB2")+cCodigo+cLocal,.F.))

If SALDOSB2() < nQtdVen 
	ShowHelpDlg("Aviso", {"Saldo indisponivel para faturamento.",""},5,{"Verifique as reservas, empenhos e previsão de compras." ,""},5)
Endif

RestArea(aArea)

Return(nQtdVen)
