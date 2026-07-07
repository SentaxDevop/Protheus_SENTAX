//--------------------------------------------------------------------------------------
//Efetua a reserva do pedido de vendas após a confirmação do atendimento pelo televendas
//--------------------------------------------------------------------------------------
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"

User Function TMKVFIM(cNumAtend, cNumPedido)
Local nQtdLib  := 0
Local aArea    := GetArea()
Local aPedidos := {}
Local nPedido  := 0
Local cQuery1  := ""
Local cQuery2  := ""
Local nRegSUB  := 0
Local lCredito := .T.
Local cObsMemo := ""
Local cBlqCom  := "2"
Local cConteud := ""
Local cNumSAC  := ""

Private cRazao    := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
Private cMot      := ""
Private dEmis     := SC5->C5_EMISSAO
Private cPed      := cNumPedido
Private nValAv    := 0
Private aDadosSUB := {}

/*
 * Natan 
 * Melhorias na data de validade evitando problemas na emissão do relatório do orçamento
 */ 
If INCLUI .OR. ALTERA
	             	
	/*
	 * Força a data de validade ser Emissão + dias de validade do Grupo de Atendimento
	 */
	RecLock("SUA",.F.)      
	SUA->UA_DTLIM := SUA->UA_EMISSAO + TkPosto(M->UA_OPERADO,"U0_VALIDAD")
	MsUnlock()			
	
EndIf 

//Verifica se é Atendimento
//If (M->UA_OPER == "3" .And. SUA->UA_TMK == "T") /*Atendimento e SAC*/
/*
	If FWAlertYesNo("O chamado do SAC poderá ser incluído de forma automática neste momento. Confirma essa inclusão?", "Chamado SAC")
		RecLock("SUA",.F.)
			SUA->UA_XGERSAC := "S"
		MsUnLock()
	End
*/
//Endif


//Verifica se é faturamento
If M->UA_OPER <> "1"

	If (SUA->UA_OPER == "3" .And. SUA->UA_TMK == "7") /*Atendimento e OS*/

		U_ATMK017(SUA->UA_OPER)

	End

	Return

Endif

