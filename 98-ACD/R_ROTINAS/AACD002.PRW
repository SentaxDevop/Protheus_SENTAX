#include "protheus.ch"
#include "apvt100.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} AACD002()
Rotina para separação de materiais pelo telnet.

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function AACD002()

	Private cNota
	Private cSerie
	Private cCodOpe		:= CBRetOpe()
	Private lUsaCB0 	:= UsaCB0('01')
	Private nQtdeLt 	:= 0             
	Private cPesoFim 	:= Space(15) 
	Private cVoluFim 	:= Space(3) 
	Private cEspeFim 	:= Space(10)
	Private nPesoOk  	:= 0        
	Private nVolOk 	 	:= 0
	Private cQbrLin 	:= 	Chr(13) + Chr(10)
	Private lPesoArmz 	:= .F.   
	Private lSepOk    	:= .F.
	Private _nTempo   	:= 3000   
	Private _lImpACD  	:= IIF(Alltrim(SuperGetMv("ST_XIMPACD", .T., "N")) == "S",.T.,.F.) 
	Private _cUndMed  	:= Alltrim(SuperGetMv("ST_UNIDMED", .T., "")) 
	
	Conout("Rotina de Separacao [AACD002]")
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	
	If Empty(cCodOpe)
		VTAlert("Operador nao cadastrado","Aviso",.T.,_nTempo) //"Operador nao cadastrado"###"Aviso"
		Return .F.
	EndIf
	
	While .T.     
		lSepOk := .F.
		cNota  := Space(TamSx3("F2_DOC")[1])
		cSerie := Space(TamSx3("F2_SERIE")[1])
		VTClear()
		@ 0,00 VTSAY 'Separação'
		@ 2,00 VTSAY 'Nota :' VTGet cNota  Pict '@!' Valid fVldNota(cNota,1) F3 "CBK" 
		@ 3,00 VTSAY 'Serie:' VTGet cSerie Pict '@!' Valid fVldNota(cNota+cSerie,2) .or. VtLastkey() == 5
		VTRead
		If VtLastKey() == 27
			Exit
		EndIf
		fSeparacao()
	EndDo  
	
