
/*/{Protheus.doc}  
 Ponto-de-Entrada: MTA455I - Liberação de estoque    
 APOS GRAVAR LIBERACAO DE ESTOQUE 
 Executado apos atualizacao dos arquivos na liberacao de estoque
 Ponto de entrada MTA455I criado para gravar a data e hora da liberação do pedido FINAL nos campos customizados C5_XDTLIOK e C5_XHRLIOK
@author  Anderson Roberto Franco de Souza
@since   24/10/2013
@return  
/*/    
User Function MTA455I()
Local _aArea:=GetArea()

If SC5->C5_LIBEROK == "S"  
   
   	SC5->(RecLock("SC5",.F.))     
	SC5->C5_XDTLIOK := DATE()
	SC5->C5_XHRLIOK := TIME()
	SC5->(MsUnlock())
	
EndIf       

SC5->(RecLock("SC5",.F.))  
SC5->C5_XOBSLIB:=AllTrim(SC5->C5_XOBSLIB)+FUNNAME()+"-"+DTOC(DATE())+"-"+TIME()+";"
SC5->(MsUnlock())     

If FUNNAME() == "MATA455"
	//------------------------------------------------------------
	// Informa o usuário, data e hora da liberação do ESTOQUE
	//------------------------------------------------------------
	RecLock("SC5",.F.)
	SC5->C5_XULIBET := RetCodUsr()
	SC5->C5_XDLIBET := Date()
	SC5->C5_XHLIBET := Time()
	MsUnlock()
	//------------------------------------------------------------
EndIf

     
RestArea(_aArea)
Return

          

//---------------------------------------------------------------------------
/*/{Protheus.doc} MA455COR  
Este ponto de entrada pertence à rotina de liberação de credito e estoque
e liberação de estoque, MATA455() e MATA450. Usado, em conjunto com os pontos 
M450LEG e MA450COR, para alterar cores do “browse” do cadastro, que representam 
o “status” do pedido. 

Formato do item do array de cores {“condição”, “cor”}.

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 aRet, Array com as cores para o "browse"

/*/    
//---------------------------------------------------------------------------
User Function MA455COR()

	Local aCoresAnt := PARAMIXB 
	Local aCores    := {}                                     	
	Local nI        := 0
	
	For nI := 1 To Len(aCoresAnt)
	
		If !(aCoresAnt[nI][2] $ "BR_AZUL|BR_PRETO|BR_AMARELO|BR_LARANJA|ENABLE")		
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

Return aCores     
