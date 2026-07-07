#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'



//-------------------------------------------------------------------
/*/{Protheus.doc} AOMS001
Browser Cadastro de Romaneio

@author d0d0

@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

User Function AOMS001()

Local oBrowse := FWMBrowse():New()


U_AOMS003A() // ajusta z06 com ocorrências padrao

 
 
oBrowse:SetAlias('Z03') 
 
// Definição da legenda 
oBrowse:AddLegend( "Z03_ACEFIN == '1' .AND. Z03_ACD <> '1' .AND. Z03_FEZMT <> '1'  "  , "GREEN", "Em Aberto - Inclusão Manual"  )
oBrowse:AddLegend( "Z03_ACEFIN == '1' .AND. Z03_ACD == '1' .AND. Z03_FEZMT <> '1'"  , "PINK", "Em Aberto - Inclusão Automática"  ) 
oBrowse:AddLegend( "Z03_ACEFIN == '1' .AND. Z03_FEZMT == '1'", "ORANGE", "Em Manutenção"  )
oBrowse:AddLegend( "Z03_ACEFIN == '2'", "RED", "Baixado"  )
oBrowse:AddLegend( "Z03_ACEFIN == '3'", "BLACK", "Baixa Cancelada"  )
 
 
 
// Titulo da Browse 
oBrowse:SetDescription('Cadastro de Romaneios') 
 
// Opcionalmente pode ser desligado a exibição dos detalhes 
//oBrowse:DisableDetails()
oBrowse:SetSeek(.T.) 


// Ativação da Classe 
oBrowse:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Thiago Henrique dos Santos

@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel 
Local oStruHist := FWFormStruct( 1, 'Z05' )
Local oStruCab:= FWFormStruct( 1, 'Z03' )
Local oStruItem := FWFormStruct( 1, 'Z04' )

oModel := MPFormModel():New('AOMS001M',{|| PreValMod (oModel)},{|| PosValMod (@oModel)})

//Inicialização de Campos
oStruCab:SetProperty('Z03_FILIAL',MODEL_FIELD_INIT,{||InitCampo(oModel,"Z03_FILIAL")})
oStruCab:SetProperty('Z03_NTRANS',MODEL_FIELD_INIT,{|| InitCampo(oModel,"Z03_NTRANS")})
oStruCab:SetProperty('Z03_DATA',MODEL_FIELD_INIT,{|| InitCampo(oModel,"Z03_DATA")})
oStruCab:SetProperty('Z03_HORA',MODEL_FIELD_INIT,{|| InitCampo(oModel,"Z03_HORA")})
oStruCab:SetProperty('Z03_IDUSER',MODEL_FIELD_INIT,{|| InitCampo(oModel,"Z03_IDUSER")})
oStruCab:SetProperty('Z03_ACEFIN',MODEL_FIELD_INIT,{|| InitCampo(oModel,"Z03_ACEFIN")})

oStruItem:SetProperty('Z04_FILIAL',MODEL_FIELD_INIT,{||InitCampo(oModel,"Z04_FILIAL")})
oStruItem:SetProperty('Z04_COD',MODEL_FIELD_INIT,{||oModel:GetValue('Z03MASTER','Z03_COD')})
oStruItem:SetProperty('Z04_DATA',MODEL_FIELD_INIT,{|| InitCampo(oModel,"Z04_DATA")})
oStruItem:SetProperty('Z04_HORA',MODEL_FIELD_INIT,{|| InitCampo(oModel,"Z04_HORA")})


oStruHist:SetProperty('Z05_DESOCO',MODEL_FIELD_INIT,{|| InitCampo(oModel,"Z05_DESOCO")})


//Validação de campos

oStruCab:SetProperty('Z03_TRANSP',MODEL_FIELD_VALID,{|| ValidCampo(oModel,"Z03_TRANSP")})

oStruItem:SetProperty('Z04_CHVNFE',MODEL_FIELD_VALID,{|| ValidCampo(oModel,"Z04_CHVNFE")})
oStruItem:SetProperty('Z04_NFISCA',MODEL_FIELD_VALID,{|| ValidCampo(oModel,"Z04_NFISCA")}) 
oStruItem:SetProperty('Z04_SERIE',MODEL_FIELD_VALID,{|| ValidCampo(oModel,"Z04_SERIE")})
oStruItem:SetProperty('Z04_CODOC',MODEL_FIELD_VALID,{|| ValidCampo(oModel,"Z04_CODOC")})
		

oStruItem:SetProperty('Z04_EXCLUI',MODEL_FIELD_WHEN,{|| oModel:GetOperation() == MODEL_OPERATION_UPDATE})




//GATILHO TRANSPORTADORA
oStruCab:AddTrigger('Z03_TRANSP'  , ;             		    	// [01] Id do campo de origem
			  		 'Z03_NTRANS'  , ;              		   	// [02] Id do campo de destino
					 { || .T. } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| Posicione("SA4",1,xFilial("SA4")+oModel:GetValue('Z03MASTER','Z03_TRANSP'),"A4_NOME") } )	// [04] Bloco de codigo de execução do gatilho

//gatihos chave nota fiscal

oStruItem:AddTrigger('Z04_CHVNFE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_NFISCA'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_CHVNFE'))} , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SUBSTR(oModel:GetValue('Z04DETAIL','Z04_CHVNFE'),26,9) } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_CHVNFE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_SERIE'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_CHVNFE'))} , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| PADR(CValToChar(VAL(SUBSTR(oModel:GetValue('Z04DETAIL','Z04_CHVNFE'),23,3))),3) } )	// [04] Bloco de codigo de execução do gatilho


//GATILHOS SERIE NOTA FISCAL

oStruItem:AddTrigger('Z04_SERIE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_CLIENT'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA'))} , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| Posicione("SF2",1,xFilial("SF2")+oModel:GetValue('Z04DETAIL','Z04_NFISCA')+;
					 									   oModel:GetValue('Z04DETAIL','Z04_SERIE'),"F2_CLIENTE") } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_SERIE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_LOJA'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_LOJA } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_SERIE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_TOTALV'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_VOLUME1 } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_SERIE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_VALOR'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_VALBRUT } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_SERIE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_CARORI'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_CARGA } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_SERIE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_CHVNFE'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_CHVNFE } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_SERIE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_DATA'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| dDataBase } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_SERIE'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_HORA'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SubStr(AllTrim(Time()),1,2)+SubStr(AllTrim(Time()),4,2) } )	// [04] Bloco de codigo de execução do gatilho


//GATILHOS NOTA FISCAL

oStruItem:AddTrigger('Z04_NFISCA'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_CLIENT'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE'))} , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| Posicione("SF2",1,xFilial("SF2")+oModel:GetValue('Z04DETAIL','Z04_NFISCA')+;
					 									   oModel:GetValue('Z04DETAIL','Z04_SERIE'),"F2_CLIENTE") } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_NFISCA'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_LOJA'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_LOJA } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_NFISCA'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_TOTALV'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_VOLUME1 } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_NFISCA'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_VALOR'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_VALBRUT } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_NFISCA'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_CARORI'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_CARGA } )	// [04] Bloco de codigo de execução do gatilho


oStruItem:AddTrigger('Z04_NFISCA'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_CHVNFE'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SF2->F2_CHVNFE } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_NFISCA'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_DATA'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| dDataBase } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_NFISCA'  , ;             		    	// [01] Id do campo de origem
			  		 'Z04_HORA'  , ;              		   	// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE')) } , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| SubStr(AllTrim(Time()),1,2)+SubStr(AllTrim(Time()),4,2) } )	// [04] Bloco de codigo de execução do gatilho


//Gatilhos ocorrencias de NF
oStruItem:AddTrigger('Z04_CODOC'  , ;             		    // [01] Id do campo de origem
			  		 'Z04_DESOCO'  , ;              		// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_CODOC'))} , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| Posicione("Z06",1,xFilial("Z06") + oModel:GetValue('Z04DETAIL','Z04_CODOC'),"Z06_DESOCO") } )	// [04] Bloco de codigo de execução do gatilho


oStruItem:AddTrigger('Z04_CODOC'  , ;             		    // [01] Id do campo de origem
			  		 'Z04_TPCOD'  , ;              		// [02] Id do campo de destino
					 { || !Empty(oModel:GetValue('Z04DETAIL','Z04_CODOC'))} , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| Z06->Z06_TPCOD } )	// [04] Bloco de codigo de execução do gatilho

oStruItem:AddTrigger('Z04_CODOC'  , ;             		    // [01] Id do campo de origem
			  		 'Z04_DESOCO'  , ;              		// [02] Id do campo de destino
					 { || Empty(oModel:GetValue('Z04DETAIL','Z04_CODOC'))} , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| "" } )	// [04] Bloco de codigo de execução do gatilho


oStruItem:AddTrigger('Z04_CODOC'  , ;             		    // [01] Id do campo de origem
			  		 'Z04_TPCOD'  , ;              		// [02] Id do campo de destino
					 { || Empty(oModel:GetValue('Z04DETAIL','Z04_CODOC'))} , ; 	   				  		// [03] Bloco de codigo de validação da execução do gatilho
					 { |x| "" } )	// [04] Bloco de codigo de execução do gatilho



oModel:AddFields( 'Z03MASTER', /*cOwner*/, oStruCab )


