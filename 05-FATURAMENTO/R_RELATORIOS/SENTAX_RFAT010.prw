#include 'rwmake.ch'
#include 'protheus.ch'
#include 'totvs.ch'
#include 'topconn.ch'
/*/{Protheus.doc} RFAT010
Relatório Análise de Vendas

@description	Rotina para gerar um relatório considerando as vendas e os custos envolvidos.

@author		dirlei@afsouza
@since		22/11/2017
@version	P12

@return		nil, nenhum

@type		function
/*/
user function RFAT010

local lContinua := .F.

private nI        := 0
private oComboBo1 := nil
private cComboBo1 := "1"
private oComboBo2 := nil
private cComboBo2 := "1"
private dEmisDe   := FirstDay(dDatabase)
private dEmisAte  := dDatabase
private cNotaDe   := space(TamSX3("D2_DOC")[1])
private cNotaAte  := replicate('Z',TamSX3("D2_DOC")[1])
private cEstDe    := space(TamSX3("A1_EST")[1])
private cEstAte   := replicate('Z',TamSX3("A1_EST")[1])
private cCliDe    := space(TamSX3("A1_COD")[1])
private cCliAte   := replicate('Z',TamSX3("A1_COD")[1])
private cLojaDe   := space(TamSX3("A1_LOJA")[1])
private cLojaAte  := replicate('Z',TamSX3("A1_LOJA")[1])
private cGrupoDe  := space(TamSX3("B1_GRUPO")[1])
private cGrupoAte := replicate('Z',TamSX3("B1_GRUPO")[1])
private cVendDe   := space(TamSX3("A3_COD")[1])
private cVendAte  := replicate('Z',TamSX3("A3_COD")[1])
private cFilDe    := space(TamSX3("D2_FILIAL")[1])
private cFilAte   := replicate('Z',TamSX3("D2_FILIAL")[1])
private cCFOP     := space(99)
private oBtn      := nil

// array para o listbox
public oLbxCampo := nil
public aLbxCampo := {}

Static oDlg := nil

//Reset campos parâmetros
ResetArray()

Define MSDialog oDlg Title "Análise de Vendas" From 000,000 To 350,400 Pixel
nLinha := 0
@ nLinha, 002 to 255, 200 Label "Parâmetros do Relatório" Pixel

nLinha += 8
@ nLinha+1, 005 SAY "Tipo" OF oDlg PIXEL
@ nLinha, 050 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS {"1=Analitico","2=Sintético"} valid ValAgrup() SIZE 072, 010 OF oDlg PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Data de" OF oDlg PIXEL
@ nLinha, 050 MSGET dEmisDe SIZE 060, 009 OF oDlg PIXEL
@ nLinha+1, 115 SAY "até" OF oDlg PIXEL
@ nLinha, 130 MSGET dEmisAte SIZE 060, 009 OF oDlg PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Nota de" OF oDlg PIXEL
@ nLinha, 050 MSGET cNotaDe SIZE 060, 009 OF oDlg F3 "SF2" PIXEL
@ nLinha+1, 115 SAY "até" OF oDlg PIXEL
@ nLinha, 130 MSGET cNotaAte SIZE 060, 009 OF oDlg F3 "SF2" PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Grupo de" OF oDlg PIXEL
@ nLinha, 050 MSGET cGrupoDe SIZE 060, 009 OF oDlg F3 "SBM" PIXEL
@ nLinha+1, 115 SAY "até" OF oDlg PIXEL
@ nLinha, 130 MSGET cGrupoAte SIZE 060, 009 OF oDlg F3 "SBM" PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Estado de" OF oDlg PIXEL
@ nLinha, 050 MSGET cEstDe SIZE 060, 009 OF oDlg F3 "12" PIXEL
@ nLinha+1, 115 SAY "até" OF oDlg PIXEL
@ nLinha, 130 MSGET cEstAte SIZE 060, 009 OF oDlg F3 "12" PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Cliente de" OF oDlg PIXEL
@ nLinha, 050 MSGET cCliDe SIZE 060, 009 OF oDlg F3 "SA1_PV" PIXEL
@ nLinha+1, 115 SAY "até" OF oDlg PIXEL
@ nLinha, 130 MSGET cCliAte SIZE 060, 009 OF oDlg F3 "SA1_PV" PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Loja de" OF oDlg PIXEL
@ nLinha, 050 MSGET cLojaDe SIZE 060, 009 OF oDlg PIXEL
@ nLinha+1, 115 SAY "até" OF oDlg PIXEL
@ nLinha, 130 MSGET cLojaAte SIZE 060, 009 OF oDlg PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Vendedor de" OF oDlg PIXEL
@ nLinha, 050 MSGET cVendDe SIZE 060, 009 OF oDlg F3 "SA3" PIXEL
@ nLinha+1, 115 SAY "até" OF oDlg PIXEL
@ nLinha, 130 MSGET cVendAte SIZE 060, 009 OF oDlg F3 "SA3" PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Filial de" OF oDlg PIXEL
@ nLinha, 050 MSGET cFilDe SIZE 060, 009 OF oDlg F3 "SM0" PIXEL
@ nLinha+1, 115 SAY "até" OF oDlg PIXEL
@ nLinha, 130 MSGET cFilAte SIZE 060, 009 OF oDlg F3 "SM0" PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "CFOP" OF oDlg PIXEL
@ nLinha, 050 MSGET cCFOP SIZE 110, 009 OF oDlg PIXEL

nLinha += 12
@ nLinha+1, 005 SAY "Agrupar por" OF oDlg PIXEL
@ nLinha, 050 MSCOMBOBOX oComboBo2 VAR cComboBo2 ITEMS {"1=Emissão","2=Grupo","3=Produto","4=Região","5=Estado","6=Município","7=Vendedor","8=Cliente"} valid ValAgrup() size 072,010 of oDlg pixel

nLinha += 24
@ nLinha,005 BmpButton type 1 action ImpRel()
@ nLinha,040 BmpButton type 2 action oDlg:End()
@ nLinha,075 BUTTON "Selecionar colunas..." SIZE 060,011 ACTION Tela() Object oBtn

Activate MSDialog oDlg Centered

return


//------------------------------------------------------------------------------
static function ValAgrup

ResetArray()
if cComboBo1 == "2"
	do case
		case cComboBo2 == "1" // 1=Emissão
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "EMISSAO"})][1] :=  "S"
		case cComboBo2 == "2" // 2=Família
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "GRUPO"})][1] :=  "S"
		case cComboBo2 == "3" // 3=Produto
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "COD_PRODUTO"})][1] :=  "S"
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "PRODUTO"})][1] :=  "S"
		case cComboBo2 == "4" // 4=Região
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "REG"})][1] :=  "S"
		case cComboBo2 == "5" // 5=Estado
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "ESTADO"})][1] :=  "S"
		case cComboBo2 == "6" // 6=Municipio
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "MUNIC"})][1] :=  "S"
		case cComboBo2 == "7" // 10=Representante
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "COD_VEND"})][1] :=  "S"
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "VENDEDOR"})][1] :=  "S"
		case cComboBo2 == "8" // 11=Cliente
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "COD_CLIENTE"})][1] :=  "S"
			aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "LOJA"})][1] :=  "S"
	endcase
endif

return(.T.)


//------------------------------------------------------------------------------
Static Function ImpRel

local oReport := nil

