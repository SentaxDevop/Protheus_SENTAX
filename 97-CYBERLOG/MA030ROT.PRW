#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "FWPRINTSETUP.CH" 
#INCLUDE "APWEBEX.CH"
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------------------
/*/{Protheus.doc} MA030ROT
Ponto de Entrada para adicionar novas funções no Botão Outras Ações do Browser
@type function
@author Carlos CLeuber
@since 09/12/2020
@version 1.0
/*/
User Function MA030ROT()
	Local aRet := {} 

	Aadd( aRet, { "CyberLog - Envia Cliente WMS"	, "processa( {|| U_fExpCli('M') }, 'Aguarde', 'Exportando Cliente...' )"		, 0 , 4,0 ,NIL} )	
	
Return aRet


