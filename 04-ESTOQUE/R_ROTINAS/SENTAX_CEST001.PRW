#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} cAcurEst
Relatório de Acuracidade de estoque

@author  Henrique Baldin
@since   04/06/2014

// Alteração 1
18/07/2014
Criado campo b7_ssaldo, saldo atual, pois era lancada nota com data
retroativa, e zicava toda a Acuracidade.

/*/
//-------------------------------------------------------------------
User Function cAcurEst()    // U_cAcurEst()

Local oReport

Private cPerg := "CACUREST"

Private nTotFis   := 0
Private nTotSis   := 0
Private ndif      := 0
Private nCTBD     := 0
Private nCTBC     := 0
Private nDifPG    := 0

Private nTotalNF  := 0
Private nTotalCT  := 0
Private nDifeTOT  := 0

Private nTotSaldoS := 0
Private nTotSaldoF := 0
Private nDifQtd    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Data de                               ³
//³ mv_par02               Data ate                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Carregamento das Perguntas
//AjustaSX1()

If !Pergunte(cPerg,.T.)
	Return
EndIf

If MV_PAR01 >= StoD("20150301") // Alterações em 27/02/2015 - Smaha 
	oReport := ReportDef1() // Novo layout considerando o campo D3_XSSALDO
Else
	oReport := ReportDef2() // Layout anterior, considerando o campo B7_SSALDO
EndIf	

oReport:PrintDialog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef1
Estrutura do Relatório

@author  Henrique baldin
@since   08/04/2013

/*/
//-------------------------------------------------------------------
Static Function ReportDef1()

Local cTitle    := OemToAnsi("RELATORIO DE ACURACIDADE DE ESTOQUE (NOVO 09/2018)")
Local cHelp     := OemToAnsi("RELATORIO DE ACURACIDADE DE ESTOQUE (NOVO 09/2018)")

Local oReport
Local oSection
Local oSection1

oReport := tReport():New("CACUREST",cTitle,cPerg,{|oReport| RepPrint1(oReport)}, )

oReport:SetLandscape()
oReport:HideParamPage()

oSection  := trSection():New(oReport,"Acuracidade Estoque",,,,,,,.F.)

