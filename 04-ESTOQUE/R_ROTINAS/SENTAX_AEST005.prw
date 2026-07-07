#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005
Chamada em Batch do Refaz Acumulado

@author  Leandro Natan Bonette Santos
@since   27/10/2016
@return  uRet, nulo

/*/
//-------------------------------------------------------------------------------
User function AEST005()

	Conout("[AEST005] - Iniciando o Refaz Acumulado")	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101"	
	MATA215(.T.)		
	RESET ENVIRONMENT
	Conout("[AEST005] - Finalizando a execução do Refaz Acumulado")

return