oModel:AddGrid( 'Z04DETAIL', 'Z03MASTER', oStruItem ,{| oModelGrid, nLine, cAction,cField | PreValLin(oModelGrid, nLine, cAction,cField, oModel) } ,;
				 { |oModelGrid| ValLinha(oModelGrid , @oModel)})
				 
oModel:AddGrid( 'Z05DETAIL', 'Z03MASTER', oStruHist )

oModel:GetModel( 'Z04DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'Z05DETAIL' ):SetOptional( .T. ) 
//oModel:GetModel( 'Z04DETAIL' ):SetNoDeleteLine( .T. )
//oModel:GetModel( 'Z05DETAIL' ):SetNoDeleteLine( .T. )

//nao permite linha duplicada de NF
 //oModel:GetModel( 'Z04DETAIL' ):SetUniqueLine( { 'Z04_NFISCA', 'Z04_SERIE' } ) 

oModel:SetRelation( 'Z04DETAIL', {{ 'Z04_FILIAL', 'Z03_FILIAL'},{ 'Z04_COD', 'Z03_COD' }},Z04->( IndexKey(1) ))
oModel:SetRelation( 'Z05DETAIL', {{ 'Z05_FILIAL', 'Z03_FILIAL'},{ 'Z05_CODROM', 'Z03_COD' }},Z05->( IndexKey(1) ))

//Define a Chave Primaria do Model Principal
oModel:SetPrimaryKey( { "Z03_FILIAL", "Z03_COD"} )	  

oModel:SetDescription( 'Cadastro de Romaneio' )

 oModel:SetVldActivate( { |oModel| VldActive( oModel ) } )
  
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Thiago Henrique dos Santos

@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function ViewDef()
 
Local oModel := FWLoadModel( 'AOMS001' ) 
Local oStruCab  := FWFormStruct( 2, 'Z03' ) 
Local oStruItem := FWFormStruct( 2, 'Z04' )  
Local oView  
 
// Cria o objeto de View 
oView := FWFormView():New() 

//retirando campos da view
oStruCab:RemoveField('Z03_FEZMT') 
oStruCab:RemoveField('Z03_ACD')


oStruItem:RemoveField('Z04_COD')
oStruItem:RemoveField('Z04_EXCLUI')
oStruItem:RemoveField('Z04_CODOC')
oStruItem:RemoveField('Z04_DESOCO')
oStruItem:RemoveField('Z04_TPCOD')

 
// Define qual Modelo de dados será utilizado 
oView:SetModel( oModel ) 

oView:AddField( 'VIEW_CAB', oStruCab, 'Z03MASTER' ) 
 
//Adiciona no nosso View um controle do tipo Grid (antiga Getdados) 
oView:AddGrid( 'VIEW_ITEM', oStruItem, 'Z04DETAIL' )

oView:AddIncrementField( 'VIEW_ITEM', 'Z04_SEQ' )  
 
// Cria um "box" horizontal para receber cada elemento da view 
oView:CreateHorizontalBox( 'SUPERIOR', 30 ) 
oView:CreateHorizontalBox( 'INFERIOR', 70 ) 
 
// Relaciona o identificador (ID) da View com o "box" para exibição 
oView:SetOwnerView( 'VIEW_CAB', 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_ITEM', 'INFERIOR' ) 
 
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
Local aRotina := {} 
 
 
	ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.AOMS001' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina Title 'Incluir'    		Action 'VIEWDEF.AOMS001' OPERATION 3 ACCESS 0 
	ADD OPTION aRotina Title 'Manutenção' 		Action 'VIEWDEF.AOMS004' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Baixar' 	  		Action 'U_AOMS001B' 	   OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Cancelar Baixa' 	Action 'U_AOMS001C'  OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Histórico'  		Action 'VIEWDEF.AOMS002' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina Title 'Excluir'    		Action 'VIEWDEF.AOMS001' OPERATION 5 ACCESS 0 
	ADD OPTION aRotina Title 'Imprimir'   		Action 'U_AOMS001D' OPERATION 2 ACCESS 0
	

 
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} InitCampo
Inicializador padrão para os campos do modelo

@author Thiago Henrique dos Santos

@param oModel - Modelo de Dados
@param cCampo - Nome do Campo
@return xResult - Valor do Inicializador padrão do campo

@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function InitCampo (oModel, cCampo)
Local xResult := ""
Local nOperation := oModel:GetOperation()

Local oModelItem := oModel:GetModel("Z04DETAIL")




If cCampo == "Z03_NTRANS"

	If !Empty(oModel:GetValue('Z03MASTER','Z03_TRANSP'))
	
		xResult := Posicione("SA4",1,xFilial("SA4")+oModel:GetValue('Z03MASTER','Z03_TRANSP'),"A4_NOME")
	
	Else
	
		xResult := ""
	
	Endif

ElseIf cCampo == "Z03_FILIAL"

	If nOperation == MODEL_OPERATION_INSERT
	
		xResult := xFilial("Z03")
	
	Else
	
		xResult := oModel:GetValue('Z03MASTER','Z03_FILIAL')
	
	Endif

ElseIf cCampo == "Z03_DATA"

	If nOperation == MODEL_OPERATION_INSERT
	
	
		xResult := dDataBase
	
	Else
	
		xResult := oModel:GetValue('Z03MASTER','Z03_DATA')
	
	Endif


ElseIf cCampo == "Z03_HORA"

	If nOperation == MODEL_OPERATION_INSERT
	
		xResult := AllTrim(Time())	
		xResult := SubStr(xResult,1,2)+SubStr(xResult,4,2)
			
	Else
	
		xResult := oModel:GetValue('Z03MASTER','Z03_HORA')
	
	Endif

ElseIf cCampo == "Z03_IDUSER"

	If nOperation == MODEL_OPERATION_INSERT
	
		xResult := RetCodUsr()		
			
	Else
	
		xResult := oModel:GetValue('Z03MASTER','Z03_IDUSER')
	
	Endif
//ZA3_ACEFIN

ElseIf cCampo == "Z03_ACEFIN"

	If nOperation == MODEL_OPERATION_INSERT
	
		xResult := "1"		
			
	Else
	
		xResult := oModel:GetValue('Z03MASTER','Z03_ACEFIN')
	
	Endif

ElseIf cCampo == "Z04_FILIAL" 

	//If nOperation == MODEL_OPERATION_INSERT
	
		xResult := xFilial("Z04")
	
	//Else
	//
	//	xResult := oModel:GetValue('Z04DETAIL','Z04_FILIAL')
	
//	Endif

ElseIf cCampo == "Z04_DATA" .AND. oModelItem:nLine > 0

	If nOperation == MODEL_OPERATION_INSERT
	
	
		xResult := dDataBase
	
	Else
	
		xResult := oModel:GetValue('Z04DETAIL','Z04_DATA')
	
	Endif

ElseIf cCampo == "Z04_HORA" .AND. oModelItem:nLine > 0

	If nOperation == MODEL_OPERATION_INSERT
	
		xResult := AllTrim(Time())	
		xResult := SubStr(xResult,1,2)+SubStr(xResult,4,2)
			
	Else
	
		xResult := oModel:GetValue('Z04DETAIL','Z04_HORA')
	
	Endif
	
	
ElseIf cCampo == "Z05_DESOCO" .AND. nOperation <> MODEL_OPERATION_INSERT

		DbSelectArea("Z05")
		If Z05->(!Eof()) 

			
			xResult := Posicione("Z06",1,xFilial("Z06")+Z05->Z05_CODOC,"Z06_DESOCO")	
		
		
	Endif

Endif


Return xResult




//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCampo
Validador para os campos do modelo

@author Thiago Henrique dos Santos

@param oModel - Modelo de Dados
@param cCampo - Nome do Campo
@return lRet - .T. se validado, .F. caso contrário

@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ValidCampo (oModel, cCampo)
Local lRet := .T.


If cCampo == "Z03_TRANSP"

	If !Empty(oModel:GetValue('Z03MASTER','Z03_TRANSP'))
	
		lRet := ExistCpo("SA4",oModel:GetValue('Z03MASTER','Z03_TRANSP'))
	Endif	
	
ElseIf cCampo == "Z04_CHVNFE"

	If !Empty(oModel:GetValue('Z04DETAIL','Z04_CHVNFE'))
	
		If len(Alltrim(oModel:GetValue('Z04DETAIL','Z04_CHVNFE'))) < 44
		
			Help( ,, 'Help',, 'Chave inválida', 1, 0 )
			lRet := .F.
			
			
		Else
		
			lRet := ExistCpo("SF2",SUBSTR(oModel:GetValue('Z04DETAIL','Z04_CHVNFE'),26,9)+;
					PADR(CValToChar(VAL(SUBSTR(oModel:GetValue('Z04DETAIL','Z04_CHVNFE'),23,3))),3))
		
		Endif
	
	
	Endif
	
ElseIf cCampo == "Z04_NFISCA" 

	If !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE')) .AND. !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA'))
	
		lRet := ExistCpo("SF2",oModel:GetValue('Z04DETAIL','Z04_NFISCA')+oModel:GetValue('Z04DETAIL','Z04_SERIE'))
		
		If lRet
		
			DbSelectArea("Z04")
			Z04->(DbSetOrder(2))
		
			lRet := Z04->(!DbSeek(xFilial("Z04")+oModel:GetValue('Z04DETAIL','Z04_NFISCA')+oModel:GetValue('Z04DETAIL','Z04_SERIE')))
			
			If !lRet
			
							
				Help( ,, 'Help',, 'Nota fiscal já utilizada em outro romaneio', 1, 0 )
			
			Endif
		
		Endif
		
	Endif	

