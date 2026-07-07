#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopCONN.CH"
#include "TOTVS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK007
lISTA DE CONTATOS
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------CHAMADA TELA PRINCIPAL------------------------------------------------
User Function ATMK007

Local aSize		:= {}
Local nI
Local oDlg
Local nUsado 		:= 0
Local aButtons 		:= {}
Local oRelation
Local oFWLayer
Local oMBrowseDown

Local aRotbkp   := MenuDef()  // Rogerio 26/09

Private lRet        := .T. 
Private oDlg 		:= NIL
Private INCLUI 		:= .F.
Private ALTERA 		:= .F.
Private cFiltro		:= ""
Private oGdList
Private oGreen   	:= LoadBitmap( GetResources(), "BR_VERDE")
Private oRed    	:= LoadBitmap( GetResources(), "BR_VERMELHO")
Private oBlack		:= LoadBitmap( GetResources(), "BR_PRETO")
Private oYellow		:= LoadBitmap( GetResources(), "BR_AMARELO")
Private oBrown		:= LoadBitmap( GetResources(), "BR_MARROM")
Private oBlue		:= LoadBitmap( GetResources(), "BR_AZUL")
Private oOrange		:= LoadBitmap( GetResources(), "BR_LARANJA")
Private oViolet		:= LoadBitmap( GetResources(), "BR_VIOLETA")
Private oPink		:= LoadBitmap( GetResources(), "BR_PINK")
Private oGray		:= LoadBitmap( GetResources(), "BR_CINZA")
Private oBranco		:= LoadBitmap( GetResources(), "BR_BRANCO")
Private oGdList2
Private lRefresh	:= .T.
Private aHead01 	:= {}
Private aHead02 	:= {}
Private aHead03 	:= {}
Private aCols01		:= {}
Private aCols02		:= {}
Private aCols03		:= {}
Private aCols 		:= {}
Private cFiltro		:= ""
Private lTst0101:=.f.
Private lTst0102:=.f.
Private lTst0103:=.f.
Private lTst0104:=.f.
Private lTst0201:=.t.
Private lTst0202:=.f.
Private lTst0203:=.f.
Private lTst0204:=.f.
Private lTst0205:=.f.
Private lTst0206:=.f.
Private lTst0207:=.t.
Private lTst0208:=.f.
Private lHasButton:=.t.
Private oMBrDownL
Private oMBrowseRight
Private oPanelDown
Private oPanelLeft
Private oPanelRight
Private cCli    :=space(50)
Private cTele	:=""
private aAlter1 	:= {}

//Local aRotina   := MenuDef()  // Rogerio 26/09 

Aadd( aButtons, {"HISTORIC", {|| ABRETMK(.F.)}, "Receptivo..."	, "Recptivo" , {|| .T.}} )
Aadd( aButtons, {"HISTORIC", {|| U_ATMK009()}, "Ag.Geral..."	, "Ag.Geral" , {|| .T.}} )

Aadd( aButtons, {"HISTORIC", {|| VELEG()}, "Legenda..."	, "Legenda" , {|| .T.}} )
Aadd( aButtons, {"HISTORIC", {|| U_ATMK006(.T.)}, "Rel.Lista...", "Rel.Lista" , {|| .T.}} )
Aadd( aButtons, {"HISTORIC", {|| veMtxRe()}, "Meta x Real..."	, "Meta x Real" , {|| .T.}} )
Aadd( aButtons, {"HISTORIC", {|| INCAGEND()}, "Inc.Agenda..."	, "Inc.Agenda" , {|| .T.}} )
Aadd( aButtons, {"HISTORIC", {|| BXGEND()}, "Baixa.Agenda..."	, "Baixa.Agenda" , {|| .T.}} )

/*If !TMKOPERADOR()
	Help("  ",1,"OPERADOR")
	lRet:= .F.
	Return(lRet)
Endif*/

cTele:=SU7->U7_COD

aSize	:= MsAdvSize()

aObjects 	:= {}

AAdd( aObjects, { 0     ,   10, .T., .T. } )
AAdd( aObjects, { 0	    ,   80, .T., .T. } )   //80
AAdd( aObjects, { 50	,   90,  .t., .T. } ) //50

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

aPosObj := MsObjSize( aInfo, aObjects )

aIndex:={}
aSeek:={}

Z19->( DbSetOrder(1) )  // DT_RET

// aRotadminina := aRotbkp // Rogerio 26/09

DEFINE MSDIALOG oDlg TITLE "Lista de Contatos" FROM aSize[7],000 TO aSize[6],aSize[5]  PIXEL

oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.F.,.T.)

//-- Microsiga Browse da esquerda
/*
oFWLayer:addLine("UP",50,.F.)
oFWLayer:AddCollumn("ALL",100,.T.,"UP")
oFWLayer:AddWindow("ALL","oPanelUp","Lista de Contatos",100,.F.,.T.,,"UP",{ || })
oPanelUp := oFWLayer:GetWinPanel("ALL","oPanelUp","UP")
*/

oFWLayer:addLine("UP",90,.F.)
oFWLayer:AddCollumn("ALL",100,.F.,"UP")
oFWLayer:AddWindow("ALL","oPanelUp","Lista de Contatos",99,.F.,.T.,,"UP",{ || })
oPanelUp := oFWLayer:GetWinPanel("ALL","oPanelUp","UP")

DEFINE FWMBROWSE oMBrowseRight ALIAS "Z19" /*MENUDEF "XXXXXX" */NO DETAILS PROFILEID "1" OF oPanelUp

oMBrowseRight:AddLegend('Z19_STATUS=="1"',"GREEN" ,"Na periodicidade"    )
oMBrowseRight:AddLegend('Z19_STATUS=="2"',"BLUE" ,"Fora periodicidade"    )
oMBrowseRight:AddLegend('Z19_STATUS=="3"',"GRAY" ,"Sem ped. period."    )
oMBrowseRight:AddLegend('Z19_STATUS=="4"',"PINK" ,"Inativo"    )

oMBrowseRight:SetMenuDef( '' ) 
oMBrowseRight:AddStatusColumns({|| Status() }/*bStatus*/, {|| Legend() }/*bLDblClick*/)
oMBrowseRight:SetDoubleClick({|| ABRETMK(.F.) })

 //oMBrowseRight:SetUseFilter( .t. )

oMBrowseRight:AddFilter('TeleMesAno', "Z19_TELE='"+CTELE+"' .AND. Z19_MES='"+SUBSTR(DTOS(DDATABASE),5,2)+"' .AND. Z19_ANO='"+SUBSTR(DTOS(DDATABASE),1,4)+"'", .T., .T.)
oMBrowseRight:AddFilter('Status DTRet', "Z19_DTRET = Stod('') .AND. Z19_STATU2 = '1' ", .F., .T.)

/*
oMBrowseRight:AddFilter('TELE', "Z19_TELE='"+CTELE+"'", .t., .t.)
oMBrowseRight:AddFilter('MES', "Z19_MES='"+SUBSTR(DTOS(DDATABASE),5,2)+"'", .t., .t.)
oMBrowseRight:AddFilter('ANO', "Z19_ANO='"+SUBSTR(DTOS(DDATABASE),1,4)+"'", .t., .t.)
*/


ACTIVATE FWBROWSE oMBrowseRight

//-- Microsiga Browse da inferior
// oFWLayer:addLine("DOWN",45,.F.)
//oFWLayer:addLine("DOWN",30,.F.)
//oFWLayer:AddCollumn("LEFT",50,.T.,"DOWN")

//oFWLayer:AddWindow("LEFT","oPanelDown","Atendimentos Pendentes",100,.F.,.T.,,"DOWN",{ || })
//oFWLayer:AddWindow("LEFT","oPanelDown","Atendimentos Pendentes",70,.F.,.T.,,"DOWN",{ || })

//oPanelDown := oFWLayer:GetWinPanel("LEFT","oPanelDown","DOWN")
//oMBrowseRight:SetMenuDef( '' ) 
cQry:=PEDPEN()
If Select("TRUB") > 0
	TRUB->(DbCloseArea())
Endif
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TRUB", .F., .T.)

/*DEFINE FWBROWSE oMBrowseDown DATA TABLE ALIAS "TRUB"  OF oPanelDown
// ADD COLUMN oColumn DATA { || UA_OPER  } 				TITLE "Operador"     SIZE 5 OF oMBrowseDown   //rogerio 04/10
ADD COLUMN oColumn DATA { || UA_OPERADO  } 				TITLE "Operador"     SIZE 5 OF oMBrowseDown
ADD COLUMN oColumn DATA { || UA_NUM  } 					TITLE "Atendimento"  SIZE 5 OF oMBrowseDown
ADD COLUMN oColumn DATA { || DTOC(STOD(UA_EMISSAO))  } 	TITLE "Emissao"    	 SIZE 5 OF oMBrowseDown
ADD COLUMN oColumn DATA { || UA_VALBRUT  } 				TITLE "Valor"    	 SIZE 5 OF oMBrowseDown
ADD COLUMN oColumn DATA { || UA_CLIENTE  } 				TITLE "Cliente"    	 SIZE 5 OF oMBrowseDown
ADD COLUMN oColumn DATA { || UA_LOJA  } 				TITLE "Loja"    	 SIZE 5 OF oMBrowseDown

ACTIVATE FWBROWSE oMBrowseDown

oRelation := FWBrwRelation():New()
oRelation:AddRelation(oMBrowseRight,oMBrowseDown,{{"UA_CLIENTE","Z19_CLIENT"},{"UA_LOJA","Z19_LOJA"}})
oRelation:Activate() */


dbSelectArea('SA3')
DBSetOrder(1)
dbSeek(xFilial('SA3')+cTele)

//-- Microsiga Browse da inferior
cSql:=" SELECT R_E_C_N_O_ AS REGISTRO, Z20_FILIAL, Z20_RESP, Z20_DTRET, Z20_HRRET, Z20_CONTAT, Z20_CLIENT, Z20_LOJA, Z20_NOME, Z20_OBS, Z20_VEND, "
cSql+= "	Z20_EMISSA, Z20_HRLIG, Z20_OPERAD, Z20_MOTIVO, Z20_DTFIM, Z20_HRFIM, Z20_RESFIM, Z20_DPRES, Z20_NUM, Z20_SEQ, "
cSql+= " Z20_EMAILS, Z20_ATENDI, Z20_ANEXA, Z20_NRESP FROM "+RetSqlName('Z20')
cSql+=" WHERE (Z20_RESP ='"+cTele+"' OR Z20_DPRES ='"+SA3->A3_XDEPTO+"') "
cSql+=" AND Z20_DTFIM=''"
cSql+=" AND D_E_L_E_T_<>'*'"

//oFWLayer:AddCollumn("RIGHT",50,.T.,"DOWN")
//oFWLayer:AddWindow("RIGHT","oPanelDownL","Agenda Geral",100,.F.,.T.,,"DOWN",{ || })
//oFWLayer:AddWindow("RIGHT","oPanelDownL","Agenda Geral",70,.F.,.T.,,"DOWN",{ || })

//oPanelDownL := oFWLayer:GetWinPanel("RIGHT","oPanelDownL","DOWN")