Return

 
//------------------------------------------------------------------- 
/*/{Protheus.doc} fVldNota()
Valida a nota fiscal de saida  

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fVldNota(cChave,nOpcao) 

	Local cRetStatus := ""
      
	If Empty(cChave)
		VTKeyBoard(chr(23))
		Return .F.
	EndIf
	
	If nOpcao == 1
		
		SF2->(dbSetOrder(1))
		If ! SF2->(dbSeek(xFilial()+cChave))
			VTAlert("Nota fiscal nao cadastrada","Aviso",.T.,_nTempo,2)
			VTKeyBoard(chr(20))
			Return .F.
		EndIf  
		
	Else
		
		SF2->(dbSetOrder(1))
		If ! SF2->(dbSeek(xFilial()+cChave))
			VTAlert("Nota fiscal nao cadastrada","Aviso",.T.,_nTempo,2) 
			VTKeyBoard(chr(20))
			Return .F.
		EndIf
		
		If Empty(SF2->F2_TRANSP)
		 
			VTAlert("Transportadora não informada para a Nota "+SF2->F2_DOC+"-"+SF2->F2_SERIE,"Aviso",.T.,_nTempo,2) 
			VTKeyBoard(chr(20))
			Return .F.

		EndIf
		
		If Len(cChave) < 9
			Return .t.
		Endif 
		
		CBK->(DbSetOrder(1))
		If CBK->(DbSeek(xFilial('CBK')+cChave)) .and. CBK->CBK_STATUS == "3"
			If VTYesNo('Itens separados. Deseja estonar os itens?','Atencao',.T.) 				 
				fEstornaNf(cChave) 
			EndIf
			VtClearGet("cNota")  // Limpa o get
			VtClearGet("cSerie")  // Limpa o get
			VTGetSetFocus("cNota") 
			Return .F.
		Endif  
		
		If CBK->(!Eof()) 
		
			Do Case
				
				Case CBK->CBK_STATUS == "1" // Conferência Não Iniciada
					cRetStatus := ""	
				Case CBK->CBK_STATUS == "2"	// Separação Iniciada
					cRetStatus := ""
				Case CBK->CBK_STATUS == "3"	// Separação Finalizada
					cRetStatus := ""
				Case CBK->CBK_STATUS == "4"	// Expedição Iniciada
				  	cRetStatus := "Expedição Iniciada. Não permitida separação de itens!"
				Case CBK->CBK_STATUS == "5"	// Expedição Finalizada
					cRetStatus := "Expedição Finalizada. Não permitida separação de itens!"	
				Case CBK->CBK_STATUS == "6"	// Nota Fiscal Cancelada
					cRetStatus := "Romaneio Finalizado. Não permitida separação de itens!" 
				Case CBK->CBK_STATUS == "7"	// Nota Fiscal Cancelada
					cRetStatus := "Nota Fiscal Cancelada. Não permitida separação de itens!"
				OtherWise
					
			EndCase  
			
			If !Empty(cRetStatus)
				VTAlert(cRetStatus,"Aviso",.T.,_nTempo,2) //"Nota fiscal nao cadastrada"###"Aviso"
				VTKeyBoard(chr(20))
				Return .F.
			EndIf
		 
		EndIf		 
		
		If CBK->(Eof())
			RecLock("CBK",.T.)
			CBK->CBK_FILIAL := xFilial('CBK')
			CBK->CBK_DOC    := SF2->F2_DOC
			CBK->CBK_SERIE  := SF2->F2_SERIE
		Else
			RecLock("CBK",.F.)
		Endif   
		
		CBK->CBK_DTEMBQ := Ctod('  /  /  ')
		CBK->CBK_STATUS := "2" 
		
		CBK->(MsUnlock())
		
	EndIf
	
Return .T. 


//------------------------------------------------------------------- 
/*/{Protheus.doc} fSeparacao()
Faz o embarque dos itens da nota fiscal  

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fSeparacao()
	
	Local   bkey06
	Local   bKey09
	Local   bkey24
	Local   cEtiqProd   
	Local 	lEstorna  := .F.
	Private lFimEmb   := .f. 
	Private _nQtdOk   := 0
	
	bKey06 := VTSetKey(06,{|| fFaltas() },"Faltantes")   // CTRL+F //"Faltantes"
	bkey09 := VTSetKey(09,{|| fInforma()},"Informacoes") // CTRL+I //"Informacoes"
	bKey24 := VTSetKey(24,{|| fEstorna()},"Estorno")     // CTRL+X //"Estorno"
	
	nQtdeLt := Space(TamSx3("D2_QUANT")[1])
	
	While .t.
		If lUsaCB0
			cEtiqProd := Space(TamSx3("CB0_CODET2")[1])
		Else
			cEtiqProd := Space(48)
		Endif
		@ 4,00 VTSAY 'Leia o item' //'Leia a etiqueta'
		@ 5,00 VTGET cEtiqProd pict '@!' Valid fVldEtiq(cEtiqProd)
		VTRead
		If lFimEmb
			Exit
		EndIf
		If VTLastkey() == 27 		
	   		If ! VTYesNo('Confirma a saida?','Atencao',.T.) 
				Loop
			EndIf  
			If !lSepOk
				If ! VTYesNo('Separação da nota não finalizada!'+chr(13)+chr(10)+chr(13)+chr(10)+'Estornar itens?','Atencao',.T.) 
					Loop 
				Else
					fEstornaNf( CBK->CBK_DOC+CBK->CBK_SERIE ) 
					lEstorna := .T.
				EndIf
			EndIf			
			fAtuCBK(.T.,lEstorna)
			Exit		
		EndIf
	EndDo
	vtsetkey(06,bkey06)
	vtsetkey(09,bkey09)
	vtsetkey(24,bkey24)
	
Return  


