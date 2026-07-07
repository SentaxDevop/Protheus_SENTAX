#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS003
Espelho NF
	
@author Leandro Natan Bonette Santos
@since 09/12/2013
@version 1.0		

@return nil, Nulo


/*/
//-------------------------------------------------------------------------------
User Function ROMS003()
	
	Local oReport   := nil 
	Local aItensEsp := {}
	
	Private _aItensAgr := {}
	Private _aItensONf := {}
	
	oReport := ReportDef()
	oReport:PrintDialog()

	If ! Empty(_aItensAgr) 
		If MsgYesNo("Deseja Imprimir Etiquetas de Produto ?", "Impressora ARGOX [ROMS003]") // Adicionado em 15/05/2014 por Alessandro Smaha 
			aItensEsp := { _aItensAgr, _aItensONf }   
			U_ROMS004B(aItensEsp) 
		EndIf 	
	EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do relatório
	
@author Leandro Natan Bonette Santos
@since 09/12/2013
@version 1.0		

@return oReport, Objeto TReport configurado


/*/
//-------------------------------------------------------------------------------
Static Function ReportDef()
	
	Local oReport    := nil
	Local oSectCarga := nil
	Local oSectCabNF := nil
	Local oSectItmNF := nil
	Local oSectRodap := nil
	Local cDoc       := ""
	Local cSerie     := ""

	Local cTitle    := "Espelho NF de saída"
	Local cQryRel   := GetNextAlias()   
	
	Local cDescric := "Este relatorio tem o objetivo de facilitar a retirada de materiais " + ;
					  "apos o Faturamento de uma NF "

	Private cPerg   :="ROMS003" 


	oReport:= TReport():New("ROMS003",cTitle,cPerg, {|oReport| ReportPrint(oReport,cQryRel)},cDescric)
	oReport:SetPortrait()
	oReport:nFontBody := 12
	oReport:nLineHeight := 45
	//------------------------------------------------
	// Ajusta o grupo de perguntas
	//------------------------------------------------
	AjustaSX1()
	//------------------------------------------------

	//------------------------------------------------
	// Variaveis utilizadas para parametros
	//------------------------------------------------
	// MV_PAR01 - De NF saída
	// MV_PAR02 - Até NF saída
	// MV_PAR03 - Da série
	// MV_PAR04 - Até série
	// MV_PAR05 - De Data entrega
	// MV_PAR06 - Até data entrega
	// MV_PAR07 - Cliente De
	// MV_PAR08 - Cliente ate
	// MV_PAR09 - Carga de
	// MV_PAR10 - Carga ate	
	//------------------------------------------------
	Pergunte(oReport:GetParam(),.F.)
	//------------------------------------------------
	

	//---------------------------------------------------------------------------------------------------------
	// oSectCarga - Folha de rosto com os dados da carga	
	//---------------------------------------------------------------------------------------------------------
	oSectCarga := TRSection():New(oReport,"Folha de rosto por carga",{"DAK","SB1","SD2"},/*Ordem*/)
	
	TRCell():New(oSectCarga,'DAK_COD'  ,'DAK',"Carga"        ,/*Picture*/,TamSX3('DAK_COD' )[1] + 5   ,.T.)
	TRCell():New(oSectCarga,'D2_COD'   ,'SD2',"Produto"      ,/*Picture*/,TamSX3('D2_COD'  )[1]       ,.F.)
	TRCell():New(oSectCarga,'B1_DESC'  ,'SB1',"Descrição"    ,/*Picture*/,TamSX3('B1_DESC' )[1]+10      ,.F.)    
	TRCell():New(oSectCarga,'D2_QUANT' ,'SD2',"Quantidade"   ,/*Picture*/,TamSX3('D2_QUANT')[1]+3     ,.F.)
	TRCell():New(oSectCarga,'D2_UM'    ,'SD2',"U.M."     	 ,/*Picture*/,TamSX3('D2_UM'   )[1]+3     ,.F.)	
	TRCell():New(oSectCarga,'D2_LOCAL' ,'SD2',"Local"        ,/*Picture*/,TamSX3('D2_LOCAL')[1]+5     ,.F.)
	//---------------------------------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------------------------------
	// oSectCabNF Cabeçalho do relatório por NF
	//---------------------------------------------------------------------------------------------------------
	oSectCabNF := TRSection():New(oSectCarga,"Cabeçalho do relatório por NF",{"SA2","SF2","SD2","SA4"},/*Ordem*/)
	oSectCabNF:SetLineStyle()
	
	TRCell():New(oSectCabNF,'DAI_COD'   ,'DAI',"Código da Carga..",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'A2_COD'    ,'SA2',"Codigo do cliente",/*Picture*/,/*Tamanho*/,.T.)
	TRCell():New(oSectCabNF,'A2_LOJA'   ,'SA2',"Loja.............",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'A2_NOME'   ,'SA2',"Nome.............",/*Picture*/,/*Tamanho*/,.F.)    
	TRCell():New(oSectCabNF,'A2_CGC'    ,'SA2',"CPF/CNPJ.........",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'A2_MUN'    ,'SA2',"Municipio........",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'A2_EST'    ,'SA2',"Estado...........",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'D2_DOC'    ,'SD2',"Nota Fiscal......",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'D2_SERIE'  ,'SD2',"Serie............",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'D2_PEDIDO' ,'SD2',"Pedido de Venda..",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'A4_COD'    ,'SA4',"Código Transport.",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'A4_NOME'   ,'SA4',"Transportadora...",/*Picture*/,/*Tamanho*/,.F.) 
	TRCell():New(oSectCabNF,'F2_TPFRETE','SF2',"Tipo Frete.......",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'F2_VOLUME1','SF2',"Volume...........",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'F2_ESPECI1','SF2',"Especie..........",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'F2_PLIQUI' ,'SF2',"Peso Liquido.....",/*Picture*/,/*Tamanho*/,.F.)
	TRCell():New(oSectCabNF,'F2_PBRUTO' ,'SF2',"Peso Bruto.......",/*Picture*/,/*Tamanho*/,.F.)    	
	

	oSectCabNF:Cell('A2_COD'    ):SetCellBreak()
	oSectCabNF:Cell('A2_LOJA'   ):SetCellBreak()
	oSectCabNF:Cell('A2_NOME'   ):SetCellBreak()
	oSectCabNF:Cell('A2_CGC'    ):SetCellBreak()
	oSectCabNF:Cell('A2_MUN'    ):SetCellBreak()
	oSectCabNF:Cell('A2_EST'    ):SetCellBreak()
	oSectCabNF:Cell('D2_DOC'    ):SetCellBreak()
	oSectCabNF:Cell('D2_SERIE'  ):SetCellBreak()
	oSectCabNF:Cell('D2_PEDIDO' ):SetCellBreak()
	oSectCabNF:Cell('A4_COD'    ):SetCellBreak()
	oSectCabNF:Cell('A4_NOME'   ):SetCellBreak()
	oSectCabNF:Cell('F2_TPFRETE'):SetCellBreak()
	oSectCabNF:Cell('F2_VOLUME1'):SetCellBreak()
	oSectCabNF:Cell('F2_ESPECI1'):SetCellBreak()
	oSectCabNF:Cell('F2_PLIQUI' ):SetCellBreak()
	oSectCabNF:Cell('F2_PBRUTO' ):SetCellBreak()
	oSectCabNF:Cell('DAI_COD'   ):SetCellBreak()
	//---------------------------------------------------------------------------------------------------------


	
	//---------------------------------------------------------------------------------------------------------
	// oSectItmNF Itens da NF
	//---------------------------------------------------------------------------------------------------------
	oSectItmNF := TRSection():New(oSectCabNF,"Itens da NF",{"SD2","SB1","SB5"},/*Ordem*/)
	oSectItmNF:SetHeaderSection()
	
	TRCell():New(oSectItmNF,'D2_COD'    ,'SD2',"Produto"    , , TamSX3("D2_COD"   )[1] , /*lPixel*/ )
	TRCell():New(oSectItmNF,'B1_DESC'   ,'SD2',"Descrição"  , , TamSX3("B1_DESC"  )[1] + 40 ,/*lPixel*/ )
	TRCell():New(oSectItmNF,'D2_LOCAL'  ,'SD2',"Local"    	, , TamSX3("D2_LOCAL" )[1]   , /*lPixel*/ )
	TRCell():New(oSectItmNF,'D2_UM'     ,'SB1',"Unidade"    , , TamSX3("D2_UM"    )[1]   , /*lPixel*/ )
	TRCell():New(oSectItmNF,'D2_QUANT'  ,'SD2',"Quantidade" , , TamSX3("D2_QUANT" )[1]   , /*lPixel*/ )
	//---------------------------------------------------------------------------------------------------------
	 

	//---------------------------------------------------------------------------------------------------------
	// oSectRodap Rodapé/Totalizadores por NF
	//---------------------------------------------------------------------------------------------------------
	oSectRodap := TRSection():New(oSectItmNF,"Totalizador NF",{"SD2","SC5"},/*Ordem*/)
	oSectRodap:SetLineStyle()
	
	TRCell():New(oSectRodap,'D2_TOTAL'   ,'SD2',"Valor total....."    , ,  , /*lPixel*/ )
	TRCell():New(oSectRodap,'C5_MENNOTA' ,'SC5',"Mens. p/ Nota..."    , ,  , /*lPixel*/ )
	TRCell():New(oSectRodap,'C5_XOBSLOG' ,'SC5',"Obs Logistica..."    , ,  , /*lPixel*/ )
	
	oSectRodap:Cell('D2_TOTAL'   ):SetCellBreak()
	oSectRodap:Cell('C5_MENNOTA' ):SetCellBreak()
	oSectRodap:Cell('C5_XOBSLOG' ):SetCellBreak()
	//---------------------------------------------------------------------------------------------------------		


