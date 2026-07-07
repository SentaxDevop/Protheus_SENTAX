#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
Static __lBloq := .F.
//-------------------------------------------------------------------
/*/{Protheus.doc} MA030TOK
O ponto de entrada MA030TOK ï¿½ utilizado para validar a inclusï¿½o e alteraï¿½ï¿½o do cadastro de clientes

@return 	lï¿½gico
@author 	Patrï¿½cia Barros
@since 	 	24/04/2015
@version 	P11
/*/
//-------------------------------------------------------------------    
User Function MA030TOK()             
Local bCampoSA1 := { |x| SA1->(Field(x)) }      
Local cCpoSA1   := Alltrim("A1_BAIRRO/A1_BAIRROC/A1_BAIRROE/A1_EST/A1_COD_MUN/A1_ESTC/A1_ESTE/A1_XCDMUEN/A1_REGIAO/A1_MUNE/A1_XDESREG/A1_DDD/A1_CEP/A1_CEPC/A1_CEP/A1_TEL/A1_SIMPLES/A1_SIMPNAC/A1_VEND/A1_NVESTN/A1_NOMVEND/A1_XTELEVE/A1_ATEND/A1_X_PISCA/A1_CONTATO/A1_XGRTELE" )
Local lRet      := IIf(M->A1_EST == 'EX', Empty(M->A1_CGC),!Empty(M->A1_CGC)) 
Local nX 		:= 1

__lBloq := .F.

if altera
	For nX := 1 to FCount()
		If !(M->&( eVal( bCampoSA1, nX) ) == SA1->&( eVal( bCampoSA1, nX)))
			if !(Alltrim(eVal( bCampoSA1, nX)) $ cCpoSA1)
				__lBloq := .T.

			Endif
		EndIf				
	Next nX 
Endif
	
If !lRet 
	Alert("CNPJ INVÁLIDO OU NÃO PREENCHIDO.")     
ElseIf   M->A1_MSBLQL =='1' .AND. Empty(M->A1_XFINCON)
	If SA1->A1_MSBLQL <> '1'
		lRet:= .F.         	
		Alert("INFORME O MOTIVO DO BLOQUEIO CADASTRAL.")
	Endif
Endif
	
//obriga a digitação do grupo de cliente quando a inscriçã estadual é diferente de branco
If !Empty(Alltrim(M->A1_INSCR)) .AND. Alltrim(M->A1_INSCR) != 'ISENTO'
	If Empty(Alltrim(M->A1_GRPTRIB))
		lRet := .F.
		Alert('Informe o Grupo de Clientes')
	EndIf
EndIf

// workflow inclusão/alteração   	
U_MCOM004() 

Processa( {|| U_fExpCli('C') }, 'Aguarde', 'Exportando Cliente...' )
   	   	   	
Return lRet  

	
//-------------------------------------------------------------------
/*/{Protheus.doc} StIsBlq
Retorna variavel static de bloqueio de cliente

@return 	lógico
@author 	Thiago Henrique dos Santos
@since 	 	18/07/2019
@version 	P11
/*/
//-------------------------------------------------------------------    
User Function StIsBlq()


Return __lBloq
