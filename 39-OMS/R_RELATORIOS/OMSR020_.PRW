#INCLUDE "OMSR020.CH"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OMSR020   ³ Autor ³Eduardo Riera          ³ Data ³10.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de cargas - Release 4.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OMSR020()
Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	OMSR020R3()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Eduardo Riera          ³ Data ³10.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport
Local oCarga
Local oItCarga
Local oItPedido
Local oItPedido2
Local oItNF
Local oItNF2
Local oBreak
Local lQuery  := .F.
Local cNReduz := ""
Local cAliasDAK := GetNextAlias()
Local cAliasDAI := cAliasDAK
Local cAliasSC9 := cAliasDAK
Local cAliasSD2 := cAliasDAK
Local cAliasSF2 := "SF2"

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
oReport := TReport():New("OMSR020",STR0001,"OMR020", {|oReport| ReportPrint(oReport,cAliasSC9,oItPedido,cAliasSD2,oITNF,oItPedido2,oItNF2,cAliasDAK,cAliasDAI,oCarga,cAliasSD2,@lQuery,cNReduz)},OemToAnsi(STR0002)+" "+OemToAnsi(STR0003)) //"Listagem de Cargas"###"Este relatorio ira imprimir a listagem de cargas de acordo"###"com os parametros informados pelo usuario"
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a secao.                   ³
//³ExpA4 : Array com as Ordens do relatorio                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatorio. O SX3 sera consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de codigo para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Section(1)                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCarga:= TRSection():New(oReport,STR0026,{"DAK","DA3","DA4"},{STR0027,STR0028},/*Campos do SX3*/,/*Campos do SIX*/) //"Carga"###"Pedido/Item"###"Produto"
oCarga:SetTotalInLine(.F.)
TRCell():New(oCarga , "DAK_COD"    , "DAK" , STR0026    , PesqPict("DAK","DAK_COD")   	, TamSx3("DAK_COD")[1]+1   	, /*lPixel*/ , /*{|| code-block de impressao }*/) //"Carga"
TRCell():New(oCarga , "DAK_SEQCAR" , "DAK" , STR0037    , PesqPict("DAK","DAK_SEQCAR")	, TamSx3("DAK_COD")[1]     	, /*lPixel*/ , /*{|| code-block de impressao }*/) //"Seq."
TRCell():New(oCarga , "DAK_CAMINH" , "DAK" , /*Titulo*/ , PesqPict("DAK","DAK_CAMINH")	, TamSx3("DAK_CAMINH")[1]+3	, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DA3_DESC"   , "DA3" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_MOTORI" , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DA4_NOME"   , "DA4" , ""         , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_PESO"   , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_CAPVOL" , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_PTOENT" , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/	 			, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_VALOR"  , "DAK" , /*Titulo*/ , /*Picture*/					, /*Tamanho*/ 				, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_DATA"   , "DAK" , /*Titulo*/ , /*Picture*/					, TamSx3("DAK_DATA")[1]+6	, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oCarga , "DAK_HORA"   , "DAK" , /*Titulo*/ , /*Picture*/					, TamSx3("DAK_HORA")[1]+4	, /*lPixel*/ , /*{|| code-block de impressao }*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Section(1):Section(1)                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItCarga:= TRSection():New(oCarga,STR0029,{"DAI","SA1","SF2"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Item da Carga"
oItCarga:SetTotalInLine(.F.)
TRCell():New(oItCarga , "DAI_SEQUEN" ,"DAI" , /*Titulo*/ , /*Picture*/ , 6, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_PEDIDO" ,"DAI" , /*Titulo*/ , /*Picture*/ , 6, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_CLIENT" ,"DAI" , /*Titulo*/ , /*Picture*/ , 6, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_LOJA"   ,"DAI" , /*Titulo*/ , /*Picture*/ , 2, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "A1_NREDUZ"  ,      , /*Titulo*/ , /*Picture*/ , 40, /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_PESO"   ,"DAI" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "DAI_CAPVOL" ,"DAI" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "F2_TIPODOC" ,"SF2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "F2_DOC"     ,"SF2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItCarga , "F2_SERIE"   ,"SF2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordem 1                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Section(1):Section(1):Section(1)                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItPedido:= TRSection():New(oItCarga,STR0030,{"SC9","SB1","SC6","SD2","SF2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Item da liberação do Pedido de venda"
oItPedido:SetTotalInLine(.F.)
TRCell():New(oItPedido , "C9_ITEM"    , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C9_PRODUTO" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "B1_DESC"    , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C9_LOTECTL" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C9_NUMLOTE" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C9_QTDLIB"  , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "B1_UM"      , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C9_QTDLIB2" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "B1_SEGUM"   , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido , "C6_VALOR"   , "SC6" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , {|| (cAliasSC9)->C9_QTDLIB*(cAliasSC9)->C9_PRCVEN })
TRCell():New(oItPedido , "D2_PESO"    , "SD2" , STR0031    , PesqPict("SB1","B1_PESO") , /*Tamanho*/ , /*lPixel*/ , {||IIf(SuperGetmv("MV_PESOCAR")=="L",SB1->B1_PESO,SB1->B1_PESBRU)*(cAliasSC9)->C9_QTDLIB}) //"Peso"
TRCell():New(oItPedido , "F2_VOLUME1" , "SF2" , STR0032    , /*Picture*/ , /*Tamanho*/ , /*lPixel*/  , {|| (cAliasSC9)->F2_VOLUME1 }) //"Volume"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Section(1):Section(1):Section(2)                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItNF:= TRSection():New(oItCarga,STR0033,{"SD2","SB1","SF2"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Item do documento de saída"
oItNF:SetTotalInLine(.F.)
TRCell():New(oItNF , "D2_ITEM"    , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_COD"     , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "B1_DESC"    , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_LOTECTL" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_NUMLOTE" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_QUANT"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "B1_UM"      , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_QTSEGUM" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "B1_SEGUM"   , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_TOTAL"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF , "D2_PESO"    , "SD2" , STR0031    , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {||IIf(SuperGetmv("MV_PESOCAR")=="L",SB1->B1_PESO,SB1->B1_PESBRU)*D2_QUANT}) //"Peso"
TRCell():New(oItNF , "F2_VOLUME1" , "SF2" , STR0032    , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/) //"Volume"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordem 2                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Section(1):Section(2)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItPedido2:= TRSection():New(oCarga,STR0030,{"SC9","SB1","SD2"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Item da liberação do Pedido de venda"
oItPedido2:SetTotalInLine(.F.)
TRCell():New(oItPedido2 , "C9_PRODUTO" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "B1_DESC"    , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "C9_LOTECTL" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "C9_NUMLOTE" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "C9_QTDLIB"  , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| IIF(MV_PAR11 == 1 .And. lQuery ,QTDE,(cAliasSC9)->C9_QTDLIB) })
TRCell():New(oItPedido2 , "B1_UM"      , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "C9_QTDLIB2" , "SC9" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| IIF(MV_PAR11 == 1 .And. lQuery ,QTDE2,(cAliasSC9)->C9_QTDLIB2) })
TRCell():New(oItPedido2 , "B1_SEGUM"   , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItPedido2 , "C6_VALOR"   , "SC6" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| IIF(MV_PAR11 == 1 .And. lQuery,VALOR,(cAliasSC9)->C9_QTDLIB*(cAliasSC9)->C9_PRCVEN) })
TRCell():New(oItPedido2 , "D2_PESO"    , "SD2" , STR0031    , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {|| IIF(SuperGetmv("MV_PESOCAR")=="L",SB1->B1_PESO,SB1->B1_PESBRU)*(IIF(MV_PAR11 == 1 .And. lQuery,QTDE,(cAliasSC9)->C9_QTDLIB))}) //"Peso"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Section(1):Section(3)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oItNF2:= TRSection():New(oCarga,STR0033,{"DAI","SD2","SB1","SF2"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Item do documento de saída"
oItNF2:SetTotalInLine(.F.)
TRCell():New(oItNF2 , "D2_DOC"     , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_SERIE"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_ITEM"    , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_COD"     , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "B1_DESC"    , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_LOTECTL" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_NUMLOTE" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_QUANT"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "B1_UM"      , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_QTSEGUM" , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "B1_SEGUM"   , "SB1" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_TOTAL"   , "SD2" , /*Titulo*/ , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/)
TRCell():New(oItNF2 , "D2_PESO"    , "SD2" , STR0031    , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , {||IIf(SuperGetmv("MV_PESOCAR")=="L",SB1->B1_PESO,SB1->B1_PESBRU)*(cAliasSC9)->C9_QTDLIB}) //"Peso"
TRCell():New(oItNF2 , "F2_VOLUME1" , "SF2" , STR0032    , /*Picture*/ , /*Tamanho*/ , /*lPixel*/ , /*{|| code-block de impressao }*/) //"Volume"

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Eduardo Riera          ³ Data ³04.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport,cAliasSC9,oItPedido,cAliasSD2,oITNF,oItPedido2,oItNF2,cAliasDAK,cAliasDAI,oCarga,cAliasSD2,lQuery,cNReduz)
Local cFilPV    := ""
Local lRemito	:= DAI->(FieldPos("DAI_REMITO")) > 0 .And. DAI->(FieldPos("DAI_SERREM")) > 0
Local nTipoOper := OsVlEntCom()
Local cFilWhere	:= ""
Local cQrySelect := "%%"
Local cQryWhere  := ""
Local cQryFrom   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

