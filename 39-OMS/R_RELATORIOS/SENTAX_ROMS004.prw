#INCLUDE "protheus.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

#DEFINE MIN_Y 005
#DEFINE MIN_X 050
#DEFINE MAX_X 900
#DEFINE COL_1 230
//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS004
Etiqueta de Produtos

@param 		cPreNota - Numero da nota fiscal (somente informado quando é chamada automatica)
cSerie - Série da nota fiscal
nTipoN - 1=Pré Nota Entrada;2=Nota de Saída

@sample 	U_ROMS004( cNota, cSerie, nTipoN, aNotas ) 

@param		cNota -  Numero da nota (pre nota ou saida)
			cSerie - Serie da nota  
			aItens - Array de produtos para o grid

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0
/*/
//-------------------------------------------------------------------------------
User Function ROMS004( cNota, cSerie, aItens )

Local cPerg 	:= "ROMS004"
Local aArea 	:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aProdutos := {}
Local aProRange	:= {}
Local lAuto		:= .F.

Default cNota	:= ""
Default cSerie	:= ""
Default aItens	:= {}

If ! Empty(aItens)
	
	aItens := fDocumentos( cNota, cSerie, aItens ) 
	aProdutos := fGridProd(aItens)
	
Else
	
	lAuto := .T.
	
	aItens := fDocumentos( cNota, cSerie, aItens ) 
		
	aProdutos := fGridProd(aItens)

Endif

If ! Empty(aProdutos)
	
	Processa( {|| fImpEtiquetas(aProdutos,lAuto) }, "Aguarde..." )
	
EndIf

RestArea(aArea)
SB1->(RestArea(aAreaSB1))

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS004A
Rotina chamada no ponto de entrada SF1140I

@sample 	U_ROMS004A()

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0
/*/
//-------------------------------------------------------------------------------
User Function ROMS004A()

// Chama a rotina para impressão de etiquetas para o registro posicionado
U_ROMS004( SF1->F1_DOC, SF1->F1_SERIE, )

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS004B
Rotina chamada após a impressão do espelho da nota

@sample 	U_ROMS004B(aItens)    

@param		aItens - Array com os produtos para o grid

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0
/*/
//-------------------------------------------------------------------------------
User Function ROMS004B(aArrItens)   

Local aItens := {}

// aArrItens [ _aItensAgr, _aItensONf ]   

If MsgYesNo("Deseja Imprimir Etiquetas de produtos na Ordem da Nota ?", "Ordem da Nota ou Agrupado") 
	aItens := aClone(aArrItens[2])    
Else
	aItens := aClone(aArrItens[1]) 
EndIf

U_ROMS004( , , aItens )    

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fDocumentos
Busca os produtos da pre-nota

@param 		cNota -  Numero da nota fiscal
			cSerie - Numero de série da nota
			aItens - Array de produtos para o grid
			
@sample 	fDocumentos(cNota,cSerie,nTipoN,lTodos)

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0

@return		aProdutos := { código do produto, descrição do produto, quantidade }
/*/
//-------------------------------------------------------------------------------
Static Function fDocumentos( cNota, cSerie, aItens )
               
Local cPerg 	:= "ROMS004"
Local aItensAux	:= {}  
Local nI 		:= 0  
Local lTodos	:= .F.  
Local nQntde	:= 0     
Local cNUndMed	:= Alltrim( SuperGetMv("ST_UNIDMED",,"") )

If ! Empty(cNota) .OR. ! Empty(aItens)
	
	AjustaSx1(cPerg)
	
	If Pergunte(cPerg,.T.)
		
		lTodos := IIF(MV_PAR01==1,.T.,.F.)  
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
		
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		
		If ! Empty(cNota)   
		
			If SD1->(DbSeek(xFilial("SD2")+cNota+cSerie))
				
				While ! SD1->(EOF()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. Alltrim(SD1->D1_DOC) == Alltrim(cNota) .AND. Alltrim(SD1->D1_SERIE) == Alltrim(cSerie)
					If SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD)) 
						
						If "*"+Alltrim(SB1->B1_UM)+"*" $ cNUndMed
							nQntde := 1 
						Else
							nQntde := SD1->D1_QUANT
						EndIf
						
						nPosPro := aScan(aItens,{ |x| AllTrim(x[1]) == Alltrim(SB1->B1_COD) })
						If nPosPro == 0
							If lTodos
								AAdd(aItens,{ SB1->B1_COD, SB1->B1_DESC, nQntde, .F. })
							Else
								If Empty(SB1->B1_CODBAR)
									AAdd(aItens,{ SB1->B1_COD, SB1->B1_DESC, nQntde, .F. })
								EndIf
							EndIf 
						Else
						 	aItens[nPosPro][3] += nQntde	
						EndIf
					EndIf
					SD1->(DbSkip())
				EndDo
				
			EndIf    
			
		ElseIf ! Empty(aItens) 
		    
			If ! lTodos       
			
				aItensAux 	:= aClone(aItens)
				aItens 		:= {} 
				
				For nI := 1 to Len(aItensAux)
				
					If SB1->(DbSeek(xFilial("SB1")+aItensAux[nI][1])) 
					   						
						If "*"+Alltrim(SB1->B1_UM)+"*" $ cNUndMed
							nQntde := 1 
						Else
							nQntde := aItensAux[nI][3]
						EndIf
						
						If Empty(SB1->B1_CODBAR)  
						
						 	aAdd(aItens,{ aItensAux[nI][1], aItensAux[nI][2], nQntde, aItensAux[nI][4] })	
						
						EndIf
					
					EndIf
				
				Next nI
				
			EndIf  
			
		EndIf
		
	EndIf
	
