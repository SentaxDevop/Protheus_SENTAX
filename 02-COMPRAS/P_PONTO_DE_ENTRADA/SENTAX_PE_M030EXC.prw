#INCLUDE "PROTHEUS.CH"
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} M030EXC
APÓS CONFIRMAR A EXCLUSÃO 
Este P.E. será executado após o usuário confirmar a exclusão; 
Depois da execução do mesmo, será feita a exclusão efetiva dos dados do Cliente no arquivo

@author Jair Matos
@since 19/01/2015
@version P11
@return Nil
/*/
//---------------------------------------------------------------------------------------------------
User Function M030EXC()

Local cNomeUser	:= UsrRetName(__cUserID)
Local cHoraBase  := Left(Time(),5)

//gravando o usuario, data e hora da ultima alteração
Reclock( "SA1" , .F.)
SA1->A1_XDTALT 	:= dDatabase
SA1->A1_XUSRALT := cNomeUser
SA1->A1_XHRALT 	:= cHoraBase
MsUnlock()
Return