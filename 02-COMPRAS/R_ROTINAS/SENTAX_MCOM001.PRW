#INCLUDE 'PROTHEUS.CH'
   
//-------------------------------------------------------------------
/*/{Protheus.doc} MCOM001
Permite ao usuário alterar o valor da chave da NF-e quando ela não
estiver preenchida.
	
@author Leandro Natan Bonette Santos
@since 31/03/2014

@return nil, nulo

/*/
//-------------------------------------------------------------------
User Function MCOM001()

	Local cChavNFE := ""
	Local lPerg    := .F.

	If !Empty(SF1->F1_CHVNFE)		
		
		ShowHelpDlg("CHAVNFE",{"Não é possível alterar o valor da chave"},1,;
							  {"Selecione um documento sem uma chave NFe"})			     			
		Return			  
				
	EndIf
	
	lPerg := Pergunte("MCOM001",.T.,"Informe a chave da NF-e",.T.,,.F.)         
	     
	If lPerg

		If Empty(MV_PAR01)
			ShowHelpDlg("CHAVNFE",{"O valor da chave não pode ser vazio"},1,{""})			     
			Return
		EndIf
		
		If LEN(AllTrim(MV_PAR01)) <> 44
			ShowHelpDlg("CHAVNFE",{"A chave da NFe deve possuir 44 caracteres"},1,{""})			     
			Return		
		EndIf
		
		If U_MCOM001B(MV_PAR01)
			If RecLock("SF1",.F.)
	
				SF1->F1_CHVNFE := MV_PAR01       
				MsUnlock()
	
				MsgInfo("Chave alterada com sucesso. Para que a alteração seja visualizada" + CRLF + ;              
						"na aba Informações DANFE, feche o documento e visualize novamente", "Alteração Chave NF-e")					
			Else
				Alert("Falha ao atualizar a chave da NF-e")
			EndIf			                               
			
		EndIf	                    

	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MCOM001B
Valida se na chave da NFe foi informada apenas números. Esta função
é utilizada pois o tamanho para a picture da SX1 possui apenas
40 caracteres
	
@author Leandro Natan Bonette Santos
@since 31/03/2014

@return lRet, .T. se a chave possui números, .F. caso contrário.

/*/
//-------------------------------------------------------------------
User Function MCOM001B(cValor)

	Local cChave := IIF(cValor == nil, &(ReadVar()), cValor)
	Local cChar  := ""
	Local nI     := 0
		
	For nI := 1 To Len(cChave)  
		cChar := SubStr(cChave,nI,1)
    	If IsAlpha( cChar )
			Help(" ", 1, "ONLYNUM")
			Return .F.
    	EndIf		
	Next nI

Return .T.