#include 'totvs.ch'
#include 'protheus.ch'
//------------------------------------------------------------------------------
/*/{Protheus.doc} MFAT011
Rotina para busca do custo médio do fechamento do estoque para o campo C6_PRECO. 

@author		Dirlei@afsouza
@since		21/01/2019
@version	P12

@return		nCusto, numerico, custo do produto

@type		function
/*/
//--------------------------------------------------------------------------------
user function MFAT011()
	
local dDtFecha := GetMV('MV_ULMES') // data fechamento estoque
local lOk      := .t.
local nI       := 1
local cProduto := ''
local cLocal   := ''
local nCusto   := 0

for nI := 1 to len(aCols)

	cProduto := GDFieldGet('C6_PRODUTO',nI)
	cLocal   := GDFieldGet('C6_LOCAL',nI)

	if empty(cProduto)
		MsgAlert('Deve ser informado o campo Produto.','Custo Produto')
		lOk := .f.
	elseif empty(cLocal)
		MsgAlert('Deve ser informado o campo Armazém.','Custo Produto')
		lOk := .f.
	endif

	if lOk
		// busca custo médio fechamento
		if !empty(cProduto) .and. !empty(cLocal)
			nCusto := Posicione('SB9',1,xFilial('SC6') + cProduto + cLocal + dtos(dDtFecha),'B9_CM1') //B9_FILIAL + B9_COD + B9_LOCAL + DTOS(B9_DATA)
		else
			MsgAlert('Não foi possível localizar o custo do produto'+ alltrim(GDFieldGet('C6_DESCRI',nI)),'Custo Produto')
		endif

		GDFieldPut('C6_PRCVEN',nCusto,nI)
		if nCusto > 0
			//MsgInfo('Campo Preço Unit. atualizado!','Custo Produto')
		else
			MsgAlert('Custo do item '+ alltrim(GDFieldGet('C6_DESCRI',nI)) +' não foi localizado!','Custo Produto')
		endif
	endif

next

MsgInfo('Campo Preço Unit. atualizado!','Custo Produto')

return