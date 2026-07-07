
#include "protheus.ch"
#include "rwmake.ch"
#include "apwizard.ch"  
#include "topconn.ch"

//itens
#define __PRODUTO 1
#define __DESC 	  2


//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT009
Importa tabela de preços, atualizando a tabela já selecionada.

@author Felipe Toazza Caldeira
@since 05/10/2015               
@version P11
/*/
//-------------------------------------------------------------------

User Function MFAT009()

Local bProcess 
Local cPerg := Padr("MFAT009",10)
Local oProcess

bProcess := {|oSelf| Executa(oSelf) }    
//cria as peguntas se não existe
CriaSX1(cPerg)
Pergunte(cPerg,.F.)

oProcess := tNewProcess():New("MFAT009","Atualização de tabela de preços!",bProcess,"Rotina para atualização de tabela de preços expecifica para SENTAX.",cPerg,,.F.,,, .T. )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Executa
Executa leitura do arquivo CSV.

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------
Static Function Executa(oProcess)

	Local cItens := alltrim(mv_par01)

	Local aItens := {}

	Private __data := DtoS(Date()) + "-" + STRTran(Time(),":","")

	Private cDiretory := ""

	//Valida o diretório para gravação dos erros
	cDiretory := alltrim(mv_par03)
	cDiretory += Iif( Right( cDiretory, 1 ) == "\", "", "\" )
	//valida o diretório
	If !ExistDir( cDiretory )
		Aviso("Diretório","Diretório '" + cDiretory + "' invalido.",{"Ok"},2)
		Return
	Endif

	IF !File(cItens)
		Aviso("Cabeçalho","Arquivo de itens '" + cItems + "' invalido.",{"Ok"},2)
		Return
	EndIF

	//leitura dos arquivos
	MSGRun("Fazendo a leitura do arquivo de Itens.","Itens",{|| aItens := SptFile(cItens) })

	//Processamento
	ProcItens( aItens, oProcess)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcItens
Realiza processamento dos itens.

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function ProcItens(aItens, oProc)
Local nAux 		:= 1  
Local lConf		:= .F.	   

Private aTabela   := {}
Private	aConfItens	:= {}
Private aAuxConf	:= {}         
Private aRelatCab	:= {}
Private	aRelatItens	:= {}		

Private lAutoErrNoFile := .T.  


	//Regua
	oProc:SetRegua1( len(aItens) )
	DbSelectArea('SB1')
	SB1->( dbSetOrder(1) )
	DbSelectArea('DA1')
	DA1->( dbSetOrder(2) )

    For nAux := 3 to Len(aItens[1])
    	If !Empty(Alltrim(aItens[1][nAux]))
    		AADD(aTabela,Alltrim(aItens[1][nAux]))
        Else
        	Exit
    	EndIf
    Next   
    
	Begin Transaction

	For s1 := 2 to len(aItens)

		//Regua 1
		oProc:IncRegua1(cValtoChar(s1)+"/"+cValToChar(len(aItens))+ " -> " + aItens[s1][__PRODUTO]+' - '+ aItens[s1][__DESC])
	
		//Localiza o produto
		SB1->(DbGoTop())
		
		If !SB1->( dbSeek( xFilial("SB1") + aItens[s1][__PRODUTO] ) )
		   	AADD(aConfItens,{aItens[s1][__PRODUTO],aItens[s1][__DESC],'INEXISTENTE','',0.00,0.00})
			Loop //go For->s1           
		Else
			For nTab := 1 to Len(aTabela)
				DA1->(DbGoTop())                            
				nVAlAux := STRTRAN(aItens[s1][2+nTab],'.','')
				nValAux := Val(STRTRAN(nVAlAux,',','.'))				
				If DA1->(DbSeek(xFilial('DA1')+PADR(aItens[s1][__PRODUTO],TAMSX3("DA1_CODPRO")[1])+aTabela[nTab]))    
					AADD(aConfItens,{aItens[s1][__PRODUTO],aItens[s1][__DESC],'ATUALIZAR',aItens[1][2+nTab],DA1->DA1_PRCVEN,nValAux})
					UpdDA1(aItens[s1][2+nTab])
				Else    
					AADD(aConfItens,{aItens[s1][__PRODUTO],aItens[s1][__DESC],'INLCUIR',aItens[1][2+nTab],0.00,nValAux})                  
					IncDA1(aTabela[nTab],aItens[s1][__PRODUTO],aItens[s1][2+nTab])
				EndIf
	  		Next				
		EndIF

	Next s1  
	   
	lConf := Confirmar(3+Len(aTabela),aConfItens)
	
	If !lConf     
		Alert('Atualização de preços não realizada!')
		//DisarmTransaction() 
		Return
	EndIf         
	
	End Transaction       
	
	RFAT009()	

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Cria grupo de perguntas, caso não exista

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function CriaSX1(cPerg)

//arquivos
PutSx1(cPerg,"01","Arquivo Importação   ","","","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o diretório onde está o arquivo","com os itens para atualização.","",""},{"","","",""},{"","",""},"")
//Diretorio
PutSx1(cPerg,"02","Diretório para erros?","","","mv_ch2","C",99,0,0,"G","","HSSDIR","","","mv_par02","","","","","","","","","","","","","","","","",{"Informe o diretório destino dos erros","desta importação","",""},{"","","",""},{"","",""},"")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SptFile
Função para leitura e separação do arquivo

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function SptFile(cFile,lUltimaColuna)

	Local aRet   := {}
	Local aLinha := {}

	Default lUltimaColuna := .T.

	//Abre o arquivo
	FT_FUse(cFile)

	While !FT_FEof()

		//Leitura da linha do arquivo
		aLinha := Split( FT_FReadLn(), ";", lUltimaColuna )

		IF len(aLinha) != 0 
			If !Empty(Alltrim(aLinha[1]))
				aAdd( aRet, aClone(aLinha) ) 
			EndIf
		EndIF

		//pula linha
		FT_FSkip()

	EndDO

	//fecha arquivo texto
	FT_FUse()

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} Split
Função para realizar separação da string dom arquivo

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function Split(cLin,cSep,lUltimaColuna)

Local aPar := {}
Local nPos := ""

While At( cSep, cLin ) != 0
	nPos := At( cSep, cLin )
	aAdd( aPar, alltrim( Subs( cLin, 1, nPos-1 ) ) )
	cLin := Subs( cLin, nPos+len(cSep), len(cLin) )
EndDO

IF lUltimaColuna
	aAdd( aPar, alltrim( cLin ) )
EndIF

Return(aPar)         

//-------------------------------------------------------------------
/*/{Protheus.doc} IncDA1
Função para realizar inclusão do item na tabela de preços

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function IncDA1(cTab,cCodPro,nValor)

	RecLock('DA1',.T.)
	DA1->DA1_FILIAL := xFilial('DA1')
	DA1->DA1_CODTAB := cTab         
	DA1->DA1_CODPRO := cCodPro
	DA1->DA1_PRCVEN := Val(STRTRAN(STRTRAN(nValor,'.',''),',','.'))
	DA1->DA1_ATIVO  := '1' 
	DA1->DA1_TPOPER := '4'
	DA1->DA1_QTDLOT := 999999.99
	DA1->DA1_INDLOT	:= '000000000999999.99'
	DA1->DA1_MOEDA	:= 1
	DA1->DA1_DATVIG := dDataBase 
	DA1->DA1_ITEM   := maxitem(cTab)  
	DA1->DA1_DTATU	:= dDataBase
	DA1->(MsUnlock())					

