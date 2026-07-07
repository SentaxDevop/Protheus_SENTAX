#include "protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
//-------------------------------------------------------------------
/*{Protheus.doc} MFAT003
Consulta vendas por cliente
@author	Anderson Roberto Franco de Souza
@since		11/12/2013
@version	P11 R1
@return	NIL
*/
//-------------------------------------------------------------------
User Function MFAT003()
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft, oBrowseRight
Local oRelacSF2
Local oRelacSD2
Private oDlgPrinc

Define MsDialog oDlgPrinc Title 'Clientes x Nota Fiscais Emitidas' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
//
// Cria o conteiner onde serão colocados os browses
//
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )
//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 35, .F. )
// Cria uma "linha" com 40% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
// Pego o objeto desse pedaço do container
//
// Painel do meio
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oFWLayer:AddLine( 'MEIO', 35, .F. )
oFWLayer:AddCollumn( 'ALL1',  50, .T., 'MEIO' ) 
oFWLayer:AddCollumn( 'ALL2',  50, .T., 'MEIO' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelME := oFWLayer:GetColPanel( 'ALL1', 'MEIO' )  // Pego o objeto do pedaço INFERIOR  
oPanelMD := oFWLayer:GetColPanel( 'ALL2', 'MEIO' )  // Pego o objeto do pedaço INFERIOR
// Painel de baixo
oFWLayer:AddLine( 'DOWN', 30, .F. )
oFWLayer:AddCollumn( 'ALL',  100, .T., 'DOWN' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelDown := oFWLayer:GetColPanel( 'ALL', 'DOWN' )  // Pego o objeto do pedaço INFERIOR
//
//
// FWmBrowse Superior
//
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )
// Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( "Clientes" )
oBrowseUp:SetAlias( 'SA1' )
//oBrowseUp:AddLegend( "Z2_SIT='1'", "RED", "Bloqueado" )
//oBrowseUp:AddLegend( "Z2_SIT='2'", "GREEN" , "Liberado" )
/*_cFil := "B1_MSBLQL !='1'"

//filtro
oBrowseUp:SetFilterDefault( _cFil )*/
oBrowseUp:SetMenuDef( 'SENTAX_MFAT003' )
oBrowseUp:DisableDetails()
// Define de onde virao os botoes deste browse
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()
oBrowseUp:Activate()
//
// Meio-Notas Fiscais
//
oBrwMeioE:= FWMBrowse():New()
oBrwMeioE:SetOwner( oPanelME)
oBrwMeioE:SetDescription( 'Notas Fiscais' )
oBrwMeioE:SetMenuDef( '' )
// Referencia vazia para que nao exiba nenhum botao
oBrwMeioE:DisableDetails()
oBrwMeioE:SetAlias( 'SF2' )
oBrwMeioE:SetProfileID( '2' )
//oBrwMeioE:SetOnlyFields( { 'F2_FILIAL','F2_DOC','F2_SERIE','F2_CLIENTE','F2_LOJA','F2_EMISSAO','F2_VALBRUT' } )
oBrwMeioE:SetOnlyFields( { 'F2_FILIAL','F2_DOC','F2_SERIE','F2_EMISSAO','F2_VALBRUT' } )
oBrwMeioE:Activate()
//
// Relacionamento entre os Paineis

oRelacSF2:= FWBrwRelation():New()

oRelacSF2:AddRelation( oBrowseUp, oBrwMeioE, { {'F2_CLIENTE' , 'A1_COD'  },{'F2_LOJA' , 'A1_LOJA'  }} )
oRelacSF2:Activate()

//
//Baixo-Itens Notas Fiscais
//
oBrwMeioD:= FWMBrowse():New()
oBrwMeioD:SetOwner( oPanelMD)
oBrwMeioD:SetDescription( 'Itens Notas Fiscais' )
oBrwMeioD:SetMenuDef( '' )
// Referencia vazia para que nao exiba nenhum botao
oBrwMeioD:DisableDetails()
oBrwMeioD:SetAlias( 'SD2' )
oBrwMeioD:SetProfileID( '3' )
//oBrwMeioD:SetOnlyFields( { 'D2_FILIAL','D2_COD','D2_QUANT','D2_TOTAL' } )
oBrwMeioD:SetOnlyFields( { 'D2_COD','D2_QUANT','D2_TOTAL' } )
oBrwMeioD:Activate()
//
// Relacionamento entre os Paineis

oRelacSD2:= FWBrwRelation():New()
//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_ITEM                                                                                                                                                                                                      
//oRelacSD2:AddRelation( oBrwMeioE, oBrwMeioD, { { 'D2_FILIAL', 'F2_FILIAL' }, {'D2_DOC' , 'F2_DOC'  }, {'D2_SERIE' , 'F2_SERIE'  },{'D2_CLIENTE' , 'F2_CLIENTE'  },{'D2_LOJA' , 'F2_LOJA'  }} )
oRelacSD2:AddRelation( oBrwMeioE, oBrwMeioD, {  { 'D2_FILIAL', 'F2_FILIAL' },{'D2_DOC' , 'F2_DOC'  }, {'D2_SERIE' , 'F2_SERIE'  },{'D2_CLIENTE' , 'F2_CLIENTE'  },{'D2_LOJA' , 'F2_LOJA'  }} )
oRelacSD2:Activate()

//Baixo - produto
//
oBrwDown:= FWMBrowse():New()
oBrwDown:SetOwner(oPanelDown)
oBrwDown:SetDescription( 'PRODUTO' )
oBrwDown:SetMenuDef( '' )
// Referencia vazia para que nao exiba nenhum botao
oBrwDown:DisableDetails()
oBrwDown:SetAlias( 'SB1' )
oBrwDown:SetProfileID( '4' )
//oBrwMeioD:SetOnlyFields( { 'D2_FILIAL','D2_COD','D2_QUANT','D2_TOTAL' } )
oBrwDown:SetOnlyFields( { 'B1_UM','B1_DESC' } )
oBrwDown:Activate()
//
// Relacionamento entre os Paineis

oRelacSB1:= FWBrwRelation():New()
//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_ITEM                                                                                                                                                                                                      
//oRelacSD2:AddRelation( oBrwMeioE, oBrwMeioD, { { 'D2_FILIAL', 'F2_FILIAL' }, {'D2_DOC' , 'F2_DOC'  }, {'D2_SERIE' , 'F2_SERIE'  },{'D2_CLIENTE' , 'F2_CLIENTE'  },{'D2_LOJA' , 'F2_LOJA'  }} )
oRelacSB1:AddRelation( oBrwMeioD, oBrwDown, {  {'B1_COD' , 'D2_COD'  }} )
oRelacSB1:Activate()
Activate MsDialog oDlgPrinc Center

Return NIL

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"            OPERATION 1 ACCESS 0 DISABLE MENU
//ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.SENTAX_MFAT003" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Imprimir"     ACTION "VIEWDEF.SENTAX_MFAT003" OPERATION 8 ACCESS 0


Return aRotina

Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruSA1 := FWFormStruct( 1, 'SA1' )
Local oStruSF2 := FWFormStruct( 1, 'SF2' )
Local oStruSD2 := FWFormStruct( 1, 'SD2' )
Local oStruSB1 := FWFormStruct( 1, 'SB1' )
Local oModel // Modelo de dados construído
Local oModel	:= MPFormModel ():New('SENTAX_MFAT003',,/*{ |oModel| LA730POST( oModel )}*/,/*{  |oModel| LA730CON(oModel)}*/)	// Modelo de Dados 

// Cria o objeto do Modelo de Dados
// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'SA1MASTER', /*cOwner*/, oStruSA1 )  

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'SF2DETAIL', 'SA1MASTER', oStruSF2 )
oModel:AddGrid( 'SD2DETAIL', 'SF2DETAIL', oStruSD2 )
oModel:AddGrid( 'SB1DETAIL', 'SD2DETAIL', oStruSB1 )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'SF2DETAIL', { {'F2_CLIENTE' , 'A1_COD'  },{'F2_LOJA' , 'A1_LOJA'  } }, SF2->( IndexKey( 1 ) ) )