//------------------------------------------------------------------- 
/*/{Protheus.doc} fEstornaNf()
Estorna os itens lidos da NF.

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fEstornaNf(cChave)

	fAtuCBK(.F.,.T.) 
	
	CBL->(dbSetOrder(1))
	If CBL->(DbSeek(xFilial('CBL')+cChave)) 
	
		While CBL->(!Eof()) .AND. xFilial('CBL') == CBL->CBL_FILIAL .AND. SF2->(F2_DOC+F2_SERIE) == cChave 
		
			RecLock('CBL',.F.)
				CBL->CBL_QTDEMB := 0
			CBL->(MsUnlock()) 
			 
			CBL->(DbSkip()) 
		EndDo
		
	EndIf  
	
	VTAlert("Itens estornados para a Nota "+Alltrim(SF2->F2_DOC)+"."+chr(13)+chr(10)+chr(13)+chr(10)+"Realizar nova conferência!","Aviso",.T.,_nTempo,2)
	  
Return


//------------------------------------------------------------------- 
/*/{Protheus.doc} fVldEtiq()
Valida a etiqueta de produto

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fVldEtiq(cEtiqProd,lEstorna)
	
	Local   cTipo
	Local   cProduto
	Local   nQE	      	:= 1            
	Local 	cEtiqPos  	:= ""
	Local 	aEtiqueta 	:= {} 
	Local   aProd 		:= {}  
	Local   lDecimal	:= .F. 
	Default lEstorna	:= .F.
	
	If Empty(cEtiqProd)
		Return .F.
	EndIf
		    
	SB1->(DbSetOrder(5)) // B1_FILIAL+B1_CODBAR	
	If SB1->(DbSeek(xFilial("SB1")+cEtiqProd))  
		cProduto := SB1->B1_COD
	Else
	 	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
		If SB1->(DbSeek(xFilial("SB1")+cEtiqProd))    
			cProduto := SB1->B1_COD
		EndIf
	EndIf 
	
	If !fVProduto(cProduto,IIf(lUsaCB0,CB0->CB0_CODETI,Space(10)),nQE,lEstorna,lDecimal)
		Return .F.
	EndIf
	
	VtClearBuffer()
	VTKeyBoard(chr(20))
	
Return .t.


//------------------------------------------------------------------- 
/*/{Protheus.doc} fVProduto()
Valida o produto lido 

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fVProduto(cProduto,cEtiqProd,nQE,lEstorna,lDecimal) 
	
	Local  aRetAnalise := {}
	Local  nQtdeNota   := 0
	Local  nQtdeEmb    := 0
	Local  nQtdeNec    := 0
	
	If !fNaNota(cProduto)
		VTAlert("O produto "+Alltrim(cProduto)+" nao consta na nota!","Aviso",.T.,_nTempo,2) //"O produto "###" nao consta na nota!"###"Aviso"
		VtClearBuffer()
		VTkeyBoard(chr(20))
		Return .f.
	EndIf
	
	If !lEstorna
		aRetAnalise := fAnalisaEmb(cProduto,.f.)
		nQtdeNota 	:= aRetAnalise[1]
		nQtdeEmb  	:= aRetAnalise[2]
		nQtdeNec  	:= nQtdeNota - nQtdeEmb
		
		If nQtdeNec <= 0
			VTAlert("Nao existe saldo a coletar deste produto!","Aviso",.T.,_nTempo,2) //"Nao existe saldo a coletar deste produto!"###"Aviso"
			VtClearBuffer()
			VTkeyBoard(chr(20))
			Return .f.
		EndIf
		
		If nQtdeNec < nQE
			VTAlert("Quantidade maior que necessaria!","Aviso",.T.,_nTempo,2) //"Quantidade maior que necessaria!"###"Aviso"
			VtClearBuffer()
			VTkeyBoard(chr(20))
			Return .f.
		EndIf 
		
	Endif 
	
	fGravaCBL(lEstorna,cProduto,cEtiqProd,nQE)
	
Return .t.


//------------------------------------------------------------------- 
/*/{Protheus.doc} fNaNota()
Retorna se o produto existe para aquela nota 

