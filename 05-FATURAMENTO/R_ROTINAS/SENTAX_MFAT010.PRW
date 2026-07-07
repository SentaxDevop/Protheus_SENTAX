#Include 'Protheus.ch'
#Include 'TOPCONN.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT010
Rotina para compartilhar o cadastro de observações (SYP)

@return 	Nil
@author 	Felipe Toazza Caldeira
@since 	 	25/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------	

//*******************************************************************
//*******************************************************************
// ATENÇÃO
// Esta rotina deve ser rodada para as filiais 01**** e 03****.
// Após isso, a deve-se executar a query abaixo e mudar o compartilha
// mento da tabela SYP via configurador para compartilhada.
//
// UPDATE SYP010 SET YP_FILIAL = '  ' WHERE YP_FILIAL LIKE '%0202%' AND D_E_L_E_T_ != '*'
// update SYP010 set YP_FILIAL = '   ' where YP_FILIAL = '0202' and YP_CHAVE NOT IN (
// select distinct YP_CHAVE FROM (
// select YP_CHAVE, YP_SEQ, COUNT(*) as conta from SYP010 where (YP_FILIAL = '    ' OR YP_FILIAL = '0202') AND D_E_L_E_T_ != '*'
// group by YP_CHAVE, YP_SEQ having COUNT(*) > 1 ) AS T ) and D_E_L_E_T_ != '*'
//*******************************************************************
//*******************************************************************
User Function MFAT010()
    
	If MsgYesNo('Você irá rodar o compartilhamento da tabela SYP para a filial '+Alltrim(xFilial('SYP'))+". Deseja continuar?")
		Processa({|| fProcessa() },"Compartilha tabela SYP ")   
	EndIf   

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Rotina que irá realizar o processamento da atualização

@return 	Nil
@author 	Felipe Toazza Caldeira
@since 	 	25/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fProcessa
Local cQuery 	:= ""
Local cCodSYP 	:= "000000"
Local cSeq		:= "001"

	//***************************************************************
	//Pega o maior numero da sequencia da filial
	//***************************************************************
	cQuery := " SELECT MAX(YP_CHAVE) as CHAVE "
	cQuery += " FROM " + RetSQLName("SYP") + " "
	cQuery += " WHERE "//YP_FILIAL = '  ' AND "
	cQuery += " D_E_L_E_T_ <> '*'"
		
	cQuery := ChangeQuery(cQuery)
			
	If ( SELECT("TRB") ) > 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf
			
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TRB" 

    dbSelectArea("TRB")
    TRB->(DbGoTop())    
    
    If !TRB->(EOF())
    	cCodSYP := TRB->CHAVE
