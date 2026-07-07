#INCLUDE "Protheus.CH"     
#INCLUDE "rwmake.ch"    
#Include "topconn.ch"
//---------------------------------------------------------------------
/*/{Protheus.doc} ACOM001
Rotina para gerar automaticamente várias pré-notas a partir dos CT-e marcados

@author Alessandro Smaha
@since 13/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
User Function ACOM001()
 	
 	Local nOpcx    := 0
	Local cCab	   := "" 
	Local cArqRet  := ""
	Local lInverte := .F.
	Local _aBrowse := {}  

	Static oDlg        
	
	Private oMarkReg   
	
	cCab   := "CT-e disponíveis para geração da Pré-nota"			
 	lOnly  := .F.

	Processa({ |lEnd| cArqRet := fGrid(@_aBrowse) }, "Aguarde...", "Verificando Chaves...",.T.)
	
	If Empty(cArqRet)
		Return
	EndIf
	
	oFont  := TFont():New("Verdana",08,12,,.T.,,,,,.F.,.F.)
	
	DEFINE MSDIALOG oDlg TITLE "Seleção de CT-e" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL
	
		@ 185, 010 BUTTON oButVs PROMPT "Visualizar CT-e" 	ACTION fVisualCte() 		 SIZE 053, 012 OF oDlg PIXEL
		@ 185, 204 BUTTON oButOk PROMPT "Ok" 			    ACTION (nOpcx:=1,oDlg:End()) SIZE 037, 012 OF oDlg PIXEL
		@ 185, 254 BUTTON oButCl PROMPT "Cancelar"			ACTION (nOpcx:=0,oDlg:End()) SIZE 037, 012 OF oDlg PIXEL

		@ 005, 005 SAY oSay1 PROMPT cCab SIZE 250, 007 OF oDlg FONT oFont PIXEL
		
		oMarkReg := msSelect():New('TMPMRK','OK','',_aBrowse,@lInverte,cMarca,{015,005,182,298})
		oMarkReg:oBrowse:lCanAllmark := .T. 
		
		oMarkReg:bAval := { || fMarkReg('TMPMRK','OK',cMarca) } 
			
		Eval(oMarkReg:oBrowse:bGoTop)	
		oMarkReg:oBrowse:Refresh()
				
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpcx == 1		
		fProcessa()
	Endif
	
	If Select("TMPMRK") > 0		
		DbSelectArea("TMPMRK")		
		DbCloseArea()		
	Endif 
	 
Return   


//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkReg
Rotina para marcar registros 

@author Alessandro Smaha
@since 13/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fMarkReg(cAliasMrk,cCampoOk,cMarcaOk)
	
	If (cAliasMrk)->(Eof())
		Return
	EndIf
	
	if Reclock(cAliasMrk,.F.)
		if cMarcaOk <> &cCampoOk
			&cCampoOK := cMarcaOk
		Else
			&cCampoOK := "  "
		Endif
		msUnlock()
	endif
	
	aAreaTmp := (cAliasMrk)->(GetArea())
	
	RestArea(aAreaTmp)
	
	oMarkReg:oBrowse:Refresh()  

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Rotina para realizar gerar pré-nota automaticamente (várias)

@author Alessandro Smaha
@since 14/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fProcessa()

	Local cErros   := ""
	Local nOkNotas := 0

	DbSelectArea("SA2")
	SA2->(DbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
	If !SA2->(DbSeek(xFilial("SA2")+Z5Z->(Z5Z_FORNEC+Z5Z_LOJA)))
		MsgAlert("Fornecedor "+Z5Z->Z5Z_FORNEC+" e loja "+Z5Z->Z5Z_LOJA+" não cadastrado!") 
		Return
	EndIf  

	DbSelectArea("Z5Z") 
	Z5Z->(DbSetOrder(1)) // Z5Z_FILIAL+Z5Z_CHAVE  
	 
	DbSelectArea("TMPMRK") 
	TMPMRK->(DbGoTop())
	
	While TMPMRK->(!Eof()) 
	    
		If !Empty(TMPMRK->OK)
			
			cChvCte := TMPMRK->CHAVE
	
			If Z5Z->(DbSeek(xFilial("Z5Z")+cChvCte)) 
				Processa({ |lEnd| U_NFAC015P(.F.,@nOkNotas) }, "Aguarde...", "Gerando Pré-Nota...",.F.) 
			Else
			    cErros += "Não encontrou a chave "+cChvCte+"."+chr(13)+chr(10)
			EndIf   
			
		EndIf
			
   		TMPMRK->(DbSkip())
   		
	EndDo  
	
	If !Empty(cErros)
		MsgInfo(cErros,"Atenção")
	EndIf
	
	MsgInfo("Total de pré-notas geradas: "+cValToChar(nOkNotas),"Aviso")
	
Return   

  
//---------------------------------------------------------------------
/*/{Protheus.doc} fVisualCte
Rotina para visualizar a CT-e

