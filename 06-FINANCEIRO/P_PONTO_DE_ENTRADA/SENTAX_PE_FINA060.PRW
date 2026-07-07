#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F060VLOK
Permite validar as informações na tela onde são informados os parâmetros para geração
do borderô a receber
	
@author    Leandro Natan Bonette Santos
@since     18/09/2015	
@return    lRet, valida se o processo será realizado

/*/
//-------------------------------------------------------------------------------------
User Function F060VLOK()
                   
	Local cBanco   := PARAMIXB[2]
	Local cAgencia := PARAMIXB[3]
	Local cConta   := PARAMIXB[4]
	
	Local aArea    := GetArea()
	Local aAreaSA6 := SA6->(GetArea())
	
	Local lRet := .T.
	
	SA6->(DbSetOrder(1))
	
	If SA6->(DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
	
		If SA6->A6_XCTGRTA == "1"  
		
			ShowHelpDlg("CTAGARANT",{"Não é possível gerar um borderô para uma conta garantida"},1,;
			                       {"Selecione outro banco"})		     
			                       
			lRet := .F.
		
		EndIf
			
	EndIf

   	
	RestArea(aAreaSA6)
	RestArea(aArea)

Return lRet
