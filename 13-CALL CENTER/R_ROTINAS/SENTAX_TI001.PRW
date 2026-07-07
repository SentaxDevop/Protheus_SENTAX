#INCLUDE "protheus.CH"

//Isso é para solucionar um Bug antigo da TOTVS, isso será revisto no futuro...

User Function MaTesInt(nEntSai,cTpOper,cClieFor,cLoja,cTipoCF,cProduto,cCampo,cTipoCli,cEstOrig,cOrigem)
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSX3	:= SX3->(GetArea())
Local aTes		:= {}
Local aDadosCfo	:= {}
Local cTesRet	:= "   "
Local cGrupo	:= ""
Local cGruProd	:= ""
Local cQuery	:= ""
Local cQuery1	:= ""
Local cProg		:= "MT100"
Local cNCM		:= ""
Local cEstado	:= ""
Local cAliasSFM	:= "SFM"
Local cTabela	:= ""
Local lQuery	:= .F.
Local nPosCpo	:= 0
Local nPosCfo	:= 0
Local nFM_POSIPI:= SFM->(FieldPos("FM_POSIPI"))
Local nFM_EST	:= SFM->(FieldPos("FM_EST"))
Local nFM_MSBLQL:= SFM->(FieldPos("FM_MSBLQL"))
Local nFM_TIPOMO:= SFM->(FieldPos("FM_TIPOMOV"))
Local cAlias	:= ""	//Tabela a ser utiliza para informacoes do produto
Local c_GRTRIB	:= ""	//SBI->BI_GRTRIB	/	SB1->B1_GRTRIB
Local c_POSIPI	:= ""	//SBI->BI_POSIPI	/	SB1->B1_POSIPI
Local c_TS		:= ""
Local c_TE		:= ""
Local cSb1Sbz	:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local lArqProp	:= SuperGetMV("MV_ARQPROP",.F.,.F.)
Local bCond		:= {||.T.}
Local bCondAux	:= {||.T.}
Local lAddTes	:= .F.
Local bSort		:= {||}
Local bAddTes	:= {||.T.}
Local bAtTes	:= {||.T.}
Local bIFWhile	:= {||.T.}
Local aRet		:= {}
Local lRet		:= .T.
Local cTesSaiB1	:= ""
Local cTesEntB1	:= ""
Local lGrade	:= MaGrade()
Local nFM_GRPTI	:= SFM->(ColumnPos("FM_GRPTI"))
Local nFM_TPCLI	:= IIF(cPaisLoc == "BRA",SFM->(ColumnPos("FM_TIPOCLI")),0)
Local nB1_GRPTI	:= IIF(cPaisLoc == "BRA",SB1->(ColumnPos("B1_GRPTI")),0)
Local nFM_GRPCST:= SFM->(ColumnPos("FM_GRPCST"))
Local nB1_GRPCST:= IIF(cPaisLoc == "BRA",SB1->(ColumnPos("B1_GRPCST")),0)
Local cGrpcst	:= ""
Local c_GRPCST 	:= "" 
Local cGrupoTI	:= ""
Local cTpCliFor	:= ""
Local c_GRPTI	:= ""
Local cGrpTi	:= ""
Local cTipFrete := Iif(Type("M->C5_TPFRETE")<>"U",M->C5_TPFRETE,"")
Local lTipPed	:= Type("M->C5_TIPO") <> "U"
Local cMVA089FAC := GetNewPar("MV_A089FAC","")
Local aCndTesInt	:= {} //Array com informações da condição do Tes inTeligente.
Local nQtdeEnq	:= 0
Local cPrOrdClie	:= "{1,2,3,4,5,6,7,8,9,10,11,12}" 
Local cPrOrdForn	:= "{1,2,3,4,5,6,7,8,9,10}" 
Local cOrdClie	:= GetNewPar("MV_OTICLI",cPrOrdClie) //Ordem dos campos da SFM Cliente
Local cOrdForn	:= GetNewPar("MV_OTIFOR",cPrOrdForn) //Ordem dos campos da SFM Fornecedor
Local aOrdSFM	:= {}
Local aOrdForn	:= {}
Local nCont		:= 0
Local cLogTes	:= ""
Local nQtdEmp	:= 0
Local nPosQtdEnq	:= 0
Local lFmId			:= SFM->(FieldPos("FM_ID")) > 0
Local cIdFM		:= '' 
Local cRecno	:= ''
Local nFM_ORIGEM:= SFM->(FieldPos("FM_ORIGEM")) 
Local nX := 0
Local nQtdTES   := 0 //Quantidade de TES com a maior quantidade de regras encontradas
Local nCountTES := 0 //Conta quantas TES com a maior quantidade de regras encontradas foram avaliadas

DEFAULT cTpOper  := IIF(IsInCallStack("tmka271"),M->UB_OPER,M->C6_OPER)
DEFAULT cClieFor := ""
DEFAULT cProduto := ""
DEFAULT nEntSai  := 0
DEFAULT cTipoCF  := "C"
DEFAULT cCampo   := ""
DEFAULT cTipoCli := Iif(Type("M->C5_TIPOCLI")<>"U",M->C5_TIPOCLI,"")
DEFAULT cEstOrig := ""
DEFAULT cOrigem  := "" 	

//---------------------------------------------------
//Para nova regra irá buscar ordem dos campos da SFM.
//---------------------------------------------------
If cTipoCF	== 'C'
	If len(cOrdClie) >= 3 .AND. substr(cOrdClie,1,1) == '{' .AND. substr(cOrdClie,Len(cOrdClie),1) == '}'
		aOrdSFM	:= &(cOrdClie)
	EndIF
	
ElseIf len(cOrdForn) >= 3 .AND. substr(cOrdForn,1,1) == '{' .AND. substr(cOrdForn,Len(cOrdForn),1) == '}'
	aOrdSFM	:= &(cOrdForn)	
EndIF

If !Empty(cCampo) .AND. ValType(aHeader) == "A"
	nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(cCampo)})
	If nPosCpo > 0
		dbSelectArea("SX3")
		dbSetOrder(2)
		MsSeek(aHeader[nPosCpo,2])
		cTabela := SX3->X3_ARQUIVO
		RestArea(aAreaSX3)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o grupo de tributacao do cliente/fornecedor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea(IIf(cTipoCF == "C","SA1","SA2"))
dbSetOrder(1)
MsSeek(xFilial()+cClieFor+cLoja)
If cTipoCF == "C"
	cGrupo  := SA1->A1_GRPTRIB
	cEstado := SA1->A1_EST
	If Empty(cTipoCli)
		cTipoCli := SA1->A1_TIPO
	EndIf	
Else
	cGrupo  := SA2->A2_GRPTRIB
	cEstado := SA2->A2_EST
EndIf
//Verifica se cEstOrig foi carregado na chamada da função. Se sim substitui o valor que há em cEstado pelo valor de cEstOrig
If !Empty(cEstOrig) .and. cEstado <> cEstOrig
	cEstado := cEstOrig
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o codigo do produto informado eh de grade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGrade
	MatGrdPrrf(@cProduto)
EndIf

If nModulo == 23 .AND. !(FindFunction("STFIsPOS") .AND. STFIsPOS()) // Se não for Totvs PDV 
	dbSelectArea("SBI")
	dbSetOrder(1)
	If dbSeek(xFilial("SBI") + cProduto)
		cGruProd := SBI->BI_GRTRIB
			cNCM := SBI->BI_POSIPI
	Endif
