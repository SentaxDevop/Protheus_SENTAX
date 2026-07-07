#Include 'Protheus.ch'    
#Include "topconn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} ATECXX1
Exclui as bases instaladas para equipamentos e adiciona novos 
equipamentos na base instalada com o número de série igual 
ao código do produto.

@author  Alessandro Smaha
@since   06/02/2013
@return  NIL
/*/
//-------------------------------------------------------------------
User Function ATECXX1()
	
	Processa({|| fProcessa() },"Base Instalada")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Processa a limpeza na base instalada.

@author  Alessandro Smaha
@since   06/02/2013
@return  NIL
/*/
//-------------------------------------------------------------------
Static Function fProcessa()

	Local aErrosInc	:= {}
	Local aOkInc	:= {}
	Local aExcluido := {}  
	Local aBaseIns  := {}     
	Local aAdiciona := {} 
	Local aAutoErro	:= {}
	Local cQuery 	:= ""
	Local cGrpPrOk  := Alltrim(SuperGetMv("ST_XGRPPRO", .T., ""))
	Local nTotItens := 0 
	Local cHoraIni  := Time()
	
	Private lMsErroAuto := .F.
	
	ProcRegua(0)
		
	If (Select("BASE") <> 0)
		
		DbSelectArea("BASE")
		BASE->(DbCloseArea())
		
	Endif
	
	cQuery := " SELECT AA3_CODCLI,AA3_LOJA,AA3_CODPRO,B1_GRUPO,AA3.R_E_C_N_O_ RECNO_AA3 " 
	cQuery += " FROM   " + RetSQLName("AA3") + " AA3 "
	cQuery += "    INNER JOIN " + RetSQLName("SB1") + " SB1 ON B1_COD = AA3_CODPRO AND SB1.D_E_L_E_T_ <> '*' AND (B1_GRUPO < '0600' OR B1_GRUPO > '0699') "
	cQuery += " WHERE  AA3.D_E_L_E_T_ <> '*' " 
	cQuery += " ORDER BY AA3_CODCLI, AA3_LOJA, AA3_CODPRO " 
	
	TCQuery cQuery new Alias "BASE"
	
	BASE->(DbGoTop())
	
	If BASE->(!Eof())
			
		DbSelectArea("AA3")
		AA3->(DbSetOrder(1)) // AA3_FILIAL+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER
		
		While BASE->(!Eof())
		
			nTotItens++
			
			IncProc("Analisando e removendo Base Intalada (v1.1)... Aguarde ("+cValToChar(nTotItens)+")")
		
		    AA3->(DbGoTo(BASE->RECNO_AA3)) 
		    
		    If Alltrim(BASE->B1_GRUPO) $ cGrpPrOk
			    
				nPosBase := aScan( aBaseIns, { |x|	Alltrim(x[1]) == Alltrim(AA3->AA3_CODCLI) .AND. ;
													Alltrim(x[2]) == Alltrim(AA3->AA3_LOJA)   .AND. ;
													Alltrim(x[3]) == Alltrim(AA3->AA3_CODPRO) } )
			    
				If nPosBase == 0
			   		aAdd( aBaseIns, { 	Alltrim(AA3->AA3_CODCLI),;
			   							Alltrim(AA3->AA3_LOJA),;
			   							Alltrim(AA3->AA3_CODPRO),;
			   							AA3->AA3_DTVEND,;
			   							AA3->AA3_DTINST,;
			   							AA3->AA3_DTGAR } ) 
			   							
			   							aAdiciona 
			   							
			   		aAdd(aAdiciona,Alltrim(AA3->AA3_CODCLI)+"/"+Alltrim(AA3->AA3_LOJA)+"/"+Alltrim(AA3->AA3_CODPRO)+"/"+Alltrim(BASE->B1_GRUPO))
			 	
			 	EndIf 
			 
			 EndIf
			 	
		 	aAdd(aExcluido,Alltrim(AA3->AA3_CODCLI)+"/"+Alltrim(AA3->AA3_LOJA)+"/"+Alltrim(AA3->AA3_CODPRO)+"/"+Alltrim(BASE->B1_GRUPO))
		 	
			RecLock("AA3",.F.)  
				AA3->(DbDelete())
			AA3->(MsUnlock())
					     
			BASE->(DbSkip())
		EndDo
		
	EndIf
	
	BASE->(DbCloseArea())
	
	If !Empty(aBaseIns)

		Processa({|| fCriaBases(aBaseIns,@aOkInc,@aErrosInc) },"Base Instalada")
		
	EndIf
	
	cTexto := "LOG: "+DtoC(dDataBase)+" Inicio: "+cHoraIni+" Fim: "+Time()+CHR(13)+CHR(10)  
	
	cTexto += Replicate("-",60)+ CHR(13) + CHR(10) 
	
	cTexto += "Itens Base: "+cValToChar(nTotItens)	  	   	 			+CHR(13)+CHR(10)      
	cTexto += "Inclusão OK: "+cValToChar(Len(aOkInc))		  	   		+CHR(13)+CHR(10) 
	cTexto += "Inclusão ERRO: "+cValToChar(Len(aErrosInc))		  	 	+CHR(13)+CHR(10)
	cTexto += "Bases Excluidas: "+cValToChar(Len(aExcluido))			+CHR(13)+CHR(10)
	cTexto += "Bases Adicionadas: "+cValToChar(Len(aAdiciona))		 	+CHR(13)+CHR(10)  
      
	//Aviso("",cTexto,{"ok"},3)
	
	fLogBsInsta(cTexto,aOkInc,aErrosInc,aExcluido,aAdiciona)

