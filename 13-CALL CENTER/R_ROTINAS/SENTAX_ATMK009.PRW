#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK009
AGENDA DE RECADOS 
@author Rodrigo Slisinski
@since 08/08/2017
@version 1.0
/*/
//-------------------CHAMADA TELA PRINCIPAL------------------------------------------------
User Function ATMK009(lImp)

Local oMBrowse
Private cDepto := ""
Private cResp  := pegaresp()
Default lImp:=.f.
Private CCADASTRO :="Agenda de Recados"

oMBrowse := FWMBrowse():New()
oMBrowse:SetMenuDef("SENTAX_ATMK009")
oMBrowse:AddLegend("Z20->Z20_RESP == '"+cResp+"'","GREEN" ,"Seus atendimentos"    )          
oMBrowse:AddLegend("Z20->Z20_RESP <> '"+cResp+"' .AND. ALLTRIM(Z20->Z20_DPRES) == '"+ALLTRIM(cDepto)+"'","YELLOW" ,"De sua equipe"    ) 
oMBrowse:AddLegend("Z20->Z20_RESP <> '"+cResp+"' .AND. ALLTRIM(Z20->Z20_DPRES) <> '"+ALLTRIM(cDepto)+"'","RED" ,"De outros Setores") 



//oMBrowse:AddStatusColumns({|| Status() }/*bStatus*/, {|| Legend() }/*bLDblClick*/)



oMBrowse:SetAlias("Z20")
oMBrowse:SetLocate()
oMBrowse:DisableDetails()
if lImp
	nPos:=aScan(oGdList:AHEADER,{|X|ALLTRIM(X[2])=='Z19_TELE'})
	oMBrowse:SetFilterDefault( "Z20_OPERAD=='"+oGdList:ACOLS[oGdList:nAt][nPos]+"'" )
EndIF	
	
	
oMBrowse:Activate()


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Modeldef
MONTA O MODELO DE DADOS
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function Modeldef()

Local oStructZ20 := Nil
Local oModel     := Nil
Local aAux       := {}

oStructZ20 := FWFormStruct(1,"Z20") //cria estrutura baseada no (dicionario)
oModel:= MPFormModel():New("ATMK009M")//cria o modelo de dados 
oModel:SetDescription("Agenda de Recados")//descricao do modelo de dados
oModel:AddFields("ATMK009_Z20",  , oStructZ20 , {|| .T.}/*Pre-Validacao*/,{|| .T.}/*Pos-Validacao*/,/*Carga*/)//ADICIONA O COMPONENT AO FORMULARIO
oModel:GetModel ("ATMK009_Z20"):SetDescription("Dados de Agenda de Recados") //DESCRICAO DADOS
oModel:SetPrimaryKey({"Z20_FILIAL+Z20_RESP"})

Return(oModel)



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
MONTA O MODELO DA INTERFACE
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oStructZ20
Local oModel := FWLoadModel("SENTAX_ATMK009")

oStructZ20 := FWFormStruct(2,"Z20",{ |cCampo| COMP11STRU(cCampo) })
//oStructZ20 := FWFormStruct(2,"Z20")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( "ATMK009_Z20" , oStructZ20)   
oView:CreateHorizontalBox("CABEC",100)
oView:SetOwnerView( "ATMK009_Z20","CABEC")
oView:EnableControlBar(.T.)  

Return oView 

Static Function COMP11STRU( cCampo )
Local lRet := .T.

If cCampo == 'Z20_EMAILS'
	lRet := .F.
EndIf

If cCampo == 'Z20_NUM'
	lRet := .F.
EndIf

If cCampo == 'Z20_SEQ'
	lRet := .F.
EndIf

If cCampo == 'Z20_ANEXA'
	lRet := .F.
EndIf




Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
monta menu da rotina 
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title 'Visualizar' 	Action 		'VIEWDEF.SENTAX_ATMK009' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir' 		Action 		'VIEWDEF.SENTAX_ATMK009' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 		Action 		'VIEWDEF.SENTAX_ATMK009' OPERATION 4 ACCESS 0
//ADD OPTION aRotina Title 'Excluir' 		Action 		'VIEWDEF.SENTAX_ATMK009' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 	Action 		'VIEWDEF.SENTAX_ATMK009' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Baixa' 		Action 		'U_atmk009b' OPERATION 3 ACCESS 0



Return aRotina


User Function atmk009b


Local nLin  		:= 005
Local nCol  		:= 005
Local nCol2  		:= nCol+40	
Local nCol3  		:= nCol2+75
Local nCol4  		:= nCol3+35

