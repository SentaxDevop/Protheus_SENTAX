//---------------------------------------------------------------------------------
//Rotina para impressão das etiquetas de entrega em impressora térmica padrão zebra
//---------------------------------------------------------------------------------
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#define DMPAPER_ENV_9_19

User Function ESTA1000()

Local cNomeArq     
Local lRet     := .F.                 
Local aCampos  := {}
Local aBrowse  := {}
Local bOk      := {|| lRet := .T.,IIF(lRet,MONTAREL(),),oDlg:END()}
Local bCancel  := {|| lRet := .F.,oDlg:END()}
Local aButtons := {}     
Local aPergs   := {} 
Private lMarca := .F.

Tamanho  := "M"
titulo   := "Impressao Etiqueta de Entrega"
cDesc1   := "Este programa destina-se a impressão das etiquetas de entrega"
cDesc2   := ""
cDesc3   := ""
cString  := "SF2"
wnrel    := "EST1000"
lEnd     := .F.
cPerg    := "EST1000"
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
nLastKey := 0

SX1->(dbSeek(xFilial("SX1")+cPerg,.T.))                                                                  
If SX1->(!Found())
	AADD(aPergs,{"Nota Inicial ","Nota Inicial ","Nota Inicial ","mv_ch1","C",09,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SF2001","","","",""})
	AADD(aPergs,{"Nota Final   ","Nota Final   ","Nota Final   ","mv_ch2","C",09,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SF2001","","","",""})
	AADD(aPergs,{"Série Inicial","Série Inicial","Série Inicial","mv_ch3","C",03,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aPergs,{"Série Final  ","Série Final  ","Série Final  ","mv_ch4","C",03,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aPergs,{"Visualiza    ","Visualiza    ","Visualiza    ","mv_ch5","N",01,0,0,"C","","MV_PAR05","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","",""})

	//AjustaSx1("EST1000",aPergs)
Endif

Pergunte(cPerg,.F.)

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

//fecha temporário caso esteja aberto
If (Select("TRB") <> 0)
	dbSelectArea("TRB")
	dbCloseArea()
Endif		

dbSelectArea("SF2")

//campos da tabela de temporária
AADD(aCampos,{"F2_FLAG   ","C",02,0})
AADD(aCampos,{"F2_DOC    ","C",09,0})
AADD(aCampos,{"F2_SERIE  ","C",03,0})
AADD(aCampos,{"F2_CLIENTE","C",06,0})
AADD(aCampos,{"F2_LOJA   ","C",02,0})
AADD(aCampos,{"A1_NOME   ","C",50,0})
AADD(aCampos,{"F2_TRANSP ","C",06,0})
AADD(aCampos,{"F2_VOLUME1","N",03,0})

//campos a serem exibidos na tela de markbrowse
AADD(aBrowse,{"F2_FLAG   ","       ","@!",02,0,".T."})
AADD(aBrowse,{"F2_DOC    ","Nota   ","@!",09,0,".T."}) 
AADD(aBrowse,{"F2_SERIE  ","Serie  ","@!",03,0,".T."})
AADD(aBrowse,{"F2_CLIENTE","Cliente","@!",06,0,".T."})
AADD(aBrowse,{"F2_LOJA   ","Loja   ","@!",02,0,".T."})
AADD(aBrowse,{"A1_NOME   ","Nome   ","@!",50,0,".T."})
AADD(aBrowse,{"F2_TRANSP ","Transp ","@!",06,0,".T."})
AADD(aBrowse,{"F2_VOLUME1","Volumes","@!",03,0,".T."})

//criação da tabela temporária a ser utilizada para marcação
//cNomeArq := CriaTrab(aCampos,.T.)
//dbUseArea(.T.,__LocalDriver,cNomeArq,"TRB",.F.,.F.)     

oTmp := FWTemporaryTable( ):New('TRB')
oTmp:SetFields( aCampos )
//oTmp:AddIndex("01", { "F2_FILIAL", "F2_DOC", "F2_SERIE" } )
oTmp:Create( )
cAliasTRB := oTmp:GetAlias( )     

//seleciona registros
cQuery := " SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_VOLUME1, F2_TRANSP, A1_NOME "
cQuery += " FROM " + RetSQLName("SF2") + " SF2, " + RetSQLName("SA1") + " SA1 "
cQuery += " WHERE "
cQuery += " SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
cQuery += " SF2.F2_DOC >= '"+mv_par01+"' AND SF2.F2_DOC <= '"+mv_par02+"' AND "
cQuery += " SF2.F2_SERIE >= '"+mv_par03+"' AND SF2.F2_SERIE <= '"+mv_par04+"' AND "
cQuery += " SF2.F2_CLIENTE+SF2.F2_LOJA = SA1.A1_COD+SA1.A1_LOJA  AND "
cQuery += " SF2.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY F2_DOC, F2_SERIE "

SqlToTrb(cQuery,aCampos,"TRB")

TRB->(dbGoTop())
AADD(aButtons,{"EDIT",{|| MarkAll(lMarca)},"Marca Todos","Marca Todos"})

@ 143,290 To 447,865 Dialog oDlg Title OemToAnsi("Impressão Etiquetas Entrega")

@ 030,001 To 147,288 Browse "TRB" Fields aBrowse Mark "F2_FLAG" Object oFields

InitMark()

Activate Dialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))

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

ProcRegua(RecCount())
TRB->(dbGoTop())
If TRB->(!Eof())
	While TRB->(!Eof())
		IncProc("Processando... Aguarde")
		aDadosPro := {TRB->F2_DOC     ,;
					  TRB->F2_SERIE	  ,; 
					  TRB->F2_CLIENTE ,;
					  TRB->F2_LOJA    ,;
					  TRB->F2_VOLUME1 ,;
					  TRB->F2_TRANSP  }
		If Marked("F2_FLAG")
			For nI := 1 To TRB->F2_VOLUME1
				cEtiq := Strzero(nI,3)
				IMPRESS(oPrint,cEtiq,aDadosPro)
    		Next
		Endif
		TRB->(dbSkip())		
	Enddo    
Endif

oPrint:EndPage()

If mv_par05 == 1
	oPrint:Preview()
Else
	oPrint:Print()
Endif

dbSelectArea("TRB")
dbCloseArea("TRB")

oPrint:END()

Return

//---------------------------------------------
//Inicia impressão - IMPRESS
//---------------------------------------------
Static Function IMPRESS(oPrint,cEtiq,aDadosPro)

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
Private cDoc  := Upper(Alltrim(aDadosPro[1])+"-"+Alltrim(aDadosPro[2]))
Private cNome := Substr(Upper(Alltrim(Posicione("SA1",1,xFilial("SA1")+aDadosPro[3]+aDadosPro[4],"A1_NOME"))),1,25)
Private cEnd  := Substr(Upper(Posicione("SA1",1,xFilial("SA1")+aDadosPro[3]+aDadosPro[4],"A1_ENDENT")),1,30)
Private cCid  := Upper(Posicione("SA1",1,xFilial("SA1")+aDadosPro[3]+aDadosPro[4],"A1_MUN"))
Private cEst  := Upper(Posicione("SA1",1,xFilial("SA1")+aDadosPro[3]+aDadosPro[4],"A1_EST"))
Private cCep  := Upper(Posicione("SA1",1,xFilial("SA1")+aDadosPro[3]+aDadosPro[4],"A1_CEP"))
Private cTra  := Substr(Posicione("SA4",1,xFilial("SA4")+aDadosPro[6],"A4_NOME"),1,25)
Private nVol  := Posicione("SF2",1,xFilial("SF2")+aDadosPro[1]+aDadosPro[2],"F2_VOLUME1")

oPrint:StartPage()

oPrint:Box(0000,0000,0550,0950) 
oPrint:SayBitmap(nRow1+0010,0740,aBmp,0200,0150)
oPrint:Say (nRow1+0010,0005,"Nota Fiscal",oFont06)
oPrint:Say (nRow1+0040,0005,cDoc,oFont18) 
oPrint:Say (nRow1+0170,0005,"Razão Social",oFont06)
oPrint:Say (nRow1+0182,0005,cNome,oFont15) 
oPrint:Say (nRow1+0237,0005,"Endereço",oFont06)
oPrint:Say (nRow1+0249,0005,cEnd,oFont15)
oPrint:Say (nRow1+0304,0005,"Cidade",oFont06)
oPrint:Say (nRow1+0316,0005,cCid,oFont15) 
oPrint:Say (nRow1+0304,0750,"UF",oFont06)
oPrint:Say (nRow1+0316,0750,cEst,oFont15) 
oPrint:Say (nRow1+0371,0005,"CEP",oFont06)
oPrint:Say (nRow1+0383,0005,Transform(cCep,"@R 99999-999"),oFont15) 
oPrint:Say (nRow1+0371,0600,"Volumes",oFont06)
oPrint:Say (nRow1+0383,0600,cEtiq+"/"+Strzero(nVol,3),oFont18) 
oPrint:Say (nRow1+0438,0005,"Transportadora",oFont06)
oPrint:Say (nRow1+0450,0005,cTra,oFont15) 

oPrint:EndPage()

Return

//----------------------
Static Function VERIMP()

Local oConf

oConf := TMSPrinter():New("Setup")
oConf:SetUp()            

Return

//-----------------------------------------------------------
//rotina utilizada para inicialização das marcações no browse
//-----------------------------------------------------------
Static Function InitMark()

TRB->(dbGoTop())
While TRB->(!Eof())                             
	RecLock("TRB",.F.)
	TRB->F2_FLAG := ThisMark()
	TRB->(MsUnlock())
			
	TRB->(dbSkip())	
Enddo      

TRB->(dbGoTop())

Return

//---------------------------------------
//marca todos os registros para impressão
//---------------------------------------    
Static Function MarkAll(lMarca)

Local nRecAtu := TRB->(Recno())

TRB->(dbGoTop())
While TRB->(!Eof())
	Reclock("TRB",.F.)
	TRB->F2_FLAG := IIF(lMarca,Space(2),GetMark())
	TRB->(MsUnlock())

	TRB->(dbSkip())
Enddo	

TRB->(dbGoTop(nRecAtu))
lMarca := !lMarca

Return
