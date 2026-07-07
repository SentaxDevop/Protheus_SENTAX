#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
//-------------------------------------------------------------------
/*SENTAX_MEST001
Mostra saldos multifiliais
//-------------------------------------------------------------------
*/
User Function MEST001()
	Private cPerg := padr("MEST001",10)

	Pergunte(cPerg,.T.)

//AjustaSX1(cPerg)
	CriaSx1()
	//While .T.
	//	If !Pergunte(cPerg,.T.)
	//		exit
	//	Endif
	u_MEST001A()
	//EndDo
Return

User Function MEST001A
	Local oBar
	Local aArea:=GetArea()
	Local oRelation
	Local oFWLayer
	Local oPanel
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cAlias := "QRY_TMP"

	Private oMBrowseAll
	Private oDlg
	Private _oDlg1
	Set Key VK_F4 TO ME001F4()



	DEFINE MSDIALOG oDlg TITLE "SALDOS EM ESTOQUE" FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL
// define a barra de botões
	Define buttonBar oBar size 25,25 3D TOP of oDlg
//	Define Button Resource "PMSRRFSH"       of oBar Action Pergunte(cPerg,.T.) Prompt "Atualiza"   ToolTip "Atualiza Browse"
	Define Button Resource "CANCEL"         of oBar Action ::end()      Prompt "Buscar/Sair"          ToolTip "Buscar/Sair"

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.,.T.)

	oFWLayer:AddCollumn("TELA",100,.T.,"UP")
	oFWLayer:AddWindow("TELA","oPanel","Saldos em estoque",80,.F.,.T.,,"UP",{ || })

	oPanel := oFWLayer:GetWinPanel("TELA","oPanel","UP")
	If SELECT("QRY_TMP") > 0
		QRY_TMP->(dbCloseArea())
	Endif
	If Select("TRB") <> 0
		TRB->( DbCLoseArea() )
	Endif
/*
B2_QEMP   ->Empenho
B2_QEMPN  -> Qtde Empenhada para N.F.s
B2_RESERVA -> Quantidade Reservada
B2_QPEDVEN -> Quantidade Pedido de Vendas
B2_SALPEDI -> Qtde prevista p/ entrar
B2_QTNP   -> Qtd. Terc. em Nosso Poder
B2_QNPT   --> Qtd. Nosso em Poder Terc.
B2_QATU - B2_RESERVA - B2_QEMP - B2_QEMPN o,nEmpenho,0) - If(lNecessidade,0,(cAliasSB2)->B2_QACLASS) - (cAliasSB2)->B2_QEMPSA - If(lEmpenho,nEmpProj,0) - AvalQtdPre("SB2",1) - If(lConsTerc,0,(cAliasSB2)->B2_QTNP) - If(lQEmpNF,If(lSaldoSemR,(cAliasSB2)->B2_QEMPN,0),0) + If(lConsNPT,(cAliasSB2)->B2_QNPT,0) )
*/
	If MV_PAR02!=1
		BeginSql alias cAlias
		%noparser%
		SELECT SB2.B2_FILIAL FILIAL
		,SB2.B2_COD COD
		,SB2.B2_LOCAL ALMOX
		,SB2.B2_QATU  QTATU
		,B2_QATU - B2_RESERVA - B2_QEMP - B2_QEMPN QTDISP
		,SB1.B1_DESC  DESCPRO
		,SB1.B1_UM    UM
		FROM %table:SB1% SB1, %table:SB2% SB2
		WHERE SB1.%notdel%
		AND SB2.%notdel%
		AND SB2.B2_COD = SB1.B1_COD
		AND SB1.B1_COD = %Exp:MV_PAR01%
		ORDER BY SB2.B2_COD,SB2.B2_FILIAL
		EndSQL
	Else
		cAux := "%'%" + ALLTRIM(MV_PAR03) + "%'%"

		BeginSql alias cAlias
		%noparser%
		SELECT SB2.B2_FILIAL FILIAL
		,SB2.B2_COD COD
		,SB2.B2_LOCAL ALMOX
		,SB2.B2_QATU  QTATU
		,B2_QATU - B2_RESERVA - B2_QEMP - B2_QEMPN QTDISP
		,SB1.B1_DESC  DESCPRO
		,SB1.B1_UM    UM
		FROM %table:SB1% SB1, %table:SB2% SB2
		WHERE SB1.%notdel%
		AND SB2.%notdel%
		AND SB2.B2_COD = SB1.B1_COD
		AND SB1.B1_DESC LIKE %Exp:caux%
		ORDER BY SB2.B2_COD,SB2.B2_FILIAL
		EndSQL
	EndIf
	cQRY:=GetLastQuery()[2]
//aviso("",GetLastQuery()[2],{"ok"},3)

	DEFINE FWBROWSE oMBrowseAll  DATA QUERY ALIAS "TRB" QUERY cQRY OF oPanel
