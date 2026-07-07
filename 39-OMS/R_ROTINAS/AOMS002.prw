#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Carrega Modelo de dados do romaneio

@author Thiago Henrique dos Santos

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel := FWLoadModel("AOMS001")



Return  oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface para visualizar os históricos

@author Thiago Henrique dos Santos

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function ViewDef()
 
Local oModel := FWLoadModel( 'AOMS002' ) 
Local oStruItem := FWFormStruct( 2, 'Z05' )  
Local oStruCab  := FWFormStruct( 2, 'Z03' ) 
Local oView  
 

// Cria o objeto de View 
oView := FWFormView():New() 

//retirando campos da view
oStruCab:RemoveField('Z03_FEZMT') 
oStruCab:RemoveField('Z03_ACD')

oStruItem:RemoveField('Z05_CODROM')
//oStruItem:RemoveField('Z04_CHKBRW')
 
// Define qual Modelo de dados será utilizado 
oView:SetModel( oModel ) 

oView:AddField( 'VIEW_CAB', oStruCab, 'Z03MASTER' ) 
 
//Adiciona no nosso View um controle do tipo Grid (antiga Getdados) 
oView:AddGrid( 'VIEW_ITEM', oStruItem, 'Z05DETAIL' )

//oView:AddIncrementField( 'VIEW_ITEM', 'Z04_SEQ' )  
 
// Cria um "box" horizontal para receber cada elemento da view 
oView:CreateHorizontalBox( 'SUPERIOR', 30 ) 
oView:CreateHorizontalBox( 'INFERIOR', 70 ) 
 
// Relaciona o identificador (ID) da View com o "box" para exibição 
oView:SetOwnerView( 'VIEW_CAB', 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_ITEM', 'INFERIOR' ) 
 
// Retorna o objeto de View criado 

Return oView

