#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"
//==================================================================================================//
//	Programa: GXPRDFOR		|	Autor: Luis Paulo							|	Data: 13/06/2022	//
//==================================================================================================//
//	Descrição: Gatilho para retornar o código do produto do fornecedor(ultima cadastrado ord recno)	//
//	-																								//
//==================================================================================================//
User Function GXPRDFOR()
Local aArea     := GetArea()
Local cRet      := ""
Local cProd     := M->UB_PRODUTO
Local cQry      := ""
Local cAliasA5  := GetNextAlias()

cQry  := " SELECT A5_PRODUTO,A5_CODPRF "
cQry  += " FROM SA5010 WITH(NOLOCK) "
cQry  += " WHERE D_E_L_E_T_ = '' "
cQry  += " AND A5_PRODUTO = '"+cProd+"' "
cQry  += " ORDER BY R_E_C_N_O_ DESC "

TcQuery cQry New Alias (cAliasA5)

DbSelectArea((cAliasA5))
(cAliasA5)->(DbGoTop())

If !(cAliasA5)->(EOF())
    cRet := (cAliasA5)->A5_CODPRF
EndIf

(cAliasA5)->(DbCloseArea())

RestArea(aArea)
Return(cRet)


User Function GXPRDSEN() //FWIsInCallStack("U_GXPRDSEN")
Local aArea     := GetArea()
Local cRet      := ""
Local cProd     := M->UB_XPRDFOR
Local cQry      := ""
Local cAliasA5  := GetNextAlias()
Local cCampo    := "UB_PRODUTO"

cQry  := " SELECT A5_PRODUTO,A5_CODPRF "
cQry  += " FROM SA5010 WITH(NOLOCK) "
cQry  += " WHERE D_E_L_E_T_ = '' "
cQry  += " AND A5_CODPRF = '"+cProd+"' "
cQry  += " ORDER BY R_E_C_N_O_ DESC "

TcQuery cQry New Alias (cAliasA5)

DbSelectArea((cAliasA5))
(cAliasA5)->(DbGoTop())

If !(cAliasA5)->(EOF())
    cRet := (cAliasA5)->A5_PRODUTO
EndIf

(cAliasA5)->(DbCloseArea())

RestArea(aArea)
Return(cRet)


User Function GPRODSEG()
Local aArea     := GetArea()
Local cRet      := ""
Local nPosPrd   := Ascan(Aheader,{|x| AllTrim(x[2]) == "UB_PRODUTO" })
Local cQry      := ""
Local cCampo    := "UB_PRODUTO"
Local cProd     := M->UB_XPRDFOR
Local cQry      := ""
Local cAliasA5  := GetNextAlias()

cRet      := Acols[n][nPosPrd]

cQry  := " SELECT A5_PRODUTO,A5_CODPRF "
cQry  += " FROM SA5010 WITH(NOLOCK) "
cQry  += " WHERE D_E_L_E_T_ = '' "
cQry  += " AND A5_CODPRF = '"+cProd+"' "
cQry  += " ORDER BY R_E_C_N_O_ DESC "

TcQuery cQry New Alias (cAliasA5)

DbSelectArea((cAliasA5))
(cAliasA5)->(DbGoTop())

If !(cAliasA5)->(EOF())
    cRet := (cAliasA5)->A5_PRODUTO
EndIf

(cAliasA5)->(DbCloseArea())

//Para aCols
If ExistTrigger(cCampo) // verifica se existe trigger para este campo
    RunTrigger(2,n,nil,,cCampo)
Endif

RestArea(aArea)
Return(cRet)

