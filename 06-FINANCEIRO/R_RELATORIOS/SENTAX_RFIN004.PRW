#INCLUDE "FINR470.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE REC_NAO_CONCILIADO	1                                 
#DEFINE REC_CONCILIADO		2
#DEFINE PAG_NAO_CONCILIADO 	3
#DEFINE PAG_CONCILIADO		4

Static lFWCodFil := FindFunction("FWCodFil")

//-------------------------------------------------------------------
/*/{Protheus.doc} RFIN004
Relatório de extrato bancário, baseado no relatório padrão FINR470.

@sample		U_RFIN004()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
User Function RFIN004()

Local lExec			:= .T.

Private lTReport	:= .F.

lTReport := .T.
oReport := ReportDef()
If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf

oReport:PrintDialog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario.

@sample		ReportDef()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oBanco
Local oMovBanc
Local oSaldoAnt, oSaldoAtu, oTotais
Local nTamChave	 := TamSX3("E5_PREFIXO")[1]+TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1] + 3

AjustaSX1()
Pergunte("FIN470",.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na admin		 da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//"EXTRATO BANCARIO"
//"Este programa ir  emitir o relat¢rio de movimenta‡”es" "banc rias em ordem de data. Poder  ser utilizado para""conferencia de extrato."
oReport := TReport():New("RFIN004",STR0004,"FIN470", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002+" "+STR0003)
//desabilita o botao GESTAO CORPORATIVA do relatório
oReport:SetUseGC(.f.)
oBanco := TRSection():New(oReport,STR0035,{"SA6"},/*[Ordem]*/ )//"Dados Bancarios"
TRCell():New(oBanco,"A6_COD" 		,"SA6",STR0008,,23,.F.)//"BANCO"
TRCell():New(oBanco,"A6_AGENCIA"	,"SA6",STR0009) //"   AGENCIA "
TRCell():New(oBanco,"A6_NUMCON"	,"SA6",STR0010)//"   CONTA "
//TRCell():New(oBanco,"SALDOINI"	,		,STR0034,,20,,)//"SALDO INICIAL"

oSaldoAnt := TRSection():New(oReport,"Saldo Anterior",{"SE5"})
TRCell():New(oSaldoAnt,"SALDO_ANT","","SALDO ANTERIOR",,20)

oMovBanc := TRSection():New(oBanco,STR0036,{"SE5"})//"Movimentos Bancarios"
TRCell():New(oMovBanc,"E5_DTDISPO" ,"SE5",STR0025	,/*Picture*/,13,/*lPixel*/,{|| DtoC(E5_DTDISPO)}) //"DATA"
TRCell():New(oMovBanc,"E5_HISTOR"	,"SE5",STR0026	,,TamSX3("E5_HISTOR")[1]+10,,{|| SubStr(E5_HISTOR,1,TamSX3("E5_HISTOR")[1])})//"OPERACAO"
//TRCell():New(oMovBanc,"E5_NUMCHEQ"	,"SE5",STR0027	,,36,,{|| If(Len(Alltrim(E5_DOCUMEN)) + Len(Alltrim(E5_NUMCHEQ)) > 35,;  //"DOCUMENTO"
//																		Alltrim(SUBSTR(E5_DOCUMEN,1,20)) + If(!empty(Alltrim(E5_DOCUMEN)),"-"," ") + Alltrim(E5_NUMCHEQ ),;
//																		If(Empty(E5_NUMCHEQ),E5_DOCUMEN,E5_NUMCHEQ))})

TRCell():New(oMovBanc,"PREFIXO/TITULO"	,"SE5",STR0028	,,nTamChave+5,,{|| If(E5_TIPODOC="CH",ChecaTp(E5_NUMCHEQ+E5_BANCO+E5_AGENCIA+E5_CONTA),;
			E5_PREFIXO+If(Empty(E5_PREFIXO)," ","-")+E5_NUMERO+; //"PREFIXO/TITULO"
			If(Empty(E5_PARCELA)," ","-")+E5_PARCELA)})

TRCell():New(oMovBanc,"CHEQUE", "", "CHEQUE",,TamSX3("E5_NUMCHEQ")[1]+3,,{|| (cAliasSE5)->E5_NUMCHEQ })      

TRCell():New(oMovBanc,"E5_VALOR-ENTRAD","SE5",STR0029	,,20)//"ENTRADAS"
TRCell():New(oMovBanc,"E5_VALOR-SAIDA" ,"SE5",STR0030	,,20)//"SAIDAS"
TRCell():New(oMovBanc,"SALDO ATUAL"		,"SE5",STR0031	,,20,,{|| nSaldoAtu})//"SALDO ATUAL"
TRCell():New(oMovBanc,"TAXA"	,,STR0037,,12)//"CONCILIADOS"
TRCell():New(oMovBanc,"x-CONCILIADOS"	,"SE5",STR0016,,3)//"CONCILIADOS"

oSaldoAtu := TRSection():New(oReport,"Saldo Atual",{"SE5"})
TRCell():New(oSaldoAtu,"SALDO_ATU","","SALDO ATUAL",,20)

//oTotal := TRSection():New(oMovBanc,STR0032,{"SE5"},/*[Ordem]*/ )//"Totais"

//TRCell():New(oTotal,"DESCRICAO",,STR0033 ,,30,,)//"DESCRICAO"
//TRCell():New(oTotal,"NAOCONC"  ,,STR0015 ,,20,,)//"NAO CONCILIADOS"
//TRCell():New(oTotal,"CONC"		 ,,STR0016 ,,20,,)//"CONCILIADOS"
//TRCell():New(oTotal,"TOTAL" 	 ,,STR0017 ,,20,,)//"TOTAL"

//oTotal:SetLeftMargin(35)

oTotais := TRSection():New(oReport,"Totais",{"SE5"})

TRCell():New(oTotais,"VAZIO01",		"SE5",""	,/*Picture*/,13)
TRCell():New(oTotais,"VAZIO02",		"SE5",""	,,TamSX3("E5_HISTOR")[1]+10)
TRCell():New(oTotais,"DESCRICAO",	"SE5",""	,,nTamChave+TamSX3("E5_NUMCHEQ")[1]+9)
//TRCell():New(oMovBanc,"VAZIO03",	"SE5","",,TamSX3("E5_NUMCHEQ")[1]+3)
TRCell():New(oTotais,"ENTRADAS",	"SE5","ENTRADAS",,20)
TRCell():New(oTotais,"SAIDAS",		"SE5","SAIDAS",,20)
TRCell():New(oTotais,"VAZIO04",		"SE5","",,12)
TRCell():New(oTotais,"VAZIO05",		"SE5","",,3)

Return(oReport)

	
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario.

