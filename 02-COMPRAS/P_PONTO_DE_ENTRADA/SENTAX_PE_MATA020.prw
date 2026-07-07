#include "totvs.ch"
#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MA020TDOK
PE para validar a inclusão/alteração do cadastro de Fornecedor

@author		dirlei@afsouza
@since		09/05/2019
@version	P12

@return		nil, nenhum

@type		function
/*/
User Function MA020TDOK()
    
local lRet := .T.        

// workflow inclusão/alteração
U_MCOM004()  

processa( {|| U_fExpFor('C') }, 'Aguarde', 'Exportando Fornecedor...' )


return lRet  
          


//-------------------------------------------------------------------
/*/{Protheus.doc} M020ALT
PE apos gravacao do cadastro do fornecedor
@author		Thiago Henrique dos Santos
@since		12/07/2019
@version	P12


/*/

User function M020ALT()  
Local cUsrblq:=Alltrim(supergetmv('ST_USRBLOQ',.f.,'000070/000217/000240' ))

if !(Alltrim(__cUserID) $ cUsrblq) 
	Reclock("SA2")
 	SA2->A2_MSBLQL := "1"
    SA2->(MsUnlock()) 
Endif



Return



	
