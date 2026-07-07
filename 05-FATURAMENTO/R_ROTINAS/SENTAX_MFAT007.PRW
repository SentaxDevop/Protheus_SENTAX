#INCLUDE "PROTHEUS.CH"          
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"   
//---------------------------------------------------------------------
/*/{Protheus.doc} MFAT007
Cadastro de tipo de operações x naturezas
 
@sample		U_MFAT007()
 
@return 	oBrowse - Objeto do Browse

@author 	Alessandro Smaha
@since 		18/02/2015
@version 	P11
/*/
//--------------------------------------------------------------------- 
User Function MFAT007()  

Local oBrowse 		:= Nil

Private cCadastro	:= "Tipo de operação x natureza"
Private nOpca      	:= 0
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z11")
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

Return oBrowse      


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados
                
@sample		ModelDef()

@return 	oModel - Objeto do Modelo de Dados

@author		Alessandro Smaha
@since		18/02/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStru 	:= FWFormStruct(1,"Z11" )

oModel := MPFormModel():New('MFAT007P')
oModel:AddFields( "Z11MASTER", /*cOwner*/, oStru )
oModel:SetPrimaryKey( { "Z11_FILIAL", "Z11_OPER" } )
oModel:SetDescription(cCadastro)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface 
                
@sample		ViewDef()

@return 	oView - Objeto da Interface

@author		Alessandro Smaha
@since		18/02/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
 
Local oModel	:= FWLoadModel( 'SENTAX_MFAT007' )
Local oStru		:= FWFormStruct( 2, "Z11" )
Local oView		:= Nil

oView:= FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW', oStru, "Z11MASTER" )
oView:CreateHorizontalBox( 'TELA', 100 )
oView:SetOwnerView( 'VIEW', 'TELA' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de opções
                
@sample		ViewDef()

@return 	aRotina - Array com opções do menu

@author		Alessandro Smaha
@since		18/02/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
       
ADD OPTION aRotina TITLE "Pesquisar"   			ACTION 'VIEWDEF.SENTAX_MFAT007' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"  			ACTION 'VIEWDEF.SENTAX_MFAT007' 	OPERATION 2 ACCESS 0  
ADD OPTION aRotina TITLE "Incluir"     			ACTION 'VIEWDEF.SENTAX_MFAT007' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     			ACTION 'VIEWDEF.SENTAX_MFAT007' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     			ACTION 'VIEWDEF.SENTAX_MFAT007' 	OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Importar"     		ACTION 'U_MFAT007I'   				OPERATION 3 ACCESS 0

Return aRotina   


//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT007I
Rotina para importar as operações x naturezas existenntes
                
@sample		MFAT007I()

@author		Alessandro Smaha
@since		19/02/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function MFAT007I() 

Local cTeProd := GETMV("MV_TPPROD")
Local cTeServ := GETMV("MV_TPSERV")
Local cTeLoca := GETMV("MV_TPLOCA")
Local cTeVema := GETMV("MV_TPVEMA")
Local cTePerm := GETMV("MV_TPPERM")

DbSelectArea("Z11")
Z11->(DbSetOrder(1)) // Z11_FILIAL+Z11_OPER+Z11_NAT  

fAtuZ11( cTeProd, "10101" ) 
fAtuZ11( cTeLoca, "10103" )
fAtuZ11( cTeServ, "10109" )
fAtuZ11( cTeVema, "10110" )
fAtuZ11( cTePerm, "10111" )   

Z11->(DbGoTop())
     
Return

	
//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuZ11
Atualiza tabela Z11
                
@sample		fAtuZ11()

@author		Alessandro Smaha
@since		19/02/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fAtuZ11( cCodOp, cCodNat )  

Local nI 	:= 0  
Local aAux 	:= {} 

aAux := Separa(Alltrim(cCodOp),"/")
    
For nI := 1 to Len(aAux)  
  
	cCodOp := aAux[nI]

	If !Z11->(DbSeek(xFilial("Z11")+cCodOp)) 
		
		RecLock("Z11",.T.)
			Z11->Z11_FILIAL := xFilial("Z11")
			Z11->Z11_OPER 	:= cCodOp
		  	Z11->Z11_NAT 	:= cCodNat
		Z11->( MsUnlock() )   
		
	EndIf
Next nI

Return