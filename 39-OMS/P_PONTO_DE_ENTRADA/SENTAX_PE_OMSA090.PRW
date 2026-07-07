#INCLUDE "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} OMSA090
Ponto de entrada Cadastro de Pontos
                
@sample		OMSA090()

@author		Alessandro Smaha
@since		03/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function OMSA090() 

Local aParam 	:= PARAMIXB  
Local xRet 		:= .T.
Local oObj 		:= ""
Local cIdPonto	:= ""
Local cIdModel 	:= ""

If aParam <> NIL 

	oObj     := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]

	If cIdPonto == 'MODELCOMMITNTTS' // Após a gravação total do modelo e fora da transação
		
		If oObj:GetOperation() == 3 .OR. oObj:GetOperation() == 4 // Inclusão ou alteração
			                 
			aAreaSA1 := SA1->(GetArea())
			aAreaDA7 := DA7->(GetArea())
			
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA  
			
			DbSelectArea("DA7")
			DA7->(DbSetOrder(1)) // DA7_FILIAL+DA7_PERCUR+DA7_ROTA+DA7_SEQUEN  
		
			cPercRot := DA7->(DA7_PERCUR+DA7_ROTA)   
			
			If DA7->(DbSeek(xFilial("DA7")+cPercRot))  
			
				While !DA7->(Eof()) .AND. xFilial("DA7") == DA7->DA7_FILIAL .AND. cPercRot == DA7->(DA7_PERCUR+DA7_ROTA) 
				      
					If SA1->(DbSeek(xFilial("SA1")+DA7->DA7_CLIENT+DA7->DA7_LOJA)) 

						RecLock("SA1",.F.)
							SA1->A1_XENTPRO := "2" // 1=Não; 2=Sim
						SA1->(MsUnLock())
					
					EndIf
				
					DA7->(DbSkip()) 
				EndDo  
			
			EndIf 
			
			RestArea(aAreaSA1)
   			RestArea(aAreaDA7)
		
		EndIf
		
	EndIf   
	
EndIf  
		
Return xRet