ElseIf cCampo == "Z04_SERIE"

	If !Empty(oModel:GetValue('Z04DETAIL','Z04_NFISCA')) .AND. !Empty(oModel:GetValue('Z04DETAIL','Z04_SERIE'))
	
		lRet := ExistCpo("SF2",oModel:GetValue('Z04DETAIL','Z04_NFISCA')+oModel:GetValue('Z04DETAIL','Z04_SERIE'))
		
		If lRet
		
			DbSelectArea("Z04")
			Z04->(DbSetOrder(2))
		
			lRet := Z04->(!DbSeek(xFilial("Z04")+oModel:GetValue('Z04DETAIL','Z04_NFISCA')+oModel:GetValue('Z04DETAIL','Z04_SERIE')))
			
			If !lRet			
								
				Help( ,, 'Help',, 'Nota fiscal já utilizada em outro romaneio', 1, 0 )
			
			Endif
		
		Endif
		
	Endif	
ElseIf cCampo == "Z04_CODOC"

	If !Empty(oModel:GetValue('Z04DETAIL','Z04_CODOC'))
	
		If oModel:GetValue('Z04DETAIL','Z04_CODOC') $ "001x002x003x004x005"
			lRet := .F.
			Help( ,, 'Help',, 'Nota é permitido incluir manualmente uma ocorrência padrão', 1, 0 )
		
		Else 
		
			DbSelectArea("Z06")
			Z06->(DbSetOrder(1))
			lRet := Z06->(DbSeek(xFilial("Z06")+oModel:GetValue('Z04DETAIL','Z04_CODOC')))
		
					
		Endif
	
	
	Endif
	
		
