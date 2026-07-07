//-------------------------------------------------------------------------------
/*/{Protheus.doc} FA080BCO
Ponto de entrada para validar banco da baixa contas a pagar

@return 
@author Felipe Toazza Caldeira
@since 17/03/2017

/*/
//-------------------------------------------------------------------------------
#include "totvs.ch"
#include "protheus.ch"               

User Function FA080BCO()
Local lRet := .T.

	DbSelectArea('SA6')
	SA6->(DbSetOrder(1))
	SA6->(DbGoTop())  
	IF SA6->(DbSeek(xFilial('SA6')+cBAnco+cAgencia+cConta))
		If !Empty(Alltrim(SA6->A6_XFILIAL)) .AND. SubSTr(SA6->A6_XFILIAL,1,4) != SubSTr(cFilAnt,1,4)
			Alert('Este banco/agencia/conta não pode ser utilizado nesta filial!')
			lRet := .F.		
		EndIf	
	EndIf	
Return lRet