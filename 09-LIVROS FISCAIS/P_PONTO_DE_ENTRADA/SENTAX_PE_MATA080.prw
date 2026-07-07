#include "totvs.ch"
#include "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MA080VLD
PE para validar a inclusão/alteração do cadastro de TES

@author		dirlei@afsouza
@since		09/05/2019
@version	P12

@return		nil, nenhum

@type		function
/*/
user function MA080VLD()
    
local lRet := .T.
Local cUsrblq:=Alltrim(supergetmv('ST_USRBLOQ',.f.,'000070/000217/000240' ))

// workflow inclusão/alteração
U_MCOM004()  

if !(Alltrim(__cUserID) $ cUsrblq)
     M->F4_MSBLQL := "1"
Endif
  



return lRet
	
