#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"    
#INCLUDE "SHELL.CH"   
#INCLUDE "REPORT.CH"    
#INCLUDE "TOPCONN.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} AEST001
Cadastro de Classes de Risco
                
@sample		U_AEST001()

@author		Alessandro Smaha
@since		05/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AEST001()

Local oBrowse 		:= Nil

Private cCadastro	:= "Classes de Risco"
Private nOpca      	:= 0
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z12")
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
Local oStru 	:= FWFormStruct(1,"Z12" )

oModel := MPFormModel():New('AEST001P')
oModel:AddFields( "Z12MASTER", /*cOwner*/, oStru )
oModel:SetPrimaryKey( { "Z12_FILIAL", "Z12_CODCLA"} )
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
 
Local oModel	:= FWLoadModel( 'SENTAX_AEST001' )
Local oStru		:= FWFormStruct( 2, "Z12" )
Local oView		:= Nil

oView:= FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW', oStru, "Z12MASTER" )
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
       
ADD OPTION aRotina TITLE "Pesquisar"   			ACTION 'VIEWDEF.SENTAX_AEST001' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"  			ACTION 'VIEWDEF.SENTAX_AEST001' 	OPERATION 2 ACCESS 0  
ADD OPTION aRotina TITLE "Incluir"     			ACTION 'VIEWDEF.SENTAX_AEST001' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     			ACTION 'VIEWDEF.SENTAX_AEST001' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     			ACTION 'VIEWDEF.SENTAX_AEST001' 	OPERATION 5 ACCESS 0

Return aRotina   


//-------------------------------------------------------------------
/*/{Protheus.doc} AEST001G
Gatilho
                
@sample		AEST001G()

@author		Alessandro Smaha
@since		05/03/2015   
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AEST001G(cCampo)
   
	Local cCodCla 	:= ""   
	Local aArea		:= GetArea()
	               
	If INCLUI 
		cCodCla := M->Z12_CODCLA
	Else
		cCodCla := Z12->Z12_CODCLA
	EndIf
	
	RestArea(aArea)
		
Return cCodCla   


//-------------------------------------------------------------------
/*/{Protheus.doc} AEST001C
Rotina para montar o complemento da descrição do produto.
                
@sample		U_AEST001C()

@author		Alessandro Smaha
@since		05/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AEST001C( cCodSB5, cDesCie, cCodOnu, cCodCla, cCodSub, cCodEmb, cCodRiS, cInfAdic ) 

Local cDesRet	:= IIF(!Empty(cInfAdic),", ","")
Local cClaSub	:= "" // Classe Subsidiaria
Local cSubSub	:= "" // SubClasse Subsidiaria
Local cEmbSub	:= "" // Grupo de Embalagem Subsidiaria
Local cOnuAux	:= ""
Local nPosOnu	:= AT("_",cCodOnu)-1   

If nPosOnu > 0 
	cCodOnu := Substr(cCodOnu,1,nPosOnu)               
EndIf

cDesRet += Alltrim(cDesCie) + IIF(!Empty(cDesCie),", ","")   
cDesRet += "ONU " + Alltrim(cCodOnu) + ", " 
cDesRet += "CR " + Alltrim(cCodCla) 
If !Empty(cCodSub)
	cDesRet += ", SC " + Alltrim(cCodSub)
EndIf
cDesRet += ", GE " + cCodEmb

If !Empty(cCodRiS) 

	cClaSub := Substr(cCodRiS,1,4)
	cSubSub := Substr(cCodRiS,5,4)
	cEmbSub := Substr(cCodRiS,9,4)
	
	cDesRet += ", RS CR " + cClaSub 
	If !Empty(cSubSub)
		cDesRet += ", RS SC " + cSubSub 
	EndIf
	cDesRet += ", RS GE " + cEmbSub      

EndIf

cInfAdic := Alltrim(cInfAdic) + IIF(!Empty(cInfAdic),". ","") + Alltrim(Upper(cDesRet)) + "." 

Return    


