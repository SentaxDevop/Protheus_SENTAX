//---------------------------------
//Importação notas fiscais de saída
//---------------------------------
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

User Function IMPFAT()

Private aArea := GetArea()
Private cArq  := Space(08)

If (Select("TMP") <> 0)
	dbSelectArea("TMP")
	dbCloseArea()
Endif		

//Definições de tela
#define CLR_HBLUE      16711680       // RGB(   0,   0, 255 )
#define CLR_HGREEN        65280       // RGB(   0, 255,   0 )
#define CLR_HGRAY      12632256       // RGB( 192, 192, 192 )
#define CLR_HRED            255       // RGB( 255,   0,   0 )
#define CLR_YELLOW        65535       // RGB( 255, 255,   0 )
#define CLR_WHITE      16777215       // RGB( 255, 255, 255 )
                                                                             
//Interface                                                
DEFINE FONT oFnt NAME "Arial" SIZE 6,22 BOLD

@ 125,200 To 309,571 DIALOG oLeDBF TITLE OemToAnsi("Importação Notas Fiscais")
@ 005,002 To 050,183
oSay1 := tSay():New(10,05,{||OemToAnsi("Esta rotina irá importar os dados das notas fiscais de saída.     ")},oLeDBF,,oFnt,,,,.T.,CLR_BLUE,CLR_RED,300,20)
oSay2 := tSay():New(34,05,{||OemToAnsi("O arquivo deverá estar na pasta SYSTEM do sistema, em formato DBF.")},oLeDBF,,oFnt,,,,.T.,,CLR_RED,300,20)
oSay3 := tSay():New(55,05,{||"Informe o nome do arquivo sem extensão e aguarde o processamento...         " },oLeDBF,,oFnt,,,,.T.,CLR_BLUE,CLR_RED,300,20)
@ 068,002 To 090,060
@ 075,005 Get cArq PICTURE "@!" SIZE 40,30
@ 077,045 Say ".DBF"

@ 75,126 BMPBUTTON TYPE 01 ACTION OkLeDBF()
@ 75,156 BMPBUTTON TYPE 02 ACTION Close(oLeDBF)

Activate Dialog oLeDBF Centered

RestArea(aArea)

Return                                         

//-----------------------
Static Function OkLeDBF()

//Arquivos e ordens utilizados
dbSelectArea("SF2")
SF2->(dbSetOrder(1))

//Verifica se o arquivo para importação existe
cArq := Alltrim(cArq)+".DBF"

If !File(cArq)
   MsgStop("Arquivo "+cArq+" Inexistente... Verifique","Atenção")
   Return
Endif

//Abre o arquivo para importação
//Use &cArq Alias TMP Shared New
dbSelectArea("TMP")
Index on TMP->NOTA To NOTA

//Iniciando o processamento
Processa({|| RunCont() },"Processando Informações...")
Return

//-----------------------
Static Function RunCont()

Local cFil  := ""
Local nNota := ""
Local nItem := 0

//Conta os registros
ProcRegua(RecCount())

//Inicia controle transações
Begin Transaction

//Importa cabeçalho das notas
dbSelectArea("SF2")
SF2->(dbSetOrder(1))

