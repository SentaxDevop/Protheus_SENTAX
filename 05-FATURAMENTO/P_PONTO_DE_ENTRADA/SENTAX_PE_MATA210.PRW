/*/{Protheus.doc}  
 Ponto-de-Entrada: FT210LIB - Liberação de pedido de venda
 Este ponto de entrada é executado após a liberação do pedido de venda bloqueado por regra de negócio. 
 Somente o pedido de venda esta posicionado no momento da execução do ponto de entrada e na mesma transação da operação do sistema.
@author  Anderson Roberto Franco de Souza
@since   24/10/2013
@return  
/*/    
User Function FT210LIB()

	Local _aArea := GetArea()
	Local oObj   := TSalesOrderBlockingByRules():New()

	If SC5->C5_LIBEROK == "S"  
		
		SC5->(RecLock("SC5",.F.))     
		SC5->C5_XDTLIOK := DATE()
		SC5->C5_XHRLIOK := TIME()
		SC5->(MsUnlock())
		
		
	EndIf       
	SC5->(RecLock("SC5",.F.))  
	SC5->C5_XOBSLIB:=AllTrim(SC5->C5_XOBSLIB)+FUNNAME()+"-"+DTOC(DATE())+"-"+TIME()+";"
	SC5->(MsUnlock())          

	//------------------------------------------------------------
	// Informa o usuário, data e hora da liberação da REGRA
	//------------------------------------------------------------
	RecLock("SC5",.F.)
	SC5->C5_XULIBRG := RetCodUsr()
	SC5->C5_XDLIBRG := Date()
	SC5->C5_XHLIBRG := Time()
	SC5->C5_LIBEROK := "S"
	MsUnlock()
	//------------------------------------------------------------

	//------------------------------------------------------------
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))    
	SC6->(DbGoTop())
	SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM,.T.))
	While SC6->(!Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM	
		//Posiciona na liberação na SC9
		dbSelectArea("SC9")
		SC9->(dbSetOrder(1)) 
		SC9->(DbGoTop())
		If SC9->(dbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.T.))
			//limpa a flag ZZ
//			RecLock('SC9',.F.)
//			SC9->(DbDelete())//C9_BLCRED := '  '
//			MSUnlock()
			//estonar a liberação/reserva de estoque
			SC9->(a460Estorna())  //->>>> estva dando EOF na SC6 
			//passa pelo processo de liberação padrão			
//			DbSelectArea('SB2')
//			SB2->(DbSetOrder(1))			
//			SB2->(DbGoTop())   
//			IF SB2->(DbSeek(xFilial('SB2')+SC6->C6_PRODUTO+SC6->C6_LOCAL))
//				RecLock('SB2',.F.)
//			    SB2->B2_RESERVA :=SB2->B2_RESERVA-SC6->C6_QTDVEN
//			    SB2->B2_SALPEDI :=SB2->B2_SALPEDI+SC6->C6_QTDVEN
//				MsUnlock()
//			EndIf
		EndIF                                        
		MaLibDoFat(SC6->(Recno()),SC6->C6_QTDVEN,.T.,.T.,.T.,.T.,.F.,.T.,,)
		SC6->(dbSkip())
	Enddo

	//Atualizao status de liberação na tabela de log
	oObj:cRequestNumber := SC5->C5_NUM
	oObj:cRequestFilial := SC5->C5_FILIAL
	oObj:UpdateLog()

	RestArea(_aArea)

Return                 
                     
