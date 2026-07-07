//--------------------------------------
//Impressão relatório separação produtos
//--------------------------------------
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function OMSA1000()

//Variáveis
Local cNomeArq   := ""  
Local lRet       := .F.                 
Local aCampos    := {}
Local aBrowse    := {}
Local bOk        := {|| lRet := .T.,IIF(lRet,MONTAREL(),),oDlg:END()}
Local bCancel    := {|| lRet := .F.,oDlg:END()}
Local aButtons   := {}     
Local aPergs     := {} 
Local oPrint
Local oFont6
Local oFont6n
Local oFont8
Local oFont8n
Local oFont10
Local oFont10n                 
Local oFont12
Local oFont12n
Local oFont14
Local oFont14n
Local nRow1      := 0
Local nTotal     := 0
Local Lin        := 0
Local aBmp       := "SENTAXBR.JPG"
Private lMarca   := .F.
Private Tamanho  := "M"
Private cTitulo  := "Impressão Separação Produtos"
Private cDesc1   := "Este programa destina-se a impressão do relatório separação"
Private cDesc2   := ""
Private cDesc3   := ""
Private cCodMot  := ""
Private cNomMot  := ""
Private cString  := "DAI"
Private wNrel    := "OMS1000"
Private lEnd     := .F.
Private cPerg    := "OMS1000"
Private aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
Private nLastKey := 0

//Definição fontes
oFont6   := TFont():New("Arial",9,6,.T.,.T.,5,.T.,5,.T.,.F.)
oFont6n  := TFont():New("Arial",9,6,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8n  := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10n := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12n := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)

SX1->(dbSeek(xFilial("SX1")+cPerg,.T.))                                                                  
If SX1->(!Found())
	AADD(aPergs,{"Carga    ","Carga    ","Carga    ","mv_ch1","C",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","DAK","","","",""})
	AADD(aPergs,{"Visualiza","Visualiza","Visualiza","mv_ch2","N",01,0,0,"C","","MV_PAR02","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","",""})

	//AjustaSx1("OMS1000",aPergs)
Endif

Pergunte(cPerg,.F.)

Wnrel := SetPrint(cString,Wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

If nLastKey == 27
	Set Filter to
	Return
Endif                 

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

If (Select("TRB") <> 0)
	dbSelectArea("TRB")
	dbCloseArea()
Endif		

//Seleciona registros
cQuery := " SELECT C9_PRODUTO, B1_DESC, SUM(C9_QTDLIB) QTDE "
cQuery += " FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("DAI")+" DAI, "+RetSqlName("SB1")+" SB1 "
cQuery += " WHERE SC9.D_E_L_E_T_ = ' ' "
cQuery += " AND DAI.D_E_L_E_T_ = ' ' "
cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " AND C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += " AND DAI_FILIAL = '"+xFilial("DAI")+"' "
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " AND C9_PEDIDO = DAI_PEDIDO "
cQuery += " AND C9_PRODUTO = B1_COD "
cQuery += " AND C9_CLIENTE = DAI_CLIENT "
cQuery += " AND C9_LOJA = DAI_LOJA "
cQuery += " AND C9_CARGA = DAI_COD " 
cQuery += " AND C9_SEQCAR = DAI_SEQCAR "
cQuery += " AND DAI_COD = '"+mv_par01+"' "
cQuery += " GROUP BY C9_PRODUTO, B1_DESC "
cQuery += " ORDER BY B1_DESC, C9_PRODUTO "

TcQuery cQuery New Alias "TRB"

//Inicia impressão
oPrint := TMSPrinter():New("Separação Produtos")

oPrint:ResetPrinter()
oPrint:SetPortrait()
oPrint:StartPage()

If !oPrint:IsPrinterActive()
	oPrint:SetUp()
Endif

ProcRegua(RecCount())
TRB->(dbGoTop())
If TRB->(!Eof())
	IncProc("Processando... Aguarde")

	oPrint:Box(0050,0150,3050,2350) 
	oPrint:SayBitmap(nRow1+0100,0200,aBmp,0350,0200 )

	//Cabeçalho
	cCodMot := Posicione("DAK",1,xFilial("DAK")+mv_par01,"DAK_MOTORI")
	cNomMot := Posicione("DA4",1,xFilial("DA4")+cCodMot,"DA4_NOME")

	oPrint:Say  (nRow1+0100,2300,"CARGA",oFont8n,,,,1)
	oPrint:Say  (nRow1+0150,2300,mv_par01,oFont14,,,,1)
	oPrint:Say  (nRow1+0200,0870,"RELATÓRIO SEPARAÇÃO DE CARGA",oFont14)

	oPrint:Say  (nRow1+0250,0870,"MOTORISTA: "+cNomMot,oFont12)

	oPrint:Line (nRow1+0350,0200,nRow1+0350,2300)
	oPrint:Line (nRow1+0360,0200,nRow1+0360,2300)

	oPrint:Say  (nRow1+0380,0200,"PRODUTO",oFont8n)
	oPrint:Say  (nRow1+0380,0500,"DESCRIÇÃO",oFont8n)
	oPrint:Say  (nRow1+0380,1450,"UM",oFont8n)
	oPrint:Say  (nRow1+0380,1700,"ENDEREÇO",oFont8n)
	oPrint:Say  (nRow1+0380,2300,"QUANTIDADE",oFont8n,,,,1)

	oPrint:Line (nRow1+0420,0200,nRow1+0420,2300)

	nLin := 0410

	TRB->(dbGoTop())
	While TRB->(!Eof())
		nlin := nLin + 35
		oPrint:Say  (nRow1+nLin,0200,Alltrim(TRB->C9_PRODUTO),oFont8)
		oPrint:Say  (nRow1+nLin,0500,Posicione("SB1",1,xFilial("SB1")+TRB->C9_PRODUTO,"B1_DESC"),oFont8)
		oPrint:Say  (nRow1+nLin,1450,Posicione("SB1",1,xFilial("SB1")+TRB->C9_PRODUTO,"B1_UM"),oFont8)
//		oPrint:Say  (nRow1+nLin,1700,"R35P22G90",oFont10)
		oPrint:Say  (nRow1+nLin,2300,Transform(TRB->QTDE,"@E 9,999,999.99"),oFont8,,,,1)

		TRB->(dbSkip())		
	Enddo    
Endif

oPrint:EndPage()

If mv_par02 == 1
	oPrint:Preview()
Else
	oPrint:Print()
Endif

dbSelectArea("TRB")
dbCloseArea("TRB")

oPrint:END()

Return
