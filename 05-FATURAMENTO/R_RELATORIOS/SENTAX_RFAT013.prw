//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#include 'parmtype.ch'

//Constantes
//#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} RFAT013
Rubbermaid 
Gerar XML com dados de vendas para montar modelo
de Plantilla información mínima TSOL- GENERAL 
@author João AFSouza
@since 07/11/2019
@version 1.0
@example u_RFAT013 ()
/*/

User Function RFAT013()

	PRIVATE _cCompCode := ""
	PRIVATE _aAreaDep := {}  // Areas depreciaveis.
	PRIVATE _cAreaDep := ""  // area de depreciação.
	PRIVATE _cDescDep := ""  // Descricao area de depreciação.
	PRIVATE nI  
	PRIVATE nCnt       := 0

	PRIVATE cPerg   := 'RFAT13'
	PRIVATE aArea     := GetArea()

	PRIVATE NHANDLE   

	PRIVATE	_aSaldo := {}
	PRIVATE	_nQuant := 0
	PRIVATE _nQtdeT := 0
	PRIVATE _cProd   := ""

	//CriaSx1(cPerg)

	Pergunte(cPerg,.T.)

	IF !APOLECLIENT('MSEXCEL')
		AVISO("MSEXCEL","NECESSARIO QUE O MS EXCEL ESTEJA INSTALADO.",{"OK"},1)
	ENDIF
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

	Private NHANDLE
	Private ACAB:={}
	NHANDLE := MSFCREATE(CDIRDOCS+"\"+CARQUIVO+".XML",0)

	If Select('QRYSB2')<>0
		DBCloseArea('QRYSB2')
	EndIf

	// Consulta para preencher a tabela de Inventário -----------------------------------------------------------
	cQuery := "   	SELECT                                                                               "                                  
	cQuery += "   	B1_COD, B1_DESC, B1_UM, B1_GRUPO GRUPO, BM_DESC DESCGRP, B2_LOCAL,                   "
	cQuery += "     SUM(B2_QATU) SLDATU, ROUND(SUM(B2_VATU1/B2_QATU),4) UNIT, SUM(B2_VATU1) VATU1        "
	cQuery += "   	FROM                                                                				 "
	cQuery += "     "+RetSQLName('SB1')+" SB1                                           				 "
	cQuery += "   	INNER JOIN "+RetSQLName('SBM')+" SBM                                                 "
	cQuery += "     ON BM_GRUPO= B1_GRUPO AND SBM.D_E_L_E_T_=''                                          "  
	cQuery += "     INNER JOIN "+RetSQLName('SB2')+" SB2                                                 "
	cQuery += "     ON B2_COD = B1_COD AND SB2.D_E_L_E_T_=''                                             "
	cQuery += "   	WHERE B1_GRUPO BETWEEN '"+AllTrim(MV_PAR01)+"'   AND '"+AllTrim(MV_PAR02)  +"'       "
	cQuery += "   	AND SB1.D_E_L_E_T_=''                                                                "
	//cQuery += "     AND B1_COD IN ('FG781408PLAT')                                                     "
	cQuery += "     GROUP BY  B1_COD, B1_DESC, B1_UM, B1_GRUPO, BM_DESC, B2_LOCAL                        "
	cQuery += "     ORDER BY B1_COD                                                                      "

	// Mostra query
	//Aviso("Query",cQuery,{"Ok"},3,,,,.T.)
	nCnt:=0
	
	TcQuery cQuery New Alias 'QRYSB2'
	While !QRYSB2->(EOF())
		nCnt++
		QRYSB2->(DBSkip())
	EndDo
	QRYSB2->(dbGoTop())
	oProcess:SetRegua1(nCnt)
	oProcess:SetRegua2(0)


	gxml('<?xml version="1.0"?> ')
	gxml('<?mso-application progid="Excel.Sheet"?> ')
	gxml('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" ')
	gxml(' xmlns:o="urn:schemas-microsoft-com:office:office" ')
	gxml(' xmlns:x="urn:schemas-microsoft-com:office:excel" ')
	gxml(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" ')
	gxml(' xmlns:html="http://www.w3.org/TR/REC-html40"> ')
	gxml(' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office"> ')
	gxml('  <Author>Maria E</Author> ')
	gxml('  <LastAuthor>João L</LastAuthor> ')
	gxml('  <Created>2017-08-11T14:13:24Z</Created> ')
	gxml('  <LastSaved>2019-11-07T14:29:47Z</LastSaved> ')
	gxml('  <Version>16.00</Version> ')
	gxml(' </DocumentProperties> ')
	gxml(' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office"> ')
	gxml('  <AllowPNG/> ')
	gxml(' </OfficeDocumentSettings> ')
	gxml(' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel"> ')
	gxml('  <WindowHeight>6705</WindowHeight> ')
	gxml('  <WindowWidth>15345</WindowWidth> ')
	gxml('  <WindowTopX>32767</WindowTopX> ')
	gxml('  <WindowTopY>32767</WindowTopY> ')
	gxml('  <ProtectStructure>False</ProtectStructure> ')
	gxml('  <ProtectWindows>False</ProtectWindows> ')
	gxml(' </ExcelWorkbook> ')
	gxml(' <Styles> ')
	gxml('  <Style ss:ID="Default" ss:Name="Normal"> ')
	gxml('   <Alignment ss:Vertical="Bottom"/> ')
	gxml('   <Borders/> ')
	gxml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/> ')
	gxml('   <Interior/> ')
	gxml('   <NumberFormat/> ')
	gxml('   <Protection/> ')
	gxml('  </Style> ')
	gxml('  <Style ss:ID="s62" ss:Name="Normal_Hoja1_1"> ')
	gxml('   <Alignment ss:Vertical="Bottom"/> ')
	gxml('   <Borders/> ')
	gxml('   <Font ss:FontName="Arial" x:Family="Swiss"/> ')
	gxml('   <Interior/> ')
	gxml('   <NumberFormat/> ')
	gxml('   <Protection/>')
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
	gxml(' <Worksheet ss:Name="Inventario">')
	gxml('  <Table ss:ExpandedColumnCount="11" ss:ExpandedRowCount="'+ cValToChar(nCnt + 39) +'" x:FullColumns="1"')
	gxml('   x:FullRows="1" ss:DefaultColumnWidth="54" ss:DefaultRowHeight="15">')
	gxml('   <Column ss:Width="53.25"/>')
	gxml('   <Column ss:Width="134.25"/>')
	gxml('   <Column ss:Width="280.5"/>')
	gxml('   <Column ss:Width="36"/>')
	gxml('   <Column ss:Width="40.5"/>')
	gxml('   <Column ss:Width="102"/>')
	gxml('   <Column ss:Width="69"/>')
	gxml('   <Column ss:Width="64.5"/>')
	gxml('   <Column ss:Width="75"/>')
	gxml('   <Column ss:Width="53.25"/>')
	gxml('   <Row ss:AutoFitHeight="0">')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">DATA</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">CODIGO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">NOME PRODUTO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">U.MED</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">GRUPO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">DESCRICAO GRUPO</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">QUANTIDADE </Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">CUSTO UNIT</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">CUSTO TOTAL</Data></Cell>')
	gxml('    <Cell ss:StyleID="s66"><Data ss:Type="String">ARMAZEM</Data></Cell>')
	gxml('   </Row>')

	
	nIt:=0
	QRYSB2->(dbGoTop())
	oProcess:SetRegua1(nCnt)
	oProcess:SetRegua2(0)

	While !QRYSB2->(EOF())

		nIt++
		oProcess:IncRegua1("Buscando registros...")
		oProcess:IncRegua2("Processando "+cValtoChar(nIt)+" de "+ cValtoChar(nCnt) )

		//_aSaldo := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,(MV_PAR02)+1) // Array com o Saldo do Produto (Data de Referencia)
		_nQuant  := QRYSB2->SLDATU
		dDataSld := Date()

		If _nQuant <> 0 
		 
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ DTOS(dDataSld) +'  </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB2->B1_COD  +'  </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB2->B1_DESC +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB2->B1_UM +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB2->GRUPO +'  </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB2->DESCGRP +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ transform(_nQuant,'@E 999,999.99') +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ transform(QRYSB2->UNIT,'@E 999,999.99') +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ transform(QRYSB2->VATU1,'@E 999,999.99') +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"><Data ss:Type="String">'+ QRYSB2->B2_LOCAL +' </Data></Cell>')
			gxml('    <Cell ss:StyleID="s67"/>')
			gxml('   </Row>')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>                    ')
			gxml('   <Row ss:AutoFitHeight="0">')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('    <Cell ss:StyleID="s67"/> ')
			gxml('   </Row>')       

		EndIf 
		QRYSB2->(DBSkip())
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
	gxml('     <ActiveRow>2</ActiveRow>')
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
	
	xPutSx1(cPerg,"01","Grupo de ?    ","","","mv_ch1","C",04,0,0,"G",""," "," ","","        ","   ",""," ","","   ","","","","","","","","","","","","","","","","","SBM","","","","","")
	xPutSx1(cPerg,"02","Grupo Até ?   ","","","mv_ch2","C",04,0,0,"G",""," "," ","","        ","   ",""," ","","   ","","","","","","","","","","","","","","","","","SBM","","","","","")

Return 

/*/{Protheus.doc} xPutSx1
-----------------------------------------------------------------------------------------------------------------------------
Função xPutSx1
@author A
@since 18/02/2020
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