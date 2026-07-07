
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

User Function RGSV001()
Local 		_cHour
Local 		_cMin
Local 		_cSecs
Local 		aParamBox 	:= {}
Local 		aTPImp		:= {"EXCEL","PDF"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private		_cTimeF
Private 	aSelFil		:={}
Private 	cCRLF		:= CRLF
Private 	cAlias
Private 	_cPerg1
Private 	_cPerg2
Private 	_cPerg3
Private 	_cPerg4
Private 	_cPerg5
Private 	_cPerg6
Private 	_cPerg7
Private 	nRegs		:= 0
Private		nCount		:= 0
Private 	oPrn

_cTime := Time() // Resultado: 10:37:17
_cHour := SubStr( _cTime, 1, 2 ) // Resultado: 10
_cMin  := SubStr( _cTime, 4, 2 ) // Resultado: 37
_cSecs := SubStr( _cTime, 7, 2 ) // Resultado: 17
_cTimeF	:=_cHour+_cMin+_cSecs

    AAdd(aParamBox, { 1,"Filial de?"		    ,Space(06),"","","SM0","",0,.F.}) // Tipo caractere
    AAdd(aParamBox, { 1,"Filial até?"		    ,Space(06),"","","SM0","",0,.F.}) // Tipo caractere

	aAdd(aParamBox, { 1,"DT de Enc de?"  	    ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
    aAdd(aParamBox, { 1,"DT de Enc até?"        ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
    
    AAdd(aParamBox, { 1,"Num OS até?"		    ,Space(06),"","","","",0,.F.}) // Tipo caractere
    AAdd(aParamBox, { 1,"Num OS de?"		    ,Space(06),"","","","",0,.F.}) // Tipo caractere

    AAdd(aParamBox,	{ 2,"Tipo de impressão?"    ,1,aTPImp	,50,"",.T.})

If ParamBox(aParamBox,"REL. ORDEM DE SERVICO", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas
        TrataPer()
    Else 

Endif
Return()

//Valida as perguntas
Static Function TrataPer()
_cPerg1	:= MV_PAR01
_cPerg2	:= MV_PAR02
_cPerg3	:= MV_PAR03
_cPerg4	:= MV_PAR04
_cPerg5	:= MV_PAR05
_cPerg6	:= MV_PAR06
_cPerg7	:= MV_PAR07

If !ValType(_cPerg7) == "N"
    If _cPerg7 == "EXCEL"
            _cPerg7 := 1 //PDF 
        Else
            _cPerg7 := 2 
    EndiF
EndIf

If _cPerg7	== 1
        Processa({||ImpExc()} ,"Processando Ordem de Servico","Aguarde...") 
	Else
		Processa({||ImpPdf()} ,"Processando Ordem de Servico","Aguarde...") 
EndIf

Return()

//Busca OS
Static Function BusOS()
Local cSql		:= ""

cAlias	:= GetNextAlias()

cSql += " SELECT	AB6.AB6_XDATEF,AB6.AB6_XHOREF,AB6_STATUS, "+cCRLF
cSql += " 		SA1.A1_NOME,SA1.A1_CGC, "+cCRLF
cSql += " 		AB6.*	  "+cCRLF
cSql += " FROM "+ RetSqlName("AB6") +" AB6 "+cCRLF
cSql += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON SA1.A1_COD = AB6.AB6_CODCLI AND SA1.A1_LOJA = AB6.AB6_LOJA AND SA1.D_E_L_E_T_ = '' "+cCRLF
cSql += " WHERE AB6.D_E_L_E_T_ = '' "+cCRLF
cSql += " AND AB6.AB6_FILIAL	>= '"+ Alltrim(_cPerg1) +"' "+cCRLF
cSql += " AND AB6.AB6_FILIAL	<= '"+ Alltrim(_cPerg2) +"' "+cCRLF
cSql += " AND AB6.AB6_XDATEF	>= '"+ DTOS(_cPerg3) +"' "+cCRLF
cSql += " AND AB6.AB6_XDATEF	<= '"+ DTOS(_cPerg4) +"' "+cCRLF
cSql += " AND AB6.AB6_NUMOS	    >= '"+ Alltrim(_cPerg5)  +"' "+cCRLF
cSql += " AND AB6.AB6_NUMOS	    <= '"+ Alltrim(_cPerg6) +"' "+cCRLF

Conout("")
Conout(cSql)
Conout("")

TCQuery cSql New Alias (cAlias)
Count To nRegs

DBSelectArea((cAlias))
(cAlias)->(DBGoTop())

Return((cAlias)->(EOF()))

//Imprime em PDF
Static Function ImpPdf()

If BusOS()
    (cAlias)->(DbCloseArea())
    MsgAlert("Não existem dados!")
    Return
EndIf 

oPrn := FWMSPrinter():New('cAlias_'+ DTOS(DATE()) + _cTimeF +'.rel', IMP_PDF ,.F.,'\Spool\',.T.) //Instancia a Classe, Gerar pdf por default, Não recalcula coordenadas,Diretorio padrao onde o arq sera salvo, deixa a cargo do programador quando será chamada a tela de setup
oPrn:SetPortrait()				//Define o relatorio como retrato
oPrn:SetPaperSize(9)			//programado para folha A4
oPrn:SetMargin(10,10,10,10)		//Margem do relatorio
oPrn:cPathPDF := "C:\Temp"		//Path do arquivo PDF
oPrn:Setup()					//apresenta a janela de configuracao de impressoras

If oPrn:nModalResult == PD_OK
		GerPdfOS()
		oPrn:Preview()		//preview
				
	Else
		oPrn:Cancel()
		If oPrn:Canceled()
			//Return .T.
		Endif
EndIf

(cAlias)->(DbCloseArea())
Return()

//Imprime em Excel
Static Function ImpExc()

If BusOS()
		MsgAlert("Não existem dados! Verifique os parametros!!")
        (cAlias)->(DbCloseArea())
		Return
		
	Else
		IMPExcel()
EndIf

Return()


Static Function IMPExcel()
Local 	oExcel
Local 	oExcelApp
Local 	cDir    	:= "C:\TEMP\"
Local 	cArq    	:= "Rel OS Sentax_"+_cTimeF+".xml"
Local 	nLinha		:= 1
Local 	_cCad		:= "Gerar XML"
Local 	_cDirTmp 	:= "C:\TEMP\"
Local 	_cDir 		:= GetSrvProfString("Startpath","")
Local nTPSLD		:= 0
Local nCount			:= 0
Local aArea			:= SM0->(GetArea())
Local cDirDocs		:= MsDocPath()
Local nQtdD         := 0

Private nSaldo		:= 0

_cDirTmp := ALLTRIM(cGetFile("Salvar em?|*|",'Salvar em?', 0,'C:\TEMP\', .T., GETF_OVERWRITEPROMPT + GETF_LOCALHARD + GETF_RETDIRECTORY,.T.))


oExcel := FWMsExcel():New()		//Instancia a classe

oExcel:AddworkSheet("RELATORIO OS")				                        //Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable ("RELATORIO OS","ORDEM DE SERVICO")		                //Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","FILIAL"			,1,1)

oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","COD CLI"	    ,1,1)
oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","LOJA"		    ,1,1)
oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","NOME" 	        ,1,1)

oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","DT ABERT OS"	,2,4)
oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","DT FECHA OS"	,2,4)
oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","QTD DE DIAS"	,2,1)

//oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","SLD APLICAÇÃO"	,1,3) //( 1-Left,2-Center,3-Right )
//oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","SLD CONTÁBIL"	,3,3)
//oExcel:AddColumn("RELATORIO OS","ORDEM DE SERVICO","DIFERENÇA"		,3,3) //Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )

oExcel:SetFont('Arial')
oExcel:SetFontSize(10)
oExcel:SetTitleBold(.T.)
//oExcel:SetTitleSizeFont(16)
oExcel:SetHeaderBold(.T.)
//oExcel:SetHeaderSizeFont(14)
oExcel:SetBold(.T.)

ProcRegua(nRegs)
While !(cAlias)->(EOF())
	
	oExcel:SetLineBold(.F.)
	oExcel:Set2LineBold(.F.)	
			
	nCount++
	IncProc('Processando Ordem de Servico - Aguarde!  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
    nQtdD := STOD((Alltrim( (cAlias)->AB6_XDATEF ))) - STOD((Alltrim( (cAlias)->AB6_EMISSA )))

    nQtdD := CValToChar(nQtdD)
	oExcel:AddRow("RELATORIO OS","ORDEM DE SERVICO",{   Alltrim( (cAlias)->AB6_FILIAL )     ,;
														Alltrim( (cAlias)->AB6_CODCLI )     ,;
														Alltrim( (cAlias)->AB6_LOJA   )     ,;
														Alltrim( (cAlias)->A1_NOME    )     ,;
														DTOC(STOD((Alltrim( (cAlias)->AB6_EMISSA ))))  ,;
														DTOC(STOD((Alltrim( (cAlias)->AB6_XDATEF )))) ,; 
                                                        nQtdD})
	
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

oExcel:Activate() 				//Habilita o uso da classe, indicando que esta configurada e pronto para uso
	
LjMsgRun( "Gerando o arquivo, aguarde...", _cCad, {|| oExcel:GetXMLFile( cArq ) } )//Cria um arquivo no formato XML do MSExcel 2003 em diante 

//oExcel:GetXMLFile(cDirDocs+"\"+cArq) //Arquivo teste.xml gerado com sucesso no \system\

If __CopyFile( cArq, _cDirTmp + cArq )
		
		If ! ApOleClient( 'MsExcel' ) 
			MsgAlert("MsExcel nao instalado!!!") //'MsExcel nao instalado'
			RestArea(aArea)	
			Return
		EndIf
		
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( _cDirTmp + cArq )
		oExcelApp:SetVisible(.T.)
        

	Else
		MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretório " + _cDir )
		MsgInfo( "Arquivo não copiado para temporário do usuário." )
Endif

RestArea(aArea)	    
Return()

//
Static Function GerPdfOS()
Local aPosiIm	    := {}
Local nCol2		    := 0580
Local nCount		:= 0
Local _nF           := 1

/*fontes*/
Private	oFont05
Private oFont05n
Private oFont06
Private oFont06n
Private oFont07
Private oFont07n
Private oFont08
Private oFont08n
Private oFont09
Private oFont09n
Private oFont10
Private oFont10n
Private oFont11
Private oFont11n
Private oFont12
Private oFont12n
Private oFont13
Private oFont13n
Private oFont14
Private oFont14n
Private oFont15
Private oFont15n
Private oFont16
Private oFont16n
Private oFont17
Private oFont17n
Private oFont18
Private oFont18n
Private nPag		:= 1
Private nLin		:= 0020

NFonte(_nF)			//carrega as fontes

oPrn:StartPage()
oPrn:Box(010,040,785,580)
aPosiIm	:= Cabec()

ProcRegua(nRegs)	
While !(cAlias)->(EOF())   
    nCount++
	IncProc('Processando Movimentos - Aguarde!  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )

    nQtdD := STOD((Alltrim( (cAlias)->AB6_XDATEF ))) - STOD((Alltrim( (cAlias)->AB6_EMISSA )))

    nQtdD := CValToChar(nQtdD)

    oPrn:SayAlign (nLin += 10	, aPosiIm[1]	, Alltrim((cAlias)->AB6_FILIAL)					, oFont06,nCol2,,,0,)
    oPrn:SayAlign (nLin     	, aPosiIm[2]	, Alltrim((cAlias)->AB6_CODCLI)					, oFont06,nCol2,,,0,)
    oPrn:SayAlign (nLin     	, aPosiIm[3]	, Alltrim((cAlias)->AB6_LOJA)					, oFont06,nCol2,,,0,)
    oPrn:SayAlign (nLin     	, aPosiIm[4]	, Alltrim((cAlias)->A1_NOME)					, oFont06,nCol2,,,0,)
    oPrn:SayAlign (nLin     	, aPosiIm[5]	, DTOC(STOD((Alltrim( (cAlias)->AB6_EMISSA ))))	, oFont06,nCol2,,,0,)
    oPrn:SayAlign (nLin     	, aPosiIm[6]	, DTOC(STOD((Alltrim( (cAlias)->AB6_XDATEF ))))	, oFont06,nCol2,,,0,)
    oPrn:SayAlign (nLin     	, aPosiIm[7]	, nQtdD					                        , oFont06,nCol2,,,0,)

    If nLin > 765
		nPag++					//Caso o numero de linha maior que 690 pula para próxima pagina
		oPrn:EndPage()			//Fecha a pagina
		oPrn:StartPage()		//Inicia a outra pagina
		nLin		:= 0020
		oPrn:Box(010,040,785,580)
		aPosiIm := Cabec()
	EndIf

    (cAlias)->(DbSkip())
EndDo 

Return()


//IMPRIME O CABEÇALHO PRINCIPAL
Static Function Cabec()
Local nCol1		:= 0590
Local nCol2		:= nCol1 - 10
Local nCol3		:= nCol2 -32
Local cNomFil	:= FWFilialName("01",cFilAnt)
Local nLinOri	:= 0
Local nCol4		:= 0050
Local aPosiIm	:= {}

cLogotipo := "lgrl000.bmp"
//oPrn:SayBitMap( nLin, 0040, cLogotipo, 104, 40)

oPrn:say( nLin, nCol3				, "Pág.: " + Alltrim(Transform(nPag,'@R 999999'))					, oFont06,1400,, 		)
nLinOri	:= nLin
oPrn:say( nLin += 10, nCol3 -= 28	, DTOC(Date()) + " - " + Time()							, oFont06,1400,,		)//-47

nLin	:= nLinOri + 0005

oPrn:SayAlign (nLin, 0000	, Alltrim(cNomFil) , oFont06n,nCol2,,,2,) 		

oPrn:SayAlign (nLin += 12, 0000	, "RELATÓRIO DE ORDENS DE SERVIÇO", oFont06,nCol2,,,2,)

oPrn:line(nLin += 15, 0040, nLin, nCol2)

oPrn:line(nLin += 02, 0040, nLin, nCol2 )

oPrn:SayAlign (nLin += 05	, nCol4			, "FILIAL" 			, oFont06,nCol2 += 25 ,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 30	, "COD CLI" 	    , oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 30	, "LOJA" 		    , oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 30	, "NOME"	        , oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 300	, "DT ABERT OS" 	, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 50	, "DT FECHA OS" 	, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 50	, "QTD DE DIAS" 	, oFont06,nCol2,,,0,)
aAdd(aPosiIm,(nCol4 + 20) )

oPrn:line(nLin += 10, 0040, nLin, nCol2 -= 25)

nLin -= 05

Return(aPosiIm)


Static Function NFonte(_nF)
Private	_nFonte	:= _nF

If 	_nFonte == 1
		oFont05 	:= TFont():New("Arial"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Arial"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Arial"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Arial"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Arial"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Arial"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Arial"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Arial"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Arial"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Arial"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Arial"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Arial"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Arial"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Arial"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Arial"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Arial"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Arial"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Arial"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Arial"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Arial"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Arial"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Arial"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Arial"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Arial"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Arial"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Arial"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 2
		oFont05 	:= TFont():New("Times New Roman"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Times New Roman"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Times New Roman"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Times New Roman"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Times New Roman"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Times New Roman"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Times New Roman"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Times New Roman"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Times New Roman"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Times New Roman"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Times New Roman"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Times New Roman"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Times New Roman"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Times New Roman"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Times New Roman"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Times New Roman"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Times New Roman"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Times New Roman"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Times New Roman"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Times New Roman"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Times New Roman"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Times New Roman"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Times New Roman"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Times New Roman"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Times New Roman"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Times New Roman"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 3
		oFont05 	:= TFont():New("Calibri"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Calibri"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Calibri"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Calibri"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Calibri"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Calibri"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Calibri"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Calibri"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Calibri"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Calibri"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Calibri"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Calibri"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Calibri"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Calibri"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Calibri"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Calibri"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Calibri"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Calibri"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Calibri"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Calibri"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Calibri"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Calibri"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Calibri"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Calibri"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Calibri"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Calibri"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 4
		oFont05 	:= TFont():New("Verdana"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Verdana"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Verdana"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Verdana"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Verdana"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Verdana"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Verdana"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Verdana"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Verdana"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Verdana"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Verdana"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Verdana"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Verdana"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Verdana"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Verdana"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Verdana"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Verdana"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Verdana"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Verdana"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Verdana"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Verdana"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Verdana"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Verdana"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Verdana"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Verdana"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Verdana"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 5
		oFont05 	:= TFont():New("Tahoma"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Tahoma"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Tahoma"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Tahoma"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Tahoma"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Tahoma"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Tahoma"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Tahoma"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Tahoma"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Tahoma"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Tahoma"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Tahoma"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Tahoma"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Tahoma"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Tahoma"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Tahoma"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Tahoma"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Tahoma"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Tahoma"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Tahoma"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Tahoma"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Tahoma"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Tahoma"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Tahoma"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Tahoma"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Tahoma"			,18,18,,.T.,,,,.T.,.F.)

	Else
		oFont05 	:= TFont():New("Courier New"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Courier New"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Courier New"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Courier New"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Courier New"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Courier New"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Courier New"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Courier New"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Courier New"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Courier New"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Courier New"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Courier New"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Courier New"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Courier New"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Courier New"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Courier New"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Courier New"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Courier New"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Courier New"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Courier New"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Courier New"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Courier New"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Courier New"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Courier New"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Courier New"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Courier New"			,18,18,,.T.,,,,.T.,.F.)

EndIf

Return()
