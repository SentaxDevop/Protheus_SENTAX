#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RFAT003
Atualização de preços
	
@author Felipe Toazza Caldeira
@since 06/10/2015
@version 1.0		

@return nil, Nulo


/*/
//-------------------------------------------------------------------------------
User Function RFAT003()
	
	Local oReport := nil
	
	oReport := ReportDef()
	oReport:PrintDialog()

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do relatório
	
@author Felipe Toazza Caldeira
@since 06/10/2015
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

	Local cTitle    := "Atualiação preços de venda"
	Local cQryRel   := GetNextAlias()   
	
	Local cDescric := "Este relatorio tem o objetivo de facilitar a visualização de alteração de tabelas de preços"

	Private cPerg   :="RFAT003"

	oReport:= TReport():New(cPerg,cTitle,cPerg, {|oReport| ReportPrint(oReport,cQryRel)},cDescric)
	oReport:SetPortrait()

	//------------------------------------------------
	// Ajusta o grupo de perguntas
	//------------------------------------------------
	CriaSx1()

	Pergunte(oReport:GetParam(),.F.)
	
	//---------------------------------------------------------------------------------------------------------
	// oSectCabNF Cabeçalho do relatório por NF
	//---------------------------------------------------------------------------------------------------------
	oSectCab := TRSection():New(oReport,"Linha de produtos",{"SBM"},/*Ordem*/)
	oSectCab:SetLineStyle()
	
	TRCell():New(oSectCab,'BM_GRUPO'   ,'SBM',"Linha"		,"@!",TamSX3("BM_GRUPO")[1]+27,.F.)
	TRCell():New(oSectCab,'BM_DESC'    ,'SBM',"Descrição"	,"@!",TamSX3("BM_DESC" )[1]+5,.F.)

	//---------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------
	// Itens atualizados
	//---------------------------------------------------------------------------------------------------------
	oSectItem := TRSection():New(oSectCab,"Itens atualizados",{"DA1","SB1"},/*Ordem*/)
	oSectItem:SetHeaderSection()                                                                        
	
	TRCell():New(oSectItem,'DA1_CODTAB'    ,'DA1',"Tabela"    ,"@!" , TamSX3('DA1_CODTAB'   )[1] , /*lPixel*/ )	
	TRCell():New(oSectItem,'DA0_DESCRI'    ,'DA0',"Tabela"    ,"@!" , TamSX3('DA0_DESCRI'   )[1] , /*lPixel*/ )	
	TRCell():New(oSectItem,'DA1_CODPRO'    ,'DA1',"Produto"    ,"@!" , TamSX3('DA1_CODPRO'   )[1] , /*lPixel*/ )
	TRCell():New(oSectItem,'B1_DESC'   	   ,'SB1',"Descrição"  ,"@!" , TamSX3('B1_DESC'  )[1] , /*lPixel*/ )
	TRCell():New(oSectItem,'DA1_PRCVEN'    ,'DA1',"Preço"      ,"@E 999,999.9999" , TamSX3('DA1_PRCVEN' )[1] , /*lPixel*/ )
	TRCell():New(oSectItem,'DA1_DTATU'     ,'DA1',"Dt. Atualiz", ,  , /*lPixel*/ )
	//---------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------
	// Itens atualizados
	//---------------------------------------------------------------------------------------------------------
	oSectIte2 := TRSection():New(oSectCab,"Itens não atualizados",{"DA1","SB1"},/*Ordem*/)
	oSectIte2:SetHeaderSection()                                                                        
	
	TRCell():New(oSectIte2,'DA1_CODTAB'    ,'DA1',"Tabela"    ,"@!" , TamSX3('DA1_CODTAB'   )[1] , /*lPixel*/ )	
	TRCell():New(oSectIte2,'DA0_DESCRI'    ,'DA0',"Tabela"    ,"@!" , TamSX3('DA0_DESCRI'   )[1] , /*lPixel*/ )	

	TRCell():New(oSectIte2,'DA1_CODPRO'    ,'DA1',"Produto"    ,"@!" , TamSX3('DA1_CODPRO'   )[1] , /*lPixel*/ )
	TRCell():New(oSectIte2,'B1_DESC'   	   ,'SB1',"Descrição"  ,"@!" , TamSX3('B1_DESC'  )[1] , /*lPixel*/ )
	TRCell():New(oSectIte2,'DA1_PRCVEN'    ,'DA1',"Preço"      ,"@E 999,999.9999" , TamSX3('DA1_PRCVEN' )[1] , /*lPixel*/ )
	TRCell():New(oSectIte2,'DA1_DTATU'     ,'DA1',"Dt. Atualiz", ,  , /*lPixel*/ )

	//---------------------------------------------------------------------------------------------------------
	                                            	

Return(oReport)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório
	
@author Felipe Toazza Caldeira
@since 06/10/2015
@version 1.0
		
