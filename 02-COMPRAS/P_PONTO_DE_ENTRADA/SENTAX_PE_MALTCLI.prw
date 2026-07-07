#INCLUDE "PROTHEUS.CH"
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MALTCLI
Ponto de entrada pertence à rotina de cadastro de clientes.Executado após a gravação das alterações.

@author Jair Matos
@since 19/01/2015
@version P11
@return Nil
/*/
//---------------------------------------------------------------------------------------------------
User Function MALTCLI()

Local cNomeUser	:= UsrRetName(__cUserID)
Local cHoraBase  := Left(Time(),5)

//gravando o usuario, data e hora da ultima alteração
Reclock( "SA1" , .F.)
SA1->A1_XDTALT 	:= dDatabase
SA1->A1_XUSRALT := cNomeUser
SA1->A1_XHRALT 	:= cHoraBase  

if U_StIsBlq() .and. nModulo != 6
	SA1->A1_MSBLQL := "1"
Endif
MsUnlock()

Return
