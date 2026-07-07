#include "protheus.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

#DEFINE MAX_X 900
#DEFINE MAX_Y 500
#DEFINE XCAB 260
#DEFINE MIN_X 40
#DEFINE PINCEL_Y 4
#DEFINE PINCEL_X 7

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS001
Etiqueta de expedição para a impressora Argox
	
@param lAuto  - Indicar .T. se chamada for através de outra rotina ou ponto de entrada
@param cSerie - Indica a séria da NF das etiquetas de volumes
@param cNota  - Indica o número da NF das etiquetas de volumes

@sample u_ROMS001(.T.,cSerie,cNota)

@author Thiago Henrique dos Santos
@since 17/01/201414
@version 1.0		

@return nil, Nulo


/*/
//-------------------------------------------------------------------------------


User Function ROMS001(lAuto,cSerie,cNota)
Local cPerg := "ROMS001"
Local cAliasTemp := GetNextAlias()
Local aArea := {}
Local aAreaSA4 := {}
Local aAreaSD2 := {}
Local aAreaSA1 := {}
Default lAuto := .F.
Default cSerie := ""
Default cNota := ""
 
Private lMarca := .F.
Private _nParNmFor := SuperGetMv("ST_XNOMFOR", .T., 1) // 1=A4_NOME; 2=A4_NREDUZ

   


aArea := GetArea()

aAreaSA1 := SA1->(GetArea())
aAreaSA4 := SA4->(GetArea())
aAreaSD2 := SD2->(GetArea())




If !lAuto

	AjustaSx1(cPerg)
	
	If !Pergunte(cPerg,.T.)
	
		Return	
	
	Endif
	


Else

	MV_PAR01 := cNota
	MV_PAR02 := cNota
	MV_PAR03 := cSerie	
	MV_PAR04 := cSerie
	MV_PAR05 := ""
	MV_PAR06 := 2

  
Endif


	


//O comando abaixo imprime diretamente sem abrir a tela de configurações para impressão...
//Wnrel := SetPrint(cString,Wnrel,"","","","","",.F.,,.F.,Tamanho,,.F.,,"EPSON.DRV",.T.,.T.,"LPT1")  


conout("antes default")
//SetDefault(aReturn,cString)


BeginSql  Alias cAliasTemp

	SELECT F2_DOC,;
			F2_SERIE,;
			F2_CLIENTE,;
			F2_LOJA,;
			F2_VOLUME1,;
			F2_TRANSP
			
	FROM   %Table:SF2% SF2
	
	WHERE 	SF2.F2_FILIAL = %xFilial:SF2% AND
	
			SF2.F2_DOC   BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND 
			SF2.F2_SERIE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
			SF2.F2_VOLUME1 > 0 AND
			SF2.%NotDel%

EndSql

DbSelectArea(cAliasTemp)

(cAliasTemp)->(DbGoTop())

If (cAliasTemp)->(!Eof())

	If !lAuto
		Processa({||PrintRel(cAliasTemp)})
	Else
	
		conout("entrando em printrel")
		PrintRel(cAliasTemp,lAuto)
		
	Endif

	
ElseIf !lAuto

	Alert("Não existem dados a serem impressos com os parâmetros selecionados.")
Else

	conout("Não existem dados a serem impressos com os parâmetros selecionados.")

Endif


(cAliasTemp)->(DbCloseArea())

SD2->(RestArea(aAreaSD2))
SA4->(RestArea(aAreaSA4))
SA1->(RestArea(aAreaSA1))
RestArea(aArea)



Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} PrintRel
Rotina que realiza a impressão

@param cAliasTemp - Alias Temporário	

@author Thiago Henrique dos Santos
@since 22/01/201414
@version 1.0		

@return nil, Nulo


/*/
//-------------------------------------------------------------------------------
Static Function PrintRel(cAliasTemp,lAuto)

Local nI		:= 0
Local nJ		:= 0
Local nTemp		:= 0 
Local nRow		:= 0
Local nEsp 		:= 0
Local aTemp 	:= {}
Local aTemp2	:= {}
Local aSeq 		:= {}
Local aEtiq 	:= {} 
Local lAjust 	:= .F. 
Local cTemp 	:= ""
Local cCodCli 	:= ""
Local cLojCli 	:= ""
Local cCodTrans	:= ""
Local cDoc 		:= ""
Local cVol 		:= ""   
Local cFile 	:= "ROMS001_"+cEmpAnt+"_"+cFilAnt+"_"+Dtos(MSDate())+"_"+StrTran(Time(),":","")
Local oFontA12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)	//Arial 12 com negrigo
Local oFontA14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)	//Arial 14 com negrigo 
Local oFontA16	:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)	//Arial 16 sem negrigo
Local oFontA16N	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)	//Arial 16 com negrigo 
Local oFontA18	:= TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)	//Arial 18 sem negrigo
Local oFontA19N	:= TFont():New("Arial",19,19,,.T.,,,,.T.,.F.)	//Arial 19 com negrigo
Local oPrint
 
