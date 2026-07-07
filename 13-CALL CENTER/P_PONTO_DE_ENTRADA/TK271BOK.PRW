//---------------------------------------------------------------------------------------------
//Verifica se o estoque dos itens digitados ainda esta disponivel na confirmação do atendimento
//ou foi utilizado neste perído, não peritindo a confirmação do pedido
//---------------------------------------------------------------------------------------------
#include "protheus.ch"
#include "topconn.ch"

User Function TK271BOK(nOpc)
Local aArea     := GetArea()
Local _lRet     := .T.
Local _lField   := 0
Local _cProd    := ""
Local _nSaldo   := 0
Local _cItem    := ""
Local _aProd    := {}
Local _cDescri  := ""
Local _cTes     := ""
Local _lEstoque := "S"
Local _nI       := 0
Local _nX		:= 0
Local nI		:= 0


If FUNNAME() == "TMKA271" .or. nFolder == 2 //TELEVENDAS

	If !INCLUI .And. ALTERA

		If cFilAnt == "020201" .And. !Empty(M->UA_NUMSC5)

			SC5->(DbSetOrder(1))
			SC5->(DbGoTop())
			IF SC5->(DbSeek(M->UA_FILIAL+M->UA_NUMSC5))

				If SC5->C5_XSTAWMS <> "R" .And. !Empty(SC5->C5_XSTAWMS)
					
					If IsBlind()
						cLogTxt := "[TK271BOK - 01] - Alteração não permitida! Separação já iniciada no Cyberlog!"
						Conout(cLogTxt)		
					Else
						Help( NIL, NIL,"TK271BOK01", NIL, "Alteração não permitida! Separação já iniciada no Cyberlog!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Realize o alinhamento com a Expedição"})
					End

					Return .F.

				End

			EndIf 

		End
		
	End

	//Obrigado a digitar os dados para lista de contatos RS 20/07/2017
	IF !u_ATMK007A()
		RETURN .F.
	EndIF

	//Não permitir alteração do pedido quando estiver com Status igual a Atendimento
	IF M->UA_NUM = POSICIONE("SUA",11,xFilial("SUA") + M->UA_NUM + M->UA_CLIENTE + M->UA_LOJA ,"UA_NUM")    //Simboliza uma alteração.
		If M->UA_OPER == "3"
			If IsBlind()
				cLogTxt := "Atenção, Atendimento com status de ATENDIMENTO, só é permitida a visualização !!! - [TK271BOK]"
				Conout(cLogTxt)		
			Else
				MsgStop("Atenção, Atendimento com status de ATENDIMENTO, só é permitida a visualização !!!")
			End
			return(.F.)
		Endif
	ENDIF
	
	If M->UA_OPER <> "1"
		Return(_lRet)
	Endif
	
	If Alltrim(aCols[1][2]) == " "
		Return(_lRet)
	Endif
	
	For _nI := 1 to Len(aCols)
		If aCols[n,Len(aHeader)+1]
			Loop
		Endif
		
		
		If !(TkGetTipoAte() $ "2/4/5")
			exit
		EndIF
		
		_nField := GDFieldPos("UB_PRODUTO")
		IF _nField==0
			exit
		EndIF
		_cProd  := aCols[_nI][_nField]
		
		_nField := GDFieldPos("UB_LOCAL")
		_cLocal := aCols[_nI][_nField]
		
		_nField := GDFieldPos("UB_QUANT")
		_nQuant := aCols[_nI][_nField]
		
		_nField := GDFieldPos("UB_DESCRI")
		_cDescri := aCols[_nI][_nField]
		
		_nField := GDFieldPos("UB_ITEM")
		_cItem := aCols[_nI][_nField]
		
		_nField := GDFieldPos("UB_TES")
		_cTes := aCols[_nI][_nField]
		
		If _nQuant == Nil .or. _nQuant == 0
			_nQuant := 1
		Endif
		
		_lEstoque := Posicione("SF4",1,xFilial("SF4")+_cTes,"F4_ESTOQUE")
		
		IF _lEstoque == "S" .or. Empty(_lEstoque)
			dbSelectArea("SB2")
			SB2->(dbSetOrder(1))
			If SB2->(dbSeek(xFilial("SB2")+_cProd+_cLocal,.T.))
				_nSaldo := SALDOSB2(,,,,,"SB2")
			Endif
			
			If _nSaldo == 0 .or. _nSaldo < _nQuant
				AADD(_aProd,{_cProd,_cLocal,_cDescri,_nSaldo,_nQuant,_cItem})
				_lRet := .F.
			Endif
		Endif
		
	Next _nI
	
	If !_lRet
		_cAviso := CRLF
		
		For _nX := 1 To Len(_aProd)
			_cAviso += _aProd[_nX][6] + " - " + Alltrim(_aProd[_nX][3])
			_cAviso += CRLF
		Next _nX
		
		If IsBlind()
			cLogTxt := "Saldo Indisponível - [TK271BOK]" + _cAviso
			Conout(cLogTxt)		
		Else
			MsgInfo(_cAviso,"Saldo Indisponível")		
		End
	Endif
