#INCLUDE "PROTHEUS.CH"
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} M030INC
Ponto de entrada chamado após a inclusão dos dados do cliente no Arquivo.

@author Jair Matos
@since 19/01/2015
@version P11
@return Nil
/*/
//---------------------------------------------------------------------------------------------------
User Function M030INC()
Local nOpcao := PARAMIXB
Local cNomeUser	:= UsrRetName(__cUserID)
Local cHoraBase  := Left(Time(),5)
   
//gravando o usuario, data e hora da inclusao  de novo cliente.
If nOpcao == 1 //Inclusao

	If !Empty(Alltrim(SA1->A1_INSCR)) .AND. Alltrim(SA1->A1_INSCR) != 'ISENTO'
		If Empty(Alltrim(SA1->A1_GRPTRIB))
			Alert('O grupo de clientes estava em branco e foi preenchido com CON!')
			Reclock( "SA1" , .F.)		
			SA1->A1_GRPTRIB := 'CON'
			MsUnlock()
		EndIf
	EndIf


	Reclock( "SA1" , .F.)
	SA1->A1_XDTALT 	:= dDatabase
	SA1->A1_XUSRALT := cNomeUser
	SA1->A1_XHRALT 	:= cHoraBase
	MsUnlock()
EndIF

Return