EndIf

Return aItens


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fImpEtiquetas
Busca os produtos da pre-nota

@param 		aProdutos - Array de produtos { cod. do produto, descrição, quantidade }
			lAuto - Chamada automaticamente ou manual

@sample 	fImpEtiquetas(aProdutos,lAuto)

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0
/*/
//-------------------------------------------------------------------------------
Static Function fImpEtiquetas(aProdutos,lAuto)

Local nI		:= 0
Local nJ 		:= 0
Local nWidth	:= 0.04
Local nHeigth	:= 1.6
Local cLogo 	:= "SENTAX.JPG"
Local cFile 	:= "ROMS004_"+cEmpAnt+"_"+cFilAnt+"_"+Dtos(MSDate())+"_"+StrTran(Time(),":","")
Local oFontA10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	//Arial 10 sem negrigo
Local oFontA16N	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)	//Arial 16 com negrigo
Local oFontA18	:= TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)	//Arial 18 sem negrigo
Local oFontA20N	:= TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)	//Arial 20 com negrigo

Local oPrint
/*
If lAuto
	
	oPrint := FWMSPrinter():New(cFile,IMP_SPOOL, .T., , .T.,.F.,,"ETIQUETA",.T.)
	oPrint:SetPortrait()
	
	oPrint:cPrinter := "ETIQUETA"
	oPrint:lServer := .T.
	
	nEsp := 30
	
Else
	
	oPrint := FWMSPrinter():New(cFile,IMP_SPOOL)
	oPrint:SetPortrait()
	
	nEsp := 35
	
Endif
*/

oPrint := FWMSPrinter():New(cFile,IMP_SPOOL)
oPrint:SetPortrait()
	
ProcRegua(Len(aProdutos))

For nI := 1 to Len(aProdutos)
	
	IncProc("Imprimindo etiquetas (Item "+cValToChar(nI)+"/"+cValToChar(Len(aProdutos))+")... Aguarde")
	
	nQntde := aProdutos[nI][3]
	
	For nJ := 1 to nQntde
		
		nRow 	:= MIN_Y
		cCodPro := Alltrim(aProdutos[nI][1])
		cDesPro := Alltrim(aProdutos[nI][2])
		
		oPrint:StartPage()
		
		// LOGO
		oPrint:SayBitmap( nRow, MIN_X, cLogo, 144, 101)
		nRow += 75
		
		// CODIGO DO PRODUTO
		oPrint:Say ( nRow, COL_1, cCodPro, oFontA20N )
		nRow += 40
		
		// DESCRICAO PRODUTO
		oPrint:SayAlign ( nRow, MIN_X, cDesPro, oFontA18, MAX_X, 200, , 0, 1 )
		
		// CODIGO DE BARRAS
		oPrint:FWMSBAR("EAN128",5.3,3, cCodPro,oPrint,.F.,,.T./*lHorz*/,nWidth/*nWidth*/,nHeigth/*nHeigth*/,.F./*lBanner*/,"TAHOMA"/*cFont*/,/*cMode*/,.F./*lPrint*/,8/*nPFWidth*/,8/*nPFHeigth*/,.T./*lCmtr2Pix*/)
		
		nRow += 390
		
		// DESCRICAO CODIGO DE BARRAS
		oPrint:Say (nRow,MIN_X+100,cCodPro,oFontA16N)
		oPrint:EndPage()
		
	Next nJ
	
Next nI

oPrint:Print()

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fGridProd
Monta a grid para impressão de produtos

@sample 	fGridProd(aItens)

