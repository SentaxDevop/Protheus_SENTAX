#INCLUDE "PROTHEUS.CH"    
#INCLUDE "TOPCONN.CH"                
//------------------------------------------------------------------- 
/*/{Protheus.doc} MT340D3()
Ponto de Entrada se encontra logo após a geração de movimento no SD3 
para acerto do inventário. 
A tabela SD3 ainda está com lock de registro.

@param cMsg - String de mensagem de log

@author Alessandro Smaha 
@since 27/02/2015
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function MT340D3() 

	If FunName() == "MATA340"
	
   		Replace D3_XSSALDO With SB2->B2_QATU // CalcEst("H0001779547 ","01",Stod("20150126")+1)[1]
   		
 	EndIf
		
Return