#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#Include "TOPCONN.CH"  
#Include "RWMAKE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC001
Cadastro de Endereços

@author		Alessandro Smaha
@since		18/06/2014
@version 	1.0
/*/
//-------------------------------------------------------------------
User Function ATEC001()  

	Local cVldAlt := ".T." 
	Local cVldExc := "U_ATEC001V(1)" 
	
	Private cString := "Z08"
	
	dbSelectArea("Z08")
	dbSetOrder(1)
	
	AxCadastro(cString,"Cadastro de Endereços",cVldExc,cVldAlt)
	
Return  


//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC001V
Valida a exclusão

@author		Alessandro Smaha
@since		18/06/2014
@version 	1.0
/*/
//-------------------------------------------------------------------
User Function ATEC001V(nOpcax)
         
	Local cQry	 := ""
	Local lRetOk := .T.  	
	Local cCodCli := "" 
	Local cLojCli := "" 
	Local cSequen := ""
	
	cCodCli := Z08->Z08_CODCLI
	cLojCli := Z08->Z08_LOJA
	cSequen := Z08->Z08_SEQUEN
	
	cQry := " SELECT AB1_NRCHAM "  
	cQry += " FROM " + RetSqlName('AB1') + ' AB1 '
	cQry += " WHERE
	cQry += " 		AB1_FILIAL = '" + xFilial('AB1') + "'"
	cQry += " 		AND AB1_CODCLI 	= '"+cCodCli+"'" 
	cQry += " 		AND AB1_LOJA	= '"+cLojCli+"'" 
	cQry += " 		AND AB1_XCDEND	= '"+cSequen+"'" 
	cQry += " 		AND AB1.D_E_L_E_T_ <> '*' "
	
	If Select("QVAL") <> 0
		QVAL->(DbCloseArea())
	EndIf      
	
	TcQuery cQry new Alias "QVAL"  
	
	DbSelectArea("QVAL") 
	
	If ! QVAL->(Eof())          
		If nOpcax == 1	// Utilizado na validação da exclusão
			MsgAlert("Registro não pode ser excluído! Já foi utilizado por um atendimento.","Atenção")    
		ElseIf nOpcax == 2	// Utilizado no when
		    
		EndIf
	   	lRetOk := .F.		
	EndIf
	

Return lRetOk  


//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC001B
Busca o sequencial do cliente

@return 	cCodSeq - Sequencial disponivel

@author		Alessandro Smaha
@since		18/06/2014
@version 	1.0
/*/
//-------------------------------------------------------------------
User Function ATEC001B(cCodCli,cLojCli)

	Local cCodSeq 	:= "" 
	Local cQry   	:= ""
	
	cQry := " SELECT ISNULL(MAX(Z08_SEQUEN)+1,1) PROXSEQ  
	cQry += " FROM " + RetSqlName('Z08') + ' Z08 '
	cQry += " WHERE
	cQry += " 		Z08_FILIAL = '" + xFilial('Z08') + "'"
	cQry += " 		AND Z08_CODCLI 	= '"+cCodCli+"'" 
	cQry += " 		AND Z08_LOJA	= '"+cLojCli+"'" 
	cQry += " 		AND Z08.D_E_L_E_T_ <> '*' "
	
	If Select("NUM_PROX") <> 0
		NUM_PROX->(DbCloseArea())
	EndIf      
	
	TcQuery cQry new Alias "NUM_PROX"  
	
	DbSelectArea("NUM_PROX")
	cCodSeq := StrZero(NUM_PROX->PROXSEQ,TAMSX3("Z08_SEQUEN")[1])

Return cCodSeq


//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC001C
Monta a tela para consulta padrão de endereços de clientes

@author Alessandro Smaha
@since  18/06/2013  
/*/
//-------------------------------------------------------------------
User Function ATEC001C(nOpcao) 

	Local cCodCli	:= ""
	Local cLojCli	:= ""  
	Local lRet      := .F.   
	Local aAreaSA1  := SA1->(GetArea())
	Local aAreaAA3  := AA3->(GetArea())

	If nOpcao == 1 // Chamada consulta padrão e gatilho do Chamado técnico (Telemarket)
		cCodCli	:= M->AB1_CODCLI
		cLojCli := M->AB1_LOJA  
	ElseIf nOpcao == 2 // Chamada consulta padrão e gatilho da Ordem de Serviço
		cCodCli	:= M->AB6_CODCLI
		cLojCli := M->AB6_LOJA
	EndIf
	
	lRet := fConsulta(cCodCli,cLojCli)  
	                 
	RestArea(aAreaSA1)   
	RestArea(aAreaAA3) 
	
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} fConsulta
Monta a tela para consulta padrão