/*

    Else
		cQuery := " SELECT MAX(YP_CHAVE) as CHAVE "
		cQuery += " FROM " + RetSQLName("SYP") + " "
		cQuery += " WHERE YP_FILIAL = '"+xFilial('SYP')+"' AND "
		cQuery += " D_E_L_E_T_ <> '*'"
		
		cQuery := ChangeQuery(cQuery)
			
		If ( SELECT("TRB") ) > 0
			dbSelectArea("TRB")
			TRB->(dbCloseArea())
		EndIf
			
		cQuery := ChangeQuery(cQuery)
		TCQUERY cQuery NEW ALIAS "TRB" 

    	dbSelectArea("TRB")
    	TRB->(DbGoTop())    
    
    	If !TRB->(EOF())
    		cCodSYP := TRB->CHAVE
		EndIf    
*/		
    EndIf	
	TRB->(dbCloseArea())
	
	//***************************************************************
	//***************************************************************


	ProcRegua(0)

	//***************************************************************
	//Pega faz a pesquisa na tabela, apenas para tabelas exclusivas
	//***************************************************************   
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("SYP") + " "
	cQuery += " WHERE YP_FILIAL = '"+xFilial("SYP")+"' AND YP_CAMPO IN "
	cQuery += " ( "
	cQuery += "  'AA9_CODMEM','AB2_MEMO','AB4_MEMO','AB7_MEMO1','AB7_MEMO3','AB9_MEMO1','ACF_CODMOT','ACF_CODOBS','CC8_DESCR2','CDO_DESCR2', "
	cQuery += "  'TZ2_DESCRI','TZ5_DESCRI','UA_CODCANC','UA_CODOBS','UC_CODCANC','UC_CODMOT','UD_CODEXEC' 
	cQuery += " ) AND " 
	cQuery += " D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY YP_FILIAL, YP_CHAVE "
		
	cQuery := ChangeQuery(cQuery)
			
	If ( SELECT("TRB") ) > 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf
			
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TRB" 
     
    dbSelectArea("TRB")
    TRB->(DbGoTop())
    
    While !TRB->(EOF())
 		cCodSYP := Soma1(cCodSYP)

		cUpd := " UPDATE "+RetSqlName('SYP')+" SET YP_FILIAL = '      ', YP_CHAVE = '"+cCodSYP+"' "
		cUpd += " WHERE YP_FILIAL = '"+xFilial("SYP")+"' AND YP_CHAVE = '"+TRB->YP_CHAVE+"' AND YP_CAMPO = '"+TRB->YP_CAMPO+"' AND D_E_L_E_T_ <> '*'"
        TCSqlExec(cUpd)                         
                                      
        cAuxTab := SubStr(TRB->YP_CAMPO,1,At('_',TRB->YP_CAMPO)-1)
        If Len(Alltrim(cAuxTab)) == 2
        	cAuxTab := 'S'+Alltrim(cAuxTab)
        EndIf 
         
		cUpd := " UPDATE "+RetSqlName(cAuxTab)+" SET "+TRB->YP_CAMPO+" = '"+cCodSYP+"' "
		cUpd += " WHERE SUBSTRING("+IIF(SUbStr(cAuxTab,1,1)=='S',SUbStr(cAuxTab,2,2),cAuxTab)+"_FILIAL,1,2) = '"+SubStr(xFilial(cAuxTab),1,2)+"' AND "+TRB->YP_CAMPO+" = '"+TRB->YP_CHAVE+"' AND D_E_L_E_T_ <> '*'"
        TCSqlExec(cUpd)                         
		                  
		TRB->(DbSkip())    
    EndDo 
    TRB->(DbCloseArea())		


	//********************************************************************
	//Pega faz a pesquisa na tabela, apenas para tabelas compartilhadas
	//********************************************************************   
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("SYP") + " "
	cQuery += " WHERE YP_FILIAL = '"+xFilial("SYP")+"' AND YP_CAMPO IN "
	cQuery += " ( "
	cQuery += "  'F0G_DESCR2','F08_DESCR2','CCK_DESCR2','CC6_DESCR2','B1_CODPROC','B1_CODOBS','AA3_CODMEM','A1_CODHIST' "
	cQuery += " )"
	cQuery += " AND D_E_L_E_T_ <> '*'"            
	cQuery += " ORDER BY YP_CHAVE,  R_E_C_N_O_ "
		
	cQuery := ChangeQuery(cQuery)
			
	If ( SELECT("TRB") ) > 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf
			
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TRB" 
     
    dbSelectArea("TRB")
    TRB->(DbGoTop())
            
    While !TRB->(EOF())
       
    	cSeq := soma1(fSeq(TRB->YP_CHAVE,TRB->YP_CAMPO)) 
 		
		cUpd := " UPDATE "+RetSqlName('SYP')+" SET YP_FILIAL = '      ', YP_SEQ = '"+cSeq+"' "
		cUpd += " WHERE YP_FILIAL = '"+xFilial("SYP")+"' AND YP_CHAVE = '"+TRB->YP_CHAVE+"' AND YP_CAMPO = '"+TRB->YP_CAMPO+"' AND YP_SEQ = '"+TRB->YP_SEQ+"' AND D_E_L_E_T_ <> '*'"
        TCSqlExec(cUpd)                         
                                      		                  
		TRB->(DbSkip())    
    EndDo 
    TRB->(DbCloseArea())		

		                                                                                            
Return          

//-------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Rotina que irá buscar o maior numero da sequencia

@return 	Nil
@author 	Felipe Toazza Caldeira
@since 	 	25/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fSeq(cChave,cCampo)
Local cAux 		:= "000"
Local cQuery 	:= ""    

	//********************************************************************
	//Pega faz a pesquisa na tabela, apenas para tabelas compartilhadas
	//********************************************************************   
	cQuery := " SELECT MAX(YP_SEQ) AS SEQ "
	cQuery += " FROM " + RetSQLName("SYP") + " "
	cQuery += " WHERE YP_CHAVE = '"+cChave+"' AND YP_CAMPO = '"+cCampo+"' AND "
	cQuery += " D_E_L_E_T_ <> '*'"            
		
	cQuery := ChangeQuery(cQuery)
			
	If ( SELECT("TRBSEQ") ) > 0
		dbSelectArea("TRBSEQ")
		TRBSEQ->(dbCloseArea())
	EndIf
			
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TRBSEQ" 
     
    dbSelectArea("TRBSEQ")
    TRBSEQ->(DbGoTop())
	If !TRBSEQ->(EOF())
		cAux := TRBSEQ->SEQ
    EndIf	
	TRBSEQ->(dbCloseArea())

return cAux
