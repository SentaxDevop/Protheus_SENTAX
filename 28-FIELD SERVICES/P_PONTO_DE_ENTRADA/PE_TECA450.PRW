#INCLUDE "PROTHEUS.CH"    
#INCLUDE "TOPCONN.CH"                
//------------------------------------------------------------------- 
/*/{Protheus.doc} TC450ROT()
Ponto de entrada para a inclusão de rotinas de usuário, na barra de 
menu da rotina de Ordem de Serviço, do módulo de Gestão de Serviços.
O ponto de entrada deverá devolver um array nos mesmos moldes do 
array aRotina utilizado pela browse.

@author		Alessandro Smaha 
@since		20/06/2014
@version	P11 
/*/ 
//-------------------------------------------------------------------
User Function TC450ROT()

Local aRotAdic:= {}

aAdd(aRotAdic, { "Impressão P.V.",'U_RTEC002O', 0 , 2} )
aAdd(aRotAdic, { "Impressão O.S.",'U_RTEC006P', 0 , 2} )

Return aRotAdic