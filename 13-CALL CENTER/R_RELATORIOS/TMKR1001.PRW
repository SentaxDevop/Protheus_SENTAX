#INCLUDE "TMKR038.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMKR038  ³ Autor ³ Armando M. Tessaroli  ³ Data ³ 19/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relacao de atendimentos no Telecobranca.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Telecobranca (ACF)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Hanna     ³13/07/06³99208 ³- Alterado para relatorio personalizavel    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TMKR038()
Local oReport					// Objeto Report
Local aArea := GetArea()		// Salva a area

If !FindFunction("TRepInUse") .OR. !TRepInUse()
                                                                                           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa versao anterior do fonte³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	R038R3()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                          ³
	//³ Mv_Par01           // Do Atendimento                          ³
	//³ Mv_Par02           // Ate o Atendimento                       ³
	//³ Mv_Par03           // Do Cliente                              ³
	//³ Mv_Par04           // Da Loja                                 ³
	//³ Mv_Par05           // Ate o Cliente                           ³
	//³ Mv_Par06           // Ate a Loja                              ³
	//³ Mv_Par07           // Do Operador                             ³
	//³ Mv_Par08           // Ate o Operador                          ³
	//³ Mv_Par09           // Da Data                                 ³
	//³ Mv_Par10           // Ate a Data                              ³
	//³ Mv_Par11           // Tipo de Ligacao                         ³
	//³ Mv_Par12           // Ocorrencia                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("TMK038",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := Tkr038RptDef()
	oReport:PrintDialog()
EndIf

RestArea( aArea )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMKR038  ³ Autor ³ Armando M. Tessaroli  ³ Data ³ 19/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relacao de atendimentos no Telecobranca.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Telecobranca (ACF)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Couto     ³20/06/05³8.11  ³- Alterado cString para a tabela ACF        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function R038R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel   	:= "TMKR038"  	 		// Nome do Arquivo utilizado no Spool
Local Titulo 	:= STR0001 				//"Atendimentos do Telecobranca"
Local cDesc1 	:= STR0002 				//"Este programa ira emitir a relacao dos atendimentos efetuados pelo atendimento de Telecobranca"
Local cDesc2 	:= STR0003 				//"Os dados serao emitidos conforme os parametros informados."
Local cDesc3 	:= STR0004 				//"Serao considerados os atendimentos Ativos e Receptivos."
Local nomeprog	:= "TMKR038.PRX"		// nome do programa
Local cString 	:= "ACF"				// Alias utilizado na Filtragem
Local lDic    	:= .F. 					// Habilita/Desabilita Dicionario
Local lComp   	:= .F. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .T. 					// Habilita/Desabilita o Filtro

Private Tamanho := "G" 					// P/M/G
Private Limite  := 220 					// 80/132/220
Private aReturn := { STR0005,;			// [1] Reservado para Formulario //"Zebrado"
					 1,;				// [2] Reservado para N§ de Vias
					 STR0006,;			// [3] Destinatario //"Administracao"
					 2,;				// [4] Formato => 1-Comprimido 2-Normal	
					 2,;	    		// [5] Midia   => 1-Disco 2-Impressora
					 1,;				// [6] Porta ou Arquivo 1-LPT1... 4-COM1...
					 "",;				// [7] Expressao do Filtro
					 1 } 				// [8] Ordem a ser selecionada
					 					// [9]..[10]..[n] Campos a Processar (se houver)
Private m_pag   := 1  				 	// Contador de Paginas
Private nLastKey:= 0  				 	// Controla o cancelamento da SetPrint e SetDefault
Private cPerg   := "TMK038"  		 	// Pergunta do Relatorio
Private aOrdem  := {}  				 	// Ordem do Relatorio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                          ³
//³ Mv_Par01           // Do Atendimento                          ³
//³ Mv_Par02           // Ate o Atendimento                       ³
//³ Mv_Par03           // Do Cliente                              ³
//³ Mv_Par04           // Da Loja                                 ³
//³ Mv_Par05           // Ate o Cliente                           ³
//³ Mv_Par06           // Ate a Loja                              ³
//³ Mv_Par07           // Do Operador                             ³
//³ Mv_Par08           // Ate o Operador                          ³
//³ Mv_Par09           // Da Data                                 ³
//³ Mv_Par10           // Ate a Data                              ³
//³ Mv_Par11           // Tipo de Ligacao                         ³
//³ Mv_Par12           // Ocorrencia                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(	cString	, wnrel		, cPerg		, @titulo	,;
					cDesc1	, cDesc2	, cDesc3	, lDic		,;
					aOrdem	, lComp		, Tamanho	, lFiltro )

If (nLastKey == 27)
	DbSelectArea(cString)
	DbSetOrder(1)
	DbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If (nLastKey == 27)
	DbSelectArea(cString)
	DbSetOrder(1)
	DbClearFilter()
	Return
