#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} wtmk001
gera planilha de projecao de vendas e envia por e-mail

@author		Rodrigo@afsouza.com.br
@since		11/05/2021
@version	P12

@return 	Nil, nenhum

@type function
/*/
//-------------------------------------------------------------------

Static oCellHorAlign    := FwXlsxCellAlignment():Horizontal()
Static oCellVertAlign   := FwXlsxCellAlignment():Vertical()

User Function WTMK001()
Local nCont         := 0
Local __cEmp	    := "01"
Local __cFil	    := "020201"
Local lDayOne       := .F.

Private cCRLF       := CRLF
Private nHandle     := 0      
Private cNumCond    := space(10)
Private lFist       :=.f.
Private nErros      := 0

RPCSetType(3)  
If !RpcSetEnv(__cEmp,__cFil,,,,GetEnvServer(),{ }) 
		Conout("")
		Conout("Empresa nao localizada")
	Else 
		lRpcSetEnv := .F.
EndIf

DbSelectArea("SX6")
DbSetOrder(1)

Conout('**********************WF de Projecao de Vendas-WTMK001****************************')
Conout('**********************WF de Projecao de Vendas-WTMK001****************************')
Conout('**********************WF de Projecao de Vendas-WTMK001****************************')

If FirstDate(dDataBase)  == dDataBase .AND. GETMV("SX_PROCWF") <> dDataBase
    dDataBase   :=  LastDate((FirstDate(dDataBase) - 5))

    PUTMV('SX_PROCWF', dDataBase)
    
    cUpd:= "UPDATE SA3010 SET A3_XDTWF='"+ DtOS( (dDataBase - 1) ) +"'"

    lDayOne := .T.
EndIF

If ( (FirstDate(dDataBase) + 1 ) == dDataBase ) //tratamento para o segundo dia do mes
  
    dDataBase   :=  LastDate((FirstDate(dDataBase) - 5))

    PUTMV('SX_PROCWF', dDataBase)
    
    cUpd:= "UPDATE SA3010 SET A3_XDTWF='"+ DtOS( (dDataBase-1) ) +"'"
EndIf

cSql:=" SELECT VEND.A3_COD,VEND.A3_NOME,VEND.A3_EMAIL EMAILVEND, VEND.A3_GEREN, GERENTE.A3_EMAIL AS EMAILGERENTE, VEND.R_E_C_N_O_ REC "+cCRLF
cSql+="	FROM SA3010 VEND WITH(NOLOCK)"+cCRLF
cSql+="	LEFT JOIN SA3010 GERENTE WITH(NOLOCK) ON VEND.A3_FILIAL = GERENTE.A3_FILIAL AND VEND.A3_GEREN = GERENTE.A3_COD AND GERENTE.D_E_L_E_T_<>'*' "+cCRLF
cSql+="	INNER JOIN VENDAS ON (VEND_UA1 = VEND.A3_COD OR VEND_UA2 = VEND.A3_COD) "+cCRLF
cSql+="	WHERE VEND.D_E_L_E_T_ <> '*' "+cCRLF
cSql+="	AND VEND.A3_MSBLQL <> '1' "+cCRLF

    If lDayOne
        cSql+=" AND VEND.A3_XDTWF = '"+DtOS(dDataBase)+"' "+cCRLF"
    Else
        cSql+=" AND VEND.A3_XDTWF <> '"+DtOS(dDataBase)+"' "+cCRLF"
    End
cSql+=" AND VEND.A3_XVENWF = 'S' "+cCRLF
cSql+=" GROUP BY VEND.A3_COD,VEND.A3_EMAIL, VEND.A3_GEREN, GERENTE.A3_EMAIL,VEND.A3_NOME,VEND.R_E_C_N_O_ "+cCRLF
cSql+=" ORDER BY VEND.A3_COD "+cCRLF

If SELECT('TRBA')<>0
    TRBA->(DbCloseArea())
EndIf

TcQuery cSql New Alias 'TRBA'

DbSelectArea("TRBA")
TRBA->(DbGoTop())

While !TRBA->(EOF())   
    nCont++

    Conout("")
    Conout("PRocessando "+cValToChar(nCont))
    
    cMail:=alltrim(TRBA->EMAILVEND)
    if (!empty(cMail))
        cMail+=';'
    EndiF
    
    cMail+=alltrim(TRBA->EMAILGERENTE)
    if (!empty(cMail)).AND. RIGHT(cMail,1)<>";"
        cMail+=';'
    EndiF

    if (!empty(cMail)).AND. RIGHT(cMail,1)<>";"
        cMail+=';'
    EndiF
    
    cMail+= GetMV("ST_MAILTI")
   
    //CMail:=""

    GERAXLS(TRBA->A3_COD)
   
    Conout(TRBA->A3_COD +' '+TRBA->A3_NOME)
    
    //envmail(TRBA->A3_COD,cMail)
     
    cMensagem := "Prezado(a) "+TRBA->A3_NOME+'<br>'
    cMensagem += "Segue relação de vendas <br>"+cCRLF
    
    lEnv    := .f.
    lEnv    :=  SendMail(cMail,"PROJEÇÃO DE VENDAS "+TRBA->A3_COD,cMensagem,'\plan_vendas\'+ALLTRIM(TRBA->A3_COD)+'.xlsx')
    
    if lEnv
            cUpd:= "UPDATE SA3010 SET A3_XDTWF='"+DtOS(dDataBase)+"' WHERE R_E_C_N_O_ ="+cValToChar(TRBA->REC)+""
            TcSqlExec(cUpd)
        Else
            nErros++
    EndIf

    If nErros>10
        //Return
    EndiF

    TRBA->(DbSkip())
EndDo

Return()

Static Function GERAXLS(cCodVend)
Local cPath     := "\plan_vendas\"  // /spool/ para uma geração no server
Local cArquivo  := cPath + "exemplo.rel"

Local lRet      := .F.
Local oFileW 
Local oPrtXlsx 

cNome       := BuscaDados(cCodVend)

cArquivo    := cPath +ALLTRIM(cCodVend)+".rel"
oFileW      := FwFileWriter():New(cArquivo)
oPrtXlsx    := FwPrinterXlsx():New()

lRet := oPrtXlsx:Activate(cArquivo, oFileW)

lRet := oPrtXlsx:AddSheet("Minha Plan1")

//PRIMEIRA LINHA E PRIMEIRA COLUNA
cFont       := FwPrinterFont():Calibri()
nSize       := 14
lItalic     := .T.
lBold       := .T.
lUnderlined := .T.

// Comando 'Fonte' com Calibri 14, itálico, negrito e sublinhado
lRet            := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)

cHorAlignment   := oCellHorAlign:Default()
cVertAlignment  := oCellVertAlign:Default()
lWrapText       := .F.
nRotation       := 0

// Comando 'Formato de Célula' com cor de texto e fundo personalizadas
lRet    := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "00008B", "FFFFFF", "" )

nColFrom := 1
nColTo  := 25
nWidth  := 24
lRet    := oPrtXlsx:SetColumnsWidth(nColFrom, nColTo, nWidth)

nRow    := 1
nCol    := 1

// Texto em A1
lRet        := oPrtXlsx:SetText(nRow, nCol, ALLTRIM(cCodVend)+"-"+TRAB->A3_NOME)
//PRIMEIRA LINHA E PRIMEIRA COLUNA ---FIM

//SEGUNDA LINHA
// cFont := FwPrinterFont():getFromName("Calibri")
cFont       :=  FwPrinterFont():getFromName("Verdana")
nSize       := 11
lItalic     := .F.
lBold       := .T.
lUnderlined := .F.

// Calibri 11
lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)

lRet := oPrtXlsx:ResetCellsFormat()
lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "FFFFFF", "00008B", "FFFFFF", "" )
nRow := 2
nCol := 1
lRet := oPrtXlsx:SetText(nRow, nCol, "GRUPO")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "FILIAL")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "EMISSAO")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "VEND")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "NVEND")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "TELEVENDAS")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "NTELEV")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "OPERADOR")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "NOTA")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "NF_ORIGEM")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "PEDIDO")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "COD_CLI")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "FANTASIA")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "MARKETING")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "GRUPO")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "DESC.GRUPO")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "ITEM")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "PRODUTO")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "DESCRICAO")
nCol++

lRet := oPrtXlsx:SetText(nRow, nCol, "CFOP")
nCol++

lRet := oPrtXlsx:SetText(nRow, nCol, "CFOP_DESC")
nCol++

lRet := oPrtXlsx:SetText(nRow, nCol, "NOME_FORNEC")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "QUANT")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "PRCVEN")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "PRCCOM")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "Tot_venda")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "Tot_Dev")
nCol++
lRet := oPrtXlsx:SetText(nRow, nCol, "Tot_Geral")
nCol++

lRet := oPrtXlsx:SetText(nRow, nCol, "CFOP")
nCol++

lRet := oPrtXlsx:SetText(nRow, nCol, "CFOP_Desc")
nCol++

Ret := oPrtXlsx:ResetCellsFormat()

DbSelectArea("TRAB")
TRAB->(DbGoTop())

While !TRAB->(EOF())
    nRow++
    nCol := 1
    lRet := oPrtXlsx:SetText(nRow, nCol, "SENTAX")
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol, ALLTRIM(TRAB->COD_FIL))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,dtoc(STOD(TRAB->EMISSAO)))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,ALLTRIM(TRAB->A3_COD))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,ALLTRIM(TRAB->A3_NOME))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,TRAB->VEND_UA2)
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->NUAVEND2))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->OPERADOR))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->NF))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->NOTAORIGEM))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->PEDIDO))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->COD_CLIENTE))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->HISTORICO))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->TMK))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->GRPROD))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->GRUPOPROD))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->ITEM))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->COD_PRODUTO))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->PRODUTO))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->CFOP))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->X5_DESCRI))
    nCol++

    lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->FORNECEDOR))
    nCol++

    lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(cValToChar(TRAB->QUANTI)))
    nCol++

    lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(cValToChar(TRAB->PRCVEN)))
    nCol++

    lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(cValToChar(TRAB->PRCCOM)))
    nCol++

    lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(cValToChar(TRAB->TOTAL_VENDA)))
    nCol++

    lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(cValToChar(TRAB->DEVOLUCAO)))
    nCol++

    lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(cValToChar(TRAB->TOTAL_GERAL)))

    TRAB->(DBSKIP())
EndDo


lRet := oPrtXlsx:toXlsx()
 
Return()


Static Function fGetXML(cTexto)

FWrite(nHandle,FwNoAccent(cTexto) + chr(13) + chr(10))

Return()

Static Function BuscaDados(cCodVend)
Local cSql := ""

/*
cSql:="SELECT COD_PRODUTO,GRUPOPROD,GRPROD,VEND.A3_EMAIL EMAILVEND, VEND.A3_GEREN, GERENTE.A3_EMAIL AS EMAILGERENTE,"+cCRLF
cSql+="	COD_FIL, EMISSAO, VEND.A3_COD,VEND.A3_NOME,VEND_UA2, NUAVEND2,OPERADOR,NF,NOTAORIGEM,PEDIDO,COD_CLIENTE,HISTORICO,TMK, ITEM,PRODUTO,FORNECEDOR, QUANTI, PRCVEN,CUSTO PRCCOM, VENDA-FRETE TOTAL_VENDA, DEVOLUCAO,VENDA-FRETE+DEVOLUCAO TOTAL_GERAL"+cCRLF
cSql+="	FROM SA3010 VEND"+cCRLF
cSql+="	LEFT JOIN SA3010 GERENTE"+cCRLF
cSql+="		on VEND.A3_FILIAL = GERENTE.A3_FILIAL"+cCRLF
cSql+="		AND VEND.A3_GEREN = GERENTE.A3_COD"+cCRLF
cSql+="		AND GERENTE.D_E_L_E_T_<>'*'"+cCRLF
cSql+="	INNER JOIN VENDAS "+cCRLF
//cSql+="		ON COD_VEND = VEND.A3_COD"+cCRLF // ALTERADO PARA VALIDAR O VENDEDOR DO PEDIDO E NAO O DO CLIENTE
cSql+="		ON VEND_UA1 = VEND.A3_COD"+cCRLF
cSql+=" where EMISSAO LIKE '"+substr(dtos(dDataBase),1,6)+"%'"+cCRLF
cSql+=" AND  (VEND.A3_COD='"+cCodVend+"' OR  VENDAS.VEND_UA2='"+cCodVend+"' )"+cCRLF
cSql+=" AND  (VENDAS.CFOP NOT IN ('5908','6908','1909','2909') )"+cCRLF
cSql+=" and VEND.D_E_L_E_T_<>'*'"+cCRLF
cSql+=" order by COD_FIL,EMISSAO,VEND_UA2,OPERADOR"+cCRLF
*/
cSql += " SELECT	COD_PRODUTO,VENDAS.CFOP, SX5.X5_DESCRI, "+cCRLF
cSql += " 		GRUPOPROD,GRPROD,VEND.A3_EMAIL EMAILVEND, VEND.A3_GEREN, GERENTE.A3_EMAIL AS EMAILGERENTE, "+cCRLF
cSql += " 		COD_FIL, EMISSAO, VEND.A3_COD,VEND.A3_NOME,VEND_UA2, NUAVEND2,OPERADOR,NF,NOTAORIGEM,PEDIDO,COD_CLIENTE,HISTORICO,TMK, "+cCRLF
cSql += " 		ITEM,PRODUTO,FORNECEDOR, QUANTI, PRCVEN,CUSTO PRCCOM, VENDA-FRETE TOTAL_VENDA, DEVOLUCAO,VENDA-FRETE+DEVOLUCAO TOTAL_GERAL "+cCRLF
cSql += " FROM " + RetSqlName("SA3") + " VEND WITH(NOLOCK) "+cCRLF
cSql += " LEFT JOIN " + RetSqlName("SA3") + " GERENTE WITH(NOLOCK) ON VEND.A3_FILIAL = GERENTE.A3_FILIAL	AND VEND.A3_GEREN = GERENTE.A3_COD AND GERENTE.D_E_L_E_T_<>'*' "+cCRLF
cSql += " INNER JOIN VENDAS ON VEND_UA1 = VEND.A3_COD "+cCRLF 
cSql += " LEFT JOIN " + RetSqlName("SX5") + " SX5 WITH(NOLOCK) ON SX5.X5_TABELA = '13' AND LTRIM(SX5.X5_CHAVE) = VENDAS.CFOP AND SX5.D_E_L_E_T_ = '' "+cCRLF
cSql += " WHERE EMISSAO LIKE '"+ Substr(DTOS(dDataBase) ,1,6) +"%' "+cCRLF
cSql += " AND  (VEND.A3_COD = '"+cCodVend+"' OR  VENDAS.VEND_UA2 = '"+cCodVend+"' ) "+cCRLF
cSql += " AND  (VENDAS.CFOP NOT IN ('5908','6908','1909','2909') ) "+cCRLF
cSql += " AND VEND.D_E_L_E_T_<>'*' "+cCRLF
cSql += " ORDER BY COD_FIL,EMISSAO,VEND_UA2,OPERADOR "+cCRLF

