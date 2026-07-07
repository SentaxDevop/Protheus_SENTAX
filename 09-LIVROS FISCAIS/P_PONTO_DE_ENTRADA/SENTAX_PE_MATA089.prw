#include "totvs.ch"
#include "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MT089TOK
PE para validar a inclusão/alteração do cadastro de TES Inteligente

@author		dirlei@afsouza
@since		09/05/2019
@version	P12

@return		nil, nenhum

@type		function
/*/
user function MT089TOK()
    
local lRet := .T. 
Local cUsrblq:=Alltrim(supergetmv('ST_USRBLOQ',.f.,'000070/000217/000240' ))

// workflow inclusão/alteração
U_MCOM004()  

if !(Alltrim(__cUserID) $ cUsrblq)
     M->FM_MSBLQL := "1"
Endif


return lRet
	