//--------------------------------------------------------

	ADD COLUMN oColumn DATA { ||  TRB->FILIAL        }          TITLE "Filial"  SIZE OF oMBrowseAll
	ADD COLUMN oColumn DATA { ||  TRB->COD            }          TITLE "Codigo"   SIZE 15 OF oMBrowseAll
	ADD COLUMN oColumn DATA { ||  TRB->DESCPRO        }          TITLE "Descrição"    SIZE 30 OF oMBrowseAll
	ADD COLUMN oColumn DATA { ||  TRB->ALMOX          }          TITLE "Armazém"  SIZE OF oMBrowseAll
	ADD COLUMN oColumn DATA { ||  TRB->QTDISP         }          TITLE "Disponível"     SIZE OF oMBrowseAll
	ADD COLUMN oColumn DATA { ||  TRB->QTATU          }          TITLE "TOTAL"     SIZE OF oMBrowseAll

	DEFINE FONT oFontGrande NAME "Courier New" SIZE 9,14
	ACTIVATE FWBROWSE oMBrowseAll

	ACTIVATE MSDIALOG oDlg CENTERED
	lSai:=.T.

	Set Key VK_F4 TO
	RestArea(aArea)
return

// Ajusta Perguntas
//Static Function AjustaSX1(cPerg)

//	Local aRegs   := {},;
//		_sAlias := Alias(),;
//		nX

//	cPerg := PadR(cPerg,Len(Sx1->x1_grupo))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria uma array, contendo todos os valores...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	aAdd(aRegs,{cPerg,"01",  "Produto ?","",      "",     "mv_ch1","C",  15,     0,       0,    "G", "",  "mv_par01","",         "",       "",      "",        "",   "",   "",       "",      "",   "",   "",   "",       "",      "",   "",   "",   "",       "",      "",   "",   "",   "",       "",      "",   "SB1"   , ""})
//	aAdd(aRegs,{cPerg,"02",  "Contém ?" ,"",      "",     "mv_ch1","C",  15,     0,       0,    "G", "",  "mv_par01","",         "",       "",      "",        "",   "",   "",       "",      "",   "",   "",   "",       "",      "",   "",   "",   "",       "",      "",   "",   "",   "",       "",      "",   "SB1"   , ""})
//	DbSelectArea('SX1')
//	SX1->(DbSetOrder(1))

//	For nX:=1 to Len(aRegs)
//		If !SX1->(DbSeek(aRegs[nx][01]+aRegs[nx][02]))
//			RecLock('SX1',.t.)
//			Replace SX1->X1_GRUPO		With aRegs[nx][01]
//			Replace SX1->X1_ORDEM   	With aRegs[nx][02]
//			Replace SX1->X1_PERGUNTE	With aRegs[nx][03]
//			Replace SX1->X1_PERSPA		With aRegs[nx][04]
//			Replace SX1->X1_PERENG		With aRegs[nx][05]
//			Replace SX1->X1_VARIAVL		With aRegs[nx][06]
//			Replace SX1->X1_TIPO		With aRegs[nx][07]
//			Replace SX1->X1_TAMANHO		With aRegs[nx][08]
//			Replace SX1->X1_DECIMAL		With aRegs[nx][09]
//			Replace SX1->X1_PRESEL		With aRegs[nx][10]
//			Replace SX1->X1_GSC			With aRegs[nx][11]
//			Replace SX1->X1_VALID		With aRegs[nx][12]
//			Replace SX1->X1_VAR01		With aRegs[nx][13]
//			Replace SX1->X1_DEF01		With aRegs[nx][14]
//			Replace SX1->X1_DEF02		With aRegs[nx][15]
//			Replace SX1->X1_DEF03		With aRegs[nx][16]
//			Replace SX1->X1_F3   		With aRegs[nx][17]
//			Replace SX1->X1_PICTURE		With aRegs[nx][18]
//			MsUnlock('SX1')
//		Endif
//	Next nX
Return

Static Function CriaSx1()
	Local aHlp01 := {'Informe ou Selecione o Código do Produto','Código para Filtro dos dados.'}
	Local aHlp02 := {'Considera a pergunta abaixo?','Se sim irá filtrar os produtos que contem os caracteres abaixo.'}
	Local aHlp03 := {'Informe caracteres contidos na descrição do produto','Palavra contida na descrição do produto.'}

	PutSx1(cPerg,"01","Produto ?"				,"Produto ?"				,"Produto ?"				,"mv_ch1","C",15,0,0,"G",""				,"SB1"	,"","","mv_par01","","","","","","","","","","","","","","","","",aHlp01)
	PutSx1(cPerg,"02","Considera filtro abaixo ?"	,"Considera filtro abaixo ?"	,"Considera filtro abaixo ?"	,"mv_ch2","N",01,0,1,"C",""				,""		,"","","mv_par02","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlp02)
	PutSx1(cPerg,"03","Descrição contém ..."		 		,"Descrição contém ..."				,"Descrição contém ..."				,"mv_ch3","C",30,0,0,"G",""				,""		,"","","mv_par03","","","","","","","","","","","","","","","","",aHlp03)



return

Static Function ME001F4()
	Local cFilBkp := cFilAnt
	Set Key VK_F4 TO
	cFilAnt := TRB->FILIAL
	MaViewSB2(TRB->COD)
	cFilAnt := cFilBkp
	Set Key VK_F4 TO ME001F4()
Return