Endif


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValLinha
Pós validação de linha
@Obs Utilizado também para totalizar as NFs do Romaneio

@author Thiago Henrique dos Santos

@param oModelGrid - Modelo de Grid de NFS
@param oModel     - Modelo de dados
@return lRet      - .T. Se validado , .F. Caso contrário 

@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ValLinha (oModelGrid, oModel)
Local lRet := .T.
Local nVolume := 0
Local nValor := 0
Local nI := 0
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE .AND. !oModelGrid:IsDeleted()

	//exclusao de item romaneado
	IF oModelGrid:GetValue("Z04_EXCLUI") .AND. !oModelGrid:IsInserted()  
	
		If Empty(oModelGrid:GetValue("Z04_CODOC"))
		
			lRet := .F.
			Help( ,, 'Help',, 'É obrigatório informar o campo Cod. Ocorr., indicando a ocorrência da exclusão.', 1, 0 )
		
		ElseIf oModelGrid:GetValue("Z04_TPCOD") <> "2"		
			
				lRet := .F.
				Help( ,, 'Help',, 'A ocorrência do campo Cod. Ocorr. deve ser do tipo Exclusão.', 1, 0 )			
					
		
		Endif
		
	ElseIf oModelGrid:IsInserted() .AND. !oModelGrid:GetValue("Z04_EXCLUI")
	
		If Empty(oModelGrid:GetValue("Z04_CODOC"))
		
			lRet := .F.
			Help( ,, 'Help',, 'É obrigatório informar o campo Cod. Ocorr., indicando a ocorrência da inclusão.', 1, 0 )
		
		ElseIf oModelGrid:GetValue("Z04_TPCOD") <> "1"		
			
				lRet := .F.
				Help( ,, 'Help',, 'A ocorrência do campo Cod. Ocorr. deve ser do tipo Inclusão.', 1, 0 )
				
		Endif
	
	ElseIf oModelGrid:IsUpdated() 
	
		DbSelectArea("Z04")
		Z04->(DbSetOrder(1))
		//Z04->(DbGoTop())
		iF Z04->(DbSeek(xFilial("Z04")+oModelGrid:GetValue("Z04_COD")+oModelGrid:GetValue("Z04_SEQ")))
		
			If Z04->Z04_TOTALV <> oModelGrid:GetValue("Z04_TOTALV")
			
				If Empty(oModelGrid:GetValue("Z04_CODOC"))
		
					lRet := .F.
					Help( ,, 'Help',, 'É obrigatório informar o campo Cod. Ocorr., indicando a ocorrência da alteração.', 1, 0 )
		
				ElseIf oModelGrid:GetValue("Z04_TPCOD") <> "5"		
			
					lRet := .F.
					Help( ,, 'Help',, 'A ocorrência do campo Cod. Ocorr. deve ser do tipo Alteração.', 1, 0 )
				
				Endif
				
			Else
			
				If !Empty(oModelGrid:GetValue("Z04_CODOC")) .AND. oModelGrid:GetValue("Z04_TPCOD") <> "6"
				
					lRet := .F.
					Help( ,, 'Help',, 'Não houve alteração na NF, a ocorrência deve ser do tipo Informativa.', 1, 0 )
				
				Endif 
			
			
			Endif
		
		Endif
	
	Endif

Endif




If lRet

	For nI := 1 to oModelGrid:Length()
	
		oModelGrid:GoLine(nI)
		
		If !oModelGrid:IsDeleted() .AND. !oModelGrid:GetValue("Z04_EXCLUI")
		
			nVolume += oModelGrid:GetValue('Z04_TOTALV')
			nValor +=  oModelGrid:GetValue('Z04_VALOR')		
		
		Endif
	
			
	Next nI
	
	oModel:SetValue('Z03MASTER', 'Z03_TOTALV', nVolume)
	oModel:SetValue('Z03MASTER', 'Z03_VALOR',  nValor)


Endif


Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PreValLin
Pré Validação de linha

@Obs Não permite alterar nota e séries já gravadas e valida ocorrências específicas.

@author Thiago Henrique dos Santos

@param oModelGrid - Modelo de Grid de NFS
@param nLine      - número da linha
@param cAction    - Ação Executada
@param cField     - Campo que executa a ação
@param oModel     - Modelo de dados 
@return lRet      - .T. Se validado , .F. Caso contrário 

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function PreValLin(oModelGrid, nLine, cAction,cField, oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()


If nOperation == MODEL_OPERATION_UPDATE .AND. oModel:GetValue("Z03MASTER","Z03_ACEFIN") == "2"

	Help( ,, 'Help',, 'Não é permitido alterar romaneio baixado', 1, 0 )

	lRet := .F.
	
Endif

If cAction == "DELETE" .AND. !oModelGrid:IsInserted() .AND. nOperation == MODEL_OPERATION_UPDATE

	If !IsInCallStack('PosValMod')

		Help( ,, 'Help',, 'Para deletar uma linha com uma NF já romaneada é necessário marcar a opção EXCLUI NF.', 1, 0 )

		lRet := .F.
	Endif

Endif

If cField == "Z04_NFISCA" .OR. cField == "Z04_SERIE" .OR. cField == "Z04_CHVNFE"

	If nOperation == MODEL_OPERATION_UPDATE .AND. cAction == "CANSETVALUE" .AND. !oModelGrid:IsInserted()
	
		lRet := .F.
			
	
	Endif

Endif

Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} AOMS001B
Chamada para Baixa de Romaneio


@author Thiago Henrique dos Santos

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

User Function AOMS001B()

DbSelectArea("Z03")

If Z03->Z03_ACEFIN == "2"

	Help( ,, 'Help',, 'O romaneio '+Z03->Z03_COD+' já está baixado. Não é possível baixar novamente.', 1, 0 )
	Return
	

Endif

If MsgYesNo("Deseja baixar o Romaneio "+Z03->Z03_COD+"?","Baixa de Romaneio")


	Processa({|| ProcBaixa() },"Processando Baixa")

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcBaixa
Processa Baixa de Romaneio


