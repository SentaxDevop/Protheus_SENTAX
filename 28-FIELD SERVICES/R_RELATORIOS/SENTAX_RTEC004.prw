#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"    
#INCLUDE "TOPCONN.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC004
Relatório de equipamentos instalados
                
@sample		U_RTEC004()

@author		Alessandro Smaha
@since		25/04/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function RTEC004()        

	Local oReport      
	
	Private cPerg := "RTEC004"   
	Private lWeb  := .F. //Valida se o relatorio é para WEB
			
	AjustaSX1()
	If ! Pergunte(cPerg,.T.) 	
		Return     	
	EndIf

	oReport := fRelFonDef()
		
	If !lWeb
		oReport:PrintDialog()
	Endif
         
Return             


//-------------------------------------------------------------------
/*/{Protheus.doc} fRelFonDef
Definição do relatorio
                
@sample		fRelFonDef()

@author		Alessandro Smaha
@since		25/04/2015   
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fRelFonDef()   

	Local cTitle    := OemToAnsi("Equipamentos instalados")
	Local cHelp     := OemToAnsi("Impressão do Relatório de equipamentos instalados")
	
	Local oReport   
	Local oSection1  
	Local oBreak
		                                        
	oReport := tReport():New(cPerg,cTitle,cPerg,{|oReport| fReportPrint(oReport)},cHelp)
	
	oReport:SetLandscape()
	//oReport:HideParamPage()
		
	oSection1 := trSection():New(oReport,cTitle,{"SB1"})   
	 
	trCell():New(oSection1,"A1_COD","TQRY","Cliente",PesqPict("SA1","A1_COD"),TamSX3("A1_COD")[1])
	trCell():New(oSection1,"A1_LOJA","TQRY","Loja",PesqPict("SA1","A1_LOJA"),TamSX3("A1_LOJA")[1])	
	trCell():New(oSection1,"A1_NOME","TQRY","Nome",PesqPict("SA1","A1_NOME"),30)	
	trCell():New(oSection1,"A1_EST","TQRY","Estado",PesqPict("SA1","A1_EST"),TamSX3("A1_EST")[1]) 	
	trCell():New(oSection1,"A1_MUN","TQRY","Município",PesqPict("SA1","A1_MUN"),TamSX3("A1_MUN")[1])
	trCell():New(oSection1,"B1_COD","TQRY","Máq./Equipamento",PesqPict("SB1","B1_COD"),TamSX3("B1_COD")[1])  
	trCell():New(oSection1,"B1_DESC","TQRY","Descrição",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1])  
	trCell():New(oSection1,"AA3_NUMSER","TQRY","Numero de Série",PesqPict("AA3","AA3_NUMSER"),TamSX3("AA3_NUMSER")[1]) 
	trCell():New(oSection1,"AA3_DTVEND","TQRY","Data Venda",PesqPict("AA3","AA3_DTVEND"),TamSX3("AA3_DTVEND")[1],,{|| StoD(TQRY->AA3_DTVEND) }) 
	
	lTSecao := .F.
	lTGeral := .T.
		           
	oBreak := TRBreak():New(oSection1,oSection1:Cell("A1_COD"),"Total: ",.F.)
	TRFunction():New(oSection1:Cell("A1_COD"),NIL,"COUNT",,,,,lTSecao,lTGeral)	

	oReport:SetTotalInLine(.F.) 
	
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} fReportPrint
Impressao do relatorio
                
@sample		fReportPrint(oReport)

@author		Alessandro Smaha
@since		16/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fReportPrint(oReport)
                                          
	Local cQuery := ""                             
	Local oSection1 := oReport:Section(1)  
	 
	If Select("TQRY") > 0
		TQRY->(DbCloseArea())
	Endif
	
	cQuery := " SELECT * 
	cQuery += " FROM " + RetSqlName("AA3")+" AA3
	cQuery += " INNER JOIN " + RetSqlName("SA1")+" SA1 ON A1_COD = AA3_CODCLI AND A1_LOJA = AA3_LOJA AND SA1.D_E_L_E_T_ <> '*' 
	cQuery += " INNER JOIN " + RetSqlName("SB1")+" SB1 ON B1_COD = AA3_CODPRO AND SB1.D_E_L_E_T_ <> '*' 
	cQuery += " WHERE AA3_CODPRO BETWEEN '" +mv_Par01+"' AND '" +mv_Par02+"' 
	cQuery += " 	AND AA3_CODCLI	BETWEEN '" +mv_Par03+"' AND '" +mv_Par05+"' 
	cQuery += " 	AND AA3_LOJA	BETWEEN '" +mv_Par04+"' AND '" +mv_Par06+"' 
	If !Empty(mv_Par07)
 		cQuery += " 	AND A1_EST = '" +mv_Par07+"' 
 	EndIf
 	If !Empty(mv_Par08)
 		cQuery += " 	AND A1_COD_MUN = '" +mv_Par08+"'
 	EndIf
	cQuery += " 	AND AA3.D_E_L_E_T_ <> '*'
	cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA, B1_COD

	TCQUERY cQuery NEW ALIAS "TQRY" 
		
	DbSelectArea("TQRY")
	
	oReport:SetMeter(0) 
	
	TQRY->(DbGoTop()) 
	
	oSection1:Init()
	
	While !oReport:Cancel() .And. !TQRY->(Eof())  
	
		oReport:IncMeter()  
		
		oSection1:PrintLine()		
		
		TQRY->(DbSkip())
	EndDo 
	
	oSection1:Finish()
	
Return      


//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas para impressão do relatório
                
@sample		AjustaSX1()

@author		Alessandro Smaha
@since		16/07/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function AjustaSX1()

	Local aHelpPor01 := {"A partir do código do Produto."}
	Local aHelpPor02 := {"Até o código do Produto."}
	Local aHelpPor03 := {"A partir do código do Cliente."}
	Local aHelpPor04 := {"A partir da loja do cliente."}
	Local aHelpPor05 := {"Até o código do cliente."}
	Local aHelpPor06 := {"Até a loja do cliente."}
	Local aHelpPor07 := {"Se preenchido, apenas este estado."}
	Local aHelpPor08 := {"Se preenchido, apenas este municipio."}	

	PutSx1(cPerg,"01","Produto de ?","","" 	  	   				,"MV_CH1","C",TamSx3("B1_COD")[1]	,0,0,"G",,"SB1"  ,,,"MV_PAR01",,,,"",,,,,,,,,,,,,aHelpPor01)
	PutSx1(cPerg,"02","Produto ate ?","",""	  	   				,"MV_CH2","C",TamSx3("B1_COD")[1]	,0,0,"G",,"SB1"  ,,,"MV_PAR02",,,,"",,,,,,,,,,,,,aHelpPor02)
	
	PutSx1(cPerg,"03","Cliente de ?","",""   	  	   			,"MV_CH3","C",TamSx3("A1_COD")[1]	,0,0,"G",,"SA1"  ,,,"MV_PAR03",,,,"",,,,,,,,,,,,,aHelpPor03)
	PutSx1(cPerg,"04","Loja de ?","",""  	 	   				,"MV_CH4","C",TamSx3("A1_LOJA")[1]	,0,0,"G",,"   "  ,,,"MV_PAR04",,,,"",,,,,,,,,,,,,aHelpPor04)
	                                          	   	
	PutSx1(cPerg,"05","Cliente ate ?","",""	   	  	  			,"MV_CH5","C",TamSx3("A1_COD")[1]	,0,0,"G",,"SA1"   ,,,"MV_PAR05",,,,"",,,,,,,,,,,,,aHelpPor05)
	PutSx1(cPerg,"06","Loja ate ?","",""		  				,"MV_CH6","C",TamSx3("A1_LOJA")[1]	,0,0,"G",,"   "   ,,,"MV_PAR06",,,,"",,,,,,,,,,,,,aHelpPor06)
	
	PutSx1(cPerg,"07","Estado ?","",""  						,"MV_CH7","C",TamSx3("A1_EST")[1],0,0,"G",,"12"   	  ,,,"MV_PAR07",,,,"",,,,,,,,,,,,,aHelpPor07)
	PutSx1(cPerg,"08","Município ?","","" 		   				,"MV_CH8","C",TamSx3("A1_COD_MUN")[1],0,0,"G",,"CC2"  ,,,"MV_PAR08",,,,"",,,,,,,,,,,,,aHelpPor08)
	                              
Return