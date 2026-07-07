#INCLUDE "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} F380CPOS
Ponto de entrada F380CPOS permite alterar a ordem dos campos 
dos registros que serao apresentados na selecao para 
conciliacao bancaria.
                
@sample		U_F380CPOS()
@author		Débora Friebe
@since		13/10/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function F380CPOS()

Local aCamposPE := {}   

aCamposPE := { 	{ "E5_OK"  		 ,, "Rec." },; 
	            { "E5_RECPAG"   ,, "REC/PAG"},;   
				{ "E5_DTDISPO"   ,, "DATA"},;
		        { "E5_VALOR"     ,, "VALOR",PesqPict("SE5","E5_VALOR",19)},;
				{ "E5_NUMERO"   ,, "NUMERO DOC"},;
			    { "E5_NUMCHEQ"   ,, "CHEQUE"},;
				{ "E5_BENEF"   ,, "BENEFICIARIO"},;
				{ "E5_HISTOR"   ,, "HISTORICO"},;
				{ "E5_CLIFOR"	  ,, "Cli/For"},;  
				{ "E5_LOJA" 	  ,, "Loja"} ,;
                { "E5_FILIAL" 	  ,, "Filial"}} 
					
Return aCamposPE