@sample		ReportPrint()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local oBanco	:= oReport:Section(1)
Local oSaldoAnt	:= oReport:Section(2)
Local oSaldoAtu	:= oReport:Section(3)
Local oTotais	:= oReport:Section(4)
Local oMovBanc	:= oReport:Section(1):Section(1)
//Local oTotal	:= oReport:Section(1):Section(1):Section(1)
Local cAlias
Local lAllFil	:= .F.
Local cChave	:= ""
Local cAliasSA6	:= "SA6"
Local cAliasSE5	:= "SE5"
Local cSql1:= cSql2	:= ""
Local nMoeda	:= GetMv("MV_CENT"+(IIF(mv_par06 > 1 , STR(mv_par06,1),"")))
Local lSpbInUse	:= SpbInUse()
Local nSaldoAtu	:= 0
Local cTabela14	:= ""
Local nCol		:= 0
Local aRecon 	:= {}
Local nTotEnt	:= 0
Local nTotSaida	:= 0
Local nLimCred	:= 0
Local nRecebNCon:= 0
Local nRecebConc:= 0
Local cPictVlr	:=	tm(SE5->E5_VALOR,15,nMoeda)
Local nX
Local aTotais := {}
Local nLinReport 	:= 8
Local nLinPag		:= mv_par08
Local cExpMda		:= ""
Local nCont 		:= 0
Local cCampos 		:= ""
Local nTaxa 		:= 0
Local lMultSld    	:= (FindFunction( "FXMultSld" ) .AND. FXMultSld())
Local lMsmMoeda   	:= .F.
Local lGestao		:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cAliasTmp
Local cFilSE5 := IIf(lGestao, FwFilial("SE5"), xFilial("SE5"))
Local cFilSE8 := IIf(lGestao, FWFilial("SE8"), xFilial("SE8"))
Local nSaldoIni	:=0
Local aAreaSE5
Local nDespVal := 0
Local oCellSaida := nil
Local nValTroco	:= 0
Local aAuxPos	:= {}
Local nEspDir := 6	
Local lTaxa := .F.


//-----------------------------------------------------------------------------------------------
// Aglutinacao de tarifas - AFSOUZA
Local aBMovBanco := Array(8)
Local nSaldoAux   := 0
Local nSaldoAux2  := 0
Local nDespSal    := 0
Local oCellSaldo  := nil
Local lHasTaxas   := .F.
//-----------------------------------------------------------------------------------------------


#IFNDEF TOP
	Local cCondicao := ""
	Local cFiltSE5 := oReport:Section(1):GetAdvplExp("SE5")
#ENDIF

Private nTxMoedBc := 0
Private nMoedaBco := 1

AAdd( aRecon, {0,0,0,0} )

If !Empty(mv_par08)
	nLinPag := IIf(MV_PAR08>=80,80,MV_PAR08)
Else
	nLinPag := 80
EndIf

dbSelectArea("SA6")
dbSetOrder(1)
IF !(dbSeek(cFilial+mv_par01+mv_par02+mv_par03))
	Help(" ",1,"BCONOEXIST")
	Return
EndIF

nMoedaBco	:=	Max(A6_MOEDA,1)

// Carrega a tabela 14
cTabela14 := FR470Tab14()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Saldo de Partida 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE8")
dbSetOrder(1)
dbSeek(xFilial("SE8")+mv_par01+mv_par02+mv_par03+Dtos(mv_par04),.T.)   // filial + banco + agencia + conta
dbSkip(-1)

IF E8_FILIAL != xFilial("SE8") .Or. E8_BANCO!=mv_par01 .or. E8_AGENCIA!=mv_par02 .or. E8_CONTA!=mv_par03 .or. BOF() .or. EOF()
	nSaldoAtu:=0
	nSaldoIni:=0