Return(oReport)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório
	
@author Leandro Natan Bonette Santos
@since 09/12/2013
@version 1.0
		
@param oReport, objeto, Objeto TReport
@param cQryRel, character, Alias da query que será executada

@return nil, Nulo

/*/
//-------------------------------------------------------------------------------
Static Function ReportPrint(oReport, cQryRel)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)
	Local oSection3 := oReport:Section(1):Section(1):Section(1)
	Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1) 
	
	Local cDataDE  := DTOS(MV_PAR05)
	Local cDataATE := DTOS(MV_PAR06)
		
	Local cChavCarga := "" 
	Local cChaveNF   := ""          

	Local cChavDAI := ""   
	Local cChav
	
	Local nI := 0
	Local nJ := 0        
	Local nK := 0
	
	Local aDados := {}  
    Local aNotas := {}
                      
	Local aProdutos := {}
	Local aCabNF    := {}         
	Local aItensNF  := {}                       
	Local aNotas    := {}
	Local aCabNF    := {}
	Local oFontV := TFont():New("Tahoma",16,10 ,,.T.,,,,,.F.,.F.)
	Local oFontT := TFont():New("Tahoma",12,12 ,,.T.,,,,,.F.,.F.)
                   
	Local aDados   := {}
	Local aDadItem := {}    
	Local aProd    := {}     
	Local aNF      := {}    
	Local aItmNF   := {}
	
	Local aPedidos   := {}
	Local cMemNota   := ""
	Local cMemLogist := ""
	Local nTotalNF   := 0
	Local nAltLinha := 0
	Local lSair := .F.
	
	Local oPrn
	 
	
	DbSelectArea("DAI")
	DAI->(DbSetOrder(1)) //FILIAL + CARGA
	
	cSql := "SELECT DAI_COD,F2_DOC,F2_SERIE,D2_ITEM,D2_COD,DAI_DATA,A1_COD,A1_LOJA,A1_NOME,A1_CGC,A1_MUN,A1_EST, A4_COD, A4_NOME,F2_TIPO,F2_TPFRETE,F2_VOLUME1,F2_ESPECI1,F2_PLIQUI,F2_PBRUTO, B1_DESC,D2_CLIENTE,D2_LOJA,D2_LOCAL,D2_UM,D2_QUANT,D2_DOC,D2_SERIE,D2_PEDIDO,D2_TOTAL " 
	cSql += "FROM SF2010 SF2 " 
	cSql += "INNER JOIN "+RetSqlName("SD2")+" SD2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D_E_L_E_T_= ' ' "
	cSql += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA  AND SA1.D_E_L_E_T_= ' ' "
	cSql += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_= ' ' "
	cSql += "LEFT JOIN "+RetSqlName("DAI")+" DAI ON DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.DAI_CLIENT = SF2.F2_CLIENTE AND DAI.DAI_LOJA = SF2.F2_LOJA AND DAI.DAI_DATA BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' AND DAI.D_E_L_E_T_= ' ' "
	cSql += "LEFT JOIN "+RetSqlName("SA4")+" SA4 ON SF2.F2_TRANSP = SA4.A4_COD AND SA4.D_E_L_E_T_ <> '*' "
	cSql += "WHERE  SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.F2_DOC  >= '"+MV_PAR01+"' AND SF2.F2_DOC  <= '"+MV_PAR02+"' AND SF2.F2_SERIE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  AND SA1.A1_COD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND DAI.DAI_COD BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'  AND SF2.D_E_L_E_T_= ' '   
	cSql += "ORDER BY  DAI_COD,F2_DOC,F2_SERIE,D2_ITEM"
	
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql), cQryRel ,.F.,.F.)
	
	(cQryRel)->(DbGoTop())
	                          
	
	oSection1:Init()
	oSection1:lBold     := .T.
	oSection1:oReport:oFontBody := oFontV
	
	oSection2:Init()
	oSection2:oReport:lBold     := .T.
	
	oSection3:Init()
	oSection3:oReport:lBold     := .T.
   
	oSection4:Init()
	oSection4:oReport:lBold     := .T.

             
    oReport:SetMeter((cQryRel)->(RecCount()))
	//---------------------------------------------------------------------------------------------
	// Realiza a leitura dos dados da query e armazena em uma estrutura de arrays
	// para facilitar a impressão das sessões
	//---------------------------------------------------------------------------------------------
	While !oReport:Cancel() .And. !(cQryRel)->(Eof())
  
  		oReport:IncMeter()
  		
		cChavDAI := (cQryRel)->(DAI_COD)
		aProdutos := {}
		aNotas := {}
		
		                                
		While cChavDAI == (cQryRel)->(DAI_COD) 
		    
		    cChav := (cQryRel)->(DAI_COD+F2_DOC+F2_SERIE+A1_COD+A1_LOJA)   

	
			If (cQryRel)->F2_TIPO $ "DB"
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial("SA2")+(cQryRel)->D2_CLIENTE+(cQryRel)->D2_LOJA)				
				aCabNF := {SA2->A2_COD,SA2->A2_LOJA,SA2->A2_NOME,SA2->A2_CGC,SA2->A2_MUN,SA2->A2_EST}
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+(cQryRel)->D2_CLIENTE+(cQryRel)->D2_LOJA)			
				aCabNF := {SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME,SA1->A1_CGC,SA1->A1_MUN,SA1->A1_EST}
			EndIf

			aAdd(aCabNF,(cQryRel)->D2_DOC     )
			aAdd(aCabNF,(cQryRel)->D2_SERIE   )
			aAdd(aCabNF,(cQryRel)->D2_PEDIDO  )
			aAdd(aCabNF,(cQryRel)->A4_COD     )	
			aAdd(aCabNF,(cQryRel)->A4_NOME    )
			aAdd(aCabNF,(cQryRel)->F2_TPFRETE )
			aAdd(aCabNF,(cQryRel)->F2_VOLUME1 )
			aAdd(aCabNF,(cQryRel)->F2_ESPECI1 )
			aAdd(aCabNF,(cQryRel)->F2_PLIQUI  )
			aAdd(aCabNF,(cQryRel)->F2_PBRUTO  )				
			aAdd(aCabNF,(cQryRel)->DAI_COD    )		
			aAdd(aCabNF,{}                    )
			
	        
	        
			aItensNF := {}
			
		    While cChav == (cQryRel)->(DAI_COD+F2_DOC+F2_SERIE+A1_COD+A1_LOJA)
	            
				aAdd(aItensNF ,{(cQryRel)->D2_COD,(cQryRel)->B1_DESC,(cQryRel)->D2_LOCAL,(cQryRel)->D2_QUANT,(cQryRel)->D2_TOTAL,(cQryRel)->D2_PEDIDO,(cQryRel)->D2_UM})
				aAdd(aProdutos,{(cQryRel)->DAI_COD,(cQryRel)->D2_COD,(cQryRel)->B1_DESC,(cQryRel)->D2_LOCAL,(cQryRel)->D2_UM,(cQryRel)->D2_QUANT})
		        
		       	aAdd(_aItensONf,{ (cQryRel)->D2_COD, (cQryRel)->B1_DESC, (cQryRel)->D2_QUANT, .F. })
		       
		    	(cQryRel)->(dbskip())
			End
	
			ATail(aCabNF) := aItensNF
			
			aAdd(aNotas,aCabNF)
		
		End

		aAdd(aDados,{cChavDAI,aProdutos,aNotas})
		
	End             
	//---------------------------------------------------------------------------------------------	      

    oReport:SetMeter((cQryRel)->(len(aDados)))
	//---------------------------------------------------------------------------------------------
	// Imprime os dados nas sessões do relatório	
	//---------------------------------------------------------------------------------------------
	For nI := 1 To Len(aDados)
	
		oReport:IncMeter()
		
		aDadItem := aDados[nI]
		
		aProd := {}
		
		For nJ := 1 To Len(aDadItem[2])
		
			If !Empty(aProd)
			
				If aScan(aProd,{|x|x[1] == aDadItem[2][nJ][1] .AND. x[2] == aDadItem[2][nJ][2]}) > 0
				
				
					aProd[aScan(aProd,{|x|x[1] == aDadItem[2][nJ][1] .AND. x[2] == aDadItem[2][nJ][2]})][6] += aDadItem[2][nJ][6] 
				
				
				Else
				
					AADD(aProd,aDadItem[2][nJ])
				
				Endif
			
			Else
			
				AADD(aProd,aDadItem[2][nJ])
			
			Endif 
		
			
			
		Next nJ
		
		nAltLinha := oReport:LineHeight() 
		oReport:SetLineHeight(nAltLinha + 10)
		For nJ :=1 to len(aProd)
		
			If aScan(_aItensAgr,{ |x| AllTrim(x[1]) == Alltrim((cQryRel)->F2_DOC) .AND. AllTrim(x[2]) == Alltrim((cQryRel)->F2_SERIE) }) == 0
				aAdd(_aItensAgr,{ aProd[nJ][2], aProd[nJ][3], aProd[nJ][6], .F. })
			EndIf

			oSection1:Cell('DAK_COD'  ):SetValue(aProd[nJ][1] )
			oSection1:Cell('D2_COD'   ):SetValue(aProd[nJ][2] )
			oSection1:Cell('B1_DESC'  ):SetValue(aProd[nJ][3] )
			oSection1:Cell('D2_LOCAL' ):SetValue(aProd[nJ][4] )
			oSection1:Cell('D2_UM'    ):SetValue(aProd[nJ][5] )
			oSection1:Cell('D2_QUANT' ):SetValue(aProd[nJ][6] )
                     
			oSection1:PrintLine()		
			oReport:ThinLine()
			
			If nJ == len(aProd)
			
				DAI->(DbSeek(xFilial("DAI")+aProd[nJ][1]))
				
				lSair := .F.
				
				While DAI->(!Eof()) .AND. DAI->DAI_FILIAL == xFilial("DAI") .AND. DAI->DAI_COD == aProd[nJ][1] .AND. !lSair
				
				
					If Empty(DAI->DAI_NFISCA)
					
						lSair := .T.
						oReport:SkipLine()
						oReport:PrintText("      ******      CARGA EM ABERTO      ******", ,oReport:PageWidth()/3 )
						
					Endif
				
					DAI->(DbSkip())
				Enddo
				
					
				
			
			Endif
			
			
			fRodape(oReport)
			
		
		next nJ 	
		
		oReport:EndPage()
		
		oReport:SetLineHeight(nAltLinha)
		
		For nJ := 1 To LEN(aDadItem[3])
		      
			aNF := aDadItem[3][nJ]  			              
			
			oSection2:Cell('DAI_COD'    ):SetValue(aNF[17])
			
			oSection2:Cell('A2_COD'     ):SetValue(aNF[1] )
			oSection2:Cell('A2_LOJA'    ):SetValue(aNF[2] )
			oSection2:Cell('A2_NOME'    ):SetValue(aNF[3] )
			oSection2:Cell('A2_CGC'     ):SetValue(aNF[4] )
			oSection2:Cell('A2_MUN'     ):SetValue(aNF[5] )
			oSection2:Cell('A2_EST'     ):SetValue(aNF[6] )
			oSection2:Cell('D2_DOC'     ):SetValue(aNF[7] )
			oSection2:Cell('D2_SERIE'   ):SetValue(aNF[8] )
			oSection2:Cell('D2_PEDIDO'  ):SetValue(aNF[9] )
			oSection2:Cell('A4_COD'     ):SetValue(aNF[10])
			oSection2:Cell('A4_NOME'    ):SetValue(aNF[11])
			oSection2:Cell('F2_TPFRETE' ):SetValue(aNF[12])
			oSection2:Cell('F2_VOLUME1' ):SetValue(aNF[13])
			oSection2:Cell('F2_ESPECI1' ):SetValue(aNF[14])
			oSection2:Cell('F2_PLIQUI'  ):SetValue(aNF[15])
			oSection2:Cell('F2_PBRUTO'  ):SetValue(aNF[16])			

						
			oSection2:PrintLine()
			

			cDoc := aNF[7]
			cSerie:= Alltrim(aNF[8])
			
			aItmNF := aNF[Len(aNF)]

			aPedidos   := {}
			nTotalNF   := 0
			cMemNota   := ""
			cMemLogist := "" 
			
			//---------------------------------------------------------------------------------------------------------
			//Código de Barras                                                 
			//---------------------------------------------------------------------------------------------------------			

			MSBAR3("CODE128",2.3,17,cDoc+cSerie,@oReport:oPrint,.F.,,.T.,.02960,0.8,.T.,"Tohoma","C",.F.)     
		   //	If nK != 0
			  //	oSection3:PrintHeader()			        			
			//EndIf
			 oSection3:Init()
			 oSection3:oReport:oFontBody := oFontV
			
			For nK := 1 TO Len(aItmNF)
			
				oSection3:Cell('D2_COD'   ):SetValue( aItmNF[nK][1] )
				oSection3:Cell('B1_DESC'  ):SetValue( aItmNF[nK][2] )
				oSection3:Cell('D2_LOCAL' ):SetValue( aItmNF[nK][3] )
				oSection3:Cell('D2_QUANT' ):SetValue( aItmNF[nK][4] )
				oSection3:Cell('D2_UM' ):SetValue( aItmNF[nK][7] )
				
							
				oSection3:PrintLine()								
                
				nTotalNF += aItmNF[nK][5]
				
				If aScan(aPedidos,{|cPedido| cPedido == aItmNF[nK][6]}) == 0
					aAdd(aPedidos,aItmNF[nK][6])
				EndIf
				       			
			Next nK		
		
            oSection3:Finish()
			        	             
        	For nK := 1 To Len(aPedidos)
				cMemNota   +=  Alltrim(POSICIONE("SC5",1,XFILIAL("SC5")+aPedidos[nK],"C5_MENNOTA")) + " / "
				cMemLogist +=  Alltrim(POSICIONE("SC5",1,XFILIAL("SC5")+aPedidos[nK],"C5_XOBSLOG")) + " / "
        	Next nK

			cMemNota   := substr(cMemNota  ,1,len(cMemNota  )-3)
			cMemLogist := substr(cMemLogist,1,len(cMemLogist)-3)                    
			
			oReport:SkipLine(10)       
			
			oSection4:Cell('D2_TOTAL'   ):SetValue( nTotalNF   )
			oSection4:Cell('C5_MENNOTA' ):SetValue( cMemNota   )
			oSection4:Cell('C5_XOBSLOG' ):SetValue( cMemLogist )
			
        			                   
		 	oSection4:PrintLine()    			
		
			fRodape(oReport)
			oReport:EndPage()						      
		Next nJ
				
	Next nI
	//---------------------------------------------------------------------------------------------

	(cQryRel)->(DbCloseArea()) 
	
Return



//-------------------------------------------------------------------------------
/*/{Protheus.doc} fRodape
Imprime o rodapé
	
