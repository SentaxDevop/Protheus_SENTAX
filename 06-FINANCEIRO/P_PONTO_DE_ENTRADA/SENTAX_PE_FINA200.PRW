#INCLUDE "PROTHEUS.CH"
              
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F200DB1
Ponto de entrada executado após gravar as despesas bancárias no SE5
	
@author  Leandro Natan Bonette Santos
@since   09/09/2015
@return  uRet, nil

/*/
//------------------------------------------------------------------------------------------------
User Function F200DB1()

	Local aArea    := GetArea()
	Local aAreaSEE := SEE->(GetArea())
	Local aAreaSA6 := SA6->(GetArea())

	If !Empty(SEE->EE_XPCOD) .AND. !Empty(SEE->EE_XMAGENC) .AND. !Empty(SEE->EE_XMNUMCT)
	     	                                                                                 
		If SA6->(DbSeek(xFilial("SA6")+SEE->EE_XPCOD+SEE->EE_XMAGENC+SEE->EE_XMNUMCT))
                      
			//Atualiza o número da agência/conta da conta garantida para a principal
			If SA6->A6_COD == "341" .OR. SA6->A6_COD == "104"
				RecLock("SE5",.F.)
				SE5->E5_BANCO   := SA6->A6_COD
				SE5->E5_AGENCIA := SA6->A6_AGENCIA
				SE5->E5_CONTA   := SA6->A6_NUMCON
				MsUnlock()         
			EndIf
		
		EndIf
	
	EndIf

	RestArea(aAreaSA6)
	RestArea(aAreaSEE)
	RestArea(aArea)
		
Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F200PORT
Ponto de entrada utilizado para definir o banco a ser utilizado na baixa do título
no retorno CNAB a Receber
	
@author  Leandro Natan Bonette Santos
@since   09/09/2015      
@return  lRet, .T. - Utiliza portador do título, ignorando banco do retorno CNAB (Padrão)
               .F. - Utiliza banco do retorno CNAB

/*/
//------------------------------------------------------------------------------------------------
User Function F200PORT()

	Local lRet := .T.

	If !Empty(SEE->EE_XPCOD) .AND. !Empty(SEE->EE_XMAGENC) .AND. !Empty(SEE->EE_XMNUMCT)
	
		lRet := .F.		
		
	EndIf

Return lRet
                           
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA200
Executado antes da gravação dos dados dos títulos que serão baixados
	
@author  Leandro Natan Bonette Santos
@since   09/09/2015      
@return  uRet, nil

/*/
//------------------------------------------------------------------------------------------------
User Function FINA200()

	If !Empty(SEE->EE_XPCOD) .AND. !Empty(SEE->EE_XMAGENC) .AND. !Empty(SEE->EE_XMNUMCT)
		
		If cBanco == "341"
			//Tratamento para conta garantida que não está considerando as despesas corretamente
			//gerando baixas parciais	
			nValRec := nValRec + nDespes
		EndIf
		
	EndIf

Return                          
