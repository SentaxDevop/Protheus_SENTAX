#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK004
Cadastro Segmento x Produto

@sample		U_ATMK004()

@author		Alessandro Smaha
@since		10/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ATMK004()

Local oBrowse 		:= Nil

Private cCadastro	:= "Segmento x Produto"
Private nOpca      	:= 0
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z10")
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

Return oBrowse


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados

@sample		ModelDef()

@return 	oModel - Objeto do Modelo de Dados

@author		Alessandro Smaha
@since		10/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStru 	:= FWFormStruct(1,"Z10" )

oModel := MPFormModel():New('ATMK004P',,{ |oModel| fValidPos(oModel) })
oModel:AddFields( "Z10MASTER", /*cOwner*/, oStru )
oModel:SetPrimaryKey( { "Z10_FILIAL", "Z10_PRODUT", "Z10_SEGMEN"} )
oModel:SetDescription(cCadastro)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface

@sample		ViewDef()

@return 	oView - Objeto da Interface

@author		Alessandro Smaha
@since		10/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FWLoadModel( 'SENTAX_ATMK004' )
Local oStru		:= FWFormStruct( 2, "Z10" )
Local oView		:= Nil

oView:= FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW', oStru, "Z10MASTER" )
oView:CreateHorizontalBox( 'TELA', 100 )
oView:SetOwnerView( 'VIEW', 'TELA' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de opções

@sample		ViewDef()

@return 	aRotina - Array com opções do menu

@author		Alessandro Smaha
@since		10/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"   			ACTION 'VIEWDEF.SENTAX_ATMK004' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"  			ACTION 'VIEWDEF.SENTAX_ATMK004' 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"     			ACTION 'VIEWDEF.SENTAX_ATMK004' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     			ACTION 'VIEWDEF.SENTAX_ATMK004' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     			ACTION 'VIEWDEF.SENTAX_ATMK004' 	OPERATION 5 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} fValidPos
Validação antes de gravar

@sample		fValidPos

@author		Alessandro Smaha
@since		10/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fValidPos(oModel)
             
Local cMsg		:= ""
Local lRetOk 	:= .T. 
Local cCodPro	:= oModel:GetValue("Z10MASTER","Z10_PRODUT")
Local cCodSeg	:= oModel:GetValue("Z10MASTER","Z10_SEGMEN") 

If !Empty(cCodPro) .AND. !Empty(cCodSeg) 
	                 
	DbSelectArea("Z10")
	Z10->(DbSetOrder(1)) // Z10_FILIAL+Z10_PRODUT+Z10_SEGMEN
	If Z10->(DbSeek(xFilial("Z10")+cCodPro+cCodSeg))
		cMsg := "Registro já existe para o produto e segmento informado!"
		Help( ,, 'Atenção',, cMsg, 1, 0 )	
		lRetOk := .F.		
	EndIf 
	
EndIf

Return lRetOk



//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK004P
Ponto de entrada após a gravação do registro para atualizar a 
data e hora de alteração

@sample		ATMK004P

@author		Alessandro Smaha
@since		10/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ATMK004P()

Local aParam 	:= PARAMIXB
Local xRet 		:= .T.
Local oObj 		:= ""
Local cIdPonto	:= ""
Local cIdModel 	:= ""

If aParam <> NIL
	
	oObj     := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]
	
	If cIdPonto == 'MODELCOMMITNTTS' // Após a gravação total do modelo e dentro da transação.
		
		RecLock("Z10",.F.)    
			Z10->Z10_XDALTE := dDataBase                                                                           
			Z10->Z10_XHALTE := Substr(Time(),1,5)
		Z10->(MsUnLock())  
		
	EndIf
	
EndIf

Return xRet