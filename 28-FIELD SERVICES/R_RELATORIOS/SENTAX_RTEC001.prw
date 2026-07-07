#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#Include "TOPCONN.CH"  

#DEFINE nColIni 0030 	// Coluna inicial
#DEFINE nColFim	2300 	// Coluna Final

#DEFINE nEspacoA 0055 // 10	// Espaço entre linhas
#DEFINE nEspacoB 0035 // 07	// Espaço entre linhas
#DEFINE nEspacoC 0082 // 15	// Espaço entre linhas   
#DEFINE nEspacoD 0035 // 07	// Espaço entre linhas

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RTEC001
Novo layout da OS para o Field Service

@author		Alessandro Smaha
@since		13/06/2014

/*/
//-------------------------------------------------------------------------------
User Function RTEC001(cCodOs)

Local lImpRel	:= .F.
Local oReport

Default cCodOs 	:= ""

Private lWeb	:= .F.	// Valida se o relatorio é para WEB
Private cPerg 			:= "RTEC001"

//cCodOs := "000726"

DbSelectArea("AB6")
AB6->(DbSetOrder(1)) // AB6_FILIAL+AB6_NUMOS

AjustaSx1(cPerg)

If !Empty(cCodOs)
	
	Pergunte(cPerg,.F.)
	
	MV_PAR01 := cCodOs
	
	lImpRel	:= .T.
	
Else
	
	If Pergunte(cPerg,.T.)
		cCodOs := MV_PAR01
		lImpRel	:= .T.
	EndIf
	
EndIf

If lImpRel
	
	oReport := fPrintRel(cCodOs)
	
	If !lWeb
		oReport:PrintDialog()
	EndIf
	
EndIF

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fPrintRel
Definição do relatório de Ordem de Serviço

@author		Alessandro Smaha
@since		13/06/2014

/*/
//-------------------------------------------------------------------------------
Static Function fPrintRel(cCodOs)

Local oReport

Private cTitulo     := "Ordem de Serviço"
Private cDesc1      := "Impressão Ordem de Serviço"
Private cTamanho    := "G"

oReport := TReport():New("RTEC001",cTitulo,"RTEC001",{ |oReport| fPrtRel(oReport,cCodOs) }, cDesc1 )

oReport:SetPortrait()        // Define orientação de página do relatório como retrato.
oReport:DisableOrientation() // Desabilita a seleção da orientação (Retrato/Paisagem)
oReport:HideHeader(.F.)
oReport:HideParamPage(.F.)

Return oReport


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fPrtRel
Impressão do relatório de Ordem de Serviço

@author		Alessandro Smaha
@since		13/06/2014

