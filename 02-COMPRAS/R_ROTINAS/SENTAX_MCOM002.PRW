#INCLUDE "PROTHEUS.CH"    
#INCLUDE "TOPCONN.CH"                
//------------------------------------------------------------------- 
/*/{Protheus.doc} MCOM002()
Função para validar e não permitir realizar compra de item com valor unitário maior que o contido em tabela de preço do fornecedor
@param _cCodFor - Codigo do fornecedor
       _cLojFor - Loja do Fornecedor
       _cCodPro - Codigo do Produto
       _nvlrSC7 - Valor informado no item do pedido   
       colocar na validação de usuário do campo C7_PRECO
       u_MCOM002(cA120Forn,cA120Loj,GdFieldGet("C7_CODTAB"),M->C7_PRECO)   
       If(ExistBlock('MCOM002'),u_MCOM002(cA120Forn,cA120Loj,GdFieldGet("C7_CODPRO"),M->C7_PRECO),.T.)                                                                                     
@author Anderson Franco
@since 08/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------   
User Function MCOM002(_cCodFor,_cLojFor,_cCodPro,_nvlrSC7)  
Local _lRet := .T.
Local _aArea:= GetArea()
Local _cAlias := GetNextAlias()
Local _sdata := DTOS(dDatabase)
Local _sdtbranco:=''    

BeginSql Alias _cAlias
   SELECT AIB.AIB_FILIAL,AIB.AIB_CODPRO,AIA.AIA_CODTAB,AIB.AIB_PRCCOM FROM %Table:AIB% AIB, %Table:AIA%  AIA
		WHERE 
		((%Exp:_sdata% BETWEEN AIA.AIA_DATDE AND AIA.AIA_DATATE) OR (AIA.AIA_DATDE <=%Exp:_sdata% AND AIA.AIA_DATATE = %Exp:_sdtbranco%))  AND
		AIB.AIB_FILIAL = %xFilial:AIB% AND 
		AIB.AIB_FILIAL = AIA.AIA_FILIAL AND
		AIB.AIB_CODFOR = AIA.AIA_CODFOR AND
		AIB.AIB_LOJFOR = AIA.AIA_LOJFOR AND
		AIA.AIA_CODFOR = %Exp:_cCodfor% AND AIA.AIA_LOJFOR = %Exp:_cLojFor% AND 
		AIB.AIB_CODPRO = %Exp:_cCodPro% AND 
		AIB.%NotDel% AND
		AIA.%NotDel%
EndSql        
 
DbSelectArea(_cAlias)

(_cAlias)->(DbGoTop())


If !Empty((_cAlias)->AIA_CODTAB)
   If  _nvlrSC7 > (_cAlias)->AIB_PRCCOM          // SE PREÇO INFORMADO FOR MAIOR QUE O CONTIDO NA TABELA DE PREÇO NÃO PERMITE INCLUIR O ITEM
	   ShowHelpDlg("Aviso", {"Preço é MAIOR que o informado na tabela de preços.",""},5,{"Verifique, por favor!" ,""},5) 
	  _lRet:= .F.
   EndIf  
EndIf
				
RestArea(_aArea)
Return _lRet
 