//Verifica se o pedido possui bloqueio por regra (desconto ou avaliação TES)
dbSelectArea("SC6")
SC6->(dbSetOrder(1))
SC6->(dbSeek(xFilial("SC6")+cNumPedido,.T.))
While SC6->(!Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPedido
	If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_BLQ") == "S" .or. Posicione("SUB",3,xFilial("SUB")+SC6->C6_NUM+SC6->C6_ITEM,"UB_BLQREG") == "S"
		nPedido := nPedido + 1
	Endif
	SC6->(dbSkip())
Enddo

//Grava o preço da tabela A no pedido de venda
nRegSUB := SUB->(RECNO())

dbSelectArea("SC6")
SC6->(dbSetOrder(1))
SC6->(dbGoTop())

SUB->(dbSetOrder(1))
SUB->(dbGoTop())
SUB->(dbSeek(xFilial("SUB")+cNumAtend))


While !SUB->(Eof()) .And. SUB->UB_FILIAL+SUB->UB_NUM == xFilial("SUB")+cNumAtend
	
	If SC6->(dbSeek(SUB->UB_FILIAL+SUB->UB_NUMPV+SUB->UB_ITEM))
		RecLock("SC6")
		SC6->C6_DESCRI	:= Posicione("SB1",1,xFilial("SB1") + SC6->C6_PRODUTO,"B1_DESC")
		SC6->C6_PRELIST := SUB->UB_PRELIST
		SC6->C6_PEDCLI  := SUB->UB_PEDCLI
		//TAGs xPED e nItemPed no XML
		SC6->C6_NUMPCOM	:= SUB->UB_PEDCLI
		SC6->C6_ITEMPC	:= IF(!Empty(Alltrim(SUB->UB_XITEMPC)),SUB->UB_XITEMPC,SUB->UB_ITEM)
		SC6->(MsUnLock())         
		
		//VERIFICA SE É OPERAÇÃO ESPECIAL, BLOQUEANDO O PEDIDO PARA FATURAMENTO E PERMITINDO GERAR PEDIDO DE REMESSA
		cConteud := GetMV("ST_OPREM")
		If ALLTRIM(SUB->UB_XOPER) $ cConteud 
			cBlqCom := '1'                          
		EndIf 
		
	EndIf

	aAdd(aDadosSUB, { SUB->UB_PRODUTO })

	SUB->(dbSkip())
	
EndDo


SUB->(dbGoTo(nRegSUB))

//Grava bloqueio nos itens do pedido de vendas por regra
If nPedido > 0
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+cNumPedido,.T.))
	While SC6->(!Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPedido
		Begin Transaction
		If RecLock("SC6")
			SC6->C6_BLOQUEI := "01"
			MsUnLock("SC6")
		Endif
		End Transaction
		SC6->(dbSkip())
	Enddo
Endif

//Grava bloqueio no cabeçalho do pedido de vendas por regra
If nPedido > 0
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+cNumPedido,.T.))
	If SC5->(Found())
		Begin Transaction
		If RecLock("SC5")
			SC5->C5_BLQ := "1"
			MsUnLock("SC5")
		Endif
		End Transaction
	Endif
	
	//Envia e-mail se houver bloqueio por regras
	If GETMV("MV_USAROT") == "S"
	
		BeginSql Alias "TMPSC6"
			SELECT	SUM((C6_PRCVEN * C6_QTDVEN)) TOTAL 
			FROM	%Table:SC6%
			WHERE	C6_FILIAL = %xFilial:SC6%	AND
					C6_NUM    = %Exp:cNumPedido%
		EndSql
		
		nValAv := TMPSC6->TOTAL
		
		TMPSC6->(DbCloseArea())
	
		cMot := Alltrim(cNumPedido) + " - BLOQUEIO REGRAS"
		MAILPED()
	Endif
Endif

