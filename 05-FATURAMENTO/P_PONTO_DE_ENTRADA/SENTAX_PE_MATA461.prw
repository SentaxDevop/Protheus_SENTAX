#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} M460MARK
O ponto de entrada M460MARK é utilizado para validar os pedidos marcados e está localizado no inicio da função 
a460Nota (endereça rotinas para a geração dos arquivos SD2/SF2).Será informado no terceiro parâmetro a série 
selecionada na geração da nota e o número da nota fiscal poderá ser verificado pela variável private cNumero.

@return 	lógico
@author 	Alessandro Smaha
@since 	 	18/03/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function M460MARK()
Local lRetOk := .T.

U_AFAT001() //verifica transportadora
	
lRetOk := U_AFAT002() //Valida faturamento parcial
   	
   	   	
Return lRetOk  
	
