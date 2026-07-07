#INCLUDE "PROTHEUS.CH"          
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"   
//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC004
Cadastro de Bônus Adicional 
                
@sample		U_ATEC004()

@author		Alessandro Smaha
@since		03/09/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ATEC004() 

Local oBrowse 		:= Nil
Local cUsrPerm		:= Alltrim(GetMv("ST_USRGTEC",.F.,"")) 

Private cCadastro	:= "Bônus Adicional"
Private nOpca      	:= 0
Private aRotina 	:= MenuDef()

If !RetCodUsr() $ cUsrPerm
	MsgAlert("Usuário sem permissão para acessar esta rotina! Verificar parâmetro de acesso!","Atenção - [ST_USRGTEC]")
    Return
EndIf

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z16")
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

Return oBrowse      


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados
                
@sample		ModelDef()

@author		Alessandro Smaha
@since		03/09/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStru 	:= FWFormStruct(1,"Z16" )  
Local aAux		:= {}

// GATILHOS
aAux := FWStruTrigger("Z16_TECNIC","Z16_NOME","Posicione('AA1',1,xFilial('AA1')+M->Z16_TECNIC,'AA1_NOMTEC')",.F.,,,)
oStru:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oModel := MPFormModel():New('ATEC004P', /*bPreValid*/ , { |oModel| fPosValid(oModel) }/*bPosValid*/ , /*bComValid*/ ,/*bCancel*/ )		

oModel:AddFields( "Z16MASTER", /*cOwner*/, oStru )
oModel:SetPrimaryKey( { "Z16_FILIAL", "Z16_TECNIC", "Z16_ANO", "Z16_MES" } )    // Z16_FILIAL+Z16_TECNIC+Z16_ANO+Z16_MES
oModel:SetDescription(cCadastro)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface
                
@sample		ViewDef()

@author		Alessandro Smaha
@since		03/09/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
 
Local oModel	:= FWLoadModel( 'SENTAX_ATEC004' )
Local oStru		:= FWFormStruct( 2, "Z16" )
Local oView		:= Nil

oView:= FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW', oStru, "Z16MASTER" )
oView:CreateHorizontalBox( 'TELA', 100 )
oView:SetOwnerView( 'VIEW', 'TELA' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de opções
                
@sample		MenuDef()

@author		Alessandro Smaha
@since		03/09/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
       
ADD OPTION aRotina TITLE "Pesquisar"   			ACTION 'VIEWDEF.SENTAX_ATEC004' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"  			ACTION 'VIEWDEF.SENTAX_ATEC004' 	OPERATION 2 ACCESS 0  
ADD OPTION aRotina TITLE "Incluir"     			ACTION 'VIEWDEF.SENTAX_ATEC004' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     			ACTION 'VIEWDEF.SENTAX_ATEC004' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     			ACTION 'VIEWDEF.SENTAX_ATEC004' 	OPERATION 5 ACCESS 0

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
Local cChave := oModel:GetValue("Z16MASTER","Z16_TECNIC") + oModel:GetValue("Z16MASTER","Z16_ANO") + oModel:GetValue("Z16MASTER","Z16_MES")

DbSelectArea("Z16")
Z16->(DbSetOrder(1)) // Z16_FILIAL+Z16_TECNIC+Z16_ANO+Z16_MES
If Z16->(DbSeek(xFilial("Z16")+cChave))
	HELP(Nil, 1, "Atenção", Nil, "Já existe meta para o técnico "+oModel:GetValue("Z16MASTER","Z16_TECNIC")+" neste período ("+;
			oModel:GetValue("Z16MASTER","Z16_MES")+"/"+oModel:GetValue("Z16MASTER","Z16_ANO")+")!" ,1,0)
	lRetOk := .F.  
EndIf 

If lRetOk
	If Val(oModel:GetValue("Z16MASTER","Z16_ANO")) < 2010
		HELP(Nil, 1, "Atenção", Nil, "Ano informado é inválido!" ,1,0)
		lRetOk := .F.  			
	EndIf
EndIf

Return lRetOk 