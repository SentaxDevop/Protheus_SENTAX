#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} MFAT003
Indicadores MRP
@author	Anderson Roberto Franco de Souza
@since		26/12/2013
@version	P11 R1
@return	NIL
*/
//-------------------------------------------------------------------
User Function REST001()
Local oReport

Private cPerg := padr("REST001",10)


CriaSx1()
if !Pergunte(cPerg,.T.)
	return .F.
EndIf

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
+------------+------------------------------------------------------------+
! Descricao  ! Rotina para criar a estrutura do relatorio Analítico       !
+------------+------------------------------------------------------------+
! Sintaxe    ! ReportDef()                                               !
+------------+------------------------------------------------------------+
! Parametros ! Nenhum                                                     !
+------------+------------------------------------------------------------+
*/
Static Function ReportDef()
Local cTitle	:= OemToAnsi ("Relação de produtos e indicadores MRP.")
Local cHelp		:= OemToAnsi ("Permite imprimir produtos com os indicadores MRP.")
Local oReport

Local oSection
Local oPreNFi

Local oQtitulo
Local cAlias  	:= getNextAlias()
Local oSection

oReport	:= TReport():New("REST001",cTitle,""      ,{|oReport| RepPrint(oReport)},cHelp)
oReport:SetPortrait()

//Section do cabeçalho do relatório  que contem dados do cabçalho da nota
//SBZ.BZ_FILIAL,SB1.B1_COD,SB1.B1_DESC,SBZ.BZ_EMIN,SBZ.BZ_ESTSEG,SBZ.BZ_TIPE,SBZ.BZ_PE,SBZ.BZ_LE,SBZ.BZ_LM
oSection  := TRSection():New(oReport,"Produto com indicadores MRP",{"SB1"})
TRCell():New(oSection,"BZ_FILIAL","SBZ","Filial"	,PesqPict("SBZ","BZ_FILIAL") ,TamSx3("BZ_FILIAL")[1]+1 )
TRCell():New(oSection,"B1_GRUPO","SBZ","Grupo"	   ,PesqPict("SB1","B1_GRUPO") ,TamSx3("B1_GRUPO")[1]+1 )
TRCell():New(oSection,"BM_DESC","SBM","Desc Grupo"	   ,PesqPict("SB1","B1_GRUPO") ,TamSx3("B1_GRUPO")[1]+1 )
TRCell():New(oSection,"B1_COD","SBZ","Codigo"	   ,PesqPict("SB1","B1_COD") ,TamSx3("B1_COD")[1]+1 )
TRCell():New(oSection,"B1_DESC","SBZ","Descrição Prod"	   ,PesqPict("SB1","B1_DESC") ,TamSx3("B1_DESC")[1]+1 )
TRCell():new(oSection,"BZ_EMIN"	,"SBZ","Ponto Pedido"      ,PesqPict("SBZ","BZ_EMIN"),TamSx3("BZ_EMIN")[1]+1 )
TRCell():new(oSection,"BZ_ESTSEG","SBZ","Segurança"      ,PesqPict("SBZ","BZ_ESTSEG"),TamSx3("BZ_ESTSEG")[1]+1 )
TRCell():new(oSection,"BZ_TIPE"	,"SBZ","Tp Prz Ent"      ,PesqPict("SBZ","BZ_TIPE"),TamSx3("BZ_TIPE")[1]+1 )
TRCell():new(oSection,"BZ_PE"	,"SBZ","Prz Ent"      ,PesqPict("SBZ","BZ_PE"),TamSx3("BZ_PE")[1]+1 )
TRCell():new(oSection,"BZ_LE"	,"SBZ","Lote Econ."      ,PesqPict("SBZ","BZ_LE"),TamSx3("BZ_LE")[1]+1 )
TRCell():new(oSection,"BZ_LM"	,"SBZ","Lote Min."      ,PesqPict("SBZ","BZ_LM"),TamSx3("BZ_LM")[1]+1 )


oReport:SetTotalInLine(.F.)

Return (oReport)

/*
+------------+--------------------------------------------------------------+
! Descricao  ! Rotina para impressão do relatorio                         	!
+------------+--------------------------------------------------------------+
! Sintaxe    ! RepPrint(oReport,cAlias)                                 	!
+------------+--------------------------------------------------------------+
! Parametros ! oReport: Estrutura do relatório                            	!
!            ! cAlias: Alias temporário                                     !
+------------+--------------------------------------------------------------+
*/
static function RepPrint(oReport)

Local oSection  := oReport:Section(1)
Local nOrdem     := oReport:Section(1):GetOrder()
Local _cQuery	:= getnextAlias()

Do Case
	Case nOrdem == 1
		cOrder := "% SB1.B1_GRUPO,SB1.B1_DESC,SBZ.BZ_FILIAL %"