MV_PAR01 := oComboBo1:nAt
nTipoRel := oComboBo1:nAt
MV_PAR02 := dEmisDe
MV_PAR03 := dEmisAte
MV_PAR04 := cNotaDe
MV_PAR05 := cNotaAte
MV_PAR06 := cEstDe
MV_PAR07 := cEstAte
MV_PAR08 := cCliDe
MV_PAR09 := cCliAte
MV_PAR10 := cLojaDe
MV_PAR11 := cLojaAte
MV_PAR12 := cGrupoDe
MV_PAR13 := cGrupoAte
MV_PAR14 := cVendDe
MV_PAR15 := cVendAte
MV_PAR16 := cFilDe
MV_PAR17 := cFilAte
MV_PAR18 := cCFOP

oDlg:end()

oReport := ReportDef()
oReport:PrintDialog()

return


//------------------------------------------------------------------------------
static function ReportDef

local oReport   := nil
local oSection1 := nil
local oBreak    := nil
local nI        := 0

oReport   := TReport():New("RFAT010","Análise de Vendas",,{|oReport| PrintReport(oReport)},"Análise de Vendas",)
oSection1 := TRSection():New(oReport,"NFs","TRB01",nil,.F.,.F.,,,,,,.T.) // 12 parametro (.t.) serve para fazer a quebra automatica das colunas.   