@author Alessandro Smaha
@since  18/06/2013  
/*/
//-------------------------------------------------------------------	
Static Function fConsulta(cCodCli,cLojCli) 

   	Local lRet		:= .T.
	Local aTitulo	:= {}
	Local aCabec	:= {}
	Local aCodigos  := {}
	Local aItens    := {} 
	Local aButtons	:= {}
	Local nX		:= 0
	Local nRet		:= 0
	Local lCancel   := .T.
	Local cDescri 	:= ""  
	Local cQuery    := ""  
	
	// AAdd(aButtons,{ "BMPVISUAL",{ ||  U_ATEC001() }, OemToAnsi( 'Cad. Endereços' ) } )      
	
	aButtons := { {11, { || U_ATEC001() } } }
	
	If ! Empty(cCodCli) .AND. ! Empty(cLojCli)         
		
		cQuery := fBuscaEnd(cCodCli,cLojCli)  
		        
		If Select("QEND") <> 0
			QEND->(DbCloseArea())
		EndIf      
		
		TcQuery cQuery new Alias "QEND"  
		
		QEND->(DbGoTop())
		
		While QEND->(!Eof()) 
		
			Aadd( aItens, { QEND->Z08_SEQUEN, QEND->A1_END } ) 
			
			QEND->(DbSkip())
		
		EndDo 
		
	EndIf
		    
	cDescri := "Endereços de Clientes"
	 	
	If Len(aItens) > 0
			
		Aadd(aTitulo,'Código' )
		Aadd(aTitulo,'Endereço' )

		aCabec := aClone(aTitulo)
				
		nRet := TmsF3Array( aTitulo, aItens, OemToAnsi(cDescri), lCancel,aButtons, aCabec )
			 	
		If !Empty(nRet) 
		
			VAR_IXB := aItens[nRet][1]
			  
		EndIf
		
	Endif  
	    
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaEnd
Busca endereço

@author Alessandro Smaha
@since  18/06/2013  
/*/
//-------------------------------------------------------------------	
Static Function fBuscaEnd(cCodCli,cLojCli)
	
	Local cQuery := ''
	
	// ENDEREÇO DO CADASTRO DO CLIENTE
	
	cQuery += " SELECT * FROM (
	cQuery += " 	SELECT   
	cQuery += " 		'000' Z08_SEQUEN ,
	cQuery += " 		A1_COD A1_COD ,
	cQuery += " 		A1_LOJA A1_LOJA , 	 
	cQuery += " 		RTRIM(A1_END)+' '+RTRIM(A1_MUN)+'-'+RTRIM(A1_EST) A1_END
	cQuery += " 	FROM 
	cQuery += RetSqlName('SA1') + " SA1 " 
	cQuery += " 	WHERE
	cQuery += " 		SA1.D_E_L_E_T_ <> '*' 
	If !Empty(cCodCli) 
		cQuery += " 		AND SA1.A1_COD = '"+cCodCli+"'" 
	EndIf  
	If !Empty(cLojCli)
   		cQuery += " 		AND SA1.A1_LOJA = '"+cLojCli+"'"
 	EndIf	
    
	// ENDEREÇOS DE ENTREGA DO CLIENTE (TABELA Z08)
	
	cQuery += " 	UNION ALL
	cQuery += " 	SELECT  
	cQuery += " 		Z08_SEQUEN Z08_SEQUEN , 
	cQuery += " 		Z08_CODCLI A1_COD ,    
	cQuery += " 		Z08_LOJA A1_LOJA ,	
	cQuery += " 		RTRIM(Z08_ENDERE)+' '+RTRIM(Z08_MUN)+'-'+RTRIM(Z08_EST) A1_END
	cQuery += " 	FROM     
	cQuery += RetSqlName('Z08') + " Z08 " 
	cQuery += " 	WHERE  
	cQuery += " 		Z08.D_E_L_E_T_ <> '*'
	If !Empty(cCodCli) 
		cQuery += " 		AND Z08.Z08_CODCLI = '"+cCodCli+"'" 
	EndIf  
	If !Empty(cLojCli)
   		cQuery += " 		AND Z08.Z08_LOJA = '"+cLojCli+"'"
 	EndIf	  

	// ENDEREÇO DE ENTREGA DO CADASTRO DE CLIENTE

	cQuery += " 	UNION ALL
	cQuery += " 	SELECT   
	cQuery += " 		'999' Z08_SEQUEN ,
	cQuery += " 		A1_COD A1_COD ,
	cQuery += " 		A1_LOJA A1_LOJA , 	 
	cQuery += " 		RTRIM(A1_ENDENT)+' '+RTRIM(A1_MUNE)+'-'+RTRIM(A1_ESTE) A1_END
	cQuery += " 	FROM 
	cQuery += RetSqlName('SA1') + " SA1 " 
	cQuery += " 	WHERE
	cQuery += " 		SA1.D_E_L_E_T_ <> '*' 
	If !Empty(cCodCli) 
		cQuery += " 		AND SA1.A1_COD = '"+cCodCli+"'" 
	EndIf  
	If !Empty(cLojCli)
   		cQuery += " 		AND SA1.A1_LOJA = '"+cLojCli+"'"
 	EndIf	

 	cQuery += " 	) AS TRB1 ORDER BY A1_COD, A1_LOJA, Z08_SEQUEN
	
	//U_MakeView('AESP018',cQuery) 

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC001D
Busca o endereço do cliente

