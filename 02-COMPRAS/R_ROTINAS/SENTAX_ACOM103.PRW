#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "FileIO.CH"
#INCLUDE "DBINFO.CH" 

/*/{Protheus.doc}  
 Rotina para manutenção da contagem cega realizada
@author  Anderson Roberto Franco de Souza
@since   27/09/2013
@return  
/*/    
User Function ACOM103()  

	Private cCadastro := "Contagem cega"
	Private aRotina   := {  {"Pesquisar"	,"AxPesqui"		,0,1},; 
                            { "Visualizar"  ,"A103NFiscal('SF1',SF1->(RECNO()),2,.F.,.F.)",0,2},;
							{"Informa"   	,"U_ACOM01('I')",0,3}}
	
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	
	Private cString := "SF1"
	
	dbSelectArea(cString)
	dbSetOrder(1)

	mBrowse( 6,1,22,75,cString)

Return

//+---------------------------------------------------------+
//|                                                         |
//+---------------------------------------------------------+

User Function ACOM01(cOpcao)
	Local aArea := GetArea()
	Local nPosCom := 0
	Local lRet:=.F.
	Private aHeader := {}
	Private aCols := {}
	Private lVisual := IIF(cOpcao=="V",.T.,.F.)
	Private lInclui := IIF(cOpcao=="I",.T.,.F.)
	Private lAltera := IIF(cOpcao=="A",.T.,.F.)
	Private lExclui := IIF(cOpcao=="E",.T.,.F.)
	Private nOpcE, nOpcG 
	
  	Do Case
		Case cOpcao=="I"; nOpcE:=3 ; nOpcG:=3
		Case cOpcao=="A"; nOpcE:=3 ; nOpcG:=3
		Case cOpcao=="V"; nOpcE:=2 ; nOpcG:=2
	EndCase 
	
	//+---------------------------------------------------------+
	//| Cria variaveis M->????? da Enchoice                     |
	//+---------------------------------------------------------+
//   RegToMemory("SF1",.T.)	
     RegToMemory("SF1",.F.,.F.)
     //M->F1_RZSOC:=POSICIONE("SA2",1,XFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")   
	
	//+---------------------------------------------------------+
	//| Cria aHeader e aCols da GetDados                        |
	//+---------------------------------------------------------+
	nUsado:=0
	
//	dbSelectArea("SX3")
//	dbSeek("SD1") 
	
//	aHeader:={}
	
//	While !Eof().And.(X3_ARQUIVO=="SD1")
	
//		If ALLTRIM(SX3->X3_CAMPO) != "D1_ITEM" .And. ALLTRIM(SX3->X3_CAMPO) != "D1_COD" .And. ALLTRIM(SX3->X3_CAMPO) != "D1_UM" ;
//		   .And. ALLTRIM(SX3->X3_CAMPO)!= "D1_DESCRIC" .And. ALLTRIM(SX3->X3_CAMPO) != "D1_QUANT" .And. ALLTRIM(SX3->X3_CAMPO) != "D1_XQTDCEG" 
//			dbSkip()
//			Loop
//		Endif
	
//		If X3USO(X3_USADO).And.cNivel>=X3_NIVEL .and. (ALLTRIM(SX3->X3_CAMPO) $ "D1_ITEM|D1_COD|D1_DESCRIC|D1_UM|D1_QUANT|D1_XQTDCEG")
//	    	nUsado:=nUsado+1
//	        Aadd(aHeader,{TRIM(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"AllwaysTrue()",X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
//		Endif
		