If Select("TRUBX") > 0
	TRUBX->(DbCloseArea())
Endif
DbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRUBX", .F., .T.)

/*DEFINE FWBROWSE oMBrDownL DATA TABLE  ALIAS "TRUBX" OF oPanelDownL
ADD COLUMN oColumn DATA { || DTOC(STOD(Z20_DTRET))  } 		TITLE "Dt.Ret"    	     	SIZE 5 OF oMBrDownL
ADD COLUMN oColumn DATA { || Z20_HRRET  } 					TITLE "Hr.Ret"    	     	SIZE 5 OF oMBrDownL
ADD COLUMN oColumn DATA { || Z20_NRESP  } 					TITLE "NResp."    	     	SIZE 10 OF oMBrDownL
ADD COLUMN oColumn DATA { || Z20_NOME  } 					TITLE "NCliente"			SIZE 10 OF oMBrDownL
ADD COLUMN oColumn DATA { || Z20_OBS  } 					TITLE "Obs."    	     	SIZE 5 OF oMBrDownL
ADD COLUMN oColumn DATA { || DTOC(STOD(Z20_EMISSAO))  } 	TITLE "Emissão"    	 		SIZE 5 OF oMBrDownL
ADD COLUMN oColumn DATA { || Z20_HRLIG  } 					TITLE "Hr.Ligação"    	 	SIZE 7 OF oMBrDownL
ADD COLUMN oColumn DATA { || Z20_RESP  } 					TITLE "Resp"    	     	SIZE 5 OF oMBrDownL
// ADD COLUMN oColumn DATA { || Z20_OPERAD  } 					TITLE "Operador"    	    SIZE 5 OF oMBrDownL  Rogerio 25/09
// ADD COLUMN oColumn DATA { || Z20_VEND  } 					TITLE "Vendedor"    	    SIZE 5 OF oMBrDownL  Rogerio 25/09

oMBrDownL:SetFilterDefault("")
 


ACTIVATE FWBROWSE oMBrDownL  */


ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},,@aButtons) CENTERED

aRotina  := aRotbkp  // Rogerio 26/09

Return

Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title 'Visualizar' Action 'SENTAX_ATMK007' OPERATION 2 ACCESS 0
Return aRotina


Static Function Status()

Local cImgRPO := ""

If Z19->Z19_STATU2=='1'
	cImgRPO:="BR_MARROM"
ElseIF Z19->Z19_STATU2=='2'
	cImgRpo := "BR_VERDE"
ElseIF Z19->Z19_STATU2=='3'
	cImgRpo := "BR_VERMELHO"
ElseIF Z19->Z19_STATU2=='4'
	cImgRpo := "BR_AMARELO"
ElseIF Z19->Z19_STATU2=='5'
	cImgRpo := "BR_AZUL"
ElseIF Z19->Z19_STATU2=='6'
	cImgRpo := "BR_PINK"
ElseIF Z19->Z19_STATU2=='7'
	cImgRpo := "BR_BRANCO"
ElseIF Z19->Z19_STATU2=='8'
	cImgRpo := "BR_LARANJA"
EndIF

Return cImgRPO
//-------------------------------------------------------------------
/*/{Protheus.doc} Legend
MONTA A LEGENDA DE STATUS NA TELA DO BROWSE
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Legend()

// Array das Legendas
Local aLegenda := {	{"BR_MARROM"		, "Não Realizado"	 		}, ;
{"BR_VERDE"			, "Pedido"				 	}, ;
{"BR_VERMELHO"		, "Comprou concorrente"		}, ;
{"BR_AMARELO"		, "Comprou com vendedor"	}, ;
{"BR_AZUL"			, "Orçamento"				}, ;
{"BR_PINK"			, "Tem estoque"				}, ;
{"BR_BRANCO"		, "Outro motivo"			}, ;
{"BR_LARANJA"		, "Reagendado"				}}"


BrwLegenda("Satus","Legenda",aLegenda)

Return .T.


Static Function BuscaDados()

Local lRet:=.t.
cStat01:=""
cStat02:=""

// Retirado comentario da linha abaixo   Rogerio 20171011
//cFiltro:= " (Z19_STATU2 in('1','7')  or (Z19_STATU2  = 2 AND Z19_DTRET <> ''))" 

If lTst0101
	if Empty(cStat01)
		cStat01+=" AND (
	EndIF
	cStat01+= " Z19_STATUS ='1' "
EndIF
If lTst0102
	if Empty(cStat01)
		cStat01+=" AND (
	Else
		cStat01+=" or "
	EndIF
	cStat01+= " Z19_STATUS ='2' "
EndIF
If lTst0103
	if Empty(cStat01)
		cStat01+=" AND (
	Else
		cStat01+=" or "
	EndIF
	cStat01+= " Z19_STATUS ='3' "
EndIF
If lTst0104
	if Empty(cStat01)
		cStat01+=" AND (
	Else
		cStat01+=" or "
	EndIF
	cStat01+= " Z19_STATUS ='4' "
EndIF
if !Empty(cStat01)
	cStat01+=")"
EndIF

If lTst0201
	if Empty(cStat02)
		cStat02+=" AND (
	EndIF
	cStat02+= " Z19_STATU2 ='1' "
EndIF
If lTst0202
	if Empty(cStat02)
		cStat02+=" AND (
	Else
		cStat02+=" or "
	EndIF
	cStat02+= " (Z19_STATU2 ='2' OR Z19_DTRET <> '' )"
EndIF

If lTst0203
	if Empty(cStat02)
		cStat02+=" AND (
	Else
		cStat02+=" or "
	EndIF
	cStat02+= " (Z19_STATU2 ='3'   OR Z19_DTRET <> '')"
EndIF
If lTst0204
	if Empty(cStat02)
		cStat02+=" AND (
	Else
		cStat02+=" or "
	EndIF
	cStat02+= " (Z19_STATU2 ='4'   OR Z19_DTRET <> '')"
EndIF
If lTst0205
	if Empty(cStat02)
		cStat02+=" AND (
	Else
		cStat02+=" or "
	EndIF
	cStat02+= " (Z19_STATU2 ='5'  OR Z19_DTRET <> '')"
EndIF

If lTst0206
	if Empty(cStat02)
		cStat02+=" AND (
	Else
		cStat02+=" or "
	EndIF
	cStat02+= " (Z19_STATU2 ='6' OR Z19_DTRET <> '') "
EndIF
If lTst0207
	if Empty(cStat02)
		cStat02+=" AND (
	Else
		cStat02+=" or "
	EndIF
	cStat02+= " (Z19_STATU2 ='7' OR Z19_DTRET <> '')"
EndIF

If lTst0208
	if Empty(cStat02)
		cStat02+=" AND (
	Else
		cStat02+=" or "
	EndIF
	cStat02+= " (Z19_STATU2 ='8' OR Z19_DTRET <> '') "
EndIF

if !EmPty(cStat02)
	cStat02+=")"
EndIF

cQry:=" SELECT CASE "
cQry+=" WHEN Z19_PRIORI = '' THEN 'X'"
cQry+=" WHEN Z19_PRIORI <>'' THEN Z19_PRIORI"
cQry+=" END Z19_PRIORI,
//cQry+=" Z19_DTRET,Z19_HRRET,Z19_CLIENT,Z19_LOJA,Z19_NOMCLI,A1_DDD,A1_TEL,A1_NROCOM,Z19_CONTAT,Z19_UF,Z19_CIDADE,A3_NOME,Z19_ULTCOM,Z19_META,Z19_MEDIA,Z19_PEDMES,Z19_FATMES,Z19_DTFAT,Z19_EFICIE,Z19_POTEN,Z19_TELE,Z19_STATUS,Z19_STATU2,Z19_JUSTIF
cQry+=" Z19_DTRET,Z19_HRRET,Z19_CLIENT,Z19_LOJA,Z19_NOMCLI,A1_DDD,A1_TEL,A1_NROCOM,Z19_CONTAT,Z19_UF,Z19_CIDADE,A3_NOME,Z19_ULTCOM,Z19_META,Z19_MEDIA,Z19_PEDMES,Z19_FATMES,Z19_DTFAT,Z19_EFICIE,Z19_POTEN,Z19_TELE,Z19_STATUS,Z19_STATU2,Z19_JUSTIF


cQry+=" FROM "+RetSqlName('Z19')+" A"
cQry+=" INNER JOIN "+RetSqlName('SU7')+" B"
cQry+=" ON Z19_FILIAL = U7_FILIAL"
cQry+=" AND Z19_TELE = U7_COD"
cQry+=" INNER JOIN SA1010 SA1"
cQry+=" ON A1_COD = Z19_CLIENT ""
cQry+=" AND A1_FILIAL ='"+xFilial('SA1')+"'"
cQry+=" AND A1_LOJA  = Z19_LOJA"
cQry+=" AND SA1.D_E_L_E_T_<>'*'"
cQry+=" INNER JOIN SA3010 SA3"
cQry+=" ON A3_COD = Z19_VEND "
cQry+=" AND A.D_E_L_E_T_<>'*'"
cQry+=" WHERE A.D_E_L_E_T_<>'*'"
cQry+=" AND B.D_E_L_E_T_<>'*'"
cQry+=" AND U7_CODUSU='"+RetCodUsr()+"'"
cQry+=" AND	Z19_MES = '"+SUBSTR(DTOS(DDATABASE),5,2)+"' "
cQry+=" AND	Z19_ANO = '"+SUBSTR(DTOS(DDATABASE),1,4)+"' "
if !Empty(Cfiltro)
	cQry+=" and ("+cFiltro+")"
End

if !empty(cStat01)
	cQry+=cStat01
EndIF
if !empty(cStat02)
	cQry+=cStat02
EndIF
//cQry+=" ORDER BY PRIO, Z19_DTRET,Z19_STATUS "
IF Select('TRZ19')<> 0
	TRZ19->(DBCloseArea())
EndIF

TcQuery cQry new Alias "TRZ19"

IF TRZ19->(EOF())
	lRet:=.f.
EndIF

Return cQry

Static Function PEGASSTS1(cStatus)
cRet:=""

if cStatus=="1"
	cRet:=oGreen
elseif cStatus=="2"
	cRet:= oBlue
elseif cStatus=="3"
	cRet:=oGray
elseif cStatus=="4"
	cRet:=oPink
EndIF

Return cRet

Static Function GETSTS2(cStatus)
cRet:=""
If cStatus=='1'
	cRet := oBrown
ElseIF cStatus=='2'
	cRet := oGreen
ElseIF cStatus=='3'
	cImgRpo := oRed
ElseIF cStatus=='4'
	cRet := oYellow
ElseIF cStatus=='5'
	cRet := oBlue
ElseIF cStatus=='6'
	cRet := oPink
ElseIF cStatus=='7'
	cRet := oBranco
ElseIF cStatus=='8'
	cRet := oOrange
EndIF

Return cRet


Static Function ABRETMK(lRece)

Local cAlias:='SU5'
Local nReg	:= 0
Private lAltTpOper 	:= .T.										//Na inicializacao o DEFAULT e sempre TRUE
Private INCLUI := .t.
Private ALTERA := .t.
Private lTk271Auto  := .F.
Private lRecept:=lRece

Private cCadastro := "Cadastro de Atendimento"

// Rogerio 26/09
				aRotina		:= {  { "Pesquisar"  	,"AxPesqui"        ,0,1 },; 
							  { "Visualizar"		,"TK271CallCenter" ,0,2 },;
							  { "Incluir"	 	,"TK271CallCenter" ,0,3 },; 
							  { "Alterar"		,"TK271CallCenter" ,0,4 }}
// Rogerio			

RECLOCK('Z19',.F.)
Z19->Z19_DTINI := DDATABASE
MSUNLOCK()

cFilBkp:=cFilant
cFilAnt := ""
//Do While Empty(cFilAnt) //Nao sai da tela enquanto nao escolher uma filial
	cFilant := FWPesqSM0("M0_CODFIL",cEmpAnt) //Escolher a filial que deseja trabalhar
	if Empty(cFilant)
		cFilAnt :=cFilBkp
		return
	EndIF
//EndDo
MaReleTabPrc()

DbSelectArea("SU5")
DbSetOrder(1)
DbSeek(xFilial("SU5"))

DbSelectArea("SUC")
DbSetOrder(1)
DbSeek(xFilial("SUC"))

DbSelectArea("SUA")
DbSetOrder(1)
DbSeek(xFilial("SUA"))

DbSelectArea("ACF")
DbSetOrder(1)
DbSeek(xFilial("ACF"))

cCodCli:=Z19->Z19_CLIENT
cLojCli:=Z19->Z19_LOJA
// cContat:=Z19->Z19_CONTATO

// TK271CallCenter(	cAlias	,nReg ,3)

TK271CallCenter( cAlias	,nReg ,3, Nil, cCodCli, cLojCli, Nil ,'SA1' ,{},NIL,NIL,'' ) //,cContat, Nil,Nil,Nil )
// TK271CallCenter(cAlias,nReg,3,Nil,Z19->Z19_CLIENT,Z19->Z19_LOJA,'','SA1',{},NIL,NIL,'')  // Rogerio

nAt:=oMBrowseRight:At()
cQry:=buscadados()
oMBrowseRight:Data():Deactivate()
oMBrowseRight:SetQuery(cQry)
oMBrowseRight:Data():Activate()
oMBrowseRight:UpdateBrowse(.T.)
//oMBrowseRight:Refresh(.T.)


//EndIF
/*cFilant:=cFilBkp
oMBrowseRight:GoTo(1,.T.)
oMBrowseRight:Refresh(.T.)*/

