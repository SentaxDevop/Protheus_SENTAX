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
!Nome              ! TMKBARLA                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. utilizado para adicionar botões no CallCenter      !
+------------------+---------------------------------------------------------+
!Autor             !  SUELEN REGINA DE SOUZA                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/01/2014 !                                            !
+------------------+---------------------------------------------------------+ */

User function TMKBARLA()
Local aBotao := {}

If (TkGetTipoAte()== "2") .OR. (TkGetTipoAte()== "4") .OR. (TkGetTipoAte()== "5")  //2 - Somente Televendas , 4 - Todos , 5 - Televendas e TeleMarketing.
	
	aadd(aBotao,{"DBG07"    , {||U_TMKA1008(M->UA_CLIENTE, M->UA_LOJA)}, "Pisca"})
	
ELSEIF (TkGetTipoAte()== "3")     

	aadd(aBotao,{"BUDGETY"    , {||Tk274Tit()}, "Busca Titulo"})    
	
ENDIF

Return(aBotao)