Return  


//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaBases
Cria bases instaladas...

@author  Alessandro Smaha
@since   06/02/2013
@return  NIL
/*/
//-------------------------------------------------------------------
Static Function fCriaBases(aBaseIns,aOkInc,aErrosInc)
    
	Local aCab040 	:= {}
   	Local aItens040 := {}  
   	Local aAutoErro := {}
	Local nI 		:= 0  

	Private lMsHelpAuto 	:= .T.
	Private lMsErroAuto 	:= .F. 
	Private lAutoErrNoFile 	:= .T. 
	 
	ProcRegua(Len(aBaseIns))
			
	For nI := 1 to Len(aBaseIns)  
	
		IncProc("Criando Base Intalada... Aguarde ("+cValToChar(nI)+")") 
	
		aCab040 := {}
		aItens040 := {}  
		                                 
		Aadd(aCab040, { "AA3_FILIAL", 	xFilial("AA3"),	NIL } )                
		Aadd(aCab040, { "AA3_CODCLI", 	aBaseIns[nI][1],NIL } )                
		Aadd(aCab040, { "AA3_LOJA", 	aBaseIns[nI][2],NIL } )                
		Aadd(aCab040, { "AA3_CODPRO",	aBaseIns[nI][3],NIL } )                
		Aadd(aCab040, { "AA3_NUMSER",	aBaseIns[nI][3],NIL } )                 
		Aadd(aCab040, { "AA3_DTVEN", 	aBaseIns[nI][4],NIL } ) 
		Aadd(aCab040, { "AA3_DTINST", 	aBaseIns[nI][5],NIL } ) 
		Aadd(aCab040, { "AA3_DTGAR", 	aBaseIns[nI][6],NIL } ) 
		             
		TECA040(,aCab040,aItens040,3)                
		                
		// VerIfica se houveram erros durante a geracao da base                  
		If !lMsErroAuto  
	
			aAdd(aErrosInc,Alltrim(aBaseIns[nI][1])+"|"+Alltrim(aBaseIns[nI][2])+"|"+Alltrim(aBaseIns[nI][3]))
				
		Else    
		                         
			aAdd(aOkInc,Alltrim(AA3->AA3_CODPRO)) 
	 		
	    EndIf 
	    
	Next nI
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuTexto
Atualiza Textos

@author  Alessandro Smaha
@since   06/02/2013
@return  NIL
/*/
//------------------------------------------------------------------- 
Static Function fAtuTexto( aArrayRec, cTituloTx )

	Local nI := 0 
	Local cAuxTxt := ""

	cAuxTxt += Replicate("-",60)+ CHR(13) + CHR(10)  
	cAuxTxt += cTituloTx
	
	For nI := 1 to Len(aArrayRec) 
	       
   		cAuxTxt += aArrayRec[nI] + ", " //+ CHR(13) + CHR(10)
		
	Next nI 

Return cAuxTxt  


//------------------------------------------------------------------- 
/*/{Protheus.doc} fLogBsInsta()
Salva o log     

@param cMsg - String de mensagem de log

@author Alessandro Smaha 
@since 06/02/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
Static Function fLogBsInsta(cContTxt,aOkInc,aErrosInc,aExcluido,aAdiciona)
      
    Local _cQlin := CHR(13) + CHR(10)  
	Local nI := 0
	Local cDirLog  := "\log_afs\"
	Local cArqNovo := cDirLog+DtoS(dDataBase)+"_"+SubStr(Time(),1,2)+"H"+SubStr(Time(),4,2)+"M"+SubStr(Time(),7,2)+"S.txt"  
	
	// Cria o diretorio se não existir
	MontaDir(cDirLog)
		
	//Cria arquivo no diretório
	nHandle  := FCREATE(cArqNovo, 0) 
			
	// Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido
	If FERROR() <> 0 
		
		MsgInfo("Não foi possível abrir ou criar o arquivo: " + cArqNovo )
	
	Else
	   
		//aOkInc,aErrosInc,aExcluido,aAdiciona
		FWrite( nHandle, Replicate("-",60)+_cQlin+"Inclusão OK"+_cQlin+_cQlin )
		For nI := 1 to Len(aOkInc)
			FWrite( nHandle, aOkInc[nI]+_cQlin )
		Next nI 
		
		FWrite( nHandle, Replicate("-",60)+_cQlin+"Inclusão ERRO"+_cQlin+_cQlin )
		For nI := 1 to Len(aErrosInc)
			FWrite( nHandle, aErrosInc[nI]+_cQlin )
		Next nI
		
		FWrite( nHandle, Replicate("-",60)+_cQlin+"Excluidos"+_cQlin+_cQlin )
		For nI := 1 to Len(aExcluido)
			FWrite( nHandle, aExcluido[nI]+_cQlin )
		Next nI
		
		FWrite( nHandle, Replicate("-",60)+_cQlin+"Adicionados"+_cQlin+_cQlin )
		For nI := 1 to Len(aAdiciona)
			FWrite( nHandle, aAdiciona[nI]+_cQlin )
		Next nI 
		
		FWrite( nHandle, Replicate("-",60)+_cQlin+"FIM"+_cQlin+Replicate("-",60) )

		FCLOSE(nHandle)
		         
		DbCommit()  
		
		MsgInfo("Arquivo de log salvo. "+cArqNovo,"Aviso")
					
	Endif
	
Return
