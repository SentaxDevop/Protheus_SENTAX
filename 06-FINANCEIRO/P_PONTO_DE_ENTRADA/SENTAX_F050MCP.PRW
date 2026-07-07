//-------------------------------------------------------------------
/*/{Protheus.doc} F050MCP
Este ponto de entrada permite incluir novos campos na opção Alterar da rotina FINA050. 
Será executado ao exibir a tela após clicar no botão Alterar da rotina FINA050. 
Desta forma, os campos que forem incluidos por este Ponto de Entrada também poderão ser editados na opçao Alterar.     
ATENÇÃO! A alteração da data de vencimento do titulo pode afetar os titulos já contabilizados
assim como os titulos criados automaticamente pelas rotinas geradoras. 

@author 		Patrícia Barros
@since 	 		27/04/2016
@version 		P11
@Solicitante	Jorge
/*/
//-------------------------------------------------------------------

#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 

User Function F050MCP() 

Local aCampos := PARAMIXB 

IF SE2->E2_SALDO == SE2-> E2_VALOR 
     AADD(aCampos,"E2_VENCTO") 
     AADD(aCampos,"E2_VENCREA")      

ELSE
	ALERT ("VENCIMENTO NÃO PODERÁ SER ALTERADA DEVIDO TITULO ESTAR BAIXADO PARCIALMENTE")

ENDIF

Return aCampos 