#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#Include "TOPCONN.CH"  
//-------------------------------------------------------------------------------
/*/{Protheus.doc} RTEC003
Relatório de OS x técnico x ano

@author		Alessandro Smaha
@since		04/07/2014

/*/
//-------------------------------------------------------------------------------
User Function RTEC003()

	Local nOpca

	Private cPerg := "RTEC003"

	//Cria as Perguntas no SX1
	AjustaSX1()
	
	If Pergunte(cPerg,.T.)  
	
		oReport := ReportDef(MV_PAR01)
		oReport:PrintDialog()
	
	EndIf 
	

Return            


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definições do relatório

@author		Alessandro Smaha
@since		04/07/2014

/*/
//-------------------------------------------------------------------------------
Static Function ReportDef(cAno)

	Local cTitle    := OemToAnsi("Técnico x OS x Ano - "+cAno)
	Local cHelp     := OemToAnsi("Impressão do Relatório de Técnico x OS x Ano")
	
	Local oReport   := Nil
	Local oSection1 := Nil
		                                        
	oReport := tReport():New(cPerg,cTitle,cPerg,{|oReport| ReportPrint(oReport)},cHelp)
	
	//oReport:SetLandscape()
	oReport:HideParamPage()
		
	oSection1 := trSection():New(oReport,cTitle,{"AA1"})   
	 
	trCell():New(oSection1,"COD_TEC","TQRY","Técnico",/*Picture*/,TamSX3("AA1_CODTEC")[1],.T.)
	trCell():New(oSection1,"AA1_NOMTEC","TQRY","Nome","@!",TamSX3("AA1_NOMTEC")[1]+1,.T.)
	
	trCell():New(oSection1,"ALOCA","TQRY","Ativo?","@!",8,.T.)
	
	trCell():New(oSection1,"MES_JAN","TQRY","Janeiro","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_FEV","TQRY","Fevereiro","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_MAR","TQRY","Março","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_ABR","TQRY","Abril","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_MAI","TQRY","Maio","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_JUN","TQRY","Junho","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_JUL","TQRY","Julho","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_AGO","TQRY","Agosto","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_SET","TQRY","Setembro","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_OUT","TQRY","Outubro","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_NOV","TQRY","Novembro","@E 9,999,999",8,.T.)
	trCell():New(oSection1,"MES_DEZ","TQRY","Dezembro","@E 9,999,999",8,.T.) 
	trCell():New(oSection1,"MES_TOT","TQRY","Total","@E 9,999,999",8,.T.)
		                
	lTSection := .F.
	lTGeral := .T.
		
	TRFunction():New(oSection1:Cell("COD_TEC"),NIL,"COUNT",,,,,lTSection,lTGeral)	
	TRFunction():New(oSection1:Cell("MES_JAN"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_FEV"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_MAR"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_ABR"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_MAI"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_JUN"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_JUL"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_AGO"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_SET"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_OUT"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_NOV"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_DEZ"),NIL,"SUM",,,,,lTSection,lTGeral)
	TRFunction():New(oSection1:Cell("MES_TOT"),NIL,"SUM",,,,,lTSection,lTGeral)
	     
	//oSection1:SetLeftMargin(03) 
	     
	oReport:SetTotalInLine(.F.) 
	
Return(oReport)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Impressão do relatório

@author		Alessandro Smaha
@since		04/07/2014

/*/
//-------------------------------------------------------------------------------
Static Function ReportPrint(oReport)
                                        
	Local aTecnicos := {}
	Local aTecAux	:= {}
	Local oSection1 := oReport:Section(1) 
	
	If ( Select("TQRY") ) > 0
		DbSelectArea("TQRY")
		TQRY->(dbCloseArea())
	EndIf 
	
	nAno := Val(MV_PAR01)
    
    cQuery := " SELECT COD_TEC, AA1_NOMTEC, AA1_ALOCA, 	SUM(MES_JAN) MES_JAN, SUM(MES_FEV) MES_FEV, SUM(MES_MAR) MES_MAR, SUM(MES_ABR) MES_ABR, "
    cQuery += " 										SUM(MES_MAI) MES_MAI, SUM(MES_JUN) MES_JUN, SUM(MES_JUL) MES_JUL, SUM(MES_AGO) MES_AGO, "
	cQuery += "											SUM(MES_SET) MES_SET, SUM(MES_OUT) MES_OUT, SUM(MES_NOV) MES_NOV, SUM(MES_DEZ) MES_DEZ " 
	cQuery += "											
	cQuery += " FROM ( "
    
    // Lista todos os técnicos    
	cQuery += " 	SELECT AA1_CODTEC COD_TEC, 0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, " 
	cQuery += " 							   0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ " 
	cQuery += " 	FROM "+RetSqlName("AA1")+" AA1 " 
	cQuery += " 	WHERE D_E_L_E_T_ <> '*' " 
	cQuery += " 	UNION ALL " 
    
    // Lista todos os meses
	For nI := 1 to 12
		cQuery += fMontaMes(nI,nAno) 
	Next nI   
	
	cQuery += " ) AS TRABA "
	cQuery += " LEFT JOIN "+RetSqlName("AA1")+" ON AA1_CODTEC = COD_TEC "  	
	cQuery += " WHERE COD_TEC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'" 
	
	If MV_PAR05 == 1 // 1=Disponivel, 2=Indisponivel, 3=Todos
		cQuery += " AND AA1_ALOCA = '1' "
	ElseIf MV_PAR05 == 2
		cQuery += " AND AA1_ALOCA = '2' "
	EndIf
		
	cQuery += " GROUP BY COD_TEC, AA1_NOMTEC, AA1_ALOCA " 
	
	If MV_PAR04 == 1 // Código
		cQuery += " ORDER BY COD_TEC "
	Else // Nome
   		cQuery += " ORDER BY AA1_NOMTEC "
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TQRY"  
	
	If ( Select("TAUX") ) > 0
		DbSelectArea("TAUX")
		TAUX->(dbCloseArea())
	EndIf 
	
	cQuery := " SELECT AB6_NUMOS, AB6_EMISSA, AB6_XCDAUX "
	cQuery += " FROM "+RetSqlName("AB6")+" AB6 " 
	cQuery += " WHERE AB6_XCDAUX <> '' "
	cQuery += " 	AND YEAR(AB6_EMISSA) = "+cValToChar(nAno)
	cQuery += " 	AND AB6.D_E_L_E_T_ <> '*' " 
	  
	cQuery := ChangeQuery(cQuery)  
	TCQUERY cQuery NEW ALIAS "TAUX" 
		
	DbSelectArea("TQRY")		
	TQRY->(DbGoTop())  
	
	// Técnicos  
	If TQRY->(!EoF())
		While TQRY->(!EoF())		
			aAdd( aTecnicos, { 	TQRY->COD_TEC, TQRY->AA1_NOMTEC, TQRY->AA1_ALOCA,; 
								TQRY->MES_JAN, TQRY->MES_FEV, TQRY->MES_MAR,;
								TQRY->MES_ABR, TQRY->MES_MAI, TQRY->MES_JUN,;
								TQRY->MES_JUL, TQRY->MES_AGO, TQRY->MES_SET,;
								TQRY->MES_OUT, TQRY->MES_NOV, TQRY->MES_DEZ } ) 			
			
			TQRY->(DbSkip())
		EndDo   
	EndIf
	              
	// Técnicos Auxilizares 
	If TAUX->(!EoF())
		DbSelectArea("TAUX")		
		TAUX->(DbGoTop())  		
		While TAUX->(!EoF()) 
			
			aTecAux := Separa(TAUX->AB6_XCDAUX,";")
		    
		    For nI := 1 To Len(aTecAux) 
		    
		    	nMes := Month(StoD(TAUX->AB6_EMISSA)) + 3
			    
			    nPos := aScan(aTecnicos,{ |x| Alltrim(x[1]) == Alltrim(aTecAux[nI]) })
			    
			    If nPos > 0
			    
			    	aTecnicos[nPos][nMes] += 1	
			    
			    EndIf
			    
			Next nI
			      
			TAUX->(DbSkip())
		EndDo 
	EndIf
	
	oSection1:Init()	
	For nI := 1 to Len(aTecnicos) 
		oSection1:Cell("COD_TEC"):SetValue(aTecnicos[nI][1])
		oSection1:Cell("AA1_NOMTEC"):SetValue(aTecnicos[nI][2])  
		cAtivo := IIF(aTecnicos[nI][3] == "1","Sim","Não")		
		oSection1:Cell("ALOCA"):SetValue(cAtivo)
		oSection1:Cell("MES_JAN"):SetValue(aTecnicos[nI][4])
		oSection1:Cell("MES_FEV"):SetValue(aTecnicos[nI][5])
		oSection1:Cell("MES_MAR"):SetValue(aTecnicos[nI][6])
		oSection1:Cell("MES_ABR"):SetValue(aTecnicos[nI][7])
		oSection1:Cell("MES_MAI"):SetValue(aTecnicos[nI][8])
		oSection1:Cell("MES_JUN"):SetValue(aTecnicos[nI][9])
		oSection1:Cell("MES_JUL"):SetValue(aTecnicos[nI][10])
		oSection1:Cell("MES_AGO"):SetValue(aTecnicos[nI][11])
		oSection1:Cell("MES_SET"):SetValue(aTecnicos[nI][12])
		oSection1:Cell("MES_OUT"):SetValue(aTecnicos[nI][13])
		oSection1:Cell("MES_NOV"):SetValue(aTecnicos[nI][14])
		oSection1:Cell("MES_DEZ"):SetValue(aTecnicos[nI][15])       
		nTotal := 0
		For nJ := 1 to 12
			nTotal += aTecnicos[nI][nJ+3]
		Next nJ	
		oSection1:Cell("MES_TOT"):SetValue(nTotal) 
  		oSection1:PrintLine()
	Next nI	
	oSection1:Finish()	
	
Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fMontaMes
Monta query para o mes informado

@author		Alessandro Smaha
@since		04/07/2014

/*/
//-------------------------------------------------------------------------------  
Static Function fMontaMes(nMes,nAno) 

	Local cQuery := ""
	 	
	If nMes == 1
		
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	COUNT(*) MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 2
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, COUNT(*) MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 3
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, COUNT(*) MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 4 
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, COUNT(*) MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 5
	
   		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, COUNT(*) MES_MAI, 0 MES_JUN, "
   		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 6
	
   		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, COUNT(*) MES_JUN, "
   		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 7
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					COUNT(*) MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 8   
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, COUNT(*) MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 9             
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, COUNT(*) MES_SET, 0 MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 10    
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, COUNT(*) MES_OUT, 0 MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 11  
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, COUNT(*) MES_NOV, 0 MES_DEZ "
	
	ElseIf nMes == 12    
	
		cQuery := " SELECT AB6_XCDTEC COD_TEC,	0 MES_JAN, 0 MES_FEV, 0 MES_MAR, 0 MES_ABR, 0 MES_MAI, 0 MES_JUN, "
		cQuery += " 		   					0 MES_JUL, 0 MES_AGO, 0 MES_SET, 0 MES_OUT, 0 MES_NOV, COUNT(*) MES_DEZ "
	
	EndIf
	
	cQuery += " FROM "+RetSqlName("AB6")+" AB6 "
	cQuery += " WHERE D_E_L_E_T_ <> '*' 
	cQuery += " 	AND AB6_XCDTEC <> ''
	cQuery += " 	AND MONTH(AB6_EMISSA) = "+cValToChar(nMes)
	cQuery += " 	AND YEAR(AB6_EMISSA)  = "+cValToChar(nAno)
	cQuery += " GROUP BY AB6_XCDTEC
	
	If nMes < 12 
		cQuery += " UNION ALL "
	EndIf
	
Return cQuery


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas para impressão do relatório

@author		Alessandro Smaha
@since		04/07/2014

/*/
//-------------------------------------------------------------------------------  
Static Function AjustaSX1()

	Local aHelpPor01 := {"Ano para impressão do relatório"}
	Local aHelpPor02 := {"A partir do Código do Técnico"}
	Local aHelpPor03 := {"Até o Código do Técnico"} 
	Local aHelpPor04 := {"Ordem de impressão: Código ou Nome"}
	Local aHelpPor05 := {"Staus: Disponivel, Indisponivel ou Todos"}
	
	PutSx1(cPerg,"01","Ano ?"        ,"","","MV_CH01","C",4,0,0,"G",/*cValid*/,/*cF3*/,,,"MV_PAR01",,,,"",,,,,,,,,,,,,aHelpPor01)
	PutSx1(cPerg,"02","Técnico de ?" ,"","","MV_CH02","C",6,0,0,"G",/*cValid*/,"AA1"  ,,,"MV_PAR02",,,,"",,,,,,,,,,,,,aHelpPor02)
	PutSx1(cPerg,"03","Técnico ate ?","","","MV_CH03","C",6,0,0,"G",/*cValid*/,"AA1"  ,,,"MV_PAR03",,,,"",,,,,,,,,,,,,aHelpPor03)
	PutSx1(cPerg,"04","Ordem ?"      ,"","","MV_CH04","N",1,0,0,"C",/*cValid*/,/*cF3*/,,,"MV_PAR04",;
				 "Código","Código","Código","","Nome","Nome","Nome",,,,,,,,,,aHelpPor04)   
	PutSx1(cPerg,"05","Status ?"     ,"","","MV_CH05","N",1,0,0,"C",/*cValid*/,/*cF3*/,,,"MV_PAR05",;
				 "Disponivel","Disponivel","Disponivel","","Indisponivel","Indisponivel","Indisponivel","Todos","Todos","Todos",,,,,,,aHelpPor05)   
		
Return