oModel:SetRelation( 'SD2DETAIL', { { 'D2_FILIAL', 'F2_FILIAL' },{'D2_DOC' , 'F2_DOC'  }, {'D2_SERIE' , 'F2_SERIE'  },{'D2_CLIENTE' , 'F2_CLIENTE'  },{'D2_LOJA' , 'F2_LOJA'  }  }, SF2->( IndexKey( 1 ) ) )

oModel:SetRelation( 'SB1DETAIL', { {'D2_COD' , 'B1_COD'  }  }, SB1->( IndexKey( 1 ) ) )
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( 'Notas Fiscais' )
// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'SA1MASTER' ):SetDescription( 'Clientes' )
oModel:GetModel( 'SF2DETAIL' ):SetDescription( 'Notas Fiscais' )
oModel:GetModel( 'SD2DETAIL' ):SetDescription( 'Itens da Nota Fiscal' )
oModel:GetModel( 'SB1DETAIL' ):SetDescription( 'Produto' )

// Retorna o Modelo de dados   
removeCampos(oStruSF2)
remCpoSD2(oStruSD2)
oModel:AddFields( 'SF2DETAIL', /*cOwner*/, oStruSF2 )
oModel:AddFields( 'SD2DETAIL', /*cOwner*/, oStruSD2 )    
oModel:AddFields( 'SB1DETAIL', /*cOwner*/, oStruSB1 )    