Return        

//-------------------------------------------------------------------
/*/{Protheus.doc} maxitem
Função para realizar busca do item na tabela de preços

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function maxitem(cTab)
Local cItem 	:= ""
Local cQuery 	:= ""

	cQuery := " SELECT MAX(DA1_ITEM) AS ITEM "
	cQuery += " FROM "+RetSqlName('DA1')
	cQuery += " WHERE "
	cQuery += " 	DA1_FILIAL = '"+xFilial('DA1')+"' AND DA1_CODTAB = '"+cTab+"' AND D_E_L_E_T_ != '*' "

	If (Select("QRYITEM") <> 0)
		DbSelectArea("QRYITEM")
		QRYITEM->(DbCloseArea())
	Endif
		
	TCQuery cQuery new Alias "QRYITEM"
    If !QRYITEM->(EOF())
		cItem := StrZero(Val(QRYITEM->ITEM)+1,4)
	Else
		cItem := '0001'
	EndIf 	

	QRYITEM->(DbCloseArea())

Return cItem     

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdDA1
Função para realizar alteração do item na tabela de preços

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function UpdDA1(nValor)

	RecLock('DA1',.F.)
	DA1->DA1_PRCVEN := Val(STRTRAN(STRTRAN(nValor,'.',''),',','.'))
	DA1->DA1_DTATU	:= dDataBase
	DA1->(MsUnlock())
                                           
Return                          

//-------------------------------------------------------------------
/*/{Protheus.doc} Confirmar
Função para apresentar as alterações que serão feitas

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function Confirmar(nCols,aItens)

