#include "protheus.ch"
#include "rwmake.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#Include "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch" 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fExpItem
Função para exportar o Items do Pedido
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
User Function xxfExpItem(pAcao)

	Local aArea		:= GetArea()
	Local aRet		:= array(3)
	Local lEDIOk	:= .T.
	Local lIntegra	:= ''
	Local cMsgPnl	:= ''
	Local cRet 		:= ''
	Local nX

	Private cOpera	:= pAcao //Variavel do Tipo Private que sera usada no Layout do Envio do Pedido na Tabla ZA3, para definir se é uma inclusao ou exclusao

	For nX:=1 to len(aItens)

		If aItens[nX,01]

			SC5->(DbGoto(aItens[nX,7]))

	/*		DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			SC5->(DbGotoP())
			If SC5->(DbSeek(xFilial("SC5") + SC9->C9_PEDIDO))
				DbSelectArea("SA4")
				SA4->(DbSetOrder(1))
				SA4->(DbGotoP())
				If SA4->(DbSeek(xFilial("SA4") + SC5->C5_TRANSP))

				EndiF
			EndIf
	*/
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))

			SA4->(DbSeek(xFilial("SA4") + SC5->C5_TRANSP))		

			cMsgPnl:= aItens[nX,04] + CRLF
			cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
			cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

			lEDIOk	:= .T.//GetAdvFVal("ZA7","ZA7_STATUS",xFilial("ZA7")+SC9->C9_PEDIDO+SC9->C9_ITEM,3) == "7"
			lIntegra:= .T. //GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+SC9->C9_PRODUTO,1) == "S"


			If Empty(cRet)
				aRet:= U_xWMSPED( GetMv('FZ_WSWMS5'), 'SC6', 1, 'C6_FILIAL+C6_NUM+C6_ITEM', FWxFilial('SC6')+SC6->C6_NUM+SC6->C6_ITEM ) 
			Else
				aRet[1]:= .F.
				aRet[3]:= cRet	
			Endif

			//DbSelectArea("SC9")
			//SC9->(DbGoto(aItens[nX,7]))

			RecLock("SC5",.F.)
			If cOpera !="C"
				If Empty(SC5->C5_XSTAWMS) .or. SC5->C5_XSTAWMS=="F"
					SC5->C5_XSTAWMS:= iIf(aRet[1],"E","F") //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
				Endif
			Else
				If aRet[1]
					SC5->C5_XSTAWMS:= "C" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
				Endif
			Endif
			SC5->C5_XDTIWMS:= dDataBase
			SC5->C5_XHRIWMS:= Time()
			SC5->C5_XMSGWMS:= cMsgPnl+aRet[3]		
			SC5->(MsUnlock())
		Endif

	Next nX

	fQryPed()

	RestArea(aArea)

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fPnlWMS
Painel Integração CyberLog WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 15/01/2021
/*/
User Function XXfPnlWMS()

Local aArea:= GetArea()
Local oGroup1, oGroup2,  oBEnv
Local oFontCab := TFont():New( "Arial",, 15,,.F.,,,, .F., .F. )  
Local cPerg	:= PadR('WMSEXPSC9',10)

Private oDlg
Private aItens  := {}
Private oItens
Private oObs, oDescri
Private cObs		:= ""
Private cDescri		:= ""
Private lCheck		:= .F.	

Private oOK	:= LoadBitmap(GetResources(), "LBOK" )
Private oNO	:= LoadBitmap(GetResources(), "LBNO" )

Private oLeg
Private oLgBranco	:= LoadBitmap(GetResources(),'BR_BRANCO')	//C9_XSTAWMS==' ' - Não Enviado
Private oLgAzul		:= LoadBitmap(GetResources(),'BR_AZUL')		//C9_XSTAWMS=='E' - Enviado
Private oLgVermel	:= LoadBitmap(GetResources(),'BR_VERMELHO')	//C9_XSTAWMS=='F' - Falha no Envio
Private oLgPreto	:= LoadBitmap(GetResources(),'BR_PRETO')	//C9_XSTAWMS=='X' - Falha no Retorno
Private oLgVerde	:= LoadBitmap(GetResources(),'BR_VERDE')	//C9_XSTAWMS=='O' - Retorno com Sucesso
Private oLgCancel	:= LoadBitmap(GetResources(),'BR_CANCEL')	//C9_XSTAWMS=='C' - Retorno com Sucesso
Private oLgReenV	:= LoadBitmap(GetResources(),'BR_AZUL_CLARO')	//C9_XSTAWMS=='R' - Retorno com Sucesso

fSX1SC9(cPerg)
If ! Pergunte(cPerg,.T.)
	Return
Endif

DEFINE MSDIALOG oDlg TITLE "Painel Integração CyberLog X Protheus" FROM 000, 000 TO 680, 775 PIXEL
	   
oItens := TcBrowse():New( 015, 010, 370, 180,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F.,,,, )
		
oItens:SetArray( aItens )

oItens:AddColumn( TcColumn():New( ""			, { || If(aItens[oItens:nAt,01], oOK,oNO) 	}, 	 				,,, "CENTER", 010, .T., .F.,,,, .F., ) )		
oItens:AddColumn( TcColumn():New( "Status"		, { || aItens[oItens:nAt,02]				},"" 				,,, "CENTER", 010, .T., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Pedido"		, { || aItens[oItens:nAt,03]				}, "@!"				,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
//oItens:AddColumn( TcColumn():New( "Item"		, { || aItens[oItens:nAt,04]				}, "@!"				,,, "LEFT"  , 020, .F., .F.,,,, .F., ) )
//oItens:AddColumn( TcColumn():New( "Produto"		, { || aItens[oItens:nAt,05]				}, "@!"				,,, "LEFT"  , 100, .F., .F.,,,, .F., ) )
//oItens:AddColumn( TcColumn():New( "Qtd"			, { || aItens[oItens:nAt,06]				}, "@E 999,999.99"	,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Cliente"		, { || aItens[oItens:nAt,05]				}, "@!"				,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
oItens:nAt := 1

oItens:bLDblClick:= {|| fMarca() }
oItens:bChange := { || ( cObs:= aItens[oItens:nAt,06], oObs:refresh())  }	

@ 005, 005 GROUP oGroup1 TO 220, 385 PROMPT "[ Itens ]" OF oDlg COLOR 128, 16777215 PIXEL

@ 220, 005 GROUP oGroup2 TO 325, 385 PROMPT "[ Mensagem Integração ]" OF oDlg COLOR 128, 16777215 PIXEL
@ 230, 010 GET oObs VAR cObs OF oDlg MULTILINE READONLY SIZE 370, 090 COLORS 0, 16777215 HSCROLL PIXEL

oBLeg	:= tButton():New(202,010  ,"Legenda"		,oDlg,{ || fLegenda()}		,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBRee	:= tButton():New(202,090  ,"Filtro"			,oDlg,{ || iIf(Pergunte(cPerg,.T.), fQryPed(),.F.)}		,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBEnv	:= tButton():New(202,170  ,"Solicitar WMS"	,oDlg,{ || processa( {|| U_xxfExpItem("E") }, 'Aguarde', 'Enviando Reserva do Item...' )}	,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBCan	:= tButton():New(202,250  ,"Cancelar  WMS"	,oDlg,{ || processa( {|| U_xxfExpItem("C") }, 'Aguarde', 'Cancelando Reserva do Item...' )}		,070,012,,oFontCab,,.T.,,"",,,,.F.)

oCheck  := TCheckBox():New( 205,330,"Marcar Todos",{|u| If(PCount()>0,lCheck:=u,lCheck)},oDlg,100,008,,{|| fMTodos() },,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

//DEFINE SBUTTON oSButton1 FROM 325, 360 TYPE 20 OF oDlg ENABLE ACTION oDlg:End()

fQryPed()

oTimer := TTimer():New(2000*60 , {|| fQryPed() }, oDlg )
oTimer:Activate()

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return	

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Rotina : Carrega o array de itens
Static Function fQryPed()

	Local aArea     := GetArea()
	Local cAlias    := GetNextAlias()
	Local cWhere    := "%"
	
	aItens  := {}

	If MV_PAR09 == 2
		cWhere += " AND C5_XSTAWMS = ' ' " //Não Integrado
	Endif

	cWhere += "%"

	If Select( cAlias ) <> 0
		(cAlias)->( dbCloseArea() )
	EndIf	

	BeginSql Alias cAlias

		SELECT C5_FILIAL, C5_NUM,
			C5_CLIENTE,
			C5_LOJACLI,
			C5_XSTAWMS,
			C5_XDTIWMS,
			C5_XHRIWMS,
			ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), SC5.C5_XMSGWMS)), '') MSGINT,
			C5_TIPO,
			CASE
				WHEN C5_TIPO IN ('D',
									'B') THEN A2_NOME
				ELSE A1_NOME
			END NOME,
			SC5.R_E_C_N_O_ RECSC5
		FROM %Table:SC5% SC5 (NOLOCK)
		INNER JOIN %Table:SC6% SC6 (NOLOCK) ON C6_FILIAL = C5_FILIAL
			AND C6_NUM = C5_NUM
			AND SC6.%NOTDEL%
		INNER JOIN %Table:SC9% SC9 (NOLOCK) ON C9_FILIAL = C6_FILIAL
			AND C6_NUM = C9_PEDIDO
			AND C6_PRODUTO = C9_PRODUTO
			AND C9_ITEM = C6_ITEM
			AND SC9.%NOTDEL%
		LEFT JOIN %Table:SA1% SA1 (NOLOCK) ON A1_COD = C5_CLIENTE
			AND A1_LOJA = C5_LOJACLI
			AND SA1.%NOTDEL%
		LEFT JOIN %Table:SA2% SA2 (NOLOCK) ON A2_COD = C5_CLIENTE
			AND A2_LOJA = C5_LOJACLI
			AND SA2.%NOTDEL%
		WHERE C5_FILIAL 	= '020201'
			AND C5_EMISSAO 	BETWEEN %Exp:dtos(MV_PAR01)% AND %Exp:dtos(MV_PAR02)%
			AND C6_ENTREG 	BETWEEN %Exp:dtos(MV_PAR03)% AND %Exp:dtos(MV_PAR04)%
			AND C5_NUM 		BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND C6_PRODUTO 	BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
			AND C9_NFISCAL 	= ''
			AND C9_BLEST 	= ''
			AND C9_BLCRED 	= ''
			AND SC5.%NOTDEL%
			%Exp:cWhere%
		GROUP BY C5_FILIAL, C5_NUM,
				C5_CLIENTE,
				C5_LOJACLI,
				C5_XSTAWMS,
				C5_XDTIWMS,
				C5_XHRIWMS,
				C5_XMSGWMS,
				C5_TIPO,
				A2_NOME,
				A1_NOME,
				SC5.R_E_C_N_O_
		ORDER BY C5_NUM

	EndSql	

	While ! (cAlias)->( EOF() )	

		If !(U_ValPed((cAlias)->C5_FILIAL, (cAlias)->C5_NUM))
			(cAlias)->( DbSkip() )
			LOOP
		End


		If Empty((cAlias)->C5_XSTAWMS)
			oLeg:= oLgBranco
		ElseIf (cAlias)->C5_XSTAWMS=='E'
			oLeg:= oLgAzul
		ElseIf (cAlias)->C5_XSTAWMS=='F'
				oLeg:= oLgVermel
		ElseIf (cAlias)->C5_XSTAWMS=='X'
				oLeg:= oLgPreto
		ElseIf (cAlias)->C5_XSTAWMS=='O'
				oLeg:= oLgVerde
		ElseIf (cAlias)->C5_XSTAWMS=='C'
				oLeg:= oLgCancel
		ElseIf (cAlias)->C5_XSTAWMS=='R'
				oLeg:= oLgReenv		
		Endif

		aAdd( aItens, {	.F.,;
						oLeg,;
						(cAlias)->C5_NUM,;
						(cAlias)->C5_XSTAWMS,;
						(cAlias)->C5_CLIENTE+"/"+(cAlias)->C5_LOJACLI +"-"+(cAlias)->NOME,;
						(cAlias)->MSGINT,;
						(cAlias)->RECSC5} )

		(cAlias)->( DbSkip() )
		
	End

	(cAlias)->( DbCloseArea() )

	If Empty(aItens)
		aItens:= {{	.F.,"","","","","",0}}
	Endif

	fAtuBrw()

	RestArea(aArea)

Return

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Rotina : Atualiza o browse de itens

Static Function fAtuBrw()

	oItens:SetArray(aItens)
	oItens:nAt := 1
	oItens:refresh()
	oItens:setfocus()

	oObs:refresh()
	cObs:= aItens[oItens:nAt,06]

Return

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Rotina : Atualiza o browse de itens

Static Function fMarca()

	//' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorerto 
	If Empty(aItens[oItens:nAt,04]) .or. alltrim(aItens[oItens:nAt,04]) == 'F'
		aItens[oItens:nAt,01]:= !aItens[oItens:nAt,01]

	ElseIf alltrim(aItens[oItens:nAt,04]) $ ' |E|F|C|R'

		If alltrim(aItens[oItens:nAt,04]) == 'E'
			If MsgYesNo("Esse item do pedido ja foi enviado ao WMS. Confirma o reenvio do Item ?")
				aItens[oItens:nAt,01]:= .T.
			Else
				aItens[oItens:nAt,01]:= .F.
			Endif
		Else
			aItens[oItens:nAt,01]:= !aItens[oItens:nAt,01]
		Endif

	Else
		If alltrim(aItens[oItens:nAt,04]) $ 'O|X' 
			Alert('Item do Pedido já foi enviado ao WMS.')
		Endif 
		aItens[oItens:nAt,01]:= .F.
	Endif

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function fMTodos
	Local  nI := 0

	For nI := 1 To Len( aItens )

		If Empty(aItens[oItens:nAt,07]) .or. alltrim(aItens[oItens:nAt,07]) == 'F'
			aItens[oItens:nAt,01]:= !aItens[oItens:nAt,01]
		Else
			aItens[oItens:nAt,01]:= .F.	
		Endif	
		
	Next nI

	oItens:Refresh()

Return NIL

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fLegenda
Legenda Painel Integracao WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 15/01/2021
/*/
Static Function fLegenda()

	Local	aLegenda  := {	{'BR_BRANCO'	,'Item não Integrado ao WMS'}		,;
							{'BR_AZUL'		,'Item enviado ao WMS'}				,;
							{'BR_AZUL_CLARO','Item Renviado ao WMS'}			,;
							{'BR_VERMELHO'	,'Item com falha no envio do WMS'}	,;
							{'BR_PRETO'		,'Item com falha no retorno do WMS'},;
							{'BR_VERDE'		,'Item com sucesso no retorno'}		,;
							{'BR_CANCEL'	,'Item cancelado'}}

	BrwLegenda("Painel de Integração",'Legenda',aLegenda)

