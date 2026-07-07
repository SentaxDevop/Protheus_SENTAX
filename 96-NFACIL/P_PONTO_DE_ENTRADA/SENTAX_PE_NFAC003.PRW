#INCLUDE "PROTHEUS.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} NFA003MN
Ponto de Entrada para incluir ou tratar rotinas no menu
                
@sample		U_NFA003MN()

@author		Alessandro Smaha
@since		15/01/2016
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function NFA003MN()

Local aTempRot 	:= PARAMIXB[1]

aAdd( aTempRot, { "Sentax NF-e", "U_ACOM003", 0, 2 }) 

Return aTempRot
