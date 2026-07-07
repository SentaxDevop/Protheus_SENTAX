#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} AFIS001
Função para validar a DATA DE do grupo de perguntas do reprocessamento.
     
@sample		U_AFIS001()

@return 	lRetOk - Condição que não deva ser processada no reprocessamento dos livros fiscais de entrada.

@author		Alessandro Smaha
@since		05/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AFIS001()
 
Local lRetOk 	:= .T.    
Local dDataPar 	:= GETNEWPAR( "ST_DTCORRF", CtoD("//") )
 
If FunName() $ "MATA930|MATA959"
	 
	If ! Empty(dDataPar)
		
		If MV_PAR01 < dDataPar   
		
			MsgInfo(	"A data do parâmetro DATA DE ? ("+DtoC(MV_PAR01)+") é menor que a data do parâmetro ST_DTCORRF ("+DtoC(dDataPar)+")."+;
						chr(13)+chr(10)+chr(13)+chr(10)+"A data do parâmetro DATA DE ? vai assumir a data do parâmetro ST_DTCORRF.","Aviso") 
			
			MV_PAR01 := dDataPar 
		     
		EndIf
	
	EndIf	

EndIf

Return lRetOk