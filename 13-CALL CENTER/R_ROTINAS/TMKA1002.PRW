//-----------------------------------------------------------------------------------------------------------
//Ao pressionar F4 a rotina mostra a posição do estoque do produto semelhante a utilizada no pedido de vendas
//-----------------------------------------------------------------------------------------------------------
#include "protheus.ch"

User Function TMKA1002()

Local aArea  := GetArea()
Local nItem  := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_QUANT"})]
Local cCampo := AllTrim(Upper(ReadVar()))

SetKey(VK_F4,{||MaViewSB2(GdFieldGet("UB_PRODUTO"),,GdFieldGet("UB_LOCAL"))})

RestArea(aArea)

Return(nItem)
