#INCLUDE 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//==================================================================================================//
//	Programa: ST03SLDP		|	Autor: Luis Paulo							|	Data: 06/12/2021	//
//==================================================================================================//
//	Descrição: REL. SALDO PRODUTO E ULT COMP E ULT VENDA										    //
//																									//
//==================================================================================================//
User function ST03SLDP()

//Variaveis Parambox
Local 		aParamBox 	:= {}
Local 		aSituac		:= {"TODOS","PENDENTE","BAIXA PARCIAL","BAIXADO"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private 	oReport		:= Nil

	AAdd(aParamBox, { 1,"Filial de?"		,Space(6)       ,"","","XM0"	,"",0,.F.}) // Tipo caractere
    AAdd(aParamBox, { 1,"Filial ate?"		,Space(6)       ,"","","XM0"    ,"",0,.F.}) // Tipo caractere
    
	AAdd(aParamBox, { 1,"Amz de?"			,Space(2)       ,"","","NNR"	,"",0,.F.}) // Tipo caractere
    AAdd(aParamBox, { 1,"Amz ate?"		    ,Space(2)       ,"","","NNR"	    ,"",0,.F.}) // Tipo caractere
	
	aAdd(aParamBox, { 1,"Vendas menores que?"  	,Ctod(Space(8)) ,"","","",""    ,50,.F.}) // Tipo data
	
If ParamBox(aParamBox,"REL CONFERENCIA DE SALDOS", @aRet,, ,lCentered, , , , , .T., .T.)//@aRet Array com respostas - Par 11 salvar perguntas
	   oReport	:= ReportDef()		// Monta a Estrutura do TReport
	   oReport:PrintDialog()		//Dispara a tela de impressão
   Else 
      	Return .T.
Endif

Return()


//Monta estrutura
Static Function ReportDef()
Local _oBreak
Local _cNome		:= "REL CONFERENCIA DE SALDOS"
Local _cPerg4
Local _cPerg5		
Local _cTitulo		:= "REL CONFERENCIA DE SALDOS"		
Local _cDescri		:= "REL CONFERENCIA DE SALDOS"
Local _cTSec1		:= "REL CONFERENCIA DE SALDOS"
Local _cMaskNm		:= "@E 999,999,999,999.99"
Local _cMaskCN		:= "@R 99.999.999/9999-99"
Local _cMaskCP		:= "@R 999.999.999-99"
Private 	_bBlock		:= {|oReport| PrintReport(oReport)}

oReport	:= TReport():New(_cNome,_cTitulo,,_bBlock,_cDescri)

oReport:SetEnvironment(9)
oReport:nFontBody		:= 07			//Tamanho do texto
oReport:nLineHeight		:= 42			//altura das linhas
oReport:SetLandscape() 			//chama a função para orientação Paisagem
//oReport:SetPortrait() 					//chama a função para orientação Paisagem
oReport:lParamPage 		:= .F.

oReport:oPage:SetPaperSize(9)			//Define o tamanho do papel
oReport:DisableOrientation()			//Desabilita selecao de retrato/paisagem
//oReport:lDisableOrientation := .T.	//Desabilita selecao de retrato/paisagem

oReport:HideParamPage()					//Define se será permitida a alteração dos parâmetros do relatório.
oReport:oPage:NoUserFilter()			//Desabilita a utilização de filtros na personalização do relatório.
//oReport:ParamReadOnly()				//Define se o usuário terá acesso aos parâmetros do relatório.

//Declaração da Secção	
oSec1 := TRSection():New( oReport , "REL. SLDS DE PRODUTOS", {"cAlias1"} )

//Declaração das colunas
TRCell():New( oSec1, "FILIAL"		, "cAlias1", "Filial"			, "@!"						    , TamSx3("D2_FILIAL")[1]	,,,"LEFT",,"LEFT")
TRCell():New( oSec1, "PROD"		    , "cAlias1", "Produto"		    , "@!"						    , TamSx3("B1_COD")[1]		,,,"LEFT",,"LEFT")
TRCell():New( oSec1, "PRODDES"		, "cAlias1", "Desc Prd"		    , "@!"						    , TamSx3("B1_DESC")[1]		,,,"LEFT",,"LEFT")
TRCell():New( oSec1, "GRUPO"		, "cAlias1", "Grupo" 			, "@!"						    , TamSx3("B1_GRUPO")[1]	    ,,,"LEFT",,"LEFT")
TRCell():New( oSec1, "AMZ"		    , "cAlias1", "Amz"			    , "@!"						    , TamSx3("B2_LOCAL")[1]		,,,"LEFT",,"LEFT")
TRCell():New( oSec1, "QTD"			, "cAlias1", "Qtd"	   			, _cMaskNm					    , TamSx3("D1_QUANT")[1]     ,,,"RIGHT",,"RIGHT")
TRCell():New( oSec1, "CM"			, "cAlias1", "Custo Medio"		, _cMaskNm					    , TamSx3("D1_QUANT")[1]     ,,,"RIGHT",,"RIGHT")
TRCell():New( oSec1, "VLRTOT"		, "cAlias1", "Valor Total"		, _cMaskNm					    , TamSx3("D1_QUANT")[1]     ,,,"RIGHT",,"RIGHT")
TRCell():New( oSec1, "ULT_VENDA"	, "cAlias1", "Ult Venda"		, PesqPict("SD2","D2_EMISSAO")	, TamSx3("D2_EMISSAO")[1]	,,,"CENTER",,"CENTER")
TRCell():New( oSec1, "ULT_COMPRA"	, "cAlias1", "Ult Compra"		, PesqPict("SD2","D2_EMISSAO")	, TamSx3("D2_EMISSAO")[1]	,,,"CENTER",,"CENTER")

Return(oReport)

// Função que processa os Dados.
Static Function PrintReport(oReport)
Local cCRLF		:= CRLF
Local oSecINI	:= oReport:Section(1)
Local _cPerg1	:= MV_PAR01
Local _cPerg2	:= (MV_PAR02)
Local _cPerg3	:= (MV_PAR03)
Local _cPerg4	:= (MV_PAR04)

Local _cMaskNm		:= "@E 999,999,999,999.99"
Local _cMaskCN		:= "@R 99.999.999/9999-99"
Local _cMaskCP		:= "@R 999.999.999-99"
Local cQuery	:= ''
Private cAlias1	:= GetNextAlias()

cQuery := " SELECT *  "+cCRLF
cQuery += "	FROM (  "+cCRLF
cQuery += "			SELECT B2_FILIAL AS FILIAL,B1_COD AS PROD,B1_GRUPO AS GRUPO, B1_DESC AS PRODDES,B2_LOCAL AS AMZ, B2_QATU AS QTD,B2_CM1 AS CM,B2_VATU1 AS VLRTOT,  "+cCRLF
cQuery += "				(SELECT TOP 1 D2_EMISSAO FROM "+ RetSqlName("SD2") +" WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND D2_FILIAL = SB2.B2_FILIAL AND D2_COD = SB2.B2_COD ORDER BY D2_EMISSAO DESC) AS ULT_VENDA,  "+cCRLF
cQuery += "				(SELECT TOP 1 D1_EMISSAO FROM "+ RetSqlName("SD1") +" WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND D1_FILIAL = SB2.B2_FILIAL AND D1_COD = SB2.B2_COD ORDER BY D1_EMISSAO DESC) AS ULT_COMPRA  "+cCRLF
cQuery += "			FROM "+ RetSqlName("SB2") +" SB2 WITH(NOLOCK)  "+cCRLF
cQuery += "			INNER JOIN "+ RetSqlName("SB1") +" SB1 WITH(NOLOCK) ON B1_COD = B2_COD AND SB1.D_E_L_E_T_<>'*'  "+cCRLF
cQuery += "			WHERE SB2.D_E_L_E_T_ = ''  "+cCRLF
cQuery += "			AND SB2.B2_FILIAL >= '" + aRet[1] + "'  "+cCRLF
cQuery += "			AND SB2.B2_FILIAL <= '" + aRet[2] + "'  "+cCRLF
cQuery += "			AND SB2.B2_LOCAL >= '" + aRet[3] + "'  "+cCRLF
cQuery += "			AND SB2.B2_LOCAL <= '" + aRet[4] + "'  "+cCRLF
cQuery += "			AND SB2.B2_QATU > 0   "+cCRLF
cQuery += "		) DADOS_CP  "+cCRLF
cQuery += "	WHERE ULT_VENDA < '" + DTOS(aRet[5]) + "'  "+cCRLF
cQuery += "	ORDER BY QTD  "+cCRLF

Conout(cQuery)

If Select("cAlias1") <> 0
	DBSelectArea("cAlias1")
	cAlias1->(DBCloseArea())
Endif

TCQuery cQuery NEW ALIAS 'cAlias1'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea("cAlias1")
cAlias1->(DBGoTop())


oSecINI:Init()

While !oReport:Cancel() .AND. !cAlias1->(EOF())

	oReport:Line()	
	oReport:IncMeter()	//regua

 	oSecINI:Cell("FILIAL" 	)	:SetValue(ALLTRIM(cAlias1->FILIAL))
	oSecINI:Cell("PROD"     )	:SetValue(ALLTRIM(cAlias1->PROD))
    oSecINI:Cell("PRODDES"  )	:SetValue(ALLTRIM(cAlias1->PRODDES))
	
	oSecINI:Cell("GRUPO" 	)	:SetValue(ALLTRIM(cAlias1->GRUPO))
	oSecINI:Cell("AMZ"	    )	:SetValue(ALLTRIM(cAlias1->AMZ))
    
	oSecINI:Cell("QTD"		)	:SetValue(cAlias1->QTD)
	oSecINI:Cell("CM"		)	:SetValue(cAlias1->CM)
	oSecINI:Cell("VLRTOT"	)	:SetValue(cAlias1->VLRTOT)

	oSecINI:Cell("ULT_VENDA"	)	:SetValue(STOD(cAlias1->ULT_VENDA))
	oSecINI:Cell("ULT_COMPRA"	)	:SetValue(STOD(cAlias1->ULT_COMPRA))

	oSecINI:PrintLine()
	cAlias1->(DBSkip())
EndDo

oSecINI:Finish()
cAlias1->(DBCloseArea())

Return
