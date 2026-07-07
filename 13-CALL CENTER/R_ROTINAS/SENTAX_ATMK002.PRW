#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK002
Rotina para calcular o preço ótimo, chamada pelo faturamento
                
@sample		U_ATMK002()

@return 	Nil

@author		Alessandro Smaha
@since		10/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ATMK002( lRetorna, lAltItem, nValUni )

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
	Local nPosPro 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO" })
	Local nPosQtd 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN" })
	Local nPosVun 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN" })
	Local nPosPTb 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRUNIT" })
	Local nPosTot 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR" })
	Local nPosTes 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES" })
	Local nPValDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALDESC" })
	Local nPosVen	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_XPRCVEN" })
	Local nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL" })
	Local nPNumLote := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_NUMLOTE" })
	Local nValIPI	:= 0
	Local lPrcDec   := SuperGetMV("MV_PRCDEC",,.F.)
	Local aColsAux	:= aClone(aCols)

	Default lRetorna := .F.
	Default lAltItem := .F.
	Default nValUni	 := 0

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

	DbSelectArea("SF4")
	SF4->(DbSetOrder(1)) // F4_FILIAL+F4_CODIGO

	DbSelectArea("DA1")
	DA1->(DbSetOrder(1)) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM

	If !Empty(nPosPro) .AND. !Empty(nPosQtd) .AND. !Empty(nPosVun) .AND. !Empty(nPosTot)

		SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))

		MaFisIni(M->C5_CLIENTE,M->C5_LOJACLI,"C",M->C5_TIPO,M->C5_TIPOCLI,MaFisRelImp("ATMK002",{"SC5","SC6"}),,,"SB1","ATMK002")

		For nLinha := 1 To Len(aCols)

			If lAltItem .AND. nLinha <> n
				Loop
			EndIf

			If ! aCols[nLinha][Len(aHeader)+1] // Não deletado

				cCodPro := Alltrim(aCols[nLinha][nPosPro])
				nQuantd := aCols[nLinha][nPosQtd]

				If lRetorna .AND. !Empty(M->C5_TABELA)
					If Empty(nValUni)
						If DA1->(DbSeek(xFilial("DA1")+M->C5_TABELA+cCodPro))
							nValUni := DA1->DA1_PRCVEN
						Else
							nValUni := 0
						EndIf
					EndIf
				Else
					nValUni := aCols[nLinha][nPosVun]
				EndIf

				nValUni := A410Arred(nValUni,"C6_PRUNIT")
				nValTot := A410Arred( nValUni * nQuantd ,"C6_VALOR" ) // aCols[nLinha][nPosTot]
				nValVen := aCols[nLinha][nPosVen]
				cTesUti := Alltrim(aCols[nLinha][nPosTes])
				nValDes := aCols[nLinha][nPValDesc]
				nPrcTot := ( nQuantd * nValUni)
				nPrcUni := nValUni

				MaFisAdd(	cCodPro,;
					cTesUti,;
					nQuantd,;
					nPrcUni,;
					nValDes,;
					"",;
					"",;
					0,;
					0,;
					0,;
					0,;
					0,;
					nPrcTot,;
					0,;
					0,;
					0)

				If ! lRetorna // Verifica se retorna os valores dos itens ou calcula imposto para novos valores unitários

					nImposto := MaFisRet(nLinha,"IT_VALSOL")

					If ! Empty(nImposto) .AND. nValVen == nValUni

						nPercent := nImposto * 100 / (nValTot + nImposto)

						nValTot2 := nValTot - ( nValTot * nPercent / 100 )
						nValTot2 := A410Arred(nValTot2,"C6_VALOR",If(cPaisLoc=="CHI" .And. lPrcdec,M->C5_MOEDA,NIL))
						nValUni2 := nValTot2 / nQuantd

						aCols[nLinha][nPosVun] := nValUni2
						aCols[nLinha][nPosPTb] := nValUni2
						aCols[nLinha][nPosTot] := nValTot2

					EndIf

				Else

					aCols[nLinha][nPosVun] := nValUni
					aCols[nLinha][nPosPTb] := nValUni
					aCols[nLinha][nPosVen] := nValUni
					aCols[nLinha][nPosTot] := nValTot

				EndIf

				MaFisAlt("IT_QUANT"		,aCols[nLinha][nPosQtd]	,nLinha)
				MaFisAlt("IT_PRCUNI"	,aCols[nLinha][nPosVun]	,nLinha)
				MaFisAlt("IT_VALMERC"	,aCols[nLinha][nPosTot]	,nLinha)

				If ExistTrigger("C6_PRCVEN")
					//RunTrigger(2,nLinha,Nil,,"C6_PRCVEN")
				EndIf

			EndIf

		Next nLinha

		MaFisEnd()

		//oListBox:Refresh()
		oMainWnd:Refresh()

	EndIf

	M->C5_XRECALC := .F.

	If !lAltItem // Verifica se foi chamado no gatilho ou pelo botão preço ótimo.
		For nLinha := 1 to Len(aCols)
			If ! aCols[nLinha][Len(aHeader)+1] .AND. aColsAux[nLinha][nPosVun] <> aCols[nLinha][nPosVun]
				M->C5_XPRECOT := .T.
			EndIf
		Next nLinha
	EndIf

	Ma410Rodap()

	RestArea(aAreaSA1)
	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aAreaDA1)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK002G
Rotina chamada pelo gatilho para atualizar flag de recalculo de itens
                
@sample		U_ATMK002G()

@return 	Nil

@author		Alessandro Smaha
@since		10/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ATMK002G(xConteudo,xCampo)

	Default xCampo := ""

	If Alltrim(funname()) <> "RPC" .And. !(ProcName(8) == "POST_RECAVARIAS") //REST WMS
		
		If xCampo == "C6_PRCVEN"
			U_ATMK002(.T.,.T.,xConteudo)
		Else
			U_ATMK002(.T.,.T.)
		EndIF
	
		M->C5_XRECALC := .T.
	
	EndIf

Return xConteudo


//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK002V
Rotina chamada por PE para validação total e atualização de itens, 
caso necessário
                
@sample		U_ATMK002V()

@return 	Nil

@author		Alessandro Smaha
@since		10/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ATMK002V(lRetOk)

	If M->C5_XPRECOT // Foi clicado em preço otimo ?

		If M->C5_XRECALC // Foi atualizado após clicar em preço ótimo ?

			If MsgYesNo("O atendimento foi alterado e será necessário refazer os calculos!"+chr(13)+chr(10)+chr(13)+chr(10)+;
					"Confirma a operação ? ","Atenção")

				U_ATMK002(.T.)
				lRetOk := .F.
				M->C5_XRECALC := .F.

			Else

				lRetOk := .F.

			EndIf

		EndIf

	EndIf

Return lRetOk
