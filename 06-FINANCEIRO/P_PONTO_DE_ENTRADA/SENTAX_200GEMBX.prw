#INCLUDE "PROTHEUS.CH"
      
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 200GEMBX
O ponto de entrada 200GEMBX tratará os valores dos títulos na rotina de retorno da 
comunicação bancária.

@author  Leandro Natan Bonette Santos
@since   20/03/2016
@return  uRet, nulo

/*/
//------------------------------------------------------------------------------------------  
User Function 200GEMBX()
      
	Local cIdCnab := AllTrim(PARAMIXB[1][1])  
	Local xBuffer := AllTrim(PARAMIXB[1][16]) 
	Local _cCodOc := AllTrim(PARAMIXB[1][14])
	
	If cBanco == "104" .AND. Empty(cIdCnab) .AND. !Empty(xBuffer)
		
		cNumTit := "XXXXXXXXXX"			
		
	EndIf   
	
	If cBanco == "104" .AND. _cCodOc == "28"
		nDespes := 0.0
	EndIf
	
Return