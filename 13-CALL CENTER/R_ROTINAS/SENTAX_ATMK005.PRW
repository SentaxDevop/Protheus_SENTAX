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
!Modulo            ! TMK - Call Center                                       !
+------------------+---------------------------------------------------------+
!Nome              ! ATMK005                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! REFAZ AGENDA DO OPERADOR	             			     !
+------------------+---------------------------------------------------------+
!Autor             ! SUELEN REGINA DE SOUZA                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 06/08/2012                                              !
+------------------+---------------------------------------------------------+

+------------------+------------------------------------------------------------------------------+
!                                        ATUALIZACOES                  				              !
+-------------------------------------------+---------------------+--------------------+----------+
!   Descricao detalhada da atualizacao      !Nome do              ! Analista           !Data da   !
!                                           !Solicitante          ! Respons.           !Atualiz.  !
+-------------------------------------------+---------------------+--------------------+----------+
! - Inclusão de novos fatores para cálculo  ! Rafael              ! Alexandre Effting  !05/09/2011!
! do custo de reposição.                    !                     !                    !          !
+-------------------------------------------+---------------------+--------------------+----------+
*/

User Function ATMK005()
Local nOpcA     := 0
Local cPerg 	:= ""

FormBatch("Refaz Agenda do Operador",;
{"Este programa tem o objetivo FINALIZAR a AGENDA DO OPERADOR que constar ",;
"atendimentos CANCELADOS, FATURADOS e ENCERRADOS."},;
{{5,.T.,{|o| Pergunte(cPerg,.F.)}},;
{1,.T.,{|o| nOpcA:=1,o:oWnd:End()}},;
{2,.T.,{|o| o:oWnd:End()}}})

IF nOpcA == 1
	
	PROCESSA({|| Reprocessa() },"","Aguarde o Processamento...",.F.)
	
ENDIF

Return

Static Function Reprocessa()

DbSelectArea("SU4")
SU4->(DbSetOrder(1))

DbSelectArea("SU6")
SU6->(DbSetOrder(1))

//Atendimento do Televendas CANCELADOS
cQuery := " SELECT * "
cQuery += " 	FROM " + RetSqlName("SU4") +" SU4"
cQuery += " WHERE U4_STATUS = '1'"
cQuery += " AND U4_TIPO = '3'"
cQuery += " AND D_E_L_E_T_ <> '*'"
cQuery += " AND U4_CODLIG IN (  SELECT UA_NUM"
cQuery += "                     FROM " + RetSqlName("SUA") +" SUA "
cQuery += "  		  			WHERE UA_FILIAL = U4_FILIAL "
cQuery += "                     	AND UA_CANC = 'S' "
cQuery += "                     	AND D_E_L_E_T_ <> '*')"

cQuery := ChangeQuery(cQuery)

If ( SELECT("TRB") ) > 0
	dbSelectArea("TRB")
	TRB->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "TRB"

TRB->(DbGotop())
DO WHILE TRB->(!EOF())
     IF SU4->(DbSeek(TRB->U4_FILIAL + TRB->U4_LISTA))
     		RecLock("SU4",.F.)
	   		SU4->U4_STATUS := "2"
	   		SU4->(MsUnLock())
     ENDIF
     
     IF SU6->(DbSeek(TRB->U4_FILIAL + TRB->U4_LISTA))
       		RecLock("SU6",.F.)
	   		SU6->U6_STATUS := "2"
	   		SU6->(MsUnLock())
     ENDIF
     
     TRB->(DbSkip())
ENDDO

//Atendimento do Televendas FATURADOS
cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName("SU4") +" SU4"
cQuery += " WHERE U4_STATUS = '1'"
cQuery += " AND U4_TIPO = '3'"
cQuery += " AND D_E_L_E_T_ <> '*'"
cQuery += " AND U4_CODLIG IN (	SELECT UA_NUM"
cQuery += "                    	FROM " + RetSqlName("SUA") +" SUA"
cQuery += "  		  			WHERE UA_FILIAL = U4_FILIAL "
cQuery += "                     	AND UA_DOC <>  '  '"
cQuery += "                     	AND D_E_L_E_T_ <> '*')"

