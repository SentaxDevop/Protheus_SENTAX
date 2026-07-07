#INCLUDE 'PROTHEUS.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK001
Rotina para calcular o preço ótimo, chamada pelo CallCenter
                
@sample		U_ATMK001()

@return 	Nil

@author		Alessandro Smaha
@since		10/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ATMK001( lRetorna, lAltItem, nValUni)
	                    
	Local aAreaSA1  := GetArea("SA1")
	Local aAreaSB1  := GetArea("SB1")
	Local aAreaSF4  := GetArea("SF4")
	Local aAreaDA1  := GetArea("DA1")
	Local cCodPro	:= "" 
	Local cTesUti	:= ""
	Local nQuantd	:= 0 
	Local nValTot	:= 0  
	Local nValISt	:= 0  
	Local nValTot2	:= 0
	Local nValUni2	:= 0 
	Local nValVend	:= 0
	Local nPercent	:= 0
	Local nImposto	:= 0  
	Local nLinha 	:= 0
	Local nPosPro 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_PRODUTO" })
	Local nPosQtd 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_QUANT" })
	Local nPosVun 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VRUNIT" }) 
	Local nPosTot 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VLRITEM" })  
	Local nPosTes 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_TES" })   
	Local nPValDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VALDESC" })  
	Local nPosVen	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_XPRCVEN" })  
	Local aColsAux	:= aClone(aCols)
	
	Default lRetorna := .F.
	Default lAltItem := .F.
	Default nValUni  := 0
		  
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
		
	DbSelectArea("SB1")  
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1)) // F4_FILIAL+F4_CODIGO	 
		
	DbSelectArea("DA1")
	DA1->(DbSetOrder(1)) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
	
	If !Empty(nPosPro) .AND. !Empty(nPosQtd) .AND. !Empty(nPosVun) .AND. !Empty(nPosTot) 
	
		SA1->(DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
	
		// Atualiza o valor do suframa na mão, pois quando é Televendas
		// off-line, esse valor está desatualizado.                    
		Tk273Refresh(.T.)

		// Recalcula o item para garantir os impostos de acordo com a quantidade informada se houver desconto da SUFRAMA 
		If MaFisFound()
			               
			For nLinha := 1 To Len(aCols)                            
				
				If lAltItem .AND. nLinha <> n 
				 	Loop	
				EndIf
						
		 		If ! aCols[nLinha][Len(aHeader)+1] // Não deletado   
								
					cCodPro := Alltrim(aCols[nLinha][nPosPro])
					nQuantd := aCols[nLinha][nPosQtd]
					
					If lRetorna .AND. !Empty(M->UA_TABELA)	
						If Empty(nValUni)
							If DA1->(DbSeek(xFilial("DA1")+M->UA_TABELA+cCodPro))
								nValUni := DA1->DA1_PRCVEN
							Else
						 		nValUni := 0 
							EndIf  
						EndIf												
					Else				
						nValUni := aCols[nLinha][nPosVun]
					EndIf 
					
					nValTot := aCols[nLinha][nPosTot]
					nValVen := aCols[nLinha][nPosVen]
					cTesUti := Alltrim(aCols[nLinha][nPosTes])		
					
					If SB1->(DbSeek(xFilial("SB1")+cCodPro))    
					
						If SF4->(DbSeek(xFilial("SF4")+cTesUti))
							
							If ! lRetorna // Verifica se retorna os valores dos itens ou calcula imposto para novos valores unitários
								
				    			nImposto := MaFisRet(nLinha,"IT_VALSOL")  
				    
								If ! Empty(nImposto) .AND. nValVen == nValUni
										
								    nPercent := nImposto * 100 / (nValTot + nImposto)
								    
								    nValTot2 := nValTot - ( nValTot * nPercent / 100 )
									nValUni2 := nValTot2 / nQuantd  
									
									aCols[nLinha][nPosVun] := nValUni2
																
								EndIf
								
							Else
							
								aCols[nLinha][nPosVun] := nValUni
								aCols[nLinha][nPosVen] := nValUni
								
							EndIf
									
						   	MaFisAlt("IT_QUANT"		,aCols[nLinha][nPosQtd]	,nLinha)
							MaFisAlt("IT_PRCUNI"	,aCols[nLinha][nPosVun]	,nLinha)
							MaFisAlt("IT_VALMERC"	,aCols[nLinha][nPosTot]	,nLinha)
						       
							// Recalcula o item para garantir os impostos de acordo com a quantidade informada se houver desconto da SUFRAMA ³
							//If aValores[SUFRAMA] > 0 
								Tk273Recalc(nLinha,.T.)
							//Endif
			
							If nPValDesc > 0 .And.	nPosTes > 0	
								If aCols[nLinha][nPValDesc] > 0 .And. !Empty(aCols[nLinha][nPosTes]) 
									SF4->(dbSetOrder(1))
									SF4->(dbseek(xFilial("SF4")+aCols[nLinha][nPosTes]))
									If SF4->F4_IPI == "S" .And. SF4->F4_TPIPI == "B"
										MaFisAlt("IT_BASEIPI",MaFisRet(nLinha,"IT_BASEIPI") + aCols[nLinha][nPValDesc],nLinha)			
									EndIf
								EndIf
							EndIf 
						EndIf		
					EndIf
				EndIf			
			Next nLinha                           
			
			Eval(bListRefresh)

		Endif
			    
	EndIf
	
	M->UA_XRECALC := .F.
	
	If !lAltItem // Verifica se foi chamado no gatilho ou pelo botão preço ótimo.
		For nLinha := 1 to Len(aCols)	
			If ! aCols[nLinha][Len(aHeader)+1] .AND. aColsAux[nLinha][nPosVun] <> aCols[nLinha][nPosVun]		
				M->UA_XPRECOT := .T.			
			EndIf	
		Next nLinha
	EndIf
		
    RestArea(aAreaSA1)
    RestArea(aAreaSB1)
    RestArea(aAreaSF4)  
    RestArea(aAreaDA1)
    
Return Nil        


//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK001G
Rotina chamada pelo gatilho para atualizar flag de recalculo de itens
                
@sample		U_ATMK001G()

@return 	Nil

@author		Alessandro Smaha
@since		10/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ATMK001G(xConteudo,xCampo)
               
	Default xCampo := "" 
	
	If xCampo == "UB_VRUNIT"
		U_ATMK001(.T.,.T.,xConteudo) 
	Else
		U_ATMK001(.T.,.T.)
	EndIF
        
	M->UA_XRECALC := .T.

Return xConteudo


//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK001V
Rotina chamada por PE para validação total e atualização de itens, 
caso necessário
                
@sample		U_ATMK001V()

@return 	Nil

@author		Alessandro Smaha
@since		10/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ATMK001V(lRetOk)   

	If M->UA_XPRECOT // Foi clicado em preço otimo ? 
	
		If M->UA_XRECALC // Foi atualizado após clicar em preço ótimo ?  
		
			If MsgYesNo("O atendimento foi alterado e será necessário refazer os calculos!"+chr(13)+chr(10)+chr(13)+chr(10)+;
						"Confirma a operação ? ","Atenção") 
			
				U_ATMK001(.T.)
				lRetOk := .F.
				M->UA_XRECALC := .F.
				
			Else
			
				lRetOk := .F.  
				
			EndIf			
				
		EndIf
	
	EndIf

Return lRetOk