/*/
//-------------------------------------------------------------------------------
Static Function fPrtRel(oReport,cCodOs)

Local nCorBrco  := 16777215
Local nCorAzul	:= 7684405
Local li		:= 0
Local oBrush	:= TBrush():New( , nCorAzul)

Local cLogo1 	:= "lg_sentax001.bmp"
Local cLogo2 	:= "lg_sentax002.bmp"

Local aArea		:= GetArea()
Local cTecnico	:= ""  
Local cCodChm  	:= ""

Local oFont05	:= TFont():New("Arial",	05,05,,.F.,,,,.T.,.F.)	//Arial   05 sem negrigo
Local oFont06N	:= TFont():New("Arial",	06,06,,.T.,,,,.T.,.F.)	//Arial   06 com negrigo
Local oFont06	:= TFont():New("Arial",	06,06,,.F.,,,,.T.,.F.)	//Arial   06 sem negrigo
Local oFont07N	:= TFont():New("Arial",	07,07,,.T.,,,,.T.,.F.)	//Arial   07 com negrigo
Local oFont07	:= TFont():New("Arial",	07,07,,.F.,,,,.T.,.F.)	//Arial   07 sem negrigo
Local oFont08  	:= TFont():New("Arial",	08,08,,.F.,,,,.T.,.F.)	//Arial   08 sem negrigo
Local oFont08N	:= TFont():New("Arial",	08,08,,.T.,,,,.T.,.F.)	//Arial   08 com negrigo
Local oFont09  	:= TFont():New("Arial",	09,09,,.F.,,,,.T.,.F.)	//Arial   09 sem negrigo 
Local oFont09N	:= TFont():New("Arial",	09,09,,.T.,,,,.T.,.F.)	//Arial   09 com negrigo
Local oFont10  	:= TFont():New("Arial",	10,10,,.F.,,,,.T.,.F.)	//Arial   10 sem negrigo
Local oFont10N 	:= TFont():New("Arial",	10,10,,.T.,,,,.T.,.F.)	//Arial   10 com negrigo
Local oFont11N 	:= TFont():New("Arial",	11,11,,.T.,,,,.T.,.F.)	//Arial   11 com negrigo
Local oFont12  	:= TFont():New("Arial", 12,12,,.F.,,,,.T.,.F.)	//Arial   12 sem negrigo
Local oFont12N 	:= TFont():New("Arial",	12,12,,.T.,,,,.T.,.F.)	//Arial   12 com negrigo
Local oFont14  	:= TFont():New("Arial", 14,14,,.F.,,,,.T.,.F.)	//Arial   14 sem negrigo
Local oFont14N 	:= TFont():New("Arial", 14,14,,.T.,,,,.T.,.F.)	//Arial   14 com negrigo
Local oFont16N 	:= TFont():New("Arial", 16,16,,.T.,,,,.T.,.F.)	//Arial   16 com negrigo
Local oFont18N 	:= TFont():New("Arial", 18,18,,.T.,,,,.T.,.F.)	//Arial   18 com negrigo
      
Local nPosFim := 0
Local nCol001 := 0
Local nCol002 := 0
Local nCol003 := 0
Local nCol004 := 0
Local nCol005 := 0
Local nCol006 := 0
Local nCol007 := 0
Local nCol008 := 0
Local nCol009 := 0
Local nCol010 := 0
Local nCol011 := 0
Local nCol012 := 0
Local nCol013 := 0
Local nLinRod := SuperGetMv("ST_XRODAPE",,2290) // Parâmetro para iniciar a impressão do rodapé  
Local cEquip001	:= ""
Local cEquip002 := ""
Local cEquip003 := ""
Local cEquip004 := ""
Local cDataPrv	:= "" 
Local cOcorre	:= ""

// Ajusta o tamanho das colunas para o relatório

nMargem := nColIni

nMeio1_4 := ((nColFim-nMargem) / 02) // 300
nMeio1_3 := ((nColFim-nMargem) / 04) // 150
nMeio1_2 := ((nColFim-nMargem) / 08) // 75
nMeio1_1 := ((nColFim-nMargem) / 16) // 37.5

nCol001 := nMeio1_1 - 15 					+ nMargem 
nCol002 := nMeio1_1 + 15 					+ nMargem
nCol003 := nMeio1_2 						+ nMargem
nCol004 := nMeio1_2 + nMeio1_1 				+ nMargem
nCol005 := nMeio1_3 						+ nMargem
nCol006 := nMeio1_3 + nMeio1_1 				+ nMargem
nCol007 := nMeio1_3 + nMeio1_2 				+ nMargem
nCol008 := nMeio1_4 						+ nMargem
nCol009 := nMeio1_4 + nMeio1_1 				+ nMargem
nCol010 := nMeio1_4 + nMeio1_2 				+ nMargem
nCol011 := nMeio1_4 + nMeio1_2 + nMeio1_1 	+ nMargem
nCol012 := nMeio1_4 + nMeio1_3 				+ nMargem
nCol013 := nMeio1_4 + nMeio1_3 + nMeio1_2 	+ nMargem

If AB6->(DbSeek(xFilial("AB6")+cCodOs))    

	// Alimenta as variáveis para impressão do relatório
		
	cLinha   := ""
	cServico := "" 
	cRegiao  := ""
	cOsPor   := ""
	cContato := ""
	cVend	 := ""
	cCodCli  := ""
	cNomCli  := ""
	cFanCli  := ""
	cEndere  := ""
	cBairro  := ""
	cCidade  := ""
	cEstado  := ""
	cCep     := ""
	cTel     := ""
	cEndEnt  := ""
	cMotivo1 := ""
	cMotivo2 := ""
	cMotivo3 := "" 
	cSolPor  := "" 
	cCodPro  := "" 
	cCodGrp  := ""  
	cDataEm  := ""  
	cCodSer  := ""
	cCodVend := ""	 
	cTecnico := "" 
	cCodChm  := fBuscaChm(cCodOs)
	
	cCodTec	 := AB6->AB6_XCDTEC
	
	cOsPor  := Alltrim(AB6->AB6_ATEND)
	cSolPor := Alltrim(AB6->AB6_ATEND)

	dDataEm  := AB6->AB6_EMISSA
	
	cDataEm := DtoC(dDataEm)   
	cDataPrv := DtoC(AB6->AB6_XDATPR) 
	
	cAnoEmis := Substr(cValToChar(Year(dDataEm)),3,2)  
	
	DbSelectArea("AB7")
	AB7->(DbSetOrder(1)) // AB7_FILIAL+AB7_NUMOS+AB7_ITEM 

	DbSelectArea("AB8")
	AB8->(DbSetOrder(1)) // AB8_FILIAL+AB8_NUMOS+AB8_ITEM+AB8_SUBITE
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD  
	
	DbSelectArea("AA1")
	AA1->(DbSetOrder(1)) // AA1_FILIAL+AA1_CODTEC
		
	DbSelectArea("AA5")
	AA5->(DbSetOrder(1)) // AA5_FILIAL+AA5_CODSER 
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA  
	
	DbSelectArea("Z08")
	Z08->(DbSetOrder(1)) // Z08_FILIAL+Z08_CODCLI+Z08_LOJA+Z08_SEQUEN
	
	DbSelectArea("AB1")
	AB1->(DbSetOrder(1)) // AB1_FILIAL+AB1_NRCHAM
			
	If AB7->(DbSeek(xFilial("AB7")+cCodOs))
		cCodPro := AB7->AB7_CODPRO 
		cMotMemo := Alltrim(MSMM(AB7->AB7_MEMO1,TamSx3("AB7_MEMO2")[1]))	
		cOcorre := Alltrim(AB7->AB7_CODPRB)+" - "+Alltrim(Posicione("AAG",1,xFilial("AAG")+AB7->AB7_CODPRB,"AAG->AAG_DESCRI"))
	EndIf
	
	If ! Empty(cMotMemo)
		cMotMemo := StrTran( cMotMemo , CHR(13)+CHR(10) , " " )   		
		nPosFim := AT(Replicate("-",40), cMotMemo) - 1 
			
		If nPosFim > 340 
			nPosFim := 340
		EndIf	
		
		cMotMemo := Substr(cMotMemo,1,nPosFim) 
		nLinMemo := MLCount(cMotMemo)
		
		For nK := 1 to nLinMemo    
			If nK == 1
				cMotivo1 := Alltrim(MemoLine(cMotMemo,110,nK))
			ElseIf nK == 2
				cMotivo2 := Alltrim(MemoLine(cMotMemo,110,nK)) 
			ElseIf nK == 3
				cMotivo3 := Alltrim(MemoLine(cMotMemo,110,nK))
			EndIf		
		Next nK  
		
	EndIf
		
	If ! Empty(cCodPro) 
	    
	    If !Empty(AB6->AB6_XCLASS)        
	    	cServico := POSICIONE("SX5",1,XFILIAL("SX5")+"A3"+AB6->AB6_XCLASS,"X5_DESCRI")  
	    EndIf                                  
	    
		If Empty(cServico)
			If AB8->(DbSeek(xFilial("AB8")+AB7->(AB7_NUMOS+AB7_ITEM)))
			
				If AA5->(DbSeek(xFilial("AA5")+AB8->AB8_CODSER))
				 	cServico := Upper(Alltrim(AA5->AA5_DESCRI))
				EndIf		
						
			EndIf  
		EndIf
			
		If SB1->(DbSeek(xFilial("SB1")+cCodPro))
			cCodGrp := SB1->B1_GRUPO		
		EndIf   
		
	EndIf	

	If ! Empty(cCodGrp)	// Grupo de Produto
		DbSelectArea("SBM")
		SBM->(DbSetOrder(1)) // BM_FILIAL+BM_GRUPO
		If SBM->(DbSeek(xFilial("SBM")+cCodGrp))
			cLinha := Upper(Alltrim(SBM->BM_DESC))
		EndIf
	EndIf
	
	If SA1->(DbSeek(xFilial("SA1")+AB6->(AB6_CODCLI+AB6_LOJA))) 
		cCodCli  := AB6->AB6_CODCLI
		cNomCli  := Alltrim(SA1->A1_NOME)
		cFanCli  := Alltrim(SA1->A1_NREDUZ)
		cEndere  := Alltrim(SA1->A1_END)
		cBairro  := Alltrim(SA1->A1_BAIRRO)
		cCidade  := Alltrim(SA1->A1_MUN)
		cEstado  := Alltrim(SA1->A1_EST)
		cCep     := Alltrim(SA1->A1_CEP)
		cTel     := Alltrim(SA1->A1_DDD) + " " + Alltrim(SA1->A1_TEL) 
		cContato := Alltrim(SA1->A1_CONTATO)
		cCodVend := SA1->A1_VEND 
		cEndEnt  := Alltrim(SA1->A1_ENDENT)
		
		If ! Empty(AB6->AB6_XCDEND) .AND. AB6->AB6_XCDEND <> "000"
			If Z08->(DbSeek(xFilial("Z08")+AB6->(AB6_CODCLI+AB6_LOJA+AB6_XCDEND)))  
				cEndEnt  := Alltrim(Z08->Z08_ENDERE)+Iif(Empty(AllTrim(Z08->Z08_EST+Z08->Z08_MUN)),"",", "+Z08->Z08_EST+"-"+AllTrim(Z08->Z08_MUN))
			EndIf
	    EndIf
		
	EndIf 
	
	If ! Empty(cCodVend)	
		DbSelectArea("SA3") // Vendedores
		SA3->(DbSetOrder(1)) // A3_FILIAL+A3_COD
		If SA3->(DbSeek(xFilial("SA3")+cCodVend))
			cVend := Upper(Alltrim(SA3->A3_NOME))
		EndIf
	EndIf 
	
	If ! Empty(cCodTec)
		If AA1->(DbSeek(xFilial("AA1")+cCodTec))
	     	cTecnico := Alltrim(AA1->AA1_NOMTEC)	     
		EndIf
	EndIf   
	
	If ! Empty(cCodChm)
  		If AB1->(DbSeek(xFilial("AB1")+cCodChm))
	     	cTel     := Alltrim(AB1->AB1_TEL)
	  		cContato := Alltrim(AB1->AB1_CONTAT)	  
	  		cOsPor   := Alltrim(AB1->AB1_ATEND)
 			cSolPor  := Alltrim(AB1->AB1_ATEND)
   		EndIf
	EndIf
	
	// Busca os Equipamentos do Cliente
	 
	
	lLin1Ok := .F.
	lLin2Ok := .F.
	lLin3Ok := .F.
	lLin4Ok := .F.
			
	If AB7->(DbSeek(xFilial("AB7")+cCodOs))
	
		While ! AB7->(Eof()) .AND. xFilial("AB7") == AB7->AB7_FILIAL .AND. cCodOs == AB7->AB7_NUMOS
		    cEptoCli := Alltrim(AB7->AB7_CODPRO) 
		    If SB1->(DbSeek(xFilial("SB1")+cEptoCli))
				cEptoCli += "-"+Alltrim(SB1->B1_DESC)+" ("+cValToChar(AB7->AB7_XQTDIN)+")"		
			EndIf  
			
			If Len(cEquip001) + Len(cEptoCli) > 120
				lLin1Ok := .T.                   
			EndIf
			                                     
			If Len(cEquip002) + Len(cEptoCli) > 120
				lLin2Ok := .T.
			EndIf 
			
			If Len(cEquip003) + Len(cEptoCli) > 120
				lLin3Ok := .T.
			EndIf
			
			If Len(cEquip004) + Len(cEptoCli) > 120
				lLin4Ok := .T.
			EndIf
			
			If ! lLin1Ok 
			
				cEquip001 += IIF(Empty(cEquip001),""," | ") + cEptoCli
			
			ElseIf ! lLin2Ok  
			
				cEquip002 += IIF(Empty(cEquip002),""," | ") + cEptoCli
			
			ElseIf ! lLin3Ok 
				
				cEquip003 += IIF(Empty(cEquip003),""," | ") + cEptoCli
			
			ElseIf ! lLin4Ok 
				
				cEquip004 += IIF(Empty(cEquip004),""," | ") + cEptoCli
			
			EndIf					
			
	   		AB7->(DbSkip()) 
		EndDo
	EndIf 
		
	// Ínicio do relatório
	
	li := 015
	
	// Vetor com coordenadas no formato: linha inicial, coluna inicial, linha final,coluna final
	oReport:FillRect( { li, nColIni, li+210, 2000 }, oBrush )
	
	oReport:SayBitmap( li, nCol010, cLogo1, 850 /*COMP*/ , /*ALT*/ 210 ) // SayBitmap(nRow,nCol,cBitmap,nWidth,nHeight)
	
	li += 80
	
	// hor -> 0 esquerda 1 direita 2 centralizado ## ver -> 0 centralizado 1 - superior 2 - inferior
	
	oReport:Say ( li, nCol002, "ORDEM DE SERVIÇO - N°  "+cCodOs+"/"+cAnoEmis, oFont14N,,nCorBrco); li += 140
		
	oReport:Say ( li, nColIni, "Linha: "+cLinha, oFont09N)
	oReport:Say ( li, nCol005, "Serviço: "+cServico, oFont09N)
	oReport:Say ( li, nCol009, "Região: "+cRegiao, oFont09N)
	oReport:Say ( li, nCol013, "Data: "+cDataEm, oFont09N); li += nEspacoB
	
	oReport:Say ( li, nColIni, "O.S. Por: "+cOsPor, oFont09N)
	oReport:Say ( li, nCol006, "Contato: "+cContato, oFont09N)
	oReport:Say ( li, nCol010, "Vendedor: "+cVend, oFont09N)
	oReport:Say ( li, nCol013, "Previsão: "+cDataPrv, oFont09N); li += nEspacoB 
		
	oReport:Say ( li, nColIni, "Código: "+cCodCli, oFont09N)
	oReport:Say ( li, nCol003, "Cliente: "+cNomCli, oFont09N)
	oReport:Say ( li, nCol010, "Ocorrência: "+cOcorre, oFont09N); li += nEspacoB
	
	oReport:Say ( li, nColIni, "Nome Fantasia: "+cFanCli, oFont09N)
	oReport:Say ( li, nCol010, "Técnico: "+cTecnico, oFont09N); li += nEspacoB 
	
	oReport:Say ( li, nColIni, "Endereço: "+cEndere, oFont09N)
	oReport:Say ( li, nCol008, "Bairro: "+cBairro, oFont09N); li += nEspacoB
	
	oReport:Say ( li, nColIni, "Cidade: "+cCidade, oFont09N)
	oReport:Say ( li, nCol005, "Estado: "+cEstado, oFont09N)
	oReport:Say ( li, nCol008, "CEP: "+cCep, oFont09N)
	oReport:Say ( li, nCol011, "Telefone: "+cTel, oFont09N); li += nEspacoB	
	
	oReport:Say ( li, nColIni, "Endereço de Entrega: "+cEndEnt, oFont09N); li += nEspacoB	
	
	oReport:Say ( li, nColIni, "Equipamentos: ", oFont09N)
	oReport:Say ( li, nCol003, cEquip001, oFont09N); li += nEspacoB
	oReport:Say ( li, nCol003, cEquip002, oFont09N); li += nEspacoB 
	oReport:Say ( li, nCol003, cEquip003, oFont09N); li += nEspacoB
	oReport:Say ( li, nCol003, cEquip004, oFont09N)
	
	li += (nEspacoB + 15)
	
	oReport:Say ( li, nColIni, "Motivo da O.S.: ", oFont10N)
	oReport:Say ( li, nCol002 + 70, cMotivo1, oFont10N); li += nEspacoB
	oReport:Say ( li, nCol002 + 70, cMotivo2, oFont10N); li += nEspacoB
	oReport:Say ( li, nCol002 + 70, cMotivo3, oFont10N)
	
	li += (nEspacoB)
	
	oReport:Box ( li, nColIni, li+(nEspacoA*9), nCol003 )
	oReport:Box ( li, nCol003, li+(nEspacoA*9), nColFim )
	
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
//	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
//	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	
	nAux := nCol002 - nCol001
	
	oReport:Say ( li+15, nColIni+15, "Observações do", oFont09N)
	oReport:Say ( li+45, nColIni+65, "Técnico:", oFont09N)
	
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
//	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA   
//	oReport:Line( li, nCol003, li, nColFim ); li += nEspacoA
	
	li += nEspacoA
	
	oReport:Box ( li, nColIni, li+(nEspacoA), nColFim )
	
	oReport:Say ( li+15, nColIni+15, "LOCAIS DE INSTALAÇÃO LINHA KC / ECOLAB", oFont07N)
	
	li += nEspacoA
	
	oReport:Box ( li, nColIni, li+(nEspacoA*05), nColFim )
	oReport:Box ( li, nCol003, li+(nEspacoA*05), nCol005 )
	oReport:Box ( li, nCol005, li+(nEspacoA*05), nCol007 )
	oReport:Box ( li, nCol007, li+(nEspacoA*05), nCol008 )
	oReport:Box ( li, nCol008, li+(nEspacoA*05), nCol010 )
	
	oReport:Say ( li+015, nColIni+070, "Local / Qntd", oFont07N)
	oReport:Say ( li+015, nCol003+090, "Produto", oFont07N)
	oReport:Say ( li+015, nCol005+090, "Produto", oFont07N)
	oReport:Say ( li+015, nCol007+090, "Produto", oFont07N)
	oReport:Say ( li+015, nCol008+090, "Produto", oFont07N)
	oReport:Say ( li+015, nCol012+060, "Observações", oFont07N)
	
	li += nEspacoA
	
	oReport:Box ( li, nCol010, li+(nEspacoA*04), nColFim )
