#include "Protheus.ch" 
#INCLUDE "topconn.ch"
#Include "Folder.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} AACD001
Monitor de Conferência
Rotina de monitoramento de embarque simples sobre os itens da Nota Fiscal de Saida.
OBS.: Nao utiliza controle de enderecamento/rastreabilidade/palletizacao   

@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function AACD001() 
	                      
	Local oBrowse := Nil

	Private aRotina := {	{ "Pesquisar"  			,"AxPesqui"   	, 0, 1 },; //"Pesquisar"
							{ "Monitorar Separação" ,"U_ACD001A"	, 0, 3 },; //"Monitorar"
							{ "Legenda"  			,"U_ACD001C" 	, 0, 5 }}  //"Legenda"
	
	Private cCadastro := OemtoAnsi( "Monitor de Conferência" ) 
	Private dDataCol := CtoD("  /  /  ")
	Private cHoraCol := "" 
	Private cNumeCol := ""
	   
	aCores := {	{ "U_ACD001D(1)", "BR_VERDE"	},;
				{ "U_ACD001D(2)", "BR_AMARELO"	},;
				{ "U_ACD001D(3)", "BR_AZUL"		},;
				{ "U_ACD001D(4)", "BR_LARANJA"	},;
				{ "U_ACD001D(5)", "BR_PINK"		},;
				{ "U_ACD001D(6)", "BR_VERMELHO"	},; 
				{ "U_ACD001D(7)", "BR_PRETO"	}}   
				
	SF2->(DbSetOrder(1))
    
	//MBrowse ( 	6, 1, 22, 75, "SF2", , , , , , aCores,/* cTopFun */,/*cBotFun*/,/*nPar14*/,/*bInitBloc*/,;
	//			/*lNoMnuFilter*/,/*lSeeAll*/,/*lChgAll*/,/*cExprFilTop*/,1000/*nInterval*/,{ |x| fTimerBrw(x) }/*bTimerAction*/)
	
	oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias( "SF2" )
	
	oBrowse:AddLegend( "U_ACD001D(1)", "BR_VERDE"	, "- Conferência Não Iniciada" 	) 
	oBrowse:AddLegend( "U_ACD001D(2)", "BR_AMARELO",  "- Separação Iniciada" 		) 
	oBrowse:AddLegend( "U_ACD001D(3)", "BR_AZUL"	, "- Separação Finalizada" 		) 
	oBrowse:AddLegend( "U_ACD001D(4)", "BR_LARANJA",  "- Expedição Iniciada" 		) 
	oBrowse:AddLegend( "U_ACD001D(5)", "BR_PINK"	, "- Expedição Finalizada" 		) 
	oBrowse:AddLegend( "U_ACD001D(6)", "BR_VERMELHO", "- Romaneio Finalizado" 		) 
	oBrowse:AddLegend( "U_ACD001D(7)", "BR_PRETO"	, "- Nota Fiscal Cancelada"		) 
	
	oBrowse:SetDescription( cCadastro )
	
	//oBrowse:SetTimer( { || fTimerBrw(@oBrowse) }, 5000 )
	
	oBrowse:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ACD001A
Consulta dos itens embarcados  

