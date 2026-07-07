#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'Protheus.ch' 
#include "rwmake.ch"
#include "TOPCONN.ch"
#include "APWEBEX.CH"
#include "TBICONN.ch"
//==================================================================================================//
//	Programa: AWMS001		|	Autor: Luis Paulo							|	Data: 29/11/2022	//
//==================================================================================================//
//	Descrição: Funcao responsavel por enviar a NF para o WMS										//
//	-																								//
//==================================================================================================//
User Function AWMS001()
Local aArea     := GetArea()

Local cQry      := ""
Local cCRLF     := CRLF
Local cSC9      := RetSqlName("SC9")
Local cAlias    := GetNextAlias()
Private cOpera	:= "U"

cQry := " SELECT DISTINCT C9_SERIENF,C9_NFISCAL, "+cCRLF
cQry += " 	(	SELECT TOP 1 R_E_C_N_O_  "+cCRLF
cQry += " 		FROM "+cSC9+"  WITH(NOLOCK) "+cCRLF
cQry += " 		WHERE D_E_L_E_T_ = '' "+cCRLF
cQry += " 		AND C9_FILIAL = '"+ SC5->C5_FILIAL +"'"+cCRLF
cQry += " 		AND C9_PEDIDO = '"+ SC5->C5_NUM +"'"+cCRLF
cQry += " 		AND C9_SERIENF = SC9.C9_SERIENF "+cCRLF
cQry += " 		AND C9_NFISCAL = SC9.C9_NFISCAL "+cCRLF
cQry += " 		ORDER BY R_E_C_N_O_ DESC) RECREC "+cCRLF
cQry += " FROM "+cSC9+" SC9 WITH(NOLOCK) "+cCRLF
cQry += " WHERE SC9.D_E_L_E_T_ = '' "+cCRLF
cQry += " AND SC9.C9_FILIAL = '"+ SC5->C5_FILIAL +"'"+cCRLF
cQry += " AND SC9.C9_PEDIDO = '"+ SC5->C5_NUM +"'"+cCRLF
cQry += " AND SC9.C9_ITEM = '01' "+cCRLF

TcQuery cQry New Alias (cAlias)

DbSelectArea((cAlias))
(cAlias)->(DbGoTop())

While !(cAlias)->(EOF())

    DbSelectArea("SC9")
    //SC9->(DbGoTop())
    SC9->(DbGoto((cAlias)->RECREC ))
   
    Conout("")
    Conout("Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)))

    aRet:= U_xWMSPED( GetMv('FZ_WSWMS5'), 'SC9', 1, 'C9_FILIAL+C9_PEDIDO+C9_ITEM', FWxFilial('SC9') + SC9->C9_PEDIDO + SC9->C9_ITEM ) 

    SF2->(DbSetOrder(1))
    SF2->(DbSeek(FWxFilial("SF2") + (cAlias)->C9_NFISCAL + (cAlias)->C9_SERIENF))
    Reclock("SF2",.F.)
        If aRet[1]
            SF2->F2_XSTAWMS := "E"
            FWAlertSuccess("Nota Fiscal enviada com sucesso para o WMS." + CRLF + "Retorno:(" + aRet[2] + ")")
        Else
            SF2->F2_XSTAWMS := "F"
            FWAlertError("Falha no envio da Nota Fiscal para o WMS. Retorno:(" + aRet[3] + ")")
        End
    SF2->(MsUnLock())

    (cAlias)->(DbSkip())
EndDO 

(cAlias)->(DbCloseArea()) 

RestArea(aArea)  
Return()