Else
	If mv_par07 == 1  //Todos
		nSaldoAtu:=Round(xMoeda(E8_SALATUA,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALATUA,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
	ElseIf mv_par07 == 2 //Conciliados
		nSaldoAtu:=Round(xMoeda(E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
	ElseIf mv_par07 == 3	//Nao Conciliados
		nSaldoAtu:=Round(xMoeda(E8_SALATUA-E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
		nSaldoIni:=Round(xMoeda(E8_SALATUA-E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
	Endif
Endif

// Deve considerar todas as filiais para selecao dos movimentos na query
If lGestao
	lAllFil := Empty( FWFilial( "SA6" ) ) .And. !Empty( FWFilial( "SE5" ) )
Else
	lAllFil := Empty( xFilial("SA6") ) .And. !Empty( xFilial("SE5") )
EndIf

If lAllFil
	cChave	:= "DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA"
Else
	cChave  := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA"
EndIf

If ExistBlock("F470ALLF")
	lAllFil := ExecBlock("F470ALLF",.F.,.F.,{lAllFil})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	
	cAlias := GetNextAlias()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBanco:BeginQuery()
	
	If	lAllFil
		cOrder  := "%E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ%"
	Else
		If nTamFilSE5 > nTamFilSA6 .OR. nTamFilSE5 == nTamFilSA6
			cSql1	:=	"E5_FILIAL = '" + xFilial("SE5") + "'" + " AND "
		Else
			cSql1	:=	"E5_FILIAL LIKE '" + Substr(xFilial("SE5"),1,nTamFilSA6) + "%'" + " AND "
		EndIf			
		//cSql1	:=	"E5_FILIAL = '" + xFilial("SE5") + "'" + " AND "
		If Empty(cFilSE5) .and. !Empty(cFilSE8)
			cSql1	+=	"E5_FILORIG = '" + xFilial("SE8") + "'" + " AND "
		Endif
		//cOrder  := "%E5_FILIAL,E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ%"   
		cOrder  := "%E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,SE5.R_E_C_N_O_,E5_NUMCHEQ,E5_DOCUMEN,E5_PREFIXO,E5_NUMERO%"
	EndIf
	If lSpbInuse
		cSql1	+=	" E5_DTDISPO >=  '"     + DTOS(mv_par04) + "' AND"
		cSql1	+=	" ((E5_DTDISPO <= '"+ DTOS(mv_par05) + "') OR "
		cSql1	+=	"  (E5_DTDISPO >= '"+ DTOS(mv_par05) + "' AND "
		cSql1	+=	"  (E5_DATA    >= '"+ DTOS(mv_par04) + "' AND "
		cSql1	+=	"   E5_DATA    <= '"+ DTOS(mv_par05) + "'))) AND"
	Else
		cSql1	+=	" E5_DTDISPO >= '" + DTOS(mv_par04) + "' AND"
		cSql1	+=	" E5_DTDISPO <= '" + DTOS(mv_par05) + "' AND"
	EndIf
	If mv_par07 == 2
		cSql1	+=	" E5_RECONC <> ' ' AND "
	ElseIf mv_par07 == 3
		cSql1	+=	" E5_RECONC = ' ' AND "
	EndIf
	
	cSql1 := "%"+cSql1+"%"
	cCampos := "E5_FILIAL,  E5_DTDISPO,	E5_HISTOR,	E5_NUMCHEQ,	E5_DOCUMEN, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPODOC, E5_FILORIG, "
	cCampos += "E5_RECPAG, 	E5_VALOR, 	E5_MOEDA, 	E5_VLMOED2, E5_CLIFOR, 	E5_LOJA, 	E5_RECONC, E5_TIPO, E5_SEQ, "
	cCampos += "SE5.R_E_C_N_O_ REGSE5, E5_NATUREZ, "
	
	//Necessario incluir alguns campos de acordo com a alteracao realizada para a exibicao no relatorio dos dados corretos
	//de um titulo a pagar quando baixado como normal e com cheque.
	cCampos += "E5_BANCO, E5_AGENCIA, E5_CONTA, "
	
	cCampos += "A6_FILIAL, 	A6_COD, 	A6_NREDUZ, 	A6_AGENCIA, A6_NUMCON, A6_LIMCRED"
	If SE5->( FieldPos("E5_TXMOEDA") > 0 )
		cCampos += ", E5_TXMOEDA "
	EndIf
	cCampos := "%"+cCampos+"%"
	
	cExpMda	:= "%E5_MOEDA NOT IN " + FormatIn(cTabela14+"/DO","/") + "%"
	
	BeginSql Alias cAlias
		Select	%Exp:cCampos%
		FROM 	%table:SE5% SE5
		LEFT JOIN %table:SA6% SA6 ON
		(E5_BANCO 	= A6_COD AND
		E5_AGENCIA	= A6_AGENCIA AND
		E5_CONTA 	= A6_NUMCON)
		WHERE 	%Exp:cSql1%
		A6_FILIAL 	= %xFilial:SA6% AND
		E5_BANCO 	= %Exp:mv_par01% AND
		E5_AGENCIA 	= %Exp:mv_par02% AND
		E5_CONTA 	= %Exp:mv_par03% AND
		E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','V2','C2','CP','TL','BA','I2','EI') AND
		NOT (E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ = '               ' AND (E5_TIPODOC NOT IN('TR','TE'))) AND
		NOT (E5_TIPODOC IN ('TR','TE') AND ((E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') OR (E5_DOCUMEN BETWEEN '*                ' AND '*ZZZZZZZZZZZZZZZZ' ))) AND
		NOT (E5_TIPODOC IN ('TR','TE') AND E5_NUMERO = '      ' AND %Exp:cExpMda% ) AND
		E5_SITUACA <> 'C' AND
		E5_VALOR   <> 0 AND
		NOT(E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') AND//NOT LIKE '*%' AND
		//(E5_VENCTO <= %Exp:DTOS(mv_par05)% OR E5_VENCTO <= E5_DATA) AND
		SE5.%notDel% AND
		SA6.%notDel%
		
		ORDER BY %exp:cOrder%
	EndSql
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBanco:EndQuery(/*Array com os parametros do tipo Range*/)
	
	oMovBanc:SetParentQuery()
	
	cAliasSA6	:= cAlias
	cAliasSE5 	:= cAlias
#ELSE
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao Advpl                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DbSelectArea("SE5")
	DbSetOrder(1)
	
	MakeAdvplExpr(oReport:uParam)
	
	If	lAllFil
		cOrder  := "DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
	Else
		cOrder  := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
		If nTamFilSE5 == nTamFilSA6 .or. nTamFilSE5 < nTamFilSA6
			cCondicao := 'E5_FILIAL == "' + xFilial("SE5")+'" .And.'
		Else
			cCondicao := "'" + Substr(E5_FILIAL,1,nTamFilSA6) + "' == " + "'" + Substr(xFilial("SE5"),1,nTamFilSA6)+"' .And. "
		EndIf	
		If Empty(cFilSE5) .and. !Empty(cFilSE8)
			cCondicao += 'E5_FILORIG == "' + xFilial("SE8")+'" .And.'
		Endif
	EndIf
	If lSpbInuse
		cCondicao	+=	" ((DTOS(E5_DTDISPO) <= '"+ DTOS(mv_par05) + "') .OR. "
		cCondicao	+=	"  (DTOS(E5_DTDISPO) >= '"+ DTOS(mv_par05) + "' .And. "
		cCondicao	+=	"  (DTOS(E5_DATA)    >= '"+ DTOS(mv_par04) + "' .And. "
		cCondicao	+=	"   DTOS(E5_DATA)    <= '"+ DTOS(mv_par05) + "'))) .And. "
	EndIf
	cCondicao += 'DTOS(E5_DTDISPO) >= "' + DTOS(mv_par04) + '" .And. '
	cCondicao += 'DTOS(E5_DTDISPO) <= "' + DTOS(mv_par05) + '" .And. '
	cCondicao += 'E5_BANCO   == "' + mv_par01 + '" .And. '
	cCondicao += 'E5_AGENCIA == "' + mv_par02 + '" .And. '
	cCondicao += 'E5_CONTA   == "' + mv_par03 + '" .And. '
	cCondicao += 'E5_SITUACA <> "C" .And. '   //Cancelado
	cCondicao += 'E5_VALOR   <> 0 .And. '
	cCondicao += '!(E5_TIPODOC $ "DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL/BA/I2/EI") .And. '
	cCondicao += '!(E5_MOEDA $ "C1/C2/C3/C4/C5/CH" .And. E5_NUMCHEQ = "               " .And. !(E5_TIPODOC $ "TR#TE")) .And.'
	cCondicao += '(DTOS(E5_VENCTO) <= "' + DTOS(mv_par05) + '".Or. E5_VENCTO <= E5_DATA)'
	
	//Adiciona filtro do usuário
	If !Empty(cFiltSE5)
		cCondicao += ' .And. ' + cFiltSE5
	EndIf
	
	oMovBanc:SetFilter( cCondicao, cOrder )
	
	oMovBanc:SetRelation( {|| xFilial((cAliasSE5))+(cAliasSA6)->(A6_COD+A6_AGENCIA+A6_NUMCON)},cAliasSA6,1,.T.)
	oMovBanc:SetParentFilter( {|cParam| (cAliasSE5)->(E5_BANCO+E5_AGENCIA+E5_CONTA) == cParam}, { || (cAliasSA6)->(A6_COD+A6_AGENCIA+A6_NUMCON) } )
	
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cMoeda := Upper(GetMv("MV_MOEDA"+LTrim(Str(mv_par06))))

nTxMoeda := If(nTxMoedBc > 1, nTxMoedBc,RecMoeda(iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06))
If alltrim(oReport:title()) == alltrim (STR0004)
	oReport:SetTitle(OemToAnsi(STR0007 + " " + DTOC(mv_par04) + STR0040 + Dtoc(mv_par05) + STR0039 + cMoeda))//"EXTRATO BANCARIO ENTRE "
Endif
oMovBanc:Cell("E5_VALOR-ENTRAD"	):SetPicture(tm(E5_VALOR,20,nMoeda))
oMovBanc:Cell("E5_VALOR-SAIDA"	):SetPicture(tm(E5_VALOR,20,nMoeda))
oMovBanc:Cell("TAXA"	):SetPicture(tm(E5_VALOR,12,nMoeda))
oMovBanc:Cell("SALDO ATUAL"		):SetPicture(tm(E5_VALOR,20,nMoeda))

If lMultSld .And. !Empty((cAliasSE5)->E5_TXMOEDA)
	If (cAliasSE5)->E5_RECPAG == "P"
		lMsmMoeda := Posicione("SE2",1,xFilial("SE2")+(cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E2_MOEDA") == mv_par06
	Else
		lMsmMoeda := Posicione("SE1",1,xFilial("SE1")+(cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E1_MOEDA") == mv_par06
	EndIf
EndIf

oMovBanc:Cell("SALDO ATUAL"		):SetBlock({|| nSaldoAtu += Round(xMoeda(F470VlMoeda(cAliasSE5);
,Iif((cPaisLoc <> "BRA" .And. ((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)) ,1, nMoedaBco );
,mv_par06;
,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
,nMoeda + 1;
,IIf(lMultSld, /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/	,	Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,1),nTxMoedBc)));
,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoeda))));
,nMoeda) * (If((cAliasSE5)->E5_RECPAG == 'R',1,-1)) })

oMovBanc:Cell("E5_VALOR-ENTRAD"	):SetHeaderAlign("RIGHT")
oMovBanc:Cell("E5_VALOR-SAIDA"	):SetHeaderAlign("RIGHT")
oMovBanc:Cell("SALDO ATUAL"		):SetHeaderAlign("RIGHT")
oMovBanc:Cell("TAXA"	   		):SetHeaderAlign("CENTER")

oMovBanc:Cell("CHEQUE"		):SetBlock({|| (cAliasSE5)->E5_NUMCHEQ })

oTotais:Cell("ENTRADAS"):SetPicture(tm(E5_VALOR,20,nMoeda))
oTotais:Cell("SAIDAS"):SetPicture(tm(E5_VALOR,20,nMoeda))

oTotais:Cell("ENTRADAS"):SetHeaderAlign("RIGHT")
oTotais:Cell("SAIDAS"):SetHeaderAlign("RIGHT")

// Se realiza controle de saldos em multiplas moedas
If lMultSld
	
	oMovBanc:Cell("E5_VALOR-ENTRAD"  ):SetBlock({|| If((cAliasSE5)->E5_RECPAG == "R", Round(xMoeda(F470VlMoeda(cAliasSE5),;
	nMoedaBco ,;
	mv_par06,;
	iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),;
	nMoeda,;
	IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ),;
	IIf(!lMsmMoeda,RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06),(cAliasSE5)->E5_TXMOEDA)),nMoeda), nil)})
	
	oMovBanc:Cell("E5_VALOR-SAIDA"   ):SetBlock({|| If((cAliasSE5)->E5_RECPAG == "P",;
	Round(xMoeda(F470VlMoeda(cAliasSE5),;
	nMoedaBco,;
	mv_par06,;
	iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),;
	nMoeda,;
	IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ),;
	IIf(!lMsmMoeda, RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06), (cAliasSE5)->E5_TXMOEDA)),nMoeda),;
	nil)})
	
Else
	
	oMovBanc:Cell("E5_VALOR-ENTRAD"  ):SetBlock({||If((cAliasSE5)->E5_RECPAG == "R", Round(xMoeda(F470VlMoeda(cAliasSE5);
	,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
	,mv_par06;
	,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
	,nMoeda+1;
	,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA", /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/,nTxMoedBc));
	,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06),nTxMoeda)));
	,nMoeda);
	,nil)})
	
	oMovBanc:Cell("E5_VALOR-SAIDA"   ):SetBlock({||;
	If((cAliasSE5)->E5_RECPAG == "P", ;
		Round(	xMoeda(F470VlMoeda(cAliasSE5),Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
		,mv_par06;
		,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
		,nMoeda+1;
		,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA", /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,nTxMoedBc));
		,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc,if(cPaisLoc=="BRA",RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06),nTxMoeda));
		);
		,nMoeda);
		, nil);
		})
	
	