@param cProduto  -> Código do produto
@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fNaNota(cProduto)  
	
	SD2->(DbSetOrder(3))
	SD2->(DbSeek(SF2->(xFilial('SF2')+F2_DOC+F2_SERIE)))
	While SD2->(!Eof() .AND. D2_FILIAL+D2_DOC+D2_SERIE == xFilial('SF2')+SF2->(F2_DOC+F2_SERIE))
		If SD2->D2_COD == cProduto
			Return .t.
			Exit
		EndIf
		SD2->(DbSkip())
	EndDo 
	
Return .f.


//------------------------------------------------------------------- 
/*/{Protheus.doc} fGravaCBL()
Grava as etiquetas lidas	
       
@param lEstorna  -> Variavel logica de estorno
@param cProduto  -> Codigo do Produto lido 
@param cEtiqProd -> Codigo da Etiqueta de Produto
@param nQE       -> Quantidade lida  
@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fGravaCBL(lEstorna,cProduto,cEtiqProd,nQE)
	
	CBL->(dbSetOrder(1))
	If CBL->(DbSeek(xFilial('CBL')+SF2->(F2_DOC+F2_SERIE)+cEtiqProd+cProduto))
		If lEstorna
			IF ! VtYesNo("Confirma o estorno?","Aviso",.t.)  //"Confirma o estorno?"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .F.
			EndIf
			RecLock('CBL',.F.)
			If CBL->CBL_QTDEMB - nQE <= 0
				CBL->(DbDelete())
			Else
				CBL->CBL_QTDEMB -= nQE
			Endif
			CBL->(MsUnlock())
		Else
			RecLock('CBL',.F.)
			CBL->CBL_QTDEMB += nQE
			CBL->(MsUnlock()) 
			_nQtdOk++
		Endif
	Else
		If lEstorna
			If lUsaCB0
				VtAlert("Etiqueta nao lida!","Aviso",.t.,_nTempo,3) //"Etiqueta nao lida!"###"Aviso"
			Else
				VtAlert("Produto nao lido!","Aviso",.t.,_nTempo,3) //"Produto nao lido!"###"Aviso"
			Endif
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		Else
			RecLock('CBL',.T.)
			CBL->CBL_FILIAL := xFilial('CBL')
			CBL->CBL_DOC    := SF2->F2_DOC
			CBL->CBL_SERIE  := SF2->F2_SERIE
			CBL->CBL_CODETI := If(lUsaCB0,cEtiqProd,"")
			CBL->CBL_PROD   := cProduto
			CBL->CBL_QTDEMB := nQE
			CBL->(MsUnlock())
		Endif
	Endif
	If !lEstorna
		fAtuCBK(.F.,.F.)
	Endif
	
Return


//------------------------------------------------------------------- 
/*/{Protheus.doc} fEstorna()
Estorno das etiquetas lidas 

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fEstorna() 
	
	Local aTela
	Local cEtiqueta
	
	If Empty(cNota)
		Return
	Endif
	
	aTela := VTSave()
	VTClear()
	If lUsaCB0
		cEtiqueta := Space(TamSx3("CB0_CODET2")[1])
	Else
		cEtiqueta := Space(48)
	Endif
	@ 00,00 VtSay Padc("Estorno da Leitura",VTMaxCol()) //"Estorno da Leitura"
	@ 02,00 VtSay "Etiqueta:" //"Etiqueta:"
	@ 03,00 VtGet cEtiqueta pict "@!" Valid fVldEtiq(cEtiqueta,.t.)
	VtRead
	vtRestore(,,,,aTela)
	
Return


