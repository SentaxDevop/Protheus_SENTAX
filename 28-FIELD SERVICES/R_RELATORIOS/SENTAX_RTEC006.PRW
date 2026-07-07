#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC006
Impressao do Ordem de Servico (Alterado o relatório TECR450).
                
@sample		U_RTEC006(cOs)

@param		cOs - Numero da OS                     

@author		Alessandro Smaha
@since		14/11/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function RTEC006(cOs)

Local oReport							//Objeto do relatorio personalizavel
Local aArea		:= GetArea()			//Guarda a area atual

Default cOS := ""

Private lWeb	:= .F.			// Valida se o relatorio é para WEB
Private cPerg 	:= "RTEC006"	//Nome da pergunta p/ buscar no X1_GRUPO

// MV_PAR01               Ordem de Servico De                    
// MV_PAR02               Ordem de Servico Ate                   
// MV_PAR03               Qual Moeda                             
// MV_PAR04               Outras Moedas (Converter/Nao imprimir) 

If Empty(cOS)
		
	fAjustaSX1()
	
	If ! Pergunte(cPerg,.T.) 	
		Return     	
	EndIf
	
Else

	Pergunte("RTEC006",.F.) 
	
	If !Empty(cOS)
		MV_PAR01 := cOS
		MV_PAR02 := cOS  
		MV_PAR05 := 1
		/*
		If MsgYesNo("Imprimir OS no layout novo ?","Aviso")
	   		MV_PAR05 := 1
	 	Else
	 		MV_PAR05 := 2
	 	EndIf
	 	*/	 	
	EndIf
	
EndIf 

If MV_PAR05 == 1  // Layout 1=Novo/2=Anterior

	// Interface de impressao
	oReport:=Tcr450RptDef()
	oReport:PrintDialog()
	
Else

	U_RTEC001(cOs)	

EndIf

RestArea( aArea )

Return	


