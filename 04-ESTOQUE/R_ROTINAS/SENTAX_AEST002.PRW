#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} AEST002
Cadastro de Grupos de Embalagens
                
@sample		U_AEST002()

@author		Alessandro Smaha
@since		05/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AEST002()

Local oBrowse 		:= Nil

Private cCadastro	:= "Grupo Embalagem de Risco"
Private nOpca      	:= 0
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z14")
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

Return oBrowse      


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados
                
@sample		ModelDef()

@return 	oModel - Objeto do Modelo de Dados

@author		Alessandro Smaha
@since		05/03/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStru 	:= FWFormStruct(1,"Z14" )

oModel := MPFormModel():New('AEST002P')
oModel:AddFields( "Z14MASTER", /*cOwner*/, oStru )
oModel:SetPrimaryKey( { "Z14_FILIAL", "Z14_CODGRP"} )
oModel:SetDescription(cCadastro)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface 
                
@sample		ViewDef()

@return 	oView - Objeto da Interface

@author		Alessandro Smaha
@since		05/03/2015   
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
 
Local oModel	:= FWLoadModel( 'SENTAX_AEST002' )
Local oStru		:= FWFormStruct( 2, "Z14" )
Local oView		:= Nil

oView:= FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW', oStru, "Z14MASTER" )
oView:CreateHorizontalBox( 'TELA', 100 )
oView:SetOwnerView( 'VIEW', 'TELA' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de opções
                
@sample		ViewDef()

@return 	aRotina - Array com opções do menu

@author		Alessandro Smaha
@since		05/03/2015   
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
       
ADD OPTION aRotina TITLE "Pesquisar"   			ACTION 'VIEWDEF.SENTAX_AEST002' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"  			ACTION 'VIEWDEF.SENTAX_AEST002' 	OPERATION 2 ACCESS 0  
ADD OPTION aRotina TITLE "Incluir"     			ACTION 'VIEWDEF.SENTAX_AEST002' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     			ACTION 'VIEWDEF.SENTAX_AEST002' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     			ACTION 'VIEWDEF.SENTAX_AEST002' 	OPERATION 5 ACCESS 0

Return aRotina