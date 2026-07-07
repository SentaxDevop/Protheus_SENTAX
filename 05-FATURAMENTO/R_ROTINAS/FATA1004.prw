//Pressionando F11 mostra as últimas notas de vendas do produto digitado no atendimento do Call Center baseado
//no parâmetro MV_ANOVEN, que permite informar a parter de que mês e ano deseja consultar as notas
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function FATA1004()

Private aArea  := GetArea()
Private nValor := 0

if N > 0 .AND. TkGetTipoAte() != "3"
   nValor:=  aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_VRUNIT"})]
   //SetKey(VK_F11,{||ULTVEN()})
	ULTVEN()

Endif


RestArea(aArea)

Return(nValor)

//----------------------
Static Function ULTVEN()

Local lRet     := .F.
Local aCampos  := {}
Local aBrowse  := {}
Local bOk      := {|| lRet := .T.,oDlg:END()}
Local bCancel  := {|| lRet := .F.,oDlg:END()}
Local aButtons := {}
//Local xRetorno
Local oDlg

If (Select("TRB") <> 0)
	dbSelectArea("TRB")
	dbCloseArea()
Endif
AADD(aCampos,{"D2_FILIAL"	,"C",TAMSX3('D2_FILIAL')[1],0})
AADD(aCampos,{"NOTA"		,"C",TAMSX3('D2_DOC')[1],0})
AADD(aCampos,{"D2_SERIE"	,"C",TAMSX3('D2_SERIE')[1],0})
AADD(aCampos,{"EMISSAO"		,"D",08,0})
AADD(aCampos,{"QTDE"		,"N",09,2})
AADD(aCampos,{"UNIT"		,"N",09,2})
	
AADD(aBrowse,{"D2_FILIAL ","Filial","@!",,TAMSX3('D2_FILIAL')[1],0,".T."})
//AADD(aBrowse,{"D2_SERIE","Serie  ","@!",,TAMSX3('D2_SERIE')[1],0,".T."})
AADD(aBrowse,{"NOTA   ","Nota       ","@!",09,0,".T."})
AADD(aBrowse,{"EMISSAO","Emissão    ","@!",08,0,".T."})
AADD(aBrowse,{"QTDE   ","Quantidade ","@E 99,999.99",09,2,".T."})
AADD(aBrowse,{"UNIT   ","Vl Unitario","@E 99,999.99",09,2,".T."})

//cNomeArq := CriaTrab(aCampos,.T.)
//dbUseArea(.T.,__LocalDriver,cNomeArq,"TRB",.F.,.F.)

oTmp := FWTemporaryTable( ):New('TRB')
oTmp:SetFields( aCampos )
//oTmp:AddIndex("01", { "D2_FILIAL", "NOTA", "D2_SERIE" } )
oTmp:Create( )
cAliasTRB := oTmp:GetAlias( )   

cQuery := " SELECT D2_FILIAL, D2_DOC NOTA,D2_SERIE, D2_COD, D2_EMISSAO EMISSAO, B1_DESC, SUM(D2_QUANT) QTDE, MAX(UB_VRUNIT) UNIT "
cQuery += " FROM "
cQuery += RetSqlName("SD2")+" SD2, "+RetSqlName("SB1")+" SB1,  " +RetSqlName("SUB")+" SUB "  
cQuery += " WHERE "
cQuery += " SB1.D_E_L_E_T_ = ' ' "
cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
cQuery += " AND UB_FILIAL = '"+xFilial("SUB")+"' "
cQuery += " AND D2_FILIAL = '"+xFilial("SD2")+"' "
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " AND SUBSTRING(D2_EMISSAO,1,6) >= '"+GETMV("MV_ANOVEN")+"' "
cQuery += " AND D2_CLIENTE = '"+M->UA_CLIENTE+"' "
cQuery += " AND D2_LOJA = '"+M->UA_LOJA+"' "
cQuery += " AND D2_COD = '"+aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_PRODUTO"})]+"' "
cQuery += " AND D2_COD = B1_COD "
cQuery += " AND SUB.UB_NUMPV = SD2.D2_PEDIDO "
cQuery += " AND SUB.UB_ITEMPV = SD2.D2_ITEMPV "
cQuery += " AND SUB.UB_PRODUTO = SD2.D2_COD "
cQuery += " GROUP BY D2_FILIAL, D2_DOC,D2_SERIE, D2_COD, D2_EMISSAO, B1_DESC "
cQuery += " ORDER BY D2_EMISSAO DESC "

SqlToTrb(cQuery,aCampos,"TRB")

TRB->(dbGoTop())	
@ 143,290 To 502,850 Dialog oDlg Title OemToAnsi("Cliente x Produto")
@ 030,001 To 179,284 BROWSE "TRB" FIELDS aBrowse OBJECT oFields

Activate Dialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))

TRB->(dbCloseArea())
	
Return
