#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS005
Notas fiscais não romaneadas
	
@author		Leandro Natan Bonette Santos
@since		14/07/2014
@version 	1.0		

@return nil, sem retorno

/*/
//-------------------------------------------------------------------------------
User Function ROMS005()

	Local oReport := nil
	
	Private cPerg   :="ROMS005" 
	
	oReport := ReportDef()
	oReport:PrintDialog()

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do relatório
	
@author		Leandro Natan Bonette Santos
@since		14/07/2014
@version	1.0		

@return oReport, Objeto TReport configurado


/*/
//-------------------------------------------------------------------------------
Static Function ReportDef()

	Local oReport    := nil
	Local oSection1  := nil

	Local cTitle    := "Notas fiscais não romaneadas"
	
	Local cDescric := "Este relatorio tem o objetivo de imprimir as notas fiscais não romaneadas, pendentes de expedição"

	oReport:= TReport():New("ROMS005",cTitle,cPerg, {|oReport| ReportPrint(oReport)},cDescric)  
	oReport:SetLandscape()
	oReport:DisableOrientation()

	//------------------------------------------------
	// Ajusta o grupo de perguntas
	//------------------------------------------------
	AjustaSX1()
	//------------------------------------------------

	//------------------------------------------------
	// Variaveis utilizadas para parametros
	//------------------------------------------------
	// MV_PAR01 - Da Emissão
	// MV_PAR02 - Até Emissao
	// MV_PAR03 - Da Filial
	// MV_PAR04 - Até Filial
	// MV_PAR05 - Do Cliente
	// MV_PAR06 - Da Loja
	// MV_PAR07 - Até Cliente
	// MV_PAR08 - Até Loja
	// MV_PAR09 - Impressa
	//------------------------------------------------	
	Pergunte(oReport:GetParam(),.F.)
	//------------------------------------------------
	

	//---------------------------------------------------------------------------------------------------------
	// oSection1 - Dados das notas fiscais pendentes de expedição
	//---------------------------------------------------------------------------------------------------------
	oSection1 := TRSection():New(oReport,"Notas fiscais pendentes de expedição",{"CBK","SA1","DA7","SF2"},/*Ordem*/)
	
	TRCell():New(oSection1,'F2_FILIAL'   ,'SF2',"Filial"             ,/*Picture*/,TamSX3('F2_FILIAL' )[1] + 2   ,.F.)
	TRCell():New(oSection1,'Z04_COD'     ,'Z04',"Cod Romaneio"       ,/*Picture*/,TamSX3('Z04_FILIAL' )[1] + 10  ,.F.)
	TRCell():New(oSection1,'F2_DOC'      ,'SF2',"NF"                 ,/*Picture*/,TamSX3('F2_DOC'    )[1] + 5   ,.F.)
	TRCell():New(oSection1,'F2_SERIE'    ,'SF2',"Série"              ,/*Picture*/,TamSX3('F2_SERIE'  )[1]       ,.F.)    
	TRCell():New(oSection1,'F2_CLIENTE'  ,'SF2',"Cliente"            ,/*Picture*/,TamSX3('F2_CLIENTE' )[1]       ,.F.)
	TRCell():New(oSection1,'A1_NREDUZ'   ,'SA1',"Nome Cliente"       ,/*Picture*/,TamSX3('A1_NREDUZ'  )[1] - 25  ,.F.)	
	TRCell():New(oSection1,'DA7_PERCUR'  ,'DA7',"Zona"               ,/*Picture*/,TamSX3('DA7_PERCUR' )[1]       ,.F.)
	TRCell():New(oSection1,'DA5_DESC'    ,'DA5',"Desc. Zona"         ,/*Picture*/,TamSX3('DA5_DESC'   )[1] - 15  ,.F.)	
	TRCell():New(oSection1,'F2_LOJA'     ,'SF2',"Loja"               ,/*Picture*/,TamSX3('F2_LOJA'    )[1]       ,.F.)
	TRCell():New(oSection1,'F2_EMISSAO'  ,'SF2',"Dt. Emissão"        ,/*Picture*/,TamSX3('F2_EMISSAO' )[1]       ,.F.)
	TRCell():New(oSection1,'F2_VALBRUT'  ,'SF2',"Vlr. Bruto"         ,/*Picture*/,TamSX3('F2_VALBRUT' )[1]       ,.F.)
	TRCell():New(oSection1,'F2_FIMP'     ,'SF2',"DANFE"              ,/*Picture*/,TamSX3('F2_FIMP'    )[1]       ,.F.)
	TRCell():New(oSection1,'F2_HAUTNFE'  ,'SF2',"Hora Aut. NF-e"     ,/*Picture*/,TamSX3('F2_HAUTNFE' )[1]       ,.F.)
	TRCell():New(oSection1,'F2_DAUTNFE'  ,'SF2',"Data Aut. NF-e"     ,/*Picture*/,TamSX3('F2_DAUTNFE' )[1]       ,.F.)
	TRCell():New(oSection1,'CBK_STATUS'  ,'CBK',"Status monitor"     ,/*Picture*/,100,.F.)
	//---------------------------------------------------------------------------------------------------------  

	                                  	                  	
	oSection1:Cell("CBK_STATUS"):SetCBox("1=Conf. não iniciada;"	+;	//Conferência Não Iniciada
										 "2=Sep. Iniciada;"			+;	//Separação Iniciada
										 "3=Sep. Finalizada;"		+;	//Separação Finalizada
										 "4=Exp. Iniciada;"			+;	//Expedição Iniciada
										 "5=Exp. Finalizada;"		+;	//Expedição Finalizada
										 "6=Rom. Finalizado;"		+;	//Romaneio Finalizado
										 "7=NF Cancelada")				//Nota Fiscal Cancelada
										 
	oSection1:Cell("F2_FIMP"):SetCBox("S=Autorizada;"	  +; //NF Autorizada
									  "T=Transmitida;"	  +; //NF Transmitida
									  "D=Denegado;"		  +; //NF Uso denegado
									  "N=Não autorizada")    //NF não autorizada 



