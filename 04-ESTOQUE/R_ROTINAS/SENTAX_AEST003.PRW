#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"    
#INCLUDE "SHELL.CH"   
#INCLUDE "REPORT.CH"    
#INCLUDE "TOPCONN.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} AEST003
Cadastro de Classe, SubClasse e Grupo de Embalagem
                
@sample		U_AEST003()

@author		Alessandro Smaha
@since		05/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AEST003()

Local oBrowse 		:= Nil

Private cCadastro	:= "Classe, SubClasse e Grupo de Embalagem"
Private nOpca      	:= 0
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z13")
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
Local oStru 	:= FWFormStruct(1,"Z13" )

oModel := MPFormModel():New('AEST003P')
oModel:AddFields( "Z13MASTER", /*cOwner*/, oStru )
oModel:SetPrimaryKey( { "Z13_FILIAL", "Z13_CODCLA", "Z13_CODSUB"} )
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
 
Local oModel	:= FWLoadModel( 'SENTAX_AEST003' )
Local oStru		:= FWFormStruct( 2, "Z13" )
Local oView		:= Nil

oView:= FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW', oStru, "Z13MASTER" )
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
       
ADD OPTION aRotina TITLE "Pesquisar"   			ACTION 'VIEWDEF.SENTAX_AEST003' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"  			ACTION 'VIEWDEF.SENTAX_AEST003' 	OPERATION 2 ACCESS 0  
ADD OPTION aRotina TITLE "Incluir"     			ACTION 'VIEWDEF.SENTAX_AEST003' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     			ACTION 'VIEWDEF.SENTAX_AEST003' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     			ACTION 'VIEWDEF.SENTAX_AEST003' 	OPERATION 5 ACCESS 0

Return aRotina