// memowrite("c:\temp\afata001.txt",cQuery)

If select('TRAB') != 0
	TRAB->(DbCloseArea())
EndIf

TcQuery cSql New Alias 'TRAB'

Return() 

Static Function SendMail(cTo,cAssunto,cBody,cAnexo)
Local cServer    := GETMV("MV_RELSERV")
Local cAccount   := GETMV("MV_RELACNT")
Local cPassword  := GETMV("MV_RELPSW")
Local cFrom      := GETMV("MV_RELFROM")


lRet := EnvMail(cAccount,cPassword,cServer,cFrom,cTo,cAssunto,cBody,cAnexo)

Return lRet



Static Function EnvMail(cEnviaSMTP,cPassword,cServer,cEnvia,cTo,cAssunto,cHTML,cAnexo)
Local oMail  		:= NIL
Local oMessage  	:= NIL
Local nErro 		:= 0
Local lRet 			:= .T.
Local cSMTPServer	:= substr(cServer,1,at(':',cserver)-1 )
Local cSMTPUser		:= cEnviaSMTP
Local cSMTPPass		:= cPassword
Local cMailFrom		:= "SENTAX <"+cEnvia+">"
Local nPort	   		:= val(substr(cServer,at(':',cserver)+1))
Local lUseAuth		:= GetMV("MV_RELAUTH",,.T.)
Local cPara 		:= cTo //Destinatário
Local lTLS			:= GetMV("MV_RELTLS ",.F.,.F.)
Local nTOUT			:= GetMV("MV_RELTIME",.F.,120)

