#INCLUDE 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
//==================================================================================================//
//	Programa: ST02COMO		|	Autor: Luis Paulo							|	Data: 16/11/2021	//
//==================================================================================================//
//	Descrição: REL. CONFERENCIA DE COMODATOS													    //
//																									//
//==================================================================================================//

User function ST02COMO()

//Variaveis Parambox
Local 		aParamBox 	:= {}
Local 		aSituac		:= {"TODOS","PENDENTE","BAIXA PARCIAL","BAIXADO"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private 	oReport		:= Nil

	AAdd(aParamBox, { 1,"Cliente de?"		,Space(6)       ,"","","SA1"	,"",0,.F.}) // Tipo caractere
    AAdd(aParamBox, { 1,"Loja de?"		    ,Space(2)       ,"","",""	    ,"",0,.F.}) // Tipo caractere
    AAdd(aParamBox, { 1,"Cliente ate?"		,Space(6)       ,"","","SA1"	,"",0,.F.}) // Tipo caractere
    AAdd(aParamBox, { 1,"Loja ate?"		    ,Space(2)       ,"","",""	    ,"",0,.F.}) // Tipo caractere
	aAdd(aParamBox, { 1,"Emissão de?"  		,Ctod(Space(8)) ,"","","",""    ,50,.F.}) // Tipo data
	aAdd(aParamBox, { 1,"Emissão Até?"  	,Ctod(Space(8)) ,"","","",""    ,50,.F.}) // Tipo data
	
If ParamBox(aParamBox,"REL CONFERENCIA DE COMODATOS", @aRet,, ,lCentered, , , , , .T., .T.)//@aRet Array com respostas - Par 11 salvar perguntas
	   oReport	:= ReportDef()		// Monta a Estrutura do TReport
	   oReport:PrintDialog()		//Dispara a tela de impressão
   Else 
      	Return .T.
Endif

Return()


//Monta estrutura
Static Function ReportDef()
Local _oBreak
Local _cNome		:= "REL CONFERENCIA DE COMODATOS"
Local _cPerg4
Local _cPerg5		
Local _cTitulo		:= "REL CONFERENCIA DE COMODATOS"		
Local _cDescri		:= "REL CONFERENCIA DE COMODATOS"
Local _cTSec1		:= "REL CONFERENCIA DE COMODATOS"
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
	oSec1 := TRSection():New( oReport , "REL. ANALÍTICO DE COMODATOS", {"cAlias1"} )
	//Declaração das colunas
	
	TRCell():New( oSec1, "FILIAL"		, "cAlias1", "Filial"			, "@!"						    , TamSx3("D2_FILIAL")[1]	,,,"LEFT",,"LEFT")
	TRCell():New( oSec1, "CLIENTE"		, "cAlias1", "Cliente" 			, "@!"						    , TamSx3("A1_COD")[1]	    ,,,"LEFT",,"LEFT")
	TRCell():New( oSec1, "LOJA"		    , "cAlias1", "Loja"			    , "@!"						    , TamSx3("A1_LOJA")[1]		,,,"LEFT",,"LEFT")
	TRCell():New( oSec1, "DESCLI"		, "cAlias1", "Desc Cli"		    , "@!"						    , TamSx3("A1_NOME")[1]		,,,"LEFT",,"LEFT")
	TRCell():New( oSec1, "EMISSAO"		, "cAlias1", "Emissao"			, PesqPict("SD2","D2_EMISSAO")	, TamSx3("D2_EMISSAO")[1]	,,,"CENTER",,"CENTER")
    TRCell():New( oSec1, "SERIE"		, "cAlias1", "Serie"		    , "@!"						    , TamSx3("A1_LOJA")[1]		,,,"CENTER",,"CENTER")
    TRCell():New( oSec1, "NFSAIDA"		, "cAlias1", "NF Saida"		    , "@!"						    , TamSx3("D2_DOC")[1]		,,,"LEFT",,"LEFT")
    TRCell():New( oSec1, "ITEM"		    , "cAlias1", "Item"			    , "@!"						    , TamSx3("D2_ITEM")[1]		,,,"CENTER",,"CENTER")
    TRCell():New( oSec1, "PROD"		    , "cAlias1", "Produto"		    , "@!"						    , TamSx3("B1_COD")[1]		,,,"LEFT",,"LEFT")
    TRCell():New( oSec1, "PRODDES"		, "cAlias1", "Desc Prd"		    , "@!"						    , TamSx3("B1_DESC")[1]		,,,"LEFT",,"LEFT")
    TRCell():New( oSec1, "TOTENVIADO"	, "cAlias1", "Total Env"	    , _cMaskNm					    , TamSx3("D1_QUANT")[1]     ,,,"RIGHT",,"RIGHT")
    TRCell():New( oSec1, "CFOP"		    , "cAlias1", "CFOP"		        , "@!"						    , TamSx3("D2_CF")[1]		,,,"CENTER",,"CENTER")
    TRCell():New( oSec1, "ULTCP"		, "cAlias1", "Ult Compra"		, PesqPict("SA1","A1_ULTCOM")	, TamSx3("A1_ULTCOM")[1]	,,,"CENTER",,"CENTER")
    TRCell():New( oSec1, "TOTRETORNO"	, "cAlias1", "Total Ret"		, _cMaskNm					    , TamSx3("D1_QUANT")[1]	    ,,,"RIGHT",,"RIGHT")

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

cQuery := " SELECT	SD2.D2_FILIAL,D2_CLIENTE,D2_LOJA,SA1.A1_NOME, "+cCRLF
cQuery += "			D2_EMISSAO AS EMISSAO,D2_SERIE AS SERIE,D2_DOC AS NF,D2_ITEM AS ITEM, "+cCRLF
cQuery += "			SD2.D2_COD,SB1.B1_DESC,SD2.D2_QUANT, "+cCRLF
cQuery += "			SD2.D2_CF AS CFOP, "+cCRLF
cQuery += "			SA1.A1_ULTCOM, "+cCRLF
cQuery += "			ISNULL((	SELECT SUM(D1_QUANT)  "+cCRLF
cQuery += "						FROM "+ RetSqlName("SD1") +" WITH(NOLOCK)  "+cCRLF
cQuery += "						WHERE D_E_L_E_T_ = '' "+cCRLF
cQuery += "						AND D1_FILIAL = SD2.D2_FILIAL "+cCRLF
cQuery += "						AND D1_SERIORI	= SD2.D2_SERIE "+cCRLF
cQuery += "						AND D1_NFORI	= SD2.D2_DOC "+cCRLF
cQuery += "						AND D1_ITEMORI	= SD2.D2_ITEM "+cCRLF
cQuery += "						AND D1_COD		= SD2.D2_COD  "+cCRLF  
cQuery += "						AND D1_CF IN ('1909','2909') "+cCRLF
cQuery += "					) ,0)AS TOTALRET "+cCRLF
cQuery += "	FROM "+ RetSqlName("SD2") +" SD2 WITH(NOLOCK) "+cCRLF
cQuery += "	INNER JOIN "+ RetSqlName("SA1") +" SA1 WITH(NOLOCK) ON SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.D_E_L_E_T_ = ''  "+cCRLF //AND SA1.A1_ULTCOM <= '20210531'
cQuery += "	INNER JOIN "+ RetSqlName("SB1") +" SB1 WITH(NOLOCK) ON SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_ = '' "+cCRLF
cQuery += "	WHERE SD2.D_E_L_E_T_ = '' "+cCRLF
cQuery += "	AND SD2.D2_EMISSAO >= '" + DTOS(aRet[5]) + "' "+cCRLF
cQuery += "	AND SD2.D2_EMISSAO <= '" + DTOS(aRet[6]) + "' "+cCRLF

cQuery += "	AND SD2.D2_CLIENTE	>= '" + aRet[1] + "'  "+cCRLF
cQuery += "	AND SD2.D2_LOJA		>= '" + aRet[2] + "'  "+cCRLF   
cQuery += "	AND SD2.D2_CLIENTE	<= '" + aRet[3] + "'  "+cCRLF
cQuery += "	AND SD2.D2_LOJA		<= '" + aRet[4] + "'  "+cCRLF

cQuery += "	AND SD2.D2_CF IN ('5908','6908') "+cCRLF
cQuery += "	ORDER BY SD2.D2_FILIAL,D2_EMISSAO,D2_SERIE,D2_DOC,D2_ITEM "+cCRLF

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

 	oSecINI:Cell("FILIAL" 	)	:SetValue(ALLTRIM(cAlias1->D2_FILIAL))
	oSecINI:Cell("CLIENTE" 	)	:SetValue(ALLTRIM(cAlias1->D2_CLIENTE))
	oSecINI:Cell("LOJA"	    )	:SetValue(ALLTRIM(cAlias1->D2_LOJA))
    oSecINI:Cell("DESCLI"   )	:SetValue(ALLTRIM(cAlias1->A1_NOME))
    oSecINI:Cell("EMISSAO"	)	:SetValue(STOD(cAlias1->EMISSAO))

    oSecINI:Cell("SERIE"    )	:SetValue(ALLTRIM(cAlias1->SERIE))
    oSecINI:Cell("NFSAIDA"  )	:SetValue(ALLTRIM(cAlias1->NF))
    oSecINI:Cell("ITEM"     )	:SetValue(ALLTRIM(cAlias1->ITEM))
    oSecINI:Cell("PROD"     )	:SetValue(ALLTRIM(cAlias1->D2_COD))
    oSecINI:Cell("PRODDES"  )	:SetValue(ALLTRIM(cAlias1->B1_DESC))

    oSecINI:Cell("TOTENVIADO")	:SetValue(cAlias1->D2_QUANT)
	
	oSecINI:Cell("CFOP"      )	:SetValue(ALLTRIM(cAlias1->CFOP))
	oSecINI:Cell("ULTCP"	 )	:SetValue(STOD(cAlias1->A1_ULTCOM))

    oSecINI:Cell("TOTRETORNO")	:SetValue(cAlias1->TOTALRET)

	oSecINI:PrintLine()
	cAlias1->(DBSkip())
EndDo

oSecINI:Finish()
cAlias1->(DBCloseArea())

Return