//------------------------------------------------------------------- 
/*/{Protheus.doc} fFaltas()
Mostra produtos que faltam ser lidos  

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fFaltas()
	
	Local aSize,aSave 	:= VTSAVE()
	Local aItensNota	:= {}
	Local aItensEmb		:= {}
	Local aCab			:= {}
	Local aItensFalta 	:= {}
	Local nI, nX
	
	If Empty(cNota)
		Return
	Endif
	
	aItensAux  := fAnalisaEmb(NIL,.t.)
	aItensNota := aItensAux[1]
	aItensEmb  := aItensAux[2]
	
	For nI:=1 to Len(aItensNota)
		nX := Ascan(aItensEmb,{|x| x[01]==aItensNota[nI,1]})
		If nX > 0
			aadd(aItensFalta,{aItensNota[nI,01],Transform(aItensNota[nI,02]-aItensEmb[nX,02],"@E 999,999.99")})
		Else
			aadd(aItensFalta,{aItensNota[nI,01],Transform(aItensNota[nI,02],"@E 999,999.99")})
		Endif
	Next
	
	VTClear()
	aCab  := {"Produto","Qtde"} //"Produto"###"Qtde"
	aSize := {15,12}
	VTaBrowse(0,0,7,19,aCab,aItensFalta,aSize)
	VtRestore(,,,,aSave) 
	
Return


//------------------------------------------------------------------- 
/*/{Protheus.doc} fInforma()
Mostra produtos que ja foram lidos 

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fInforma()  
	
	Local aCab,aSize,aSave := VTSAVE()
	Local aHist:={}
	
	If Empty(cNota)
		Return
	Endif
	
	CBL->(dbSetOrder(1))
	CBL->(DbSeek(xFilial('CBL')+SF2->(F2_DOC+F2_SERIE)))
	While CBL->(!Eof() .and. CBL_FILIAL+CBL_DOC+CBL_SERIE == xFilial('SF2')+SF2->(F2_DOC+F2_SERIE))
		AADD(aHist,{CBL->CBL_CODETI,CBL->CBL_PROD,Transform(CBL->CBL_QTDEMB,"@E 999,999.99")})
		CBL->(DbSkip())
	EndDo
	
	VTClear()
	@ 0,0 VTSay "Operador : "+cCodOpe //"Operador : "
	aCab  := {"Etiqueta","Produto","Qtde"} //"Etiqueta"###"Produto"###"Qtde"
	aSize := {10,15,12}
	VTaBrowse(1,0,7,19,aCab,aHist,aSize)
	VtRestore(,,,,aSave)
	
Return


