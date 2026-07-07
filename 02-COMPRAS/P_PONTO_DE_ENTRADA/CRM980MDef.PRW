#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//==================================================================================================//
//	Programa: CRM980MDef	|	Autor: Luis 								|	Data: 18/07/2022	//
//==================================================================================================//
//	Descrição: PE para add itens ao menu do cad clientes.											//
//																									//
//==================================================================================================//
User Function CRM980MDef()
Local aRotina := {}
//----------------------------------------------------------------------------------------------------------
// [n][1] - Nome da Funcionalidade
// [n][2] - Função de Usuário 
// [n][3] - Operação (1-Pesquisa; 2-Visualização; 3-Inclusão; 4-Alteração; 5-Exclusão)
// [n][4] - Acesso relacionado a rotina, se esta posição não for informada nenhum acesso será validado
//----------------------------------------------------------------------------------------------------------
aAdd(aRotina,{"CyberLog - Envia Cliente WMS","processa( {|| U_fExpCli('M') }, 'Aguarde', 'Exportando Cliente...' )",MODEL_OPERATION_UPDATE,0})
//Aadd( aRotina, { "CyberLog - Envia Cliente WMS"	, "processa( {|| U_fExpCli('M') }, 'Aguarde', 'Exportando Cliente...' )"		, 0 , 4,0 ,NIL} )

Return( aRotina )
