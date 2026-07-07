#include 'protheus.ch'
#include 'parmtype.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK011
Deleta linha de itens quando operação for atendimento
@author Thiago Henrique dos Santos
@since 02/02/2018
@version p12
/*/
//-------------------CHAMADA TELA PRINCIPAL------------------------------------------------
user function ATMK011()
Local nI := 0 
Local lRet := .t.
If M->UA_OPER == "3"
	For nI := 1 to len(aCols)
	
		aCols[nI][len(aHeader)+1] := .T.
	
	Next
	
	Eval(bGDRefresh)

Endif	
	
return lRet