#include "protheus.ch"
#include "topconn.ch"
        
//  Ajustado Layze Fuzinato - Considerar se a TES movimenta estoque.

User Function MT100LOK()
Local lRet	:= .T.
/*
Local nPCod		:= GdFieldPos("D1_COD")
Local nPStWMS	:= GdFieldPos("D1_XSTAWMS")
Local nPSTes    := GdFieldPos("D1_TES")
Local cCodProd	:= aCols[n,nPCOD]
Local cStaWMS	:= aCols[n,nPStWMS]
Local cTes      := aCols[n,nPSTes]
Local cMov      := ''
Local cCFOP     := ''
//Local cVar 		:= GetMV("MV_XENTW",.F.)

If cFilAnt == '020201' .AND. C103TIPO == 'N'
    cMov:= Posicione('SF4',1,XFILIAL('SF4')+CTES,'F4_ESTOQUE')
    //cCFOP:= Posicione('SF4',1,XFILIAL('SF4')+CTES,'F4_CF')

    If !GdDeleted(n) 
        If cMov == 'S' //.AND. cCFOP $ cVar
                If cStaWMS != "O"
                    Aviso("Atenção - MT100LOK","Produto " + cCodProd + " Linha " + strzero(n,3) + CRLF +  "Produto com integração com o WMS!!! " + CRLF +  "Produto não foi integrado ou o retorno com erro.",{"OK"})
                    lRet:= .F.
                Endif
        EndIf
    endif
EndIf
*/
Return lRet 

/*/{Protheus.doc} MA103OPC
    Ponto de Entrada utilizado para adicionar itens no menu
    @type function
    @version 1.0
    @author Alfred Andersen
    @since 21/11/2023
    @requester Kleber Moro
    @consultancy Harpia
    @site www.harpiaconsultoria.com
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=6085341
/*/
User Function MA103OPC()

    Local aRet := {}

    aAdd(aRet,{'WMS - Devolução', 'U_fPnlWMSNF()', 0, 5})
    aAdd(aRet,{'Baixar SAC', 'U_ATMK016()', 0, 5})

Return aRet
