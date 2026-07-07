#include "protheus.ch"
#INCLUDE 'FWMVCDEF.CH'

User Function MEST002()
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft, oBrowseRight
Local oRelacSBZ
Private oDlgPrinc

Define MsDialog oDlgPrinc Title 'Produtos x Indicadores' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
//
// Cria o conteiner onde serão colocados os browses
//
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )
//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 50, .F. )
// Cria uma "linha" com 25% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
// Pego o objeto desse pedaço do container
//
// Painel Inferior
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oFWLayer:AddLine( 'INFERIOR', 50, .F. )
oFWLayer:AddCollumn( 'BAIXO',  100, .T., 'INFERIOR' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelBaixo := oFWLayer:GetColPanel( 'BAIXO', 'INFERIOR' )  // Pego o objeto do pedaço INFERIOR
//
// FWmBrowse Superior
//
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )
// Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( "Produtos sem Bloqueio" )
oBrowseUp:SetAlias( 'SB1' )
//oBrowseUp:AddLegend( "Z2_SIT='1'", "RED", "Bloqueado" )
//oBrowseUp:AddLegend( "Z2_SIT='2'", "GREEN" , "Liberado" )
_cFil := "B1_MSBLQL !='1'"

//filtro
oBrowseUp:SetFilterDefault( _cFil )
oBrowseUp:SetMenuDef( 'MEST002' )
oBrowseUp:DisableDetails()
// Define de onde virao os botoes deste browse
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()
oBrowseUp:Activate()
//
// Inferio-Periodos
//
oBrowseBaixo:= FWMBrowse():New()
oBrowseBaixo:SetOwner( oPanelBaixo)
oBrowseBaixo:SetDescription( 'Avaliações' )
oBrowseBaixo:SetMenuDef( 'SENTAX_MEST002' )
// Referencia vazia para que nao exiba nenhum botao
oBrowseBaixo:DisableDetails()
oBrowseBaixo:SetAlias( 'SBZ' )
oBrowseBaixo:SetProfileID( '2' )

oBrowseBaixo:Activate()
//
// Relacionamento entre os Paineis

oRelacSBZ:= FWBrwRelation():New()

oRelacSBZ:AddRelation( oBrowseUp, oBrowseBaixo, { {'BZ_COD' , 'B1_COD'  }} )
oRelacSBZ:Activate()

Activate MsDialog oDlgPrinc Center

Return NIL

/*Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"            OPERATION 1 ACCESS 0 DISABLE MENU
ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.SENTAX_MEST002" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Imprimir"     ACTION "VIEWDEF.SENTAX_MEST002" OPERATION 8 ACCESS 0


Return aRotina
  */

Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruSB1 := FWFormStruct( 1, 'SB1' )
Local oStruSBZ := FWFormStruct( 1, 'SBZ' )
Local oModel // Modelo de dados construído
Local _cCodigo
Local _ni:=0
Local oModel	:= MPFormModel ():New('SENTAX_MEST002',,/*{ |oModel| LA730POST( oModel )}*/,/*{  |oModel| LA730CON(oModel)}*/)	// Modelo de Dados 

// Cria o objeto do Modelo de Dados
// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'SB1MASTER', /*cOwner*/, oStruSB1 )  

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'SBZDETAIL', 'SB1MASTER', oStruSBZ )

// Faz relacionamento entre os componentes do model
//oModel:SetRelation( 'SBZDETAIL', { { 'BZ_FILIAL', 'xFilial( "SBZ" )' }, {'BZ_COD' , 'B1_COD'  } }, SBZ->( IndexKey( 1 ) ) )
oModel:SetRelation( 'SBZDETAIL', { {'BZ_COD' , 'B1_COD'  } }, SBZ->( IndexKey( 1 ) ) )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( 'Avaliações' )
// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'SB1MASTER' ):SetDescription( 'Produtos' )
oModel:GetModel( 'SBZDETAIL' ):SetDescription( 'Indicadores' )

// Retorna o Modelo de dados
oModel:AddFields( 'SBZDETAIL', /*cOwner*/, oStruSBZ )

Return oModel

Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'SENTAX_MEST002' )
// Cria as estruturas a serem usadas na View
Local oStruSB1 := FWFormStruct( 2, 'SB1' )
Local oStruSBZ := FWFormStruct( 2, 'SBZ' )
// Interface de visualização construída
Local oView
Local nOperation := oModel:GetOperation()
// Cria o objeto de View
oView := FWFormView():New()
// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_SBZ', oStruSB1, 'SB1MASTER' )
//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_SBZ', oStruSBZ, 'SBZDETAIL' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 50 )
oView:CreateHorizontalBox( 'PERIODO', 50 )
// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_SB1', 'Produto' )

oView:SetOwnerView( 'VIEW_SBZ', 'Indicadores' )
// Retorna o objeto de View criado

Return oView