TRCell():New(oSection1,"COD_FIL"		,"TRB01","Filial"	     	, nil              	  , 6  )
TRCell():New(oSection1,"DESC_FIL"		,"TRB01","Desc.Filial"     	, nil              	  , 15 )
TRCell():New(oSection1,"EMISSAO"		,"TRB01","Data Emissão"		, nil              	  , 10 )
TRCell():New(oSection1,"NF"				,"TRB01","Número Doc"		, nil                 , 9  )
TRCell():New(oSection1,"TIPONF"			,"TRB01","Tipo Doc"			, nil                 , 1  )
TRCell():New(oSection1,"GRPROD"			,"TRB01","Grupo Prod."		, nil              	  , 4  )
TRCell():New(oSection1,"GRUPOPROD"		,"TRB01","Desc.Grupo"		, nil              	  , 30 )
TRCell():New(oSection1,"COD_PRODUTO"	,"TRB01","Cod.Produto"	 	, nil              	  , 30 )
TRCell():New(oSection1,"PRODUTO"		,"TRB01","Produto"     		, nil                 , 50 )
TRCell():New(oSection1,"CFOP"			,"TRB01","CFOP"     	    , nil                 , 4  )
TRCell():New(oSection1,"TIPO"			,"TRB01","Tipo Prod."		, nil                 , 4  )
TRCell():New(oSection1,"QUANTI"			,"TRB01","Quantidade"      	, "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"REG"			,"TRB01","Região"          	, nil                 , 15 )
TRCell():New(oSection1,"COD_MUN"		,"TRB01","Cod.Munic"       	, nil                 , 5  )
TRCell():New(oSection1,"MUNIC"			,"TRB01","Municipio"       	, nil                 , 15 )
TRCell():New(oSection1,"ESTADO"			,"TRB01","Estado"          	, nil                 , 2  )
TRCell():New(oSection1,"COD_CLIENTE"	,"TRB01","Cod.Cliente"     	, nil              	  , 9  )
TRCell():New(oSection1,"LOJA"			,"TRB01","Loja"            	, nil              	  , 4  )
TRCell():New(oSection1,"HISTORICO"		,"TRB01","Razão Social"     , nil                 , 40 )
TRCell():New(oSection1,"COD_VEND"		,"TRB01","Cod.Vendedor"    	, nil              	  , 6  )
TRCell():New(oSection1,"VENDEDOR"		,"TRB01","Vendedor"        	, nil              	  , 60 )
TRCell():New(oSection1,"COD_OPERADOR"	,"TRB01","Cod.Atendente"   	, nil              	  , 6  )
TRCell():New(oSection1,"OPERADOR"		,"TRB01","Atendente"       	, nil              	  , 60 )   
TRCell():New(oSection1,"NUAVEND1"		,"TRB01","Vend.TMK 1"       , nil              	  , 60 ) 
TRCell():New(oSection1,"NUAVEND2"		,"TRB01","Vend TMK 2"       , nil              	  , 60 ) 
TRCell():New(oSection1,"TMK"		    ,"TRB01","Marketing"       	, nil              	  , 60 ) 
TRCell():New(oSection1,"NCM"			,"TRB01","Pos.IPI/NCM"		, nil 				  , 8  )
TRCell():New(oSection1,"TIPOCLI"		,"TRB01","Tipo Cliente"		, nil                 , 20 )
TRCell():New(oSection1,"IE"				,"TRB01","Ins.Estadual"     , nil                 , 18 )
TRCell():New(oSection1,"SUFRAMA"		,"TRB01","SUFRAMA"          , nil                 , 12 )
TRCell():New(oSection1,"GRPTRIB"		,"TRB01","Grupo Tributo"    , nil                 , 3  )
TRCell():New(oSection1,"TPESSOA"		,"TRB01","Tipo Pessoa"      , nil                 , 20 )
TRCell():New(oSection1,"CNAE"			,"TRB01","Código CNAE"      , nil                 , 9  )
TRCell():New(oSection1,"SIMPLES"		,"TRB01","Opt.Simp.Nac"     , nil                 , 3  )
TRCell():New(oSection1,"MT"				,"TRB01","Rg.Simp.MT"  		, nil                 , 3  )
TRCell():New(oSection1,"VENDA"			,"TRB01","Venda"            , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"PIPI"			,"TRB01","% IPI"            , "@E 999.99"         , 6  )
TRCell():New(oSection1,"IPI"			,"TRB01","IPI"              , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"ST"				,"TRB01","ST"               , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"RECEITA_BRUTA"	,"TRB01","Receita Bruta"    , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"PICMS"			,"TRB01","% ICMS"           , "@E 999.99"         , 6  )
TRCell():New(oSection1,"ICMS"			,"TRB01","ICMS"             , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"PIS"			,"TRB01","PIS"              , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"COFINS"         ,"TRB01","Cofins"           , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"DESCONTO"		,"TRB01","Desconto"         , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"RECEITA_LIQUIDA","TRB01","Receira Líquida"  , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"CUSTO"			,"TRB01","Custo"            , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"MARGEM_BRUTA"	,"TRB01","Margem Bruta"     , "@E 999,999,999.99" , 13 )
TRCell():New(oSection1,"P_CUSTO"		,"TRB01","% Custo"          , "@E 999.99"         , 5  )
TRCell():New(oSection1,"P_LUCRO"		,"TRB01","% Lucro"          , "@E 999.99"         , 5  )
TRCell():New(oSection1,"NUMCTE"			,"TRB01","Número CTe"		, nil                 , 9  )
TRCell():New(oSection1,"SERCTE"			,"TRB01","Série CTe"		, nil                 , 3  )
TRCell():New(oSection1,"VALFRETE"		,"TRB01","Frete"            , "@E 999,999,999.99" , 13 )

oSection1:Cell("TIPOCLI"):SetCBox('F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao')
oSection1:Cell("TPESSOA"):SetCBox('CI=Comercio/Industria;PF=Pessoa Fisica;OS=Prestacäo de Servico;EP=Empresa Publica')
oSection1:Cell("SIMPLES"):SetCBox('1=Sim;2=Nao')
oSection1:Cell("MT"):SetCBox('1=Sim;2=Nao')

do case
	case cComboBo2 == "1"	// 1=Emissão
		oBreak := TRBreak():New(oSection1,oSection1:Cell("EMISSAO"),"Sub Total")
	case cComboBo2 == "2" // 2=Grupo
		oBreak := TRBreak():New(oSection1,oSection1:Cell("GRUPO"),"Sub Total")
	case cComboBo2 == "3" // 3=Produto
		oBreak := TRBreak():New(oSection1,oSection1:Cell("COD_PRODUTO"),"Sub Total")
	case cComboBo2 == "4" // 4=Região
		oBreak := TRBreak():New(oSection1,oSection1:Cell("REG"),"Sub Total")
	case cComboBo2 == "5" // 5=Estado
		oBreak := TRBreak():New(oSection1,oSection1:Cell("ESTADO"),"Sub Total")
	case cComboBo2 == "6" // 6=Município
		oBreak := TRBreak():New(oSection1,oSection1:Cell("MUNIC"),"Sub Total")
	case cComboBo2 == "7" // 7=Vendedor
		oBreak := TRBreak():New(oSection1,oSection1:Cell("VENDEDOR"),"Sub Total")
	case cComboBo2 == "8" // 8=Cliente
		oBreak := TRBreak():New(oSection1,oSection1:Cell("COD_CLIENTE"),"Sub Total")
endcase

if nTipoRel = 1
	TRFunction():New(oSection1:Cell("QUANTI"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

// Desabilita as células
for nI := 1 to len(aLbxCampo)
	if aLbxCampo[nI,1] == "N"
		oSection1:Cell(aLbxCampo[nI,3]):Disable()
	endif
next

if oSection1:Cell("VENDA"):Enabled()
	TRFunction():New(oSection1:Cell("VENDA"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("IPI"):Enabled()
	TRFunction():New(oSection1:Cell("IPI"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("ST"):Enabled()
	TRFunction():New(oSection1:Cell("ST"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("RECEITA_BRUTA"):Enabled()
	TRFunction():New(oSection1:Cell("RECEITA_BRUTA"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("ICMS"):Enabled()
	TRFunction():New(oSection1:Cell("ICMS"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("PIS"):Enabled()
	TRFunction():New(oSection1:Cell("PIS"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("COFINS"):Enabled()
	TRFunction():New(oSection1:Cell("COFINS"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("RECEITA_LIQUIDA"):Enabled()
	TRFunction():New(oSection1:Cell("RECEITA_LIQUIDA"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("CUSTO"):Enabled()
	TRFunction():New(oSection1:Cell("CUSTO"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("MARGEM_BRUTA"):Enabled()
	TRFunction():New(oSection1:Cell("MARGEM_BRUTA"),NIL,"SUM",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("P_CUSTO"):Enabled()
	TRFunction():New(oSection1:Cell("P_CUSTO"),NIL,"AVERAGE",oBreak,,,,.F.,.T.)
endif

if oSection1:Cell("P_LUCRO"):Enabled()
	TRFunction():New(oSection1:Cell("P_LUCRO"),NIL,"AVERAGE",oBreak,,,,.F.,.T.)
endif

oReport:SetTotalInLine(.F.)

return oReport


//------------------------------------------------------------------------------
static function PrintReport(oReport)

local oSection1 := oReport:Section(1)
local cAux1     := ""
local cOrder    := ""
local cGroup    := ""
local cQuery    := ""

If cComboBo1 == "1"
	do case
		case cComboBo2 == "1" // 1=Emissão
			cOrder += " D2_EMISSAO,D2_DOC "
		case cComboBo2 == "2" // 2=Grupo
			cOrder += " B1_GRUPO,D2_COD,D2_EMISSAO,D2_DOC "
		case cComboBo2 == "3" // 3=Produto
			cOrder += " D2_COD,D2_EMISSAO,D2_DOC "
		case cComboBo2 == "4" // 4=Região
			cOrder += " REGIAO,D2_EST,A1_COD_MUN,D2_EMISSAO,D2_DOC "
		case cComboBo2 == "5" // 5=Estado
			cOrder += " D2_EST,A1_COD_MUN,D2_EMISSAO,D2_DOC "
		case cComboBo2 == "6" // 6=Municipio
			cOrder += " A1_COD_MUN,D2_EST,D2_EMISSAO,D2_DOC "
		case cComboBo2 == "7" // 7=Vendedor
			cOrder += " A1_VEND,D2_EMISSAO,D2_DOC "
		case cComboBo2 == "8" // 8=Cliente
			cOrder += " A1_COD,A1_LOJA,D2_EMISSAO,D2_DOC "
		otherwise
			cOrder += " 1,2,3 "
	endcase
else
	do case
		case cComboBo2 == "1" // 1=Emissão
			cOrder += " D2_EMISSAO "
		case cComboBo2 == "2" // 2=Grupo
			cOrder += " B1_GRUPO "
		case cComboBo2 == "3" // 3=Produto
			cOrder += " D2_COD "
		case cComboBo2 == "4" // 4=Região
			cOrder += " REGIAO "
		case cComboBo2 == "5" // 5=Estado
			cOrder += " D2_EST "
		case cComboBo2 == "6" // 6=Municipio
			cOrder += " A1_COD_MUN "
		case cComboBo2 == "7" // 7=Representante
			cOrder += " A1_VEND "
		case cComboBo2 == "8" // 8=Cliente
			cOrder += " A1_COD,A1_LOJA "
		otherwise
			cOrder += " 1,2,3 "
	endcase
endif

if cComboBo1 == "1" // Analítico
	cOrder += ",D2_ITEM DESC "
endif

do case
	case cComboBo2 == "1" // 1=Emissão
		cGroup := "GROUP BY  D2_EMISSAO, "
	case cComboBo2 == "2" // 2=Grupo
		cGroup := "GROUP BY  B1_GRUPO, "
	case cComboBo2 == "3" // 3=Produto
		cGroup := "GROUP BY  D2_COD, "
	case cComboBo2 == "4" // 4=Região
		cGroup := "GROUP BY  X5_REGIAO, "
	case cComboBo2 == "5" // 5=Estado
		cGroup := "GROUP BY  D2_EST, "
	case cComboBo2 == "6" // 6=Municipio
		cGroup := "GROUP BY  A1_COD_MUN, "
	case cComboBo2 == "7" // 10=Vendedor
		cGroup := "GROUP BY  A1_VEND, "
	case cComboBo2 == "8" // 8=Cliente
		cGroup := "GROUP BY  A1_COD,A1_LOJA, "
endcase

// Se foi escolhido a opção de Planilha, retira a quebra de linha para não aparecer linhas em branco
if oReport:nDevice == 4
	oSection1:lLineBreak := .F.
endif

if !empty(MV_PAR18) // filtra as CPFOs
	cAux1 += "AND D2_CF IN " + FormatIn(MV_PAR18, ";") // transforma em formato IN de SQL, trocando o | por ','
endif

if Select("TRB01") > 0
	dbSelectArea("TRB01")
	TRB01->(dbCloseArea())
endif

If nTipoRel == 1  //ANALITICO

	cQuery := " SELECT SD2.D2_EMISSAO [EMISSAO],
	cQuery += "        SD2.D2_FILIAL [COD_FIL],
	cQuery += "        CASE WHEN SD2.D2_FILIAL = '010101' THEN 'SENTAX - CURITIBA' 
	cQuery += "             WHEN SD2.D2_FILIAL = '020201' THEN 'GIBRALTAR - CURITIBA'
	cQuery += "             WHEN SD2.D2_FILIAL = '020202' THEN 'GIBRALTAR - FOZ DO IGUACU'
	cQuery += "             WHEN SD2.D2_FILIAL = '020203' THEN 'GIBRALTAR - JOINVILLE'
	cQuery += "             WHEN SD2.D2_FILIAL = '020204' THEN 'GIBRALTAR - MARILIA'
	cQuery += "             WHEN SD2.D2_FILIAL = '020205' THEN 'GIBRALTAR - SAO JOSE DOS PINHAIS'
	cQuery += "             WHEN SD2.D2_FILIAL = '030301' THEN 'ARVOREDE - JOINVILLE'
	cQuery += "             WHEN SD2.D2_FILIAL = '040401' THEN 'RADICAL CONSULTORIA DE MARKETING'
	cQuery += "        END [DESC_FIL],	
	cQuery += "        SD2.D2_DOC [NF],
	cQuery += "        SF2.F2_TIPO [TIPONF],
	cQuery += "        SB1.B1_GRUPO [GRPROD],
	cQuery += "        SBM.BM_DESC [GRUPOPROD],
	cQuery += "        SD2.D2_COD [COD_PRODUTO],
	cQuery += "        SB1.B1_DESC [PRODUTO],
	cQuery += "        SD2.D2_QUANT [QUANTI],
	cQuery += "        SD2.D2_CF [CFOP],
	cQuery += "        SB1.B1_TIPO [TIPO],
	cQuery += "        REGIAO.X5_DESCRI [REGIAO],
	cQuery += "        SA1.A1_COD_MUN [COD_MUN],
	cQuery += "        SA1.A1_MUN [MUNIC],
	cQuery += "        SD2.D2_EST [ESTADO],
	cQuery += "        SA1.A1_COD [COD_CLIENTE],
	cQuery += "        SA1.A1_LOJA [LOJA],
	cQuery += "        SA1.A1_NOME [HISTORICO],
	cQuery += "        SA1.A1_VEND [COD_VEND],
	cQuery += "        A3VEN.A3_NREDUZ [VENDEDOR],
	cQuery += "        SUA.UA_OPERADO [COD_OPERADOR],
	cQuery += "        SU7.U7_NOME [OPERADOR],
	cQuery += "        SUA.UA_VEND [VEND_UA1],
	cQuery += "        VEND1UA.A3_NREDUZ [NUAVEND1], 
	cQuery += "        SUA.UA_VEND2 [VEND_UA2],
	cQuery += "        VEND2UA.A3_NREDUZ [NUAVEND2],  
	cQuery += "        CASE WHEN SUA.UA_TMK ='1' THEN 'RECEPTIVO' 
	cQuery += "        WHEN SUA.UA_TMK ='2' THEN 'ATIVO' 
	cQuery += "        WHEN SUA.UA_TMK ='3' THEN 'ACOMPANHAMENTO' 
	cQuery += "        WHEN SUA.UA_TMK ='4' THEN 'REPRESENTANTE' 
	cQuery += "        WHEN SUA.UA_TMK ='5' THEN 'RETORNO ATIVO' 
	cQuery += "        WHEN SUA.UA_TMK ='6' THEN 'COTAÇÃO' 
	cQuery += "        WHEN SUA.UA_TMK ='7' THEN 'ORDEM DE SERVIÇO' 
	cQuery += "        WHEN SUA.UA_TMK ='8' THEN 'E-MAIL' 
	cQuery += "        WHEN SUA.UA_TMK ='9' THEN 'WHATTS-UP' 
	cQuery += "        WHEN SUA.UA_TMK ='S' THEN 'SITE' 
	cQuery += "        END [TMK], 
	cQuery += "        SD2.D2_VALBRUT [VENDA],
	cQuery += "        SD2.D2_IPI [PIPI],
	cQuery += "        SD2.D2_VALIPI [IPI],
	cQuery += "        CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN (SD2.D2_ICMSRET) ELSE 0 END [ST],
	cQuery += "        ROUND(((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN (SD2.D2_ICMSRET) ELSE 0 END))),2) [RECEITA_BRUTA],
	cQuery += "        SD2.D2_PICM [PICMS],
	cQuery += "        SD2.D2_VALICM [ICMS],
	cQuery += "        SD2.D2_VALIMP6 [PIS],
	cQuery += "        SD2.D2_VALIMP5 [COFINS],
	cQuery += "        SD2.D2_DESCZFC + SD2.D2_DESCZFP [DESCONTO],
	cQuery += "        (SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN SD2.D2_ICMSRET ELSE 0 END) - (CASE WHEN SD2.D2_CF NOT IN ('6110') THEN (SD2.D2_DESCZFC - SD2.D2_DESCZFP) ELSE 0 END) - SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5) [RECEITA_LIQUIDA],
	cQuery += "        SD2.D2_CUSTO1 [CUSTO],
	cQuery += "        SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('6110') THEN  SD2.D2_DESCZFC - SD2.D2_DESCZFP ELSE 0 END) - SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 - SD2.D2_CUSTO1 - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN SD2.D2_ICMSRET ELSE 0 END) [MARGEM_BRUTA],
	cQuery += "        SD2.D2_CUSTO1 / (SD2.D2_VALBRUT - D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') AND SD2.D2_ICMSRET < SD2.D2_VALBRUT - SD2.D2_VALIPI THEN SD2.D2_ICMSRET WHEN SD2.D2_VALBRUT - SD2.D2_VALIPI = SD2.D2_ICMSRET THEN 1 ELSE 0 END)) * 100 [P_CUSTO],
	cQuery += "        ((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('6110') THEN (SD2.D2_DESCZFC - SD2.D2_DESCZFP) ELSE 0 END) - SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 - SD2.D2_CUSTO1 - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN SD2.D2_ICMSRET ELSE 0 END)) / (SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') AND SD2.D2_ICMSRET < (SD2.D2_VALBRUT - SD2.D2_VALIPI) THEN SD2.D2_ICMSRET WHEN (SD2.D2_VALBRUT - SD2.D2_VALIPI) = SD2.D2_ICMSRET THEN 1 ELSE 0 END)) * 100) [P_LUCRO],
	cQuery += "        SB1.B1_POSIPI [NCM],
	cQuery += "        SA1.A1_TIPO [TIPOCLI],
	cQuery += "        SA1.A1_INSCR [IE],
	cQuery += "        SA1.A1_SUFRAMA [SUFRAMA],
	cQuery += "        SA1.A1_GRPTRIB [GRPTRIB],
	cQuery += "        SA1.A1_TPESSOA [TPESSOA],
	cQuery += "        SA1.A1_CNAE [CNAE],
	cQuery += "        SA1.A1_SIMPNAC [SIMPLES],
	cQuery += "        SA1.A1_REGESIM [MT],
	cQuery += "        Z7Z.Z7Z_DOC [NUMCTE],
	cQuery += "        Z7Z.Z7Z_SERIE [SERCTE],
	cQuery += "        (SD2.D2_VALBRUT /    
	cQuery += " (SELECT  SUM(SF2.F2_VALBRUT) 
	cQuery += "     FROM "+ RetSqlName("Z7Z") +" Z7Z  
    cQuery += "     INNER JOIN "+ RetSqlName("SF2") +" SF2      
    cQuery += "     ON SF2.F2_DOC = Z7Z.Z7Z_NOTA AND SF2.F2_SERIE = Z7Z.Z7Z_SERINF  AND SF2.D_E_L_E_T_ != '*' AND SF2.F2_DUPL <> '' WHERE Z7Z_DOC= 
    cQuery += "      ( SELECT TOP 1 Z7Z_DOC 
    cQuery += "        FROM "+ RetSqlName("Z7Z") +" Z7Z 
    cQuery += "        WHERE Z7Z_NOTA = SD2.D2_DOC AND Z7Z.D_E_L_E_T_	!= '*') 
    cQuery += "   AND Z7Z.D_E_L_E_T_	!= '*'))  *
	cQuery += " (SELECT SUM(Z6Z.Z6Z_VALTOT) FROM  "+ RetSqlName("Z6Z") +" Z6Z INNER JOIN "+ RetSqlName("Z7Z") +" Z7Z ON Z7Z.Z7Z_FILIAL = Z6Z.Z6Z_FILIAL AND Z7Z.Z7Z_SERIE = Z6Z.Z6Z_SERIE AND Z7Z.Z7Z_DOC = Z6Z.Z6Z_DOC AND Z7Z.Z7Z_FILIAL = SD2.D2_FILIAL AND Z7Z.Z7Z_SERINF = SD2.D2_SERIE AND Z7Z.Z7Z_NOTA = SD2.D2_DOC AND Z7Z.D_E_L_E_T_	!= '*' WHERE Z6Z.D_E_L_E_T_ != '*' AND Z6Z.Z6Z_FILIAL = SD2.D2_FILIAL ) [VALFRETE]
	cQuery += " FROM "+ RetSqlName("SD2") +" SD2
	cQuery += " INNER JOIN "+ RetSqlName("SF2") +" SF2
	cQuery += "  ON SF2.F2_FILIAL = SD2.D2_FILIAL
	cQuery += " AND SF2.F2_DOC = SD2.D2_DOC
	cQuery += " AND SF2.F2_SERIE = SD2.D2_SERIE
	cQuery += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
	cQuery += " AND SF2.F2_LOJA = SD2.D2_LOJA
	cQuery += " AND SF2.F2_DUPL != ' '
	cQuery += " AND SF2.F2_TIPO IN ('N','D')
	cQuery += " AND SF2.D_E_L_E_T_ != '*'
	cQuery += " LEFT JOIN "+ RetSqlName("Z7Z") +" Z7Z
	cQuery += "  ON Z7Z.Z7Z_FILIAL = SD2.D2_FILIAL
	cQuery += " AND Z7Z.Z7Z_SERINF = SD2.D2_SERIE
	cQuery += " AND Z7Z.Z7Z_NOTA = SD2.D2_DOC
	cQuery += " AND Z7Z.D_E_L_E_T_ != '*'
	cQuery += " LEFT JOIN "+ RetSqlName("SUA") +" SUA
	cQuery += "  ON SUA.UA_FILIAL = SD2.D2_FILIAL
	cQuery += " AND SUA.UA_SERIE = SD2.D2_SERIE
	cQuery += " AND SUA.UA_DOC = SD2.D2_DOC
	cQuery += " AND SUA.D_E_L_E_T_ != '*'
	cQuery += " LEFT JOIN "+ RetSqlName("SU7") +" SU7
	cQuery += "  ON SU7.U7_COD = SUA.UA_OPERADO
	cQuery += " AND SU7.D_E_L_E_T_ != '*'	
	cQuery += " INNER JOIN "+ RetSqlName("SA1") +" SA1
	cQuery += "  ON SA1.A1_COD = SD2.D2_CLIENTE
	cQuery += " AND SA1.A1_LOJA = SD2.D2_LOJA
	cQuery += " AND SA1.A1_VEND BETWEEN '"+ MV_PAR14 +"' AND '"+ MV_PAR15 +"'
	cQuery += " AND SA1.D_E_L_E_T_ != '*'
	cQuery += " INNER JOIN "+ RetSqlName("SB1") +" SB1
	cQuery += "  ON SB1.B1_COD = SD2.D2_COD
	cQuery += " AND SB1.B1_GRUPO BETWEEN '"+ MV_PAR12 +"' AND '"+ MV_PAR13 +"'
	cQuery += " AND SB1.D_E_L_E_T_ != '*'
	cQuery += " INNER JOIN "+ RetSqlName("SBM") +" SBM
	cQuery += "  ON SB1.B1_GRUPO = SBM.BM_GRUPO
	cQuery += " AND SBM.D_E_L_E_T_ != '*'
	cQuery += " LEFT JOIN "+ RetSqlName("SA3") +" A3VEN
	cQuery += "  ON A3VEN.A3_COD = SA1.A1_VEND
	cQuery += " AND A3VEN.D_E_L_E_T_ != '*'  	
	cQuery += " LEFT JOIN "+ RetSqlName("SA3") +" VEND1UA
	cQuery += "  ON VEND1UA.A3_COD = SUA.UA_VEND
	cQuery += " AND VEND1UA.D_E_L_E_T_ != '*'  	
	cQuery += " LEFT JOIN "+ RetSqlName("SA3") +" VEND2UA
	cQuery += "  ON VEND2UA.A3_COD = SUA.UA_VEND2
	cQuery += " AND VEND2UA.D_E_L_E_T_ != '*'	
	cQuery += " LEFT JOIN "+ RetSqlName("SX5") +" REGIAO
	cQuery += "  ON REGIAO.X5_TABELA = 'A2'
	cQuery += " AND REGIAO.X5_CHAVE = A1_REGIAO
	cQuery += " AND REGIAO.D_E_L_E_T_ != '*'
	cQuery += " WHERE SD2.D_E_L_E_T_ != '*'
	cQuery += " AND SD2.D2_FILIAL BETWEEN '"+ MV_PAR16 +"' AND '"+ MV_PAR17 +"'
	cQuery += " AND SD2.D2_EMISSAO BETWEEN '"+ dtos(MV_PAR02) +"' AND '"+ dtos(MV_PAR03) +"'
	cQuery += " AND SD2.D2_DOC BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"'
	cQuery += " AND SD2.D2_CLIENTE BETWEEN '"+ MV_PAR08 +"' AND '"+ MV_PAR09 +"'
	cQuery += " AND SD2.D2_LOJA BETWEEN '"+ MV_PAR10 +"' AND '"+ MV_PAR11 +"'
	cQuery += " AND SD2.D2_EST BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"'
	cQuery += cAux1
	cQuery += " ORDER BY "+ cOrder

Else  // SINTETICO

	cQuery := " SELECT
	
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "EMISSAO"})][1] ==  "S"
		cQuery += " (SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4)) [EMISSAO],
		if !("D2_EMISSAO" $ cGroup)
			cGroup += " D2_EMISSAO,"
		endif
	endif
	
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "COD_FIL"})][1] ==  "S"
		cQuery += " SD2.D2_FILIAL [COD_FIL],
		if !("D2_FILIAL" $ cGroup)
			cGroup += " D2_FILIAL,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "NF"})][1] ==  "S"
		cQuery += " SD2.D2_DOC [NF],
		if !("D2_DOC" $ cGroup)
			cGroup += " D2_DOC,"
		endif
	endif
		
	if aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "GRPROD"})][1] ==  "S"
		cQuery += "SB1.B1_GRUPO [GRPROD],
		if !("B1_GRUPO" $ cGroup)
			cGroup += " B1_GRUPO,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "CFOP"})][1] ==  "S"
		cQuery += "SD2.D2_CF [CFOP],
		if !("D2_DOC" $ cGroup)
			cGroup += " D2_DOC,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "REG"})][1] ==  "S"
		cQuery += " REGIAO.X5_DESCRI [REGIAO],
		if !("X5_DESCRI" $ cGroup)
			cGroup += " X5_DESCRI,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "COD_MUN"})][1] ==  "S"
		cQuery += " SA1.A1_COD_MUN [COD_MUN],
		if !("A1_COD_MUN" $ cGroup)
			cGroup += " A1_COD_MUN,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "MUNIC"})][1] ==  "S"
		cQuery += " SA1.A1_MUN [MUNIC],
		if !("A1_MUN" $ cGroup)
			cGroup += " A1_MUN,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "ESTADO"})][1] ==  "S"
		cQuery += " SD2.D2_EST [ESTADO],
		if !("D2_EST" $ cGroup)
			cGroup += " D2_EST,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "COD_PRODUTO"})][1] ==  "S"
		cQuery += " SD2.D2_COD [COD_PRODUTO],
		if !("D2_COD" $ cGroup)
			cGroup += " D2_COD,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "PRODUTO"})][1] ==  "S"
		cQuery += " SB1.B1_DESC [PRODUTO],
		if !(" B1_DESC" $ cGroup)
			cGroup += " B1_DESC,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "QUANTI"})][1] ==  "S"
		cQuery += " SUM(SD2.D2_QUANT) [QUANTI],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "TIPO"})][1] ==  "S"
		cQuery += " SB1.B1_TIPO [TIPO],
		if !("B1_TIPO" $ cGroup)
			cGroup += " B1_TIPO,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "COD_CLIENTE"})][1] ==  "S"
		cQuery += " SA1.A1_COD [COD_CLIENTE],
		if !("A1_COD" $ cGroup)
			cGroup += " A1_COD,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "LOJA"})][1] ==  "S"
		cQuery += " SA1.A1_LOJA [LOJA],
		if !("A1_LOJA" $ cGroup)
			cGroup += " A1_LOJA,"
		endif
	endif
				
	if aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "HISTORICO"})][1] ==  "S"
		cQuery += " SA1.A1_NOME [HISTORICO],
		if !("A1_NOME" $ cGroup)
			cGroup += " A1_NOME,"
		endif
	endif
		
	if aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "COD_VEND"})][1] ==  "S"
		cQuery += " SA1.A1_VEND [COD_VEND],
		If !("A1_VEND" $ cGroup)
			cGroup += " A1_VEND,"
		endif
	endif
		
	if aLbxCampo[aScan(aLbxCampo, {|x| alltrim(x[3]) == "VENDEDOR"})][1] ==  "S"
		cQuery += " A3VEN.A3_NREDUZ [VENDEDOR],
		if !("A3VEN.A3_NREDUZ" $ cGroup)
			cGroup += " A3VEN.A3_NREDUZ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "VENDA"})][1] ==  "S"
		cQuery += " SUM(SD2.D2_VALBRUT) [VENDA],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "IPI"})][1] ==  "S"
		cQuery += " SUM(SD2.D2_VALIPI) [IPI],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "ST"})][1] ==  "S"
		cQuery += " SUM((CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN (SD2.D2_ICMSRET) ELSE 0 END))[ST],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "RECEITA_BRUTA"})][1] ==  "S"
		cQuery += " SUM((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN SD2.D2_ICMSRET ELSE 0 END))) [RECEITA_BRUTA],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "ICMS"})][1] ==  "S"
		cQuery += " SUM(SD2.D2_VALICM) [ICMS],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "PIS"})][1] ==  "S"
		cQuery += " SUM(SD2.D2_VALIMP6) [PIS],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "COFINS"})][1] ==  "S"
		cQuery += " SUM(SD2.D2_VALIMP5) [COFINS],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "DESCONTO"})][1] ==  "S"
		cQuery += " SUM((SD2.D2_DESCZFC + SD2.D2_DESCZFP)) [DESCONTO],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "RECEITA_LIQUIDA"})][1] ==  "S"
		cQuery += " SUM((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN SD2.D2_ICMSRET ELSE 0 END) - (CASE WHEN SD2.D2_CF NOT IN ('6110') THEN SD2.D2_DESCZFC - SD2.D2_DESCZFP ELSE 0 END) - SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5)) [RECEITA_LIQUIDA],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "CUSTO"})][1] ==  "S"
		cQuery += " SUM(SD2.D2_CUSTO1) [CUSTO],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "MARGEM_BRUTA"})][1] ==  "S"
		cQuery += " SUM((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('6110') THEN SD2.D2_DESCZFC - SD2.D2_DESCZFP ELSE 0 END) - SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 - SD2.D2_CUSTO1 - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') THEN SD2.D2_ICMSRET ELSE 0 END))) [MARGEM_BRUTA],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "P_CUSTO"})][1] ==  "S"
		cQuery += " (((SUM(SD2.D2_CUSTO1)/(SUM((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') AND SD2.D2_ICMSRET < (SD2.D2_VALBRUT - SD2.D2_VALIPI) THEN SD2.D2_ICMSRET WHEN (SD2.D2_VALBRUT - SD2.D2_VALIPI) = SD2.D2_ICMSRET THEN 1 ELSE 0 END))))))*100) [P_CUSTO],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "P_LUCRO"})][1] ==  "S"
		cQuery += " (((SUM((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('6110') THEN (SD2.D2_DESCZFC - SD2.D2_DESCZFP) ELSE 0 END) - SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 - SD2.D2_CUSTO1 - (CASE WHEN SD3.D2_CF NOT IN ('5949','6102') THEN SD2.D2_ICMSRET ELSE 0 END)))/(SUM((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949','6102') AND SD2.D2_ICMSRET < (SD2.D2_VALBRUT - SD2.D2_VALIPI) THEN SD2.D2_ICMSRET WHEN (SD2.D2_VALBRUT - SD2.D2_VALIPI) = SD2.D2_ICMSRET THEN 1 ELSE 0 END))))))*100) [P_LUCRO],
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "NCM"})][1] ==  "S"
		cQuery += " SB1.B1_POSIPI [NCM],
		If !("B1_POSIPI" $ cGroup)
			cGroup += " B1_POSIPI ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "TIPOCLI"})][1] ==  "S"
		cQuery += " SA1.A1_TIPO [TIPOLCI],
		if !("A1_TIPO" $ cGroup)
			cGroup += " A1_TIPO ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "IE"})][1] ==  "S"
		cQuery += " SA1.A1_INSCR [IE],
		if !("A1_INSCR" $ cGroup)
			cGroup += " A1_INSCR ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "SUFRAMA"})][1] ==  "S"
		cQuery += " SA1.A1_SUFRAMA [SUFRAMA],
		If !("A1_SUFRAMA" $ cGroup)
			cGroup += " A1_SUFRAMA ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "GRPTRIB"})][1] ==  "S"
		cQuery += " SA1.A1_GRPTRIB [GRPTRIB],
		if !("A1_GRPTRIB" $ cGroup)
			cGroup += " A1_GRPTRIB ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "TPESSOA"})][1] ==  "S"
		cQuery += " SA1.A1_TPESSOA [TPESSOA],
		if !("A1_TPESSOA" $ cGroup)
			cGroup += " A1_TPESSOA ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "CNAE"})][1] ==  "S"
		cQuery += " SA1.A1_CNAE [CNAE],
		if !("A1_CNAE" $ cGroup)
			cGroup += " A1_CNAE ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "SIMPLES"})][1] ==  "S"
		cQuery += " SA1.A1_SIMPNAC [SIMPLES],
		If !("A1_SIMPNAC" $ cGroup)
			cGroup += " A1_SIMPNAC ,"
		endif
	endif
		
	if aLbxCampo[ascan(aLbxCampo, {|x| alltrim(x[3]) == "MT"})][1] ==  "S"
		cQuery += " A1_REGESIM [MT],
		if !("A1_REGESIM" $ cGroup)
			cGroup += " A1_REGESIM ,"
		endif
	endif
		
	cQuery := substr(cQuery,1,rat(',',cQuery)-1) // Retira virgula
	cQuery += " FROM "+ RetSqlName("SD2") +" SD2
	cQuery += " INNER JOIN "+ RetSqlName("SA1") +" SA1
	cQuery += "  ON SA1_COD = SD2_CLIENTE
	cQuery += " AND SA1.A1_LOJA = SD2.D2_LOJA
	cQuery += " AND SA1.A1_VEND BETWEEN '"+ MV_PAR14 +"' AND '"+ MV_PAR15 +"'
	cQuery += " AND SA1.D_E_L_E_T_ != '*'
	cQuery += " INNER JOIN "+ RetSqlName("SB1") +" SB1
	cQuery += "  ON SB1.B1_COD = SD2.D2_COD
	cQuery += " AND SB1.B1_GRUPO BETWEEN '"+ MV_PAR12 +"' AND '"+ MV_PAR13 +"'
	cQuery += " AND SB1.D_E_L_E_T_ != '*'
	cQuery += " LEFT OUTER JOIN "+ RetSQLName("SA3") +" A3VEN
	cQuery += "  ON A3VEN.A3_COD = SA1.A1_VEND
	cQuery += " AND A3VEN.D_E_L_E_T_ != '*'
	cQuery += " LEFT JOIN "+ RetSqlName("SX5") +" REGIAO
	cQuery += "  ON REGIAO.X5_TABELA = 'A2'
	cQuery += " AND REGIAO.X5_CHAVE = SA1.A1_REGIAO
	cQuery += " AND REGIAO.D_E_L_E_T_ != '*'
	cQuery += " WHERE SD2.D_E_L_E_T_ <> '*'
	cQuery += " AND SD2.D2_FILIAL BETWEEN '"+ MV_PAR16 +"' AND '"+ MV_PAR17 +"'
	cQuery += " AND SD2.D2_EMISSAO BETWEEN '"+ dtos(MV_PAR02) +"' AND '"+ dtos(MV_PAR03) +"'
	cQuery += " AND SD2.D2_DOC BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"'
	cQuery += " AND SD2.D2_CLIENTE BETWEEN '"+ MV_PAR08 +"' AND '"+ MV_PAR09 +"'
	cQuery += " AND SD2.D2_LOJA BETWEEN '"+ MV_PAR10 +"' AND '"+ MV_PAR11 +"'
	cQuery += " AND SD2.D2_EST BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"'
	cQuery += " "+ substr(alltrim(cGroup),1,len(alltrim(cGroup))-1)
	cQuery += cAux1 
	cQuery += " "+ cOrder
		
endif

cQuery := ChangeQuery(cQuery)
// Mostra query
//Aviso("Query",cQuery,{"Ok"},3,,,,.T.)
TCQuery cQuery New Alias "TRB01"

oSection1:EndQuery()
oSection1:Print()

dbSelectArea("TRB01")
dbCloseArea()

return


//------------------------------------------------------------------------------
static function ResetArray()

aLbxCampo := {}

//adiciona Campos ao array
//aAdd( aLbxCampo, { lSelecionado,titulo,oCell,SetValue,select,group,"AS"})
if cComboBo1 == "1"
	aadd( aLbxCampo, { "S","Data Emissão","EMISSAO",.F.})
	aadd( aLbxCampo, { "S","Filial","COD_FIL",.F.})
	aadd( aLbxCampo, { "S","Número Doc","NF",.F.})
	aadd( aLbxCampo, { "S","Tipo Doc","TIPONF",.F.})
	aadd( aLbxCampo, { "S","Grupo","GRPROD",.F.})
	aadd( aLbxCampo, { "S","Cód.Produto","COD_PRODUTO",.F.})
	aadd( aLbxCampo, { "S","Produto","PRODUTO",.F.})
	aadd( aLbxCampo, { "S","CFOP","CFOP",.F.})
	aadd( aLbxCampo, { "S","Tipo Produto","TIPO",.F.})
	aadd( aLbxCampo, { "S","Quantidade","QUANTI",.F.})
	aadd( aLbxCampo, { "S","Região","REG",.F.})
	aadd( aLbxCampo, { "S","Cod Munic","COD_MUN",.F.})
	aadd( aLbxCampo, { "S","Municipio","MUNIC",.F.})
	aadd( aLbxCampo, { "S","Estado","ESTADO",.F.})
	aadd( aLbxCampo, { "S","Cód Cliente","COD_CLIENTE",.F.})
	aadd( aLbxCampo, { "S","Loja","LOJA",.F.})
	aadd( aLbxCampo, { "S","Razão Social","HISTORICO",.F.})
	aadd( aLbxCampo, { "S","Cód vendedor","COD_VEND",.F.})
	aadd( aLbxCampo, { "S","Vendedor","VENDEDOR",.F.})
	aadd( aLbxCampo, { "S","Cód Atendente","COD_OPERADOR",.F.})
	aadd( aLbxCampo, { "S","Atendente","OPERADOR",.F.})
	aadd( aLbxCampo, { "S","Vend TMK 1","NUAVEND1",.F.})
    aadd( aLbxCampo, { "S","Vend TMK 2","NUAVEND2",.F.})
    aadd( aLbxCampo, { "S","Marketing" ,"TMK",.F.})
	aadd( aLbxCampo, { "S","Pos.IPI/NCM","NCM",.F.})
	aadd( aLbxCampo, { "S","Tipo Cliente","TIPOCLI",.F.})
	aadd( aLbxCampo, { "S","Ins Estadual","IE",.F.})
	aadd( aLbxCampo, { "S","SUFRAMA","SUFRAMA",.F.})
	aadd( aLbxCampo, { "S","Grupo Tributo","GRPTRIB",.F.})
	aadd( aLbxCampo, { "S","Tipo Pessoa","TPESSOA",.F.})
	aadd( aLbxCampo, { "S","Codigo CNAE","CNAE",.F.})
	aadd( aLbxCampo, { "S","Opt Simp Nac","SIMPLES",.F.})
	aadd( aLbxCampo, { "S","Rg. Simp. MT","MT",.F.})
	aadd( aLbxCampo, { "S","Numero CTe","NUMCTE",.F.})
	aadd( aLbxCampo, { "S","Serie CTe","SERCTE",.F.})
	aadd( aLbxCampo, { "S","Frete","VALFRETE",.F.})
else
	aadd( aLbxCampo, { "N","Data Emissão","EMISSAO",.F.})
	aadd( aLbxCampo, { "N","Filial","COD_FIL",.F.})
	aadd( aLbxCampo, { "N","Número Doc","NF",.F.})
	aadd( aLbxCampo, { "N","Tipo Doc","TIPONF",.F.})
	aadd( aLbxCampo, { "N","Família","GRPROD",.F.})
	aadd( aLbxCampo, { "N","Cód Produto","COD_PRODUTO",.F.})
	aadd( aLbxCampo, { "N","Produto","PRODUTO",.F.})
	aadd( aLbxCampo, { "N","CFOP","CFOP",.F.})
	aadd( aLbxCampo, { "N","Tipo Produto","TIPO",.F.})
	aadd( aLbxCampo, { "N","Quantidade","QUANTI",.F.})
	aadd( aLbxCampo, { "N","Região","REG",.F.})
	aadd( aLbxCampo, { "N","Cod Munic","COD_MUN",.F.})
	aadd( aLbxCampo, { "N","Municipio","MUNIC",.F.})
	aadd( aLbxCampo, { "N","Estado","ESTADO",.F.})
	aadd( aLbxCampo, { "N","Cód Cliente","COD_CLIENTE",.F.})
	aadd( aLbxCampo, { "N","Loja","LOJA",.F.})
	aadd( aLbxCampo, { "N","Razão Social","HISTORICO",.F.})
	aadd( aLbxCampo, { "N","Cód vendedor","COD_VEND",.F.})
	aadd( aLbxCampo, { "N","Vendedor","VENDEDOR",.F.})
	aadd( aLbxCampo, { "N","Cód Atendente","COD_OPERADOR",.F.})
	aadd( aLbxCampo, { "N","Atendente","OPERADOR",.F.}) 
	aadd( aLbxCampo, { "N","Vend TMK 1","NUAVEND1",.F.})
    aadd( aLbxCampo, { "N","Vend TMK 2","NUAVEND2",.F.})
    aadd( aLbxCampo, { "N","Marketing" ,"TMK",.F.})
	aadd( aLbxCampo, { "N","Pos.IPI/NCM","NCM",.F.})
	aadd( aLbxCampo, { "N","Tipo Cliente","TIPOCLI",.F.})
	aadd( aLbxCampo, { "N","Ins Estadual","IE",.F.})
	aadd( aLbxCampo, { "N","SUFRAMA","SUFRAMA",.F.})
	aadd( aLbxCampo, { "N","Grupo Tributo","GRPTRIB",.F.})
	aadd( aLbxCampo, { "N","Tipo Pessoa","TPESSOA",.F.})
	aadd( aLbxCampo, { "N","Codigo CNAE","CNAE",.F.})
	aadd( aLbxCampo, { "N","Opt Simp Nac","SIMPLES",.F.})
	aadd( aLbxCampo, { "N","Rg. Simp. MT","MT",.F.})
	aadd( aLbxCampo, { "N","Numero CTe","NUMCTE",.F.})
	aadd( aLbxCampo, { "N","Serie CTe","SERCTE",.F.})
	aadd( aLbxCampo, { "N","Frete","VALFRETE",.F.})
	
endif

aadd( aLbxCampo, { "S","Venda","VENDA",.F.})
aadd( aLbxCampo, { "S","IPI","IPI",.F.})
aadd( aLbxCampo, { "S","ST","ST",.F.})
aadd( aLbxCampo, { "S","Receita bruta","RECEITA_BRUTA",.F.})
aadd( aLbxCampo, { "S","ICMS","ICMS",.F.})
aadd( aLbxCampo, { "S","PIS","PIS",.F.})
aadd( aLbxCampo, { "S","Cofins","COFINS",.F.})
aadd( aLbxCampo, { "S","Desconto","DESCONTO",.F.})
aadd( aLbxCampo, { "S","Receira Liquida","RECEITA_LIQUIDA",.F.})
aadd( aLbxCampo, { "S","Custo","CUSTO",.F.})
aadd( aLbxCampo, { "S","Margem Bruta","MARGEM_BRUTA",.F.})
aadd( aLbxCampo, { "S","% Custo","P_CUSTO",.F.})
aadd( aLbxCampo, { "S","% Lucro","P_LUCRO",.F.})

return nil


//------------------------------------------------------------------------------
Static Function Tela

local lGera := .F.

private oDlgSel := nil

//ordena por título do campo para facilitar a seleção do usuário
aSort(aLbxCampo,,,{|x,y| x[2]<y[2]})

// define a tela para seleção das notas a imprimir
Define MSDialog oDlgSel From 001, 001 To 492, 945 Title "Seleção de Campos" Pixel

// posiciona a divisão da tela
@ 020, 004 to 227, 470 title "Campos: "
// posiciona o listbox
@ 028, 008 listbox oLbxCampo fields header "", "Descrição" size 458, 195 of oDlgSel pixel
// ajusta o listbox
oLbxCampo:SetArray( aLbxCampo )

oLbxCampo:bLine := {|| { Est01Img( aLbxCampo[oLbxCampo:nAt][01] ),; // flag seleção
                         aLbxCampo[oLbxCampo:nAt][02] }}			// Campo

// mostra help ao usuario
oLbxCampo:cToolTip := "Clique no cabeçalho da tabela para marcar ou desmarcar todos"
// marca/desmarca todos Campos
oLbxCampo:bHeaderClick := {|x, y| LbxHClick(y) }
// marca/desmarca o registro
oLbxCampo:bLDblClick := {|| LbxDClick() }
// atualiza o listbox
oLbxCampo:Refresh()

// ativa a tela
Activate MSDialog oDlgSel Centered On Init EnchoiceBar( oDlgSel, {|| oDlgSel:end() }, {|| oDlgSel:end() })

return nil


/*/{Protheus.doc} Est01Img
Retorna a imagem para item desmarcado

@author		dirlei@afsouza
@since		06/05/2019
@version	P12

@param		cFlag, caracter, S/N

@return		oRet, objeto, retorno marcação

@type		function
/*/
static function Est01Img(cFlag)

// retorno da função
local oRet := nil

if ( cFlag == "S" )
	// marca o item
	oRet := LoadBitmap( GetResources(), "LBOK" )
else
	// desamarca o item
	oRet := LoadBitmap( GetResources(), "LBNO" )
endif

return oRet


/*/{Protheus.doc} LbxHClick
Marca/Desmarca todos os campos do ListBox

@author		dirlei@afsouza
@since		06/05/2019
@version	P12

@param		nCol, numerica, item

@return		nil, nenhum

@type		function
/*/
static function LbxHClick( nCol )

// flag de marcação
local cMark := ""

// contador de loop
local nI := 0

// verifica se os Camposs estão marcados
if aLbxCampo[oLbxCampo:nAt][01] == "S"
	cMark := "N"
else
	cMark := "S"
endif

// marca/desmarca todos os campos
for nI := 1 to len(aLbxCampo)
	aLbxCampo[nI][01] := cMark
next nI

// atualiza o listbox
oLbxCampo:Refresh()

return nil


/*/{Protheus.doc} LbxDClick
responde ao evento de double Click do listbox

@author		dirlei@afsouza
@since		06/05/2019
@version	P12

@return		nil, nenhum

@type		function
/*/
static function LbxDClick()

if aLbxCampo[oLbxCampo:nAt][01] == "N"
	// marca o item
	aLbxCampo[oLbxCampo:nAt][01] := "S"
else
	// desmarca o item
	aLbxCampo[oLbxCampo:nAt][01] := "N"
endIf

// atualiza o listbox
oLbxCampo:Refresh()

return nil