ProcRegua(0)
IncProc("Processando... Aguarde")

//*********************************************************************************************************
//Parte do código que trata as sequências (páginas de impressão) a serem impressas, no padrão Windows     *
//1-5, serão impressas todas as páginas de 1 a 5														  *
//1;5 serão impressas somente as páginas 1 e 5															  *
//1-5;9 serão impressas todas as páginas de 1 a 5 e a página 9											  *
//Em branco todas as páginas serão impressas															  *
//*********************************************************************************************************
If !Empty(MV_PAR05)
	
	aTemp := StrTokArr(MV_PAR05,"-")
	
	If Empty(aTemp)
	
		AADD(aTemp,Alltrim(MV_PAR05))
			
	Endif
	
	For nI := 1 to len(aTemp)
	
		aTemp2 := ACLONE(StrTokArr(aTemp[nI],";"))
		
		If Empty(aTemp2)
		
			AADD(aTemp2,aTemp[nI])
		
		Endif
		
		If nI > 1 .AND. !Empty(aSeq)
		
			If aSeq[len(aSeq)] < val(aTemp2[1]) - 1
			
				nTemp := val(aTemp2[1]) - aSeq[len(aSeq)] - 1
				
				For nJ := 1 to nTemp
				
					AADD(aSeq,aSeq[Len(aSeq)]+1)
				
				Next nJ
			
			Endif
		
		Endif
		
		For nJ := 1 to len(aTemp2)
		
			AADD(aSeq,val(aTemp2[nJ]))		
		
		Next nJ
	
	
	Next nI
	
Endif

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

oPrint:SetResolution(72)

While (cAliasTemp)->(!Eof())

	cCodCli		:= (cAliasTemp)->F2_CLIENTE
	cLojCli 	:= (cAliasTemp)->F2_LOJA
	cCodTrans 	:= (cAliasTemp)->F2_TRANSP
	cDoc 		:= (cAliasTemp)->F2_DOC
		
	For nI := 1 to (cAliasTemp)->F2_VOLUME1
	
		// Se faz parte da sequencia a ser impressa
		If Empty(aSeq) .OR. aScan(aSeq,{|x| x == nI} ) > 0 .AND. nI <= (cAliasTemp)->F2_VOLUME1 
		
			cVol := Strzero(ni,3)
			
			oPrint:StartPage()
            
			// EMPRESA 
			nRow := nEsp + 5
			
			oPrint:Say (nRow,5+MIN_X,SubStr(AllTrim(SM0->M0_NOMECOM),1,40),oFontA19N)  
			
			// TELEFONE	
			cTelefone := ""		
				
			If "CURITIBA" $ SM0->M0_CIDCOB

				cTelefone := "(41) " + Transform(Alltrim(SM0->M0_TEL),"@R 9999-9999")

			ElseIf "JOINVILLE" $ SM0->M0_CIDCOB

				cTelefone := "(47) " + Transform(Alltrim(SM0->M0_TEL),"@R 9999-9999")

			ElseIf "FOZ" $ SM0->M0_CIDCOB

				cTelefone := "(45) " + Transform(Alltrim(SM0->M0_TEL),"@R 9999-9999")

			Endif   
			
			If ! Empty(cTelefone)
		   		oPrint:SayAlign (nRow, 5+MIN_X, cTelefone, oFontA12N, MAX_X, 50, , 2, 0 ) 
		 	EndIf

			//DESTINATARIO			
			nRow += nEsp + nEsp/2
	
			If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
     
				cNomeCli := Alltrim(SA1->A1_NOME) 
				cNomeCli := Substr(cNomeCli,1,36)
				
				oPrint:SayAlign (nRow,5+MIN_X,"PARA: "+cNomeCli,oFontA14N, MAX_X+100, 50, , 2, 0 ) 
	              
				nRow += nEsp
	
				// CIDADE ESTADO 
				cTemp := AllTrim(SA1->A1_MUNE) 				
				cTemp += IIf(Empty(cTemp),""," - ")+IIF(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST)
				cTemp := Upper(cTemp)
				oPrint:SayAlign (nRow,5+MIN_X,SubStr(Alltrim(cTemp),1,70),oFontA14N, MAX_X+100, 50, , 2, 0 )	

			Endif
                       
            // NF/VOLUME
			nRow += nEsp + nEsp + nEsp + nEsp/2
			
			If !lAuto  
				nRow -= 20
			EndIf

			oPrint:Say (nRow,5+MIN_X,"NF / VOLUME"+Space(08)+cDoc +" / "+ cVol+" / " + StrZero((cAliasTemp)->F2_VOLUME1,3),oFontA16)
			
			// CODIGO DE BARRAS 			
			If lAuto           
				nRow += 240
			Else
		   		nRow += 250
			EndIf

 			oPrint:Code128C(nRow+10,5+MIN_X,cDoc+cVol, 80)  			
 			
			// TRANSPORTADORA
			If SA4->(DbSeek(xFilial("SA4")+cCodTrans)) 
			    
				If _nParNmFor == 1 // 1=A4_NOME; 2=A4_NREDUZ
					cNomeTrans := Alltrim(SA4->A4_NOME)  
				Else
					cNomeTrans := Alltrim(SA4->A4_NREDUZ)
				EndIf
				   
				cNomeTrans := Substr(cNomeTrans,1,18)
			    
			    If lAuto
					oPrint:Say (nRow,MAX_X+175,cNomeTrans,oFontA16N,,,270 ) 
				Else
					oPrint:Say (nRow,MAX_X+150,cNomeTrans,oFontA16N,,,270 )
				EndIf
			
			EndIf  
			
			// DESCRICAO CODIGO DE BARRAS  
			nRow += nEsp + 15
			
			oPrint:Say (nRow,5+MIN_X+240,cDoc+cVol,oFontA18)
            
			oPrint:EndPage()
		Endif
	Next nI
	
	(cAliasTemp)->(DbSkip())

