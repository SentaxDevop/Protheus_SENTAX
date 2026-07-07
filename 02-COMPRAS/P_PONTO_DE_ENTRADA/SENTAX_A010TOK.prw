#include "totvs.ch"
#include "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} A010TOK
PE para validar a inclus�o/altera��o do cadastro de produto

@author		Thiago Henrique dos Santos
@since		08/07/2019
@version	P12

@return		nil, nenhum

@type		function
/*/
user function A010TOK()
    
local lRet := .T. 
Local cUsrblq:=Alltrim(supergetmv('ST_USRBLOQ',.f.,'000070/000217/000240' ))

// workflow inclus�o/altera��o
//U_MCOM004()  

Processa( {|| U_fExpProd('A') }, 'Aguarde', 'Exportando Produto...' )

return lRet
