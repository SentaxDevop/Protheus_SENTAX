#include "totvs.ch"
#include "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} NFA012IP
PE para adicionar informacoes apos a importacao do CT-e.
                
@author		Dirlei@afsouza.com.br
@since		07/02/2019     
@version 	P12

@return		Nil, nenhum
/*/
//-------------------------------------------------------------------
User Function NFA012IP()

Local aArea     := GetArea()
Local cChave    := PARAMIXB[1]
Local cAcabCTE  := AllTrim(GetMV("NF_CABCTE",,""))
Local cAIteCTE  := AllTrim(GetMV("NF_ITECTE",,""))
Local cPrdPedg  := AllTrim(GetMV("NF_XPRDPDG",,""))
Local cSerie    := ""
Local cDoc      := ""
Local dDtEmi    := CToD("")
Local cNomeF    := ""
Local cFornece  := ""
Local cLojaFor  := ""
Local nVlrFrete := 0
Local nBaseIcms := 0

dbSelectArea(cAcabCTE)
(cAcabCTE)->(dbSetOrder(1)) // Z5Z_FILIAL+Z5Z_CHAVE

dbSelectArea(cAIteCTE)
(cAIteCTE)->(dbSetOrder(2)) // Z6Z_FILIAL+Z6Z_SERIE+Z6Z_DOC+Z6Z_FORNEC+Z6Z_LOJA+Z6Z_ITEM

dbSelectArea("SB1")
SB1->(dbSetOrder(1)) // B1_FILIAL+B1_COD

If (cAcabCTE)->(dbSeek(xFilial(cAcabCTE) + cChave))

	cSerie   := &(cAcabCTE+"->"+cAcabCTE+"_SERIE")
	cDoc     := &(cAcabCTE+"->"+cAcabCTE+"_DOC")
	dDtEmi   := &(cAcabCTE+"->"+cAcabCTE+"_EMISSA")
	cNomeF   := &(cAcabCTE+"->"+cAcabCTE+"_NOME")
	cFornece := &(cAcabCTE+"->"+cAcabCTE+"_FORNEC")
	cLojaFor := &(cAcabCTE+"->"+cAcabCTE+"_LOJA")
	
	cChvItens := cSerie + cDoc + cFornece + cLojaFor   
	
	If (cAIteCTE)->(dbSeek(xFilial(cAIteCTE) + cChvItens))
		nVlrFrete := &(cAIteCTE+"->"+cAIteCTE+"_VALTOT")
		nBaseIcms := &(cAIteCTE+"->"+cAIteCTE+"_BCICMS")

		If nVlrFrete != nBaseIcms
		
			If (cAIteCTE)->(dbSeek(xFilial(cAIteCTE) + cChvItens))
				RecLock(cAIteCTE,.F.)
					&(cAIteCTE+"->"+cAIteCTE+"_VALUNI") := nBaseIcms
					&(cAIteCTE+"->"+cAIteCTE+"_VALTOT") := nBaseIcms
				(cAIteCTE)->(MsUnLock())
			EndIf
			
			nVlrPedg := nVlrFrete - nBaseIcms
			
			SB1->(dbSeek(xFilial("SB1") + cPrdPedg))
			
			RecLock(cAIteCTE,.T.)
				&(cAIteCTE+"->"+cAIteCTE+"_FILIAL") := xFilial(cAIteCTE)
				&(cAIteCTE+"->"+cAIteCTE+"_SERIE") 	:= cSerie
				&(cAIteCTE+"->"+cAIteCTE+"_DOC") 	:= cDoc
				&(cAIteCTE+"->"+cAIteCTE+"_EMISSA")	:= dDtEmi
				&(cAIteCTE+"->"+cAIteCTE+"_ITEM")	:= StrZero(2,4)
				&(cAIteCTE+"->"+cAIteCTE+"_PRODUT")	:= SB1->B1_COD
				&(cAIteCTE+"->"+cAIteCTE+"_DESCRI")	:= SB1->B1_DESC
				&(cAIteCTE+"->"+cAIteCTE+"_UM")     := SB1->B1_UM
				&(cAIteCTE+"->"+cAIteCTE+"_QUANTI") := 1
				&(cAIteCTE+"->"+cAIteCTE+"_VALUNI") := nVlrPedg
				&(cAIteCTE+"->"+cAIteCTE+"_VALTOT") := nVlrPedg
				&(cAIteCTE+"->"+cAIteCTE+"_BCICMS") := 0
				&(cAIteCTE+"->"+cAIteCTE+"_FORNEC") := cFornece
				&(cAIteCTE+"->"+cAIteCTE+"_LOJA") 	:= cLojaFor
			(cAIteCTE)->(MsUnLock())
		
		EndIf

	EndIf			

EndIf

RestArea(aArea)

Return
                            