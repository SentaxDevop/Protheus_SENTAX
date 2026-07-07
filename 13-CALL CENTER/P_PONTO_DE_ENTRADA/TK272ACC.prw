#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"

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
!Nome              ! TK272ACC                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. utilizado para manipular a autenticação do e-mail  !
+------------------+---------------------------------------------------------+
!Autor             !  SUELEN REGINA DE SOUZA                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 10/09/2014 !                                            !
+------------------+---------------------------------------------------------+ */

User Function TK272ACC()
Local aRetorno := {} 
Local lRet := .F.               
Local _cConta :=  Posicione("SU7",1,xFilial("SU7") + TkOperador(),"U7_CONTA") 
Local _cSenha :=  Posicione("SU7",1,xFilial("SU7") + TkOperador(),"U7_SENHA")
 
_cSenha := Embaralha(_cSenha,1)

aRetorno := { _cConta , _cSenha }

Return aRetorno