//------------------------------------------------------------------- 
/*/{Protheus.doc} fAtuCBK()
Atualiza o status da tabela de Cabecalho de Embarque (CBK) 

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fAtuCBK(lFinal,lEstorna) 
	
	Local   aRetAnalise := {}
	Local   nQtdeNota   := 0
	Local   nQtdeEmb    := 0   
	Local 	cVolumeAt   := Space(15)
	Local 	lOk 		:= .F.
	Local   lOkVol      := .F.
	Local   cVolumeAt   := ""   
	Local   cTextoMsg   := ""
	
	If lEstorna  
		
		RecLock("CBK",.F.)
			CBK->CBK_DTEMBQ := CtoD("  /  /  ")
			CBK->CBK_STATUS := "1" // Conferência Não Iniciada
		CBK->(MsUnlock()) 
		
	Else
		
		aRetAnalise := fAnalisaEmb(NIL,.f.)
		nQtdeNota 	:= aRetAnalise[1]
		nQtdeEmb  	:= aRetAnalise[2]
		
		cVolumeAt := Padr(cValToChar(nQtdeEmb),15," ")   
		
		If nQtdeNota == nQtdeEmb 
		          
	   		lSepOk := .T.
			lFimEmb := .t. 
			
			While .t. 
			
				VTClear() 
				
				VTAlert("Separação da NF OK!","Aviso",.T.,1500)
				
				@ 0,00 VTSAY "Separação da NF OK!"
				
				If !Empty(SF2->F2_DAUTNFE) 
				
					@ 2,00 VTSAY "NF Transmitida!"
					@ 4,00 VTSAY "Volumes: "+cValToChar(SF2->F2_VOLUME1)
					@ 6,00 VTGet cVolumeAt pict '@!' Valid fVldVol(cVolumeAt,@lOkVol) .OR. VtLastkey() == 5   
					
				Else
					
					@ 2,00 VTSAY "Confirme o Volume:"
					@ 3,00 VTGet cVolumeAt pict '@!' Valid fVldVol(cVolumeAt,@lOkVol) .OR. VtLastkey() == 5   
					
				EndIf
					
				VTRead 
				
				If lOkVol
					Exit
				EndIf   
								
				If VTLastkey() == 27 		
			   		If ! VTYesNo('Confirma a saida?','Atencao',.T.) 
						Loop
					EndIf  
					If !lOkVol
						If ! VTYesNo('Volume não confirmado!'+chr(13)+chr(10)+chr(13)+chr(10)+'Estornar itens?','Atencao',.T.) 
							Loop 
						Else
							fEstornaNf( CBK->CBK_DOC+CBK->CBK_SERIE ) 
							lEstorna := .T.
						EndIf
					EndIf			
					fAtuCBK(.T.,lEstorna)
					Exit		
				EndIf
					
			EndDo 
			
			If lOkVol
			
				lSepOk := .T.		     
									
				RecLock("CBK",.F.)
					CBK->CBK_DTEMBQ := dDataBase
					CBK->CBK_STATUS := "3" // Separação Finalizada
				CBK->(MsUnlock()) 
				
				U_AFAT004( SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SF2->F2_VOLUME1, Val(cVolumeAt), "AACD002/fAtuCBK", dDataBase, Time(), UsrFullName(RetCodUsr()), "Separação Finalizada. Atualizando volume." ) 	
				
				RecLock("SF2",.F.)
					If Empty(SF2->F2_ESPECI1) 
				   		SF2->F2_ESPECI1	:= "CAIXA"	
				 	EndIf
				 	If SF2->F2_VOLUME1 <> Val(cVolumeAt) .AND. Empty(SF2->F2_DAUTNFE) 
						SF2->F2_VOLUME1	:= Val(cVolumeAt)    
					EndIf
				SF2->(MsUnlock())
				
				//If _lImpACD
				
					//If VTYesNo('Deseja imprimir a(s) etiqueta(s) de volume ?','Atencao',.T.)  
					    
					//	VTClear()
					//	U_ROMS001( .T., SF2->F2_SERIE, SF2->F2_DOC )
							
					//EndIf      
				
				//Else 
								
				//	VTClear()
				//	VTAlert("Imprimir etiquetas via sigaOMS! (Ver Parâmetro ST_XIMPACD)","Aviso",.T.,_nTempo)
					
				//EndIf 
				
				cTextoMsg := "Separação finalizada!"
				VTAlert(cTextoMsg,"Aviso",.T.,1500)   
								
				VTClear()
			
			EndIf  
			
		Endif 
		
	EndIf 
	
Return
 
 
//------------------------------------------------------------------- 
/*/{Protheus.doc} fAnalisaEmb()
Analisa a necessidade de embarque do produto lido 

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fAnalisaEmb(cProduto,lRetTodosPrd)
	
	Local   nPos
	Local   aRet     	:= {}
	Local   aRetNota 	:= {}
	Local   aRetEmb  	:= {}
	Local   nQtdeNota	:= 0
	Local   nQtdeEmb 	:= 0     
	
	Default cProduto 		:= ""
	Default lRetTodosPrd 	:= .f.  
	
	conout("analisando embarque")
	
	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial('SD2')+SF2->(F2_DOC+F2_SERIE)))
	While SD2->(!Eof() .AND. D2_FILIAL+D2_DOC+D2_SERIE == xFilial('SF2')+SF2->(F2_DOC+F2_SERIE))
		nQtdeIt := fBuscaQtde(SD2->D2_COD,SD2->D2_QUANT)
		nPos := Ascan(aRetNota,{|x| x[1] == SD2->D2_COD})
		If nPos == 0
			aadd(aRetNota,{SD2->D2_COD,nQtdeIt})
		Else
			aRetNota[nPos,2] += nQtdeIt
		Endif
		If SD2->D2_COD == cProduto .or. Empty(cProduto)
			nQtdeNota += nQtdeIt
		Endif
		SD2->(DbSkip())
	EndDo
	
	CBL->(dbSetOrder(1))
	CBL->(DbSeek(xFilial('CBL')+SF2->(F2_DOC+F2_SERIE)))
	While CBL->(!Eof() .and. CBL_FILIAL+CBL_DOC+CBL_SERIE == xFilial('SF2')+SF2->(F2_DOC+F2_SERIE))
		nPos := Ascan(aRetEmb,{|x| x[1] == CBL->CBL_PROD})
		If nPos == 0
			aadd(aRetEmb,{CBL->CBL_PROD,CBL->CBL_QTDEMB})
		Else
			aRetEmb[nPos,2] += CBL->CBL_QTDEMB
		Endif
		If CBL->CBL_PROD == cProduto .or. Empty(cProduto)
			nQtdeEmb += CBL->CBL_QTDEMB
		Endif
		CBL->(DbSkip())
	EndDo
	
	If lRetTodosPrd
		aRet := {aRetNota,aRetEmb}
	Else
		aRet := {nQtdeNota,nQtdeEmb}
	Endif
	
