#include "totvs.ch"          
#include "protheus.ch"
#include "topconn.ch"   
/*/{Protheus.doc} ATEC005
Tela saldo remessa comodato
@description Rotina utilizada para informa o saldo do item (AB2_CODPRO) quando for um chamado técnico com
classificação 005 = Retirada ou 008 = Retirada Ecolab

@author dirlei@afsouza
@since 22/11/2017
@version P11 R8

@return nil, nenhum

@example u_atec005()

@type function
/*/
User Function ATEC005() 

Local aArea    := GetArea()
Local lRet     := .F.
Local cCodCla  := AllTrim(SuperGetMV("ST_CLASSIF",.F.,"005/008"))
Local cCliente := M->AB1_CODCLI
Local cLoja    := M->AB1_LOJA
Local cClassif := aCols[n][GdFieldPos("AB2_CLASSI")]
Local cCodPro  := M->AB2_CODPRO //aCols[n][GdFieldPos("AB2_CODPRO")]
Local cTitulo  := "Saldo Comodato"
Local aLista   := {}
Local aCabec   := {"Documento","Serie","Emissão","Quantidade","Saldo"}
Local oLbx     := Nil

Static oDlg := Nil

If Empty(cCliente) .Or. Empty(cLoja)
	MsgStop("O Cliente/Loja deve ser informado!","Cliente/Loja")
	lRet := .F.
	Return lRet
EndIf

If Empty(cClassif)
	MsgStop("A Classificação deve ser informada!","Classifição")
	lRet := .F.
	Return lRet
EndIf

// Verifica se Classificação está dentro do parâmetro
If !(cClassif $ cCodCla)
	lRet := .T.
	Return lRet
EndIf

BuscaSld(cCliente,cLoja,cCodPro)
dbSelectArea("TRBSLD")

// Carrega o vetor conforme a condição.
While !TRBSLD->(Eof())
	AAdd( aLista, { TRBSLD->D2_DOC, TRBSLD->D2_SERIE, SToD(TRBSLD->D2_EMISSAO), TRBSLD->D2_QUANT, TRBSLD->SALDO } )
	TRBSLD->(dbSkip())
End

// Se não houver dados no vetor, avisar usuário e sair rotina
If Len(aLista) == 0
	MsgAlert("Não existem dados a consultar!", cTitulo)
	lREt := .T.
	Return lRet
EndIf

// Monta a tela
Define MsDialog oDlg Title cTitulo From 000,000 To 250,500 Pixel

oLbx := TWBrowse():New(10,10,240,95,,aCabec,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oLbx:SetArray( aLista )
oLbx:bLine := {|| aEval(aLista[oLbx:nAt],{|x,y| aLista[oLbx:nAt,y] } ) }

Define SButton From 110,210 Type 1 Action oDlg:End() Enable Of oDlg
Activate MsDialog oDlg Center

dbCloseArea("TRBSLD")

RestArea(aArea)

lRet := .T.

Return lRet 


/*/{Protheus.doc} BUSCASLD
Query saldo comodato

@author dirlei@afsouza
@since 22/11/2017
@version P11 R8

@return nil, nenhum

@type function
/*/
Static Function BuscaSld(cCodCli, cLojaCli, cProduto)

Local aArea := GetArea()
Local cQry  := ""
Local cTes  := FormatIn(AllTrim(GetMV("ST_TESCOMO")),";")

If Select("TRBSLD") > 0
	dbSelectArea("TRBSLD")
	dbCloseArea("TRBSLD")
EndIf
 
cQry := " SELECT SD2.D2_FILIAL
cQry += "       ,SD1.D1_FILIAL
cQry += "       ,SD2.D2_DOC
cQry += "       ,SD1.D1_NFORI
cQry += "       ,SD2.D2_SERIE
cQry += "       ,SD1.D1_SERIORI
cQry += "       ,SD2.D2_EMISSAO
cQry += "       ,SD2.D2_COD
cQry += "       ,SD1.D1_COD
cQry += "       ,SD2.D2_CLIENTE
cQry += "       ,SD1.D1_FORNECE
cQry += "       ,SD2.D2_LOJA
cQry += "       ,SD1.D1_LOJA
cQry += "       ,SD2.D2_QUANT
cQry += "       ,SD1.D1_QUANT
cQry += "       ,SD2.D2_QUANT - ISNULL(SD1.D1_QUANT,0) AS SALDO
cQry += " FROM "+ RetSqlName("SD2") +" SD2
cQry += " LEFT JOIN "+ RetSqlName("SD1") +" SD1
cQry += " ON SD2.D2_FILIAL = SD1.D1_FILIAL
cQry += " AND SD2.D2_DOC = SD1.D1_NFORI
cQry += " AND SD2.D2_SERIE = SD1.D1_SERIORI
cQry += " AND SD2.D2_CLIENTE = SD1.D1_FORNECE
cQry += " AND SD2.D2_LOJA = SD1.D1_LOJA
cQry += " AND SD2.D2_COD = SD1.D1_COD
cQry += " AND SD1.D_E_L_E_T_ != '*'
cQry += " WHERE SD2.D_E_L_E_T_ != '*'
cQry += " AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"'
cQry += " AND SD2.D2_COD = '"+ cProduto +"'
cQry += " AND SD2.D2_CLIENTE = '"+ cCodCli +"' 
cQry += " AND SD2.D2_LOJA = '"+ cLojaCli +"'
cQry += " AND SD2.D2_TES IN "+ cTes

// Mostra query
//Aviso("Query",cQry,{"Ok"},3,,,,.T.)
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TRBSLD",.F.,.T.)

RestArea(aArea)

Return Nil