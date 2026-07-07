//------------------------------------------------------------------- 
/*/{Protheus.doc} MTEC002
Rotina chamada pelo campo AB2_MEMO2 para nao permitir usuários sem permissão para alterar o comentário.

@author Alessandro Smaha 
@since 04/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function MTEC002() 

	Local lRetOk := .T.  
	Local cCodUsr := RetCodUsr() 
	Local cUsrMstr:= SuperGetMv("ST_XUSRMST", .T., "")
	
	If !cCodUsr $ cUsrMstr
		lRetOk := .F.	
	EndIf
	
Return lRetOk