EndCase
BeginSql Alias _cQuery
	
	SELECT SBZ.BZ_FILIAL,SB1.B1_GRUPO,SBM.BM_DESC,SB1.B1_COD,SB1.B1_DESC,SBZ.BZ_EMIN,SBZ.BZ_ESTSEG,SBZ.BZ_TIPE,SBZ.BZ_PE,SBZ.BZ_LE,SBZ.BZ_LM
	FROM %Table:SB1% SB1 
	INNER JOIN %Table:SBM% SBM ON
	SBM.%NotDel% AND
	SBM.BM_GRUPO = SB1.B1_GRUPO
	INNER JOIN %Table:SBZ% SBZ ON
	SBZ.%NotDel% AND
	SBZ.BZ_COD = SB1.B1_COD AND
	SBZ.BZ_FILIAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
	WHERE SB1.%NotDel% AND
	SB1.B1_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
	SB1.B1_GRUPO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
	SB1.B1_TIPO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
	ORDER BY %Exp:cOrder%
EndSql
(_cQuery)->(dbGoTop())

oSection:init()
While !(_cQuery)->(Eof()) .And. !oReport:Cancel()
	oSection:Cell("BZ_FILIAL"):SetValue((_cQuery)->BZ_FILIAL)
	oSection:Cell("B1_GRUPO"):SetValue((_cQuery)->B1_GRUPO)
	oSection:Cell("BM_DESC"):SetValue((_cQuery)->BM_DESC)	
	oSection:Cell("B1_COD"):SetValue((_cQuery)->B1_COD)
	oSection:Cell("B1_DESC"):SetValue((_cQuery)->B1_DESC)
	oSection:Cell("BZ_EMIN"):SetValue((_cQuery)->BZ_EMIN)
	oSection:Cell("BZ_ESTSEG"):SetValue((_cQuery)->BZ_ESTSEG)
	oSection:Cell("BZ_TIPE"):SetValue((_cQuery)->BZ_TIPE)
	oSection:Cell("BZ_PE"):SetValue((_cQuery)->BZ_PE)
	oSection:Cell("BZ_LE"):SetValue((_cQuery)->BZ_LE)
	oSection:Cell("BZ_LM"):SetValue((_cQuery)->BZ_LM)
	oSection:PrintLine()
	
	(_cQuery)->(dbSkip())
	oReport:IncMeter()
	oReport:SkipLine()
	
EndDo
oSection:Finish()



return

Static Function CriaSx1()
Local aHlp01 := {'Informe ou Selecione o Código do Produto','Código para Filtro dos dados.'}
Local aHlp03 := {'Informe ou Selecione o Código do Grupo de Produtos','Código para Filtro dos dados.'}
Local aHlp05 := {'Informe ou Selecione o Tipo de Produto','Código para Filtro dos dados.'}
Local aHlp07 := {'Informe ou Selecione a Filial','Código para Filtro dos dados.'}

PutSx1(cPerg,"01","Produto de ?"				,"Produto de ?"				,"Produto de ?"				,"mv_ch1","C",15,0,0,"G",""				,"SB1"	,"","","mv_par01","","","","","","","","","","","","","","","","",aHlp01)
PutSx1(cPerg,"02","Produto até?"				,"Produto até?"				,"Produto até?"				,"mv_ch2","C",15,0,0,"G",""				,"SB1"	,"","","mv_par02","","","","","","","","","","","","","","","","",aHlp01)

PutSx1(cPerg,"03","Grupo de ?"				,"Grupo de ?"				,"Grupo de ?"				,"mv_ch3","C",04,0,0,"G",""				,"SBM"	,"","","mv_par03","","","","","","","","","","","","","","","","",aHlp03)
PutSx1(cPerg,"04","Grupo até?"				,"Grupo até?"				,"Grupo até?"				,"mv_ch4","C",04,0,0,"G",""				,"SBM"	,"","","mv_par04","","","","","","","","","","","","","","","","",aHlp03)

PutSx1(cPerg,"05","Tipo de ?"				,"Tipo de ?"				,"Tipo de ?"				,"mv_ch5","C",02,0,0,"G",""				,"02"	,"","","mv_par05","","","","","","","","","","","","","","","","",aHlp05)
PutSx1(cPerg,"06","Tipo até?"				,"Produto até?"				,"Produto até?"				,"mv_ch6","C",02,0,0,"G",""				,"02"	,"","","mv_par06","","","","","","","","","","","","","","","","",aHlp05)

PutSx1(cPerg,"07","Filial de ?"				,"Filial de ?"				,"Filial de ?"				,"mv_ch7","C",06,0,0,"G",""				,"SM0"	,"","","mv_par07","","","","","","","","","","","","","","","","",aHlp07)
PutSx1(cPerg,"08","Filial até?"				,"Filial até?"				,"Filial até?"				,"mv_ch8","C",06,0,0,"G",""				,"SM0"	,"","","mv_par08","","","","","","","","","","","","","","","","",aHlp07)

Return
