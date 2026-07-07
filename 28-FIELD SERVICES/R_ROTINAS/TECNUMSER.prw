#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

//----------------------------------------------------------------------------------------
//Verifica o próximo número de série para a auto numeração na inclusão da OS
//Essa regra de auto numeração da série só funciona para os produtos que NÃO
//SÃO MÁQUINAS, portanto GRUPO diferente de MAQ. Para esses existe um número de série.
//
//Solicitante: Fabiano Guadagnin
//Raphael D. PILATTI
//31/10/2012
//Rotina foi refeita para utilizar o mesmo número do produto como nr de série para os casos de equipamentos.
//AFS - 07/02/2014
//-----------------------------------------------------------------------------------------
User Function TECNUMSER(cCodPro,cSerNum,cCodCli,cCodLoj)  
    
	Local aArea   := GetArea()
	Local cCodigo := ""     
	Local cGrpPrOk:= Alltrim(SuperGetMv("ST_XGRPPRO", .T., ""))
	
	Default cSerNum := ""
	Default cCodCli := ""
	Default cCodLoj := ""

	If SB1->(DbSeek(xFilial("SB1")+cCodPro)) 
	
		If Empty(cSerNum)
		     
			If SB1->B1_GRUPO $ cGrpPrOk
				 
				cCodigo := Alltrim(StrZero(Val(cCodCli),6) + StrZero(Val(cCodLoj),2) + Substr(Alltrim(cCodPro),1,12)) // SB1->B1_COD
				
			Else   
			
				cCodigo := ""
			
			EndIf		
		
		Else   
		
			cCodigo := cSerNum
		
		EndIf
	
	Else 
		
		cCodigo := cSerNum
	
	EndIf
		
Return(cCodigo)
