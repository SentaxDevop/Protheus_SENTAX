#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: MTGRDVW		|	Autor: Luis Paulo							|	Data: 08/11/2021	//
//==================================================================================================//
//	Descrição: PE para incluir campos na grid  e edits na tela de Consulta ao Estoque pela tecla F4.//
//                                                                                                  //
//==================================================================================================//
User Function MTGRDVW()
Local ExpA1	    :=  PARAMIXB[1]  
Local ExpO1	    :=  PARAMIXB[2]   
Local ExpO2	    :=  PARAMIXB[3]  
Local cDataSC   := ""
Local cDivSor   := " - "
Local cDataPC   := ""
Local cDataFim  := ""
Private cCRLF   := CRLF 
Private nQtdD   := SuperGetMv('ST_QDDESPV',,90) 

cDataSC := BusDTSc()
cDataPC := BusDTPc()

cDataFim := cDataSC + cDivSor + cDataPC

//...Customização do cliente
@ 225,007 SAY "Prev SC / Prev PC" of ExpO2 PIXEL 
@ 224,075 MsGet cDataFim of ExpO2 PIXEL SIZE 070,009 When .F.

Return Nil



Static Function BusDTSc()
Local aArea     := GetArea()
Local cAliasSc  := GetNextAlias()
Local cQry      := ""
Local cRet      := ""

cQry := " SELECT ISNULL(C1_DATPRF,'') DATAPREV "+cCRLF
cQry += " FROM "+ RetSqlName("SC1") +" "+cCRLF
cQry += " WHERE D_E_L_E_T_ = '' "+cCRLF
cQry += " AND C1_FILIAL = '"+ xFilial("SC1") +"' "+cCRLF
cQry += " AND C1_PRODUTO = '"+ SB1->B1_COD+"' "+cCRLF
cQry += " AND C1_PEDIDO = '' "+cCRLF
cQry += " AND C1_RESIDUO = '' "+cCRLF
cQry += " AND C1_DATPRF >= '"+ DTOS((Date() - nQtdD)) +"' "+cCRLF
cQry += " ORDER BY C1_DATPRF "+cCRLF

TCQuery cQry New Alias (cAliasSc)

DbSelectArea((cAliasSc))
(cAliasSc)->(DbGoTop())

If !(cAliasSc)->(EOF())
    cRet      := DTOC((STOD((cAliasSc)->DATAPREV)))
EndIf

(cAliasSc)->(DbCloseArea())

RestArea(aArea)
Return(cRet)

Static Function BusDTPc()
Local aArea     := GetArea()
Local cAliasPc  := GetNextAlias()
Local cQry      := ""
Local cRet      := ""

cQry := " SELECT ISNULL(C7_DATPRF,'') DATAPREV "+cCRLF
cQry += " FROM " + RetSqlName("SC7") + "  "+cCRLF
cQry += " WHERE D_E_L_E_T_ = ''  "+cCRLF
cQry += " AND C7_FILIAL = '"+ xFilial("SC7") +"' "+cCRLF
cQry += " AND C7_PRODUTO = '"+ SB1->B1_COD+"'  "+cCRLF
cQry += " AND C7_QUJE < C7_QUANT  "+cCRLF
cQry += " AND C7_QTDACLA = 0  "+cCRLF
cQry += " AND C7_RESIDUO = ''  "+cCRLF
cQry += " AND C7_DATPRF >= '"+ DTOS((Date() - nQtdD)) +"' "+cCRLF
cQry += " ORDER BY C7_DATPRF  "+cCRLF

TCQuery cQry New Alias (cAliasPc)

DbSelectArea((cAliasPc))
(cAliasPc)->(DbGoTop())

If !(cAliasPc)->(EOF())
    cRet      := DTOC((STOD((cAliasPc)->DATAPREV)))
EndIf

(cAliasPc)->(DbCloseArea())

RestArea(aArea)
Return(cRet)