trCell():New(oSection,"FILIAL"," ","Filial"    ,PesqPict("SB7","B7_FILIAL"),TamSx3("B7_FILIAL")[1] )
trCell():New(oSection,"PRODUT"," ","PRODUTO"   ,PesqPict("SB1","B1_COD"), 	TamSx3("B1_COD")[1] )
trCell():New(oSection,"DESCRI"," ","DESCRICAO" ,PesqPict("SB1","B1_DESC"), 	TamSx3("B1_DESC")[1] )
trCell():New(oSection,"ARMAZE"," ","ARMAZEM"   ,PesqPict("SB1","B1_LOCPAD"),TamSx3("B1_LOCPAD")[1] )
trCell():New(oSection,"UNIDME"," ","UM"        ,PesqPict("SB1","B1_UM"), 	TamSx3("B1_UM")[1] )
trCell():New(oSection,"SLDSIS"," ","SALDO_SIST",,TamSx3("D3_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"SLDFIS"," ","SALDO_FIS" ,,TamSx3("D3_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>SALD"," ","<> SALDO"  ,,TamSx3("D3_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"VLRSIS"," ","VALOR_SIST",,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"VLRFIS"," ","VALOR_FIS" ,,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>VALO"," ","<> VALOR"  ,,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")

Return(oReport)


//-------------------------------------------------------------------
/*/{Protheus.doc} RepPrint1
Realiza a impressão do relatório

@author  Henrique Baldin
@since   04/06/2014


/*/
//-------------------------------------------------------------------
Static Function RepPrint1(oReport)

Local oSection  := oReport:Section(1)

Local aCampos   := {}
Local aEstru    := {}
Local aEstru2   := {}
Local aValores	:= {}

Local nI        := 0
Local cUnidade  :=""

Private cDataINI  := DTOS(MV_PAR01)
Private cDataFIM  := DTOS(MV_PAR02)


If ( SELECT("SD3TMP") ) > 0
	dbSelectArea("SD3TMP")
	SD3TMP->(dbCloseArea())
EndIf 

cQuery := " SELECT SD3.D3_FILIAL
cQuery += "       ,SD3.D3_QUANT
cQuery += "       ,SD3.D3_CUSTO1
cQuery += "       ,SD3.D3_CF
cQuery += "       ,SD3.D3_EMISSAO
cQuery += "       ,SD3.D3_COD
cQuery += "       ,SD3.D3_LOCAL
cQuery += "       ,SD3.D3_XSSALDO
cQuery += "       ,SD3.D3_CUSTO1
cQuery += "       ,SD3.D3_CF
cQuery += "       ,SB1.B1_DESC
cQuery += "       ,SB1.B1_UM
cQuery += " FROM "+ RetSQLName("SD3") +" SD3
cQuery += " INNER JOIN "+ RetSQLName("SB1") +" SB1 
cQuery += "  ON SB1.B1_COD = SD3.D3_COD 
cQuery += " AND SB1.D_E_L_E_T_ <> '*'
cQuery += " WHERE SD3.D3_FILIAL = '"+ xFilial("SD3") +"'
cQuery += "	  AND SD3.D3_EMISSAO BETWEEN '"+ cDataINI +"' AND '"+ cDataFIM +"'
cQuery += "   AND SD3.D3_DOC = 'INVENT'
cQuery += "   AND SD3.D3_LOCAL BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' 
cQuery += "   AND SD3.D_E_L_E_T_ <> '*'
cQuery += " ORDER BY SD3.D3_FILIAL,SD3.D3_COD

TCQUERY cQuery NEW ALIAS "SD3TMP"

oReport:SetMeter(0)

SD3TMP->(dbGoTop())

oSection:Init()

Do While !SD3TMP->(Eof())
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	If Substr(SD3TMP->D3_CF,1,2) == "RE"
	 	nSaldoF := SD3TMP->D3_XSSALDO - SD3TMP->D3_QUANT 
	Else
  		nSaldoF := SD3TMP->D3_XSSALDO + SD3TMP->D3_QUANT 
	EndIf
	
	nSaldoS    := SD3TMP->D3_XSSALDO  	
	aValores   := CalcEst( SD3TMP->D3_COD, SD3TMP->D3_LOCAL, StoD(SD3TMP->D3_EMISSAO) + 1 )
	nVunit     := aValores[2] / aValores[1]
	nValSist   := Round( nSaldoS * nVunit, 2 )
	nValFis    := Round( nSaldoF * nVunit, 2 )
	nDifVal    := (nValFis - nValSist)
	nTotSis    += nValSist
	nTotFis	   += nValFis
	nTotSaldoS += nSaldoS
	nTotSaldoF += nSaldoF
	
	If nValFis <> nValSist
		If (nValSist - nValFis) < 0
			nDif += (nValFis - nValSist)
		Else
			nDif += (nValSist - nValFis)
		EndIf
	EndIf
	nDifQtd += Abs(nSaldoS) - Abs(nSaldoF)
	 
	oSection:Cell("FILIAL"):SetValue( SD3TMP->D3_FILIAL )
	oSection:Cell("PRODUT"):SetValue( SD3TMP->D3_COD )
	oSection:Cell("DESCRI"):SetValue( SD3TMP->B1_DESC )
	oSection:Cell("ARMAZE"):SetValue( SD3TMP->D3_LOCAL )
	oSection:Cell("UNIDME"):SetValue( SD3TMP->B1_UM )
	oSection:Cell("SLDSIS"):SetValue( nSaldoS )
	oSection:Cell("SLDFIS"):SetValue( nSaldoF )
	oSection:Cell("<>SALD"):SetValue( nSaldoF - nSaldoS )
	oSection:Cell("VLRSIS"):SetValue( nValSist )
	oSection:Cell("VLRFIS"):SetValue( nValFis )
	oSection:Cell("<>VALO"):SetValue( Round( nDifVal, 2 ) )
	 
	oSection:PrintLine()
	oReport:SkipLine()
	
	SD3TMP->(DBSkip())
	
EndDo

oReport:SkipLine()
oReport:SkipLine()

oReport:PrintText("Data De: "+ DToC(MV_PAR01) +" Data Até: "+ DToC(MV_PAR02))
oReport:SkipLine()

oReport:PrintText("Total Sistema (R$)........: "+ AllTrim(Transform(nTotSis,"@E 99,999,999.99")))
oReport:PrintText("Total Fisico (R$).........: "+ AllTrim(Transform(nTotFis,"@E 99,999,999.99")))
oReport:PrintText("Total Diferença (R$) .....: "+ AllTrim(Transform(Abs(nDif),"@E 99,999,999.99")))
nAcur := (1 - (Abs(nDif)/nTotSis)) * 100
oReport:PrintText("ACURACIDADE DE ESTOQUE ...: " + AllTrim(Transform(nAcur,"@E 99,999,999.99")) + "%" )
oReport:SkipLine()

oReport:PrintText("Quant.Total Sistema ......: "+ AllTrim(Transform(nTotSaldoS,"@E 99,999,999.99")))
oReport:PrintText("Quant.Total Fisico .......: "+ AllTrim(Transform(nTotSaldoF,"@E 99,999,999.99")))
oReport:PrintText("Total Diferença ..........: "+ AllTrim(Transform(Abs(nDifQtd),"@E 99,999,999.99")))
nAcurQtd := (1 - (Abs(nDifQtd)/nTotSaldoS)) * 100
oReport:PrintText("ACURACIDADE DE ESTOQUE ...: " + AllTrim(Transform(nAcurQtd,"@E 99,999,999.99")) + "%" )

oSection:Finish()

Return
          
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef2
Estrutura do Relatório

@author  Henrique baldin
@since   08/04/2013

/*/
//-------------------------------------------------------------------
Static Function ReportDef2()

Local cTitle    := OemToAnsi("RELATORIO DE ACURACIDADE DE ESTOQUE (03/2015)")
Local cHelp     := OemToAnsi("RELATORIO DE ACURACIDADE DE ESTOQUE (03/2015)")

Local oReport
Local oSection
Local oSection1

oReport := tReport():New("cAcurEst",cTitle,cPerg,{|oReport| RepPrint2(oReport)}, )


oReport:SetLandscape()
oReport:HideParamPage()


oSection  := trSection():New(oReport,"Acuracidade Estoque",,,,,,,.F.)

trCell():New(oSection,"FILIAL"," ","Filial"    ,PesqPict("SB7","B7_FILIAL"),TamSx3("B7_FILIAL")[1] )
trCell():New(oSection,"PRODUT"," ","PRODUTO"   ,PesqPict("SB1","B1_COD"), 	TamSx3("B1_COD")[1] )
trCell():New(oSection,"DESCRI"," ","DESCRICAO" ,PesqPict("SB1","B1_DESC"), 	TamSx3("B1_DESC")[1] )
trCell():New(oSection,"ARMAZE"," ","ARMAZEM"   ,PesqPict("SB1","B1_LOCPAD"),TamSx3("B1_LOCPAD")[1] )
trCell():New(oSection,"UNIDME"," ","UM"        ,PesqPict("SB1","B1_UM"), 	TamSx3("B1_UM")[1] )
trCell():New(oSection,"SLDSIS"," ","SALDO_SIST",,TamSx3("B7_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"SLDFIS"," ","SALDO_FIS" ,,TamSx3("B7_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>DFS1"," ","<>_SALDO"  ,,TamSx3("B7_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>DFS2"," ","SALDO MOV" ,,TamSx3("B7_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"VLRSIS"," ","VALOR_SIST",,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"VLRFIS"," ","VALOR_FIS" ,,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>VALO"," ","<>_VALOR"  ,,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")

Return(oReport)


//-------------------------------------------------------------------
/*/{Protheus.doc} RepPrint2
Realiza a impressão do relatório

@author  Henrique Baldin
@since   04/06/2014


/*/
//-------------------------------------------------------------------
Static Function RepPrint2(oReport)

Local oSection  := oReport:Section(1)

Local aCampos   := {}
Local aEstru    := {}
Local aEstru2   := {}
Local aValores	:= {}

Local nI        := 0
Local cUnidade  :=""

Private cDataINI  := DTOS(MV_PAR01)
Private cDataFIM  := DTOS(MV_PAR02)


If ( SELECT("SB7TMP") ) > 0
	dbSelectArea("SB7TMP")
	SB7TMP->(dbCloseArea())
EndIf

cQuery := " SELECT ISNULL(D3_QUANT,0) D3_QUANT, D3_CUSTO1, D3_CF, B7_FILIAL,B7_COD,B7_LOCAL,B7_DATA,B7_QUANT,B7_SSALDO , B1_UM,B1_DESC
cQuery += " FROM "+RetSQLName("SB7")+" SB7
cQuery += " INNER JOIN "+RetSQLName("SB1")+" B1 ON B1.B1_FILIAL = ' ' AND B1.B1_COD = SB7.B7_COD   AND B1.D_E_L_E_T_ <> '*'
cQuery += " LEFT JOIN "+RetSQLName("SD3")+" SD3 ON D3_FILIAL = B7_FILIAL AND D3_COD = B7_COD AND D3_LOCAL = B7_LOCAL AND D3_EMISSAO = B7_DATA AND D3_DOC = 'INVENT' AND SD3.D_E_L_E_T_ <> '*'
cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"' "
cQuery += " 	AND B7_DATA >= '"+cDataINI+"' "
cQuery += " 	AND B7_DATA <= '"+cDataFIM+"' "
cQuery += " 	AND SB7.D_E_L_E_T_ =' '

TCQUERY cQuery NEW ALIAS "SB7TMP"

oReport:SetMeter(0)

SB7TMP->(DBGotop())

oSection:Init()

Do While SB7TMP->(!EOF())
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	nSaldoS   := SB7TMP->B7_SSALDO
	
	aValores  := CalcEst( SB7TMP->B7_COD, SB7TMP->B7_LOCAL, StoD(SB7TMP->B7_DATA) + 1 )
	
	nVunit := aValores[2] / aValores[1]
	
	nValsist := Round( nSaldoS * nVunit, 2 )
	nValfis  := Round( SB7TMP->B7_QUANT * nVunit, 2 )
	
	If SB7TMP->D3_QUANT > 0
		nDifVal  :=	SB7TMP->D3_CUSTO1 * IIF( Substr(SB7TMP->D3_CF,1,2) == "RE", -1, 1)
	Else
		nDifVal  := 0
	EndIf
	
	nTotSIS += nValsist
	nTotFIS	+= nValfis
	
	If nValfis <> nValsist
		If (nValsist - nValfis) < 0
			ndif += (nValfis - nValsist)
		Else
			ndif += (nValsist - nValfis)
		endif
	endif
	
	If SB7TMP->D3_QUANT > 0
		nDifAux1 := ""
		nDifAux2 := SB7TMP->D3_QUANT
	Else
		nDifAux1 := SB7TMP->B7_QUANT - nSaldoS
		nDifAux2 := 0
	EndIf
	
	oSection:Cell("FILIAL"):SetValue( SB7TMP->B7_FILIAL )
	oSection:Cell("PRODUT"):SetValue( SB7TMP->B7_COD )
	oSection:Cell("DESCRI"):SetValue( SB7TMP->B1_DESC )
	oSection:Cell("ARMAZE"):SetValue( SB7TMP->B7_LOCAL )
	oSection:Cell("UNIDME"):SetValue( SB7TMP->B1_UM )
	oSection:Cell("SLDSIS"):SetValue( nSaldoS )
	oSection:Cell("SLDFIS"):SetValue( SB7TMP->B7_QUANT )
	oSection:Cell("<>DFS1"):SetValue( IIF(SB7TMP->D3_QUANT>0,"",nDifAux1))
	oSection:Cell("<>DFS2"):SetValue( nDifAux2 )
	oSection:Cell("VLRSIS"):SetValue( nValsist )
	oSection:Cell("VLRFIS"):SetValue( nValfis )
	oSection:Cell("<>VALO"):SetValue( Round( nDifVal, 2 ) )
	
	oSection:PrintLine()
	oReport:SkipLine()
	
	SB7TMP->(DBSkip())
	
enddo

oReport:SkipLine()
oReport:SkipLine()

oReport:PrintText("Total Sistema:............."+AllTrim(Transform(nTotSIS,"@E 99,999,999.99")))
oReport:PrintText("Total fisico..............."+AllTrim(Transform(nTotFIS,"@E 99,999,999.99")))
oReport:PrintText("Total Diferença............"+AllTrim(Transform(ndif,"@E 99,999,999.99")))
nAcur := ( 1-(ndif/nTotSIS) ) *100
oReport:PrintText("ACURACIDADE DE ESTOQUE....."+AllTrim(Transform(nAcur,"@E 99,999,999.99")) + "%" )
oReport:SkipLine()
oReport:PrintText("Data De:"+DTOC(MV_PAR01)+"  Data Até:"+DTOC(MV_PAR02))

oSection:Finish()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} cAcEstOld
Relatório de Acuracidade de estoque

@author  Henrique Baldin
@since   04/06/2014

// Alteração 1
18/07/2014
Criado campo b7_ssaldo, saldo atual, pois era lancada nota com data
retroativa, e zicava toda a Acuracidade.

Versão antiga para comparação - Solicitado por Kleber
/*/
//-------------------------------------------------------------------
User Function cAcEstOld()

Local oReport

Private cPerg := "CACUREST"

Private nTotFis   := 0
Private nTotSis   := 0
Private ndif      := 0
Private nCTBD     := 0
Private nCTBC     := 0
Private nDifPG    := 0

Private nTotalNF  := 0
Private nTotalCT  := 0
Private nDifeTOT  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Data de                               ³
//³ mv_par02               Data ate                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Carregamento das Perguntas
//AjustaSX1()

If !Pergunte(cPerg,.T.)
	Return
EndIf

If MV_PAR01 >= StoD("20150301") // Alterações em 27/02/2015 - Smaha 
	oReport := ReportDef3() // Novo layout considerando o campo D3_XSSALDO
Else
	oReport := ReportDef4() // Layout anterior, considerando o campo B7_SSALDO
EndIf	

oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef1
Estrutura do Relatório

@author  Henrique baldin
@since   08/04/2013

/*/
//-------------------------------------------------------------------
Static Function ReportDef3()

Local cTitle    := OemToAnsi("RELATORIO DE ACURACIDADE DE ESTOQUE (ANTIGO)")
Local cHelp     := OemToAnsi("RELATORIO DE ACURACIDADE DE ESTOQUE (ANTIGO)")

Local oReport
Local oSection
Local oSection1

oReport := tReport():New("cAcEstOld",cTitle,cPerg,{|oReport| RepPrint3(oReport)}, )


oReport:SetLandscape()
oReport:HideParamPage()


oSection  := trSection():New(oReport,"Acuracidade Estoque",,,,,,,.F.)

trCell():New(oSection,"FILIAL"," ","Filial"    ,PesqPict("SB7","B7_FILIAL"),TamSx3("B7_FILIAL")[1] )
trCell():New(oSection,"PRODUT"," ","PRODUTO"   ,PesqPict("SB1","B1_COD"), 	TamSx3("B1_COD")[1] )
trCell():New(oSection,"DESCRI"," ","DESCRICAO" ,PesqPict("SB1","B1_DESC"), 	TamSx3("B1_DESC")[1] )
trCell():New(oSection,"ARMAZE"," ","ARMAZEM"   ,PesqPict("SB1","B1_LOCPAD"),TamSx3("B1_LOCPAD")[1] )
trCell():New(oSection,"UNIDME"," ","UM"        ,PesqPict("SB1","B1_UM"), 	TamSx3("B1_UM")[1] )
trCell():New(oSection,"SLDSIS"," ","SALDO_SIST",,TamSx3("D3_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"SLDFIS"," ","SALDO_FIS" ,,TamSx3("D3_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>SALD"," ","<> SALDO"  ,,TamSx3("D3_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"VLRSIS"," ","VALOR_SIST",,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"VLRFIS"," ","VALOR_FIS" ,,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>VALO"," ","<> VALOR"  ,,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")

Return(oReport)


//-------------------------------------------------------------------
/*/{Protheus.doc} RepPrint1
Realiza a impressão do relatório

@author  Henrique Baldin
@since   04/06/2014


/*/
//-------------------------------------------------------------------
Static Function RepPrint3(oReport)

Local oSection  := oReport:Section(1)

Local aCampos   := {}
Local aEstru    := {}
Local aEstru2   := {}
Local aValores	:= {}

Local nI        := 0
Local cUnidade  :=""

Private cDataINI  := DTOS(MV_PAR01)
Private cDataFIM  := DTOS(MV_PAR02)


If ( SELECT("SD3TMP") ) > 0
	dbSelectArea("SD3TMP")
	SD3TMP->(dbCloseArea())
EndIf 

cQuery := " SELECT D3_FILIAL, D3_QUANT, D3_CUSTO1, D3_CF, D3_EMISSAO, D3_COD, D3_LOCAL, D3_XSSALDO, D3_CUSTO1, D3_CF, B1_DESC, B1_UM "
cQuery += " FROM "+RetSQLName("SD3")+" SD3 "
cQuery += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = D3_COD AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
cQuery += " 	AND D3_EMISSAO BETWEEN '"+cDataINI+"' AND '"+cDataFIM+"' "
cQuery += " 	AND D3_DOC = 'INVENT' " 
cQuery += " 	AND SD3.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D3_FILIAL,D3_COD "

TCQUERY cQuery NEW ALIAS "SD3TMP"

oReport:SetMeter(0)

SD3TMP->(DBGotop())

oSection:Init()

Do While SD3TMP->(!EOF())
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	If Substr(SD3TMP->D3_CF,1,2) == "RE"
	 	nSaldoF := SD3TMP->D3_XSSALDO - SD3TMP->D3_QUANT 
	Else
  		nSaldoF := SD3TMP->D3_XSSALDO + SD3TMP->D3_QUANT 
	EndIf
	
	nSaldoS   := SD3TMP->D3_XSSALDO  	
	
	aValores  := CalcEst( SD3TMP->D3_COD, SD3TMP->D3_LOCAL, StoD(SD3TMP->D3_EMISSAO) + 1 )
	
	nVunit := aValores[2] / aValores[1]
	
	nValSist := Round( nSaldoS * nVunit, 2 )
	nValFis  := Round( nSaldoF * nVunit, 2 )
	
	ndifval :=	(nValFis - nValSist )
	
	nTotSIS += nValSist
	nTotFIS	+= nValFis
	
	If nValFis <> nValSist
		If (nValSist - nValFis) < 0
			ndif += (nValFis - nValSist)
		Else
			ndif += (nValSist - nValFis)
		endif
	endif
	
	oSection:Cell("FILIAL"):SetValue( SD3TMP->D3_FILIAL )
	oSection:Cell("PRODUT"):SetValue( SD3TMP->D3_COD )
	oSection:Cell("DESCRI"):SetValue( SD3TMP->B1_DESC )
	oSection:Cell("ARMAZE"):SetValue( SD3TMP->D3_LOCAL )
	oSection:Cell("UNIDME"):SetValue( SD3TMP->B1_UM )
	oSection:Cell("SLDSIS"):SetValue( nSaldoS )
	oSection:Cell("SLDFIS"):SetValue( nSaldoF )
	oSection:Cell("<>SALD"):SetValue( nSaldoF - nSaldoS )
	oSection:Cell("VLRSIS"):SetValue( nValSist )
	oSection:Cell("VLRFIS"):SetValue( nValFis )
	oSection:Cell("<>VALO"):SetValue( Round( nDifVal, 2 ) )
	 
	oSection:PrintLine()
	oReport:SkipLine()
	
	SD3TMP->(DBSkip())
	
EndDo

oReport:SkipLine()
oReport:SkipLine()

oReport:PrintText("Total Sistema:............."+AllTrim(Transform(nTotSIS,"@E 99,999,999.99")))
oReport:PrintText("Total fisico..............."+AllTrim(Transform(nTotFIS,"@E 99,999,999.99")))
oReport:PrintText("Total Diferença............"+AllTrim(Transform(ndif,"@E 99,999,999.99")))
nAcur := ( 1-(ndif/nTotSIS) ) *100
oReport:PrintText("ACURACIDADE DE ESTOQUE....."+AllTrim(Transform(nAcur,"@E 99,999,999.99")) + "%" )
oReport:SkipLine()
oReport:PrintText("Data De:"+DTOC(MV_PAR01)+"  Data Até:"+DTOC(MV_PAR02))

oSection:Finish()

Return

 
          
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef2
Estrutura do Relatório

@author  Henrique baldin
@since   08/04/2013

/*/
//-------------------------------------------------------------------
Static Function ReportDef4()

Local cTitle    := OemToAnsi("RELATORIO DE ACURACIDADE DE ESTOQUE (ANTIGO)")
Local cHelp     := OemToAnsi("RELATORIO DE ACURACIDADE DE ESTOQUE (ANTIGO)")

Local oReport
Local oSection
Local oSection1

oReport := tReport():New("cAcurEst",cTitle,cPerg,{|oReport| RepPrint4(oReport)}, )


oReport:SetLandscape()
oReport:HideParamPage()


oSection  := trSection():New(oReport,"Acuracidade Estoque",,,,,,,.F.)

trCell():New(oSection,"FILIAL"," ","Filial"    ,PesqPict("SB7","B7_FILIAL"),TamSx3("B7_FILIAL")[1] )
trCell():New(oSection,"PRODUT"," ","PRODUTO"   ,PesqPict("SB1","B1_COD"), 	TamSx3("B1_COD")[1] )
trCell():New(oSection,"DESCRI"," ","DESCRICAO" ,PesqPict("SB1","B1_DESC"), 	TamSx3("B1_DESC")[1] )
trCell():New(oSection,"ARMAZE"," ","ARMAZEM"   ,PesqPict("SB1","B1_LOCPAD"),TamSx3("B1_LOCPAD")[1] )
trCell():New(oSection,"UNIDME"," ","UM"        ,PesqPict("SB1","B1_UM"), 	TamSx3("B1_UM")[1] )
trCell():New(oSection,"SLDSIS"," ","SALDO_SIST",,TamSx3("B7_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"SLDFIS"," ","SALDO_FIS" ,,TamSx3("B7_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>DFS1"," ","<>_SALDO"  ,,TamSx3("B7_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>DFS2"," ","SALDO MOV" ,,TamSx3("B7_QUANT")[1] ,,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"VLRSIS"," ","VALOR_SIST",,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"VLRFIS"," ","VALOR_FIS" ,,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")
trCell():New(oSection,"<>VALO"," ","<>_VALOR"  ,,TamSx3("D3_CUSTO1")[1],,/*{||  aItens[nI][6] }*/,,,"RIGHT")

Return(oReport)


//-------------------------------------------------------------------
/*/{Protheus.doc} RepPrint2
Realiza a impressão do relatório

@author  Henrique Baldin
@since   04/06/2014


/*/
//-------------------------------------------------------------------
Static Function RepPrint4(oReport)

Local oSection  := oReport:Section(1)

Local aCampos   := {}
Local aEstru    := {}
Local aEstru2   := {}
Local aValores	:= {}

Local nI        := 0
Local cUnidade  :=""

Private cDataINI  := DTOS(MV_PAR01)
Private cDataFIM  := DTOS(MV_PAR02)


If ( SELECT("SB7TMP") ) > 0
	dbSelectArea("SB7TMP")
	SB7TMP->(dbCloseArea())
EndIf

cQuery := " SELECT ISNULL(D3_QUANT,0) D3_QUANT, D3_CUSTO1, D3_CF, B7_FILIAL,B7_COD,B7_LOCAL,B7_DATA,B7_QUANT,B7_SSALDO , B1_UM,B1_DESC
cQuery += " FROM "+RetSQLName("SB7")+" SB7
cQuery += " INNER JOIN "+RetSQLName("SB1")+" B1 ON B1.B1_FILIAL = ' ' AND B1.B1_COD = SB7.B7_COD   AND B1.D_E_L_E_T_ <> '*'
cQuery += " LEFT JOIN "+RetSQLName("SD3")+" SD3 ON D3_FILIAL = B7_FILIAL AND D3_COD = B7_COD AND D3_LOCAL = B7_LOCAL AND D3_EMISSAO = B7_DATA AND D3_DOC = 'INVENT' AND SD3.D_E_L_E_T_ <> '*'
cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"' "
cQuery += " 	AND B7_DATA >= '"+cDataINI+"' "
cQuery += " 	AND B7_DATA <= '"+cDataFIM+"' "
cQuery += " 	AND SB7.D_E_L_E_T_ =' '

TCQUERY cQuery NEW ALIAS "SB7TMP"

oReport:SetMeter(0)

SB7TMP->(DBGotop())

oSection:Init()

Do While SB7TMP->(!EOF())
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	nSaldoS   := SB7TMP->B7_SSALDO
	
	aValores  := CalcEst( SB7TMP->B7_COD, SB7TMP->B7_LOCAL, StoD(SB7TMP->B7_DATA) + 1 )
	
	nVunit := aValores[2] / aValores[1]
	
	nValsist := Round( nSaldoS * nVunit, 2 )
	nValfis  := Round( SB7TMP->B7_QUANT * nVunit, 2 )
	
	If SB7TMP->D3_QUANT > 0
		nDifVal  :=	SB7TMP->D3_CUSTO1 * IIF( Substr(SB7TMP->D3_CF,1,2) == "RE", -1, 1)
	Else
		nDifVal  := 0
	EndIf
	
	nTotSIS += nValsist
	nTotFIS	+= nValfis
	
	If nValfis <> nValsist
		If (nValsist - nValfis) < 0
			ndif += (nValfis - nValsist)
		Else
			ndif += (nValsist - nValfis)
		endif
	endif
	
	If SB7TMP->D3_QUANT > 0
		nDifAux1 := ""
		nDifAux2 := SB7TMP->D3_QUANT
	Else
		nDifAux1 := SB7TMP->B7_QUANT - nSaldoS
		nDifAux2 := 0
	EndIf
	
	oSection:Cell("FILIAL"):SetValue( SB7TMP->B7_FILIAL )
	oSection:Cell("PRODUT"):SetValue( SB7TMP->B7_COD )
	oSection:Cell("DESCRI"):SetValue( SB7TMP->B1_DESC )
	oSection:Cell("ARMAZE"):SetValue( SB7TMP->B7_LOCAL )
	oSection:Cell("UNIDME"):SetValue( SB7TMP->B1_UM )
	oSection:Cell("SLDSIS"):SetValue( nSaldoS )
	oSection:Cell("SLDFIS"):SetValue( SB7TMP->B7_QUANT )
	oSection:Cell("<>DFS1"):SetValue( IIF(SB7TMP->D3_QUANT>0,"",nDifAux1))
	oSection:Cell("<>DFS2"):SetValue( nDifAux2 )
	oSection:Cell("VLRSIS"):SetValue( nValsist )
	oSection:Cell("VLRFIS"):SetValue( nValfis )
	oSection:Cell("<>VALO"):SetValue( Round( nDifVal, 2 ) )
	
	oSection:PrintLine()
	oReport:SkipLine()
	
	SB7TMP->(DBSkip())
	
enddo

oReport:SkipLine()
oReport:SkipLine()

oReport:PrintText("Total Sistema:............."+AllTrim(Transform(nTotSIS,"@E 99,999,999.99")))
oReport:PrintText("Total fisico..............."+AllTrim(Transform(nTotFIS,"@E 99,999,999.99")))
oReport:PrintText("Total Diferença............"+AllTrim(Transform(ndif,"@E 99,999,999.99")))
nAcur := ( 1-(ndif/nTotSIS) ) *100
oReport:PrintText("ACURACIDADE DE ESTOQUE....."+AllTrim(Transform(nAcur,"@E 99,999,999.99")) + "%" )
oReport:SkipLine()
oReport:PrintText("Data De:"+DTOC(MV_PAR01)+"  Data Até:"+DTOC(MV_PAR02))

oSection:Finish()

Return