//-------------------------------------------------------------------
/*/{Protheus.doc} Tcr450RptDef
Funcao para informar as celulas que serao utilizadas no relalatorio
                
@sample		Tcr450RptDef()

@author		Alessandro Smaha
@since		14/11/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function Tcr450RptDef()     

Local oReport		  		// Objeto do relatorio
Local oSection1		   		// Objeto da secao 1
Local oSection2		   		// Objeto da secao 2
Local oSection3		   		// Objeto da secao 3
Local cAlias1		:= ""	// Pega o proximo Alias Disponivel
Local cAlias3		:= ""	// Pega o proximo Alias Disponivel

#IFDEF TOP
	cAlias1	:= GetNextAlias()
	cAlias3	:= GetNextAlias()	
#ELSE
	cAlias1	:= "AB6"
	cAlias3	:= "AB8"
#ENDIF

// Define a criacao do objeto oReport  
DEFINE REPORT oReport NAME "RTEC006" TITLE "Impressao da Ordem de Servico" PARAMETER "RTEC006" ACTION {|oReport| RTECPRT(oReport, cAlias1)} DESCRIPTION "     Este programa ira emitir as Ordem de Servicos conforme os parametros" + "solicitados." 
   
	// Define a secao1 do relatorio  
	DEFINE SECTION oSection1 OF oReport TITLE "Ordem de Serviço" TABLES "AB6","SA1","SE4" TOTAL TEXT "TOTAL GERAL" TOTAL IN COLUMN 		//"Ordem de Serviço"
	
		// Define as celulas que irao aparecer na secao1 	
		DEFINE CELL NAME "AB6_EMISSA"  		OF oSection1 ALIAS "AB6"	TITLE "DATA DE EMISSÃO"			SIZE 016  	
		DEFINE CELL NAME "CHAMADO" 	 		OF oSection1 ALIAS " " 		TITLE "CHAMADO N°" 				SIZE 012 	BLOCK {|| _cNumCham } 
		DEFINE CELL NAME "EMITENTE"	   		OF oSection1 ALIAS " " 		TITLE "OS EMITIDA POR" 	   	   	SIZE 040 	BLOCK {|| _cEmiteOs } 
		DEFINE CELL NAME "REGIAO_ENT"  		OF oSection1 ALIAS "   " 	TITLE "REGIÃO" 			   		SIZE 040  	BLOCK {|| _cRegEntr } CELL BREAK  		
		//DEFINE CELL NAME "CLIENTE"  		OF oSection1 ALIAS "   "	TITLE "CLIENTE"					SIZE 080 	BLOCK {|| _cCodNCli }
		DEFINE CELL NAME "A1_NREDUZ"   		OF oSection1 ALIAS "SA1"	TITLE "NOME FANTASIA" 			SIZE 040  	       
		DEFINE CELL NAME "CONTATO" 			OF oSection1 ALIAS " " 		TITLE "CONTATO" 	   			SIZE 040	BLOCK {|| _cNomeCon } 
		DEFINE CELL NAME "A1_NOMVEND"	   	OF oSection1 ALIAS "AB6" 	TITLE "VENDEDOR" 	 	   	   	SIZE 040	PICTURE "@!" CELL BREAK		
		DEFINE CELL NAME "END_ENTREGA" 		OF oSection1 ALIAS " " 		TITLE "ENDERECO" 				SIZE 200 	BLOCK {|| _cEndEntr } CELL BREAK
//		DEFINE CELL NAME "COMPLEMENTO" 		OF oSection1 ALIAS " " 		TITLE "COMPLEMENTO" 	   		SIZE 050	BLOCK {|| _cComEntr }
//		DEFINE CELL NAME "BAIRRO"  			OF oSection1 ALIAS " " 		TITLE "BAIRRO" 	   	   			SIZE 030	BLOCK {|| _cBaiEntr }
//		DEFINE CELL NAME "CEP" 				OF oSection1 ALIAS " " 		TITLE "CEP"  	   	   			SIZE 012	PICTURE "@R 99999-999" BLOCK {|| _cCEPEntr }
		DEFINE CELL NAME "CIDADE"  			OF oSection1 ALIAS " " 		TITLE "CIDADE" 	   	   			SIZE 040	BLOCK {|| _cCidEntr } 
		DEFINE CELL NAME "ESTADO"	  		OF oSection1 ALIAS " " 		TITLE "UF" 	 	   	   			SIZE 008	BLOCK {|| _cEstEntr } 
		DEFINE CELL NAME "A1_DDD" 	  		OF oSection1 ALIAS "SA1" 	TITLE "DDD"		  	   	   		SIZE 003	PICTURE "@!"  
		DEFINE CELL NAME "A1_TEL" 	   		OF oSection1 ALIAS "SA1" 	TITLE "TELEFONE"  	   	   		SIZE 015	PICTURE "@!" 
		DEFINE CELL NAME "A1_CEL" 			OF oSection1 ALIAS "SA1" 	TITLE "CELULAR"	 	   	   		SIZE 015	PICTURE "@!" CELL BREAK         
		DEFINE CELL NAME "TECNICO" 			OF oSection1 ALIAS " " 		TITLE "TECNICO"  	   	   		SIZE 040	BLOCK {|| _cNomTecn } 
		DEFINE CELL NAME "AGENDA" 			OF oSection1 ALIAS " " 		TITLE "AGENDA DO DIA"  	   		SIZE 016	BLOCK {|| _cAgenDia } 
		DEFINE CELL NAME "PREVISAO"			OF oSection1 ALIAS " " 		TITLE "PRAZO P/ ATENDIMENTO"  	SIZE 016	BLOCK {|| _cPrevAte }
		DEFINE CELL NAME "LINHA"	   		OF oSection1 ALIAS " " 		TITLE "LINHA" 			 	   	SIZE 040	BLOCK {|| _cLinProd } CELL BREAK		
		DEFINE CELL NAME "TIPO_SERV"   		OF oSection1 ALIAS " " 		TITLE "TIPO DE SERVIÇO"  	   	SIZE 040	BLOCK {|| _cTipServ }
		DEFINE CELL NAME "OCORRENCIA"  		OF oSection1 ALIAS " " 		TITLE "OCORRÊNCIA"  	   		SIZE 040	BLOCK {|| _cOcorren }  
		DEFINE CELL NAME "OBS_OS" 			OF oSection1 ALIAS " " 		TITLE "OBSERVAÇÕES DA OS"	 	SIZE 150 	BLOCK {|| _cMensOrS }
          
		// Define a secao2 do relatorio 	
		DEFINE SECTION oSection2 OF oSection1 TITLE "Itens da Ordem de Serviço" TABLE "AB7","AB6","AAG","AA3"			//Itens da ordem de servico
	
			// Define as celulas que irao aparecer na secao2 
			DEFINE CELL NAME "AB7_ITEM" 	OF oSection2 ALIAS "AB7" SIZE 005 TITLE "ITEM"	
			DEFINE CELL NAME "AB7_CODPRO" 	OF oSection2 ALIAS "AB7" SIZE 025 TITLE "PRODUTO"	
			DEFINE CELL NAME "DESC_PRO" 	OF oSection2 ALIAS "AB7" SIZE 050 TITLE "DESCRIÇÃO" BLOCK {|| _cDescPrd }
			DEFINE CELL NAME "AB7_NUMSER" 	OF oSection2 ALIAS "AB7" SIZE 020 TITLE "NUM. SÉRIE"	
			DEFINE CELL NAME "AB7_XQTDIN" 	OF oSection2 ALIAS "AB7" SIZE 012 TITLE "QTDE SOLIC."
			DEFINE CELL NAME "QTDE_SOLIC" 	OF oSection2 ALIAS "AB7" SIZE 012 TITLE "QTDE EXEC." BLOCK {|| "" }
			DEFINE CELL NAME "OBSERVACOES" 	OF oSection2 ALIAS "AB7" SIZE 060 TITLE "OBSERVAÇÕES" BLOCK {|| "" }
            
        oSection1:SetPageBreak()

		// Define impressao no estilo Enchoice 
        oSection1:SetLineStyle()
        
		oReport:SetPortrait()        // Define orientação de página do relatório como retrato.
		oReport:DisableOrientation() // Desabilita a seleção da orientação (Retrato/Paisagem)
		oReport:HideParamPage()
		
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} RTECPRT
Funcao para impressao do relatorio personalizavel 
                
@sample		RTECPRT( oReport, cAlias1 ) 

@author		Alessandro Smaha
@since		14/11/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function RTECPRT( oReport, cAlias1 )            

Local oSection1 := oReport:Section(1)							// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)							// Define que a secao 2 sera filha da secao 1
Local cWhere	:= ""											// Condicao a adicionar na query
Local lTaxa		:= ( AB6->( FieldPos("AB6_TXMOED") ) > 0 )		// Indica se existe o campo AB6_TXMOED
Local cSelect	:= ""											// Campos adicionais do Select
Local cTipSer	:= ""
Local cOcorre	:= ""
Local cLinhaP	:= "" 
Local lPrimLin	:= .F.

Private _cNumCham	:= ""
Private _cCodNCli	:= ""
Private _cRegEntr	:= ""
Private _cEndEntr	:= ""
Private _cComEntr	:= ""
Private _cNomeCon	:= ""
Private _cBaiEntr 	:= ""
Private _cCEPEntr 	:= ""
Private _cCidEntr 	:= ""
Private _cEstEntr 	:= ""
Private _cEmiteOs 	:= ""
Private _cTipServ 	:= ""
Private _cNomTecn 	:= "" 
Private _cAgenDia	:= ""
Private _cPrevAte	:= ""
Private _cMensOrS	:= "" 
Private _cDescPrd 	:= "" 
Private _cOcorren	:= ""
Private _cLinProd	:= ""
Private _cTitulOS	:= "" 

oSection1:Cell("OBS_OS"):lLineBreak := .T.
          
DbSelectArea("AB6")
DbSetOrder(1)

// Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 
MakeSqlExpr("RTEC006")
    
If mv_par04 == 2

	// So imprimir orcamentos com moeda igual a escolhida (MV_PAR03)  
	cWhere := "% AND AB6_MOEDA = '" + Str(mv_par03) + "' %"
Else
	cWhere := "% %"
EndIf

// Adiciona campos no SELECT 
If lTaxa
	cSelect := "%, AB6_TXMOED %"
Else
	cSelect := "%%"
EndIf

// Inicializa a secao 1
BEGIN REPORT QUERY oSection1

// Query da secao 1
BeginSql alias cAlias1 

	SELECT	AB6_NUMOS,	AB6_CODCLI,	AB6_LOJA,	AB6_EMISSA,
			AB6_MOEDA,	AB6_ATEND,	AB6_CONPAG,	E4_DESCRI,
			AB6_DESC1,	AB6_DESC2,	AB6_DESC3,	AB6_DESC4,
			AB6_XCLASS,	AB6_XCDEND,	AB6_ATEND,	AB6_XCDTEC,
			AB6_XDATPR, 
			A1_NOME,   	A1_NREDUZ,	AB6_STATUS, A1_NOMVEND,	
			A1_REGIAO,	A1_DDD,		A1_TEL,  	A1_CEL    
			%exp:cSelect%  
						
	FROM %table:AB6% AB6, %table:SA1% SA1, %table:SE4% SE4
	
	WHERE	AB6_FILIAL = %xfilial:AB6%		AND
			AB6_NUMOS >= %exp:mv_par01%		AND  
			AB6_NUMOS <= %exp:mv_par02%		AND
			AB6.%notDel%					AND
			A1_FILIAL = %xfilial:SA1%		AND
			AB6_CODCLI = A1_COD				AND
			AB6_LOJA = A1_LOJA				AND
			SA1.%notDel%					AND                       
			E4_FILIAL = %xfilial:SE4%		AND
			AB6_CONPAG = E4_CODIGO			AND
			SE4.%notDel%				
			%exp:cWhere%				

	ORDER BY %Order:AB6%
			
EndSql

END REPORT QUERY oSection1 

oReport:SetTitle("ORDEM DE SERVICO") //"ORDEM DE SERVICO"
             
DbSelectArea("AA1")  // Técnicos
AA1->(DbSetOrder(1)) // AA1_FILIAL+AA1_CODTEC

DbSelectArea("AAG")  // Ocorrencias
AAG->(DbSetOrder(1)) // AAG_FILIAL+AAG_CODPRB

DbSelectArea("ABB")  // Agenda
ABB->(DbSetOrder(3)) // ABB_FILIAL+ABB_NUMOS

DbSelectArea("AB1")  // Chamado técnico
AB1->(DbSetOrder(1)) // AB1_FILIAL+AB1_NRCHAM

DbSelectArea("AB2")  // Item Chamado técnico
AB2->(DbSetOrder(1)) // AB2_FILIAL+AB2_NRCHAM+AB2_ITEM+AB2_CODPRO+AB2_NUMSER

DbSelectArea("AB7")  // Item da OS
AB7->(DbSetOrder(1)) // AB7_FILIAL+AB7_NUMOS+AB7_ITEM

DbSelectArea("AB8")  // SubItem da OS
AB8->(DbSetOrder(1)) // AB8_FILIAL+AB8_NUMOS+AB8_ITEM+AB8_SUBITE

DbSelectArea("SB1")  // Produto
SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

DbSelectArea("SX5")  // Tabelas
SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE

oReport:SetMeter(0)

DbSelectArea(cAlias1)
(cAlias1)->(DbGoTop())

If (cAlias1)->(!Eof())  

	While (cAlias1)->(!Eof()) 
	
		cAnoOs := cValToChar(Year((cAlias1)->AB6_EMISSA))
				
		If Len(cAnoOs) > 2
			cAnoOs := Substr(cAnoOs,3,2)
		EndIf  
		
		_cTitulOS := (cAlias1)->AB6_NUMOS +"/"+ cAnoOs

		oReport:SetTitle("Ordem de Serviço "+_cTitulOS+" - "+Alltrim((cAlias1)->AB6_CODCLI)+" - "+ SubStr((cAlias1)->A1_NOME,1,50))
		
		oSection1:Init() 
		
		fEndEntrega( (cAlias1)->AB6_CODCLI, (cAlias1)->AB6_LOJA, (cAlias1)->AB6_XCDEND ) 
				
		_cCodNCli := Alltrim((cAlias1)->AB6_CODCLI) + "-" + Alltrim((cAlias1)->A1_NOME)
		_cRegEntr := Posicione("SX5",1,xFilial("SX5")+"A2"+(cAlias1)->A1_REGIAO,"X5_DESCRI")
		_cNumCham := ""  
		_cNomeCon := ""
		_cEmiteOs := ""
		_cTipServ := Alltrim(Posicione("SX5",1,xFilial("SX5")+"A3"+(cAlias1)->AB6_XCLASS,"X5_DESCRI"))
		_cNomTecn := "" 
		_cAgenDia := ""
		_cPrevAte := ""		 
		_cOcorren := ""
		_cLinProd := ""
		_cMensOrS := ""
		_cAgenDia := ""
		_cPrevAte := DtoC((cAlias1)->AB6_XDATPR)
	      
		If ABB->(DbSeek(xFilial("ABB")+(cAlias1)->AB6_NUMOS))                           
		   
			_cAgenDia := DtoC(ABB->ABB_DTINI)
			
			If AA1->(DbSeek(xFilial("AA1")+ABB->ABB_CODTEC))  
		
		 		_cNomTecn := Alltrim(AA1->AA1_CODTEC) +	" - " + Alltrim(AA1->AA1_NOMTEC)
		 		
			EndIf
		
		EndIf
			
		If AB7->(DbSeek(xFilial("AB7")+(cAlias1)->AB6_NUMOS)) 
		
			_cNumCham := Substr(AB7->AB7_NRCHAM,1,8)  
			_cOcorren := Posicione("AAG",1,xFilial("AAG")+AB7->AB7_CODPRB, "AAG_DESCRI")  // Alltrim(AB7->AB7_DSCOCO) 
		
	   		cGrupoPrd := Posicione("SB1",1,xFilial("SB1")+AB7->AB7_CODPRO, "B1_GRUPO") 
			 
			If !Empty(cGrupoPrd)
		  		_cLinProd := Posicione("SBM",1,xFilial("SBM")+cGrupoPrd,"BM_DESC")
			EndIf    
				
			If !Empty(_cNumCham) .AND. AB1->(DbSeek(xFilial("AB1")+_cNumCham)) // AB1_FILIAL+AB1_NRCHAM
			
				_cNomeCon := Alltrim(AB1->AB1_CONTAT)
				_cEmiteOs := Alltrim(AB1->AB1_ATEND) 
				
				If AB2->(DbSeek(xFilial("AB2")+AB1->AB1_NRCHAM))

					While AB2->(!Eof()) .AND. xFilial("AB2") == AB2->AB2_FILIAL .AND. AB2->AB2_NRCHAM == AB1->AB1_NRCHAM

						If !Empty(_cMensOrS)
							_cMensOrS += " | "
						End

			   			_cMensOrS += fBuscaMemo(AB2->AB2_MEMO,"AB2_MEMO")
			   		
						
						AB2->(DbSkip())
				
					EndDo 
					
			 	EndIf
			
			Else
			
				_cEmiteOs := AllTrim(AB6->AB6_ATEND)
			
			EndIf
						
			lPrimLin := .T.
			
			oSection1:PrintLine() 
			
			oSection2:Init() 
			
			While AB7->(!Eof()) .AND. xFilial("AB7") == AB7->AB7_FILIAL .AND. (cAlias1)->AB6_NUMOS == AB7->AB7_NUMOS
				
				If !lPrimLin
				
					oReport:SkipLine(1) 
					oReport:ThinLine()
					//oReport:SkipLine(1)  
				
				EndIf
				
				lPrimLin := .F.
					
				oReport:IncMeter()
				
				_cDescPrd := Alltrim(Posicione("SB1",1,xFilial("SB1")+AB7->AB7_CODPRO, "B1_DESC"))
				
				oSection2:PrintLine()
				
				AB7->(DbSkip())
				
			EndDo 
			
		  	oSection2:Finish()			
			oSection1:Finish()
			
		EndIf 
		
		oReport:SkipLine(1)
		oReport:ThinLine()
					
		fImpRodape( oReport )
		
		oReport:EndPage()
		
		(cAlias1)->(DbSkip())
		
	EndDo
				
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RegEntrega() 
Busca o Região de Entrega...
                
@sample		RegEntrega(cAlias1) 

@author		Alessandro Smaha
@since		17/11/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function RegEntrega(cAlias1)     

Local cRegEntr	:= ""   

cEndEntr := Posicione("SX5",1,xFilial("SX5")+"A2"+(cAlias1)->A1_REGIAO,"X5_DESCRI") 

Return cEndEntr


//-------------------------------------------------------------------
/*/{Protheus.doc} fEndEntrega() 
Busca o Endereço de Entrega...
                