Else
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1") + cProduto)
		cAlias   := "SB1"
		c_GRTRIB := "SB1->B1_GRTRIB"
		c_POSIPI := "SB1->B1_POSIPI"
		c_TS     := "SB1->B1_TS"
		c_TE     := "SB1->B1_TE"
		If nB1_GRPTI > 0
			c_GRPTI := "SB1->B1_GRPTI"
		EndIf
		If nB1_GRPCST > 0
			c_GRPCST := "SB1->B1_GRPCST"
		EndIf
		
		If cSb1Sbz == "SBZ"
			// Se existir registro no SBZ (Indicadores de Produtos) busca as informacoes desta tabela 
			c_GRTRIB  := "SBZ->BZ_GRTRIB"
			dbSelectArea("SBZ")
			SBZ->(dbSetOrder(1)) //BZ_FILIAL+BZ_PRODUTO
			If DbSeek(xFilial("SBZ") + cProduto) .And. lArqProp .And.!Empty(SBZ->BZ_GRTRIB)//O parametro eh true e o campo esta preenchido?
				// sim
				cGruProd := &(c_GRTRIB)
			ElseIf !lArqProp  // O parametro eh false busca o conteudo vazio da tabela SBZ
				cGruProd := &(c_GRTRIB)
			Else // Neste caso o parametro eh true e busca as informacoes na Tabela SB1
				c_GRTRIB := "SB1->B1_GRTRIB"
				cGruProd := &(c_GRTRIB)
			EndIf
		Else // neste caso busca as informacoes na tabela SB1 apenas
			cGruProd := &(c_GRTRIB)
			cTesSaiB1:= &(c_TS)
			cTesEntB1:= &(c_TE)
			If nB1_GRPTI > 0
				cGrpTI := &(c_GRPTI)
			EndIf
			If nB1_GRPCST > 0
				cGrpcst := &(c_GRPCST)
			EndIf
		EndIf
		// Como não existe o campo NCM na SBZ, não sendo o módulo 23, será verificado na SB1
		If !Empty(c_POSIPI)
			cNCM := &(c_POSIPI)
		Endif
		// Como não existe o campo GRUPO TI na SBZ, não sendo o módulo 23, será verificado na SB1
		If !Empty(c_GRPTI)
			cGrpTI := &(c_GRPTI)
		Endif

	EndIf
EndIf