//Libera o pedido de vendas e efetua reserva do estoque se não existir bloqueio por regra
If nPedido == 0
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+cNumPedido,.T.))
	
	While SC6->(!Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPedido
		Begin Transaction
		
		If Empty(aPedidos)
			AADD(aPedidos, cNumPedido)
		Endif
		
		MaLibDoFat(SC6->(Recno()),SC6->C6_QTDVEN,.T.,.T.,.T.,.T.,.F.,.T.,,)
		
		End Transaction
		SC6->(dbSkip())
	Enddo
	
	cQuery1 := " SELECT C9_PEDIDO, C9_BLCRED "
	cQuery1 += " FROM " + RetSqlName("SC9")
	cQuery1 += " WHERE D_E_L_E_T_ = ' ' "
	cQuery1 += " AND C9_FILIAL = '" + xFilial("SC9") + "' "
	cQuery1 += " AND C9_PEDIDO = '" + cNumPedido + "' "
	cQuery1 += " AND C9_BLCRED <> '  ' "
	
	TcQuery cQuery1 New Alias "TRB"
	
	TRB->(DBGOTOP())
	IF !EMPTY(TRB->C9_PEDIDO)
		//Envia e-mail se houver bloqueio por crédito
		If GETMV("MV_USAROT") == "S"
		
			BeginSql Alias "TMPSC6"
				SELECT	SUM((C6_PRCVEN * C6_QTDVEN)) TOTAL 
				FROM	%Table:SC6%
				WHERE	C6_FILIAL = %xFilial:SC6%	AND
						C6_NUM    = %Exp:cNumPedido%
			EndSql
			
			nValAv := TMPSC6->TOTAL
			
			TMPSC6->(DbCloseArea())
		
			cMot := Alltrim(cNumPedido) + " - BLOQUEIO CRÉDITO"
			MAILPED()
		Endif
	ENDIF
	
	TRB->(DbCloseArea())
	
ENDIF

//Grava liberação do pedido de vendas
If !Empty(aPedidos)
	Begin Transaction
	SC5->(MaLiberOk({cNumPedido},.F.))
	End Transaction
Endif 

//Busca informações do memo de observação do atendimento
cObsMemo:= MSMM(SUA->UA_CODOBS,TamSx3("UA_OBS")[1]) 

//Grava dados do atendimento no pedido de vendas
dbSelectArea("SC5")
SC5->(dbSetOrder(1))
SC5->(dbSeek(xFilial("SC5")+cNumPedido,.T.))
If SC5->(Found())
	//Begin Transaction
	If RecLock("SC5",.F.)
		SC5->C5_MENNOTA := M->UA_XMENNOT
		SC5->C5_MENPAD  := M->UA_XMENPAD
		// retirado para funcionar no padrao o tipo 9
		/* SC5->C5_PARC1   := M->UA_XPARC1
		SC5->C5_PARC2   := M->UA_XPARC2
		SC5->C5_PARC3   := M->UA_XPARC3
		SC5->C5_PARC4   := M->UA_XPARC4
		SC5->C5_DATA1   := M->UA_XDATA1
		SC5->C5_DATA2   := M->UA_XDATA2
		SC5->C5_DATA3   := M->UA_XDATA3
		SC5->C5_DATA4   := M->UA_XDATA4*/
		SC5->C5_VEND2   := M->UA_VEND2
		SC5->C5_VEND3   := M->UA_VEND3
		SC5->C5_XFORMA	:= SL4->L4_FORMA
		SC5->C5_TIPLIB  := "1"     
   		SC5->C5_XENDENT	:= SUA->UA_ENDENT
   		SC5->C5_XBAIENT := SUA->UA_BAIRROE  
   		SC5->C5_XCEPENT := SUA->UA_CEPE 
   		SC5->C5_XESTENT := SUA->UA_ESTE 
   		SC5->C5_XMUNENT := SUA->UA_MUNE //SUA->UA_MUNC		
		SC5->C5_XOBSLOG	:= cObsMemo
		SC5->C5_XBLCOM	:= cBlqCom
		MsUnlock("SC5")
	Endif
	//End Transaction
Endif
        
cSql:=" select SUM(C6_VALOR)VALOR from "+RetSqlName('SC5')+" SC5 "
cSql+=" INNER JOIN "+RetSqlName('SC6')+" SC6 "
cSql+="  ON C6_FILIAL = C5_FILIAL "
cSql+=" AND C6_NUM = C5_NUM "
cSql+=" AND SC6.D_E_L_E_T_<>'*' "
cSql+=" INNER JOIN "+RetSqlName('SF4')+" SF4 "
cSql+=" ON F4_FILIAL ='"+xFilial('SF4')+"'"
cSql+=" AND F4_CODIGO = C6_TES "
cSql+=" AND F4_DUPLIC='S' "
cSql+=" AND SF4.D_E_L_E_T_<>'*' "
cSql+=" WHERE C5_CLIENTE='"+SC5->C5_CLIENTE+"' "
cSql+=" AND C5_LOJACLI = '"+SC5->C5_LOJACLI+"'
cSql+=" AND C5_EMISSAO LIKE '"+SUBSTR(DTOS(SC5->C5_EMISSAO),1,6)+"%' "
cSql+=" AND SC5.D_E_L_E_T_<>'*' "
IF Select('TRC6')<>0
  TRC6->(DBCloseArea())
EndIF
TcQuery cSql new Alias 'TRC6'


IF !TRC6->(EOF())
	
	dbSelectArea('Z19')
	DBSetOrder(1)
	If DBSeek(xFilial('Z19')+substr(dtos(SC5->C5_EMISSAO),5,2)+substr(dtos(SC5->C5_EMISSAO),1,4)+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		RECLOCK('Z19',.F.)
		Z19->Z19_PEDMES  := TRC6->VALOR
		// Z19->Z19_STATU2  := '2'   // Pedido Melhoria... Nao subir neste momento.
		msunlock()
	Endif 	

EndIF

If (SUA->UA_OPER == "1") /*Faturamento*/

	U_ATMK017(SUA->UA_OPER)

End


RestArea(aArea)

Return

//------------------------------------------
//Envio de e-mail sobre o bloqueio do pedido
//------------------------------------------
Static Function MAILPED()

Private cServer    := GETMV("MV_RELSERV")
Private cAccount   := GETMV("MV_RELACNT")
Private cPassword  := GETMV("MV_RELPSW")
Private lAutentica := GETMV("MV_RELAUTH")
Private cMail      := GETMV("MV_MAILPED")
Private cInforma   := Alltrim(cUserName)+" - "+Time()
Private cAssunto   := cMot
Private cEnvia     := cAccount
Private cBody      := ""
Private cQbra      := "<BR>"

cBody += '<table class=p11preto border=1 cellpadding=1 cellspacing=2 width="100%" bordercolor="#111111"> '
cBody += '<tr> '
cBody += '<td bgColor=#e4dfe0 style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center"> <b>ATENÇÃO - PEDIDO DE VENDAS BLOQUEADO</b> </td>'
cBody += '</tr> '
cBody += '</table>'

cBody += '<table class=p11preto border=1 cellpadding=1 cellspacing=2 width="100%" bordercolor="#111111"> '
cBody += '<tr> '
cBody += '<td bgColor=#e4dfe0 style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center"> <b>FILIAL</b> </td>'
cBody += '<td bgColor=#e4dfe0 style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center"> <b>PEDIDO</b> </td>'
cBody += '<td bgColor=#e4dfe0 style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center"> <b>CLIENTE</b> </td>'
cBody += '<td bgColor=#e4dfe0 style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center"> <b>EMISSÃO</b> </td>'
cBody += '<td bgColor=#e4dfe0 style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center"> <b>VALOR</b> </td>'

cBody += '</tr> '
cBody += '<tr>'
cBody += '<td style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center">' + xFilial("SC5") + '</td>'
cBody += '<td style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center">' + cPed + '</td>'
cBody += '<td style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center">' + cRazao + '</td>'
cBody += '<td style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center">' + dtoc(dEmis) + '</td>'
cBody += '<td style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center">' + Transform(nValAv,"@E 999,999,999.99") + '</td>'


cBody += '</tr>'
cBody += '</table>'

cBody += cQbra

cBody += '<table class=p11preto border=1 cellpadding=1 cellspacing=2 width="100%" bordercolor="#111111"> '
cBody += '<tr> '
cBody += '<td bgColor=#e4dfe0 style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center"> <b>USUÁRIO</b> </td>'
cBody += '</tr> '
cBody += '<tr>'
cBody += '<td style="font-size:10.0pt;mso-bidi-font-size:10.0pt font-family:Tahoma"> <FONT face=Tahoma> <p align="center">'+ cInforma + '</td>'
cBody += '</tr>'
cBody += '</table>'

//Conexão servidor
lConectou := .F.
If !lConectou
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou
Endif

While !lConectou
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou
Enddo

If lConectou
	mailauth(cAccount, cPassword)
	SEND MAIL FROM cEnvia TO cMail SUBJECT cAssunto BODY cBody RESULT lSendOk
	
	If !lSendOk
		MostraErro()
	Endif
Else
	MostraErro()
Endif

If lConectou
	DISCONNECT SMTP SERVER
Endif

Return

//-----------------------------
//Verifica erro na conexão SMTP
//-----------------------------
Static Function MostraErro()
Get MAIL ERROR cError
qOut(cError + "-Erro")

Return
