#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

User Function LOGBLQ()
          
IF M->A1_MSBLQL = '1'
  
 MSGBOX("Contatar logistica para desbloqueio"," ","INFO")
EndIf               

Return(.T.)