If cTipoCF == "C" 	
	#IFDEF TOP
		bAddTes		:=	{||aAdd(aTes, {(cAliasSFM)->FM_PRODUTO,;
					(cAliasSFM)->FM_GRPROD,;
					IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
					(cAliasSFM)->FM_CLIENTE,;
					(cAliasSFM)->FM_LOJACLI,;
					(cAliasSFM)->FM_GRTRIB,;
					IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
					(cAliasSFM)->FM_TE,;
					(cAliasSFM)->FM_TS,;
					Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
					Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
					Iif(nFM_TPCLI > 0, (cAliasSFM)->FM_TIPOCLI, ""),;
					Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
					nQtdeEnq,;
					Iif(nFM_TIPOMO > 0, (cAliasSFM)->FM_TIPOMOV, ""),;
					Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
					(cAliasSFM)->R_E_C_N_O_,;
					Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}
	#ELSE
		bAddTes		:=	{||aAdd(aTes, {(cAliasSFM)->FM_PRODUTO,;
						(cAliasSFM)->FM_GRPROD,;
						IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
						(cAliasSFM)->FM_CLIENTE,;
						(cAliasSFM)->FM_LOJACLI,;
						(cAliasSFM)->FM_GRTRIB,;
						IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
						(cAliasSFM)->FM_TE,;
						(cAliasSFM)->FM_TS,;
						Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
						Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
						Iif(nFM_TPCLI > 0, (cAliasSFM)->FM_TIPOCLI, ""),;
						Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
						nQtdeEnq,;
						Iif(nFM_TIPOMO > 0, (cAliasSFM)->FM_TIPOMOV, ""),;
						Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
						(cAliasSFM)->(Recno()),;
						Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "") })}	
	#ENDIF
					
					

		bSort		:=	{|x,y| x[14] > y[14]}
Else
	#IFDEF TOP
		bAddTes		:=	{|| aAdd(aTes,{(cAliasSFM)->FM_PRODUTO,;
					(cAliasSFM)->FM_GRPROD,;
					IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
					(cAliasSFM)->FM_FORNECE,;
					(cAliasSFM)->FM_LOJAFOR,;
					(cAliasSFM)->FM_GRTRIB,;
					IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
					(cAliasSFM)->FM_TE,;
					(cAliasSFM)->FM_TS,;
					Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
					Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
					Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
					nQtdeEnq,;
					Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
					(cAliasSFM)->R_E_C_N_O_,;
					Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}									
	#ELSE
		bAddTes		:=	{|| aAdd(aTes,{(cAliasSFM)->FM_PRODUTO,;
						(cAliasSFM)->FM_GRPROD,;
						IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
						(cAliasSFM)->FM_FORNECE,;
						(cAliasSFM)->FM_LOJAFOR,;
						(cAliasSFM)->FM_GRTRIB,;
						IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
						(cAliasSFM)->FM_TE,;
						(cAliasSFM)->FM_TS,;
						Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
						Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
						Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
						nQtdeEnq,;
						Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
						(cAliasSFM)->(Recno()),;
						Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}
	#ENDIF
	bSort		:=	{|x,y| x[13] > y[13]}
EndIf

bIRWhile		:=	{||((cAliasSFM)->(!Empty(FM_GRTRIB) .And. !Empty(FM_GRPROD)) .And. AllTrim(cGrupo)+AllTrim(cGruProd)==(cAliasSFM)->(AllTrim(FM_GRTRIB)+AllTrim(FM_GRPROD))) .Or.;
					(cAliasSFM)->(Empty(FM_GRTRIB) .Or. Empty(FM_GRPROD))}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que permite alterar a regra de selecao do TES,³
//³alterar a ordem do array com os elementos encontrados pela     ³
//³rotina e alterar o conteudo do array com os campos do SFM.     ³
//³Todos os retornos tem que ser em forma de CodBlock.            ³
//³Caso seja incluido campo novo para ser tratado na regra, se faz³
//³necessario incluir no X2_UNICO do SFM.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT089CD")
	aRet		:= Execblock("MT089CD",.T.,.T.,{bCond,bSort,bIRWhile,bAddTes,cTabela,cTpOper})
	bCondAux	:= aRet[1]
	bSort		:= aRet[2]
	bIFWhile	:= aRet[3]
	bAtTes		:= aRet[4]
	If Len(aRet) > 4
		cTpOper	:= aRet[5]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por todas as regras validas para este caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para tratar seleção da tes inteligente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("MT089TES"))
		cRet := ExecBlock("MT089TES",.F.,.F.,{nEntSai,cTpOper,cClieFor,cLoja,cProduto})
		If Valtype( cRet ) == "C"
			cQuery := cRet
			lQuery := .T.
			lRet := .F.
		EndIf
	EndIf
	If(lRet)
		lQuery := .T.
		cAliasSFM := GetNextAlias()
		cQuery += "SELECT  
		If !Empty(cProduto)
			cQuery1 += Iif(EMPTY(cQuery1)," ( ","")+" (CASE "
			cQuery1 += "		WHEN SFM.FM_PRODUTO = '"+cProduto+"'
			cQuery1 += "		THEN 1
			cQuery1 += "		ELSE 0
			cQuery1 += "	END)
		EndIf
		If !Empty(cGruProd)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	  WHEN SFM.FM_GRPROD = '"+cGruProd+"'
			cQuery1 += "	  THEN 1
			cQuery1 += "	  ELSE 0
			cQuery1 += "  END)
		EndIf
		If !Empty(cGrupo)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "  WHEN SFM.FM_GRTRIB = '"+cGrupo+"'
			cQuery1 += "  THEN 1
			cQuery1 += "  ELSE 0
			cQuery1 += " END)
		EndIf
		If cTipoCF == "C" .And. !Empty(cClieFor) .And. !Empty(cLoja)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	WHEN SFM.FM_CLIENTE = '"+cClieFor+"' AND SFM.FM_LOJACLI = '"+cLoja+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If cTipoCF == "F" .And. !Empty(cClieFor) .And. !Empty(cLoja)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	WHEN SFM.FM_FORNECE = '"+cClieFor+"' AND SFM.FM_LOJAFOR = '"+cLoja+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cEstado)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_EST = '"+cEstado+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If lTipPed .And. !Empty(M->C5_TIPO) .And. nFM_TIPOMO > 0
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_TIPOMOV = '"+M->C5_TIPO+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cNCM)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_POSIPI = '"+cNCM+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cGrpTi)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_GRPTI = '"+cGrpTi+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cTipoCli)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_TIPOCLI = '"+cTipoCli+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cGrpcst)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_GRPCST = '"+cGrpcst+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf
		If !Empty(cOrigem)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_ORIGEM = '"+cOrigem+"'
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
		EndIf

		cQuery += Iif(!Empty(cQuery1),cQuery1+") QTDREGRA, ","")+"SFM.* FROM " + RetSqlName("SFM") + " SFM "
		cQuery += "WHERE SFM.FM_FILIAL = '" + xFilial("SFM") + "' "
		cQuery += "AND SFM.FM_TIPO = '" + cTpOper + "' "
		cQuery += "AND SFM.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+Iif(!Empty(cQuery1),"QTDREGRA DESC,","")+SqlOrder(SFM->(IndexKey()))
	EndIf
	cAliasSFM := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFM,.T.,.T.)
#ELSE
	dbSelectArea("SFM")
	dbSetOrder(1)
	MsSeek(xFilial("SFM")+cTpOper)
#ENDIF

lQuery1 := Iif(!Empty(cQuery1), .T., .F.) 
nQTDREGRA := Iif(!Empty(cQuery1),(cAliasSFM)->QTDREGRA,0)

If ValType(nQTDREGRA) == "C"
	nQTDREGRA := Val(nQTDREGRA)
EndIf

If lQuery1 .And. ValType(nQTDREGRA) == "N" .And. nQTDREGRA > 0
	nQtdTES := Contar(cAliasSFM,"!Eof() .And. QTDREGRA == "+AllTrim(cValToChar(nQTDREGRA))) //Verifico a quantidade de TES que se enquadraram na quantidade máxima de regras
	(cAliasSFM)->(DbGoTop())
EndIf


While (cAliasSFM)->(!Eof()) .And. (cAliasSFM)->FM_TIPO==cTpOper

	nCountTES++
	// Verificar se esta Bloqueado
	If nFM_MSBLQL > 0 .And. (cAliasSFM)->FM_MSBLQL == '1'
		dbSelectArea(cAliasSFM)
		dbSkip()
		LOOP
	EndIf

	If (cPaisLoc == "RUS")
		// Verificar se possui Tipo do Contrato
		If (cTabela == "SC7")
			nPosContra := aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim("C7_CONTRA")})
			nPosContRev := aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim("C7_CONTREV")})
			
			If (nPosContra > 0 .And. nPosContRev > 0)
				DbSelectArea("CN9")
				CN9->(DbSetOrder(1))
				If (CN9->(DbSeek(xFilial("CN9") + aCols[n][nPosContra] + aCols[n][nPosContRev])))
					cTpContra := CN9->CN9_TPCTO
				Endif
			Endif
		Elseif (cTabela == "SD1")
			nPosPedido := aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim("D1_PEDIDO")})
			nPosItem := aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim("D1_ITEMPC")})
			
			If (nPosPedido > 0 .And. nPosItem > 0)
				DbSelectArea("SC7")
				SC7->(DbSetOrder(1))
				If (SC7->(DbSeek(xFilial("SC7") + aCols[n][nPosPedido] + aCols[n][nPosItem])))
					DbSelectArea("CN9")
					CN9->(DbSetOrder(1))
					If (CN9->(DbSeek(xFilial("CN9") + SC7->C7_CONTRA + SC7->C7_CONTREV)))
						cTpContra := CN9->CN9_TPCTO
					Endif
				Endif
			Endif
		Elseif (cTabela == "SC6")
			DbSelectArea("CN9")
			CN9->(DbSetOrder(1))
			If (CN9->(DbSeek(xFilial("CN9") + M->C5_MDCONTR)))
				cTpContra := CN9->CN9_TPCTO
			Endif
		Endif
		
		
		If (nFM_TPCTO > 0 .And. AllTrim(cTpContra) != AllTrim((cAliasSFM)->FM_TPCTO))
			dbSelectArea(cAliasSFM)
			dbSkip()
			LOOP
		Endif
	Endif
	//Será considerado como prioridade a maior quantidade de campos enquadrados
	lAddTes	:= .F.
	nQtdeEnq	:= 0			
	If !Empty((cAliasSFM)->FM_TS) .Or. !Empty((cAliasSFM)->FM_TE)

		aCndTesInt	:= Condicao(cAliasSFM,	nFM_EST,	nFM_TIPOMO,	nFM_POSIPI,	nFM_GRPTI,;
								nFM_TPCLI,	nFM_GRPCST,	lGrade,		cTipoCF,	cProduto,;
								cGruProd,	cClieFor,	cLoja,		cGrupo,		cEstado,;
								cNCM,		cGrpTi,		cTipoCli,	cGrpcst,	lTipPed,;
								nFM_ORIGEM, cOrigem)

		nQtdeEnq	:= aCndTesInt[2]
		lAddTes	:= aCndTesInt[1]
	EndIF

	IF lAddTes .AND. Eval(bCondAux)
		If Eval(bIRWhile) .And. Eval(bIFWhile)
			Eval(bAddTes)//Adiciono o conteudo original da rotina
			Eval(bAtTes) //Caso o ponto de entrada MT089CD esteja ativo, adiciono o retorno dele
		EndIf
	EndIf

	dbSelectArea(cAliasSFM)
	dbSkip()

	If lQuery1 .And. (nQtdTES == nCountTES .And. Len(aTES) > 0)
		Exit
	EndIf
	
EndDo
If ( lQuery )
	dbSelectArea(cAliasSFM)
	dbCloseArea()
	dbSelectArea("SFM")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por todas as regras validas para este caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aTES,,,bSort) //Ordena o array conforme passado na regra do bSort, podendo ser alterardo pelo PE MT089CD

//Caso utilize ponto de entrada, mantenho o legado do sistema
If !ExistBlock("MT089CD")	
	//------------------------------------------------------------------
	//Para nova regra, deverá verificar se houve empate de enquadramento
	//------------------------------------------------------------------
	//Verifica se existe empate, se existir irá desempatar pela regra do cliente	
	If !Desempate(@aTes,cTipoCF,aOrdSFM, Iif(cTipoCF == 'C',cPrOrdClie ,cPrOrdForn ))
		
		//Se não conseguiu desempatar pela regra do cliente irá tentar desempatar pela regra padrão
		IF !Desempate(@aTes,cTipoCF,,Iif(cTipoCF == 'C',cPrOrdClie ,cPrOrdForn ))
			//Se ainda assim não conseguiu desempatar, pela regra do cliente e pela regra padrão
			//é porque existem regras cadastradas na SFM somente com tipo de movimento igual copm TES diferente ou
			//regras com mesmo campos chaves iguais, neste caso não irei sugerir nenhum TES pois este cadastro está duplicado.
			//Por este motivo irei zerar o aTES  
			//Abaixo trecho de LOG para incidar regras de TES que estão empatadas e que a rotina não irá sugerir por falta de critério
			//o usuário deverá analisar estes empates para rever as regras e eliminar regras conflitantes.			
			
			nPosQtdEnq	:= Iif(cTipoCF == "C",14,13)			
			nQtdEmp	:= aTES[1][nPosQtdEnq]  
			
			ProcLogIni({})
			//ProcLogAtu("INICIO",STR0009,,'MATA089')
			For nCont := 1 to len(aTES)
				
				cIdFM	:= ''
				If lFmId
					cIdFM	:= aTES[nCont][Iif(cTipoCF == "C",16,14)]					
				EndIF
				
				cRecno	:= cvaltochar(aTES[nCont][Iif(cTipoCF == "C",17,15)]) 			
							
				//Somente irei guardar LOG dos empates com maior número de enquadramento
				IF nQtdEmp ==  aTES[nCont][nPosQtdEnq]
					cLogTes	+= Iif(!Empty(cIdFM),'Código da Regra de TES Inteligente: ' + cIdFM ,'' ) + " TES: " + aTES[nCont][ Iif(nEntSai==1,8,9) ] + " Tipo de Movimentação: " +  cTpOper +" Rotina: " + FunName() + " RECNO: " + cRecno +  CHR(10)+CHR(13)	+  CHR(10)+CHR(13)				
				Else					 
					Exit
				EndIF 
				
			Next nCont			
			
			//ProcLogAtu("ERRO",STR0013,cLogTes,'MATA089')			
			//ProcLogAtu("FIM",STR0014,,'MATA089')
			aTES	:= {}
		EndIF		
	EndIF