cQuery := ChangeQuery(cQuery)

If ( SELECT("TRB") ) > 0
	dbSelectArea("TRB")
	TRB->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "TRB"


TRB->(DbGotop())
DO WHILE TRB->(!EOF())
     IF SU4->(DbSeek(TRB->U4_FILIAL + TRB->U4_LISTA))
     		RecLock("SU4",.F.)
	   		SU4->U4_STATUS := "2"
	   		SU4->(MsUnLock())
     ENDIF
     
     IF SU6->(DbSeek(TRB->U4_FILIAL + TRB->U4_LISTA))
       		RecLock("SU6",.F.)
	   		SU6->U6_STATUS := "2"
	   		SU6->(MsUnLock())
     ENDIF
     
     TRB->(DbSkip())
ENDDO

//Atendimento Telemarketing CANCELADOS
cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName("SU4") +" SU4"
cQuery += " WHERE U4_STATUS = '1'"
cQuery += " AND U4_TIPO = '1'"
cQuery += " AND D_E_L_E_T_ <> '*'"
cQuery += " AND U4_CODLIG IN (	SELECT UC_CODIGO "
cQuery += "                     FROM " + RetSqlName("SUC") +" SUC"
cQuery += "  		  			WHERE UC_FILIAL = U4_FILIAL "
cQuery += "                     	AND UC_CODCANC <>  '  '"
cQuery += "                     	AND D_E_L_E_T_ <> '*')"

cQuery := ChangeQuery(cQuery)

If ( SELECT("TRB") ) > 0
	dbSelectArea("TRB")
	TRB->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "TRB"  


TRB->(DbGotop())
DO WHILE TRB->(!EOF())
     IF SU4->(DbSeek(TRB->U4_FILIAL + TRB->U4_LISTA))
     		RecLock("SU4",.F.)
	   		SU4->U4_STATUS := "2"
	   		SU4->(MsUnLock())
     ENDIF
     
     IF SU6->(DbSeek(TRB->U4_FILIAL + TRB->U4_LISTA))
       		RecLock("SU6",.F.)
	   		SU6->U6_STATUS := "2"
	   		SU6->(MsUnLock())
     ENDIF
     
     TRB->(DbSkip())
ENDDO

//Atendimento Telemarketing ENCERRADOS
cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName("SU4") +" SU4"
cQuery += " WHERE U4_STATUS = '1' "
cQuery += " AND U4_TIPO = '1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " AND U4_CODLIG IN (	SELECT UC_CODIGO "
cQuery += "                     FROM " + RetSqlName("SUC") +" SUC"
cQuery += "  		  			WHERE UC_FILIAL = U4_FILIAL "
cQuery += "                     	AND UC_STATUS = '3' "
cQuery += "                     	AND D_E_L_E_T_ <> '*') "

cQuery := ChangeQuery(cQuery)

If ( SELECT("TRB") ) > 0
	dbSelectArea("TRB")
	TRB->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "TRB" 


TRB->(DbGotop())
DO WHILE TRB->(!EOF())
     IF SU4->(DbSeek(TRB->U4_FILIAL + TRB->U4_LISTA))
     		RecLock("SU4",.F.)
	   		SU4->U4_STATUS := "2"
	   		SU4->(MsUnLock())
     ENDIF
     
     IF SU6->(DbSeek(TRB->U4_FILIAL + TRB->U4_LISTA))
       		RecLock("SU6",.F.)
	   		SU6->U6_STATUS := "2"
	   		SU6->(MsUnLock())
     ENDIF
     
     TRB->(DbSkip())
ENDDO


Return
