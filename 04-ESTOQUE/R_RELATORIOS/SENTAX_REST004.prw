#INCLUDE "MATR480.CH" 
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR480  ³ Autor ³ Nereu Humberto Junior ³ Data ³ 16.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Controle de Materiais de Terceiros em nosso po-³±±
±±³          ³der e nosso Material em poder de Terceiros.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR480(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function REST004()

Local oReport

If  TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	//MATR480R3()
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Nereu Humberto Junior  ³ Data ³16.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(nReg)

Local oReport 
Local oSection1
Local oSection2 
Local oSection3 
Local oCell         
Local aOrdem := {}
Local cTamVal:= TamSX3('B6_CUSTO1' )[1]
Local cTamQtd:= TamSX3('B6_QUANT' )[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("REST004",STR0009,"REST004", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002+" "+STR0003) //"Relacao de materiais de Terceiros e em Terceiros"##"Este programa ira emitir o Relatorio de Materiais"##"de Terceiros em nosso poder e/ou nosso Material em"##"poder de Terceiros."
oReport:SetLandscape()    
oReport:SetTotalInLine(.F.)

Pergunte("REST004",.F.)

Aadd( aOrdem, STR0004 ) //" Produto/Local " 
Aadd( aOrdem, STR0005 ) //" Cliente/Fornecedor " 
Aadd( aOrdem, STR0006 ) //" Dt. Mov/Produto " 

oSection1 := TRSection():New(oReport,STR0052,{"SB6"},aOrdem) //"Relacao de materiais de Terceiros e em Terceiros"
oSection1 :SetTotalInLine(.F.)

TRCell():New(oSection1,"B1_COD"		,"SB1"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_DESC"	,"SB1"	,/*Titulo*/	,/*Picture*/,30				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B6_LOCAL"	,"SB6"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"cVendedor"	,"   "	,"Vendedor"	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"cCliFor"	,"   "	,/*Titulo*/	,/*Picture*/,6				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"cLoja"		,"   "	,/*Titulo*/	,/*Picture*/,2				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"cNome"		,"   "	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("cNome"):GetFieldInfo("A2_NOME")
TRCell():New(oSection1,"B6_EMISSAO"	,"SB6"	,STR0038	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,{|| (cAliasSB6)->B6_EMISSAO }) //"DATA DE MOVIMENTACAO : "

oSection2 := TRSection():New(oSection1,STR0053,{"SB6"}) //"Relacao de materiais de Terceiros e em Terceiros"
oSection2 :SetTotalInLine(.F.)
oSection2 :SetHeaderPage()

TRCell():New(oSection2,"B6_LOCAL"	,"SB6"	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B6_PRODUTO"	,"SB6",/*Titulo*/			,/*Picture*/				,15			,/*lPixel*/,{|| (cAliasSB6)->B6_PRODUTO })
TRCell():New(oSection2,"B1_DESC"	,"SB1"	,/*Titulo*/	,/*Picture*/,30				,/*lPixel*/,/*{|| code-block de impressao }*/)		
TRCell():New(oSection2,"B6_TPCF"	,"SB6",/*Titulo*/			,/*Picture*/				,/*Tamanho*/,/*lPixel*/,{|| IIf((cAliasSB6)->B6_TPCF == "C",STR0018,STR0019) })
TRCell():New(oSection2,"B6_CLIFOR"	,"SB6",/*Titulo*/			,/*Picture*/				,TamSX3('B6_CLIFOR' )[1]+5,/*lPixel*/,{|| (cAliasSB6)->B6_CLIFOR })
TRCell():New(oSection2,"B6_LOJA"	,"SB6",/*Titulo*/			,/*Picture*/				,/*Tamanho*/,/*lPixel*/,{|| (cAliasSB6)->B6_LOJA })

TRCell():New(oSection2,"cNome"		,"   "	,/*Titulo*/	,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection2:Cell("cNome"):GetFieldInfo("A2_NOME")

TRCell():New(oSection2,"B6_DOC"		,"SB6",/*Titulo*/			,/*Picture*/				,/*Tamanho*/,/*lPixel*/,{|| (cAliasSB6)->B6_DOC },,,,,,.F.)
TRCell():New(oSection2,"B6_SERIE"	,"SB6",/*Titulo*/			,/*Picture*/				,/*Tamanho*/,/*lPixel*/,{|| (cAliasSB6)->B6_SERIE })
TRCell():New(oSection2,"B6_EMISSAO"	,"SB6",/*Titulo*/			,/*Picture*/				,/*Tamanho*/,/*lPixel*/,{|| (cAliasSB6)->B6_EMISSAO })
TRCell():New(oSection2,"B6_QUANT"	,"SB6",STR0042+CRLF+STR0043	,/*Picture*/				,/*Tamanho*/,/*lPixel*/,{|| If(mv_par15==1,ConvUM((cAliasSB6)->B6_PRODUTO,(cAliasSB6)->B6_QUANT,0,2),(cAliasSB6)->B6_QUANT) }) //"Quantidade"##"Original"
TRCell():New(oSection2,"nQuJe"		,"   ",STR0042+CRLF+STR0044	,PesqPict("SB6","B6_QUANT")	,cTamQtd	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Quantidade"##"Ja entregue"				
TRCell():New(oSection2,"nSaldo"		,"   ","|"+space(cTamQtd-len(STR0045)-2)+STR0045+CRLF+"|"+space(ctamqtd),         							 PesqPict("SB6", "B6_QUANT"),cTamQtd	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Saldo"
TRCell():New(oSection2,"nTotNF"		,"   ","|"+space(cTamVal-len(STR0046)-2)+STR0046+CRLF+"|"+space(cTamVal-len(STR0047)-2)+STR0047,			 '@E 99,999,999,999.99'		,cTamVal	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Total"##"N.Fiscal"
TRCell():New(oSection2,"nTotDev"	,"   ","|"+space(cTamVal-len(STR0046)-2)+STR0046+CRLF+"|"+space(cTamVal-len(STR0048)-2)+STR0048,			 '@E 99,999,999,999.99'		,cTamVal	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Total"##"Devolvido"
TRCell():New(oSection2,"nCusto"		,"   ","|"+space(cTamVal-len(STR0049)-2)+STR0049+"  |"+CRLF+"|"+space(cTamVal-len(STR0050)-2)+STR0050+"  |"	,'@E 999,999,999.99'		,cTamVal	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Custo"##"Prod."
TRCell():New(oSection2,"B6_TIPO"	,"SB6",STR0051				,/*Picture*/				,cTamVal-10,/*lPixel*/,{|| IIF((cAliasSB6)->B6_TIPO=="D","D","E") }) //"TM"
TRCell():New(oSection2,"B6_DTDIGIT"	,"SB6",/*Titulo*/			,/*Picture*/				,/*Tamanho*/,/*lPixel*/,{|| (cAliasSB6)->B6_DTDIGIT })				
TRCell():New(oSection2,"B6_UENT"	   ,"SB6",/*Titulo*/			,/*Picture*/				,/*Tamanho*/,/*lPixel*/,{|| (cAliasSB6)->B6_UENT })

TRFunction():New(oSection2:Cell("B6_QUANT")	,NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/				,/*uFormula*/,.T.,.T.,,oSection1) 
TRFunction():New(oSection2:Cell("nQuJe")	,NIL,"SUM",/*oBreak*/,/*Titulo*/,PesqPict("SB6","B6_QUANT")	,/*uFormula*/,.T.,.T.,,oSection1)
TRFunction():New(oSection2:Cell("nSaldo")	,NIL,"SUM",/*oBreak*/,/*Titulo*/,PesqPict("SB6","B6_QUANT")	,/*uFormula*/,.T.,.T.,,oSection1)
TRFunction():New(oSection2:Cell("nTotNF")	,NIL,"SUM",/*oBreak*/,/*Titulo*/,'@E 99,999,999,999.99'		,/*uFormula*/,.T.,.T.,,oSection1)
TRFunction():New(oSection2:Cell("nTotDev")	,NIL,"SUM",/*oBreak*/,/*Titulo*/,'@E 99,999,999,999.99'		,/*uFormula*/,.T.,.T.,,oSection1)
TRFunction():New(oSection2:Cell("nCusto")	,NIL,"SUM",/*oBreak*/,/*Titulo*/,'@E 999,999,999.99'		,/*uFormula*/,.T.,.T.,,oSection1)

oSection3 := TRSection():New(oSection2,STR0054,{"SB6"}) //"Relacao de materiais de Terceiros e em Terceiros"
oSection3 :SetTotalInLine(.F.)

TRCell():New(oSection3,"B6_PRODUTO"	,"SB6",/*Titulo*/			,/*Picture*/					,15				,/*lPixel*/,{|| (cAliasSB6)->B6_PRODUTO })
TRCell():New(oSection3,"B6_TPCF"	,"SB6",/*Titulo*/			,/*Picture*/					,/*Tamanho*/	,/*lPixel*/,{|| IIf((cAliasSB6)->B6_TPCF == "C",STR0018,STR0019) })
TRCell():New(oSection3,"B6_CLIFOR"	,"SB6",/*Titulo*/			,/*Picture*/					,15				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B6_LOJA"	,"SB6",/*Titulo*/			,/*Picture*/					,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B6_DOC"		,"SB6",/*Titulo*/			,/*Picture*/					,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection3,"B6_SERIE"	,"SB6",SerieNfId("SB6",7,"B6_SERIE"),/*Picture*/,SerieNfId("SB6",6,"B6_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B6_EMISSAO","SB6",/*Titulo*/			,/*Picture*/					,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"B6_QUANT"	,"SB6",STR0042+CRLF+STR0043	,/*Picture*/					,/*Tamanho*/	,/*lPixel*/,{|| If(mv_par15==1,ConvUM((cAliasSB6)->B6_PRODUTO,(cAliasSB6)->B6_QUANT,0,2),(cAliasSB6)->B6_QUANT) }) //"Quantidade"##"Original"
TRCell():New(oSection3,"nQuJe"		,"   ",STR0042+CRLF+STR0044	,PesqPict("SB6","B6_QUANT")		,cTamQtd		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Quantidade"##"Ja entregue"				
TRCell():New(oSection3,"nSaldo"		,"   ","|"+space(cTamQtd-len(STR0045)-2)+STR0045+CRLF+"|"+space(ctamqtd)									,PesqPict("SB6", "B6_QUANT")	,cTamQtd		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Saldo"
TRCell():New(oSection3,"nTotNF"		,"   ","|"+space(cTamVal-len(STR0046)-2)+STR0046+CRLF+"|"+space(cTamVal-len(STR0047)-2)+STR0047,			'@E 99,999,999,999.99'			,cTamVal		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Total"##"N.Fiscal"
TRCell():New(oSection3,"nTotDev"	,"   ","|"+space(cTamVal-len(STR0046)-2)+STR0046+CRLF+"|"+space(cTamVal-len(STR0048)-2)+STR0048,			'@E 99,999,999,999.99'			,cTamVal		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Total"##"Devolvido"
TRCell():New(oSection3,"nCusto"		,"   ","|"+space(cTamVal-len(STR0049)-5)+STR0049+"  |"+CRLF+"|"+space(cTamVal-len(STR0050)-2)+STR0050+"  |"	,'@E 999,999,999.99'			,cTamVal		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Custo"##"Prod."
TRCell():New(oSection3,"B6_TIPO"	,"SB6","TM"				,/*Picture*/					,cTamVal-10	,/*lPixel*/,{|| IIF((cAliasSB6)->B6_TIPO=="D","D","E") }) //"TM"
TRCell():New(oSection3,"B6_DTDIGIT"	,"SB6",/*Titulo*/			,/*Picture*/					,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)				
TRCell():New(oSection3,"B6_UENT"	,"SB6",/*Titulo*/			,/*Picture*/					,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Nereu Humberto Junior  ³ Data ³16.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(1):Section(1)  
Local oSection3 := oReport:Section(1):Section(1):Section(1)  
Local nOrdem    := oReport:GetOrder() 
Local lListCustM:= .T.
Local lCusFIFO  := GetMV('MV_CUSFIFO')
Local cProdLOCAL:= ""
Local cCliFor   := ""
Local cCliForAnt:= ""
Local cFilUser := oSection1:GetAdvplExp()
Local lImprime  := .F.
Local lFirstRec := .T.
Local lPlanilha := oReport:nDevice == 4
Local lPlanTab  := oReport:lXlsTable == .T.
Local lFound    := .F.
Local nX        := 0
Local aStrucSB6 := {}
Private cAliasSB6 := "SB6"

lListCustM := (mv_par16==1)

dbSelectArea("SB6")
dbSetOrder(nOrdem)

If nOrdem == 1
	oSection1 :SetTotalText(STR0020) //"TOTAL DESTE PRODUTO / LOCAL ------ >"
	If mv_par10 == 1
		oReport:SetTitle(STR0010) //"RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - PRODUTO / LOCAL"
	ElseIf mv_par10 == 2
		oReport:SetTitle(STR0011) //"RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - PRODUTO / LOCAL"
	Else
		oReport:SetTitle(STR0012) //"RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - PRODUTO / LOCAL"
	EndIf
ElseIf nOrdem == 2
	oSection1 :SetTotalText(STR0032) //"TOTAL DO PRODUTO NO "
	If mv_par10 == 1
		oReport:SetTitle(STR0023) //"RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - CLIENTE / FORNECEDOR"
	ElseIf mv_par10 == 2
		oReport:SetTitle(STR0024) //"RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - CLIENTE / FORNECEDOR"
	Else
		oReport:SetTitle(STR0025) //"RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - CLIENTE / FORNECEDOR"
	EndIf
ElseIf nOrdem == 3
	oSection2:Cell("B6_DOC"):SetSize(12)
	oSection3:Cell("B6_DOC"):SetSize(12)
	oSection2:Cell("B6_DOC"):SetLineBreak() 
	oSection3:Cell("B6_DOC"):SetLineBreak() 
	oSection1 :SetTotalText(STR0040) //"TOTAL DO PRODUTO NA DATA --------- >"
	If mv_par10 == 1
		oReport:SetTitle(STR0033) //"RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - DATA DO MOVIMENTO"
	ElseIf mv_par10 == 2
		oReport:SetTitle(STR0034) //"RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - DATA DO MOVIMENTO"
	Else
		oReport:SetTitle(STR0035) //"RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - DATA DO MOVIMENTO"
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(SB6->(LastRec()))

cAliasSB6 := GetNextAlias()
aStrucSB6 := SB6->(dbStruct())      
cQuery := " SELECT SB6.*, SB6.R_E_C_N_O_ AS RECNO, SF4.F4_PODER3
cQuery += " FROM " + RetSqlName("SB6") + " SB6"
cQuery += " JOIN " + RetSqlName("SF4") + " SF4"
cQuery += " ON SF4.F4_FILIAL = '"   + xFilial("SF4") + "' "
cQuery += " AND SF4.F4_CODIGO = SB6.B6_TES AND SF4.F4_PODER3 <> 'D' "
cQuery += " AND SF4.D_E_L_E_T_ = ' ' "

// Filtro por Vendedor 
If !Empty(MV_PAR17)
	cQuery += " JOIN "+ RetSqlName("SA1") +" SA1"
	cQuery += "  ON SA1.A1_COD = SB6.B6_CLIFOR
	cQuery += " AND SA1.A1_LOJA = SB6.B6_LOJA
	cQuery += " AND SA1.D_E_L_E_T_ != '*'
	cQuery += " AND SA1.A1_VEND = '"+ MV_PAR17 +"'
EndIf

cQuery += " WHERE SB6.B6_FILIAL = '"   + xFilial("SB6") + "' "
cQuery += " AND ((SB6.B6_TPCF = 'C' AND B6_CLIFOR >= '" + mv_par01 + "' AND B6_CLIFOR <= '" + mv_par02 + "' ) "
cQuery += " OR  ( SB6.B6_TPCF = 'F' AND B6_CLIFOR >= '" + mv_par03 + "' AND B6_CLIFOR <= '" + mv_par04 + "' ))"
cQuery += " AND SB6.B6_PRODUTO >= '" + mv_par05 + "' "
cQuery += " AND SB6.B6_PRODUTO <= '" + mv_par06 + "' "
cQuery += " AND SB6.B6_DTDIGIT >= '"+ DTOS(mv_par07) +"' AND SB6.B6_DTDIGIT <= '" + DTOS(mv_par08) + "' "
If mv_par10 == 1
	cQuery  += " AND SB6.B6_TIPO = 'D' "
ElseIf mv_par10 == 2
	cQuery  += " AND SB6.B6_TIPO = 'E' "
EndIf
cQuery   += " AND SB6.B6_QUANT <> 0 AND SB6.D_E_L_E_T_ = ' ' "

If nOrdem == 1
	cQuery += " ORDER BY B6_FILIAL, B6_PRODUTO, B6_LOCAL "
ElseIf nOrdem == 2
	cQuery += " ORDER BY B6_FILIAL,B6_TPCF,B6_CLIFOR,B6_LOJA,B6_PRODUTO "
Else	
	cQuery += " ORDER BY B6_FILIAL,B6_DTDIGIT,B6_PRODUTO,B6_CLIFOR,B6_LOJA"
EndIf

cQuery := ChangeQuery(cQuery)
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSB6,.F.,.T.)},STR0069) //"Processando ..."

dbSelectArea(cAliasSB6)
For nX := 1 To Len(aStrucSB6)
	If ( aStrucSB6[nX][2] <> "C" .And. FieldPos(aStrucSB6[nX][1])<>0 )
		TcSetField(cAliasSB6,aStrucSB6[nX][1],aStrucSB6[nX][2],aStrucSB6[nX][3],aStrucSB6[nX][4])
	EndIf
Next

Do Case
	Case nOrdem == 1
		IF !lPlanTab
			oSection1:Cell("B6_EMISSAO"):Disable()
			oSection2:Cell("B6_PRODUTO"):Disable()
			oSection3:Cell("B6_PRODUTO"):Disable()
		EndIF
			
	Case nOrdem == 2
		If !lPlanilha
	    	oSection1:Cell("B1_COD" ):Disable()
	    	oSection1:Cell("B1_DESC"):Disable()
			oSection1:Cell("B6_LOCAL"  ):Disable()
    		oSection1:Cell("B6_EMISSAO"):Disable()
    	
    
			oSection2:Cell("B6_TPCF"   ):Disable()
			oSection2:Cell("B6_CLIFOR" ):Disable()
			oSection2:Cell("B6_LOJA"   ):Disable()		    
		
			oSection3:Cell("B6_TPCF"   ):Disable()
			oSection3:Cell("B6_CLIFOR" ):Disable()
			oSection3:Cell("B6_LOJA"   ):Disable()

	    	oSection2:Cell("cNome"):Disable()
		EndIf		

	Case nOrdem == 3
	    If !lPlanilha
	    	oSection1:Cell("B1_COD" ):Disable()
	    	oSection1:Cell("B1_DESC"):Disable()
	    EndIf
	   	IF !lPlanTab
		 	oSection1:Cell("B6_LOCAL"):Disable()
		 	//oSection1:Cell("cVendedor"):Disable()
			oSection1:Cell("cCliFor"):Disable()
	 	 	oSection1:Cell("cLoja"):Disable()
		 	oSection1:Cell("cNome"):Disable()
		EndIf
EndCase
		
While !oReport:Cancel() .And. !(cAliasSB6)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf
	
	oReport:IncMeter()
	
	If !Empty(cFilUser)
		SB6->(dbSetOrder(1))
	   	SB6->(dbSeek( xFilial("SB6")+(cAliasSB6)->B6_PRODUTO+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_IDENT))
	    If !(&(cFilUser))
	       (cAliasSB6)->(dbSkip())
	   	   Loop
	   	EndIf   
	EndIf
	
	aSaldo  := (cAliasSB6)->(CalcTerc(B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_IDENT,B6_TES,,mv_par07,mv_par08))
	nSaldo  := aSaldo[1]
	nPrUnit := IIF(aSaldo[3]==0,(cAliasSB6)->(B6_PRUNIT),aSaldo[3])
	
	If mv_par09 == 2 .And. nSaldo <= 0
		(cAliasSB6)->(dbSkip())
		Loop
	EndIf

	If nOrdem == 1
		cQuebra := (cAliasSB6)->(B6_PRODUTO+B6_LOCAL)
	ElseIf nOrdem == 2
		cQuebra := (cAliasSB6)->(B6_CLIFOR+B6_LOJA+B6_PRODUTO+B6_TPCF)
	ElseIf nOrdem == 3
		cQuebra := (cAliasSB6)->(Dtos(B6_EMISSAO)+B6_PRODUTO)
		lImprime := .T.
	Endif
	
	While !oReport:Cancel() .And. !(cAliasSB6)->(Eof()) .And. xFilial("SB6") == (cAliasSB6)->B6_FILIAL ;
	      .And. Iif(nOrdem==1,cQuebra == (cAliasSB6)->(B6_PRODUTO+B6_LOCAL),If(nOrdem==2,cQuebra == (cAliasSB6)->(B6_CLIFOR+B6_LOJA+B6_PRODUTO+B6_TPCF),cQuebra == (cAliasSB6)->(Dtos(B6_EMISSAO)+B6_PRODUTO)))

		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()
		
		aSaldo  := (cAliasSB6)->(CalcTerc(B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_IDENT,B6_TES,,mv_par07,mv_par08))
		nSaldo  := aSaldo[1]
		nPrUnit := IIF(aSaldo[3]==0,(cAliasSB6)->(B6_PRUNIT),aSaldo[3])
		
		If mv_par09 == 2 .And. nSaldo <= 0
			(cAliasSB6)->(dbSkip())
			Loop
		EndIf
		
		SB6->(MsGoto((cAliasSB6)->(RECNO)))

		If lPlanTab

			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+(cAliasSB6)->B6_PRODUTO))
			oSection2:Cell("B6_PRODUTO"):SetValue((cAliasSB6)->B6_PRODUTO)
			oSection2:Cell("B1_DESC"   ):SetValue(SB1->B1_DESC)
			oSection2:Cell("B6_LOCAL"  ):SetValue((cAliasSB6)->B6_LOCAL)

			If (cAliasSB6)->(B6_TPCF) == "C" 
				SA1->(MsSeek(xFilial("SA1")+(cAliasSB6)->(B6_CLIFOR+B6_LOJA)))
			Else
				SA2->(MsSeek(xFilial("SA2")+(cAliasSB6)->(B6_CLIFOR+B6_LOJA)))
			Endif	
			
			oSection2:Cell("cNome"):SetValue(Iif((cAliasSB6)->(B6_TPCF) == "C",SA1->A1_NOME,SA2->A2_NOME))
			
		Endif

		oSection1:Init()
		If nOrdem == 1
			If cProdLOCAL != (cAliasSB6)->(B6_PRODUTO+B6_LOCAL)
				If SB1->(dbSeek(xFilial("SB1")+(cAliasSB6)->B6_PRODUTO))
					If (cAliasSB6)->(B6_TPCF) == "C" 
						SA1->(MsSeek(xFilial("SA1")+(cAliasSB6)->(B6_CLIFOR+B6_LOJA)))
					Else
						SA2->(MsSeek(xFilial("SA2")+(cAliasSB6)->(B6_CLIFOR+B6_LOJA)))
					Endif	
					
					lFound := IIf((cAliasSB6)->(B6_TPCF) == "C", SA1->(!Eof()),SA2->(!Eof()) )
					
					If lFound
						dbSelectArea("SB6")
					  
						oSection1:Cell("cVendedor"):SetValue(Posicione("SA3",1,xFilial("SA3") + SA1->A1_VEND,"A3_NOME"))
						oSection1:Cell("cCliFor"):SetTitle(IIf((cAliasSB6)->(B6_TPCF) == "C",STR0028,STR0029)) //"CLIENTE / LOJA: "###"FORNECEDOR / LOJA: "
						oSection1:Cell("cCliFor"):SetValue(Iif((cAliasSB6)->(B6_TPCF) == "C",SA1->A1_COD,SA2->A2_COD))
						
						oSection1:Cell("cLoja"):SetValue(Iif((cAliasSB6)->(B6_TPCF) == "C",SA1->A1_LOJA,SA2->A2_LOJA))
						oSection1:Cell("cNome"):SetValue(Iif((cAliasSB6)->(B6_TPCF) == "C",SA1->A1_NOME,SA2->A2_NOME))
										
					EndIf
					oSection1:PrintLine()			
					cProdLOCAL := (cAliasSB6)->(B6_PRODUTO+B6_LOCAL)
				Else
					Help(" ",1,"R480PRODUT")
					dbSelectArea("SB6")
					Return .F.
				EndIf
			EndIf
			If !Empty(cProdLocal)
				
				oSection2:Init()
				
				oSection2:Cell("nQuJe"):SetValue(If(mv_par15==1,ConvUM((cAliasSB6)->B6_PRODUTO,((cAliasSB6)->B6_QUANT - nSaldo),0,2),((cAliasSB6)->B6_QUANT - nSaldo)))
				oSection2:Cell("nSaldo"):SetValue(If(mv_par15==1,ConvUm((cAliasSB6)->B6_PRODUTO,nSaldo,0,2),nSaldo))
				oSection2:Cell("nTotNF"):SetValue(round(aSaldo[5],2))
				oSection2:Cell("nTotDev"):SetValue((B6_QUANT - nSaldo) * nPrUnit)
				oSection2:Cell("B6_TIPO"):SetValue(B6_TIPO)
				// Custo na Moeda
				nCusto := (&(If(lListCustM.Or.(!lListCustM.And.!lCusFIFO), 'B6_CUSTO', 'B6_CUSFF')+Str(mv_par11,1,0)) / (cAliasSB6)->(B6_QUANT)) * nSaldo		
				oSection2:Cell("nCusto"):SetValue(nCusto)

				oSection2:PrintLine()
			Endif	
		ElseIf nOrdem == 2
			If cCliForAnt != (cAliasSB6)->(B6_TPCF) .Or. cNomeCliFor != (cAliasSB6)->(B6_CLIFOR+B6_LOJA)
				
				If (lPlanilha .And. !lFirstRec) 
					//oSection1:Cell("cVendedor"):Enable()
					oSection1:Cell("cCliFor"):Enable()
					oSection1:Cell("cLoja"):Enable()
					oSection1:Cell("cNome"):Enable()
					oSection1:Cell("B6_EMISSAO"):Enable()
				EndIf
				
				lFirstRec := .T.
				If (cAliasSB6)->(B6_TPCF) == "C" 
					SA1->(MsSeek(xFilial("SA1")+(cAliasSB6)->(B6_CLIFOR+B6_LOJA)))
					oSection1 :SetTotalText(STR0032+STR0030) //"TOTAL DO PRODUTO NO "##"CLIENTE ---->"###"FORNECEDOR --->"
				Else
					SA2->(MsSeek(xFilial("SA2")+(cAliasSB6)->(B6_CLIFOR+B6_LOJA)))
					oSection1 :SetTotalText(STR0032+STR0031) //"TOTAL DO PRODUTO NO "##"FORNECEDOR --->"
				Endif	
				
				lFound := IIf((cAliasSB6)->(B6_TPCF) == "C", SA1->(!Eof()),SA2->(!Eof()) )
				
				If lFound
					dbSelectArea("SB6")
				  
					oSection1:Cell("cVendedor"):SetValue(Posicione("SA3",1,xFilial("SA3") + SA1->A1_VEND,"A3_NOME"))
					oSection1:Cell("cCliFor"):SetTitle(IIf((cAliasSB6)->(B6_TPCF) == "C",STR0028,STR0029)) //"CLIENTE / LOJA: "###"FORNECEDOR / LOJA: "
					oSection1:Cell("cCliFor"):SetValue(Iif((cAliasSB6)->(B6_TPCF) == "C",SA1->A1_COD,SA2->A2_COD))
					
					oSection1:Cell("cLoja"):SetValue(Iif((cAliasSB6)->(B6_TPCF) == "C",SA1->A1_LOJA,SA2->A2_LOJA))
					oSection1:Cell("cNome"):SetValue(Iif((cAliasSB6)->(B6_TPCF) == "C",SA1->A1_NOME,SA2->A2_NOME))

					If lPlanilha .And. lFirstRec
						SB1->(DbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+(cAliasSB6)->(B6_PRODUTO)))
						oSection1:Cell("B1_COD"):SetValue(SB1->B1_COD)
						oSection1:Cell("B1_DESC"):SetValue(SB1->B1_DESC)
					EndIf
					
					oSection1:PrintLine()			

					cNomeCliFor := (cAliasSB6)->(B6_CLIFOR+B6_LOJA)
					cCliForAnt  := (cAliasSB6)->(B6_TPCF)
				Else
					Help(" ",1,"R480CLIFOR")
					Return .F.
				EndIf
			EndIf
			If Len(cNomeCliFor) != 0
				oSection2:Init()

				oSection2:Cell("nQuJe"):SetValue(If(mv_par15==1,ConvUM((cAliasSB6)->(B6_PRODUTO),((cAliasSB6)->(B6_QUANT) - nSaldo),0,2),((cAliasSB6)->(B6_QUANT) - nSaldo)))
				oSection2:Cell("nSaldo"):SetValue(If(mv_par15==1,ConvUm((cAliasSB6)->(B6_PRODUTO),nSaldo,0,2),nSaldo))
				oSection2:Cell("nTotNF"):SetValue(round(aSaldo[5],2))
				oSection2:Cell("nTotDev"):SetValue(((cAliasSB6)->(B6_QUANT) - nSaldo) * nPrUnit)
				// Custo na Moeda
				nCusto := (&(If(lListCustM.Or.(!lListCustM.And.!lCusFIFO), 'B6_CUSTO', 'B6_CUSFF')+Str(mv_par11,1,0)) / (cAliasSB6)->B6_QUANT) * nSaldo
				oSection2:Cell("nCusto"):SetValue(nCusto)
				
				If lPlanilha .And. !lFirstRec
					SB1->(DbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1")+(cAliasSB6)->(B6_PRODUTO)))
					oSection1:Cell("B1_COD"):SetValue(SB1->B1_COD)
					oSection1:Cell("B1_DESC"):SetValue(SB1->B1_DESC)
					If !lPlanTab
						oSection1:Cell("B6_LOCAL"):Disable()
					 	oSection1:Cell("cCliFor"):Disable()
						oSection1:Cell("cLoja"):Disable()
						oSection1:Cell("cNome"):Disable()
						oSection1:Cell("B6_EMISSAO"):Disable()
					EndIf
				EndIf
				lFirstRec := .F.
				
				oSection2:PrintLine()
			Endif
		ElseIf nOrdem == 3
			If lImprime
				If lPlanilha
					SB1->(DbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1")+(cAliasSB6)->(B6_PRODUTO)))
					oSection1:Cell("B1_COD"):SetValue(SB1->B1_COD)
					oSection1:Cell("B1_DESC"):SetValue(SB1->B1_DESC)
					oSection1:PrintLine()
				Else
					oSection1:PrintLine()
				EndIf				
				lImprime := .F.
			Endif	

			oSection2:Init()
			
			oSection2:Cell("nQuJe"):SetValue(If(mv_par15==1,ConvUM((cAliasSB6)->(B6_PRODUTO),((cAliasSB6)->(B6_QUANT) - nSaldo),0,2),((cAliasSB6)->(B6_QUANT) - nSaldo)))
			oSection2:Cell("nSaldo"):SetValue(If(mv_par15==1,ConvUm((cAliasSB6)->(B6_PRODUTO),nSaldo,0,2),nSaldo))
			oSection2:Cell("nTotNF"):SetValue(round(aSaldo[5],2))
			oSection2:Cell("nTotDev"):SetValue((B6_QUANT - nSaldo) * nPrUnit)
			// Custo na Moeda
			nCusto := (&(If(lListCustM.Or.(!lListCustM.And.!lCusFIFO), 'B6_CUSTO', 'B6_CUSFF')+Str(mv_par11,1,0)) / (cAliasSB6)->(B6_QUANT)) * nSaldo
			oSection2:Cell("nCusto"):SetValue(nCusto)
		
			oSection2:PrintLine()				
		Endif	
		// Lista as devolucoes da remessa
		If mv_par12 == 1 .And. (((cAliasSB6)->(B6_QUANT) - nSaldo) > 0)
			aAreaSB6 := SB6->(GetArea())
			SB6->(dbSetOrder(3))
			cSeek:=xFilial("SB6")+(cAliasSB6)->(B6_IDENT+B6_PRODUTO)+"D"
			If SB6->(dbSeek(cSeek))
				oReport:PrintText(STR0041) //"Notas Fiscais de Retorno"
				Do While !Eof() .And. SB6->(B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3) == cSeek
					If SB6->B6_DTDIGIT < mv_par13 .Or. SB6->B6_DTDIGIT > mv_par14
						SB6->(dbSkip())
						Loop
					Endif
					oSection3:Init(.F.)
					If nOrdem == 2
						oSection3:Cell("B6_PRODUTO"):Hide()
					Endif	
					oSection3:Cell("B6_QUANT"):SetValue(SB6->B6_QUANT)
					oSection3:Cell("nQuJe"):Hide()
					oSection3:Cell("nSaldo"):Hide()
					oSection3:Cell("nTotDev"):Hide()
					oSection3:Cell("nCusto"):Hide()
					
					oSection3:Cell("nTotNF"):SetValue(SB6->B6_QUANT * nPrUnit)
					oSection3:PrintLine()
					SB6->(dbSkip())
				EndDo
				oSection3:Finish()
			EndIf
			RestArea(aAreaSB6)
		EndIf					
		dbSelectArea(cAliasSB6)  
		dbSkip()
	EndDo
	oSection2:Finish()
	oSection1:Finish()
EndDo
		
Return NIL