EndIF

If Len(aTes) <> 0
	cTesRet := If(nEntSai==1,aTes[1][8],aTes[1][9])
EndIf
If nPosCpo > 0 .And. !Empty(cTesRet) .And. Type('aCols') <> "U"
	aCols[n][nPosCpo] := cTesRet
	Do Case
		Case cTabela == "SD1"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D1_CF") })
		Case cTabela == "SD2"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D2_CF") })
		Case cTabela == "SC6"
			dbSelectArea("SF4")
			dbSetOrder(1)
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("C6_CF") })
			If nPosCfo > 0 .And. MsSeek(xFilial("SF4")+cTesRet)
				aDadosCfo := {}
				AAdd(aDadosCfo,{"OPERNF","S"})
				AAdd(aDadosCfo,{"TPCLIFOR",If(cTipoCF == "C", cTipoCli     , SA2->A2_TIPO )})
				AAdd(aDadosCfo,{"UFDEST"  ,If(cTipoCF == "C", SA1->A1_EST  , SA2->A2_EST  )})
				AAdd(aDadosCfo,{"INSCR"   ,If(cTipoCF == "C", SA1->A1_INSCR, SA2->A2_INSCR)})
				AAdd(aDadosCfo,{"CONTR"   ,If(cTipoCF == "C", SA1->A1_CONTRIB, "")})
				Aadd(aDadosCfo,{"FRETE"   ,cTipFrete})
				aCols[n][nPosCfo] := MaFisCfo( ,SF4->F4_CF,aDadosCfo )
			EndIf
			nPosCfo := 0
		Case cTabela == "SC7"
			cProg := "MT120"
		Case cTabela == "SC8"
			cProg := "MT150"
		Case cTabela == "SUB"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("UB_CF") })
			cProg := "TK273"
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Agroindustria  		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTabela == "NKO"  
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("NKO_TES") })
		
	EndCase
	If nPosCfo > 0
		aCols[n][nPosCfo] := Space(Len(aCols[n][nPosCfo]))
	EndIf
	If MaFisFound("IT",N)
		MaFisAlt("IT_TES",cTesRet,n)
		MaFisRef("IT_TES",cProg,cTesRet)
	EndIf
EndIf
If !Empty(cTesRet)
	dbSelectArea("SF4")
	If MsSeek(xFilial("SF4")+cTesRet)
		If !RegistroOK("SF4")
			cTesRet := Space(Len(cTesRet))
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso NENHUMA regra tenha sido aplicada, ao inves de retornar uma TES em ³
	//³branco, a instrucao a seguir MANTEM a TES existente no aCols, ANTES da  ³
	//³execucao do gatilho do campo ??_OPER que executou esta funcao MaTesInt()³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If Type("aCols") == "A" .AND. !(nModulo == 12)  .And. (!Empty(cTesSaiB1) .Or. !Empty(cTesEntB1))
		nPosTes := aScan(aHeader,{|x| AllTrim( Substr( x[2] , AT("_TES" , x[2] ) , AT("_TES" , x[2] )+ 4  ))  == AllTrim("_TES") } )
		If nPosTes > 0
			cTesRet := aCols[N,nPosTes]
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da rotina                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA2)
RestArea(aAreaSA1)
RestArea(aAreaSB1)
RestArea(aArea)
Return(cTesRet)


Static Function Condicao(cAliasSFM,	nFM_EST,	nFM_TIPOMO,	nFM_POSIPI,	nFM_GRPTI,;
						nFM_TPCLI,	nFM_GRPCST,	lGrade,		cTipoCF,	cProduto,;
						cGruProd,	cClieFor,	cLoja,		cGrupo,		cEstado,;
						cNCM,		cGrpTi,		cTipoCli,	cGrpcst,	lTipPed,;
						nFM_ORIGEM, cOrigem)

Local lPRODUTO := .F.
Local lREFGRD  := .F.
Local lGRPROD  := .F.
Local lCLILOJA := .F.
Local lFORLOJA := .F.
Local lGRTRIB  := .F.
Local lEST     := .F.
Local lTIPOMOV := .F.
Local lPOSIPI  := .F.
Local lGRPTI   := .F.
Local lTIPOCLI := .F.
Local lGRPCST  := .F.
Local lRet     := .F.
Local lORIGEM  := .F. 
Local nQtdeEnq := 0

//---------------------------------------------------------------------------
//INICIALIZA AS TODAS VARIÁVEIS COM .T. CASO A INFORMAÇÃO DA SFM ESTEJA VAZIA
//---------------------------------------------------------------------------
lPRODUTO := Empty((cAliasSFM)->FM_PRODUTO)
lGRPROD  := Empty((cAliasSFM)->FM_GRPROD)
lGRTRIB  := Empty((cAliasSFM)->FM_GRTRIB)
lCLILOJA := Empty((cAliasSFM)->(FM_CLIENTE+FM_LOJACLI))
lFORLOJA := Empty((cAliasSFM)->(FM_FORNECE+FM_LOJAFOR))
lREFGRD  := Iif (cPaisLoc == "BRA" .And. Empty((cAliasSFM)->FM_REFGRD),.T.,.F.)
lEST     := Iif((nFM_EST    > 0 .AND. Empty((cAliasSFM)->FM_EST))     .OR. nFM_EST    == 0,.T.,.F.)
lTIPOMOV := Iif((cPaisLoc == "BRA" .And. nFM_TIPOMO > 0 .AND. Empty((cAliasSFM)->FM_TIPOMOV)) .OR. nFM_TIPOMO == 0,.T.,.F.)
lPOSIPI  := IIf((nFM_POSIPI > 0 .AND. Empty((cAliasSFM)->FM_POSIPI))  .OR. nFM_POSIPI == 0,.T.,.F.)
lGRPTI   := Iif((nFM_GRPTI  > 0 .AND. Empty((cAliasSFM)->FM_GRPTI))   .OR. nFM_GRPTI  == 0,.T.,.F.)
lTIPOCLI := Iif((cPaisLoc == "BRA" .And. nFM_TPCLI  > 0 .AND. EmptY((cAliasSFM)->FM_TIPOCLI)) .OR. nFM_TPCLI  == 0,.T.,.F.)
lGRPCST  := Iif((nFM_GRPCST > 0 .AND. Empty((cAliasSFM)->FM_GRPCST))  .OR. nFM_GRPCST == 0,.T.,.F.)
lREFGRD  := Iif (cPaisLoc <> "BRA" ,.T.,lREFGRD)
lORIGEM  := Iif(nFM_ORIGEM > 0,Iif(Empty((cAliasSFM)->FM_ORIGEM),.T.,.F.),.T.)

