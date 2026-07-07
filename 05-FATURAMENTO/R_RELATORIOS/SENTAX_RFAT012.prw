#include 'rwmake.ch'
#include 'protheus.ch'
#include 'totvs.ch'
#include 'topconn.ch'
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SENTAX_RFAT012
Relatáorio utilizado para Análise de vendas

@author  João Edenilson Lopes
@since   05/02/2020
/*/
//-------------------------------------------------------------------------------
User Function RFAT012()

	Local   oReport := nil	                       

	Private cPerg     :="RFAT012" 
	Private cPictVal  := X3Picture("D2_VALBRUT")
	Private cPictCNPJ := X3Picture("A1_CGC")
	Private cPictInsc := X3Picture("A1_INSCR")
	Private nTotal    := 0 

	oReport := ReportDef()
	oReport:PrintDialog()

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do relatório

@author    João E. Lopes
@since     19/09/2019
@version   1.0		
@return    oReport, Objeto TReport configurado

/*/
//-------------------------------------------------------------------------------
Static Function ReportDef()

	Local oReport      := nil
	Local oSection1    := nil
	Local oSection2    := nil
	Local cTitle       := "Cadastro de Clientes Personalizado"
	Local cDescric     := "Relatório utilizado para Analise de Vendas"
	Local cFilePrint   := "RFAT012_"+Dtos(MSDate())+StrTran(Time(),":","")

	oReport:= TReport():New(cFilePrint,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cDescric)
	oReport:SetLandscape()
	oReport:lPrtParamPage := .F.

	//------------------------------------------------
	// Ajusta o grupo de perguntas
	//------------------------------------------------ 
	CriaPerg()
	//------------------------------------------------

	//------------------------------------------------	
	Pergunte(oReport:GetParam(),.F.)
	//------------------------------------------------

	oSection1 := TRSection():New(oReport,"Análise de Vendas")

	TRCell():New(oSection1,'COD_FIL'	 	,''," COD_FIL"         ,/*Picture*/,TamSX3('A1_FILIAL' ) [1] , .F.,,) 
	TRCell():New(oSection1,'DESC_FIL'   	,''," DESC_FIL"        ,/*Picture*/,TamSX3('B1_DESC'   ) [1] , .F.,,)
	TRCell():New(oSection1,'EMISSAO' 		,''," EMISSAO"         ,/*Picture*/,TamSX3('A1_PRICOM' ) [1] , .F.,,)
	TRCell():New(oSection1,'NF'  			,''," NF"              ,/*Picture*/,TamSX3('D2_DOC'    ) [1] , .F.,,)
	TRCell():New(oSection1,'TIPONF'    		,''," TIPONF"          ,/*Picture*/,TamSX3('D2_TIPO'   ) [1] , .F.,,)
	TRCell():New(oSection1,'GRPROD'   		,''," GRPROD"          ,/*Picture*/,TamSX3('BM_GRUPO'  ) [1] , .F.,,)
	TRCell():New(oSection1,'GRUPOPROD'		,''," GRUPOPROD"       ,/*Picture*/,TamSX3('BM_DESC'   ) [1] , .F.,,)
	TRCell():New(oSection1,'COD_PRODUTO'  	,''," COD_PRODUTO"     ,/*Picture*/,TamSX3('B1_COD'    ) [1] , .F.,,)
	TRCell():New(oSection1,'PRODUTO'    	,''," PRODUTO"         ,/*Picture*/,TamSX3('B1_DESC'   ) [1] , .F.,,)
	TRCell():New(oSection1,'CFOP'     		,''," CFOP"            ,/*Picture*/,TamSX3('D2_CF'     ) [1] , .F.,,)
	TRCell():New(oSection1,'TIPO'  			,''," TIPO"            ,/*Picture*/,TamSX3('D2_TIPO'   ) [1] , .F.,,)
	TRCell():New(oSection1,'QUANTI'     	,''," QUANTI"          ,/*Picture*/,TamSX3('D2_QUANT'  ) [1] , .F.,,)
	TRCell():New(oSection1,'REG'     		,''," REG"             ,/*Picture*/,TamSX3('B1_DESC'   ) [1] , .F.,,)
	TRCell():New(oSection1,'COD_MUN'    	,''," COD_MUN"         ,/*Picture*/,TamSX3('A1_COD_MUN') [1] , .F.,,)
	TRCell():New(oSection1,'MUNIC'   		,''," MUNIC"           ,/*Picture*/,TamSX3('A1_MUN'    ) [1] , .F.,,)
	TRCell():New(oSection1,'ESTADO'  		,''," ESTADO"          ,/*Picture*/,TamSX3('D2_EST'    ) [1] , .F.,,)
	TRCell():New(oSection1,'COD_CLIENTE'  	,''," COD_CLIENTE"     ,/*Picture*/,TamSX3('A1_COD'    ) [1] , .F.,,)
	TRCell():New(oSection1,'LOJA'      		,''," LOJA"            ,/*Picture*/,TamSX3('A1_LOJA'   ) [1] , .F.,,)
	TRCell():New(oSection1,'HISTORICO'    	,''," HISTORICO"       ,/*Picture*/,TamSX3('A1_NOME'   ) [1] , .F.,,)
	TRCell():New(oSection1,'COD_VEND'     	,''," COD_VEND"        ,/*Picture*/,TamSX3('A1_VEND'   ) [1] , .F.,,)
	TRCell():New(oSection1,'VENDEDOR'     	,''," VENDEDOR"        ,/*Picture*/,TamSX3('A3_NREDUZ' ) [1] , .F.,,)
	TRCell():New(oSection1,'COD_OPERADOR'   ,''," COD_OPERADOR"    ,/*Picture*/,TamSX3('UA_OPERADO') [1] , .F.,,)
	TRCell():New(oSection1,'OPERADOR'     	,''," OPERADOR"        ,/*Picture*/,TamSX3('U7_NOME'   ) [1] , .F.,,)
	TRCell():New(oSection1,'NUAVEND1' 		,''," NUAVEND1"        ,/*Picture*/,TamSX3('A3_NREDUZ' ) [1] , .F.,,)
	TRCell():New(oSection1,'NUAVEND2'  		,''," NUAVEND2"        ,/*Picture*/,TamSX3('A3_NREDUZ' ) [1] , .F.,,)
	TRCell():New(oSection1,'TMK' 			,''," TMK"             ,/*Picture*/,TamSX3('B1_DESC'   ) [1] , .F.,,)
	TRCell():New(oSection1,'NCM' 			,''," NCM"             ,/*Picture*/,TamSX3('B1_POSIPI' ) [1] , .F.,,)
	TRCell():New(oSection1,'TIPOCLI' 		,''," TIPOCLI"         ,/*Picture*/,TamSX3('A1_TIPO'   ) [1] , .F.,,)
	TRCell():New(oSection1,'IE'   			,''," IE"              ,/*Picture*/,TamSX3('A1_INSCR'  ) [1] , .F.,,)
	TRCell():New(oSection1,'SUFRAMA'		,''," SUFRAMA"         ,/*Picture*/,TamSX3('A1_SUFRAMA') [1] , .F.,,)
	TRCell():New(oSection1,'GRPTRIB' 		,''," GRPTRIB"         ,/*Picture*/,TamSX3('A1_GRPTRIB') [1] , .F.,,)
	TRCell():New(oSection1,'TPESSOA' 		,''," TPESSOA"         ,/*Picture*/,TamSX3('A1_TPESSOA') [1] , .F.,,)
	TRCell():New(oSection1,'CNAE' 			,''," CNAE"            ,/*Picture*/,TamSX3('A1_CNAE'   ) [1] , .F.,,)
	TRCell():New(oSection1,'SIMPLES' 		,''," SIMPLES"         ,/*Picture*/,TamSX3('A1_SIMPNAC') [1] , .F.,,)
	TRCell():New(oSection1,'MT' 			,''," MT"              ,/*Picture*/,TamSX3('A1_REGESIM') [1] , .F.,,)
	TRCell():New(oSection1,'VENDA' 			,''," VENDA"           ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'PIPI'			,''," PIPI"            ,/*Picture*/,TamSX3('D2_IPI'    ) [1] , .F.,,)
	TRCell():New(oSection1,'IPI' 			,''," IPI"             ,  cPictVal ,TamSX3('D2_VALIPI' ) [1]+2 , .F.,,)
	TRCell():New(oSection1,'ST' 			,''," ST"              ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'RECEITA_BRUTA' 	,''," RECEITA_BRUTA"   ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'PICMS' 			,''," PICMS"           ,/*Picture*/,TamSX3('A1_COD'    ) [1] , .F.,,)
	TRCell():New(oSection1,'ICMS' 			,''," ICMS"            ,/*Picture*/,TamSX3('D2_IPI'    ) [1] , .F.,,)
	TRCell():New(oSection1,'PIS' 			,''," PIS"             ,  cPictVal ,TamSX3('D2_VALIPI' ) [1]+2 , .F.,,)
	TRCell():New(oSection1,'COFINS' 		,''," COFINS"          ,  cPictVal ,TamSX3('D2_VALIPI' ) [1]+2 , .F.,,)
	TRCell():New(oSection1,'DESCONTO' 		,''," DESCONTO"        ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'RECEITA_LIQUIDA',''," RECEITA_LIQUIDA" ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'CUSTO'			,''," CUSTO"           ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'MARGEM_BRUTA' 	,''," MARGEM_BRUTA"    ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'P_CUSTO' 		,''," P_CUSTO"         ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'P_LUCRO'		,''," P_LUCRO"         ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)
	TRCell():New(oSection1,'NUMCTE' 		,''," NUMCTE"          ,/*Picture*/,TamSX3('Z7Z_DOC'   ) [1] , .F.,,)
	TRCell():New(oSection1,'SERCTE' 		,''," SERCTE"          ,/*Picture*/,TamSX3('Z7Z_SERIE' ) [1] , .F.,,)
	TRCell():New(oSection1,'VALFRETE' 		,''," VALFRETE"        ,  cPictVal ,TamSX3('D2_VALBRUT') [1]+2 , .F.,,)

	//TRCell():New(oSection1,'CODIGO'		,'',"CODIGO"           ,/*Picture*/,TamSX3('A1_COD')    [1]+2 ,.F.,,)
	//TRCell():New(oSection1,'LOJA'		,'',"LOJA"             ,/*Picture*/,TamSX3('A1_LOJA')   [1]   ,.F.,,)

