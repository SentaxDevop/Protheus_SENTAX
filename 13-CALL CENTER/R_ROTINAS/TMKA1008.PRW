//--------------------------------------------------------------------------------------------------
//Chama o Pisca atravez de uma caixa de MEMO para evitar fechar com ENTER
//solicitado pela Sra. Denise
//--------------------------------------------------------------------------------------------------
#include "totvs.ch"

User Function  TMKA1008(cCliente, cLoja)
	Local oDlg												//Tela
	Local oMonoAs := TFont():New("Arial",,17,, .t.)		//Fonte do objeto
	Local nOpca	  := 0										//Opcao de escolha OK ou CANCELA
	Local lCancela:= .F.									//Flag para autorizar o cancelament
	Local cObs    := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_X_PISCA")
	Local oObs
	
	Local lExecuta := .T. 
	Local nCount   := 1

	
	For nCount := 1 to Len(ProcName())
		If Alltrim(ProcName(nCount)) == "U_M410STTS"
			lExecuta := .F. 
		EndIf
	Next

	If !IsBlind()
		If lExecuta
			IF !EMPTY(cObs)
				DEFINE MSDIALOG oDlg FROM 05,10 TO 400,600 TITLE "PISCA" PIXEL

				@04,06 TO 190,291 LABEL "Mensagem" OF oDlg COLOR CLR_HRED PIXEL

				@13,12 GET oObs VAR cObs OF oDlg MEMO size 273,171 PIXEL READONLY

				oObs:oFont 		:= oMonoAs

				oDlg:lEscClose     := .F. //Nao permite sair ao se pressionar a tecla ESC.

				ACTIVATE MSDIALOG oDlg CENTER
			ENDIF
		EndIf
	End

Return