//----------------------------------------------------------------------------------------------------------------------
//SE TODOS OS CAMPOS DA SFM ESTIVEREM VAZIOS, ENTÃO IRÁ ADICIONAR E NÃO TERÁ NENHUM ENQUADRAMENTO, É UMA REGRA GENÉRICA
//----------------------------------------------------------------------------------------------------------------------
If lCLILOJA .AND. lFORLOJA .AND. lEST   	.AND. lGRTRIB  .AND. lPRODUTO .AND. lGRPROD  .AND. ;
	lPOSIPI .AND. lREFGRD  .AND. lTIPOMOV  .AND. lGRPTI  .AND. lTIPOCLI .AND. lGRPCST .AND. lORIGEM
	lRet	:= .T.
EndIF
//------------------------------------------------------------------------
//VERIFICA CAMPO POR CAMPO DA SFM COMPARANDO COM INFORMAÇÃO DA NOTA FISCAL
//SOMENTE SE ALGUM CAMPO DA SFM ESTIVER PREENCHIDO
//------------------------------------------------------------------------

If !lRet

	If !lPRODUTO .And. Alltrim(cProduto) == Alltrim((cAliasSFM)->FM_PRODUTO)
		nQtdeEnq	++
		lPRODUTO	:= .T.
	EndIF
	
	If lGrade .AND. !lREFGRD .And. Alltrim((cAliasSFM)->FM_REFGRD) 	== Alltrim(cProduto)
		nQtdeEnq	++
		lREFGRD	:= .T.
	EndIF
	
	If !lGRPROD .AND. Alltrim(cGruProd) == Alltrim((cAliasSFM)->FM_GRPROD)
		nQtdeEnq	++
		lGRPROD	:= .T.
	EndIF
	
	If cTipoCF == 'C'
		If !lCLILOJA .AND. Alltrim(cClieFor+cLoja)  == Alltrim((cAliasSFM)->(FM_CLIENTE+FM_LOJACLI))
			nQtdeEnq	++
			lCLILOJA	:= .T.
		EndIF
	Else
		If !lFORLOJA .AND. Alltrim(cClieFor+cLoja) == Alltrim((cAliasSFM)->(FM_FORNECE+FM_LOJAFOR)) 
			nQtdeEnq	++
			lFORLOJA	:= .T.
		EndIF
	EndIF
	
	If !lGRTRIB .And. AllTrim(cGrupo) == AllTrim((cAliasSFM)->FM_GRTRIB)
		nQtdeEnq	++
		lGRTRIB	:= .T.
	EndIF
	
	If nFM_EST> 0 .And. !lEST .And. Alltrim(cEstado) == Alltrim((cAliasSFM)->FM_EST)
		nQtdeEnq	++
		lEST	:= .T.
	EndIF
	
	If !lTipPed .Or.(nFM_TIPOMO > 0 .And. lTipPed .And. !lTIPOMOV .And. Alltrim(M->C5_TIPO) == Alltrim((cAliasSFM)->FM_TIPOMOV))
		nQtdeEnq	++
		lTIPOMOV	:= .T.
	EndIF
	
	If nFM_POSIPI >0 .And. !lPOSIPI .And. Alltrim(cNCM) == Alltrim((cAliasSFM)->FM_POSIPI)
		nQtdeEnq	++
		lPOSIPI	:= .T.
	EndIF
	
	If nFM_GRPTI > 0 .And. !lGRPTI .And. Alltrim(cGrpTi) == Alltrim((cAliasSFM)->FM_GRPTI)
		nQtdeEnq	++
		lGRPTI	:= .T.
	EndIF
	
	If cTipoCF == 'C'
		If nFM_TPCLI > 0 .And. !lTIPOCLI .And. Alltrim(cTipoCli) == Alltrim((cAliasSFM)->FM_TIPOCLI)
			nQtdeEnq	++  
			lTIPOCLI	:= .T.
		EndIF
	EndIF
	
	If nFM_GRPCST > 0 .And. !lGRPCST .And. Alltrim(cGrpcst) == Alltrim((cAliasSFM)->FM_GRPCST)
		nQtdeEnq	++
		lGRPCST	:= .T.
	EndIF

	If nFM_ORIGEM > 0 .And. !lORIGEM .And. Alltrim(cOrigem) == Alltrim((cAliasSFM)->FM_ORIGEM) 
		nQtdeEnq	++
		lORIGEM	:= .T.
	EndIF

	//------------------------------------------------------------
	//FAZ VERIFICAÇÃO SE AS INFORMAÇÕES DA SFM PODERÁ SER SUGERIDA
	//------------------------------------------------------------
	If (Iif(cTipoCF == 'C',lCLILOJA,lFORLOJA)).AND. lEST   .AND. lGRTRIB  .AND. lPRODUTO .AND. lGRPROD  .AND. ;
		lPOSIPI .AND. lREFGRD  .AND. Iif(cTipoCF == 'C',lTIPOMOV,.T.) .AND. lGRPTI  .AND. Iif(cTipoCF == 'C',lTIPOCLI,.T.) .AND. lGRPCST .AND. lORIGEM 
		
		lRet	:= .T.	
	EndIF
	
EndIF

Return {lRet , nQtdeEnq}
Static Function Desempate(aTes,cTipoCF,aOrdemTes, cOrdSFM)

Local nCont		:= 0
Local nQtde		:= 0
Local nContTes	:= 0
Local bSort		:=	Iif(cTipoCF == 'C',{|x,y| x[14] > y[14]},{|x,y| x[13] > y[13]})
Local lAlt			:= .F.
Local lRet			:= .F.
Local nPosATes	:= Iif(cTipoCF == 'C',14,13)

Default aOrdemTes	:= &(cOrdSFM)  //Ordem padrão do sistema

//Verifica se existem regras empatadas no array aTes
//A variável nQtde terá a quantidade de TES empatadas
If CheckEmpate(aTes,@nQtde,cTipoCF)

	//Aqui existem pelo menos duas regras empatadas.	Irá então processar a ordem dos campos de prioridade para desempatar e sugerir o TES
	For nCont := 1 to Len(aOrdemTes)
		lAlt	:= .F.
		//Irá verificar em todos os tes empatados a ordem dos campos
		For nContTes	:= 1 to nQtde		
			
			If ChkOrdSFM(aTes[nContTes],aOrdemTes[nCont],cTipoCF)
				//Se atendeu a regra da ordem prioritária, irá incrementar o número de enquadramento
				aTes[nContTes][nPosATes] ++
				lAlt	:= .T.
			EndIF
		
		Next nContTes
		
		//Somente irá processar se houve alteração em alguma regra 
		If lAlt		
			//Após verificar o campo em todos as regras empatadas, irá então ordenar novamente para ver se
			//ainda resta regras empatadas
			aSort(aTES,,,bSort)
			//Deverá verificar aqui se desempatou
			If !CheckEmpate(aTes,,cTipoCF)
				//Não há mais empate, foi resolvido com o processamento da ordem dos campos e não deverá mais verificar os
				//demais campos da ordem de prioridade
				lRet	:= .T.
				Exit
			Endif
		EndIF	
									
	Next nCont		
Else
	//Não houve empate, não será necessário processar ordem prioritária dos campos
	lRet	:= .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckEmpate
 
Função que irá percorrer o array aTes, verifica se existe regras com o 
mesmo número de campos enquadrados, ou seja, estão empatados.
  
@param  	aTes      - Array com informações dos Tes enquadrados
			nQtde     - Quantidade de Tes empatadas
			cTipoCF   -Indca operação com Cliente 'C' ou fornecedor 'F'
