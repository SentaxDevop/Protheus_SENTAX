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



User Function MA020ROT()
Local aRet := {}

Aadd( aRet, { "CyberLog - Envia Fornecedor WMS"	, "processa( {|| U_fExpFor('M') }, 'Aguarde', 'Exportando Fornecedor...' )"		, 0 , 4,0 ,NIL} )


Return aRet