Return oModel

Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'SENTAX_MFAT003' )
// Cria as estruturas a serem usadas na View
Local oStruSA1 := FWFormStruct( 2, 'SA1' )
Local oStruSF2 := FWFormStruct( 2, 'SF2' )
Local oStruSF2 := FWFormStruct( 2, 'SD2' )  
Local oStruSB1 := FWFormStruct( 2, 'SB1' )
// Interface de visualização construída
Local oView
Local nOperation := oModel:GetOperation()
// Cria o objeto de View
oView := FWFormView():New()
// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_SA1', oStruSA1, 'SA1MASTER' )
//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_SF2', oStruSF2, 'SF2DETAIL' )
oView:AddGrid( 'VIEW_SD2', oStruSD2, 'SD2DETAIL' ) 
oView:AddGrid( 'VIEW_SB1', oStruSB1, 'SB1DETAIL' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'MEIO', 30 )
oView:CreateHorizontalBox( 'BAIXO', 40 )
// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_SA1', 'SUPERIOR' )

oView:SetOwnerView( 'VIEW_SF2', 'MEIOE' )   

oView:SetOwnerView( 'VIEW_SD2', 'MEIOD' )

oView:SetOwnerView( 'VIEW_SD2', 'DOWN' )
// Retorna o objeto de View criado

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} removeCampos
ViewDef da rotina

@author
@param   oStruSF1 - Estrutura da view da tabela SF2
@since   11/12/2013
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function removeCampos(oStruSF2)

Local aAreaSX3  := SX3->(GetArea())
//CHAVE: F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA                                                                                                                                                                                                              
Local cCposView := 	"F2_FILIAL|F2_DOC|F2_SERIE|F2_CLIENTE|F2_LOJA|F2_EMISSAO|F2_VALBRUT|"

Local cSX3CPO

//SX3->(dbsetorder(1))
//SX3->(dbseek("SF2"))

//While ( SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == 'SF2' )
	
//	cSX3CPO := alltrim(SX3->X3_CAMPO)
//	If ( cSX3CPO $ cCposView )
//		SX3->(dbSkip())
//		LOOP
//	EndIf
	
//	oStruSF2:RemoveField(cSX3CPO)
	
//	SX3->(dbSkip())
//End

//SX3->(RestArea(aAreaSX3))

Return     


//-------------------------------------------------------------------
/*/{Protheus.doc} removeCampos
ViewDef da rotina

@author
@param   oStruSF1 - Estrutura da view da tabela SD2
@since   19/12/2013
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function remCpoSD2(oStruSD2)

Local aAreaSX3  := SX3->(GetArea())
//CHAVE: D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA                                                                                                                                                                                                              
Local cCposView := 	"D2_COD|D2_QUANT|D2_UM|D2_TOTAL"

Local cSX3CPO

//SX3->(dbsetorder(1))
//SX3->(dbseek("SD2"))

//While ( SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == 'SD2' )
	
//	cSX3CPO := alltrim(SX3->X3_CAMPO)
//	If ( cSX3CPO $ cCposView )
//		SX3->(dbSkip())
//		LOOP
//	EndIf
	
//	oStruSD2:RemoveField(cSX3CPO)
	
//	SX3->(dbSkip())
//End

//SX3->(RestArea(aAreaSX3))

Return