EndIf

oMovBanc:Cell("x-CONCILIADOS"		):SetBlock({|| Iif(Empty((cAliasSE5)->E5_RECONC), " ", "x")})
oMovBanc:Cell("x-CONCILIADOS"		):SetTitle("")

If cPaisLoc <> "BRA"
	If cPaisLoc<>"ANG"
		If mv_par06 <> nMoedaBco .And. mv_par06 > 1
			oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(iif(MV_PAR09==1,dDataBase,E5_DTDISPO),mv_par06))})
		Else
			oMovBanc:Cell("TAXA"):Disable()
		EndIf
	Else
		If mv_par06 <> nMoedaBco
			If nMoedaBco>1
				oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(E5_DTDISPO,nMoedaBco))})
			Else
				oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,mv_par06),(cAliasSE5)->E5_TXMOEDA))})
			EndIf
		Else
			oMovBanc:Cell("TAXA"):Disable()
		EndIf
	EndIf
Else
	oMovBanc:Cell("TAXA"):Disable()
EndIf

oBanco:SetLineStyle()
oSaldoAnt:SetLineStyle()
oSaldoAtu:SetLineStyle()

If cPaisLoc == "BRA"
	nLimCred := (cAliasSA6)->(A6_LIMCRED)
Else
	If SA6->A6_MOEDA <> 1 .and. SA6->A6_MOEDA == mv_par06
		nLimCred := (cAliasSA6)->(A6_LIMCRED)
	Else
		nLimCred := xMoeda((cAliasSA6)->A6_LIMCRED,SA6->A6_MOEDA,1,dDataBase)
	EndIf
EndIf

oBanco:Init()

//Banco:Cell("SALDOINI"):SetBlock( { || Transform(nSaldoIni,tm(nSaldoIni,16,nMoeda)) } )
//oBanco:Cell("SALDOINI"):SetHeaderAlign("RIGHT")

oMovBanc:OnPrintLine( {|| F470LinPag(nLinPag, @nLinReport)})

(cAliasSE5)->(dbEval({|| nCont++}))
(cAliasSE5)->(dbGoTop())

If (cAliasSE5)->(Eof())
	oBanco:Cell("A6_COD"):SetBlock( {|| SA6->A6_COD +" - "+AllTrim(SA6->A6_NREDUZ)} )
	oBanco:Cell("A6_AGENCIA"):SetBlock( {|| SA6->A6_AGENCIA } )
	oBanco:Cell("A6_NUMCON"):SetBlock( {|| SA6->A6_NUMCON } )
	oBanco:PrintLine()
	oMovBanc:Init()
	oMovBanc:PrintLine()
	oMovBanc:Finish()