@author Alessandro Smaha
@since 14/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fVisualCte()

	Local cChvCte := "CHAVE"

	DbSelectArea("Z5Z") 
	Z5Z->(DbSetOrder(1)) // Z5Z_FILIAL+Z5Z_CHAVE
	If Z5Z->(DbSeek(xFilial("Z5Z")+cChvCte))
	 	U_NFAC015T(2)
	Else 	     
		MsgInfo("Não existe a chave '"+cChvCte+"' cadastrada no CT-e importados (Z5Z).")
	EndIf
	
Return



//---------------------------------------------------------------------
/*/{Protheus.doc} fGrid
Rotina para realizar seleção de itens

@author Alessandro Smaha
@since 06/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGrid(_aBrowse)
	
	Local _lRetorno := .F. 		//Validacao da dialog criada oDlg	
	Local _cArqEmp 	:= "" 		//Arquivo temporario com as empresas a serem escolhidas
	Local _aStruTrb := {} 		//estrutura do temporario     
	Local cProdutos := "" 
	Local cRetOk	:= ""
	Local cBkpFil	:= cFilAnt

	Private cPerg := "ACOM001P"
	
	AjustaSX1() 
	
	If !Pergunte(cPerg,.T.) 	 
	 	Return cRetOk
	Else
		nOrdem  := MV_PAR07
	EndIf
	
	If Empty(MV_PAR08)
	    Return cRetOk
	EndIf
	
	cFilAnt := MV_PAR08        

	aadd(_aStruTrb,{"OK" 		,"C",02,0})		// Define campos do TRB 
	aadd(_aStruTrb,{"DOCUMENTO" ,"C",09,0})	
	aadd(_aStruTrb,{"SERIE" 	,"C",03,0})	
	aadd(_aStruTrb,{"EMISSAO" 	,"D",08,0})	
	aadd(_aStruTrb,{"FORN"  	,"C",06,0})
	aadd(_aStruTrb,{"LOJA"	 	,"C",02,0})
	aadd(_aStruTrb,{"NOME"	 	,"C",40,0})
	aadd(_aStruTrb,{"CHAVE" 	,"C",44,0})	
	
	aadd(_aBrowse,{"OK" ,,		"" })  			// Define campos do MsSelect	
	aadd(_aBrowse,{"DOCUMENTO",,"Nota" })	
	aadd(_aBrowse,{"SERIE",,	"Série" })	
	aadd(_aBrowse,{"EMISSAO" ,,	"Emissão" }) 
	aadd(_aBrowse,{"FORN" ,,	"Fornecedor" })
	aadd(_aBrowse,{"LOJA" ,,	"Loja" })
	aadd(_aBrowse,{"NOME" ,,	"Nome" })	
	aadd(_aBrowse,{"CHAVE",,	"Chave" })
	
	DbSelectArea("Z5Z")
	Z5Z->(DbSetOrder(1))	// Z5Z_FILIAL+Z5Z_CHAVE
			
	If Select("TMPMRK") > 0		
		TMPMRK->(DbCloseArea())		
	Endif 
	
	ProcRegua(0)
	IncProc("Verificando Notas de Saída...")

	//_cArqEmp := CriaTrab(_aStruTrb)
	//dbUseArea(.T.,__LocalDriver,_cArqEmp,"TMPMRK")

	oTmp := FWTemporaryTable( ):New( )
	oTmp:SetFields(_aStruTrb)
	oTmp:AddIndex("01", { "Z5Z_FILIAL", "Z5Z_CHAVE"} )
	oTmp:Create( )
	_cArqEmp:= oTmp:GetAlias( )

	
	cQuery := " SELECT Z5Z_DOC DOCUMENTO,Z5Z_SERIE SERIE,Z5Z_EMISSA EMISSAO,Z5Z_FORNEC FORN,Z5Z_LOJA LOJA,Z5Z_NOME NOME,Z5Z_CHAVE CHAVE,* " 
	cQuery += " FROM " + RetSQLName('Z5Z')+ " Z5Z 
	cQuery += " WHERE 	Z5Z_FILIAL = '"+xFilial("Z5Z")+"' "
	cQuery += " 		AND Z5Z_STATUS = '2' "       
	cQuery += " 		AND Z5Z_FORNEC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR03+"' "
	cQuery += " 		AND Z5Z_LOJA   BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR04+"' "
	cQuery += " 		AND Z5Z_EMISSA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' "
	cQuery += " 		AND Z5Z.D_E_L_E_T_ <> '*' "	
	cQuery += " ORDER BY " 
 
	If nOrdem == 1  // 1="Cód. Fornecedor" 2="Documento" 3="Emissão" 4="Nome Fornecedor" 
   		cQuery += " 	Z5Z_FORNEC, Z5Z_LOJA "
 	ElseIf nOrdem == 2
   		cQuery += " 	Z5Z_EMISSA "
	ElseIf nOrdem == 3
   		cQuery += " 	Z5Z_NOME "
	Else
   		cQuery += " 	Z5Z_DOC, Z5Z_SERIE "
	EndIf
	
	TCQuery cQuery new Alias ( cAlias := GetNextAlias() )   
	
	(cAlias)->(DbGoTop())
	
	If (cAlias)->(!Eof())
	
		While (cAlias)->(!Eof())
		
			RecLock("TMPMRK",.T.)
					
				TMPMRK->OK 			:= "  "		
				TMPMRK->DOCUMENTO	:= (cAlias)->DOCUMENTO	
				TMPMRK->SERIE   	:= (cAlias)->SERIE	
				TMPMRK->EMISSAO 	:= StoD((cAlias)->EMISSAO) 
				TMPMRK->FORN 		:= (cAlias)->FORN
				TMPMRK->LOJA    	:= (cAlias)->LOJA
				TMPMRK->NOME    	:= (cAlias)->NOME						
				TMPMRK->CHAVE   	:= (cAlias)->CHAVE
		
			MsUnlock()
			
			(cAlias)->(DbSkip())
			
		Enddo
		
		(cAlias)->(DbCloseArea())  
		
		cRetOk := (_cArqEmp+OrdBagExt()) 
		
	Else
	
		MsgInfo("Não possui itens para seleção!","Atenção")
		
	EndIf 
	
	//cFilAnt := cBkpFil
 
Return cRetOk         

//---------------------------------------------------------------------
/*/{Protheus.doc} AjustaSx1
Rotina para ajustar o SX1