Endif

//SUELEN SOUZA - 27-12-13
If nFolder == 3 .or. FUNNAME() == "TMKA350" //SOMENTE EXECUTA SE FOR TELECOBRANÇA.
	
	nPPrefix	:= Ascan(aHeader, {|x| x[2] == "ACG_PREFIX"} )
	nPTitulo	:= Ascan(aHeader, {|x| x[2] == "ACG_TITULO"} )
	nPParcel	:= Ascan(aHeader, {|x| x[2] == "ACG_PARCEL"} )
	nPTipo		:= Ascan(aHeader, {|x| x[2] == "ACG_TIPO  "} )
		
	For nI := 1 To Len(aCols)	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao dos itens do atendimento de Telecobranca³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ACG->(FieldPos("ACG_FILORI"))  > 0)
			nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
			If nPFilOrig > 0
				cFilOrig := aCols[nI][nPFilOrig]
			Else
				cFilOrig := xFilial("SE1")
			Endif
		Else
			cFilOrig := xFilial("SE1")
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados dos titulos cobrados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE1")
		DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
		If DbSeek(cFilOrig + M->ACF_CLIENT + M->ACF_LOJA + aCols[nI][nPPrefix] + aCols[nI][nPTitulo] + aCols[nI][nPParcel] + aCols[nI][nPTipo])
			RecLock("Z8Z", .T.)
			Z8Z->Z8Z_FILIAL			:= SE1->E1_FILIAL
			Z8Z->Z8Z_CLIENT			:= SE1->E1_CLIENTE
			Z8Z->Z8Z_LOJA			:= SE1->E1_LOJA
			Z8Z->Z8Z_PREFIX			:= SE1->E1_PREFIXO
			Z8Z->Z8Z_NUM			:= SE1->E1_NUM
			Z8Z->Z8Z_PARCEL			:= SE1->E1_PARCELA
			Z8Z->Z8Z_TIPO			:= SE1->E1_TIPO
			Z8Z->Z8Z_VENCTO			:= SE1->E1_VENCTO
			Z8Z->Z8Z_VENCRE			:= SE1->E1_VENCREA
			Z8Z->Z8Z_HIST			:= SE1->E1_HIST
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se ainda nao houve baixa para o titulo, significa que os dados de   ³
			//³Desconto Financeiro, Descrescimo e Acrescimo poderao ser alterados. ³
			//³No Financeiro os Acrescimos, Decrescimos e Descontos, sao concedidos³
			//³somente na primeira baixa do titulo. Se existirem novos valores     ³
			//³o usuario  devera informar manualmente na baixa de titulo.		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  Empty(SE1->E1_BAIXA)
				Z8Z->Z8Z_DESCFI			:= SE1->E1_DESCFIN		// Percentual de Desconto Financeiro
				Z8Z->Z8Z_LIDESC			:= SE1->E1_LIDESCF		// Data Limite para Desconto Financeiro
				Z8Z->Z8Z_ACRESC			:= SE1->E1_ACRESC		// Valor de Acrescimo
				Z8Z->Z8Z_DECRES			:= SE1->E1_DECRESC			// Valor de Descrescimo
				
				If (SE1->(FieldPos("E1_DESCJUR")) > 0) .AND. (ACG->(FieldPos("ACG_DESCJU")) > 0)
					Z8Z->Z8Z_DESCJU		:= SE1->E1_DESCJUR		// Percentual de Desconto sobre Juros
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Os Saldos de Acrescimo e Decrescimo devem ser atualizados       ³
				//³para serem avaliados no momento da baixa do titulo. 			   ³
				//³Os Saldos sao atualizados ate que o titulo seja baixado, 	   ³
				//³apos a baixa (parcial), o mesmo nao podera ser alterado.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Z8Z->Z8Z_SDACRE	:= SE1->E1_SDACRES				// Saldo de Acrescimo
				Z8Z->Z8Z_SDDECR	:= SE1->E1_SDDECRE				// Saldo de Descrescimo
			Endif
			
			MsUnlock()
		Endif
	NEXT
	
ENDIF

RestArea(aArea)

Return(_lRet)
