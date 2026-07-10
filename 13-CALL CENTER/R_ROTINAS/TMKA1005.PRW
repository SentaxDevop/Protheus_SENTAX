#include "totvs.ch"
#include "topconn.ch"

//-----------------------------------------------------------------
//Verifica se o valor do produto esta dentro das regras de desconto
//-----------------------------------------------------------------
User Function TMKA1005()
	Local aArea    := GetArea()
	Local cProduto := ""	//aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_PRODUTO"})]
	Local cTabMin  := GETMV("MV_TABMIN")
	Local cTabMax  := GETMV("MV_TABMAX")
	Local nDifMin  := GETMV("MV_DIFMIN")
	Local nDifMax  := GETMV("MV_DIFMAX")
	Local cBloq    := ""	//"N"
	Local cQuery   := ""
	Local nPreco   := ""	//aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_VRUNIT"})]
	Local nPercent := 0
	Local lCont    := .T.
	Local lExecuta := .T. 
	Local nCount   := 1
	Local cCliente := GetNewPar("SF_1005A","28736")

	For nCount := 1 to Len(ProcName())
		If Alltrim(ProcName(nCount)) == "U_M410STTS"
			lExecuta := .F. 
		EndIf
	Next

	If cEmpAnt == '01' .and. cFilAnt $ ('010101|040401|050501') .And. lExecuta
		lExecuta := .F. 
	End

	If lExecuta .And. (Alltrim(M->C5_TIPO) $ "D|B" .Or. Alltrim(M->C5_CLIENTE) $ cCliente)
		lExecuta := .F. 
	End

	If FunName() <> "MATA310" .AND. Alltrim(FunName()) <> "RPC"  .AND. lExecuta .And. !(ProcName(8) == "POST_RECAVARIAS") //REST WMS

		If AllTrim(FunName()) == "MATA410" .OR. AllTrim(FunName()) == "AFAT003"
			cProduto := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "C6_PRODUTO"})]
			nPreco   := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "C6_PRCVEN"})]

			If !(SC5->C5_TIPO $ "N/C")
				lCont := .F.
			Endif

		Else
			cProduto := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_PRODUTO"})]
			nPreco   := aCols[N][aScan(aHeader,{|X| ALLTRIM(X[2]) == "UB_VRUNIT"})]
			cBloq    := "N"
		EndIf

		If Select("TRB") > 0
			dbSelectArea("TRB")
			dbCloseArea()
		Endif

		//Seleciona registros
		cQuery := " SELECT DA1_CODPRO, DA1_CODTAB, SUM(DA1_PRCVEN) PRECO "
		cQuery += " FROM "+RetSqlName("DA1")+" DA1 " //tabela de preco
		cQuery += " WHERE DA1.D_E_L_E_T_ = ' ' "
		cQuery += " AND DA1_FILIAL = '"+xFilial("DA1")+"' "
		cQuery += " AND DA1_CODPRO = '"+cProduto+"' "
		//cQuery += " AND DA1_DATVIG >= '"+Dtos(dDataBase)+"' "
		cQuery += " GROUP BY DA1_CODTAB, DA1_CODPRO "
		cQuery += " ORDER BY DA1_CODTAB, DA1_CODPRO "

		TcQuery cQuery New Alias "TRB"

		dbSelectArea("TRB")
		TRB->(dbGoTop())

		If TRB->(!Eof()) .and. lCont
			
			While TRB->(!Eof())
			
				If TRB->DA1_CODTAB == cTabMin
			
					If nPreco < TRB->PRECO
						nPercent := 100-(nPreco/TRB->PRECO*100)
					Endif
			
					If nPercent > nDifMin
						
						If IsBlind()
							cLogTxt := "Este item será bloqueado pela regra... o valor do produto é INFERIOR ao mínimo permitido e a RESERVA NÃO SERA EFETUADA. - [TMKA1005]"
							Conout(cLogTxt)		
						Else
							ShowHelpDlg("Aviso", {"Este item será bloqueado pela regra... o valor do produto é INFERIOR ao mínimo permitido e a RESERVA NÃO SERA EFETUADA.",""},5,{"Entre em contato com o responsável." ,""},5)
						End
						
						If AllTrim(FunName()) == "MATA410" .OR. AllTrim(FunName()) == "AFAT003"
								cBloq := "01"
							Else
								cBloq := "S"
						EndIf

					Endif

				Endif

				/* //Remoção realizada por solicitação do Kleber - 25/05/2023
				If TRB->DA1_CODTAB == cTabMax

					If nPreco > TRB->PRECO
						nPercent := (nPreco/TRB->PRECO*100)-100
					Endif
				
					If nPercent > nDifMax

						ShowHelpDlg("Aviso", {"Este item será bloqueado pela regra... o valor do produto é SUPERIOR ao máximo permitido e a RESERVA NÃO SERA EFETUADA.",""},5,{"Entre em contato com o responsável." ,""},5)

						If AllTrim(FunName()) == "MATA410"  .OR. AllTrim(FunName()) == "AFAT003"
								cBloq := "01"
							Else
								cBloq := "S"
						EndIf

					Endif
				
				Endif
				*/
				TRB->(dbSkip())
				nPercent := 0
			
			Enddo
		
		Else
			cBloq := "S" //cBloq
			FWAlertHelp("Produto sem vínculo com tabela de preço!", "Cadastre o produto na tabela de preço vinculada ao cliente")
		Endif

		DbSelectArea("TRB")
		TRB->(dbCloseArea())

		RestArea(aArea)

	EndIf

Return(cBloq)
