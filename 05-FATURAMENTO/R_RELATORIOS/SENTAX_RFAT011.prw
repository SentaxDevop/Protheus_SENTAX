//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#include 'parmtype.ch'

//Constantes
//#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} RFAT011
Rubbermaid 
Gerar XML com dados de vendas para montar modelo
de Plantilla información mínima TSOL- GENERAL 
@author João AFSouza
@since 07/11/2019
@version 1.0
@example u_RFAT011 ()
/*/

User Function RFAT011()

	PRIVATE _cCompCode := ""
	PRIVATE _aAreaDep := {}  // Areas depreciaveis.
	PRIVATE _cAreaDep := ""  // area de depreciação.
	PRIVATE _cDescDep := ""  // Descricao area de depreciação.
	PRIVATE nI  
	PRIVATE nCnt       := 0

	PRIVATE cPerg   := 'ATVXML'
	PRIVATE aArea     := GetArea()

	PRIVATE NHANDLE   

	PRIVATE dDtIni		:= mv_par01                   // Emissão Inicial
	PRIVATE dDtFim		:= mv_par02                   // EMissao Final  
	PRIVATE cGRPI	    := ALLTRIM(mv_par03)          // Grupo de
	PRIVATE cGRPF	    := ALLTRIM(mv_par04)          // Grupo até 

	PRIVATE	_aSaldo := {}
	PRIVATE	_nQuant := 0
	PRIVATE _nQtdeT := 0
	PRIVATE _cProd   := ""

	//CriaSx1(cPerg)

	Pergunte(cPerg,.T.)

	//IF !APOLECLIENT('MSEXCEL')
	//	AVISO("MSEXCEL","NECESSARIO QUE O MS EXCEL ESTEJA INSTALADO.",{"OK"},1)
	//ENDIF
	//PROCESSA({|LEND|PROCIMP(@LEND)},"Importacao registros Protheus","AGUARDE. PREPARANDO DADOS PARA IMPRESSÃO...",.T.)
	oProcess := MsNewProcess():New({|lAbort| procIMp(@oProcess, @lAbort) },"Extraindo registros","CARREGANDO DADOS...",.T.)
	oProcess:Activate()

Return

Static Function PROCIMP

	LOCAL CTBP    := GETNEXTALIAS()
	LOCAL CDIRDOCS := MSDOCPATH()
	LOCAL ASTRU	   := {}
	LOCAL CARQUIVO := CRIATRAB(,.F.)
	LOCAL CPATH	   := ALLTRIM(GETTEMPPATH())
	LOCAL OEXCELAPP
	LOCAL NLIN   	:= 0
	LOCAL CGRUPO 	:= ""
	LOCAL CDESCRI	:= ""
	LOCAL AGRUPO 	:= {}
	LOCAL ALINHAS 	:= {}
	LOCAL NREGS := 0

	LOCAL QRYSN1    := ""
	LOCAL nMesesDep := 0
	LOCAL nAnosDep  := 0
	LOCAL nDifMonth := 0

	LOCAL nYearSAP  := 0
	LOCAL nMontSAP  := 0

	Private dDtExt  := mv_par02                   // Emissão da OP Inicial

	Private NHANDLE
	Private ACAB:={}
	NHANDLE := MSFCREATE(CDIRDOCS+"\"+CARQUIVO+".XML",0)


	If Select('QRYSD2')<>0
		DBCloseArea('QRYSD2')
	EndIF

	cQuery := " SELECT                                                      "
	cQuery += " ROW_NUMBER() OVER(ORDER BY SD2.D2_DOC) [NLINHA],            "
	cQuery += "	SD2.D2_FILIAL [FILIAL],                                     "
	cQuery += " SD2.D2_DOC      [NFISCAL],                                  "
	cQuery += " SD2.D2_EMISSAO  [EMISSAO],                                  "
	cQuery += " SA1.A1_VEND     [COD_VEND],                                 "
	cQuery += " A3VEN.A3_NREDUZ [VENDEDOR],                                 "
	cQuery += " A3VEN.A3_CODUSR [USRVEND],                                  "
	cQuery += " SA1.A1_COD_MUN  [CODMUN],                                   "
	cQuery += " SA1.A1_MUN      [MUN],                                      "
	cQuery += " SA1.A1_COD      [CODCLI],                                   "
	cQuery += "	SUBSTRING(SA1.A1_NOME,1,60)     [NOMCLI],                   " 
	cQuery += " SA1.A1_CGC      [CNPJ],                                     "
	cQuery += " SA1.A1_END      [ENDR],                                     "
	cQuery += " SD2.D2_COD      [COD_PRODUTO],                              "
	cQuery += " SB1.B1_DESC     [PRODUTO],                                  "
	cQuery += " SD2.D2_ITEM     [ITEM],                                     "
	cQuery += " SB1.B1_CODBAR   [CODBARRAS],                                "
	cQuery += " 'NOMBRE PROVEEDOR' [PROVEEDOR],                             "
	cQuery += " SA1.A1_SATIV1   [TPNEGOCIO],                                "
	cQuery += " ATIVIDADE.X5_DESCRI  [NOMENEGOCIO],                         "
	cQuery += " CASE WHEN SD2.D2_TIPO='D' THEN '1' ELSE '0' END [TIPOV],    "
	cQuery += " SD2.D2_QUANT [QUANTI],                                      "
	cQuery += " SD2.D2_CUSTO1 [CUSTO],                                      "
	cQuery += " SD2.D2_VALBRUT [VENDA]                                      "
	cQuery += "     FROM                                                    "
	cQuery += " "+RetSQLName('SD2')+" SD2 (NOLOCK)                          "
	cQuery += "     INNER JOIN                                              "
	cQuery += "     "+RetSQLName('SF2')+" SF2 (NOLOCK)                      "
	cQuery += "     ON SF2.F2_FILIAL = SD2.D2_FILIAL                        "
	cQuery += "     AND SF2.F2_DOC = SD2.D2_DOC                             "
	cQuery += "     AND SF2.F2_SERIE = SD2.D2_SERIE                         "
	cQuery += "     AND SF2.F2_CLIENTE = SD2.D2_CLIENTE                     "
	cQuery += "     AND SF2.F2_LOJA = SD2.D2_LOJA                           "
	cQuery += "     AND SF2.F2_DUPL != ' '                                  "
	cQuery += "     AND SF2.F2_TIPO IN                                      "
	cQuery += "      (                                                      "
	cQuery += "        'N',                                                 "
	cQuery += "        'D'                                                  "
	cQuery += "       )                                                     "
	cQuery += "     AND SF2.D_E_L_E_T_ != '*'                               "
	cQuery += "     INNER JOIN                                              "
	cQuery += "     "+RetSQLName('SA1')+" SA1 (NOLOCK)                      "
	cQuery += "     ON SA1.A1_COD = SD2.D2_CLIENTE                          "
	cQuery += "     AND SA1.A1_LOJA = SD2.D2_LOJA                           "
	//cQuery += "   AND SA1.A1_VEND BETWEEN '      ' AND 'ZZZZZZ'           "
	cQuery += "     AND SA1.D_E_L_E_T_ != '*'                               "
	cQuery += "     INNER JOIN                                              "
	cQuery += "     "+RetSQLName('SB1')+" SB1 (NOLOCK)                      "
	cQuery += "     ON SB1.B1_COD = SD2.D2_COD                              "
	cQuery += "     AND SB1.B1_GRUPO BETWEEN '"+AllTrim(MV_PAR03)+"'   AND '"+AllTrim(MV_PAR04)  +"' "
	cQuery += "     AND SB1.D_E_L_E_T_ != '*'                               "
	cQuery += "     INNER JOIN                                              "
	cQuery += "     "+RetSQLName('SBM')+" SBM (NOLOCK)                      "
	cQuery += "     ON SB1.B1_GRUPO = SBM.BM_GRUPO                          "
	cQuery += "     AND SBM.D_E_L_E_T_ != '*'                               "
	cQuery += "     LEFT JOIN                                               "
	cQuery += "     "+RetSQLName('SA3')+" A3VEN (NOLOCK)                    "
	cQuery += "     ON A3VEN.A3_COD = SA1.A1_VEND                           "
	cQuery += "     AND A3VEN.D_E_L_E_T_ != '*'                             "
	cQuery += "     LEFT JOIN                                               "
	cQUery += "     "+RetSQLName('SX5')+" REGIAO  (NOLOCK)                  "    
	cQuery += "     ON REGIAO.X5_TABELA = 'A2'                              "
	cQuery += "     AND REGIAO.X5_CHAVE = A1_REGIAO                         "
	cQuery += "     AND REGIAO.D_E_L_E_T_ != '*'                            "
	cQuery += "     LEFT JOIN                                               "
	cQuery += "     "+RetSQLName('SX5')+" ATIVIDADE (NOLOCK)                "
	cQuery += "     ON ATIVIDADE.X5_TABELA = 'T3'                           "
	cQuery += "    AND ATIVIDADE.X5_CHAVE = A1_SATIV1                       "
	cQuery += "    AND ATIVIDADE.D_E_L_E_T_ != '*'                          "
	cQuery += "       WHERE                                                 "
	cQuery += "     SD2.D_E_L_E_T_ != '*'                                   "
	cQuery += "     AND SD2.D2_FILIAL BETWEEN '      ' AND 'ZZZZZZ'         "
	cQuery += "     AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+  "'   AND '"+DTOS(MV_PAR02)    +"' "

	cQuery += "	 UNION ALL "

	cQuery += "	SELECT                                                   "                    
	cQuery += "	ROW_NUMBER() OVER(ORDER BY SD1.D1_DOC) [NLINHA],         "
	cQuery += "	SD1.D1_FILIAL [FILIAL],                                  "
	cQuery += "	SD1.D1_DOC [NFISCAL],                                    "                  
	cQuery += "	SD1.D1_DTDIGIT [EMISSAO],                                "                
	cQuery += "	SA1.A1_VEND [COD_VEND],                                  "                  
	cQuery += "	A3VEN.A3_NREDUZ [VENDEDOR],                              "                 
	cQuery += "	A3VEN.A3_CODUSR [USRVEND],                               "                 
	cQuery += "	SA1.A1_COD_MUN  [CODMUN],                                "                 
	cQuery += "	SA1.A1_MUN      [MUN],                                   "                 
	cQuery += "	SA1.A1_COD      [CODCLI],                                "                 
	cQuery += "	SUBSTRING(SA1.A1_NOME,1,60)     [NOMCLI],                "                 
	cQuery += "	SA1.A1_CGC      [CNPJ],                                  "                
	cQuery += "	SA1.A1_END      [ENDR],                                  "                   
	cQuery += "	SD1.D1_COD      [COD_PRODUTO],                           "                
	cQuery += "	SB1.B1_DESC     [PRODUTO],                               "
	cQuery += "	SD1.D1_ITEM     [ITEM],                                  "               
	cQuery += "	SB1.B1_CODBAR   [CODBARRAS],                             "                 
	cQuery += "	'NOMBRE PROVEEDOR' [PROVEEDOR],                          "                 
	cQuery += "	SA1.A1_SATIV1   [TPNEGOCIO],                             "                 
	cQuery += "	ATIVIDADE.X5_DESCRI  [NOMENEGOCIO],                      "                 
	cQuery += "	CASE WHEN SD1.D1_TIPO='D' THEN '1' ELSE '0' END [TIPOV], "                 
	cQuery += "	SD1.D1_QUANT [QUANTI],                                   "                 
	cQuery += "	SD1.D1_CUSTO [CUSTO],                                    "                
	cQuery += "	SD1.D1_TOTAL [VENDA]                                     "  
	cQuery += "     FROM                                                 "                      
	cQuery += "	"+RetSQLName('SD1')+" SD1 (NOLOCK)                       "   
	cQuery += "	INNER JOIN                                               "                      
	cQuery += "	"+RetSQLName('SF1')+" SF1 (NOLOCK)                       "                
	cQuery += "	ON SF1.F1_FILIAL = SD1.D1_FILIAL                         "                 
	cQuery += "	AND SF1.F1_DOC = SD1.D1_DOC                              "                 
	cQuery += "	AND SF1.F1_SERIE = SD1.D1_SERIE                          "                 
	cQuery += "	AND SF1.F1_FORNECE = SD1.D1_FORNECE                      "                 
	cQuery += "	AND SF1.F1_LOJA = SD1.D1_LOJA                            "                 
	cQuery += "	AND SF1.F1_DUPL != ' '                                   "                 
	cQuery += "	AND SF1.F1_TIPO IN ('D')                                 "                                        
	cQuery += "	AND SF1.D_E_L_E_T_ != '*'                                "              
	cQuery += "	INNER JOIN                                               "
	cQuery += " "+RetSQLName('SA1')+" SA1 (NOLOCK)                       "
	cQuery += " ON SA1.A1_COD = SD1.D1_FORNECE                           "
	cQuery += " AND SA1.A1_LOJA = SD1.D1_LOJA                            "
	cQuery += " AND SA1.D_E_L_E_T_ != '*'                                "              
	cQuery += "	INNER JOIN                                               "
	cQuery += " "+RetSQLName('SB1')+" SB1 (NOLOCK)                       "
	cQuery += " ON SB1.B1_COD = SD1.D1_COD                               "
	cQuery += " AND SB1.B1_GRUPO BETWEEN '"+AllTrim(MV_PAR03)+"'   AND '"+AllTrim(MV_PAR04)  +"' "
	cQuery += " AND SB1.D_E_L_E_T_ != '*'                                "
	cQuery += "	INNER JOIN                                               "
	cQuery += " "+RetSQLName('SBM')+" SBM (NOLOCK)                       "
	cQuery += " ON SB1.B1_GRUPO = SBM.BM_GRUPO                           "
	cQuery += " AND SBM.D_E_L_E_T_ != '*'                                "               
	cQuery += "	LEFT JOIN                                                "
	cQuery += "	"+RetSQLName('SA3')+" A3VEN (NOLOCK)                     "
	cQuery += "	ON A3VEN.A3_COD = SA1.A1_VEND                            "
	cQuery += "	AND A3VEN.D_E_L_E_T_ != '*'                              "               
	cQuery += "	LEFT JOIN                                                "
	cQuery += "	"+RetSQLName('SX5')+" REGIAO  (NOLOCK)                   "
	cQuery += "	ON REGIAO.X5_TABELA = 'A2'                               "
	cQuery += "	AND REGIAO.X5_CHAVE = A1_REGIAO                          "
	cQuery += "	AND REGIAO.D_E_L_E_T_ != '*'                             "              
	cQuery += "	LEFT JOIN                                                "
	cQuery += "	"+RetSQLName('SX5')+" ATIVIDADE (NOLOCK)                 "
	cQuery += "	ON ATIVIDADE.X5_TABELA = 'T3'                            "
	cQuery += "	AND ATIVIDADE.X5_CHAVE = A1_SATIV1                       "
	cQuery += "	AND ATIVIDADE.D_E_L_E_T_ != '*'                          "           
	cQuery += "	WHERE  SD1.D_E_L_E_T_ != '*'                             "
	cQuery += "	AND SD1.D1_FILIAL BETWEEN '      ' AND 'ZZZZZZ'          "                 
	cQuery += "	AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+  "'   AND '"+DTOS(MV_PAR02)    +"' "          

	cQuery += " ORDER BY                                                   "
	cQuery += "              EMISSAO,                                      "
	cQuery += "              NFISCAL,                                      "
	cQuery += "              ITEM DESC                                     "

	if Select('QRYSD2')<>0
		DBCloseArea('QRYSD2')
	EndIF

	nCnt:=0
	TcQuery cQuery New Alias 'QRYSD2'

	While !QRYSD2->(EOF())
		nCnt++
		QRYSD2->(DBSkip())
	EndDo

	QRYSD2->(dbGoTop())
	oProcess:SetRegua1(nCnt)
	oProcess:SetRegua2(0)

	// Consulta para preencher a tabela de Inventário -----------------------------------------------------------
	cQuery := "   	SELECT                                                                               "                                  
	cQuery += "   	B1_COD, B1_DESC, B1_UM, B1_GRUPO GRUPO, BM_DESC DESCGRP, B2_LOCAL,                   "
	cQuery += "     SUM(B2_QATU) SLDATU                                                                  "
	cQuery += "   	FROM                                                                				 "
	cQuery += "     "+RetSQLName('SB1')+" SB1                                           				 "
	cQuery += "   	INNER JOIN "+RetSQLName('SBM')+" SBM                                                 "
	cQuery += "     ON BM_GRUPO= B1_GRUPO AND SBM.D_E_L_E_T_=''                                          "  
	cQuery += "     INNER JOIN "+RetSQLName('SB2')+" SB2                                                 "
	cQuery += "     ON B2_COD = B1_COD AND SB2.D_E_L_E_T_=''                                             "
	cQuery += "   	WHERE B1_GRUPO BETWEEN '"+AllTrim(MV_PAR03)+"'   AND '"+AllTrim(MV_PAR04)  +"'       "
	cQuery += "   	AND SB1.D_E_L_E_T_=''                                                                "
	//cQuery += "     AND B1_COD IN ('FG781408PLAT')                                                     "
	cQuery += "     GROUP BY  B1_COD, B1_DESC, B1_UM, B1_GRUPO, BM_DESC, B2_LOCAL                        "
	cQuery += "     ORDER BY B1_COD                                                                      "

	if Select('QRYSB1')<>0
		DBCloseArea('QRYSB1')
	EndIF
	nCnt2:=0
	TcQuery cQuery New Alias 'QRYSB1'
	While !QRYSB1->(EOF())
		nCnt2++
		QRYSB1->(DBSkip())
	EndDo

	gxml('<?xml version="1.0"?>')
	gxml('<?mso-application progid="Excel.Sheet"?>')
	gxml('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"')
	gxml(' xmlns:o="urn:schemas-microsoft-com:office:office"')
	gxml(' xmlns:x="urn:schemas-microsoft-com:office:excel"')
	gxml(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"')
	gxml(' xmlns:html="http://www.w3.org/TR/REC-html40">')
	gxml(' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">')
	gxml('  <Author>Maria E</Author>')
	gxml('  <LastAuthor>João L</LastAuthor>')
	gxml('  <Created>2017-08-11T14:13:24Z</Created>')
	gxml('  <LastSaved>2019-11-07T14:29:47Z</LastSaved>')
	gxml('  <Version>16.00</Version>')
	gxml(' </DocumentProperties>')
	gxml(' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">')
	gxml('  <AllowPNG/>')
	gxml(' </OfficeDocumentSettings>')
	gxml(' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">')
	gxml('  <WindowHeight>7485</WindowHeight>')
	gxml('  <WindowWidth>20490</WindowWidth>')
	gxml('  <WindowTopX>32767</WindowTopX>')
	gxml('  <WindowTopY>32767</WindowTopY>')
	gxml('  <ActiveSheet>1</ActiveSheet>')
	gxml('  <ProtectStructure>False</ProtectStructure>')
	gxml('  <ProtectWindows>False</ProtectWindows>')
	gxml(' </ExcelWorkbook>')
	gxml(' <Styles>')
	gxml('  <Style ss:ID="Default" ss:Name="Normal">')
	gxml('   <Alignment ss:Vertical="Bottom"/>')
	gxml('   <Borders/>')
	gxml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
	gxml('   <Interior/>')
	gxml('   <NumberFormat/>')
	gxml('   <Protection/>')
	gxml('  </Style>')
	gxml('  <Style ss:ID="s62" ss:Name="Normal_Hoja1_1">')
	gxml('   <Alignment ss:Vertical="Bottom"/>')
	gxml('   <Borders/>')
	gxml('   <Font ss:FontName="Arial" x:Family="Swiss"/>')
	gxml('   <Interior/>')
	gxml('   <NumberFormat/>')
	gxml('   <Protection/>')
	gxml('  </Style>')
	gxml('  <Style ss:ID="s63">')
	gxml('   <NumberFormat ss:Format="0"/>')
	gxml('  </Style>')
	gxml('  <Style ss:ID="s65" ss:Parent="s62">')
	gxml('   <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>')
	gxml('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Color="#FFFFFF" ss:Bold="1"/>')
	gxml('   <Interior ss:Color="#003366" ss:Pattern="Solid"/>')
	gxml('   <NumberFormat ss:Format="@"/>')
	gxml('  </Style>')
	gxml('  <Style ss:ID="s66" ss:Parent="s62">')
	gxml('   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>')
	gxml('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Color="#FFFFFF" ss:Bold="1"/>')
	gxml('   <Interior ss:Color="#003366" ss:Pattern="Solid"/>')
	gxml('   <NumberFormat ss:Format="@"/>')
	gxml('  </Style>')
	gxml('  <Style ss:ID="s67" ss:Parent="s62">')
	gxml('   <Interior/>')
	gxml('   <NumberFormat ss:Format="@"/>')
	gxml('  </Style>')
	gxml(' </Styles>')
	gxml(' <Worksheet ss:Name="Ventas">')
	gxml('  <Table ss:ExpandedColumnCount="16142" ss:ExpandedRowCount="'+ cValToChar(nCnt + 02) +'" x:FullColumns="1"')
	gxml('   x:FullRows="1" ss:DefaultColumnWidth="108.75" ss:DefaultRowHeight="15">')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="6" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="10" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="14" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="16" ss:StyleID="s63" ss:AutoFitWidth="0" ss:Span="4"/>')
	gxml('   <Column ss:Index="257" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="262" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="266" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="270" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="513" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="518" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="522" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="526" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="769" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="774" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="778" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="782" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="1025" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="1030" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="1034" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="1038" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="1281" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="1286" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="1290" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="1294" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="1537" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="1542" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="1546" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="1550" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="1793" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="1798" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="1802" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="1806" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="2049" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="2054" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="2058" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="2062" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="2305" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="2310" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="2314" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="2318" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="2561" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="2566" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="2570" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="2574" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="2817" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="2822" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="2826" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="2830" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="3073" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="3078" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="3082" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="3086" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="3329" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="3334" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="3338" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="3342" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="3585" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="3590" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="3594" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="3598" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="3841" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="3846" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="3850" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="3854" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="4097" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="4102" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="4106" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="4110" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="4353" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="4358" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="4362" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="4366" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="4609" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="4614" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="4618" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="4622" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="4865" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="4870" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="4874" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="4878" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="5121" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="5126" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="5130" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="5134" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="5377" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="5382" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="5386" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="5390" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="5633" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="5638" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="5642" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="5646" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="5889" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="5894" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="5898" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="5902" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="6145" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="6150" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="6154" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="6158" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="6401" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="6406" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="6410" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="6414" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="6657" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="6662" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="6666" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="6670" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="6913" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="6918" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="6922" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="6926" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="7169" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="7174" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="7178" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="7182" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="7425" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="7430" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="7434" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="7438" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="7681" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="7686" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="7690" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="7694" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="7937" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="7942" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="7946" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="7950" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="8193" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="8198" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="8202" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="8206" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="8449" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="8454" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="8458" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="8462" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="8705" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="8710" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="8714" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="8718" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="8961" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="8966" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="8970" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="8974" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="9217" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="9222" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="9226" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="9230" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="9473" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="9478" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="9482" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="9486" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="9729" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="9734" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="9738" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="9742" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="9985" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="9990" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="9994" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="9998" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="10241" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="10246" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="10250" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="10254" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="10497" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="10502" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="10506" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="10510" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="10753" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="10758" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="10762" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="10766" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="11009" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="11014" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="11018" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="11022" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="11265" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="11270" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="11274" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="11278" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="11521" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="11526" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="11530" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="11534" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="11777" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="11782" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="11786" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="11790" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="12033" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="12038" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="12042" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="12046" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="12289" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="12294" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="12298" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="12302" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="12545" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="12550" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="12554" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="12558" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="12801" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="12806" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="12810" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="12814" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="13057" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="13062" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="13066" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="13070" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="13313" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="13318" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="13322" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="13326" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="13569" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="13574" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="13578" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="13582" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="13825" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="13830" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="13834" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="13838" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="14081" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="14086" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="14090" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="14094" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="14337" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="14342" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="14346" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="14350" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="14593" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="14598" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="14602" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="14606" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="14849" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="14854" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="14858" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="14862" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="15105" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="15110" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="15114" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="15118" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="15361" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="15366" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="15370" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="15374" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="15617" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="15622" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="15626" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="15630" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="15873" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="15878" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="15882" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="15886" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Column ss:Index="16129" ss:AutoFitWidth="0" ss:Width="62.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="86.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="66"/>')
	gxml('   <Column ss:Index="16134" ss:AutoFitWidth="0" ss:Width="70.5"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="80.25"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="49.5"/>')
	gxml('   <Column ss:Index="16138" ss:AutoFitWidth="0" ss:Width="66.75"/>')
	gxml('   <Column ss:Index="16142" ss:AutoFitWidth="0" ss:Width="90"/>')
	gxml('   <Row ss:AutoFitHeight="0" ss:Height="26.25">')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">NUMERO&#10;FACTURAS</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">FECHA VENTA</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">CODIGO VENDEDOR</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">NOMBRE VENDEDOR</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">CEDULA VENDEDOR</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">CODIGO DE MUNICIPIO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">NOMBRE DEL MUNICIPIO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">COD. CLIENTE</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">NOM.CLIENTE</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">NIT CLIENTE</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">DIRECCIÓN CLIENTE</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">CÓDIGO .PRODUCTO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">DESCRIPCIÓN. PRODUCTO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">CODIGO DE BARRA</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">NOMBRE PROVEEDOR</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">CODIGO TIPO NEGOCIO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">NOMBRE TIPO NEGOCIO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">TIPO (Venta=0)&#10;(Devolución=1)</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">CANTIDAD</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">COSTO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s65"><Data ss:Type="String">VALOR TOTAL VENTA</Data></Cell>')
	gxml('   </Row>')

	nIt:=0
	QRYSD2->(dbGoTop())
	oProcess:SetRegua1(nCnt)
	oProcess:SetRegua2(0)
	//alert (DTOS(MV_PAR01))
	While !QRYSD2->(EOF())

		nIt++
		oProcess:IncRegua1("Buscando registros...")
		oProcess:IncRegua2("Processando "+cValtoChar(nIt)+" de "+ cValtoChar(nCnt) )

		gxml('   <Row ss:AutoFitHeight="0">')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->NFISCAL+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->EMISSAO+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->COD_VEND+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->VENDEDOR+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->USRVEND+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->CODMUN+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->MUN+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->CODCLI+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->NOMCLI+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->CNPJ+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->ENDR+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->COD_PRODUTO+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->PRODUTO+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->CODBARRAS+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->PROVEEDOR+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->TPNEGOCIO+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+QRYSD2->NOMENEGOCIO+'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+cValtoChar(QRYSD2->TIPOV) +'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+ Transform(QRYSD2->QUANTI ,'@E 999,999.99') +'</Data></Cell>')
		gxml('    <Cell><Data ss:Type="String">'+ Transform (QRYSD2->CUSTO ,'@E 999,999.99') +'</Data></Cell>')
		gxml('    <Cell ss:StyleID="s63"><Data ss:Type="String">'+ Transform ( QRYSD2->VENDA ,'@E 999,999.99') +'</Data></Cell>')
		gxml('   </Row>')

		QRYSD2->(DBSkip())
	EndDo

	gxml('  </Table>')
	gxml('  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
	gxml('   <PageSetup>')
	gxml('    <Header x:Margin="0.3"/>')
	gxml('    <Footer x:Margin="0.3"/>')
	gxml('    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>')
	gxml('   </PageSetup>')
	gxml('   <Unsynced/>')
	gxml('   <LeftColumnVisible>13</LeftColumnVisible>')
	gxml('   <Panes>')
	gxml('    <Pane>')
	gxml('     <Number>3</Number>')
	gxml('     <ActiveRow>1</ActiveRow>')
	gxml('     <ActiveCol>21</ActiveCol>')
	gxml('    </Pane>')
	gxml('   </Panes>')
	gxml('   <ProtectObjects>False</ProtectObjects>')
	gxml('   <ProtectScenarios>False</ProtectScenarios>')
	gxml('  </WorksheetOptions>')
	gxml(' </Worksheet>')
	gxml(' <Worksheet ss:Name="Inventario">')
	gxml('  <Table ss:ExpandedColumnCount="16132" ss:ExpandedRowCount="'+ cValToChar(nCnt2 + 03) +'" x:FullColumns="1"')
	gxml('   x:FullRows="1" ss:DefaultColumnWidth="60" ss:DefaultRowHeight="15">')
	gxml('   <Column ss:Index="3" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="259" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="515" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="771" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="1027" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="1283" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="1539" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="1795" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="2051" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="2307" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="2563" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="2819" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="3075" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="3331" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="3587" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="3843" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="4099" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="4355" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="4611" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="4867" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="5123" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="5379" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="5635" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="5891" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="6147" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="6403" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="6659" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="6915" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="7171" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="7427" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="7683" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="7939" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="8195" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="8451" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="8707" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="8963" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="9219" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="9475" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="9731" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="9987" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="10243" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="10499" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="10755" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="11011" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="11267" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="11523" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="11779" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="12035" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="12291" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="12547" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="12803" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="13059" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="13315" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="13571" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="13827" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="14083" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="14339" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="14595" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="14851" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="15107" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="15363" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="15619" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="15875" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Column ss:Index="16131" ss:Width="168.75"/>')
	gxml('   <Column ss:AutoFitWidth="0" ss:Width="61.5"/>')
	gxml('   <Row ss:AutoFitHeight="0">')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">FECHA</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">CODIGO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">NOMBRE PRODUCTO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">CANTIDAD</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">UN MEDIDA</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">ARMAZEM</Data></Cell>')
	gxml('   </Row>')

	nIt:=0
	QRYSB1->(dbGoTop())
	oProcess:SetRegua1(nCnt2)
	oProcess:SetRegua2(0)

	While !QRYSB1->(EOF())

		nIt++
		oProcess:IncRegua1("Buscando registros...")
		oProcess:IncRegua2("Processando "+cValtoChar(nIt)+" de "+ cValtoChar(nCnt2) )

		//DbSelectArea("SB2")
		//DbSeek(QRYSB1->FILIAL + QRYSB1->B1_COD + QRYSB1->B2_LOCAL)

		//_aSaldo := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,(MV_PAR02)+1) // Array com o Saldo do Produto (Data de Referencia)
		_nQuant := QRYSB1->SLDATU

		If _nQuant <> 0  
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String"> '+ DTOS(MV_PAR02) +' </Data></Cell> ')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB1->B1_COD  +'  </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB1->B1_DESC +' </Data></Cell> ')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ transform(_nQuant,'@E 999,999.99') +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB1->B1_UM +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB1->B2_LOCAL +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"/>')
			gxml('   </Row>')
		EndIf 
		QRYSB1->(DBSkip())

	EndDo

	gxml('  </Table>')
	gxml('  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
	gxml('   <PageSetup>')
	gxml('    <Header x:Margin="0.3"/>')
	gxml('    <Footer x:Margin="0.3"/>')
	gxml('    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>')
	gxml('   </PageSetup>')
	gxml('   <Unsynced/>')
	gxml('   <Selected/>')
	gxml('   <Panes>')
	gxml('    <Pane>')
	gxml('     <Number>3</Number>')
	gxml('     <ActiveRow>1</ActiveRow>')
	gxml('     <ActiveCol>5</ActiveCol>')
	gxml('    </Pane>')
	gxml('   </Panes>')
	gxml('   <ProtectObjects>False</ProtectObjects>')
	gxml('   <ProtectScenarios>False</ProtectScenarios>')
	gxml('  </WorksheetOptions>')
	gxml(' </Worksheet>')
	gxml('</Workbook>')



	FCLOSE(NHANDLE)

	//--COPIA PARA O TEMP
	CPYS2T(CDIRDOCS+"\"+CARQUIVO+".XML",CPATH,.T.)

	//--ABRE O XML NO EXCEL
	OEXCELAPP := MSEXCEL():NEW()
	OEXCELAPP:WORKBOOKS:OPEN( CPATH+CARQUIVO+".XML" )
	OEXCELAPP:SETVISIBLE(.T.)
	OEXCELAPP:DESTROY()

	RestArea(aArea)

Return

STATIC FUNCTION GXML(CTEXTO)

	FWRITE(NHANDLE,FwNoAccent(CTEXTO)+CHR(13)+CHR(10))
RETURN

/*/{Protheus.doc} CriaSx1
-----------------------------------------------------------------------------------------------------------------------------
Função CriaSX1
@author A
@since 11/04/2019
@version 1.0
@example
u_CriaSx1()
-----------------------------------------------------------------------------------------------------------------------------
/*/

Static Function CriaSx1(cPerg)
	xPutSx1(cPerg,"01","da Data ?    ","","","mv_ch1","D",08,0,0,"G",""," "," ","","        ","   ",""," ","","   ","","","","","","","","","","","","","","","","","","","","","","")
	xPutSx1(cPerg,"02","Até Data?    ","","","mv_ch2","D",08,0,0,"G",""," "," ","","        ","   ",""," ","","   ","","","","","","","","","","","","","","","","","","","","","","")
	xPutSx1(cPerg,"03","do Grupo?    ","","","mv_ch3","C",04,0,0,"G",""," "," ","","        ","   ",""," ","","   ","","","","","","","","","","","","","","","","","SBM","","","","","")
	xPutSx1(cPerg,"04","Até o Grupo? ","","","mv_ch4","C",04,0,0,"G",""," "," ","","        ","   ",""," ","","   ","","","","","","","","","","","","","","","","","SBM","","","","","")

Return 

/*/{Protheus.doc} xPutSx1
-----------------------------------------------------------------------------------------------------------------------------
Função xPutSx1
@author A
@since 07/11/2019
@version 1.0
@example
u_xPutSx1()
-----------------------------------------------------------------------------------------------------------------------------
/*/

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,;
	cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,;
	cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,	aHelpPor,aHelpEng,aHelpSpa,cHelp)

	Local aArea  := GetArea()
	Local cKey
	Local lPort  := .f.
	Local lSpa   := .f.
	Local lIngl  := .f.

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme := Iif( cPyme == Nil, " ", cPyme )
	cF3 := Iif( cF3 == NIl, " ", cF3 )
	cGrpSxg := Iif( cGrpSxg == Nil, " ", cGrpSxg )
	cCnt01 := Iif( cCnt01 == Nil, "" , cCnt01 )
	cHelp := Iif( cHelp == Nil, "" , cHelp )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa  := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng  := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

//		Reclock( "SX1" , .T. )

//		Replace X1_GRUPO   With cGrupo
//		Replace X1_ORDEM   With cOrdem
//		Replace X1_PERGUNT With cPergunt
//		Replace X1_PERSPA  With cPerSpa
//		Replace X1_PERENG  With cPerEng
//		Replace X1_VARIAVL With cVar
//		Replace X1_TIPO    With cTipo
//		Replace X1_TAMANHO With nTamanho
//		Replace X1_DECIMAL With nDecimal
//		Replace X1_PRESEL  With nPresel
//		Replace X1_GSC     With cGSC
//		Replace X1_VALID   With cValid

//		Replace X1_VAR01 With cVar01

//		Replace X1_F3 With cF3
//		Replace X1_GRPSXG With cGrpSxg

//		If Fieldpos("X1_PYME") > 0
//			If cPyme != Nil
//				Replace X1_PYME With cPyme
//			Endif
//		Endif

//		Replace X1_CNT01       With cCnt01
//		If cGSC == "C" // Mult Escolha
//			Replace X1_DEF01   With cDef01
//			Replace X1_DEFSPA1 With cDefSpa1
//			Replace X1_DEFENG1 With cDefEng1

//			Replace X1_DEF02   With cDef02
//			Replace X1_DEFSPA2 With cDefSpa2
//			Replace X1_DEFENG2 With cDefEng2

//			Replace X1_DEF03   With cDef03
//			Replace X1_DEFSPA3 With cDefSpa3
//			Replace X1_DEFENG3 With cDefEng3
//
//			Replace X1_DEF04   With cDef04
//			Replace X1_DEFSPA4 With cDefSpa4
//			Replace X1_DEFENG4 With cDefEng4

//			Replace X1_DEF05   With cDef05
//			Replace X1_DEFSPA5 With cDefSpa5
//			Replace X1_DEFENG5 With cDefEng5
//		Endif

//		Replace X1_HELP With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

//		If lPort .Or. lSpa .Or. lIngl
//			RecLock("SX1",.F.)
//			If lPort
//				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
//			EndIf
//			If lSpa
//				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
//			EndIf
//			If lIngl
//				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
//			EndIf
//			SX1->(MsUnLock())
//		EndIf
	Endif

	RestArea( aArea )

	Return

return
