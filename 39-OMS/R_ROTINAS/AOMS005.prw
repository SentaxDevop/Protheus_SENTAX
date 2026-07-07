#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

User Function AOMS005()
Local cPerg := 'AOMS001'
Local aHelpPerg  := {}

Local lFound := .F.
Local oBrowse := FWMBrowse():New()
Local cFiltro := ""


aAdd(aHelpPerg,{"Digite a Filial da Nota Fisca"})
aAdd(aHelpPerg,{"Digite o Número Nota fiscal"})

aAdd(aHelpPerg,{"Digite a Série da nota fiscal."})
	
PutSX1(cPerg,"01","Filial"      		,"" ,"" ,"MV_CH1" ,"C",6,0,0,"G","","SM0" 	 ,"033" ,"S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})
PutSX1(cPerg,"02","Número da NF"     	,"" ,"" ,"MV_CH2" ,"C",9,0,0,"G","","STSF21" ,"018" ,"S","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPerg[2] ,{},{})
PutSX1(cPerg,"03","Série da NF"         ,"" ,"" ,"MV_CH3" ,"C",3,0,0,"G","",""		 ,""    ,"S","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPerg[3] ,{},{})


If Pergunte(cPerg)

	DbSelectArea("Z04")
	Z04->(DbSetOrder(2))	
	If Z04->(DbSeek(MV_PAR01+MV_PAR02+MV_PAR03))
	
		DbSelectArea("Z05")
		Z03->(DbSetOrder(1))
		If Z03->(DbSeek(MV_PAR01+Z04->Z04_COD))
		
			lFound := .T.			
			cFiltro := 'Z03_FILIAL = "'+MV_PAR01+'" .AND. Z03_COD = "'+Z04->Z04_COD+'"'
			
			

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
			oBrowse:SetFilterDefault( cFiltro )
			oBrowse:Activate()					
		
		Endif
	
	Endif
	
	If !lFound
	
		ShowHelpDlg("Atenção", {"Nota Fiscal não localizada em romaneio.",""},5,{"Verifique os parâmetros informados." ,""},5)
	
	
	Endif
	
	

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Carrega o modelo do romaneio

@author Thiago Henrique dos Santos

@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function ModelDef()
 
Local oModel := FWLoadModel( 'AOMS001' ) 


Return oModel







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
	ADD OPTION aRotina Title 'Manutenção' 		Action 'VIEWDEF.AOMS004' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Baixar' 	  		Action 'U_AOMS001B' 	   OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Cancelar Baixa' 	Action 'U_AOMS001C'  OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Histórico'  		Action 'VIEWDEF.AOMS002' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina Title 'Excluir'    		Action 'VIEWDEF.AOMS001' OPERATION 5 ACCESS 0 
	ADD OPTION aRotina Title 'Imprimir'   		Action 'VIEWDEF.AOMS001' OPERATION 8 ACCESS 0

 

 
Return aRotina