@sample		fEndEntrega(cAlias1) 

@author		Alessandro Smaha
@since		17/11/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fEndEntrega(cCodCli,cLojCli,cCodSeq)     

Local cQry   	:= ""    

_cEndEntr := ""
_cComEntr := ""
_cBaiEntr := ""   
_cCEPEntr := ""  
_cCidEntr := "" 
_cEstEntr := ""

If cCodSeq == "000" // Busca o endereço padrão do cliente 

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
		
		_cEndEntr := Alltrim(SA1->A1_END)
		_cComEntr := Alltrim(SA1->A1_COMPLEM)
		_cBaiEntr := Alltrim(SA1->A1_BAIRRO)   
		_cCEPEntr := Alltrim(SA1->A1_CEP)  
		_cCidEntr := Alltrim(SA1->A1_MUN) 
		_cEstEntr := Alltrim(SA1->A1_EST)
				
	EndIf 
		
 	_cEndEntr += "    COMPLEMENTO: "+_cComEntr+"    BAIRRO: "+_cBaiEntr+"    CEP: "+IIF(Empty(_cCEPEntr),"",Substr(_cCEPEntr,1,5)+"-"+Substr(_cCEPEntr,7,3))

ElseIf cCodSeq == "999" // Busca o endereço de entrega padrão do cliente 

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
		
		_cEndEntr := Alltrim(SA1->A1_ENDENT)
		_cComEntr := Alltrim(SA1->A1_XCOMPEN)
		_cBaiEntr := Alltrim(SA1->A1_BAIRROE)  
		_cCEPEntr := Alltrim(SA1->A1_CEPE)  
		_cCidEntr := Alltrim(SA1->A1_MUNE)
		_cEstEntr := Alltrim(SA1->A1_ESTE)
						
	EndIf
	
 	_cEndEntr += "    COMPLEMENTO: "+_cComEntr+"    BAIRRO: "+_cBaiEntr+"    CEP: "+IIF(Empty(_cCEPEntr),"",Substr(_cCEPEntr,1,5)+"-"+Substr(_cCEPEntr,7,3))

