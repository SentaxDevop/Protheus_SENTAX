#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} RFAT002
Imprime lembrete caso exista end. de entrega diferente do fiscal 
                
@sample		U_RFAT002( cFilSF2, cDocSF2, cSerSF2 )

@author		Alessandro Smaha
@since		03/03/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function RFAT002( oDanfe,cFilSF2, cDocSF2, cSerSF2 )

Local cDdd		:= ""
Local cCel		:= ""
Local cTel		:= ""
Local aAreaSA1 	:= SA1->(GetArea()) 
Local aAreaSUA 	:= SUA->(GetArea()) 
Local cFileN 	:= Alltrim(cDocSF2)+"-"+Alltrim(cSerSF2)+"_"+DtoS(dDataBase)
Local cDirTmp	:= "C:\Temp\Lembretes_nf\"  
Local cAppPdf 	:= Alltrim(GetMV("ST_XPRGIMP",,"")) // C:\Foxit\Reader.exe
Local cImpArq	:= Alltrim(GetMV("ST_XNOMIMP",,"")) // Work - HP Deskjet 4620
Local cArqPdf	:= ""         
Local lAbrPdf	:= !cFilAnt $ Alltrim(GetMV("ST_XFIMPPT",,"")) 

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA

DbSelectArea("SUA")
SUA->(DbSetOrder(2)) // UA_FILIAL+UA_SERIE+UA_DOC

If SUA->(DbSeek(cFilSF2 + cSerSF2 + cDocSF2)) 

	If SA1->(DbSeek(xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA))    
	
		If SUA->UA_XENDDIF == "2" .AND. SUA->UA_XENTPRO == "2" // 1=Não,2=Sim
		
			RFAT002A(oDanfe)
		/*
			fPrtLembr(cDirTmp,cFileN)   
			     
			cArqPdf	:= cDirTmp+cFileN+".pdf"

			If File(cArqPdf) .AND. !Empty(cAppPdf) .AND. !Empty(cAppPdf)
				
				If lAbrPdf
				     
				    // Realiza a abertura do arquivo pdf                     
					MsDocView( cFileN+".pdf", {}, 'Open', cDirTmp )  
			
				Else
					
					// Realiza a impressão via FoxIt na impressora informada
					If WinExec(cAppPdf+" /t "+cArqPdf+" "+cImpArq,1) <> 0
						
						MsgAlert("Erro ao imprimir lembrete de endereço diferente! Impressora ("+cImpArq+") ou aplicativo ("+cAppPdf+") de impressão não encontrado!","Atenção")    
					Else	 

					    MsDocView( cFileN+".pdf", {}, 'Open', cDirTmp )  
					    
					EndIf
	                
				EndIf
				

			Else
				
				MsgAlert("Arquivo de lembrete não foi gerado para impressão!","Atenção")     
				    
			EndIf 
		*/


		EndIf 
	EndIf
EndIf    
                  
RestArea(aAreaSA1)
RestArea(aAreaSUA)

Return                      


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fPrtRel
Impressão do relatório de Ordem de Serviço

@author		Alessandro Smaha
@since		13/06/2014