Local lRet			:= .F.
Local lHasButton 	:= .T.
Local oFont 		:= TFont():New('Arial',,-12,.T.,.t.)
Local aItems        := {'01=teste'}
private dDtBaixa 	:= date()
private chrBaixa  	:= time() 
private cResp     	:= UsrFullName ( RetCodUsr() )
private chrBaixa  	:= time() 
Private cTxBx		:= ""
Private cMotivo		:= ""

private oDlgPr


//DBSelectArea('SX3')
//DBSetOrder(2)
//IF DbSeek('Z20_MOTIVO')
//	aItems:=SEPARA(SX3->X3_CBOX,';')
//EndIf
if !Empty(Z20->Z20_HRFIM)
	alert("Tarefa ja encerrada!")
	return
EndIF
	  
DEFINE MSDIALOG oDlgPr TITLE "[ATMK009] BAIXA " FROM 000, 000  TO 400, 550 COLORS 0, 16777215 PIXEL
	 
	oSay1 := TSay():New( nLin+1, nCol,{||'Data Baixa'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oGet1 := TGet():New( nLin, nCol2, { | u | If( PCount() == 0, dDtBaixa, dDtBaixa := u ) },oDlgPr, 070, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.F. ,,"dDtBaixa",,,,lHasButton  )
	
	oSay1 := TSay():New( nLin+1, nCol3,{||'Hora Baixa'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oGet1 := TGet():New( nLin, nCol4, { | u | If( PCount() == 0, chrBaixa, chrBaixa := u ) },oDlgPr, 070, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.F. ,,"chrBaixa",,,,lHasButton  )
	nLin+=15
	oSay1 := TSay():New( nLin+1, nCol,{||'Responsavel'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oGet1 := TGet():New( nLin, nCol2, { | u | If( PCount() == 0, cResp, cResp := u ) },oDlgPr, 070, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.F. ,,"cResp",,,,lHasButton  )
	
	nLin+=15
	oSay1 := TSay():New( nLin+1, nCol,{||'Motivo'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	
	cMotivo:= aItems[1]
	oCombo := TComboBox():New( nLin+1, nCol2,{|u|if(PCount()>0,cMotivo:=u,cMotivo)},aItems,100,20,oDlgPr,,{||.T.},,,,.T.,,,,,,,,,'cMotivo')
	
	
	
	//oTMultiget1 := tMultiget():new( nLin, nCol2, {| u | if( pCount() > 0, cMotivo := u, cMotivo ) },  oDlgPr, 200, 60, , , , , , .T. )
	
	nLin+=15
	oSay1 := TSay():New( nLin+1, nCol,{||'Texto Baixa'},oDlgPr,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oTMultiget1 := tMultiget():new( nLin, nCol2, {| u | if( pCount() > 0, cTxBx := u, cTxBx ) },  oDlgPr, 200, 60, , , , , , .T. )
	
	
	nLin+=75
	oTButton1 := TButton():New( nLin, nCol2+30, "Confirmar",oDlgPr,{||lRet:=GRVAG(oDlgPr) }, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	oTButton1 := TButton():New( nLin, nCol4, "Cancelar",oDlgPr,{||lRet:=.T.,oDlgPr:END()}, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. ) 

	ACTIVATE MSDIALOG oDlgPr CENTERED
	

Return


Static Function GRVAG(oDlgPr)

 IF EMPTY(ALLTRIM(cMotivo))
 	ALERT('Motivo Obrigatorio!')
 	return .f.
 EndIF
 
 IF EMPTY(ALLTRIM(cTxBx))
 	ALERT('Texto Baixa Obrigatorio!')
 	return .f.
 EndIF
 
 
 RECLOCK('Z20',.F.)
 
 Z20->Z20_MOTIVO	:= cMotivo
 Z20->Z20_DTFIM		:= dDtBaixa
 Z20->Z20_HRFIM		:= chrBaixa
 Z20->Z20_RESFIM	:= RetCodUsr()
 Z20->Z20_TXFIM		:= cTxBx
 
 MsUnlock()

oDlgPr:END()
Return .t.



Static Function Status()

Local cImgRPO := ""
	
	
	IF Z20->Z20_RESP == cResp
		cImgRpo := "BR_VERDE"
	ElseIF Z20->Z20_DPRES == cDepto
		cImgRpo := "BR_AMARELO"
	Else
		cImgRpo := "BR_VERMELHO"
	EndIf
	
Return cImgRPO




Static Function Legend()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_VERDE"			, "Seus atendimentos"	}, ;	
						{"BR_AMARELO"		, "De sua equipe" 		}, ;
						{"BR_VERMELHO"		, "De outros Setores"	}}
					
	
BrwLegenda("Satus","Legenda",aLegenda)	
	
Return .T.


Static Functio pegaresp()
cRet  := posicione('SA3',7,XFILIAL('SA3')+RETCODUSR(),'A3_COD')
cDepto:= SA3->A3_XDEPTO

Return cRet