@author Thiago Henrique dos Santos

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ProcBaixa()

Local dData := dDatabase
Local cHora := Time()
Local cSeq  := 0
Local cAliasTemp := GetNextAlias()

cHora := Substr(cHora,1,2)+Substr(cHora,4,2)

ProcRegua(0)

IncProc()


BeginSql  Alias cAliasTemp

	SELECT MAX(Z05_SEQ) SEQUEN
	FROM   %Table:Z05% Z05
	WHERE 	Z05.Z05_FILIAL = %xFilial:Z05% AND
			Z05.Z05_CODROM = %Exp:Z03->Z03_COD% AND
			Z05.%NotDel%
			
EndSql

DbSelectArea(cAliasTemp)

(cAliasTemp)->(DbGoTop())

If !Empty((cAliasTemp)->SEQUEN)

	cSeq := Soma1((cAliasTemp)->SEQUEN)
	
Else

	cSeq := "001"


Endif

IncProc()

(cAliasTemp)->(DbCloseArea())	
			


Begin Transaction

	Reclock("Z03",.F.)
	Z03->Z03_ACEFIN := "2"
	Z03->(MsUnlock())
	
	DbSelectArea("Z05")

	DbSelectArea("Z04")
	Z04->(DbSetOrder(1))
	Z04->(DbSeek(xFilial("Z04")+Z03->Z03_COD))

	While Z04->(!Eof()) .AND. Z04->Z04_FILIAL == xFilial("Z04") .AND. Z04->Z04_COD == Z03->Z03_COD
		IncProc()
	
		If Empty(Z04->Z04_DTCONC)
		
			RecLock("Z04",.F.)
			Z04->Z04_DTCONC := dData
			Z04->(MsUnlock())
			
			RecLock("Z05",.T.)
			Z05->Z05_FILIAL := xFilial("Z05")
			Z05->Z05_CODROM := Z03->Z03_COD
			Z05->Z05_SEQ    := cSeq
			Z05->Z05_TPCOD  := "3"
			Z05->Z05_CODOC  := "002"
			Z05->Z05_NFISCA := Z04->Z04_NFISCA
			Z05->Z05_SERIE  := Z04->Z04_SERIE
			Z05->Z05_VALOR  := Z04->Z04_VALOR
			Z05->Z05_TOTALV := Z04->Z04_TOTALV
			Z05->Z05_DATA   := dData
			Z05->Z05_HORA	:= cHora
			Z05->Z05_IDUSER := RetCodUsr()
			Z05->(MsUnlock())
			cSeq := Soma1(cSeq)
			
		
		Endif
	
	
		Z04->(DbSkip())
		
	Enddo
	
	
	
	RecLock("Z05",.T.)
	Z05->Z05_FILIAL := xFilial("Z05")
	Z05->Z05_CODROM := Z03->Z03_COD
	Z05->Z05_SEQ    := cSeq
	Z05->Z05_TPCOD  := "3"
	Z05->Z05_CODOC  := "001"
	Z05->Z05_DATA   := dData
	Z05->Z05_HORA	:= cHora
	Z05->Z05_IDUSER := RetCodUsr()
	Z05->(MsUnlock())


End Transaction
Return




//------------------------------------------------------------------
/*/{Protheus.doc} AOMS001C
Chamada para Cancelar Baixa de Romaneio


@author Thiago Henrique dos Santos

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

User Function AOMS001c()

DbSelectArea("Z03")

If Z03->Z03_ACEFIN <> "2"

	Help( ,, 'Help',, 'O romaneio '+Z03->Z03_COD+' não está baixado. Não é possível cancelar baixa.', 1, 0 )
	Return
	

Endif

If MsgYesNo("Deseja cancelar baixa do Romaneio "+Z03->Z03_COD+"?","Cancelar Baixa")


	Processa({|| ProcCan() },"Processando Cancelamento de Baixa")

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCan
Processa Cancelamento de Baixa de Romaneio


@author Thiago Henrique dos Santos

@since 28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function ProcCan()

Local dData := dDatabase
Local cHora := Time()
Local cSeq  := 0
Local cAliasTemp := GetNextAlias()

cHora := Substr(cHora,1,2)+Substr(cHora,4,2)

ProcRegua(0)

IncProc()


BeginSql  Alias cAliasTemp

	SELECT MAX(Z05_SEQ) SEQUEN
	FROM   %Table:Z05% Z05
	WHERE 	Z05.Z05_FILIAL = %xFilial:Z05% AND
			Z05.Z05_CODROM = %Exp:Z03->Z03_COD% AND
			Z05.%NotDel%
			
EndSql

DbSelectArea(cAliasTemp)

(cAliasTemp)->(DbGoTop())

If !Empty((cAliasTemp)->SEQUEN)

	cSeq := Soma1((cAliasTemp)->SEQUEN)
	
Else

	cSeq := "001"


Endif

IncProc()

(cAliasTemp)->(DbCloseArea())	

Begin Transaction

	Reclock("Z03",.F.)
	Z03->Z03_ACEFIN := "3"
	Z03->(MsUnlock())
	IncProc()
    	
	DbSelectArea("Z05")
	
	RecLock("Z05",.T.)
	Z05->Z05_FILIAL := xFilial("Z05")
	Z05->Z05_CODROM := Z03->Z03_COD
	Z05->Z05_SEQ    := cSeq
	Z05->Z05_TPCOD  := "4"
	Z05->Z05_CODOC  := "004"
	Z05->Z05_DATA   := dData
	Z05->Z05_HORA	:= cHora
	Z05->Z05_IDUSER := RetCodUsr()
	Z05->(MsUnlock())

End Transaction
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PreValMod
Pre Validação de Modelo
@Obs Utilizado também para totalizar as NFs do Romaneio

@author Thiago Henrique dos Santos


@param oModel     - Modelo de dados
@return lRet      - .T. Se validado , .F. Caso contrário 

@since 29/01/2014

@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PreValMod (oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE .AND. oModel:GetValue("Z03MASTER","Z03_ACEFIN") == "2"

	lRet := .F.
	Help( ,, 'Help',, 'Não é permitido alterar romaneio baixado', 1, 0 )

Endif


Return lRet




//------------------------------------------------------------------
/*/{Protheus.doc} VldActive
Validação de Pré Ativação de Modelo


@author Thiago Henrique dos Santos

@since 29/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function VldActive(oModel)
Local lRet := .T.
//Local oObj       := PARAMIXB[1] 
//Local cIdPonto   := PARAMIXB[2] 
//Local cIdModel   := PARAMIXB[3]