/*/
//-------------------------------------------------------------------------------
Static Function fPrtLembr(cDirTmp,cFileN)

	Local li		:= 0
	Local nColIni	:= 050    
	Local nColFim	:= 400  
	Local nCol001	:= 060
	Local nEspaco	:= 20
	Local oFont18N 	:= TFont():New("Arial", 18,18,,.T.,,,,.T.,.F.)	//Arial   18 com negrigo
	Local cDdd 		:= ""
	Local cTel 		:= ""
	Local cCel		:= ""  
	Local oPrinter 

	MontaDir(cDirTmp)

	If !File(cDirTmp+cFileN+".pdf")
		
		oPrinter := FWMSPrinter():New(cFileN,6,.F.,,.T.,,,,,.F.)
		
		//oPrinter:Setup() monta tela para salvar pdf
		
		oPrinter:cPathPDF := cDirTmp // caminho onde vai ser salvo o pdf
		
		oPrinter:LVIEWPDF := .F.
		
		li := 50
		
		oPrinter:Box ( li, nColIni, li+050, nColFim ) ; li += nEspaco
		
		oPrinter:Say ( li, nCol001, "CÓDIGO CLIENTE:"+SA1->A1_COD+"   LOJA:"+SA1->A1_LOJA, oFont18N); li += nEspaco
		oPrinter:Say ( li, nCol001, Alltrim(SA1->A1_NOME), oFont18N)
		
		li += 10
		
		oPrinter:Box ( li, nColIni, li+155, nColFim ) ; li += nEspaco
		
		oPrinter:Say ( li, nCol001, Alltrim(SUA->UA_ENDENT), oFont18N); li += nEspaco
		oPrinter:Say ( li, nCol001, "BAIRRO: "+Alltrim(SUA->UA_BAIRROE), oFont18N); li += nEspaco
		oPrinter:Say ( li, nCol001, "CIDADE: "+Alltrim(SUA->UA_MUNE), oFont18N); li += nEspaco
		oPrinter:Say ( li, nCol001, "CEP: "+Alltrim(SUA->UA_CEPE), oFont18N); li += nEspaco*2
		oPrinter:Say ( li, nCol001, "TELEFONES PARA CONTATO:", oFont18N); li += nEspaco
		
		cDdd := "("+StrZero(Val(Alltrim(SA1->A1_DDD)),2)+")"
		cTel := Alltrim(SA1->A1_TEL)
		cTel := StrTran(cTel,"-","")
		cTel := StrTran(cTel," ","")
		
		cCel := Alltrim(SA1->A1_CEL)
		cCel := StrTran(cCel,"-","")
		cCel := StrTran(cCel," ","")
		
		If Len(cTel) > 4
			cTel := cDdd + " " + Substr(cTel,1,Len(cTel)-4) + "-" + Substr(cTel,Len(cTel)-3,4)
		Else
			cTel := cDdd + " " + cTel
		EndIf
		
		If !Empty(cCel)
			If Len(cCel) > 4
				cTel += " / " + Substr(cCel,1,Len(cCel)-4) + "-" + Substr(cCel,Len(cCel)-3,4)
			Else
				cTel += " / " + cCel
			EndIf
		EndIf
		
		oPrinter:Say ( li, nCol001, cTel, oFont18N)
		
		oPrinter:EndPage() // fim do arquivo
		
		oPrinter:Preview() // depois de salvar abre o arquivo na tela

	EndIf
	
Return


Static Function RFAT002A(oDanfe)

	Local li		:= 0
	Local nColIni	:= 050    
	Local nColFim	:= 400  
	Local nCol001	:= 060
	Local nEspaco	:= 20
	Local oFont18N 	:= TFont():New("Arial", 18,18,,.T.,,,,.T.,.F.)	//Arial   18 com negrigo
	Local cDdd 		:= ""
	Local cTel 		:= ""
	Local cCel		:= ""  

	li := 50

	oDanfe:StartPage() // Inicia uma nova página
	
	oDanfe:Box ( li, nColIni, li+050, nColFim ) ; li += nEspaco
	
	oDanfe:Say ( li, nCol001, "CÓDIGO CLIENTE:"+SA1->A1_COD+"   LOJA:"+SA1->A1_LOJA, oFont18N); li += nEspaco
	oDanfe:Say ( li, nCol001, Alltrim(SA1->A1_NOME), oFont18N)
	
	li += 10
	
	oDanfe:Box ( li, nColIni, li+155, nColFim ) ; li += nEspaco
	
	oDanfe:Say ( li, nCol001, Alltrim(SUA->UA_ENDENT), oFont18N); li += nEspaco
	oDanfe:Say ( li, nCol001, "BAIRRO: "+Alltrim(SUA->UA_BAIRROE), oFont18N); li += nEspaco
	oDanfe:Say ( li, nCol001, "CIDADE: "+Alltrim(SUA->UA_MUNE), oFont18N); li += nEspaco
	oDanfe:Say ( li, nCol001, "CEP: "+Alltrim(SUA->UA_CEPE), oFont18N); li += nEspaco*2
	oDanfe:Say ( li, nCol001, "TELEFONES PARA CONTATO:", oFont18N); li += nEspaco
	
	cDdd := "("+StrZero(Val(Alltrim(SA1->A1_DDD)),2)+")"
	cTel := Alltrim(SA1->A1_TEL)
	cTel := StrTran(cTel,"-","")
	cTel := StrTran(cTel," ","")
	
	cCel := Alltrim(SA1->A1_CEL)
	cCel := StrTran(cCel,"-","")
	cCel := StrTran(cCel," ","")
	
	If Len(cTel) > 4
		cTel := cDdd + " " + Substr(cTel,1,Len(cTel)-4) + "-" + Substr(cTel,Len(cTel)-3,4)
	Else
		cTel := cDdd + " " + cTel
	EndIf
	
	If !Empty(cCel)
		If Len(cCel) > 4
			cTel += " / " + Substr(cCel,1,Len(cCel)-4) + "-" + Substr(cCel,Len(cCel)-3,4)
		Else
			cTel += " / " + cCel
		EndIf
	EndIf
	
	oDanfe:Say ( li, nCol001, cTel, oFont18N)
	
	oDanfe:EndPage() // fim do arquivo
	
	//oDanfe:Preview() // depois de salvar abre o arquivo na tela

	
Return