@param oReport, objeto, Objeto TReport
@param cQryRel, character, Alias da query que será executada
@return nil, Nulo
/*/
//-------------------------------------------------------------------------------
Static Function ReportPrint(oReport, cQryRel)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)
	Local oSection3 := oReport:Section(1):Section(2)
	
	Local oFontV := TFont():New("Verdana",10,10 ,,.T.,,,,,.F.,.F.)
	Local oFontT := TFont():New("Tahoma"     ,08,10 ,,.T.,,,,,.F.,.F.)
                   
		
	cSql := "SELECT BM_GRUPO,BM_DESC,DA1_CODTAB, DA0_DESCRI, DA1_CODPRO,DA1_PRCVEN,B1_DESC, DA1_DTATU "
	cSql += "FROM "+RetSqlName('DA1')+" DA1 " 
	cSql += "INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO >= '"+MV_PAR02+"' AND SBM.BM_GRUPO <= '"+MV_PAR03+"' AND  SBM.D_E_L_E_T_= ' ' "
	cSql += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SBM')+"' AND SB1.B1_COD = DA1.DA1_CODPRO  AND SB1.B1_MSBLQL != '1' AND SB1.B1_GRUPO = SBM.BM_GRUPO  AND SB1.D_E_L_E_T_= ' ' "
	cSql += "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0.DA0_FILIAL = DA1.DA1_FILIAL AND DA0.DA0_CODTAB = DA1.DA1_CODTAB AND DA0.D_E_L_E_T_= ' ' "
	cSql += "WHERE  DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1.DA1_CODTAB >= '"+MV_PAR04+"' AND DA1.DA1_CODTAB <= '"+MV_PAR05+"' "
	cSql += "  AND DA1.DA1_DTATU  = '"+DtoS(MV_PAR01)+"' AND DA1.D_E_L_E_T_= ' ' "  
	cSql += "ORDER BY  BM_GRUPO,DA1_CODPRO,DA1_CODTAB"
	
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql), cQryRel ,.F.,.F.)
	
	(cQryRel)->(DbGoTop())

	
	oSection1:Init()
	oSection1:oReport:oFontBody := oFontV
	             
    oReport:SetMeter((cQryRel)->(RecCount()))
	//---------------------------------------------------------------------------------------------
	// Realiza a leitura dos dados da query e armazena em uma estrutura de arrays
	// para facilitar a impressão das sessões
	//---------------------------------------------------------------------------------------------
	While !oReport:Cancel() .And. !(cQryRel)->(Eof())
  
  		oReport:IncMeter()
  		
		cChavSBM := (cQryRel)->(BM_GRUPO)
		oSection1:Cell('BM_GRUPO'   ):SetValue((cQryRel)->(BM_GRUPO))
		oSection1:Cell('BM_DESC'    ):SetValue((cQryRel)->(BM_DESC))   
		oSection1:PrintLine()
	
		oSection2:Init()
		oSection2:oReport:lBold     := .T.
		oSection2:oReport:oFontBody := oFontT
		oSection2:PrintLine()
			                                
		While cChavSBM == (cQryRel)->(BM_GRUPO)
			oSection2:Cell('DA1_CODTAB' ):SetValue((cQryRel)->(DA1_CODTAB))
			oSection2:Cell('DA0_DESCRI' ):SetValue((cQryRel)->(DA0_DESCRI)) 
			oSection2:Cell('DA1_CODPRO' ):SetValue((cQryRel)->(DA1_CODPRO))
			oSection2:Cell('B1_DESC'    ):SetValue((cQryRel)->(B1_DESC) )
			oSection2:Cell('DA1_PRCVEN' ):SetValue((cQryRel)->(DA1_PRCVEN))
			oSection2:Cell('DA1_DTATU'  ):SetValue((cQryRel)->(DtoC(Stod(DA1_DTATU))))   

			oSection2:PrintLine()							        
		 	(cQryRel)->(dbskip())
		End
		oReport:SkipLine()
		oReport:ThinLine()
	End             
	
	(cQryRel)->(DbCloseArea())  
	cSql := " SELECT * FROM (
	cSql += " SELECT BM_GRUPO,BM_DESC,DA1_CODTAB,DA0_DESCRI,DA1_CODPRO,DA1_PRCVEN,B1_DESC "
	cSql += " FROM "+RetSqlName('DA1')+" DA1 " 
	cSql += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO >= '"+MV_PAR02+"' AND SBM.BM_GRUPO <= '"+MV_PAR03+"' AND  SBM.D_E_L_E_T_= ' ' "
	cSql += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SBM')+"' AND SB1.B1_COD = DA1.DA1_CODPRO  AND SB1.B1_MSBLQL != '1' AND SB1.B1_GRUPO = SBM.BM_GRUPO  AND SB1.D_E_L_E_T_= ' ' "
	cSql += "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0.DA0_FILIAL = DA1.DA1_FILIAL AND DA0.DA0_CODTAB = DA1.DA1_CODTAB AND DA0.D_E_L_E_T_= ' ' "
	cSql += "WHERE  DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1.DA1_CODTAB >= '"+MV_PAR04+"' AND DA1.DA1_CODTAB <= '"+MV_PAR05+"' "
	cSql += "  AND DA1.DA1_DTATU  != '"+DtoS(MV_PAR01)+"' AND DA1.D_E_L_E_T_= ' ' "  
    cSql += " EXCEPT "
	cSql += " SELECT BM_GRUPO,BM_DESC,DA1_CODTAB,DA0_DESCRI,DA1_CODPRO,DA1_PRCVEN,B1_DESC "
	cSql += " FROM "+RetSqlName('DA1')+" DA1 " 
	cSql += " INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO >= '"+MV_PAR02+"' AND SBM.BM_GRUPO <= '"+MV_PAR03+"' AND  SBM.D_E_L_E_T_= ' ' "
	cSql += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SBM')+"' AND SB1.B1_COD = DA1.DA1_CODPRO  AND SB1.B1_MSBLQL != '1' AND SB1.B1_GRUPO = SBM.BM_GRUPO  AND SB1.D_E_L_E_T_= ' ' "
	cSql += "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0.DA0_FILIAL = DA1.DA1_FILIAL AND DA0.DA0_CODTAB = DA1.DA1_CODTAB AND DA0.D_E_L_E_T_= ' ' "
	cSql += "WHERE  DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1.DA1_CODTAB >= '"+MV_PAR04+"' AND DA1.DA1_CODTAB <= '"+MV_PAR05+"' "
	cSql += "  AND DA1.DA1_DTATU  = '"+DtoS(MV_PAR01)+"' AND DA1.D_E_L_E_T_= ' ' ) AS TEMPDA1"  
	cSql += " ORDER BY  BM_GRUPO,DA1_CODPRO,DA1_CODTAB"
	
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql), cQryRel ,.F.,.F.)
	
	(cQryRel)->(DbGoTop())

	
	oSection1:Init()
	oSection1:oReport:oFontBody := oFontV
	             
    oReport:SetMeter((cQryRel)->(RecCount()))
	//---------------------------------------------------------------------------------------------
	// Realiza a leitura dos dados da query e armazena em uma estrutura de arrays
	// para facilitar a impressão das sessões
	//---------------------------------------------------------------------------------------------
	While !oReport:Cancel() .And. !(cQryRel)->(Eof())
  
  		oReport:IncMeter()
  		
		cChavSBM := (cQryRel)->(BM_GRUPO)
		oSection1:Cell('BM_GRUPO'   ):SetValue((cQryRel)->(BM_GRUPO))
		oSection1:Cell('BM_DESC'    ):SetValue((cQryRel)->(BM_DESC))   
		oSection1:PrintLine()
	
		oSection3:Init()
		oSection3:oReport:lBold     := .T.
		oSection3:oReport:oFontBody := oFontT
		oSection3:PrintLine()							        
			                                
		While cChavSBM == (cQryRel)->(BM_GRUPO)
			oSection3:Cell('DA1_CODTAB' ):SetValue((cQryRel)->(DA1_CODTAB))
			oSection3:Cell('DA0_DESCRI' ):SetValue((cQryRel)->(DA0_DESCRI))
			oSection3:Cell('DA1_CODPRO' ):SetValue((cQryRel)->(DA1_CODPRO))
			oSection3:Cell('B1_DESC'    ):SetValue((cQryRel)->(B1_DESC) )
			oSection3:Cell('DA1_PRCVEN' ):SetValue((cQryRel)->(DA1_PRCVEN))
			oSection3:Cell('DA1_DTATU'  ):SetValue('  /  /    ')
			oSection3:PrintLine()							        
		 	(cQryRel)->(dbskip())
		End
		oReport:SkipLine()
		oReport:ThinLine()

	End             
	
	(cQryRel)->(DbCloseArea())  


Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} CriaSx1
Função para criação de Pergunte                                    admin

@return 
@author Felipe Toazza Caldeira
@since 28/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function CriaSx1( cPerg )

	//Data de até
	PutSx1(cPerg,"01","Data Atualização?"  	,"Data Atualização?" ,"Data Atualização?" 	,"mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"02","Linha De?" 			,"Linha De?"   		 ,"Linha De?"   		,"mv_ch2","C",4,0,0,"G","","SBM","","","mv_par02","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"03","Linha Ate?"			,"Linha Ate?"  		 ,"Linha Ate?"  		,"mv_ch3","C",4,0,0,"G","","SBM","","","mv_par03","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"04","Tabela De?"			,"Tabela Ate?"  	 ,"Tabela Ate?"  		,"mv_ch4","C",4,0,0,"G","","DA0","","","mv_par04","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"05","Tabela Ate?"			,"Tabela Ate?"  	 ,"Tabela Ate?"  		,"mv_ch5","C",4,0,0,"G","","DA0","","","mv_par05","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
             

Return




//-------------------------------------------------------------------------------