Else
	
	cQry := " SELECT Z08_ENDERE,Z08_EST,Z08_MUN,Z08_DESCRI "  
	cQry += " FROM " + RetSqlName('Z08') + ' Z08 ' 
	cQry += " WHERE "
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
		_cEndEntr := Alltrim(QSEQ->Z08_ENDERE)
		_cComEntr := Alltrim(QSEQ->Z08_DESCRI)
		_cBaiEntr := ""   
		_cCEPEntr := ""  
		_cCidEntr := AllTrim(QSEQ->Z08_MUN) 
		_cEstEntr := QSEQ->Z08_EST
	EndIf 
			
 	_cEndEntr += "    COMPLEMENTO: "+_cComEntr

EndIf 

Return 



//-------------------------------------------------------------------
/*/{Protheus.doc} fImpRodape
Imprime o rodapé para o relatório
                
@sample		fImpRodape(oReport)

@author		Alessandro Smaha
@since		14/11/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fImpRodape( oReport ) 
 
Local nLin	:= oReport:Row() 
Local nMarg	:= 0025
Local nEsp0	:= 0015
Local nEsp1	:= 0030
Local nEsp2	:= 0045 
Local nEsp3	:= 0060
Local nEsp4	:= 0075 
Local nEsp5	:= 0090
Local nC00I := 0010
Local nC001 := 0300
Local nC002 := 0590
Local nC003 := 0880
Local nC004 := 1170
Local nC005 := 1460
Local nC006 := 1750
Local nC007 := 2040
Local nC00F := 2330
Local nLimLin	:= 1450
Local nCorBco  	:= 16777215
Local nCorCza  	:= 5921370
Local nCorClr  	:= 14211288
Local oFont08  	:= TFont():New("Arial",	08,08,,.F.,,,,.T.,.F.)	// Arial   08 sem negrigo 
Local oFont08N	:= TFont():New("Arial",	08,08,,.T.,,,,.T.,.F.)	// Arial   08 com negrigo
Local oFont09  	:= TFont():New("Arial",	09,09,,.F.,,,,.T.,.F.)	// Arial   09 sem negrigo 
Local oFont09N	:= TFont():New("Arial",	09,09,,.T.,,,,.T.,.F.)	// Arial   09 com negrigo
Local oFont10  	:= TFont():New("Arial",	10,10,,.F.,,,,.T.,.F.)	// Arial   10 sem negrigo 
Local oFont10N	:= TFont():New("Arial",	10,10,,.T.,,,,.T.,.F.)	// Arial   10 com negrigo
Local oFont11  	:= TFont():New("Arial",	11,11,,.F.,,,,.T.,.F.)	// Arial   11 sem negrigo 
Local oFont11N	:= TFont():New("Arial",	11,11,,.T.,,,,.T.,.F.)	// Arial   11 com negrigo
Local oBrush1	:= TBrush():New( , nCorCza)
Local oBrush2	:= TBrush():New( , nCorClr)

// OBSERVAÇÕES DO TÉCNICO

nLin += nEsp3 

If nLin > nLimLin 
	oReport:EndPage()
	nLin := 250
Else
	nLin := nLimLin
EndIf

oReport:Box(  nLin, nC00I, nLin + (nEsp3*3), nC00F )
oReport:Line( nLin, nC002, nLin + (nEsp3*3), nC002 ) // Linha Vertical 

nLin += nEsp3

oReport:Say ( nLin+05, nC00I+075, "OBSERVAÇÕES DO TÉCNICO", oFont09N)
oReport:Say ( nLin+35, nC00I+105, "(use o verso se precisar)", oFont09N)

oReport:Line( nLin, nC002, nLin, nC00F ) // Linha Horizontal 

nLin += nEsp3

oReport:Line( nLin, nC002, nLin, nC00F ) // Linha Horizontal

nLin += nEsp5 

// AUTORIZAÇÃO PARA EXECUÇÃO DO SERVIÇO

//oReport:FillRect( { nLin, nC00I, nLin + nEsp3, nC00F }, oBrush1 ) 
oReport:Box(  nLin, nC00I, nLin + (nEsp3*6) + nEsp0, nC00F )  
oReport:Say ( nLin+15, nC003, "AUTORIZAÇÃO PARA EXECUÇÃO DO SERVIÇO", oFont09N) 

nLin += nEsp3 

oReport:Line( nLin, nC00I, nLin, nC00F ) // Linha Horizontal 

oReport:Say( nLin+nEsp0, nC00I+nMarg, "Prezado Cliente,",oFont08) 

nLin += nEsp2

oReport:Say( nLin+nEsp0, nC00I+nMarg, "Favor informar ao nosso funcionário os locais onde não corre-se perigo de perfuração da tubulação de água e/ou eletricidade, onde serão instalados os equipamentos. Desta maneira eximimo-nos de qualquer",oFont08) 
nLin += nEsp1
oReport:Say( nLin+nEsp0, nC00I+nMarg, "dano eventualmente causado nestas tubulações. Aparelho parafusado não cai! No caso do cliente preferir só a colagem, fica sob sua responsabilidade danos que venham ocorrer aos mesmos.",oFont08) 
nLin += nEsp1
oReport:Say( nLin+nEsp0, nC00I+nMarg, "Caso o aparelho colado caia e quebre, eu, o cliente serei o responsável.",oFont08) 
nLin += nEsp1                                                                                           
oReport:Say( nLin+nEsp0, nC00I+nMarg, "Autorizo a execução do serviço e estou ciente das informações acima.",oFont08N) 

nLin += nEsp3

oReport:Line( nLin, nC00I, nLin, nC00F ) // Linha Horizontal

oReport:Say ( nLin+nEsp0, nC00I+nMarg, "NOME DO RESPONSÁVEL PELA AUTORIZAÇÃO:", oFont09N)

nLin += nEsp3

oReport:Line( nLin, nC00I, nLin, nC00F ) // Linha Horizontal 

oReport:Say ( nLin+nEsp0, nC00I+nMarg, "ASSINATURA DO RESPONSÁVEL PELA AUTORIZAÇÃO:", oFont09N)
oReport:Say ( nLin+nEsp0, nC005+nMarg, "DOCUMENTO:", oFont09N)

oReport:Line( nLin, nC005, nLin + nEsp3, nC005 ) // Linha Vertical 

nLin += nEsp5 

// ENTREGA DO SERVIÇO

//oReport:FillRect( { nLin, nC00I, nLin + nEsp3, nC00F }, oBrush1 ) 
//oReport:FillRect( { nLin+nEsp3, nC00I, nLin + nEsp3 + nEsp2, nC002 }, oBrush2 )
//oReport:FillRect( { nLin+nEsp3, nC004, nLin + nEsp3 + nEsp2, nC006 }, oBrush2 ) 
oReport:Box(  nLin, nC00I, nLin + (nEsp3*4), nC00F )
oReport:Say ( nLin+15, nC003+180, "ENTREGA DO SERVIÇO", oFont09N) 

nLin += nEsp3 

oReport:Line( nLin, nC00I, nLin, nC00F ) // Linha Horizontal

oReport:Line( nLin, nC001, nLin + (nEsp3*2), nC001 ) // Linha Vertical 
oReport:Line( nLin, nC002, nLin + (nEsp3*2), nC002 ) // Linha Vertical 
oReport:Line( nLin, nC003, nLin + (nEsp3*2), nC003 ) // Linha Vertical 
oReport:Line( nLin, nC004, nLin + (nEsp3*2), nC004 ) // Linha Vertical 
oReport:Line( nLin, nC005, nLin + (nEsp3*3), nC005 ) // Linha Vertical 
oReport:Line( nLin, nC006, nLin + (nEsp3*2), nC006 ) // Linha Vertical 
oReport:Line( nLin, nC007, nLin + (nEsp3*2), nC007 ) // Linha Vertical  
                                                         
oReport:Say( nLin+05, nC00I+050, "DATA CHEGADA",oFont08N)
oReport:Say( nLin+05, nC001+050, "HORA CHEGADA",oFont08N)
oReport:Say( nLin+05, nC002+050, "DATA ÍNICIO", oFont08N)
oReport:Say( nLin+05, nC003+050, "HORA ÍNICIO", oFont08N)
oReport:Say( nLin+05, nC004+050, "DATA FIM", 	oFont08N)
oReport:Say( nLin+05, nC005+050, "HORA FIM", 	oFont08N)
oReport:Say( nLin+05, nC006+050, "DATA SAÍDA", 	oFont08N)
oReport:Say( nLin+05, nC007+050, "HORA SAÍDA", 	oFont08N)

nLin += nEsp2 // 045

oReport:Line( nLin, nC00I, nLin, nC00F ) // Linha Horizontal  

oReport:Say( nLin+nEsp1, nC00I+020, "___ / ___ / _____",oFont11)   
oReport:Say( nLin+nEsp1, nC001+080, "___ : ___ ",oFont11)
oReport:Say( nLin+nEsp1, nC002+020, "___ / ___ / _____",oFont11)   
oReport:Say( nLin+nEsp1, nC003+080, "___ : ___ ",oFont11)
oReport:Say( nLin+nEsp1, nC004+020, "___ / ___ / _____",oFont11)   
oReport:Say( nLin+nEsp1, nC005+080, "___ : ___ ",oFont11)
oReport:Say( nLin+nEsp1, nC006+020, "___ / ___ / _____",oFont11)   
oReport:Say( nLin+nEsp1, nC007+080, "___ : ___ ",oFont11)

nLin += nEsp4

oReport:Line( nLin, nC00I, nLin, nC00F ) // Linha Horizontal  

oReport:Say( nLin+nEsp0, nC00I+nMarg, "TÉCNICO RESPONSÁVEL PELO SERVIÇO:",oFont09N) 
oReport:Say( nLin+nEsp0, nC005+nMarg, "ASSINATURA DO TÉCNICO:",oFont09N)   

nLin += nEsp5 

// ACEITE DO SERVIÇO

//oReport:FillRect( { nLin, nC00I, nLin + nEsp3, nC00F }, oBrush1 ) 
oReport:Box(  nLin, nC00I, nLin + (nEsp3*4), nC00F )
oReport:Say ( nLin+nEsp0, nC003+200, "ACEITE DO SERVIÇO", oFont09N)

//oReport:Line( nLin + nEsp3, nC002, nLin + (nEsp3*4), nC002 ) // Linha Vertical
oReport:Line( nLin + (nEsp3*2), nC005, nLin + (nEsp3*3), nC005 ) // Linha Vertical  
oReport:Line( nLin+nEsp3, nC00I, nLin+nEsp3, nC00F ) // Linha Horizontal

nLin += nEsp0 

oReport:Say ( nLin+(nEsp3*1), nC00I+nMarg, "NOME DO RESPONSÁVEL PELO ACEITE:", oFont09N)
oReport:Say ( nLin+(nEsp3*2), nC00I+nMarg, "ASSINATURA DO RESPONSÁVEL PELO ACEITE:", oFont09N)   
oReport:Say ( nLin+(nEsp3*2), nC005+nMarg, "DOCUMENTO:", oFont09N)
oReport:Say ( nLin+(nEsp3*3), nC00I+nMarg, "SERVIÇO REALIZADO ATENDEU A EXPECTATIVA?  (  )SIM   (  )NÃO, POR QUE: ", oFont09N)

nLin += nEsp3 
nLin += nEsp2 

oReport:Line( nLin, nC00I, nLin, nC00F ) // Linha Horizontal

nLin += nEsp3 

oReport:Line( nLin, nC00I, nLin, nC00F ) // Linha Horizontal

nLin += nEsp4 

oReport:Say ( nLin, nC00I, Replicate("- ",137), oFont09N)

nLin += nEsp3 

// RECIBO DA ORDEM DE SERVIÇO 

//oReport:FillRect( { nLin, nC00I, nLin + nEsp3, nC00F }, oBrush1 ) 
oReport:Box(  nLin, nC00I, nLin + (nEsp3*9), nC00F )
oReport:Say ( nLin+nEsp0, nC003, "RECIBO DA ORDEM DE SERVIÇO "+_cTitulOS, oFont09N)

oReport:Line( nLin+nEsp3, nC00I, nLin+nEsp3, nC00F ) // Linha Horizontal
oReport:Line( nLin + (nEsp3*2), nC002, nLin + (nEsp3*5), nC002 ) // Linha Vertical 

oReport:Line( nLin + (nEsp3*2), nC00I, nLin + (nEsp3*2), nC00F ) // Linha Horizontal
oReport:Line( nLin + (nEsp3*3), nC002, nLin + (nEsp3*3), nC00F ) // Linha Horizontal
oReport:Line( nLin + (nEsp3*4), nC002, nLin + (nEsp3*4), nC00F ) // Linha Horizontal  
oReport:Line( nLin + (nEsp3*5), nC00I, nLin + (nEsp3*5), nC00F ) // Linha Horizontal

nLin += nEsp4 

oReport:Say ( nLin, nC00I+150, "CLIENTE:", oFont09N) 
oReport:Say ( nLin, nC001+010, _cCodNCli, oFont09)  

/*
nLin += nEsp2

oReport:Say ( nLin, nC00I+nMarg, "TIPO DE SERVIÇO:", oFont09N)
oReport:Say ( nLin, nC001+010, _cTipServ, oFont09) 

oReport:Say ( nLin, nC003, "OCORRÊNCIA:", oFont09N)
oReport:Say ( nLin, nC003+220, _cOcorren, oFont09)

oReport:Say ( nLin, nC006, "LINHA:", oFont09N)
oReport:Say ( nLin, nC006+120, _cLinProd, oFont09)
*/