//	oReport:Box ( li, nCol012, li+(nEspacoA*04), nCol013 )
//	oReport:Box ( li, nCol013, li+(nEspacoA*04), nColFim )
	
	oReport:Line( li, nColIni, li, nColFim ); li += nEspacoA
	oReport:Line( li, nColIni, li, nColFim ); li += nEspacoA
	oReport:Line( li, nColIni, li, nColFim ); li += nEspacoA
	oReport:Line( li, nColIni, li, nColFim ); li += nEspacoA

	li += nEspacoA
	
	oReport:Box ( li, nColIni, li+(nEspacoA), nColFim )
	
	oReport:Say ( li+020, nColIni+15, "Instalação de acordo? (    ) SIM  (    ) NÃO, POR QUE: "+Replicate("_",114), oFont07N)
	
	li += nEspacoA
	
	oReport:Box ( li, nColIni, li+(nEspacoA*1.5), nColFim )
	oReport:Box ( li, nCol003, li+(nEspacoA*1.5), nCol005 )
	oReport:Box ( li, nCol005, li+(nEspacoA*1.5), nCol010 )
	oReport:Box ( li, nCol010, li+(nEspacoA*1.5), nCol012 )
	
	oReport:Say ( li, nColIni+10, "Horário de Entrada:", oFont06)
	oReport:Say ( li, nCol003+10, "Horário de Saída:", oFont06)
	oReport:Say ( li, nCol005+10, "Assinatura do Cliente:", oFont06)
	oReport:Say ( li, nCol010+10, "Data:", oFont06)
	oReport:Say ( li, nCol012+10, "Técnico:", oFont06)
	
	li += nEspacoA
	li += nEspacoA
	li += nEspacoB
	
	oReport:Box ( li, nColIni, li+(nEspacoA), nColFim )
	
	oReport:Say ( li+020, nColIni+15, "Instalação de acordo? (    ) SIM  (    ) NÃO, POR QUE: "+Replicate("_",114), oFont07N)
	
	li += nEspacoA
	
	oReport:Box ( li, nColIni, li+(nEspacoA*1.5), nColFim )
	oReport:Box ( li, nCol003, li+(nEspacoA*1.5), nCol005 )
	oReport:Box ( li, nCol005, li+(nEspacoA*1.5), nCol010 )
	oReport:Box ( li, nCol010, li+(nEspacoA*1.5), nCol012 )
	
	oReport:Say ( li, nColIni+10, "Horário de Entrada:", oFont06)
	oReport:Say ( li, nCol003+10, "Horário de Saída:", oFont06)
	oReport:Say ( li, nCol005+10, "Assinatura do Cliente:", oFont06)
	oReport:Say ( li, nCol010+10, "Data:", oFont06)
	oReport:Say ( li, nCol012+10, "Técnico:", oFont06)
	
	li += (nEspacoA*2)
	li += nEspacoB
	
	oReport:Box ( li, nColIni, li+(nEspacoA*02), nColFim )
	oReport:Box ( li, nCol006, li+(nEspacoA*02), nCol011 )
	
	oReport:Say ( li+10, nColIni+10, "NOME", oFont06)
	oReport:Say ( li+10, nCol006+10, "ASSINATURA", oFont06)
	oReport:Say ( li+10, nCol011+10, "DATA", oFont06)
	
	li += (nEspacoA*2)
	
	cTextoL1 := "Autorizo a execução do serviço. Estou ciente das informações abaixo."
	
	oReport:Say ( li+10, nCol006+20, cTextoL1, oFont07N)
	
	cTextoL1 := "Prezado Cliente,"
	cTextoL2 := "Favor informar ao nosso funcionário os locais onde não corre-se perigo de perfuração da tubulação de água "+;
				"e/ou eletricidade, onde serão instalados os " 
	cTextoL3 := "equipamentos. Desta maneira eximimo-nos de qualquer dano eventualmente causado nestas tubulações. Aparelho parafusado não cai! No caso do cliente preferir "
   	cTextoL4 := "só a colagem, fica sob a sua responsabilidade danos que venham ocorrer aos mesmos. Caso o aparelho colado caia e quebre, eu, o cliente serei o responsável."
   	cTextoL5 := ""
	 
	li += nEspacoA
	
	oReport:Say ( li+10, nColIni+10, cTextoL1, oFont10N); li += nEspacoD
	oReport:Say ( li+10, nColIni+10, cTextoL2, oFont10N); li += nEspacoD
	oReport:Say ( li+10, nColIni+10, cTextoL3, oFont10N); li += nEspacoD
	oReport:Say ( li+10, nColIni+10, cTextoL4, oFont10N); li += nEspacoD	
	
	
	// Imprime picote da folha
			
	li := nLinRod
	
	li += nEspacoA
	li += nEspacoA
	
	oReport:Say ( li+10, nColIni+10, Replicate("_ ",150), oFont06)
	
	li += nEspacoA
	
	oReport:Say ( li+10, nColIni+10, cTextoL1, oFont10N); li += nEspacoD
	oReport:Say ( li+10, nColIni+10, cTextoL2, oFont10N); li += nEspacoD
	oReport:Say ( li+10, nColIni+10, cTextoL3, oFont10N); li += nEspacoD
	oReport:Say ( li+10, nColIni+10, cTextoL4, oFont10N); li += nEspacoD
	
	li += 20
	
	// Vetor com coordenadas no formato: linha inicial, coluna inicial, linha final,coluna final
	oReport:FillRect( { li, nColIni, li+120, 2000 }, oBrush )
	
	oReport:SayBitmap( li,nCol012+100, cLogo2,  /*COMP*/ 500, /*ALT*/ 125 )
	
	li += 040
	
	// hor -> 0 esquerda 1 direita 2 centralizado ## ver -> 0 centralizado 1 - superior 2 - inferior
	
	oReport:Say ( li, nCol002, "RECIBO ORDEM DE SERVIÇO - N°  "+cCodOs+"/"+cAnoEmis, oFont11N,,nCorBrco); li += 100    
	
	oReport:Say ( li, nColIni, "Data da O.S.: "+cDataEm, oFont09N)
	oReport:Say ( li, nCol006, "Técnico: "+cTecnico, oFont09N); li += nEspacoB   
	
	oReport:Say ( li, nColIni, "Linha: "+cLinha, oFont09N)
	oReport:Say ( li, nCol006, "Serviço: "+cServico, oFont09N)
	oReport:Say ( li, nCol010, "Região: "+cRegiao, oFont09N); li += nEspacoB        
	
	oReport:Say ( li, nColIni, "O.S. Solicitada por: "+cOsPor, oFont09N)
	oReport:Say ( li, nCol006, "Contato: "+cContato, oFont09N)
	oReport:Say ( li, nCol010, "Vendedor: "+cVend, oFont09N); li += nEspacoB     
	
	oReport:Say ( li, nColIni, "Código: "+cCodCli, oFont09N)
	oReport:Say ( li, nCol003, "Cliente: "+cNomCli, oFont09N)
	oReport:Say ( li, nCol009, "Nome Fantasia: "+cFanCli, oFont09N); li += nEspacoB                
	
	oReport:Say ( li, nColIni, "Endereço: "+cEndere, oFont09N) 
	oReport:Say ( li, nCol009, "Bairro: "+cBairro, oFont09N); li += nEspacoB      
	
	oReport:Say ( li, nColIni, "Cidade: "+cCidade, oFont09N) 
	oReport:Say ( li, nCol005, "Estado: "+cEstado, oFont09N)
	oReport:Say ( li, nCol009, "CEP: "+cCep, oFont09N); li += nEspacoB     
	
	oReport:Say ( li, nColIni, "Endereço de Entrega: "+cEndEnt, oFont09N)
	
	li += nEspacoB + 15 
	
	oReport:Say ( li, nColIni, "Motivo da O.S.: ", oFont10N)
	oReport:Say ( li, nCol002 + 70, cMotivo1, oFont10N); li += nEspacoB 
	oReport:Say ( li, nCol002 + 70, cMotivo2, oFont10N); li += nEspacoB 
	oReport:Say ( li, nCol002 + 70, cMotivo3, oFont10N) 
	
	li += (nEspacoB)
	       
	oReport:Box ( li, nColIni, li+(nEspacoA), nCol003 )
	oReport:Box ( li, nCol003, li+(nEspacoA), nColFim )
	
	oReport:Say ( li+15, nColIni+10, "Observações do Técnico:", oFont06N)
	
	li += 080
	
	oReport:Say ( li+10, nCol008, Replicate("_",60), oFont07N)
	
	li += nEspacoB
	
	oReport:Say ( li+10, nCol010, "Assinatura do Técnico", oFont07N)
	
	li += 040
	
	cTextoL1 := "Distribuidor Exclusivo Kimberly Clark, Ecolab, Netter, Dixie, TTS, 3M - Rua Mercedes Seiler Rocha, 423 - "+;
				"Bacacheri - Curitiba/PR (41) 3360 8500 / 0800 644 0350 - www.sentax.com.br"
	
	oReport:Say ( li, nCol003, cTextoL1, oFont06)
	
