#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "topconn.ch"

User Function CADZA2()
Local aArea		:= Getarea()
Local oBrowse

//Private bMstJson     := {|| Aviso("JSON", U_fGrJson(ZA2->ZA2_COD), {'OK'}, 03) }
Private bMstJson     := {|| EECVIEW( U_fGrJson(ZA2->ZA2_COD) ) }

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("ZA2")
oBrowse:SetDescription("Layout JSon Integração WS CyberLog")
oBrowse:SetMenuDef("WMS_LAYOUT")
oBrowse:DisableDetails()

oBrowse:Activate()
RestArea(aArea)

Return Nil


Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"  		ACTION 'PesqBrw' 					OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 		ACTION "VIEWDEF.WMS_LAYOUT"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    		ACTION "VIEWDEF.WMS_LAYOUT"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    		ACTION "VIEWDEF.WMS_LAYOUT"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    		ACTION "VIEWDEF.WMS_LAYOUT"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Mostar LayOut"   	ACTION "eval(bMstJson)"				OPERATION 9 ACCESS 0
	
Return aRotina


Static Function ModelDef()
Local oModel:=  MPFormModel():New('MDCADZA2')

// Cria as estruturas a serem usadas no Modelo de Dados
Local oStr1:= FWFormStruct(1,'ZA2')
Local oStr2:= FWFormStruct(1,'ZA3')

// Adiciona ao modelo um componente de formulário
oModel:addFields('ZA2MASTER',,oStr1)
oModel:addGrid('ZA3ITENS','ZA2MASTER',oStr2)

oModel:SetPrimaryKey({})

// Faz relacionamento entre os componentes do model
oModel:SetRelation('ZA3ITENS', { { 'ZA3_FILIAL', 'FwxFilial("ZA2")' }, { 'ZA3_COD', 'ZA2_COD' } }, ZA3->(IndexKey(2)) )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription('Layout JSon Integração WS CyberLog')

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:getModel('ZA2MASTER'):SetDescription('Cabeçalho WS')
oModel:getModel('ZA3ITENS'):SetDescription('TAG Layout JSON')
oModel:GetModel('ZA3ITENS'):SetUniqueLine( { 'ZA3_FILIAL', 'ZA3_TAG' } )

Return oModel

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'ZA2')
Local oStr2:= FWFormStruct(2, 'ZA3')

oView := FWFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( 'BOXZA2', 35 )
oView:CreateHorizontalBox( 'BOXZA3', 65 )

oStr2:RemoveField( 'ZA3_COD' )

oView:AddField('VIEW_ZA2' , oStr1,'ZA2MASTER' )

oView:AddGrid('VIEW_ZA3' , oStr2,'ZA3ITENS')  
oView:AddIncrementField('VIEW_ZA3', 'ZA3_ORDEM')

oView:SetOwnerView('VIEW_ZA2','BOXZA2')
oView:SetOwnerView('VIEW_ZA3','BOXZA3')


Return oView

