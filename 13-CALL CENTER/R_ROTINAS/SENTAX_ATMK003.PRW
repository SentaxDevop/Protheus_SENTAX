#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK003
Rotina para exibir o historico consolidado

@sample		U_ATMK003()

@author		Alessandro Smaha
@since		05/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ATMK003()

	Processa( { || fProcessa() },"Aguarde... ", "Verificando Histórico Consolidado",.T. )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Rotina para montar a tela de histórico

@sample		fProcessa()

@author		Alessandro Smaha
@since		05/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fProcessa()

Local aAreaSA1	:= SA1->(GetArea())
Local aAreaDA1  := DA1->(GetArea())
Local aAreaSU7  := SU7->(GetArea())
Local aTFolder	:= {} 
Local aTFldEx	:= {}
Local aHead1a1	:= {}
Local aHead2a1	:= {}
Local aCols2a1	:= {} 
Local aHead1a2	:= {}
Local aCols1a2	:= {}  
Local aCols2a2 	:= {}
Local aHead1a3	:= {}
Local aCols1a3	:= {} 
Local aCols2a3 	:= {} 
Local aHead1a4  := {}
Local aCols1a4 	:= {} 
Local aCols2a4 	:= {}
Local aCols3a4 	:= {}  
Local aHead1a5	:= {}
Local aCols1a5	:= {}
Local aCols2a5	:= {}  
Local aCols1a6	:= {}
Local aCols2a6	:= {}
Local aCols1a7	:= {}   
Local aCols1a8	:= {}
Local aCols2a8	:= {}
Local aCols1a9	:= {}  
Local aCfops	:= {}
Local aComod	:= {} 
Local aCposAlt	:= {} 
Local aSize    	:= MsAdvSize(.T.)
Local nOpcA		:= 0
Local nK		:= 0 
Local nL 		:= 0 
Local nPosx		:= 0
Local nPosy		:= 0
Local nComp		:= 0
Local nAltu		:= 0  
Local n1de2		:= 0
Local n1de3		:= 0
Local n1de4		:= 0    
Local nLinX		:= 0
Local nLinY		:= 0
Local nEspaco	:= 20    
Local nPosXQtd	:= 0
Local nPosXTip 	:= 0			
Local nPosXPro	:= 0
Local nPosXPre 	:= 0
Local nPosDel	:= 0  
Local _nSaldoB2	:= 0     
Local nNumAba	:= 0
Local nItemaCols 	:= 0 
Local nPosIte 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_ITEM" })
Local nPosNum 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_NUM" })
Local nPosPro 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_PRODUTO" })  
Local nPosDes 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_DESCRI" }) 
Local nPosAmz	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_LOCAL" }) 
Local nPosQtd 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_QUANT" })
Local nPosVun 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VRUNIT" })
Local nPosTot 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VLRITEM" })
Local nPosOpe 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_OPER" })
Local nPosTes 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_TES" })  
Local nPosSld 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_XSB2" })  
Local nPosVen	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_XPRCVEN" })  
Local nPosxOp	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_XOPER" }) 
Local cCodCli 	:= ""
Local cLojCli 	:= ""
Local cParOper	:= ""  
Local cAmzProd	:= ""
Local cTesAten	:= ""
Local cEstoque	:= ""
Local cMultObs	:= ""
Local cMultCan	:= ""  
Local cMObs5	:= ""
Local cMCan5	:= ""
Local cMEnc5	:= ""
Local cMObs7	:= ""
Local cMCan7	:= ""
Local cMEnc7	:= ""
Local cPOperNm	:= GetMV("ST_OPNMTMK",,"01")
Local cPOperCm	:= GetMV("ST_OPCMTMK",,"02") 
Local lVisTelec	:= .F.

Local lCobran 	:= .F.
Local lMarket 	:= .F.
Local lVendas 	:= .F. 
Local lRetOK 	:= .T.

Local oBmp01, oBmp02, oBmp03, oBmp04, oBmp05, oBmp06, oBmp07, oBmp08, oBmp09, oBmp10
Local oBmp11, oBmp12, oBmp13, oBmp14, oBmp15, oBmp16, oBmp17, oBmp18, oBmp19, oBmp20
Local oBmp21, oBmp22, oBmp23, oBmp24, oBmp25, oBmp26, oBmp27, oBmp28, oBmp29, oBmp30
Local oBmp31, oBmp32, oBmp33, oBmp34, oBmp35, oBmp36, oBmp37, oBmp38, oBmp39, oBmp40  
Local oBmp41, oBmp42, oBmp43, oBmp44, oBmp45, oBmp46, oBmp47, oBmp48, oBmp49 

Local oSLeg01, oSLeg02, oSLeg03, oSLeg04, oSLeg05, oSLeg06, oSLeg07, oSLeg08, oSLeg09, oSLeg10
Local oSLeg11, oSLeg12, oSLeg13, oSLeg14, oSLeg15, oSLeg16, oSLeg17, oSLeg18, oSLeg19, oSLeg20
Local oSLeg21, oSLeg22, oSLeg23, oSLeg24, oSLeg25, oSLeg26, oSLeg27, oSLeg28, oSLeg29, oSLeg30
Local oSLeg31, oSLeg32, oSLeg33, oSLeg34, oSLeg35, oSLeg36, oSLeg37, oSLeg38, oSLeg39, oSLeg40
Local oSLeg41, oSLeg42, oSLeg43, oSLeg44, oSLeg45, oSLeg46, oSLeg47, oSLeg48, oSLeg49

Local oDlg, oTFolder, oMultObs, oMultCan, oMObs5, oMCan5, oMEnc5, oMObs7, oMCan7, oMEnc7
Local oAb1Top, oAb1Bot, oAb2Top, oAb2Med, oAb2Bot, oAb3Top, oAb3Bot, oAb4Top, oAb4Med, oAb4Bot, oAb5Top 
Local oAb5Med, oAb5Bot, oAb6Top, oAb6Bot, oAb7Top, oAb7Me1, oAb7Me2, oAb7Bot, oAb8Top, oAb8Bot

Private aCols1a1	:= {}
Private aHead2a2 	:= {}  
Private aHead2a3 	:= {}
Private aHead2a4 	:= {}
Private aHead3a4 	:= {}
Private aHead2a5	:= {} 
Private aHead1a6	:= {}
Private aHead2a6	:= {} 
Private aHead1a7 	:= {}      
Private aHead2a7  	:= {}
Private aCols2a7	:= {} 
Private aHead1a8  	:= {}   
Private aHead2a8	:= {}
Private aHead1a9  	:= {}   
Private aHead2a9	:= {}
Private aHead3a9	:= {}
Private aCols2a9	:= {} 
Private aCols3a9	:= {} 
Private oGrid1a1, oGrid1a2, oGrid1a3, oGrid1a4, oGrid1a5, oGrid1a6, oGrid1a7, oGrid1a8, oGrid1a9
Private cPerg 		:= "ATMK003"  
Private cParCfop	:= GetMV("ST_TMKCFVE",,"")
Private cParComo	:= GetMV("ST_TMKCFCO",,"")
Private aRdpTlc := Array(12,2) 
Private cCodCont	:= ""  

DbSelectArea("AB9")
AB9->(DbSetOrder(1)) // AB9_FILIAL+AB9_NUMOS+AB9_CODTEC+AB9_SEQ

DbSelectArea("SU7")
SU7->(DbSetOrder(4)) // U7_FILIAL+U7_CODUSU
If SU7->(DbSeek(xFilial("SU7")+RetCodUsr()))  
	lVisTelec := IIF(SU7->U7_XVISCOB == "S",.T.,.F.)	
EndIf

If !Empty(cParCfop)
	aCfops := Separa(cParCfop,';',.F.)
	cParCfop := ""
	For nK := 1 to Len(aCfops)
		cParCfop += IIF(Empty(cParCfop),"","','")+aCfops[nK]
	Next nK
EndIf

If !Empty(cParComo)
	aComod := Separa(cParComo,';',.F.)
	cParComo := ""
	For nK := 1 to Len(aComod)
		cParComo += IIF(Empty(cParComo),"","','")+aComod[nK]
	Next nK
EndIf

ProcRegua(0)
IncProc( "Carregando itens")

aAdd(aTFolder,'Periodicidade de Compra') // Cria a Folder
aAdd(aTFolder,'Televendas')
aAdd(aTFolder,'Liberações')
aAdd(aTFolder,'Logística')
aAdd(aTFolder,'SAC / Telemarketing')
aAdd(aTFolder,'Devolução')                           
If lVisTelec
	aAdd(aTFolder,'Telecobrança')
EndIf
aAdd(aTFolder,'Chamado Técnico') 
aAdd(aTFolder,'Ordem de Serviço') 
  
aAdd(aTFldEx,'Encargos Atuais') 
aAdd(aTFldEx,'Saldos Atuais') 

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA

If TkGetTipoAte() == "1" .AND. M->UC_ENTIDAD == "SA1"					// Telemarketing
	cCodCli := Substr(M->UC_CHAVE,1,TamSX3("A1_COD")[1])
	cLojCli := Substr(M->UC_CHAVE,TamSX3("A1_COD")[1]+1,TamSX3("A1_LOJA")[1]) 
	cCodCont := M->UC_CODCONT
	lMarket := .T.
ElseIf TkGetTipoAte() $ "2" .AND. ! M->UA_PROSPEC .AND. ! lProspect	// Televendas/Todos/Tmk e Tlv
	cCodCli := M->UA_CLIENTE
	cLojCli := M->UA_LOJA
	lVendas := .T.          
ElseIf TkGetTipoAte() == "3"   											// Telecobrança
	cCodCli := M->ACF_CLIENT
	cLojCli := M->ACF_LOJA
	lCobran := .T.  
ElseIf TkGetTipoAte() $ "45" .AND. ! lProspect	// Televendas/Todos/Tmk e Tlv
	If nFolder == 1 .AND. M->UC_ENTIDAD == "SA1" 
	 	cCodCli := Substr(M->UC_CHAVE,1,TamSX3("A1_COD")[1])
		cLojCli := Substr(M->UC_CHAVE,TamSX3("A1_COD")[1]+1,TamSX3("A1_LOJA")[1])  
		cCodCont := M->UC_CODCONT
		lMarket := .T.	
	ElseIf nFolder == 2 .AND. ! M->UA_PROSPEC
		cCodCli := M->UA_CLIENTE
		cLojCli := M->UA_LOJA
		lVendas := .T. 
	ElseIf nFolder == 3
		cCodCli := M->ACF_CLIENT
		cLojCli := M->ACF_LOJA
		lCobran := .T. 
	EndIf
Else
	MsgAlert("A rotina de Histórico Consolidado somente será executada para entidade CLIENTE!","Atenção")
	lRetOK := .F.
EndIf

If Empty(cCodCli) .OR. Empty(cLojCli)
	MsgAlert("Informar Código do Cliente e Loja para Consulta!","Atenção")
	lRetOK := .F.
ElseIf !SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
	MsgAlert("Código do Cliente e Loja não Encontrado!","Atenção")
	lRetOK := .F.
EndIf

If lRetOK
	fAjustaSX1()
	If !Pergunte(cPerg,.T.)
		lRetOK := .F.
	EndIf
EndIf

If lVendas     
	aAdd(aCposAlt,"QUANT")
EndIf

