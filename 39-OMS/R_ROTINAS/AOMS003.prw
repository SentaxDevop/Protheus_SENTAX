#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} AOMS003
Browser Cadastro de Ocorrências

@author d0d0

@since 27/01/2014
@version 1.0

/*/
//-------------------------------------------------------------------

User Function AOMS003

Local oBrowse 

U_AOMS003A()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('Z06') 
 

// Titulo da Browse 
oBrowse:SetDescription('Ocorrências de Entrega') 
 
// Opcionalmente pode ser desligado a exibição dos detalhes 
oBrowse:DisableDetails() 
 
// Ativação da Classe 
oBrowse:Activate()

Return




//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Thiago Henrique dos Santos

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function ModelDef()
Local oModel 
Local oStru:= FWFormStruct( 1, 'Z06' )

oModel := MPFormModel():New('AOMS003M',,{|oModel| TudoOK(oModel)})

oStru:SetProperty('Z06_CODOCO',MODEL_FIELD_VALID,{|| ExistChav("Z06",oModel:GetValue('Z06MASTER','Z06_CODOCO'),1)})
oStru:SetProperty('Z06_CODOCO' , MODEL_FIELD_WHEN, {||oModel:GetOperation() == MODEL_OPERATION_INSERT}) 
oStru:SetProperty('Z06_DESOCO' , MODEL_FIELD_WHEN, {||oModel:GetOperation() == MODEL_OPERATION_INSERT})

oModel:AddFields( 'Z06MASTER', /*cOwner*/, oStru )

//Define a Chave Primaria do Model Principal
oModel:SetPrimaryKey( { "Z06_FILIAL", "Z06_CODOCO"} )	  

oModel:SetDescription( 'Ocorrências de entrega' ) 

Return oModel




//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface para visualizar os históricos

@author Thiago Henrique dos Santos

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function ViewDef()
 
Local oModel := FWLoadModel( 'AOMS003' ) 
Local oStru  := FWFormStruct( 2, 'Z06' ) 
Local oView  
 
// Cria o objeto de View 
oView := FWFormView():New()

oView:SetModel( oModel ) 

oView:AddField( 'VIEW', oStru, 'Z06MASTER' ) 
 
 
// Cria um "box" horizontal para receber cada elemento da view 
oView:CreateHorizontalBox( 'TELA', 100 ) 
 
 
// Relaciona o identificador (ID) da View com o "box" para exibição 
oView:SetOwnerView( 'VIEW', 'TELA' ) 
 
 
// Retorna o objeto de View criado 

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Definição do Menu

@author Thiago Henrique dos Santos

@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef() 

 
Return FWMVCMenu( 'AOMS003' )



//-------------------------------------------------------------------
/*/{Protheus.doc} AOMS003A
Ajusta Z06 com os padrões

@author Thiago Henrique dos Santos

@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

User Function AOMS003A()

DbSelectArea("Z06")
Z06->(DbSetOrder(1))

If !Z06->(Dbseek(xFilial("Z06")+"001"))

	RecLock("Z06",.T.)
	Z06->Z06_FILIAL := xFilial("Z06")
	Z06->Z06_CODOCO := "001"
	Z06->Z06_DESOCO := "Baixa de Romaneio"
	Z06->Z06_TPCOD := "3"
	Z06->(MsUnlock())
	

Endif


If !Z06->(Dbseek(xFilial("Z06")+"002"))

	RecLock("Z06",.T.)
	Z06->Z06_FILIAL := xFilial("Z06")
	Z06->Z06_CODOCO := "002"
	Z06->Z06_DESOCO := "Baixa de NF por Manutenção"
	Z06->Z06_TPCOD := "3"
	Z06->(MsUnlock())

Endif  


If !Z06->(Dbseek(xFilial("Z06")+"003"))

	RecLock("Z06",.T.)
	Z06->Z06_FILIAL := xFilial("Z06")
	Z06->Z06_CODOCO := "003"
	Z06->Z06_DESOCO := "Inclusão Automática de Romaneio"
	Z06->Z06_TPCOD := "1"
	Z06->(MsUnlock())

Endif  

If !Z06->(Dbseek(xFilial("Z06")+"004"))

	RecLock("Z06",.T.)
	Z06->Z06_FILIAL := xFilial("Z06")
	Z06->Z06_CODOCO := "004"
	Z06->Z06_DESOCO := "Cancelamento de Baixa de Romaneio"
	Z06->Z06_TPCOD := "4"
	Z06->(MsUnlock())

Endif

If !Z06->(Dbseek(xFilial("Z06")+"005"))

	RecLock("Z06",.T.)
	Z06->Z06_FILIAL := xFilial("Z06")
	Z06->Z06_CODOCO := "005"
	Z06->Z06_DESOCO := "Volume Alterado no Momento do Romaneio"
	Z06->Z06_TPCOD := "5"
	Z06->(MsUnlock())

Endif

Return
  
 
 //-------------------------------------------------------------------
/*/{Protheus.doc} TudoOK
Pós Validação TudoOK do Modelo

@author Thiago Henrique dos Santos

@param oModel - Modelo de Dados
@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TudoOK(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE

	If oModel:GetValue('Z06MASTER','Z06_CODOCO') $ "001x002x003x004x005"
	
		Help( ,, 'Help',, 'Não é permitido excluir ocorrências padrões.', 1, 0 )
		lRet := .F. 
	
	Else
	
		DbSelectArea("Z05")
		Z05->(DbSetOrder(5))
		
		iF Z05->(DbSeek(oModel:GetValue('Z06MASTER','Z06_CODOCO')))
			Help( ,, 'Help',, 'Ocorrência já gerou histórico, não é permitido excluir.', 1, 0 )
			lRet := .F. 
		
		Endif
	
	Endif
	
ElseIf nOperation == MODEL_OPERATION_UPDATE

	If oModel:GetValue('Z06MASTER','Z06_CODOCO') $ "001x002x003x004x005"
	
		Help( ,, 'Help',, 'Não é permitido alterar ocorrências padrões.', 1, 0 )
		lRet := .F. 
		
	Else
	
		DbSelectArea("Z05")
		Z05->(DbSetOrder(5))
		
		iF Z05->(DbSeek(oModel:GetValue('Z06MASTER','Z06_CODOCO')))
			Help( ,, 'Help',, 'Ocorrência já gerou histórico, não é permitido alterar.', 1, 0 )
			lRet := .F. 
		
		Endif
	
	Endif
	
Endif




Return lRet