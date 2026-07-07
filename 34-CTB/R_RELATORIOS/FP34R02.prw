#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"
#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

//Objeto para a classe FwTemporaryTable (Cria tabela temporária no banco de dados)
Static _oF34CTB

//==================================================================================================//
//	Programa: FP34R02		|	Autor: Luis Paulo							|	Data: 12/04/2018	//
//==================================================================================================//
//	Descrição: Relatório Sintético de contas 														//
//																									//
//==================================================================================================//
User Function FP34R02()
Local 		_cHour
Local 		_cMin
Local 		_cSecs
Local 		aParamBox 	:= {}
Local 		aTPImp		:= {"PDF","EXCEL"}
Local 		aApura		:= {"NAO","SIM"}
Local 		aSldZero	:= {"NAO","SIM"}
Local 		aImpSom		:= {"NAO","SIM"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private		_cTimeF
Private 	aSelFil		:={}
Private 	cCRLF		:= CRLF
Private 	cAliasT1	:= GetNextAlias()
Private 	_cPerg1
Private 	_cPerg2
Private 	_cPerg3
Private 	_cPerg4
Private		_cPerg5
Private		_cPerg6 		//Desconsidera uma apuracao
Private		_cPerg7
Private		_cPerg8
Private 	_cPerg9
Private 	nRegs		:= 0
Private		nCount		:= 0
Private 	cCodigo		:= ""
Private 	oPrn

Private nTipoCab		:=  1
Private lTemp			:= .f.
Private aStruZTB   		:= ZTB->(DbStruct())

_cTime	:= TimeFull() // Resultado: 10:37:17.389    //Time() // Resultado: 10:37:17
_cHour	:= SubStr( _cTime, 1, 2 ) // Resultado: 10
_cMin	:= SubStr( _cTime, 4, 2 ) // Resultado: 37
_cSecs	:= SubStr( _cTime, 7, 2 ) // Resultado: 17
_MlcSecs:= SubStr( _cTime, 10, 3 ) // Resultado: 389
_cTimeF	:=_cHour+_cMin+_cSecs+_MlcSecs

If lTemp 
	//Deleta tabela temporaria criada no banco de dados
		If _oF34CTB <> Nil
			_oF34CTB:Delete()
			_oF34CTB := Nil
		Endif

		CriaTemp() //Cria o temporario
		
	Else
		DbSelectArea("ZTB")
EndIf 

AAdd(aParamBox, { 1, "Conta de?"		,Space(20),"","","CT1","",0,.F.}) // Tipo caractere
AAdd(aParamBox, { 1, "Conta Até?"		,Space(20),"","","CT1","",0,.F.}) // Tipo caractere

aAdd(aParamBox, { 1,"Data De?"  		,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
aAdd(aParamBox, { 1,"Data Até?"  		,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
AAdd(aParamBox,	{ 2,"Tipo de impressão?",1,aTPImp	,50,"",.T.})

AAdd(aParamBox,	{ 2,"Posicao Ant. Lucros/Perdas?",1,aApura	,50,"",.T.})
aAdd(aParamBox, { 1,"Data de Apuracao?" ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data

AAdd(aParamBox,	{ 2,"Imprime Saldos zerados?",1,aSldZero	,50,"",.T.})
AAdd(aParamBox,	{ 2,"Imprime Subtotais em Excel?",1,aImpSom	,50,"",.T.})
	
If ParamBox(aParamBox,"REL. SLD PLANO DE CONTAS SINTETICO", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas
			
		If Empty(aSelFil)
			aSelFil := AdmGetFil()
		EndIf
		
		If Len( aSelFil ) <= 0
				Return
			Else
				If Len( aSelFil ) == 1
						nTipoCab	:= 1
					Else
						nTipoCab	:= 2
				EndIf
				TrataPer()
				
		EndIf 
   Else 

Endif
	
Return()

/**********************************************************************************************************************************/
/** static function ImpPdf()								                                                                     **/
/** Imprime em PDF			   		                                                                                             **/
/**********************************************************************************************************************************/
Static Function ImpPdf()

oPrn := FWMSPrinter():New('cAlias_'+ DTOS(DATE()) + _cTimeF +'.rel', IMP_PDF ,.F.,'\Spool\',.T.) //Instancia a Classe, Gerar pdf por default, Não recalcula coordenadas,Diretorio padrao onde o arq sera salvo, deixa a cargo do programador quando será chamada a tela de setup
oPrn:SetPortrait()				//Define o relatorio como retrato
oPrn:SetPaperSize(9)			//programado para folha A4
oPrn:SetMargin(10,10,10,10)		//Margem do relatorio
oPrn:cPathPDF := "C:\Temp"		//Path do arquivo PDF
oPrn:Setup()					//apresenta a janela de configuracao de impressoras

If oPrn:nModalResult == PD_OK
		If !BusConta()
				MsgAlert("Não existem dados!")
				Return
				
			Else
				ProcSldFP()
				CtaDebit()
				CtaCredit()
				CtaSldAt()
				CtaSuper()
				u_FP34R02A(aret[3],aret[4])
				oPrn:Preview()		//preview
				xDelete()
		EndIf
				
	Else
		oPrn:Cancel()
		If oPrn:Canceled()
			Return .T.
		Endif
EndIf

Return()

/**********************************************************************************************************************************/
/** static function ImpExc()								                                                                     **/
/** Imprime em Excel				                                                                                             **/
/**********************************************************************************************************************************/
Static Function ImpExc()

If !BusConta()
		MsgAlert("Não existem dados!")
		Return
		
	Else
		ProcSldFP()
		CtaDebit()
		CtaCredit()
		CtaSldAt()
		CtaSuper()
		u_FP34R02B(aRet[3],aRet[4],_cTimeF)
		xDelete()
EndIf

Return()

/**********************************************************************************************************************************/
/** static function BusConta()								                                                                     **/
/** Busca as informações de conta	                                                                                             **/
/*******************""***************************************************************************************************************/
Static Function BusConta()
Local cSql		:= ""
Local lRet		:= .F.
Local lBusSup	:= .F. //Roda o processamento da conta superior
Local lAchou	:= .F.
Private cAliasSP 	:= GetNextAlias()
Private cAliasSN 	:= GetNextAlias()
Private cAliasT1	:= GetNextAlias()

/* Cria Query */
If Select((cAliasT1)) <> 0
	DBSelectArea((cAliasT1))
	(cAliasT1)->(DBCloseArea())
Endif

cRetF	:= RetFilFP()

//Foi disponibilizada duas querys, pois isso em casos do plano de contas completo,
//o sistema ganha em tempo de processamento
If (Empty(aRet[1]) .OR. Alltrim(aRet[1]) == "1")  .And. UPPER((Substr(aRet[2],1,10))) == 'ZZZZZZZZZZ'
		lBusSup	:= .F. //Roda o processamento da conta superior
	Else
		lBusSup	:= .T. //Roda o processamento da conta superior
EndIf

cSql	+= " SELECT DISTINCT CT1_CONTA,ISNULL(CQ0.CQ0_FILIAL,'') AS FILCQ0 ,ISNULL(CT1_CTASUP,'') AS CTASUP,CT1.CT1_DESC01,ISNULL(CQ0.CQ0_CONTA,'') AS CONCQ0,CT1.CT1_CLASSE,CT1_NORMAL "+cCRLF
cSql	+= " FROM "+ RetSqlName("CT1") +" CT1 WITH(NOLOCK) "+cCRLF
cSql	+= " LEFT JOIN "+ RetSqlName("CQ0") +" CQ0 WITH(NOLOCK) ON CT1.CT1_CONTA = CQ0.CQ0_CONTA AND CQ0.D_E_L_E_T_ = '' AND CQ0.CQ0_TPSALD = '1' "+cCRLF //Saldo por Conta no Mês

If !Empty(cRetF)
	cSql	+= " AND CQ0.CQ0_FILIAL IN ("+cRetF+")"+cCRLF
EndIf

cSql	+= " WHERE CT1.D_E_L_E_T_ = ''	"+cCRLF
cSql	+= " AND CT1_CONTA >= '"+aRet[1]+"'
cSql	+= " AND CT1_CONTA <= '"+aRet[2]+"'
cSql	+= " ORDER BY CT1_CONTA,ISNULL(CQ0.CQ0_FILIAL,''),ISNULL(CT1_CTASUP,''),CT1_DESC01,ISNULL(CQ0.CQ0_CONTA,''),CT1.CT1_CLASSE,CT1_NORMAL "+cCRLF

Conout("")
//Conout(cSql)
Conout("")

If !lTemp
		TCQuery cSql NEW ALIAS (cAliasT1)
	Else 
		Processa({||SqlToTrb(cQuery, aStruTmp, "TZTB")} , "Atualizando data aguarde...")	// Cria arquivo temporario
EndIf 

Count To nRegs

DBSelectArea((cAliasT1))
(cAliasT1)->(DBGoTop())

cCodigo	:= GETSXENUM("ZTB","ZTB_CODIGO")
ConfirmSx8()

nCount		:= 0
ProcRegua(nRegs)
While !(cAliasT1)->(EOF())
	
	nCount++
	IncProc('Processando Contas  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	If !lTemp 
			DbSelectArea("ZTB") //Alimenta as contas do período
			Reclock("ZTB",.T.)
			ZTB_FILIAL	:= xFilial("ZTB")
			ZTB_CODIGO	:= cCodigo
			ZTB_CTACT1	:= (cAliasT1)->CT1_CONTA
			ZTB_CTASUP	:= (cAliasT1)->CTASUP	
			ZTB_DESCTA	:= (cAliasT1)->CT1_DESC01
			ZTB_FILCQ0	:= (cAliasT1)->FILCQ0
			ZTB_TPCTA	:= (cAliasT1)->CT1_CLASSE //1 sintetica - 2 analitica
			ZTB_DTINIC	:= aRet[3]
			ZTB_DTFINA	:= aRet[4]
			ZTB_CTACD	:= (cAliasT1)->CT1_NORMAL //1 Devedora - 2 credora
			ZTB->(MsUnlock())

		Else

	EndIf

	lRet		:= .T.
	
	(cAliasT1)->(DBSkip())
EndDo


If lBusSup

	 
	BusCSupN() //Buscar os níveis
	While !(cAliasSN)->(EOF())
		
		BusCSup((cAliasSN)->NIVEIS) //Busca as contas superiores atuais
		While !(cAliasSP)->(EOF())
			
			If Empty((cAliasSP)->ZTB_CTASUP) //Se achou a conta superior do nível
				lAchou	:= .T.
				Exit
			EndIf
			
			DbSelectArea("ZTB")
			ZTB->(DbSetOrder(4))
			ZTB->(DbGoTop())
			If !ZTB->(DbSeek(xFilial("ZTB") + cCodigo + (cAliasSP)->ZTB_CTASUP)) //Caso nao achou a conta grava e reinicia todo processo até achar o último nivel
				
				DbSelectArea("ZTB")
				Reclock("ZTB",.T.)  				//Gravacai das contas sinteticas
				ZTB_FILIAL	:= xFilial("ZTB")
				ZTB_CODIGO	:= cCodigo
				ZTB_CTACT1	:= (cAliasSP)->ZTB_CTASUP
				ZTB_CTASUP	:= (cAliasSP)->CT1_CTASUP	
				ZTB_DESCTA	:= (cAliasSP)->CT1_DESC01
				ZTB_FILCQ0	:= ""
				ZTB_TPCTA	:= (cAliasSP)->CT1_CLASSE //1 sintetica - 2 analitica
				ZTB_DTINIC	:= aRet[3]
				ZTB_DTFINA	:= aRet[4]
				ZTB_CTACD	:= (cAliasSP)->CT1_NORMAL //1 Devedora - 2 credora
				ZTB->(MsUnlock())
				
				Exit
			EndIf
			
			(cAliasSP)->(DbSkip())
		EndDo
		
		(cAliasSP)->(DbCloseArea())
		
		If lAchou //Achou a ultima conta do nivel
			lAchou	:= .F.
			(cAliasSN)->(DbSkip())
		EndIf
		
	EndDo
	(cAliasSN)->(DbCloseArea())
	
EndIf

Return(lRet)

Static Function TrataPer()

_cPerg3	:= MV_PAR03
_cPerg4	:= MV_PAR04

_cPerg5	:= MV_PAR05
_cPerg6	:= MV_PAR06
_cPerg7	:= MV_PAR07
_cPerg8	:= MV_PAR08
_cPerg9	:= MV_PAR09

If ValType(_cPerg5) == "N"
		
		If _cPerg5 == 1
				_cPerg5 := 1
			Else
				_cPerg5 := 2
		EndIf
	
	Else
		If _cPerg5 == "PDF"
				_cPerg5 := 1
				
			Else
				_cPerg5 := 2 
		
		EndiF
EndIf


If ValType(_cPerg6) == "N"
		
		If _cPerg6 == 1
				_cPerg6 := 1
			Else
				_cPerg6 := 2
		EndIf
	
	Else
		If _cPerg6 == "NAO"
				_cPerg6 := 1
			Else
				_cPerg6 := 2 //SIM Desconsidera uma apuracao
		EndiF
EndIf

If ValType(_cPerg8) == "N"
		
		If _cPerg8 == 1
				_cPerg8 := 1
			Else
				_cPerg8 := 2
		EndIf
	
	Else
		If _cPerg8 == "NAO"
				_cPerg8 := 1
			Else
				_cPerg8 := 2 //SIM Desconsidera uma apuracao
		EndiF
EndIf


If ValType(_cPerg9) == "N"
		
		If _cPerg9 == 1
				_cPerg9 := 1
			Else
				_cPerg9 := 2
		EndIf
	
	Else
		If _cPerg9 == "NAO"
				_cPerg9 := 1
			Else
				_cPerg9 := 2 //SIM subtotais
		EndiF
EndIf



If _cPerg6 == 2 .And. Empty(_cPerg7) //SIM Desconsidera uma apuracao
	MsgAlert("Informe a data de apuracao para desconsiderar!!!")
	Return
EndIf

If _cPerg3 >  _cPerg4
	MsgAlert("A segunda data nao pode ser menor que a primeira!!!")
	Return
EndIf


If _cPerg5	== 1
		Processa({||ImpPdf()} ,"Processando Contas","Aguarde...") 
	Else
		Processa({||ImpExc()} ,"Processando Contas","Aguarde...") 
EndIf

Return()

Static Function RetFilFP()
Local nX	:= 1
Local cRet	:= ""

For nX	:= 1 To Len(aSelFil)
	cRet	+=	"'" + aSelFil[nX] + "',"
Next

cRet	:= Substr(cRet,1,Len(cRet)-1)

Return(cRet)


//Processamento de saldos
Static Function ProcSldFP()
Local dDtaSldA	:= Aret[3]//((Aret[3])-1)
Local nSaldoIn	:= 0
Local aArea		:= SM0->(GetArea())
Local cSaveFil	:= cFilant
Local dDtaBSBK	:= dDataBase
 
DbSelectArea("ZTB")
ZTB->(DbSetOrder(2))
ZTB->(DbGotop())

If ZTB->(DbSeek(xFilial("ZTB") + cCodigo + "2"))
	
	dDataBase	:= dDtaSldA
	ProcRegua(nRegs)
	nCount		:= 0
	While !ZTB->(EOF()) .And. ZTB->ZTB_CODIGO == cCodigo  .And. ZTB->ZTB_TPCTA == "2"
		
		nCount++
		IncProc('Processando Saldo Ant Contas  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
		
		If Empty(ZTB->ZTB_FILCQ0)
			ZTB->(DbSkip())
			Loop
		EndIf
		
		If cFilant != ZTB->ZTB_FILCQ0
			cFilant		:= 	ZTB->ZTB_FILCQ0			//Seta a filial correta
			SM0->(DbSeek( cEmpAnt + ZTB->ZTB_FILCQ0 ) )//Seta SM0 correta
			If !RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
				MsgAlert("Empresa nao localizada")
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorno:                                             ³
		//³ [1] Saldo Atual (com sinal)                          ³
		//³ [2] Debito na Data                                   ³
		//³ [3] Credito na Data                                  ³
		//³ [4] Saldo Atual Devedor                              ³
		//³ [5] Saldo Atual Credor                               ³
		//³ [6] Saldo Anterior (com sinal)                       ³
		//³ [7] Saldo Anterior Devedor                           ³
		//³ [8] Saldo Anterior Credor                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _cPerg6 == 2 //Desconsidera uma apuracao  - Desconsiderar tb na CQ1 O CAMPO CQ1_DTLP <> DESSA DT 
				nSaldoIn	:= SaldoConta(ZTB->ZTB_CTACT1,dDtaSldA,"01","1",6,1,_cPerg7,) //desconsidera apuracao de resultado a partir de uma data
			Else
				nSaldoIn	:= SaldoConta(ZTB->ZTB_CTACT1,dDtaSldA,"01","1",6,0,,)
		EndIF
		
		If Substr(Alltrim(ZTB->ZTB_CTACT1),1,1) == "1" //Ativo
			/*
			If ZTB->ZTB_CTACD == '1' //Devedora
					nSaldoIn	:= nSaldoIn * -1
				Else	//Credora
					nSaldoIn	:= nSaldoIn * -1
			EndIf
			*/
		EndIf
		
		RecLock("ZTB",.F.)
		ZTB->ZTB_SLDANT	:= nSaldoIn
		ZTB->(MsUnLock())
		
		ZTB->(DbSkip())
	EndDo

	RestArea( aArea )
	
	cFilant 	:= cSaveFil
	dDataBase 	:= dDtaBSBK
EndIf

Return()

Static Function CtaDebit()
Local cSql		:= ""
Local cAliasT2	:= GetNextAlias()

/* Cria Query */
If Select((cAliasT2)) <> 0
	DBSelectArea((cAliasT2))
	(cAliasT2)->(DBCloseArea())
Endif

cSql	+= " SELECT CQ1.CQ1_FILIAL AS FILIAL,CQ1.CQ1_CONTA AS CONTA,ISNULL(SUM(CQ1_DEBITO),0) AS VALOR "+cCRLF
cSql	+= " FROM CQ1010 CQ1 WITH(NOLOCK) "+cCRLF
cSql	+= " INNER JOIN ZTB010 ZTB WITH(NOLOCK) ON CQ1.CQ1_FILIAL = ZTB_FILCQ0 AND CQ1.CQ1_CONTA = ZTB.ZTB_CTACT1 AND ZTB.D_E_L_E_T_ = '' AND ZTB.ZTB_CODIGO = '"+cCodigo+"' "+cCRLF
cSql	+= " WHERE CQ1.D_E_L_E_T_ = '' "+cCRLF
cSql	+= " AND CQ1_DATA >= '"+ DTOS(_cPerg3) +"' "+cCRLF
cSql	+= " AND CQ1_DATA <= '"+ DTOS(_cPerg4) +"' "+cCRLF
cSql	+= " AND CQ1_MOEDA = '01' "+cCRLF
cSql	+= " AND CQ1_TPSALD = '1' "+cCRLF

If _cPerg6 == 2 //Desconsidera uma apuracao
	cSql	+= " AND (CQ1_LP IN ('N','S') OR (CQ1_LP = 'Z' AND CQ1_DTLP <'"+ DTOS(_cPerg7) +"' )) "+cCRLF //S|N=NORMAL - Z=ENCERRAMENTOS
EndIf

cSql	+= " GROUP BY CQ1.CQ1_FILIAL,CQ1.CQ1_CONTA "+cCRLF
cSql	+= " ORDER BY CQ1.CQ1_FILIAL,CQ1.CQ1_CONTA "+cCRLF

Conout("")
//Conout(cSql)
Conout("")

TCQuery cSql NEW ALIAS (cAliasT2)
//DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasT2, .F., .T.)
Count To nRegs

DBSelectArea((cAliasT2))
(cAliasT2)->(DBGoTop())

nCount		:= 0
ProcRegua(nRegs)
While !(cAliasT2)->(EOF())
	
	nCount++
	IncProc('Processando Debitos ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	cSql	:= " UPDATE ZTB010 "
	cSql	+= " SET ZTB_DEBITO = '"+STR((cAliasT2)->VALOR)+"'"
	cSql	+= " WHERE 	ZTB_CODIGO = '"+cCodigo+"'"
	cSql	+= "		AND ZTB_FILCQ0 = '"+(cAliasT2)->FILIAL+"'"
	cSql	+= "		AND ZTB_CTACT1 = '"+(cAliasT2)->CONTA+"'"
	cSql	+= "				AND D_E_L_E_T_ = '' "
	If TcSqlExec(cSql) < 0
		Conout("")
		Conout("TCSQLError() " + TCSQLError())
		Conout("")
	EndIf

	(cAliasT2)->(DbSkip())

EndDo
(cAliasT2)->(DBCloseArea())

Return()


Static Function CtaCredit()
Local cSql		:= ""
Local cAliasT2	:= GetNextAlias()

/* Cria Query */
If Select((cAliasT2)) <> 0
	DBSelectArea((cAliasT2))
	(cAliasT2)->(DBCloseArea())
Endif

cSql	+= " SELECT CQ1.CQ1_FILIAL AS FILIAL,CQ1.CQ1_CONTA AS CONTA,ISNULL(SUM(CQ1_CREDIT),0) AS VALOR "+cCRLF
cSql	+= " FROM CQ1010 CQ1 WITH(NOLOCK) "+cCRLF
cSql	+= " INNER JOIN ZTB010 ZTB WITH(NOLOCK) ON CQ1.CQ1_FILIAL = ZTB_FILCQ0 AND CQ1.CQ1_CONTA = ZTB.ZTB_CTACT1 AND ZTB.D_E_L_E_T_ = '' AND ZTB.ZTB_CODIGO = '"+cCodigo+"' "+cCRLF
cSql	+= " WHERE CQ1.D_E_L_E_T_ = '' "+cCRLF
cSql	+= " AND CQ1_DATA >= '"+ DTOS(_cPerg3) +"' "+cCRLF
cSql	+= " AND CQ1_DATA <= '"+ DTOS(_cPerg4) +"' "+cCRLF
cSql	+= " AND CQ1_MOEDA = '01' "+cCRLF
cSql	+= " AND CQ1_TPSALD = '1' "+cCRLF

If _cPerg6 == 2 //Desconsidera uma apuracao
	cSql	+= " AND (CQ1_LP IN ('N','S') OR (CQ1_LP = 'Z' AND CQ1_DTLP <'"+ DTOS(_cPerg7) +"' )) "+cCRLF //S|N=NORMAL - Z=ENCERRAMENTOS
EndIf

cSql	+= " GROUP BY CQ1.CQ1_FILIAL,CQ1.CQ1_CONTA "+cCRLF
cSql	+= " ORDER BY CQ1.CQ1_FILIAL,CQ1.CQ1_CONTA "+cCRLF

Conout("")
//Conout(cSql)
Conout("")

TCQuery cSql NEW ALIAS (cAliasT2)
//DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasT2, .F., .T.)
Count To nRegs

DBSelectArea((cAliasT2))
(cAliasT2)->(DBGoTop())

nCount		:= 0
ProcRegua(nRegs)
While !(cAliasT2)->(EOF())
	
	nCount++
	IncProc('Processando Creditos ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	cSql	:= " UPDATE ZTB010 "
	cSql	+= " SET ZTB_CREDIT = '"+STR((cAliasT2)->VALOR)+"'"
	cSql	+= " WHERE 	ZTB_CODIGO = '"+cCodigo+"'"
	cSql	+= "		AND ZTB_FILCQ0 = '"+(cAliasT2)->FILIAL+"'"
	cSql	+= "		AND ZTB_CTACT1 = '"+(cAliasT2)->CONTA+"'"
	cSql	+= "				AND D_E_L_E_T_ = '' "
	If TcSqlExec(cSql) < 0
		Conout("")
		Conout("TCSQLError() " + TCSQLError())
		Conout("")
	EndIf
	
	(cAliasT2)->(DbSkip())

EndDo
(cAliasT2)->(DBCloseArea())

Return()

//Processamento do sld atual
Static Function CtaSldAt()
Local dDtaSldA	:= ((Aret[3])-1)
Local nSaldoIn	:= 0
Local cSaveFil	:= cFilant
Local dDtaBSBK	:= dDataBase
 
DbSelectArea("ZTB")
ZTB->(DbSetOrder(2))
ZTB->(DbGotop())

If ZTB->(DbSeek(xFilial("ZTB") + cCodigo + "2"))
	
	dDataBase	:= dDtaSldA
	ProcRegua(nRegs)
	nCount		:= 0
	While !ZTB->(EOF()) .And. ZTB->ZTB_CODIGO == cCodigo  .And. ZTB->ZTB_TPCTA == "2"
		
		nCount++
		IncProc('Processando Saldo Atu Contas  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
		
		If Substr((Alltrim(ZTB->ZTB_CTACT1)),1,1) == "1" //Ativo
				If ZTB->ZTB_CTACD == "1" //Devedora
						nSaldoIn	:= (ZTB->ZTB_SLDANT + ZTB->ZTB_DEBITO) - ZTB->ZTB_CREDIT
					Else	//Credora
						nSaldoIn	:= (ZTB->ZTB_SLDANT - ZTB->ZTB_DEBITO) + ZTB->ZTB_CREDIT
				EndIf
			
			Else //passivo - resultado - apuracao
				If ZTB->ZTB_CTACD == "1" //Devedora
						nSaldoIn	:= (ZTB->ZTB_SLDANT - ZTB->ZTB_DEBITO) + ZTB->ZTB_CREDIT
					Else	//Credora
						nSaldoIn	:= (ZTB->ZTB_SLDANT + ZTB->ZTB_CREDIT) - ZTB->ZTB_DEBITO 
				EndIf
		EndIf
		
		RecLock("ZTB",.F.)
		ZTB->ZTB_SLDATU	:= nSaldoIn
		ZTB->(MsUnLock())
		
		ZTB->(DbSkip())
	EndDo

EndIf

Return()


Static Function CtaSuper()
Local cSql		:= ""
Local cAliasS1	:= GetNextAlias()
Local cCtaSupA	:= ""
Local cCtaSupN	:= ""
Local aAret		:= {}
Local nSalAtu	:= 0
Local cTipoCta	:= ""

Local nCount	:= 0

/* Cria Query */
If Select((cAliasS1)) <> 0
	DBSelectArea((cAliasS1))
	(cAliasS1)->(DBCloseArea())
Endif

cSql	+= " SELECT * "+cCRLF
cSql	+= " FROM ZTB010 WITH(NOLOCK) "+cCRLF
cSql	+= " WHERE D_E_L_E_T_ = '' "+cCRLF
cSql	+= " AND ZTB_CODIGO = '"+cCodigo+"' "+cCRLF
cSql	+= " AND ZTB_TPCTA = '1' "+cCRLF
cSql	+= " ORDER BY LEN(ZTB_CTASUP) DESC "+cCRLF

Conout("")
//Conout(cSql)
Conout("")

TCQuery cSql NEW ALIAS (cAliasS1)
//DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasS1, .F., .T.)
Count To nRegs 

DBSelectArea((cAliasS1))
(cAliasS1)->(DBGoTop())

ProcRegua(nRegs)

cCtaSupA	:= (cAliasS1)->ZTB_CTACT1
cCtaSupN	:= (cAliasS1)->ZTB_CTACT1
cTipoCta	:= Alltrim((cAliasS1)->ZTB_CTACD)

While !(cAliasS1)->(EOF())
	
	nCount++
	IncProc('Processando Contas Sup ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	cCtaSupN	:= (cAliasS1)->ZTB_CTACT1
	
	If cCtaSupA != cCtaSupN
		
		aAret	:= RetValS(cCtaSupA)
		If Substr((Alltrim(cCtaSupA)),1,1) == "1" //Ativo
				If cTipoCta == "1" //Devedora
						nSalAtu	:= (aAret[1] + aAret[2]) - aAret[3] //(Saldo anterior + debito) - Credito
					Else	//Credora
						nSalAtu	:= (aAret[1] - aAret[2]) + aAret[3] //(Saldo anterior - debito) + Credito
				EndIf
			
			Else //passivo - resultado - apuracao
				If cTipoCta == "1" //Devedora
						nSalAtu	:= (aAret[1] - aAret[2]) + aAret[3] //(Saldo anterior - debito) + Credito
					Else	//Credora
						nSalAtu	:= (aAret[1] + aAret[3]) - aAret[2] //(Saldo anterior + debito) - Credito
				EndIf
		EndIf
		
		cSql	:= " UPDATE ZTB010
		cSql	+= " SET ZTB_SLDANT = "+ Str(aAret[1]) +" , ZTB_DEBITO = "+ Str(aAret[2]) +", ZTB_CREDIT = "+ Str(aAret[3]) +" , ZTB_SLDATU = "+ Str(nSalAtu) +""
		cSql	+= " WHERE D_E_L_E_T_ = ''
		cSql	+= " AND ZTB_CODIGO = '"+cCodigo+"'"
		cSql	+= " AND ZTB_CTACT1 = '"+cCtaSupA+"'"
		If TcSqlExec(cSql) < 0
			Conout("")
			Conout("TCSQLError() " + TCSQLError())
			Conout("")
		EndIf
		
		cTipoCta	:= Alltrim((cAliasS1)->ZTB_CTACD)
		cCtaSupA	:= (cAliasS1)->ZTB_CTACT1
		Loop
	EndIf
	
	(cAliasS1)->(DbSkip())
EndDo

If !Empty(cCtaSupA)
	aAret	:= RetValS(cCtaSupA)
	
	If Substr((Alltrim(cCtaSupA)),1,1) == "1" //Ativo
			If Alltrim(cTipoCta) == "1" //Devedora
					nSalAtu	:= (aAret[1] + aAret[2]) - aAret[3]
				Else	//Credora
					nSalAtu	:= (aAret[1] - aAret[2]) + aAret[3]
			EndIf
		
		Else //passivo - resultado - apuracao
			If Alltrim(cTipoCta) == "1" //Devedora
					nSalAtu	:= (aAret[1] - aAret[2]) + aAret[3]
				Else	//Credora
					nSalAtu	:= (aAret[1] + aAret[3]) - aAret[2] 
			EndIf
	EndIf
	
	cSql	:= " UPDATE ZTB010
	cSql	+= " SET ZTB_SLDANT = "+ Str(aAret[1]) +" , ZTB_DEBITO = "+ Str(aAret[2]) +", ZTB_CREDIT = "+ Str(aAret[3]) +" , ZTB_SLDATU = "+ Str(nSalAtu) +""
	cSql	+= " WHERE D_E_L_E_T_ = ''
	cSql	+= " AND ZTB_CODIGO = '"+cCodigo+"'"
	cSql	+= " AND ZTB_CTACT1 = '"+cCtaSupA+"'"
	If TcSqlExec(cSql) < 0
		Conout("")
		Conout("TCSQLError() " + TCSQLError())
		Conout("")
	EndIf
EndIf

(cAliasS1)->(DBCloseArea())
Return()

Static Function RetValS(cCtaSup)
Local aARet	:= {}
Local cAliasS2 := GetNextAlias()
Local cSql	:= ""

If Select((cAliasS2)) <> 0
	DBSelectArea((cAliasS2))
	(cAliasS2)->(DBCloseArea())
Endif

cSql	+= " SELECT SUM(ZTB_SLDANT) AS SLDANT,SUM(ZTB_DEBITO) AS DEBITO,SUM(ZTB_CREDIT) AS CREDITO,SUM(ZTB_SLDATU) AS SLDATU
cSql	+= " FROM ZTB010
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND ZTB_CTASUP = '"+cCtaSup+"'
cSql	+= " AND ZTB_CODIGO = '"+cCodigo+"'

//TCQuery cSql NEW ALIAS (cAliasS2)		
DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cAliasS2, .F., .T.)
DBSelectArea((cAliasS2))
(cAliasS2)->(DBGoTop())

aAdd(aARet,(cAliasS2)->SLDANT)
aAdd(aARet,(cAliasS2)->DEBITO)
aAdd(aARet,(cAliasS2)->CREDITO)
aAdd(aARet,(cAliasS2)->SLDATU)
(cAliasS2)->(DBCloseArea())

Return(aARet)


//buscar as contas superiores
Static Function BusCSup(cNivel) 
Local cSql	:= ""

If Select((cAliasSP)) <> 0
	DBSelectArea((cAliasSP))
	(cAliasSP)->(DBCloseArea())
Endif

cSql	+= " SELECT DISTINCT ZTB.ZTB_CTASUP,CT1.*
cSql	+= " FROM ZTB010 ZTB
cSql	+= " LEFT JOIN CT1010 CT1 ON ZTB_CTASUP = CT1.CT1_CONTA AND CT1.D_E_L_E_T_ = ''
cSql	+= " WHERE ZTB.ZTB_CODIGO = '"+cCodigo+"'
cSql	+= " AND SUBSTRING(ZTB.ZTB_CTACT1,1,1) = '"+cNivel+"'
cSql	+= " AND ZTB.D_E_L_E_T_ = ''
cSql	+= " ORDER BY ZTB.ZTB_CTASUP DESC

TCQuery cSql NEW ALIAS (cAliasSP)

DBSelectArea((cAliasSP))
(cAliasSP)->(DbGotop())

Return((cAliasSP)->(EOF()))


//Busca as quantidades de niveis
Static Function BusCSupN() 
Local cSql	:= ""

If Select((cAliasSN)) <> 0
	DBSelectArea((cAliasSN))
	(cAliasSN)->(DBCloseArea())
Endif

cSql	+= " SELECT DISTINCT SUBSTRING(ZTB_CTASUP,1,1) AS NIVEIS
cSql	+= " FROM ZTB010
cSql	+= " WHERE ZTB_CODIGO = '"+cCodigo+"'
cSql	+= " AND D_E_L_E_T_ = ''
cSql	+= " AND ZTB_CTASUP <> ''

TCQuery cSql NEW ALIAS (cAliasSN)

DBSelectArea((cAliasSN))
(cAliasSN)->(DbGotop())

Return((cAliasSN)->(EOF()))


Static Function xDelete()
Local cSql := ""

cSql	:= " DELETE FROM ZTB010 "
cSql	+= " WHERE 	ZTB_CODIGO = '"+cCodigo+"'"
cSql	+= "		AND D_E_L_E_T_ = '' "
If TcSqlExec(cSql) < 0
	Conout("")
	Conout("TCSQLError() " + TCSQLError())
	Conout("")
EndIf

Return()



Static Function CriaTemp()
Local aArea := GetArea()
Local aIndTmp  := {}
Local ni, nx

Aadd(aStruTmp, {"ZTB_FILIAL",GetSx3Cache("ZTB_FILIAL","X3_TIPO"),GetSx3Cache("ZTB_FILIAL","X3_TAMANHO"),GetSx3Cache("ZTB_FILIAL","X3_DECIMAL")} )


For ni := 1 to Len(aStruZTB)
	If X3Uso(GetSx3Cache(aStruZTB[ni,1],"X3_USADO")) .And. cNivel >= GetSx3Cache(aStruZTB[nI,1],"X3_NIVEL") ;
			.And. GetSx3Cache(aStruZTB[nI,1],"X3_CONTEXT") $ " R" .And. GetSx3Cache(aStruZTB[nI,1],"x3_TIPO") <> "M"

		Aadd(aStruTmp, {aStruZTB[nI,1],	GetSx3Cache(aStruZTB[nI,1],"X3_TIPO"),GetSx3Cache(aStruZTB[nI,1],"X3_TAMANHO"),GetSx3Cache(aStruZTB[nI,1],"X3_DECIMAL")})

	EndIf
Next

Aadd(aIndTmp,  {"ZTB_FILIAL","ZTB_CODIGO"}) 							//ZTB_FILIAL+ZTB_CODIGO                                                                                                                                           
Aadd(aIndTmp,  {"ZTB_FILIAL","ZTB_CODIGO","ZTB_TPCTA"}) 				//ZTB_FILIAL+ZTB_CODIGO+ZTB_TPCTA                                                                                                                                 
Aadd(aIndTmp,  {"ZTB_FILIAL","ZTB_CODIGO","ZTB_TPCTA","ZTB_FILCQ0"}) 	//ZTB_FILIAL+ZTB_CODIGO+ZTB_TPCTA+ZTB_FILCQ0                                                                                                                      
Aadd(aIndTmp,  {"ZTB_FILIAL","ZTB_CODIGO","ZTB_CTACT1"}) 				//ZTB_FILIAL+ZTB_CODIGO+ZTB_CTACT1                                                                                                                                
Aadd(aIndTmp,  {"ZTB_FILIAL","ZTB_CODIGO","ZTB_CTASUP"}) 				//ZTB_FILIAL+ZTB_CODIGO+ZTB_CTASUP                                                                                                                                
Aadd(aIndTmp,  {"ZTB_FILIAL","ZTB_CODIGO","ZTB_CTACT1","ZTB_CTACD"})	//ZTB_FILIAL+ZTB_CODIGO+ZTB_CTACT1+ZTB_CTACD                                                                                                                      
Aadd(aIndTmp,  {"ZTB_FILIAL","ZTB_CODIGO","ZTB_CTASUP","ZTB_CTACD"}) 	//ZTB_FILIAL+ZTB_CODIGO+ZTB_CTASUP+ZTB_CTACD                                                                                                                      	

U_SCRIATMP(aStruTmp,"TZTB",aIndTmp)

RestArea(aArea)
Return()

//Funcao Generica para criar 
User Function SCRIATMP(aStruTmp,cAlisTmp,aIndTmp)
Local ni

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cAlisTmp )

//--------------------------
//Monta os campos da tabela
//--------------------------
oTemptable:SetFields( aStruTmp )
For ni := 1 to Len(aIndTmp)
	oTempTable:AddIndex(cAlisTmp+STRZERO(ni,2), aIndTmp[ni] )
Next

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

Return()