nLin += nEsp3 
nLin += nEsp3

oReport:Say ( nLin, nC00I+120, "OBSERVAÇÕES GERAIS:", oFont09N)

nLin += nEsp4 
nLin += nEsp4

oReport:Say ( nLin, nC005, "Data e Hora ____ / ____ / _______ - ____ : ____ ", oFont08)
  
nLin += nEsp4

oReport:Say ( nLin, nC002, Replicate("_",60), oFont08)  
oReport:Say ( nLin, nC005, Replicate("_",60), oFont08)

nLin += nEsp2

oReport:Say ( nLin, nC003, "Nome do Técnico", oFont08)  
oReport:Say ( nLin, nC006, "Assinatura do Técnico", oFont08)

nLin += nEsp2

oReport:Say ( nLin, nC00I+150,	"Distribuidor Exclusivo Kimberly Clark, Ecolab, Netter, Dixie, TTS, 3M - Rua Mercedes Seiler Rocha, 423 - "+;
								"Bacacheri - Curitiba/PR (41) 3360 8500 / 0800 644 0350 - www.sentax.com.br", oFont08) 

Return

 
//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaMemo
Busca o conteudo de um campo memo

@sample		fBuscaMemo()

@author		Alessandro Smaha
@since		13/03/2015
@version 	P11
/*/
//------------------------------------------------------------------- 
Static Function fBuscaMemo( cCodSYP, cCampoCod )  
                   
Local cQuery 	:= ""
Local cContMemo := ""  

If !Empty(cCodSYP) 

	If !Empty(cCodSYP)
	
		If (Select("QMEM") <> 0)
			DbSelectArea("QMEM")
			QMEM->(DbCloseArea())
		Endif
		
		cQuery := " SELECT YP_TEXTO "
		cQuery += " FROM "+RetSQLName("SYP")+" " 
		cQuery += " WHERE YP_CHAVE = '"+cCodSYP+"' "
		cQuery += " 	AND D_E_L_E_T_ <> '*' "  
		If ! Empty(cCampoCod)
			cQuery += " 	AND YP_CAMPO = '"+cCampoCod+"' " 	
		EndIf
		cQuery += " ORDER BY YP_SEQ " 
		
		TCQuery cQuery new Alias "QMEM"
		
		QMEM->(DbGoTop())
		
		If QMEM->(!Eof())   
			
			While QMEM->(!Eof()) 
				cContMemo += Rtrim(QMEM->YP_TEXTO)
				QMEM->(DbSkip()) 	
			EndDo   
			
			cContMemo := Alltrim(StrTran(cContMemo, "\13\10",chr(13)+chr(10))) 
		
		EndIf  
		
		cContMemo := Substr(cContMemo,1,440)
		
	EndIf 
		
EndIf
	
Return cContMemo 


//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC006P
Chama a impressão do relatório para a OS posicionada no browse
                
@sample		U_RTEC006P()

@author		Alessandro Smaha
@since		29/11/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function RTEC006P() 

U_RTEC006(AB6->AB6_NUMOS) 

Return
       
     
//-------------------------------------------------------------------------------
/*/{Protheus.doc} fAjustaSX1
Cria as perguntas do programa