DEFAULT cAssunto := ""
DEFAULT cHTML := ""

cMsg :=chtml// StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cHTML, ";"), "&", "&amp;"), " ", "&nbsp;"), ">", "&gt;"), "<", "&lt;"), CRLF, "<BR>")

If !lTLS
	//MailSMTPOn
	CONNECT SMTP SERVER cSMTPServer ACCOUNT cSMTPUser PASSWORD cSMTPPass RESULT lRet
	If 	lRet
            SEND MAIL FROM cMailFrom ;
            TO cPara ;
            SUBJECT cAssunto ;
            BODY cMsg;
            ATTACHMENT ;
            RESULT lRet
            If !lRet
                GET MAIL ERROR cMAilError
                Conout("Erro no envio do e-mail " + RTrim(cMAilError)) //"Erro no envio do e-mail "
            EndIf
            DISCONNECT SMTP SERVER
        Else
            GET MAIL ERROR cMAilError
            Conout("Erro na conexão:" +  RTrim(cErro)) //"Erro na conexão:"
	EndIf
	
Else
	oMail := TMailManager():New()
	oMail:SetUseTLS(.T.)
    oMail:SetUseSSL(.f.)
	oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort  )
	oMail:SetSmtpTimeOut( nTOUT )
	nErro := oMail:SmtpConnect()
	
	If lUseAuth
		nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
		If nErro <> 0
			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')') //"Erro de Autenticacao "
			lRet := .F.
		Endif
	Endif
	
	if nErro <> 0
		
		// Recupera erro
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := '***UNKNOW***'
		Conout(cMAilError)
		
		Conout("Erro de Conexão SMTP "+str(nErro,4)) //"Erro de Conexão SMTP "
		oMail:SMTPDisconnect()
		
		lRet := .F.
		
	Endif
	Conout(chr(13)+chr(10)+"___________________________________________________________________________________________")
	Conout(cpara)
	Conout(chr(13)+chr(10)+"___________________________________________________________________________________________")
	If lRet
		oMessage := TMailMessage():New()
		oMessage:Clear()
		oMessage:cFrom	:= cMailFrom
		oMessage:cTo	:= cPara
		oMessage:cSubject	:= cAssunto
		oMessage:cBody		:= cMsg  
	   	nRet := oMessage:AttachFile( cAnexo )
		nErro := oMessage:Send( oMail )
		
		if nErro <> 0
			xError := oMail:GetErrorString(nErro)
			Conout("Erro de Envio SMTP" +str(nErro,4)+" ("+xError+")") //"Erro de Envio SMTP "
			lRet := .F.
		Endif
		
		oMail:SMTPDisconnect()
		FreeObj(oMessage)
	Endif
	
	FreeObj(oMail)
	
EndIf

Return lRet







