//-------------------------------------------------------------------
/*/{Protheus.doc} MA180TOK
Ponto de Entrada que customiza a validação da rotina de Dados 
Complementares do Produto. Está localizado na função de validação da 
rotina de Dados Complementares do Produto.
                
@sample		U_MA180TOK()

@author		Alessandro Smaha
@since		24/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function MA180TOK()  

Local lRetOk := .T.   

// Valida campos para produto de risco
lRetOk := fVldPrdRi()                            

Return lRetOk


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldPrdRi
Valida campos para produto de risco
                
@sample		fVldPrdRi()

@author		Alessandro Smaha
@since		24/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fVldPrdRi()
       
Local cNumOnu	:= ""   
Local cDiretor	:= Alltrim(GetMV("ST_XDIRONU",,""))
Local aArquivo	:= {}    
Local nI		:= 0  
Local lEncOk	:= .F.  
Local lRetOk	:= .T.
 
If INCLUI .OR. ALTERA
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+M->B5_COD))
	
	If SB1->B1_XRISCO == "S" // S=Sim;N=Não
	
		cNumOnu := Alltrim(Upper(M->B5_XNONU))
		
		MontaDir(cDiretor)
			
		If !Empty(cNumOnu) .AND. !Empty(cDiretor)
		
			cNumOnu  += IIF(Substr(cNumOnu,Len(cNumOnu)-3,4)==".PDF","",".PDF")   
			cDiretor += IIF(Substr(cDiretor,Len(cDiretor),1)=="\","","\")
		
			aArquivo := DIRECTORY(cDiretor + "*.PDF","D")
		   
			For nI := 1 to Len(aArquivo)
			 
				If cNumOnu == Alltrim(Upper(aArquivo[nI][1]))
				
					lEncOk := .T. 
					Exit
					
				EndIf
			
			Next nI
					
		EndIf  
		
		If Empty(M->B5_XNONU ) 
			MsgAlert("Campo Número ONU no complemento do produto é obrigatório para produto de risco","Atenção")
			lRetOk := .F.	
		ElseIf Empty(M->B5_XCLASRI ) 
			MsgAlert("Campo Classe Risco no complemento do produto é obrigatório para produto de risco","Atenção")
			lRetOk := .F.	
		ElseIf Empty(M->B5_XSUBCLA )
			MsgAlert("Campo SubClasse Risco no complemento do produto é obrigatório para produto de risco","Atenção")
			lRetOk := .F.	
		ElseIf Empty(M->B5_XGRPEMB )
			MsgAlert("Campo Grupo de Embalagem no complemento do produto é obrigatório para produto de risco","Atenção")
			lRetOk := .F.	
		ElseIf !lEncOk  
			MsgAlert("O arquivo ("+cNumOnu+") não foi localizado no diretório "+cDiretor+"!","Atenção")
		EndIf
		
	EndIf 
	
EndIf
	
Return lRetOk