Return oReport

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório
	
@author		Leandro Natan Bonette Santos
@since		14/07/2014
@version	1.0
		                                        
		
@param oReport, objeto, Objeto TReport
@param cQryRel, character, Alias da query que será executada

@return nil, Nulo

/*/
//-------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local cAliasQry := GetNextAlias()                                          

	Local cPAR11 := ""
	                                                           
	If MV_PAR09 == 1
		cPAR09 := "% SF2.F2_FIMP = 'S' %"                                    
	ElseIf MV_PAR09 == 2
		cPAR09 := "% SF2.F2_FIMP <> 'S' %"                                    
	ElseIf MV_PAR09 == 3                  
		cPAR09 := "% SF2.F2_FIMP <> 'Z' %"                               	
	EndIf
	
	
	
	oSection1:BeginQuery()	
	
	BeginSql Alias cAliasQry
                              
 		COLUMN F2_EMISSAO AS DATE

		SELECT * FROM( 
			SELECT	ISNULL(Z04.Z04_COD,'') Z04_COD,
					CBK.CBK_FILIAL, 
					CBK.CBK_DOC, 
					CBK.CBK_SERIE,
					SF2.F2_FILIAL,			 
					SF2.F2_DOC,
					SF2.F2_SERIE,
					SF2.F2_CLIENTE,
					SF2.F2_LOJA,
					SA1.A1_NREDUZ, 
					DA7.DA7_PERCUR,
					DA5.DA5_DESC, 
					SF2.F2_EMISSAO, 
					SF2.F2_VALBRUT, 
					SF2.F2_FIMP, 
					SF2.F2_HAUTNFE, 
					SF2.F2_DAUTNFE, 
					SF2.F2_CHVNFE, 
					SA1.A1_EST,
					SF2.D_E_L_E_T_ SF2DEL,
					CBK.D_E_L_E_T_ CBKDEL,
					SA1.D_E_L_E_T_ SA1DEL,
					DA5.D_E_L_E_T_ DA5DEL,
					DA7.D_E_L_E_T_ DA7DEL,			
					ISNULL(CBK.CBK_STATUS,'') CBK_STATUS,
					ISNULL(SD1.D1_NFORI,'') D1_NFORI
					
			FROM	%Table:CBK% CBK
			
			RIGHT
			JOIN	%Table:SF2% SF2 ON
			
					SF2.F2_FILIAL  = CBK.CBK_FILIAL	AND
					SF2.F2_DOC     = CBK.CBK_DOC	AND
					SF2.F2_SERIE   = CBK.CBK_SERIE	AND			
					CBK.%NotDel%

			LEFT 
			JOIN	%Table:SD1% SD1 ON
			
					SD1.D1_FILIAL  = SF2.F2_FILIAL	AND
					SD1.D1_NFORI   = SF2.F2_DOC		AND
					SD1.D1_SERIORI = SF2.F2_SERIE	AND
					SD1.D1_FORNECE = SF2.F2_CLIENTE	AND
					SD1.D1_LOJA    = SF2.F2_LOJA	AND
					SD1.D1_ITEM    = %Exp:'0001'%	AND
					SD1.%NotDel%
				
			INNER
			JOIN	%Table:SA1% SA1 ON
			
					SA1.A1_COD		= SF2.F2_CLIENTE	AND
					SA1.A1_LOJA		= SF2.F2_LOJA		AND			
					SA1.A1_FILIAL	= %xFilial:SA1%		AND
					SA1.%NotDel%
						
			LEFT 
			JOIN	%Table:DA7% DA7 ON
			
					DA7.DA7_CLIENT = SA1.A1_COD  AND
					DA7.DA7_LOJA   = SA1.A1_LOJA AND
					DA7.%NotDel%
			
			LEFT
			JOIN	%Table:DA5%	DA5 ON
			 
					DA5.DA5_FILIAL = DA7.DA7_FILIAL AND
					DA5.DA5_COD    = DA7.DA7_PERCUR AND
					DA5.%NotDel%
			 
			 LEFT
			 JOIN	%Table:Z04%	Z04 ON
			 
					Z04.Z04_FILIAL = SF2.F2_FILIAL	AND
					Z04.Z04_NFISCA = SF2.F2_DOC		AND
					Z04.Z04_SERIE  = SF2.F2_SERIE	AND
					Z04.Z04_CLIENT = SF2.F2_CLIENTE	AND
					Z04.Z04_LOJA   = SF2.F2_LOJA	AND		 
					Z04.%NotDel%
						
			WHERE	SF2.F2_FILIAL	BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND				 
					SF2.F2_EMISSAO	BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND 
					SF2.F2_CLIENTE	BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07% AND 
					SF2.F2_LOJA		BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR08% AND					
					SF2.F2_DOC		BETWEEN %Exp:MV_PAR10% AND %Exp:MV_PAR12% AND
					SF2.F2_SERIE	BETWEEN %Exp:MV_PAR11% AND %Exp:MV_PAR13% AND
	                
	
					SF2.%NotDel% AND
					
					%Exp:cPAR09%
							
		) ROMANEIO		
		
		WHERE	CBK_STATUS <> %Exp:'6'% 		AND
				D1_NFORI    = %Exp:'         '% AND
				Z04_COD     = %Exp:'      '%
		
		ORDER BY F2_FILIAL,F2_EMISSAO,F2_DOC,F2_SERIE,CBK_STATUS
			
	EndSql
		               
	//Aviso("",GetLastQuery()[2],{"ok"},3)

	oSection1:EndQuery()                         
	oSection1:Print()

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do programa
	
@author		Leandro Natan Bonette Santos
@since		14/07/2014
@version 	1.0		

@return nil, sem retorno

/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1()

	Local aHelpPerg  := {}
	
	aAdd(aHelpPerg,{"Informe a data de emissão inicial."})
	aAdd(aHelpPerg,{"Informe a data de emissão final."})

	aAdd(aHelpPerg,{"Informe a filial inicial."})
	aAdd(aHelpPerg,{"Informe a filial final."  })

	aAdd(aHelpPerg,{"Cliente de "})
	aAdd(aHelpPerg,{"Loja de"})

	aAdd(aHelpPerg,{"Cliente até"})
	aAdd(aHelpPerg,{"Loja até"  })

	aAdd(aHelpPerg,{"Informe se deseja imprimir as DANFEs",;
	                "já impressas ou não"})
	

	PutSX1(cPerg,"01","Da Emissão"    ,"" ,"" ,"MV_PAR01" ,"D",8,0,0,"G","","SF2001" ,"018" ,"","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})
	PutSX1(cPerg,"02","Até Emissao"   ,"" ,"" ,"MV_PAR02" ,"D",8,0,0,"G","","SF2001" ,"018" ,"","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPerg[2] ,{},{})

	PutSX1(cPerg,"03","Da Filial"     ,"" ,"" ,"MV_PAR03" ,"C",FWSizeFilial(),0,0,"G","","SM0",""    ,"","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPerg[3] ,{},{})
	PutSX1(cPerg,"04","Até Filial"    ,"" ,"" ,"MV_PAR04" ,"C",FWSizeFilial(),0,0,"G","","SM0",""    ,"","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPerg[4] ,{},{})

	PutSX1(cPerg,"05","Do Cliente"    ,"" ,"" ,"MV_PAR05" ,"C",TamSX3("A1_COD")[1] ,0,0,"G","","SA1","001" ,"","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPerg[5] ,{},{})
	PutSX1(cPerg,"06","Da Loja"       ,"" ,"" ,"MV_PAR06" ,"C",TamSX3("A1_LOJA")[1],0,0,"G","",""   ,""    ,"","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPerg[6] ,{},{})

	PutSX1(cPerg,"07","Até Cliente"   ,"" ,"" ,"MV_PAR07" ,"C",TamSX3("A1_COD")[1] ,0,0,"G","","SA1" ,"001" ,"","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPerg[7] ,{},{})
	PutSX1(cPerg,"08","Até Loja"      ,"" ,"" ,"MV_PAR08" ,"C",TamSX3("A1_LOJA")[1],0,0,"G","",""    ,""    ,"","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPerg[8] ,{},{})

	PutSX1(cPerg,"09","Impressa"      ,"" ,"" ,"MV_PAR09" ,"N",1,0,0,"C","","","","","MV_PAR09","Sim","","","1","Nao","","","Todos","","","","","","","","",aHelpPerg[9] ,{},{})
	
	
Return                                           
