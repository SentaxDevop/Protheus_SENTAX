
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc}  
 Tela para informacao de mensagens para nota.
@author  Henrique Baldin
@since   12/01/2015
@return  
/*/    
User Function SF1100I()

// Atualiza registro 
RecLock("SF1",.F.)
SF1->F1_HORA := Time()
MsUnlock()


Return