//-------------------------------------------------------------------
/*/{Protheus.doc} AEST001I
Rotina para guardar o nome do arquivo pdf para impressão das fichas
emergenciais após a impressão da danfe.
                
@sample		U_AEST001I()

@author		Alessandro Smaha
@since		20/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AEST001I( aArqPdf ) 

Local nI		:= 0
Local cArqPdf 	:= "" 
Local cDirPdf 	:= Alltrim(GetMV("ST_XDIRONU",,"")) // \FC_EMERG
Local cAppPdf 	:= Alltrim(GetMV("ST_XPRGIMP",,"")) // C:\Foxit\Reader.exe
Local cImpArq	:= Alltrim(GetMV("ST_XNOMIMP",,"")) // Work - HP Deskjet 4620
Local cDirTmp	:= "C:\TEMP\"
Local aTmpPdf   := aClone(aArqPdf)
Local lAbrPdf	:= !cFilAnt $ Alltrim(GetMV("ST_XFIMPPT",,"")) 

aArqPdf := {}

For nI := 1 To Len(aTmpPdf)
	If Ascan(aArqPdf,{|x| Alltrim(x) == Alltrim(aTmpPdf[nI]) }) == 0
		aAdd(aArqPdf,aTmpPdf[nI])
	EndIf
Next nI

cDirPdf += IIF(Substr(cDirPdf,Len(cDirPdf),1) <> "\","\","")
       
// Cria o diretório temporário, caso não existir
If !Empty(cDirTmp)   
	MontaDir(cDirTmp)
EndIf

If lAbrPdf
	
	For nI := 1 to Len(aArqPdf)   
	     
		cArqPdf := aArqPdf[nI] + ".PDF"
		
		// Verifica se existe o arquivo da ficha emergencia no diretório
		If File(cDirPdf + cArqPdf) 
			 
			MsDocView( cArqPdf, {}, 'Open', cDirPdf ) 
			
		Else
		
			MsgAlert("Ficha emergencial "+Alltrim(cArqPdf)+" não encontrada!","Atenção")
				
		EndIf	
	
	Next nI  

Else
	
	For nI := 1 to Len(aArqPdf)   
	     
		cArqPdf := aArqPdf[nI] + ".PDF"
		
		// Verifica se existe o arquivo da ficha emergencia no diretório
		If File(cDirPdf + cArqPdf)       
		
			CpyS2T ( cDirPdf+cArqPdf, cDirTmp ) 
			
			// Verifica se o arquivo foi copiado e se todos os parâmetros estão preenchidos
			If File(cDirTmp+cArqPdf) .AND. !Empty(cAppPdf) .AND. !Empty(cAppPdf)
				
				// Realiza a impressão via FoxIt na impressora informada
				If WinExec(cAppPdf+" /t "+cDirTmp+cArqPdf+" "+cImpArq,1) <> 0
					
					MsgAlert("Erro ao imprimir ficha emergencial "+cArqPdf+"! Impressora ("+cImpArq+") ou aplicativo ("+cAppPdf+") de impressão não encontrado!","Atenção")     
				
				EndIf
				
			EndIf 
			
		EndIf	
	
	Next nI    
	
	/*        
	// Pausa para excluir após enviar a impressão
	Sleep(5000)
	
	// Apaga os arquivos Temporários
	For nI := 1 to Len(aArqPdf)   
	
		If File(cDirTmp+cArqPdf)  
		
			Ferase( cDirTmp+cArqPdf )
		
		EndIf
	     
	Next nI 
	*/
	
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AEST001R
Relatório de Fichas emergenciais
                
@sample		U_AEST001R()

@author		Alessandro Smaha
@since		20/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AEST001R() 

Local oReport      

Private lWeb	:= .F. //Valida se o relatorio é para WEB

oReport := fRelDef()
	
If !lWeb
	oReport:PrintDialog()
Endif
       

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fRelDef
Definição do relatorio
                
@sample		fRelDef()

