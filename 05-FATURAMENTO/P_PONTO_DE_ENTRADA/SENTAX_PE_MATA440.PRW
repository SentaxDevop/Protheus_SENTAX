#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------------
/*/{Protheus.doc} MA440COR 
O ponto de entrada MA440COR possibilita alterar as regras das cores do browse
na liberação dos pedidos de vendas.

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 aRet, array com as cores para o "browse"

/*/    
//---------------------------------------------------------------------------
User Function MA440COR()

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
		If !(aCoresAnt[nI][2] $ "ENABLE|BR_AMARELO|BR_AZUL|BR_LARANJA")		
			AAdd(aCores,{aCoresAnt[nI][1],aCoresAnt[nI][2]})		
		EndIf
	
	Next nI


	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '01'  ","BR_AMARELO" }) //01 - Apto a Faturar
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '02'  ","PMSEDT1"    }) //02 - Bloqueio por Regra
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '03'  ","PMSEDT2"    }) //03 - Bloqueio por Verba
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '04'  ","PMSTASK1"   }) //04 - Bloqueio de Crédito
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '05'  ","BR_CANCEL"  }) //05 - Rejeitado na Liberação do Credito
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '06'  ","PMSEDT4"    }) //06 - Bloqueio de Estoque
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '07'  ","PMSEDT3"    }) //07 - Bloqueio WMS
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '08'  ","BR_PINK"    }) //08 - Bloqueio TMS
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '09'  ","ENABLE"     }) //09 - Pedido em aberto    
	


Return aCores
   