If	MV_PAR11 == 2 .And.  MV_PAR13 == 2// Analitico
	If	oReport:Section(1):nOrder == 1	// Por Pedido
		oBreak := TRBreak():New(oCarga,oCarga:Cell("DAK_COD"),STR0036,.F.) //"Total da Carga"
		TRFunction():New(oItNF:Cell("D2_QUANT")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItNF:Cell("D2_QTSEGUM"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItNF:Cell("D2_TOTAL")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItNF:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItNF:Cell("F2_VOLUME1"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
	Else  // Ordem por Produto
	//	oBreak := TRBreak():New(oItPedido,oItPedido:Cell("C9_PRODUTO" ),STR0034,.F.) 	// por Emissao //"TOTAL DO ITEM"
	//	TRFunction():New(oItPedido:Cell("C9_QTDLIB") ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	//	TRFunction():New(oItPedido:Cell("C9_QTDLIB2"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	//	TRFunction():New(oItPedido:Cell("C6_VALOR")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	//	TRFunction():New(oItPedido:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	// 	TRFunction():New(oItPedido:Cell("F2_VOLUME1"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)

		oBreak := TRBreak():New(oCarga,oCarga:Cell("DAK_COD"),STR0036,.F.) //"Total da Carga"
		TRFunction():New(oItPedido2:Cell("C9_QTDLIB") ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItPedido2:Cell("C9_QTDLIB2"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItPedido2:Cell("C6_VALOR")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		TRFunction():New(oItPedido2:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
	EndIf
Else		 		// Sintetico
	If	oReport:Section(1):nOrder == 2 // Por produto
		If	MV_PAR13 == 2	// Carga por Nota
			//	oBreak := TRBreak():New(oItNF2,oItNF2:Cell("D2_COD"),"Total Produto",.F.)
			oBreak := TRBreak():New(oCarga,oCarga:Cell("DAK_COD"),STR0036,.F.) //"Total da Carga"
			TRFunction():New(oItNF2:Cell("D2_QUANT")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItNF2:Cell("D2_QTSEGUM"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItNF2:Cell("D2_TOTAL")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItNF2:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItNF2:Cell("F2_VOLUME1"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		Else	// Carga por Pedido
			//	oBreak := TRBreak():New(oItPedido2,oItPedido2:Cell("C9_PRODUTO"),"Total Produto",.F.)
			oBreak := TRBreak():New(oCarga,oCarga:Cell("DAK_COD"),STR0036,.F.) //"Total da Carga"
			TRFunction():New(oItPedido2:Cell("C9_QTDLIB") ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItPedido2:Cell("C9_QTDLIB2"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItPedido2:Cell("C6_VALOR")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
			TRFunction():New(oItPedido2:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,.F./*lEndPage*/)
		EndIf
	Else	// Por Pedido	
	 //	oBreak := TRBreak():New(oItPedido,oItPedido:Cell("C9_PRODUTO" ),STR0034,.F.)//--"TOTAL DO ITEM"
	 //	TRFunction():New(oItPedido:Cell("C9_QTDLIB") ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	 //	TRFunction():New(oItPedido:Cell("C9_QTDLIB2"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	//	TRFunction():New(oItPedido:Cell("C6_VALOR")  ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	//	TRFunction():New(oItPedido:Cell("D2_PESO")   ,/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	//	TRFunction():New(oItPedido:Cell("F2_VOLUME1"),/* cID */,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T.,/*lEndPage*/,oItPedido)
	//	oReport:Section(1):Section(1):SetLinesBefore(0) //-- Quantidade de linhas saltadas antes da impressao da secao.
	//	oReport:Section(1):Section(1):SetHeaderPage(.T.) //-- Imprime o cabecalho no topo da pagina
	EndIf
EndIf

If	mv_par14 == 2	// Nao Imprimir Lote
	oReport:Section(1):Section(1):Section(1):Cell("C9_LOTECTL"):Disable()
	oReport:Section(1):Section(1):Section(1):Cell("C9_NUMLOTE"):Disable()
	oReport:Section(1):Section(1):Section(2):Cell("D2_LOTECTL"):Disable()
	oReport:Section(1):Section(1):Section(2):Cell("D2_NUMLOTE"):Disable()

	oReport:Section(1):Section(2):Cell("C9_LOTECTL"):Disable()
	oReport:Section(1):Section(2):Cell("C9_NUMLOTE"):Disable()
	oReport:Section(1):Section(3):Cell("D2_LOTECTL"):Disable()
	oReport:Section(1):Section(3):Cell("D2_NUMLOTE"):Disable()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lQuery := .T.
If cPaisLoc == "BRA"
	cQryWhere := "C9_NFISCAL = F2_DOC AND C9_SERIENF = F2_SERIE AND "
EndIf
cQryWhere := "%"+cQryWhere+"%"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case

	Case oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 1	// Ordem = Pedido | Carga por = Pedido
		cQrySelect := ""
		If lRemito
			cQrySelect	+=	",DAI_REMITO,DAI_SERREM "
		EndIf
		If nTipoOper == 2 .Or. nTipoOper == 3
			cQrySelect += ",DAI_FILPV "
		EndIf

		If	MV_PAR11 == 1	// Ordem = Pedido | Tipo do Relatorio = Sintetico |  Carga por = Pedido
			cQrySelect := "%"+cQrySelect+"%"
			oReport:Section(1):BeginQuery()
			BeginSQL Alias cAliasDAK
				SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,
						DAK_PTOENT,DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,
						DAI_CLIENT,DAI_LOJA,DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE
						%exp:cQrySelect%
				FROM %table:DAK% DAK ,%table:DAI% DAI
				WHERE DAK_FILIAL = %xFilial:DAK% AND 
						DAK_COD    >= %exp:mv_par01% AND 
						DAK_COD    <= %exp:mv_par02% AND 
						DAK_SEQCAR >= %exp:mv_par03% AND 
						DAK_SEQCAR <= %exp:mv_par04% AND 
						DAK_CAMINH >= %exp:mv_par05% AND 
						DAK_CAMINH <= %exp:mv_par06% AND 
						DAK_MOTORI >= %exp:mv_par07% AND 
						DAK_MOTORI <= %exp:mv_par08% AND 
						DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
						DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
						DAK.%NotDel% AND 
						DAI_FILIAL = %exp:xFilial("DAI")% AND 
						DAI_COD    = DAK.DAK_COD AND 
						DAI_SEQCAR = DAK.DAK_SEQCAR AND 
						DAI.%NotDel%
				ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAI_SEQUEN
			EndSQL
			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
		Else	// Ordem = Pedido | Tipo do Relatorio = Analitico | Carga por = Pedido
			cQrySelect := ""
			If cPaisLoc <> "BRA"
				cQrySelect += ",C9_REMITO "
			EndIf
			If nTipoOper == 2 .Or. nTipoOper == 3
				cQrySelect += ",DAI_FILPV "
			EndIf 
			cQrySelect := "%"+cQrySelect+"%"

			cFilWhere := Iif(nTipoOper == 1, xFilial("SC9"),"%"+OsFilQry("SC9","DAI.DAI_FILPV")+"%" )

			oReport:Section(1):BeginQuery()
			BeginSQL Alias cAliasDAK
				SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_HORA,
						DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,
						C9_FILIAL,C9_CLIENTE,C9_LOJA,C9_PEDIDO,C9_ITEM,C9_PRODUTO,C9_QTDLIB,C9_QTDLIB2,C9_PRCVEN,C9_CARGA,C9_SEQCAR,C9_NFISCAL,C9_SERIENF,C9_LOTECTL,C9_NUMLOTE,B1_UM,B1_SEGUM
						%exp:cQrySelect%
				FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SC9% SC9 ,%table:SB1% SB1
				WHERE DAK_FILIAL = %xFilial:DAK% AND 
						DAK_COD    >= %exp:mv_par01% AND 
						DAK_COD    <= %exp:mv_par02% AND 
						DAK_SEQCAR >= %exp:mv_par03% AND 
						DAK_SEQCAR <= %exp:mv_par04% AND 
						DAK_CAMINH >= %exp:mv_par05% AND 
						DAK_CAMINH <= %exp:mv_par06% AND 
						DAK_MOTORI >= %exp:mv_par07% AND 
						DAK_MOTORI <= %exp:mv_par08% AND 
						DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
						DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
						DAK.%NotDel% AND 
						DAI_FILIAL = %exp:xFilial("DAI")% AND 
						DAI_COD    = DAK_COD AND 
						DAI_SEQCAR = DAK_SEQCAR AND 
						DAI.%NotDel% AND 
						B1_FILIAL  = %exp:xFilial("SB1")% AND 
						B1_COD = C9_PRODUTO AND
						SB1.%NotDel% AND 
						C9_FILIAL  = %exp:cFilWhere% AND 
						C9_PEDIDO  = DAI_PEDIDO AND 
						C9_CLIENTE = DAI_CLIENT AND 
						C9_LOJA    = DAI_LOJA   AND 
						C9_CARGA   = DAI_COD    AND 
						C9_SEQCAR  = DAI_SEQCAR AND 
						SC9.%NotDel%
				ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAI_SEQUEN,C9_PEDIDO,C9_ITEM
			EndSQL
			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
		EndIf

		oReport:Section(1):Section(1):SetParentQuery()
		oReport:Section(1):Section(1):Section(1):SetParentQuery()

	Case oReport:Section(1):nOrder == 2 .And. MV_PAR13 == 1	// Ordem por = Produto | Carga por = Pedido
		cQrySelect := ""
		
		If nTipoOper == 2 .Or. nTipoOper == 3
			cQrySelect += ",DAI_FILPV "
		EndIf 
		cQrySelect := "%"+cQrySelect+"%"

		If mv_par11 == 2	// Ordem por = Produto | Tipo do Relatorio = Analitico | Carga por = Pedido
			cFilWhere := Iif(nTipoOper == 1, xFilial("SC9"),"%"+OsFilQry("SC9","DAI.DAI_FILPV")+"%" )
			oReport:Section(1):BeginQuery()
			BeginSQL Alias cAliasDAK
				SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,
						DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,
						DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,C9_FILIAL,C9_CLIENTE,C9_LOJA,C9_PEDIDO,C9_ITEM,C9_PRODUTO,
						C9_QTDLIB,C9_QTDLIB2,C9_PRCVEN,C9_CARGA,C9_SEQCAR,C9_NFISCAL,C9_SERIENF,C9_LOTECTL,C9_NUMLOTE,B1_UM,B1_SEGUM
						%exp:cQrySelect%
				FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SC9% SC9 ,%table:SB1% SB1
				WHERE DAK_FILIAL = %xFilial:DAK% AND 
						DAK_COD    >= %exp:mv_par01% AND 
						DAK_COD    <= %exp:mv_par02% AND 
						DAK_SEQCAR >= %exp:mv_par03% AND 
						DAK_SEQCAR <= %exp:mv_par04% AND 
						DAK_CAMINH >= %exp:mv_par05% AND 
						DAK_CAMINH <= %exp:mv_par06% AND 
						DAK_MOTORI >= %exp:mv_par07% AND 
						DAK_MOTORI <= %exp:mv_par08% AND 
						DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
						DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
						DAK.%NotDel% AND 
						DAI_FILIAL = %exp:xFilial("DAI")% AND 
						DAI_COD    = DAK_COD AND 
						DAI_SEQCAR = DAK_SEQCAR AND 
						DAI.%NotDel% AND
						B1_FILIAL  = %exp:xFilial("SB1")% AND 
						B1_COD = C9_PRODUTO AND
						SB1.%NotDel% AND 
						C9_FILIAL  = %exp:cFilWhere% AND 
						C9_PEDIDO  = DAI_PEDIDO AND 
						C9_CLIENTE = DAI_CLIENT AND 
						C9_LOJA    = DAI_LOJA AND 
						C9_CARGA   = DAI_COD AND 
						C9_SEQCAR  = DAI_SEQCAR AND 
						SC9.%NotDel%
				ORDER BY C9_FILIAL,C9_CARGA,C9_SEQCAR,C9_PRODUTO
			EndSql
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Metodo EndQuery ( Classe TRSection )                                    ³
			//³                                                                        ³
			//³Prepara o relatório para executar o Embedded SQL.                       ³
			//³                                                                        ³
			//³ExpA1 : Array com os parametros do tipo Range                           ³
			//³                                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
			oReport:Section(1):Section(2):SetParentQuery()
		Else	// Ordem = Produto | Tipo do Relatorio = Sintetico |  Carga por = Pedido
			cQrySelect := ""

			If nTipoOper == 2 .Or. nTipoOper == 3
				cQrySelect += ",DAI_FILPV "
			EndIf 
			cQrySelect := "%"+cQrySelect+"%"

			cFilWhere := Iif(nTipoOper == 1, xFilial("SC9"),"%"+OsFilQry("SC9","DAI.DAI_FILPV")+"%" )

			oReport:Section(1):BeginQuery()
			BeginSQL Alias cAliasDAK
				SELECT C9_FILIAL,C9_CARGA,C9_SEQCAR,DAK_COD,DAK_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,
						DAK_PTOENT,DAK_VALOR,DAK_PESO,DAK_HORA,C9_PRODUTO,C9_LOTECTL,C9_NUMLOTE,B1_PESO,B1_PESBRU,
						SUM(C9_QTDLIB)QTDE,SUM(C9_QTDLIB2)QTDE2,SUM(C9_QTDLIB*C9_PRCVEN) VALOR,B1_UM,B1_SEGUM
						%exp:cQrySelect%
				FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SC9% SC9 ,%table:SB1% SB1
				WHERE DAK_FILIAL = %xFilial:DAK% AND 
						DAK_COD    >= %exp:mv_par01% AND 
						DAK_COD    <= %exp:mv_par02% AND 
						DAK_SEQCAR >= %exp:mv_par03% AND 
						DAK_SEQCAR <= %exp:mv_par04% AND 
						DAK_CAMINH >= %exp:mv_par05% AND 
						DAK_CAMINH <= %exp:mv_par06% AND 
						DAK_MOTORI >= %exp:mv_par07% AND 
						DAK_MOTORI <= %exp:mv_par08% AND 
						DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
						DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
						DAK.%NotDel% AND 
						DAI_FILIAL = %exp:xFilial("DAI")% AND 
						DAI_COD    = DAK_COD AND 
						DAI_SEQCAR = DAK_SEQCAR AND 
						DAI.%NotDel% AND 
						C9_FILIAL  = %exp:cFilWhere% AND 
						C9_PEDIDO  = DAI_PEDIDO AND 
						C9_CLIENTE = DAI_CLIENT AND 
						C9_LOJA    = DAI_LOJA AND 
						C9_CARGA   = DAI_COD AND 
						C9_SEQCAR  = DAI_SEQCAR AND
						SC9.%NotDel% AND
						B1_FILIAL  = %exp:xFilial("SB1")% AND 
						B1_COD     = SC9.C9_PRODUTO AND 
						SB1.%NotDel%
				GROUP BY
						C9_FILIAL,C9_CARGA,C9_SEQCAR,DAK_COD,DAK_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,
						DAK_PTOENT,DAK_VALOR,DAK_PESO,DAK_HORA,C9_PRODUTO,C9_LOTECTL,C9_NUMLOTE,B1_PESO,B1_PESBRU,B1_UM,B1_SEGUM
						%exp:cQrySelect%
			EndSQL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Metodo EndQuery ( Classe TRSection )                                    ³
			//³                                                                        ³
			//³Prepara o relatório para executar o Embedded SQL.                       ³
			//³                                                                        ³
			//³ExpA1 : Array com os parametros do tipo Range                           ³
			//³                                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
			oReport:Section(1):Section(2):SetParentQuery()
		EndIf

	Case oReport:Section(1):nOrder == 2 .And. MV_PAR13 == 2	// Ordem por = Produto | Carga por = Nota Fiscal
		cQrySelect := ""

		If nTipoOper == 2 .Or. nTipoOper == 3
			cQrySelect += ",DAI_FILPV "
		EndIf 
		cQrySelect := "%"+cQrySelect+"%"

		cFilWhere := Iif(nTipoOper == 1, xFilial("SD2"),"%"+OsFilQry("SD2","DAI.DAI_FILPV")+"%" )

		oReport:Section(1):BeginQuery()
		BeginSQL Alias cAliasDAK
			SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,
					DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,
					DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,C9_QTDLIB,C9_QTDLIB2,C9_PEDIDO,C9_NFISCAL,D2_FILIAL,
					D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_PEDIDO,D2_ITEMPV,D2_ITEM,D2_COD,D2_QUANT,D2_QTSEGUM,
					D2_LOTECTL,D2_NUMLOTE,D2_TOTAL,B1_UM,B1_SEGUM
					%exp:cQrySelect%
			FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SD2% SD2,%table:SF2% SF2,%table:SC9% SC9,%table:SB1% SB1
			WHERE DAK_FILIAL = %xFilial:DAK% AND 
					DAK_COD    >= %exp:mv_par01% AND 
					DAK_COD    <= %exp:mv_par02% AND 
					DAK_SEQCAR >= %exp:mv_par03% AND 
					DAK_SEQCAR <= %exp:mv_par04% AND 
					DAK_CAMINH >= %exp:mv_par05% AND 
					DAK_CAMINH <= %exp:mv_par06% AND 
					DAK_MOTORI >= %exp:mv_par07% AND 
					DAK_MOTORI <= %exp:mv_par08% AND 
					DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
					DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
					DAK.%NotDel% AND 
					DAI_FILIAL = %exp:xFilial("DAI")% AND 
					DAI_COD    = DAK.DAK_COD AND 
					DAI_SEQCAR = DAK.DAK_SEQCAR AND 
					DAI.%NotDel% AND 
					F2_FILIAL  = %exp:cFilWhere% AND 
					F2_CARGA   = DAI_COD AND 
					F2_SEQCAR  = DAI_SEQCAR AND 
					SF2.%NotDel% AND 
					D2_FILIAL  = %exp:cFilWhere% AND 
					D2_DOC     = F2_DOC AND 
					D2_SERIE   = F2_SERIE AND 
					D2_CLIENTE = F2_CLIENTE AND 
					D2_LOJA    = F2_LOJA AND 
					SD2.%NotDel%  AND
					C9_PEDIDO  = DAI_PEDIDO AND 
					C9_CLIENTE = DAI_CLIENT AND 
					C9_LOJA    = DAI_LOJA AND 
					C9_CARGA   = DAI_COD AND 
					C9_SEQCAR  = DAI_SEQCAR AND 
					C9_PRODUTO = D2_COD AND
					%exp:cQryWhere%
					SC9.%NotDel% AND
					B1_FILIAL  = %exp:xFilial("SB1")% AND 
					B1_COD     = SC9.C9_PRODUTO AND 
					SB1.%NotDel% 
			ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,D2_COD
		EndSQL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Metodo EndQuery ( Classe TRSection )                                    ³
			//³                                                                        ³
			//³Prepara o relatório para executar o Embedded SQL.                       ³
			//³                                                                        ³
			//³ExpA1 : Array com os parametros do tipo Range                           ³
			//³                                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)	
			oReport:Section(1):Section(3):SetParentQuery()	

	Case oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 2	// Ordem por = Pedido | Carga por = Nota Fiscal
		cQrySelect := ""
		If lRemito
			cQrySelect	+=	",DAI_REMITO,DAI_SERREM "
		EndIf
		If nTipoOper == 2 .Or. nTipoOper == 3
			cQrySelect += ",DAI_FILPV "
		EndIf

		cFilWhere := Iif(nTipoOper == 1, xFilial("SD2"),"%"+OsFilQry("SD2","DAI.DAI_FILPV")+"%" )

		If	MV_PAR11 == 1	// Ordem = Pedido | Tipo do Relatorio = Sintetico | Carga por = Nota Fiscal
			cQrySelect := "%"+cQrySelect+"%"
			oReport:Section(1):BeginQuery()
			BeginSQL Alias cAliasDAK
				SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,
						DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,
						DAI_LOJA,DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,D2_DOC,D2_SERIE,F2_DOC,F2_SERIE,F2_TIPODOC
						%exp:cQrySelect%
				FROM %table:DAK% DAK ,%table:DAI% DAI, %table:SD2% SD2, %table:SF2% SF2 
				WHERE DAK_FILIAL = %xFilial:DAK% AND 
						DAK_COD    >= %exp:mv_par01% AND 
						DAK_COD    <= %exp:mv_par02% AND 
						DAK_SEQCAR >= %exp:mv_par03% AND 
						DAK_SEQCAR <= %exp:mv_par04% AND 
						DAK_CAMINH >= %exp:mv_par05% AND 
						DAK_CAMINH <= %exp:mv_par06% AND 
						DAK_MOTORI >= %exp:mv_par07% AND 
						DAK_MOTORI <= %exp:mv_par08% AND 
						DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
						DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
						DAK_FEZNF  = '1' AND 
						DAK.%NotDel% AND 
						DAI_FILIAL = %exp:xFilial("DAI")% AND 
						DAI_COD    = DAK_COD AND 
						DAI_SEQCAR = DAK_SEQCAR AND 
						DAI.%NotDel% AND 
						D2_FILIAL  = %exp:cFilWhere% AND 
						D2_PEDIDO  = DAI_PEDIDO AND 
						D2_CLIENTE = DAI_CLIENT AND 
						D2_LOJA    = DAI_LOJA AND
						D2_DOC     = F2_DOC AND 
						D2_SERIE   = F2_SERIE AND 
						SD2.%NotDel% 
				ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAI_SEQUEN
			EndSQL
			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
		Else	// Ordem = Pedido | Tipo do Relatorio = Analitico | Carga por = Nota Fiscal
			cQrySelect := ""
			If cPaisLoc <> "BRA"
				cQrySelect += ",D2_REMITO "
			EndIf
			If nTipoOper == 2 .Or. nTipoOper == 3
				cQrySelect += ",DAI_FILPV "
			EndIf

			cQrySelect := "%"+cQrySelect+"%"

			cFilWhere := Iif(nTipoOper == 1, xFilial("SD2"),"%"+OsFilQry("SD2","DAI.DAI_FILPV")+"%" )

			oReport:Section(1):BeginQuery()
			BeginSQL Alias cAliasDAK
				SELECT DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAK_CAMINH,DAK_MOTORI,DAK_DATA,DAK_PESO,DAK_CAPVOL,DAK_PTOENT,
						DAK_VALOR,DAK_HORA,DAI_FILIAL,DAI_COD,DAI_SEQCAR,DAI_SEQUEN,DAI_PEDIDO,DAI_CLIENT,DAI_LOJA,
						DAI_PESO,DAI_CAPVOL,DAI_NFISCA,DAI_SERIE,D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_PEDIDO,
						D2_ITEMPV,D2_ITEM,D2_COD,D2_QUANT,D2_QTSEGUM,D2_TOTAL,D2_LOTECTL,D2_NUMLOTE,F2_DOC,F2_SERIE,F2_TIPODOC,B1_UM,B1_SEGUM
						%exp:cQrySelect%
				FROM %table:DAK% DAK ,%table:DAI% DAI ,%table:SD2% SD2, %table:SF2% SF2, %table:SB1% SB1
				WHERE DAK_FILIAL = %xFilial:DAK% AND 
						DAK_COD    >= %exp:mv_par01% AND 
						DAK_COD    <= %exp:mv_par02% AND 
						DAK_SEQCAR >= %exp:mv_par03% AND 
						DAK_SEQCAR <= %exp:mv_par04% AND 
						DAK_CAMINH >= %exp:mv_par05% AND 
						DAK_CAMINH <= %exp:mv_par06% AND 
						DAK_MOTORI >= %exp:mv_par07% AND 
						DAK_MOTORI <= %exp:mv_par08% AND 
						DAK_DATA   >= %exp:Dtos(mv_par09)% AND 
						DAK_DATA   <= %exp:Dtos(mv_par10)% AND 
						DAK_FEZNF  = '1' AND 
						DAK.%NotDel% AND 
						DAI_FILIAL = %Exp:xFilial("DAI")% AND 
						DAI_COD    = DAK_COD AND 
						DAI_SEQCAR = DAK_SEQCAR AND 
						DAI_PEDIDO = D2_PEDIDO  AND 
						DAI.%NotDel% AND 
						F2_FILIAL  = %exp:cFilWhere% AND 
						F2_CLIENTE = DAI_CLIENT AND
						F2_LOJA    = DAI_LOJA AND
						F2_CARGA   = DAI_COD AND 
						F2_SEQCAR  = DAI_SEQCAR AND 
						F2_CARGA   = DAK_COD AND 
						SF2.%NotDel% AND 
						D2_FILIAL  = %exp:cFilWhere% AND 
						D2_DOC     = F2_DOC AND 
						D2_SERIE   = F2_SERIE AND 
						D2_TIPO    = F2_TIPO AND 
						D2_CLIENTE = F2_CLIENTE AND 
						D2_LOJA    = F2_LOJA AND 
						SD2.%NotDel% AND
						B1_FILIAL  = %exp:xFilial("SB1")% AND 
						B1_COD     = D2_COD AND 
						SB1.%NotDel% 
				ORDER BY DAK_FILIAL,DAK_COD,DAK_SEQCAR,DAI_SEQUEN,D2_DOC,D2_ITEM
			EndSQL
			oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
		EndIf
		oReport:Section(1):Section(1):SetParentQuery()
		oReport:Section(1):Section(1):Section(2):SetParentQuery()
EndCase

If oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem Pedido, Carga por Pedido                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Section(1):SetParentFilter({|x| (cAliasDAI)->DAI_FILIAL+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == x})
	oReport:Section(1):Section(1):bParentParam := {||cFilPv := Iif(nTipoOper == 1,cFilAnt, (cAliasDAI)->DAI_FILPV),xFilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}

	oReport:Section(1):Section(1):Section(1):SetParentFilter({|x|(cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_CLIENTE+(cAliasSC9)->C9_LOJA+(cAliasSC9)->C9_PEDIDO == x})
	oReport:Section(1):Section(1):Section(1):bParentParam := {||OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA+(cAliasDAI)->DAI_PEDIDO}
ElseIf	oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem por Pedido, Carga por Nota Fiscal                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Section(1):SetParentFilter({|x| (cAliasDAI)->DAI_FILIAL+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == x})
	oReport:Section(1):Section(1):bParentParam := {||cFilPv := Iif(nTipoOper == 1,cFilAnt, (cAliasDAI)->DAI_FILPV),xFilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}

	oReport:Section(1):Section(1):Section(2):SetParentFilter({|x|(cAliasDAK)->D2_FILIAL+(cAliasDAK)->D2_DOC+(cAliasDAK)->D2_SERIE == x})
	oReport:Section(1):Section(1):Section(2):bParentParam := {||OsFilial("SD2",cFilPv)+(cAliasDAK)->D2_DOC+(cAliasDAK)->D2_SERIE}
ElseIf	oReport:Section(1):nOrder == 2 .And. MV_PAR13 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem por Produto, Carga por Pedido                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Section(2):SetParentFilter({|x|(cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_CARGA+(cAliasSC9)->C9_SEQCAR == x})
	oReport:Section(1):Section(2):bParentParam := {||cFilPv := Iif(nTipoOper == 1,cFilAnt, (cAliasDAI)->DAI_FILPV),OsFilial("SC9",cFilPv)+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}
ElseIf	oReport:Section(1):nOrder == 2 .And. MV_PAR13 == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordem por Produto, Carga por Nota Fiscal                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	MV_PAR13 <> 2 .Or. oReport:Section(1):nOrder <> 2 .Or. lQuery
		oReport:Section(1):Section(3):SetParentFilter({|x|(cAliasSD2)->D2_FILIAL+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR == x})
		oReport:Section(1):Section(3):bParentParam := {||cFilPv := Iif(nTipoOper == 1,cFilAnt, (cAliasDAI)->DAI_FILPV),OsFilial("SD2",cFilPv)+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR}
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desliga e liga as section com base na ordem do relatorio.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	oReport:Section(1):nOrder == 1
	oReport:Section(1):Section(1):Enable()
	oReport:Section(1):Section(2):Disable()
	oReport:Section(1):Section(3):Disable()
	If	MV_PAR13 == 1 		// Carga por: Pedido
		oReport:Section(1):Section(1):Section(2):Disable()
		If	MV_PAR11 == 1	// Sintetico
			oReport:Section(1):Section(1):Section(1):Disable()
		EndIf
	Else					// Carga por: Nota Fiscal
		oReport:Section(1):Section(1):Section(1):Disable()	
		If	MV_PAR11 == 1 	// Sintetico
			oReport:Section(1):Section(1):Section(2):Disable()
		EndIf
	EndIf
Else
	oReport:Section(1):Section(1):Section(1):Disable()
	oReport:Section(1):Section(1):Section(2):Disable()
	If	MV_PAR13 == 1	// Carga por: Pedido
		oReport:Section(1):Section(1):Disable()
		oReport:Section(1):Section(2):Enable()		// Habilita por Pedido
		oReport:Section(1):Section(3):Disable()	// Desabilita por Nota
	Else				// Carga por: Nota Fiscal
		oReport:Section(1):Section(1):Hide()
		oReport:Section(1):Section(2):Disable()	// Desabilita por Pedido
		oReport:Section(1):Section(3):Enable()		// Habilita por nota
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo TrPosition()                                                     ³
//³                                                                        ³
//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
//³realizado antes da impressao de cada linha do relatorio.                ³
//³                                                                        ³
//³                                                                        ³
//³ExpO1 : Objeto Report da Secao                                          ³
//³ExpC2 : Alias da Tabela                                                 ³
//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
//³ExpX4 : String ou Bloco de codigo para pesquisa. A string sera macroexe-³
//³        cutada.                                                         ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordem 1                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	oReport:Section(1):nOrder == 1 .And. MV_PAR13 == 2	// Ordem por = Pedido | Carga por = Nota Fiscal
	oReport:Section(1):Section(1):Cell("F2_TIPODOC"):SetBlock({|| IIf(IsRemito(1,"'"+(cAliasDAK)->F2_TIPODOC+"'"),"(2)","(1)")})
EndIf
oReport:Section(1):Section(1):Cell("A1_NREDUZ" ):SetBlock({|| cNReduz})
TRPosition():New(oReport:Section(1),"DA3",1,{|| xFilial("DA3")+(cAliasDAK)->DAK_CAMINH })
TRPosition():New(oReport:Section(1),"DA4",1,{|| xFilial("DA4")+(cAliasDAK)->DAK_MOTORI })
TRPosition():New(oReport:Section(1):Section(1),"SC5",1,{|| BuscaNome(OsFilial("SC5",cFilPv)+(cAliasDAI)->DAI_PEDIDO,@cNReduz)})

If	MV_PAR13 == 1 // Por Pedido
	If	MV_PAR11 == 1    // Sintetico
		TRPosition():New(oReport:Section(1):Section(1),"SF2",1,{|| OsFilial("SD2",cFilPv)+(cAliasDAK)->DAI_NFISCA+(cAliasDAK)->DAI_SERIE+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA})
	ElseIf MV_PAR11 == 2 // Analitico 
		TRPosition():New(oReport:Section(1):Section(1),"SF2",1,{|| OsFilial("SD2",cFilPv)+(cAliasDAK)->C9_NFISCAL+(cAliasDAK)->C9_SERIENF+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA})	
	EndIf
EndIf

TRPosition():New(oReport:Section(1):Section(1):Section(1),"SB1",1,{|| OsFilial("SB1",cFilPv)+(cAliasSC9)->C9_PRODUTO})
TRPosition():New(oReport:Section(1):Section(1):Section(2),"SB1",1,{|| OsFilial("SB1",cFilPv)+(cAliasSD2)->D2_COD})
TRPosition():New(oReport:Section(1):Section(1),"SA1",1,{|| OsFilial("SA1",cFilPv) + SC5->C5_CLIENTE + SC5->C5_LOJACLI })

oReport:Section(1):Section(1):Section(1):Cell("F2_VOLUME1"):SetBlock({||OsPrCapArm(SB1->B1_COD,cFilPv)*(cAliasSC9)->C9_QTDLIB})
oReport:Section(1):Section(1):Section(2):Cell("F2_VOLUME1"):SetBlock({||OsPrCapArm(SB1->B1_COD,cFilPv)*(cAliasSD2)->D2_QUANT})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordem 2                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oReport:Section(1):Section(2),"SB1",1,{|| OsFilial("SB1",cFilPv)+(cAliasSC9)->C9_PRODUTO})
TRPosition():New(oReport:Section(1):Section(3),"SB1",1,{|| OsFilial("SB1",cFilPv)+(cAliasSD2)->D2_COD})
TRPosition():New(oReport:Section(1):Section(3),"SF2",1,{|| OsFilial("SF2",cFilPv)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(DAK->(LastRec()))
If	MV_PAR12 == 1
	oReport:Section(1):SetPageBreak()
EndIf

If	MV_PAR13 <> 2 .Or. oReport:Section(1):nOrder <> 2 .Or. lQuery
	oReport:Section(1):Print()
Else

	DbSelectArea("DAK")
	oReport:SetMeter((cAliasDAK)->(LastRec()))
	While !oReport:Cancel() .And. !(cAliasDAK)->(Eof())

		oReport:Section(1):Init()
		oReport:Section(1):Section(3):Init()
		oReport:Section(1):PrintLine()
		DbSelectArea(cAliasDAI)
		DbSetOrder(1)
		MSSeek(xFilial("DAI")+ (cALiasDAK)->DAK_COD + (cALiasDAK)->DAK_SEQCAR)
		While !oReport:Cancel() .And. !(cAliasDAI)->(Eof()) .And. (cALiasDAK)->DAK_COD + (cALiasDAK)->DAK_SEQCAR == (cALiasDAI)->DAI_COD + (cALiasDAI)->DAI_SEQCAR

			DbSelectArea(cAliasSD2)
			DbSetOrder(3)
			MSSeek(xFilial("SD2")+ (cAliasDAI)->DAI_NFISCA+(cAliasDAI)->DAI_SERIE)
			While !oReport:Cancel() .And. !(cAliasDAI)->(Eof()) .And. (cAliasDAI)->DAI_NFISCA+(cAliasDAI)->DAI_SERIE == (cAliasSD2)->D2_DOC + (cAliasSD2)->D2_SERIE
				oReport:Section(1):Section(3):PrintLine()
				dbSelectAre(cAliasSD2)
				dbSkip()
			EndDo

			DbSelectArea(cAliasDAI)
			dbSkip()
		EndDo

		oReport:Section(1):Finish()
		oReport:Section(1):Section(3):Finish()

		dbSelectArea(cAliasDAK)
		dbSkip()
	EndDo
EndIf

RetIndex("SC9")
RetIndex("SD2")
RetIndex("DAK")
RetIndex("DAI")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OMSR020R3 ³ Autor ³ Henry Fila            ³ Data ³ 20.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Cargas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 29/08/06 ³ Marco Bianchi ³Inserido totais quando impressao por produto³±±
±±³          ³               ³e sintetico.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OMSR020R3()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF WINDOWS
	Local Titulo := OemToAnsi(STR0001) //"Listagem de cargas"
	Local cDesc1 := OemToAnsi(STR0002) //"Este relatorio ira imprimir a listagem de cargas de acordo"
	Local cDesc2 := OemToAnsi(STR0003) //"com os parametros informados pelo usuario"
	Local cDesc3 := OemToAnsi("")
#ELSE
	Local Titulo := STR0001 // "Listagem de Precos"
	Local cDesc1 := STR0002
	Local cDesc2 := STR0003
	Local cDesc3 := ""
#ENDIF
Local cString  := "DAK" 	// Alias utilizado na Filtragem
Local lDic     := .F. 		// Habilita/Desabilita Dicionario
Local lComp    := .T. 		// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro  := .T. 		// Habilita/Desabilita o Filtro
Local wnrel    := "OMSR020"	// Nome do Arquivo utilizado no Spool
Local nomeprog := "OMSR020"	// nome do programa

Private Tamanho := "M" 		// P/M/G
Private Limite  := 132 		// 80/132/220
Private cPerg   := "OMR020"	// Pergunta do Relatorio
Private aOrdem  := {STR0019,STR0020}
Private aReturn := { STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
						//[1] Reservado para Formulario
						//[2] Reservado para N§ de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd     := .F. // Controle de cancelamento do relatorio
Private m_pag    := 1   // Contador de Paginas
Private nLastKey := 0   // Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as Perguntas Seleciondas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
If (nLastKey==27)
	DbSelectArea(cString)
	DbSetOrder(1)
	dbClearFilter()
	Return
EndIf
SetDefault(aReturn,cString)
If (nLastKey==27)
	DbSelectArea(cString)
	DbSetOrder(1)
	dbClearFilter()
	Return
EndIf

#IFDEF WINDOWS
	RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
#ELSE
	ImpDet(.F.,wnrel,cString,nomeprog,Titulo)
#ENDIF

DbSelectArea("SD2")
DbSetOrder(1)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpDet(lEnd,wnrel,cString,nomeprog,Titulo)
Tamanho := If(mv_par14==1 .And. mv_par11==2, 'G', Tamanho) // P/M/G
Limite  := If(mv_par14==1 .And. mv_par11==2, 220, Limite)
Do Case
	Case aReturn[8] == 1 .And. mv_par13 == 1
		ImpSeqSC9(lEnd,wnrel,cString,nomeprog,Titulo)
	Case aReturn[8] == 2 .And. mv_par13 == 1
		ImpPrdSC9(lEnd,wnrel,cString,nomeprog,Titulo)
	Case aReturn[8] == 1 .And. mv_par13 == 2
		ImpSeqSD2(lEnd,wnrel,cString,nomeprog,Titulo)
	Case aReturn[8] == 2 .And. mv_par13 == 2
		ImpPrdSD2(lEnd,wnrel,cString,nomeprog,Titulo)
EndCase

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpSeqSD2³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio por sequencia de entrega     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpSeqSD2(lEnd,wnrel,cString,nomeprog,Titulo)
Local aStruQry  := {}
Local aStruDAK  := {}

Local bWhileDAI := {||.T.}

Local cbCont    := 0   // Numero de Registros Processados
Local cbText    := ""  // Mensagem do Rodape
Local cIndDAK   := ""
Local cQuery    := ""
Local cCodDAK   := ""
Local cSeqDAK   := ""
Local cCliDAI   := ""
Local cPedDAI   := ""
Local cFilPv    := ""
Local cQryAd    := ""
Local cName     := ""
Local cAliasDAK := "DAK"
Local cAliasDAI := "DAI"
Local cAliasSC9 := "SC9"
Local cAliasSB1 := "SB1"

Local nIndDAK   := 0
Local nPeso     := 0
Local nCapVol   := 0
Local nTipoOper := OsVlEntCom()
Local nX        := 0
Local nCols     := 0

Local lFirst    := .T.
Local lImp      := .F. // Indica se algo foi impresso
Local lQuery    := .F.

Local cFilter	:= aReturn[7]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as cargas selecionada    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTabant   := ""
Local li        := 100 // Contador de Linhas
Local cNReduz   := ""


//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
//|XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX  XXXXXX   XXX,XXX.XX XXX,XXX.XX  XXX,XXX.XX XXX,XXX.XX  XXX.XXX     XX  XXXXXXXXXX                                                                                         |
//|CARGA   : XXXXXX-XX                                                                                                                                                                                                          |
//|VEICULO : XXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXX     MOTORISTA : XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                                       |
//|PESO    : XXXX,XXX.XX    VOLUME M3 : XXXX,XXX.XX    PTOS ENTREGA : XXXXXX   VALOR : XXX,XXX,XXX.XX                                                                                                                           |
//|DATA    : XX/XX/XX AS XX:XX                                                                                                                                                                                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCabec1 := OemtoAnsi(STR0004) //"SEQUENCIA PEDIDO CLIENTE   NOME                                    PESO         VOLUME     NOTA  SERIE"
Local cCabec2 := OemtoAnsi(STR0005) //"ENTREGA                                                                             M3   FISCAL"

DbSelectArea(cString)
DbSetOrder(2)
cIndDAK := CriaTrab(NIL,.F.)

If TcSrvType() != "AS/400"

	DbSelectArea("SX3")
	DbSetOrder(2)
	MsSeek("DAK_DATA")
	AAdd(aStruQry,{"DAK_DATA",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAK_PESO")
	AAdd(aStruQry,{"DAK_PESO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAK_CAPVOL")
	AAdd(aStruQry,{"DAK_CAPVOL",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAK_PTOENT")
	AAdd(aStruQry,{"DAK_PTOENT",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAK_VALOR")
	AAdd(aStruQry,{"DAK_VALOR",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAI_PESO")
	AAdd(aStruQry,{"DAI_PESO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAI_CAPVOL")
	AAdd(aStruQry,{"DAI_CAPVOL",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o relatorio for analitico inclui os campos do SD2                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If	mv_par11 == 2

		MsSeek("D2_QUANT")
		AAdd(aStruQry,{"D2_QUANT",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		MsSeek("D2_PRCVEN")
		AAdd(aStruQry,{"D2_PRCVEN",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	EndIf

	cQuery := "SELECT "
	cQuery += "DAK_COD, DAK_SEQCAR, DAK_CAMINH, DAK_MOTORI, DAK_DATA, DAK_PESO, DAK_CAPVOL, DAK_PTOENT, "
	cQuery += "DAK_VALOR, DAK_HORA, DAI_COD, DAI_SEQCAR,DAI_SEQUEN, DAI_PEDIDO, DAI_CLIENT, DAI_LOJA, "
	cQuery += "DAI_PESO, DAI_CAPVOL,F2_DOC,F2_SERIE,F2_TIPODOC"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Esta Rotina adiciona a cQuery os campos selecionados pelo usuario  |
	//³no filtro do usuario.                                              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aStruDAK := DAK->(dbStruct())
	If !Empty(aReturn[7])
		For nX := 1 To DAK->(FCount())
			cName := DAK->(FieldName(nX))
			If AllTrim( cName ) $ aReturn[7]
				If aStruDAK[nX,2] <> "M"  
					If !cName $ cQuery .And. !cName $ cQryAd
						cQryAd += ","+cName
					EndIf
				EndIf
			EndIf
		Next nX

		cQuery += cQryAd

	EndIf

	If nTipoOper == 2 .Or. nTipoOper == 3
		cQuery += ",DAI_FILPV "
	EndIf

	If mv_par11 == 2
		cQuery += ",D2_FILIAL, D2_CLIENTE, D2_LOJA, D2_PEDIDO ,D2_ITEMPV, D2_COD    , D2_QUANT , D2_PRCVEN, B1_COD, B1_DESC,B1_PESO,B1_PESBRU,B1_UM,B1_SEGUM"		
		If mv_par14 == 1
			cQuery += ",D2_LOTECTL,D2_NUMLOTE"
		EndIf
	EndIf

	cQuery += " FROM "+ RetSqlName("DAK")+ " DAK , "
	cQuery += RetSqlName("DAI")+ " DAI , "
	cQuery += RetSqlName("SF2")+ " SF2 "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o relatorio for analitico inclui os arquivos do SD2                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par11 == 2
		cQuery += ", "+RetSqlName("SB1")+ " SB1 , "
		cQuery += RetSqlName("SD2")+ " SD2  "
	EndIf

	cQuery += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"' "
	cQuery += " AND DAK_COD >= '"+mv_par01+"' AND DAK_COD <='"+mv_par02+"' "
	cQuery += " AND DAK_SEQCAR >= '"+mv_par03+"' AND DAK_SEQCAR <='"+mv_par04+"' "
	cQuery += " AND DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' "
	cQuery += " AND DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' "
	cQuery += " AND DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' "
	cQuery += " AND DAK_FEZNF = '1' "
	cQuery += " AND DAK.D_E_L_E_T_ = ' '"

	cQuery += " AND DAI_FILIAL = '"+xFilial("DAI")+"' "
	cQuery += " AND DAI_COD = DAK_COD "
	cQuery += " AND DAI_SEQCAR = DAK_SEQCAR "
	cQuery += " AND DAI.D_E_L_E_T_ = ' '"

	cQuery += " AND F2_FILIAL = "+Iif(nTipoOper == 1 .Or. Empty(fwFilial("SF2")) , "'"+xFilial("SF2")+"'", OsFilQry("SF2","DAI.DAI_FILPV") )

	cQuery += " AND F2_CARGA   = DAI_COD    "
	cQuery += " AND F2_SEQCAR  = DAI_SEQCAR "
	cQuery += " AND F2_CLIENTE = DAI_CLIENT "
	cQuery += " AND F2_LOJA    = DAI_LOJA   "
	cQuery += " AND SF2.D_E_L_E_T_ = ' '"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o relatorio for analitico relaciona os arquivos do SD2             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	mv_par11 == 2

		cQuery += " AND D2_FILIAL = "+Iif(nTipoOper == 1 , "'"+xFilial("SD2")+"'", OsFilQry("SD2","DAI.DAI_FILPV") )
		cQuery += " AND D2_DOC     = F2_DOC     "
		cQuery += " AND D2_SERIE   = F2_SERIE   "
		cQuery += " AND D2_TIPO    = F2_TIPO    "
		cQuery += " AND D2_CLIENTE = DAI_CLIENT "
		cQuery += " AND D2_LOJA    = DAI_LOJA   "
		cQuery += " AND D2_PEDIDO  = DAI_PEDIDO "
		cQuery += " AND SD2.D_E_L_E_T_ = ' '"

		cQuery += " AND B1_FILIAL = "+Iif(nTipoOper == 1,"'"+xFilial("SB1")+"'",OsFilQry("SB1","SD2.D2_FILIAL") )
		cQuery += " AND B1_COD = D2_COD "
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery += "ORDER BY DAK_COD,DAK_SEQCAR,DAI_SEQUEN,DAI_PEDIDO"+Iif(mv_par11 == 2,",D2_ITEMPV","")
	cQuery := ChangeQuery(cQuery)
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBCAR",.F.,.T.)
	For nX := 1 To Len(aStruQry)
		If ( aStruQry[nX][2] <> "C" )
			TcSetField("TRBCAR",aStruQry[nX][1],aStruQry[nX][2],aStruQry[nX][3],aStruQry[nX][4])
		EndIf
	Next nX

	cAliasDAK := "TRBCAR"
	cAliasDAI := "TRBCAR"
	cAliasSD2 := "TRBCAR"
	cAliasSF2 := "TRBCAR"
	cAliasSB1 := "TRBCAR"
	lQuery    := .T.

Else
	cKey := IndexKey()

	cCondicao := 'DAK_FILIAL == "'+xFilial("DAK")+'".And.' 
	cCondicao += 'DAK_COD >= "'+mv_par01+'".And.DAK_COD <="'+mv_par02+'".And.'
	cCondicao += 'DAK_SEQCAR >= "'+mv_par03+'".And.DAK_SEQCAR <="'+mv_par04+'".And.'
	cCondicao += 'DAK_CAMINH >= "'+mv_par05+'".And.DAK_CAMINH <="'+mv_par06+'".And.'
	cCondicao += 'DAK_MOTORI >= "'+mv_par07+'".And.DAK_MOTORI <="'+mv_par08+'".And.'
	cCondicao += 'Dtos(DAK_DATA) >= "'+Dtos(mv_par09)+'".And.Dtos(DAK_DATA) <="'+Dtos(mv_par10)+'".And.'
	cCondicao += 'DAK_FEZNF == "1"'

	IndRegua("DAK",cIndDAK,cKey,,cCondicao,STR0016) //"Selecionando Registros ..."
	nIndDAK := RetIndex("DAK")
	
	DbSetOrder(nIndDAK+1)

	cAliasDAK := "DAK"
	cAliasDAI := "DAI"
	cAliasSD2 := "SD2"
	cAliasSF2 := "SF2"
	cAliasSB1 := "SB1"
EndIf

DbSelectArea(cAliasDAK)
dbGotop()
While !Eof()

	If !Empty(cFilter) .And. !(&cFilter.)
		DbSkip()
		Loop
	EndIf
	lFirst := .T.

	#IFNDEF WINDOWS
		If LastKey() = 286
			lEnd := .T.
		EndIf
	#ENDIF
	If lEnd
		@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	If ( li > 60 )
		li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
		li++
	EndIf

	DbSelectArea("DA3")
	DbSetOrder(1)
	MsSeek(xFilial("DA3")+(cAliasDAK)->DAK_CAMINH)

	DbSelectArea("DA4")
	DbSetOrder(1)
	MsSeek(xFilial("DA4")+(cAliasDAK)->DAK_MOTORI)

	@ li,000 PSAY OemtoAnsi(STR0006)+(cAliasDAK)->DAK_COD+"-"+(cAliasDAK)->DAK_SEQCAR //"CARGA   : "
	li++
	@ li,000 PSAY OemtoAnsi(STR0007)+(cAliasDAK)->DAK_CAMINH + " - " + DA3->DA3_DESC //"VEICULO : "
	@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasDAK)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "
	li++
	@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :"
	@ li,010 PSAY (cAliasDAK)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")
	@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
	@ li,037 PSAY (cAliasDAK)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")
	@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
	@ li,067 PSAY (cAliasDAK)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")
	@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "
	@ li,084 PSAY (cAliasDAK)->DAK_VALOR Picture PesqPict("DAK","DAK_VALOR")
	li++ 
	@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasDAK)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasDAK)->DAK_HORA
	li++
	@ li,000 PSAY Replicate('-',limite)
	li++

	If !lQuery
		DbSelectArea(cAliasDAI)
		DbSetOrder(1)
		MsSeek(xfilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR)

		bWhileDAI := { || !Eof() .And. (cAliasDAI)->DAI_FILIAL+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == ;
						xFilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR }
	Else
		cCodDAK   := (cAliasDAK)->DAK_COD
		cSeqDAK   := (cAliasDAK)->DAK_SEQCAR
		bWhileDAI :=  {|| (cAliasDAI)->(!Eof()) .And. (cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == ;
							cCodDAK+cSeqDAK }
	EndIf

	While Eval(bWhileDAI)

		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		EndIf

		cFilPv := Iif(nTipoOper == 1,xFilial("SC5"), (cAliasDAI)->DAI_FILPV )
		SC5->(DbSetOrder(1))
		SC5->(MsSeek(OsFilial('SC5',cFilPv)+(cAliasDAI)->DAI_PEDIDO))
		cNReduz := ""
		If !SC5->C5_TIPO $ "BD"
			cFilPv := Iif(nTipoOper == 1, xFilial("SA1"),(cAliasDAI)->DAI_FILPV)
			SA1->(DbSetOrder(1))
			SA1->(MsSeek(OsFilial("SA1",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA))
			cNReduz := SA1->A1_NREDUZ
		Else
			cFilPv := Iif(nTipoOper == 1, xFilial("SA2"),(cAliasDAI)->DAI_FILPV)
			SA2->(DbSetOrder(1))
			SA2->(MsSeek(OsFilial("SA2",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA))
			cNReduz := SA2->A2_NREDUZ
		EndIf

		If	mv_par11 == 1
			@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
			@ li,010 PSAY (cAliasDAI)->DAI_PEDIDO
			@ li,017 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA
			@ li,027 PSAY Substr(cNReduz,1,30)
			@ li,059 PSAY (cAliasDAI)->DAI_PESO Picture PesqPict("DAI","DAI_PESO")
			@ li,074 PSAY (cAliasDAI)->DAI_CAPVOL Picture PesqPict("DAI","DAI_CAPVOL")
			If !lQuery
				SF2->(DbSetOrder(5))
				SF2->(MSSeek(xFilial()+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR))
			EndIf
			If IsRemito(1,"'"+(cAliasSF2)->F2_TIPODOC+"'")
				@ li,089 PSAY Alltrim(GetDescRem()) + STR0018
			Else
				@ li,089 PSAY OemToAnsi(STR0017)
			EndIf

			@ li,109 PSAY (cAliasSF2)->F2_DOC+" "+(cAliasSF2)->F2_SERIE

			If lQuery
				li++
				DbSelectArea(cAliasDAI)
				dbSkip()
				Loop
			EndIf

		Else
			If !lFirst
				@ li,000 PSAY Replicate('-',limite)
				lFirst := .F.
			EndIf

			li++
			@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
			@ li,010 PSAY (cAliasDAI)->DAI_PEDIDO
			@ li,017 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA
			@ li,027 PSAY Substr(cNReduz,1,30)
			@ li,059 PSAY (cAliasDAI)->DAI_PESO Picture PesqPict("DAI","DAI_PESO")
			@ li,074 PSAY (cAliasDAI)->DAI_CAPVOL Picture PesqPict("DAI","DAI_CAPVOL")
			If !lQuery
				SD2->(DbSetOrder(8))
				If SD2->(MSSeek(Iif(nTipoOper == 1 ,xFilial("SD2"), (cAliasDAI)->DAI_FILPV )+(cAliasDAI)->DAI_PEDIDO))
					SF2->(DbSetOrder(1))
					If SF2->(MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))

						While SF2->(!Eof()) .And. xFilial("SF2")   == xFilial("SF2")  .And.;
													SD2->D2_DOC     == SF2->F2_DOC     .And.;
													SD2->D2_SERIE   == SF2->F2_SERIE   .And.;
													SD2->D2_CLIENTE == SF2->F2_CLIENTE .And.;
													SD2->D2_LOJA    == SF2->F2_LOJA

							If SF2->F2_CARGA == DAK->DAK_COD .And. SF2->F2_SEQCAR == DAK->DAK_SEQCAR
								Exit
							EndIf

							SF2->(dbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
			If IsRemito(1,"'"+(cAliasSF2)->F2_TIPODOC+"'")
				@ li,089 PSAY Alltrim(GetDescRem()) + STR0018
			Else
				@ li,089 PSAY OemToAnsi(STR0017)
			EndIf

			@ li,109 PSAY (cAliasSF2)->F2_DOC+" "+(cAliasSF2)->F2_SERIE
			li++

			@ li,000 PSAY Replicate('-',limite)
			li++
			@ li,000 PSAY If(mv_par14==1,OemtoAnsi(STR0023),OemtoAnsi(STR0015))

			//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
			//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
			//|ITEM PRODUTO          DESCRICAO                          QTD. 1aUM       UNID.   QTD. 2aUM       SEG.UN.MED.     VALOR           PESO            VOLUME                                                                      |
			//|XXX  XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XX,XXX,XXX,XX   XX      XX,XXX,XXX,XX   XX              XX,XXX,XXX,XX   XX,XXX,XXX,XX   XX,XXX,XXX,XX                                                               |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
			//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
			//|ITEM PRODUTO          DESCRICAO                       LOTE       SUBLOTE     QTD. 1aUM       UNIDADE     QTD. 2aUM       SEG.UN.MED.     VALOR          PESO         	VOLUME                                              |
			//|XXX  XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXX XXXXXX      XX,XXX,XXX,XX   XX          XX,XXX,XXX,XX   XX      XX,XXX,XXX,XX  XX,XXX,XXX,XX     XX,XXX,XXX,XX                                              |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			li++
			@ li,000 PSAY Replicate('-',limite)

			If lQuery

				cCarDAK := (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR
				cCliSD2 := (cAliasSD2)->D2_CLIENTE+ (cAliasSD2)->D2_LOJA

				bWhileSD2 := {|| (cAliasSD2)->(!Eof()) .And. (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR+(cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA == ;
								cCarDAK+cCliSD2}

			Else

				cFilPv := Iif(nTipoOper == 1 ,xFilial("SF2"), (cAliasDAI)->DAI_FILPV )

				DbSelectArea(cAliasSD2)
				DbSetOrder(3)
				MsSeek(OsFilial("SF2",cFilPv)+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)

				bWhileSD2 := {|| !Eof() .And. OsFilial("SF2",cFilPv)+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA == ;
														 OsFilial("SD2",cFilPv)+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA	}		
			EndIf

			While Eval(bWhileSD2)
				li++

				If ( li > 60 )
					li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
					li++
				EndIf

				cFilPv := Iif(nTipoOper == 1, xFilial("SB1"), (cAliasSD2)->D2_FILIAL )

				If !lQuery
					DbSelectArea(cAliasSB1)
					DbSetOrder(1)
					MsSeek(OsFilial("SB1",(cAliasSD2)->D2_FILIAL)+(cAliasSD2)->D2_COD)
				EndIf

				nCapArm := OsPrCapArm((cAliasSB1)->B1_COD, cFilPv)
				nCapVol := ( nCapArm * (cAliasSD2)->D2_QUANT )
				If Getmv("MV_PESOCAR") == "L"
					nPeso := ( (cAliasSB1)->B1_PESO   * (cAliasSD2)->D2_QUANT )
				Else
					nPeso := ( (cAliasSB1)->B1_PESBRU * (cAliasSD2)->D2_QUANT )
				EndIf

				//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
				//|ITEM PRODUTO          DESCRICAO                       LOTE       SUBLOTE		QTD. 1aUM 		UNIDADE		QTD. 2aUM		SEG.UN.MED.		VALOR           PESO         	VOLUME                                              |
				//|XXX  XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXX XXXXXX  	XX,XXX,XXX,XX  	XX			XX,XXX,XXX,XX  	XX				XX,XXX,XXX,XX	XX,XXX,XXX,XX  	XX,XXX,XXX,XX                                       |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
				//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
				//|ITEM PRODUTO          DESCRICAO                        	QTD. 1aUM  		UNID.	QTD. 2aUM		SEG.UN.MED.		VALOR     		PESO         	VOLUME                                                                      |
				//|XXX  XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		XX,XXX,XXX,XX  	XX		XX,XXX,XXX,XX  	XX				XX,XXX,XXX,XX  	XX,XXX,XXX,XX  	XX,XXX,XXX,XX                                                               |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ li,000 PSAY (cAliasSD2)->D2_ITEMPV
				@ li,005 PSAY (cAliasSD2)->D2_COD
				@ li,037 PSAY Substr((cAliasSB1)->B1_DESC,1,30)
				If	mv_par14 == 1
					@ li,069 PSAY (cAliasSD2)->D2_LOTECTL
					@ li,080 PSAY (cAliasSD2)->D2_NUMLOTE
					nCols := 20
				EndIf
				@ li,070+nCols PSAY (cAliasSD2)->D2_QUANT Picture PesqPict("SD2","D2_QUANT")
				@ li,083+nCols PSAY (cAliasSD2)->B1_UM
				@ li,091+nCols PSAY ConvUM((cAliasSD2)->D2_COD,(cAliasSD2)->D2_QUANT,0,2) Picture PesqPict("SD2","D2_QUANT")
				@ li,105+nCols PSAY (cAliasSD2)->B1_SEGUM
				@ li,115+nCols PSAY (cAliasSD2)->D2_QUANT *(cAliasSD2)->D2_PRCVEN Picture "@E 999,999,999.99"
				@ li,130+nCols PSAY nPeso	Picture "@E 999,999,999.99"
				@ li,144+nCols PSAY nCapVol	Picture "@E 999,999,999.99"
				DbSelectArea(cAliasSD2)
				dbSkip()
			Enddo
		EndIf
		li++

		DbSelectArea(cAliasDAI)
		If !lQuery
			dbSkip()
		EndIf
	Enddo

	li++
	If mv_par12 == 1
		li := 80
	EndIf

	DbSelectArea(cAliasDAK)
	If !lQuery
		dbSkip()
	EndIf

Enddo

If ( lImp )
	Roda(cbCont,cbText,Tamanho)
EndIf

If lQuery
	DbSelectArea("TRBCAR")
	dbCloseArea()
Else
	DbSelectArea("DAK")
	RetIndex("DAK")
	dbClearFilter()
EndIf

Set Device To Screen
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
EndIf
MS_FLUSH()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpPrdSD2³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio por sequencia de entrega     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpPrdSD2(lEnd,wnrel,cString,nomeprog,Titulo)
Local aStruQry  := {}
Local aStruDAK  := {}
Local aStruSC9  := {}

Local cbCont    := 0   // Numero de Registros Processados
Local cbText    := ""  // Mensagem do Rodape
Local cIndDAK   := ""
Local cQuery    := ""
Local cCodDAK   := ""
Local cSeqDAK   := ""
Local cCliDAI   := ""
Local cPedDAI   := ""
Local cFilPv    := ""

Local nIndDAK   := 0
Local nPeso     := 0
Local nCapVol   := 0
Local nTipoOper := OsVlEntCom()
Local nPosProd  := 0
Local nX        := 0
Local nCols     := 0
Local lFirst    := .T.
Local lImp      := .F. // Indica se algo foi impresso
Local lQuery    := .F.

Local cFilter	 := aReturn[7]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as cargas selecionada    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cTabant := ""
Local li      := 100 // Contador de Linhas

//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
//|XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX  XXXXXX   XXX,XXX.XX XXX,XXX.XX  XXX,XXX.XX XXX,XXX.XX  XXX.XXX     XX  XXXXXXXXXX                                                                                         |
//|CARGA   : XXXXXX-XX                                                                                                                                                                                                          |
//|VEICULO : XXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXX     MOTORISTA : XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                                       |
//|PESO    : XXXX,XXX.XX    VOLUME M3 : XXXX,XXX.XX    PTOS ENTREGA : XXXXXX   VALOR : XXX,XXX,XXX.XX                                                                                                                           |
//|DATA    : XX/XX/XX AS XX:XX                                                                                                                                                                                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCabec1 := If(mv_par14==1,OemtoAnsi(STR0022),OemtoAnsi(STR0021))

//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
//|PRODUTO           DESCRICAO                      LOTE       SUBLOT   UNID.        QTD 1aUM       QTD 2aUM    2aUNI.  PESO        VOLUME      VALOR                                                                           |
//|XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXX XXXXXX   XX      XX,XXX,XXX,XX  XX,XXX,XXX,XX   XX      XX,XXX,XX   XX,XXX,XX   XX,XXX,XXX,XX                                                                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
//|PRODUTO           DESCRICAO                          QTD 1aUM        UNID.   QTD 2aUM        SEG.UN.MED.     PESO        VOLUME      VALOR                                                                                   |
//|XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XX,XXX,XXX,XX   XX      XX,XXX,XXX,XX   XX              XX,XXX,XX   XX,XXX,XX   XX,XXX,XXX,XX                                                                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local oTempTable	:= NIL
Local cCabec2 := ""
Local nTotQtd := 0
Local nTotQtd2:= 0
Local nTotPes := 0
Local nTotVol := 0
Local nTotVlr := 0

DbSelectArea(cString)
DbSetOrder(2)
cIndDAK := CriaTrab(NIL,.F.)

If TcSrvType() != "AS/400"

	aStruDAK := DAK->(dbStruct())
	aStruSD2 := SD2->(dbStruct())

	AAdd(aStruSD2,{'QTDE' ,'N',18,2})
	AAdd(aStruSD2,{'VALOR','N',18,2})

	cAliasQRY := "TRBQRY"

	cQuery := "SELECT F2_CARGA,F2_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_PESO,"
	cQuery += "DAK_HORA,D2_COD,D2_LOTECTL,D2_NUMLOTE,B1_DESC,B1_PESO,B1_PESBRU,B1_UM,B1_SEGUM, D2_QUANT QTDE, D2_TOTAL VALOR"
	cQuery += " FROM "
	cQuery += RetSqlName("SF2") + " SF2, "
	cQuery += RetSqlName("SD2") + " SD2, "
	cQuery += RetSqlName("SB1") + " SB1, "
	cQuery += RetSqlName("DAK") + " DAK  "

	cQuery += " WHERE "
	cQuery += " F2_FILIAL = "+Iif(nTipoOper == 1 , "'"+xFilial("SF2")+"'", OsFilQry("SF2","DAI.DAI_FILPV") )+" AND "
	cQuery += " F2_CARGA  >= '"+mv_par01+"' AND "
	cQuery += " F2_CARGA  <= '"+mv_par02+"' AND "
	cQuery += " F2_SEQCAR >= '"+mv_par03+"' AND "
	cQuery += " F2_SEQCAR <= '"+mv_par04+"' AND "
	cQuery += " SF2.D_E_L_E_T_ = ' ' AND "

	cQuery += " D2_FILIAL = "+Iif(nTipoOper == 1 , "'"+xFilial("SD2")+"'", OsFilQry("SD2","DAI.DAI_FILPV") )+" AND "
	cQuery += " D2_DOC     = F2_DOC     AND "
	cQuery += " D2_SERIE   = F2_SERIE   AND "
	cQuery += " D2_CLIENTE = F2_CLIENTE AND "
	cQuery += " D2_LOJA    = F2_LOJA    AND "
	cQuery += " D2_TIPO    = F2_TIPO    AND "
	cQuery += " SD2.D_E_L_E_T_ = ' '    AND "


	cQuery += "B1_FILIAL = '"+xFilial("SB1")+ "' AND "
	cQuery += "B1_COD    = D2_COD AND "
	cQuery += "SB1.D_E_L_E_T_ = ' ' AND "

	cQuery += "DAK_FILIAL = '"+xFilial("DAK")+"' AND "
	cQuery += "DAK_COD    = F2_CARGA AND "
	cQuery += "DAK_SEQCAR = F2_SEQCAR AND "
	cQuery += "DAK_FEZNF = '1' AND "
	cQuery += "DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' AND "
	cQuery += "DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' AND "
	cQuery += "DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' AND "
	cQuery += "DAK.D_E_L_E_T_ = ' '"


	cQuery += "ORDER BY F2_CARGA,F2_SEQCAR,D2_COD"

	cQuery := ChangeQuery(cQuery)
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)

	For nX := 1 To Len(aStruDAK)
		If aStruDAK[nX][2]!="C"
			TcSetField(cAliasQRY,aStruDAK[nX][1],aStruDAK[nX][2],aStruDAK[nX][3],aStruDAK[nX][4])
		EndIf
	Next nX

	For nX := 1 To Len(aStruSD2)
		If aStruSD2[nX][2]!="C"
			TcSetField(cAliasQRY,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
		EndIf
	Next nX

	While (cAliasQRY)->(!Eof())

		If lEnd
			@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		EndIf


		DbSelectArea("DA3")
		DbSetOrder(1)
		MsSeek(xFilial("DA3")+(cAliasQRY)->DAK_CAMINH)

		DbSelectArea("DA4")
		DbSetOrder(1)
		MsSeek(xFilial("DA4")+(cAliasQRY)->DAK_MOTORI)

		cCarga := (cAliasQRY)->F2_CARGA+(cAliasQRY)->F2_SEQCAR

		@ li,000 PSAY OemtoAnsi(STR0006)+(cAliasQRY)->F2_CARGA+"-"+(cAliasQRY)->F2_SEQCAR //"CARGA   : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0007)+(cAliasQRY)->DAK_CAMINH + " - " + DA3->DA3_DESC //"VEICULO : "
		@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasQRY)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :"
		@ li,010 PSAY (cAliasQRY)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")
		@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
		@ li,037 PSAY (cAliasQRY)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")
		@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
		@ li,067 PSAY (cAliasQRY)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")
		@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "
		@ li,084 PSAY (cAliasQRY)->DAK_VALOR Picture PesqPict("DAK","DAK_VALOR")
		li++
		@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasQRY)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasQRY)->DAK_HORA
		li++
		@ li,000 PSAY Replicate('-',limite)
		li++

		aTotais := {0,0,0,0,0}
		While (cAliasQRY)->(!Eof()) .And. (cAliasQRY)->F2_CARGA+(cAliasQRY)->F2_SEQCAR == cCarga

			If	lEnd
				@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If (li > 60)
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			EndIf

			cFilPv   := xFilial("SB1")
			nCapArm  := OsPrCapArm((cAliasQRY)->D2_COD, cFilPv)

			If	Getmv("MV_PESOCAR") == "L"
				nPeso := ((cAliasQRY)->B1_PESO   * (cAliasQRY)->QTDE)
			Else
				nPeso := ((cAliasQRY)->B1_PESBRU * (cAliasQRY)->QTDE)
			EndIf
			nCapVol  := ( nCapArm * (cAliasQRY)->QTDE )

			@ li,000 PSAY (cAliasQRY)->D2_COD
			@ li,033 PSAY SubStr((cAliasQRY)->B1_DESC,1,30)
			If	mv_par14 == 1
				@ li,064 PSAY (cAliasQRY)->D2_LOTECTL
				@ li,075 PSAY (cAliasQRY)->D2_NUMLOTE
				nCols := 20
			EndIf
			@ li,062+nCols PSAY (cAliasQRY)->QTDE	Picture PesqPict("SD2","D2_QUANT")
			@ li,078+nCols PSAY (cAliasQRY)->B1_UM
			@ li,086+nCols PSAY ConvUm((cAliasQRY)->D2_COD,(cAliasQRY)->QTDE,0,2) Picture PesqPict("SD2","D2_QUANT")
			@ li,100+nCols PSAY (cAliasQRY)->B1_SEGUM
			@ li,115+nCols PSAY nPeso				Picture "@E 99,999.99"
			@ li,130+nCols PSAY nCapVol				Picture "@E 99,999.99"
			@ li,144+nCols PSAY (cAliasQRY)->VALOR	Picture "@E 99,999,999.99"
			// Totais da Carga
			aTotais[1] += (cAliasQRY)->QTDE
			aTotais[2] += ConvUm((cAliasQRY)->D2_COD,(cAliasQRY)->QTDE,0,2)
			aTotais[3] += nPeso
			aTotais[4] += nCapVol
			aTotais[5] += (cAliasQRY)->VALOR

			// Total Geral
			nTotQtd  += (cAliasQRY)->QTDE
			nTotQtd2 += ConvUm((cAliasQRY)->D2_COD,(cAliasQRY)->QTDE,0,2)
			nTotPes  += nPeso
			nTotVol  += nCapVol
			nTotVlr  += (cAliasQRY)->VALOR
			li++
			(cAliasQRY)->(dbSkip())
		EndDo

		If	mv_par11 == 1
			li++
			If (li > 60)
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			EndIf
			@ li,000       PSAY STR0025    //"Total ---> "
			@ li,062+nCols PSAY aTotais[1] Picture PesqPict("SD2","D2_QUANT")
			@ li,078+nCols PSAY aTotais[2] Picture PesqPict("SD2","D2_QUANT")
			@ li,115+nCols PSAY aTotais[3] Picture "@E 99,999.99"
			@ li,130+nCols PSAY aTotais[4] Picture "@E 99,999.99"
			@ li,144+nCols PSAY aTotais[5] Picture "@E 99,999,999.99"
		EndIf
		If	mv_par12 == 1
			li := 80
		Else
			li+=2
		EndIf

	EndDo

	DbSelectArea(cAliasQRY)
	dbCloseArea()
Else
	Omr020Trb(@oTempTable,aReturn[8])

	DbSelectArea("DAK")
	DbSetOrder(1)
	cKey := IndexKey()

	cCondicao := 'DAK_FILIAL == "'+xFilial("DAK")+'".And.' 
	cCondicao += 'DAK_COD >= "'+mv_par01+'".And.DAK_COD <="'+mv_par02+'".And.'
	cCondicao += 'DAK_SEQCAR >= "'+mv_par03+'".And.DAK_SEQCAR <="'+mv_par04+'".And.'
	cCondicao += 'DAK_CAMINH >= "'+mv_par05+'".And.DAK_CAMINH <="'+mv_par06+'".And.'
	cCondicao += 'DAK_MOTORI >= "'+mv_par07+'".And.DAK_MOTORI <="'+mv_par08+'".And.'
	cCondicao += 'Dtos(DAK_DATA) >= "'+Dtos(mv_par09)+'".And.Dtos(DAK_DATA) <="'+Dtos(mv_par10)+'".And.'
	cCondicao += 'DAK_FEZNF == "1"'

	IndRegua("DAK",cIndDAK,cKey,,cCondicao,STR0016) //"Selecionando Registros ..."
	nIndDAK := RetIndex("DAK")
	DbSetOrder(nIndDAK+1)


	While !DAK->(Eof())

		If !Empty(cFilter) .And. !(&cFilter.)
			DbSkip()
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca itens da carga                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DAI->(DbSetOrder(1))
		DAI->(MsSeek(xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR))

		While !DAI->(Eof()) .And. DAI->DAI_FILIAL == xFilial("DAI") .And.;
											DAI->DAI_COD    == DAK->DAK_COD .And. ;
											DAI->DAI_SEQCAR == DAK->DAK_SEQCAR

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca pedidos da carga                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			cFilPv := Iif(nTipoOper == 1, xFilial("SC9"),DAI->DAI_FILPV)

			SF2->(DbSetOrder(5))
			SF2->(MSSeek(xFilial()+DAI->DAI_COD+DAI->DAI_SEQCAR))

			SD2->(DbSetOrder(3))
			SD2->(MsSeek(OsFilial("SD2",cFilPv)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

			bWhileSD2 := {|| !SD2->(Eof()) .And.	OsFilial("SF2",cFilPv)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == ;
													OsFilial("SD2",cFilPv)+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA	}		

			While Eval(bWhileSD2)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca produtos para aglutinar conforme o relatório³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				SB1->(DbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))

				nCapArm  := OsPrCapArm(SB1->B1_COD, cFilPv)
				nCapVol  := ( nCapArm   * SD2->D2_QUANT )

				If Getmv("MV_PESOCAR") == "L"
					nPeso    := ( SB1->B1_PESO   * SD2->D2_QUANT )
				Else
					nPeso    := ( SB1->B1_PESBRU * SD2->D2_QUANT )
				EndIf

				DbSelectArea("TRBPRO")
				If !MsSeek(DAK->DAK_COD+DAK->DAK_SEQCAR+SD2->D2_COD)

					RecLock("TRBPRO",.T.)
					TRBPRO->TRB_CODCAR := DAK->DAK_COD 	
					TRBPRO->TRB_SEQCAR := DAK->DAK_SEQCAR
					TRBPRO->TRB_MOTORI := DAK->DAK_MOTORI
					TRBPRO->TRB_VEICUL := DAK->DAK_CAMINH
					TRBPRO->TRB_DATA   := DAK->DAK_DATA
					TRBPRO->TRB_HORA   := DAK->DAK_HORA
					TRBPRO->TRB_PTOENT := DAK->DAK_PTOENT
					TRBPRO->TRB_PESTOT := DAK->DAK_PESO
					TRBPRO->TRB_VOLTOT := DAK->DAK_CAPVOL
					TRBPRO->TRB_VALTOT := DAK->DAK_VALOR
					TRBPRO->TRB_CODPRO := SD2->D2_COD
					TRBPRO->TRB_DESPRO := SB1->B1_DESC
					TRBPRO->TRB_CODCLI := SD2->D2_CLIENTE
					TRBPRO->TRB_LOJA   := SD2->D2_LOJA
					TRBPRO->TRB_LOTEC  := SD2->D2_LOTECTL
					TRBPRO->TRB_NUMLO  := SD2->D2_NUMLOTE

				Else
					RecLock("TRBPRO",.F.)
				EndIf

				TRBPRO->TRB_QUANT  += SD2->D2_QUANT
				TRBPRO->TRB_PESO   += nPeso
				TRBPRO->TRB_CAPVOL += nCapvol
				TRBPRO->TRB_VALOR  += SD2->D2_TOTAL
				MsUnlock()
				SD2->(dbSkip())
			Enddo
			DAI->(dbSkip())
		Enddo
		DAK->(dbSkip())
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impressao do relatorio                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
	//|PRODUTO           DESCRICAO                      LOTE       SUBLOTE	UNID.	QTD 1aUM      	QTD 2aUM     	2aUNI.	PESO      	VOLUME     	VALOR                                                                           |
	//|XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXX XXXXXX  	XX		XX,XXX,XXX,XX 	XX,XXX,XXX,XX 	XX 		XX,XXX,XX   XX,XXX,XX	XX,XXX,XXX,XX                                                                   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
	//|PRODUTO           DESCRICAO                        	QTD 1aUM  		UNID. 	QTD 2aUM   		SEG.UN.MED.		PESO      	VOLUME    	VALOR                                                                                   |
	//|XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		XX,XXX,XXX,XX 	XX		XX,XXX,XXX,XX  	XX				XX,XXX,XX   XX,XXX,XX	XX,XXX,XXX,XX                                                                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRBPRO")
	dbGotop()

	While !Eof()

		#IFNDEF WINDOWS
			If LastKey() = 286
				lEnd := .T.
			EndIf
		#ENDIF
		If lEnd
			@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		EndIf

		cCarga := TRBPRO->TRB_CODCAR+TRBPRO->TRB_SEQCAR

		@ li,000 PSAY OemtoAnsi(STR0006)+TRBPRO->TRB_CODCAR+"-"+TRBPRO->TRB_SEQCAR //"CARGA   : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0007)+TRBPRO->TRB_VEICUL + " - " + DA3->DA3_DESC //"VEICULO : "
		@ li,055 PSAY OemtoAnsi(STR0008)+TRBPRO->TRB_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :"
		@ li,010 PSAY TRBPRO->TRB_PESTOT Picture PesqPict("DAK","DAK_PESO")
		@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
		@ li,037 PSAY TRBPRO->TRB_VOLTOT Picture PesqPict("DAK","DAK_CAPVOL")
		@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
		@ li,067 PSAY TRBPRO->TRB_PTOENT Picture PesqPict("DAK","DAK_PTOENT")
		@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "
		@ li,084 PSAY TRBPRO->TRB_VALTOT Picture PesqPict("DAK","DAK_VALOR")
		li++
		@ li,000 PSAY OemtoAnsi(STR0013) +DtoC(TRBPRO->TRB_DATA) + OemtoAnsi(STR0014) + TRBPRO->TRB_HORA
		li++
		@ li,000 PSAY Replicate('-',limite)
		li++

		aTotais := {0,0,0,0,0}
		While TRBPRO->(!Eof()) .And. TRBPRO->TRB_CODCAR+TRBPRO->TRB_SEQCAR == cCarga

			If lEnd
				@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			EndIf

			@ li,000 PSAY TRBPRO->TRB_CODPRO
			@ li,018 PSAY SubStr(TRBPRO->TRB_DESPRO,1,30)
			If	mv_par14 == 1
				@ li,049 PSAY TRBPRO->TRB_LOTEC
				@ li,060 PSAY TRBPRO->TRB_NUMLO
				nCols := 20
			EndIf
			@ li,062+nCols PSAY TRBPRO->TRB_QUANT  Picture PesqPict("SD2","D2_QUANT")
			@ li,086+nCols PSAY ConvUm(TRBPRO->TRB_CODPRO,TRBPRO->TRB_QUANT,0,2) Picture PesqPict("SD2","D2_QUANT")
			@ li,115+nCols PSAY TRBPRO->TRB_PESO   Picture "@E 99,999.99"
			@ li,130+nCols PSAY TRBPRO->TRB_CAPVOL Picture "@E 99,999.99"
			@ li,144+nCols PSAY TRBPRO->TRB_VALOR  Picture "@E 99,999,999.99"

			// Totais da Carga
			aTotais[1] += TRBPRO->TRB_QUANT
			aTotais[2] += ConvUm(TRBPRO->TRB_CODPRO,TRBPRO->TRB_QUANT,0,2)
			aTotais[3] += TRBPRO->TRB_PESO
			aTotais[4] += TRBPRO->TRB_CAPVOL
			aTotais[5] += TRBPRO->TRB_VALOR

			// Total Geral
			nTotQtd  += TRBPRO->TRB_QUANT
			nTotQtd2 += ConvUm(TRBPRO->TRB_CODPRO,TRBPRO->TRB_QUANT,0,2)
			nTotPes  += TRBPRO->TRB_PESO
			nTotVol  += TRBPRO->TRB_CAPVOL
			nTotVlr  += TRBPRO->TRB_VALOR

			li++

			TRBPRO->(dbSkip())

		Enddo
		If mv_par11 == 1
			li++
			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			EndIf

			@ li,000       PSAY STR0025    //"Total ---> "
			@ li,062+nCols PSAY aTotais[1] Picture PesqPict("SD2","D2_QUANT")
			@ li,086+nCols PSAY aTotais[2] Picture PesqPict("SD2","D2_QUANT")
			@ li,115+nCols PSAY aTotais[3] Picture "@E 99,999.99"
			@ li,130+nCols PSAY aTotais[4] Picture "@E 99,999.99"
			@ li,144+nCols PSAY aTotais[5] Picture "@E 99,999,999.99"
		EndIf
		If mv_par12 == 1
			li := 80
		Else
			li+=2
		EndIf

	Enddo
	oTempTable:Delete()

	DbSelectArea("DAK")
	RetIndex("DAK")
	dbClearFilter()
EndIf

If MV_PAR11 == 1		//relatorio sintetico
	If nTotPes <> 0 .Or. nTotVol <> 0  .Or. nTotVlr <> 0
		li := PRow() + 2
		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
		EndIf
		li += 2
		@li,000 PSAY STR0024 //"Total Geral"
		@ li,062+nCols PSAY nTotQtd  Picture PesqPict("SD2","D2_QUANT")
		@ li,078+nCols PSAY nTotQtd2 Picture PesqPict("SD2","D2_QUANT")
		@ li,115+nCols PSAY nTotPes  Picture "@E 999,999.99"
		@ li,130+nCols PSAY nTotVol  Picture "@E 999,999.99"
		@ li,144+nCols PSAY nTotVlr  Picture "@E 999,999,999.99"
	EndIf
EndIf

If ( lImp )
	Roda(cbCont,cbText,Tamanho)
EndIf

Set Device To Screen
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
EndIf
MS_FLUSH()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpSeqSC9³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio por sequencia de entrega     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpSeqSC9(lEnd,wnrel,cString,nomeprog,Titulo)
Local aStruQry  := {}
Local aStruDAK  := {}

Local bWhileDAI := {||.T.}

Local cbCont    := 0   // Numero de Registros Processados
Local cbText    := ""  // Mensagem do Rodape
Local cIndDAK   := ""
Local cQuery    := ""
Local cCodDAK   := ""
Local cSeqDAK   := ""
Local cCliDAI   := ""
Local cPedDAI   := ""
Local cFilPv    := ""
Local cQryAd    := ""
Local cName     := ""
Local cAliasDAK := "DAK"
Local cAliasDAI := "DAI"
Local cAliasSC9 := "SC9"
Local cAliasSB1 := "SB1"
Local cItem     := ""
Local cCarga    := ""
Local cSeqCar   := ""


Local nIndDAK   := 0
Local nPeso     := 0
Local nCapVol   := 0
Local nTipoOper := OsVlEntCom()
Local nX        := 0
Local nQuantIt  := 0
Local nQuant2It := 0
Local nValorIt  := 0
Local nPesoIt   := 0
Local nVolIt    := 0
Local nCols     := 0

Local lFirst    := .T.
Local lImp      := .F. // Indica se algo foi impresso
Local lQuery    := .F.

Local lRemito	:= DAI->(FieldPos("DAI_REMITO")) > 0 .And. DAI->(FieldPos("DAI_SERREM")) > 0
Local cFilter	:= aReturn[7]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as cargas selecionada    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cTabant := ""
Local li      := 100 // Contador de Linhas
Local cNReduz := ""

//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
//|XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX  XXXXXX   XXX,XXX.XX XXX,XXX.XX  XXX,XXX.XX XXX,XXX.XX  XXX.XXX     XX  XXXXXXXXXX                                                                                         |
//|CARGA   : XXXXXX-XX                                                                                                                                                                                                          |
//|VEICULO : XXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXX     MOTORISTA : XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                                       |
//|PESO    : XXXX,XXX.XX    VOLUME M3 : XXXX,XXX.XX    PTOS ENTREGA : XXXXXX   VALOR : XXX,XXX,XXX.XX                                                                                                                           |
//|DATA    : XX/XX/XX AS XX:XX		                                                                                                                                                                                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCabec1 := OemtoAnsi(STR0004) //"SEQUENCIA PEDIDO CLIENTE   NOME                                    PESO         VOLUME     NOTA  SERIE"
Local cCabec2 := OemtoAnsi(STR0005) //"ENTREGA                                                                             M3   FISCAL"

DbSelectArea(cString)
DbSetOrder(2)
cIndDAK := CriaTrab(NIL,.F.)

If TcSrvType() != "AS/400"	

	DbSelectArea("SX3")
	DbSetOrder(2)
	MsSeek("DAK_DATA")
	AAdd(aStruQry,{"DAK_DATA",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAK_PESO")
	AAdd(aStruQry,{"DAK_PESO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAK_CAPVOL")
	AAdd(aStruQry,{"DAK_CAPVOL",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAK_PTOENT")
	AAdd(aStruQry,{"DAK_PTOENT",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAK_VALOR")
	AAdd(aStruQry,{"DAK_VALOR",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAI_PESO")
	AAdd(aStruQry,{"DAI_PESO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	MsSeek("DAI_CAPVOL")
	AAdd(aStruQry,{"DAI_CAPVOL",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o relatorio for analitico inclui os campos do SC9                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If mv_par11 == 2

		MsSeek("C9_QTDLIB")
		AAdd(aStruQry,{"C9_QTDLIB",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		MsSeek("C9_PRCVEN")
		AAdd(aStruQry,{"C9_PRCVEN",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

	EndIf

	cQuery := "SELECT "
	cQuery += "DAK_COD, DAK_SEQCAR, DAK_CAMINH, DAK_MOTORI, DAK_DATA, DAK_PESO, DAK_CAPVOL, DAK_PTOENT, "
	cQuery += "DAK_VALOR, DAK_HORA, DAI_COD, DAI_SEQCAR,DAI_SEQUEN, DAI_PEDIDO, DAI_CLIENT, DAI_LOJA, "
	cQuery += "DAI_PESO, DAI_CAPVOL, DAI_NFISCA,DAI_SERIE"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Esta Rotina adiciona a cQuery os campos selecionados pelo usuario  |
	//³no filtro do usuario.                                              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStruDAK := DAK->(dbStruct())
	If !Empty(aReturn[7])
		For nX := 1 To DAK->(FCount())
			cName := DAK->(FieldName(nX))
			If AllTrim( cName ) $ aReturn[7]
				If aStruDAK[nX,2] <> "M"  
					If !cName $ cQuery .And. !cName $ cQryAd
						cQryAd += ","+cName
					EndIf
				EndIf
			EndIf
		Next nX

		cQuery += cQryAd

	EndIf

	If	lRemito
		cQuery	+=	", DAI_REMITO, DAI_SERREM "
	EndIf
	If	nTipoOper == 2 .Or. nTipoOper == 3
		cQuery += ",DAI_FILPV "
	EndIf

	If	mv_par11 == 2
		cQuery += ",C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO ,C9_ITEM, C9_PRODUTO, C9_QTDLIB, C9_PRCVEN, C9_CARGA, C9_SEQCAR, C9_NFISCAL, C9_SERIENF, B1_COD, B1_DESC,B1_UM,B1_SEGUM, B1_PESO, B1_PESBRU "
		If	cPaisLoc <> "BRA"
			cQuery	+=	", C9_REMITO "
		EndIf
		If	mv_par14 == 1
			cQuery += ", C9_LOTECTL, C9_NUMLOTE "
		EndIf
	EndIf

	cQuery += " FROM "+ RetSqlName("DAK")+ " DAK , "
	cQuery += RetSqlName("DAI")+ " DAI "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o relatorio for analitico inclui os arquivos do SC9                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	mv_par11 == 2
		cQuery += ", "+RetSqlName("SB1")+ " SB1 , "
		cQuery += RetSqlName("SC9")+ " SC9   "
	EndIf

	cQuery += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"' "
	cQuery += " AND DAK_COD >= '"+mv_par01+"' AND DAK_COD <='"+mv_par02+"' "
	cQuery += " AND DAK_SEQCAR >= '"+mv_par03+"' AND DAK_SEQCAR <='"+mv_par04+"' "
	cQuery += " AND DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' "
	cQuery += " AND DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' "
	cQuery += " AND DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' "
	cQuery += " AND DAK.D_E_L_E_T_ = ' '"

	cQuery += " AND DAI_FILIAL = '"+xFilial("DAI")+"' "
	cQuery += " AND DAI_COD = DAK_COD "
	cQuery += " AND DAI_SEQCAR = DAK_SEQCAR "
	cQuery += " AND DAI.D_E_L_E_T_ = ' '"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o relatorio for analitico relaciona os arquivos do SC9             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	mv_par11 == 2

		cQuery += " AND C9_FILIAL = "+Iif(nTipoOper == 1, "'"+xFilial("SC9")+"'", OsFilQry("SC9","DAI.DAI_FILPV") )

		cQuery += " AND C9_PEDIDO = DAI_PEDIDO "
		cQuery += " AND C9_CLIENTE = DAI_CLIENT "
		cQuery += " AND C9_LOJA = DAI_LOJA "
		cQuery += " AND C9_CARGA = DAI_COD "
		cQuery += " AND C9_SEQCAR = DAI_SEQCAR "
		cQuery += " AND SC9.D_E_L_E_T_ = ' '"

		cQuery += " AND B1_FILIAL = "+Iif(nTipoOper == 1,"'"+xFilial("SB1")+"'",OsFilQry("SB1","SC9.C9_FILIAL") )
		If cPaisLoc <> "BRA" .And. SC9->(FieldPos("C9_DOCGER")) > 0  .And. SC9->C9_DOCGER == "2"
			bIfSC9	:=	{|| (cAliasSC9)->C9_REMITO == (cAliasDAI)->DAI_REMITO }
		Else
			bIfSC9	:=	{|| (cAliasSC9)->(C9_NFISCAL+C9_SERIENF) == (cAliasDAI)->(DAI_NFISCA+DAI_SERIE) }
		EndIf
		cQuery += " AND B1_COD = C9_PRODUTO "
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery += " ORDER BY DAK_COD,DAK_SEQCAR,DAI_SEQUEN,DAI_PEDIDO"+Iif(mv_par11 == 2,",C9_ITEM ","")
	cQuery := ChangeQuery(cQuery)
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBCAR",.F.,.T.)

	For nX := 1 To Len(aStruQry)
		If ( aStruQry[nX][2] <> "C" )
			TcSetField("TRBCAR",aStruQry[nX][1],aStruQry[nX][2],aStruQry[nX][3],aStruQry[nX][4])
		EndIf
	Next nX

	cAliasDAK := "TRBCAR"
	cAliasDAI := "TRBCAR"
	cAliasSC9 := "TRBCAR"
	cAliasSB1 := "TRBCAR"
	lQuery    := .T.
Else
	cKey := IndexKey()
	cCondicao := 'DAK_FILIAL == "'+xFilial("DAK")+'".And.' 
	cCondicao += 'DAK_COD >= "'+mv_par01+'".And.DAK_COD <="'+mv_par02+'".And.'
	cCondicao += 'DAK_SEQCAR >= "'+mv_par03+'".And.DAK_SEQCAR <="'+mv_par04+'".And.'
	cCondicao += 'DAK_CAMINH >= "'+mv_par05+'".And.DAK_CAMINH <="'+mv_par06+'".And.'
	cCondicao += 'DAK_MOTORI >= "'+mv_par07+'".And.DAK_MOTORI <="'+mv_par08+'".And.'
	cCondicao += 'Dtos(DAK_DATA) >= "'+Dtos(mv_par09)+'".And.Dtos(DAK_DATA) <="'+Dtos(mv_par10)+'"'

	IndRegua("DAK",cIndDAK,cKey,,cCondicao,STR0016) //"Selecionando Registros ..."
	nIndDAK := RetIndex("DAK")
	DbSetOrder(nIndDAK+1)

	cAliasDAK := "DAK"
	cAliasDAI := "DAI"
	cAliasSC9 := "SC9"
	cAliasSB1 := "SB1"
EndIf

DbSelectArea(cAliasDAK)
dbGotop()
While !Eof()
	If !Empty(cFilter) .And. !(&cFilter.)
		DbSkip()
		Loop
	EndIf
	lFirst := .T.

	#IFNDEF WINDOWS
		If LastKey() = 286
			lEnd := .T.
		EndIf
	#ENDIF
	If lEnd
		@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	If ( li > 60 )
		li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
		li++
	EndIf


	DbSelectArea("DA3")
	DbSetOrder(1)
	MsSeek(xFilial("DA3")+(cAliasDAK)->DAK_CAMINH)

	DbSelectArea("DA4")
	DbSetOrder(1)
	MsSeek(xFilial("DA4")+(cAliasDAK)->DAK_MOTORI)

	@ li,000 PSAY OemtoAnsi(STR0006)+(cAliasDAK)->DAK_COD+"-"+(cAliasDAK)->DAK_SEQCAR //"CARGA   : "
	li++
	@ li,000 PSAY OemtoAnsi(STR0007)+(cAliasDAK)->DAK_CAMINH + " - " + DA3->DA3_DESC //"VEICULO : "
	@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasDAK)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "
	li++
	@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
	@ li,010 PSAY (cAliasDAK)->DAK_PESO   Picture PesqPict("DAK","DAK_PESO")
	@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
	@ li,037 PSAY (cAliasDAK)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")
	@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
	@ li,067 PSAY (cAliasDAK)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")
	@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "
	@ li,084 PSAY (cAliasDAK)->DAK_VALOR  Picture PesqPict("DAK","DAK_VALOR")
	li++
	@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasDAK)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasDAK)->DAK_HORA //"DATA    :"###" AS "
	li++
	@ li,000 PSAY Replicate('-',limite)
	li++

	If !lQuery
		DbSelectArea(cAliasDAI)
		DbSetOrder(1)
		MsSeek(xfilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR)

		bWhileDAI := { || !Eof() .And. (cAliasDAI)->DAI_FILIAL+(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == ;
						xFilial("DAI")+(cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR }
	Else
		cCodDAK   := (cAliasDAK)->DAK_COD
		cSeqDAK   := (cAliasDAK)->DAK_SEQCAR
		bWhileDAI :=  {|| (cAliasDAI)->(!Eof()) .And. (cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR == cCodDAK+cSeqDAK }
	EndIf

	While Eval(bWhileDAI)

		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		EndIf
		cFilPv := Iif(nTipoOper == 1,xFilial("SC5"), (cAliasDAI)->DAI_FILPV )
		SC5->(DbSetOrder(1))
		SC5->(MsSeek(OsFilial('SC5',cFilPv)+(cAliasDAI)->DAI_PEDIDO))

		cNReduz := ""
		If !SC5->C5_TIPO $ "BD"
			cFilPv := Iif(nTipoOper == 1, xFilial("SA1"),(cAliasDAI)->DAI_FILPV)
			SA1->(DbSetOrder(1))
			SA1->(MsSeek(OsFilial("SA1",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA))
			cNReduz := SA1->A1_NREDUZ
		Else
			cFilPv := Iif(nTipoOper == 1, xFilial("SA2"),(cAliasDAI)->DAI_FILPV)
			SA2->(DbSetOrder(1))
			SA2->(MsSeek(OsFilial("SA2",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA))
			cNReduz := SA2->A2_NREDUZ
		EndIf

		If mv_par11 == 1

			@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
			@ li,010 PSAY (cAliasDAI)->DAI_PEDIDO
			@ li,017 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA
			@ li,027 PSAY Substr(cNReduz,1,30)
			@ li,059 PSAY (cAliasDAI)->DAI_PESO Picture PesqPict("DAI","DAI_PESO")
			@ li,074 PSAY (cAliasDAI)->DAI_CAPVOL Picture PesqPict("DAI","DAI_CAPVOL")
			If lRemito .And. !Empty((cAliasDAI)->DAI_REMITO )
				@ li,089 PSAY Alltrim(RetTitle("DAI_REMITO")) + STR0018
				@ li,109 PSAY (cAliasDAI)->DAI_REMITO+" "+(cAliasDAI)->DAI_SERREM
			ElseIf !Empty((cAliasDAI)->DAI_NFISCA )
				@ li,089 PSAY OemToAnsi(STR0017)
				@ li,109 PSAY (cAliasDAI)->DAI_NFISCA+" "+(cAliasDAI)->DAI_SERIE
			EndIf

			If lQuery
				li++
				DbSelectArea(cAliasDAI)
				dbSkip()
				Loop
			EndIf

		Else
			If !lFirst
				@ li,000 PSAY Replicate('-',limite)
				lFirst := .F.
			EndIf

			li++
			@ li,000 PSAY (cAliasDAI)->DAI_SEQUEN
			@ li,010 PSAY (cAliasDAI)->DAI_PEDIDO
			@ li,017 PSAY (cAliasDAI)->DAI_CLIENT+"-"+(cAliasDAI)->DAI_LOJA
			@ li,027 PSAY Substr(cNReduz,1,30)
			@ li,059 PSAY (cAliasDAI)->DAI_PESO Picture PesqPict("DAI","DAI_PESO")
			@ li,074 PSAY (cAliasDAI)->DAI_CAPVOL Picture PesqPict("DAI","DAI_CAPVOL")
			If lRemito .And. !Empty((cAliasDAI)->DAI_REMITO )
				@ li,089 PSAY Alltrim(RetTitle("DAI_REMITO")) + STR0018
				@ li,109 PSAY (cAliasDAI)->DAI_REMITO+" "+(cAliasDAI)->DAI_SERREM 
			ElseIf !Empty((cAliasDAI)->DAI_NFISCA )
				@ li,089 PSAY OemToAnsi(STR0017)
				@ li,109 PSAY (cAliasDAI)->DAI_NFISCA+" "+(cAliasDAI)->DAI_SERIE 
			EndIf

			li++

			@ li,000 PSAY Replicate('-',limite)
			li++
			@ li,000 PSAY If(mv_par14==1,OemtoAnsi(STR0023),OemtoAnsi(STR0015))	//"ITEM PRODUTO                         DESCRICAO                       LOTE       SUBLOTE     QTD. 1aUM  UNIDADE   QTD. 2aUM   SEG.UN.MED.        VALOR           PESO        VOLUME"
																					//"ITEM PRODUTO                         DESCRICAO                           QTD 1aUM  UNID.      QTD 2aUM   SEG.UN.MED.        VALOR           PESO        VOLUME"
			li++
			@ li,000 PSAY Replicate('-',limite)

			If lQuery

				cCarDAK := (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR
				cCliDAI := (cAliasDAI)->DAI_CLIENT + (cAliasDAI)->DAI_LOJA
				cPedDAI := (cAliasDAI)->DAI_PEDIDO

				bWhileSC9 := {|| (cAliasSC9)->(!Eof()) .And. (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR+(cAliasSC9)->C9_CLIENTE + (cAliasSC9)->C9_LOJA + (cAliasSC9)->C9_PEDIDO == ;
								cCarDAK+cCliDAI+cPedDAI }

			Else

				cFilPv := Iif(nTipoOper == 1,xFilial("SC9"), (cAliasDAI)->DAI_FILPV )

				DbSelectArea(cAliasSC9)
				DbSetOrder(2)
				MsSeek(OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA+(cAliasDAI)->DAI_PEDIDO)

				bWhileSC9 := {|| !Eof() .And. (cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_CLIENTE+(cAliasSC9)->C9_LOJA+(cAliasSC9)->C9_PEDIDO == ;
								OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_CLIENT+(cAliasDAI)->DAI_LOJA+(cAliasDAI)->DAI_PEDIDO }

			EndIf
			bIfSC9	:=	{|| .T. }

			If cPaisLoc <> "BRA"
				If SC5->(FieldPos("C5_DOCGER")) > 0 
					cFilPv := Iif(nTipoOper == 1,xFilial("SC9"), (cAliasDAI)->DAI_FILPV )
					SC5->(DbSetOrder(1))
					SC5->(MsSeek(OsFilial('SC5',cFilPv)+(cAliasSC9)->C9_PEDIDO))
					If SC5->C5_DOCGER == "2"
						bIfSC9	:=	{||(cAliasSC9)->C9_REMITO == (cAliasDAI)->DAI_REMITO}
					Else
						bIfSC9	:=	{||(cAliasSC9)->C9_NFISCAL+(cAliasSC9)->C9_SERIENF == (cAliasDAI)->DAI_NFISCA+(cAliasDAI)->DAI_SERIE}
					EndIf
				EndIf
			EndIf

			While Eval(bWhileSC9)
				If Eval(bIfSC9)
					li++

					If ( li > 60 )
						li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
						li++
					EndIf

					cFilPv := Iif(nTipoOper == 1, xFilial("SB1"), (cAliasSC9)->C9_FILIAL )

					If !lQuery
						DbSelectArea(cAliasSB1)
						DbSetOrder(1)
						MsSeek(OsFilial("SB1",(cAliasSC9)->C9_FILIAL)+(cAliasSC9)->C9_PRODUTO)
					EndIf

					nCapArm := OsPrCapArm((cAliasSB1)->B1_COD, cFilPv)

					If Getmv("MV_PESOCAR") == "L"
						nPeso := ((cAliasSB1)->B1_PESO   * (cAliasSC9)->C9_QTDLIB)
					Else
						nPeso := ((cAliasSB1)->B1_PESBRU * (cAliasSC9)->C9_QTDLIB)
					EndIf
					nCapVol := (nCapArm * (cAliasSC9)->C9_QTDLIB)

					//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
					//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
					//|ITEM PRODUTO                          DESCRICAO                       LOTE       SUBLOTE     QTD. 1aUM  		UNIDADE		QTD. 2aUM		SEG.UN.MED.		VALOR           PESO         	VOLUME                              |
					//|XXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXX XXXXXX		XX,XXX,XXX,XX  	XX			XX,XXX,XXX,XX  	XX				XX,XXX,XXX,XX  	XX,XXX,XXX,XX  	XX,XXX,XXX,XX                       |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
					//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
					//|ITEM PRODUTO                          DESCRICAO                          QTD. 1aUM  		UNID.   QTD. 2aUM		SEG.UN.MED.		VALOR           PESO         	VOLUME                                                      |
					//|XXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  	XX,XXX,XXX,XX  	XX		XX,XXX,XXX,XX  	XX				XX,XXX,XXX,XX	XX,XXX,XXX,XX  	XX,XXX,XXX,XX                                               |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					@ li,000 PSAY (cAliasSC9)->C9_ITEM
					@ li,005 PSAY (cAliasSC9)->C9_PRODUTO
					@ li,037 PSAY Substr((cAliasSB1)->B1_DESC,1,30)
					If	mv_par14 == 1
						@ li,069 PSAY (cAliasSC9)->C9_LOTECTL
						@ li,080 PSAY (cAliasSC9)->C9_NUMLOTE
						nCols := 20
					EndIf
					@ li,072+nCols PSAY (cAliasSC9)->C9_QTDLIB Picture PesqPict("SC9","C9_QTDLIB")
					@ li,083+nCols PSAY (cAliasSC9)->B1_UM
					@ li,093+nCols PSAY ConvUM((cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_QTDLIB,0,2) Picture PesqPict("SC9","C9_QTDLIB")
					@ li,105+nCols PSAY (cAliasSC9)->B1_SEGUM
					@ li,115+nCols PSAY (cAliasSC9)->C9_QTDLIB*(cAliasSC9)->C9_PRCVEN Picture "@E 999,999,999.99"
					@ li,130+nCols PSAY nPeso   Picture "@E 999,999,999.99"
					@ li,144+nCols PSAY nCapVol Picture "@E 999,999,999.99"

					nQuantIt  += (cAliasSC9)->C9_QTDLIB
					nQuant2It += ConvUM((cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_QTDLIB,0,2)
					nValorIt  +=(cAliasSC9)->C9_QTDLIB*(cAliasSC9)->C9_PRCVEN
					nPesoIt   += nPeso
					nVolIt    += nCapVol
					cItem     := (cAliasSC9)->C9_ITEM
					cPedido   := (cAliasSC9)->C9_PEDIDO
					cCarga    := (cAliasSC9)->C9_CARGA
					cSeqCar   := (cAliasSC9)->C9_SEQCAR
				EndIf
				DbSelectArea(cAliasSC9)
				dbSkip()

				/*If	cItem <> (cAliasSC9)->C9_ITEM .Or. cPedido <> (cAliasSC9)->C9_PEDIDO .Or.;
					(cCarga <> (cAliasSC9)->C9_CARGA .Or. cSeqCar <> (cAliasSC9)->C9_SEQCAR)
					li++
					@ li,000 PSAY Replicate('-',limite)
					li++
					@ li,000 PSAY "TOTAL DO ITEM -->"
					@ li,072+nCols PSAY nQuantIt 	Picture PesqPict("SC9","C9_QTDLIB")
					@ li,093+nCols PSAY nQuant2It	Picture PesqPict("SC9","C9_QTDLIB")
					@ li,115+nCols PSAY nValorIt 	Picture "@E 999,999,999.99"
					@ li,130+nCols PSAY nPesoIt 	Picture "@E 999,999,999.99"
					@ li,144+nCols PSAY nVolIt 		Picture "@E 999,999,999.99"
					li++
					nQuantIt  := 0
					nQuant2It := 0
					nValorIt  := 0
					nPesoIt   := 0
					nVolIt    := 0
				EndIf*/
			Enddo
		EndIf
		li++

		DbSelectArea(cAliasDAI)

		If !lQuery
			dbSkip()
		EndIf
	Enddo
	li++
	If	mv_par12 == 1
		li := 80
	EndIf

	DbSelectArea(cAliasDAK)
	If !lQuery
		dbSkip()
	EndIf

Enddo

If (lImp)
	Roda(cbCont,cbText,Tamanho)
EndIf

If lQuery
	DbSelectArea("TRBCAR")
	dbCloseArea()
Else
	DbSelectArea("DAK")
	RetIndex("DAK")
	dbClearFilter()
EndIf

Set Device To Screen
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
EndIf
MS_FLUSH()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpPrdSC9³ Autor ³ Henry Fila            ³ Data ³02.07.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio por sequencia de entrega     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpPrdSC9(lEnd,wnrel,cString,nomeprog,Titulo)
Local oTempTable:= NIL

Local aStruQry  := {}
Local aStruDAK  := {}
Local aStruSC9  := {}

Local cbCont    := 0   // Numero de Registros Processados
Local cbText    := ""  // Mensagem do Rodape
Local cIndDAK   := ""
Local cQuery    := ""
Local cCodDAK   := ""
Local cSeqDAK   := ""
Local cCliDAI   := ""
Local cPedDAI   := ""
Local cFilPv    := ""
Local cAliasDAK := "DAK"
Local cAliasDAI := "DAI"
Local cAliasSC9 := "SC9"
Local cAliasSB1 := "SB1"
Local cAliasDA3 := "DA3"
Local cAliasDA4 := "DA4"
Local cSeek		:= ""

Local nIndDAK   := 0
Local nPeso     := 0
Local nCapVol   := 0
Local nTipoOper := OsVlEntCom()
Local nPosProd  := 0
Local nX        := 0
Local nCols     := 0

Local lFirst    := .T.
Local lImp      := .F. // Indica se algo foi impresso
Local lQuery    := .F.

Local lRemito   := DAI->(FieldPos("DAI_REMITO")) > 0 .And. DAI->(FieldPos("DAI_SERREM")) > 0
Local cFilter   := aReturn[7]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime as cargas selecionada    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cTabant := ""
Local li      := 100 // Contador de Linhas

//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
//|XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX  XXXXXX   XXX,XXX.XX XXX,XXX.XX  XXX,XXX.XX XXX,XXX.XX  XXX.XXX     XX  XXXXXXXXXX                                                                                         |
//|CARGA   : XXXXXX-XX                                                                                                                                                                                                          |
//|VEICULO : XXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXX     MOTORISTA : XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                                       |
//|PESO    : XXXX,XXX.XX    VOLUME M3 : XXXX,XXX.XX    PTOS ENTREGA : XXXXXX   VALOR : XXX,XXX,XXX.XX                                                                                                                           |
//|DATA    : XX/XX/XX AS XX:XX		                                                                                                                                                                                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCabec1 := If(mv_par14==1,OemtoAnsi(STR0022),OemtoAnsi(STR0021))	//"PRODUTO                          DESCRICAO                      LOTE       SUBLOTE  QTD. 1aUM     UNID.     QTD. 2aUM 2aUM                  PESO         VOLUME             VALOR"
																		//"PRODUTO                          DESCRICAO                      QTD. 1aUM     UNID.     QTD. 2aUM 2aUM                  PESO         VOLUME             VALOR"

//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
//|PRODUTO           DESCRICAO                      LOTE       SUBLOTE	QTD 1aUM  		UNID.	QTD 2aUM		2aUNI.	PESO      	VOLUME		VALOR                                                                           |
//|XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXX XXXXXX  	XX,XXX,XXX,XX 	XX		XX,XXX,XXX,XX  	XX		XX,XXX,XX   XX,XXX,XX  	XX,XXX,XXX,XX                                                                   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
//|PRODUTO           DESCRICAO                          QTD 1aUM		UNID.	QTD 2aUM   		SEG.UN.MED.		PESO      	VOLUME    	VALOR                                                                                   |
//|XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		XX,XXX,XXX,XX 	XX  	XX,XXX,XXX,XX  	XX				XX,XXX,XX   XX,XXX,XX	XX,XXX,XXX,XX                                                                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCabec2 := ""

Local nTotQtd := 0
Local nTotQtd2:= 0
Local nTotPes := 0
Local nTotVol := 0
Local nTotVlr := 0

DbSelectArea(cString)
DbSetOrder(2)
cIndDAK := CriaTrab(NIL,.F.)

If TcSrvType() != "AS/400"

	aStruDAK := DAK->(dbStruct())
	aStruSC9 := SC9->(dbStruct())

	cAliasQRY := "TRBQRY"

	cAliasDAK := cAliasQRY
	cAliassc9 := cAliasQRY
	cAliasSB1 := cAliasQRY

	If mv_par11 == 2
		cQuery := "SELECT C9_CARGA,C9_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_PESO,"
		cQuery += "DAK_HORA,C9_PRODUTO,C9_LOTECTL,C9_NUMLOTE,B1_DESC,B1_PESO,B1_PESBRU,B1_UM,B1_SEGUM,C9_QTDLIB,C9_PRCVEN"
		cQuery += " FROM "
		cQuery += RetSqlName("SC9") + " SC9, "

		cQuery += RetSqlName("SB1") + " SB1, "
		cQuery += RetSqlName("DAK") + " DAK "

		cQuery += " WHERE "		
		cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND "
		cQuery += "C9_CARGA  >= '"+mv_par01+"' AND "
		cQuery += "C9_CARGA  <= '"+mv_par02+"' AND "
		cQuery += "C9_SEQCAR >= '"+mv_par03+"' AND "
		cQuery += "C9_SEQCAR <= '"+mv_par04+"' AND "
		cQuery += "SC9.D_E_L_E_T_ = ' ' AND "

		cQuery += "B1_FILIAL = '"+xFilial("SB1")+ "' AND "
		cQuery += "B1_COD = C9_PRODUTO AND "
		cQuery += "SB1.D_E_L_E_T_ = ' ' AND "

		cQuery += "DAK_FILIAL = '"+xFilial("DAK")+"' AND "
		cQuery += "DAK_COD    = C9_CARGA AND "
		cQuery += "DAK_SEQCAR = C9_SEQCAR AND "
		cQuery += "DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' AND "
		cQuery += "DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' AND "
		cQuery += "DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' AND "
		cQuery += "DAK.D_E_L_E_T_ = ' '"

		cQuery += "ORDER BY C9_CARGA,C9_SEQCAR,C9_PRODUTO"

		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)
	Else
		cQuery := "SELECT C9_CARGA,C9_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_PESO,"
		cQuery += "DAK_HORA,C9_PRODUTO,C9_LOTECTL,C9_NUMLOTE,B1_DESC,B1_PESO,B1_PESBRU,B1_UM,B1_SEGUM, SUM(C9_QTDLIB) QTDE, SUM(C9_QTDLIB*C9_PRCVEN) VALOR"
		cQuery += " FROM "
		cQuery += RetSqlName("SC9") + " SC9, "

		cQuery += RetSqlName("SB1") + " SB1, "
		cQuery += RetSqlName("DAK") + " DAK "

		cQuery += " WHERE "
		cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND "
		cQuery += "C9_CARGA  >= '"+mv_par01+"' AND "
		cQuery += "C9_CARGA  <= '"+mv_par02+"' AND "
		cQuery += "C9_SEQCAR >= '"+mv_par03+"' AND "
		cQuery += "C9_SEQCAR <= '"+mv_par04+"' AND "
		cQuery += "SC9.D_E_L_E_T_ = ' ' AND "

		cQuery += "B1_FILIAL = '"+xFilial("SB1")+ "' AND "
		cQuery += "B1_COD = C9_PRODUTO AND "
		cQuery += "SB1.D_E_L_E_T_ = ' ' AND "

		cQuery += "DAK_FILIAL = '"+xFilial("DAK")+"' AND "
		cQuery += "DAK_COD    = C9_CARGA AND "
		cQuery += "DAK_SEQCAR = C9_SEQCAR AND "
		cQuery += "DAK_CAMINH >= '"+mv_par05+"' AND DAK_CAMINH <='"+mv_par06+"' AND "
		cQuery += "DAK_MOTORI >= '"+mv_par07+"' AND DAK_MOTORI <='"+mv_par08+"' AND "
		cQuery += "DAK_DATA >= '"+Dtos(mv_par09)+"' AND DAK_DATA <='"+Dtos(mv_par10)+"' AND "
		cQuery += "DAK.D_E_L_E_T_ = ' '"

		cQuery += "GROUP BY "
		cQuery += "C9_CARGA,C9_SEQCAR,DAK_MOTORI,DAK_CAMINH,DAK_DATA,DAK_CAPVOL,DAK_PTOENT,DAK_VALOR,DAK_PESO,"
		cQuery += "DAK_HORA,C9_PRODUTO,C9_LOTECTL,C9_NUMLOTE,B1_DESC,B1_PESO,B1_PESBRU,B1_UM,B1_SEGUM "

		cQuery += "ORDER BY C9_CARGA,C9_SEQCAR,C9_PRODUTO"

		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)
	EndIf
	For nX := 1 To Len(aStruDAK)
		If aStruDAK[nX][2]!="C"
			TcSetField(cAliasDAK,aStruDAK[nX][1],aStruDAK[nX][2],aStruDAK[nX][3],aStruDAK[nX][4])
		EndIf
	Next nX

	For nX := 1 To Len(aStruSC9)
		If aStruSC9[nX][2]!="C"
			TcSetField(cAliasSC9,aStruSC9[nX][1],aStruSC9[nX][2],aStruSC9[nX][3],aStruSC9[nX][4])
		EndIf
	Next nX

	While (cAliasQRY)->(!Eof())

		If lEnd
			@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		EndIf

		DbSelectArea("DA3")
		DbSetOrder(1)
		MsSeek(xFilial("DA3")+(cAliasDAK)->DAK_CAMINH)

		DbSelectArea("DA4")
		DbSetOrder(1)
		MsSeek(xFilial("DA4")+(cAliasDAK)->DAK_MOTORI)

		cCarga := (cAliasQRY)->C9_CARGA+(cAliasQRY)->C9_SEQCAR

		@ li,000 PSAY OemtoAnsi(STR0006)+(cAliasQRY)->C9_CARGA+"-"+(cAliasQRY)->C9_SEQCAR //"CARGA   : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0007)+(cAliasQRY)->DAK_CAMINH + " - " + DA3->DA3_DESC //"VEICULO : "
		@ li,055 PSAY OemtoAnsi(STR0008)+(cAliasQRY)->DAK_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :"
		@ li,010 PSAY (cAliasQRY)->DAK_PESO Picture PesqPict("DAK","DAK_PESO")
		@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
		@ li,037 PSAY (cAliasQRY)->DAK_CAPVOL Picture PesqPict("DAK","DAK_CAPVOL")
		@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
		@ li,067 PSAY (cAliasQRY)->DAK_PTOENT Picture PesqPict("DAK","DAK_PTOENT")
		@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "
		@ li,084 PSAY (cAliasQRY)->DAK_VALOR Picture PesqPict("DAK","DAK_VALOR")
		li++
		@ li,000 PSAY OemtoAnsi(STR0013) +DtoC((cAliasQRY)->DAK_DATA) + OemtoAnsi(STR0014) + (cAliasDAK)->DAK_HORA //"DATA    :"###" AS "
		li++
		@ li,000 PSAY Replicate('-',limite)
		li++

		aTotais := {0,0,0,0,0}
		While (cAliasQRY)->(!Eof()) .And. (cAliasQRY)->C9_CARGA+(cAliasQRY)->C9_SEQCAR == cCarga

			If lEnd
				@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			EndIf

			nCapArm := OsPrCapArm((cAliasQRY)->C9_PRODUTO, cFilPv)

			If Getmv("MV_PESOCAR") == "L"
				nPeso := ((cAliasSB1)->B1_PESO   * IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB))
			Else
				nPeso := ((cAliasSB1)->B1_PESBRU * IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB))
			EndIf

			nCapVol  := ( nCapArm * IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB) )
			//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
			//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
			//|PRODUTO         DESCRICAO                       QTD. 1aUM      UNID.  QTD. 2aUM      2aUM           PESO      VOLUME          VALOR
			//|XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX,XXX,XXX,XX  XX     XX,XXX,XXX,XX  XX        XX,XXX,XX   XX,XXX,XX   XX,XXX,XXX,XX                                                                                               |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ li,000 PSAY (cAliasQRY)->C9_PRODUTO
			@ li,017 PSAY PADR((cAliasQRY)->B1_DESC,30)
			If	mv_par14 == 1
			//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
			//Ú01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890¿
			//|PRODUTO         DESCRICAO                      LOTE       SUBLOTE QTD 1aUM  	   UNID. QTD 2aUM	   2aUNI. PESO      VOLUME	  VALOR                                                                                         |
			//|XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXX XXXXXX  XX,XXX,XXX,XX XX	 XX,XXX,XXX,XX XX	  XX,XXX,XX XX,XXX,XX XX,XXX,XXX,XX                                                                                 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ li,047 PSAY (cAliasQRY)->C9_LOTECTL
				@ li,058 PSAY (cAliasQRY)->C9_NUMLOTE
				nCols := 19
			EndIf
			@ li,049+nCols PSAY IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB) Picture PesqPict("SC9","C9_QTDLIB")
			@ li,064+nCols PSAY (cAliasQRY)->B1_UM
			@ li,071+nCols PSAY ConvUm((cAliasQRY)->C9_PRODUTO,IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB),0,2) Picture PesqPict("SC9","C9_QTDLIB")
			@ li,086+nCols PSAY (cAliasQRY)->B1_SEGUM
			@ li,096+nCols PSAY nPeso               Picture "@E 99,999.99"
			@ li,108+nCols PSAY nCapVol             Picture "@E 99,999.99"
			@ li,119+nCols PSAY IIF(mv_par11 == 1,(cAliasQRY)->VALOR,(cAliasSC9)->C9_QTDLIB*(cAliasSC9)->C9_PRCVEN)  Picture "@E 99,999,999.99"
			// Totais da Carga
			aTotais[1] += IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB)
			aTotais[2] += ConvUm((cAliasQRY)->C9_PRODUTO,IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB),0,2)
			aTotais[3] += nPeso
			aTotais[4] += nCapVol
			aTotais[5] += IIF(mv_par11 == 1,(cAliasQRY)->VALOR,IIF(mv_par11 == 1,(cAliasQRY)->VALOR,(cAliasSC9)->C9_QTDLIB*(cAliasSC9)->C9_PRCVEN))

			// Total Geral
			nTotQtd  += IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB)
			nTotQtd2 += ConvUm((cAliasQRY)->C9_PRODUTO,IIF(mv_par11 == 1,(cAliasQRY)->QTDE,(cAliasSC9)->C9_QTDLIB),0,2)
			nTotPes  += nPeso
			nTotVol  += nCapVol
			nTotVlr  += IIF(mv_par11 == 1,(cAliasQRY)->VALOR,IIF(mv_par11 == 1,(cAliasQRY)->VALOR,(cAliasSC9)->C9_QTDLIB*(cAliasSC9)->C9_PRCVEN))
			li++

			(cAliasQRY)->(dbSkip())
		EndDo

		li++
		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		EndIf
		@ li,000       PSAY STR0025     //"Total ---> "
		@ li,048+nCols PSAY aTotais[1]  Picture PesqPict("SC9","C9_QTDLIB")
		@ li,070+nCols PSAY aTotais[2]  Picture PesqPict("SC9","C9_QTDLIB")
		@ li,095+nCols PSAY aTotais[3]  Picture "@E 99,999.99"
		@ li,107+nCols PSAY aTotais[4]  Picture "@E 99,999.99"
		@ li,118+nCols PSAY aTotais[5]  Picture "@E 99,999,999.99"

		If mv_par12 == 1
			li := 80
		Else
			li+=2
		EndIf

	EndDo
	DbSelectArea(cAliasQRY)
	dbCloseArea()
Else
	Omr020Trb(@oTempTable,aReturn[8])
	DbSelectArea("DAK")
	DbSetOrder(1)
	cKey := IndexKey()

	cCondicao := 'DAK_FILIAL == "'+xFilial("DAK")+'".And.'
	cCondicao += 'DAK_COD >= "'+mv_par01+'".And.DAK_COD <="'+mv_par02+'".And.'
	cCondicao += 'DAK_SEQCAR >= "'+mv_par03+'".And.DAK_SEQCAR <="'+mv_par04+'".And.'
	cCondicao += 'DAK_CAMINH >= "'+mv_par05+'".And.DAK_CAMINH <="'+mv_par06+'".And.'
	cCondicao += 'DAK_MOTORI >= "'+mv_par07+'".And.DAK_MOTORI <="'+mv_par08+'".And.'
	cCondicao += 'Dtos(DAK_DATA) >= "'+Dtos(mv_par09)+'".And.Dtos(DAK_DATA) <="'+Dtos(mv_par10)+'"'

	IndRegua("DAK",cIndDAK,cKey,,cCondicao,STR0016) //"Selecionando Registros ..."
	nIndDAK := RetIndex("DAK")
	DbSetOrder(nIndDAK+1)

	cAliasDAK := "DAK"
	cAliasDAI := "DAI"
	cAliasSC9 := "SC9"
	cAliasSB1 := "SB1"

	While (cAliasDAK)->(!Eof() )

		If !Empty(cFilter) .And. !(&cFilter.)
			DbSkip()
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca itens da carga                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DAI->(DbSetOrder(1))
		DAI->(MsSeek(xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR))

		While (cAliasDAI)->(!Eof()) .And. DAI->DAI_FILIAL == xFilial("DAI") .And.;
											DAI->DAI_COD    == DAK->DAK_COD .And. ;
											DAI->DAI_SEQCAR == DAK->DAK_SEQCAR

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca pedidos da carga                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			cFilPv := Iif(nTipoOper == 1, xFilial("SC9"),(cAliasDAI)->DAI_FILPV)

			(cAliasSC9)->(DbSetOrder(1))
			(cAliasSC9)->(MsSeek(OsFilial("SC9",cFilPv)+(cAliasDAI)->DAI_PEDIDO))

			While (cAliasSC9)->(!Eof()) .And. (cAliasSC9)->C9_FILIAL == xFilial("SC9") .And. ;
												(cAliasSC9)->C9_PEDIDO == (cAliasDAI)->DAI_PEDIDO

				If	(cAliasSC9)->C9_CARGA  == (cAliasDAK)->DAK_COD .And. ;
					(cAliasSC9)->C9_SEQCAR == (cAliasDAK)->DAK_SEQCAR

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busca produtos para aglutinar conforme o relatório³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					(cAliasSB1)->(DbSetOrder(1))
					(cAliasSB1)->(MsSeek(xFilial("SB1")+(cAliasSC9)->C9_PRODUTO))

					nCapArm  := OsPrCapArm((cAliasSB1)->B1_COD, cFilPv)

					If	Getmv("MV_PESOCAR") == "L"
						nPeso := ((cAliasSB1)->B1_PESO   * (cAliasSC9)->C9_QTDLIB)
					Else
						nPeso := ((cAliasSB1)->B1_PESBRU * (cAliasSC9)->C9_QTDLIB)
					EndIf

					nCapVol  := ( nCapArm   * (cAliasSC9)->C9_QTDLIB )

					If	mv_par11 == 1
						cSeek := (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR+(cAliasSC9)->C9_PRODUTO
					else
						cSeek := (cAliasDAK)->DAK_COD+(cAliasDAK)->DAK_SEQCAR+(cAliasSC9)->C9_PRODUTO+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+SD2->D2_DOC+SD2->D2_SERIE
					endIf

					DbSelectArea("TRBPRO")
					If !MsSeek(cSeek)

						RecLock("TRBPRO",.T.)
						TRBPRO->TRB_CODCAR := (cAliasDAK)->DAK_COD
						TRBPRO->TRB_SEQCAR := (cAliasDAK)->DAK_SEQCAR
						TRBPRO->TRB_MOTORI := (cAliasDAK)->DAK_MOTORI
						TRBPRO->TRB_VEICUL := (cAliasDAK)->DAK_CAMINH
						TRBPRO->TRB_DATA   := (cAliasDAK)->DAK_DATA
						TRBPRO->TRB_HORA   := (cAliasDAK)->DAK_HORA
						TRBPRO->TRB_PTOENT := (cAliasDAK)->DAK_PTOENT
						TRBPRO->TRB_PESTOT := (cAliasDAK)->DAK_PESO
						TRBPRO->TRB_VOLTOT := (cAliasDAK)->DAK_CAPVOL
						TRBPRO->TRB_VALTOT := (cAliasDAK)->DAK_VALOR
						TRBPRO->TRB_CODPRO := (cAliasSC9)->C9_PRODUTO
						TRBPRO->TRB_DESPRO := (cAliasSB1)->B1_DESC
						TRBPRO->TRB_CODCLI := (cAliasSC9)->C9_CLIENTE
						TRBPRO->TRB_LOJA   := (cAliasSC9)->C9_LOJA
						TRBPRO->TRB_LOTEC  := SD2->D2_LOTECTL
						TRBPRO->TRB_NUMLO  := SD2->D2_NUMLOTE
					Else
						RecLock("TRBPRO",.F.)
					EndIf

					TRBPRO->TRB_QUANT  += (cAliasSC9)->C9_QTDLIB
					TRBPRO->TRB_PESO   += nPeso
					TRBPRO->TRB_CAPVOL += nCapvol
					TRBPRO->TRB_VALOR  += (cAliasSC9)->C9_QTDLIB * (cAliasSC9)->C9_PRCVEN
					MsUnlock()

				EndIf
				(cAliasSC9)->(dbSkip())

			EndDo
			(cAliasDAI)->(dbSkip())

		EndDo
		(cAliasDAK)->(dbSkip())

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impressao do relatorio                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRBPRO")
	dbGotop()

	While !Eof()

		#IFNDEF WINDOWS
			If LastKey() = 286
				lEnd := .T.
			EndIf
		#ENDIF
		If lEnd
			@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		EndIf

		cCarga := TRBPRO->TRB_CODCAR+TRBPRO->TRB_SEQCAR

		@ li,000 PSAY OemtoAnsi(STR0006)+TRBPRO->TRB_CODCAR+"-"+TRBPRO->TRB_SEQCAR //"CARGA   : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0007)+TRBPRO->TRB_VEICUL + " - " + DA3->DA3_DESC //"VEICULO : "
		@ li,055 PSAY OemtoAnsi(STR0008)+TRBPRO->TRB_MOTORI + " - " + DA4->DA4_NOME //"MOTORISTA : "
		li++
		@ li,000 PSAY OemtoAnsi(STR0009) //"PESO    :" 
		@ li,010 PSAY TRBPRO->TRB_PESTOT Picture PesqPict("DAK","DAK_PESO")
		@ li,025 PSAY OemtoAnsi(STR0010) //"VOLUME M3 : "
		@ li,037 PSAY TRBPRO->TRB_VOLTOT Picture PesqPict("DAK","DAK_CAPVOL")
		@ li,052 PSAY OemtoAnsi(STR0011) //"PTOS ENTREGA : "
		@ li,067 PSAY TRBPRO->TRB_PTOENT Picture PesqPict("DAK","DAK_PTOENT")
		@ li,076 PSAY OemtoAnsi(STR0012) //"VALOR : "
		@ li,084 PSAY TRBPRO->TRB_VALTOT Picture PesqPict("DAK","DAK_VALOR")
		li++
		@ li,000 PSAY OemtoAnsi(STR0013) +DtoC(TRBPRO->TRB_DATA) + OemtoAnsi(STR0014) + TRBPRO->TRB_HORA
		li++
		@ li,000 PSAY Replicate('-',limite)
		li++

		aTotais := {0,0,0,0,0}
		While TRBPRO->(!Eof()) .And. TRBPRO->TRB_CODCAR+TRBPRO->TRB_SEQCAR == cCarga

			If lEnd
				@ Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
				Exit
			EndIf

			If ( li > 60 )
				li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
				li++
			EndIf

			@ li,000 PSAY TRBPRO->TRB_CODPRO
			@ li,033 PSAY TRBPRO->TRB_DESPRO
			If	mv_par14 == 1
				@ li,064 PSAY TRBPRO->TRB_LOTEC
				@ li,075 PSAY TRBPRO->TRB_NUMLO
				nCols := 20
			EndIf
			@ li,064+nCols PSAY TRBPRO->TRB_QUANT  Picture PesqPict("SC9","C9_QTDLIB")
			@ li,088+nCols PSAY ConvUm(TRBPRO->TRB_CODPRO,TRBPRO->TRB_QUANT,0,2) Picture PesqPict("SC9","C9_QTDLIB")
			@ li,115+nCols PSAY TRBPRO->TRB_PESO   Picture "@E 99,999.99"
			@ li,130+nCols PSAY TRBPRO->TRB_CAPVOL Picture "@E 99,999.99"
			@ li,144+nCols PSAY TRBPRO->TRB_VALOR  Picture "@E 99,999,999.99"

			// Totais da Carga
			aTotais[1] += TRBPRO->TRB_QUANT
			aTotais[2] += ConvUm(TRBPRO->TRB_CODPRO,TRBPRO->TRB_QUANT,0,2)
			aTotais[3] += TRBPRO->TRB_PESO
			aTotais[4] += TRBPRO->TRB_CAPVOL
			aTotais[5] += TRBPRO->TRB_VALOR

			// Total Geral
			nTotQtd  += TRBPRO->TRB_QUANT
			nTotQtd2 += ConvUm(TRBPRO->TRB_CODPRO,TRBPRO->TRB_QUANT,0,2)
			nTotPes  += TRBPRO->TRB_PESO
			nTotVol  += TRBPRO->TRB_CAPVOL
			nTotVlr  += TRBPRO->TRB_VALOR
			li++
			TRBPRO->(dbSkip())
		EndDo

		li++
		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		EndIf

		@ li,000       PSAY STR0025    // "Total ---> "
		@ li,064+nCols PSAY aTotais[1] Picture PesqPict("SC9","C9_QTDLIB")
		@ li,088+nCols PSAY aTotais[2] Picture PesqPict("SC9","C9_QTDLIB")
		@ li,115+nCols PSAY aTotais[3] Picture "@E 99,999.99"
		@ li,130+nCols PSAY aTotais[4] Picture "@E 99,999.99"
		@ li,144+nCols PSAY aTotais[5] Picture "@E 99,999,999.99"

		If	mv_par12 == 1
			li := 80
		Else
			li+=2
		EndIf
	EndDo
	oTempTable:Delete()

	DbSelectArea("DAK")
	RetIndex("DAK")
	dbClearFilter()
EndIf

If MV_PAR11 == 1  //relatorio sintetico
	If nTotPes <> 0 .Or. nTotVol <> 0 .Or. nTotVlr <> 0
		If ( li > 60 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
		EndIf
		li += 2
		@ li,000       PSAY STR0024  //"Total Geral"
		@ li,064+nCols PSAY nTotQtd  Picture PesqPict("SC9","C9_QTDLIB")
		@ li,088+nCols PSAY nTotQtd2 Picture PesqPict("SC9","C9_QTDLIB")
		@ li,015+nCols PSAY nTotPes  Picture "@E 999,999.99"
		@ li,130+nCols PSAY nTotVol  Picture "@E 999,999.99"
		@ li,144+nCols PSAY nTotVlr  Picture "@E 999,999,999.99"
	EndIf
EndIf

If (lImp)
	Roda(cbCont,cbText,Tamanho)
EndIf

Set Device To Screen
Set Printer To
If (aReturn[5] = 1)
	dbCommitAll()
	OurSpool(wnrel)
EndIf
MS_FLUSH()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMR020Trb   ºAutor  ³Henry Fila          º Data ³  21/06/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria arquivo temporario para emissao do relatorio          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Nome do arquivo que sera gerado por referencia       º±±
±±º          ³ExpN2: Ordem dos produtos a serem listados                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5dl                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Omr020Trb(oTempTable,nOrdem)

Local aCampos := {}
Local cAlias  := ""

AAdd(aCampos,{"TRB_CODCAR" ,"C",06,0}) 
AAdd(aCampos,{"TRB_SEQCAR" ,"C",02,0}) 
AAdd(aCampos,{"TRB_MOTORI" ,"C",06,0}) 
AAdd(aCampos,{"TRB_VEICUL" ,"C",08,0}) 
AAdd(aCampos,{"TRB_DATA"   ,"D",08,0}) 
AAdd(aCampos,{"TRB_HORA"   ,"C",05,0}) 
AAdd(aCampos,{"TRB_PTOENT" ,"N",06,0}) 
AAdd(aCampos,{"TRB_PESTOT" ,"N",12,2}) 
AAdd(aCampos,{"TRB_VOLTOT" ,"N",12,2}) 
AAdd(aCampos,{"TRB_VALTOT" ,"N",12,2}) 
AAdd(aCampos,{"TRB_CODPRO" ,"C",15,0}) 
AAdd(aCampos,{"TRB_DESPRO" ,"C",30,0}) 
AAdd(aCampos,{"TRB_CODCLI" ,"C",Len(SA1->A1_COD),0}) 
AAdd(aCampos,{"TRB_LOJA"   ,"C",Len(SA1->A1_LOJA),0}) 
AAdd(aCampos,{"TRB_QUANT"  ,"N",12,2}) 
AAdd(aCampos,{"TRB_PESO"   ,"N",12,2}) 
AAdd(aCampos,{"TRB_CAPVOL" ,"N",12,2}) 
AAdd(aCampos,{"TRB_VALOR"  ,"N",12,2}) 
AAdd(aCampos,{"TRB_LOTEC"  ,"C",10,0}) 
AAdd(aCampos,{"TRB_NUMLO"  ,"C",06,0}) 

cAlias  := "TRBPRO"
oTempTable := FWTemporaryTable():New( cAlias )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("01", {"TRB_CODCAR","TRB_SEQCAR","TRB_CODPRO","TRB_CODCLI","TRB_LOJA"} )
oTempTable:Create()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaNome   ºAutor  ³Marco Bianchi       º Data ³ 19/11/2007º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca nome do cliente/fornecedor dependendo do tipo do     º±±
±±º          ³ pedido de vendas.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Filial_Numero do pedido de vendas                    º±±
±±º          ³ExpC2: Nome do cliente/fornececor                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8/P10                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaNome(cChave,cNReduz)
DbSelectArea("SC5")
DbSetOrder(1)
If DbSeek(cChave)
	If !SC5->C5_TIPO $ "BD"
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		cNReduz := SA1->A1_NREDUZ
	Else
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		cNReduz := SA2->A2_NREDUZ
	EndIf
EndIf

Return( cChave )