@return	(nQtde>1)  - Retornar booleano, indicando que existem Tes empatadas			
@author Erick G. Dias
@since 12/05/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function CheckEmpate(aTes,nQuantidad,cTipoCF)
Local nContEmp		:= 0
Local nQtdeEnq	:= 0
Local nPosATes	:= Iif(cTipoCF == 'C',14,13)
Default nQuantidad		:= 0

//Verifica se existem regras empatadas
For nContEmp	:= 1 to Len(aTes)	
	If  aTes[nContEmp][nPosATes] >= nQtdeEnq
		nQtdeEnq	:= aTes[nContEmp][nPosATes]
		nQuantidad++
	Else
		Exit
	EndIF
	
Next nContEmp

Return (nQuantidad>1)


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkOrdSFM
 
Função que faz a verificação se determinado campo do aTes está preenhido.
Esta função é utilizada para processar ´critério de desempate,
verificando campo por campo se está prenhido, considerando ordem de 
prioridade dos campos da SFM, seja ordem padrão ou ordem definida pelo Cliente
  
@param  	aTes      - Array com informações dos Tes enquadrados
			nOrdem    - Número que corresponde ao campo da tabela SFM
			cTipoCF   -Indca operação com Cliente 'C' ou fornecedor 'F'

@return	lRet 	   - Retornar booleano, indicando que campo em questão está preenchido no aTes			
@author Erick G. Dias
@since 12/05/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ChkOrdSFM(aTes,nOrdem,cTipoCF)

Local lRet	:= .F.

If cTipoCF == 'C'
	//CLIENTE
	//1==FM_PRODUTO				 	== aTes 01
	//2==FM_GRPROD  					== aTes 02
	//3==FM_POSIPI 					== aTes 03
	//4==FM_CLIENTE+FM_LOJACLI		== aTes4 + aTes5  
	//5==FM_GRTRIB 				 	== aTes6
	//6==FM_EST 					 	== aTes7
	//7==FM_REFGRD 			     	== aTes10
	//8==FM_GRPTI                  == aTes11
	//9==FM_TIPOCLI                == aTes 12
	//10==FM_GRPCST                == aTes 13	
	//11==FM_TIPOMOV				   ==aTes 15
	//12==FM_ORIGEM                == aTes 18
	
	Do Case
		Case nOrdem == 1	
			lRet	:= !Empty(aTes[1]) //FM_PRODUTO 				
		Case nOrdem == 2
			lRet	:= !Empty(aTes[2]) //FM_GRPROD				
		Case nOrdem == 3
			lRet	:= !Empty(aTes[3]) //FM_POSIPI								
		Case nOrdem == 4
			lRet	:= !Empty(aTes[4]+aTes[5]) //FM_CLIENTE+FM_LOJACLI
		Case nOrdem == 5
			lRet	:= !Empty(aTes[6]) //FM_GRTRIB			
		Case nOrdem == 6
			lRet	:= !Empty(aTes[7])//FM_EST				
		Case nOrdem == 7
			lRet	:= !Empty(aTes[10])//FM_REFGRD				
		Case nOrdem == 8
			lRet	:= !Empty(aTes[11])//FM_GRPTI				
		Case nOrdem == 9
			lRet	:= !Empty(aTes[12])//FM_TIPOCLI
		Case nOrdem == 10
			lRet	:= !Empty(aTes[13])//FM_GRPCST
		Case nOrdem == 11
			lRet	:= !Empty(aTes[15])//FM_TIPOMOV						
		Case nOrdem == 12 
			lRet	:= !Empty(aTes[18])//FM_ORIGEM 				
	EndCase
Else	
	//FORNECEDOR
	//1==FM_PRODUTO 			  	  	== aTes 01
	//2==FM_GRPROD  			   		== aTes 02
	//3==FM_POSIPI  			  	    == aTes 03
	//4==FM_FORNECE+FM_LOJAFOR  	== aTes 4 + aTes 5  
	//5==FM_GRTRIB 			   		== aTes 6
	//6==FM_EST                   	== aTes 7
	//7==FM_REFGRD              	== aTes 10
	//8==FM_GRPTI               	== aTes 11
	//9==FM_GRPCST              	== aTes 12
	//10==FM_ORIGEM                 == aTes 16
		
	Do Case
		Case nOrdem == 1	
			lRet	:= !Empty(aTes[1]) //FM_PRODUTO				
		Case nOrdem == 2
			lRet	:= !Empty(aTes[2]) //FM_GRPROD				
		Case nOrdem == 3
			lRet	:= !Empty(aTes[3]) //FM_POSIPI								
		Case nOrdem == 4
			lRet	:= !Empty(aTes[4]+aTes[5]) //FM_FORNECE+FM_LOJAFOR				
		Case nOrdem == 5
			lRet	:= !Empty(aTes[6]) //FM_GRTRIB				
		Case nOrdem == 6
			lRet	:= !Empty(aTes[7]) //FM_EST				
		Case nOrdem == 7
			lRet	:= !Empty(aTes[10]) //FM_REFGRD				
		Case nOrdem == 8
			lRet	:= !Empty(aTes[11]) //FM_GRPTI				
		Case nOrdem == 9
			lRet	:= !Empty(aTes[12]) //FM_GRPCST		
		Case nOrdem == 10 
			lRet	:= !Empty(aTes[16]) //FM_ORIGEM
	EndCase
EndIF

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CopySFM

@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param cAliasQry, Caracter, Alias da Query executada na SFM, com TES selecionados para realizar a cópia
@description Função que irá realizar a cópia da SFM para demais filiais 

/*/
//----------------------------------------------------------------------------------------------------
Static Function CopySFM(cAliasQry,lMark)
Local aDados	:= {}
Local aEstrut	:= SFM->(dbStruct()) //Monta estrutura da SFM
Local aAreaSM0  := SM0->(GetArea())
Local aSm0		:= {}
Local cTabela	:= 'SFM'
Local cFilCad	:= cFilAnt
Local cEmpCad	:= cEmpAnt
Local nCont		:= 0
Local cMensagem	:= ''
Local lProc		:= .T.
Local nHandle	:= CriaTxtLog()

Default lMark := .F.

If lMark	
	aSm0 	:= MatFilCalc( .T.,,,,,,.T. ) //Seleciona Filial
	IndRegua (cAliasQry,cAliasQry,"FM_TIPO",,"MARK=='X'")	// Filtra somente registros marcados
Else	
	aSm0 	:= MatFilCalc( .F.,,,,,,.T. )
Endif

//Inicia transação
Begin Transaction

//Laço nas filiais da empresa logada
For nCont := 1 to Len(aSm0)

	If lMark
		//Processa somente Filiais Marcadas
		lProc := aSm0[nCont][1]
	Else
		//Processa Todas Filiais
		lProc := .T.
	Endif

	
	If lProc
		SM0->(DbGoTop ())
		SM0->(MsSeek (cEmpCad+aSm0[nCont][2],.T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL
		
		IF cFilAnt <> cFilCad
			//Laço de TES que serão copiados para as filiais
			(cAliasQry)->(DbGoTop ())
			Do While !(cAliasQry)->(Eof ())
				
				//Verifica se o TES já existe na filial de destino, somente irá incluir se não existir
				IF ! ChkSFM(cAliasQry)	
					//Função que realizar cópia para filial de destino
					GrvTab(aEstrut, cAliasQry, cTabela, nHandle,lMark )
				Else
					//TODO Deverá gravar log indicando o código do TES + Descrição + Filial de destino que não foi possível realizar a cópia
				EndiF
						
				(cAliasQry)->(dbSkip())
				Loop
			EndDo
		EndIF
	EndIF
	
Next nCont

//Fecha alias e restaura filial logada
//Fecha alias e restaura filial logada
IF lMark
	//Limpa Objeto e Arquivo Temporario
	If !Empty(cAliasQry)    
		Ferase(cAliasQry+GetDBExtension())
		Ferase(cAliasQry+OrdBagExt())
		cAliasQry := ""
	Endif	
Else
	(cAliasQry)->(DbCloseArea ())
Endif

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

If (nHandle>=0)
	FClose (nHandle)
Endif

//Fecha transação 		
End Transaction

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvTab
 
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param aEstrut, Array, Estrutura da tabela que será copiada
@param cAliasQry, Caracter, Alias da Query executada da tabela que será copiada
@param cTabela, Caracter, Nome da tabela que será copiada
@description Função que irá realizar a cópia da SFM para demais filiais 

/*/
//----------------------------------------------------------------------------------------------------
Static Function GrvTab(aEstrut, cAliasQry, cTabela, nHandle,lMark )