TMP->(dbGoTop())
While TMP->(!Eof())
	IncProc("Importando Cabeçalho Notas... Aguarde")
	cFil := IIF(Alltrim(TMP->FILIAL) == "A02","030301","020201")

	SF2->(dbSeek(cFil+Strzero(Val(Alltrim(TMP->NOTA)),9),.T.))
	If SF2->(!Found())
		RecLock("SF2",.T.)
		SF2->F2_FILIAL	:= IIF(Alltrim(TMP->FILIAL) == "A02","030301","020201")
		SF2->F2_EST     := Posicione("SA1",1,xFilial("SA1")+Alltrim(TMP->CLIENTE),"A1_EST")
		SF2->F2_TIPO    := "N"
		SF2->F2_DTLANC	:= TMP->DATA
		SF2->F2_DOC		:= Strzero(Val(TMP->NOTA),9)
		SF2->F2_EMISSAO	:= TMP->DATA
		SF2->F2_SERIE	:= "MAN"
		SF2->F2_CLIENTE	:= Posicione("SA1",1,xFilial("SA1")+Alltrim(TMP->CLIENTE),"A1_COD")
		SF2->F2_LOJA	:= Posicione("SA1",1,xFilial("SA1")+Alltrim(TMP->CLIENTE),"A1_LOJA")
		SF2->F2_ESPECIE	:= "NF"
		SF2->F2_COND	:= "000"
		SF2->F2_VALBRUT	:= TMP->TOTAL
		SF2->F2_TPFRETE	:= "1"
		SF2->F2_MOEDA  	:= 1
		SF2->F2_RECISS  := "2"
 		MsUnlock("SF2")
	Endif
	TMP->(dbSkip())
Enddo

//Importa itens das notas
dbSelectArea("SD2")
SD2->(dbSetOrder(3))

TMP->(dbGoTop())
While TMP->(!Eof())
	IncProc("Importando Itens Notas... Aguarde")
	cFil := IIF(Alltrim(TMP->FILIAL) == "A02","030301","020201")

	SD2->(dbSeek(xFilial("SD2")+Strzero(Val(Alltrim(TMP->NOTA)),9),.T.))
	If SD2->(!Found()) .and. !Empty(TMP->PRODUTO)
		nNota := TMP->NOTA
		nItem := nItem + 1
		RecLock("SD2",.T.)
		SD2->D2_FILIAL	:= IIF(Alltrim(TMP->FILIAL) == "A02","030301","020201")
		SD2->D2_DOC		:= Strzero(Val(TMP->NOTA),9)
		SD2->D2_TIPO    := "N"
		SD2->D2_ORIGLAN := "LM"
		SD2->D2_COD		:= Alltrim(TMP->PRODUTO)
		SD2->D2_ITEM	:= Strzero(nItem,2)
		SD2->D2_QUANT	:= TMP->QTDE
		SD2->D2_PRCVEN	:= TMP->UNIT
		SD2->D2_TOTAL	:= TMP->TOTAL
		SD2->D2_UM		:= Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_UM")
		SD2->D2_SEGUM	:= Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_SEGUM")
		SD2->D2_EST     := Posicione("SA1",1,xFilial("SA1")+Alltrim(TMP->CLIENTE),"A1_EST")
		SD2->D2_GRUPO   := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_GRUPO")
		SD2->D2_TP      := "PA"
		SD2->D2_TES     := "999"
		If SD2->D2_EST == "PR"
			SD2->D2_CF := "5949"
		Else
			SD2->D2_CF := "6949"
		Endif
		If Empty(TMP->CNPJ)
			SD2->D2_CLIENTE := Posicione("SA1",3,xFilial("SA1")+Substr(TMP->CPF,2,11),"A1_COD")
			SD2->D2_LOJA	:= Posicione("SA1",3,xFilial("SA1")+Substr(TMP->CPF,2,11),"A1_LOJA")
		Else
			SD2->D2_CLIENTE := Posicione("SA1",3,xFilial("SA1")+Substr(TMP->CNPJ,2,14),"A1_COD")
			SD2->D2_LOJA	:= Posicione("SA1",3,xFilial("SA1")+Substr(TMP->CNPJ,2,11),"A1_LOJA")
		Endif
		SD2->D2_CLASFIS	:= "000"
		SD2->D2_EMISSAO := TMP->DATA
		SD2->D2_SERIE   := "MAN"
		SD2->D2_LOCAL   := "01"
		SD2->D2_VALBRUT := TMP->TOTAL
		SD2->D2_PICM 	:= 0
 		MsUnlock("SD2")
	Endif
	TMP->(dbSkip())

	If TMP->NOTA <> nNota
		nItem := 0
	Endif
Enddo

//Finaliza controle transações
End Transaction

MsgInfo("Importação Concluída","Atenção")

oLeDBF:End()

Return
