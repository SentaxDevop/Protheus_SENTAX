#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDEF.ch'

Static __oModel

/*/{Protheus.doc} FINA460
Ponto de entrada no modelo de dados FINA460A	(liquidacao de titulos a receber)

@author  Thiago Henrique dos Santos
@since   31/01/2017
/*/
user function FINA460A()

Local xRet := .T. 
Local aParam     := PARAMIXB
Local oObj       := ''
Local oModel 	 := nil
Local cIdPonto   := ''
Local cIdModel   := ''
Local nOperation := 0
Local oTit
Local oParc
Local oCab
Local aArea := GetArea()
Local aAreaSE1 
Local nI
Local cNum := ""

If aParam <> NIL

	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3]
	oModel 	   := oObj:GetModel()
	nOperation := oModel:GetOperation()
	
	
	IF cIdPonto == 'MODELCOMMITTTS' .and. (nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE)
		oTit 	:= oModel:GetModel( "TITSELFO1" )
		oParc	:= oModel:GetModel( "TITGERFO2" )
		oCab 	:= oModel:GetModel( "MASTERFO0" )
		
		DbSelectArea("SE1")
		aAreaSE1 := SE1->(GetArea())
		
		SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		
		For nI := 1 to oParc:Length()
			oParc:GoLine(nI)
			If !oParc:IsDeleted()
					
				cNum := PadL(Alltrim(oParc:GetValue("FO2_NUM")),TamSx3("E1_NUM")[1],'0')
				IF SE1->(DbSeek(xFilial("SE1")+oParc:GetValue("FO2_PREFIX")+cNum+oParc:GetValue("FO2_PARCEL")+oCab:GetValue("FO0_TIPO")))				
					
					RecLock("SE1",.f.)					
					SE1->E1_XFORMA := oCab:GetValue("FO0_XFORMA")
					SE1->(MsUnlock())										
		
				Endif
					
			Endif
		Next nI		
		
		SE1->(RestArea(aAreaSE1))		
		RestArea(aArea)
		
		
	Endif	

Endif
	
return xRet
