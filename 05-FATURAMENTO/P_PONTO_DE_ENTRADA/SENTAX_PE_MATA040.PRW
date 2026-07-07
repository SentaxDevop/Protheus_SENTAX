#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MA040DAL
Ponto de Entrada que irá alterar o campo de nome de vendedor da SA1.
                
@sample		U_MA040DAL()

@author		Felipe Toazza Caldeira
@since		14/10/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function MA040DAL()  
       
TcSqlExec("UPDATE "+RetSqlName('SA1')+" SET A1_NOMVEND = '"+SA3->A3_NOME+"' WHERE A1_FILIAL = '"+xFilial('SA1')+"' AND A1_VEND = '"+SA3->A3_COD+"' AND D_E_L_E_T_ != '*' ")
	
Return 