If   "AOMS001" $ FUNNAME()

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE  .AND. Z03->Z03_ACEFIN == "2"

		lRet := .F.
		Help( ,, 'Help',, 'Não é permitido alterar romaneio baixado', 1, 0 )
		
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE  .AND. Z03->Z03_ACEFIN == "2"

		lRet := .F.
		Help( ,, 'Help',, 'Não é permitido excluir romaneio baixado', 1, 0 )
		
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
	
		DbSelectArea("Z05")
		Z05->(DbSetOrder(1))
		iF Z05->(DbSeek(xFilial("Z05")+Z03->Z03_COD))
		
			lRet := .F.
			Help( ,, 'Help',, 'Não é permitido excluir romaneio com históricos de ocorrência', 1, 0 )
		
		Endif	

	Endif
	
Endif 


Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PosValMod
Pos Validação de Modelo


@Obs Utilizado para geracao de históricos
@author Thiago Henrique dos Santos


@param oModel     - Modelo de dados
@return lRet      - .T. Se validado , .F. Caso contrário 

@since 29/01/2014

@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PosValMod (oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()
Local oModelHist := oModel:GetModel("Z05DETAIL")
Local oModelItem := oModel:GetModel("Z04DETAIL")
Local nI := 0
Local cHora := Time()
Local nValor := 0
Local nVolume := 0

cHora := Substr(cHora,1,2)+Substr(cHora,4,2)


DbSelectArea("SF2")
SF2->(DbSetOrder(1))

DbSelectArea("Z04")
Z04->(DbSetOrder(1))


If nOperation == MODEL_OPERATION_INSERT .AND. oModel:GetValue("Z03MASTER","Z03_ACD") == "1"

	//oModelHist:AddLine()
	oModelHist:SetValue('Z05_FILIAL'  ,xFilial("Z05"))
	oModelHist:SetValue('Z05_CODROM'  ,oModel:GetValue("Z03MASTER","Z03_COD"))
	oModelHist:SetValue('Z05_SEQ'     ,StrZero(oModelHist:Length(),3))
	oModelHist:SetValue('Z05_TPCOD'  ,"1")
	oModelHist:SetValue('Z05_CODOC'    ,"003")
	oModelHist:SetValue('Z05_DATA'    ,oModel:GetValue("Z03MASTER","Z03_DATA"))
	oModelHist:SetValue('Z05_HORA'    ,oModel:GetValue("Z03MASTER","Z03_HORA"))
	oModelHist:SetValue('Z05_IDUSER'    ,oModel:GetValue("Z03MASTER","Z03_IDUSER"))

Endif


If nOperation == MODEL_OPERATION_UPDATE

 
	  for nI := 1 to oModelItem:Length()
	
		oModelItem:GoLine(nI)
		
		If !oModelItem:IsDeleted()
		
			nVolume += oModelItem:GetValue('Z04_TOTALV')
			nValor +=  oModelItem:GetValue('Z04_VALOR')
		
			// históricos específico de item
			If !Empty(oModelItem:GetValue("Z04_CODOC"))
			
				oModelHist:GoLine(oModelHist:Length())
		
				If !Empty(oModelHist:GetValue("Z05_CODOC"))
			
					oModelHist:AddLine()			
			
				Endif
				
				//historico de exclusão
				If oModelItem:GetValue("Z04_EXCLUI")
				
					If !oModelItem:IsInserted()
					
						oModelHist:SetValue('Z05_FILIAL'  ,xFilial("Z05"))
						oModelHist:SetValue('Z05_CODROM'  ,oModel:GetValue("Z03MASTER","Z03_COD"))
						oModelHist:SetValue('Z05_SEQ'     ,StrZero(oModelHist:Length(),3))
						oModelHist:SetValue('Z05_NFISCA'  ,oModelItem:GetValue("Z04_NFISCA"))
						oModelHist:SetValue('Z05_SERIE'   ,oModelItem:GetValue("Z04_SERIE"))
						oModelHist:SetValue('Z05_VALOR'   ,oModelItem:GetValue("Z04_VALOR"))
						oModelHist:SetValue('Z05_TOTALV'  ,oModelItem:GetValue("Z04_TOTALV"))
						oModelHist:SetValue('Z05_TPCOD'   ,oModelItem:GetValue("Z04_TPCOD"))
						oModelHist:SetValue('Z05_CODOC'   ,oModelItem:GetValue("Z04_CODOC"))
						oModelHist:SetValue('Z05_DATA'    ,dDataBase)
						oModelHist:SetValue('Z05_HORA'    ,cHora)
						oModelHist:SetValue('Z05_IDUSER'  ,oModel:GetValue("Z03MASTER","Z03_IDUSER"))
						
					
					
					Endif
					
					oModelItem:DeleteLine() 
					
					fAtuZ07( 	oModelItem:GetValue("Z04_NFISCA") , oModelItem:GetValue("Z04_SERIE"), oModelItem:GetValue("Z04_CLIENT"),;
								oModelItem:GetValue("Z04_LOJA") , /*nVolumes*/ , .T. ) // Exclui registros Z07
				
				Else
							
					oModelHist:SetValue('Z05_FILIAL'  ,xFilial("Z05"))
					oModelHist:SetValue('Z05_CODROM'  ,oModel:GetValue("Z03MASTER","Z03_COD"))
					oModelHist:SetValue('Z05_SEQ'     ,StrZero(oModelHist:Length(),3))
					oModelHist:SetValue('Z05_NFISCA'  ,oModelItem:GetValue("Z04_NFISCA"))
					oModelHist:SetValue('Z05_SERIE'   ,oModelItem:GetValue("Z04_SERIE"))
					oModelHist:SetValue('Z05_VALOR'   ,oModelItem:GetValue("Z04_VALOR"))
					oModelHist:SetValue('Z05_TOTALV'  ,oModelItem:GetValue("Z04_TOTALV"))
					oModelHist:SetValue('Z05_TPCOD'   ,oModelItem:GetValue("Z04_TPCOD"))
					oModelHist:SetValue('Z05_CODOC'   ,oModelItem:GetValue("Z04_CODOC"))
					oModelHist:SetValue('Z05_DATA'    ,dDataBase)
					oModelHist:SetValue('Z05_HORA'    ,cHora)
					oModelHist:SetValue('Z05_IDUSER'  ,oModel:GetValue("Z03MASTER","Z03_IDUSER"))  
					
					fAtuZ07( 	oModelItem:GetValue("Z04_NFISCA") , oModelItem:GetValue("Z04_SERIE"), oModelItem:GetValue("Z04_CLIENT"),;
								oModelItem:GetValue("Z04_LOJA"), oModelItem:GetValue("Z04_TOTALV"), .F. ) // Inclui registros Z07
					
				Endif						
									
			Endif
			
				
			// histórico padrão de baixa de NF por manuentação
			If !Empty(oModelItem:GetValue("Z04_DTCONC")) .AND. !oModelItem:IsDeleted()
				
				If Z04->(DbSeek(xFilial("Z04")+oModelItem:GetValue("Z04_COD")+oModelItem:GetValue("Z04_SEQ")))
					
					
					If Z04->Z04_DTCONC <> oModelItem:GetValue("Z04_DTCONC")
						
						oModelHist:GoLine(oModelHist:Length())
		
						If !Empty(oModelHist:GetValue("Z05_CODOC"))
			
							oModelHist:AddLine()			
			
						Endif
							
						oModelHist:SetValue('Z05_FILIAL'  ,xFilial("Z05"))
						oModelHist:SetValue('Z05_CODROM'  ,oModel:GetValue("Z03MASTER","Z03_COD"))
						oModelHist:SetValue('Z05_SEQ'     ,StrZero(oModelHist:Length(),3))
						oModelHist:SetValue('Z05_NFISCA'  ,oModelItem:GetValue("Z04_NFISCA"))
						oModelHist:SetValue('Z05_SERIE'   ,oModelItem:GetValue("Z04_SERIE"))
						oModelHist:SetValue('Z05_VALOR'   ,oModelItem:GetValue("Z04_VALOR"))
						oModelHist:SetValue('Z05_TOTALV'  ,oModelItem:GetValue("Z04_TOTALV"))
						oModelHist:SetValue('Z05_TPCOD'   ,"3")
						oModelHist:SetValue('Z05_CODOC'   ,"002")
						oModelHist:SetValue('Z05_DATA'    ,dDataBase)
						oModelHist:SetValue('Z05_HORA'    ,cHora)
						oModelHist:SetValue('Z05_IDUSER'  ,oModel:GetValue("Z03MASTER","Z03_IDUSER"))
							
						
					Endif
					
					
				Endif
				
				
			Endif
				
			//ocorrência padrão de alteração de volume
			 	
			If oModelItem:IsInserted() .AND. !oModelItem:IsDeleted()
			
				If DbSeek(xFilial("SF2")+oModelItem:GetValue('Z04_NFISCA')+oModelItem:GetValue('Z04_SERIE')) 
				
					U_AFAT004( SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SF2->F2_VOLUME1, SF2->F2_VOLUME1, "AOMS001/PosValMod", dDataBase, Time(), UsrFullName(RetCodUsr()), "Alteração. Cadastrando uma ocorrência padrão de alteração de volume." )
				
					If SF2->F2_VOLUME1 > 0 .AND. SF2->F2_VOLUME1 <> oModelItem:GetValue('Z04_TOTALV')
					
						oModelHist:GoLine(oModelHist:Length())
		
						If !Empty(oModelHist:GetValue("Z05_CODOC"))
			
							oModelHist:AddLine()			
			
						Endif
							
						oModelHist:SetValue('Z05_FILIAL'  ,xFilial("Z05"))
						oModelHist:SetValue('Z05_CODROM'  ,oModel:GetValue("Z03MASTER","Z03_COD"))
						oModelHist:SetValue('Z05_SEQ'     ,StrZero(oModelHist:Length(),3))
						oModelHist:SetValue('Z05_NFISCA'  ,oModelItem:GetValue("Z04_NFISCA"))
						oModelHist:SetValue('Z05_SERIE'   ,oModelItem:GetValue("Z04_SERIE"))
						oModelHist:SetValue('Z05_VALOR'   ,oModelItem:GetValue("Z04_VALOR"))
						oModelHist:SetValue('Z05_TOTALV'  ,oModelItem:GetValue("Z04_TOTALV"))
						oModelHist:SetValue('Z05_TPCOD'   ,"5")
						oModelHist:SetValue('Z05_CODOC'   ,"005")
						oModelHist:SetValue('Z05_DATA'    ,dDataBase)
						oModelHist:SetValue('Z05_HORA'    ,cHora)
						oModelHist:SetValue('Z05_IDUSER'  ,oModel:GetValue("Z03MASTER","Z03_IDUSER"))
					
					Endif
				
				
				Endif
			
			ElseIf oModelItem:IsUpdated() .AND. !oModelItem:IsDeleted()
			
				If Z04->(DbSeek(xFilial("Z04")+oModelItem:GetValue("Z04_COD")+oModelItem:GetValue("Z04_SEQ")))
				
					IF oModelItem:GetValue('Z04_TOTALV') <> Z04->Z04_TOTALV
					
						oModelHist:GoLine(oModelHist:Length())
		
						If !Empty(oModelHist:GetValue("Z05_CODOC"))
			
							oModelHist:AddLine()			
			
						Endif
							
						oModelHist:SetValue('Z05_FILIAL'  ,xFilial("Z05"))
						oModelHist:SetValue('Z05_CODROM'  ,oModel:GetValue("Z03MASTER","Z03_COD"))
						oModelHist:SetValue('Z05_SEQ'     ,StrZero(oModelHist:Length(),3))
						oModelHist:SetValue('Z05_NFISCA'  ,oModelItem:GetValue("Z04_NFISCA"))
						oModelHist:SetValue('Z05_SERIE'   ,oModelItem:GetValue("Z04_SERIE"))
						oModelHist:SetValue('Z05_VALOR'   ,oModelItem:GetValue("Z04_VALOR"))
						oModelHist:SetValue('Z05_TOTALV'  ,oModelItem:GetValue("Z04_TOTALV"))
						oModelHist:SetValue('Z05_TPCOD'   ,"5")
						oModelHist:SetValue('Z05_CODOC'   ,"005")
						oModelHist:SetValue('Z05_DATA'    ,dDataBase)
						oModelHist:SetValue('Z05_HORA'    ,cHora)
						oModelHist:SetValue('Z05_IDUSER'  ,oModel:GetValue("Z03MASTER","Z03_IDUSER"))
					
					Endif					
				
				Endif
			
			
			Endif
			
		Endif		
	
	Next nI
	
	oModel:SetValue('Z03MASTER', 'Z03_TOTALV', nVolume)
	oModel:SetValue('Z03MASTER', 'Z03_VALOR',  nValor)
	oModel:SetValue('Z03MASTER', 'Z03_FEZMT',  "1")
	

ElseIf nOperation == MODEL_OPERATION_INSERT

 
	for nI := 1 to oModelItem:Length()
	
		oModelItem:GoLine(nI)
		
		If !oModelItem:IsDeleted()
		
			//ocorrencia padrão de alteração de volume

			If SF2->(DbSeek(xFilial("SF2")+oModelItem:GetValue('Z04_NFISCA')+oModelItem:GetValue('Z04_SERIE')))
				
				U_AFAT004( SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SF2->F2_VOLUME1, SF2->F2_VOLUME1, "AOMS001/PosValMod", dDataBase, Time(), UsrFullName(RetCodUsr()), "Inclusão. Cadastrando uma ocorrência padrão de alteração de volume." )
				
				If SF2->F2_VOLUME1 > 0 .AND. SF2->F2_VOLUME1 <> oModelItem:GetValue('Z04_TOTALV')
					
					oModelHist:GoLine(oModelHist:Length())
		
					If !Empty(oModelHist:GetValue("Z05_CODOC"))
			
						oModelHist:AddLine()			
			
					Endif
							
					oModelHist:SetValue('Z05_FILIAL'  ,xFilial("Z05"))
					oModelHist:SetValue('Z05_CODROM'  ,oModel:GetValue("Z03MASTER","Z03_COD"))
					oModelHist:SetValue('Z05_SEQ'     ,StrZero(oModelHist:Length(),3))
					oModelHist:SetValue('Z05_NFISCA'  ,oModelItem:GetValue("Z04_NFISCA"))
					oModelHist:SetValue('Z05_SERIE'   ,oModelItem:GetValue("Z04_SERIE"))
					oModelHist:SetValue('Z05_VALOR'   ,oModelItem:GetValue("Z04_VALOR"))
					oModelHist:SetValue('Z05_TOTALV'  ,oModelItem:GetValue("Z04_TOTALV"))
					oModelHist:SetValue('Z05_TPCOD'   ,"5")
					oModelHist:SetValue('Z05_CODOC'   ,"005")
					oModelHist:SetValue('Z05_DATA'    ,dDataBase)
					oModelHist:SetValue('Z05_HORA'    ,cHora)
					oModelHist:SetValue('Z05_IDUSER'  ,oModel:GetValue("Z03MASTER","Z03_IDUSER"))
					
				Endif
					
				fAtuZ07( 	oModelItem:GetValue("Z04_NFISCA") , oModelItem:GetValue("Z04_SERIE"), oModelItem:GetValue("Z04_CLIENT"),;
							oModelItem:GetValue("Z04_LOJA"), oModelItem:GetValue("Z04_TOTALV"), .F. ) // Inclui registros Z07
						
			Endif
		
			nVolume += oModelItem:GetValue('Z04_TOTALV')
			nValor +=  oModelItem:GetValue('Z04_VALOR')
			
		Endif
		
	Next nI	
	
	oModel:SetValue('Z03MASTER', 'Z03_TOTALV', nVolume)
	oModel:SetValue('Z03MASTER', 'Z03_VALOR',  nValor)

Endif

Return lRet


 
//-------------------------------------------------------------------
/*/{Protheus.doc} AOMS001D
Chama a impressão do romaneio


@author Alessandro Smaha

@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------

User Function AOMS001D()

	U_ROMS002(Z03->Z03_COD,.F.)

Return    


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuZ07()
Atualiza tabela Z07 e CBK para gerar novos romaneios com notas excluídas do romaneio.

@sample		fAtuZ07( cNumNota, cSerNota, nVolumes, lExcNf )
@author 	Alessandro Smaha

@since 		26/05/2014
@version 	1.0
/*/
//-------------------------------------------------------------------

Static Function fAtuZ07( cNumNota, cSerNota, cCodCli, cLojaCli, nVolumes, lExcNf )
                              
Local nI 		:= 0
Local aAreaSF2	:= SF2->(GetArea())

If lExcNf 
    
	DbSelectArea("CBK")
	CBK->(DbSetOrder(1)) // CBK_FILIAL+CBK_DOC+CBK_SERIE+CBK_CLIENT+CBK_LOJA   

	DbSelectArea("Z07")
	Z07->(DbSetOrder(1)) // Z07_FILIAL+Z07_DOC+Z07_VOLUME

	If Z07->(DbSeek(xFilial("Z07")+cNumNota))
		
		While Z07->(!Eof()) .AND. xFilial("Z07") == Z07->Z07_FILIAL .AND. cNumNota == Z07->Z07_DOC
			
			RecLock("Z07",.F.) 
			Z07->(DbDelete())
			Z07->(MsUnlock())
			
			Z07->(DbSkip())
			
		EndDo
		
	EndIf
	
	If CBK->(DbSeek(xFilial("CBK")+cNumNota+cSerNota))
		RecLock("CBK",.F.)		
	Else
		RecLock("CBK",.T.)
		CBK->CBK_FILIAL := xFilial('CBK')
		CBK->CBK_DOC    := cNumNota
		CBK->CBK_SERIE  := cSerNota    
//		CBK->CBK_CLIENT := cCodCli
//		CBK->CBK_LOJA   := cLojaCli	
  		CBK->CBK_DTEMBQ := Ctod('  /  /  ')
	EndIf    
	
	CBK->CBK_XQTVOL := 0
	CBK->CBK_XDTEXP := Ctod('  /  /  ')
	If ! Empty(CBK->CBK_DTEMBQ)
		CBK->CBK_STATUS := "3" // Separação Finalizada 
	Else
		CBK->CBK_STATUS := "1"  // Conferência Não Iniciada
	EndIf
	CBK->(MsUnlock())
	
Else // Inclui registro 

	If CBK->(DbSeek(xFilial("CBK")+cNumNota+cSerNota))
		RecLock("CBK",.F.)
	Else
		RecLock("CBK",.T.)
		CBK->CBK_FILIAL := xFilial('CBK')
		CBK->CBK_DOC    := cNumNota
		CBK->CBK_SERIE  := cSerNota   
//		CBK->CBK_CLIENT := cCodCli
//		CBK->CBK_LOJA   := cLojaCli	
  		CBK->CBK_DTEMBQ := Ctod('  /  /  ')   		
	EndIf 
	
	CBK->CBK_XQTVOL := nVolumes
	CBK->CBK_XDTEXP := dDataBase
	CBK->CBK_STATUS := "6"
	CBK->(MsUnlock())
	
	For nI := 1 to nVolumes
	       
		If ! Z07->(DbSeek(xFilial("Z07")+cNumNota+StrZero(nI,3)))
		
			RecLock("Z07",.T.)
			Z07->Z07_FILIAL := xFilial('Z07')
			Z07->Z07_DOC    := cNumNota
			Z07->Z07_VOLUME := StrZero(nI,3)
			Z07->Z07_STATUS := "2" 
	   		Z07->Z07_DTCONF := dDataBase
	   		Z07->Z07_HRCONF := Time()
			Z07->(MsUnlock())
		
		EndIf
	
	Next nI
  
EndIf  

RestArea(aAreaSF2)

Return