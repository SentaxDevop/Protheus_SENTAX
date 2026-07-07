#include "protheus.ch"
#include "topconn.ch"

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
!Nome              ! TLVENT                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E na entrada da tela principal do call center que     !
!                  ! atualiza o campo saldo ao abrir um atendimento.         !
+------------------+---------------------------------------------------------+
!Autor             ! SUELEN REGINA DE SOUZA                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 02/01/2013                                              !
+------------------+---------------------------------------------------------+   */

User Function TLVENT()
Local aArea 		:= GetArea()
Local nPosEst   	:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_XSB2"})
Local nPosProd   	:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
Local nPosLocal		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_LOCAL"})
Local cCodigo 		:= ""
Local cLocal 		:= ""
Local i				:= 0

If FUNNAME() == "TMKA271" .or. nFolder == 2 //TELEVENDAS  
     
	IF ALTERA 
		
		IF EMPTY(M->UA_DOC)
			
			If IsBlind()
				cLogTxt := "O campo SALDO EST. será ATUALIZADO para cada produo no atendimento - [TLVENT]"
				Conout(cLogTxt)		
			Else		
				MSGALERT("O campo SALDO EST. será ATUALIZADO para cada produo no atendimento")
			End

			For i:=1 to Len(aCols)
				
				IF !EMPTY(aCols[i,nPosProd])
					cCodigo 			:= aCols[i,nPosProd]
					cLocal  			:= aCols[i, nPosLocal]
					aCols[i,nPosEst]  	:= U_TMKA1007(cCodigo, cLocal)
				ENDIF
				
			Next i
			
		ENDIF 
	
	ELSE  
			
		IF EMPTY(SUA->UA_DOC)
			
			If IsBlind()
				cLogTxt := "O campo SALDO EST. será ATUALIZADO para cada produo no atendimento - [TLVENT]"
				Conout(cLogTxt)		
			Else
				MSGALERT("O campo SALDO EST. será ATUALIZADO para cada produo no atendimento")
			End

			For i:=1 to Len(aCols)
				
				IF !EMPTY(aCols[i,nPosProd])
					cCodigo 			:= aCols[i,nPosProd]
					cLocal  			:= aCols[i, nPosLocal]
					aCols[i,nPosEst]  	:= U_TMKA1007(cCodigo, cLocal)
				ENDIF
				
			Next i
			
		ENDIF 
	
	ENDIF
	
Endif

RestArea(aArea)
Return
