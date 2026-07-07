#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------
/*/{Protheus.doc} F650VAR
Executado após carregar os dados do arquivo de recepcao bancária.
Utilizado para alterar os dados recebidos.

@author  Leandro Natan Bonette Santos
@since   24/04/2015
@return  Nil 

/*/
//--------------------------------------------------------------------------

User Function F650VAR()

	Local _cNumTit   := PARAMIXB[1][1] //Existe a variável Private cNumTit
	Local cCodOcorr  := AllTrim(PARAMIXB[1][13])
	Local cBanco     := MV_PAR03  
	Local aArea      := {}
	Local aAreaSE1   := {}  
	Local _cNossoNum := PARAMIXB[1][4] //Existe a variável Private _cNossoNum 
	Local cDtVenc    := ""     
	Local xBuffer    := PARAMIXB[1][14]


	If MV_PAR07 == 1
	
		//CNAB A RECEBER

		If cBanco == "104" .AND. ( Empty(AllTrim(_cNumTit)) .OR. SubStr(_cNumTit,1,10) == "0000000000" )
		
			/*
			 * Banco Caixa Econômica - Tratamento para ID CNAB vazio ou zeros
			 */                     
			 
			 cDtVenc := SubStr(xBuffer,74,8)
			 cDtVenc := SubStr(cDtVenc,5,4) + SubStr(cDtVenc,3,2) + SubStr(cDtVenc,1,2) //Inverte a Data de ddmmaaaa para aaaammdd
			 
			 BeginSql Alias "TMPSE1"
			 
			 	SELECT	E1_FILIAL,
			 			E1_CLIENTE,
			 			E1_LOJA,
			 			E1_PREFIXO,
			 			E1_NUM,
			 			E1_PARCELA,
			 			E1_TIPO,
			 			R_E_C_N_O_ RECSE1
			 			
			 	FROM	%Table:SE1%
			 	
			 	WHERE	E1_NUMBCO  = %Exp:_cNossoNum% AND
			 			E1_PORTADO = %Exp:"104"%      AND
			 			E1_VENCREA = %Exp:cDtVenc%    AND
			 			%NotDel%
			 						 
			 EndSql
			 
			 If TMPSE1->(!EoF())

				aArea    := GetArea()
				aAreaSE1 := SE1->(GetArea())

				DbSelectArea("SE1")
				SE1->(DbGoTo(TMPSE1->RECSE1))   
				cNumTit := AllTrim(SE1->E1_NUMBCO)
								
				
				RestArea(aAreaSE1)
				RestArea(aArea)
			 
			 EndIf                       
			 
			 TMPSE1->(DbCloseArea())     
					
		EndIf

		If cBanco == "341" .AND. cCodOcorr == "06"
		
			/*
		 	 * Banco Itaú e ocorrência 06-Liquidação Normal (Pagamento efetuado)
		 	 * Verifica se o título possui movimentação relacionada a uma compensação.
		 	 */
			aArea    := GetArea()
			aAreaSE1 := SE1->(GetArea())
		
			SE1->(DbSetOrder(19)) //ID CNAB		
			If SE1->(DbSeek(_cNumTit))
				
				BeginSql Alias "TMPSE5"			
					SELECT	E5_HISTOR 				
					FROM	%Table:SE5%				
					WHERE	E5_FILIAL  = %xFilial:SE5%			AND
							E5_PREFIXO = %Exp:SE1->E1_PREFIXO%	AND
							E5_NUMERO  = %Exp:SE1->E1_NUM%		AND
							E5_PARCELA = %Exp:SE1->E1_PARCELA%	AND
							E5_CLIFOR  = %Exp:SE1->E1_CLIENTE%	AND
							E5_LOJA    = %Exp:SE1->E1_LOJA%		AND
							E5_TIPODOC = %Exp:"CP"%				AND
							E5_MOTBX   = %Exp:"CMP"%			AND                          
							%NotDel%									
				EndSql
				
				If TMPSE5->(!EoF())			
					cOcorr := "X1 " //Troca a ocorrência para X1-Título com compensação			
				EndIf
				
				TMPSE5->(DbCloseArea())
						
			EndIf
	
			RestArea(aAreaSE1)
			RestArea(aArea)
		
		EndIf	
			
		If cBanco == "001"
			nDespes +=VAL(substr(xBuffer,189,13))/100
		EndIF
	EndIf

Return
