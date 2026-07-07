#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------------
/*/{Protheus.doc} MFAT005
Verifica o status do pedido para exibição da legenda

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@param	 cPedido, caracter, número do pedido de venda
@return	 cRet, código do status do pedido

@description

Retorna os seguintes códigos 

01 - Apto a Faturar
02 - Bloqueio por Regra
03 - Bloqueio por Verba
04 - Bloqueio de Crédito
05 - Rejeitado na Liberação do Credito
06 - Bloqueio de Estoque
07 - Bloqueio WMS
08 - Bloqueio TMS   
09 - Pedido em aberto

/*/    
//---------------------------------------------------------------------------
User Function MFAT005(cPedFil,cPedido,cItem)

	Local aArea    := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC9 := SC9->(GetArea())

	Local cRet := ""	

	DEFAULT cItem := ""

	If Empty(cPedFil) .OR. Empty(cPedido) 
		Return ""	
	EndIf

	If Empty(cItem)
	
		/*
		 * Liberação por pedido
		 */
		cRet := fTLibPedido(cPedFil,cPedido)
	
	Else
	
 		/*
 		 * Liberação por item
 		 */                
	 	cRet := fTLibItem(cPedFil,cPedido,cItem)	
	 	
	EndIf
              	
	RestArea(aAreaSC9)
	RestArea(aAreaSC5)
	RestArea(aArea)
			
Return cRet


//---------------------------------------------------------------------------
/*/{Protheus.doc} fTLibPedido
Verifica o status do pedido em sua totalidade

@author  Leandro Natan Bonette Santos
@since   15/09/2014
@param	 cPedFil, caracter, filial do pedido
@param	 cPedido, caracter, numero do pedido
@return	 cRet, código do status do pedido - ver função U_MFAT005

/*/    
//---------------------------------------------------------------------------
Static Function fTLibPedido(cPedFil,cPedido)
	
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(cPedFil+cPedido))

		//--------------------------------------------------------------------------------------
		// Bloqueio de regra
		//--------------------------------------------------------------------------------------
		If SC5->C5_BLQ == '1' 
			Return "02"
		EndIf
		//--------------------------------------------------------------------------------------
		
		
		//--------------------------------------------------------------------------------------
		 // Bloqueio por verba       		
		//--------------------------------------------------------------------------------------		
		If SC5->C5_BLQ == '2'
			Return "03"		
		EndIf
		//--------------------------------------------------------------------------------------
		

		//--------------------------------------------------------------------------------------
		// Bloqueado na liberação de crédito		
		//--------------------------------------------------------------------------------------
		BeginSql Alias "TMPQRY"			
			SELECT	DISTINCT COUNT(*) TOTAL
			FROM	%Table:SC9%				
			WHERE	C9_FILIAL = %Exp:cPedFil%	AND 
					C9_PEDIDO = %Exp:cPedido%	AND 
					C9_BLCRED = %Exp:'09'%		AND
					%NotDel%			
		EndSql			
		If TMPQRY->TOTAL > 0	
			TMPQRY->(DbCloseArea())
			Return "05"
		EndIf
		TMPQRY->(DbCloseArea())
		//--------------------------------------------------------------------------------------
		

		//--------------------------------------------------------------------------------------
		// Bloqueado Crédito		
		//--------------------------------------------------------------------------------------		
		BeginSql Alias "TMPQRY"			
			SELECT	DISTINCT COUNT(*) TOTAL											
			FROM	%Table:SC9%				
			WHERE	C9_FILIAL  = %Exp:cPedFil%	AND 
					C9_PEDIDO  = %Exp:cPedido%	AND 
					C9_BLCRED <> %Exp:'  '%		AND 
					C9_BLCRED <> %Exp:'09'%		AND 
					C9_BLCRED <> %Exp:'10'%		AND 
					C9_BLCRED <> %Exp:'ZZ'%		AND
					%NotDel%
		EndSql
		If TMPQRY->TOTAL > 0	
			TMPQRY->(DbCloseArea())
			Return "04"
		EndIf
		TMPQRY->(DbCloseArea())			
		//--------------------------------------------------------------------------------------


		//--------------------------------------------------------------------------------------
		// Bloqueado Estoque		
		//--------------------------------------------------------------------------------------
		BeginSql Alias "TMPQRY"			
			SELECT	DISTINCT COUNT(*) TOTAL							
			FROM	%Table:SC9%			
			WHERE	C9_FILIAL  = %Exp:cPedFil%	AND 
					C9_PEDIDO  = %Exp:cPedido%	AND 
					C9_BLEST  <> %Exp:'  '%		AND 
					C9_BLEST  <> %Exp:'10'%		AND 
					C9_BLEST  <> %Exp:'ZZ'%		AND
					%NotDel%
		EndSql
		If TMPQRY->TOTAL > 0	
			TMPQRY->(DbCloseArea())
			Return "06"			
		EndIf
		TMPQRY->(DbCloseArea())
		//--------------------------------------------------------------------------------------
		
			
		//--------------------------------------------------------------------------------------				
		// Item Bloqueado WMS		
		//--------------------------------------------------------------------------------------
		BeginSql Alias "TMPQRY"			
			SELECT	DISTINCT COUNT(*) TOTAL 
			FROM	%Table:SC9%				
			WHERE	C9_FILIAL  = %Exp:cPedFil%	AND 
					C9_PEDIDO  = %Exp:cPedido%	AND 
					C9_BLWMS  <= %Exp:'05'%		AND
					C9_BLWMS  <> %Exp:'  '%		AND
					%NotDel%
		EndSql
		If TMPQRY->TOTAL > 0	
			TMPQRY->(DbCloseArea())
			Return "07"			
		EndIf		
		TMPQRY->(DbCloseArea())
		//--------------------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------------------
		// Bloqueado TMS		
		//--------------------------------------------------------------------------------------
		BeginSql Alias "TMPQRY"			
			SELECT	DISTINCT COUNT(*) TOTAL
			FROM	%Table:SC9% 			
			WHERE	C9_FILIAL  = %Exp:cPedFil%	AND 
					C9_PEDIDO  = %Exp:cPedido%	AND 
					C9_BLTMS  <> %Exp:'  '%		AND
					%NotDel%
		EndSql
		If TMPQRY->TOTAL > 0	
			TMPQRY->(DbCloseArea())
			Return "08"			
		EndIf		
		TMPQRY->(DbCloseArea())
		//--------------------------------------------------------------------------------------

		//--------------------------------------------------------------------------------------
		// Bloqueado TMS		
		//--------------------------------------------------------------------------------------
		BeginSql Alias "TMPQRY"			
			SELECT	DISTINCT COUNT(*) TOTAL
			FROM	%Table:SC9% 			
			WHERE	C9_FILIAL  = %Exp:cPedFil%	AND 
					C9_PEDIDO  = %Exp:cPedido%	AND
					C9_XSTAWMS = 'O'		AND
					%NotDel%
		EndSql
		If TMPQRY->TOTAL > 0	
			TMPQRY->(DbCloseArea())
			Return "10"			
		EndIf		
		TMPQRY->(DbCloseArea())




		//--------------------------------------------------------------------------------------
		// Pedido em aberto
		//--------------------------------------------------------------------------------------
		If Empty(SC5->C5_LIBEROK) .AND. Empty(SC5->C5_NOTA) .AND. Empty(SC5->C5_BLQ)		   
		   Return "09"		
		EndIf
		//--------------------------------------------------------------------------------------

		//--------------------------------------------------------------------------------------
		// Apto a faturar
		//--------------------------------------------------------------------------------------
		If !Empty(SC5->C5_LIBEROK) .AND. Empty(SC5->C5_NOTA) .AND. Empty(SC5->C5_BLQ)
			Return "01"
		EndIf
		//--------------------------------------------------------------------------------------
							
	EndIf
	