@author		Alessandro Smaha
@since		17/11/2016
/*/
//-------------------------------------------------------------------------------
Static Function fAjustaSX1()

Local aHelpPor01 := {"Código da Ordem de Serviço."}
Local aHelpPor02 := {"Código da Ordem de Serviço."}
Local aHelpPor03 := {"Qual moeda ?"}
Local aHelpPor04 := {"Outras Moedas ?"}
Local aHelpPor05 := {"Layout ?"}

PutSX1(cPerg,"01","Nr.OS de ?","" ,"" ,"MV_CH1" ,"C",6,0,0,"G","","AB6","","S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor01 ,{},{})
PutSX1(cPerg,"02","Nr.OS ate ?","" ,"" ,"MV_CH2" ,"C",6,0,0,"G","","AB6","","S","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor02 ,{},{})


PutSx1(cPerg,"03","Qual Moeda ?","",""	,"MV_CH3","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR03",;
				 		"Moeda 1","Moeda 1","Moeda 1","","Moeda 2","Moeda 2","Moeda 2","Moeda 3","Moeda 3","Moeda 3","Moeda 4","Moeda 4","Moeda 4","Moeda 5","Moeda 5","Moeda 5",aHelpPor03) 

PutSx1(cPerg,"04","Outras Moedas ?","",""	,"MV_CH4","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR04",;
				 		"Converter","Converter","Converter","","Nao imprimir","Nao imprimir","Nao imprimir",,,,,,,,,,aHelpPor04) 
				 		
PutSx1(cPerg,"05","Layout ?","",""	,"MV_CH5","N",1					 	,0,0,"C",,/*cF3*/,,,"MV_PAR05",;
				 		"Novo","Novo","Novo","","Anterior","Anterior","Anterior",,,,,,,,,,aHelpPor05) 

Return    
