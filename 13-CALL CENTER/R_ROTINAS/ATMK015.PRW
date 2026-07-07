#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"
User Function ATMK015()
Local aArea         := GetArea()
Local cSql 			:= ""
Private oDlg		:= nil
Private cFilTmk	    := xFilial("SD2")
Private oFilTmk	    := nil
Private cAtendim	:= Space(6)
Private oAtendim	:= nil
Private nBtoOk		:= 0
Private cPrompt		:= "Informe o Atendimento"

DEFINE MSDIALOG oDlg TITLE "[Atualização de Atendimento]" From 001,001 to 220,500 Pixel

nLinha := 32
@ nLinha, 02  group obroup to 100,210 PIXEL prompt cPrompt oF oDlg
nLinha += 20

@ nLinha, 005 SAY  "Filial:" SIZE 025, 007 OF oDlg  PIXEL
@ nLinha, 040 MSGET oFilTmk VAR cFilTmk SIZE 100, 010 WHEN .T. OF oDlg COLORS 0, 16777215 PIXEL

nLinha += 20

@ nLinha, 005 SAY  "Atendimento:" SIZE 025, 007 OF oDlg  PIXEL
@ nLinha, 040 MSGET oAtendim VAR cAtendim SIZE 100, 010 WHEN .T. OF oDlg COLORS 0, 16777215 PIXEL


ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )

If nBtoOk == 0
		Help( ,, 'Atualizacao de Atendimento',, 'Cancelado pelo usuário!!!!!!!', 1, 0 )
		cAtendim	:= Space(6)
	
	Else
		Processa({||AtuAten(cAtendim)} ,"Processando Atendimento","Aguarde...")
EndIf

Return()

Static Function AtuAten(cAtendim)
Local aArea     := GetArea()
Local nRegs		:= 0
Private QORC	:= GetNextAlias()

// define a query de orçamentos atualizados
cQr := " UPDATE "+ RetSqlName("SUC") +" SET UC_STATUS = '2',UC_CODENCE='',UC_CODMOT='' WHERE D_E_L_E_T_ = '' AND UC_FILIAL = '"+cFilTmk+"' AND UC_CODIGO = '"+cAtendim+"'"

If TCSqlExec(cQr) < 0
        Conout("")
        Conout("TCSQLError() " + TCSQLError())

        MsgInfo("Erro na atualizacao do Status!", "Sentax")

    Else
        cQr := " UPDATE "+ RetSqlName("SUD") +" SET UD_STATUS = '1' WHERE D_E_L_E_T_ = '' AND UD_FILIAL = '"+cFilTmk+"' AND UD_CODIGO = '"+cAtendim+"'"

        If TCSqlExec(cQr) < 0
                Conout("")
                Conout("TCSQLError() " + TCSQLError())
                MsgInfo("Erro na atualizacao do Status!", "Sentax")

            Else
                MsgInfo("Finalizado!! Não esqueça de Finalizar novamente este Atendimento!", "Sentax")
        EndIf
EndIf

RestArea(aArea)
Return()
