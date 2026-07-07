//----------------------------------------------------------
//Preenche a natureza do item conforme a operação (UB_OPER)
//----------------------------------------------------------
#include "totvs.ch"

User Function FATA1001()
Local aArea   := GetArea()
Local cNat    := ""
Local cTeProd := GETMV("MV_TPPROD")
Local cTeServ := GETMV("MV_TPSERV")
Local cTeLoca := GETMV("MV_TPLOCA")
Local cTeVema := GETMV("MV_TPVEMA")
Local cTePerm := GETMV("MV_TPPERM")
Local _nField := GDFieldPos("UB_OPER")
Local _cOPer  := aCols[n][_nField]
		
/*If INCLUI
	If M->UB_OPER $ cTeProd  	  	//VENDA DE MERCADORIASsuel
		cNat := "10101"
	Elseif M->UB_OPER $ cTeLoca		//LOCACAO DE MAQUINAS
		cNat := "10103"	
	Elseif M->UB_OPER $ cTeServ		//RECEITA DE SOCIOS
		cNat := "10109"
	Elseif M->UB_OPER $ cTeVema		//VENDA DE MAQUINAS
		cNat := "10110"
	Elseif M->UB_OPER $ cTePerm		//PERMUTA
		cNat := "10111"		
	Endif	
Else*/
	If _cOPer $ cTeProd    	//VENDA DE MERCADORIAS
		cNat := "10101"
	Elseif _cOPer $ cTeLoca	//LOCACAO DE MAQUINAS
		cNat := "10103"	
	Elseif _cOPer $ cTeServ	//RECEITA DE SOCIOS
		cNat := "10109"
	Elseif _cOPer $ cTeVema	//VENDA DE MAQUINAS
		cNat := "10110"
	Elseif _cOPer $ cTePerm	//PERMUTA
		cNat := "10111"		
	Endif
//EndIf
                                   
RestArea(aArea)

Return(cNat)   
