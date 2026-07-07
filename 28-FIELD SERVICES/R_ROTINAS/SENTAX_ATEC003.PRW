#INCLUDE "PROTHEUS.CH"          
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"   
//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC003
Cadastro de Produtos
                
@sample		U_ATEC003()

@author		Alessandro Smaha
@since		25/02/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ATEC003() 

Local oBrowse 		:= Nil
Local cUsrPerm		:= Alltrim(GetMv("ST_USRGTEC",.F.,"")) 

Private cCadastro	:= "Meta dos Técnicos"
Private nOpca      	:= 0
Private aRotina 	:= MenuDef()

If !RetCodUsr() $ cUsrPerm
	MsgAlert("Usuário sem permissão para acessar esta rotina! Verificar parâmetro de acesso!","Atenção - [ST_USRGTEC]")
    Return
EndIf

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z15")
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

Return oBrowse      


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados
                
@sample		ModelDef()

@author		Alessandro Smaha
@since		25/02/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStru 	:= FWFormStruct(1,"Z15" )
Local aAux		:= {}

oModel := MPFormModel():New('ATEC003P', /*bPreValid*/ , { |oModel| fPosValid(oModel) }/*bPosValid*/ , /*bComValid*/ ,/*bCancel*/ )	
oModel:AddFields( "Z15MASTER", /*cOwner*/, oStru )
oModel:SetPrimaryKey( { "Z15_FILIAL", "Z15_ANO", "Z15_MES" } )
oModel:SetDescription(cCadastro)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface
                
@sample		ViewDef()

@author		Alessandro Smaha
@since		25/02/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
 
Local oModel	:= FWLoadModel( 'SENTAX_ATEC003' )
Local oStru		:= FWFormStruct( 2, "Z15" )
Local oView		:= Nil

oView:= FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW', oStru, "Z15MASTER" )
oView:CreateHorizontalBox( 'TELA', 100 )
oView:SetOwnerView( 'VIEW', 'TELA' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de opções
                
@sample		MenuDef()

@author		Alessandro Smaha
@since		25/02/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
       
ADD OPTION aRotina TITLE "Pesquisar"   			ACTION 'VIEWDEF.SENTAX_ATEC003' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"  			ACTION 'VIEWDEF.SENTAX_ATEC003' 	OPERATION 2 ACCESS 0  
ADD OPTION aRotina TITLE "Incluir"     			ACTION 'VIEWDEF.SENTAX_ATEC003' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     			ACTION 'VIEWDEF.SENTAX_ATEC003' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     			ACTION 'VIEWDEF.SENTAX_ATEC003' 	OPERATION 5 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} fPosValid
Pré-validação do modelo
                
@sample		fPosValid()

@author		Alessandro Smaha
@since		03/09/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fPosValid(oModel)
  
Local lRetOk := .T.
Local cChave := oModel:GetValue("Z15MASTER","Z15_ANO") + oModel:GetValue("Z15MASTER","Z15_MES")

DbSelectArea("Z15")
Z15->(DbSetOrder(1)) // Z15_FILIAL+Z15_ANO+Z15_MES
If Z15->(DbSeek(xFilial("Z15")+cChave))
	HELP(Nil, 1, "Atenção", Nil, "Já existe meta para o período "+;
			oModel:GetValue("Z15MASTER","Z15_MES")+"/"+oModel:GetValue("Z15MASTER","Z15_ANO")+"!" ,1,0)
	lRetOk := .F.  
EndIf

If lRetOk
	If Val(oModel:GetValue("Z15MASTER","Z15_ANO")) < 2010
		HELP(Nil, 1, "Atenção", Nil, "Ano informado é inválido!" ,1,0)
		lRetOk := .F.  			
	EndIf
EndIf

Return lRetOk 