Else
	oBanco:Cell("A6_COD"):SetBlock( {|| (cAliasSA6)->A6_COD +" - "+AllTrim((cAliasSA6)->A6_NREDUZ)} )
	oReport:OnPageBreak( { || oBanco:PrintLine() } )
EndIf

oReport:SetMeter(nCont)

While !oReport:Cancel() .And. (cAliasSE5)->(!Eof())
	
	If oReport:Cancel()
		Exit
	EndIf
	
	If oBanco:Cancel()
		Exit
	EndIf
	
	lFirst := .T.
	
	If oReport:GetOrientation() == 1  	// Retrato
		oSaldoAnt:SetLeftMargin(137)
		oSaldoAtu:SetLeftMargin(140)
	Else                           		// Paisagem
		oSaldoAnt:SetLeftMargin(170)
		oSaldoAtu:SetLeftMargin(173)
	EndIf
	
	oReport:SetRow(280)
	oReport:PrtRight("SALDO ANTERIOR "+Transform(nSaldoIni,"@E 9,999,999,999.99")+Space(nEspDir))
	oReport:SkipLine()
	
	oMovBanc:Init()
	
	//-------------------------------------------
	// Aglutinacao de tarifas - AFSOUZA
	If MV_PAR11 == 1
		dDispoAnt := (cAliasSE5)->E5_DTDISPO
	EndIf
	//-------------------------------------------
	
	oMovBanc:Init()
	
	While !oReport:Cancel() .And. !(cAliasSE5)->(Eof())
		
		//oMovBanc:Cell("CHEQUE"):SetValue( (cAliasSE5)->E5_NUMCHEQ )
		
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()
		
		//-----------------------------------------------------------------------------------------------
		// Aglutinacao de tarifas - AFSOUZA
		//-----------------------------------------------------------------------------------------------
		If MV_PAR11 == 1
			
			If dDispoAnt != (cAliasSE5)->E5_DTDISPO	.AND. lHasTaxas
				
				aBMovBanco[1] := oMovBanc:Cell("E5_DTDISPO"      ):uValue
				aBMovBanco[2] := oMovBanc:Cell("E5_HISTOR"       ):uValue				
				aBMovBanco[3] := oMovBanc:Cell("PREFIXO/TITULO"  ):uValue
				aBMovBanco[4] := oMovBanc:Cell("CHEQUE"          ):uValue
				aBMovBanco[5] := oMovBanc:Cell("E5_VALOR-ENTRAD" ):uValue
				aBMovBanco[6] := oMovBanc:Cell("E5_VALOR-SAIDA"  ):uValue
				aBMovBanco[7] := oMovBanc:Cell("SALDO ATUAL"     ):uValue
				aBMovBanco[8] := oMovBanc:Cell("x-CONCILIADOS"   ):uValue
				
				
				oMovBanc:Cell("E5_DTDISPO"      ):SetValue(dDispoAnt)
				oMovBanc:Cell("E5_HISTOR"       ):SetValue("TARIFAS BANCARIAS")
				oMovBanc:Cell("PREFIXO/TITULO"  ):SetValue(nil)
				oMovBanc:Cell("CHEQUE"          ):SetValue(nil)				
				oMovBanc:Cell("E5_VALOR-ENTRAD" ):SetValue(nil)
				oMovBanc:Cell("E5_VALOR-SAIDA"  ):SetValue(nDespVal)
				oMovBanc:Cell("SALDO ATUAL"     ):SetValue(nSaldoAtu - nDespSal)
				oMovBanc:Cell("x-CONCILIADOS"   ):SetValue()
				
				oMovBanc:PrintLine()
				
				dDispoAnt := (cAliasSE5)->E5_DTDISPO
				nSaldoAtu += -nDespVal
				nDespVal  := 0
				nDespSal  := 0
				
				
				oMovBanc:Cell("E5_DTDISPO"      ):SetBlock(aBMovBanco[1])
				oMovBanc:Cell("E5_HISTOR"       ):SetBlock(aBMovBanco[2])				
				oMovBanc:Cell("PREFIXO/TITULO"  ):SetBlock(aBMovBanco[3])
				oMovBanc:Cell("CHEQUE"          ):SetBlock(aBMovBanco[4])
				oMovBanc:Cell("E5_VALOR-ENTRAD" ):SetBlock(aBMovBanco[5])
				oMovBanc:Cell("E5_VALOR-SAIDA"  ):SetBlock(aBMovBanco[6])
				oMovBanc:Cell("SALDO ATUAL"     ):SetBlock(aBMovBanco[7])
				oMovBanc:Cell("x-CONCILIADOS"   ):SetBlock(aBMovBanco[8])
				
				lHasTaxas := .F.
				
			EndIf
			
		EndIf
		//-----------------------------------------------------------------------------------------------
		
		// Posiciona no correspondente SE5 para permitir configuracoes condicionais de colunas
		#IFDEF TOP
			SE5->( dbGoTo( (cAliasSE5)->REGSE5 ) )
		#ELSE
			If (cAliasSE5)->E5_TIPODOC $ "TR/TE" .and. Empty((cAliasSE5)->E5_NUMERO)
				If !((cAliasSE5)->E5_MOEDA $ cTabela14)
					dbSkip()
					Loop
				Endif
			Endif
			If (cAliasSE5)->E5_TIPODOC $ "TR/TE" .and. (Substr((cAliasSE5)->E5_NUMCHEQ,1,1)=="*" .or. Substr((cAliasSE5)->E5_DOCUMEN,1,1) == "*" )
				dbSkip()
				Loop
			Endif
			If !Fr470Skip(mv_par01,mv_par02,mv_par03)
				(cAliasSE5)->(dbSkip())
				Loop
			EndIf
		#ENDIF
		
		// Em ambiente Mexico a informacao Troco nao esta sendo processada
		If (cAliasSE5)->E5_MOEDA=="TC" .and. cPaisLoc=="MEX"
			dbSkip()
			Loop
		Endif
		
		nTxMoedBc 	:= 0
		
		If (cAliasSE5)->E5_TIPODOC=="ES"
			aAreaSE5 := (cAliasSE5)->( GetArea() )
			cAliasTmp  :=Alias()
			cChave     := (cAliasSE5)->E5_FILIAL+(cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA+(cAliasSE5)->E5_SEQ
			
			DbSelectArea("SE5")
			DbSetOrder(7)
			DbGoTop()
			
			If DbSeek(cChave)
				If SE5->E5_TIPODOC=="V2"
					RestArea( aAreaSE5 )
					DbSelectArea(cAliasTmp)
					(cAliasSE5)->(dbSkip())
					Loop
				EndIf
			EndIf
			RestArea( aAreaSE5 )
			DbSelectArea(cAliasTmp)
			
		EndIf
		
		If cPaisloc<>"BRA"
			nTaxa := TxMoeda(cAliasSE5, nMoedaBco)
			If mv_par09 == 1
				nTxMoedBc := 0 //RecMoeda(dDatabase,nMoedaBco)
			Else
				nTxMoedBc := nTaxa
			Endif
		EndIf
		
		
		//-----------------------------------------------------------------------------------------------
		// Aglutinacao de tarifas - AFSOUZA
		//-----------------------------------------------------------------------------------------------
		If MV_PAR11 == 1 .AND. (cAliasSE5)->E5_NATUREZ == "DESP BANC "
			
			oCellSaldo := oMovBanc:Cell("SALDO ATUAL")
			oCellSaida := oMovBanc:Cell("E5_VALOR-SAIDA")
			
			nSaldoAux := nSaldoAtu
			
			
			Eval(oCellSaldo:uValue)
			
			nSaldoAux2 := Abs(Abs(nSaldoAtu) - Abs(nSaldoAux))
			
			nDespVal += Eval(oCellSaida:uValue)
			nDespSal += nSaldoAux2
			
			nSaldoAtu := nSaldoAux
			
			lHasTaxas := .T.
			
		Else
			oMovBanc:PrintLine()
		EndIf
		//-----------------------------------------------------------------------------------------------
		
		
		If Empty((cAliasSE5)->E5_RECONC) .AND. (cAliasSE5)->E5_RECPAG == "R"
			aRecon[1][REC_NAO_CONCILIADO] += Round(xMoeda( F470VlMoeda(cAliasSE5);
			,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
			,mv_par06;
			,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
			,nMoeda+1;
			,IIf(lMultSld, /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA", /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,nTxMoedBc)));
			,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 ,nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoedBc))));
			,nMoeda)
		ElseIf E5_RECPAG == "R"
			aRecon[1][REC_CONCILIADO] += Round(xMoeda(F470VlMoeda(cAliasSE5);
			,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
			,mv_par06;
			,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
			,nMoeda+1;
			,IIf(lMultSld,/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) )/**/ ,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,nTxMoedBc)));
			,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 ,nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoedBc))));
			,nMoeda)
		ElseIf Empty( E5_RECONC ) .AND. E5_RECPAG == "P"
			aRecon[1][PAG_NAO_CONCILIADO] += Round(xMoeda(F470VlMoeda(cAliasSE5);
			,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
			,mv_par06;
			,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
			,nMoeda+1;
			,IIf(lMultSld,/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) )/**/,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA", /**/ IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) /**/ ,nTxMoedBc)));
			,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 ,nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoeda))));
			,nMoeda)
		ElseIf E5_RECPAG == "P"
			aRecon[1][PAG_CONCILIADO] += Round(xMoeda(F470VlMoeda(cAliasSE5);
			,Iif((cPaisLoc<>"BRA".And.((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco );
			,mv_par06;
			,iif(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
			,nMoeda+1;
			,IIf(lMultSld,/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) )/**/,Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",/**/IIF(MV_PAR09 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) )/**/,nTxMoedBc)));
			,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(IIf(MV_PAR09==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 ,nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06),nTxMoedBc))));
			,nMoeda)
		EndIf
		
		(cAliasSE5)->(dbSkip())
	EndDo
	
	
	//-----------------------------------------------------------------------------------------------
	// Aglutinacao de tarifas - AFSOUZA
	//-----------------------------------------------------------------------------------------------
	If MV_PAR11 == 1 .AND. lHasTaxas
		
		aBMovBanco[1] := oMovBanc:Cell("E5_DTDISPO"      ):uValue
		aBMovBanco[2] := oMovBanc:Cell("E5_HISTOR"       ):uValue		
		aBMovBanco[4] := oMovBanc:Cell("PREFIXO/TITULO"  ):uValue
		aBMovBanco[3] := oMovBanc:Cell("CHEQUE"      	 ):uValue
		aBMovBanco[5] := oMovBanc:Cell("E5_VALOR-ENTRAD" ):uValue
		aBMovBanco[6] := oMovBanc:Cell("E5_VALOR-SAIDA"  ):uValue
		aBMovBanco[7] := oMovBanc:Cell("SALDO ATUAL"     ):uValue
		aBMovBanco[8] := oMovBanc:Cell("x-CONCILIADOS"   ):uValue
		
		nSaldoAtu -= nDespSal
		
		oMovBanc:Cell("E5_DTDISPO"      ):SetValue(dDispoAnt)
		oMovBanc:Cell("E5_HISTOR"       ):SetValue("TARIFAS BANCARIAS")		
		oMovBanc:Cell("PREFIXO/TITULO"  ):SetValue(nil)
		oMovBanc:Cell("CHEQUE"      	):SetValue(nil)
		oMovBanc:Cell("E5_VALOR-ENTRAD" ):SetValue(nil)
		oMovBanc:Cell("E5_VALOR-SAIDA"  ):SetValue(nDespVal)
		oMovBanc:Cell("SALDO ATUAL"     ):SetValue(nSaldoAtu)
		oMovBanc:Cell("x-CONCILIADOS"   ):SetValue()
		
		oMovBanc:PrintLine()
		
		oMovBanc:Cell("E5_DTDISPO"      ):SetBlock(aBMovBanco[1])
		oMovBanc:Cell("E5_HISTOR"       ):SetBlock(aBMovBanco[2])		
	 	oMovBanc:Cell("PREFIXO/TITULO"  ):SetBlock(aBMovBanco[3]) 
	 	oMovBanc:Cell("CHEQUE"      	):SetBlock(aBMovBanco[4])
		oMovBanc:Cell("E5_VALOR-ENTRAD" ):SetBlock(aBMovBanco[5])
		oMovBanc:Cell("E5_VALOR-SAIDA"  ):SetBlock(aBMovBanco[6])
		oMovBanc:Cell("SALDO ATUAL"     ):SetBlock(aBMovBanco[7])
		oMovBanc:Cell("x-CONCILIADOS"   ):SetBlock(aBMovBanco[8])
		
		lHasTaxas := .F.
		
	EndIf
	//-----------------------------------------------------------------------------------------------
	
	oMovBanc:Finish()
	oReport:SkipLine()
EndDo

oBanco:Finish()


/*
oSaldoAtu:Init()
oSaldoAtu:Cell("SALDO_ATU"):SetValue( Transform(nSaldoAtu,"@E 9,999,999,999.99") )
oSaldoAtu:PrintLine()
oSaldoAtu:Finish()
*/
oReport:PrtRight("SALDO ATUAL "+Transform(nSaldoAtu,"@E 9,999,999,999.99")+Space(nEspDir))
oReport:SkipLine()
oReport:SkipLine()

If !lTaxa
	oMovBanc:Cell("TAXA"):Disable()
EndIf

oTotais:Init()

oTotais:Cell("VAZIO01"):SetValue( "" )
oTotais:Cell("VAZIO02"):SetValue( "" )
//oTotais:Cell("VAZIO03"):SetValue( "" )
If lTaxa
	oTotais:Cell("VAZIO04"):SetValue( "" )
EndIf
oTotais:Cell("VAZIO05"):SetValue( "" )

oTotais:Cell("DESCRICAO"):SetValue( "Total de Lançamentos" )
oTotais:Cell("ENTRADAS"):SetValue( aRecon[1][REC_NAO_CONCILIADO] +  aRecon[1][REC_CONCILIADO] + nValTroco )
oTotais:Cell("SAIDAS"):SetValue( aRecon[1][PAG_NAO_CONCILIADO] +  aRecon[1][PAG_CONCILIADO] )
oTotais:PrintLine()
oTotais:Cell("DESCRICAO"):SetValue( "Total de Lançamentos Conciliados" )
oTotais:Cell("ENTRADAS"):SetValue( aRecon[1][REC_CONCILIADO] )
oTotais:Cell("SAIDAS"):SetValue( aRecon[1][PAG_CONCILIADO] )
oTotais:PrintLine()
oTotais:Cell("DESCRICAO"):SetValue( "Total de Lançamentos Não Conciliados" )
oTotais:Cell("ENTRADAS"):SetValue( aRecon[1][REC_NAO_CONCILIADO] + nValTroco )
oTotais:Cell("SAIDAS"):SetValue( aRecon[1][PAG_NAO_CONCILIADO] )
oTotais:PrintLine()
oTotais:Finish()


/*
AADD( aTotais ,{STR0014,,,nSaldoIni})//"SALDO INICIAL...........: "
AADD( aTotais ,{STR0018,aRecon[1][REC_NAO_CONCILIADO],aRecon[1][REC_CONCILIADO],aRecon[1][REC_NAO_CONCILIADO] +  aRecon[1][REC_CONCILIADO]})//"ENTRADAS NO PERIODO.....: "
AADD( aTotais ,{STR0019,aRecon[1][PAG_NAO_CONCILIADO],aRecon[1][PAG_CONCILIADO],aRecon[1][PAG_NAO_CONCILIADO] +  aRecon[1][PAG_CONCILIADO] })//"SAIDAS NO PERIODO ......: "
AADD( aTotais ,{STR0021,,,nLimCred})//"LIMITE DE CREDITO.......: "
AADD( aTotais ,{STR0020,,,nSaldoAtu += nLimCred})//"SALDO ATUAL ............: "

oTotal:Init()

oTotal:Cell("DESCRICAO"):HideHeader()
oTotal:Cell("NAOCONC"):SetHeaderAlign("CENTER")
oTotal:Cell("CONC"):SetHeaderAlign("CENTER")
oTotal:Cell("TOTAL"):SetHeaderAlign("CENTER")

For nX := 1 to 5
oTotal:Cell("DESCRICAO"):SetBlock( { || aTotais[nX][1] } )
oTotal:Cell("NAOCONC")	:SetBlock( { || If(nX == 2 .Or. nX == 3,Transform(aTotais[nX][2],tm(aTotais[nX][2],16,nMoeda)),"")} )
oTotal:Cell("CONC") 		:SetBlock( { || If(nX == 2 .Or. nX == 3,Transform(aTotais[nX][3],tm(aTotais[nX][3],16,nMoeda)),"")} )
oTotal:Cell("TOTAL")		:SetBlock( { || Transform(aTotais[nX][4],tm(aTotais[nX][4],16,nMoeda))} )
If nX == 2 .Or. nX == 5
oReport:SkipLine()
EndIf
oTotal:PrintLine()
Next


oReport:Title(STR0004)
oTotal:Finish()
*/  

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} F470VlMoeda
Retorno o campo de valor a ser utilizado para conversão

