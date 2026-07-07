#Include "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} FATM1001
Rotina para validar grupo de produtos "NAO USAR".

@author  Alessandro Smaha
@since   28/03/2014
@return  NIL
/*/
//-------------------------------------------------------------------
User Function FATM1001(cCodGrp)    

	Local lRetOk := .T.

	If !Empty(cCodGrp)
	         
		DbSelectArea("SBM")
		SBM->(DbSetOrder(1))
		If SBM->(DbSeek(xFilial("SBM")+cCodGrp))
			If Substr(Alltrim(SBM->BM_DESC),1,8) == "NAO USAR"                                                           
				lRetOk := .F.
				MsgAlert("O grupo "+Alltrim(cCodGrp)+" - "+Alltrim(SBM->BM_DESC)+" pertence ao grupo não usar!","Atenção")	
			EndIf
		EndIf    
	
	EndIf

Return lRetOk