Return aClone(aRet)


//------------------------------------------------------------------- 
/*/{Protheus.doc} fBuscaQtde()
Verifica a quantidade. Se a unidade de medida estiver no parametro, considera uma unidade apenas.
Utilizado para os itens que são vendidos em quilos, metros...  

@sample fBuscaQtde(cCodPro,nQtde)

@author Alessandro Smaha 
@since 30/05/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fBuscaQtde(cCodPro,nQtde)
	
	If nQtde <> Int(nQtde) // Verifica se é decimal
		nQtde := 1
		conout("decimal")
	Else   
		conout("nao decimal")
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
		If SB1->(DbSeek(xFilial("SB1")+cCodPro))
			If "*"+Alltrim(SB1->B1_UM)+"*" $ _cUndMed
				nQtde := 1 
				conout("pertence ao param unidade de medida")
			EndIf			
		EndIf		
	EndIf
	
Return nQtde
                          
           
//------------------------------------------------------------------- 
/*/{Protheus.doc} fVldVol()
Valida o volume

@author Alessandro Smaha 
@since 10/01/2014
@version P11 
/*/ 
//------------------------------------------------------------------
Static Function fVldVol(cVolumeAt,lRetOk)

	Local cTextoAux := ""
	
	If !Empty(SF2->F2_DAUTNFE) 
	
		cTextoAux := "Nota transmitida! "
	    
		If Val(cVolumeAt) == SF2->F2_VOLUME1
			lRetOk := .T.
		Else	   		
	   		VTAlert("Nota "+SF2->F2_DOC+" já foi transmitida! O Volume deve ser o mesmo. Total de Volumes: "+cValToChar(SF2->F2_VOLUME1),"Aviso",.T.,_nTempo) //"Operador nao cadastrado"###"Aviso"
			lRetOk := .F.  
		EndIf
	
	Else 
	
		cTextoAux := "Nota não transmitida! " 
	
		If !Empty(cVolumeAt)  
		
			If Val(cVolumeAt) > 999
		   		VTAlert("Volume não pode ser maior do que 999! Verificar volume informado.","Aviso",.T.,_nTempo) 
				lRetOk := .F. 
			ElseIf VTYesNo('Confirma o Volume '+ALLTRIM(cVolumeAt)+ '?','Atencao',.T.)
			  	lRetOk := .T.
			EndIf  
		Else
			VTAlert("Volume deve ser Informado!","Aviso",.T.,_nTempo)
		EndIf 
		
	EndIf
	
	U_AFAT004( SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SF2->F2_VOLUME1, Val(cVolumeAt), "AACD002/fVldVol", dDataBase, Time(), UsrFullName(RetCodUsr()), "lRetOk="+cValToChar(lRetOk)+" "+cTextoAux ) 	
	
Return lRetOk 