Return ""


//---------------------------------------------------------------------------
/*/{Protheus.doc} ftLibItem
Verifica o status do item do pedido de venda

@author  Leandro Natan Bonette Santos
@since   15/09/2014
@param	 cPedFil, caracter, filial do pedido
@param	 cPedido, caracter, numero do pedido
@param   cItem, caracter, item do pedido
@return	 cRet, código do status do pedido - ver função U_MFAT005

/*/    
//---------------------------------------------------------------------------
Static Function ftLibItem(cPedFil,cPedido,cItem)
      
	SC9->(DbSetOrder(1))
	If SC9->(DbSeek(cPedFil+cPedido+cItem))



		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(cPedFil+cPedido))

			//--------------------------------------------------------------------------------------
			// Bloqueio de regra
			//--------------------------------------------------------------------------------------
			If SC5->C5_BLQ == '1' 
				Return "02"
			EndIf
			//--------------------------------------------------------------------------------------
			
			
			//--------------------------------------------------------------------------------------
			 // Bloqueio por verba       		
			//--------------------------------------------------------------------------------------		
			If SC5->C5_BLQ == '2'
				Return "03"		
			EndIf
			//--------------------------------------------------------------------------------------

	    
		EndIf
	
		//--------------------------------------------------------------------------------------
		// Bloqueado na liberação de crédito		
		//--------------------------------------------------------------------------------------		
		If SC9->C9_BLCRED == '09'
			Return "05"
		EndIf
		//--------------------------------------------------------------------------------------		



		//--------------------------------------------------------------------------------------
		// Bloqueado Crédito
		//--------------------------------------------------------------------------------------
		If !SC9->C9_BLCRED == '  ' .AND. SC9->C9_BLCRED <> '09' .AND. SC9->C9_BLCRED <> '10' .AND. SC9->C9_BLCRED <> 'ZZ'
			Return "04"
		EndIf
		//--------------------------------------------------------------------------------------				
		
		//--------------------------------------------------------------------------------------				
		// Bloqueado Estoque
		//--------------------------------------------------------------------------------------				
		If SC9->C9_BLEST <> '  ' .AND. SC9->C9_BLEST <> '10'.AND. SC9->C9_BLEST <> 'ZZ'
			Return "06"			
		EndIf
		//--------------------------------------------------------------------------------------				

		//--------------------------------------------------------------------------------------				
		// Bloqueado WMS
		//--------------------------------------------------------------------------------------				
		If SC9->C9_BLWMS  <= '05' .AND. SC9->C9_BLWMS  <> '  '
			Return "07"			
		EndIf
		//--------------------------------------------------------------------------------------				

		//--------------------------------------------------------------------------------------				
		// Bloqueado TMS		
		//--------------------------------------------------------------------------------------				
		If SC9->C9_BLTMS  <> '  ' 			     	
			Return "08"			
		EndIf
		//--------------------------------------------------------------------------------------				

		
		//--------------------------------------------------------------------------------------				
		// Bloqueado TMS		
		//--------------------------------------------------------------------------------------				
		If SC9->C9_XSTAWMS  == 'O'
			Return "10"			
		EndIf
		//--------------------------------------------------------------------------------------				



		//--------------------------------------------------------------------------------------				
		// Se nao caiu em nenhum das condições acima, assume que o item esteja liberado
		//--------------------------------------------------------------------------------------				
		Return "01"
		//--------------------------------------------------------------------------------------				

	EndIf
	
Return ""
                                           