Return

User Function ATMK007A()

Local cGet1 	:= "Define variable value" // Variavel do tipo caracter
Local nGet2 	:= 0 // Variável do tipo numérica
Local dGet3 	:= Date() // Variável do tipo Data
Local lHasButton := .T.
Local oFont 	:= TFont():New('Arial',,-12,.T.,.t.)
Local aRetorno	:= {'','S=Sim','N=Não'}
Local aPrior	:= {'','A','B'}
Local aStatus	:= {"","1=Não realizado no mês","2=Cliente fez pedido","3=Comprou com concorrente","4=Comprou com vendedor","5=Cliente fez orçamento","6=Estoque está em dia","7=Outro motivo","8=Reagendado"}

Local nLin  	:= 005
Local nCol  	:= 045
Local nCol2  	:= nCol+75
Local lRet		:= .F.
private cMail	:= space(100)
private dDtRet  := ctod('//')
private cPrior	:= ""
private cRetorno:= 'N'
private cStatus	:= ""
private cBody 	:= ""
private oDlgPr
private cAnexa	:= ""
Private cJust	:= space(200)
Private hRtRet	:= space(30)
  
IF SU7->U7_XLISTA<>'S'
	RETURN .T.
EndIf

if TkGetTipoAte() <> "2" .and. nFolder<> 2 // 2 - TELEVENDAS 
  	RETURN .T.  
EndIF

DEFINE MSDIALOG oDlgPr TITLE " " FROM 000, 000  TO 400, 550 COLORS 0, 16777215 PIXEL
 