//	    dbSkip()
//	End
	
	nPosCom := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D1_ITEM"})
	
	//+---------------------------------------------------------+
	//| Cria o Acols dos campos que estão no Aheader para exibi-|
	//| ção na GetDados                                         |
	//+---------------------------------------------------------+
	
	//+---------------------------------------------------------+
	//| Caso seja Inclusão cria um Acols para exibir na GetDados|
	//| com uma posição                                         |
	//+---------------------------------------------------------+
	If lInclui .or. laltera
		
     	aCols:={}          
		
		dbSelectArea("SD1")
		dbSetOrder(1)   
		//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM
		dbSeek(M->F1_FILIAL+M->F1_DOC+M->F1_SERIE+M->F1_FORNECE+M->F1_LOJA)
		
		While !eof() .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == M->F1_FILIAL+M->F1_DOC+M->F1_SERIE+M->F1_FORNECE+M->F1_LOJA
			
			AADD(aCols,Array(nUsado+1))
			
			For ni:=1 to nUsado
			
				// Adiciona o conteudo do campo correspondente a posição no Aheader da Tabela 
				If aHeader[nI,10] # "V"   // Se nao for Campo Virtual
					aCols[Len(aCols),ni]:=FieldGet(FieldPos(aHeader[ni,2]))
				EndIf
				
			Next
			
			aCols[Len(aCols),nUsado+1]:=.F.
			
			dbSkip()
		End
	Endif

	If Len(aCols)>0
		//+---------------------------------------------------------+
		//| Executa a Modelo 3                                      |
		//+---------------------------------------------------------+
		cTitulo:=cCadastro
		cAliasEnchoice:="SF1"
		cAliasGetD:="SD1"
		cLinOk:="AllwaysTrue()"
		cTudOk:="U_AC103tOk(aheader,acols)" //"AllwaysTrue()"
		cFieldOk:="AllwaysTrue()"
		aCpoEnchoice:={"F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA"}       //,"F1_RZSOC"}

	   //	lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,u_AC103tOk(aheader,acols),nOpcE,nOpcG,cFieldOk)
	   	lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)   
		//+---------------------------------------------------------+
		//| Executar processamento                                  |
		//+---------------------------------------------------------+
		If lRet .And. !lVisual
		   	ConfRegra(aheader,acols)
		Endif
	Endif  
	RestArea(aArea)
Return


Static Function ConfRegra(aheader,acols)

	If lAltera .OR. linclui
		dbSelectArea("SD1")
		dbSetOrder(1)     
		//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM   
		// Grava qtdade informada resultante da conferência cega
		For i:=1 To Len(aCols)  
			cCod := aCols[i][Ascan(aHeader, {|X| AllTrim(X[2]) == "D1_COD"})]
			cItemNF := aCols[i][Ascan(aHeader, {|X| AllTrim(X[2]) == "D1_ITEM"})]
                                                                                                  
			If aCols[i][Len(aHeader)+1] == .F.      
			
		   	   If DbSeek(M->F1_FILIAL+M->F1_DOC+M->F1_SERIE+M->F1_FORNECE+M->F1_LOJA+cCod+cItemNF)
					RecLock("SD1",.F.)
					D1_XQTDCEG:=aCols[i][Ascan(aHeader, {|X| AllTrim(X[2]) == "D1_XQTDCEG"})]
					SD1->(MsUnlock()) 
				
				EndIf
			EndIf
		Next i
	EndIf   
		dbSelectArea("SF1")
		dbSetOrder(1)     
Return

// Valida quantdade entrada x conferência cega
User Function AC103tOk(aheader,acols) 
    Local lRet:=.T.
    Local nqtdDiv:=0
	For i:=1 To Len(aCols)    
        If aCols[i][Ascan(aHeader, {|X| AllTrim(X[2]) == "D1_QUANT"})] <> aCols[i][Ascan(aHeader, {|X| AllTrim(X[2]) == "D1_XQTDCEG"})] .and. (aCols[i][Ascan(aHeader, {|X| AllTrim(X[2]) == "D1_XQTDCEG"})]!=0)
   			nqtdDiv+=1 
        EndIf
	Next   
	If nqtdDiv > 0        
       IF !MsgYesNo("Divergência na contagem de "+Transform(nqtdDiv,"999")+" itens."+chr(13)+chr(10)+" Confirma essa informação ? ", "Conferência Cega")
    	   lRet:=.F.
       EndIf
	EndIf
Return lRet