Local lRet := .F.
Local aObjects  	:= {} 
Local aPosObj   	:= {} 
Local aSizeAut  	:= MsAdvSize()             
Local aButtons := {}            
			
Private cCadastro 	:= "Importação Tabela de Preços" 
Private oGet
Private nLen		:= 0    
		
static oDlgI           	



//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//                          
	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
					
		@ 005, 005 group oGrpCabec to 270, 505 prompt 'Preços' of oDlgI	color 0,16777215 pixel
		GRIDCRIT(nCols,aItens)// cabecalho                                          
		

		ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| lRet := .T., oDlgI:end()}, {|| oDlgI:end()},,@aButtons))
	
Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function GRIDCRIT(nCols,aItens)
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'B1_COD','B1_DESC','B1_CONTA'}
	local aFieldFill	:= {}
	local aAlterFields	:= {}


	aAdd(aFieldFill, "")
	aAdd(aFieldFill, "")
	aAdd(aFieldFill, "")
		
	For nI := 4 to nCols 
		AADD(aFields,'B1_PRV1') 
		AADD(aFields,'B1_PRV1')
		aAdd(aFieldFill, 0.00)
		aAdd(aFieldFill, 0.00)		
	Next
	 nAuxPos := 0
//	dbSelectArea('SX3')
//	dbSetOrder(2)
//	for nX := 1 to len(aFields)
//		if SX3-> (dbSeek(aFields[nX]))  
//			If nX == 3
//				aAdd(aHeader,{'Status', X3_CAMPO,X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO,X3_TIPO,X3_F3, X3_CONTEXT, X3_CBOX, X3_RELACAO})    			
//			ElseIf nX > 3        
//				If Mod(nX,2) == 0
//					aAdd(aHeader,{aTabela[nX-3-nAuxPos]+" - Anterior ", X3_CAMPO, ;
//							X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO,X3_TIPO,X3_F3, X3_CONTEXT, X3_CBOX, X3_RELACAO}) 
//					nAuxPos++		   				
//				Else
//					aAdd(aHeader,{aTabela[nX-3-nAuxPos]+" - "+SubStr(Posicione('DA0',1,xFilial('DA0')+aTabela[nX-3-nAuxPos],"DA0_DESCRI"),1,10), X3_CAMPO, ;
//							X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO,X3_TIPO,X3_F3, X3_CONTEXT, X3_CBOX, X3_RELACAO})    
//				EndIf            
				
