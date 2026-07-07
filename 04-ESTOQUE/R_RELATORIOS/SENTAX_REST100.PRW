//---------------------------------------------------------------------------------
//Rotina para impressão das etiquetas de recebimento em impressora térmica padrão zebra
//---------------------------------------------------------------------------------
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#define DMPAPER_ENV_9_19

User Function REST100(cProduto,nQuant,nvisual)

Local cNomeArq     
Local lRet     := .F.                 
Local aCampos  := {}
Local aBrowse  := {}
Local aButtons := {}     
Local aPergs   := {} 
Local _cQuery	:= getnextAlias() 
Private lMarca := .F.

Tamanho  := "M"
titulo   := "Impressao Etiqueta de PRODUTO"
cDesc1   := "Este programa destina-se a impressão das etiquetas de PRODUTO"
cDesc2   := ""
cDesc3   := ""
cString  := "SB1"
wnrel    := "REST100"
lEnd     := .F.
cPerg    := "REST100"
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
nLastKey := 0
If FUNNAME() != "REST100"  
   //	Pergunte(cPerg,.F.)
	MV_PAR01:= cProduto
	MV_PAR02:= nQuant
	MV_PAR03:= nvisual
Else
	SX1->(dbSeek(xFilial("SX1")+cPerg,.T.))                                                                  
	If SX1->(!Found())                                
		AADD(aPergs,{"Cod.Produto ","Cod.Produto ","Cod.Produto "   ,"mv_ch1","C",30,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","",""})
		AADD(aPergs,{"Quantidade  ","Quantidade  ","Quantidade  "   ,"mv_ch2","N",02,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		AADD(aPergs,{"Visualiza    ","Visualiza    ","Visualiza    ","mv_ch3","N",01,0,0,"C","","MV_PAR03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","",""})
		AjustaSx1("REST100",aPergs)
	Endif
	Pergunte(cPerg,.T.)
EndIf
Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

If nLastKey == 27
	Set Filter to
	Return
Endif                 

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif
MONTAREL()
Return

//------------------------------------
//Inicia consulta dos dados - MONTAREL
//------------------------------------
Static Function MONTAREL()

Local oPrint
Local aDadosPro
Local cEtiq := ""
Local nI    := 0

oPrint := TMSPrinter():New("Impressão Etiquetas")

oPrint:ResetPrinter()
oPrint:SetPortrait()
oPrint:SetPaperSize(DMPAPER_ENV_9_19)
oPrint:StartPage()

If !oPrint:IsPrinterActive()
	oPrint:SetUp()
Endif

ProcRegua(MV_PAR02)   
dbSelectArea("SB1")      
dbSetOrder(1)
If !dbSeek(xFilial('SB1')+MV_PAR01)
	Alert("Produto não encontrado")
	Return
EndIf	
For _i:=1 to MV_PAR02
	IncProc("Processando... Aguarde")
	aDadosPro := {SB1->B1_COD     ,;
	SB1->B1_DESC	  ,;
	SB1->B1_UM ,;
	SB1->B1_CODBAR  }
	IMPRESS(oPrint,aDadosPro)
Next

oPrint:EndPage()

If mv_par03 == 1
	oPrint:Preview()
Else
	oPrint:Print()
Endif

oPrint:END()

Return

//---------------------------------------------
//Inicia impressão - IMPRESS
//---------------------------------------------
Static Function IMPRESS(oPrint,aDadosPro)

nRow1 := 0

Private oFont06 := TFont():New("Tahoma",,-06,.T.,.T.)
Private oFont08 := TFont():New("Tahoma",,-08,.T.,.T.)
Private oFont10 := TFont():New("Tahoma",,-10,.T.,.T.)
Private oFont12 := TFont():New("Tahoma",,-12,.T.,.T.)
Private oFont14 := TFont():New("Tahoma",,-14,.T.,.T.)
Private oFont15 := TFont():New("Tahoma",,-15,.T.,.T.)
Private oFont16 := TFont():New("Tahoma",,-16,.T.,.T.)
Private oFont18 := TFont():New("Tahoma",,-18,.T.,.T.)

Private aBmp  := "SENTAX.JPG"
Private cCod  := Upper(Alltrim(aDadosPro[1]))  
Private cCodEAN  := Upper(Alltrim(aDadosPro[4]))           
Private cDesc := Substr(Upper(Alltrim(aDadosPro[2])+"-"+Alltrim(aDadosPro[3])),1,27)
Private cDesc1 := Substr(Upper(Alltrim(aDadosPro[2])+"-"+Alltrim(aDadosPro[3])),27,27)

oPrint:StartPage()

oPrint:Box(0000,0000,0550,0950) 
oPrint:SayBitmap(nRow1+0010,0740,aBmp,0200,0150)
oPrint:Say (nRow1+0010,0015,"Código",oFont06)
oPrint:Say (nRow1+0040,0015,cCod,oFont18) 
oPrint:Say (nRow1+0170,0015,"Descrição",oFont06)
oPrint:Say (nRow1+0182,0015,cDesc,oFont15) 
oPrint:Say (nRow1+0228,0015,cDesc1,oFont15)       

//MSBAR3 -Impressão de código de barras na deskjet HP e laser ( [ cTypeBar ] [ nRow ] [ nCol ] [ cCode ] [ oPr ] [ lCheck ] [ Color ] [ lHort ] [ nWidth ] [ nHeigth ] [ lBanner ] [ cFont ] [ cMode ] [ lPrint ] [ nPFWidth ] [ nPFHeigth ] ) --> Nil
If EMPTY(cCodEAN)
	MSBAR3("CODE128",5,03,cCod,oPrint,.F., , .T., 0.025, 0.8, .F., 'TAHOMA', 'B', .F. )
Else
	MSBAR3("EAN13",5,03,cCodEAN,oPrint,.F., , .T., 0.025, 0.8, .F., 'TAHOMA', 'B', .F. )
EndIf

oPrint:EndPage()

Return

//----------------------
Static Function VERIMP()

Local oConf

oConf := TMSPrinter():New("Setup")
oConf:SetUp()            

Return
