#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! TMK - CallCenter	                                     !
+------------------+---------------------------------------------------------+
!Nome              ! TK271ABR                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. utilizado para no botão alterar do call center     !
+------------------+---------------------------------------------------------+
!Autor             !  SUELEN REGINA DE SOUZA                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 24/01/2014 !                                            !
+------------------+---------------------------------------------------------+ */

User Function TK271ABR()

//Não permitir alteração do pedido quando estiver com Status igual a Atendimento
If PARAMIXB[1] == 4 .AND.(TkGetTipoAte()== "2") //SOMENTE EXECUTA SE FOR TELEVENDAS.
	If SUA->UA_OPER == "3"
			If IsBlind()
				cLogTxt := "Atenção, Atendimento com status de ATENDIMENTO, só é permitida a visualização !!! - [TK271ABR]"
				Conout(cLogTxt)				
			Else
				MsgStop("Atenção, Atendimento com status de ATENDIMENTO, só é permitida a visualização !!!")
			End
		return(.F.)
	Endif	
	
	IF !Empty(Alltrim(SUA->UA_NUMSC5))
		DbSelectArea('DAI')
		DAI->(DbSetOrder(4))
		DAI->(DbGoTop())
		IF DAI->(DbSeek(xFilial('DAI')+SUA->UA_NUMSC5))
			If IsBlind()
				cLogTxt := "Atenção, este atendimento já está em carga! Não é permitida alteração de Atendimentos em carga! - [TK271ABR]"
				Conout(cLogTxt)				
			Else
				MsgStop("Atenção, este atendimento já está em carga! Não é permitida alteração de Atendimentos em carga!")
			End
			return(.F.)
		EndIf                            
              
		If !Empty(Alltrim(SUA->UA_NUMSC5))
			DbSelectArea('SD2')
			SD2->(DbSetOrder(8))
			SD2->(DbGoTop())
			IF SD2->(DbSeek(xFilial('SD2')+SUA->UA_NUMSC5))
				If IsBlind()
					cLogTxt := "Atenção, este atendimento possui nota fiscal gerada! Ele não pode ser alterado! - [TK271ABR]"
					Conout(cLogTxt)		
				Else
					MsgStop("Atenção, este atendimento possui nota fiscal gerada! Ele não pode ser alterado!")
				End
				return(.F.)
			EndIf                            				
		EndIf		

		DbSelectArea('SC5')
		SC5->(DbSetOrder(1))
		SC5->(DbGoTop())
		IF SC5->(DbSeek(SUA->UA_FILIAL+SUA->UA_NUMSC5))
			If SC5->C5_XSTAWMS == "E" .Or. SC5->C5_XSTAWMS == "O"
				
				If IsBlind()
					cLogTxt := "[TK271ABR - 01] - Este Atendimento gerou o pedido de venda nº "+SUA->UA_NUMSC5+" que consta integrado ao WMS. Alteração não permitida!"
					Conout(cLogTxt)		
				Else
					FWAlertWarning("[TK271ABR - 01] - Este Atendimento gerou o pedido de venda nº "+SUA->UA_NUMSC5+" que consta integrado ao WMS. Alteração não permitida!", "SENTAX")
				End

				return(.F.)
			End
		EndIf                            				
	EndIf
	
	
ENDIF

return(.t.)