//			Else
//				aAdd(aHeader,{trim(X3_TITULO), X3_CAMPO,X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO,X3_TIPO,X3_F3, X3_CONTEXT, X3_CBOX, X3_RELACAO})    			
//			EndIf
//		endIf
//	next
	
	aAdd(aFieldFill, .f.)

	For ni :=  1 to Len(aConfItens)      
        nLin := aScan(aCols,{|X|Alltrim(X[1])==aConfItens[nI][1]})
		If nLin == 0
			aFieldFill[1] := aConfItens[nI][1]
			aFieldFill[2] := aConfItens[nI][2]
			aFieldFill[3] := aConfItens[nI][3]
			nPos := aScan(aHeader,{|X|Alltrim(SubStr(X[1],1,3))==aConfItens[nI][4]})
			If nPos > 0  
				aFieldFill[nPos] := aConfItens[nI][5]  
				aFieldFill[nPos+1] := aConfItens[nI][6]
			EndIf  	
			aFieldFill[Len(aHeader)+1] := .F. 	
    		aAdd(aCols,aClone(aFieldFill))
		Else
			nPos := aScan(aHeader,{|X|Alltrim(SubStr(X[1],1,3))==aConfItens[nI][4]})
			If nPos > 0  
				aCols[nLin][nPos] := aConfItens[ni][5]  
				aCols[nLin][nPos+1] := aConfItens[ni][6]  	
			EndIf
		EndIf
		
	Next	
                         
	aRelatCab 	:= aClone(aHeader)
	aRelatItens	:= aClone(aCols)

 	oGet := MsNewGetDados():New( 020, 010, 265, 500,, 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	
                                           
Return                           

//-------------------------------------------------------------------
/*/{Protheus.doc} RFAT009
Relatório contendo o resultado da importação

@sample	ReportDef() 

@author	Felipe Toazza Caldeira
@since	28/09/2015
@return	oReport - Objeto de impressão do relatório
/*/
//-------------------------------------------------------------------       
Static Function RFAT009() 
Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Configura o objeto TReport. 

@sample	ReportDef() 

@author	Felipe Toazza Caldeira
@since	28/09/2015
@return	oReport - Objeto de impressão do relatório
/*/
//-------------------------------------------------------------------   
Static Function ReportDef() 

Local cTituRel	:= "SENTAX - Importação de tabela de preços"
Local cDescRel 	:= "Este programa ira emitir o relatório "+cTituRel
Local aOrdem   	:= {} 
Local cPerg		:= "RFAT009"
Local oReport  
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oBreak1
Local oBreak2  

oReport := TReport():New(cPerg,cTituRel,cPerg, {|oReport| ReportPrint(oReport)},cDescRel)   

oReport:SetPortrait()
oReport:SetTotalInLine(.F.) 
oReport:HideParamPage()
oReport:DisableOrientation()


oSection1 := TRSection():New(oReport,"Importação tabela de preços",{}) 

TRCell():New(oSection1, "PRODUTO"	,"SB1","Produto"	,"@!",TAMSX3("B1_COD")[1])	
TRCell():New(oSection1, "DESCRI"	,"SB1","Descrição"	,"@!",TAMSX3("B1_DESC")[1])	
TRCell():New(oSection1, "STATUS"	,"SB1","Status"		,"@!",TAMSX3("B1_CONTA")[1])				


For nI := 4 to Len(aRelatCab)
	TRCell():New(oSection1, Alltrim(STR(nI))	,"SB1",aRelatCab[nI][1]	,"@E 999,999.9999",14)				                                                            
	oSection1:Cell(Alltrim(STR(nI))):nHeaderAlign := 3	// Alinhamento da célula. 1-Esquerda, 2-Center ou 3-Direita.  
Next

Return oReport
                                

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função de impressão do relatório.

@sample	ReportPrint(oReport)

@param	oReport - Objeto do tReport para impressão

@author Felipe Toazza Caldeira
@since	28/09/2015
@return	NIL
/*/
//-------------------------------------------------------------------   
Static Function ReportPrint(oReport)
    
	Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
                                         
    oReport:SetMeter(0)
  	oSection1:Init()
      
    oReport:SetTitle( oReport:Title()  )     
                  
	// Busca o total para impressão da primeira linha
	For nK := 1 to Len(aRelatitens)
		
		oReport:IncMeter() 
		
		If oReport:Cancel()
			Exit
		EndIf  
		
		oSection1:Cell("PRODUTO"):SetValue(aRelatitens[nK][1])
		oSection1:Cell("DESCRI"):SetValue(aRelatitens[nK][2])
		oSection1:Cell("STATUS"):SetValue(aRelatitens[nK][3])			 

		For nJ := 4 to len(aRelatCab)
			oSection1:Cell(Alltrim(STR(nJ))):SetValue(aRelatitens[nK][nJ])	
		Next		
		oSection1:PrintLine()

	Next	
	oSection1:Finish() 
	oReport:SkipLine(1)
				
Return        
//SSSSS