@param		aItens - Itens para preencher o grid.

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0
/*/
//-------------------------------------------------------------------------------
Static Function fGridProd(aItens)

Local cQry   	:= ""
Local nOpca		:= 0
Local aProds	:= {}

Default aItens	:= {}

Static oDlgPro

Private oMsProd
Private aHeader	:= {}
Private aCols		:= {} 

If ! Empty(aItens) 

	aCols := aClone(aItens)	

EndIf

// Monta as Dimensoes dos Objetos
aObjCoords		:= {}
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 0 , 0 }

aAdd( aObjCoords , { 020, 001, .T. , .F. } )
aAdd( aObjCoords , { 000, 000, .T. , .T. } )

aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdd( aHeader , { "Código" ,   "PRODUTO",  	"@!", TamSx3("B1_COD")[1],0,,,"C","SB1", } )
aAdd( aHeader , { "Descrição", "DESCRICAO", "@!", TamSx3("B1_DESC")[1],0,,,"C","", } )
aAdd( aHeader , { "Quantidade","QUANT",   	"999", 3,0,,,"N","", } )

aAltera := {"PRODUTO","QUANT"}

DEFINE MSDIALOG oDlgPro TITLE "Impressão de etiquetas de produtos" FROM aAdvSize[7],0 TO aAdvSize[6]-10, aAdvSize[5] OF oMainWnd PIXEL

oMsProd := MsNewGetDados():New( aObjSize[2,1], aObjSize[2,2], aObjSize[2,3]-10, aObjSize[2,4], GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "U_ROMS004V()", "+Field1+Field2", aAltera,, 999, "U_ROMS004L()", "", "AllwaysTrue", oDlgPro, aHeader , aCols)

ACTIVATE MSDIALOG oDlgPro ON INIT EnchoiceBar(oDlgPro,{||IIF(oMsProd:TudoOK(),(oDlgPro:End(),nOpca:=1),nOpca := 0)},{||oDlgPro:End()},,) CENTERED

If nOpca == 1
	
	For nI := 1 to Len(oMsProd:aCols)
		lDeletado := oMsProd:aCols[nI][Len(oMsProd:aCols[nI])]
		If ! lDeletado
			aAdd(aProds,{oMsProd:aCols[nI][1],oMsProd:aCols[nI][2],oMsProd:aCols[nI][3]})
		EndIf
	Next nI
	
Endif

Return aProds


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS004V
Validação do aCols

@sample 	U_ROMS004V()

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0
@return		lógico - se validou o aCols
/*/
//-------------------------------------------------------------------------------
User Function ROMS004V()

Local nI	 := 0
Local lRetOk := .T.

nPosPro := aScan(aHeader,{ |x| AllTrim(x[2]) == "PRODUTO" 	})
nPosDes := aScan(aHeader,{ |x| AllTrim(x[2]) == "DESCRICAO" })
nPosQtd := aScan(aHeader,{ |x| AllTrim(x[2]) == "QUANT" 	})

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

For nI := 1 to Len(aCols)
	
	cCodPro   := aCols[nI][nPosPro]
	nQtdPro   := aCols[nI][nPosQtd]
	lDeletado := aCols[nI][Len(aCols[nI])]
	
	If ! lDeletado
		If Empty(cCodPro)
			MsgAlert("Produto deve ser informado! Linha "+cValToChar(nI)+".","Atenção")
			lRetOk	:= .F.
		ElseIf ! SB1->(DbSeek(xFilial("SB1")+cCodPro))
			MsgAlert("Produto não está cadastrado! Linha "+cValToChar(nI)+".","Atenção")
			lRetOk	:= .F.
			Exit
		ElseIf Empty(nQtdPro)
			MsgAlert("Quantidade deve ser informada! Linha "+cValToChar(nI)+".","Atenção")
			lRetOk	:= .F.
			Exit
		EndIf
	EndIf
	
Next nI

Return lRetOk


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS004L
Validação do campo

@sample 	U_ROMS004L()

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0
@return		lógico - se validou o campo
/*/
//-------------------------------------------------------------------------------
User Function ROMS004L()

Local cVarAtu	:= Upper(READVAR())
Local lRetOk	:= .T.

nPosPro := aScan(aHeader,{ |x| AllTrim(x[2]) == "PRODUTO" 	})
nPosDes := aScan(aHeader,{ |x| AllTrim(x[2]) == "DESCRICAO" })
nPosQtd := aScan(aHeader,{ |x| AllTrim(x[2]) == "QUANT" 	})

If nPosPro > 0 .AND. nPosDes > 0 .AND. nPosQtd > 0
	
	If "PRODUTO" $ cVarAtu
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
		If SB1->(DbSeek(xFilial("SB1")+M->PRODUTO))
			aCols[n][nPosDes] := SB1->B1_DESC
		Else
			MsgAlert("Produto não está cadastrado!","Atenção")
			lRetOk	:= .F.
		EndIf
		
	ElseIf "QUANT" $ cVarAtu
		If Empty(M->QUANT)
			MsgAlert("Quantidade deve ser informada!","Atenção")
			lRetOk	:= .F.
		EndIf
	EndIf
	
EndIf

Return lRetOk


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do programa

@param 		cPerg - Nome do grupo de perguntas

@sample 	AjustaSX1(cPerg)

@author 	Alessandro Smaha
@since 		12/05/2014
@version 	1.0
/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1(cPerg)

Local aHelpPerg  := {}

aAdd(aHelpPerg,{"Indica se imprime todos os produtos ou"," produtos sem etiqueta." })

PutSx1(cPerg,"01","Imprime ?","","","MV_CH1","N",1,0,0,"C","","   ","","","MV_PAR01","Todos","","","","Sem Cod. Barras","","","","","","","","","","","",aHelpPerg[1] ,{},{})

Return 