Return .T.

/*/{Protheus.doc} fSX1ExpPro
Cria Grupo de Pergntas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
Static Function fSX1SC9(cPerg)

	cPerg := PADR(cPerg,10)

	CheckSX1(cPerg, "01", "Dt Emissao De?"	, "Dt Emissao De?"		, "Dt Emissao De?"		, "mv_ch1"		, "D", TamSX3("C5_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "02", "Dt Emissao Ate?"	, "Dt Emissao Ate?"		, "Dt Emissao Ate?"		, "mv_ch2"		, "D", TamSX3("C5_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "03", "Dt Entrega De?"	, "Dt Entrega De?"		, "Dt Entrega De?"		, "mv_ch3"		, "D", TamSX3("C5_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "04", "Dt Entrega Ate?"	, "Dt Entrega Ate?"		, "Dt Entrega Ate?"		, "mv_ch4"		, "D", TamSX3("C5_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "05", "Pedido De?"		, "Pedido De?"			, "Pedido De?"			, "mv_ch5"		, "C", TamSX3("C5_NUM")[1]		, 0, 0, "G", "", "SC5"	,"","","MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "06", "Pedido Ate?"		, "Pedido Ate?"			, "Pedido Ate?"			, "mv_ch6"		, "C", TamSX3("C5_NUM")[1]		, 0, 0, "G", "", "SC5"	,"","","MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "07", "Produto De?"		, "Produto De?"			, "Produto De?"			, "mv_ch7"		, "C", TamSX3("B1_COD")[1]		, 0, 0, "G", "", "SB1"	,"","","MV_PAR07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "08", "Produto Ate?"	, "Produto Ate?"		, "Produto Ate?"		, "mv_ch8"		, "C", TamSX3("B1_COD")[1]		, 0, 0, "G", "", "SB1"	,"","","MV_PAR08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "09", "Status?"			, "Status?"				, "Status?"				, "mv_ch9"		, "N", 01						, 0, 0, "C", "",""		,"","","MV_PAR09", "Todos", "", "", "", "Nao Integrado", "", "", "", "Enviado", "", "", "", "Falha no Envio", "", "", "", "Falha no retorno", "", "", "", "",{},{},{})

Return()


User Function xWMSPED(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
	Local aZA2		:= GetArea()
	Local lRet		:= .T.
	Local cEndWS	:= Iif((Upper(AllTrim(GetPvProfString(UPPER((Alltrim(GetEnvServer()))), "dbALIAS", "", GetsRVIniName()))) == "CZ2O05_152804_PR_PD"),GetMV("ST_IPWMS"),"http://189.45.131.206:9393") //Se o banco de dados for de produção, pega os dados do parâmetro
	Local cMetodo	:= ''
	Local cBody 	:= ''
	Local cChave	:= GetMV("FZ_WSCHWMS")
	Local cToken	:= ''
	Local cTipoMov	:= ''
	Local cOrigMov	:= ''
	Local aOK 		:= array(2)
	Local aRet		:= array(3)
	Local aHeader	:= {}
	Local aLogIn	:= {}
	Local oJson		
	Local oRest
	Local oObj

	Local cError	:= ''
	Local cCodRet	:= ''
	Local cRetJson	:= ''
	Local cJson		:= ''
	Local nStatus	:= 0

	Local cWSPar1:= alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
	Local cWSPar2:= alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
	Local cWSPar3:= alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		
	Local cWSPar4:= alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		
	Local cWSPar5:= alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
	Local cWSPar6:= alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	
	Local cWSPar7:= alltrim(GetMv("FZ_WSWMS7"))	//"[FZ_WSWMS7] - Código do Layout de Integração do WS CyberLog WMS - [Manutencao de Lotes]"	
	Local cWSPar8:= alltrim(GetMv("FZ_WSWMS8"))	//"[FZ_WSWMS8] - Código do Layout de Integração do WS CyberLog WMS - [Movimentacao de Interna]"	
	Local cWSPar9:= alltrim(GetMv("FZ_WSWMS9"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Transferencias]"	
	Local cWSParA:= alltrim(GetMv("FZ_WSWMSA"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Aceite]"	
	Local cWSParB:= alltrim(GetMv("FZ_WSWMSB"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	
	Local cWSParD:= alltrim(GetMv("FZ_WSWMSD"))	//"[FZ_WSWMSA] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	

	Private cLayOut:= alltrim(cLayOut)
	aLogIn:= U_fLgInJson()

	If aLogIn[1] .and. !Empty(aLogIn[3]) 

		cToken:= aLogIn[3]
		AAdd(aHeader,'Accept: application/json')
		aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')
		aAdd(aHeader,"chave: "+ 'jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI')
		//aAdd(aHeader,"chave: "+ cChave)
		aAdd(aHeader,"token: "+ cToken)

		cJson:= "{Header"+ CRLF
		//cJson+= 'Content-Type: application/x-www-form-urlencoded' + CRLF 
		
		cJson+= "chave: "+ 'jEQpPW_RGYhhFEw2HDrIXI11VXqp_I9rjon8-UiAfkI' + CRLF
		//cJson+= "chave: "+ cChave + CRLF
		cJson+= "token: "+ cToken + "}" + CRLF + CRLF

		DbSelectArea("ZA2")
		ZA2->(DbSetOrder(1)) //Filial+Codigo Layout+Nome da TAG
		If ZA2->(DbSeek(FWxFilial("ZA2")+cLayOut,.T.))

			//cEndWS	:= alltrim(ZA2->ZA2_ENDWS)+":"+alltrim(ZA2->ZA2_PORWS)
			cMetodo	:= alltrim(ZA2->ZA2_METWS)

			cBody	+= U_xWMSPE1("005",cTab,nIndice,cCpsPesq,cChvPesq,ZA2->ZA2_CHVPAR) 

			ConOut("Body: " + cBody)	

			cJson+= cBody

			//Monta a conexão com o servidor REST
			oRest := FWRest():New(cEndWS) 
			oRest:setPath(cMetodo)  
			
			//Definindo o parâmetro a ser usado no POST
			cBody := FWNoAccent(cBody)
			oRest:SetPostParams(cBody)
			oRest:SetChkStatus(.F.)
			
			//Publica a alteração, e caso não dê certo, mostra erro
			If ! oRest:Post(aHeader)
				lret:= .F.
				cCodRet:= "999"
				cMsg:= 'Atenção !!! Houve erro na atualização no servidor!' + CRLF + ;
					'Contate o Administrador!' + CRLF 
				//	"Erro: " + oRest:GetLastError() + CRLF + "Result: " + oRest:GetResult()

				ConOut(cMsg)	
			Else

				FWJsonDeserialize(oRest:GetResult(),@oObj)
				cError := ""
				nStatus := HTTPGetStatus(@cError)

				if nStatus >= 200 .And. nStatus <= 299
					if Empty(oRest:getResult())
						lret:= .F.
						cCodRet:= "ERRO: " + cvaltochar(nStatus)
						cMsg:= "GetStatus: " + str(nStatus)
					else
						oJson:= JsonObject():New()
						cRetJson:= oJson:fromJson(oRest:GetResult())
						If ValType(cRetJson) != "U"
							lRet:= .F.
							cCodRet:= "999"
							cMsg:= 'Falha ao popular JsonObject. Erro: ' + cRetJson

						Else

							If !Empty(oJson["CyberWeb"])
								cCodRet:= alltrim(oJson["CyberWeb"])
								If substr(cCodRet,1,1)=="!"
									cCodRet:= substr(cCodRet,2,len(cCodRet))
								Endif
								cMsg:= "Serviço: " + cLayOut + CRLF
								cMsg+= "Método: "+ cMetodo + CRLF

								aOk:= fRslCnx(cLayOut, val(cCodRet))
								cMsg+= "Codigo Retorno: " +  aOK[2]

								If ! aOK[1]
									lRet:= .f.
								Endif
							Else
								lRet:= .F.
								cCodRet:= "999"
								cMsg:= "ERRO: Chave Json [CYBERWEB]"
							Endif
						Endif
					endif
				else
					lRet:= .F.
					cCodRet:= "999"
					cMsg:= cError + oRest:GetResult()
				endif

				ConOut(cMsg)	

			Endif

		Endif

		//Faz o LogOut no WS do WMS
		U_fLgOuJson(cToken)
	Else
		lret:= .F.
		cCodRet:= "999"
		cMsg:= "Não foi possivel fazer o Login!!!"+ CRLF + aLogIn[2]
	Endif

	cMsg += CRLF + "IP WMS: "+ cEndWS

	cJson+=CRLF+CRLF+"{ Resultado"+ CRLF
	cJson+="Codigo Retorno:" + cCodRet + CRLF
	cJson+="Mensagem: "+ cMsg + "}"

	aRet[1]:= lRet
	aRet[2]:= cCodRet
	aRet[3]:= cMsg
		
	If cLayOut == cWSPar1
		cTipoMov:= "1"
		cOrigMov:= "[Cadastro PRODUTOS]"

	ElseIf cLayOut == cWSPar2
		cTipoMov:= "2"
		cOrigMov:= "[Cadastro FORNECEDOR]"

	ElseIf cLayOut == cWSPar3
		cTipoMov:= "3"
		cOrigMov:= "[Cadastro CLIENTE]"

	ElseIf cLayOut == cWSPar4
		cTipoMov:= "4"
		cOrigMov:= "[Cadastro PESSOAS]"

	ElseIf cLayOut == cWSPar5
		cTipoMov:= "5"
		cOrigMov:= "[Pedido de Vendas]"

	ElseIf cLayOut == cWSPar6
		cTipoMov:= "6"
		cOrigMov:= "[Recebimentos Nota Fiscal]"

	ElseIf cLayOut == cWSPar7
		cTipoMov:= "7"
		cOrigMov:= "[Manutencao de Lotes]"

	ElseIf cLayOut == cWSPar8
		cTipoMov:= "8"
		cOrigMov:= "[Movimentos Internos]"

	ElseIf cLayOut == cWSPar9
		cTipoMov:= "9"
		cOrigMov:= "[Transferencias]"		

	ElseIf cLayOut == cWSParA
		cTipoMov:= "A"
		cOrigMov:= "[Aceite]"	

	ElseIf cLayOut == cWSParB
		cTipoMov:= "B"
		cOrigMov:= "[Consulta Estoque]"	

	ElseIf cLayout == cWSParD
		cTipoMov:= "D"
		cOrigMov:= "[Cargas]"	

	Endif

	If !lRet
		DbSelectArea("ZA1")
		RecLock("ZA1",.T.)
		ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
		ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
		ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
		ZA1->ZA1_TIPOTR:= "E"
		ZA1->ZA1_ORIGEM:= cOrigMov
		ZA1->ZA1_DATATR:= date()
		ZA1->ZA1_HORATR:= time()
		ZA1->ZA1_USERTR:= upper(UsrRetName(__cUserId))
		ZA1->ZA1_JSON  := cJson
		ZA1->ZA1_TPMOV := cTipoMov
		ZA1->(MsUnlock())
	EndIf 

	FreeObj(oObj)
	FreeObj(oRest)
	FreeObj(oJSON)

	RestArea(aZA2)
Return aRet


User Function xWMSPE1(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq,cChvParam)
	Local aZA3	:= GetArea()
	Local nCont	:= 1
	Local cValor:= ''
	Local cCont	:= ''
	Local cRet	:= ''

	If !Empty(cChvParam)
		cRet := alltrim(cChvParam)+'={'
	else
		cRet := '{'
	Endif

	DbSelectArea("ZA3")
	ZA3->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
	If ZA3->(DbSeek(FWxFilial("ZA3")+cLayOut,.T.))

		While !ZA3->(Eof()) .and. ZA3->ZA3_COD==cLayOut

			
			If ZA3->ZA3_TIPTAG == '1'

				If empty(ZA3->ZA3_CONTEU)
					If ZA3->ZA3_TPDADO == '2'
						cCont:= cvaltochar(0)
					Else
						cCont:= 'null'
					Endif
				Else //"IIF(Empty(SC5->C5_TRANSP),'',Posicione('SA4', 1, xFilial('SA4') + SC5->C5_TRANSP, 'A4_NOME'))"                                                    

					If "->"  $ alltrim(ZA3->ZA3_CONTEU) .or. "U_"  $ upper(alltrim(ZA3->ZA3_CONTEU)) .or. ;
						( ("("  $ alltrim(ZA3->ZA3_CONTEU)) .and. (")"  $ alltrim(ZA3->ZA3_CONTEU)) )

						cValor:= &(ZA3->ZA3_CONTEU)
					Else
						cValor:= ZA3->ZA3_CONTEU
					Endif

					If ZA3->ZA3_TPDADO == '1'
						If Alltrim(cValor) == "null" //Para tratativas de retorno null de IFs por exemplo
								cCont:= '' + alltrim( substr(cValor,1,ZA3->ZA3_TAMANH) ) + ''
							Else 
								cCont:= '"' + alltrim( substr(cValor,1,ZA3->ZA3_TAMANH) ) + '"'
						EndIf 
						

					elseIf ZA3->ZA3_TPDADO == '2' .and. ZA3->ZA3_DECIMA = 0
						cCont:= alltrim(cvaltochar(cValor))

					elseIf ZA3->ZA3_TPDADO == '2' .and. ZA3->ZA3_DECIMA != 0
						//cCont:= padl(strtran(strtran(cValor,".",""),",",""),nDec) 
						cCont:= alltrim(cvaltochar(cValor))

					ElseIf ZA3->ZA3_TPDADO == '3'
						cCont:= '"'+ DTOS(cValor) + '"'

					ElseIf ZA3->ZA3_TPDADO == '4'
						If Substr(cValor,1,1) $ "V|T"
							cCont:= 'True'
						Else
							cCont:= 'false'
						Endif
					Endif

				Endif

				cRet	+= '"' + alltrim(ZA3->ZA3_TAG) + '":'+ cCont
				cValor	:= ''
				cCont	:= ''
				
			else

				If !Empty(ZA3->ZA3_CODARR)
					lRet:= .T.
					cRet+= '"' + alltrim(ZA3->ZA3_TAG) + '": ['
					//cPedido:= ''
					DbSelectArea(cTab)
					(cTab)->(DbSetOrder(nIndice))
					If (cTab)->(DbSeek(cChvPesq,.T.))
						While ! (cTab)->(Eof()) .and. (cTab)->&(cCpsPesq) == cChvPesq
							cRet+=  U_XwmsPE2(ZA3->ZA3_CODARR,,,,cChvPesq) + ']'
							(cTab)->(DbSkip())
							nCont++
						EndDo
					EndIf
				Else
					cRet+= '"' + alltrim(ZA3->ZA3_TAG) + '": null'
				Endif			

			Endif

			ZA3->(DbSkip())

			If ZA3->ZA3_COD == cLayOut
				cRet+= ","
			Endif

		End
	Endif

	If !Empty(cChvParam)
		cRet += '}'
	else
		cRet += '}'
	Endif

	RestArea(aZA3)
Return cRet


User Function XwmsPE2(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
	//Local aZA4	:= GetArea()
	Local cValor:= ''
	Local cCont	:= ''
	Local cRet	:= '{'
	Local nCont	:= 1
	Private cChave:= cChvPesq
	Private lRet := .T.
	Private cNum:= ''


	DbSelectArea("ZA4")
	ZA4->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
	If ZA4->(DbSeek(FWxFilial("ZA4")+cLayOut,.T.))

		If Select ("QRY") > 0
			QRY->(DbCloseArea())
		Endif	

		cQuery:= " SELECT * FROM SC9010 "
		cQuery+= " WHERE C9_FILIAL = '020201' "
		cQuery+= " AND C9_PEDIDO = '"+Substr(cChave,7,6)+"' "
		cQuery+= " AND D_E_L_E_T_ = ''  " //AND C9_BLCRED = '' AND C9_BLEST = '' AND C9_NFISCAL = ''

		TCQUERY cQuery NEW ALIAS "QRY"    

		DbSelectArea("QRY")
		DbGoTop()
		While QRY->(!EOF())
				If nCont > 1
					cRet+= '},{'
				Endif
				lLayout:= .T.
				If lRet // .OR. cNum <> SC9->C9_PEDIDO
					DbSelectArea('SC9')
					DbSetOrder(2)
					If DbSeek(QRY->(C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM))
						cNum:= SC9->C9_PEDIDO
						DbSelectArea("ZA4")
						ZA4->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
						If ZA4->(DbSeek(FWxFilial("ZA4")+cLayOut,.T.))
							While !ZA4->(Eof()) .and. ZA4->ZA4_COD==cLayOut
								If ZA4->ZA4_TIPTAG == '1'

									If empty(ZA4->ZA4_CONTEU)

										If ZA4->ZA4_TPDADO == '2'
											cCont:= cvaltochar(0)
										Else
											cCont:= 'null'
										Endif

									Else

										If "->"  $ alltrim(ZA4->ZA4_CONTEU) .or. "U_"  $ upper(alltrim(ZA4->ZA4_CONTEU)) .or. ;
										( ("("  $ alltrim(ZA4->ZA4_CONTEU)) .and. (")"  $ alltrim(ZA4->ZA4_CONTEU)) )

											cValor:= &(ZA4->ZA4_CONTEU)
										Else
											cValor:= ZA4->ZA4_CONTEU
										Endif

										If ZA4->ZA4_TPDADO == '1'
											cCont:= '"' + alltrim( substr(cValor,1,ZA4->ZA4_TAMANH) ) + '"'

										elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA = 0
											cCont:= cvaltochar(cValor)

										elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA != 0
											cCont:= cvaltochar(cValor)

										ElseIf ZA4->ZA4_TPDADO == '3'
											cCont:= '"'+ DTOS(cValor) + '"'

										ElseIf ZA3->ZA3_TPDADO == '4'
											If Substr(cValor,1,1) $ "V|T"
												cCont:= 'True'
											Else
												cCont:= 'false'
											Endif

										Endif

									Endif

									cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '":'+ cCont
									cValor	:= ''
									cCont	:= ''			

								else

									If !Empty(ZA4->ZA4_CODARR)
										cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '":[' + U_XwmsPE3("005",,,,QRY->(C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT+C9_PEDIDO)) + ']'
										lLayout:= .F.
									Else
										cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '": null'
									Endif

								Endif

								If ZA4->ZA4_COD == cLayOut .And. lLayout
									cRet+= ","
								Endif

								ZA4->(DbSkip())
							EndDo
			
							//lRet:= .F.
						EndIf
					EndIf
					nStr:= Len(cRet)
					cRet:= Substr(cRet,1, nStr - 1)	
				EndIf
				nCont++
			QRY->(DbSkip())
		EndDo
	Endif

	cRet+= '}'

	//RestArea(aZA4)
Return cRet


User Function XwmsPE3(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
	//Local aZA4	:= GetArea()
	Local cValor:= ''
	Local cCont	:= ''
	Local cRet	:= '{'
	Local nCont	:= 1
	Private cChave:= cChvPesq
	Private lRet := .T.
	Private limp := .F.

	DbSelectArea('SC9')
	DbSetOrder(12)
	SC9->(DbGoTop())
	If DbSeek(cChave)
		While ! SC9->(Eof()) .and. SC9->(C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT+C9_PEDIDO) == cChave
			If nCont > 1
				cRet+= '},{'
				limp:= .T.
			Endif
				DbSelectArea("ZAC")
				ZAC->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
				If ZAC->(DbSeek(FWxFilial("ZAC")+cLayOut,.T.))
					While !ZAC->(Eof()) .and. ZAC->ZAC_COD==cLayOut
						If ZAC->ZAC_TIPTAG == '1'

							If empty(ZAC->ZAC_CONTEU)

								If ZAC->ZAC_TPDADO == '2'
									cCont:= cvaltochar(0)
								Else
									cCont:= 'null'
								Endif

							Else

								If "->"  $ alltrim(ZAC->ZAC_CONTEU) .or. "U_"  $ upper(alltrim(ZAC->ZAC_CONTEU)) .or. ;
								( ("("  $ alltrim(ZAC->ZAC_CONTEU)) .and. (")"  $ alltrim(ZAC->ZAC_CONTEU)) )

									cValor:= &(ZAC->ZAC_CONTEU)
								Else
									cValor:= ZAC->ZAC_CONTEU
								Endif

								If ZAC->ZAC_TPDADO == '1'
									cCont:= '"' + alltrim( substr(cValor,1,ZAC->ZAC_TAMANH) ) + '"'

								elseIf ZAC->ZAC_TPDADO == '2' .and. ZAC->ZAC_DECIMA = 0
									cCont:= cvaltochar(cValor)

								elseIf ZAC->ZAC_TPDADO == '2' .and. ZAC->ZAC_DECIMA != 0
									cCont:= cvaltochar(cValor)

								ElseIf ZAC->ZAC_TPDADO == '3'
									cCont:= '"'+ DTOS(cValor) + '"'

								ElseIf ZAC->ZAC_TPDADO == '4'
									If Substr(cValor,1,1) $ "V|T"
										cCont:= 'True'
									Else
										cCont:= 'false'
									Endif

								Endif

							Endif

							cRet+= '"' + alltrim(ZAC->ZAC_TAG) + '":'+ cCont
							cValor	:= ''
							cCont	:= ''			

						else

							If !Empty(ZAC->ZAC_CODARR)
								cRet+= '"' + alltrim(ZAC->ZAC_TAG) + '":[' + U_XwmsPE3("005",,,,cChave) + ']'
							Else
								cRet+= '"' + alltrim(ZAC->ZAC_TAG) + '": null'
							Endif

						Endif

						ZAC->(DbSkip())

						If ZAC->ZAC_COD == cLayOut
							cRet+= ","
						Endif
				
					Enddo
				EndIF
			SC9->(DbSkip())
			//If limp
			//	cRet+= '}'
			//EndIf
			nCont++
		EndDo
	EndIf

		
	cRet+= '}'

	//RestArea(aZA4)
Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fResulCnx
Função para Retornar o Resultado da Integração WS
@type function
@version 12.1.27
@author Carlos Cleuber
@since 21/12/2020
@param cLayout, character, codigo do layout do WebService
/*/
Static Function fRslCnx(cSrv, nCod)
	Local aCodError:= {}
	Local aRet:= array(2)
	Local nPos:= 0
	Local cWSPar1:= alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
	Local cWSPar2:= alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
	Local cWSPar3:= alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		
	Local cWSPar4:= alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		
	Local cWSPar5:= alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
	Local cWSPar6:= alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	
	Local cWSPar7:= alltrim(GetMv("FZ_WSWMS7"))	//"[FZ_WSWMS7] - Código do Layout de Integração do WS CyberLog WMS - [Manutencao de Lotes]"	
	Local cWSPar8:= alltrim(GetMv("FZ_WSWMS8"))	//"[FZ_WSWMS8] - Código do Layout de Integração do WS CyberLog WMS - [Movimentacao de Interna]"	
	Local cWSPar9:= alltrim(GetMv("FZ_WSWMS9"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Transferencias]"	
	Local cWSParA:= alltrim(GetMv("FZ_WSWMSA"))	//"[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Aceite do Produto]"	
	Local cWSParB:= alltrim(GetMv("FZ_WSWMSB"))	//"[FZ_WSWMSB] - Código do Layout de Integração do WS CyberLog WMS - [Consulta Estoque]"	
	//Produto
	aAdd( aCodError, {cWSPar1, 1 , 'Inserido'														, .t. } )
	aAdd( aCodError, {cWSPar1, 2 , 'Alterado'														, .t. } )
	aAdd( aCodError, {cWSPar1, 3 , 'Excluído'														, .t. } )
	aAdd( aCodError, {cWSPar1, 4 , 'Não inserido(não há configuração de depósito para a empresa)'	, .f. } )
	aAdd( aCodError, {cWSPar1, 5 , 'Não inserido(depósito informado não possui configuração)'		, .f. } )
	aAdd( aCodError, {cWSPar1, 6 , 'Não inserido(ERPID vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar1, 7 , 'Não inserido(código de barras vazio)'							, .f. } )
	aAdd( aCodError, {cWSPar1, 8 , 'Não inserido(código reduzido vazio)'							, .f. } )
	aAdd( aCodError, {cWSPar1, 9 , 'Não inserido(fornecedor não existe no WMS)'						, .f. } )
	aAdd( aCodError, {cWSPar1, 42 , ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

	aAdd( aCodError, {cWSPar2, 1, 'Inserido'														, .t. } )
	aAdd( aCodError, {cWSPar2, 2, 'Alterado'														, .t. } )
	aAdd( aCodError, {cWSPar2, 3, 'Excluído'														, .t. } )
	aAdd( aCodError, {cWSPar2, 4, 'Não inserido(depósito informado não possui configuração)'		, .f. } )
	aAdd( aCodError, {cWSPar2, 5, 'Não inserido(ERPID vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar2, 6, 'Não inserido(número vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar2, 7, 'Não inserido(nome vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar2, 8, 'Não inserido(endereço vazio)'									, .f. } )
	aAdd( aCodError, {cWSPar2, 9, 'Não inserido(cep vazio)'											, .f. } )
	aAdd( aCodError, {cWSPar2, 10, 'Não inserido(cidade/uf vazio)'									, .f. } )
	aAdd( aCodError, {cWSPar2, 42, ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

	//Cliente
	aAdd( aCodError, {cWSPar3, 1 ,'Inserido'														, .t. } )
	aAdd( aCodError, {cWSPar3, 2 ,'Alterado'														, .t. } )
	aAdd( aCodError, {cWSPar3, 3 ,'Excluído'														, .t. } )
	aAdd( aCodError, {cWSPar3, 4 ,'Não inserido(depósito informado não possui configuração)'		, .f. } )
	aAdd( aCodError, {cWSPar3, 5 ,'Não inserido(ERPID vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar3, 7 ,'Não inserido(nome vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar3, 8 ,'Não inserido(endereço vazio)'									, .f. } )
	aAdd( aCodError, {cWSPar3, 9 ,'Não inserido(cep vazio)'											, .f. } )
	aAdd( aCodError, {cWSPar3, 10,'Não inserido(cidade/uf vazio)'									, .f. } )
	aAdd( aCodError, {cWSPar3, 42,' Erro não cadastrado(informações no log do servidor).'			, .f. } )

	//Pessoas
	aAdd( aCodError, {cWSPar4, 1, 'Inserido'														, .t. } )
	aAdd( aCodError, {cWSPar4, 2, 'Alterado'														, .t. } )
	aAdd( aCodError, {cWSPar4, 3, 'Excluído'														, .t. } )
	aAdd( aCodError, {cWSPar4, 4, 'Não inserido(depósito informado não possui configuração)'		, .f. } )
	aAdd( aCodError, {cWSPar4, 5, 'Não inserido(ERPID vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar4, 6, 'Não inserido(número vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar4, 7, 'Não inserido(nome vazio)'										, .f. } )
	aAdd( aCodError, {cWSPar4, 8, 'Não inserido(endereço vazio)'									, .f. } )
	aAdd( aCodError, {cWSPar4, 9, 'Não inserido(cep vazio)'											, .f. } )
	aAdd( aCodError, {cWSPar4, 10, 'Não inserido(cidade/uf vazio)'									, .f. } )
	aAdd( aCodError, {cWSPar4, 42, ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

	//Pedidos
	aAdd( aCodError, {cWSPar5, 1 , 'Inserido'														, .t. } )
	aAdd( aCodError, {cWSPar5, 2 , 'Alterado'														, .t. } )
	aAdd( aCodError, {cWSPar5, 3 , 'Excluído'														, .t. } )
	aAdd( aCodError, {cWSPar5, 4 , 'Não alterado (processo já iniciado)'							, .f. } )
	aAdd( aCodError, {cWSPar5, 5 , 'Não alterado (conferência de separação já iniciada)'			, .f. } )
	aAdd( aCodError, {cWSPar5, 6 , 'Não inserido (processo não cadastrado)'							, .f. } )
	aAdd( aCodError, {cWSPar5, 7 , 'Não inserido (cliente não cadastrado)'							, .f. } )
	aAdd( aCodError, {cWSPar5, 8 , 'Não inserido (rota não cadastrada)'								, .f. } )
	aAdd( aCodError, {cWSPar5, 9 , 'Não inserido (recebimento com documento vazio)'					, .f. } )
	aAdd( aCodError, {cWSPar5, 10 , 'Não inserido (pedido com documento vazio)'						, .f. } )
	aAdd( aCodError, {cWSPar5, 11 , 'Não inserido (registro incompleto)'							, .f. } )
	aAdd( aCodError, {cWSPar5, 12 , 'Não inserido (produto não consta no WMS)'						, .f. } )
	aAdd( aCodError, {cWSPar5, 13 , 'Inserido (pedido complementar)'								, .f. } )
	aAdd( aCodError, {cWSPar5, 14 , 'Aguardando (conclusão da separação para integrar)'				, .f. } )
	aAdd( aCodError, {cWSPar5, 15 , 'Executando separação'											, .f. } )
	aAdd( aCodError, {cWSPar5, 16 , 'Concluída separação'											, .f. } )
	aAdd( aCodError, {cWSPar5, 17 , 'Executando conferência de separação'							, .f. } )
	aAdd( aCodError, {cWSPar5, 18 , 'Concluída conferência de separação'							, .f. } )
	aAdd( aCodError, {cWSPar5, 19 , 'Executando consolidação'										, .f. } )
	aAdd( aCodError, {cWSPar5, 20 , 'Concluída consolidação'										, .f. } )
	aAdd( aCodError, {cWSPar5, 21 , 'Executando expedição'											, .f. } )
	aAdd( aCodError, {cWSPar5, 22 , 'Concluída expedição'											, .f. } )
	aAdd( aCodError, {cWSPar5, 42 , ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

	//Recebimentos
	aAdd( aCodError, {cWSPar6, 1 , 'Inserido'														, .t. } )
	aAdd( aCodError, {cWSPar6, 2 , 'Alterado'														, .t. } )
	aAdd( aCodError, {cWSPar6, 3 , 'Excluído'														, .t. } )
	aAdd( aCodError, {cWSPar6, 4 , 'Não alterado (processo já iniciado)'							, .f. } )
	aAdd( aCodError, {cWSPar6, 5 , 'Não alterado (conferência de separação já iniciada)'			, .f. } )
	aAdd( aCodError, {cWSPar6, 6 , 'Não inserido (Não há configuração de deposito para Empresa)'	, .f. } )
	aAdd( aCodError, {cWSPar6, 7 , 'Não inserido (deposito informado não possui configuração)'		, .f. } )
	aAdd( aCodError, {cWSPar6, 8 , 'Não Excluido (processo ja iniciado)'							, .f. } )
	aAdd( aCodError, {cWSPar6, 9 , 'Não inserido (documento vazio)'									, .f. } )
	aAdd( aCodError, {cWSPar6, 10 , 'Não inserido (ERPID vazio)'									, .f. } )
	aAdd( aCodError, {cWSPar6, 11 , 'Não inserido (fornecedor nao cadastrado)'						, .f. } )
	aAdd( aCodError, {cWSPar6, 12 , 'Não inserido (fornecedor vazio)'								, .f. } )
	aAdd( aCodError, {cWSPar6, 13 , 'Nao inserido (produto não consta no WMS)'						, .f. } )
	aAdd( aCodError, {cWSPar6, 42 , ' Erro não cadastrado(informações no log do servidor).'			, .f. } )

	//Manutenção de Lotes
	aAdd( aCodError, {cWSPar7, 1 , 'Processado'														, .t. } )
	aAdd( aCodError, {cWSPar7, 2 , 'Processado com pendências'										, .f. } )
	aAdd( aCodError, {cWSPar7, 3 , 'Não processado(não há configuração de depósito para a empresa)' , .f. } )
	aAdd( aCodError, {cWSPar7, 4 , 'Não processado(depósito informado não possui configuração)'		, .f. } )
	aAdd( aCodError, {cWSPar7, 5 , 'Não processado(código reduzido vazio)'							, .f. } )
	aAdd( aCodError, {cWSPar7, 6 , 'Não processado(produto não identificado no WMS)'				, .f. } )
	aAdd( aCodError, {cWSPar7, 7 , 'Não processado(lote não encontrado)' 							, .f. } )
	aAdd( aCodError, {cWSPar7, 8 , 'Não processado(lote não encontrado no layout especificado)' 	, .f. } )
	aAdd( aCodError, {cWSPar7, 9 , 'Não processado(campo operação vazio)'							, .f. } )
	aAdd( aCodError, {cWSPar7, 10 , 'Não processado(operação não identificada)'						, .f. } )
	aAdd( aCodError, {cWSPar7, 11 , 'Não processado(lote não informado)'							, .f. } )
	aAdd( aCodError, {cWSPar7, 42 , 'Erro não cadastrado(informações no log do servidor)'			, .f. } )

	//Movimentacao Interna
	aAdd( aCodError, {cWSPar8, 1  , 'Inserido'														, .t. } )
	aAdd( aCodError, {cWSPar8, 2  , 'Alterado'														, .t. } )
	aAdd( aCodError, {cWSPar8, 3  , 'Excluído'														, .t. } )
	aAdd( aCodError, {cWSPar8, 4  , 'Não alterado (processo já iniciado)'							, .f. } )
	aAdd( aCodError, {cWSPar8, 6  , 'Não inserido (processo não cadastrado)'						, .f. } )
	aAdd( aCodError, {cWSPar8, 10 , 'Não inserido (pedido com documento vazio)'						, .f. } )
	aAdd( aCodError, {cWSPar8, 11 , 'Não inserido (registro incompleto)'							, .f. } )
	aAdd( aCodError, {cWSPar8, 12 , 'Não inserido (produto não consta no WMS)'						, .f. } )
	aAdd( aCodError, {cWSPar8, 14 , 'Aguardando (conclusão da separação para integrar)'				, .f. } )
	aAdd( aCodError, {cWSPar8, 15 , 'Executando separação'											, .f. } )
	aAdd( aCodError, {cWSPar8, 16 , 'Concluída separação'											, .f. } )
	aAdd( aCodError, {cWSPar8, 42 , 'Erro não cadastrado(informações no log do servidor).'			, .f. } )

	//Transferencias
	aAdd( aCodError, {cWSPar9, 1  , 'Inserido'														, .t. } )
	aAdd( aCodError, {cWSPar9, 2  , 'Alterado'														, .t. } )
	aAdd( aCodError, {cWSPar9, 3  , 'Excluído'														, .t. } )
	aAdd( aCodError, {cWSPar9, 4  , 'Não alterado (processo já iniciado)'							, .f. } )
	aAdd( aCodError, {cWSPar9, 6  , 'Não inserido (processo não cadastrado)'						, .f. } )
	aAdd( aCodError, {cWSPar9, 10 , 'Não inserido (pedido com documento vazio)'						, .f. } )
	aAdd( aCodError, {cWSPar9, 11 , 'Não inserido (registro incompleto)'							, .f. } )
	aAdd( aCodError, {cWSPar9, 12 , 'Não inserido (produto não consta no WMS)'						, .f. } )
	aAdd( aCodError, {cWSPar9, 14 , 'Aguardando (conclusão da separação para integrar)'				, .f. } )
	aAdd( aCodError, {cWSPar9, 15 , 'Executando separação'											, .f. } )
	aAdd( aCodError, {cWSPar9, 16 , 'Concluída separação'											, .f. } )
	aAdd( aCodError, {cWSPar9, 42 , 'Erro não cadastrado(informações no log do servidor).'			, .f. } )

	//Aceite do Produto no WMS
	aAdd( aCodError, {cWSParA, 1  , 'Efetivado'														, .t. } )
	aAdd( aCodError, {cWSParA, 2  , 'Não Alterado(erpId não consta no WMS)'							, .f. } )
	aAdd( aCodError, {cWSParA, 3  , 'Operação inválida (operação não conforme documentação)'		, .f. } )
	aAdd( aCodError, {cWSParA, 42 , 'Erro não cadastrado(informações no log do servidor).'			, .f. } )


	nPos := aScan( aCodError, { |x| x[1]==AllTrim(cSrv) .and. x[2]==nCod } )
	If nPos >0
		aRet[1]:= aCodError[nPos,04]
		aRet[2]:= cvaltochar(aCodError[nPos,02]) +"-"+ aCodError[nPos,03]
	Else
		aRet[1]:= .F.
		aRet[2]:= cvaltochar(nCod) +"- Mensagem de Erro não encontrada."
	Endif

Return aRet

/*/{Protheus.doc} ValCli
Manipulação da loja do cliente devido aos vários cadastros oriundos do Vtrina e a existência apenas de 1 no Cyberloj
@type funcion
@version 1.0
@author Alfred Andersen
@since 21/03/2023
/*/
//U_VALCLI(SC9->C9_FILIAL, SC9->C9_PEDIDO, SC9->C9_CLIENTE, SC9->C9_LOJA)
User Function ValCli(_cFilial, _cPedido, _cCliente, _cLoja)

	Local aArea 	:= GetArea()
	Local cReturn 	:= _cCliente + _cLoja

	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(_cFilial + _cPedido))

		If Alltrim(SC5->C5_VEND1) == '510'
		
			cReturn := _cCliente + '01'

		End
		
	End

	RestArea( aArea )

Return cReturn

/*/{Protheus.doc} ValPed
Compara se o pedido de venda possui todos os seus itens liberados
@type function
@version 1.0
@author Alfred Andersen
@since 12/11/2023
@param _cFil, variant, Código da Filial
@param _cNum, variant, Código do Pedido de Venda
/*/
User Function ValPed(_cFil, _cNum)

	Local lRet      := .T.
	Local cAliasSC6 := GetNextAlias()
	Local cAliasSC9 := ""

		If Select( cAliasSC6) <> 0
			(cAliasSC6)->( dbCloseArea() )
		EndIf	

		//Pesquiso todos os itens do Pedido
		BeginSql Alias cAliasSC6

			SELECT 
				C6_ITEM, C6_PRODUTO, C6_NUM 
			FROM 
				%Table:SC6% SC6
			WHERE 
				SC6.%NOTDEL%
				AND C6_FILIAL = %Exp:_cFil%
				AND C6_NUM = %Exp:_cNum%
		EndSql	

		While ! (cAliasSC6)->( EOF() )

			cAliasSC9 := GetNextAlias()

			If Select( cAliasSC9) <> 0
				(cAliasSC9)->( dbCloseArea() )
			EndIf	

			//Para cada item, verifico se ele consta liberado na SC9 
			BeginSql Alias cAliasSC9
				SELECT 
					MAX(C9_SEQUEN) SEQSC9
				FROM 
					%Table:SC9% SC9
				WHERE 
					SC9.%NOTDEL%
					AND C9_FILIAL = %Exp:_cFil%
					AND C9_PEDIDO = %Exp:_cNum%
					AND C9_ITEM = %Exp:(cAliasSC6)->C6_ITEM%
					AND C9_PRODUTO = %Exp:(cAliasSC6)->C6_PRODUTO%
					AND C9_NFISCAL 	= ''
					AND C9_BLEST 	= ''
					AND C9_BLCRED 	= ''
			EndSql

			(cAliasSC9)->( DbGoTop() )

			//Se não encontrar 1 único produto, o pedido não está apto a ser enviado para o WMS
			If Empty((cAliasSC9)->SEQSC9)
				
				Conout("O item não consta liberado na SC9 | ITEM " + (cAliasSC6)->C6_ITEM +" PRODUTO "+ (cAliasSC6)->C6_PRODUTO)

				Return .F.
			End

			If Select( cAliasSC9) <> 0
				(cAliasSC9)->( dbCloseArea() )
			EndIf

			(cAliasSC6)->( DbSkip() )
		End

		//Encerro as temporárias
		If Select( cAliasSC6) <> 0
			(cAliasSC6)->( dbCloseArea() )
		EndIf	

		If Select( cAliasSC9) <> 0
			(cAliasSC9)->( dbCloseArea() )
		EndIf	

Return lRet