//primeira linha
oSay1 := TSay():New( nLin,05,{||'Retorno'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
oCombo1 := TComboBox():New(nLin, nCol ,{|u|if(PCount()>0,cRetorno:=u,cRetorno)},aRetorno,70,20,oDlgPr,,{||},,,,.T.,,,,,,,,,'cRetorno')

oSay2 := TSay():New( nLin, nCol2,{||'Prioridade'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
oCombo2 := TComboBox():New(nLin, nCol2+70 ,{|u|if(PCount()>0,cPrior:=u,cPrior)},aPrior,70,20,oDlgPr,,{||},,,,.T.,,,,,,,,,'cPrior')

//segunda linha
nLin+=15
oSay3 := TSay():New( nLin,05,{||'Status'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
oCombo3 := TComboBox():New(nLin, nCol ,{|u|if(PCount()>0,cStatus:=u,cStatus)},aStatus,70,20,oDlgPr,,{||},,,,.T.,,,,,,,,,'cStatus')

oSay4 := TSay():New( nLin, nCol2,{||'Anexa CTRL+Y'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
oCombo4 := TComboBox():New(nLin, nCol2+70 ,{|u|if(PCount()>0,cAnexa:=u,cAnexa)},aRetorno,70,20,oDlgPr,,{||},,,,.T.,,,,,,,,,'cAnexa')

//TERCEIRA LINHA
nLin+=15
oSay5 := TSay():New( nLin,05,{||'Data Retorno'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
oGet1 := TGet():New( nLin, nCol, { | u | If( PCount() == 0, dDtRet, dDtRet := u ) },oDlgPr, 070, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtRet",,,,lHasButton  )

oSay6 := TSay():New( nLin, nCol2,{||'Hora Retorno'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
oGet2 := TGet():New( nLin, nCol2+70, { | u | If( PCount() == 0, hRtRet, hRtRet := u ) },oDlgPr, 070, 010, "@R 99:99",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"hRtRet",,,,lHasButton  )

nLin+=15
oSay7 := TSay():New( nLin,05,{||'Texto do e-mail para o vendedor'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

nLin+=15
oTMultiget1 := tMultiget():new( nLin, 005, {| u | if( pCount() > 0, cBody := u, cBody ) },  oDlgPr, 260, 92, , , , , , .T. )
nLin+=100
oSay8 := TSay():New( nLin,  005, {||'E-Mail CC'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
//oGet1 := TGet():New( nLin, nCol, { | u | If( PCount() == 0, cMail, cMail := u ) },oDlgPr,220, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMail",,,,lHasButton  )
oGet3 := TGet():New( nLin, nCol, { | u | If( PCount() == 0, cMail, cMail := u ) },oDlgPr, 220, 010,,, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMail",,,,lHasButton  )

nLin+=20
oTButton1 := TButton():New( nLin, nCol+30, "Confirmar",oDlgPr,{||lRet:=grvprio()}, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. ) 
oTButton2 := TButton():New( nLin, nCol2+30, "Cancelar",oDlgPr,{||lRet:=.f.,oDlgPr:END()}, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. ) 

ACTIVATE MSDIALOG oDlgPr CENTERED

return lRet

Static Function grvprio(lRet)

Private cpara := ""

IF cStatus == '7'
	telJust()
EndIF
if cRetorno=="S"
	if empty(cPrior)
	    alert("Obrigatorio preencher a Prioridade.")
		Return .f.
	EndIF
	If empty(dDtRet)
		alert("Obrigatorio preencher a data de retorno.")
		Return .f.
	EndIF
	If empty(hRtRet)
		alert("Obrigatorio preencher a hora de retorno.")
		Return .f.
	EndIF
EndIF

if  empty(cStatus)
	alert("Obrigatorio preencher o Status.")
	Return .f.
EndIF
lTele:=.F.

DbSelectArea('SU7')
DbSetOrder(1)
DbSeek(xFilial('SU7')+Z19->Z19_TELE)
if SU7->U7_CODVEN == M->UA_VEND2
	lTele:=.t.
EndIf

Z19->(DBSelectArea('Z19'))
Z19->(DBSetOrder(1))
If Z19->(dbSeek(xFilial('Z19')+SUBSTR(DTOS(DDATABASE),5,2)+SUBSTR(DTOS(DDATABASE),1,4)+M->UA_CLIENTE+M->UA_LOJA))
	Reclock('Z19',.F.)
	Z19->Z19_RET 	:= cRetorno
	Z19->Z19_PRIORI	:= cPrior
	Z19->Z19_STATU2	:= cStatus
	
	Z19->Z19_NUMATE:= ALLTRIM(Z19->Z19_NUMATEN)+IF(EMPTY(Z19->Z19_NUMATEN),"","|")+M->UA_NUM
	Z19->Z19_DTRET	:= dDtRet
	Z19->Z19_HRRET	:= transform(hRtRet,"@R 99:99")
	
	MsUnlock()
Endif

if ltele
	M->UA_XLIST := Z19->Z19_MES+Z19->Z19_ANO
EndIF

dbSelectArea('SA3')
DBSetOrder(1)
dbSeek(xFilial('SA3')+M->UA_VEND)

cpara:=UsrRetMail ( SU7->U7_CODUSU)
cpara+=";"+UsrRetMail ( SA3->A3_CODUSR)
cpara+=';'+ cMail
DBSelectArea('Z20')

Z20->(RECLOCK('Z20',.T.))
Z20->Z20_FILIAL 	:= xFilial('Z20')
Z20->Z20_NUM		:= GetSXENum("Z20","Z20_NUM")
Z20->Z20_SEQ		:= "001"
Z20->Z20_EMISSAO	:= DDATABASE
Z20->Z20_HRLIG 		:= TIME()
Z20->Z20_CLIENT  	:= M->UA_CLIENTE
Z20->Z20_LOJA 		:= M->UA_LOJA
Z20->Z20_NOME	 	:= M->UA_DESCCLI

// Z20->Z20_RESP 		:= M->UA_VEND  Rogerio 25/09
// Z20->Z20_RESP 		:= SU7->U7_CODUSU

// Z20->Z20_RESP 		:= SU7->U7_CODUSU rOGERIO 05/10
Z20->Z20_RESP 		:= SU7->U7_COD
Z20->Z20_NRESP      := SU7->U7_NREDUZ

Z20->Z20_VEND 		:= M->UA_VEND
Z20->Z20_DTRET 		:= dDtRet
Z20->Z20_HRRET 		:= hRtRet
Z20->Z20_OPERAD 	:= Z19->Z19_TELE
Z20->Z20_OBS 		:= cBody
Z20->Z20_EMAILS		:= cpara
Z20->Z20_ATENDI		:= M->UA_NUM
Z20->Z20_ANEXA		:= cAnexa

// Z20->Z20_NRESP		:= POSICIONE('SA3',1,xFilial('SA3')+M->UA_VEND,'A3_NOME') Rogerio 25/09
Z20->Z20_NRESP		:= SU7->U7_NREDUZ

Z20->Z20_DPRES 		:= SA3->A3_XDEPTO //(dpto do responsável Z02_RESP).
/*Z20->Z20_DTFIM = ctod
Z20->Z20_HRFIM = “”
Z20->Z20_MOTIVO = “”
Z20->Z20_TXBX = “” */
Z20->(MsUnlock())
ConfirmSX8()
//If !Empty(cBody) //ENVIAR E-MAIL
	//envio de email
	cPara	:= SA3->A3_EMAIL+IIF(!Empty(cMail),';'+alltrim(cMail),"")
	cAssunto:=	"Atendimento ao Cliente"
	//cBody	:=	"teste"
	cAnexo:=""
	cBody:=montaHtml()
	
	U_SendMail(cPara,cAssunto,cBody,cAnexo)
//EndIf

oDlgPr:END()

Return .T.



User Function SendMail(cTo,cAssunto,cBody,cAnexo)

Local cServer    := GETMV("MV_RELSERV")
Local cAccount   := GETMV("MV_RELACNT")
Local cPassword  := GETMV("MV_RELPSW")
Local lAutentica := GETMV("MV_RELAUTH")
Local cFrom      := GETMV("MV_RELFROM")
Local cEnvia     := GETMV("MV_RELACNT")


cMsg := cBody

//lRet:=ACSendMail(cEnvia,cPassword,cServer,cEnvia,cTo,cAssunto,cMsg,''/*ANEXO*/,.T.)

lRet := EnvMail(cAccount,cPassword,cServer,cFrom,cTo,cAssunto,cBody,cAnexo)
					

Return lRet

Static Function montaHtml()
Local nFor
Local cLink 		 := supergetmv('MV_CAMWF',,'http://192.168.0.9:8099/U_ATMK008.APW')

cHtml:=' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cHtml+=' <html xmlns="http://www.w3.org/1999/xhtml">'
cHtml+=' <head>'
cHtml+=' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
cHtml+=' <title>Untitled Document</title>'
cHtml+=' <style type="text/css">'
cHtml+=' 	#TITULOS {'
cHtml+=' 		color: #CCC;'
cHtml+=' 	}'
cHtml+=' 	.tit {'
cHtml+=' 		color: #CCC;'
cHtml+=' 	}'
cHtml+=' 	.TAB {'
cHtml+=' 		border: thin solid #333;'
cHtml+=' 	}'
cHtml+=' 	.TAB2 {'
cHtml+=' 		font-size: 12px;'
cHtml+=' 		color: #FFF;'
cHtml+=' 	}'
cHtml+=' 	'
cHtml+=' 	.botao01{'
cHtml+='       background: -webkit-linear-gradient(bottom, #E0E0E0, #F9F9F9 70%);'
cHtml+='       background: -moz-linear-gradient(bottom, #E0E0E0, #F9F9F9 70%);'
cHtml+='       background: -o-linear-gradient(bottom, #E0E0E0, #F9F9F9 70%);'
cHtml+='       background: -ms-linear-gradient(bottom, #E0E0E0, #F9F9F9 70%);'
cHtml+='       background: linear-gradient(bottom, #E0E0E0, #F9F9F9 70%);'
cHtml+='       border: 1px solid #CCCCCE;'
cHtml+='       border-radius: 3px;'
cHtml+='       box-shadow: 0 3px 0 rgba(0, 0, 0, .3),'
cHtml+='                     0 2px 7px rgba(0, 0, 0, 0.2);'
cHtml+='       color: #616165;'
cHtml+='       '
cHtml+='       font-family: "Trebuchet MS";'
cHtml+='       font-size: 14px;'
cHtml+='       font-weight: bold;'
cHtml+='       line-height: 25px;'
cHtml+='       text-align: center;'
cHtml+='       text-decoration: none;'
cHtml+='       text-transform: uppercase;'
cHtml+='       text-shadow:1px 1px 0 #FFF;'
cHtml+='       padding: 5px 15px;'
cHtml+='       position: relative;'
cHtml+='       width: 80px;'
cHtml+='  	 display: inline-block !important;'
cHtml+='  	 margin-left: 170px;'
cHtml+='      }'
cHtml+=' '
cHtml+=' </style>'
cHtml+=' </head>'
cHtml+=' '
cHtml+=' <body>'
cHtml+=' <table width="100%" border="1" class="TAB">'
cHtml+='   <tr>'
cHtml+='     <td align="center" bgcolor="#000099" class="tit"><strong>RECADOS TELEVENDAS</strong></td>'
cHtml+='   </tr>'
cHtml+='   <tr>'
cHtml+='     <td><table width="100%" border="0">'
cHtml+='       <tr>'
cHtml+='         <td width="3%">Tele:</td>'
cHtml+='         <td width="7%"><strong>'+SU7->U7_NOME+'</strong></td>'
cHtml+='         <td width="5%">Data:</td>'
cHtml+='         <td width="10%"><strong>'+DTOC(DDATABASE)+'</strong></td>'
cHtml+='         <td width="10%">Atendimento:</td>'
cHtml+='         <td width="7%"><strong>'+M->UA_NUM+'</strong></td>'
cHtml+='         <td width="6%">Cliente:</td>'
cHtml+='         <td width="52%"><strong>'+M->UA_CLIENTE+"/"+M->UA_LOJA+" - "+TkDCliente(M->UA_CLIENTE,M->UA_LOJA)+'</strong></td>'
cHtml+='       </tr>'
cHtml+='     </table></td>'
cHtml+='   </tr>'
cHtml+='   <tr>'
cHtml+='     <td align="center"><strong>MENSAGEM</strong></td>'
cHtml+='   </tr>'
cHtml+='   <tr>'
cHtml+='     <td align="center">'+cBody+'</td>'
cHtml+='   </tr>'
If cAnexa =='S'
	
	cHtml+='   <tr>'
	cHtml+='     <td align="center"><strong>HISTÓRICO DE COMPRAS DO CLIENTE</strong></td>'
	cHtml+='   </tr>'
	cHtml+='   <tr>'
	cHtml+='     <td><table width="100%" border="1">'
	cHtml+='       <tr bgcolor="#000099" class="TAB2">'
	cHtml+='         <td width="4%" class="TAB2"><strong>FILIAL</strong></td>'
	cHtml+='         <td width="13%" class="tit"><strong class="TAB2">PRODUTO</strong></td>'
	cHtml+='         <td width="22%"><strong>DESCRIÇÃO</strong></td>'
	cHtml+='         <td width="10%"><strong>ULT.COMPRA</strong></td>'
	cHtml+='         <td width="6%">QUANT.</td>'
	cHtml+='         <td width="6%">PERIOD.</td>'
	cHtml+='         <td width="10%" align="center" bgcolor="#000099">$ ULT.VENDA</td>'
	cHtml+='         <td width="5%" align="center" bgcolor="#000099">PRECO OTIMO</td>'
	cHtml+='         <td width="6%" align="center" bgcolor="#000099">ULTIMA VENDA</td>'
	cHtml+='         <td width="6%" align="center" bgcolor="#000099">QTDE ITENS FAT</td>'
	cHtml+='         <td width="7%">TENDENCIA MENOR PREÇO</td>'
	cHtml+='         <td width="5%">TABELA</td>'
	cHtml+='       </tr>'
	aProd:=fMontaQry()
	
	for nFor:=1 to len(aprod)
		cHtml+='   <tr>'
		cHtml+='     <td>'+aprod[nFor][2]+'</td>'
		cHtml+='     <td>'+aprod[nFor][3]+'</td>'
		cHtml+='     <td>'+aprod[nFor][4]+'</td>'
		cHtml+='     <td>'+aprod[nFor][5]+'</td>'
		cHtml+='     <td>'+TRANSFORM(aprod[nFor][6],'@E 999,999,999.99')+'</td>'
		cHtml+='     <td>'+TRANSFORM(aprod[nFor][7],'@E 999,999,999.99')+'</td>'
		cHtml+='     <td>'+TRANSFORM(aprod[nFor][8],'@E 999,999,999.99')+'</td>'
		cHtml+='     <td>'+TRANSFORM(aprod[nFor][9],'@E 999,999,999.99')+'</td>'
		cHtml+='     <td>'+TRANSFORM(aprod[nFor][10],'@E 999,999,99.,99')+'</td>'
		cHtml+='     <td>'+aprod[nFor][11]+'</td>'
		cHtml+='     <td>'+TRANSFORM(aprod[nFor][12],'@E 999,999,999.99')+'</td>'
		cHtml+='     <td>'+aprod[nFor][13]+'</td>'
		cHtml+='   </tr>
	Next
eNDif
/*cHtml+='       <tr>'+chr(13)+chr(10)
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='         <td>&nbsp;</td>'
cHtml+='       </tr>'
*/


cHtml+='     </table></td>'
cHtml+='   </tr>'
cHtml+='   <tr>'
cHtml+='     <td><table width="100%" border="0" align="center">'
cHtml+='       <tr>'
cHtml+='         <td align="center"><a href="'+cLink+'?ckey='+embaralha("23912"+cvaltochar(Z20->(recno())) ,0)+'" class="botao01" id="apr" >Responder</a></td>'
cHtml+='       </tr>'
cHtml+='     </table></td>'
cHtml+='   </tr>'
cHtml+=' </table>'
cHtml+=' </body>'
cHtml+=' </html>'



Return cHtml

Static Function fMontaQry()
Local cQry 		:= ""
Local cFiltro1	:= ""
Local cFiltro2	:= ""
Local cFiltro3	:= ""
Local cFiltro4	:= ""
Local cFiltro5	:= ""
Local cFiltro6	:= ""
Local cCodCont	:= ""
Local dDtIni	:= ddatabase-365
Local dDtFim	:= ddatabase

Local nTendMenor := 0
Local nTendMaior := 0
Local cTendMenor := 0
Local cTendMaior := 0
Local nPerComp   := 0
Local aColsTmp	 := {}
Private cParCfop	:= GetMV("ST_TMKCFVE",,"")
Private cParComo	:= GetMV("ST_TMKCFCO",,"")
nItem:=0
cQry := " SELECT DISTINCT D.D2_FILIAL, D.D2_COD, B1_DESC, A1_NROCOM, D.D2_EMISSAO, DMIN, E.D2_PRCVEN, TOTAL_NOTAS, TOTAL_ITENS, 'N' TIPO_C_N "+chr(13)+chr(10)
cQry += " FROM (	SELECT D2_FILIAL, D2_COD, MAX(MAX) D2_EMISSAO, MAX(MIN) DMIN, SUM(TOT_NOTAS) TOTAL_NOTAS, Sum(TOT_ITENS) TOTAL_ITENS "+chr(13)+chr(10)
cQry += " 		FROM (	SELECT D2_FILIAL, D2_COD, MAX(D2_EMISSAO) MAX, '' MIN, COUNT(*) TOT_NOTAS, Sum(D2_QUANT) TOT_ITENS "+chr(13)+chr(10)
cQry += " 				FROM "+RetSQLName("SD2")+" A "+chr(13)+chr(10)
cQry += " 				WHERE D2_CLIENTE = '"+M->UA_CLIENTE+"' "+chr(13)+chr(10)
cQry += " 					AND D2_LOJA = '"+M->UA_LOJA+"' "+chr(13)+chr(10)
If !Empty(cParCfop)
	cQry += " 					AND D2_CF IN ('"+cParCfop+"') "+chr(13)+chr(10)
EndIf
cQry += " 					AND A.D2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"' "+chr(13)+chr(10)
cQry += " 					AND A.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
cQry += " 				GROUP BY D2_FILIAL, D2_COD "+chr(13)+chr(10)
cQry += " 				UNION ALL "+chr(13)+chr(10)
cQry += " 				SELECT D2_FILIAL, D2_COD, '' MAX, MIN(D2_EMISSAO) MIN, 0 TOT_NOTAS, 0 TOT_ITENS "+chr(13)+chr(10)
cQry += " 				FROM "+RetSQLName("SD2")+" B "+chr(13)+chr(10)
cQry += " 				WHERE D2_CLIENTE = '"+M->UA_CLIENTE+"' "+chr(13)+chr(10)
cQry += " 					AND D2_LOJA = '"+M->UA_LOJA+"' "+chr(13)+chr(10)
If !Empty(cParCfop)
	//	cQry += " 					AND D2_CF IN ('"+cParCfop+"') "+chr(13)+chr(10)
EndIf
cQry += " 					AND DATEDIFF (MONTH,D2_EMISSAO,'"+DtoS(dDataBase)+"') <= "+cValToChar(dDataBase-365)+" "+chr(13)+chr(10)
cQry += " 					AND B.D2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"' "+chr(13)+chr(10)
cQry += " 					AND B.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
cQry += " 				GROUP BY D2_FILIAL, D2_COD) AS C "+chr(13)+chr(10)
cQry += " 		GROUP BY D2_FILIAL, D2_COD) AS D "+chr(13)+chr(10)
cQry += " LEFT JOIN "+RetSQLName("SD2")+" E ON E.D2_FILIAL = D.D2_FILIAL AND E.D2_COD = D.D2_COD AND E.D2_EMISSAO = D.D2_EMISSAO "+;
"AND E.D2_CLIENTE = '"+M->UA_CLIENTE+"' AND E.D2_LOJA = '"+M->UA_LOJA+"' AND E.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = D.D2_COD AND SB1.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
cQry += " LEFT JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = '"+M->UA_CLIENTE+"' AND A1_LOJA = '"+M->UA_LOJA+"' AND SB1.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)

cQry += " UNION ALL "+chr(13)+chr(10)

cQry += " SELECT DISTINCT D.D2_FILIAL, D.D2_COD, B1_DESC, A1_NROCOM, D.D2_EMISSAO, DMIN, E.D2_PRCVEN, TOTAL_NOTAS, TOTAL_ITENS, 'C' TIPO_C_N "+chr(13)+chr(10)
cQry += " FROM (	SELECT D2_FILIAL, D2_COD, MAX(MAX) D2_EMISSAO, MAX(MIN) DMIN, SUM(TOT_NOTAS) TOTAL_NOTAS, Sum(TOT_ITENS) TOTAL_ITENS "+chr(13)+chr(10)
cQry += " 		FROM (	SELECT D2_FILIAL, D2_COD, MAX(D2_EMISSAO) MAX, '' MIN, COUNT(*) TOT_NOTAS, Sum(D2_QUANT) TOT_ITENS "+chr(13)+chr(10)
cQry += " 				FROM "+RetSQLName("SD2")+" A "+chr(13)+chr(10)
cQry += " 				WHERE D2_CLIENTE = '"+M->UA_CLIENTE+"' "+chr(13)+chr(10)
cQry += " 					AND D2_LOJA = '"+M->UA_LOJA+"' "+chr(13)+chr(10)
If !Empty(cParComo)
	//	cQry += " 					AND D2_CF IN ('"+cParComo+"') "+chr(13)+chr(10)
EndIf
cQry += " 					AND A.D2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"' "+chr(13)+chr(10)
cQry += " 					AND A.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
cQry += " 				GROUP BY D2_FILIAL, D2_COD "+chr(13)+chr(10)
cQry += " 				UNION ALL "+chr(13)+chr(10)
cQry += " 				SELECT D2_FILIAL, D2_COD, '' MAX, MIN(D2_EMISSAO) MIN, 0 TOT_NOTAS, 0 TOT_ITENS "+chr(13)+chr(10)
cQry += " 				FROM "+RetSQLName("SD2")+" B "+chr(13)+chr(10)
cQry += " 				WHERE D2_CLIENTE = '"+M->UA_CLIENTE+"' "+chr(13)+chr(10)
cQry += " 					AND D2_LOJA = '"+M->UA_LOJA+"' "+chr(13)+chr(10)
If !Empty(cParComo)
	//cQry += " 					AND D2_CF IN ('"+cParComo+"') "+chr(13)+chr(10)
EndIf
cQry += " 					AND DATEDIFF (MONTH,D2_EMISSAO,'"+DtoS(dDataBase)+"') <= "+cValToChar(ddatabase-365)+" "+chr(13)+chr(10)
cQry += " 					AND B.D2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"' "+chr(13)+chr(10)
cQry += " 					AND B.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
cQry += " 				GROUP BY D2_FILIAL, D2_COD) AS C "+chr(13)+chr(10)
cQry += " 		GROUP BY D2_FILIAL, D2_COD) AS D "+chr(13)+chr(10)
cQry += " LEFT JOIN "+RetSQLName("SD2")+" E ON E.D2_FILIAL = D.D2_FILIAL AND E.D2_COD = D.D2_COD AND E.D2_EMISSAO = D.D2_EMISSAO "+;
"AND E.D2_CLIENTE = '"+M->UA_CLIENTE+"' AND E.D2_LOJA = '"+M->UA_LOJA+"' AND E.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = D.D2_COD AND SB1.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
cQry += " LEFT JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = '"+M->UA_CLIENTE+"' AND A1_LOJA = '"+M->UA_LOJA+"' AND SB1.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)

cQry += " ORDER BY D.D2_EMISSAO DESC, D.D2_FILIAL, D.D2_COD "+chr(13)+chr(10)

IF Select('QPER')<>0
	QPER->(DBCloseArea())
EndIf
TCQuery cQry New Alias "QPER"

QPER->(DbGoTop())

If QPER->(!Eof())
	
	While QPER->(!Eof())
		
		fBuscaPreco( QPER->D2_COD, QPER->D2_PRCVEN, @nTendMenor, @nTendMaior, @cTendMenor, @cTendMaior )
		
		If !Empty(QPER->D2_EMISSAO) .AND. !Empty(QPER->DMIN)
			nPerComp := Int( (StoD(QPER->D2_EMISSAO)-StoD(QPER->DMIN)) / (QPER->TOTAL_NOTAS - 1) )
		Else
			nPerComp := 0
		EndIf
		
		nItem++
		aAdd(aColsTmp,Array(15))
		
		aColsTmp[nItem][1]  := ""
		aColsTmp[nItem][2]  := QPER->D2_FILIAL
		aColsTmp[nItem][3]  := QPER->D2_COD
		aColsTmp[nItem][4]  := QPER->B1_DESC
		aColsTmp[nItem][5]  := dtoc(StoD(QPER->D2_EMISSAO))	// Ultima Compra)
		aColsTmp[nItem][6]  := 0				   	   	// Quantidade
		aColsTmp[nItem][7]  := nPerComp
		aColsTmp[nItem][8]  := QPER->D2_PRCVEN 			// Alltrim(Transform(QPER->PRECO,PesqPict("SD2","D2_TOTAL")))
		aColsTmp[nItem][9]  := QPER->TOTAL_ITENS   	   	// Quantidade
		aColsTmp[nItem][10]  := nTendMenor
		aColsTmp[nItem][11] := IIF(Empty(cTendMenor),"n/a",cTendMenor)
		aColsTmp[nItem][12] := nTendMaior
		aColsTmp[nItem][13] := IIF(Empty(cTendMaior),"n/a",cTendMaior)
		aColsTmp[nItem][14] := QPER->TIPO_C_N
		aColsTmp[nItem][15] := .F.
		
		QPER->(DbSkip())
	EndDo
EndIf

Return aColsTmp

Static Function fBuscaPreco( cCodPro, nValPreco, nTMenor, nTMaior, cTMenor, cTMaior )

Local cQuery 	:= ""
Local cTabPar	:= GetMV("ST_TABPRC",,"")
Local aTabPar	:= {}
Local nK  		:= 0

If !Empty(cTabPar)
	aTabPar := Separa(cTabPar,';',.F.)
	cTabPar := ""
	For nK := 1 to Len(aTabPar)
		cTabPar += IIF(Empty(cTabPar),"","','")+aTabPar[nK]
	Next nK
EndIf

If (Select("QPRC") <> 0)
	DbSelectArea("QPRC")
	QPRC->(DbCloseArea())
Endif

cQuery += " SELECT TIPO, DA0_CODTAB, DA0_DESCRI, PRCMENOR, PRCMAIOR "
cQuery += " FROM (	SELECT TOP 1 'MENOR' TIPO, DA0_CODTAB, DA0_DESCRI, DA1_PRCVEN PRCMENOR, 0 PRCMAIOR "
cQuery += " 		FROM "+RetSQLName("DA1")+" DA1 "
cQuery += " 		INNER JOIN "+RetSQLName("DA0")+" DA0 ON DA1_CODTAB = DA0_CODTAB AND DA0_ATIVO = '1' "
cQuery += " 			AND DA0_DATDE <= '"+DtoS(dDataBase)+"' AND DA0_DATATE >= '"+DtoS(dDataBase)+"' "
If !Empty(cTabPar)
	cQuery += " 			AND DA0_CODTAB IN ('"+cTabPar+"') "
EndIf
cQuery += " 			AND DA0.D_E_L_E_T_ <> '*' "
cQuery += " 		WHERE DA1_CODPRO = '"+cCodPro+"' "
cQuery += " 			AND DA1_PRCVEN < "+cValToChar(nValPreco)+" "
cQuery += " 			AND DA1.D_E_L_E_T_ <> '*' "
cQuery += " 		ORDER BY PRCMENOR DESC) AS A "
cQuery += " UNION ALL "
cQuery += " SELECT TIPO, DA0_CODTAB, DA0_DESCRI, PRCMENOR, PRCMAIOR "
cQuery += " FROM (	SELECT TOP 1 'MAIOR' TIPO, DA0_CODTAB, DA0_DESCRI, 0 PRCMENOR, DA1_PRCVEN PRCMAIOR "
cQuery += " 		FROM "+RetSQLName("DA1")+" DA1 "
cQuery += " 		INNER JOIN "+RetSQLName("DA0")+" DA0 ON DA1_CODTAB = DA0_CODTAB AND DA0_ATIVO = '1' "
cQuery += " 			AND DA0_DATDE <= '"+DtoS(dDataBase)+"' AND DA0_DATATE >= '"+DtoS(dDataBase)+"' "
If !Empty(cTabPar)
	cQuery += " 			AND DA0_CODTAB IN ('"+cTabPar+"') "
EndIf
cQuery += " 			AND DA0.D_E_L_E_T_ <> '*' "
cQuery += " 		WHERE DA1_CODPRO = '"+cCodPro+"' "
cQuery += " 			AND DA1_PRCVEN > "+cValToChar(nValPreco)+" "
cQuery += " 			AND DA1.D_E_L_E_T_ <> '*' "
cQuery += " 		ORDER BY PRCMENOR) AS A "

TCQuery cQuery new Alias "QPRC"

nTMenor := 0
cTMenor := ""
nTMaior := 0
cTMaior := ""

QPRC->(DbGoTop())

If QPRC->(!Eof())
	While QPRC->(!Eof())
		If AllTrim(QPRC->TIPO) == "MENOR"
			//cPrcMenor := "["+Alltrim(QPRC->DA0_CODTAB) + "-"+ Alltrim(QPRC->DA0_DESCRI) + "] " + cValToChar(QPRC->PRCMENOR)
			nTMenor := QPRC->PRCMENOR
			cTMenor := 	Alltrim(QPRC->DA0_DESCRI)
		ElseIf AllTrim(QPRC->TIPO) == "MAIOR"
			//cPrcMaior := cValToChar(QPRC->PRCMAIOR) + " [" + Alltrim(QPRC->DA0_CODTAB) + "-"+ Alltrim(QPRC->DA0_DESCRI) + "]"
			nTMaior := QPRC->PRCMAIOR
			cTMaior := Alltrim(QPRC->DA0_DESCRI)
		EndIf
		QPRC->(DbSkip())
	EndDo
	QPRC->(DbCloseArea())
EndIf

Return

STATIC FUNCTION PEDPEN()
dDtIni:=ddatabase-30
// cQry:=" SELECT * FROM "+RetSqlName('SUA')    // Rogerio 04/10/2017
cQry:=" SELECT UA_OPERADO,UA_NUM,UA_EMISSAO,UA_VALBRUT, UA_CLIENTE, UA_LOJA FROM "+RetSqlName('SUA')
cQry+=" WHERE UA_EMISSAO >= '" + dtos(dDtIni) + "'"
cQry+=" AND	UA_DOC =''"
cQry+=" AND	UA_STATUS not in ('CANC','NF')"
cQry+=" AND	UA_DTLIM >= '"+dtos(dDatabase)+"'"
cQry+=" AND	UA_OPERADO = '"+cTele+"'"    // ROGERIO 04/10/2017
cQry+=" AND	D_E_L_E_T_<>'*' "
Return cQry

//------------------------------------------------------------------------

STATIC FUNCTION PEDZ19()

cQry:=" SELECT * FROM "+RetSqlName('Z19')
cQry+=" WHERE Z19_TELE = '" + CTELE + "'"
cQry+=" AND	Z19_MES = '" + SUBSTR(DTOS(DDATABASE),5,2) + "'"
cQry+=" AND	Z19_ANO = '" + SUBSTR(DTOS(DDATABASE),1,4) + "'"
cQry+=" AND	D_E_L_E_T_<>'*' "

Return cQry


Static Function veLeg()
Local nY       				:= 0
Local nX       				:= 0
Local oDlgLeg
Local aBmp[8]

DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (8*20)+50,320 TITLE "Legenda"  PIXEL

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 11,00 TO 013,400 LABEL '' OF oDlgLeg PIXEL
@ 03,05 SAY 'Legendas' OF oDlgLeg PIXEL SIZE 100,009 FONT oBold

nlin:=20
oTBitmap1 := TBitmap():New(nlin,05,260,184,,"BR_VERDE"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,15 SAY "Na Periodicidade" OF oDlgLeg PIXEL

oTBitmap1 := TBitmap():New(nlin,70,260,184,,"BR_MARROM"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,80 SAY "Não Realizado" OF oDlgLeg PIXEL

nlin+=10
oTBitmap1 := TBitmap():New(nlin,05,260,184,,"BR_AZUL"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,15 SAY "Fora Periodicidade" OF oDlgLeg PIXEL
oTBitmap1 := TBitmap():New(nlin,70,260,184,,"BR_VERDE"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,80 SAY "Pedido" OF oDlgLeg PIXEL
nlin+=10
oTBitmap1 := TBitmap():New(nlin,05,260,184,,"BR_CINZA"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,15 SAY "Sem ped. period." OF oDlgLeg PIXEL
oTBitmap1 := TBitmap():New(nlin,70,260,184,,"BR_VERMELHO"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,80 SAY "Comprou concorrente" OF oDlgLeg PIXEL
nlin+=10
oTBitmap1 := TBitmap():New(nlin,05,260,184,,"BR_PINK"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,15 SAY "Inativo" OF oDlgLeg PIXEL
oTBitmap1 := TBitmap():New(nlin,70,260,184,,"BR_AMARELO"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,80 SAY "Comprou com vendedor" OF oDlgLeg PIXEL

nLin += 10
oTBitmap1 := TBitmap():New(nlin,70,260,184,,"BR_AZUL"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,80 SAY "Orçamento" OF oDlgLeg PIXEL

nLin += 10
oTBitmap1 := TBitmap():New(nlin,70,260,184,,"BR_PINK"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,80 SAY "Tem estoque" OF oDlgLeg PIXEL

nLin += 10
oTBitmap1 := TBitmap():New(nlin,70,260,184,,"BR_BRANCO"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,80 SAY "Outro motivo" OF oDlgLeg PIXEL

nLin += 10
oTBitmap1 := TBitmap():New(nlin,70,260,184,,"BR_LARANJA"	,.T.,oDlgLeg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
@ nlin,80 SAY "Reagendado" OF oDlgLeg PIXEL

ACTIVATE MSDIALOG oDlgLeg CENTERED

return

Static Function veMtxRe()
Local nY       				:= 0
Local nX       				:= 0
Local oDlgLeg
Local aBmp[8]
Local oFont 		:= TFont():New('Arial',,-12,.T.,.t.)


cQry:=" SELECT Z19_MES,Z19_ANO, SUM(Z19_META)META, SUM(Z19_FATMES) FAT,SUM(Z19_PEDMES) PEDIDO, "

cQry+=" 		(	SELECT ISNULL(CT_VALOR,0) "
cQry+=" 			 FROM SCT010 SCT "
cQry+=" 			 INNER JOIN SU7010 SU7 ON SU7.D_E_L_E_T_<>'*' AND SU7.U7_CODUSU ='"+RetCodUsr()+"' AND SCT.CT_VEND = SU7.U7_CODVEN "
cQry+=" 			 WHERE SCT.D_E_L_E_T_ = '') AS CT_VALOR "

cQry+=" FROM "+RetSqlName('Z19')+" A"
cQry+=" INNER JOIN "+RetSqlName('SU7')+" B ON Z19_FILIAL = U7_FILIAL AND Z19_TELE = U7_COD AND A.D_E_L_E_T_<>'*' AND B.D_E_L_E_T_<>'*' AND U7_CODUSU='"+RetCodUsr()+"' "
cQry+=" AND	Z19_MES = '"+SUBSTR(DTOS(DDATABASE),5,2)+"' "
cQry+=" AND	Z19_ANO = '"+SUBSTR(DTOS(DDATABASE),1,4)+"' "
cQry+=" GROUP BY Z19_MES,Z19_ANO "


IF Select('TR01')<>0
	TR01->(DBCloseArea())
EndIF

TCQuery cQry new Alias 'TR01'

if !TR01->(Eof())
	
	DEFINE MSDIALOG oDlgMeta FROM 0,0 TO (8*20)+50,370 TITLE "Meta de vendas"  PIXEL
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	@ 11,00 TO 013,400 LABEL '' OF oDlgMeta PIXEL
	@ 03,05 SAY 'Meta x Realizado' OF oDlgMeta PIXEL SIZE 100,009 FONT oBold
	
	nLin:=20
	nCol:=05
	//oSay1 := TSay():New( nLin+1, nCol,{||'Meta'},oDlgMeta,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	nLin+=10
	oSay1 := TSay():New( nLin+1, nCol,{||'Mes: '},oDlgMeta,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay1 := TSay():New( nLin+1, nCol+20,{||TR01->Z19_MES},oDlgMeta,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)
	
	oSay1 := TSay():New( nLin+1, nCol+40,{||'Ano: '},oDlgMeta,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay1 := TSay():New( nLin+1, nCol+60,{||TR01->Z19_ANO},oDlgMeta,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)
	nLin+=10
	oSay1 := TSay():New( nLin+1, nCol,{||'VALOR TOTAL META R$:'},oDlgMeta,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay1 := TSay():New( nLin+1, nCol+100,{||TRANSFORM(TR01->CT_VALOR,"@e 999,999,999.99")},oDlgMeta,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)
	
	nLin+=10
	oSay1 := TSay():New( nLin+1, nCol,{||'VALOR TOTAL FATURADO R$:'},oDlgMeta,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay1 := TSay():New( nLin+1, nCol+100,{||TRANSFORM(TR01->FAT,"@e 999,999,999.99")},oDlgMeta,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)
	nLin+=10
	oSay1 := TSay():New( nLin+1, nCol,{||'VALOR TOTAL PEDIDOS R$:'},oDlgMeta,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay1 := TSay():New( nLin+1, nCol+100,{||TRANSFORM(TR01->PEDIDO,"@e 999,999,999.99")},oDlgMeta,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)
	nLin+=10
	oSay1 := TSay():New( nLin+1, nCol,{||'% EFICIENCIA:'},oDlgMeta,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay1 := TSay():New( nLin+1, nCol+100,{||TRANSFORM(ROUND(TR01->FAT/TR01->CT_VALOR*100,2),"@e 999,999,999.99")},oDlgMeta,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)
	nLin+=10
	oTButton1 := TButton():New( nlin, 005, "Atualizar",oDlgMeta,{||atureal()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//oDlgMeta:= Refresh()
	
	ACTIVATE MSDIALOG oDlgMeta CENTERED
EndIF

return

STATIC FUNCTION Ordena(nCol)
aCols01:=moAcols01()
//aCols01 := aSort( aCols01,,,{|x,y| x[nCol] < y[nCol]})
oGdList:setArray(aCols01)
oGdList:oBrowse:Refresh()

RETURN

Static Function INCAGEND

Private CCADASTRO:='Agenda Geral'
Private INCLUI:=.T.
axinclui('Z20')

//oMBrDownL:SetOwner(oDlg)
oMBrDownL:Data():Deactivate()
oMBrDownL:SetQuery(cSql)
oMBrDownL:Data():Activate()
oMBrDownL:UpdateBrowse(.T.)
oMBrDownL:GoTo(1,.T.)
oMBrDownL:Refresh(.T.)
RETURN

Static FunctioN BXGEND()

a_Area:=GetArea()

dbSelectArea('Z20')
DBGOTO(TRUBX->REGISTRO)

U_atmk009b()

cSql:=" SELECT R_E_C_N_O_ AS REGISTRO, Z20_FILIAL, Z20_RESP, Z20_DTRET, Z20_HRRET, Z20_CONTAT, Z20_CLIENT, Z20_LOJA, Z20_NOME, Z20_OBS, Z20_VEND, "
cSql+= "	Z20_EMISSA, Z20_HRLIG, Z20_OPERAD, Z20_MOTIVO, Z20_DTFIM, Z20_HRFIM, Z20_RESFIM, Z20_DPRES, Z20_NUM, Z20_SEQ, "
cSql+= " Z20_EMAILS, Z20_ATENDI, Z20_ANEXA, Z20_NRESP FROM "+RetSqlName('Z20')

// cSql+=" WHERE Z20_RESP ='"+cTele+"'"
// cSql+=" AND Z20_DTFIM=''"   -- Retirado o filtro do Responsavel, para que nao retorne somente o TELE // Rogerio 05/10

cSql+=" WHERE Z20_DTFIM=''"
cSql+=" AND D_E_L_E_T_<>'*'"

oMBrDownL:Data():Deactivate()
oMBrDownL:SetQuery(cSql)
oMBrDownL:Refresh()
oMBrDownL:Data():Activate()
oMBrDownL:UpdateBrowse(.T.)
//oMBrDownL:GoTo(1,.T.)

// RestArea(a_Area)

//oMBrDownL:Refresh(.T.)

Return
//lFiltra
User function Atutela()
Local aItems:= {'1=Não Realizado','Item2','Item3'}
cStatus02	:= aItems[1]
lFiltra:=.T.
cFiltro:=""

if lFiltra
	//(Z19_STATU2 in('1','7')  or (Z19_STATU2  = 2 AND Z19_DTRET <> ''))
	DEFINE DIALOG oDlgFil TITLE "Exemplo TComboBox" FROM 180,180 TO 550,700 PIXEL
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	lCheck := .T.    // Usando New
	
	@ 11,00 TO 013,400 LABEL '' OF oDlgFil PIXEL
	@ 03,05 SAY 'Filtro' OF oDlgFil PIXEL SIZE 100,009 FONT oBold
	
	nlin:=20
	
	oCheck11 := TCheckBox():New(nlin,05,'Na Periodicidade',{|u|if(PCount()>0,lTst0101:=u,lTst0101)} ,oDlgFil,100,210,,,,,,,,.T.,,,)
	oCheck21 := TCheckBox():New(nlin,70,'Não Realizado',{|u|if(PCount()>0,lTst0201:=u,lTst0201)},oDlgFil,100,210,,,,,,,,.T.,,,)
	nlin+=10
	oCheck12 := TCheckBox():New(nlin,05,'Fora Periodicidade',{|u|if(PCount()>0,lTst0102:=u,lTst0102)},oDlgFil,100,210,,,,,,,,.T.,,,)
	oCheck22 := TCheckBox():New(nlin,70,'Pedido',{|u|if(PCount()>0,lTst0202:=u,lTst0202)},oDlgFil,100,210,,,,,,,,.T.,,,)
	nlin+=10
	oCheck13 := TCheckBox():New(nlin,05,'Sem ped. period.',{|u|if(PCount()>0,lTst0103:=u,lTst0103)},oDlgFil,100,210,,,,,,,,.T.,,,)
	oCheck23 := TCheckBox():New(nlin,70,'Comprou concorrente',{|u|if(PCount()>0,lTst0203:=u,lTst0203)},oDlgFil,100,210,,,,,,,,.T.,,,)
	nlin+=10
	oCheck14 := TCheckBox():New(nlin,05,'Inativo',{|u|if(PCount()>0,lTst0104:=u,lTst0104)},oDlgFil,100,210,,,,,,,,.T.,,,)
	oCheck24 := TCheckBox():New(nlin,70,'Comprou com vendedor',{|u|if(PCount()>0,lTst0204:=u,lTst0204)},oDlgFil,100,210,,,,,,,,.T.,,,)
	nlin+=10
	oCheck25 := TCheckBox():New(nlin,70,'Orçamento',{|u|if(PCount()>0,lTst0205:=u,lTst0205)},oDlgFil,100,210,,,,,,,,.T.,,,)
	nlin+=10
	oCheck26:= TCheckBox():New(nlin,70,'Tem estoque',{|u|if(PCount()>0,lTst0206:=u,lTst0206)},oDlgFil,100,210,,,,,,,,.T.,,,)
	nlin+=10
	oCheck27 := TCheckBox():New(nlin,70,"Outro motivo",{|u|if(PCount()>0,lTst0207:=u,lTst0207)},oDlgFil,100,210,,,,,,,,.T.,,,)
	nlin+=10
	oCheck28:= TCheckBox():New(nlin,70,"Reagendado",{|u|if(PCount()>0,lTst0208:=u,lTst0208)},oDlgFil,100,210,,,,,,,,.T.,,,)
	
	ACTIVATE DIALOG oDlgFil ON INIT EnchoiceBar(oDlgFil,{|| nOpca := 2,oDlgFil:End()},{|| nOpca := 1,oDlgFil:End()}) CENTERED
	
	aCols01:=moAcols01()
	oGdList:setArray(aCols01)
	oGdList:oBrowse:Refresh()
	
EndIF

Return

static Function FilExp()

Local lOK    := .F.
Local cFor   := Space(255)
Local cWhile := Space(255)
Local nRec   := 0
Local aOper:={"=","<>",">",">=","<","<=","Contem"}
Local lHasButton := .T.
Local aCampos:={"Z19_STATUS","Z19_STATU2","Z19_DTRET","Z19_CLIENT","Z19_LOJA","Z19_NOMCLI","Z19_CONTAT","Z19_UF","Z19_CIDADE","Z19_VEND","Z19_ULTCOM","Z19_PRIORI",;
"Z19_META","Z19_MEDIA","Z19_PEDMES","Z19_DTFAT","Z19_EFICIE","Z19_POTEN","Z19_TELE"}

Private  cCampo:=aCampos[1]
Private cOper:= aOper[1]
Private cValor:=space(100)
Private oDlgF
cFiltro:=""

DEFINE MSDIALOG oDlgF FROM 00,00 TO 250,450 TITLE "Expressões"   PIXEL
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 11,00 TO 013,400 LABEL '' OF oDlgF PIXEL
@ 03,05 SAY 'Expressões' OF oDlgF PIXEL SIZE 100,009 FONT oBold

nlin:=20
@ nlin		,05 Say "Campo " OF oDlgF PIXEL
oCombo1 := TComboBox():New(nlin+10,05,{|u|if(PCount()>0,cCampo:=u,cCampo)},aCampos,60,20,oDlgF,,{||},,,,.T.,,,,,,,,,'cCampo')

@ nlin		,75 Say "Operador " OF oDlgF PIXEL
oCombo1 := TComboBox():New(nlin+10,75,{|u|if(PCount()>0,cOper:=u,cOper)},aOper,40,20,oDlgF,,{||},,,,.T.,,,,,,,,,'cOper')

@ nlin		,120 Say "Valor " OF oDlgF PIXEL
oGet1 := TGet():New(nlin+10,125, { | u | If( PCount() == 0, cValor, cValor := u ) },oDlgF, 070, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cValor",,,,lHasButton  )
nlin+=25
oTButton1 := TButton():New( nlin, 005, "Adicionar",oDlgF,{||adtiexp()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton1 := TButton():New( nlin, 055, "Limpar",oDlgF,{||limpexp()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton1 := TButton():New( nlin, 125, "E",oDlgF,{||  adtiexp("AND") }, 20,10,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton1 := TButton():New( nlin, 155, "OU",oDlgF,{|| adtiexp("OR") }, 20,10,,,.F.,.T.,.F.,,.F.,,,.F. )

nlin+=15
oTMultiget1 := tMultiget():new( nLin, 005, {| u | if( pCount() > 0, cFiltro := u, cFiltro ) },  oDlgF, 200, 42, , , , , , .T. )

nlin+=55
oTButton1 := TButton():New( nlin, 005, "Filtrar",oDlgF,{||filz19()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton1 := TButton():New( nlin, 055, "Sair",oDlgF,  {|| oDlgF:end() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

oTButton1 := TButton():New( nlin, 135, "Filtrar Status",oDlgF,{||U_atutela()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgF CENTERED

Return .T.

Static Function adtiexp(cOp)
Default cOp:=""
If Empty(cCampo)
	alert('Selecionar o campo')
	return
EndIF
If Empty(cOper)
	alert('Selecionar a operação')
	return
EndIF
If Empty(cValor)
	alert('Preencher o valor')
	return
EndIF
/*
If !Empty(cOp) .and. (rigth(cFiltro,3) =='AND' .OR. rigth(cFiltro,2) =='OR')
return
EndIF
*/

if !Empty(cOp)
	cFiltro+=" "+cOp
Else
	cFiltro+=" "+cCampo+" "+cOper+" "+cValor
	
EndIF

Return

Static Function limpexp()

cFiltro:=""

Return

Static Function filz19
aCols01:=moAcols01()
oGdList:setArray(aCols01)
oGdList:oBrowse:Refresh()
Return

Static  Function telJust
Local lHasButton := .T.
Private oDlgJ
Private cJust :=space(100)
DEFINE MSDIALOG oDlgJ FROM 00,00 TO 170,350 TITLE "Justificativa"   Pixel Style DS_MODALFRAME
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
oDlgJ:lEscClose     := .F.
@ 11,00 TO 013,400 LABEL '' OF oDlgJ PIXEL
@ 03,05 SAY 'Justificativa' OF oDlgJ PIXEL SIZE 100,009 FONT oBold
oGet1 := TGet():New( 15,005 , { | u | If( PCount() == 0, cJust, cJust := u ) },oDlgJ, 150, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"oDlgJ",,,,lHasButton  )

oTButton1 := TButton():New(40, 055, "Confirmar",oDlgJ,  {|| grvJust() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgJ CENTERED

Return

static Function grvJust()

if Empty(cJust)
	Alert('Obrigatorio digitar a justificativa')
	return .f.
EndIF

DBSelectArea('Z19')
DBSetOrder(1)
IF dbSeek(xFilial('Z19')+SUBSTR(DTOS(DDATABASE),5,2)+SUBSTR(DTOS(DDATABASE),1,4)+M->UA_CLIENTE+M->UA_LOJA)
	reclock('Z19',.F.)
	Z19->Z19_JUSTIF:=cJust
	MsUnlock()
eNDif
oDlgj:End()
return


/*Funcao que atualiza os realizados dos faturamentos*/

Static Function atureal()

AtuRe()

Return 


Static Function AtuRe()

cUpd:=" UPDATE "+RetSqlName('Z19')+" SET Z19_PEDMES = BB.VALORPED , Z19_FATMES = BB.VALORFAT ,Z19_EFICIE = Case when Z19_META=0 then 0 Else BB.VALORFAT/Z19_META*100 End "
cUpd+=" FROM "+RetSqlName('Z19')+" INNER JOIN ("
cUpd+=" SELECT Z19_TELE,Z19_CLIENT CLIENTE,Z19_LOJA LOJA,Z19_ANO ANO ,Z19_MES MES ,SUM(C6_VALOR) VALORPED,SUM(ISNULL(D2_TOTAL,0))VALORFAT"
cUpd+=" FROM "+RetSqlName('Z19')+" Z19"
cUpd+=" INNER JOIN "+RetSqlName('SU7')+" SU7"
cUpd+=" 	ON U7_COD=Z19_TELE"
cUpd+=" 	AND SU7.D_E_L_E_T_<>'*'"
cUpd+=" INNER JOIN "+RetSqlName('SC5')+" SC5"
cUpd+=" 	ON C5_VEND2 = U7_CODVEN"
cUpd+=" 	AND SC5.D_E_L_E_T_<>'*'"
cUpd+=" 	AND SUBSTRING(C5_EMISSAO,1,6)=Z19_ANO+Z19_MES"
cUpd+=" 	AND C5_CLIENTE = Z19_CLIENT"
cUpd+=" 	AND C5_LOJACLI = Z19_LOJA"
cUpd+=" INNER JOIN "+RetSqlName('SC6')+" SC6"
cUpd+=" 	ON C6_FILIAL = C5_FILIAL"
cUpd+=" 	AND C6_NUM = C5_NUM"
cUpd+=" 	AND SC6.D_E_L_E_T_<>'*'" 
cUpd+=" INNER JOIN "+RetSqlName('SF4')+" SF4"
cUpd+=" 	ON SF4.F4_FILIAL = SUBSTRING(C6_FILIAL,1,4)"
cUpd+=" 	AND SF4.F4_CODIGO = C6_TES"
cUpd+=" 	AND SF4.F4_DUPLIC ='S'"
cUpd+=" 	AND SF4.D_E_L_E_T_<>'*'"
cUpd+=" LEFT JOIN "+RetSqlName('SF2')+" SF2"
cUpd+=" 	ON F2_CLIENTE = Z19_CLIENT"
cUpd+=" 	AND F2_LOJA = Z19_LOJA"
cUpd+=" 	AND SUBSTRING(F2_EMISSAO,1,6)=Z19_ANO+Z19_MES"
cUpd+=" 	AND SF2.D_E_L_E_T_<>'*'"
cUpd+=" 	AND F2_VEND2 =U7_CODVEN"
cUpd+=" LEFT JOIN "+RetSqlName('SD2')+" SD2"
cUpd+=" 	ON D2_FILIAL = F2_FILIAL"
cUpd+=" 	AND D2_DOC = F2_DOC"
cUpd+=" 	AND D2_SERIE = F2_SERIE"
cUpd+=" 	AND D2_ITEMPV = C6_ITEM"
cUpd+=" 	AND D2_PEDIDO = C6_NUM"
cUpd+=" 	AND SD2.D_E_L_E_T_<>'*'"  
cUpd+=" LEFT JOIN "+RetSqlName('SF4')+" SF4B"
cUpd+=" 	ON SF4B.F4_FILIAL = SUBSTRING(D2_FILIAL,1,4)"
cUpd+=" 	AND SF4B.F4_CODIGO = D2_TES"
cUpd+=" 	AND SF4B.F4_DUPLIC ='S'"
cUpd+=" 	AND SF4B.D_E_L_E_T_<>'*'"
cUpd+=" WHERE Z19_TELE='"+CTELE+"'"
cUpd+=" AND Z19_MES='"+SUBSTR(DTOS(DDATABASE),5,2)+"'"
cUpd+=" AND Z19_ANO='"+SUBSTR(DTOS(DDATABASE),1,4)+"'"
cUpd+=" GROUP BY Z19_TELE,Z19_CLIENT,Z19_LOJA,Z19_ANO,Z19_MES)BB"
cUpd+=" ON BB.CLIENTE = Z19_CLIENT"
cUpd+=" AND BB.LOJA = Z19_LOJA"
cUpd+=" AND BB.ANO =Z19_ANO"
cUpd+=" AND BB.MES = Z19_MES"

TCSqlExec(cUpd)

oDlgMeta:Refresh()
oDlgMeta:End()

Return






//-------------------------------------------------------------------
/*/{Protheus.doc} EnvMail
Envia E-mail
                

@author		Thiago Henrique dos santos
@since		31/08/2017     
@version 	P11  
/*/
//-------------------------------------------------------------------

Static Function EnvMail(cAccount	,cPassword	,cServer	,cFrom,;
					cEmail		,cAssunto	,cMensagem	,cAttach)

Local cEmailTo := ""							// E-mail de destino
Local cEmailBcc:= ""							// E-mail de copia
Local lResult  := .F.							// Se a conexao com o SMPT esta ok
Local cError   := ""							// String de erro
Local lRelauth := SuperGetMv("MV_RELAUTH")		// Parametro que indica se existe autenticacao no e-mail
Local lRet	   := .F.							// Se tem autorizacao para o envio de e-mail
Local cConta   := ALLTRIM(cAccount)				// Conta de acesso 
Local cSenha   := ALLTRIM(cPassword)	        // Senha de acesso

Local oServer  									//Objeto para o TmailManager
Local oMessage									//Objeto para o TmailMessenger
Local nErr      := 0							//Variavel para controle de erro
Local nSMTPTime := GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO
Local lSSL 		:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS 		:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
Local nSMTPPort := GetNewPar("MV_PORSMTP",25)	// PORTA SMTP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cEmailTo := cEmail
If At(";",cEmail) > 0 // existe um segundo e-mail.
	cEmailBcc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Endif	

If lSSL .Or. lTLS

	
	// Objeto de Email
	oServer := TMailManager():New()
	
	// Usa SSL, TLS ou nenhum na inicializacao
	
	oServer:SetUseTLS(lTLS)
	
	aSmtSrvPt  := Separa(cServer,':',.F.)

	If Len(aSmtSrvPt) == 2			
		cServer  := Alltrim(aSmtSrvPt[1])
		nSMTPPort := Val(aSmtSrvPt[2])
	EndIf	
	
	// Inicializacao do objeto de Email
	nErr := oServer:init("",cServer,cConta,cSenha,,nSMTPPort)
	If nErr <> 0	
		CoNout("[Init SMTP] Falha ao inicializar SMTP: " + oServer:getErrorString(nErr)) // "[Init SMTP] Falha ao inicializar SMTP: " 	
		Return(.F.)
	Else
		CoNout("[Init SMTP] Sucesso ao inicializar SMTP " + oServer:getErrorString(nErr)) //"[Init SMTP] Sucesso ao inicializar SMTP "
	Endif
	
	// Define o Timeout SMTP
	nErr := oServer:SetSMTPTimeout(nSMTPTime)
	If nErr <> 0
		CoNout("[SetSMTPTimeout] Falha ao definir timeout: " + oServer:getErrorString(nErr)) //"[SetSMTPTimeout] Falha ao definir timeout: "
		Return(.F.)
	Else
		conout( "[SetSMTPTimeout] Sucesso ao definir Timeout SMTP: " + oServer:getErrorString(nErr)) //"[SetSMTPTimeout] Sucesso ao definir Timeout SMTP: "
	EndIf
	
	// Conecta ao servidor
	nErr := oServer:smtpConnect()
	If nErr <> 0	
		CoNout("[Connect SMTP] Falha ao conectar: " + oServer:getErrorString(nErr)) // "[Connect SMTP] Falha ao conectar: "		
		oServer:SMTPDisconnect()
		Help(" ",1,"Atenção",,oServer:getErrorString(nErr),4,5)      //Atencao
		Return(.F.)
	Else
		CoNout("[Connect SMTP] Sucesso ao conectar SMTP" + oServer:getErrorString(nErr)) // "[Connect SMTP] Sucesso ao conectar SMTP"
	EndIf
	
	// Realiza autenticacao no servidor
	If lRelauth
		cFrom		:= GetNewPar("MV_RELFROM","") 	// E-mail do remetente
		nErr := oServer:smtpAuth(cConta, cSenha)
		If nErr <> 0		
			CoNout("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
			oServer:SMTPDisconnect()
			Help(" ",1,"Autenticacao",,oServer:getErrorString(nErr),4,5)  //"Autenticacao"
			MsgStop("Erro de autenticação","Verifique a conta e a senha para envio") 		 //"Erro de autenticação","Verifique a conta e a senha para envio"
			Return(.F.)
		Else
			CoNout("[AUTH] Sucesso ao autenticar: " + oServer:getErrorString(nErr)) //"[AUTH] Sucesso ao autenticar: "	
		EndIf
	EndIf	
	
	conout( "[MESSAGE] Criando mail message" ) //"[MESSAGE] Criando mail message"
	
	// Cria uma nova mensagem (TMailMessage)
	oMessage := TMailMessage():New()
	oMessage:clear()
	
	oMessage:cFrom		:= cFrom
	oMessage:cTo    	:= cEmailTo
	oMessage:cBCC		:= cEmailBcc
	oMessage:cSubject	:= cAssunto
	oMessage:cBody 		:= cMensagem
	
	If !Empty(cAttach)
		nErr := oMessage:AttachFile( cAttach )
  		If nErr < 0
  			Conout("[Attach] Erro ao anexar arquivo" +  oServer:getErrorString(nErr)) //"[Attach] Erro ao anexar arquivo"
    		Return .F.
  		Endif
	EndIf	
	
	conout( "[SEND] Enviando ..." ) //"[SEND] Enviando ..."
	nErr := oMessage:Send( oServer )
		  
	If nErr != 0
		conout( "[SEND] Falha ao enviar" ) //"[SEND] Falha ao enviar"
		conout( "[SEND][ERROR] " + str( nErr, 6 ), oServer:GetErrorString( nErr ) ) //"[SEND][ERROR] "
		Help(" ",1,"Atenção",,oServer:GetErrorString( nErr )+ " " + cEmailTo,4,5)	//Atenção
	Else
		conout( "[SEND] Sucesso no envio" + oServer:getErrorString(nErr) ) //"[SEND] Sucesso no envio"
	EndIf
	
	conout( "[DISCONNECT] Desconectando SMTP " ) //"[DISCONNECT] Desconectando SMTP "
	nErr := oServer:SmtpDisconnect()
	If nErr != 0
		conout( "[DISCONNECT] Falha ao Desconectar SMTP" ) //"[DISCONNECT] Falha ao Desconectar SMTP"
		conout( "[DISCONNECT][ERROR] " + str( nErr, 6 ), oServer:GetErrorString( nErr ) ) //"[DISCONNECT][ERROR] "
	Else
		conout( "[DISCONNECT] Sucesso ao desconectar SMTP" + oServer:getErrorString(nErr) ) //"[DISCONNECT] Sucesso ao desconectar SMTP"
	EndIf
	
Else
	CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenha RESULT lResult
	
	// Se a conexao com o SMPT esta ok
	If lResult
		
		// Se existe autenticacao para envio valida pela funcao MAILAUTH
		If lRelauth
			lRet := Mailauth(cConta,cSenha)	
		Else
			lRet := .T.	
	    Endif    
	
		If lRet
			SEND MAIL FROM cFrom ;
			TO      	cEmailTo;
			BCC     	cEmailBcc;
			SUBJECT 	cAssunto;
			BODY    	cMensagem;
			ATTACHMENT  cAttach  ;
			RESULT lResult
			
			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError
				Help(" ",1,"Atenção",,cError+ " " + cEmailTo,4,5)	//Atenção
			Endif
	
		Else
			GET MAIL ERROR cError
			Help(" ",1,"Autenticacao",,cError,4,5)  //"Autenticacao"
			MsgStop("Erro de autenticação","Verifique a conta e a senha para envio") 		 //"Erro de autenticação","Verifique a conta e a senha para envio"
		Endif
			
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Help(" ",1,"Atenção",,cError,4,5)      //Atencao
	Endif
		
EndIf



Return(lResult)