If lRetOK
	
	fAtuHeader( @aHead1a1, "1A1")
	fAtuHeader( @aHead2a1, "2A1")
	fAtuHeader( @aHead1a2, "1A2")  
	fAtuHeader( @aHead2a2, "2A2")
	fAtuHeader( @aHead1a3, "1A3") 
	fAtuHeader( @aHead2a3, "2A3") 	
	fAtuHeader( @aHead1a4, "1A4") 
	fAtuHeader( @aHead2a4, "2A4")
	fAtuHeader( @aHead3a4, "3A4")   
	fAtuHeader( @aHead1a5, "1A5")
	fAtuHeader( @aHead2a5, "2A5")
	fAtuHeader( @aHead1a6, "1A6")	 
	fAtuHeader( @aHead2a6, "2A6") 
	fAtuHeader( @aHead1a7, "1A7")	 
	fAtuHeader( @aHead2a7, "2A7")
	fAtuHeader( @aHead1a8, "1A8")
	fAtuHeader( @aHead2a8, "2A8") 
	fAtuHeader( @aHead1a9, "1A9")
	fAtuHeader( @aHead2a9, "2A9")
	fAtuHeader( @aHead3a9, "3A9")

	fAtuCols( cCodCli, cLojCli, @aCols1a1, Len(aHead1a1)+1, "1A1")
	fAtuCols( cCodCli, cLojCli, @aCols2a1, Len(aHead2a1)+1, "2A1")
	fAtuCols( cCodCli, cLojCli, @aCols1a2, Len(aHead1a2)+1, "1A2")	
	fAtuCols( cCodCli, cLojCli, @aCols1a3, Len(aHead1a3)+1, "1A3")
	fAtuCols( cCodCli, cLojCli, @aCols2a3, Len(aHead2a3)+1, "2A3")	
	fAtuCols( cCodCli, cLojCli, @aCols1a4, Len(aHead1a4)+1, "1A4")  
	fAtuCols( cCodCli, cLojCli, @aCols1a5, Len(aHead1a5)+1, "1A5") 
	fAtuCols( cCodCli, cLojCli, @aCols1a6, Len(aHead1a6)+1, "1A6")
	fAtuCols( cCodCli, cLojCli, @aCols1a7, Len(aHead1a7)+1, "1A7")  
	fAtuCols( cCodCli, cLojCli, @aCols1a8, Len(aHead1a8)+1, "1A8") 
	fAtuCols( cCodCli, cLojCli, @aCols1a9, Len(aHead1a9)+1, "1A9") 

	DEFINE MSDIALOG oDlg TITLE "Histórico Consolidado Cliente" FROM 0, 0 TO aSize[6], aSize[5] PIXEL

	nPosx	:= Int(aSize[1]) + 02  		//posicao em x
	nPosy	:= Int(aSize[2]) + 02  		//posicao em y
	nComp	:= Int(aSize[3])    		//largura
	nAltu	:= Int(aSize[4]) - 05	   	//altura
	
	n1de2	:= Int(nAltu/2) - nEspaco
	n1de3	:= Int(nAltu/3)
	n1de4	:= Int(nAltu/4) + 20

	// Cria a Folder
	oTFolder := TFolder():New( nPosy, nPosx, aTFolder,, oDlg,,,, .T.,, nComp, nAltu )
	 
	nNumAba++
	
	//-----------------------------------------------------------
	// **********************************************************
	//  ABA 1 - Periodicidade de Compra
	// **********************************************************
	//-----------------------------------------------------------
	
	// PAINEL - SUPERIOR
	oAb1Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de2)
	
	@ 005, 000 GROUP oGrpPer TO n1de2, nComp PROMPT "Periodicidade de Compra: "+Alltrim(SA1->A1_NOME) OF oAb1Top COLOR CLR_BLUE PIXEL
	
	oGrid1a1:= MsNewGetDados():New(015,000,n1de2,nComp-1,GD_UPDATE, "AllwaysTrue","AllwaysTrue","",aCposAlt,0,Len(aCols1a1),"U_ATMK003V()",,,;
		oAb1Top, aHead1a1, aCols1a1) 
	
	oGrid1a1:oBrowse:lUseDefaultColors := .F.
	oGrid1a1:oBrowse:SetBlkBackColor( { ||  fGetColor(oGrid1a1:aCols,oGrid1a1:nAt,oGrid1a1:aHeader) } )

	@ n1de2+2, nComp-095 BUTTON oBFila1 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fFiltraCols(Len(aHead1a1)+1,"1A1") PIXEL
	@ n1de2+2, nComp-050 BUTTON oBPesa1 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a1) PIXEL
	
	@  n1de2+2, 010 BITMAP oBmp01 RESNAME "BR_VERDE" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  n1de2+2, 120 BITMAP oBmp02 RESNAME "BR_AMARELO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  n1de2+2, 205 BITMAP oBmp03 RESNAME "BR_VERMELHO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  n1de2+2, 290 BITMAP oBmp04 RESNAME "BR_PINK" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	
	@  n1de2+2, 020 SAY oSLeg01 PROMPT "Última compra dentro período médio" 		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  n1de2+2, 130 SAY oSLeg02 PROMPT "Ultrapassado tempo médio" 				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  n1de2+2, 215 SAY oSLeg03 PROMPT "Ultrapassa tempo máximo" 		   		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  n1de2+2, 300 SAY oSLeg04 PROMPT "Periodicidade dentro do previsto" 		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	
	nLinY := n1de2 + 15
	
	// PAINEL - INFERIOR
	oAb1Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de2+10)
	
	@ 005, 000 GROUP oGrpSug TO n1de2+10, nComp PROMPT "Sugestão de Segmento" OF oAb1Bot COLOR CLR_BLUE PIXEL
	
	oGrid1a2 := MsNewGetDados():New(015,000,n1de2+10,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb1Bot,aHead2a1, aCols2a1,{|| })
	
	nNumAba++
	
	//-----------------------------------------------------------
	// **********************************************************
	//  ABA 2 - Televendas
	// **********************************************************
	//-----------------------------------------------------------
	
	// PAINEL - SUPERIOR
	oAb2Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3-15)
	
	@ 005, 000 GROUP oGrpLig TO n1de3-15, nComp PROMPT "Últimas Ligações: "+Alltrim(SA1->A1_NOME) OF oAb2Top COLOR CLR_BLUE PIXEL
	
	oGrid1a2:= MsNewGetDados():New(015,000,n1de3-15,nComp-1,GD_UPDATE, "AllwaysTrue","AllwaysTrue","",aCposAlt,0,Len(aCols1a2),"AllwaysTrue",,,;
	oAb2Top, aHead1a2, aCols1a2) 
	
	oGrid1a2:oBrowse:bChange:= {|| fAtuGrd2a2( @aCols2a2, @oGrid2a2, @cMultObs, @oMultObs, @cMultCan, @oMultCan ) }
	oGrid1a2:oBrowse:Refresh()
	oGrid1a2:oBrowse:SetFocus(.T.) 
	
	@ n1de3-12, nComp-095 BUTTON oBFila2 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION (fFiltraCols(Len(aHead1a2)+1,"1A2"),;
			fAtuGrd2a2( @aCols2a2, @oGrid2a2, @cMultObs, @oMultObs, @cMultCan, @oMultCan )) PIXEL
	@ n1de3-12, nComp-050 BUTTON oBPesa2 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a2) PIXEL
		      
	nLinY := n1de3 - 10
   
 	@  nLinY, 010 BITMAP oBmp05 RESNAME "BR_VERMELHO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL 
 	@  nLinY, 055 BITMAP oBmp06 RESNAME "BR_AZUL" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
 	@  nLinY, 100 BITMAP oBmp07 RESNAME "BR_AMARELO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  nLinY, 170 BITMAP oBmp08 RESNAME "BR_CANCEL" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  nLinY, 260 BITMAP oBmp09 RESNAME "PMSEDT4"  		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  nLinY, 325 BITMAP oBmp10 RESNAME "PMSEDT1"   	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL 	
	
	@  nLinY, 020 SAY oSLeg05 PROMPT "NF.Emitida"							SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 065 SAY oSLeg06 PROMPT "Orçamento" 		   					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 110 SAY oSLeg07 PROMPT "Pedido Apto a Faturar" 				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 180 SAY oSLeg08 PROMPT "Rejeitado Liberação Credito"		 	SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 270 SAY oSLeg09 PROMPT "Bloqueio de Estoque"		 		 	SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 335 SAY oSLeg10 PROMPT "Bloqueio Regra"	 					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	
	nLinY += 10
	
	@  nLinY, 010 BITMAP oBmp11 RESNAME "BR_MARRON" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  nLinY, 055 BITMAP oBmp12 RESNAME "BR_PRETO" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL 
	@  nLinY, 100 BITMAP oBmp13 RESNAME "BR_PINK"  		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 150 BITMAP oBmp14 RESNAME "BR_VERDE" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	 	
	@  nLinY, 210 BITMAP oBmp15 RESNAME "PMSTASK1" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  nLinY, 270 BITMAP oBmp16 RESNAME "PMSEDT3"  		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  nLinY, 325 BITMAP oBmp17 RESNAME "PMSEDT2"   	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
			 
	@  nLinY, 020 SAY oSLeg11 PROMPT "Atendimento" 			  				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 065 SAY oSLeg12 PROMPT "Cancelado"			 				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL  
	@  nLinY, 110 SAY oSLeg13 PROMPT "Bloqueio TMS"			  				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 160 SAY oSLeg14 PROMPT "Pedido em aberto"    					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL  
	@  nLinY, 220 SAY oSLeg15 PROMPT "Bloqueio Crédito"	   					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 280 SAY oSLeg16 PROMPT "Bloqueio WMS"			   				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 335 SAY oSLeg17 PROMPT "Bloqueio Verba" 						SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	
	nLinY += 10 
	                          	
	// PAINEL - MEIO
	oAb2Med := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3)
	
	@ 005, 000 GROUP oGrpIte TO n1de3, nComp PROMPT "Itens" OF oAb2Med COLOR CLR_BLUE PIXEL
	
	oGrid2a2 := MsNewGetDados():New(015,000,n1de3,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb2Med,aHead2a2, aCols2a2,{|| })
	
	nLinY += n1de3
	nLinX := 0
	
	nComp1d3 := (nComp / 3)
	
	cMultObs := ""
	
	// PAINEL - INFERIOR ESQUERDO
	oAb2Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3-25)
	
	@ 005, nLinX GROUP oGrpObs TO n1de3 - 25, nComp1d3 PROMPT "Observação" OF oAb2Bot COLOR CLR_BLUE PIXEL  	
	@ 015, nLinX+5 GET oMultObs VAR cMultObs OF oGrpObs MULTILINE SIZE nComp1d3-10, n1de3-45 COLORS 0, 16777215 HSCROLL PIXEL READONLY
	
	nLinX += nComp1d3 + 15 
	
	cMultCan := ""
		
	// PAINEL - INFERIOR DIREITO
	@ 005, nLinX GROUP oGrpcan TO n1de3 - 25, nComp1d3 + nLinX PROMPT "Motivo de Cancelamento" OF oAb2Bot COLOR CLR_BLUE PIXEL
	@ 015, nLinX+5 GET oMultCan VAR cMultCan OF oGrpObs MULTILINE SIZE nComp1d3-10, n1de3-45 COLORS 0, 16777215 HSCROLL PIXEL READONLY  
	
	nNumAba++
	   
 	//-----------------------------------------------------------
	// **********************************************************
	//  ABA 3 - Liberações
	// **********************************************************
	//-----------------------------------------------------------
	
	// PAINEL - SUPERIOR               
	oAb3Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de2-15)
	       
	@ 005, 000 GROUP oGrpPed TO n1de2-15, nComp PROMPT "Últimos Pedidos: "+Alltrim(SA1->A1_NOME) OF oAb3Top COLOR CLR_BLUE PIXEL
	
	oGrid1a3:= MsNewGetDados():New(015,000,n1de2-15,nComp-1,GD_UPDATE, "AllwaysTrue","AllwaysTrue","",aCposAlt,0,Len(aCols1a2),"AllwaysTrue",,,;
					oAb3Top, aHead1a3, aCols1a3) 
	
	oGrid1a3:oBrowse:bChange:= {|| fAtuGrd2a3( @aCols2a3, @oGrid2a3 ) }
	oGrid1a3:oBrowse:Refresh()
	oGrid1a3:oBrowse:SetFocus(.T.)
	
	nLinY := n1de2-12 
	
	@ n1de2-12, nComp-095 BUTTON oBFila3 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION (fFiltraCols(Len(aHead1a3)+1,"1A3"),;
			fAtuGrd2a3( @aCols2a3, @oGrid2a3 )) PIXEL
	@ n1de2-12, nComp-050 BUTTON oBPesa3 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a3) PIXEL
	     
	@  nLinY, 010 BITMAP oBmp18 RESNAME "PMSEDT1" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 070 BITMAP oBmp19 RESNAME "PMSTASK1" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 130 BITMAP oBmp20 RESNAME "PMSEDT4" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 190 BITMAP oBmp21 RESNAME "BR_VERDE"	 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 245 BITMAP oBmp22 RESNAME "BR_VERMELHO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	 
	@  nLinY, 020 SAY oSLeg18 PROMPT "Bloqueio Regra" 	SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 080 SAY oSLeg19 PROMPT "Bloqueio Crédito"	SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 140 SAY oSLeg20 PROMPT "Bloqueio Estoque"	SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL	
	@  nLinY, 200 SAY oSLeg21 PROMPT "Liberado Total"	SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL  
	@  nLinY, 255 SAY oSLeg22 PROMPT "Faturado"			SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
 	                        
	nLinY := n1de2
	
	// PAINEL - INFERIOR
	oAb3Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de2+25)
	
	@ 005, 000 GROUP oGrpIte TO n1de2+25, nComp PROMPT "Itens" OF oAb3Bot COLOR CLR_BLUE PIXEL
	
	oGrid2a3 := MsNewGetDados():New(015,000,n1de2+25,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb3Bot,aHead2a3, aCols2a3,{|| })
   
	nNumAba++
		            
 	//-----------------------------------------------------------
	// **********************************************************
	//  ABA 4 - Logistica
	// **********************************************************
	//-----------------------------------------------------------
	
	// PAINEL - SUPERIOR
	oAb4Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3-15)
	
	@ 005, 000 GROUP oGrpNfs TO n1de3-15, nComp PROMPT "Últimas Notas Fiscais: "+Alltrim(SA1->A1_NOME) OF oAb4Top COLOR CLR_BLUE PIXEL
	
	oGrid1a4:= MsNewGetDados():New(015,000,n1de3-15,nComp-1,GD_UPDATE, "AllwaysTrue","AllwaysTrue","",,0,Len(aCols1a4),"AllwaysTrue",,,;
	oAb4Top, aHead1a4, aCols1a4) 
	  
	oGrid1a4:oBrowse:bChange:= {|| fAtuGrd2a4( @aCols2a4, @oGrid2a4, @aCols3a4, @oGrid3a4, aHead1a4, cCodCli, cLojCli ) }
	oGrid1a4:oBrowse:Refresh()
	oGrid1a4:oBrowse:SetFocus(.T.) 
	
	@ n1de3-12, nComp-095 BUTTON oBFila4 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION (fFiltraCols(Len(aHead1a4)+1,"1A4"),;
			fAtuGrd2a4( @aCols2a4, @oGrid2a4, @aCols3a4, @oGrid3a4, aHead1a4, cCodCli, cLojCli )) PIXEL
	@ n1de3-12, nComp-050 BUTTON oBPesa4 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a4) PIXEL
		      
	nLinY := n1de3 
		
	@  nLinY-10, 010 BITMAP oBmp23 RESNAME "BR_VERDE" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY-10, 100 BITMAP oBmp24 RESNAME "BR_PINK" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY-10, 200 BITMAP oBmp25 RESNAME "BR_LARANJA" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY-10, 260 BITMAP oBmp26 RESNAME "BR_VERMELHO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY-10, 300 BITMAP oBmp27 RESNAME "BR_PRETO" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL 	
	 
	@  nLinY-10, 020 SAY oSLeg23 PROMPT "Em Aberto - Inclusão Manual"		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY-10, 110 SAY oSLeg24 PROMPT "Em Aberto - Inclusão Automática" 	SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY-10, 210 SAY oSLeg25 PROMPT "Em Manutenção" 					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL	
	@  nLinY-10, 270 SAY oSLeg26 PROMPT "Baixado"					  		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL	
	@  nLinY-10, 310 SAY oSLeg27 PROMPT "Baixa Cancelada"			 		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	
	// PAINEL - MEIO
	oAb4Med := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3)
	
	@ 005, 000 GROUP oGrpRom TO n1de3, nComp PROMPT "Últimos Romaneios" OF oAb4Med COLOR CLR_BLUE PIXEL
	
	oGrid2a4 := MsNewGetDados():New(015,000,n1de3,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb4Med,aHead2a4, aCols2a4,{|| })
	
	nLinY += n1de3
	nLinX := 0
		
	// PAINEL - INFERIOR
	oAb4Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3-15)
	
	@ 005, 000 GROUP oGrpPRm TO n1de3-15, nComp PROMPT "Produtos Romaneiados" OF oAb4Bot COLOR CLR_BLUE PIXEL
	
	oGrid3a4 := MsNewGetDados():New(015,000,n1de3-15,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb4Bot,aHead3a4, aCols3a4,{|| })
   
	nNumAba++
		 			        
	//-----------------------------------------------------------
	// **********************************************************
	//  ABA 5 - SAC/Telemarketing
	// **********************************************************
	//-----------------------------------------------------------
	
	// PAINEL - SUPERIOR        
	
	oAb5Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3-15)
	
	@ 005, 000 GROUP oGrpSac TO n1de3-15, nComp PROMPT "Últimas Ligações: "+Alltrim(SA1->A1_NOME) OF oAb5Top COLOR CLR_BLUE PIXEL
	
	oGrid1a5:= MsNewGetDados():New(015,000,n1de3-15,nComp-1,GD_UPDATE, "AllwaysTrue","AllwaysTrue","",aCposAlt,0,Len(aCols1a5),"AllwaysTrue",,,;
				oAb5Top, aHead1a5, aCols1a5) 
	               
	oGrid1a5:oBrowse:bChange:= {|| fAtuGrd2a5( @aCols2a5, @oGrid2a5, @cMObs5, @oMObs5, @cMCan5, @oMCan5, @cMEnc5, @oMEnc5 ) }
	oGrid1a5:oBrowse:Refresh()
	oGrid1a5:oBrowse:SetFocus(.T.) 
	
	@ n1de3-12, nComp-095 BUTTON oBFila5 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION (fFiltraCols(Len(aHead1a5)+1,"1A5"),;
			fAtuGrd2a5( @aCols2a5, @oGrid2a5, @cMObs5, @oMObs5, @cMCan5, @oMCan5, @cMEnc5, @oMEnc5 )) PIXEL
	@ n1de3-12, nComp-050 BUTTON oBPesa5 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a5) PIXEL
	
	nLinY := n1de3 - 10	        

	@  nLinY, 010 BITMAP oBmp28 RESNAME "BR_AZUL" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 060 BITMAP oBmp29 RESNAME "BR_VERMELHO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 110 BITMAP oBmp30 RESNAME "BR_VERDE" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 160 BITMAP oBmp31 RESNAME "BR_PRETO"	 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	@  nLinY, 210 BITMAP oBmp32 RESNAME "BR_MARRON"		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL 	
	@  nLinY, 270 BITMAP oBmp33 RESNAME "BR_LARANJA"	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	 
	@  nLinY, 020 SAY oSLeg28 PROMPT "Planejada" 			  				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 070 SAY oSLeg29 PROMPT "Pendente" 		   					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 120 SAY oSLeg30 PROMPT "Encerrada" 			   				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL	
	@  nLinY, 170 SAY oSLeg31 PROMPT "Cancelada"							SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL	
	@  nLinY, 220 SAY oSLeg32 PROMPT "Pend. com NFC"    					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 280 SAY oSLeg33 PROMPT "Pend. NFC Baixada" 					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	          
	nLinY := n1de3
	
	// PAINEL - MEIO
	oAb5Med := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3)
	
	@ 005, 000 GROUP oGrpISc TO n1de3, nComp PROMPT "Itens" OF oAb5Med COLOR CLR_BLUE PIXEL
	
	oGrid2a5 := MsNewGetDados():New(015,000,n1de3,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb5Med,aHead2a5, aCols2a5,{|| })
	 
	nLinY += n1de3
	nLinX := 0
	
	nComp1d4 := (nComp / 4)
	  
	cMObs := ""   
	cMCan := ""
	cMEnc := ""
	      
	// PAINEL - INFERIOR ESQUERDO
	oAb5Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3-15)
	
	@ 005, nLinX GROUP oGrpObs5 TO n1de3 - 15, nComp1d4 PROMPT "Observação" OF oAb5Bot COLOR CLR_BLUE PIXEL  	
	@ 015, nLinX+5 GET oMObs5 VAR cMObs5 OF oGrpObs5 MULTILINE SIZE nComp1d4-10, n1de3-35 COLORS 0, 16777215 HSCROLL PIXEL READONLY
	
	nLinX += nComp1d4 + 15
	      
	// PAINEL - INFERIOR MEIO
	@ 005, nLinX GROUP oGrpEnc5 TO n1de3 - 15, nComp1d4 + nLinX PROMPT "Motivo do Encerramento" OF oAb5Bot COLOR CLR_BLUE PIXEL  	
	@ 015, nLinX+5 GET oMEnc5 VAR cMEnc5 OF oGrpEnc5 MULTILINE SIZE nComp1d4-10, n1de3-35 COLORS 0, 16777215 HSCROLL PIXEL READONLY
	
	nLinX += nComp1d4 + 15 
		
	// PAINEL - INFERIOR DIREITO
	@ 005, nLinX GROUP oGrpCan5 TO n1de3 - 15, nComp1d4 + nLinX PROMPT "Motivo do Cancelamento" OF oAb5Bot COLOR CLR_BLUE PIXEL
	@ 015, nLinX+5 GET oMCan5 VAR cMCan5 OF oGrpCan5 MULTILINE SIZE nComp1d4-10, n1de3-35 COLORS 0, 16777215 HSCROLL PIXEL READONLY   
     
	nNumAba++

 	//-----------------------------------------------------------
	// **********************************************************
	//  ABA 6 - Devolução
	// **********************************************************
	//-----------------------------------------------------------
	
	// PAINEL - SUPERIOR               
	oAb6Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de2-15)
	       
	@ 005, 000 GROUP oGrpDev TO n1de2-15, nComp PROMPT "Últimas Devoluções: "+Alltrim(SA1->A1_NOME) OF oAb6Top COLOR CLR_BLUE PIXEL
	
	oGrid1a6:= MsNewGetDados():New(015,000,n1de2-15,nComp-1,GD_UPDATE, "AllwaysTrue","AllwaysTrue","",aCposAlt,0,Len(aCols1a6),"AllwaysTrue",,,;
					oAb6Top, aHead1a6, aCols1a6) 
	
	oGrid1a6:oBrowse:bChange:= {|| fAtuGrd2a6( @aCols2a6, @oGrid2a6, cCodCli, cLojCli ) }
	oGrid1a6:oBrowse:Refresh()
	oGrid1a6:oBrowse:SetFocus(.T.)
	 	
	@ n1de2-12, nComp-095 BUTTON oBFila6 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION (fFiltraCols(Len(aHead1a6)+1,"1A6"),;
			fAtuGrd2a6( @aCols2a6, @oGrid2a6, cCodCli, cLojCli )) PIXEL
	@ n1de2-12, nComp-050 BUTTON oBPesa6 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a6) PIXEL
		      	          
	nLinY := n1de2
	
	// PAINEL - INFERIOR
	oAb6Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de2+25)
	
	@ 005, 000 GROUP oGrpIDv TO n1de2+25, nComp PROMPT "Itens" OF oAb6Bot COLOR CLR_BLUE PIXEL
	
	oGrid2a6 := MsNewGetDados():New(015,000,n1de2+25,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb6Bot,aHead2a6, aCols2a6,{|| })
	       
	If lVisTelec
	
		nNumAba++
		                
	 	//-----------------------------------------------------------
		// **********************************************************
		//  ABA 7 - Telecobrança
		// **********************************************************
		//-----------------------------------------------------------
		     
		nL := 20
		
		// PAINEL - SUPERIOR               
		oAb7Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de4-15)
		       
		@ 005, 000 GROUP oGrpCob TO n1de4-15, nComp PROMPT "Últimas Ligações: "+Alltrim(SA1->A1_NOME) OF oAb7Top COLOR CLR_BLUE PIXEL
		
		oGrid1a7:= MsNewGetDados():New(015,000,n1de4-15,nComp-1,, "AllwaysTrue","AllwaysTrue","",,0,Len(aCols1a7),"AllwaysTrue",,,;
						oAb7Top, aHead1a7, aCols1a7) 
				    
		oGrid1a7:oBrowse:bChange:= {|| fAtuGrd2a7( @aCols2a7, @oGrid2a7, cCodCli, cLojCli, oGrid1a7, oGrid2a7, @oMObs7, @cMObs7, @oMEnc7, @cMEnc7, @oMCan7, @cMCan7 ) }
		oGrid1a7:oBrowse:Refresh()
		oGrid1a7:oBrowse:SetFocus(.T.)
		 	
		@ n1de4-12, nComp-095 BUTTON oBFila7 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION (fFiltraCols(Len(aHead1a7)+1,"1A7"),;
				fAtuGrd2a7( @aCols2a7, @oGrid2a7, cCodCli, cLojCli, oGrid1a7, oGrid2a7, @oMObs7, @cMObs7, @oMEnc7, @cMEnc7, @oMCan7, @cMCan7 ) ) PIXEL
		@ n1de4-12, nComp-050 BUTTON oBPesa7 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a7) PIXEL
		
		nLinY := n1de4 - 10	        
	
		@  nLinY, 010 BITMAP oBmp34 RESNAME "BR_AZUL" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
		@  nLinY, 060 BITMAP oBmp35 RESNAME "BR_VERDE" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
		@  nLinY, 110 BITMAP oBmp36 RESNAME "BR_VERMELHO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
		@  nLinY, 160 BITMAP oBmp37 RESNAME "BR_CINZA"	 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL	
	
		@  nLinY, 020 SAY oSLeg34 PROMPT "Atendimento" 			  				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
		@  nLinY, 070 SAY oSLeg35 PROMPT "Cobrança" 		   					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
		@  nLinY, 120 SAY oSLeg36 PROMPT "Encerrado" 			   				SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL	
		@  nLinY, 170 SAY oSLeg37 PROMPT "Cancelado"							SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL	
	
		nLinY := n1de4  
		
		// PAINEL - MEIO 1
		oAb7Me1 := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de4-nL)
		
		@ 005, 000 GROUP oGrpIDv TO n1de4-nL, nComp PROMPT "Itens" OF oAb7Me1 COLOR CLR_BLUE PIXEL
		
		oGrid2a7 := MsNewGetDados():New(015,000,n1de4-nL,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb7Me1,aHead2a7, aCols2a7,{|| })
		  
		nLinY += n1de4-nL-2   
		         
		// PAINEL - MEIO 2
		oAb7Me2 := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de4-nL)
		  
		// Cria a Folder
		oTFldEx := TFolder():New( 000,000, aTFldEx,, oAb7Me2,,,, .T.,, nComp, n1de4-nL-10 )
		 
		// VARIACOES   
		@ 007,010  SAY "Abatimentos" OF oTFldEx:aDialogs[1] PIXEL //"Abatimentos"
		@ 002,070  MSGET aRdpTlc[1][1] VAR aRdpTlc[1][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[1] PIXEL READONLY SIZE 70 ,9
		
		@ 022,010 SAY "Correções Monetária" OF oTFldEx:aDialogs[1] PIXEL //"Correções Monetária"
		@ 017,070 MSGET aRdpTlc[2][1] VAR aRdpTlc[2][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[1] PIXEL READONLY SIZE 70 ,9
		
		@ 037,010 SAY "Juros" OF oTFldEx:aDialogs[1] PIXEL //"Juros"
		@ 032,070 MSGET aRdpTlc[3][1] VAR aRdpTlc[3][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[1] PIXEL READONLY SIZE 70 ,9
		
		@ 007,210  SAY "Acréscimos" OF oTFldEx:aDialogs[1] PIXEL //"Acréscimos"
		@ 002,270  MSGET aRdpTlc[4][1] VAR aRdpTlc[4][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[1]PIXEL READONLY SIZE 70 ,9
		
		@ 022,210 SAY "Decréscimos" OF oTFldEx:aDialogs[1] PIXEL //"Decréscimos"
		@ 017,270 MSGET aRdpTlc[5][1] VAR aRdpTlc[5][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[1] PIXEL READONLY SIZE 70 ,9
		
		@ 037,210 SAY "Descontos" OF oTFldEx:aDialogs[1] PIXEL //"Descontos"
		@ 032,270 MSGET aRdpTlc[6][1] VAR aRdpTlc[6][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[1] PIXEL READONLY SIZE 70 ,9
			
		// SALDOS                               
		@ 007,010  SAY "Valores Originais" OF oTFldEx:aDialogs[2] PIXEL //"Valores Originais"
		@ 002,070  MSGET aRdpTlc[7][1] VAR aRdpTlc[7][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[2] PIXEL READONLY SIZE 70 ,9
		
		@ 022,010  SAY "Saldos Moeda Titulo" OF oTFldEx:aDialogs[2] PIXEL //"Saldos Moeda Titulo"
		@ 017,070 MSGET aRdpTlc[8][1] VAR aRdpTlc[8][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[2] PIXEL READONLY SIZE 70 ,9
		
		@ 037,010 SAY "Saldos Moeda Corrente" OF oTFldEx:aDialogs[2] PIXEL //"Saldos Moeda Corrente"
		@ 032,070 MSGET aRdpTlc[9][1] VAR aRdpTlc[9][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[2] PIXEL READONLY SIZE 70 ,9
		
		@ 007,210  SAY "Pagamentos Parciais" OF oTFldEx:aDialogs[2] PIXEL //"Pagamentos Parciais"
		@ 002,270  MSGET aRdpTlc[10][1] VAR aRdpTlc[10][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[2] PIXEL READONLY SIZE 70 ,9
		
		@ 022,210 SAY "Dívida Moeda Título" OF oTFldEx:aDialogs[2] PIXEL COLOR CLR_RED //"Dívida Moeda Título"
		@ 017,270 MSGET aRdpTlc[11][1] VAR aRdpTlc[11][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[2] PIXEL READONLY SIZE 70 ,9 COLOR CLR_RED
		
		@ 037,210 SAY "Dívida Moeda Corrente" OF oTFldEx:aDialogs[2] PIXEL COLOR CLR_RED //"Dívida Moeda Corrente"
		@ 032,270 MSGET aRdpTlc[12][1] VAR aRdpTlc[12][2] Picture "@E 999,999,999.99" OF oTFldEx:aDialogs[2] PIXEL READONLY SIZE 70 ,9 COLOR CLR_RED
			  
		nLinY += n1de4-nL-10    
		
		nLinX := 0
		 	
		// PAINEL - INFERIOR
		oAb7Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de4-40)
		  
		@ 005, nLinX GROUP oGrpObs7 TO n1de4 - 40, nComp1d4 PROMPT "Observação" OF oAb7Bot COLOR CLR_BLUE PIXEL  	
		@ 015, nLinX+5 GET oMObs7 VAR cMObs7 OF oGrpObs7 MULTILINE SIZE nComp1d4-10, n1de4-60 COLORS 0, 16777215 HSCROLL PIXEL
		
		nLinX += nComp1d4 + 15
		      
		@ 005, nLinX GROUP oGrpEnc7 TO n1de4 - 40, nComp1d4 + nLinX PROMPT "Motivo do Encerramento" OF oAb7Bot COLOR CLR_BLUE PIXEL  	
		@ 015, nLinX+5 GET oMEnc7 VAR cMEnc7 OF oGrpEnc7 MULTILINE SIZE nComp1d4-10, n1de4-60 COLORS 0, 16777215 HSCROLL PIXEL
		
		nLinX += nComp1d4 + 15 
			
		@ 005, nLinX GROUP oGrpCan7 TO n1de4 - 40, nComp1d4 + nLinX PROMPT "Motivo do Cancelamento" OF oAb7Bot COLOR CLR_BLUE PIXEL
		@ 015, nLinX+5 GET oMCan7 VAR cMCan7 OF oGrpCan7 MULTILINE SIZE nComp1d4-10, n1de4-60 COLORS 0, 16777215 HSCROLL PIXEL  
	
	EndIf
	    
	nNumAba++
	       
    //-----------------------------------------------------------
	// **********************************************************
	//  ABA 8 - Chamado Técnico
	// **********************************************************
	//-----------------------------------------------------------
	
	// PAINEL - SUPERIOR
	oAb8Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de2)
	
	@ 005, 000 GROUP oGrpChm TO n1de2, nComp PROMPT "Últimos Chamados Técnicos: "+Alltrim(SA1->A1_NOME) OF oAb8Top COLOR CLR_BLUE PIXEL
	
	oGrid1a8:= MsNewGetDados():New(015,000,n1de2,nComp-1,GD_UPDATE, "AllwaysTrue","AllwaysTrue","",aCposAlt,0,Len(aCols1a8),"AllwaysTrue",,,;
	oAb8Top, aHead1a8, aCols1a8) 
	
	oGrid1a8:oBrowse:bChange:= {|| fAtuGrd2a8( @aCols2a8, @oGrid2a8 ) }
	oGrid1a8:oBrowse:Refresh()
	oGrid1a8:oBrowse:SetFocus(.T.)
	
	@ n1de2+2, nComp-095 BUTTON oBFila8 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION (fFiltraCols(Len(aHead1a8)+1,"1A8"),;
			fAtuGrd2a8( @aCols2a8, @oGrid2a8 )) PIXEL
	@ n1de2+2, nComp-050 BUTTON oBPesa8 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a8) PIXEL
	
	@  n1de2+2, 010 BITMAP oBmp38 RESNAME 'BR_VERDE'  		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  n1de2+2, 060 BITMAP oBmp39 RESNAME 'BR_BRANCO'  		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  n1de2+2, 110 BITMAP oBmp40 RESNAME 'BR_AZUL'    		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  n1de2+2, 170 BITMAP oBmp41 RESNAME 'BR_PRETO'   		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  n1de2+2, 220 BITMAP oBmp42 RESNAME 'BR_VERMELHO' 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	@  n1de2+2, 270 BITMAP oBmp43 RESNAME 'BR_AMARELO'	 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL
	
	@  n1de2+2, 020 SAY oSLeg38 PROMPT "1-Chamado" 	  		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  n1de2+2, 070 SAY oSLeg39 PROMPT "2-Orçamento"   		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  n1de2+2, 120 SAY oSLeg40 PROMPT "3-Ordem Serviço"	SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  n1de2+2, 180 SAY oSLeg41 PROMPT "4-Suspenso" 		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  n1de2+2, 230 SAY oSLeg42 PROMPT "5-Encerrado" 		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  n1de2+2, 280 SAY oSLeg43 PROMPT "6-HelpDesk" 		SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	     
	nLinY := n1de2 + 15  
	
	// PAINEL - INFERIOR
	oAb8Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de2+10)
	
	@ 005, 000 GROUP oGrpICh TO n1de2+10, nComp PROMPT "Itens" OF oAb8Bot COLOR CLR_BLUE PIXEL
	
	oGrid2a8 := MsNewGetDados():New(015,000,n1de2+10,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb8Bot,aHead2a8, aCols2a8,{|| })
		 
	nNumAba++

	//-----------------------------------------------------------
	// **********************************************************
	//  ABA 9 - Ordem de Serviço
	// **********************************************************
	//-----------------------------------------------------------
	
	// PAINEL - SUPERIOR
	oAb9Top := TPanel():New(000, 000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3-15)
	
	@ 005, 000 GROUP oGrpOrS TO n1de3-15, nComp PROMPT "Últimas Ordens de Serviço: "+Alltrim(SA1->A1_NOME) OF oAb9Top COLOR CLR_BLUE PIXEL
	
	oGrid1a9:= MsNewGetDados():New(015,000,n1de3-15,nComp-1,GD_UPDATE, "AllwaysTrue","AllwaysTrue","",aCposAlt,0,Len(aCols1a9),"AllwaysTrue",,,;
					oAb9Top, aHead1a9, aCols1a9) 
	
	oGrid1a9:oBrowse:bChange:= {|| fAtuGrd2a9( @aCols2a9, @oGrid2a9 ), fAtuGrd3a9( @aCols3a9, @oGrid3a9 ) }
	oGrid1a9:oBrowse:Refresh()
	oGrid1a9:oBrowse:SetFocus(.T.) 
	
	@ n1de3-12, nComp-140 BUTTON oBPesa9 PROMPT "Laudo" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fLaudoOS( oGrid1a9 ) PIXEL
	
	@ n1de3-12, nComp-095 BUTTON oBFila9 PROMPT "Filtrar" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION (fFiltraCols(Len(aHead1a9)+1,"1A9"),;
	   		fAtuGrd2a9( @aCols2a9, @oGrid2a9 ), fAtuGrd3a9( @aCols3a9, @oGrid3a9 )) PIXEL
	@ n1de3-12, nComp-050 BUTTON oBPesa9 PROMPT "Pesquisa" 	SIZE 040, 012 OF oTFolder:aDialogs[nNumAba] ACTION fPesqCols(@oGrid1a9) PIXEL
		      
	nLinY := n1de3 - 10
   
 	@  nLinY, 010 BITMAP oBmp44 RESNAME "BR_VERDE" 		OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL 
 	@  nLinY, 055 BITMAP oBmp45 RESNAME "BR_VERMELHO" 	OF oTFolder:aDialogs[nNumAba] SIZE 10,10 NoBorder WHEN .F. PIXEL

	@  nLinY, 020 SAY oSLeg44 PROMPT "Aberta"							SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL
	@  nLinY, 065 SAY oSLeg45 PROMPT "Encerrada"	   					SIZE 110, 007 OF oTFolder:aDialogs[nNumAba] COLORS 0, 16777215 PIXEL

	nLinY += 10 
	                          	
	// PAINEL - MEIO
	oAb9Med := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3)
	
	@ 005, 000 GROUP oGrpEqp TO n1de3, nComp PROMPT "Equipamentos" OF oAb9Med COLOR CLR_BLUE PIXEL
	
	oGrid2a9 := MsNewGetDados():New(015,000,n1de3,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb9Med,aHead2a9, aCols2a9,{|| })
	
	oGrid2a9:oBrowse:bChange:= {|| fAtuGrd3a9( @aCols3a9, @oGrid3a9 ) }
	oGrid2a9:oBrowse:Refresh()
	oGrid2a9:oBrowse:SetFocus(.T.) 
	
	nLinY += n1de3
	
	// PAINEL - INFERIOR ESQUERDO
	oAb9Bot := TPanel():New(nLinY,000,,oTFolder:aDialogs[nNumAba],,,,,,nComp,n1de3-15)
	
	@ 005, 000 GROUP oGrpApn TO n1de3-15, nComp PROMPT "Apontamentos" OF oAb9Bot COLOR CLR_BLUE PIXEL
	
	oGrid3a9 := MsNewGetDados():New(015,000,n1de3-15,nComp-1,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oAb9Bot,aHead3a9, aCols3a9,{|| })
		         
	//-----------------------------------------------------------
	// **********************************************************
	//  FIM
	// **********************************************************
	//-----------------------------------------------------------
	    
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,{|| nOpcA := 1, oDlg:End() },{|| nOpcA := 0, oDlg:End() } )
	
	If nOpcA == 1 // Caso confirmar a tela e informar a quantidade, será adicionado no aCols o item.
		 
		If lVendas
			
			ProcRegua(0) 
			
			nPosDel := Len(aHeader)+1
	
			nPosXQtd := aScan(aHead1a1,{|x| AllTrim(x[2]) == "QUANT" })
			nPosXTip := aScan(aHead1a1,{|x| AllTrim(x[2]) == "TIPOCN" })			
			nPosXPro := aScan(aHead1a1,{|x| AllTrim(x[2]) == "CODPRO" }) 
			nPosXPre := aScan(aHead1a1,{|x| AllTrim(x[2]) == "TENPFT" })
			 
			For nK := 1 to Len(oGrid1a1:aCols)
			
				IncProc( "Atualizando itens")
				
				If oGrid1a1:aCols[nK][nPosXQtd] > 0 
				
					MaFisIni(cCodCli,;										// 1-Codigo Cliente/Fornecedor
							 cLojCli,;								   		// 2-Loja do Cliente/Fornecedor
							 "C",;											// 3-C:Cliente , F:Fornecedor
							 "N",;											// 4-Tipo da NF
							 SA1->A1_TIPO,;									// 5-Tipo do Cliente/Fornecedor
							 Nil,;											// 6-Relacao de Impostos que suportados no arquivo
							 Nil,;											// 7-Tipo de complemento
							 Nil,;											// 8-Permite Incluir Impostos no Rodape .T./.F.
							 Nil,;											// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
							 "ATMK003",;									// 10-Nome da rotina que esta utilizando a funcao
							 Nil,;											// 11-Tipo de documento
							 Nil,;  										// 12-Especie do documento 
						     IIF(M->UA_PROSPEC,M->UA_CLIENTE+M->UA_LOJA,""))// 13- Codigo e Loja do Prospect
					
					If oGrid1a1:aCols[nK][nPosXTip] == "C"
						cParOper := cPOperCm
					Else
						cParOper := cPOperNm
					EndIf
				     				
					_nSaldoB2 := 0 
					cAmzProd  := Posicione("SB1",1,xFilial("SB1")+oGrid1a1:aCols[nK][nPosXPro],"B1_LOCPAD")  
					cTesAten  := MaTesInt(2,cParOper,cCodCli,cLojCli,"C",oGrid1a1:aCols[nK][nPosXPro],"UB_TES")										
					cEstoque  := Posicione("SF4",1,xFilial("SF4")+cTesAten,"F4_ESTOQUE") 
					
					If cEstoque == "S" .or. Empty(cEstoque)
						DbSelectArea("SB2")
						SB2->(DbSetOrder(1))
						If SB2->(dbSeek(xFilial("SB2")+oGrid1a1:aCols[nK][nPosXPro]+cAmzProd,.T.))
					  		_nSaldoB2 := SaldoSB2(,,,,,"SB2")
						Endif
					Endif
					
					If Len(aCols) == 1
						If ! Empty(aCols[1][nPosPro])
							aadd (aCols, aClone (aCols [1]))
						EndIf
					Else						
						aadd (aCols, aClone (aCols [1])) 						
					EndIf
					
					nItemaCols := Len(aCols)
										
					aCols[nItemaCols][nPosIte] := StrZero(nItemaCols,TamSX3("UB_ITEM")[1])
					aCols[nItemaCols][nPosPro] := oGrid1a1:aCols[nK][nPosXPro]
					aCols[nItemaCols][nPosDes] := Posicione("SB1",1,xFilial("SB1")+oGrid1a1:aCols[nK][nPosXPro],"B1_DESC")					
					aCols[nItemaCols][nPosQtd] := oGrid1a1:aCols[nK][nPosXQtd]
					aCols[nItemaCols][nPosSld] := _nSaldoB2
					aCols[nItemaCols][nPosVun] := oGrid1a1:aCols[nK][nPosXPre] 
					aCols[nItemaCols][nPosVen] := oGrid1a1:aCols[nK][nPosXPre] // Posicione("DA1",1,xFilial("DA1")+M->UA_TABELA+oGrid1a1:aCols[nK][nPosXPro],"DA1_PRCVEN")                           
					aCols[nItemaCols][nPosTot] := oGrid1a1:aCols[nK][nPosXQtd] * oGrid1a1:aCols[nK][nPosXPre]
					aCols[nItemaCols][nPosOpe] := cParOper  
					aCols[nItemaCols][nPosTes] := cTesAten
					aCols[nItemaCols][nPosxOp] := cParOper  					
					aCols[nItemaCols][nPosAmz] := cAmzProd
					aCols[nItemaCols][nPosDel] := .F.
					
					For nL := 1 to Len(aHeader) 
						If ValType(aCols[nItemaCols][nL]) == "U" .AND. aHeader[nL][10] <> "V"
						 	If aHeader[nL][8] == "C"	
						 		aCols[nItemaCols][nL] := ""
						   	ElseIf aHeader[nL][8] == "N"
						   		aCols[nItemaCols][nL] := 0
						   	ElseIf aHeader[nL][8] == "D"
						   		aCols[nItemaCols][nL] := CtoD("  /  /  ")
						 	EndIf
						EndIf					
					Next nL	
					
					MaFisAdd(aCols[nItemaCols][nPosPro],;   							// 1-Codigo do Produto ( Obrigatorio )
							 aCols[nItemaCols][nPosTes],;	// 2-Codigo do TES ( Opcional )
							 aCols[nItemaCols][nPosQtd],;											// 3-Quantidade ( Obrigatorio )
							 Round(aCols[nItemaCols][nPosVun],2),;								// 4-Preco Unitario ( Obrigatorio )
							 0,;											// 5-Valor do Desconto ( Opcional )
							 "",;											// 6-Numero da NF Original ( Devolucao/Benef )
							 "",;											// 7-Serie da NF Original ( Devolucao/Benef )
							 0,;											// 8-RecNo da NF Original no arq SD1/SD2
							 0,;// 9-Valor do Frete do Item ( Opcional )
							 0,;											// 10-Valor da Despesa do item ( Opcional )
							 0.0,;											// 11-Valor do Seguro do item ( Opcional )
							 0,;											// 12-Valor do Frete Autonomo ( Opcional )
							 (aCols[nItemaCols][nPosQtd] * Round(aCols[nItemaCols][nPosVun],2)),;								// 13-Valor da Mercadoria ( Obrigatorio )
							 0)											// 14-Valor da Embalagem ( Opiconal )
					
				EndIf  
				
				GetDRefresh()
				
			Next nK   
			
			MaFisSave() 
								
			//Atualiza o Get do Televendas com o Valor
			oGetTlv:oBrowse:Refresh(.T.)			
			Tk273Refresh()	
			Eval(bFolderRefresh)
			Eval(bRefresh)	
											
		EndIf
		
	EndIf
	
EndIf

RestArea(aAreaSA1)  
RestArea(aAreaDA1)  
RestArea(aAreaSU7)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuHeader
Atualiza os aheaders dos grids

@sample		fAtuHeader()

@author		Alessandro Smaha
@since		05/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuHeader(aHeadTmp, cTipo)

Local cUsado   	:= CHR(0)+CHR(0)+CHR(1)  
Local cCampos	:= ""     
Local aCposSx	:= {}
Local nk :=0 

aHeadTmp := {}

If cTipo == "1A1"
	
	aAdd( aHeadTmp,{"Leg.",				   	 	  	  		"cMostra",	"@BMP", 				   		02,00,".F.","",    "C",,"V"} )
	aAdd( aHeadTmp,{"Filial",					  	  		"FILIAL",	PesqPict("SD2","D2_FILIAL"),	06,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Produto",			   		  	   		"CODPRO",	"@S12!",	 					30,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",		   		   	 		"DESPRO",	"@S35!", 	  					40,00,".F.",cUsado,"C",,"R"} ) 
	aAdd( aHeadTmp,{"Últ.Compra",			   	  	   		"ULTCOM", 	"@S05!",   						08,00,".F.",cUsado,"D",,"R"} )
	aAdd( aHeadTmp,{"Quantidade",						   	"QUANT",  	PesqPict("SUB","UB_QUANT"),		TamSX3("UB_QUANT")[1],TamSX3("UB_QUANT")[2],".T.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Period.Compra(Dias)",		 	  		"PERCOM", 	"@S10!",		   		   		14,00,".F.",cUsado,"N",,"R"} )	
	aAdd( aHeadTmp,{"$ Ult.Venda(S/Desc)",					"TENPFT", 	PesqPict("SD2","D2_TOTAL"),  	TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2],".F.",cUsado,"N",,"R"} ) 	
	aAdd( aHeadTmp,{"$ Preço Ótimo",						"PRECOT", 	PesqPict("SD2","D2_TOTAL"),  	TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2],".F.",cUsado,"N",,"R"} ) 	
	aAdd( aHeadTmp,{"$ Ult.Venda(C/Desc)",					"TENDES", 	PesqPict("SD2","D2_TOTAL"),  	TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2],".F.",cUsado,"N",,"R"} ) 	
	aAdd( aHeadTmp,{"Qtde.Itens Fat.",		  		  		"QTDITE", 	"@S05!",			   			14,00,".F.",cUsado,"N",,"R"} )	
	aAdd( aHeadTmp,{"Tendencia Preço Menor",	 			"TENPMN", 	PesqPict("SD2","D2_TOTAL"),  	TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2],".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Descrição",	   			  			"DESPMN", 	"",  							30,00,".F.",cUsado,"C",,"R"} )	
	aAdd( aHeadTmp,{"Tendencia Preço Maior", 	  			"TENPMO", 	PesqPict("SD2","D2_TOTAL"),  	TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2],".F.",cUsado,"N",,"R"} ) 
	aAdd( aHeadTmp,{"Descrição",	 			   			"DESPMO", 	"",  							30,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Tipo",					   	  			"TIPOCN",	"@!",  							01,00,".F.",cUsado,"C",,"R"} )
	
ElseIf cTipo == "2A1"
	
	aAdd( aHeadTmp,{"Produto",					"CODPRO",	"@!",						 		30,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"DESPRO",	"@!",						  		40,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Valor Unitário",			"VALOR", 	PesqPict("SD2","D2_TOTAL"),			TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2],".F.",cUsado,"N",,"R"} )

ElseIf cTipo == "1A2"
 	
	aAdd( aHeadTmp,{"Leg.",				 		"cMostra",	"@BMP", 				   		02,00,".F.","",							"C",,"V"} )
	aAdd( aHeadTmp,{"Filial",					"FILIAL",	PesqPict("SUA","UA_FILIAL"),	06,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Atendimento",				"ATENDI",	PesqPict("SUA","UA_NUM"),	 	TamSX3("UA_NUM")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data",						"DATAAT", 	PesqPict("SUA","UA_EMISSAO"),	TamSX3("UA_EMISSAO")[1],00,".F.",cUsado,"D",,"R"} )	
	aAdd( aHeadTmp,{"Vendedor",					"VENDED",	PesqPict("SA3","A3_NOME"), 	 	TamSX3("A3_NOME")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Operacao",			 		"OPERAC",	"",							 	12,00,".F.",cUsado,						"C",,"R"} )
	aAdd( aHeadTmp,{"Contato",					"CONTAT",	"",							 	40,00,".F.",cUsado,						"C",,"R"} )
	aAdd( aHeadTmp,{"Pedido",			 		"PEDIDO",	PesqPict("SUA","UA_NUMSC5"), 	TamSX3("UA_NUMSC5")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Status",			 		"STATUS",	"",						  	 	20,00,".F.",cUsado,						"C",,"R"} )
	aAdd( aHeadTmp,{"Ped. Remessa",			 	"PED. REMESSA",	PesqPict("SUA","UA_XPEDREM"), 	TamSX3("UA_XPEDREM")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Valor",			 		"VALLIQ",	PesqPict("SUA","UA_VLRLIQ"), 	TamSX3("UA_VLRLIQ")[1],TamSX3("UA_VLRLIQ")[1],".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Campanha",			 		"CAMPAN",	PesqPict("SUO","UO_DESC"),		TamSX3("UO_DESC")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"NF/SERIE",					"NFSERI",	"",						  		40,00,".F.",cUsado,						"C",,"R"} )
	aAdd( aHeadTmp,{"Emissao",		   			"EMISSA",	PesqPict("SUA","UA_EMISNF"),	TamSX3("UA_EMISNF")[1],00,".F.",cUsado,	"D",,"R"} )
	aAdd( aHeadTmp,{"Condicao de Pagto",		"CONDPG",	PesqPict("SE4","E4_DESCRI"),	TamSX3("E4_DESCRI")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Retorno",			   		"RETORN",	PesqPict("SUA","UA_PROXLIG"),	TamSX3("UA_PROXLIG")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Hora",			   			"HORAAT",	PesqPict("SUA","UA_HRPEND"),	TamSX3("UA_HRPEND")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Codigo Observacao",		"CODOBS",	PesqPict("SUA","UA_CODOBS"),	TamSX3("UA_CODOBS")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Codigo do Cancelamento",	"CODCAN",	PesqPict("SUA","UA_CODCANC"),	TamSX3("UA_CODCANC")[1],00,".F.",cUsado,"C",,"R"} )

ElseIf cTipo == "2A2" 

	cCampos := "UB_ITEM|UB_PRODUTO|UB_DESCRI|UB_XSB2|UB_QUANT|UB_VRUNIT|UB_XPRCVEN|UB_VLRITEM|UB_XOPER|UB_TES|UB_DESC|UB_VALDESC|UB_ACRE|"+;
					"UB_VALACRE|UB_CF|UB_PRCTAB|UB_PEDCLI|UB_LOCAL|UB_UM|UB_DTENTRE"    
	       
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2)) // X3_CAMPO 
	aCposSx := Separa(cCampos,"|")   
	       
	For nK := 1 to Len(aCposSx) 
	
		If SX3->(DbSeek(aCposSx[nK]))	
	 		aAdd(aHeadTmp,{	SX3->X3_TITULO,;
	 						SX3->X3_CAMPO,;
	 						SX3->X3_PICTURE,;
	 						SX3->X3_TAMANHO,;
	 						SX3->X3_DECIMAL,;
	 						".F.",;
	 						"",;
	 						SX3->X3_TIPO,;
	 						,;
	 						"R"})
	 											
		EndIf
	
	Next nK
	
ElseIf cTipo == "1A3"
  
	aAdd( aHeadTmp,{"Leg.",				   	 		"cMostra",	"@BMP", 				   		02,00,".F.","",    "C",,"V"} )
	aAdd( aHeadTmp,{"Filial",						"FILIAL",	PesqPict("SUA","UA_FILIAL"),	06,00,".F.",cUsado,"C",,"R"} )  
	aAdd( aHeadTmp,{"Atendimento",					"ATENDI",	PesqPict("SUA","UA_NUM"),	 	TamSX3("UA_NUM")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data",			  				"DTPEDI", 	PesqPict("SUA","UA_EMISSAO"),	08,00,".F.",cUsado,"D",,"R"} )            
	aAdd( aHeadTmp,{"Pedido",			   			"PEDIDO",	PesqPict("SC5","C5_NUM"),	 	TamSX3("C5_NUM")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Usuário Lib. Credito",			"USLBCR",  	"@!",							30,00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data lib. Credito",			"DTLBCR", 	PesqPict("SC5","C5_XDLIBCR"),	TamSX3("C5_XDLIBCR")[1],00,".F.",cUsado,	"D",,"R"} )
	aAdd( aHeadTmp,{"Hora lib. Credito",	 	   	"HRLBCR", 	PesqPict("SC5","C5_XHLIBCR"),	TamSX3("C5_XHLIBCR")[1],00,".F.",cUsado,	"C",,"R"} )	
	aAdd( aHeadTmp,{"Usuário Lib. Estoque",	  		"USLBES", 	"@!",							30,00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data Lib. Estoque",	   		"DTLBES", 	PesqPict("SC5","C5_XDLIBET"),	TamSX3("C5_XDLIBET")[1],00,".F.",cUsado,	"D",,"R"} )	
	aAdd( aHeadTmp,{"Hora lib. Estoque", 	   		"HRLBES", 	PesqPict("SC5","C5_XHLIBET"),	TamSX3("C5_XHLIBET")[1],00,".F.",cUsado,	"C",,"R"} ) 
	aAdd( aHeadTmp,{"Usuário Lib. Regra",	 		"USLBRG", 	"@!",							30,00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data Lib. Regra",				"DTLBRG",	PesqPict("SC5","C5_XDLIBRG"),	TamSX3("C5_XDLIBRG")[1],00,".F.",cUsado,	"D",,"R"} )
	aAdd( aHeadTmp,{"Hora Lib. Regra",			   	"HRLBRG",	PesqPict("SC5","C5_XHLIBRG"),	TamSX3("C5_XHLIBRG")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Usuário Alteração",			"USALTE",	"@!",							30,00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data Alteração",			   	"DTALTE",	PesqPict("SC5","C5_XDALTER"),	TamSX3("C5_XDALTER")[1],00,".F.",cUsado,	"D",,"R"} )
	aAdd( aHeadTmp,{"Hora Alteração",			   	"HRALTE",	PesqPict("SC5","C5_XHALTER"),	TamSX3("C5_XHALTER")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Usuário Sol. Alteração",		"USRSOL",	"@!",							30,00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Motivo da Alteração",			"MOTIVO",	PesqPict("SC5","C5_XMOTALT"),	TamSX3("C5_XMOTALT")[1],00,".F.",cUsado,	"C",,"R"} )

ElseIf cTipo == "2A3"
 
	aAdd( aHeadTmp,{"Item",				   	 		"ITEM",		PesqPict("SC6","C6_ITEM"), 		TamSX3("C6_ITEM")[1],TamSX3("C6_ITEM")[2],		".F.","",    "C",,"V"} )
	aAdd( aHeadTmp,{"Produto",						"PRODUT",	PesqPict("SC6","C6_PRODUTO"),	TamSX3("C6_PRODUTO")[1],00,						".F.",cUsado,"C",,"R"} )  
	aAdd( aHeadTmp,{"Descrição",					"DESCRI",	PesqPict("SB1","B1_DESC"),	 	TamSX3("B1_DESC")[1],00,						".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Quantidade",			  		"QUANTI", 	PesqPict("SC6","C6_QTDVEN"),	TamSX3("C6_QTDVEN")[1],TamSX3("C6_QTDVEN")[2],	".F.",cUsado,"N",,"R"} )            
	aAdd( aHeadTmp,{"Valor Unitário",				"VALUNI",	PesqPict("SC6","C6_PRCVEN"),	TamSX3("C6_PRCVEN")[1],TamSX3("C6_PRCVEN")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor Total",					"VALTOT",  	PesqPict("SC6","C6_VALOR"),		TamSX3("C6_VALOR")[1],TamSX3("C6_VALOR")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Tipo E/S",						"TIPOES", 	PesqPict("SC6","C6_TES"),		TamSX3("C6_TES")[1],00,							".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Valor ICMS",	 	   			"VALICM", 	PesqPict("SC6","C6_VALOR"),		TamSX3("C6_VALOR")[1],TamSX3("C6_VALOR")[2],	".F.",cUsado,"N",,"R"} )	
	aAdd( aHeadTmp,{"Valor IPI",	  				"VALIPI", 	PesqPict("SC6","C6_VALOR"),		TamSX3("C6_VALOR")[1],TamSX3("C6_VALOR")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor ICMS ST",	  			"VALIST", 	PesqPict("SC6","C6_VALOR"),		TamSX3("C6_VALOR")[1],TamSX3("C6_VALOR")[2],	".F.",cUsado,"N",,"R"} )
      
ElseIf cTipo == "1A4"
	
	aAdd( aHeadTmp,{"Filial",						"FILIAL",	PesqPict("SD2","D2_FILIAL"),	06,00,".F.",cUsado,"C",,"R"} ) 
	aAdd( aHeadTmp,{"Atendimento",					"ATENDI",	PesqPict("SUA","UA_NUM"),	 	TamSX3("UA_NUM")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data",			  				"DATAAT", 	PesqPict("SUA","UA_EMISSAO"),	08,00,".F.",cUsado,"D",,"R"} )            
	aAdd( aHeadTmp,{"Pedido",			   			"PEDIDO",	PesqPict("SUA","UA_NUMSC5"), 	TamSX3("UA_NUMSC5")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Nota Fiscal",					"NOTAFI",	PesqPict("SD2","D2_DOC"),	 	TamSX3("D2_DOC")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Serie",						"SERIEN",	PesqPict("SD2","D2_SERIE"),	 	TamSX3("D2_SERIE")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data Faturamento",			  	"DATAFA", 	PesqPict("SUA","UA_EMISSAO"),	08,00,".F.",cUsado,"D",,"R"} )            
	aAdd( aHeadTmp,{"Valor Nota Fiscal",			"VALONF",  	PesqPict("SF2","F2_VALBRUT"),	TamSX3("F2_VALBRUT")[1],TamSX3("F2_VALBRUT")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Operador",			  			"OPERAD", 	PesqPict("SUA","UA_OPERADO"),		TamSX3("UA_OPER")[1],00,".F.",cUsado,"C",,"R"} )            
	aAdd( aHeadTmp,{"Nome",			  				"NOMEOP", 	PesqPict("SU7","U7_NOME"),		TamSX3("U7_NOME")[1],00,".F.",cUsado,"C",,"R"} )            
	aAdd( aHeadTmp,{"Vendedor",			  			"VENDED", 	PesqPict("SA3","A3_NOME"),		TamSX3("A3_NOME")[1],00,".F.",cUsado,"C",,"R"} )            
	aAdd( aHeadTmp,{"Contato Cliente",			  	"CONTAT", 	PesqPict("SU5","U5_CONTAT"),	TamSX3("U5_CONTAT")[1],00,".F.",cUsado,"C",,"R"} )            
	
ElseIf cTipo == "2A4"
	
	aAdd( aHeadTmp,{"Leg.",				   	 		"cMostra",	"@BMP", 				   		02,00,".F.","",    "C",,"V"} )
	aAdd( aHeadTmp,{"Cod. Romaneio",				"ROMANE",	PesqPict("Z03","Z03_COD"), 		TamSX3("Z03_COD")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Data",			  				"DATARM", 	PesqPict("Z03","Z03_DATA"),		08,00,".F.",cUsado,"D",,"R"} )            
	aAdd( aHeadTmp,{"Hora",			   	   			"HORARM",	PesqPict("Z03","Z03_HORA"), 	TamSX3("Z03_HORA")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Transportadora",	  			"TRANSP",	PesqPict("SA4","A4_NOME"), 		TamSX3("A4_NOME")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Usuário",			  			"USUARI",	"@!", 							30,00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Total Volume",		 			"TOTVOL",  	PesqPict("Z03","Z03_TOTALV"),	TamSX3("Z03_TOTALV")[1],TamSX3("Z03_TOTALV")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Total Valor",		 			"TOTVAL",  	PesqPict("Z03","Z03_VALOR"),	TamSX3("Z03_VALOR")[1],TamSX3("Z03_VALOR")[2],	".F.",cUsado,"N",,"R"} )
      
ElseIf cTipo == "3A4"
	
	aAdd( aHeadTmp,{"Item",				   	 		"ITEM",		PesqPict("SD2","D2_ITEM"), 		TamSX3("D2_ITEM")[1],00,						".F.","",    "C",,"V"} )
	aAdd( aHeadTmp,{"Produto",						"PRODUT",	PesqPict("SD2","D2_COD"),  		TamSX3("D2_COD")[1],00,							".F.",cUsado,"C",,"R"} )  
 	aAdd( aHeadTmp,{"Descrição",					"DESCRI",	PesqPict("SB1","B1_DESC"), 		TamSX3("B1_DESC")[1],00,						".F.",cUsado,"C",,"R"} )   
 	aAdd( aHeadTmp,{"Quantidade",		 			"QUANTI",  	PesqPict("SD2","D2_QUANT"),		TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor Unitário",		 		"VALUNI",  	PesqPict("SD2","D2_PRCVEN"),	TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor Total",		 			"VALTOT",  	PesqPict("SD2","D2_TOTAL"),		TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor ICMS",		 			"VALICM",  	PesqPict("SD2","D2_VALICM"),	TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor IPI",		 			"VALIPI",  	PesqPict("SD2","D2_VALIPI"),	TamSX3("D2_VALIPI")[1],TamSX3("D2_VALIPI")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor S.T.",		 			"VALSTT",  	PesqPict("SD2","D2_ICMSRET"),	TamSX3("D2_ICMSRET")[1],TamSX3("D2_ICMSRET")[2],".F.",cUsado,"N",,"R"} )
	
ElseIf cTipo == "1A5"
	
	aAdd( aHeadTmp,{"Leg.",				 		"cMostra",	"@BMP", 				   		02,00,".F.","",							"C",,"V"} )
	aAdd( aHeadTmp,{"Filial",					"FILIAL",	PesqPict("SUC","UC_FILIAL"),	TamSX3("UC_FILIAL")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Atendimento",				"ATENDI",	PesqPict("SUC","UC_CODIGO"),	TamSX3("UC_CODIGO")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Contato",					"CONTAT",	PesqPict("SU5","U5_CONTAT"),  	TamSX3("U5_CONTAT")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Entidade",			 		"ENTIDA",	"@!",  							40,00,".F.",cUsado,						"C",,"R"} )   
	aAdd( aHeadTmp,{"Data",		   		  		"DATANF",	PesqPict("SUC","UC_DATA"),		TamSX3("UC_DATA")[1],00,".F.",cUsado,	"D",,"R"} )
 	aAdd( aHeadTmp,{"Hora",			   			"HORANF",	PesqPict("SUC","UC_INICIO"),	TamSX3("UC_INICIO")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Operador",					"OPERAD",	PesqPict("SUC","U7_NOME"),		TamSX3("U7_NOME")[1],00,".F.",cUsado,						"C",,"R"} )
	aAdd( aHeadTmp,{"Operação",			 		"OPERAC",	"", 							08,00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Status",			 		"STATUS",	"",						  	 	10,00,".F.",cUsado,						"C",,"R"} )
	aAdd( aHeadTmp,{"Setor de",					"SETORD",	PesqPict("SUC","UC_DESCDE"),	TamSX3("UC_DESCDE")[1],00,".F.",cUsado,						"C",,"R"} )
	aAdd( aHeadTmp,{"Setor para",	   			"SETORP",	PesqPict("SUC","UC_DESCPAR"),	TamSX3("UC_DESCPAR")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Causador",			   		"CAUSAD",	PesqPict("SUC","UC_DESCCAU"),	TamSX3("UC_DESCCAU")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Valor frete",			 	"VALFRE",	PesqPict("SUC","UC_VLRFRET"), 	TamSX3("UC_VLRFRET")[1],TamSX3("UC_VLRFRET")[2],".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor boleto",			 	"VALBOL",	PesqPict("SUC","UC_VLRBOL"), 	TamSX3("UC_VLRBOL")[1],TamSX3("UC_VLRBOL")[2],".F.",cUsado,"N",,"R"} )
 	aAdd( aHeadTmp,{"Nota Fiscal",			   	"NOTAFI",	"",								TamSX3("UA_DOC")[1]+TamSX3("UA_SERIE")[1]+1,00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Campanha",			   		"CAMPAN",	PesqPict("SUO","UO_DESC"),		TamSX3("UO_DESC")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Mídia",			   		"MIDIAN",	PesqPict("SUH","UH_DESC"), 		TamSX3("UH_DESC")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Retorno",		   			"RETORN",	PesqPict("SUC","UC_PENDENT"),	TamSX3("UC_PENDENT")[1],00,".F.",cUsado,	"D",,"R"} )
 	aAdd( aHeadTmp,{"Hora",			   			"HORARN",	PesqPict("SUC","UC_HRPEND"),	TamSX3("UC_HRPEND")[1],00,".F.",cUsado,"C",,"R"} )

ElseIf cTipo == "2A5"  
    
	aAdd( aHeadTmp,{"Assunto",					"ASSUNT",	PesqPict("SUD","UD_ASSUNTO"),	TamSX3("UD_ASSUNTO")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"ATENDI",	PesqPict("SUD","UD_DESCASS"),	TamSX3("UD_DESCASS")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Produto Errado",			"PRDERR",	PesqPict("SUD","UD_PRODUTO"),  	TamSX3("UD_PRODUTO")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"DESPER",	PesqPict("SB1","B1_DESC"), 		TamSX3("B1_DESC")[1],00,".F.",cUsado,	"C",,"R"} )   
	aAdd( aHeadTmp,{"Ocorrência",				"OCORRE",	PesqPict("SUD","UD_OCORREN"),  	TamSX3("UD_OCORREN")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"DESOCO",	PesqPict("SUD","UD_DESCOCO"),	TamSX3("UD_DESCOCO")[1],00,".F.",cUsado,	"C",,"R"} )   
	aAdd( aHeadTmp,{"Ação",		   		  		"ACAOPR",	PesqPict("SUD","UD_SOLUCAO"),	TamSX3("UD_SOLUCAO")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Descrição",				"DESACA",	PesqPict("SUD","UD_DESCSOL"),	TamSX3("UD_DESCSOL")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Responsável",				"RESACA",	PesqPict("SUD","UD_DESCOPE"),	TamSX3("UD_DESCOPE")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Data ação",				"DATACA",	PesqPict("SUD","UD_DATA"), 		TamSX3("UD_DATA")[1],00,".F.",cUsado,	"D",,"R"} )
	aAdd( aHeadTmp,{"Status",			 		"STATUS",	PesqPict("SUD","UD_STATUS"),	10,00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Observação",				"OBSERV",	PesqPict("SUD","UD_OBS"),  		TamSX3("UD_OBS")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Execução",	   		 		"EXECUC",	PesqPict("SUD","UD_DTEXEC"),	TamSX3("UD_DTEXEC")[1],00,".F.",cUsado,"D",,"R"} )
 	aAdd( aHeadTmp,{"Complemento",				"COMPLE",	"",								TamSX3("UD_OBSEXEC")[1],00,".F.",cUsado,"M",,"R"} )
 	aAdd( aHeadTmp,{"Produto certo",		   	"PRDCER",	PesqPict("SUD","UD_PRODCER"), 	TamSX3("UD_PRODCER")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Descrição",				"DESPCE",	PesqPict("SB1","B1_DESC"),		TamSX3("B1_DESC")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Série",			   		"SERIEP",	PesqPict("SUD","UD_NSERIE"),	TamSX3("UD_NSERIE")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Evento",		   			"EVENTO",	PesqPict("SUD","UD_EVENTO"),	TamSX3("UD_EVENTO")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Grade",			   		"GRADEE",	PesqPict("SUD","UD_GRADE"),		TamSX3("UD_GRADE")[1],00,".F.",cUsado,"C",,"R"} )
   
ElseIf cTipo == "1A6"

	aAdd( aHeadTmp,{"Filial",					"FILIAL",	PesqPict("SF1","F1_FILIAL"),	TamSX3("F1_FILIAL")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Atendimento",				"ATENDI",	PesqPict("SUA","UA_NUM"),	 	TamSX3("UA_NUM")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Data",		   		  		"DATANF",	PesqPict("SUA","UA_EMISSAO"),	TamSX3("UA_EMISSAO")[1],00,".F.",cUsado,	"D",,"R"} )
 	aAdd( aHeadTmp,{"Pedido",					"PEDIDO",	PesqPict("SUA","UA_NUMSC5"),  	TamSX3("UA_NUMSC5")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Nota Fiscal Devolução",	"NFDEVO",	PesqPict("SF1","F1_DOC"),  		TamSX3("F1_DOC")[1],00,".F.",cUsado,						"C",,"R"} )   
	aAdd( aHeadTmp,{"Serie NF Devolução",		"SEDEVO",	PesqPict("SF1","F1_SERIE"),  	TamSX3("F1_SERIE")[1],00,".F.",cUsado,						"C",,"R"} )   
	aAdd( aHeadTmp,{"Data Devolução",		   	"DATADV",	PesqPict("SF1","F1_EMISSAO"),	TamSX3("F1_EMISSAO")[1],00,".F.",cUsado,	"D",,"R"} )
	aAdd( aHeadTmp,{"Valor NF Devolução",	 	"VALDEV",	PesqPict("SF1","F1_VALBRUT"), 	TamSX3("F1_VALBRUT")[1],TamSX3("F1_VALBRUT")[2],".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Nota Fiscal Origem", 		"NFORIG",	PesqPict("SF2","F2_DOC"),  		TamSX3("F2_DOC")[1],00,".F.",cUsado,						"C",,"R"} )   
	aAdd( aHeadTmp,{"Serie NF Origem", 			"SEORIG",	PesqPict("SF2","F2_SERIE"),  	TamSX3("F2_SERIE")[1],00,".F.",cUsado,						"C",,"R"} )   
	aAdd( aHeadTmp,{"Data Faturamento",		   	"DATAFT",	PesqPict("SF2","F2_EMISSAO"),	TamSX3("F2_EMISSAO")[1],00,".F.",cUsado,	"D",,"R"} )
 	aAdd( aHeadTmp,{"Valor NF Origem",			"VALNFO",	PesqPict("SF2","F2_VALBRUT"),	TamSX3("F2_VALBRUT")[1],TamSX3("F2_VALBRUT")[2],".F.",cUsado,"N",,"R"} )
 	aAdd( aHeadTmp,{"Operador",			   		"OPERAD",	PesqPict("SU7","U7_COD"),  		TamSX3("U7_COD")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Nome",			   			"NOMEOP",	PesqPict("SUA","UA_DESCOPE"),	TamSX3("UA_DESCOPE")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Vendedor",		   			"VENDED",	PesqPict("SUA","UA_DESCVEN"),	TamSX3("UA_DESCVEN")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Contato Cliente",			"CONTAT",	PesqPict("SUA","UA_DESCNT"),	TamSX3("UA_DESCNT")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Usuário Aut. Dev.", 		"USRAUT", 	"@!",							30,00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Motivo",		   			"MOTIVO",	PesqPict("SF1","F1_XMOTDEV"),	TamSX3("F1_XMOTDEV")[1],00,".F.",cUsado,"C",,"R"} )
    
ElseIf cTipo == "2A6"
	 
	aAdd( aHeadTmp,{"Item",				   	 		"ITEM",		PesqPict("SD2","D2_ITEM"), 		TamSX3("D2_ITEM")[1],00,						".F.","",    "C",,"V"} )
	aAdd( aHeadTmp,{"Produto",						"PRODUT",	PesqPict("SD2","D2_COD"),  		TamSX3("D2_COD")[1],00,							".F.",cUsado,"C",,"R"} )  
 	aAdd( aHeadTmp,{"Descrição",					"DESCRI",	PesqPict("SB1","B1_DESC"), 		TamSX3("B1_DESC")[1],00,						".F.",cUsado,"C",,"R"} )   
 	aAdd( aHeadTmp,{"Qtde. Original Nota", 			"QUANTO",  	PesqPict("SD2","D2_QUANT"),		TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2],	".F.",cUsado,"N",,"R"} )
 	aAdd( aHeadTmp,{"Qtde. Devolvida",	 			"QUANTD",  	PesqPict("SD1","D1_QUANT"),		TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor Unitário",		 		"VALUNI",  	PesqPict("SD2","D2_PRCVEN"),	TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor Total",		 			"VALTOT",  	PesqPict("SD2","D2_TOTAL"),		TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor ICMS",		 			"VALICM",  	PesqPict("SD2","D2_VALICM"),	TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor IPI",		 			"VALIPI",  	PesqPict("SD2","D2_VALIPI"),	TamSX3("D2_VALIPI")[1],TamSX3("D2_VALIPI")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor S.T.",		 			"VALSTT",  	PesqPict("SD2","D2_ICMSRET"),	TamSX3("D2_ICMSRET")[1],TamSX3("D2_ICMSRET")[2],".F.",cUsado,"N",,"R"} )
 
ElseIf cTipo == "1A7"

	aAdd( aHeadTmp,{"Leg.",				 		"cMostra",	"@BMP", 				   		02,00,".F.","",							"C",,"V"} )
	aAdd( aHeadTmp,{"Filial",					"FILIAL",	PesqPict("ACF","ACF_FILIAL"),	TamSX3("ACF_FILIAL")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Atendimento",				"ATENDI",	PesqPict("ACF","ACF_CODIGO"),	TamSX3("ACF_CODIGO")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Cliente",					"CLIENT",	PesqPict("ACF","ACF_CLIENT"), 	TamSX3("ACF_CLIENT")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Loja",						"LOJACL",	PesqPict("ACF","ACF_LOJA"),  	TamSX3("ACF_LOJA")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Prazo Cobrança",	  		"PRAZOC",	PesqPict("ACF","ACF_PRAZO"),	TamSX3("ACF_PRAZO")[1],00,".F.",cUsado,	"D",,"R"} )
 	aAdd( aHeadTmp,{"Empresa",					"DESEMP",	PesqPict("ACF","ACF_DESC"),  	TamSX3("ACF_DESC")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Contato", 					"CONTAT",	PesqPict("ACF","ACF_CODCON"),  	TamSX3("ACF_CODCON")[1],00,".F.",cUsado,						"C",,"R"} )   
	aAdd( aHeadTmp,{"Nome", 					"NOMECO",	PesqPict("ACF","ACF_DESCNT"),  	TamSX3("ACF_DESCNT")[1],00,".F.",cUsado,						"C",,"R"} )   
 	aAdd( aHeadTmp,{"Operador",			   		"OPERAD",	PesqPict("SU7","U7_COD"),  		TamSX3("U7_COD")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Nome",			   			"NOMEOP",	PesqPict("ACF","ACF_DESCOP"),	TamSX3("ACF_DESCOP")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Ligação",			   		"LIGACA",	"",								10,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Status",			   		"STATUS",	"",								12,00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Ocorrência",			  	"OCORRE",	PesqPict("ACF","ACF_MOTIVO"), 	TamSX3("ACF_MOTIVO")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",			  	"DESOCO",	PesqPict("ACF","ACF_DESCMO"),	TamSX3("ACF_DESCMO")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Data Retorno",		   		"DATARE",	PesqPict("ACF","ACF_PENDEN"),	TamSX3("ACF_PENDEN")[1],00,".F.",cUsado,	"D",,"R"} )
 	aAdd( aHeadTmp,{"Campanha",			   		"CAMPAN",	PesqPict("ACF","ACF_CODCAM"), 	TamSX3("ACF_CODCAM")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",			   	"DESCAM",	PesqPict("ACF","ACF_DESCAM"),	TamSX3("ACF_DESCAM")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Motivo",		   			"MOTIVO",	PesqPict("ACF","ACF_CODMOT"),	TamSX3("ACF_CODMOT")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Cod. Observacao",			"CODOBS",	PesqPict("ACF","ACF_CODOBS"),	TamSX3("ACF_CODOBS")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Cod. Encerramento",		"CODENC",	PesqPict("ACF","ACF_CODMOT"),	TamSX3("ACF_CODMOT")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Cod. Cancelamento",		"CODCAN",	PesqPict("ACF","ACF_CCANC"),	TamSX3("ACF_CCANC")[1],00,".F.",cUsado,"C",,"R"} )
 	
ElseIf cTipo == "2A7"

	aAdd( aHeadTmp,{"Prefixo",					"PREFIX",	PesqPict("ACG","ACG_PREFIX"),	TamSX3("ACG_PREFIX")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Titulo",					"TITULO",	PesqPict("ACG","ACG_TITULO"),	TamSX3("ACG_TITULO")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Parcela",					"PARCEL",	PesqPict("ACG","ACG_PARCEL"), 	TamSX3("ACG_PARCEL")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Tipo",						"TIPOPA",	PesqPict("ACG","ACG_TIPO"),  	TamSX3("ACG_TIPO")[1],00,".F.",cUsado,	"C",,"R"} )
 	aAdd( aHeadTmp,{"Status",					"STATUS",	PesqPict("ACG","ACG_STATUS"),  	TamSX3("ACG_STATUS")[1],00,".F.",cUsado,	"C",,"R"} )
	aAdd( aHeadTmp,{"Vencimento",	   			"VENCTO",	PesqPict("ACG","ACG_DTVENC"),	TamSX3("ACG_DTVENC")[1],00,".F.",cUsado,	"D",,"R"} )
	aAdd( aHeadTmp,{"Vencimento Real",	  		"VENCRE",	PesqPict("ACG","ACG_DTREAL"),	TamSX3("ACG_DTREAL")[1],00,".F.",cUsado,	"D",,"R"} )
// 	aAdd( aHeadTmp,{"Atraso",		 			"ATRASO",  	"99999",   						05,00,	".F.",cUsado,"N",,"R"} )
  	aAdd( aHeadTmp,{"Valor",		 			"VALORN",  	PesqPict("ACG","ACG_VALOR"),	TamSX3("ACG_VALOR")[1],TamSX3("ACG_VALOR")[2],	".F.",cUsado,"N",,"R"} )
  	aAdd( aHeadTmp,{"Valor receber",		 	"VALREC",  	PesqPict("ACG","ACG_RECEBE"),	TamSX3("ACG_RECEBE")[1],TamSX3("ACG_RECEBE")[2],	".F.",cUsado,"N",,"R"} )
  	aAdd( aHeadTmp,{"Juros",		 			"JUROSR",  	PesqPict("ACG","ACG_JUROS"),	TamSX3("ACG_JUROS")[1],TamSX3("ACG_JUROS")[2],	".F.",cUsado,"N",,"R"} )
 	aAdd( aHeadTmp,{"Desc. Financeiro",		 	"DESCFI",  	PesqPict("ACG","ACG_DESCFI"),	TamSX3("ACG_DESCFI")[1],TamSX3("ACG_DESCFI")[2],	".F.",cUsado,"N",,"R"} )
 	aAdd( aHeadTmp,{"Limite Desconto", 			"DATLIM",	PesqPict("ACG","ACG_LIDESC"),	TamSX3("ACG_LIDESC")[1],00,".F.",cUsado,	"D",,"R"} )
  	aAdd( aHeadTmp,{"Acréscimo",		 		"ACRESC",  	PesqPict("ACG","ACG_ACRESC"),	TamSX3("ACG_ACRESC")[1],TamSX3("ACG_ACRESC")[2],	".F.",cUsado,"N",,"R"} )
  	aAdd( aHeadTmp,{"Decréscimo",		 		"DESCRE",  	PesqPict("ACG","ACG_DECRES"),	TamSX3("ACG_DECRES")[1],TamSX3("ACG_DECRES")[2],	".F.",cUsado,"N",,"R"} )
  	aAdd( aHeadTmp,{"Promoção",		 			"PROMOC",  	PesqPict("ACG","ACG_PROMOC"),	TamSX3("ACG_PROMOC")[1],TamSX3("ACG_PROMOC")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Responsável", 				"RESPON",	PesqPict("ACG","ACG_OPERAD"),  	TamSX3("ACG_OPERAD")[1],00,".F.",cUsado,						"C",,"R"} )   
	aAdd( aHeadTmp,{"Nome", 					"NOMERE",	PesqPict("ACG","ACG_DESCOP"),  	TamSX3("ACG_DESCOP")[1],00,".F.",cUsado,						"C",,"R"} )   
// 	aAdd( aHeadTmp,{"Situação",			   		"SITUAC",	PesqPict("ACG","ACG_SITUAC"), 	TamSX3("ACG_SITUAC")[1],00,".F.",cUsado,"C",,"R"} )
//	aAdd( aHeadTmp,{"Portador",			   		"PORTAD",	PesqPict("ACG","ACG_PORTAD"),	TamSX3("ACG_PORTAD")[1],00,".F.",cUsado,"C",,"R"} )
  	aAdd( aHeadTmp,{"Tx Permanência",		 	"TXPERM",  	PesqPict("ACG","ACG_VALJUR"),	TamSX3("ACG_VALJUR")[1],TamSX3("ACG_VALJUR")[2],	".F.",cUsado,"N",,"R"} )
  	aAdd( aHeadTmp,{"Porc. Juros",		 		"PORCJU",  	PesqPict("ACG","ACG_PORJUR"),	TamSX3("ACG_PORJUR")[1],TamSX3("ACG_PORJUR")[2],	".F.",cUsado,"N",,"R"} )
 	aAdd( aHeadTmp,{"Natureza",			   		"NATURE",	PesqPict("ACG","ACG_NATURE"),	TamSX3("ACG_NATURE")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição Natureza",		"DESNAT",	PesqPict("ACG","ACG_DESCNT"),	TamSX3("ACG_DESCNT")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",			   	"DESCRI",	PesqPict("ACG","ACG_DESCTP"),	TamSX3("ACG_DESCTP")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Nº banco",			   		"NUMBCO",	PesqPict("ACG","ACG_NUMBCO"), 	TamSX3("ACG_NUMBCO")[1],00,".F.",cUsado,"C",,"R"} )
  	aAdd( aHeadTmp,{"IRRF",		 		   		"VLIRRF",  	PesqPict("ACG","ACG_IRRF"),		TamSX3("ACG_IRRF")[1],TamSX3("ACG_IRRF")[2],	".F.",cUsado,"N",,"R"} )
   	aAdd( aHeadTmp,{"ISS",		 		   		"VLRISS",  	PesqPict("ACG","ACG_ISS"),		TamSX3("ACG_ISS")[1],TamSX3("ACG_ISS")[2],	".F.",cUsado,"N",,"R"} )
   	aAdd( aHeadTmp,{"CSLL",		 		   		"VLRCSL",  	PesqPict("ACG","ACG_CSLL"),		TamSX3("ACG_CSLL")[1],TamSX3("ACG_CSLL")[2],	".F.",cUsado,"N",,"R"} )
   	aAdd( aHeadTmp,{"COFINS",		 			"COFINS",  	PesqPict("ACG","ACG_COFINS"),	TamSX3("ACG_COFINS")[1],TamSX3("ACG_COFINS")[2],	".F.",cUsado,"N",,"R"} )
   	aAdd( aHeadTmp,{"PIS",		 				"VLSPIS",  	PesqPict("ACG","ACG_PIS"),		TamSX3("ACG_PIS")[1],TamSX3("ACG_PIS")[2],	".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Desc. tipo",			  	"DESTIP",	PesqPict("ACG","ACG_HIST"),		TamSX3("ACG_HIST")[1],00,".F.",cUsado,"C",,"R"} )
 	aAdd( aHeadTmp,{"Referencia",			 	"REFERE",	PesqPict("ACG","ACG_VALREF"), 	TamSX3("ACG_VALREF")[1],00,".F.",cUsado,"C",,"R"} )
//	aAdd( aHeadTmp,{"Baixa",			   		"TBAIXA",	PesqPict("ACG","ACG_BAIXA"),	TamSX3("ACG_BAIXA")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Fil. Origem",		   		"FILORI",	PesqPict("ACG","ACG_FILORI"),	TamSX3("ACG_FILORI")[1],00,".F.",cUsado,"C",,"R"} )
   	aAdd( aHeadTmp,{"Multa",		 			"VMULTA",  	PesqPict("ACG","ACG_MULTA"),	TamSX3("ACG_MULTA")[1],TamSX3("ACG_MULTA")[2],	".F.",cUsado,"N",,"R"} )
  	aAdd( aHeadTmp,{"Desc. Juros",		 		"VJUROS",  	PesqPict("ACG","ACG_DESCJU"),	TamSX3("ACG_DESCJU")[1],TamSX3("ACG_DESCJU")[2],	".F.",cUsado,"N",,"R"} )

ElseIf cTipo == "1A8"
	
	aAdd( aHeadTmp,{"Leg.",				 		"cMostra",	"@BMP", 				   		02,00,".F.","",							"C",,"V"} )
	aAdd( aHeadTmp,{"Filial",					"FILIAL",	PesqPict("AB1","AB1_FILIAL"),	TamSX3("AB1_FILIAL")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Chamado",			   		"CODPRO",	PesqPict("AB1","AB1_NRCHAMA"),	TamSX3("AB1_NRCHAMA")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Emissão",		  			"EMISSA", 	PesqPict("AB1","AB1_EMISSA"),	TamSX3("AB1_EMISSA")[1],00,".F.",cUsado,"D",,"R"} )
	aAdd( aHeadTmp,{"Hora Chamado",	   			"HORACH", 	PesqPict("AB1","AB1_HORA"),		TamSX3("AB1_HORA")[1],00,".F.",cUsado,"C",,"R"} )	
	aAdd( aHeadTmp,{"Atendente",	   			"ATENDI", 	PesqPict("AB1","AB1_ATEND"),	TamSX3("AB1_ATEND")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Chamado Tmk",	   			"CHATMK", 	PesqPict("AB1","AB1_NUMTMK"),	TamSX3("AB1_NUMTMK")[1],00,".F.",cUsado,"C",,"R"} )		
	aAdd( aHeadTmp,{"Cond. End.",	   			"CONDEN", 	PesqPict("AB1","AB1_XCDEND"),	TamSX3("AB1_XCDEND")[1],00,".F.",cUsado,"C",,"R"} )	
	aAdd( aHeadTmp,{"End. Entrega",	   			"ENDENT", 	PesqPict("AB1","AB1_XENDER"),	TamSX3("AB1_XENDER")[1],00,".F.",cUsado,"C",,"R"} )	
	
ElseIf cTipo == "2A8"
	
	aAdd( aHeadTmp,{"Item",			   			"ITEMCH",	PesqPict("AB2","AB2_ITEM"),		TamSX3("AB1_FILIAL")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Situação",					"SITUAC",	PesqPict("AB2","AB2_TIPO"),		10,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Classificação",			"CLASSI",	"@!",							20,00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Produto/Equipamento",		"CODPRO",	PesqPict("AB2","AB2_CODPRO"),	TamSX3("AB2_CODPRO")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"DESPRO",	PesqPict("AB2","AB2_X_DESC"),	TamSX3("AB2_X_DESC")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Número Série",				"NUMSER",	PesqPict("AB2","AB2_NUMSER"),	TamSX3("AB2_NUMSER")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Quantidade",				"QUANTI",	PesqPict("AB2","AB2_XQTDIN"),	TamSX3("AB2_XQTDIN")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Ocorrência",				"OCORRE",	PesqPict("AB2","AB2_CODPRB"),	TamSX3("AB2_CODPRB")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"DESOCO",	PesqPict("AB2","AB2_DESCRI"),	TamSX3("AB2_DESCRI")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Data Encerramento",		"DATENC",	PesqPict("AB2","AB2_BXDATA"),	TamSX3("AB2_BXDATA")[1],00,".F.",cUsado,"D",,"R"} )
	aAdd( aHeadTmp,{"Hora Encerramento",		"HORENC",	PesqPict("AB2","AB2_BXHORA"),	TamSX3("AB2_BXHORA")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Comentário",				"COMENT",	""							,	TamSX3("AB2_MEMO2")[1],00,".F.",cUsado,"M",,"R"} )

ElseIf cTipo == "1A9"
	
	aAdd( aHeadTmp,{"Leg.",				   	 	"cMostra",	"@BMP", 				   		02,00,".F.","",    "C",,"V"} )
	aAdd( aHeadTmp,{"Filial",					"FILIAL",	PesqPict("AB6","AB6_FILIAL"),	TamSX3("AB6_FILIAL")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"O.S.",						"ORDSER",	PesqPict("AB6","AB6_NUMOS"),	TamSX3("AB6_NUMOS")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Emissão",					"EMISSA", 	PesqPict("AB6","AB6_EMISSA"),	TamSX3("AB6_EMISSA")[1],00,".F.",cUsado,"D",,"R"} )
	aAdd( aHeadTmp,{"Atendente",			   	"ATENDE",	PesqPict("AB6","AB6_ATEND"),	TamSX3("AB6_ATEND")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Hora Abertura",		   	"HORAAB",	PesqPict("AB6","AB6_HORA"), 	TamSX3("AB6_HORA")[1],00,".F.",cUsado,"C",,"R"} ) 
	aAdd( aHeadTmp,{"O.S. Liberada ?",			"OSLIBE", 	"@!",							03,00,".F.",cUsado,"C",,"R"} ) // 1=Nao;2=Sim
	aAdd( aHeadTmp,{"Técnico",					"CODTEC",  	PesqPict("AB6","AB6_XCDTEC"),	TamSX3("AB6_XCDTEC")[1],00,".T.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Nome",						"NOMTEC", 	PesqPict("AA1","AA1_NOMTEC"),	TamSX3("AA1_NOMTEC")[1],00,".F.",cUsado,"C",,"R"} )	
//	aAdd( aHeadTmp,{"Auxiliar",	 	  			"CODAUX", 	PesqPict("AB6","AB6_XCDAUX"),  	TamSX3("AB6_XCDAUX")[1],00,".F.",cUsado,"C",,"R"} ) 	
//	aAdd( aHeadTmp,{"Nome",						"NOMAUX", 	PesqPict("AA1","AA1_NOMTEC"),	TamSX3("AA1_NOMTEC")[1],00,".F.",cUsado,"C",,"R"} )	
	aAdd( aHeadTmp,{"Cod. Endereço",	  		"CODEND", 	PesqPict("AB6","AB6_XCDEND"),  	TamSX3("AB6_XCDEND")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",	   			"DESEND", 	PesqPict("SA1","A1_END"),  		TamSX3("A1_END")[1],00,".F.",cUsado,"C",,"R"} )	
	aAdd( aHeadTmp,{"Previsão Atendimento", 	"PREATE", 	PesqPict("AB6","AB6_XDATPR"),  	TamSX3("AB6_XDATPR")[1],00,".F.",cUsado,"D",,"R"} ) 
    aAdd( aHeadTmp,{"Usuário Enc. O.S.",   		"USRENC", 	PesqPict("AB6","AB6_XUSREF"),	TamSX3("AB6_XUSREF")[1],00,".F.",cUsado,"C",,"R"} )	
	aAdd( aHeadTmp,{"Data Enc. O.S.",  			"DATENC", 	PesqPict("AB6","AB6_XDATEF"),  	TamSX3("AB6_XDATEF")[1],00,".F.",cUsado,"D",,"R"} ) 
    aAdd( aHeadTmp,{"Hora Enc. O.S.", 			"HORENC", 	PesqPict("AB6","AB6_XHOREF"),	TamSX3("AB6_XHOREF")[1],00,".F.",cUsado,"C",,"R"} )	
                                                                              
ElseIf cTipo == "2A9"
	
	aAdd( aHeadTmp,{"Item",				   		"ITEMOS",	PesqPict("AB7","AB7_ITEM"),		TamSX3("AB7_ITEM")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Situação",					"SITUAC",	"@!",							14,00,".F.",cUsado,"C",,"R"} ) // 1=O.S.;2=Pedido Gerado;3=Em Atendimento;4=Atendido;5=Encerrado 
	aAdd( aHeadTmp,{"Produto/Eqto",				"EQUIPA",	PesqPict("AB7","AB7_CODPRO"),	TamSX3("AB7_CODPRO")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"DESEQU",	PesqPict("SB1","B1_DESC"),		TamSX3("B1_DESC")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Num. Série",				"NUMSER",	PesqPict("AB7","AB7_NUMSER"),	TamSX3("AB7_NUMSER")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Num. Chamado",				"CODCHM",	PesqPict("AB7","AB7_NRCHAM"),	TamSX3("AB7_NRCHAM")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Num. Orçamento",			"CODORC",	PesqPict("AB7","AB7_NUMORC"),	TamSX3("AB7_NUMORC")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Ocorrência",				"CODOCO",	PesqPict("AB7","AB7_CODPRB"),	TamSX3("AB7_CODPRB")[1],00,".F.",cUsado,"C",,"R"} ) // AAG
	aAdd( aHeadTmp,{"Descrição",				"DESOCO",	PesqPict("AAG","AAG_DESCRI"),	TamSX3("AAG_DESCRI")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Obs. Ocorrência",			"OBSOCO",	"",								TamSX3("AB7_MEMO2")[1],00,".F.",cUsado,"M",,"R"} )
	aAdd( aHeadTmp,{"Solução",					"SOLUCA",	"",								TamSX3("AB7_MEMO4")[1],00,".F.",cUsado,"M",,"R"} )
	aAdd( aHeadTmp,{"Qtde. Instalação",			"QTDINS", 	PesqPict("AB7","AB7_XQTDIN"),	TamSX3("AB7_XQTDIN")[1],TamSX3("AB7_XQTDIN")[2],".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Contato",					"CODCON",	PesqPict("AB7","AB7_CODCON"),	TamSX3("AB7_CODCON")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Nome",						"NOMCON",	PesqPict("SU5","U5_CONTAT"),	TamSX3("U5_CONTAT")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Desc. Ocorrência",			"DESCRI",	PesqPict("AB7","AB7_DSCOCO"),	TamSX3("AB7_DSCOCO")[1],00,".F.",cUsado,"C",,"R"} )

ElseIf cTipo == "3A9"
	
	aAdd( aHeadTmp,{"Sub Item",					"SUBITE",	PesqPict("AB8","AB8_SUBITE"),	TamSX3("AB8_SUBITE")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Produto/Epto",				"PROEQT",	PesqPict("AB8","AB8_CODPRO"),	TamSX3("AB8_CODPRO")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"DESPRO",	PesqPict("SB1","B1_DESC"),		TamSX3("B1_DESC")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Serviço",					"CODSER",	PesqPict("AB8","AB8_CODSER"),	TamSX3("AB8_CODSER")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Descrição",				"DESSER",	PesqPict("AA5","AA5_DESCRI"),	TamSX3("AA5_DESCRI")[1],00,".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Quantidade",				"QTDUSA", 	PesqPict("AB8","AB8_QUANT"),	TamSX3("AB8_QUANT")[1],TamSX3("AB8_QUANT")[2],".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor Unitário",			"VALUNI", 	PesqPict("AB8","AB8_VUNIT"),	TamSX3("AB8_VUNIT")[1],TamSX3("AB8_VUNIT")[2],".F.",cUsado,"N",,"R"} )
	aAdd( aHeadTmp,{"Valor Total",				"VALTOT", 	PesqPict("AB8","AB8_TOTAL"),	TamSX3("AB8_TOTAL")[1],TamSX3("AB8_TOTAL")[2],".F.",cUsado,"N",,"R"} )

EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuCols
Atualiza os aCols dos grids

@sample		fAtuCols()

@author		Alessandro Smaha
@since		05/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuCols( cCodCli, cLojCli, aColsTmp, nTamHead, cTipoCols )

Local cParTabe	:= GetMV("ST_TABHIST",,"")
Local nParPeri	:= GetMV("ST_PARPERI",,0)   
Local cParUser	:= GetMV("ST_USRVIS",,"")
Local cUsado   	:= CHR(0)+CHR(0)+CHR(1)
Local nItem		:= 0
Local cQuery 	:= ""
Local nK		:= 0
Local dDataMin	:= CtoD("  /  /  ")
Local dDataMax	:= CtoD("  /  /  ")
Local nContDoc	:= 0
Local cTendPre	:= ""
Local cTendMenor := ""
Local cTendMaior := ""  
Local nTendMenor := 0
Local nTendMaior := 0
Local cQueryI  	 := ""
Local cQueryM 	 := ""
Local cQueryF 	 := ""
Local cQryNorm	 := ""
Local cQryComo	 := ""
Local cOperacao  := ""   
Local cAliasTmp	 := ""

If cTipoCols == "1A1" 

	fBuscaPer(cCodCli,cLojCli,@dDataMin,@dDataMax,@nContDoc)
	
	If (Select("QPER") <> 0)
		DbSelectArea("QPER")
		QPER->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli, nParPeri, cParTabe )
	
	TCQuery cQuery new Alias "QPER"
	
ElseIf cTipoCols == "2A1"
	
	If (Select("QSEG") <> 0)
		DbSelectArea("QSEG")
		QSEG->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli, nParPeri, cParTabe )
	
	TCQuery cQuery new Alias "QSEG"
	
ElseIf cTipoCols == "1A2"
 
	If (Select("QHIS") <> 0)
		DbSelectArea("QHIS")
		QHIS->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli, nParPeri, cParTabe )
	
	TCQuery cQuery new Alias "QHIS"
		
ElseIf cTipoCols == "1A3" 
 
	If (Select("QLIB") <> 0)
		DbSelectArea("QLIB")
		QLIB->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli, nParPeri, cParTabe )
	
	TCQuery cQuery new Alias "QLIB"
	
ElseIf cTipoCols == "1A4"

	If (Select("QNRM") <> 0)
		DbSelectArea("QNRM")
		QNRM->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli, nParPeri, cParTabe )
	
	TCQuery cQuery new Alias "QNRM"
	
ElseIf cTipoCols == "1A5"
	     
	If (Select("QSAC") <> 0)
		DbSelectArea("QSAC")
		QSAC->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli )
	
	TCQuery cQuery new Alias "QSAC"
	
ElseIf cTipoCols == "1A6" 
  
	If (Select("QDEV") <> 0)
		DbSelectArea("QDEV")
		QDEV->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli )
	
	TCQuery cQuery new Alias "QDEV"
	
ElseIf cTipoCols == "1A7"

	If (Select("QCOB") <> 0)
		DbSelectArea("QCOB")
		QCOB->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli )
	
	TCQuery cQuery new Alias "QCOB"
	
ElseIf cTipoCols == "1A8"

	If (Select("QTEC") <> 0)
		DbSelectArea("QTEC")
		QTEC->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli )
	
	TCQuery cQuery new Alias "QTEC"
	
ElseIf cTipoCols == "1A9"

	If (Select("QORS") <> 0)
		DbSelectArea("QORS")
		QORS->(DbCloseArea())
	Endif
	
	cQuery := fMontaQry( cTipoCols, cCodCli, cLojCli )
	
	TCQuery cQuery new Alias "QORS"
	 
EndIf 

If !Empty(cQuery)
	fColsGrid(cTipoCols,nTamHead,@aColsTmp)	
EndIf

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} fLeg1a1
Busca a legenda para a Aba 1

@sample		fLeg1a1()

@author		Alessandro Smaha
@since		11/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fLeg1a1(nPerid,dDtUltCom)

Local nSTLegPer1 := GetMV("ST_LEGPER1",,0)
Local nSTLegPer2 := GetMV("ST_LEGPER2",,0)
Local nSTLegPer3 := GetMV("ST_LEGPER3",,0)
Local nSTLegPer4 := GetMV("ST_LEGPER4",,0)
Local cNomeLeg := ""

If nPerid >= nSTLegPer3 
    If nPerid + dDtUltCom >= dDataBase
    	cNomeLeg := "BR_PINK"
    Else
	    If nPerid + dDtUltCom + (nPerid * nSTLegPer4 / 100) >= dDataBase
	  		cNomeLeg := "BR_AMARELO"
		Else
			cNomeLeg := "BR_VERMELHO"    
	    EndIf 
	EndIf
Else
	If nPerid + dDtUltCom + nSTLegPer1 >= dDataBase   
		cNomeLeg := "BR_VERDE"
	Else
		If nPerid + dDtUltCom + (nPerid * nSTLegPer2 / 100) >= dDataBase
	   		cNomeLeg := "BR_AMARELO"
		Else
			cNomeLeg := "BR_VERMELHO"    
	    EndIf 
	EndIf	
EndIf

Return cNomeLeg

      
//-------------------------------------------------------------------
/*/{Protheus.doc} fLeg1a2
Busca a legenda para a Aba 2

@sample		fLeg1a2()

@author		Alessandro Smaha
@since		11/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fLeg1a2() 

Local cNomeLeg 	:= "BR_VERDE"     
Local cFilAt	:= QHIS->UA_FILIAL
Local cNumAt	:= QHIS->UA_NUM 
Local cRetFunc	:= ""

DbSelectArea("SUA")
SUA->(DbSetOrder(1)) // UA_FILIAL+UA_NUM
If SUA->(DbSeek(cFilAt+cNumAt))

	cRetFunc := U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) 

	If (Empty(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. !Empty(SUA->UA_DOC)) 	// Faturado - VERMELHO
		cNomeLeg := "BR_VERMELHO"
	ElseIf (EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2)	// Orcamento - AZUL
   		cNomeLeg := "BR_AZUL"  
	ElseIf (EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 3)	// Atendimento - MARRON
		cNomeLeg := "BR_MARRON"  					
	ElseIf (!EMPTY(SUA->UA_CODCANC))	// Cancelado  
		cNomeLeg := "BR_PRETO"														  
	ElseIf cRetFunc == '01'  	//01 - Apto a Faturar
		cNomeLeg := "BR_AMARELO" 
	ElseIf cRetFunc == '02'  	//02 - Bloqueio por Regra
		cNomeLeg := "PMSEDT1"     
	ElseIf cRetFunc == '03'		//03 - Bloqueio por Verba
		cNomeLeg := "PMSEDT2"    
	ElseIf cRetFunc == '04'  	//04 - Bloqueio de Crédito 
		cNomeLeg := "PMSTASK1"   
	ElseIf cRetFunc == '05'   	//05 - Rejeitado na Liberação do Credito
		cNomeLeg := "BR_CANCEL"  
	ElseIf cRetFunc == '06'   	//06 - Bloqueio de Estoque
		cNomeLeg := "PMSEDT4"   
	ElseIf cRetFunc == '07' 	//07 - Bloqueio WMS  
		cNomeLeg := "PMSEDT3"    
	ElseIf cRetFunc == '08'  	//08 - Bloqueio TMS 
		cNomeLeg := "BR_PINK"    
	ElseIf cRetFunc == '09'   	//09 - Pedido em aberto 
		cNomeLeg := "BR_VERDE" 
	EndIf
	
EndIf     

Return cNomeLeg
         

//-------------------------------------------------------------------
/*/{Protheus.doc} fLeg1a3
Busca a legenda para a Aba 3

@sample		fLeg1a3()

@author		Alessandro Smaha
@since		11/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fLeg1a3() 

Local cNomeLeg 	:= ""   
Local cFilAt	:= QLIB->UA_FILIAL 
Local cNumAt	:= QLIB->UA_NUM 
Local cRetFunc	:= ""   
 
DbSelectArea("SUA")
SUA->(DbSetOrder(1)) // UA_FILIAL+UA_NUM
If SUA->(DbSeek(cFilAt+cNumAt))  
	
	cRetFunc := U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5)    

	If cRetFunc == '02'    			// Bloqueio por Regra
		cNomeLeg := "PMSEDT1"     
	ElseIf cRetFunc == '04'    		// Bloqueio de Crédito 
		cNomeLeg := "PMSEDT2"    
	ElseIf cRetFunc == '06'   		// Bloqueio de Estoque
		cNomeLeg := "PMSEDT4"   
   	ElseIf !Empty(SUA->UA_DOC)		// Faturado
   		cNomeLeg := "BR_VERMELHO"  
   	Else 							// Liberado Total 
   		cNomeLeg := "BR_VERDE" 		
	EndIf
	
EndIf  

Return cNomeLeg
         

//-------------------------------------------------------------------
/*/{Protheus.doc} fLeg2a4
Busca a legenda para a Aba 4

@sample		fLeg2a4()

@author		Alessandro Smaha
@since		09/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fLeg2a4(cACEFIN,cACD,cFEZMT)

Local cNomeLeg := "" 

If cACEFIN == '1' .AND. cACD <> '1' .AND. cFEZMT <> '1'		// Em Aberto - Inclusão Manual  
	cNomeLeg := "BR_VERDE"
ElseIf cACEFIN == '1' .AND. cACD == '1' .AND. cFEZMT <> '1'	// Em Aberto - Inclusão Automática 
	cNomeLeg := "BR_PINK" 
ElseIf cACEFIN == '1' .AND. cFEZMT == '1'					// Em Manutenção 
	cNomeLeg := "BR_LARANJA"
ElseIf cACEFIN == '2'										// Baixado 
	cNomeLeg := "BR_VERMELHO"
ElseIf cACEFIN == '3'										// Baixa Cancelada 
	cNomeLeg := "BR_PRETO"
EndIf

Return cNomeLeg 

              
//-------------------------------------------------------------------
/*/{Protheus.doc} fLeg1a7
Busca a legenda para a Aba 7

@sample		fLeg1a7()

@author		Alessandro Smaha
@since		23/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fLeg1a7() 

Local cNomeLeg 	:= ""      
Local cFilAt	:= QCOB->ACF_FILIAL
Local cNumAt	:= QCOB->ACF_CODIGO
Local cRetFunc	:= ""   
 
DbSelectArea("ACF")
ACF->(DbSetOrder(1)) // ACF_FILIAL+ACF_CODIGO
If ACF->(DbSeek(cFilAt+cNumAt))  
		
	If (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 1)
		cNomeLeg := "BR_AZUL"
	ElseIf (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 2)
		cNomeLeg := "BR_VERDE"               
	ElseIf (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 3)
		cNomeLeg := "BR_VERMELHO"
	ElseIf(!Empty(ACF->ACF_CCANC))
		cNomeLeg := "BR_CINZA"
	EndIf
	
EndIf

Return cNomeLeg  
    

//-------------------------------------------------------------------
/*/{Protheus.doc} fLeg1a8
Atualiza as legendas

@sample		fAtuGrd2a8()

@author		Alessandro Smaha
@since		26/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fLeg1a8(cXtipo)            

Local cNomeLeg 	:= "" 

If cXtipo == '1'
	cNomeLeg := 'BR_VERDE'
ElseIf cXtipo == '2'	
	cNomeLeg := 'BR_BRANCO'
ElseIf cXtipo == '3'
	cNomeLeg := 'BR_AZUL'
ElseIf cXtipo == '4'
	cNomeLeg := 'BR_PRETO'
ElseIf cXtipo == '5'
	cNomeLeg := 'BR_VERMELHO'
ElseIf cXtipo == '6'
	cNomeLeg := 'BR_AMARELO'
EndIf

Return cNomeLeg  

 
//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd2a2
Atualiza o grid em tempo real

@sample		fAtuGrd2a2()

@author		Alessandro Smaha
@since		22/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd2a2( aColsTmp, oItTmp, cMultObs, oMultObs, cMultCan, oMultCan )

Local nK := 0 
Local nItem := 0  
Local cCodCan := ""    
Local cCodObs := "" 
Local aAreaSB1 := SB1->(GetArea()) 
Local aAreaSUA := SUA->(GetArea())  
Local aAreaSUB := SUB->(GetArea())   
Local nPosPro := Ascan(aHead2a2, {|x| AllTrim( x[2] ) == "UB_PRODUTO"} )
Local nPosDes := Ascan(aHead2a2, {|x| AllTrim( x[2] ) == "UB_DESCRI"} )         
Local cAtendim	:= ""
Local cFilAten	:= ""

aColsTmp := {} 

If Len(oGrid1a2:aCols) > 0 .and. !Empty(oGrid1a2:aCols[oGrid1a2:nAt][3])
                          
	cFilAten := oGrid1a2:aCols[oGrid1a2:nAt][2]
	cAtendim := oGrid1a2:aCols[oGrid1a2:nAt][3]
   
	If SUA->(DbSeek(cFilAten+cAtendim)) 
	
		cCodObs := SUA->UA_CODOBS
		cCodCan := SUA->UA_CODCANC
		
		If SUB->(DbSeek(cFilAten+cAtendim)) 
			
			While SUB->(!Eof()) .AND. SUA->UA_FILIAL == SUB->UB_FILIAL .AND. SUA->UA_NUM == SUB->UB_NUM 
		         
		        nItem++
		        
				aAdd(aColsTmp,Array(Len(aHead2a2)+1))
						
				For nK := 1 to Len(aHead2a2)  
				
					If nPosDes == nK  
							
						aColsTmp[nItem][nK] := Posicione("SB1",1,xFilial("SB1") + aColsTmp[nItem][nPosPro],"B1_DESC")  
				
					ElseIf aHead2a2[nK][10] <> "V"  
					 
						aColsTmp[nItem][nK] := SUB->&(aHead2a2[nK][2])
									
					EndIf
				    
				Next nK   
				
				aColsTmp[nItem][Len(aHead2a2)+1] := .F.
				
				SUB->(DbSkip())
				
			EndDo 
			
		EndIf		
			
	EndIf    
	
	// Carrega o motivo do cancelamento   
	cMultObs:= ""
	cMultObs:= fBuscaMemo(cFilAten,cCodObs,"UA_CODOBS") // MSMM(cCodObs,TamSx3("UA_OBS")[1])
	oMultObs:Refresh() 
	
	// Carrega o motivo do cancelamento   
	cMultCan:= ""
	cMultCan:= fBuscaMemo(cFilAten,cCodCan,"UA_CODCANC") // MSMM(cCodCan,TamSx3("UA_OBSCANC")[1])
	oMultCan:Refresh()
  
EndIf

If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead2a2)+1))
Endif
   
oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh()
 
RestArea(aAreaSUA)
RestArea(aAreaSUB)
RestArea(aAreaSB1) 

Return (.T.) 


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd2a3
Atualiza o grid em tempo real

@sample		fAtuGrd2a3()

@author		Alessandro Smaha
@since		22/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd2a3( aColsTmp, oItTmp )

Local nK := 0 
Local nItem := 0  
Local cCodCan := ""
Local aAreaSUA := SUA->(GetArea())  
Local aAreaSC5 := SC5->(GetArea())   
Local aAreaSC6 := SC6->(GetArea()) 
Local aAreaSB1 := SB1->(GetArea())   
Local nPosPro := Ascan(aHead2a3, {|x| AllTrim( x[2] ) == "PRODUT"} )
Local nPosDes := Ascan(aHead2a3, {|x| AllTrim( x[2] ) == "DESCRI"} ) 
Local cFilAten := ""            
Local cAtendim := ""

aColsTmp := {} 

If Len(oGrid1a3:aCols) > 0  .and. !Empty(oGrid1a3:aCols[oGrid1a3:nAt][3])
	             
	cFilAten := oGrid1a3:aCols[oGrid1a3:nAt][2]             
	cAtendim := oGrid1a3:aCols[oGrid1a3:nAt][3]
  
	If SUA->(DbSeek(cFilAten+cAtendim)) .AND. !Empty(SUA->UA_NUMSC5) .AND. SC5->(DbSeek(SUA->UA_FILIAL+SUA->UA_NUMSC5))	
	
		If SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))	
		     
			While SC6->(!Eof()) .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM 
				 
		        nItem++
		        
				aAdd(aColsTmp,Array(Len(aHead2a3)+1))
				
				aColsTmp[nItem][1] := SC6->C6_ITEM  
				aColsTmp[nItem][2] := SC6->C6_PRODUTO
				aColsTmp[nItem][3] := Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")
				aColsTmp[nItem][4] := SC6->C6_QTDVEN
				aColsTmp[nItem][5] := SC6->C6_PRCVEN
				aColsTmp[nItem][6] := SC6->C6_VALOR
				aColsTmp[nItem][7] := SC6->C6_TES
				aColsTmp[nItem][8] := 0
				aColsTmp[nItem][9] := 0
				aColsTmp[nItem][10] := 0   
				aColsTmp[nItem][11] := .F.
	
				SC6->(DbSkip())
			EndDo 
		
		EndIf
	
	EndIf
  
EndIf

If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead2a3)+1))
Endif
   
oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh()
 
RestArea(aAreaSUA)
RestArea(aAreaSC5)
RestArea(aAreaSC6) 
RestArea(aAreaSB1) 

Return (.T.) 


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd2a4
Atualiza o grid em tempo real

@sample		fAtuGrd2a4()

@author		Alessandro Smaha
@since		22/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd2a4( aColsTmp, oItTmp, aColsTmp2, oItTmp2, aHeadTmp, cCodCli, cLojCli )  

Local nK := 0 
Local nItem := 0  
Local cCodCan := ""  
Local nPosFil := Ascan(aHeadTmp, {|x| AllTrim( x[2] ) == "FILIAL"} )  
Local nPosNtf := Ascan(aHeadTmp, {|x| AllTrim( x[2] ) == "NOTAFI"} )  
Local nPosSer := Ascan(aHeadTmp, {|x| AllTrim( x[2] ) == "SERIEN"} )   
Local cFilNtf := ""
Local cNFisca := ""  
Local cSerieN := "" 
Local aAreaSA4 := SA4->(GetArea()) 
Local aAreaSB1 := SB1->(GetArea())  
 
DbSelectArea("SD2")
SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

aColsTmp := {}   
aColsTmp2 := {}  

If Len(oGrid1a4:aCols) > 0 .AND. nPosNtf > 0 .AND. nPosSer > 0  .and. !Empty(oGrid1a4:aCols[oGrid1a4:nAt][nPosNtf])
    
	cFilNtf := oGrid1a4:aCols[oGrid1a4:nAt][nPosFil] 
 	cNFisca := oGrid1a4:aCols[oGrid1a4:nAt][nPosNtf] 
	cSerieN := oGrid1a4:aCols[oGrid1a4:nAt][nPosSer]    
	
	If (Select("QROM") <> 0)
		DbSelectArea("QROM")
		QROM->(DbCloseArea())
	Endif
	      
	cQuery := " SELECT Z03_COD, Z03_DATA, Z03_HORA, Z03_TRANSP, Z03_IDUSER, Z03_TOTALV, Z03_VALOR, Z03_ACEFIN, Z03_ACD, Z03_FEZMT, Z04_TOTALV, Z04_VALOR "
	cQuery += " FROM "+RetSQLName("Z04")+" Z04 "  
	cQuery += " INNER JOIN "+RetSQLName("Z03")+" Z03 ON Z03_FILIAL = Z04_FILIAL AND Z03_COD = Z04_COD AND Z03.D_E_L_E_T_ <> '*' " 
	cQuery += " WHERE Z04_FILIAL = '"+cFilNtf+"' "
	cQuery += " 	AND Z04_CLIENT = '"+cCodCli+"' "
	cQuery += " 	AND Z04_LOJA   = '"+cLojCli+"' "
	cQuery += " 	AND Z04_NFISCA = '"+cNFisca+"' "
	cQuery += " 	AND Z04_SERIE  = '"+cSerieN+"' "
	cQuery += " 	AND Z04.D_E_L_E_T_ <> '*' "
	   
	TCQuery cQuery new Alias "QROM"
	
	QROM->(DbGoTop())
	
	If QROM->(!Eof()) 
	
		nItem++        
		aAdd(aColsTmp,Array(Len(aHead2a4)+1))  	
	                    
		aColsTmp[nItem][1]  := fLeg2a4( QROM->Z03_ACEFIN, QROM->Z03_ACD, QROM->Z03_FEZMT ) 	// Leg.
		aColsTmp[nItem][2]  := QROM->Z03_COD       		                					// Cod. Romaneio
		aColsTmp[nItem][3]  := StoD(QROM->Z03_DATA)                     					// Data
		aColsTmp[nItem][4]  := QROM->Z03_HORA                           					// Hora
		aColsTmp[nItem][5]  := Posicione("SA4",1,xFilial("SA4") + QROM->Z03_TRANSP,"A4_NOME")												// Transportadora 
		aColsTmp[nItem][6]  := Alltrim(UsrFullName(QROM->Z03_IDUSER)) 						// Usuário			
		aColsTmp[nItem][7]  := QROM->Z04_TOTALV					   							// Total Volume		
		aColsTmp[nItem][8]  := QROM->Z04_VALOR 												// Total Valor 						
		aColsTmp[nItem][9] := .F.	
	
		If SD2->(DbSeek(cFilNtf+cNFisca+cSerieN+cCodCli+cLojCli))     // D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
	        
	     	nItem := 0
	     
			While SD2->(!Eof()) .AND. cFilNtf == SD2->D2_FILIAL .AND. cNFisca+cSerieN+cCodCli+cLojCli == SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
		
		        nItem++        
				aAdd(aColsTmp2,Array(Len(aHead3a4)+1))  	
			                    
				aColsTmp2[nItem][1]  := SD2->D2_ITEM 			// Item
				aColsTmp2[nItem][2]  := SD2->D2_COD       	 	// Produto
				aColsTmp2[nItem][3]  := Posicione("SB1",1,xFilial("SB1") + SD2->D2_COD,"B1_DESC")     // Descrição
				aColsTmp2[nItem][4]  := SD2->D2_QUANT         	// Quantidade
				aColsTmp2[nItem][5]  := SD2->D2_PRCVEN			// Valor unitário 
				aColsTmp2[nItem][6]  := SD2->D2_TOTAL			// Valor total			
				aColsTmp2[nItem][7]  := SD2->D2_VALICM			// Valor ICMS		
				aColsTmp2[nItem][8]  := SD2->D2_VALIPI 			// Valor IPI 						
				aColsTmp2[nItem][9]  := SD2->D2_ICMSRET         // Valor S.T.
				aColsTmp2[nItem][10] := .F.                                                         
				     
				SD2->(DbSkip()) 
				
			EndDo  
			
			aSort( aColsTmp2, , , { |x,y| y[1] > x[1] } )
			
		EndIf
	EndIf  
	
EndIf

If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead2a4)+1))
Endif

oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh()     

If Empty(aColsTmp2)
	aAdd(aColsTmp2,Array(Len(aHead3a4)+1))
Endif

oItTmp2:SetArray(aColsTmp2)                              
oItTmp2:Refresh()

RestArea(aAreaSA4) 
RestArea(aAreaSB1) 
 
Return (.T.) 

      
//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd2a5
Atualiza o aCols

@sample		fAtuGrd2a5()

@author		Alessandro Smaha
@since		16/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd2a5( aColsTmp, oItTmp, cMObs, oMObs, cMCan, oMCan, cMEnc, oMEnc )   

Local nK := 0                             
Local nItem := 0  
Local cMCodObs := "" 		 
Local cMCodEnc := "" 
Local cMCodCan := ""
Local cFilTlk  := ""
Local cCodTlk  := ""
Local aAreaSUC := SUC->(GetArea())
Local aAreaSUD := SUD->(GetArea())
Local aAreaSX5 := SX5->(GetArea())  
Local aAreaSB1 := SB1->(GetArea())  
Local aAreaSU9 := SU9->(GetArea())  
Local aAreaSUQ := SUQ->(GetArea())   
            
DbSelectArea("SUC")
SUC->(DbSetOrder(1)) // UC_FILIAL+UC_CODIGO

DbSelectArea("SUD")
SUD->(DbSetOrder(1)) // UD_FILIAL+UD_CODIGO+UD_ITEM

aColsTmp := {} 

If Len(oGrid1a5:aCols) > 0  .AND. !Empty(oGrid1a5:aCols[oGrid1a5:nAt][3] )
   
	cFilTlk := oGrid1a5:aCols[oGrid1a5:nAt][2]
	cCodTlk := oGrid1a5:aCols[oGrid1a5:nAt][3] 

	If SUC->(DbSeek(cFilTlk+cCodTlk)) 
	
	   	cMCodObs := SUC->UC_CODOBS 		 
		cMCodEnc := SUC->UC_CODMOT 
		cMCodCan := SUC->UC_CODCANC 
		
	    If SUD->(DbSeek(cFilTlk+cCodTlk)) 
		    
			While SUD->(!Eof()) .AND. cFilTlk == SUD->UD_FILIAL .AND. cCodTlk == SUD->UD_CODIGO 
		         
		        nItem++
		        
				aAdd(aColsTmp,Array(Len(aHead2a5)+1)) 
			             
				aColsTmp[nItem][01] := SUD->UD_ASSUNTO	 	  							// Assunto
				aColsTmp[nItem][02] := Posicione("SX5", 1, xFilial("SX5")+'T1'+SUD->UD_ASSUNTO, "X5_DESCRI" )	// Descrição  
				aColsTmp[nItem][03] := SUD->UD_PRODUTO  	   							// Produto Errado
				aColsTmp[nItem][04] := Posicione("SB1",1,xFilial("SB1") + SUD->UD_PRODUTO,"B1_DESC")   			// Descrição
				aColsTmp[nItem][05] := SUD->UD_OCORREN			 					  	// Ocorrência
				aColsTmp[nItem][06] := Posicione("SU9",2,xFilial("SU9") + SUD->UD_OCORREN,"U9_DESC")	   		// Descrição
				aColsTmp[nItem][07] := SUD->UD_SOLUCAO	   		  						// Ação
				aColsTmp[nItem][08] := Posicione("SUQ", 1, xFilial("SUQ") + SUD->UD_SOLUCAO, "UQ_DESC" )		// Descrição
				aColsTmp[nItem][09] := SUD->UD_OPERADO //Alltrim(UsrFullName(SUD->UD_OPERADO)) 		   	// Responsável-> Migração 12.1.27
				aColsTmp[nItem][10] := SUD->UD_DATA				  						// Data ação
				aColsTmp[nItem][11] := IIF(SUD->UD_STATUS=="1","Pendente","Encerrado")	// Status 1=Pendente;2=Encerrado
				aColsTmp[nItem][12] := SUD->UD_OBS		   								// Observação  
				aColsTmp[nItem][13] := SUD->UD_DTEXEC		   	  						// Execução 
				aColsTmp[nItem][14] := fBuscaMemo(cFilTlk,SUD->UD_CODEXEC,"UD_CODEXEC") // Alltrim(MSMM(SUD->UD_CODEXEC,TamSx3("UD_OBSEXEC")[1]))	// Complemento  
				aColsTmp[nItem][15] := SUD->UD_PRODCER		   							// Produto certo  
				aColsTmp[nItem][16] := Posicione("SB1",1,xFilial("SB1") + SUD->UD_PRODCER,"B1_DESC")	// Descrição 
				aColsTmp[nItem][17] := SUD->UD_NSERIE		  					 		// Série  
				aColsTmp[nItem][18] := SUD->UD_EVENTO		 					  		// Evento  
				aColsTmp[nItem][19] := SUD->UD_GRADE	   						   		// Grade  
				aColsTmp[nItem][20] := .F.
				     
				SUD->(DbSkip())
				
			EndDo
		
		EndIf          
		
	EndIf    
	        
	// Carrega a Observação  
	cMObs:= ""
	cMObs := fBuscaMemo(cFilTlk,cMCodObs,"UC_CODOBS") // MSMM(cMCodObs,TamSx3("UC_OBS")[1])
	oMObs:Refresh()
	
	// Carrega o motivo do encerramento  
	cMEnc:= ""
	cMEnc:= fBuscaMemo(cFilTlk,cMCodEnc,"UC_CODMOT") // MSMM(cMCodEnc,TamSx3("UC_OBSMOT")[1])
	oMEnc:Refresh() 
	
	// Carrega o motivo do cancelamento   
	cMCan:= ""
	cMCan:= fBuscaMemo(cFilTlk,cMCodCan,"UC_CODCANC") // MSMM(cMCodCan,TamSx3("UC_OBSCANC")[1])
	oMCan:Refresh()
  
EndIf
  
If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead2a5)+1))
Endif 
oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh()
 
RestArea(aAreaSUC)
RestArea(aAreaSUD)  
RestArea(aAreaSX5)  
RestArea(aAreaSB1)  
RestArea(aAreaSU9)  
RestArea(aAreaSUQ) 

Return (.T.)  
               

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd2a6
Atualiza o aCols

@sample		fAtuGrd2a6()

@author		Alessandro Smaha
@since		16/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd2a6( aColsTmp, oItTmp, cCodCli, cLojCli )
                 
Local nItem		:= 0                                
Local nQtdeDev 	:= 0        
Local aAreaSD1 	:= SD1->(GetArea())  
Local aAreaSD2 	:= SD2->(GetArea())   
Local nPosFil 	:= Ascan(aHead1a6, {|x| AllTrim( x[2] ) == "FILIAL"} )
Local nPosDOr 	:= Ascan(aHead1a6, {|x| AllTrim( x[2] ) == "NFORIG"} )
Local nPosSOr 	:= Ascan(aHead1a6, {|x| AllTrim( x[2] ) == "SEORIG"} ) 
Local nPosDDv 	:= Ascan(aHead1a6, {|x| AllTrim( x[2] ) == "NFDEVO"} )
Local nPosSDv 	:= Ascan(aHead1a6, {|x| AllTrim( x[2] ) == "SEDEVO"} )
Local cFilOri	:= ""
Local cDocOri	:= ""
Local cSerOri	:= "" 
Local cDocDev	:= ""
Local cSerDev	:= ""

aColsTmp := {} 

If Len(oGrid1a6:aCols) > 0   .and. !Empty(oGrid1a6:aCols[oGrid1a6:nAt][nPosDOr])

	cFilOri	:= oGrid1a6:aCols[oGrid1a6:nAt][nPosFil]
	cDocOri	:= oGrid1a6:aCols[oGrid1a6:nAt][nPosDOr]
	cSerOri	:= oGrid1a6:aCols[oGrid1a6:nAt][nPosSOr] 
	cDocDev	:= oGrid1a6:aCols[oGrid1a6:nAt][nPosDDv]
	cSerDev	:= oGrid1a6:aCols[oGrid1a6:nAt][nPosSDv]

	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
         
	If SD2->(DbSeek(cFilOri+cDocOri+cSerOri+cCodCli+cLojCli))
 
		While SD2->(!Eof()) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == cFilOri+cDocOri+cSerOri+cCodCli+cLojCli
			
			nQtdeDev := 0
			 
			If SD1->(DbSeek(cFilOri+cDocDev+cSerDev+cCodCli+cLojCli+SD2->D2_COD)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				nQtdeDev := SD1->D1_QUANT	
			EndIf 
			 
	        nItem++
	        
			aAdd(aColsTmp,Array(Len(aHead2a6)+1))
			
			aColsTmp[nItem][1]  := SD2->D2_ITEM
			aColsTmp[nItem][2]  := SD2->D2_COD
			aColsTmp[nItem][3]  := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")
			aColsTmp[nItem][4]  := SD2->D2_QUANT
	   		aColsTmp[nItem][5]  := nQtdeDev
			aColsTmp[nItem][6]  := SD2->D2_PRCVEN
			aColsTmp[nItem][7]  := SD2->D2_TOTAL
			aColsTmp[nItem][8]  := SD2->D2_VALICM
			aColsTmp[nItem][9]  := SD2->D2_VALIPI
			aColsTmp[nItem][10] := SD2->D2_ICMSRET  
			aColsTmp[nItem][11] := .F.

			SD2->(DbSkip())
		EndDo  
		
		aSort( aColsTmp, , , { |x,y| y[1] > x[1] } )
		
	EndIf
  
EndIf

If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead2a6)+1))
Endif    
oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh()
 
RestArea(aAreaSD1) 
RestArea(aAreaSD2)

Return .T.
    
    
//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd2a7
Atualiza o grid em tempo real

@sample		fAtuGrd2a7( aColsTmp, oItTmp, cCodCli, cLojCli )

@author		Alessandro Smaha
@since		23/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd2a7( aColsTmp, oItTmp, cCodCli, cLojCli, oGrid1, oGrid2, oMObs, cMObs, oMEnc, cMEnc, oMCan, cMCan )
       
Local nK := 0 
Local nItem := 0  
Local aAreaACG := ACG->(GetArea())   
Local nPosFil  := Ascan(aHead1a7, {|x| AllTrim( x[2] ) == "FILIAL"} )
Local nPosAte  := Ascan(aHead1a7, {|x| AllTrim( x[2] ) == "ATENDI"} )
Local nPosObs  := Ascan(aHead1a7, {|x| AllTrim( x[2] ) == "CODOBS"} )  
Local nPosEnc  := Ascan(aHead1a7, {|x| AllTrim( x[2] ) == "CODENC"} )  
Local nPosCan  := Ascan(aHead1a7, {|x| AllTrim( x[2] ) == "CODCAN"} )    
Local cFilAte	:= ""
Local cCodAte	:= ""
Local cTmkJuros	:= GetNewPar("MV_TMKAJUR","1")								// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja    
Local aValores	:= {} 

aColsTmp := {} 

For nK := 1 to Len(aRdpTlc) 
	aRdpTlc[nK][2] := 0
Next nK

DbSelectArea("SE1")
DbSetOrder(2)	//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo

If Len(oGrid1a7:aCols) > 0 .and. !Empty(oGrid1a7:aCols[oGrid1a7:nAt][nPosAte])

	DbSelectArea("ACG")
	ACG->(DbSetOrder(1)) // ACG_FILIAL+ACG_CODIGO+ACG_PREFIX+ACG_TITULO+ACG_PARCEL+ACG_TIPO+ACG_FILORI 
	             
	cFilAte := oGrid1a7:aCols[oGrid1a7:nAt][nPosFil]
	cCodAte := oGrid1a7:aCols[oGrid1a7:nAt][nPosAte]  
	cMCodObs := oGrid1a7:aCols[oGrid1a7:nAt][nPosObs]  		      
	cMCodEnc := oGrid1a7:aCols[oGrid1a7:nAt][nPosEnc] 
	cMCodCan := oGrid1a7:aCols[oGrid1a7:nAt][nPosCan] 		     
     	
	If ACG->(DbSeek(cFilAte+cCodAte)) 
        
		While ACG->(!Eof()) .AND. ACG->(ACG_FILIAL+ACG_CODIGO) == cFilAte+cCodAte
			 
	        nItem++
	        
			aAdd(aColsTmp,Array(Len(aHead2a7)+1))
			
			aColsTmp[nItem][01] := ACG->ACG_PREFIX 	// Prefixo  
			aColsTmp[nItem][02] := ACG->ACG_TITULO	// Titulo  
			aColsTmp[nItem][03] := ACG->ACG_PARCEL	// Parcela
			aColsTmp[nItem][04] := ACG->ACG_TIPO	// Tipo 
			aColsTmp[nItem][05] := ACG->ACG_STATUS	// Status 
			aColsTmp[nItem][06] := ACG->ACG_DTVENC	// Vencimento
			aColsTmp[nItem][07] := ACG->ACG_DTREAL	// Vencimento Real
			aColsTmp[nItem][08] := ACG->ACG_VALOR	// Valor
			aColsTmp[nItem][09] := ACG->ACG_RECEBE	// Valor receber
			aColsTmp[nItem][10] := ACG->ACG_JUROS	// Juros
			aColsTmp[nItem][11] := ACG->ACG_DESCFI	// Desc. Financeiro
			aColsTmp[nItem][12] := ACG->ACG_LIDESC	// Limite Desconto
			aColsTmp[nItem][13] := ACG->ACG_ACRESC	// Acréscimo
			aColsTmp[nItem][14] := ACG->ACG_DECRES	// Decréscimo
			aColsTmp[nItem][15] := ACG->ACG_PROMOC	// Promoção
			aColsTmp[nItem][16] := ACG->ACG_OPERAD	// Responsável
			aColsTmp[nItem][17] := Posicione("SU7",1,xFilial("SU7")+ACG->ACG_OPERAD,"U7_NOME")	// Nome
			aColsTmp[nItem][18] := ACG->ACG_VALJUR	// Tx Permanência 
			aColsTmp[nItem][19] := ACG->ACG_PORJUR	// Porc. Juros
			aColsTmp[nItem][20] := ACG->ACG_NATURE	// Natureza
			aColsTmp[nItem][21] := Posicione("SED",1,cFilAte + ACG->ACG_NATURE,"ED_DESCRIC")	// Descrição Natureza
			aColsTmp[nItem][22] := Posicione("SX5",1,xFilial("SX5") + "05" + ACG->ACG_TIPO,"X5DESCRI()")	// Descrição
			aColsTmp[nItem][23] := ACG->ACG_NUMBCO	// Nº banco
			aColsTmp[nItem][24] := ACG->ACG_IRRF	// IRRF
			aColsTmp[nItem][25] := ACG->ACG_ISS		// ISS
			aColsTmp[nItem][26] := ACG->ACG_CSLL	// CSLL
			aColsTmp[nItem][27] := ACG->ACG_COFINS	// COFINS
			aColsTmp[nItem][28] := ACG->ACG_PIS		// PIS
			aColsTmp[nItem][29] := ACG->ACG_HIST	// Desc. tipo
			aColsTmp[nItem][30] := ACG->ACG_VALREF	// Referencia
			aColsTmp[nItem][31] := ACG->ACG_FILORI	// Fil. Origem
			aColsTmp[nItem][32] := ACG->ACG_MULTA	// Multa
			aColsTmp[nItem][33] := ACG->ACG_DESCJU	// Desc. Juros
			aColsTmp[nItem][34] := .F.  
			
			If SE1->(DbSeek(ACG->ACG_FILORI + cCodCli + cLojCli + ACG->ACG_PREFIX + ACG->ACG_TITULO + ACG->ACG_PARCEL + ACG->ACG_TIPO))

				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³   Retorno   ³ExpA1: Array com a seguinte estrutura                        ³
				//³             ³       [1] Valor Original do Titulo                          ³
				//³             ³       [2] Abatimentos                                       ³
				//³             ³       [3] Pagto Parcial                                     ³
				//³             ³       [4] Decrescimo                                        ³
				//³             ³       [5] Acrescimo                                         ³
				//³             ³       [6] Saldo do Titulo na Moeda do Titulo                ³
				//³             ³       [7] Saldo do Titulo na Moeda Corrente                 ³
				//³             ³       [8] Juros                                             ³
				//³             ³       [9] Desconto                                          ³
				//³             ³       [10] Correcao Monetaria                               ³
				//³             ³       [11] Valor a ser Recebido na moeda do titulo          ³
				//³             ³       [12] Valor a ser Recebido na moeda corrente           ³
				//³             ³       [13] Multa                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/ 
		
				aValores := FaVlAtuCr(	NIL		, NIL	, NIL	, NIL	,;
										ACG->ACG_FILORI, .T.	)
						  					
				// [2] Abatimentos
				// [A] Correcao Monetaria
				// [8] Juros
				// [5] Acrescimo  - E1_SDACRES
				// [4] Decrescimo - E1_SDDECRE
				// [9] Desconto
				// [1] Valor Original do Titulo
				// [6] Saldo do Titulo na Moeda do Titulo
				// [7] Saldo do Titulo na Moeda Corrente
				// [3] Pagto Parcial
				// [B] Valor a ser Recebido na moeda do titulo
				// [C] Valor a ser Recebido na moeda corrente
				
				aRdpTlc[1][2]	:= aRdpTlc[1][2] + aValores[2]
				aRdpTlc[2][2]	:= aRdpTlc[2][2] + aValores[10]
				aRdpTlc[3][2]	:= aRdpTlc[3][2] + aValores[8]
				aRdpTlc[4][2]	:= aRdpTlc[4][2] + ACG->ACG_ACRESC
				aRdpTlc[5][2]	:= aRdpTlc[5][2] + ACG->ACG_DECRES
				aRdpTlc[6][2]	:= aRdpTlc[6][2]
				aRdpTlc[7][2]	:= aRdpTlc[7][2] + aValores[1]
				aRdpTlc[8][2]	:= aRdpTlc[8][2] + aValores[6]
				aRdpTlc[9][2]	:= aRdpTlc[9][2] + aValores[7]
				aRdpTlc[10][2]	:= aRdpTlc[10][2] + aValores[3]
				aRdpTlc[11][2]	:= aRdpTlc[11][2] + aValores[11] + aValores[9]
				aRdpTlc[12][2]	:= aRdpTlc[12][2] + aValores[12] + aValores[9]
							
			Endif

			ACG->(DbSkip())
		EndDo 
	     
	EndIf
	
	// Carrega a Observação  
	cMObs:= ""
	cMObs:= fBuscaMemo(cFilAte,cMCodObs,"ACF_CODOBS") // MSMM(cMCodObs,TamSx3("ACF_OBS")[1])
	oMObs:Refresh()

	// Carrega o motivo do encerramento  
	cMEnc:= ""
	cMEnc:= fBuscaMemo(cFilAte,cMCodEnc,"ACF_CODMOT") // MSMM(cMCodEnc,TamSx3("ACF_OBSMOT")[1])
	oMEnc:Refresh() 
	
	// Carrega o motivo do cancelamento   
	cMCan:= ""
	cMCan:= fBuscaMemo(cFilAte,cMCodCan,"ACF_CCANC") // MSMM(cMCodCan,TamSx3("ACF_OBSCAN")[1])
	oMCan:Refresh()
  
EndIf

If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead2a7)+1))
Endif 
oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh() 

For nK := 1 to Len(aRdpTlc)
	aRdpTlc[nK][1]:Refresh() 
Next nK

RestArea(aAreaACG)

Return (.T.) 
     
  
//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd2a8
Atualiza o grid inferior com base no item posicionado no grid superior

@sample		fAtuGrd2a8()

@author		Alessandro Smaha
@since		26/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd2a8( aColsTmp, oItTmp )

Local nK := 0                             
Local nItem := 0  
Local cFilChm  := ""
Local cCodChm  := "" 
Local cTipo    := ""
Local aAreaAB2 := AB2->(GetArea())
            
DbSelectArea("AB2")
AB2->(DbSetOrder(1)) // AB2_FILIAL+AB2_NRCHAM+AB2_ITEM+AB2_CODPRO+AB2_NUMSER

aColsTmp := {} 

If Len(oGrid1a8:aCols) > 0  .and. !Empty(oGrid1a8:aCols[oGrid1a8:nAt][3])
   
	cFilChm := oGrid1a8:aCols[oGrid1a8:nAt][2]
	cCodChm := oGrid1a8:aCols[oGrid1a8:nAt][3] 

	If AB2->(DbSeek(cFilChm+cCodChm)) 
		
		While AB2->(!Eof()) .AND. cFilChm == AB2->AB2_FILIAL .AND. cCodChm == AB2->AB2_NRCHAM 
	         
	        cTipo := ""
	        
	        If AB2->AB2_TIPO == "1" // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk
	        	cTipo := "Chamado"
	        ElseIf AB2->AB2_TIPO == "2"
	        	cTipo := "Orçamento"
	        ElseIf AB2->AB2_TIPO == "3"
	        	cTipo := "O.S"
	        ElseIf AB2->AB2_TIPO == "4"
	        	cTipo := "Suspenso"
	        ElseIf AB2->AB2_TIPO == "5"
	        	cTipo := "Encerrado"
	        ElseIf AB2->AB2_TIPO == "6"
	        	cTipo := "Help Desk"
	        EndIf
	         
	        nItem++
	        
			aAdd(aColsTmp,Array(Len(aHead2a8)+1)) 
		            
			aColsTmp[nItem][01] := AB2->AB2_ITEM	 	  	// Item
			aColsTmp[nItem][02] := cTipo					// Situação  
			aColsTmp[nItem][03] := Alltrim(AB2->AB2_CLASSI) + "-" + Alltrim(Posicione("SX5",1,xFilial("SX5") + "A3" + AB2->AB2_CLASSI,"X5DESCRI()"))	   		// Classificação
			aColsTmp[nItem][04] := AB2->AB2_CODPRO   		// Produto/equipamento
			aColsTmp[nItem][05] := AB2->AB2_X_DESC			// Descrição
			aColsTmp[nItem][06] := AB2->AB2_NUMSER 	   		// Numero serie
			aColsTmp[nItem][07] := AB2->AB2_XQTDIN 	   		// Quantidade
			aColsTmp[nItem][08] := AB2->AB2_CODPRB 			// Ocorrência
			aColsTmp[nItem][09] := Posicione( "AAG", 1, xFilial( "AAG" ) + AB2->AB2_CODPRB, "AAG_DESCRI")  	// Descrição
			aColsTmp[nItem][10] := AB2->AB2_BXDATA			// Data encerramento
			aColsTmp[nItem][11] := AB2->AB2_BXHORA 			// Hora encerramento
			aColsTmp[nItem][12] := fBuscaMemo(cFilChm,AB2->AB2_MEMO,"AB2_MEMO") // Alltrim(MSMM(AB2->AB2_MEMO,TamSx3("AB2_MEMO2")[1])) 						// Comentário
			aColsTmp[nItem][13] := .F.
			    
			AB2->(DbSkip())
			
		EndDo
		
	EndIf    
	     
EndIf

If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead2a8)+1))
Endif 

oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh()
 
RestArea(aAreaAB2)

Return (.T.)



//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd2a9
Atualiza o grid inferior com base no item posicionado no grid superior

@sample		fAtuGrd2a9()

@author		Alessandro Smaha
@since		04/02/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd2a9( aColsTmp, oItTmp )

Local nK := 0                             
Local nItem := 0  
Local cFilOrS  := ""
Local cCodOrS  := "" 
Local cTipo    := ""
Local aAreaAB7 := AB7->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaAAG := AAG->(GetArea())
Local aAreaSU5 := SU5->(GetArea())
            
DbSelectArea("AB7")
AB7->(DbSetOrder(1)) // AB7_FILIAL+AB7_NUMOS+AB7_ITEM

aColsTmp := {} 

If Len(oGrid1a9:aCols) > 0  .and. !Empty(oGrid1a9:aCols[oGrid1a9:nAt][3])
   
	cFilOrS := oGrid1a9:aCols[oGrid1a9:nAt][2]
	cCodOrS := oGrid1a9:aCols[oGrid1a9:nAt][3] 

	If AB7->(DbSeek(cFilOrS+cCodOrS)) 
		
		While AB7->(!Eof()) .AND. cFilOrS == AB7->AB7_FILIAL .AND. cCodOrS == AB7->AB7_NUMOS 
	           
	        cTipo := ""
	        
	        If AB7->AB7_TIPO == "1"
	        	cTipo := "O.S."
	        ElseIf AB7->AB7_TIPO == "2"
	        	cTipo := "Pedido Gerado"
	        ElseIf AB7->AB7_TIPO == "3"
	        	cTipo := "Em Atendimento"
	        ElseIf AB7->AB7_TIPO == "4"
	        	cTipo := "Atendido"
	        ElseIf AB7->AB7_TIPO == "5"
	        	cTipo := "Encerrado"
	        EndIf
	        
	        nItem++
	        
			aAdd(aColsTmp,Array(Len(aHead2a9)+1)) 
		            
			aColsTmp[nItem][01] := AB7->AB7_ITEM	 	  	// Item
			aColsTmp[nItem][02] := cTipo					// Situação  
			aColsTmp[nItem][03] := AB7->AB7_CODPRO	   		// Produto/Eqto
			aColsTmp[nItem][04] := Posicione("SB1",1,xFilial("SB1")+AB7->AB7_CODPRO,"B1_DESC")	// Descrição
			aColsTmp[nItem][05] := AB7->AB7_NUMSER			// Num. Série
			aColsTmp[nItem][06] := AB7->AB7_NRCHAM 	   		// Num. Chamado
			aColsTmp[nItem][07] := AB7->AB7_NUMORC 	   		// Num. Orçamento
			aColsTmp[nItem][08] := AB7->AB7_CODPRB 			// Ocorrência
			aColsTmp[nItem][09] := Posicione( "AAG", 1, xFilial( "AAG" ) + AB7->AB7_CODPRB, "AAG_DESCRI")	// Descrição
			aColsTmp[nItem][10] := fBuscaMemo(cFilOrS,AB7->AB7_MEMO1,"AB7_MEMO1") // Alltrim(MSMM(AB7->AB7_MEMO1,TamSx3("AB7_MEMO2")[1]))	// Obs. Ocorrência
			aColsTmp[nItem][11] := fBuscaMemo(cFilOrS,AB7->AB7_MEMO3,"AB7_MEMO3") // Alltrim(MSMM(AB7->AB7_MEMO3,TamSx3("AB7_MEMO4")[1]))	// Solução
			aColsTmp[nItem][12] := AB7->AB7_XQTDIN 			// Qtde. Instalação
			aColsTmp[nItem][13] := AB7->AB7_CODCON 			// Contato
			aColsTmp[nItem][14] := Posicione("SU5",1,xFilial("SU5")+AB7->AB7_CODCON,"U5_CONTAT")	// Nome
			aColsTmp[nItem][15] := POSICIONE('AAG',1,XFILIAL('AAG')+AB7->AB7_CODPRB,'AAG_DESCRI') //AB7->AB7_DSCOCO			// Desc. Ocorrência
			aColsTmp[nItem][16] := .F.
			  
			AB7->(DbSkip())
			
		EndDo
		
	EndIf    
	     
EndIf

If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead2a9)+1))
Endif 
   
oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh()
 
RestArea(aAreaAB7)
RestArea(aAreaSB1)
RestArea(aAreaAAG)
RestArea(aAreaSU5)

Return (.T.)  


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd3a9
Atualiza o grid inferior com base no item posicionado no grid superior

@sample		fAtuGrd3a9()

@author		Alessandro Smaha
@since		04/02/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd3a9( aColsTmp, oItTmp )

Local nK := 0                             
Local nItem := 0  
Local cFilOrS  := ""
Local cCodOrS  := "" 
Local cCodIte  := "" 
Local cTipo    := ""
Local aAreaAB8 := AB8->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaAA5 := AA5->(GetArea())
            
DbSelectArea("AB8")
AB8->(DbSetOrder(1)) // AB8_FILIAL+AB8_NUMOS+AB8_ITEM+AB8_SUBITE

aColsTmp := {} 

If Len(oGrid1a9:aCols) > 0 .AND. Len(oGrid2a9:aCols) > 0 .and. !Empty(oGrid1a9:aCols[oGrid1a9:nAt][3]) .and. !Empty(oGrid2a9:aCols[oGrid2a9:nAt][1])
   
	cFilOrS := oGrid1a9:aCols[oGrid1a9:nAt][2]
	cCodOrS := oGrid1a9:aCols[oGrid1a9:nAt][3] 
	cCodIte := oGrid2a9:aCols[oGrid2a9:nAt][1] 

	If AB8->(DbSeek(cFilOrS+cCodOrS+cCodIte)) 
		
		While AB8->(!Eof()) .AND. cFilOrS == AB8->AB8_FILIAL .AND. cCodOrS == AB8->AB8_NUMOS .AND. cCodIte == AB8->AB8_ITEM
	      
	        nItem++
	        
			aAdd(aColsTmp,Array(Len(aHead3a9)+1)) 
		            
			aColsTmp[nItem][01] := AB8->AB8_SUBITE	 	  	// Sub Item
			aColsTmp[nItem][02] := AB8->AB8_CODPRO	   		// Produto/Eqto
			aColsTmp[nItem][03] := Posicione("SB1",1,xFilial("SB1")+AB8->AB8_CODPRO,"B1_DESC")		// Descrição
			aColsTmp[nItem][04] := AB8->AB8_CODSER			// Serviço
			aColsTmp[nItem][05] := Posicione("AA5",1,xFilial("AA5")+AB8->AB8_CODSER,"AA5_DESCRI")	// Descrição
			aColsTmp[nItem][06] := AB8->AB8_QUANT 	   		// Quantidade
			aColsTmp[nItem][07] := AB8->AB8_VUNIT 			// Valor Unitário
			aColsTmp[nItem][08] := AB8->AB8_TOTAL 			// Valor Total
			aColsTmp[nItem][09] := .F.
			  	
			AB8->(DbSkip())
			
		EndDo
		
	EndIf    
	     
EndIf

If Empty(aColsTmp)
	aAdd(aColsTmp,Array(Len(aHead3a9)+1))
Endif 
   
oItTmp:SetArray(aColsTmp)                              
oItTmp:Refresh()
 
RestArea(aAreaAB8)
RestArea(aAreaSB1)
RestArea(aAreaAA5)

Return (.T.)  


//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaPreco
Rotina para buscar os preços da tabela de preço

@sample		fBuscaPreco()

@author		Alessandro Smaha
@since		10/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fBuscaPreco( cCodPro, nValPreco, nTMenor, nTMaior, cTMenor, cTMaior )

Local cQuery 	:= ""
Local cTabPar	:= GetMV("ST_TABPRC",,"")  
Local aTabPar	:= {}     
Local nK  		:= 0

If !Empty(cTabPar)
	aTabPar := Separa(cTabPar,';',.F.)
	cTabPar := ""
	For nK := 1 to Len(aTabPar)
		cTabPar += IIF(Empty(cTabPar),"","','")+aTabPar[nK]
	Next nK
EndIf

If (Select("QPRC") <> 0)
	DbSelectArea("QPRC")
	QPRC->(DbCloseArea())
Endif

cQuery += " SELECT TIPO, DA0_CODTAB, DA0_DESCRI, PRCMENOR, PRCMAIOR "
cQuery += " FROM (	SELECT TOP 1 'MENOR' TIPO, DA0_CODTAB, DA0_DESCRI, DA1_PRCVEN PRCMENOR, 0 PRCMAIOR "
cQuery += " 		FROM "+RetSQLName("DA1")+" DA1 "
cQuery += " 		INNER JOIN "+RetSQLName("DA0")+" DA0 ON DA1_CODTAB = DA0_CODTAB AND DA0_ATIVO = '1' "
cQuery += " 			AND DA0_DATDE <= '"+DtoS(dDataBase)+"' AND DA0_DATATE >= '"+DtoS(dDataBase)+"' "
If !Empty(cTabPar)
	cQuery += " 			AND DA0_CODTAB IN ('"+cTabPar+"') "		
EndIf
cQuery += " 			AND DA0.D_E_L_E_T_ <> '*' "
cQuery += " 		WHERE DA1_CODPRO = '"+cCodPro+"' "
cQuery += " 			AND DA1_PRCVEN < "+cValToChar(nValPreco)+" "
cQuery += " 			AND DA1.D_E_L_E_T_ <> '*' "
cQuery += " 		ORDER BY PRCMENOR DESC) AS A "
cQuery += " UNION ALL "
cQuery += " SELECT TIPO, DA0_CODTAB, DA0_DESCRI, PRCMENOR, PRCMAIOR "
cQuery += " FROM (	SELECT TOP 1 'MAIOR' TIPO, DA0_CODTAB, DA0_DESCRI, 0 PRCMENOR, DA1_PRCVEN PRCMAIOR "
cQuery += " 		FROM "+RetSQLName("DA1")+" DA1 "
cQuery += " 		INNER JOIN "+RetSQLName("DA0")+" DA0 ON DA1_CODTAB = DA0_CODTAB AND DA0_ATIVO = '1' "
cQuery += " 			AND DA0_DATDE <= '"+DtoS(dDataBase)+"' AND DA0_DATATE >= '"+DtoS(dDataBase)+"' "
If !Empty(cTabPar)
	cQuery += " 			AND DA0_CODTAB IN ('"+cTabPar+"') "	
EndIf
cQuery += " 			AND DA0.D_E_L_E_T_ <> '*' "
cQuery += " 		WHERE DA1_CODPRO = '"+cCodPro+"' "
cQuery += " 			AND DA1_PRCVEN > "+cValToChar(nValPreco)+" "
cQuery += " 			AND DA1.D_E_L_E_T_ <> '*' "
cQuery += " 		ORDER BY PRCMENOR) AS A "

TCQuery cQuery new Alias "QPRC"
 
nTMenor := 0
cTMenor := ""
nTMaior := 0
cTMaior := ""
			
QPRC->(DbGoTop())

If QPRC->(!Eof())
	While QPRC->(!Eof())
		If AllTrim(QPRC->TIPO) == "MENOR"
			//cPrcMenor := "["+Alltrim(QPRC->DA0_CODTAB) + "-"+ Alltrim(QPRC->DA0_DESCRI) + "] " + cValToChar(QPRC->PRCMENOR)
			nTMenor := QPRC->PRCMENOR
			cTMenor := 	Alltrim(QPRC->DA0_DESCRI)
		ElseIf AllTrim(QPRC->TIPO) == "MAIOR"
			//cPrcMaior := cValToChar(QPRC->PRCMAIOR) + " [" + Alltrim(QPRC->DA0_CODTAB) + "-"+ Alltrim(QPRC->DA0_DESCRI) + "]"
			nTMaior := QPRC->PRCMAIOR
			cTMaior := Alltrim(QPRC->DA0_DESCRI)
		EndIf
		QPRC->(DbSkip())
	EndDo
	QPRC->(DbCloseArea())
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaPer
Busca notas faturadas do cliente

@sample		fBuscaPer()

@author		Alessandro Smaha
@since		05/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fBuscaPer(cCodCli,cLojCli,dDataMin,dDataMax,nContDoc)

Local cQuery 	:= "" 

If (Select("QTMP") <> 0)
	DbSelectArea("QTMP")
	QTMP->(DbCloseArea())
Endif

cQuery := " SELECT 'MIN' TIPO, MIN(D2_EMISSAO) EMISSAO "
cQuery += " FROM "+RetSQLName("SD2")+" SD2 "
cQuery += " WHERE D2_CLIENTE = '"+cCodCli+"' "
cQuery += " 	AND D2_LOJA = '"+cLojCli+"' "
cQuery += " 	AND D2_CF IN ('"+cParCfop + "','" + cParComo+"') "
cQuery += " 	AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " UNION ALL "
cQuery += " SELECT 'MAX' TIPO, MAX(D2_EMISSAO) EMISSAO "
cQuery += " FROM "+RetSQLName("SD2")+" SD2 "
cQuery += " WHERE D2_CLIENTE = '"+cCodCli+"' "
cQuery += " 	AND D2_LOJA = '"+cLojCli+"' "
cQuery += " 	AND D2_CF IN ('"+cParCfop + "','" + cParComo+"') "
cQuery += " 	AND SD2.D_E_L_E_T_ <> '*' "

TCQuery cQuery new Alias "QTMP"

QTMP->(DbGoTop())

If QTMP->(!Eof())
	While QTMP->(!Eof())
		If Empty(dDataMin)
			dDataMin := StoD(QTMP->EMISSAO)
		ElseIf Empty(dDataMax)
			dDataMax := StoD(QTMP->EMISSAO)
		Else
			Exit
		EndIf
		QTMP->(DbSkip())
	EndDo
EndIf

If (Select("QTMP") <> 0)
	DbSelectArea("QTMP")
	QTMP->(DbCloseArea())
Endif

cQuery := " SELECT COUNT(*) TOTAL "
cQuery += " FROM "+RetSQLName("SD2")+" SD2 "
cQuery += " WHERE D2_CLIENTE = '"+cCodCli+"' "
cQuery += " 	AND D2_LOJA = '"+cLojCli+"' "
cQuery += " 	AND D2_CF IN ('"+cParCfop + "','" + cParComo+"') "
cQuery += " 	AND SD2.D_E_L_E_T_ <> '*' "

TCQuery cQuery new Alias "QTMP"

QTMP->(DbGoTop())

If QTMP->(!Eof())
	nContDoc := QTMP->TOTAL
EndIf

Return
     

//-------------------------------------------------------------------
/*/{Protheus.doc} fFiltraCols
Realiza o filtro do grid

@sample		fFiltraCols()

@author		Alessandro Smaha
@since		05/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fFiltraCols( nTamHead, cTipo ) 
  
Local aCampos		:= {} 
Local aIndexQPER 	:= {}        
Local nItem 		:= 0  
Local aStruFIL 		:= {}
Local cCampos		:= ""
Local cFiltroOld  	:= ""
Local cFiltroNew  	:= "" 
Local nTendMenor 	:= 0
Local nTendMaior 	:= 0
Local cTendMenor	:= ""
Local cTendMaior	:= "" 
Local cAliasTmp		:= ""  
Local nI			:= 0

If cTipo == "1A1"
	
	cAliasTmp	:= "QPER"
	cCampos		:= "D2_FILIAL|D2_COD|B1_DESC|D2_EMISSAO"	

ElseIf cTipo == "1A2" 

	cAliasTmp	:= "QHIS"
	cCampos		:= 	"UA_FILIAL|UA_NUM|UA_EMISSAO|UA_VEND|UA_DESCVEN|UA_OPER|UA_CODCONT|UA_DESCNT|UA_NUMSC5|"+;
						"UA_STATUS|UA_XPEDREM|UA_VALBRUT|UA_DESCCAM|UA_DOC|UA_SERIE|UA_EMISNF|UA_CONDPG|UA_PROXLIG|UA_HRPEND"	

ElseIf cTipo == "1A3" 

	cAliasTmp	:= "QLIB"
	cCampos		:= 	"UA_FILIAL|UA_NUM|UA_EMISSAO|UA_NUMSC5|C5_XULIBCR|C5_XDLIBCR|C5_XHLIBCR|C5_XULIBET|C5_XDLIBET|C5_XHLIBET|"+;
						"C5_XULIBRG|C5_XDLIBRG|C5_XHLIBRG|C5_USERLGA|C5_XDALTER|C5_XHALTER|C5_XUSRSOL|C5_XMOTALT" 

ElseIf cTipo == "1A4" 

	cAliasTmp	:= "QNRM"
	cCampos		:= 	"F2_FILIAL|F2_DOC|F2_SERIE|F2_EMISSAO|F2_VALBRUT|UA_NUM|UA_EMISSAO|UA_OPERADO|UA_VEND|UA_DESCNT|UA_NUMSC5" 
 
ElseIf cTipo == "1A5" 

	cAliasTmp	:= "QSAC"
	cCampos		:= 	"UC_FILIAL|UC_CODIGO|UC_CODCONT|UC_DATA|UC_INICIO|UC_OPERADO|UC_OPERACA|UC_STATUS|UC_DESCDE|UC_DESCPAR|"+;
						"UC_DESCCAU|UC_VLRFRET|UC_VLRBOL|UC_NF|UC_SERIE|UC_CODCAMP|UC_MIDIA|UC_PENDENT|UC_HRPEND" 

ElseIf cTipo == "1A6" 

	cAliasTmp	:= "QDEV"
	cCampos		:= 	"F1_FILIAL|UA_NUM|D2_PEDIDO|UA_EMISSAO|D2_PEDIDO|F1_DOC|F1_SERIE|F1_EMISSAO|F1_VALBRUT|F2_DOC|"+;
						"F2_SERIE|F2_EMISSAO|F2_VALBRUT|UA_OPERADO|UA_VEND|UA_CODCONT" 
 
ElseIf cTipo == "1A7" 

	cAliasTmp	:= "QCOB"
	cCampos		:= 	"ACF_FILIAL|ACF_CODIGO|ACF_DATA|ACF_CODCON|ACF_OPERAD|ACF_OPERA|ACF_STATUS|ACF_MOTIVO|ACF_PENDEN" 

ElseIf cTipo == "1A8" 

	cAliasTmp	:= "QTEC"
	cCampos		:= 	"AB1_FILIAL|AB1_NRCHAM|AB1_EMISSA|AB1_HORA|AB1_ATEND|AB1_NUMTMK|AB1_XCDEND|AB1_XTIPO" 

ElseIf cTipo == "1A9" 

	cAliasTmp	:= "QORS"
	cCampos		:= 	"AB6_FILIAL|AB6_NUMOS|AB6_EMISSA|AB6_STATUS|AB6_ATEND|AB6_HORA|AB6_XLIBER|AB6_XCDTEC|AA1_NOMTEC|AB6_XCDAUX|AB6_XCDEND|AB6_XDATPR" 
	 						
EndIf
	
aStruFIL := (cAliasTmp)->(DbStruct()) 
 
//SX3->(DbSetOrder(2))

//For nI := 1 to len(aStruFIL)
	
//	If SX3->(DbSeek(aStruFIL[nI][1])) .AND. Alltrim(SX3->X3_CAMPO) $ cCampos
		
//		AADD(aCampos,{	SX3->X3_CAMPO,;
//						X3Titulo(),;
//			  			If(!x3Uso(SX3->X3_USADO),.F.,.T.),;
//						SX3->X3_ORDEM,;
//						SX3->X3_TAMANHO,;
//						Trim(SX3->X3_PICTURE),;
//						SX3->X3_TIPO,;
//						SX3->X3_DECIMAL})
//	Endif
		
//Next nI
 
(cAliasTmp)->(DBClearFilter())

cFiltroOld  := "" 

If cTipo == "1A1"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a1, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
ElseIf cTipo == "1A2"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a2, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
ElseIf cTipo == "1A3"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a3, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
ElseIf cTipo == "1A4"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a4, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
ElseIf cTipo == "1A5"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a5, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
ElseIf cTipo == "1A6"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a6, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
ElseIf cTipo == "1A7"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a7, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
ElseIf cTipo == "1A8"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a8, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
ElseIf cTipo == "1A9"
	cFiltroNew  := BuildExpr(cAliasTmp,oGrid1a9, cFiltroOld, .F. /*lTopFilter*/,/*bOk*/, /*oDlg*/,/*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, aCampos )
EndIf

If !Empty(cFiltroNew)
	
	(cAliasTmp)->(dbSetFilter({|| &cFiltroNew}, cFiltroNew))
		
Else 

	(cAliasTmp)->(DBClearFilter())

EndIf  

(cAliasTmp)->(DbgoTop())

aColsFil := {}

If cTipo == "1A1" 

	fColsGrid(cTipo,nTamHead,@aColsFil)

	oGrid1a1:SetArray(aColsFil)	
	oGrid1a1:Refresh()
			
ElseIf cTipo == "1A2" 
			
	fColsGrid(cTipo,nTamHead,@aColsFil)

	oGrid1a2:SetArray(aColsFil)	
	oGrid1a2:Refresh()
 		
ElseIf cTipo == "1A3"
	
	fColsGrid(cTipo,nTamHead,@aColsFil)

	oGrid1a3:SetArray(aColsFil)	
	oGrid1a3:Refresh()

ElseIf cTipo == "1A4"
	
	fColsGrid(cTipo,nTamHead,@aColsFil)
	
	oGrid1a4:SetArray(aColsFil)	
	oGrid1a4:Refresh()
 
ElseIf cTipo == "1A5"
	
	fColsGrid(cTipo,nTamHead,@aColsFil)

	oGrid1a5:SetArray(aColsFil)	
	oGrid1a5:Refresh()

ElseIf cTipo == "1A6"
	
	fColsGrid(cTipo,nTamHead,@aColsFil)

	oGrid1a6:SetArray(aColsFil)	
	oGrid1a6:Refresh()
 
ElseIf cTipo == "1A7"
	
	fColsGrid(cTipo,nTamHead,@aColsFil)

	oGrid1a7:SetArray(aColsFil)	
	oGrid1a7:Refresh()

ElseIf cTipo == "1A8"
	
	fColsGrid(cTipo,nTamHead,@aColsFil)

	oGrid1a8:SetArray(aColsFil)	
	oGrid1a8:Refresh()
       
ElseIf cTipo == "1A9"
	
	fColsGrid(cTipo,nTamHead,@aColsFil)

	oGrid1a9:SetArray(aColsFil)	
	oGrid1a9:Refresh()
              
EndIf
	
(cAliasTmp)->(DBClearFilter())  

Return    


//-------------------------------------------------------------------
/*/{Protheus.doc} fPesqCols
Realiza a pesquisa no grid

@sample		fPesqCols()

@author		Alessandro Smaha
@since		05/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fPesqCols(oGridTmp)

Local oDlgPsq
Local oCbx
Local oBigGet
Local cOrd	 := ""
Local aOrd	 := {}
Local cCampo := Space(70)
Local lSeek	 := .F.
Local nSeek	 := 0
Local nOrdem := 1
Local nI
Local nOrdAux	:= 0
Local aListPsq	:= aClone(oGridTmp:aCols)
Local aCbx		:= {}
Local cData		:= ''
Local oPsqGet

For nI := 1 To Len( oGridTmp:aHeader )
	aAdd( aCbx, oGridTmp:aHeader[ nI, 1 ] )
Next nI

cCampo := Space( 40 )

DEFINE MSDIALOG oDlgPsq FROM 00,00 TO 100,490 PIXEL TITLE "Pesquisa"

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlgPsq ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlgPsq ENABLE ACTION (lSeek := .T.,oDlgPsq:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlgPsq ENABLE ACTION oDlgPsq:End()

ACTIVATE MSDIALOG oDlgPsq CENTERED

If lSeek .AND. Len(aListPsq) > 0
	
	nOrdem := Ascan(oGridTmp:aHeader, { |x| Alltrim(x[1]) == Alltrim(aCbx[nOrdem]) } )
	
	aListPsq := aSort( oGridTmp:aCols,,,{ |x,y| x[nOrdem] < y[nOrdem] })
	
	If Valtype(aListPsq[1][nOrdem]) == "C"
		nSeek := Ascan( aListPsq, { |x| Alltrim(x[nOrdem]) = AllTrim(cCampo) })
	ElseIf Valtype(aListPsq[1][nOrdem]) == "N"
		nSeek := Ascan( aListPsq, { |x| x[nOrdem] == Val(cCampo) })
	ElseIf Valtype(aListPsq[1][nOrdem]) == "D"
		nSeek := Ascan( aListPsq, { |x| x[nOrdem] == StoD(Alltrim(cCampo)) })
	EndIf
	
EndIf

oGridTmp:SetArray(aListPsq)
oGridTmp:Refresh()

If	nSeek > 0
	oGridTmp:GoTo(nSeek)
EndIf

Return Nil
       

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetColor
Atualiza a cor da linha do grid

@sample		fGetColor()

@author		Alessandro Smaha
@since		11/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fGetColor(aLinha,nLinha,aHeadTmp,cTipo)

Local nCor1 	:= RGB(255,255,255) // Branco
Local nCor2 	:= RGB(255,187,187) // Rosa
Local nCorRet	:= nCor1
Local nPosTip	:= aScan(aHeadTmp,{|x| Alltrim(x[2]) == "TIPOCN"})

If aLinha[nLinha][nPosTip] == "C"
	nCorRet := nCor2
EndIf

Return nCorRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaQry
Monta a string para as querys

@sample		fMontaQry( cTipoCols, cCodCli, cLojCli, nParPeri, cParTabe )

@author		Alessandro Smaha
@since		10/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fMontaQry( cTipoCols, cCodCli, cLojCli, nParPeri, cParTabe )

Local cQry 		:= ""
Local cFiltro1	:= ""
Local cFiltro2	:= ""
Local cFiltro3	:= ""
Local cFiltro4	:= ""
Local cFiltro5	:= ""
Local cFiltro6	:= ""  

Default cTipoCols := "" 
Default cCodCli   := ""
Default cLojCli	  := ""
Default nParPeri  := 0
Default cParTabe  := ""

If cTipoCols == "1A1"
	
	cQry := " SELECT DISTINCT D.D2_FILIAL, D.D2_COD, B1_DESC, A1_NROCOM, D.D2_EMISSAO, DMIN, E.D2_PRCVEN, TOTAL_NOTAS, TOTAL_ITENS, 'N' TIPO_C_N "
	cQry += " FROM (	SELECT D2_FILIAL, D2_COD, MAX(MAX) D2_EMISSAO, MAX(MIN) DMIN, SUM(TOT_NOTAS) TOTAL_NOTAS, Sum(TOT_ITENS) TOTAL_ITENS "
	cQry += " 		FROM (	SELECT D2_FILIAL, D2_COD, MAX(D2_EMISSAO) MAX, '' MIN, COUNT(*) TOT_NOTAS, Sum(D2_QUANT) TOT_ITENS "
	cQry += " 				FROM "+RetSQLName("SD2")+" A "
	cQry += " 				WHERE D2_CLIENTE = '"+cCodCli+"' "
	cQry += " 					AND D2_LOJA = '"+cLojCli+"' "
	If !Empty(cParCfop)
		cQry += " 					AND D2_CF IN ('"+cParCfop+"') "
	EndIf
	cQry += " 					AND A.D2_EMISSAO BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"' "
	cQry += " 					AND A.D_E_L_E_T_ <> '*' "
	cQry += " 				GROUP BY D2_FILIAL, D2_COD "
	cQry += " 				UNION ALL "
	cQry += " 				SELECT D2_FILIAL, D2_COD, '' MAX, MIN(D2_EMISSAO) MIN, 0 TOT_NOTAS, 0 TOT_ITENS "
	cQry += " 				FROM "+RetSQLName("SD2")+" B "
	cQry += " 				WHERE D2_CLIENTE = '"+cCodCli+"' "
	cQry += " 					AND D2_LOJA = '"+cLojCli+"' "
	If !Empty(cParCfop)
		cQry += " 					AND D2_CF IN ('"+cParCfop+"') "
	EndIf
	cQry += " 					AND DATEDIFF (MONTH,D2_EMISSAO,'"+DtoS(dDataBase)+"') <= "+cValToChar(nParPeri)+" "
	cQry += " 					AND B.D2_EMISSAO BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"' "
	cQry += " 					AND B.D_E_L_E_T_ <> '*' "
	cQry += " 				GROUP BY D2_FILIAL, D2_COD) AS C "
	cQry += " 		GROUP BY D2_FILIAL, D2_COD) AS D "
	cQry += " LEFT JOIN "+RetSQLName("SD2")+" E ON E.D2_FILIAL = D.D2_FILIAL AND E.D2_COD = D.D2_COD AND E.D2_EMISSAO = D.D2_EMISSAO "+;
				"AND E.D2_CLIENTE = '"+cCodCli+"' AND E.D2_LOJA = '"+cLojCli+"' AND E.D_E_L_E_T_ <> '*' "
	cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = D.D2_COD AND SB1.D_E_L_E_T_ <> '*' "
	cQry += " LEFT JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND SB1.D_E_L_E_T_ <> '*' "
	
	If MV_PAR08 == 1 // Exibe comodato ? 1=Sim, 2=Não
		
		cQry += " UNION ALL "
		
		cQry += " SELECT DISTINCT D.D2_FILIAL, D.D2_COD, B1_DESC, A1_NROCOM, D.D2_EMISSAO, DMIN, E.D2_PRCVEN, TOTAL_NOTAS, TOTAL_ITENS, 'C' TIPO_C_N "
		cQry += " FROM (	SELECT D2_FILIAL, D2_COD, MAX(MAX) D2_EMISSAO, MAX(MIN) DMIN, SUM(TOT_NOTAS) TOTAL_NOTAS, Sum(TOT_ITENS) TOTAL_ITENS "
		cQry += " 		FROM (	SELECT D2_FILIAL, D2_COD, MAX(D2_EMISSAO) MAX, '' MIN, COUNT(*) TOT_NOTAS, Sum(D2_QUANT) TOT_ITENS "
		cQry += " 				FROM "+RetSQLName("SD2")+" A "
		cQry += " 				WHERE D2_CLIENTE = '"+cCodCli+"' "
		cQry += " 					AND D2_LOJA = '"+cLojCli+"' "
		If !Empty(cParComo)
			cQry += " 					AND D2_CF IN ('"+cParComo+"') "
		EndIf      
		cQry += " 					AND A.D2_EMISSAO BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"' "
		cQry += " 					AND A.D_E_L_E_T_ <> '*' "
		cQry += " 				GROUP BY D2_FILIAL, D2_COD "
		cQry += " 				UNION ALL "
		cQry += " 				SELECT D2_FILIAL, D2_COD, '' MAX, MIN(D2_EMISSAO) MIN, 0 TOT_NOTAS, 0 TOT_ITENS "
		cQry += " 				FROM "+RetSQLName("SD2")+" B "
		cQry += " 				WHERE D2_CLIENTE = '"+cCodCli+"' "
		cQry += " 					AND D2_LOJA = '"+cLojCli+"' "
		If !Empty(cParComo)
			cQry += " 					AND D2_CF IN ('"+cParComo+"') "
		EndIf
		cQry += " 					AND DATEDIFF (MONTH,D2_EMISSAO,'"+DtoS(dDataBase)+"') <= "+cValToChar(nParPeri)+" "
		cQry += " 					AND B.D2_EMISSAO BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"' "
		cQry += " 					AND B.D_E_L_E_T_ <> '*' "
		cQry += " 				GROUP BY D2_FILIAL, D2_COD) AS C "
		cQry += " 		GROUP BY D2_FILIAL, D2_COD) AS D "
		cQry += " LEFT JOIN "+RetSQLName("SD2")+" E ON E.D2_FILIAL = D.D2_FILIAL AND E.D2_COD = D.D2_COD AND E.D2_EMISSAO = D.D2_EMISSAO "+;
					"AND E.D2_CLIENTE = '"+cCodCli+"' AND E.D2_LOJA = '"+cLojCli+"' AND E.D_E_L_E_T_ <> '*' "
		cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = D.D2_COD AND SB1.D_E_L_E_T_ <> '*' "
		cQry += " LEFT JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND SB1.D_E_L_E_T_ <> '*' "
		
	EndIf
	
	cQry += " ORDER BY D.D2_EMISSAO DESC, D.D2_FILIAL, D.D2_COD "
	
ElseIf cTipoCols == "2A1"
	
	cQry := " SELECT ATIVIDADE, X5_DESCRI, Z10_PRODUT, DA1_PRCVEN, B1_DESC "
	cQry += " FROM (	SELECT A1_SATIV1 ATIVIDADE "
	cQry += " 		FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " 		WHERE A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND A1_SATIV1 <> '' AND SA1.D_E_L_E_T_ <> '*' "
	cQry += " 		UNION ALL "
	cQry += " 		SELECT A1_SATIV2 ATIVIDADE "
	cQry += " 		FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " 		WHERE A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND A1_SATIV2 <> '' AND SA1.D_E_L_E_T_ <> '*' "
	cQry += " 		UNION ALL "
	cQry += " 		SELECT A1_SATIV3 ATIVIDADE "
	cQry += " 		FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " 		WHERE A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND A1_SATIV3 <> '' AND SA1.D_E_L_E_T_ <> '*' "
	cQry += " 		UNION ALL "
	cQry += " 		SELECT A1_SATIV4 ATIVIDADE "
	cQry += " 		FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " 		WHERE A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND A1_SATIV4 <> '' AND SA1.D_E_L_E_T_ <> '*' "
	cQry += " 		UNION ALL "
	cQry += " 		SELECT A1_SATIV5 ATIVIDADE "
	cQry += " 		FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " 		WHERE A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND A1_SATIV5 <> '' AND SA1.D_E_L_E_T_ <> '*' "
	cQry += " 		UNION ALL "
	cQry += " 		SELECT A1_SATIV6 ATIVIDADE "
	cQry += " 		FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " 		WHERE A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND A1_SATIV6 <> '' AND SA1.D_E_L_E_T_ <> '*' "
	cQry += " 		UNION ALL "
	cQry += " 		SELECT A1_SATIV7 ATIVIDADE "
	cQry += " 		FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " 		WHERE A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND A1_SATIV7 <> '' AND SA1.D_E_L_E_T_ <> '*' "
	cQry += " 		UNION ALL "
	cQry += " 		SELECT A1_SATIV8 ATIVIDADE "
	cQry += " 		FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " 		WHERE A1_COD = '"+cCodCli+"' AND A1_LOJA = '"+cLojCli+"' AND A1_SATIV8 <> '' AND SA1.D_E_L_E_T_ <> '*') AS A "
	cQry += " LEFT JOIN "+RetSQLName("Z10")+" Z10 ON Z10_SEGMEN = ATIVIDADE AND Z10.D_E_L_E_T_ <> '*' "
	cQry += " LEFT JOIN "+RetSQLName("SX5")+" SX5 ON X5_TABELA = 'T3' AND X5_CHAVE = ATIVIDADE AND SX5.D_E_L_E_T_ <> '*' "
	cQry += " LEFT JOIN "+RetSQLName("DA1")+" DA1 ON DA1_CODTAB = '"+cParTabe+"' AND DA1_CODPRO = Z10_PRODUT AND DA1.D_E_L_E_T_ <> '*' "
	cQry += " LEFT JOIN "+RetSQLName("SB1")+" SB1 ON Z10_PRODUT = B1_COD AND SB1.D_E_L_E_T_ <> '*' "
	cQry += " WHERE Z10_PRODUT NOT IN (	SELECT D2_COD " 
	cQry += " 							FROM "+RetSQLName("SD2")+" SD2 " 
	cQry += " 							WHERE D2_CLIENTE = '"+cCodCli+"' " 
	cQry += " 								AND D2_LOJA = '"+cLojCli+"' " 
	cQry += " 								AND SD2.D_E_L_E_T_ <> '*') " 
 
ElseIf cTipoCols == "1A2" 
	
	cQry := " SELECT * "
	cQry += " FROM " + RetSqlName("SUA") + " SUA "
	cQry += " WHERE "
	cQry += 		" SUA.UA_CLIENTE='" + cCodCli + "' AND "
	cQry += 		" SUA.UA_LOJA='"    + cLojCli + "' AND "
	cQry += 		" SUA.UA_PROSPEC='" + IIF(lProspect,'T','F') + "' AND "
	cQry += 		" SUA.UA_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' AND "
	cQry += 		" SUA.UA_OPERADO BETWEEN '" + MV_PAR03 + "' AND  '" + MV_PAR04 + "' AND "
	
	If MV_PAR05 <> 1 //Todas
		cQry += 	" SUA.UA_OPER = '" + STR(MV_PAR05-1,1) + "' AND "
	Endif
	
	If MV_PAR06 <> 1 //Todos
		cQry += 	" SUA.UA_TMK = '" + STR(MV_PAR06-1,1) + "' AND "
	Endif
	
	If !Empty(MV_PAR07)//Ocorrencia
		cQry += 	" SUA.UA_CODLIG = '"+ MV_PAR07 + "' AND "
	Endif
	
	cQry += 		" SUA.D_E_L_E_T_<>'*'" 
	
	cQry += " ORDER BY SUA.UA_EMISSAO DESC, SUA.UA_FILIAL, SUA.UA_NUM "

ElseIf cTipoCols == "1A3"
	
	cQry := " SELECT UA_FILIAL, UA_NUM, UA_EMISSAO, UA_NUMSC5, C5_XULIBCR, C5_XDLIBCR, C5_XHLIBCR, C5_XULIBET, C5_XDLIBET, C5_XHLIBET, "
	cQry += " 		C5_XULIBRG, C5_XDLIBRG, C5_XHLIBRG, C5_USERLGA, C5_XDALTER, C5_XHALTER, C5_XUSRSOL, C5_XMOTALT " 
	cQry += " FROM " + RetSqlName("SUA") + " SUA "
	cQry += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = UA_FILIAL AND C5_NUM = UA_NUMSC5 AND SC5.D_E_L_E_T_ <> '*' " 
	cQry += " WHERE UA_CLIENTE = '" + cCodCli + "' " 
	cQry += " 	AND UA_LOJA = '"    + cLojCli + "' " 
	cQry += " 	AND UA_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' "
	cQry += "	AND UA_NUMSC5 <> '' "
	cQry += " 	AND SUA.D_E_L_E_T_ <> '*' " 
	cQry += " ORDER BY SUA.UA_EMISSAO DESC, SUA.UA_FILIAL, SUA.UA_NUM "
					
ElseIf cTipoCols == "1A4"
	  
	cQry := " SELECT F2_FILIAL, UA_NUM, UA_EMISSAO, UA_NUMSC5, F2_DOC, F2_SERIE, F2_EMISSAO, F2_VALBRUT, UA_OPERADO, UA_VEND, UA_DESCNT "
	cQry += " FROM " + RetSqlName("SF2") + " SF2 " 
	cQry += " INNER JOIN " + RetSqlName("SUA") + " SUA ON UA_FILIAL = F2_FILIAL AND UA_DOC = F2_DOC AND F2_SERIE = UA_SERIE AND SUA.D_E_L_E_T_ <> '*' "
	cQry += " WHERE F2_CLIENTE = '" + cCodCli + "' " 
	cQry += " 	AND F2_LOJA = '"    + cLojCli + "' " 	
	cQry += " 	AND F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' "
	cQry += " 	AND SF2.D_E_L_E_T_ <> '*' " 
	cQry += " ORDER BY F2_EMISSAO DESC "	

ElseIf cTipoCols == "1A5"
	 
	cQry := " SELECT * "
	cQry += " FROM " + RetSqlName("SUC") + " SUC "
	cQry += " WHERE UC_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " 
	cQry += " 	AND UC_OPERADO BETWEEN '"+MV_PAR03+"' AND  '"+MV_PAR04+"' "
	cQry += " 	AND UC_ENTIDAD = 'SA1' "
	cQry += " 	AND UC_CHAVE = '" + cCodCli + cLojCli + "' "
	If !Empty(cCodCont)  
		cQry += " 	AND UC_CODCONT	='" + cCodCont + "' "  
	EndIf
	cQry += " 	AND SUC.D_E_L_E_T_ <> '*' "
	cQry += " ORDER BY UC_DATA DESC "

ElseIf cTipoCols == "1A6"            

	cQry := " SELECT F1_FILIAL,UA_NUM,UA_EMISSAO,D2_PEDIDO,F1_DOC,F1_SERIE,F1_EMISSAO,F1_VALBRUT,F2_DOC,F2_SERIE,F2_EMISSAO,F2_VALBRUT,UA_OPERADO,UA_OPERADO,UA_VEND,UA_CODCONT,F1_XUSRDEV,F1_XMOTDEV "
	cQry += " FROM " + RetSqlName("SUA") + " SUA " 
	cQry += " INNER JOIN (SELECT D2_FILIAL,D2_PEDIDO,D2_CLIENTE,D2_LOJA,D2_DOC,D2_SERIE,D2_EMISSAO,D1_DOC,D1_SERIE,D1_EMISSAO "
	cQry += " 			FROM " + RetSqlName("SD2") + " SD2 "
	cQry += " 			INNER JOIN " + RetSqlName("SD1") + " SD1 ON D2_FILIAL = D1_FILIAL AND D2_DOC = D1_NFORI AND D2_SERIE = D1_SERIORI AND D2_CLIENTE = D1_FORNECE AND D2_LOJA = D1_LOJA AND D2_COD = D1_COD AND SD1.D_E_L_E_T_ <> '*' "
	cQry += " 			WHERE D2_CLIENTE = '"+cCodCli+"' AND D2_LOJA = '"+cLojCli+"' AND SD2.D_E_L_E_T_ <> '*' "
	cQry += " 			GROUP BY D2_FILIAL,D2_PEDIDO,D2_CLIENTE,D2_LOJA,D2_DOC,D2_SERIE,D2_EMISSAO,D1_DOC,D1_SERIE,D1_EMISSAO) AS A " 
	cQry += " 	ON D2_FILIAL = UA_FILIAL AND D2_PEDIDO = UA_NUMSC5 " 
	cQry += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON F1_FILIAL = A.D2_FILIAL AND F1_DOC = A.D1_DOC AND F1_SERIE = A.D1_SERIE AND F1_FORNECE = A.D2_CLIENTE AND F1_LOJA = A.D2_LOJA AND (F1_TIPO = 'B' OR F1_TIPO = 'D') AND SF1.D_E_L_E_T_ <> '*' "
	cQry += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON F2_FILIAL = F1_FILIAL AND F2_DOC = A.D2_DOC AND F2_SERIE = A.D2_SERIE AND F2_CLIENTE = A.D2_CLIENTE AND F2_LOJA = A.D2_LOJA "+;
					" AND F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' AND SF2.D_E_L_E_T_ <> '*' "
	cQry += " WHERE SUA.D_E_L_E_T_ <> '*' "   
	cQry += " ORDER BY F2_EMISSAO DESC, F1_FILIAL, UA_NUM "
  
ElseIf cTipoCols == "1A7" 
                               
	cQry := " SELECT ACF_FILIAL,ACF_CODIGO,ACF_CLIENT,ACF_LOJA,ACF_DATA,ACF_CODCON,ACF_OPERAD,ACF_OPERA,ACF_STATUS,ACF_MOTIVO,ACF_PENDEN,ACF_CODCAM,ACF_CODMOT, ACF_CODOBS,ACF_CODMOT,ACF_CCANC " 
	cQry += " FROM " + RetSqlName("ACF") + " ACF " 
	cQry += " WHERE ACF.ACF_CLIENT = '" + cCodCli + "' AND " 
	cQry += " 	ACF.ACF_LOJA = '" + cLojCli + "' AND " 
	cQry += " 	ACF.ACF_DATA 	BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' AND "
	cQry += " 	ACF.ACF_OPERAD 	BETWEEN '" + MV_PAR03 + "' AND  '" + MV_PAR04 + "' AND " 
	cQry += " 	ACF.D_E_L_E_T_ = ' ' "    
 	cQry += " ORDER BY ACF_DATA DESC, ACF_FILIAL, ACF_CODIGO "
 
ElseIf cTipoCols == "1A8" 

	cQry := " SELECT AB1_FILIAL,AB1_NRCHAM,AB1_CODCLI, AB1_LOJA,AB1_EMISSA,AB1_HORA,AB1_ATEND,AB1_NUMTMK,AB1_XCDEND,AB1_XTIPO "
	cQry += " FROM " + RetSqlName("AB1") + " AB1 " 
	cQry += " WHERE AB1_CODCLI = '" + cCodCli + "' "
	cQry += " 	AND AB1_LOJA = '" + cLojCli + "' "    
	cQry += " 	AND AB1.AB1_EMISSA BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' "
	cQry += " 	AND AB1.D_E_L_E_T_ <> '*' "
	cQry += " ORDER BY AB1_EMISSA DESC "

ElseIf cTipoCols == "1A9" 

	cQry := " SELECT AB6_FILIAL,AB6_CODCLI,AB6_LOJA,AB6_NUMOS,AB6_EMISSA,AB6_STATUS,AB6_ATEND,AB6_HORA,AB6_XLIBER,AB6_XCDTEC,"
	cQry += " 	A.AA1_NOMTEC NOME_TEC,AB6_XCDAUX,B.AA1_NOMTEC NOME_AUX,AB6_XCDEND,AB6_XDATPR,AB6_XUSREF, AB6_XDATEF, AB6_XHOREF, ABB_CODTEC "
	cQry += " FROM " + RetSqlName("AB6") + " AB6 "
	cQry += " LEFT JOIN " + RetSqlName("AA1") + " A ON A.AA1_CODTEC = AB6_XCDTEC AND A.D_E_L_E_T_ <> '*' "
	cQry += " LEFT JOIN " + RetSqlName("AA1") + " B ON B.AA1_CODTEC = AB6_XCDAUX AND B.D_E_L_E_T_ <> '*' "
	cQry += " LEFT JOIN " + RetSqlName("ABB") + " C ON C.ABB_FILIAL = AB6_FILIAL AND C.ABB_NUMOS = AB6_NUMOS AND C.D_E_L_E_T_ <> '*' 
	cQry += " WHERE AB6_CODCLI = '" + cCodCli + "' " 
	cQry += "  	AND AB6_LOJA = '" + cLojCli + "' " 
	cQry += "  	AND AB6.AB6_EMISSA BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' "
	cQry += " 	AND AB6.D_E_L_E_T_ <> '*' " 
	cQry += " ORDER BY AB6_EMISSA DESC "
   						
EndIf

Return cQry

                
//-------------------------------------------------------------------
/*/{Protheus.doc} fColsGrid
Atualiza grid

@sample		fColsGrid()

@author		Alessandro Smaha
@since		23/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fColsGrid(cTipoCols,nTamHead,aColsTmp)
                
Local cOperacao  := ""
Local cParTabe   := GetMV("ST_TABHIST",,"")
Local nParPeri   := GetMV("ST_PARPERI",,0)
Local cParUser   := GetMV("ST_USRVIS",,"")
Local nItem      := 0
Local nTendMenor := 0
Local nTendMaior := 0
Local cTendMenor := 0
Local cTendMaior := 0
Local nPerComp   := 0
Local nValUniT   := 0
Local nPrcVenda  := 0
Local cTxtPadRt  := Replicate("*",30)
Local cCodTec    := ""
Local cNomTec    := ""

If cTipoCols == "1A1" 

	QPER->(DbGoTop())
	
	If QPER->(!Eof()) 
	
		While QPER->(!Eof())
			
			fBuscaPreco( QPER->D2_COD, QPER->D2_PRCVEN, @nTendMenor, @nTendMaior, @cTendMenor, @cTendMaior ) 
			
			nValUniT := fBusPrcUn( SA1->A1_COD, SA1->A1_LOJA, QPER->D2_EMISSAO, QPER->D2_COD ) 
			
			nPrcVenda := fPrcVenda( SA1->A1_COD, SA1->A1_LOJA, QPER->D2_EMISSAO, QPER->D2_COD )
						
			If !Empty(QPER->D2_EMISSAO) .AND. !Empty(QPER->DMIN)
				nPerComp := Int( (StoD(QPER->D2_EMISSAO)-StoD(QPER->DMIN)) / (QPER->TOTAL_NOTAS - 1) )
			Else
				nPerComp := 0
			EndIf
			
			nItem++
			aAdd(aColsTmp,Array(nTamHead))
			
			aColsTmp[nItem][1]  := fLeg1a1(nPerComp,StoD(QPER->D2_EMISSAO))
			aColsTmp[nItem][2]  := QPER->D2_FILIAL
			aColsTmp[nItem][3]  := QPER->D2_COD
			aColsTmp[nItem][4]  := QPER->B1_DESC   
			aColsTmp[nItem][5]  := StoD(QPER->D2_EMISSAO)	// Ultima Compra 
			aColsTmp[nItem][6]  := 0				   	   	// Quantidade			
			aColsTmp[nItem][7]  := nPerComp			
			aColsTmp[nItem][8]  := nPrcVenda // UB_XPRCVEN // nValUniT		 
			aColsTmp[nItem][9]  := nValUniT				  
			aColsTmp[nItem][10]  := QPER->D2_PRCVEN	   		// Alltrim(Transform(QPER->PRECO,PesqPict("SD2","D2_TOTAL")))				
			aColsTmp[nItem][11]  := QPER->TOTAL_ITENS   	   	// Quantidade			
			aColsTmp[nItem][12]  := nTendMenor
			aColsTmp[nItem][13] := IIF(Empty(cTendMenor),"n/a",cTendMenor) 			
			aColsTmp[nItem][14] := nTendMaior
			aColsTmp[nItem][15] := IIF(Empty(cTendMaior),"n/a",cTendMaior) 
			aColsTmp[nItem][16] := QPER->TIPO_C_N
			aColsTmp[nItem][17] := .F.
			  			
			QPER->(DbSkip())
		EndDo	
	EndIf
	
ElseIf cTipoCols == "2A1"
	
	QSEG->(DbGoTop())
	
	If QSEG->(!Eof())
		While QSEG->(!Eof())

			nItem++
			aAdd(aColsTmp,Array(nTamHead))
			
			aColsTmp[nItem][1] := QSEG->Z10_PRODUT
			aColsTmp[nItem][2] := QSEG->B1_DESC
			aColsTmp[nItem][3] := QSEG->DA1_PRCVEN
			aColsTmp[nItem][4] := .F.
			
			QSEG->(DbSkip())
		EndDo
	
	EndIf 
	
ElseIf cTipoCols == "1A2"
 
	QHIS->(DbGoTop())
	
	If QHIS->(!Eof())  
	
		While QHIS->(!Eof())

			nItem++
			aAdd(aColsTmp,Array(nTamHead))	
			
			cOperacao := ""
			             
			If Alltrim(QHIS->UA_OPER) == "1"
		   		cOperacao := "Faturamento"			
			ElseIf AllTrim(QHIS->UA_OPER) == "2"
   					 cOperacao := "Orçamento"
   				ElseIf AllTrim(QHIS->UA_OPER) == "3" 
				cOperacao := "Atendimento" 
			EndIf
			   
			aColsTmp[nItem][01] := fLeg1a2()   														// 01 - Status   
			aColsTmp[nItem][02] := QHIS->UA_FILIAL 													// 02 - Filial
			aColsTmp[nItem][03] := QHIS->UA_NUM 													// 02 - Atendimento
			aColsTmp[nItem][04] := StoD(QHIS->UA_EMISSAO) 								   			// 03 - Data	
			aColsTmp[nItem][05] := Posicione("SA3",1,xFilial("SA3")+QHIS->UA_VEND,"A3_NOME")   		// 04 - Vendedor
			aColsTmp[nItem][06] := cOperacao	 								   					// 05 - Operacao
			aColsTmp[nItem][07] := IIF(!Empty(QHIS->UA_CODCONT),Posicione("SU5",1,xFilial("SU5")+QHIS->UA_CODCONT,"U5_CONTAT"),QHIS->UA_DESCNT) 	// 06 - Contato
			aColsTmp[nItem][08] := QHIS->UA_NUMSC5 													// 07 - Pedido
			aColsTmp[nItem][09] := Tk273Status(QHIS->UA_STATUS) 									// 08 - Status
			aColsTmp[nItem][10] := QHIS->UA_XPEDREM 												// 09 - Pedido remessa			
			aColsTmp[nItem][11] := QHIS->UA_VLRLIQ 			  										// 09 - Valor 			
			aColsTmp[nItem][12] := Posicione("SUO",1,QHIS->UA_FILIAL+QHIS->UA_CODCAMP,"UO_DESC") 	// 10 - Campanha	
			aColsTmp[nItem][13] := QHIS->UA_DOC+"/"+QHIS->UA_SERIE 							   		// 11 - NF/SERIE
			aColsTmp[nItem][14] := Stod(QHIS->UA_EMISNF) 								   			// 12 - Emissao
			aColsTmp[nItem][15] := Posicione("SE4",1,xFilial("SE4")+QHIS->UA_CONDPG,"E4_DESCRI") 	// 13 - Condicao de Pagto  
			aColsTmp[nItem][16] := QHIS->UA_PROXLIG											   		// 18 - Retorno
			aColsTmp[nItem][17] := QHIS->UA_HRPEND                                            	   	// 19 - Hora 	
			aColsTmp[nItem][18] := QHIS->UA_CODOBS                                             	  	// 20 - Codigo Observacao
			aColsTmp[nItem][19] := QHIS->UA_CODCANC                                             	// 21 - Codigo do Cancelamento    
			aColsTmp[nItem][20] := .F.

			QHIS->(DbSkip())
		EndDo	
	EndIf 
		
ElseIf cTipoCols == "1A3" 
 
	QLIB->(DbGoTop())
	
	If QLIB->(!Eof())
		While QLIB->(!Eof())

			nItem++
			aAdd(aColsTmp,Array(nTamHead))
			 
			aColsTmp[nItem][01] := fLeg1a3()  
			aColsTmp[nItem][02] := QLIB->UA_FILIAL 				// Filial
			aColsTmp[nItem][03] := QLIB->UA_NUM			   		// Atendimento
			aColsTmp[nItem][04] := StoD(QLIB->UA_EMISSAO)   	// Data Emissao
			aColsTmp[nItem][05] := QLIB->UA_NUMSC5             	// Pedido
			aColsTmp[nItem][06] := QLIB->C5_XULIBCR //UsrFullName(QLIB->C5_XULIBCR)// Usuario Liberou Credito ->Migração 12.1.27
			aColsTmp[nItem][07] := StoD(QLIB->C5_XDLIBCR)   	// Data Liberacao Credito
			aColsTmp[nItem][08] := QLIB->C5_XHLIBCR          	// Hora Liberacao Credito  
			aColsTmp[nItem][09] := QLIB->C5_XULIBET //UsrFullName(QLIB->C5_XULIBET)// Usuario Liberou Estoque ->Migração 12.1.27
			aColsTmp[nItem][10] := StoD(QLIB->C5_XDLIBET)   	// Data Liberacao Estoque
			aColsTmp[nItem][11] := QLIB->C5_XHLIBET        		// Hora Liberacao Estoque
			aColsTmp[nItem][12] := QLIB->C5_XULIBRG // UsrFullName(QLIB->C5_XULIBRG)// Usuario Liberou Regra ->Migração 12.1.27
			aColsTmp[nItem][13] := StoD(QLIB->C5_XDLIBRG)   	// Data Liberacao Regra
			aColsTmp[nItem][14] := QLIB->C5_XHLIBRG          	// Hora Liberacao Regra
			aColsTmp[nItem][15] := UsrFullName(SubStr( Embaralha( QLIB->C5_USERLGA, 1 ), 3, 6 )) // Alltrim(FWLEUSERLG("F1_USERLGI",1)) 	// Usuario Alteracao
			aColsTmp[nItem][16] := StoD(QLIB->C5_XDALTER)   	// Data Alteracao
			aColsTmp[nItem][17] := QLIB->C5_XHALTER          	// Hora Alteracao
			aColsTmp[nItem][18] := QLIB->C5_XUSRSOL //UsrFullName(QLIB->C5_XUSRSOL)// Usuario Solicitante ->Migração 12.1.27
			aColsTmp[nItem][19] := QLIB->C5_XMOTALT	        	// Motivo Solicitação
			aColsTmp[nItem][20] := .F.

			QLIB->(DbSkip())
		EndDo	
	EndIf 

ElseIf cTipoCols == "1A4"

	QNRM->(DbGoTop())
	
	If QNRM->(!Eof())
		While QNRM->(!Eof())

			nItem++
			aAdd(aColsTmp,Array(nTamHead))

			aColsTmp[nItem][01] := QNRM->F2_FILIAL	 			// Filial
			aColsTmp[nItem][02] := QNRM->UA_NUM			   		// Atendimento  
			aColsTmp[nItem][03] := StoD(QNRM->UA_EMISSAO)  		// Data
			aColsTmp[nItem][04] := QNRM->UA_NUMSC5		   		// Pedido
			aColsTmp[nItem][05] := QNRM->F2_DOC				   	// Nota Fiscal 
			aColsTmp[nItem][06] := QNRM->F2_SERIE			   	// Nota Fiscal
			aColsTmp[nItem][07] := StoD(QNRM->F2_EMISSAO)		// Data Faturamento
			aColsTmp[nItem][08] := QNRM->F2_VALBRUT		   		// Valor Nota Fiscal
			aColsTmp[nItem][09] := QNRM->UA_OPERADO		   		// Operador
			aColsTmp[nItem][10] := Posicione("SU7",1,xFilial("SU7") + QNRM->UA_OPERADO, "U7_NOME")	// Nome
			aColsTmp[nItem][11] := Posicione("SA3",1,xFilial("SA3") + QNRM->UA_VEND, "A3_NOME") 	// Vendedor
			aColsTmp[nItem][12] := QNRM->UA_DESCNT		   		// Contato Cliente	   
			aColsTmp[nItem][13] := .F.
		           
			QNRM->(DbSkip())
		EndDo	
	EndIf 
	     
ElseIf cTipoCols == "1A5"
	     
	QSAC->(DbGoTop())

	While QSAC->(!Eof())    
				    
		nItem++
		aAdd(aColsTmp,Array(nTamHead))
        
  		aColsTmp[nItem][01] := Tk272Pendente(QSAC->UC_STATUS,QSAC->UC_CODCANC)	// Legenda
		aColsTmp[nItem][02] := QSAC->UC_FILIAL	// Filial
		aColsTmp[nItem][03] := QSAC->UC_CODIGO	// Atendimento
		aColsTmp[nItem][04] := Posicione("SU5",1,xFilial("SU5")+QSAC->UC_CODCONT,"U5_CONTAT")	// Contato
		aColsTmp[nItem][05] := Alltrim(Posicione("SX2",1,ALLTRIM(QSAC->UC_ENTIDAD),"X2NOME()"))+": "+Alltrim(TkEntidade(QSAC->UC_ENTIDAD,QSAC->UC_CHAVE,1))	// Entidade
		aColsTmp[nItem][06] := StoD(QSAC->UC_DATA)	// Data
		aColsTmp[nItem][07] := QSAC->UC_INICIO		// Hora
		aColsTmp[nItem][08] := Posicione("SU7",1,xFilial("SU7")+QSAC->UC_OPERADO,"U7_NOME")	// Operador
		aColsTmp[nItem][09] := TkOperacao(QSAC->UC_OPERACA)	// Operação
		aColsTmp[nItem][10] := Tk272Ligacao(QSAC->UC_STATUS)	// Status
		aColsTmp[nItem][11] := IIF( RetCodUsr() $ cParUser, QSAC->UC_DESCDE,  cTxtPadRt )	// Setor de
		aColsTmp[nItem][12] := IIF( RetCodUsr() $ cParUser, QSAC->UC_DESCPAR, cTxtPadRt )	// Setor para
		aColsTmp[nItem][13] := IIF( RetCodUsr() $ cParUser, QSAC->UC_DESCCAU, cTxtPadRt )	// Causador
		aColsTmp[nItem][14] := QSAC->UC_VLRFRET	// Valor frete
		aColsTmp[nItem][15] := QSAC->UC_VLRBOL	// Valor boleto
		aColsTmp[nItem][16] := Alltrim(QSAC->UC_NF)+"/"+Alltrim(QSAC->UC_SERIE)		// Nota fiscal
		aColsTmp[nItem][17] := Posicione("SUO",1,QSAC->UC_FILIAL+QSAC->UC_CODCAMP,"UO_DESC")	// Campanha
		aColsTmp[nItem][18] := Posicione("SUH",1,xFilial("SUH")+QSAC->UC_MIDIA,"UH_DESC")	// Mídia
		aColsTmp[nItem][19] := QSAC->UC_PENDENT	// Retorno
		aColsTmp[nItem][20] := QSAC->UC_HRPEND	// Hora
		aColsTmp[nItem][21] := .F.
	          
 		QSAC->(DbSkip()) 

	EndDo
	
ElseIf cTipoCols == "1A6" 

	QDEV->(DbGoTop())
	
	While QDEV->(!Eof())    
				    
		nItem++
		aAdd(aColsTmp,Array(nTamHead))
        
		aColsTmp[nItem][01] := QDEV->F1_FILIAL		   		// Filial
		aColsTmp[nItem][02] := QDEV->UA_NUM			   		// Atendimento   		
		aColsTmp[nItem][03] := StoD(QDEV->UA_EMISSAO)  		// Data
		aColsTmp[nItem][04] := QDEV->D2_PEDIDO 		  		// Pedido		
		aColsTmp[nItem][05] := QDEV->F1_DOC			  		// Nota Fiscal Devolução   
		aColsTmp[nItem][06] := QDEV->F1_SERIE		   		// Serie NF Devolução
		aColsTmp[nItem][07] := StoD(QDEV->F1_EMISSAO)  		// Data Devolução
		aColsTmp[nItem][08] := QDEV->F1_VALBRUT	 	   		// Valor NF Devolução		
		aColsTmp[nItem][09] := QDEV->F2_DOC			   		// Nota Fiscal Origem  
		aColsTmp[nItem][10] := QDEV->F2_SERIE		   		// Serie NF Origem
		aColsTmp[nItem][11] := StoD(QDEV->F2_EMISSAO)  		// Data Faturamento
		aColsTmp[nItem][12] := QDEV->F2_VALBRUT		   		// Valor NF Origem		
		aColsTmp[nItem][13] := QDEV->UA_OPERADO   	   		// Operador
		aColsTmp[nItem][14] := Posicione("SU7",1,xFilial("SU7") + QDEV->UA_OPERADO , "U7_NOME")		// Nome
		aColsTmp[nItem][15] := Posicione("SA3",1,xFilial("SA3") + QDEV->UA_VEND, "A3_NOME")			// Vendedor
		aColsTmp[nItem][16] := Posicione("SU5",1,xFilial("SU5") + QDEV->UA_CODCONT, "U5_CONTAT")	// Contato Cliente
		aColsTmp[nItem][17] := QDEV->F1_XUSRDEV // UsrFullName(QDEV->F1_XUSRDEV)// Usuario Autorizou Devolução ->Migração 12.1.27
		aColsTmp[nItem][18] := Alltrim(QDEV->F1_XMOTDEV)	// Motivo
		aColsTmp[nItem][19] := .F.
	          
 		QDEV->(DbSkip()) 
                          
	EndDo
	
ElseIf cTipoCols == "1A7"
	
	QCOB->(DbGoTop())	

	While QCOB->(!Eof())
	               
		If QCOB->ACF_STATUS == "1" // 1=Atendimento;2=Cobranca;3=Encerrado
			cStatus := "Atendimento"           
		ElseIf QCOB->ACF_STATUS == "2"
	  		cStatus := "Cobrança"
		Else
	  		cStatus := "Encerrado"
		EndIf  
		
		If QCOB->ACF_OPERA == "1"
			cLigacao := "Receptivo"
		Else
	   		cLigacao := "Ativo" 
		EndIf
				    
		nItem++
		aAdd(aColsTmp,Array(nTamHead))
        
		aColsTmp[nItem][01] := fLeg1a7()  	   			// Legenda
		aColsTmp[nItem][02] := QCOB->ACF_FILIAL			// Filial   		
		aColsTmp[nItem][03] := QCOB->ACF_CODIGO			// Atendimento
		aColsTmp[nItem][04] := QCOB->ACF_CLIENT 		// Cliente		
		aColsTmp[nItem][05] := QCOB->ACF_LOJA			// Loja 
		aColsTmp[nItem][06] := CtoD("//")	  			// Prazo Cobrança
		aColsTmp[nItem][07] := Posicione("SA1",1,xFilial("SA1") + QCOB->ACF_CLIENT + QCOB->ACF_LOJA , "A1_NOME")	// Empresa
		aColsTmp[nItem][08] := QCOB->ACF_CODCON	 		//Contato		
		aColsTmp[nItem][09] := Posicione("SU5",1,xFilial("SU5") + QCOB->ACF_CODCON, "U5_CONTAT")					// Nome  
		aColsTmp[nItem][10] := QCOB->ACF_OPERAD			// Operador
		aColsTmp[nItem][11] := Posicione("SU7",1,xFilial("SU7") + QCOB->ACF_OPERAD, "U7_NOME") 						// Nome
		aColsTmp[nItem][12] := cLigacao					// Ligação 1=Receptivo;2=Ativo
		aColsTmp[nItem][13] := cStatus   	   			// Status 1=Atendimento;2=Cobranca;3=Encerrado
		aColsTmp[nItem][14] := QCOB->ACF_MOTIVO			// Ocorrência
		aColsTmp[nItem][15] := Posicione("SU9",2,xFilial("SU9") + QCOB->ACF_MOTIVO, "U9_DESC")	// Descrição
		aColsTmp[nItem][16] := StoD(QCOB->ACF_PENDEN)	// Data Retorno
		aColsTmp[nItem][17] := QCOB->ACF_CODCAM			// Campanha  
		aColsTmp[nItem][18] := Posicione("SUO",1,QCOB->ACF_FILIAL + QCOB->ACF_CODCAM, "UO_DESC")	// Descrição
		aColsTmp[nItem][19] := QCOB->ACF_CODMOT			// Motivo
	    aColsTmp[nItem][20] := QCOB->ACF_CODOBS
	    aColsTmp[nItem][21] := QCOB->ACF_CODMOT
	    aColsTmp[nItem][22] := QCOB->ACF_CCANC
    	aColsTmp[nItem][23] := .F.
	    
 		QCOB->(DbSkip()) 
                          
	EndDo

ElseIf cTipoCols == "1A8"

	QTEC->(DbGoTop())

	While QTEC->(!Eof())
			    
		nItem++
		aAdd(aColsTmp,Array(nTamHead))
        
		aColsTmp[nItem][01] := fLeg1a8(QTEC->AB1_XTIPO)		// Legenda
		aColsTmp[nItem][02] := QTEC->AB1_FILIAL				// Filial   		
		aColsTmp[nItem][03] := QTEC->AB1_NRCHAM		   		// Chamado
		aColsTmp[nItem][04] := StoD(QTEC->AB1_EMISSA)  		// Emissão		
		aColsTmp[nItem][05] := QTEC->AB1_HORA		  		// Hora Chamado 
		aColsTmp[nItem][06] := QTEC->AB1_ATEND	  	  		// Atendente
		aColsTmp[nItem][07] := QTEC->AB1_NUMTMK		   		// Chamado Tmk
		aColsTmp[nItem][08] := QTEC->AB1_XCDEND	 	  		// Cond. End.		
		aColsTmp[nItem][09] := U_ATEC001D(QTEC->AB1_CODCLI,QTEC->AB1_LOJA,QTEC->AB1_XCDEND)	// End. Entrega
		aColsTmp[nItem][10] := .F.
	    
 		QTEC->(DbSkip()) 
                          
	EndDo
	      
ElseIf cTipoCols == "1A9"

	QORS->(DbGoTop())

	While QORS->(!Eof())  
	    
		//Caso não esteja preenchido, considera o técnico da agenda
		cCodTec := If(Empty(QORS->AB6_XCDTEC),QORS->ABB_CODTEC,QORS->AB6_XCDTEC)
		cNomeTec:= If(Empty(QORS->NOME_TEC), GetAdvFVal("AA1","AA1_NOMTEC",FWxFilial("AA1")+cCodTec,1),QORS->NOME_TEC)

		nItem++
		aAdd(aColsTmp,Array(nTamHead))
        
		aColsTmp[nItem][01] := IIF(QORS->AB6_STATUS=="A","BR_VERDE","BR_VERMELHO")	// Legenda
		aColsTmp[nItem][02] := QORS->AB6_FILIAL				// Filial   		
		aColsTmp[nItem][03] := QORS->AB6_NUMOS		   		// O.S.
		aColsTmp[nItem][04] := StoD(QORS->AB6_EMISSA)  		// Emissão		
		aColsTmp[nItem][05] := QORS->AB6_ATEND	  	  		// Atendente
		aColsTmp[nItem][06] := QORS->AB6_HORA		   		// Hora Abertura
		aColsTmp[nItem][07] := IIF(QORS->AB6_XLIBER=="2","SIM","NÃO") // O.S. Liberada ? // 1=Nao;2=Sim 		
		aColsTmp[nItem][08] := cCodTec	 			  		// Técnico
		aColsTmp[nItem][09] := cNomeTec	 	 		 		// Nome		
//		aColsTmp[nItem][10] := QORS->AB6_XCDAUX	 	  		// Auxiliar 		
//		aColsTmp[nItem][11] := QORS->NOME_AUX	 	  		// Nome		
		aColsTmp[nItem][10] := QORS->AB6_XCDEND	 	  		// Cod. Endereço		
		aColsTmp[nItem][11] := U_ATEC001D(QORS->AB6_CODCLI,QORS->AB6_LOJA,QORS->AB6_XCDEND)	// Descrição		
		aColsTmp[nItem][12] := StoD(QORS->AB6_XDATPR)  		// Previsão Atendimento  
		aColsTmp[nItem][13] := QORS->AB6_XUSREF				// Usuario Encerrou O.S.
		aColsTmp[nItem][14] := StoD(QORS->AB6_XDATEF)		// Data Encerramento O.S.
		aColsTmp[nItem][15] := QORS->AB6_XHOREF				// Hora Encerramento O.S.
		aColsTmp[nItem][16] := .F.
	    
 		QORS->(DbSkip()) 
                          
	EndDo

EndIf

If Empty(aColsTmp)
		aAdd(aColsTmp,Array(nTamHead))
Endif

Return  


//-------------------------------------------------------------------
/*/{Protheus.doc} ATMK003V
Valida campo de quantidade verificando produto bloqueado

@sample		ATMK003V()

@author		Alessandro Smaha
@since		26/01/2015
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ATMK003V()
        
Local aAreaSB1 	:= SB1->(GetArea())
Local lRetOk 	:= .T.        
Local nPosXPro 	:= aScan(oGrid1a1:aHeader,{|x| AllTrim(x[2]) == "CODPRO" })  
Local cCodProd 	:= ""
Local nQtdProd 	:= 0

If nPosXPro > 0 

	cCodProd := oGrid1a1:aCols[oGrid1a1:nAt][nPosXPro]
	nQtdProd := M->QUANT

	If nQtdProd > 0  
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
		If SB1->(DbSeek(xFilial("SB1")+cCodProd))
			If SB1->B1_MSBLQL == '1' 
				If IsBlind()
					cLogTxt := "Este produto está bloqueado! - [ATMK003V]"
					Conout(cLogTxt)		
				Else
					MsgAlert("Este produto está bloqueado!","Atenção")	
				End
				lRetOk := .F.		
			EndIf
		EndIf	
	EndIf   
	
EndIf

RestArea(aAreaSB1)

Return lRetOk
  
 
//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaMemo
Busca o conteudo de um campo memo

@sample		fBuscaMemo()

@author		Alessandro Smaha
@since		13/03/2015
@version 	P11
/*/
//------------------------------------------------------------------- 
Static Function fBuscaMemo(cFilSYP,cCodSYP,cCampoCod)  
                   
Local cQuery 	:= ""
Local cContMemo := ""      

If !Empty(cCodSYP)   

	cFilSYP := Substr( cFilSYP, 1, 4 ) + Space(2)
	
	If (Select("QMEM") <> 0)
		DbSelectArea("QMEM")
		QMEM->(DbCloseArea())
	Endif
	
	cQuery := " SELECT YP_TEXTO "
	cQuery += " FROM "+RetSQLName("SYP")+" " 
	cQuery += " WHERE " // YP_FILIAL = '"+cFilSYP+"' AND " // A tabela SYP foi compartilhada... 
	cQuery += " 	YP_CHAVE = '"+cCodSYP+"' "
	cQuery += " 	AND D_E_L_E_T_ <> '*' "  
	If ! Empty(cCampoCod)
		cQuery += " 	AND YP_CAMPO = '"+cCampoCod+"' " 	
	EndIf
	cQuery += " ORDER BY YP_SEQ " 
	
	TCQuery cQuery new Alias "QMEM"
	
	QMEM->(DbGoTop())
	
	If QMEM->(!Eof())   
		
		While QMEM->(!Eof()) 
			cContMemo += Alltrim(QMEM->YP_TEXTO)
			QMEM->(DbSkip()) 	
		EndDo   
		
		cContMemo := Alltrim(StrTran(cContMemo, "\13\10",chr(13)+chr(10))) 
	
	EndIf 
	
EndIf
	
Return cContMemo 
     

//-------------------------------------------------------------------
/*/{Protheus.doc} fBusPrcUn
Busca o valor unitário sem desconto

@sample		fBusPrcUn()

@author		Alessandro Smaha
@since		08/07/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fBusPrcUn(cCodCl, cCodLj, sDatEm, cCodPd) 
                 
Local cQryPrc := ""
Local nValUnr := 0 
Local nDescon := 0

If (Select("QPRC") <> 0)
	DbSelectArea("QPRC")
	QPRC->(DbCloseArea())
Endif
	
cQryPrc += " SELECT * "
cQryPrc += " FROM "+RetSQLName("SD2")+" X "	
cQryPrc += " WHERE X.D2_CLIENTE   = '"+cCodCl+"' "
cQryPrc += " 	 AND X.D2_LOJA    = '"+cCodLj+"' "
cQryPrc += " 	 AND X.D2_EMISSAO = '"+sDatEm+"' "
cQryPrc += " 	 AND X.D2_COD 	  = '"+cCodPd+"' "
cQryPrc += " 	 AND X.D_E_L_E_T_ <> '*' "
	 
TCQuery cQryPrc new Alias "QPRC"  
      
QPRC->(DbGoTop())

If QPRC->(!Eof()) 

	If QPRC->D2_ORIGLAN == "VD"
		nDescon := Round(QPRC->D2_QUANT*QPRC->D2_PRUNIT,2)+(QPRC->D2_VALACRS)-QPRC->D2_TOTAL
	Else 
		nDescon := QPRC->D2_DESCON            	
	EndIf   
	
	If QPRC->D2_TIPO $ "IP"	
		nValUnr := 0	
	Else	
		If QPRC->D2_QUANT < 1		    
			if QPRC->D2_PRUNIT == QPRC->D2_PRCVEN
				nValUnr := ( ( ( QPRC->D2_PRUNIT * QPRC->D2_QUANT ) + nDescon + QPRC->D2_DESCZFR ) / QPRC->D2_QUANT )	
			ElseIf QPRC->D2_PRUNIT < QPRC->D2_PRCVEN
				nValUnr := ( ( ( QPRC->D2_PRCVEN * QPRC->D2_QUANT ) + QPRC->D2_DESCZFR ) / QPRC->D2_QUANT )		
			Else
				nValUnr := ( ( ( QPRC->D2_PRUNIT * QPRC->D2_QUANT ) + QPRC->D2_DESCZFR ) / QPRC->D2_QUANT )
			EndIf					
		Else		
			nValUnr := ( ( QPRC->D2_TOTAL + nDescon + QPRC->D2_DESCZFR ) / QPRC->D2_QUANT )		
		Endif	
	Endif	
	nValUnr := NoRound( nValUnr, 8 ) 	
EndIf
	 
Return nValUnr


//-------------------------------------------------------------------
/*/{Protheus.doc} fPrcVenda
Busca o valor unitário sem desconto

@sample		fPrcVenda()

@author		Alessandro Smaha
@since		07/12/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fPrcVenda(cCodCl, cCodLj, sDatEm, cCodPd) 
                 
Local cQryPrc := ""
Local nValUnr := 0 
Local nDescon := 0

If (Select("QPRV") <> 0)
	DbSelectArea("QPRV")
	QPRV->(DbCloseArea())
Endif
	
cQryPrc += " SELECT UB_XPRCVEN " 
cQryPrc += " FROM "+RetSQLName("SD2")+" SD2 "
cQryPrc += " INNER JOIN "+RetSQLName("SUB")+" SUB ON UB_FILIAL = D2_FILIAL " 
cQryPrc += " 	AND UB_NUMPV = D2_PEDIDO " 
cQryPrc += " 	AND UB_ITEMPV = D2_ITEMPV " 
cQryPrc += " 	AND SUB.D_E_L_E_T_ <> '*' "
cQryPrc += " WHERE D2_CLIENTE   		= '"+cCodCl+"' " 
cQryPrc += " 	 AND D2_LOJA    		= '"+cCodLj+"' " 
cQryPrc += " 	 AND D2_EMISSAO 		= '"+sDatEm+"' " 
cQryPrc += " 	 AND D2_COD 	  		= '"+cCodPd+"' " 
cQryPrc += " 	 AND SD2.D_E_L_E_T_ <> '*' " 
	 
TCQuery cQryPrc new Alias "QPRV"  
      
QPRV->(DbGoTop())

If QPRV->(!Eof()) 
	nValUnr := NoRound( QPRV->UB_XPRCVEN, 8 ) 	
EndIf
	 
Return nValUnr	  	  


//-------------------------------------------------------------------
/*/{Protheus.doc} fLaudoOS()
Verifica os laudos para as OS.

@sample		fLaudoOS(cNumOs)

@author		Alessandro Smaha
@since		16/11/2016
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fLaudoOS( oGridOs )

Local cLaudo	:= ""    
Local cFilOs	:= ""
Local cNumOs	:= "" 
Local cNomTec	:= ""
Local oGrpMsg, oMultG, oButMsg

Static oDlgLaudo

If Len(oGridOs:aCols) > 0    

	cFilOs	:= oGridOs:aCols[oGridOs:nAt][2]
	cNumOs	:= oGridOs:aCols[oGridOs:nAt][3] 
	
Else                                            
	If IsBlind()
		cLogTxt := "Ordem de serviço não localizada!- [ATMK003V]"
		Conout(cLogTxt)		
	Else
		MsgAlert("Ordem de serviço não localizada!","Atenção")
	End
	
	Return      
	
EndIf            

If AB7->(DbSeek( cFilOs + cNumOs )) 

	While AB7->(!Eof()) .AND. cFilOs == AB7->AB7_FILIAL .AND. cNumOs == AB7->AB7_NUMOS
	
		If AB9->(DbSeek( cFilOs + cNumOs + AB7->AB7_ITEM )) 
		
			While AB9->(!Eof()) .AND. AB9->AB9_FILIAL == AB7->AB7_FILIAL .AND. AB9->AB9_NUMOS == AB7->AB7_NUMOS + AB7->AB7_ITEM
			   
            	If !Empty(AB9->AB9_MEMO1)
				
					cNomTec := Alltrim(Posicione("AA1",1,xFilial("AA1") + AB9->AB9_CODTEC, "AA1_NOMTEC"))
				    cDesPrd := Alltrim(Posicione("SB1",1,xFilial("SB1") + AB7->AB7_CODPRO, "B1_DESC"))
				    
			   		cLaudo += "Item "+AB7->AB7_ITEM+"   Técnico: "+Alltrim(AB9->AB9_CODTEC)+" - "+cNomTec+chr(13)+chr(10) 
			   		cLaudo += "Produto: "+Alltrim(AB7->AB7_CODPRO)+" - "+cDesPrd+chr(13)+chr(10)+chr(13)+chr(10)
			   		cLaudo += "Laudo: "+fBuscaMemo( "", AB9->AB9_MEMO1, "AB9_MEMO1" ) + chr(13)+chr(10) + chr(13)+chr(10)			 
					cLaudo += Replicate("- ",50)+chr(13)+chr(10)+chr(13)+chr(10) 

				EndIf
									 
				AB9->(DbSkip())
				
			EndDo
			
		EndIf
		
		AB7->(DbSkip())  
		
	EndDo
		
EndIf

If Empty(cLaudo)

	cLaudo += "Laudo: Não possui atendimento." + chr(13)+chr(10) + chr(13)+chr(10)			 
	cLaudo += Replicate("- ",50)+chr(13)+chr(10)+chr(13)+chr(10) 

EndIf 

cLaudo := Replicate("- ",50)+chr(13)+chr(10)+chr(13)+chr(10) + cLaudo

DEFINE MSDIALOG oDlgLaudo TITLE "Laudos" FROM 000, 000  TO 430, 400 COLORS 0, 16777215 PIXEL
	
	@ 003, 001 GROUP oGrpMsg TO 199, 198 PROMPT "OS: "+cNumOs OF oDlgLaudo COLOR 0, 16777215 PIXEL
	@ 011, 002 GET oMultG VAR cLaudo OF oDlgLaudo MULTILINE SIZE 194, 183 COLORS 0, 16777215 READONLY HSCROLL PIXEL
	@ 201, 154 BUTTON oButMsg PROMPT "OK" SIZE 037, 012 OF oDlgLaudo ACTION oDlgLaudo:End() PIXEL

ACTIVATE MSDIALOG oDlgLaudo CENTERED

Return cLaudo
    
 
//-------------------------------------------------------------------
/*/{Protheus.doc} fAjustaSX1
Cria as perguntas para filtrar os dados

@sample		fAjustaSX1()

@author		Alessandro Smaha
@since		19/12/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAjustaSX1()

Local aHelpPor01 := {"Informe a data de emissão inicial."}
Local aHelpPor02 := {"Informe a data de emissão final."}
Local aHelpPor03 := {"Informe o operador inicial."}
Local aHelpPor04 := {"Informe o operador final."}
Local aHelpPor05 := {"Informe o tipo de operação."}
Local aHelpPor06 := {"Informe o tipo de marketing."}
Local aHelpPor07 := {"UInforme o tipo da ocorrência."}
Local aHelpPor08 := {"Informe se deve exibir itens de comodato."}

PutSx1(cPerg,"01","Da Emissão ?",		"","","MV_PAR01","D",8,0,0,"G",/*cValid*/,/*cF3*/,,,"MV_PAR01",,,,"",,,,,,,,,,,,,aHelpPor01)
PutSx1(cPerg,"02","Até a Emissão ?",	"","","MV_PAR02","D",8,0,0,"G",/*cValid*/,/*cF3*/,,,"MV_PAR02",,,,"",,,,,,,,,,,,,aHelpPor02)
PutSx1(cPerg,"03","Do Operador ?",		"","","MV_PAR03","C",6,0,0,"G",/*cValid*/,"SU7"  ,,,"MV_PAR03",,,,"",,,,,,,,,,,,,aHelpPor03)
PutSx1(cPerg,"04","Até o Operador ?",	"","","MV_PAR04","C",6,0,0,"G",/*cValid*/,"SU7"  ,,,"MV_PAR04",,,,"",,,,,,,,,,,,,aHelpPor04)
PutSx1(cPerg,"05","Operação ?",			"","","MV_PAR05","N",1,0,0,"C",/*cValid*/,/*cF3*/,,,"MV_PAR05","Todos",,,"","Faturamento",,,"Orçamento",,,;
			"Atendimento",,,,,,aHelpPor05)
PutSx1(cPerg,"06","Marketing ?",		"","","MV_PAR06","N",1,0,0,"C",/*cValid*/,/*cF3*/,,,"MV_PAR06","Todos",,,"","Receptivo",,,"Ativo",,,"Fax",,,;
			"Representante",,,aHelpPor06)
PutSx1(cPerg,"07","Ocorrência ?",		"","","MV_PAR07","C",6,0,0,"G",/*cValid*/,"U9V"  ,,,"MV_PAR07",,,,"",,,,,,,,,,,,,aHelpPor07)
PutSx1(cPerg,"08","Exibe Comodato ?",	"","","MV_PAR08","N",1,0,0,"C",/*cValid*/,/*cF3*/,,,"MV_PAR08","Sim",,,"","Não",,,,,,,,,,,,aHelpPor08)

Return