Return oReport

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint                                       	
Impressão do relatório

@author  Felipe Caldeira
@param   oReport, objeto, Objeto TReport
@return  nil, Nulo

/*/
//-------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1) 
	Local cAliasQry := GetNextAlias()   
	Local nMargin   := 0
	Local nTotalArm := 0

	Local nT_Quantity      := 0
	Local nT_TotalCost     := 0
	Local nT_TotalNetPrice := 0
	Local nT_Margin        := 0	
	Local _cCteRepet       := " "	
	Local _nVlrRepet       := 0
	Local  cWhere :=  IIf(MV_PAR13 == 1,"%AND SF2.F2_DUPL != ' ' AND%", "%AND%")    // Só Geradores Financeiro? 1-sim 2- nao 
	
	Local cQtdQuery := "" 

	BeginSql Alias cAliasQry

		SELECT                                                                       
		SD2.D2_EMISSAO [EMISSAO],                                                   
		SD2.D2_FILIAL [COD_FIL],                                                    
		CASE                                                                        
		WHEN SD2.D2_FILIAL = '010101' THEN 'SENTAX - CURITIBA'                   
		WHEN SD2.D2_FILIAL = '020201' THEN 'GIBRALTAR - CURITIBA'                
		WHEN SD2.D2_FILIAL = '020202' THEN 'GIBRALTAR - FOZ DO IGUACU'           
		WHEN SD2.D2_FILIAL = '020203' THEN 'GIBRALTAR - JOINVILLE'               
		WHEN SD2.D2_FILIAL = '020204' THEN 'GIBRALTAR - MARILIA'                 
		WHEN SD2.D2_FILIAL = '020205' THEN 'GIBRALTAR - SAO JOSE DOS PINHAIS'    
		WHEN SD2.D2_FILIAL = '030301' THEN 'ARVOREDE - JOINVILLE'                
		WHEN SD2.D2_FILIAL = '040401' THEN 'RADICAL CONSULTORIA DE MARKETING'  END [DESC_FIL],                                                             
		SD2.D2_DOC    [NF],                                                            
		SF2.F2_TIPO   [TIPONF],                                                       
		SB1.B1_GRUPO  [GRPROD],                                                      
		SBM.BM_DESC   [GRUPOPROD],                                                    
		SD2.D2_COD    [COD_PRODUTO],                                                   
		SB1.B1_DESC   [PRODUTO],                                                      
		SD2.D2_QUANT  [QUANTI],                                                      
		SD2.D2_CF     [CFOP],                                                           
		SB1.B1_TIPO   [TIPO],                                                         
		REGIAO.X5_DESCRI [REGIAO],                                                  
		SA1.A1_COD_MUN 	 [COD_MUN],                                                   
		SA1.A1_MUN 		 [MUNIC],                                                         
		SD2.D2_EST       [ESTADO],                                                        
		SA1.A1_COD       [COD_CLIENTE],                                                   
		SA1.A1_LOJA      [LOJA],                                                         
		SA1.A1_NOME      [HISTORICO],                                                    
		SA1.A1_VEND      [COD_VEND],                                                     
		A3VEN.A3_NREDUZ  [VENDEDOR],                                                
		SUA.UA_OPERADO   [COD_OPERADOR],                                              
		SU7.U7_NOME      [OPERADOR],                                                     
		SUA.UA_VEND      [VEND_UA1],                                                     
		VEND1UA.A3_NREDUZ  [NUAVEND1],                                               
		SUA.UA_VEND2       [VEND_UA2],                                                    
		VEND2UA.A3_NREDUZ  [NUAVEND2],                                               
		CASE  WHEN SUA.UA_TMK = '1' THEN 'RECEPTIVO'                                
		WHEN SUA.UA_TMK = '2' THEN 'ATIVO'                                    
		WHEN SUA.UA_TMK = '3' THEN 'PARCERIA'                           
		WHEN SUA.UA_TMK = '4' THEN 'REPRESENTANTE'                            
		WHEN SUA.UA_TMK = '5' THEN 'RETORNO ATIVO'                            
		WHEN SUA.UA_TMK = '6' THEN 'COTAÇÃO'                                  
		WHEN SUA.UA_TMK = '7' THEN 'ORDEM DE SERVIÇO'                         
		WHEN SUA.UA_TMK = '8' THEN 'E-MAIL'                                   
		WHEN SUA.UA_TMK = '9' THEN 'WHATSAPP'                                
		WHEN SUA.UA_TMK = 'S' THEN 'SITE'  
		WHEN SUA.UA_TMK = 'G' THEN 'GOOGLE'
		WHEN SUA.UA_TMK = 'U' THEN 'UPLACES'   
		WHEN SUA.UA_TMK = 'N' THEN 'NAO ATENDIDO'  
		WHEN SUA.UA_TMK = 'R' THEN 'RDSTATION' 
		WHEN SUA.UA_TMK = 'M' THEN 'MARKETPLACE' END  [TMK] ,   
		SD2.D2_VALBRUT [VENDA],                                                     
		SD2.D2_IPI [PIPI],                                                          
		SD2.D2_VALIPI [IPI],                                                        
		CASE WHEN SD2.D2_CF NOT IN ('5949', '6102') THEN (SD2.D2_ICMSRET)  ELSE 0 END [ST],                                                                                   
		ROUND(((SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949', '6102') THEN (SD2.D2_ICMSRET) ELSE 0 END))), 2)  [RECEITA_BRUTA],                       
		SD2.D2_PICM [PICMS], SD2.D2_VALICM [ICMS], SD2.D2_VALIMP6 [PIS], SD2.D2_VALIMP5 [COFINS], SD2.D2_DESCZFC + SD2.D2_DESCZFP      [DESCONTO],                            

		(  SD2.D2_VALBRUT - SD2.D2_VALIPI - (CASE WHEN SD2.D2_CF NOT IN ('5949', '6102') THEN SD2.D2_ICMSRET ELSE 0 END ) -                                                    
		(  CASE WHEN SD2.D2_CF NOT IN ('6110') THEN (SD2.D2_DESCZFC - SD2.D2_DESCZFP) ELSE 0 END )  -                                                                         
		SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 ) [RECEITA_LIQUIDA],                                                                                              

		SD2.D2_CUSTO1 [CUSTO], SD2.D2_VALBRUT - SD2.D2_VALIPI -                                                                                                               
		(  CASE WHEN SD2.D2_CF NOT IN ('6110') THEN SD2.D2_DESCZFC - SD2.D2_DESCZFP ELSE 0 END) -                                                                             
		SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 - SD2.D2_CUSTO1 -                                                                                                  
		(  CASE WHEN SD2.D2_CF NOT IN ('5949', '6102') THEN SD2.D2_ICMSRET ELSE 0 END) [MARGEM_BRUTA],                                                                        

		SD2.D2_CUSTO1 / (SD2.D2_VALBRUT - D2_VALIPI -                                                                                                                         
		(  CASE WHEN SD2.D2_CF NOT IN ('5949', '6102')                                                                                                                        
		AND SD2.D2_ICMSRET < SD2.D2_VALBRUT - SD2.D2_VALIPI THEN SD2.D2_ICMSRET WHEN SD2.D2_VALBRUT - SD2.D2_VALIPI = SD2.D2_ICMSRET  THEN 1 ELSE 0 END)) * 100 [P_CUSTO], 

		( (SD2.D2_VALBRUT - SD2.D2_VALIPI -                                                                                                                                   
		(  CASE WHEN SD2.D2_CF NOT IN ('6110') THEN (SD2.D2_DESCZFC - SD2.D2_DESCZFP) ELSE 0 END) -                                                                           
		SD2.D2_VALICM - SD2.D2_VALIMP6 - SD2.D2_VALIMP5 - SD2.D2_CUSTO1 -                                                                                                  
		(  CASE WHEN SD2.D2_CF NOT IN ('5949', '6102') THEN SD2.D2_ICMSRET ELSE 0 END )) / (SD2.D2_VALBRUT - SD2.D2_VALIPI -                                                  
		(  CASE WHEN  SD2.D2_CF NOT IN ('5949', '6102') AND SD2.D2_ICMSRET < (SD2.D2_VALBRUT - SD2.D2_VALIPI) THEN SD2.D2_ICMSRET                                            
		WHEN (SD2.D2_VALBRUT - SD2.D2_VALIPI )= SD2.D2_ICMSRET THEN 1 ELSE 0 END )) * 100 ) [P_LUCRO],    

		SB1.B1_POSIPI [NCM],                                                                                                                                                    
		SA1.A1_TIPO [TIPOCLI],                                                                                                                                                  
		SA1.A1_INSCR [IE],                                                                                                                                                      
		SA1.A1_SUFRAMA [SUFRAMA],                                                                                                                                               
		SA1.A1_GRPTRIB [GRPTRIB],                                                                                                                                               
		SA1.A1_TPESSOA [TPESSOA],                                                                                                                                               
		SA1.A1_CNAE [CNAE],                                                                                                                                                     
		SA1.A1_SIMPNAC [SIMPLES],                                                                                                                                               
		SA1.A1_REGESIM [MT],                                                                                                                                                    
		Z7Z.Z7Z_DOC [NUMCTE],                                                                                                                                                   
		Z7Z.Z7Z_SERIE [SERCTE],                                                                                                                                                 

		( SD2.D2_VALBRUT /                                                                                                                                                    
		( SELECT SUM(SF2.F2_VALBRUT)                                                                                                                                          
		FROM                                                                                                                                                         
		%Table:Z7Z%	Z7Z                                                                                                                             
		INNER JOIN                                                                                                                                                          
		%Table:SF2%	SF2                                                                                                                        
		ON SF2.F2_DOC = Z7Z.Z7Z_NOTA                                                                                                                                 
		AND SF2.F2_SERIE = Z7Z.Z7Z_SERINF                                                                                                                            
		AND SF2.%NotDel%	                                                                                                                                
		AND SF2.F2_DUPL <> ''                                                                                                                                        
		WHERE Z7Z_DOC =                                                                                                                                                    
		( SELECT TOP 1 Z7Z_DOC                                                                                                                                          
		FROM                                                                                                                                                         
		%Table:Z7Z%	Z7Z                                                                                                                         
		WHERE                                                                                                                                                        
		Z7Z_NOTA = SD2.D2_DOC                                                                                                                                     
		AND Z7Z.%NotDel%	)                                                                                                                               
		AND Z7Z.%NotDel%	))  *                                                                                                                                   
		( SELECT SUM(Z6Z.Z6Z_VALTOT)                                                                                                                                       
		FROM                                                                                                                                                         
		%Table:Z6Z%	Z6Z                                                                                                                                 
		INNER JOIN                                                                                                                                                     
		%Table:Z7Z%	Z7Z                                                                                                                                
		ON Z7Z.Z7Z_FILIAL = Z6Z.Z6Z_FILIAL                                                                                                                             
		AND Z7Z.Z7Z_SERIE = Z6Z.Z6Z_SERIE                                                                                                                              
		AND Z7Z.Z7Z_DOC   = Z6Z.Z6Z_DOC                                                                                                                                
		AND Z7Z.Z7Z_FILIAL = SD2.D2_FILIAL                                                                                                                             
		AND Z7Z.Z7Z_SERINF = SD2.D2_SERIE                                                                                                                              
		AND Z7Z.Z7Z_NOTA   = SD2.D2_DOC                                                                                                                                
		AND Z7Z.%NotDel%	                                                                                                                                     
		WHERE Z6Z.%NotDel%	                                                                                                                                  
		AND Z6Z.Z6Z_FILIAL = SD2.D2_FILIAL ) [VALFRETE]                                                                                                                

		FROM                                                                                                                                                                  
		%Table:SD2%	SD2                                                                                                                              
		INNER JOIN                                                                                                                                                         
		%Table:SF2%	SF2                                                                                                                               
		ON SF2.F2_FILIAL = SD2.D2_FILIAL                                                                                                                                
		AND SF2.F2_DOC = SD2.D2_DOC                                                                                                                                    
		AND SF2.F2_SERIE = SD2.D2_SERIE                                                                                                                                 
		AND SF2.F2_CLIENTE = SD2.D2_CLIENTE                                                                                                                             
		AND SF2.F2_LOJA = SD2.D2_LOJA                                                                                                                                   
		%Exp:cWhere%                                                                                                                                       
		SF2.F2_TIPO IN                                                                                                                                              
		('N','D')                                                                                                                                                       
		AND SF2.%NotDel%	                                                                                                                                       
		LEFT JOIN                                                                                                                                                          
		%Table:Z7Z%	Z7Z                                                                                                                                
		ON Z7Z.Z7Z_FILIAL = SD2.D2_FILIAL                                                                                                                               
		AND Z7Z.Z7Z_SERINF = SD2.D2_SERIE                                                                                                                               
		AND Z7Z.Z7Z_NOTA = SD2.D2_DOC                                                                                                                                   
		AND Z7Z.%NotDel%	                                                                                                                                      
		LEFT JOIN                                                                                                                                                          
		%Table:SUA%	SUA                                                                                                                                
		ON SUA.UA_FILIAL = SD2.D2_FILIAL                                                                                                                                
		AND SUA.UA_SERIE = SD2.D2_SERIE                                                                                                                                 
		AND SUA.UA_DOC = SD2.D2_DOC                                                                                                                                     
		AND SUA.%NotDel%	                                                                                                                                      
		LEFT JOIN                                                                                                                                                          
		%Table:SU7%	SU7                                                                                                                              
		ON SU7.U7_COD = SUA.UA_OPERADO                                                                                                                                  
		AND SU7.%NotDel%	                                                                                                                                      
		INNER JOIN                                                                                                                                                         
		%Table:SA1%	SA1                                                                                                                               
		ON SA1.A1_COD = SD2.D2_CLIENTE                                                                                                                                  
		AND SA1.A1_LOJA = SD2.D2_LOJA                                                                                                                                   
		AND SA1.A1_VEND BETWEEN '      ' AND 'ZZZZZZ'                                                                                                                   
		AND SA1.%NotDel%	                                                                                                                                      
		INNER JOIN                                                                                                                                                         
		%Table:SB1%	SB1                                                                                                                              
		ON SB1.B1_COD = SD2.D2_COD                                                                                                                                      
		AND SB1.B1_GRUPO BETWEEN '    ' AND 'ZZZZ'                                                                                                                      
		AND SB1.%NotDel%	                                                                                                                                      
		INNER JOIN                                                                                                                                                         
		%Table:SBM%	SBM                                                                                                                                
		ON SB1.B1_GRUPO = SBM.BM_GRUPO                                                                                                                                  
		AND SBM.%NotDel%	                                                                                                                                      
		LEFT JOIN                                                                                                                                                          
		%Table:SA3%	 A3VEN                                                                                                                             
		ON A3VEN.A3_COD = SA1.A1_VEND                                                                                                                                   
		AND A3VEN.%NotDel%	                                                                                                                                    
		LEFT JOIN                                                                                                                                                          
		%Table:SA3%	 VEND1UA                                                                                                                           
		ON VEND1UA.A3_COD = SUA.UA_VEND                                                                                                                                 
		AND VEND1UA.%NotDel%	                                                                                                                                  
		LEFT JOIN                                                                                                                                                          
		%Table:SA3%	VEND2UA (NOLOCK)                                                                                                                            
		ON VEND2UA.A3_COD = SUA.UA_VEND2                                                                                                                                
		AND VEND2UA.%NotDel%	                                                                                                                                  
		LEFT JOIN                                                                                                                                                          
		%Table:SX5%	 REGIAO (NOLOCK)                                                                                                                             
		ON REGIAO.X5_TABELA = 'A2'                                                                                                                                      
		AND REGIAO.X5_CHAVE = A1_REGIAO                                                                                                                                 
		AND REGIAO.%NotDel%	                                                                                                                                 
		WHERE                                                                                                                                                                 
		SD2.%NotDel%	                                                                                                                                           
		AND SD2.D2_FILIAL  BETWEEN '  '       AND 'ZZZZZZ'                                                                                                                 
		AND SD2.D2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)%   AND %Exp:DTOS(MV_PAR02)%                                                                                   
		AND SD2.D2_DOC     BETWEEN '  '       AND 'ZZZZZZZZZZZZZZZ'                                                                                                              
		AND SD2.D2_CLIENTE BETWEEN %Exp:(MV_PAR09)%   AND %Exp:(MV_PAR10)%                                                                                                   
		AND SD2.D2_LOJA    BETWEEN %Exp:(MV_PAR11)%   AND %Exp:(MV_PAR12)%                                                                                                           
		AND SD2.D2_EST     BETWEEN '  '       AND 'ZZ'  

		ORDER BY D2_EMISSAO, D2_DOC, D2_ITEM DESC   

	EndSql

	If (cAliasQry)->(!Eof())

		//-------------------------------------------------------
		//Contando total de registros da consulta
		//-------------------------------------------------------
		Count To nTotal
		(cAliasQry) ->(DbGoTop())
		//-------------------------------------------------------

		oReport:SetMsgPrint("Processando..")
		oReport:SetMeter(nTotal)

		oSection1:Init()
		
		_cCteRepet := ( alltrim((cAliasQry)->NF) + alltrim((cAliasQry)->NUMCTE) )

		While (cAliasQry)->(!Eof())
		
		If _cCteRepet ==   (alltrim((cAliasQry)->NF)) + (alltrim((cAliasQry)->NUMCTE)) 

			oSection1:Cell('COD_FIL'  ) :SetValue((cAliasQry)->COD_FIL)
			oSection1:Cell('DESC_FIL' ) :SetValue((cAliasQry)->DESC_FIL)
			oSection1:Cell('EMISSAO'  ) :SetValue((cAliasQry)->EMISSAO)  
			oSection1:Cell('NF'  ):SetValue((cAliasQry)->NF)  
			oSection1:Cell('TIPONF'    ):SetValue((cAliasQry)->TIPONF)  
			oSection1:Cell('GRPROD'    ):SetValue((cAliasQry)->GRPROD)  
			oSection1:Cell('GRUPOPROD'):SetValue((cAliasQry)->GRUPOPROD)  
			oSection1:Cell('COD_PRODUTO'):SetValue((cAliasQry)->COD_PRODUTO)  
			oSection1:Cell('PRODUTO'     ):SetValue((cAliasQry)->PRODUTO)  
			oSection1:Cell('CFOP'     ):SetValue((cAliasQry)->CFOP)  
			oSection1:Cell('TIPO'  ):SetValue((cAliasQry)->TIPO)  
			oSection1:Cell('QUANTI'     ):SetValue((cAliasQry)->QUANTI)  
			oSection1:Cell('REG'     ):SetValue((cAliasQry)->REGIAO)  
			oSection1:Cell('COD_MUN'     ):SetValue((cAliasQry)->COD_MUN)  
			oSection1:Cell('MUNIC'   ):SetValue((cAliasQry)->MUNIC)  
			oSection1:Cell('ESTADO'  ):SetValue((cAliasQry)->ESTADO)  
			oSection1:Cell('COD_CLIENTE'  ):SetValue((cAliasQry)->COD_CLIENTE)  
			oSection1:Cell('LOJA'  ):SetValue((cAliasQry)->LOJA)  
			oSection1:Cell('HISTORICO'   ):SetValue((cAliasQry)->HISTORICO)  
			oSection1:Cell('COD_VEND'    ):SetValue((cAliasQry)->COD_VEND)  
			oSection1:Cell('VENDEDOR'   ):SetValue((cAliasQry)->VENDEDOR)  
			oSection1:Cell('COD_OPERADOR'):SetValue((cAliasQry)->COD_OPERADOR)  
			oSection1:Cell('OPERADOR'  ):SetValue((cAliasQry)->OPERADOR)  
			oSection1:Cell('NUAVEND1'  ):SetValue(Stod((cAliasQry)->NUAVEND1)) 
			oSection1:Cell('NUAVEND2'  ):SetValue(Stod((cAliasQry)->NUAVEND2))  
			oSection1:Cell('TMK' ):SetValue((cAliasQry)->TMK) 
			oSection1:Cell('NCM'  ):SetValue((cAliasQry)->NCM)
			oSection1:Cell('TIPOCLI' ):SetValue((cAliasQry)->TIPOCLI)			
			oSection1:Cell('IE'   ):SetValue((cAliasQry)->IE)			
			oSection1:Cell('SUFRAMA' ):SetValue((cAliasQry)->SUFRAMA)			
			oSection1:Cell('GRPTRIB' ):SetValue((cAliasQry)->GRPTRIB)
			oSection1:Cell('TPESSOA' ):SetValue((cAliasQry)->TPESSOA)
			oSection1:Cell('CNAE' ):SetValue((cAliasQry)->CNAE)
			oSection1:Cell('SIMPLES' ):SetValue((cAliasQry)->SIMPLES)
			oSection1:Cell('MT' ):SetValue((cAliasQry)->MT)
			oSection1:Cell('VENDA' ):SetValue((cAliasQry)->VENDA)
			oSection1:Cell('PIPI' ):SetValue((cAliasQry)->PIPI)
			oSection1:Cell('IPI' ):SetValue((cAliasQry)->IPI)
			oSection1:Cell('ST' ):SetValue((cAliasQry)->ST)
			oSection1:Cell('RECEITA_BRUTA' ):SetValue((cAliasQry)->RECEITA_BRUTA)
			oSection1:Cell('PICMS' ):SetValue((cAliasQry)->PICMS)
			oSection1:Cell('ICMS' ):SetValue((cAliasQry)->ICMS)
			oSection1:Cell('PIS' ):SetValue((cAliasQry)->PIS)
			oSection1:Cell('COFINS' ):SetValue((cAliasQry)->COFINS)
			oSection1:Cell('DESCONTO' ):SetValue((cAliasQry)->DESCONTO)
			oSection1:Cell('RECEITA_LIQUIDA' ):SetValue((cAliasQry)->RECEITA_LIQUIDA)
			oSection1:Cell('CUSTO' ):SetValue((cAliasQry)->CUSTO)
			oSection1:Cell('MARGEM_BRUTA' ):SetValue((cAliasQry)->MARGEM_BRUTA)
			oSection1:Cell('P_CUSTO' ):SetValue((cAliasQry)->P_CUSTO)
			oSection1:Cell('P_LUCRO' ):SetValue((cAliasQry)->P_LUCRO)
			oSection1:Cell('NUMCTE' ):SetValue((cAliasQry)->NUMCTE)
			oSection1:Cell('SERCTE' ):SetValue((cAliasQry)->SERCTE)
			oSection1:Cell('VALFRETE' ):SetValue((cAliasQry)->VALFRETE)
			
			_cCteRepet := ( alltrim((cAliasQry)->NF) + alltrim((cAliasQry)->NUMCTE) )
			
		Else 
		
		oSection1:Cell('COD_FIL'  ) :SetValue((cAliasQry)->COD_FIL)
			oSection1:Cell('DESC_FIL' ) :SetValue((cAliasQry)->DESC_FIL)
			oSection1:Cell('EMISSAO'  ) :SetValue((cAliasQry)->EMISSAO)  
			oSection1:Cell('NF'  ):SetValue((cAliasQry)->NF)  
			oSection1:Cell('TIPONF'    ):SetValue((cAliasQry)->TIPONF)  
			oSection1:Cell('GRPROD'    ):SetValue((cAliasQry)->GRPROD)  
			oSection1:Cell('GRUPOPROD'):SetValue((cAliasQry)->GRUPOPROD)  
			oSection1:Cell('COD_PRODUTO'):SetValue((cAliasQry)->COD_PRODUTO)  
			oSection1:Cell('PRODUTO'     ):SetValue((cAliasQry)->PRODUTO)  
			oSection1:Cell('CFOP'     ):SetValue((cAliasQry)->CFOP)  
			oSection1:Cell('TIPO'  ):SetValue((cAliasQry)->TIPO)  
			oSection1:Cell('QUANTI'     ):SetValue(_nVlrRepet)  
			oSection1:Cell('REG'     ):SetValue((cAliasQry)->REGIAO)  
			oSection1:Cell('COD_MUN'     ):SetValue((cAliasQry)->COD_MUN)  
			oSection1:Cell('MUNIC'   ):SetValue((cAliasQry)->MUNIC)  
			oSection1:Cell('ESTADO'  ):SetValue((cAliasQry)->ESTADO)  
			oSection1:Cell('COD_CLIENTE'  ):SetValue((cAliasQry)->COD_CLIENTE)  
			oSection1:Cell('LOJA'  ):SetValue((cAliasQry)->LOJA)  
			oSection1:Cell('HISTORICO'   ):SetValue((cAliasQry)->HISTORICO)  
			oSection1:Cell('COD_VEND'    ):SetValue((cAliasQry)->COD_VEND)  
			oSection1:Cell('VENDEDOR'   ):SetValue((cAliasQry)->VENDEDOR)  
			oSection1:Cell('COD_OPERADOR'):SetValue((cAliasQry)->COD_OPERADOR)  
			oSection1:Cell('OPERADOR'  ):SetValue((cAliasQry)->OPERADOR)  
			oSection1:Cell('NUAVEND1'  ):SetValue(Stod((cAliasQry)->NUAVEND1)) 
			oSection1:Cell('NUAVEND2'  ):SetValue(Stod((cAliasQry)->NUAVEND2))  
			oSection1:Cell('TMK' ):SetValue((cAliasQry)->TMK) 
			oSection1:Cell('NCM'  ):SetValue((cAliasQry)->NCM)
			oSection1:Cell('TIPOCLI' ):SetValue((cAliasQry)->TIPOCLI)			
			oSection1:Cell('IE'   ):SetValue((cAliasQry)->IE)			
			oSection1:Cell('SUFRAMA' ):SetValue((cAliasQry)->SUFRAMA)			
			oSection1:Cell('GRPTRIB' ):SetValue((cAliasQry)->GRPTRIB)
			oSection1:Cell('TPESSOA' ):SetValue((cAliasQry)->TPESSOA)
			oSection1:Cell('CNAE' ):SetValue((cAliasQry)->CNAE)
			oSection1:Cell('SIMPLES' ):SetValue((cAliasQry)->SIMPLES)
			oSection1:Cell('MT' ):SetValue((cAliasQry)->MT)
			oSection1:Cell('VENDA' ):SetValue(_nVlrRepet)
			oSection1:Cell('PIPI' ):SetValue(_nVlrRepet)
			oSection1:Cell('IPI' ):SetValue(_nVlrRepet)
			oSection1:Cell('ST' ):SetValue(_nVlrRepet)
			oSection1:Cell('RECEITA_BRUTA' ):SetValue(_nVlrRepet)
			oSection1:Cell('PICMS' ):SetValue(_nVlrRepet)
			oSection1:Cell('ICMS' ):SetValue(_nVlrRepet)
			oSection1:Cell('PIS' ):SetValue(_nVlrRepet)
			oSection1:Cell('COFINS' ):SetValue(_nVlrRepet)
			oSection1:Cell('DESCONTO' ):SetValue(_nVlrRepet)
			oSection1:Cell('RECEITA_LIQUIDA' ):SetValue(_nVlrRepet)
			oSection1:Cell('CUSTO' ):SetValue(_nVlrRepet)
			oSection1:Cell('MARGEM_BRUTA' ):SetValue(_nVlrRepet)
			oSection1:Cell('P_CUSTO' ):SetValue(_nVlrRepet)
			oSection1:Cell('P_LUCRO' ):SetValue(_nVlrRepet)
			oSection1:Cell('NUMCTE' ):SetValue((cAliasQry)->NUMCTE)
			oSection1:Cell('SERCTE' ):SetValue((cAliasQry)->SERCTE)
			oSection1:Cell('VALFRETE' ):SetValue(_nVlrRepet)
		
		EndIf 

			oSection1:PrintLine()			

			oReport:IncMeter()  

			(cAliasQry)->(DbSkip())
		End

		oSection1:Finish()

	EndIf

	oReport:EndPage()		               		
	(cAliasQry)->(DbCloseArea())

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Atualização do SX1 - Perguntas

@author TOTVS Protheus
@since  29/01/2016
@obs    Gerado por EXPORDIC - V.4.19.9.2 EFS / Upd. V.4.17.9 EFS

/*/
//-------------------------------------------------------------------------------
Static Function CriaPerg()                                                                       	

	Local aArea    := GetArea()
	Local aAreaDic := SX1->( GetArea() )
	Local aEstrut  := {}
	Local aStruDic := SX1->( dbStruct() )
	Local aDados   := {}
	Local nI       := 0
	Local nJ       := 0
	Local nTam1    := Len( SX1->X1_GRUPO )
	Local nTam2    := Len( SX1->X1_ORDEM )

	aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
	"X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
	"X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
	"X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
	"X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
	"X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
	"X1_IDFIL"   }

	aAdd( aDados, {'RFAT012','01','Da data?'        ,'','','MV_CH1','D',8,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','   ','','','','',''} )
	aAdd( aDados, {'RFAT012','02','Até a Data?'     ,'','','MV_CH2','D',8,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','   ','','','','',''} )
	aAdd( aDados, {'RFAT012','03','Grupo de Vendas?','','','MV_CH3','C',6,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','ACY','','','','',''} )
	aAdd( aDados, {'RFAT012','04','Grupo de Vendas?','','','MV_CH4','C',6,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','ACY','','','','',''} )
	aAdd( aDados, {'RFAT012','05','Vendedor De ?'	,'','','MV_CH5','C',6,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','SA3','','','','',''} )
	aAdd( aDados, {'RFAT012','06','Vendedor ate ?'	,'','','MV_CH6','C',6,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','SA3','','','','',''} )
	aAdd( aDados, {'RFAT012','07','Gerente de ?'	,'','','MV_CH7','C',6,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SA3','','','','',''} )
	aAdd( aDados, {'RFAT012','08','Gerente ate ?'	,'','','MV_CH8','C',6,0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','SA3','','','','',''} )
	aAdd( aDados, {'RFAT012','09','Cliente de ?'	,'','','MV_CH9','C',6,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','SA1','','','','',''} )
	aAdd( aDados, {'RFAT012','10','Cliente ate ?'	,'','','MV_CH0','C',6,0,0,'G','','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','','SA1','','','','',''} )
	aAdd( aDados, {'RFAT012','11','Loja de ?'	    ,'','','MV_CHA','C',4,0,0,'G','','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','SA1','','','','',''} )
	aAdd( aDados, {'RFAT012','12','Loja ate ?'	    ,'','','MV_CHB','C',4,0,0,'G','','MV_PAR12','','','','','','','','','','','','','','','','','','','','','','','','','SA1','','','','',''} )
	aAdd( aDados, {'RFAT012','13','Movimenta Financeiro? '	,'','','MV_CHC','N',1,0,0,'C','','MV_PAR13','1-Sim','1-Sí','1-Yes','1','','2-Nao','2-No','2-No','2','','','','','','','','','','','','','','','','','','','','',''} )
	//
	// Atualizando dicionário
	//
	dbSelectArea( "SX1" )
	SX1->( dbSetOrder( 1 ) )

	For nI := 1 To Len( aDados )
		If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
			RecLock( "SX1", .T. )
			For nJ := 1 To Len( aDados[nI] )
				If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
					SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
				EndIf
			Next nJ
			MsUnLock()
		EndIf
	Next nI

	RestArea( aAreaDic )
	RestArea( aArea )

Return                                           