Endif

RptStatus({|lEnd| TK038Imp(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C038IMP  ³ Autor ³ Armando Tessaroli     ³ Data ³ 21.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio - TeleCobranca                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKR038			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK038Imp(	lEnd	, wnrel	, cString	, nomeprog	,;
							Titulo )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao Do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo relatorio
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= "" 			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis especificas para este relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAtend 	:= ""				// Cuida da quebra dos atendimentos por cliente
Local nTot01	:= 0				// Totaliza pelo status PAGO
Local nTot02	:= 0				// Totaliza pelo status NEGOCIADO
Local nTot03	:= 0				// Totaliza pelo status CARTORIO
Local nTAtend01	:= 0				// Totaliza o Valor
Local nTAtend02	:= 0				// Totaliza o Acrescimo
Local nTAtend03	:= 0				// Totaliza o Decrescimo
Local nTAtend04	:= 0				// Totaliza o Valor Juros
Local nTAtend05	:= 0				// Totaliza o IRRF
Local nTAtend06	:= 0				// Totaliza o ISS
Local nTAtend07	:= 0				// Totaliza o CSLL
Local nTAtend08	:= 0				// Totaliza o COFINS
Local nTAtend09	:= 0				// Totaliza o PIS
Local cACF		:= "ACF"			// Para comandar o alias valido na operacao, motivo >> diferenca entre TOP e DBF
Local cACG		:= "ACG"			// Para comandar o alias valido na operacao, motivo >> diferenca entre TOP e DBF
Local aACG_Status	:= TkSx3Box("ACG_STATUS")		// Pesquisa as opcoes do campo no DD SX3
Local aACF_Opera	:= TkSx3Box("ACF_OPERA")		// Pesquisa as opcoes do campo no DD SX3
Local aLinhas	:= {}				// Guarda as linhas do campo memo
Local cDesc		:= ""				// Manipula a descricao do resultado do seek
Local nI		:= 0

#IFDEF TOP
	Local cQuery	:= ""		// Armazena a expressao da query para top
	Local aStruACF	:= ACF->(DbStruct())
	Local aStruACG	:= ACG->(DbStruct())
#ENDIF

// Se vai quebra por cliente entao seleciono a cabeca e ordeno por cliente
DbSelectArea("ACF")
DbSetOrder(1)
SetRegua(RecCount())

#IFDEF TOP
	cACG := "ACF"
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("ACF") + " ACF, " + RetSqlName("ACG") + " ACG "
	cQuery += " WHERE	ACF.ACF_FILIAL = '" + xFilial("ACF") + "' AND "
	cQuery += "			ACF.ACF_CODIGO BETWEEN '" + Mv_Par01 + "' AND '" + Mv_Par02 + "' AND "
	cQuery += "			ACF.ACF_CLIENT BETWEEN '" + Mv_Par03 + "' AND '" + Mv_Par05 + "' AND "
	cQuery += "			ACF.ACF_LOJA BETWEEN '" + Mv_Par04 + "' AND '" + Mv_Par06 + "' AND "
	cQuery += "			ACF.ACF_OPERAD BETWEEN '" + Mv_Par07 + "' AND '" + Mv_Par08 + "' AND "
	cQuery += "			ACF.ACF_ULTATE BETWEEN '" + DtoS(Mv_Par09) + "' AND '" + DtoS(Mv_Par10) + "' AND "
	If Mv_Par11 != 3	// Se nao for AMBOS, pego apenas ATIVO ou RECEPTIVO
		cQuery += " ACF.ACF_OPERA = '" + Str(Mv_Par11,1) + "' AND "
	Endif
	
	If !Empty(Mv_Par12)		// Se escolheu uma ocorrencia so pego ela
		cQuery += " ACF.ACF_MOTIVO = '" + Mv_Par12 + "' AND "
	Endif
	
	cQuery += " ACG.ACG_FILIAL = '" + xFilial("ACG") + "' AND "
	cQuery += " ACG.ACG_CODIGO = ACF.ACF_CODIGO AND "
	cQuery += " ACG.D_E_L_E_T_ = '' AND "
	cQuery += " ACF.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY " + SqlOrder(IndexKey())
	
	// Agora retorno os dados e até mais rapido, pois a pesquisa ja esta no buffer
	cQuery := ChangeQuery(cQuery)
	// MemoWrite("TMKR038.SQL", cQuery)
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACF', .F., .T.)
	
	For nI := 1 To Len(aStruACF)
		If aStruACF[nI][2] $ "NDL"
			TCSetField('ACF', aStruACF[nI][1], aStruACF[nI][2], aStruACF[nI][3], aStruACF[nI][4])
		Endif
	Next nI
	
	For nI := 1 To Len(aStruACG)
		If aStruACG[nI][2] $ "NDL"
			TCSetField('ACF', aStruACG[nI][1], aStruACG[nI][2], aStruACG[nI][3], aStruACG[nI][4])
		Endif
	Next nI
#ELSE
	MsSeek(xFilial("ACF") + Mv_Par01, .T.)		// Codigo do atendimento
#ENDIF

While	(!Eof()) .AND.;
		(ACF->ACF_FILIAL == xFilial("ACF")) .AND.;
		(ACF->ACF_CODIGO) >= Mv_Par01 .AND.;
		(ACF->ACF_CODIGO) <= Mv_Par02
	
	IncRegua()
	
	If lEnd
		@Prow()+1,001 PSay STR0007 //"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera filtro do usuario                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(aReturn[7])) .AND. (!&(aReturn[7]))
		DbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avalia os parametros para DBF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFNDEF TOP
		If ACF->ACF_CLIENT < Mv_Par03 .OR. ACF->ACF_CLIENT > Mv_Par05
			DbSkip()
			Loop
		Endif
		
		If ACF->ACF_LOJA < Mv_Par04 .OR. ACF->ACF_LOJA > Mv_Par06
			DbSkip()
			Loop
		Endif
		
		If ACF->ACF_OPERAD < Mv_Par07 .OR. ACF->ACF_OPERAD > Mv_Par08
			DbSkip()
			Loop
		Endif
		
		If ACF->ACF_ULTATE < Mv_Par09 .OR. ACF->ACF_ULTATE > Mv_Par10
			DbSkip()
			Loop
		Endif

		If Mv_Par11 != 3	// Se a opcao nao for AMBOS ignoro as invalidas ATIVO ou RECEPTIVO
			If ACF->ACF_OPERA <> Str(Mv_Par06,1)
				DbSkip()
				Loop
			Endif
		Endif
		
		If !Empty(Mv_Par12)		// Se especificou uma ocorrencia ignoro o que for diferente
			If ACF->ACF_MOTIVO <> Mv_Par07
				DbSkip()
				Loop
			Endif
		Endif
	#ENDIF
		
	// imprime o cabecalho do atendimento
	If cAtend <> (cACF)->ACF_CODIGO
		cAtend := (cACF)->ACF_CODIGO
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtFatLine()
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR(STR0008,25) //"Data do Atendimento"
		@ nLi,PCol()+1	PSay PadR(DtoC((cACF)->ACF_ULTATE),80)
		@ nLi,Limite/2	PSay PadR(STR0009,25) //"Codigo do Atendimento"
		@ nLi,PCol()+1	PSay PadR((cACF)->ACF_CODIGO,80)

		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR(STR0010,25) //"Tipo de Ligacao"
		@ nLi,PCol()+1	PSay PadR(IIF(Val((cACF)->ACF_OPERA)>0,aACF_Opera[Val((cACF)->ACF_OPERA)],STR0011),80) //"Nao Informado"
		@ nLi,Limite/2	PSay PadR(STR0012,25) //"Retornar em"
		@ nLi,PCol()+1	PSay (cACF)->ACF_PENDEN
		@ nLi,PCol()+1	PSay STR0013 //"às"
		@ nLi,PCol()+1	PSay (cACF)->ACF_HRPEND
		
		If !Empty((cACF)->ACF_CLIENT) .AND. !Empty((cACF)->ACF_LOJA)
			DbSelectArea("SA1")
			DbSetOrder(1)
			If MsSeek(xFilial("SA1") + (cACF)->ACF_CLIENT + (cACF)->ACF_LOJA)
				cDesc := SA1->A1_NOME
			Else
				cDesc := STR0014 //"Nao Localizado no cadastro..."
			Endif
        Else
			cDesc := STR0015 //"Nao Informado no atendimento..."
		Endif
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR(STR0016,25) //"Codigo Cliente/Loja"
		@ nLi,PCol()+1	PSay PadR((cACF)->ACF_CLIENT + " / " + (cACF)->ACF_LOJA,80)
		@ nLi,Limite/2	PSay PadR(STR0017,25) //"Razao Social"
		@ nLi,PCol()+1	PSay PadR(cDesc,80)
		
		If !Empty((cACF)->ACF_CODCON)
			DbSelectArea("SU5")
			DbSetOrder(1)
			If MsSeek(xFilial("SU5") + (cACF)->ACF_CODCON)
				cDesc := SU5->U5_CONTAT
			Else
				cDesc := STR0014 //"Nao Localizado no cadastro..."
			Endif
        Else
			cDesc := STR0015 //"Nao Informado no atendimento..."
		Endif
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR(STR0018,25) //"Codigo do Contato"
		@ nLi,PCol()+1	PSay PadR((cACF)->ACF_CODCON,80)
		@ nLi,Limite/2	PSay PadR(STR0019,25) //"Nome do Contato"
		@ nLi,PCol()+1	PSay PadR(cDesc,80)
		
		If !Empty((cACF)->ACF_OPERAD)
			DbSelectArea("SU7")
			DbSetOrder(1)
			If MsSeek(xFilial("SU7") + (cACF)->ACF_OPERAD)
				cDesc := SU7->U7_NOME
			Else
				cDesc := STR0014 //"Nao Localizado no cadastro..."
			Endif
        Else
			cDesc := STR0015 //"Nao Informado no atendimento..."
		Endif
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR(STR0020,25) //"Codigo do Operador"
		@ nLi,PCol()+1	PSay PadR((cACF)->ACF_OPERAD,80)
		@ nLi,Limite/2	PSay PadR(STR0021,25) //"Nome do Operador"
		@ nLi,PCol()+1	PSay PadR(cDesc,80)
		
		If !Empty((cACF)->ACF_MOTIVO)
			DbSelectArea("SU9")
			DbSetOrder(2)    	// Codigo da Ocorrencia
			If MsSeek(xFilial("SU9") + (cACF)->ACF_MOTIVO)
				cDesc := SU9->U9_DESC
			Else
				cDesc := STR0014 //"Nao Localizado no cadastro..."
			Endif
        Else
			cDesc := STR0015 //"Nao Informado no atendimento..."
		Endif
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR(STR0022,25) //"Codigo da Ocorrencia"
		@ nLi,PCol()+1	PSay PadR((cACF)->ACF_MOTIVO,80)
		@ nLi,Limite/2	PSay PadR(STR0023,25) //"Descricao da Ocorrencia"
		@ nLi,PCol()+1	PSay PadR(cDesc,80)
		
		aLinhas := TkMemo((cACF)->ACF_CODOBS, 195)
		For nI := 1 to Len(aLinhas)
			TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
			If nI == 1
				@ nLi,000 PSay PadR(STR0024,25) //"Observacao"
			Endif
			@ nLi,26 PSay aLinhas[nI]
		Next nI
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtFatLine()
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR(STR0025,Limite) //"Prf Título-P Tip Natureza   Vencto   V. Real         Valor   Acrésc  Decrésc Núm Banco       Historico                  %Per  Val Jur     IRRF      ISS     CSLL   COFINS      PIS Status          Resp.  Nome do Responsavel"
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		
	Endif
	
	#IFNDEF TOP
		DbSelectArea("ACG")
		DbSetOrder(1)
		MsSeek(xFilial("ACG") + ACF->ACF_Codigo)
		While	(!Eof()) 								.AND.;
				(ACG->ACG_FILIAL == xFilial("ACG")) 	.AND.;
				(ACG->ACG_CODIGO == ACF->ACF_CODIGO)
	#ENDIF
			
			// Agora vamos imprimir todos os titulos
			TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
			@ nLi,000		PSay (cACG)->ACG_PREFIX
			@ nLi,PCol()+1	PSay (cACG)->ACG_TITULO + "-" + (cACG)->ACG_PARCEL
			@ nLi,PCol()+1	PSay (cACG)->ACG_TIPO
			@ nLi,PCol()+1	PSay (cACG)->ACG_NATURE
			@ nLi,PCol()+1	PSay (cACG)->ACG_DTVENC
			@ nLi,PCol()+1	PSay (cACG)->ACG_DTREAL
			@ nLi,PCol()+1	PSay Transform((cACG)->ACG_VALOR, '@E 9,999,999.99')
			@ nLi,PCol()+1	PSay Transform((cACG)->ACG_ACRESC, '@E 9,999.99')
			@ nLi,PCol()+1	PSay Transform((cACG)->ACG_DECRES, '@E 9,999.99')
			@ nLi,PCol()+1	PSay (cACG)->ACG_NUMBCO
			@ nLi,PCol()+1	PSay (cACG)->ACG_HIST
			@ nLi,PCol()+1	PSay Transform((cACG)->ACG_PORJUR, '@E 99.99')
			@ nLi,PCol()+1	PSay Transform((cACG)->ACG_VALJUR, '@E 9,999.99')
			If cPaisLoc = "BRA"
				@ nLi,PCol()+1	PSay Transform((cACG)->ACG_IRRF, '@E 9,999.99')
				@ nLi,PCol()+1	PSay Transform((cACG)->ACG_ISS, '@E 9,999.99')
				@ nLi,PCol()+1	PSay Transform((cACG)->ACG_CSLL, '@E 9,999.99')
				@ nLi,PCol()+1	PSay Transform((cACG)->ACG_COFINS, '@E 9,999.99')
				@ nLi,PCol()+1	PSay Transform((cACG)->ACG_PIS, '@E 9,999.99')                                                         
			EndIf                                                          
			@ nLi,IIF(cPaisLoc ="BRA",PCol()+1,PCol()+47) PSay PadR(IIF(Val((cACG)->ACG_STATUS)>0,aACG_Status[Val((cACG)->ACG_STATUS)],STR0011),15) //"Nao Informado"
			@ nLi,PCol()+1	PSay (cACG)->ACG_OPERAD
			@ nLi,PCol()+1	PSay Substr(UsrRetName((cACG)->ACG_OPERAD)+Space(24),1,20)
			
			// Depois que imprimo os titulos eu somo os totais
			nTAtend01 := nTAtend01 + (cACG)->ACG_VALOR
			nTAtend02 := nTAtend02 + (cACG)->ACG_ACRESC
			nTAtend03 := nTAtend03 + (cACG)->ACG_DECRES
			nTAtend04 := nTAtend04 + (cACG)->ACG_VALJUR
			If cPaisLoc = "BRA"
				nTAtend05 := nTAtend05 + (cACG)->ACG_IRRF
				nTAtend06 := nTAtend06 + (cACG)->ACG_ISS
				nTAtend07 := nTAtend07 + (cACG)->ACG_CSLL
				nTAtend08 := nTAtend08 + (cACG)->ACG_COFINS
				nTAtend09 := nTAtend09 + (cACG)->ACG_PIS 
			EndIf	
			nTot01 := nTot01 + IIF((cACG)->ACG_STATUS=='1',(cACG)->ACG_VALOR,0)
			nTot02 := nTot02 + IIF((cACG)->ACG_STATUS=='2',(cACG)->ACG_VALOR,0)
			nTot03 := nTot03 + IIF((cACG)->ACG_STATUS=='3',(cACG)->ACG_VALOR,0)
			
	#IFNDEF TOP
			DbSelectArea(cACG)
			DbSkip()
		End
	#ENDIF

	DbSelectArea(cACF)
	DbSkip()
	
	// rodape tem que ser depois do pulo
	If cAtend <> (cACF)->ACF_Codigo
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR(STR0026,45) //"TOTAIS DO ATENDIMENTO"
		@ nLi,PCol()+1	PSay Transform(nTAtend01, '@E 9,999,999.99')
		@ nLi,PCol()+1	PSay Transform(nTAtend02, '@E 9,999.99')
		@ nLi,PCol()+1	PSay Transform(nTAtend03, '@E 9,999.99')
		@ nLi,PCol()+49	PSay Transform(nTAtend04, '@E 9,999.99') 
		If cPaisLoc = "BRA"
			@ nLi,PCol()+1	PSay Transform(nTAtend05, '@E 9,999.99')
			@ nLi,PCol()+1	PSay Transform(nTAtend06, '@E 9,999.99')
			@ nLi,PCol()+1	PSay Transform(nTAtend07, '@E 9,999.99')
			@ nLi,PCol()+1	PSay Transform(nTAtend08, '@E 9,999.99')
			@ nLi,PCol()+1	PSay Transform(nTAtend09, '@E 9,999.99')
		EndIf
		nTAtend01 := 0
		nTAtend02 := 0
		nTAtend03 := 0
		nTAtend04 := 0
		nTAtend05 := 0
		nTAtend06 := 0
		nTAtend07 := 0
		nTAtend08 := 0
		nTAtend09 := 0
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay STR0027 //"TOTAIS POR STATUS"
		@ nLi,045		PSay STR0028 + Transform(nTot01, '@E 9,999,999.99') //"PAGO: "
		@ nLi,PCol()+10	PSay STR0029 + Transform(nTot02, '@E 9,999,999.99') //"NEGOCIADO: "
		@ nLi,PCol()+10	PSay STR0030 + Transform(nTot03, '@E 9,999,999.99') //"CARTORIO: "
		nTot01 := 0
		nTot02 := 0
		nTot03 := 0
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		TkIncLine(@nLi,3,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		
	Endif
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso nada tenha sido impresso, entao imprime uma menssagem de aviso³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLi == 0
	TkIncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay STR0031 //"Nao existem dados a serem impressos para este relatorio com os parametros informados"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime o rodape do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Roda(cbCont,cbText,Tamanho)

#IFDEF TOP
	DbSelectArea("ACF")
	DbCloseArea()
	ChkFile("ACF")
#ENDIF

Set Device To Screen
If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tkr038RptDef ºAutor  ³Hanna               º Data ³  30/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para informar as celulas que serao utilizadas no rela-  º±±
±±º          ³latorio                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKR038                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ºManutencao Efetuada                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºHanna C   ³26/07/06ºR4    º Inclusao SetLineStyle para impressao estilo   º±±
±±º          ³        º      º Enchoice                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tkr038RptDef()
Local oReport				// Objeto do relatorio
Local oBreak				// Objeto para quebra
Local oSection1				// Objeto da secao 1
Local oSection2				// Objeto da secao 2
Local oSection3				// Objeto da secao 3
Local cAlias1	:= "ACF"	// Define o cAlias1 como ACF
Local cAlias2	:= "ACG"	// Define o cAlias2 como ACG

#IFDEF TOP
	cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel
	cAlias2		:= cAlias1								// Deixa o cAlias2 igual ao cAlias1
#ENDIF	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera a tela com os dados para a confirmação da geracao do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//"Atendimentos do Telecobrança"
// "Este programa irá emitir a relação dos atendimentos efetuados pelo atendimento de Telecobrança"
// "Os dados serão emitidos conforme os parâmetros informados." # "Serão considerados os atendimentos Ativos e Receptivos."
DEFINE REPORT oReport NAME "TMKR038" TITLE STR0001 PARAMETER "TMK038" ACTION {|oReport| TKR038PrtRpt( oReport, cAlias1 )} DESCRIPTION STR0002 + STR0003 + STR0004
oReport:SetLandscape()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao1 do relatorio, com quebra por filial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SECTION oSection1 OF oReport TITLE STR0043 TABLES "ACF","SA1","SU5","SU7","SU9" 	//"Cabecalho do Atendimento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as celulas que irao aparecer na secao1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE CELL NAME "ACF_ULTATE"		OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "ACF_CODIGO"	OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "ACF_OPERA"	OF oSection1 ALIAS "ACF"		// Verificar nao informado
DEFINE CELL NAME "ACF_PENDEN"	OF oSection1 ALIAS "ACF"		// Retornar em    as
DEFINE CELL NAME "ACF_HRPEND"	OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "ACF_CLIENT"	OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "ACF_LOJA"		OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "A1_NOME"		OF oSection1 ALIAS "SA1"		 //"Nao Localizado no cadastro..."
DEFINE CELL NAME "ACF_CODCON"	OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "U5_CONTAT"	OF oSection1 ALIAS "SU5"
DEFINE CELL NAME "ACF_OPERAD"	OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "U7_NOME" 		OF oSection1 ALIAS "SU7"
DEFINE CELL NAME "ACF_MOTIVO"	OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "U9_DESC" 		OF oSection1 ALIAS "SU9" BLOCK {|| Tkr038RetMot ( (cAlias1)->ACF_MOTIVO ) }
DEFINE CELL NAME "ACF_OBS"  	OF oSection1 ALIAS "ACF" BLOCK {|| PrtMemo( (cAlias1)->ACF_CODOBS ) }
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao2 do relatorio, informando que o arquivo principal utlizado eh o SL3 e o complementar o SB1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SECTION oSection2 OF oSection1 TITLE STR0044 TABLES "ACG" 	//"Itens do Atendimento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as celulas que irao aparecer na secao2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE CELL NAME "ACG_PREFIX"	OF oSection2 ALIAS "ACG" TITLE STR0032
DEFINE CELL NAME "ACG_TITULO"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_PARCEL"	OF oSection2 ALIAS "ACG" TITLE STR0033
DEFINE CELL NAME "ACG_TIPO"		OF oSection2 ALIAS "ACG" TITLE STR0034
DEFINE CELL NAME "ACG_NATURE"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_DTVENC"	OF oSection2 ALIAS "ACG" TITLE STR0035
DEFINE CELL NAME "ACG_DTREAL"	OF oSection2 ALIAS "ACG" TITLE STR0036
DEFINE CELL NAME "ACG_VALOR"	OF oSection2 ALIAS "ACG" SIZE 12 PICTURE "@E 9,999,999.99"
DEFINE CELL NAME "ACG_ACRESC"	OF oSection2 ALIAS "ACG" SIZE 08 PICTURE "@E 9,999.99" TITLE STR0037
DEFINE CELL NAME "ACG_DECRES"	OF oSection2 ALIAS "ACG" SIZE 08 PICTURE "@E 9,999.99" TITLE STR0038
DEFINE CELL NAME "ACG_NUMBCO"	OF oSection2 ALIAS "ACG" SIZE 10 TITLE STR0039
DEFINE CELL NAME "ACG_HIST"		OF oSection2 ALIAS "ACG" SIZE TamSX3("ACG_HIST")[1] TITLE STR0040
DEFINE CELL NAME "ACG_PORJUR"	OF oSection2 ALIAS "ACG" PICTURE "@E 99.99" TITLE STR0041 
DEFINE CELL NAME "ACG_VALJUR"	OF oSection2 ALIAS "ACG" SIZE 10 PICTURE "@E 9,999.99" TITLE STR0042

If cPaisLoc = "BRA"
	DEFINE CELL NAME "ACG_IRRF"		OF oSection2 ALIAS "ACG" SIZE 08 PICTURE "@E 9,999.99"
	DEFINE CELL NAME "ACG_ISS" 		OF oSection2 ALIAS "ACG" SIZE 08 PICTURE "@E 9,999.99"
	DEFINE CELL NAME "ACG_CSLL"		OF oSection2 ALIAS "ACG" SIZE 08 PICTURE "@E 9,999.99"
	DEFINE CELL NAME "ACG_COFINS" 	OF oSection2 ALIAS "ACG" SIZE 08 PICTURE "@E 9,999.99"
	DEFINE CELL NAME "ACG_PIS"		OF oSection2 ALIAS "ACG" SIZE 08 PICTURE "@E 9,999.99"
EndIf                                                          

DEFINE CELL NAME "ACG_STATUS"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_OPERAD"	OF oSection2 ALIAS "ACG" SIZE 35 BLOCK {|| "ACG_OPERAD" + " - " + Substr(UsrRetName( (cAlias2)->ACG_OPERAD ) + Space(24),1,20) }

oSection1:SetLineBreak()
oSection2:SetLineBreak()
oSection2:SetTotalText("")  
oSection2:SetTotalInLine(.F.)		// Imprime total em linha ou coluna (default .T. - linha )
oSection1:SetLineStyle()
DEFINE FUNCTION FROM oSection2:Cell("ACG_VALOR")	FUNCTION SUM NO END REPORT
DEFINE FUNCTION FROM oSection2:Cell("ACG_ACRESC")	FUNCTION SUM NO END REPORT
DEFINE FUNCTION FROM oSection2:Cell("ACG_DECRES")	FUNCTION SUM NO END REPORT

DEFINE FUNCTION FROM oSection2:Cell("ACG_VALJUR")	FUNCTION SUM NO END REPORT
DEFINE FUNCTION FROM oSection2:Cell("ACG_PORJUR")	FUNCTION SUM NO END REPORT
	
If cPaisLoc = "BRA"
	DEFINE FUNCTION FROM oSection2:Cell("ACG_IRRF")	FUNCTION SUM NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("ACG_ISS")	FUNCTION SUM NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("ACG_CSLL")	FUNCTION SUM NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("ACG_COFINS") FUNCTION SUM NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("ACG_PIS")	FUNCTION SUM NO END REPORT
Endif

DEFINE COLLECTION OF oSection2 FUNCTION SUM FORMULA oSection2:Cell("ACG_STATUS") CONTENT oSection2:Cell("ACG_VALOR") TITLE STR0027
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKR038PrtRptºAutor  ³Hanna               º Data ³  14/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para impressao do relatorio personalizavel             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKR038                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TKR038PrtRpt( oReport, cAlias1 )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local cFiltro	:= ""								// Variavel utilizada para o filtro
Local cQuery	:= "%%"								// Variavel da cQuery
Local cQuery1	:= "%%"								// Variavel da cQuery
Local cAlias3	:= GetNextAlias()					// Pega o proximo nome disponivel para a tabela
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de telecobranca pelo indice do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ACF")
DbSetOrder(1)

#IFDEF TOP
	MakeSqlExpr("TMK038")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao for AMBOS, pego apenas ATIVO ou RECEPTIVO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR11 <> 3
		cQuery := "% ACF_OPERA = '" + Str( MV_PAR11,1 ) + "' AND %"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se definiu uma ocorrencia somente ela eh filtrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(MV_PAR12)
		cQuery1 := "% ACF_MOTIVO = '" + MV_PAR12 + "' AND %"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a secao 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query utilizada para filtrar todos os dados necessarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BeginSql alias cAlias1
		SELECT	DISTINCT ACF_FILIAL, ACF_ULTATE,	ACF_OPERAD,	ACF_CODIGO,	ACF_OPERA,	ACF_PENDEN,	ACF_HRPEND,	
				ACF_CLIENT,	ACF_LOJA,	ACF_CODCON,	ACF_OPERAD,	ACF_MOTIVO,	ACF_CODOBS,
				A1_NOME,	U5_CONTAT,	U7_NOME,
				ACG_PREFIX,	ACG_TITULO,	ACG_PARCEL,
				ACG_TIPO,	ACG_NATURE,	ACG_DTVENC,	ACG_DTREAL,	ACG_VALOR,	ACG_ACRESC,
				ACG_DECRES,	ACG_NUMBCO,	ACG_HIST,	ACG_PORJUR,	ACG_VALJUR,	ACG_IRRF,
				ACG_ISS,	ACG_CSLL,	ACG_COFINS,	ACG_PIS,	ACG_STATUS,	ACG_VALOR,	ACG_OPERAD

		FROM %table:ACF% ACF, %table:ACG% ACG, %table:SA1% SA1, %table:SU5% SU5, %table:SU7% SU7
		WHERE	ACF_FILIAL	=	%xfilial:ACF%			AND
				ACG_FILIAL	=	%xfilial:ACG%			AND
				A1_FILIAL	=	%xfilial:SA1%			AND
				U5_FILIAL	=	%xfilial:SU5%			AND
				ACF_CODIGO	>=	%exp:mv_par01%			AND
				ACF_CODIGO	<=	%exp:mv_par02%			AND
				ACF_CLIENT	>=	%exp:mv_par03%			AND
				ACF_CLIENT	<=	%exp:mv_par05%			AND
				ACF_LOJA	>=	%exp:mv_par04%			AND
				ACF_LOJA	<=	%exp:mv_par06%			AND
				ACF_OPERAD	>=	%exp:mv_par07%			AND
				ACF_OPERAD	<=	%exp:mv_par08%			AND
				ACF_ULTATE	>=	%exp:mv_par09%			AND
				ACF_ULTATE	<=	%exp:mv_par10%			AND
				ACF_CODIGO	=	ACG_CODIGO				AND
				ACF_CLIENT	=	A1_COD					AND
				ACF_LOJA	=	A1_LOJA					AND
				ACF_CODCON	=	U5_CODCONT				AND
				ACF_OPERAD	=	U7_COD					AND
				%exp:cQuery%
				ACF.%notDel%							AND
				%exp:cQuery1%
				ACG.%notDel%							AND
				SA1.%notDel%							AND
				SU5.%notDel%                            AND
				SU7.%notDel%
		ORDER BY %Order:ACF%
	EndSql

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indica o fim da query, caso utilize range, deve-se informar como parametro ³
	//³{MV_?,MV_?} para que seja incluido no select automaticamente               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	END REPORT QUERY oSection1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( { | cParam | (cAlias1)->ACF_CODIGO == cParam},{|| (cAlias1)->ACF_CODIGO } )
#ELSE
	MakeSqlExpr("TMKR038")
    
    cFiltro := "ACF_FILIAL = '" + xFilial("ACF") + "'" 
	cFiltro += " .AND. ACF_CODIGO	>= '" + MV_PAR01 + "' .AND. ACF_CODIGO	<= '" + MV_PAR02 + "'"
 	cFiltro += " .AND. ACF_CLIENT	>= '" + MV_PAR03 + "' .AND. ACF_CLIENT	<= '" + MV_PAR05 + "'"
	cFiltro += " .AND. ACF_LOJA		>= '" + MV_PAR04 + "' .AND. ACF_LOJA	<= '" + MV_PAR06 + "'"
	cFiltro += " .AND. ACF_OPERAD	>= '" + MV_PAR07 + "' .AND. ACF_OPERAD	<= '" + MV_PAR08 + "'"
	cFiltro += " .AND. DTOS(ACF_ULTATE) >= '" + DTOS(MV_PAR09) + "' .AND. DTOS(ACF_ULTATE) <= '" + DTOS(MV_PAR10) + "'"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao for AMBOS, pego apenas ATIVO ou RECEPTIVO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR11 <> 3
		cFiltro += " .AND. ACF_OPERA	== '" + Str(MV_PAR11,1) + "'"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se definiu uma ocorrencia somente ela eh filtrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(MV_PAR12)
		cFiltro += " .AND. ACF_MOTIVO == '" + MV_PAR12 + "'"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o filtro de acordo com a expressao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:SetFilter( cFiltro )

	TRPosition():New( oSection1,"SA1",1,"xFilial() + ACF->ACF_CLIENT + ACF->ACF_LOJA" )
	TRPosition():New( oSection1,"SU5",1,"xFilial() + ACF->ACF_CODCON" )
	TRPosition():New( oSection1,"SU7",1,"xFilial() + ACF->ACF_OPERAD" )
	TRPosition():New( oSection1,"SU9",2,"xFilial() + ACF->ACF_MOTIVO" )

	oSection2:SetRelation({|| xFilial("ACG") + ACF->ACF_CODIGO },"ACG",1,.T.)
	oSection2:SetParentFilter({|cParam| ACG->ACG_CODIGO == cParam },{|| ACF->ACF_CODIGO })
#ENDIF
oSection1:Print()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrtMemo³ Autor ³Hanna Caroline   		    ³ Data ³14/07/2006³±±
±±³          ³             ³       ³                    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que coloca em uma string o campo memo do banco de    ³±±
±±³          ³dados.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tkr038PrtMemo(ExpA1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = array com as linhas do campo memo                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtMemo(cDado)
Local cLine := ""       //String contendo as linhas do campo memmo de observacao

cLine := MSMM(cDado, 500)	

Return(cLine)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKR038RetMot ³ Autor ³Hanna Caroline      ³ Data ³17/07/2006³±±
±±³          ³             ³       ³                    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que retorna o motivo caso exista                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TKR038RetMot(ExpA1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Codigo do motivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tkr038RetMot( cMot )
Local cRet	:= ""				// Variavel de retorno da funcao
      
If !Empty( cMot )
	DbSelectArea("SU9")
	DbSetOrder(2)    	// Codigo da Ocorrencia
	If MsSeek( xFilial( "SU9" ) + cMot )
		cRet := SU9->U9_DESC
	Else
		cRet := STR0014 //"Nao Localizado no cadastro..."
	Endif
Else
	cRet := STR0015 //"Nao Informado no atendimento..."
Endif

Return cRet