@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ACD001A()
	
	Local oDlgEmb
	Local oFolder, aTitulos:={}, aPaginas:={}
	Local lUsaCB0 := UsaCB0("01")
	Local oTimer
	
	Local aListBoxSD2 := {}
	Local oListBoxSD2
	Local cVarSD2
	
	Local aListBoxDet := {}
	Local oListDet
	Local cVarDet
	
	Local cStatus := RetStatusEmb()
	Local cTitulo := "Monitor - Nota Fiscal: "+SF2->F2_DOC+" - Serie: "+SF2->F2_SERIE+" - ("+cStatus+")" //"Embarque - Nota Fiscal: "###" - Serie: "
	
	// Incrementa titulos do Folder:
	aadd(aTitulos,OemtoAnsi("Itens")) //"Itens"
	aadd(aPaginas,OemtoAnsi("Itens")) //"Itens" 
	
	If lUsaCB0
		aadd(aTitulos,OemtoAnsi("Etiquetas")) //"Etiquetas"
		aadd(aPaginas,OemtoAnsi("Etiquetas")) //"Etiquetas"
	Endif
	
	DEFINE MSDIALOG oDlgEmb TITLE OemToAnsi(cTitulo) FROM 0,0 TO 300,700 PIXEL
	
	// Monta Folder:
	oFolder:=TFolder():New(10,0,aTitulos,aPaginas,oDlgEmb,,,,.T.,.F.,352,152,)
	oFolder:bSetOption := {|nAtu| AtuDetEti(aListBoxDet,oListDet,aListBoxSD2[oListBoxSD2:nAt,1],oTimer)}
	
	@ 0,0 LISTBOX oListBoxSD2 VAR cVarSD2 FIELDS HEADER "Produto","Descricao","Qtde Nota","Qtde Separada" SIZE 350,128 PIXEL OF oFolder:aDialogs[1] 
	AtuSD2(aListBoxSD2,oListBoxSD2)
	
	If lUsaCB0
		@  0,0  LISTBOX oListDet VAR cVarDet FIELDS HEADER "Etiqueta            ","Produto        ","Quantidade","" SIZE 300,138 PIXEL OF oFolder:aDialogs[2] //"Etiqueta            "###"Produto        "###"Quantidade"
		AtuDetEti(aListBoxDet,oListDet,aListBoxSD2[oListBoxSD2:nAt,1])
	Endif
	
	DEFINE TIMER oTimer INTERVAL 1000 ACTION If(oFolder:nOption == 1,AtuSD2(aListBoxSD2,oListBoxSD2,oTimer),AtuDetEti(aListBoxDet,oListDet,aListBoxSD2[oListBoxSD2:nAt,1],oTimer)) OF oDlgEmb
	oTimer:Activate()
	
	ACTIVATE MSDIALOG oDlgEmb CENTERED ON INIT EnchoiceBar(oDlgEmb,{||oDlgEmb:End()},{||oDlgEmb:End()})
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RetStatusEmb
Retorna a descricao do status do embarque

@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function RetStatusEmb() 

	Local cRetStatus := ""
	
	CBK->(DbSeek(xFilial('CBK')+SF2->(F2_DOC+F2_SERIE)))

 	If CBK->CBK_STATUS $ " 1"
		cRetStatus := ("Conferência Não Iniciada")	// VERDE
	ElseIf CBK->CBK_STATUS == "2"
		cRetStatus := ("Separação Iniciada")  		// AMARELO
	ElseIf CBK->CBK_STATUS == "3"
		cRetStatus := ("Separação Finalizada") 		// AZUL   
	ElseIf CBK->CBK_STATUS == "4"
		cRetStatus := ("Expedição Iniciada")   		// LARANJA
	ElseIf CBK->CBK_STATUS == "5"
		cRetStatus := ("Expedição Finalizada")		// PINK
	ElseIf CBK->CBK_STATUS == "6"
		cRetStatus := ("Romaneio Finalizado")		// VERMELHO  
	ElseIf CBK->CBK_STATUS == "7"
		cRetStatus := ("Nota Fiscal Cancelada")		// PRETO
	EndIf   
 
Return cRetStatus


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSD2
Funcao que atualiza informacoes do listbox principal (SD2)
   