@author		Alessandro Smaha
@since		16/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fRelDef()   

	Local cTitle    := OemToAnsi("Gerenciamento Fichas Emergenciais")
	Local cHelp     := OemToAnsi("Impressão do Relatório de Gerenciamento Fichas Emergenciais")
	
	Local oReport   := Nil
	Local oSection1 := Nil
		                                        
	oReport := tReport():New("AEST001R",cTitle,"AEST001R",{|oReport| fReportPrint(oReport)},cHelp)
	
	oReport:SetPortrait()
	oReport:HideParamPage()
		
	oSection1 := trSection():New(oReport,cTitle,{"SB1"})   
	 
	trCell():New(oSection1,"B1_COD"," ","Código",PesqPict("SB1","B1_COD"),16)	
	trCell():New(oSection1,"B1_DESC"," ","Descrição",PesqPict("SB1","B1_DESC"),33)	
	trCell():New(oSection1,"B5_XNONU"," ","Número da ONU",PesqPict("SB5","B5_XNONU"),TamSX3("B5_XNONU")[1]+1) 
	trCell():New(oSection1,"MOTIVO"," ","Motivo","@!",50)  

	lTSecao := .F.
	lTGeral := .T.
		
	TRFunction():New(oSection1:Cell("B1_COD"),NIL,"COUNT",,,,,lTSecao,lTGeral)	

	oReport:SetTotalInLine(.F.) 
	
Return oReport          


//-------------------------------------------------------------------
/*/{Protheus.doc} fReportPrint
Impressao do relatorio
                
@sample		fReportPrint(oReport)

@author		Alessandro Smaha
@since		16/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fReportPrint(oReport)
                            
	Local oSection1 := oReport:Section(1)   
	Local nI 		:= 0   
	Local aItens	:= {}
	Local cQuery 	:= ""   
	Local cArqPdf	:= "" 
	Local cMotivo	:= ""   
	Local cDirPdf 	:= Alltrim(GetMV("ST_XDIRONU",,"")) // \FC_EMERG  
	
	cDirPdf += IIF(Substr(cDirPdf,Len(cDirPdf),1) <> "\","\","")
	
	If ( Select("TQRY") ) > 0
		DbSelectArea("TQRY")
		TQRY->(dbCloseArea())
	EndIf    
			
	cQuery := " SELECT B1_COD, B1_DESC, ISNULL(B5_XNONU,'') B5_XNONU " 
	cQuery += " FROM " + RetSqlName("SB1")+" SB1 "
	cQuery += " LEFT JOIN " + RetSqlName("SB5")+" SB5 ON B5_FILIAL = '"+xFilial("SB5")+"' AND B5_COD = B1_COD AND SB5.D_E_L_E_T_ <> '*' " 
	cQuery += " WHERE B1_XRISCO = 'S' AND SB1.D_E_L_E_T_ <> '*' "   
	cQuery += " ORDER BY B1_COD "   
	
	TCQUERY cQuery NEW ALIAS "TQRY" 
		
	DbSelectArea("TQRY")
	
	oReport:SetMeter(0) 
	
	TQRY->(DbGoTop()) 
	
	While !oReport:Cancel() .And. !TQRY->(Eof())  
	
		oReport:IncMeter() 
		
		cMotivo := "" 
		
		If Empty(TQRY->B5_XNONU)  
		
			cMotivo := "Número da Onu não informado!" 
		
		Else
		
	   		cArqPdf := cDirPdf+Alltrim(TQRY->B5_XNONU)+".pdf"
		
	  		If !File(cArqPdf)   
	  		                  
	  			cMotivo := "Arquivo "+cArqPdf+" não encontrado!" 
	  			
	  		EndIf	
	  		
	 	EndIf 
	 	
	 	If !Empty(cMotivo)
	 		aAdd(aItens,{	TQRY->B1_COD,;
							TQRY->B1_DESC,;   
							TQRY->B5_XNONU,;
							cMotivo	})  
	 	EndIf
			  
		TQRY->(DbSkip())
	EndDo 
	
	oSection1:Init()	   
	
	For nI := 1 to Len(aItens) 
	
		If oReport:Cancel()
			Exit
		EndIf   
		
		oSection1:Cell("B1_COD"):SetValue(aItens[nI][1])
		oSection1:Cell("B1_DESC"):SetValue(aItens[nI][2])
		oSection1:Cell("B5_XNONU"):SetValue(aItens[nI][3])
		oSection1:Cell("MOTIVO"):SetValue(aItens[nI][4])
	     
		oSection1:PrintLine()
		
	Next nI
	
	oSection1:Finish()	
	
Return