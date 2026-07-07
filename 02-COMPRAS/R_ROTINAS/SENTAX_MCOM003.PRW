#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MCOM003
Gatilho executado na inclusão do código do fornecedor no pedido de compra
e documento de entrada
	
@author	Leandro Natan Bonette Santos
@since	28/07/2014
@param	cCodigo, caracter, codigo do fornecedor
@param	cLoja, caracter, codigo da loja
@param	cCpoRet, caracter, campo do produto (SB1) a ser retornado

@return	cRet, valor do campo com base no parametro cCpoRet

/*/
//-------------------------------------------------------------------------------
User Function MCOM003(cCodigo,cLoja,cCpoRet)

	Local aArea    := GetArea()
    Local aAreaSA5 := SA5->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())
	
	Local cRet := ""  
	Local cVar := &(ReadVar())
	
	DEFAULT cCodigo := ""  
	DEFAULT cLoja   := ""   
	DEFAULT cCpoRet := "" 
	
	SB1->(DbSetOrder(1))
	SA5->(DbSetOrder(14))	 //A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF, R_E_C_N_O_, D_E_L_E_T_
                       

	If SA5->(DbSeek(xFilial("SA5")+cCodigo+cLoja+cVar))

		cRet := POSICIONE("SB1",1,XFILIAL("SB1")+SA5->A5_PRODUTO,cCpoRet)
				         
	EndIf

	RestArea(aAreaSA5)	
	RestArea(aAreaSB1)
	RestArea(aArea)
    
Return cRet