EndIf

oReport:EndPage()

RestArea(aArea)

Return
   

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fBuscaChm()
Busca o chamado para buscar dados do contato

@author		Alessandro Smaha
@since		20/06/2014
/*/
//-------------------------------------------------------------------------------
Static Function fBuscaChm(cNumOs)
        
Local cQry		:= ""              
Local cCodChm 	:= "" 

cQry := " SELECT AB2_FILIAL, AB2_NRCHAM "
cQry += " FROM " + RetSqlName('AB2') + " AB2 "
cQry += " WHERE AB2_FILIAL = '" + xFilial('AB2') + "' "
cQry += " 	AND SUBSTRING(AB2_NUMOS,1,6) = '" + cNumOs + "' "
cQry += " 	AND D_E_L_E_T_ <> '*' "

If Select("QCHM") <> 0
	QCHM->(DbCloseArea())
EndIf      

TcQuery cQry new Alias "QCHM"  

DbSelectArea("QCHM") 
QCHM->(DbGoTop()) 

If ! QCHM->(Eof())  
	cCodChm := QCHM->AB2_NRCHAM
EndIf

Return cCodChm 



//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC001P
Chama a impressão do relatório para a OS posicionada no browse
                
@sample		U_RTEC001P()

@author		Alessandro Smaha
@since		12/02/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function RTEC001P() 

U_RTEC001(AB6->AB6_NUMOS) 

Return
            

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do programa

@author		Alessandro Smaha
@since		15/05/2014
/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1()

Local aHelpPerg  := {}

aAdd(aHelpPerg,{"Código da Ordem de Serviço."})

PutSX1(cPerg,"01","Ordem de Serviço?","" ,"" ,"MV_CH1" ,"C",6,0,0,"G","","AB6","","S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})

Return    
