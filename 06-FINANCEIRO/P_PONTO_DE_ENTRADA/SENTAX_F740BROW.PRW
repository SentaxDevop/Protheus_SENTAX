//-------------------------------------------------------------------
/*/{Protheus.doc} F740BROW
Ponto de entrada para filtrar dados a serem exibidos na rotina "Funções de Contas a Receber"

@return 	Nil
@author 	Alfred Andersen
@since 	 	21/01/2016
@version 	P11
/*/
//-------------------------------------------------------------------

User Function F740BROW()

Local _aDados := aRotina

//Verifica se usuário participa do grupo de Administradores
_nRet := PswAdmin("","", __cUserID)


IF _nRet == 0 .OR. __cUserID $ GetNewPar("MV_XFIN740","") //Se usuário é do grupo de Administradores ou está presente no parâmetro
	Return
ELSE
	ADEL(_aDados[5][2],3) //Remove botão Cancelar da rotina "Transf/Borderô"
	ASize(_aDados[5][2],(Len(_aDados[5][2])-1)) //Reorganiza Array
	aRotina := _aDados //Retorna novo conteúdo para o aRotina
ENDIf


Return