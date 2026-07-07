#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} MFAT004
Inicializador do campo Descrição da Zona

@author	Leandro Natan Bonette Santos
@since  24/07/2014
@param  cCliente, caracter, código do cliente
@param  cLoja, caracter, código da loja
@return	cZonaDesc, descrição da zona

*/
//-------------------------------------------------------------------
User Function MFAT004(cCliente,cLoja)

	Local cZonaDesc := ""
	
	Local aArea    := GetArea()
	Local aAreaDA5 := DA5->(GetArea())
	Local aAreaDA7 := DA7->(GetArea())
	
	DEFAULT cCliente := SC5->C5_CLIENTE
	DEFAULT cLoja    := SC5->C5_LOJACLI
	                    
	DA5->(DbSetOrder(1))
	DA7->(DbSetOrder(2))
	
	If DA7->(DbSeek(xFilial("DA7")+cCliente+cLoja))	
		cZonaDesc := POSICIONE("DA5",1,XFILIAL("DA5")+DA7->DA7_PERCUR,"DA5_DESC")	
	Else		
		cZonaDesc := "SEM ZONA CADASTRADA"			
	EndIf
	  
	RestArea(aAreaDA5)
	RestArea(aAreaDA7)
	RestArea(aArea)
	
Return cZonaDesc