Local nCont		:= 0
Local cLinha	:= ''

//Inclui nova linha na tabela
RecLock(cTabela,.T.)

//Gravação do campo _FILIAL será sempre com retorno do xFilial()
&(cTabela + "->" + Iif(Substr(cTabela,1,1) == 'S', Substr(cTabela,2,2) ,cTabela )   + "_FILIAL" ) := xFilial(cTabela)

//Laço nos campos da tabela estrutura do SX3
For nCont := 1 to Len(aEstrut)

	//Ignora campo de Marcação
	If lMark .And. aEstrut[nCont][1] =='MARK'
		Loop
	Endif
	
	If aEstrut[nCont][2] <> 'M'
		//Campo Filial não será copiado, já foi gravado anteriormente com conteúdo do xFilial
		If ! "FILIAL"  $ aEstrut[nCont][1]
			//Para campo tipo Date preciso utilizar a função TcSetField para que não ocorra erro de Type Mismatch
			If aEstrut[nCont][2] == 'D'
				&(cTabela + "->" +aEstrut[nCont][1] ) := StoD((cAliasQry)->&(aEstrut[nCont][1]))
			Else
				If aEstrut[nCont][2] == 'L'
					If (cAliasQry)->&(aEstrut[nCont][1]) == "T"
						&(cTabela + "->" +aEstrut[nCont][1] ) := .T.
					Else
						&(cTabela + "->" +aEstrut[nCont][1] ) := .F.
					EndIf	
				Else
					&(cTabela + "->" +aEstrut[nCont][1] ) := (cAliasQry)->&(aEstrut[nCont][1])	
				EndIf
			EndIF
		EndIf
	EndIf

	
Next nCont

MsUnLock()

cLinha	:= 'TES Inteligente replicada para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("SFM",1) == 'C' .OR. Empty(Alltrim(FWCompany())),''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("SFM",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())),''  , ', Unidade de Negócio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("SFM",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )   
cLinha	+=' : Tipo de Operação = '					+ (cAliasQry)->FM_TIPO   
cLinha	+=', Produto = ' 							+ (cAliasQry)->FM_PRODUTO  
cLinha	+=', Cliente/Loja = ' 						+ (cAliasQry)->FM_CLIENTE+'/'+(cAliasQry)->FM_LOJACLI
cLinha	+=', Fornecedor/Loja = ' 					+ (cAliasQry)->FM_FORNECE+'/'+(cAliasQry)->FM_LOJAFOR
cLinha	+=', Estado = ' 							+ (cAliasQry)->FM_EST 
cLinha	+=', Grupo de Tributação = ' 				+ (cAliasQry)->FM_GRTRIB
cLinha	+=', Grupo de Produto = ' 					+ (cAliasQry)->FM_GRPROD 
cLinha	+=', NCM = ' 								+ (cAliasQry)->FM_POSIPI 
cLinha	+=', TES de Entrada = ' 					+ (cAliasQry)->FM_TE
cLinha	+=', TES de Saída = ' 						+ (cAliasQry)->FM_TS
cLinha	+=', Grupo de TES Inteligente = '			+ (cAliasQry)->FM_GRPTI
cLinha	+=', Tipo de Cliente = ' 					+ (cAliasQry)->FM_TIPOCLI + ' ' 
cLinha	+= Chr (13)+Chr (10)

FWrite (nHandle, cLinha, Len (cLinha))

Return


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QrySFM
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param cCodSFM, Caracter, Estrutura da tabela que será copiada
@return	cAliasSFM, Caracter, Query realizada na SFM
@description Função que faz seleção do código de TES Inteligente que deverá ser copiado 

/*/
//----------------------------------------------------------------------------------------------------
Static Function QrySFM(nRecnoSFM)

Local cAliasSFM	:= "SFM"
Local cSlctSFM	:= ''

cSlctSFM :='%'
cSlctSFM += 'SFM.* ' //Preciso trazer todos os campos da SFM, por este motivo utilizo asterísco.
cSlctSFM +='%'
   	
cAliasSFM	:=	GetNextAlias()

BeginSql Alias cAliasSFM	
	SELECT			    
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL=%xFilial:SFM% AND
		SFM.R_E_C_N_O_= %Exp:nRecnoSFM% and
		SFM.%NotDel%	
EndSql
Return cAliasSFM

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkSFM
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função que verifica se regra de tes inteligente já existe 

/*/
//----------------------------------------------------------------------------------------------------
Static Function ChkSFM(cAliasSFM2)

Local cAliasSFM	:= "SFM"
Local cSlctSFM	:= ''
Local lExiste	:= .F.

cSlctSFM :='%'
cSlctSFM += 'SFM.FM_TIPO ' //Preciso trazer todos os campos da SFM, por este motivo utilizo asterísco.
cSlctSFM +='%'
   	
cAliasSFM	:=	GetNextAlias()
  	
BeginSql Alias cAliasSFM	
	SELECT			    
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL		=%xFilial:SFM% AND		
		SFM.FM_TIPO 		= %Exp:(cAliasSFM2)->FM_TIPO% 		AND
		SFM.FM_PRODUTO 		= %Exp:(cAliasSFM2)->FM_PRODUTO%	AND 
		SFM.FM_CLIENTE 		= %Exp:(cAliasSFM2)->FM_CLIENTE% 	AND
		SFM.FM_LOJACLI 		= %Exp:(cAliasSFM2)->FM_LOJACLI% 	AND
		SFM.FM_FORNECE 		= %Exp:(cAliasSFM2)->FM_FORNECE% 	AND
		SFM.FM_LOJAFOR 		= %Exp:(cAliasSFM2)->FM_LOJAFOR% 	AND
		SFM.FM_EST 			= %Exp:(cAliasSFM2)->FM_EST% 		AND
		SFM.FM_GRTRIB 		= %Exp:(cAliasSFM2)->FM_GRTRIB% 	AND
		SFM.FM_GRPROD 		= %Exp:(cAliasSFM2)->FM_GRPROD% 	AND
		SFM.FM_POSIPI 		= %Exp:(cAliasSFM2)->FM_POSIPI% 	AND
		SFM.FM_TE 			= %Exp:(cAliasSFM2)->FM_TE% 		AND
		SFM.FM_TS 			= %Exp:(cAliasSFM2)->FM_TS% 		AND		 
		SFM.FM_GRPTI 		= %Exp:(cAliasSFM2)->FM_GRPTI% 		AND
 		SFM.FM_TIPOCLI 		= %Exp:(cAliasSFM2)->FM_TIPOCLI% 	AND		
		SFM.%NotDel%	
EndSql


(cAliasSFM)->(DbGoTop ())
Do While !(cAliasSFM)->(Eof ())
	
	//Se entrou nesta linha significa que já existe esta regra cadastrada em outra filial
	lExiste	:= .T.	
	exit
	(cAliasSFM)->(dbSkip())
	Loop
EndDo

(cAliasSFM)->(DbCloseArea ())

Return lExiste

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldReplica
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função que faz validação se regra de tes inteligente já existe em alguma filial 