@author Leandro Natan Bonette Santos
@since 09/12/2013
@version 1.0
		
@param oReport, objeto, Objeto TReport

@return nil, Nulo

/*/
//-------------------------------------------------------------------------------
Static Function fRodape(oReport)
	
	Local nAltura  := oReport:PageHeight()
	Local nLargura := oReport:PageWidth()
	Local oFont := TFont():New("Tahoma"     ,08,10 ,,.T.,,,,,.F.,.F.)
	
	                          
	oReport:Line( nAltura - 140  , nLargura / 2             , nAltura-140 ,   nLargura / 2 + 500  )
	oReport:Say(  nAltura - 120  , nLargura / 2 + 100       , "Assinatura Separador",oFont   )
	
	oReport:Line( nAltura - 140  , nLargura / 2 + 650       , nAltura-140, nLargura / 2 + 650 + 500 )
	oReport:Say(  nAltura - 120  , nLargura / 2 + 650 + 100 , "Assinatura Conferente",oFont    )
                                                                                                              
	oReport:Say(  nAltura - 40 , 5 ," Atesto que os itens acima foram devidamente separados" +; 
									" e conferidos e estão em conformidade com os itens do"  + ;
									" Espelho da Nota Fiscal.",oFont )

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do programa
	
@author Leandro Natan Bonette Santos
@since 09/12/2013
@version 1.0		

@return nil, sem retorno

/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1()

	Local aHelpPerg  := {}
	
	aAdd(aHelpPerg,{"Nota fiscal Inicial"})
	aAdd(aHelpPerg,{"Nota fiscal Final"})

	aAdd(aHelpPerg,{"Série inicial da nota fiscal."})
	aAdd(aHelpPerg,{"Série final da nota fiscal."  })

	aAdd(aHelpPerg,{"Data de entrega inicial a ser ",;
	                "considerada."})
	aAdd(aHelpPerg,{"Data de entrega final a ser "  ,;
	                "considerada."})

	aAdd(aHelpPerg,{"Cliente inicial."})
	aAdd(aHelpPerg,{"Cliente Final."  })

	aAdd(aHelpPerg,{"Carga de."})
	aAdd(aHelpPerg,{"Carga até"})
	

	PutSX1(cPerg,"01","De NF saída"      ,"" ,"" ,"MV_PAR01" ,"C",9,0,0,"G","","SF2001" ,"018" ,"S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})
	PutSX1(cPerg,"02","Até NF saída"     ,"" ,"" ,"MV_PAR02" ,"C",9,0,0,"G","","SF2001" ,"018" ,"S","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPerg[2] ,{},{})
	PutSX1(cPerg,"03","Da série"         ,"" ,"" ,"MV_PAR03" ,"C",3,0,0,"G","","",""    ,"S","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPerg[3] ,{},{})
	PutSX1(cPerg,"04","Até série"        ,"" ,"" ,"MV_PAR04" ,"C",3,0,0,"G","","",""    ,"S","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPerg[4] ,{},{})
	PutSX1(cPerg,"05","De Data entrega"  ,"" ,"" ,"MV_PAR05" ,"D",8,0,0,"G","","",""    ,"S","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPerg[5] ,{},{})
	PutSX1(cPerg,"06","Até data entrega" ,"" ,"" ,"MV_PAR06" ,"D",8,0,0,"G","","",""    ,"S","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPerg[6] ,{},{})
	PutSX1(cPerg,"07","Cliente De?"      ,"" ,"" ,"MV_PAR07" ,"C",6,0,0,"G","","SA1"    ,"001" ,"S","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPerg[7] ,{},{})
	PutSX1(cPerg,"08","Cliente ate?"     ,"" ,"" ,"MV_PAR08" ,"C",6,0,0,"G","","SA1"    ,"001" ,"S","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPerg[8] ,{},{})
	PutSX1(cPerg,"09","Carga de?"        ,"" ,"" ,"MV_PAR09" ,"C",6,0,0,"G","","DAK"    ,""    ,"S","MV_PAR09","","","","","","","","","","","","","","","","",aHelpPerg[9] ,{},{})
	PutSX1(cPerg,"10","Carga ate?"       ,"" ,"" ,"MV_PAR10" ,"C",6,0,0,"G","","DAK"    ,""    ,"S","MV_PAR10","","","","","","","","","","","","","","","","",aHelpPerg[10],{},{})


Return                                                                           


//-------------------------------------------------------------------------------
