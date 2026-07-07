#INCLUDE "PROTHEUS.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} ACOM002
Job para execução do nFácil

@author		Alessandro Smaha
@since 		08/12/2015
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
User Function ACOM002()  
                
Local cEmpFert	:= ""
Local cFilFert	:= ""
Local aEmpFil	:= { "01010101", "01020201" } // Informar as empresas desta forma: { "0101", "0105", "0107" }
Local nK		:= 0

For nK := 1 to Len(aEmpFil)
 
	cEmpFert := Substr(aEmpFil[nK],1,2)
	cFilFert := Substr(aEmpFil[nK],3,6)
	
	U_NFAC011( cEmpFert, cFilFert )

Next nK

Return