@sample		F470VlMoeda()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function F470VlMoeda(cAliasSE5)

Local nVlMoeda:=0
Local cMoeda
Local lSpbInUse := SpbInUse()

cMoeda := Iif((cPaisLoc<>"BRA" .And. ((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .And. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco )

If cPaisLoc $ "ARG|COL|DOM|EQU|MEX|VEN" //Gravaçao do SE5 nas rotinas localizadas são diferentes do Brasil.
	If cMoeda <> 1
		If (mv_par06 == 1) .OR. (mv_par06 == cMoeda)
			nVlMoeda := (cAliasSE5)->E5_VALOR
		Else
			If (cAliasSE5)->E5_VLMOED2 > 0
				nVlMoeda := (cAliasSE5)->E5_VLMOED2
			Else
				nVlMoeda := (cAliasSE5)->E5_VALOR
			EndIf
		EndIf
	Else
		nVlMoeda := (cAliasSE5)->E5_VALOR
	EndIf
	
Else
	
	If lSpbInUse .And. !lTReport
		cAliasSE5 := "TRB"
	EndIf
	
	If cMoeda <> 1
		nVlMoeda := (cAliasSE5)->E5_VALOR
		//***********************************************
		// Bloco comentado pois a movimentação bancaria *
		// é sempre feita na moeda do banco.            *
		//***********************************************
		/*If mv_par06 == 1 .and. (mv_par06 == cMoeda)
		nVlMoeda := (cAliasSE5)->E5_VALOR
		Else
		If (cAliasSE5)->E5_VLMOED2 > 0 .AND. !((cAliasSE5)->E5_TIPO $ MVRECANT ) // MOVIMENTO DE RA TEM COMPORTAMENTO DIFERENTE NA GRAVAÇÃO DA SE5
		nVlMoeda := (cAliasSE5)->E5_VLMOED2
		Elseif (cAliasSE5)->E5_TIPO $ MVRECANT .and. (cAliasSE5)->E5_RECPAG == "P" // MOVIMENTO DE RA TEM COMPORTAMENTO DIFERENTE NA GRAVAÇÃO DA SE5
		nVlMoeda := (cAliasSE5)->E5_VLMOED2
		Else
		nVlMoeda := (cAliasSE5)->E5_VALOR
		EndIf
	EndIf*/
	Else
   		nVlMoeda := (cAliasSE5)->E5_VALOR
	EndIf
	
Endif

Return (nVlMoeda)


//-------------------------------------------------------------------
/*/{Protheus.doc} F470LinPag
Faz a quebra de pagina de acordo com o parametro
por Pagina?" (mv_par08)

@sample		F470LinPag()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function F470LinPag(nLinPag, nLinReport)

nLinReport++

If nLinReport > (nLinPag + 8)
	oReport:EndPage()
	nLinReport := 9
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Insere novas perguntas ao sx1

@sample		AjustaSX1()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local aArea := GetArea()

Aadd( aHelpPor, "Informe o numero de linhas que serao "    )
Aadd( aHelpPor, "impressas .     "    )

Aadd( aHelpSpa, "Informe el numero de lineas que se "    )
Aadd( aHelpSpa, "imprimiran.      "    )

Aadd( aHelpEng, "Enter the number of lines to be "    )
Aadd( aHelpEng, "printed .  "    )

PutSx1( "FIN470", "08","Linhas por Pagina  ?","Lineas por Pagina  ?","Lines per Page  ?","mv_ch8","N",2,0,0,"G","","","","",;
"mv_par08"," ","","","55","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

//Incluso pergunta para considerar a taxa contratada ou taxa da data base
Aadd( aHelpPor, "Selecione qual a taxa sera utilizada "    )
Aadd( aHelpPor, "para a conversao do valores .     "    )
Aadd( aHelpSpa, "Seleccione la tasa que se utilisara "    )
Aadd( aHelpSpa, "para la conversion de los valores . "    )
Aadd( aHelpEng, "Select the rate to be used in order "    )
Aadd( aHelpEng, "to convert values  .  "    )

PutSx1( "FIN470", "09","Converte valores pela  ?","Conv. valores por la","Convert values by ?","mv_ch9","N",2,0,0,"C","","","","",;
"mv_par09","Data Base","Tasa dia","Daily Rate","","Data Movimento","Tasa Movimiento","Movement Rate","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

PutSX1Help("P.FIN47009.",aHelpPor,aHelpEng,aHelpSpa,.T.)

If cPaisLoc == "COL"
	DbSelectArea("SX1")
	dbSetOrder(1)
	If SX1->( MsSeek( PadR("FIN470", Len(SX1->X1_GRUPO) ) + "06" ) )//Dbseek(cteste)
		RecLock("SX1",.F.)
		Replace  X1_VALID With "VerifMoeda(mv_par06)"
		MsUnlock()
	EndIf
ENDIF

RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TxMoeda
Retorna taxa da moeda do movimento de transferencia caso
tenha sido informada. Caso contrario retorna a taxa do
cadastro de moedas (SM2)

@sample		TxMoeda()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function TxMoeda( cAliasSE5, nMoedaBco )

Local aArea	:= GetArea()
Local nTaxa	:= 0
Local cNum	:= (cAliasSE5)->E5_NUMCHEQ

If !Empty(cNum)
	SE5->(dbSetOrder(10))
	SE5->(MsSeek(xFilial("SE5")+cNum))
	If MV_PAR09 == 1
		nTaxa := RecMoeda(dDatabase,mv_par06)
	ElseIf (cAliasSE5)->(FieldPos("E5_TXMOEDA") > 0) .And. (cAliasSE5)->E5_TXMOEDA == 1 .And.;
		(cAliasSE5)->(FieldPos("E5_MOEDA")   > 0) .And. Val((cAliasSE5)->E5_MOEDA) == 1
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06)
	ElseIf (cAliasSE5)->( FieldPos("E5_TXMOEDA") > 0) .And. !Empty((cAliasSE5)->E5_TXMOEDA)
		nTaxa := (cAliasSE5)->E5_TXMOEDA
	Else
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,mv_par06)
	EndIf
Else
	If MV_PAR09 == 1
		nTaxa := RecMoeda(dDatabase,nMoedaBco)
	ElseIf (cAliasSE5)->( FieldPos("E5_TXMOEDA") > 0) .And. !Empty((cAliasSE5)->E5_TXMOEDA) .And. ( Val((cAliasSE5)->E5_MOEDA) == nMoedaBco .or. (cAliasSE5)->E5_TIPO $ MVPAGANT+MVRECANT ) // QUANDO É ADIANTAMENTO O CAMPO E5_MOEDA FICA EM BRANCO
		nTaxa := (cAliasSE5)->E5_TXMOEDA
	Elseif (cAliasSE5)->( FieldPos("E5_TXMOEDA") > 0) .And. !Empty((cAliasSE5)->E5_TXMOEDA) .And. ( nMoedaBco <> 1 .and. (cAliasSE5)->E5_TXMOEDA > 0)
		nTaxa := (cAliasSE5)->E5_TXMOEDA //Caso de moeda contratada. Ou seja, valor da taxa da moeda fornecido por exemplo em cta a receber ou movimento bancario a receber.
	Else
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,nMoedaBco)
	EndIf
EndIf

RestArea( aArea )

Return( nTaxa )


//-------------------------------------------------------------------
/*/{Protheus.doc} FR470Tab14
Carrega e retorna moedas da tabela 14

@sample		FR470Tab14()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function FR470Tab14()

Local cTabela14 := ""

SX5->(DbSetOrder(1))
SX5->(MsSeek(xFilial("SX5")+"14"))
While SX5->(!Eof()) .And. SX5->X5_TABELA == "14"
	cTabela14 += (Alltrim(SX5->X5_CHAVE) + "/")
	SX5->(DbSkip())
End
cTabela14 += If(cPaisLoc=="BRA","","/$ ")
If cPaisLoc == "BRA"
	cTabela14 := SubStr( cTabela14, 1, Len(cTabela14) - 1 )
EndIf

Return cTabela14


//-------------------------------------------------------------------
/*/{Protheus.doc} ChecaTp
Essa funcao retorna os dados do arquivo SEF para movimentos
bancarios do tipo CH.

@sample		ChecaTp()

@author		Alessandro Smaha
@since		12/02/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function ChecaTp(cChaveTp)

Local cRetorno := ""
Local cChavSef := ""
Local aArea    := GetArea()
Local nSoma := 0

If(E5_TIPODOC="CH")
	cChavSef := (xFilial("SE5")+cChaveTp)
	SEF->(dbSetOrder(4))
	If SEF->(Dbseek(cChavSef))
		dbSelectArea("SEF")
		While !EOF() .and. (EF_FILIAL+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) = cChavSef .and. nSoma <= 1
			If !Empty(EF_TIPO)
				nSoma++
				cRetorno := EF_PREFIXO+If(Empty(EF_PREFIXO)," ","-")+EF_TITULO+If(Empty(EF_PARCELA)," ","-")+EF_PARCELA
			Endif
			SEF->(Dbskip())
		Enddo
	Else
		cChavSef := (E5_FILORIG+cChaveTp)
		dbSelectArea("SEF")
		SEF->(dbSetOrder(4))
		SEF->(Dbseek(cChavSef))
		While !EOF() .and. (EF_FILIAL+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) = cChavSef .and. nSoma <= 1
			If !Empty(EF_TIPO)
				nSoma++
				cRetorno := EF_PREFIXO+If(Empty(EF_PREFIXO)," ","-")+EF_TITULO+If(Empty(EF_PARCELA)," ","-")+EF_PARCELA
			Endif
			SEF->(Dbskip())
		Enddo
	EndIf
	
	If nSoma > 1
		cRetorno := "   "
		nSoma := 0
	Endif
	
	dbCloseArea()
	RestArea(aArea)
	nSoma := 0
EndIf

Return (cRetorno)