@author Alessandro Smaha
@since 12/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function AjustaSx1() 
    
   	PutSx1(cPerg,"01","Fornecedor de ?" ,"Fornecedor de ?" 	,"Fornecedor de ?" 	,"MV_CH1","C",06,0,0,"G","","SA2","","","MV_PAR01")
   	PutSx1(cPerg,"02","Loja de ?" 	 	,"Loja de ?" 		,"Loja de ?" 		,"MV_CH2","C",02,0,0,"G","","   ","","","MV_PAR02") 
    PutSx1(cPerg,"03","Fornecedor ate ?","Fornecedor ate ?"	,"Fornecedor ate ?"	,"MV_CH3","C",06,0,0,"G","","SA2","","","MV_PAR03")
   	PutSx1(cPerg,"04","Loja ate ?"		,"Loja ate ?"		,"Loja ate ?"		,"MV_CH4","C",02,0,0,"G","","   ","","","MV_PAR04")  
	PutSx1(cPerg,"05","Emissão de ?" 	,"Emissão de ?" 	,"Emissão de ?" 	,"MV_CH5","D",08,0,0,"G","","   ","","","MV_PAR05") 
	PutSx1(cPerg,"06","Emissão ate ?"	,"Emissão ate ?"	,"Emissão ate ?"	,"MV_CH6","D",08,0,0,"G","","   ","","","MV_PAR06")  
	PutSx1(cPerg,"07","Ordem?"		 	,"Ordem?"       	,"Ordem?"       	,"MV_CH7","N",01,0,0,"C","","   ","","","MV_PAR07",;
				 "Cód. Fornecedor","Cód. Fornecedor","Cód. Fornecedor","","Documento","Documento","Documento","Emissão","Emissão","Emissão",;
				 "Nome Fornecedor","Nome Fornecedor","Nome Fornecedor")
    PutSx1(cPerg,"08","Filial ?"   		,"Filial ?" 		,"Filial ?" 		,"MV_CH8","C",06,0,0,"G","","SM0","","","MV_PAR08")
                	
Return