Enddo

oPrint:Print()

Return




//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do programa
	
@author Thiago Henrique dos Santos
@since 23/01/2013
@version 1.0		

@return nil, sem retorno

/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1(cPerg)

	Local aHelpPerg  := {}
	
	aAdd(aHelpPerg,{"Nota fiscal Inicial"})
	aAdd(aHelpPerg,{"Nota fiscal Final"})

	aAdd(aHelpPerg,{"Série inicial da nota fiscal."})
	aAdd(aHelpPerg,{"Série final da nota fiscal."  })

	aAdd(aHelpPerg,{"Sequências a serem impressas.",;
					  " Para imprimir todas, deixar ",;
	                "em branco. Para especificar:",;
	                " Ex. separar por vírgula 2,5",;
	                " imprimirá a 2 e a 5. ",;
	                "Separar por hífen 2-5 ",;
	                "imprimirá as 2,3,4 e 5. "})
	                
	aAdd(aHelpPerg,{"Indica se apenas visualiza" })

	PutSX1(cPerg,"01","De NF saída"      ,"" ,"" ,"MV_CH1" ,"C",9,0,0,"G","","SF2001" ,"018" ,"S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})
	PutSX1(cPerg,"02","Até NF saída"     ,"" ,"" ,"MV_CH2" ,"C",9,0,0,"G","","SF2001" ,"018" ,"S","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPerg[2] ,{},{})
	PutSX1(cPerg,"03","Da série"         ,"" ,"" ,"MV_CH3" ,"C",3,0,0,"G","","",""    ,"S","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPerg[3] ,{},{})
	PutSX1(cPerg,"04","Até série"        ,"" ,"" ,"MV_CH4" ,"C",3,0,0,"G","","",""    ,"S","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPerg[4] ,{},{})
	PutSX1(cPerg,"05","Etiqueta SEQ"     ,"" ,"" ,"MV_CH5" ,"C",20,0,0,"G","","",""    ,"","MV_PAR05",""   ,"","","",""   ,"","","","","","","","","","","",aHelpPerg[5] ,{},{})
	PutSx1(cPerg,"06","Visualiza?"		  ,"",""  ,"MV_CH6" ,"N",01,0,0,"C","","",""    ,"","MV_PAR06","Sim","","","","Nao","","","","","","","","","","","",aHelpPerg[6] ,{},{})
Return  