@param		aListBoxSD2 -> array do listbox principal 
@param		oListBoxSD2 -> objeto do listbox principal
@param		oTimer      -> objeto timer do listbox principal
@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function AtuSD2(aListBoxSD2,oListBoxSD2,oTimer)
	
	Local  nPos
	
	If oTimer # NIL
		oTimer:DeActivate()
	EndIf
	
	aListBoxSD2 := {}
	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial('SD2')+SF2->(F2_DOC+F2_SERIE)))
	While SD2->(!Eof() .and. D2_FILIAL+D2_DOC+D2_SERIE == xFilial('SF2')+SF2->(F2_DOC+F2_SERIE))
		nPos := Ascan(aListBoxSD2,{|x| x[1] == SD2->D2_COD})
		If nPos == 0
			aadd(aListBoxSD2,{SD2->D2_COD,Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC"),SD2->D2_QUANT,0})
		Else
			aListBoxSD2[nPos,3] += SD2->D2_QUANT
		EndIf
		SD2->(DbSkip())
	EndDo
	
	CBL->(dbSetOrder(1))
	CBL->(DbSeek(xFilial('CBL')+SF2->(F2_DOC+F2_SERIE)))
	While CBL->(!Eof() .and. CBL_FILIAL+CBL_DOC+CBL_SERIE == xFilial('SF2')+SF2->(F2_DOC+F2_SERIE))
		nPos := Ascan(aListBoxSD2,{|x| x[1] == CBL->CBL_PROD})
		aListBoxSD2[nPos,4] += CBL->CBL_QTDEMB
		CBL->(DbSkip())
	EndDo
	
	If Empty( aListBoxSD2 )
		AAdd( aListBoxSD2, { CriaVar("CBL_PROD"),CriaVar("B1_DESC"),CriaVar("CBL_QTDEMB"),CriaVar("CBL_QTDEMB") } )
	EndIf
	
	aSort( aListBoxSD2, , , { |x,y| y[1] > x[1] } )
	
	oListBoxSD2:SetArray(aListBoxSD2)
	oListBoxSD2:bLine := { || { aListBoxSD2[oListBoxSD2:nAT,1], aListBoxSD2[oListBoxSD2:nAT,2], Transform(aListBoxSD2[oListBoxSD2:nAT,3],"@E 999,999,999.99"), Transform(aListBoxSD2[oListBoxSD2:nAT,4],"@E 999,999,999.99") } }
	oListBoxSD2:Refresh()
	
	If oTimer # NIL
		oTimer:Activate()
	EndIf
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuDetEti
Atualiza informacoes do listbox das etiquetas lidas (CBL)
   
@param		aListBoxDet -> array do listbox das etiquetas 
@param		oListDet -> objeto do listbox das etiquetas 
@param		cProduto -> codigo do produto selecionado
@param		oTimer   -> objeto timer do listbox das etiquetas 
@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function AtuDetEti(aListBoxDet,oListDet,cProduto,oTimer)
	
	If oTimer # NIL
		oTimer:DeActivate()
	EndIf
	
	aListBoxDet := {}
	CBL->(dbSetOrder(1))
	CBL->(DbSeek(xFilial('CBL')+CBK->(CBK_DOC+CBK_SERIE)))
	While CBL->(!Eof() .and. CBL_FILIAL+CBL_DOC+CBL_SERIE == xFilial('CBK')+CBK->(CBK_DOC+CBK_SERIE))
		If CBL->CBL_PROD == cProduto
			aadd(aListBoxDet,{CBL->CBL_CODETI,CBL->CBL_PROD,CBL->CBL_QTDEMB,""})
		Endif
		CBL->(DbSkip())
	EndDo
	
	If Empty( aListBoxDet )
		aadd(aListBoxDet,{CriaVar("CBL_CODETI"),CriaVar("CBL_PROD"),0,""})
	EndIf
	
	aSort( aListBoxDet, , , { |x,y| y[1] > x[1] } )
	
	oListDet:SetArray( aListBoxDet )
	oListDet:bLine := { || { aListBoxDet[oListDet:nAT,1], aListBoxDet[oListDet:nAT,2], Transform(aListBoxDet[oListDet:nAT,3],"@E 999,999,999.99"), aListBoxDet[oListDet:nAT,4] } }
	oListDet:Refresh()
	
	If oTimer # NIL
		oTimer:Activate()
	EndIf
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ACD001D
Analisa a cor a ser retornada para o browse
   
@param		1 - Processo Não Iniciado | 2 - Conferencia Iniciada | 3 - Conferencia Finalizada | 4 - Mercadoria Entregue
@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ACD001D(nTipo) 
	
	Local lRet := .f.   
	
	CBK->(DbSeek(xFilial('CBK')+SF2->(F2_DOC+F2_SERIE))) 
	
	If nTipo == 1 .and. (CBK->CBK_STATUS == "1" .or. CBK->(Eof())) 
		lRet := .t.
	ElseIf nTipo == 2 .and. CBK->CBK_STATUS == "2"
		lRet := .t.
	ElseIf nTipo == 3 .and. CBK->CBK_STATUS == "3"
		lRet := .t.
	ElseIf nTipo == 4 .and. CBK->CBK_STATUS == "4"
		lRet := .t.
	ElseIf nTipo == 5 .and. CBK->CBK_STATUS == "5"
		lRet := .t.
	ElseIf nTipo == 6 .and. CBK->CBK_STATUS == "6"	
		lRet := .t.
	ElseIf nTipo == 7 .and. CBK->CBK_STATUS == "7"	
		lRet := .t.
	Endif   
	   	
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} ACD001C
Legenda para as cores da mbrowse 
   
@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ACD001C()  
	
	Local aCorDesc  
	
	aCorDesc := {	{ "BR_VERDE",		"- Conferência Não Iniciada" 	},;  
					{ "BR_AMARELO",		"- Separação Iniciada" 	},; 
					{ "BR_AZUL",		"- Separação Finalizada" 	},; 
					{ "BR_LARANJA",		"- Expedição Iniciada" 	},;  
					{ "BR_PINK",		"- Expedição Finalizada" 	},; 
					{ "BR_VERMELHO",	"- Romaneio Finalizado" 	},; 
					{ "BR_PRETO",		"- Nota Fiscal Cancelada"  }}    
				
	BrwLegenda( "Legenda - Conferencia", "Status", aCorDesc ) 		
	
Return( .T. )


//-------------------------------------------------------------------
/*/{Protheus.doc} TimerBrw
Funcao que cria timer no mbrowse
     
@param		cMBrowse -> form em que sera criado o timer
@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fTimerBrw(oBrowse)
	
oBrowse:Refresh()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TmBrowse
Funcao de timer do mbrowse
     
@param		cMBrowse -> objeto mbrowse a dar refresh 
@param		oTimer   -> objeto timer 
@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fTmBrowse(oObjBrow,oTimer)

oTimer:Deactivate()
oObjBrow:Refresh()
oTimer:Activate() 

MsgAlert("fTmBrowse 2")

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ACD001B
Monta a tela para informar campos para a coleta
     
@return 	nil
@author 	Alessandro Smaha
@since 	 	30/01/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ACD001B()
    
	Local oButtonOk
	Local oCancelar
	Local oData
	Local oHora
	Static oDlg 
	
	cHoraCol := SUBSTR(Time(),1,2)+SUBSTR(Time(),4,2)
	dDataCol := Date()
	cNumeCol := Space(TAMSX3("CBK_NUMCOL")[1])
	
	DbSelectArea("CBK")
	CBK->(DbSetOrder(1)) // CBK_FILIAL+CBK_DOC+CBK_SERIE 
    CBK->(DbSeek(xFilial('CBK')+SF2->(F2_DOC+F2_SERIE)))

    If Found()
		If Empty(CBK->CBK_DATACL)		
			DEFINE MSDIALOG oDlg TITLE "Coleta" FROM 000, 000  TO 150, 230 COLORS 0, 16777215 PIXEL	
						
				@ 010, 012 SAY oNume PROMPT "Número:" 	SIZE 023, 007 OF oDlg COLORS 0, 16777215 PIXEL
				@ 025, 012 SAY oData PROMPT "Data:" 	SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    			@ 040, 012 SAY oHora PROMPT "Hora:" 	SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL				
				@ 008, 075 MSGET cNumeCol SIZE 015, 010 					   OF oDlg COLORS 0, 16777215 PIXEL	
			    @ 023, 047 MSGET dDataCol SIZE 060, 010 VALID !EMPTY(dDataCol) OF oDlg COLORS 0, 16777215 PIXEL
			    @ 038, 082 MSGET cHoraCol SIZE 010, 010 VALID !EMPTY(cHoraCol) OF oDlg COLORS 0, 16777215 PIXEL PICTURE "@R 99:99"			    
			    @ 057, 015 BUTTON oButtonOk PROMPT "Ok" 		SIZE 037, 012	ACTION (fAtualiza(), oDlg:End()) OF oDlg PIXEL
			    @ 057, 065 BUTTON oCancelar PROMPT "Cancelar" 	SIZE 037, 012 	ACTION oDlg:End()	OF oDlg PIXEL	 
			    				
			ACTIVATE MSDIALOG oDlg CENTERED		
		Else
		    If MsgYesNo("Mercadoria Entregue!"+Chr(10)+Chr(13)+;
		    			"Coleta: "+ALLTRIM(CBK->CBK_NUMCOL)+;
		    			" Data: "+DtoC(CBK->CBK_DATACL)+;  
		    			" Hora: "+SUBSTR(CBK->CBK_HORACL,1,2)+":"+SUBSTR(CBK->CBK_HORACL,3,2)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
		    			"Retornar Mercadoria?","Atenção")
				RecLock("CBK",.F.)  // Alteração
					CBK->CBK_DATACL	:= CtoD("  /  /  ")
					CBK->CBK_HORACL	:= ""  
					CBK->CBK_NUMCOL := ""
				CBK->(MsUnLock())		
		    EndIf
		EndIf
	EndIf

Return  
