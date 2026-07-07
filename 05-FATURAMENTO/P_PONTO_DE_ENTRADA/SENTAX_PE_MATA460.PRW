#INCLUDE "PROTHEUS.CH"


//---------------------------------------------------------------------------
/*/{Protheus.doc} M461LEG  
Altera os textos da legenda sobre o status da Nota Fiscal

@author  Leandro Natan Bonette Santos
@since   24/09/2014                    
@param   Array com a legenda padrão.
@return	 Array com as novas legenda para as novas cores do “browse”

/*/    
//---------------------------------------------------------------------------
User Function M461LEG()

	Local aCoresAnt := PARAMIXB     
	Local aCores    := {}	
	Local nI        := 0

	//Inclui a legenda em aberto antes para a ordem ficar correta	
	AAdd(aCores,{"BR_AMARELO"  ,"Pedido de Venda apto a faturar"})	  	

	For nI := 1 To Len(aCoresAnt)
	
		If !(aCoresAnt[nI][1] $ "ENABLE|BR_AZUL")		
		     AAdd(aCores,{aCoresAnt[nI][1],aCoresAnt[nI][2]})
		EndIf
	
	Next nI

	                     	
	AAdd(aCores,{"PMSTASK1"  ,"Bloqueio de Credito"})
	AAdd(aCores,{"BR_CANCEL" ,"Rejeitado na Liberacao do Credito"})
	AAdd(aCores,{"PMSEDT4"   ,"Bloqueio de Estoque"})
	AAdd(aCores,{"PMSEDT3"   ,"Bloqueio WMS"})	
	AAdd(aCores,{"BR_PINK"   ,"Bloqueio TMS"})	 

Return aCores    

//---------------------------------------------------------------------------
/*/{Protheus.doc} M461COR  
Altera cores do “browse” do cadastro sobre o status da Nota Fiscal

@author  Leandro Natan Bonette Santos
@since   24/09/2014                    
@param   Array com as cores padrões.
@return	 Array com as novas cores para o “browse”

/*/    
//---------------------------------------------------------------------------
User Function M461COR()

	Local aCoresAnt := PARAMIXB	
	Local aCores    := {}	
	Local nI        := 0	


	For nI := 1 To Len(aCoresAnt)

		/*
			Remove as legendas:
			
			Pedido de Venda em aberto (ENABLE)
			Pedido de Venda liberado (BR_AMARELO)
			Pedido de Venda com Bloqueio de Regra (BR_AZUL)
			Pedido de Venda com Bloqueio de Verba (BR_LARANJA)
			
		 */	       
		If !(aCoresAnt[nI][2] $ "ENABLE|BR_AZUL")		
			AAdd(aCores,{aCoresAnt[nI][1],aCoresAnt[nI][2]})		
		EndIf
	
	Next nI

	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '01'  ","BR_AMARELO" }) //01 - Apto a Faturar
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '02'  ","PMSEDT1"    }) //02 - Bloqueio por Regra
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '03'  ","PMSEDT2"    }) //03 - Bloqueio por Verba
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '04'  ","PMSTASK1"   }) //04 - Bloqueio de Crédito
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '05'  ","BR_CANCEL"  }) //05 - Rejeitado na Liberação do Credito
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '06'  ","PMSEDT4"    }) //06 - Bloqueio de Estoque
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '07'  ","PMSEDT3"    }) //07 - Bloqueio WMS
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '08'  ","BR_PINK"    }) //08 - Bloqueio TMS
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '09'  ","ENABLE"     }) //09 - Pedido em aberto
	
Return aCores

  
//-------------------------------------------------------------------
/*/{Protheus.doc} SF2460I
Ponto de entrada localizado após a atualização das tabelas referentes 
à nota fiscal (SF2/SD2), mas antes da contabilização. 
ATENÇÃO: Este ponto de entrada está dentro da transação na gravação 
das tabelas do documento.
                
@sample		U_SF2460I()

@return 	lógico

@author		Alessandro Smaha
@since		15/04/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function SF2460I()  

Local dDataVcto := DataValida(SF2->F2_EMISSAO+1,.T.) 

If FunName() <> "MATA310"

	If (Inclui .OR. Altera)
		DbSelectArea('SF6')
		SF6->(DbSetOrder(3))
		
		DbSelectArea('SE1')
		SE1->(DbSetOrder(1))
		
		If (SF6->(DbSeek(SF2->F2_FILIAL+'2'+SF2->F2_TIPO+SF2->F2_DOC+SF2->F2_SERIE)))
			DO WHILE SF6->(!EOF()) .AND. SF6->F6_FILIAL = SF2->F2_FILIAL .AND. SF6->F6_OPERNF == "2" .AND. SF6->F6_TIPODOC == SF2->F2_TIPO .AND. SF6->F6_DOC == SF2->F2_DOC .AND. SF6->F6_SERIE == SF2->F2_SERIE
			 
				Reclock('SF6', .F.)
				SF6->F6_DTVENC  := dDataVcto
				SF6->F6_DTPAGTO := dDataVcto
				SF6->(MsUnlock())
				
				If (SE2->(DbSeek(SF6->F6_FILIAL + SF6->F6_NUMERO)))
					Reclock('SE2', .F.)
					SE2->E2_VENCTO  	:= dDataVcto
					SE2->E2_VENCREA 	:= dDataVcto
					SE2->(MsUnlock())
				ENDIF
				
				SF6->(DbSkip())
			ENDDO
			
		EndIf
	EndIf

EndIf

Return .T.