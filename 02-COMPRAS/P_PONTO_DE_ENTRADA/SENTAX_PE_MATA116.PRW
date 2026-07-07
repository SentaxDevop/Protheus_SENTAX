#INCLUDE "PROTHEUS.CH"
//---------------------------------------------------------------------
/*/{Protheus.doc} MT116AGR
Ponto de Entrada da Nota de Conhecimento de Frete responsável 
pela inclusão de notas de conhecimento de frete.
Após a gravação da NF de conhecimento de frete fora da transação.

@author 	Alessandro Smaha
@since 		14/01/2016
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
User Function MT116AGR() 
 
// Atualiza o status do xml CT-e ingrado
U_NFAC025(4)

Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} M116ACOL
Este ponto de entrada tem o objetivo de permitir a manipulação do 
aCols que será carregado para cada documento de entrada selecionado 
pela rotina de Conhecimento de Frete.
@description Possibilita identificar o documento que está sendo processado, 
para adicionar campos customizados pré-existentes no ambiente com 
seus conteúdos preenchidos no aCols do conhecimento de frete.

@author 	Alessandro Smaha
@since 		17/05/2016
@version 	P11 || P12

@return 	Nil, nenhum

@type function
/*/
//------------------------------------------------------------------------------
User Function M116ACOL()

// Atualiza valores ICMS
U_NFAC036I(ParamIXB)
	
Return 
