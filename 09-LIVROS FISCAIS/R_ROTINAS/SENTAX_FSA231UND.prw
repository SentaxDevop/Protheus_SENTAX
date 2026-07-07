#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include 'topconn.ch'


//---------------------------------------------------------------------------
/*/{Protheus.doc} FSA231UND   
DESCRIÇÃO:Unidade de medida e quantidade do item informadas no documento fiscal ( [cAlias] ) --> aRet

@sample		FSA231UND ()
@return 	Nill
@author		João E. Lopes
@since		23/04/2020 
@version 	P12
/*/
//----------------------------------------------------------------------------
 
User Function FSA231UND()

Local   cAlsMov  := PARAMIXB[1]  //---Alias posicionado---//
Local   aRetorno := {}
Local   aAreaAnt := GetArea()

 
If (cAlsMov)->FT_TIPOMOV == 'E'
    DbSelectArea('SD1')
    SD1->(DbSetOrder(1)) //---D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM---//
    If SD1->(DbSeek(xFilial("SD1") + (cAlsMov)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
        If !Empty(SD1->D1_QTSEGUM) .And. !Empty(SD1->D1_SEGUM)
         
            Aadd(aRetorno, SD1->D1_SEGUM)          //---Unidade de medida do item no Documento Fiscal---//
            Aadd(aRetorno, SD1->D1_QTSEGUM)        //---Quantidade do item no Documento Fiscal---//
            Aadd(aRetorno, (1/(cAlsMov)->B1_CONV)) //---Fator de Conversão para a unidade de medida constante no Registro 0200---//
            Aadd(aRetorno, (cAlsMov)->B1_TIPCONV)  //---Tipo de Conversão: M-Multiplicação / D-Divisão---//
 
        EndIf
    EndIf
EndIf
 
RestArea(aAreaAnt)
Return aRetorno