@return 	cCodSeq - Sequencial disponivel

@author		Alessandro Smaha
@since		18/06/2014
@version 	1.0
/*/
//-------------------------------------------------------------------
User Function ATEC001D(cCodCli,cLojCli,cCodSeq)

	Local cQry   	:= ""    
	Local cEndCli	:= "" 
	Local aAreaSA1	:= SA1->(GetArea())
	Local aAreaAA3 	:= AA3->(GetArea())

	If cCodSeq == "000" // Busca o endereço padrão do cliente 
	
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
			
			//cEndCli := Alltrim(SA1->A1_END)
			cEndCli := Alltrim(SA1->A1_END)+", "+SA1->A1_EST+"-"+AllTrim(SA1->A1_MUN)
			
		EndIf
	
	ElseIf cCodSeq == "999" // Busca o endereço de entrega padrão do cliente 
	
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
			
			cEndCli := Alltrim(SA1->A1_ENDENT)+", "+SA1->A1_ESTE+"-"+AllTrim(SA1->A1_MUNE)
			
		EndIf
	
	Else
		
		cQry := " SELECT RTRIM(Z08_ENDERE)+' '+RTRIM(Z08_MUN)+'-'+RTRIM(Z08_EST) Z08_ENDERE "
		cQry += " FROM " + RetSqlName('Z08') + ' Z08 '
		cQry += " WHERE
		cQry += " 		Z08_FILIAL = '" + xFilial('Z08') + "'"
		cQry += " 		AND Z08_CODCLI 	= '"+cCodCli+"'" 
		cQry += " 		AND Z08_LOJA	= '"+cLojCli+"'" 
		cQry += " 		AND Z08_SEQUEN	= '"+cCodSeq+"'" 
		cQry += " 		AND Z08.D_E_L_E_T_ <> '*' "
		
		If Select("QSEQ") <> 0
			QSEQ->(DbCloseArea())
		EndIf      
		
		TcQuery cQry new Alias "QSEQ"  
		
		DbSelectArea("QSEQ")   
		
		If ! QSEQ->(EOF()) 
		 	cEndCli := Alltrim(QSEQ->Z08_ENDERE)
		EndIf
		
	EndIf  
	
	RestArea(aAreaSA1)
	RestArea(aAreaAA3) 
	
Return cEndCli  


//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC001E
Validação do campo

@return 	cCodSeq - Sequencial disponivel

@author		Alessandro Smaha
@since		18/06/2014
@version 	1.0
/*/
//-------------------------------------------------------------------
User Function ATEC001E(cCodCli,cLojCli,cCodSeq)

	Local lRetOk := .T.
    
	DbSelectArea("Z08")
	Z08->(DbSetOrder(1)) 
	
	If ! Empty(cCodSeq) 
		If cCodSeq <> "000" .AND. cCodSeq <> "999"
			If ! Z08->(DbSeek(xFilial("Z08")+cCodCli+cLojCli+cCodSeq))  
				MsgAlert("Não existe endereço cadastrado para esta sequencia!","Atenção") 
		   		lRetOk := .F.
			EndIf        
		EndIf
	EndIf
	
Return lRetOk