/*/
//----------------------------------------------------------------------------------------------------
Static Function VldReplica()

Local aAreaSM0  := SM0->(GetArea())
Local aSm0		:= MatFilCalc( .F.,,,,,,.T. )
Local nCont		:= 0
Local cMsg		:= ''
Local cEmpCad	:= cEmpAnt
Local cFilCad	:= cFilAnt

For nCont := 1 to Len(aSm0)

	SM0->(DbGoTop ())
	SM0->(MsSeek (cEmpCad+aSm0[nCont][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL	
	
	//A filial logada é desconsiderada
	IF cFilAnt <> cFilCad
				
		//Verifica se o TES Inteligente já existe na filial de destino, somente irá incluir se não existir
		IF PreChkSFM()	
			cMsg	+= 'TES Inteligente já existe na filial: ' + cFilAnt 	+ chr(13)+chr(10)
		EndiF
		
	EndIF

Next nCont

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

Return cMsg


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreChkSFM
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função que verifica se regra de tes inteligente já existe, considernado os campos digitados pelo 
	         usuário.		  

/*/
//----------------------------------------------------------------------------------------------------
Static Function PreChkSFM()

Local cAliasSFM	:= "SFM"
Local cSlctSFM	:= ''
Local lExiste	:= .F.

cSlctSFM :='%'
cSlctSFM += 'SFM.FM_TIPO ' //Preciso trazer todos os campos da SFM, por este motivo utilizo asterísco.
cSlctSFM +='%'
   	
cAliasSFM	:=	GetNextAlias()
  	
BeginSql Alias cAliasSFM	
	SELECT			    
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL		=%xFilial:SFM% AND		
		SFM.FM_TIPO 		= %Exp:M->FM_TIPO% 		AND
		SFM.FM_PRODUTO 		= %Exp:M->FM_PRODUTO%	AND 
		SFM.FM_CLIENTE 		= %Exp:M->FM_CLIENTE% 	AND
		SFM.FM_LOJACLI 		= %Exp:M->FM_LOJACLI% 	AND
		SFM.FM_FORNECE 		= %Exp:M->FM_FORNECE% 	AND
		SFM.FM_LOJAFOR 		= %Exp:M->FM_LOJAFOR% 	AND
		SFM.FM_EST 			= %Exp:M->FM_EST% 		AND
		SFM.FM_GRTRIB 		= %Exp:M->FM_GRTRIB% 	AND
		SFM.FM_GRPROD 		= %Exp:M->FM_GRPROD% 	AND
		SFM.FM_POSIPI 		= %Exp:M->FM_POSIPI% 	AND
		SFM.FM_TE 			= %Exp:M->FM_TE% 		AND
		SFM.FM_TS 			= %Exp:M->FM_TS% 		AND		 
		SFM.FM_GRPTI 		= %Exp:M->FM_GRPTI% 	AND
 		SFM.FM_TIPOCLI 		= %Exp:M->FM_TIPOCLI% 	AND		
		SFM.%NotDel%	
EndSql

(cAliasSFM)->(DbGoTop ())
Do While !(cAliasSFM)->(Eof ())
	
	//Se entrou nesta linha significa que já existe esta regra cadastrada em outra filial
	lExiste	:= .T.	
	exit
	(cAliasSFM)->(dbSkip())
	Loop
EndDo

(cAliasSFM)->(DbCloseArea ())

Return lExiste

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTxtLog
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função responsável por criar diretório e arquivo de log.	  

/*/
//----------------------------------------------------------------------------------------------------
Static Function CriaTxtLog()

Local cDiretorio	:=  GetSrvProfString("Startpath","") + 'FISCOPY'

IF ! ExistDir( cDiretorio ) 
	MakeDir( cDiretorio )
EndIf

Return FCREATE(cDiretorio + '\FISCOPY_SFM_' + StrTran(DtoC(dDataBase), "/","")+'_'+ StrTran(Time(), ":","" )+'.TXT', 0)


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkIdSFM
 
Função que irá verificar se o campo FM_ID já existe, se existir irá popular
a base legado preenchendo este campo.
			
@author Erick G. Dias
@since 04/09/2017
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ChkIdSFM(nQtde)

Local cChave	:= ''
Local lAtuSx5	:= .F.
Local cAliasSFM	:= ''
Local nCont		:= 0

conout(time()) 
If SFM->(FieldPos("FM_ID")) > 0 .AND. SX5->( dbSeek(xFilial('SX5')+"RV"+'SFM'))
	//Verifica se existe algum ID preenchido
	cChave	:= Substr(X5Descri(),1,6)
	
	ProcRegua (nQtde/10000)
	
	//Chama query para trazer as linhas com FM_ID com conteúdo vazio
	cAliasSFM	:= QrySFMID(.F.)
	DbSelectArea (cAliasSFM)
	(cAliasSFM)->(DbGoTop ())
		
	Do While !(cAliasSFM)->(Eof ())
		
		IF mod(nCont,10000) == 0
			IncProc('Atualizando Regra: ' + Alltrim(str(nCont)) + ' de : ' + Alltrim(str(nQtde)))
		EndiF
		
		//Aqui significa que existe linha na SFM com ID em branco que precisa ser alterado
		SFM->(dbGoto( (cAliasSFM)->RECNO  ))
		
		cChave	:= Soma1(cChave,6)	
		
		RecLock("SFM",.F.)
		SFM->FM_ID		:= cChave
		SFM->FM_DESCR	:= 'Regra de TES Inteligente ' + cChave
		MsUnlock()			
		lAtuSx5	:= .T.
		nCont++
		(cAliasSFM)->(DbSkip ())			
	EndDo

	DbSelectArea( cAliasSFM )
	( cAliasSFM )->( dbCloseArea () )
	
	
	If lAtuSx5 .AND. SX5->(dbSeek(xFilial("SX5")+"RV"+'SFM'))
		RecLock('SX5',.F.)
		SX5->X5_DESCRI		:= cChave
		SX5->X5_DESCSPA 	:= cChave
		SX5->X5_DESCENG 	:= cChave
		MsUnlock()
	EndIF	
	
EndIF
conout(time())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QrySFMID
 
Função que realiza a query na SFM em busca de linhas com o campo FM_ID
com conteúdo vazio 
			
@author Erick G. Dias
@since 11/09/2017
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function QrySFMID(lCount)

Local cSlctSFM		:= ''

IF lCount
	cSlctSFM :='%'
	cSlctSFM += 'Count(R_E_C_N_O_)  as QTDE'	
	cSlctSFM +='%'
Else
	cSlctSFM :='%'
	cSlctSFM += 'R_E_C_N_O_  as RECNO'	
	cSlctSFM +='%'
EndIF
  	
cAliasSFM	:=	GetNextAlias()
   	
BeginSql Alias cAliasSFM		
	SELECT			    
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL = %xFilial:SFM% AND
		SFM.FM_ID = ' ' AND			  
		SFM.%NotDel%	
EndSql

Return cAliasSFM

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcFMID
 
Função que retorna a quantidade de linhas na SFM com o campo FM_ID vazio
			
@author Erick G. Dias
@since 11/09/2017
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ProcFMID()

Local nQtde		:= 0
Local cAliasSFM	:= ''

If SFM->(FieldPos("FM_ID")) > 0 .AND. SX5->( dbSeek(xFilial('SX5')+"RV"+'SFM'))

	dbSelectArea("SFM")
	SFM->(dbSetOrder(3))
	
	cAliasSFM	:= QrySFMID(.T.)
	
	DbSelectArea (cAliasSFM)
	(cAliasSFM)->(DbGoTop ())
	
	If !(cAliasSFM)->(Eof ())
		nQtde	:= (cAliasSFM)->QTDE	
	EndIF
	
	DbSelectArea( cAliasSFM )
	( cAliasSFM )->( dbCloseArea () )
EndIF

Return nQtde  
