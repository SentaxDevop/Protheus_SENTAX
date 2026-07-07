#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"                                                                                                               
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'    


//-------------------------------------------------------------------
/*/{Protheus.doc} CurvaABCF
Relatório de Curva ABC Faturamento

@author  Henrique Baldin	
@since   02/07/2014                                                


/*/
//-------------------------------------------------------------------
User Function CurvaABC()    // U_CurvaABCF()

	Local oReport 
	
	Private cPerg := "CABCFAT"

                                                                                                                

	Private nTotFis   := 0
	Private nTotSis   := 0                                            		
	Private ndif      := 0
	Private nCTBD     := 0
	Private nCTBC     := 0
	Private nDifPG    := 0
	
	Private nTotalNF  := 0
	Private nTotalCT  := 0
	Private nDifeTOT  := 0
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01               Data de                               ³
	//³ mv_par02               Data ate                              ³
	//³ mv_par03               Curva A                               ³	
	//³ mv_par04               Curva B                               ³
	//³ mv_par05               Curva C                               ³
	//³ mv_par06               Atualiza cadastro Produto.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Carregamento das Perguntas
   //	AjustaSX1()
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf  
	// validação pergunta
   /*	If  MV_PAR05 <> 100
	    Msgalert("Curva C deve ser igual a 100") 
	    Pergunte(cPerg,.T.) 	    
	Endif 
	 
	If  MV_PAR03 > MV_PAR04
 		Msgalert("A curva A deve ser menor que a curva B")
 		Pergunte(cPerg,.T.)
	endif	
	If  MV_PAR04 > MV_PAR05
 		Msgalert("A curva B deve ser menor que a curva C")
 		Pergunte(cPerg,.T.)
	endif */	 
                 
    while  (MV_PAR03 + MV_PAR04 + MV_PAR05) <> 100 .OR. MV_PAR05 < 0
			Msgalert("A soma das curvas deve ser igual a 100")
	 		//Pergunte(cPerg,.T.)

	enddo
		
	If  MV_PAR06 == 1
 			If MsgYesNo("Deseja mesmo Atualizar a Curva ABC","Aviso")	
        		oReport := ReportDef()
				oReport:PrintDialog()
		
	    EndIf	
	Else
		oReport := ReportDef()
		oReport:PrintDialog()    
	Endif	
	
	


Return



//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Estrutura do Relatório

@author  Henrique baldin
@since   08/04/2013

/*/
//-------------------------------------------------------------------
Static Function ReportDef()

	Local cTitle    := OemToAnsi("RELATORIO DE CURVA ABC DE FATURAMENTO")
	Local cHelp     := OemToAnsi("RELATORIO DE CURVA ABC DE FATURAMENTO")
	
	Local oReport    
	Local oSection  
	Local oSection1		                                        
	
	oReport := tReport():New("CABCFAT",cTitle,cPerg,{|oReport| ReportPrint(oReport)}, )
	 	
	
	//oReport:SetLandscape()
	oReport:HideParamPage() 
	
		
	oSection  := trSection():New(oReport,"Curva ABC de Faturamento",,,,,,,.F.)    
 
 	 
	trCell():New(oSection,"Filial"      ," ","Filial"    ,,6  )
	trCell():New(oSection,"Produto"     ," ","Produto"   ,,16 ) 
	trCell():New(oSection,"Grupo"	    ," ","Grupo"   	 ,,06 )
	trCell():New(oSection,"Descricao"   ," ","Descricao" ,,40 )
	trCell():New(oSection,"Um"          ," ","Um"        ,,5  )	   
	
	// calculados
	trCell():New(oSection,"V_Unit_Medio",PesqPict("SD2","D2_TOTAL"),"V_Unit_Medio",,TamSX3("D2_TOTAL")[1]+2,,/*{|| }*/,,,"RIGHT")
	trCell():New(oSection,"Quantidade"  ,PesqPict("SD2","D2_QUANT"),"Quant"  ,,TamSX3("D2_QUANT")[1]+2,,/*{|| }*/,,,"RIGHT")
	trCell():New(oSection,"V_total",	 PesqPict("SD2","D2_TOTAL"),"V_total",,TamSX3("D2_TOTAL")[1]+2,,/*{|| }*/,,,"CENTER")
	trCell():New(oSection,"Percen_Venda"," ","%venda "      ,,07,,/*{|| }*/,,,"RIGHT")
	trCell():New(oSection,"Percen_Item" ," ","%Acumulado "  ,,12,,/*{|| }*/,,,"RIGHT")
	trCell():New(oSection,"Curva"       ," ","Curva"      ,,10) 
    
	oSection:Cell("Percen_Item"):SetAlign("RIGHT")	 
	
Return(oReport)


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Realiza a impressão do relatório

@author  Henrique Baldin
@since   04/06/2014                      


/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local oSection  := oReport:Section(1)
Local aItens :={}
Local cCurva :=""
Local nCurva := 0
Local nPacu := 0
Local nFatTotal := 0
Local nTotFat := 0 

Private cDataINI  := DTOS(MV_PAR01)
Private cDataFIM  := DTOS(MV_PAR02)
Private nCurvaA  := (MV_PAR03)
Private nCurvaB  := (MV_PAR03)+(MV_PAR04)
Private nCurvaC  := (MV_PAR05)
Private nAtuSB1  := (MV_PAR06)

If ( SELECT("SD2TMP") ) > 0
	dbSelectArea("SD2TMP")
	SD2TMP->(dbCloseArea())
EndIf

cQuery := " SELECT D2_FILIAL, "
cQuery += " D2_COD, "
cQuery += " D2_UM, "
cQuery += " B1_DESC, "
cQuery += " B1_GRUPO, "
cQuery += " SUM(D2_QUANT) QUANT, "
cQuery += " 0 VALLIQ, "
cQuery += " 0 DEV, "
cQuery += " ISNULL((SELECT SUM(D2_TOTAL) TOTAL "
cQuery += " 		FROM   " + RetSqlName("SD2") + " C "
cQuery += " 		INNER JOIN " + RetSqlName("SF4") + " SF4A ON SF4A.F4_FILIAL = SUBSTRING(C.D2_FILIAL, 1, 4) "
cQuery += " 			AND SF4A.F4_CODIGO = C.D2_TES AND SF4A.F4_ESTOQUE = 'S' AND SF4A.D_E_L_E_T_ = ' ' "
cQuery += " 		WHERE  C.D2_FILIAL = '"+cFilAnt+"' "
cQuery += " 			AND C.D2_EMISSAO >= '"+cDataINI+"' "
cQuery += " 			AND C.D2_EMISSAO <= '"+cDataFIM+"' "
cQuery += " 			AND C.D2_COD = A.D2_COD "
cQuery += " 			AND C.D_E_L_E_T_ = ' ' "
cQuery += " 		GROUP  BY C.D2_FILIAL,C.D2_COD), 0) AS FAT, "
cQuery += " ISNULL((SELECT SUM(D.D2_TOTAL) TOTAL "
cQuery += " 		FROM   " + RetSqlName("SD2") + " D "
cQuery += " 		INNER JOIN " + RetSqlName("SF4") + " SF4B ON SF4B.F4_FILIAL = SUBSTRING(D.D2_FILIAL, 1, 4) "
cQuery += " 			AND SF4B.F4_CODIGO = D.D2_TES AND SF4B.F4_ESTOQUE = 'S' AND SF4B.D_E_L_E_T_ = ' ' "
cQuery += " 		WHERE  D.D2_FILIAL = '"+cFilAnt+"' "
cQuery += " 			AND D.D2_EMISSAO >= '"+cDataINI+"' "
cQuery += " 			AND D.D2_EMISSAO <= '"+cDataFIM+"' "
cQuery += " 			AND D.D_E_L_E_T_ = ' ' "
cQuery += " 		GROUP  BY D.D2_FILIAL), 0) AS TOTFAT "
cQuery += " FROM   " + RetSqlName("SD2") + " A "
cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.B1_FILIAL = ' ' "
cQuery += " 	AND B1.B1_COD = A.D2_COD "
cQuery += " 	AND B1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4C ON SF4C.F4_FILIAL = SUBSTRING(A.D2_FILIAL, 1, 4) "
cQuery += " 			AND SF4C.F4_CODIGO = A.D2_TES AND SF4C.F4_ESTOQUE = 'S' AND SF4C.D_E_L_E_T_ = ' ' "
cQuery += " WHERE  A.D2_FILIAL = '"+cFilAnt+"' "
cQuery += " 	AND A.D2_EMISSAO >= '"+cDataINI+"' "
cQuery += " 	AND A.D2_EMISSAO <= '"+cDataFIM+"' "
cQuery += " 	AND A.D_E_L_E_T_ = ' ' "
cQuery += " GROUP  BY D2_FILIAL, D2_COD, D2_UM, B1_DESC, B1_GRUPO "
cQuery += " ORDER  BY FAT DESC "

TCQUERY cQuery NEW ALIAS "SD2TMP"

SD2TMP->(DBGotop())

oReport:SetMeter(SD2TMP->(LastRec())) 
 
oSection:Init() 

If SD2TMP->(!EOF()) 
	nTotFat := SD2TMP->TOTFAT
Else
	nTotFat := 0	
EndIf
	
Do While SD2TMP->(!EOF())  

	oReport:IncMeter()  
	
	nVunitM 	:= SD2TMP->FAT / SD2TMP->QUANT
	nPerc   	:=  ( SD2TMP->FAT * 100 ) / SD2TMP->TOTFAT
	
	// tatativa para ver qual  curva se enquadra ...
	
	nCurva += nPerc
	
	//nCurva := noround(nCurva,1)
	
	If nCurva < nCurvaA
		cCurva := "  A"
	ElseIf  nCurva < nCurvaB
		cCurva := "  B"
	Else
		cCurva := "  C"
	Endif
	oSection:Cell("FILIAL"      ):SetValue( SD2TMP->D2_FILIAL )
	oSection:Cell("PRODUTO"     ):SetValue( SD2TMP->D2_COD )
	//	oSection:Cell("ARMAZEM"     ):SetValue(cUn)       
	oSection:Cell("GRUPO"       ):SetValue( SD2TMP->B1_GRUPO )	
	oSection:Cell("DESCRICAO"   ):SetValue( SD2TMP->B1_DESC )
	oSection:Cell("UM"          ):SetValue( SD2TMP->D2_UM )
	oSection:Cell("V_Unit_Medio"):SetValue( Transform(nVunitM, PesqPict("SD2","D2_TOTAL")) )
	oSection:Cell("Quantidade"	):SetValue( SD2TMP->QUANT )
	oSection:Cell("V_total"    	):SetValue( Transform(SD2TMP->FAT, PesqPict("SD2","D2_TOTAL")) )
	oSection:Cell("Percen_Venda"):SetValue( Transform(nPerc, "@E 999.999") )
	If nPerc >= 0.0001
		oSection:Cell("Percen_Item" ):SetValue( Transform(nCurva, "@E 999.999") )
	Else
		oSection:Cell("Percen_Item" ):SetValue( "-")
	EndIf
	oSection:Cell("Curva"    	):SetValue( cCurva)
	
	oSection:PrintLine()
	oReport:SkipLine()
	
	// Realiza alteração no cadastro de produto conforme parametro MV_PAR06 .
	If MV_PAR06  == 1
		DbSelectArea("SB3")
		SB3->(dbSetOrder(1))
		IF SB3->(dbSeek(xFilial("SB3")+ SD2TMP->D2_COD ))
			RecLock("SB3",.F.)
			SB3->B3_CLASSE := LTRIM(cCurva)
			MsUnLock("SB3")
		ENDIF
	EndIf
	SD2TMP->(DBSkip()) 
	
EndDo
     
oReport:SkipLine() 
oReport:SkipLine() 

oReport:PrintText("Total faturamento:............."+AllTrim(Transform(nTotFat,"@E 999,999,999.99"))   )
 
oReport:SkipLine() 	
oReport:PrintText("Data De:"+DTOC(MV_PAR01)+"  Data Até:"+DTOC(MV_PAR02))
  
oSection:Finish()		
 
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do relatório no dicionário de dados (SX1)

@author  henrique baldin (henrique@consultir.com.br)
@since   08/04/2013

/*/
//-------------------------------------------------------------------
Static Function AjustaSX1()

	Local aHelpPor01 := {"Data inicial"}
	Local aHelpPor02 := {"Data final"}	 
	Local aHelpPor03 := {"Curva A"}
	Local aHelpPor04 := {"Curva B"}
	Local aHelpPor05 := {"Curva C"}
	Local aHelpPor06 := {"Atualiza cadastro de Demandas do produto"}  
							
	PutSx1(cPerg,"01","Data de"               ,"","","MV_PAR01","D",08 ,0,0,"G",/*cValid*/,/*cF3*/,,,"MV_PAR01",       ,,,"",         ,,,,,,,,,,,,aHelpPor01)
	PutSx1(cPerg,"02","Data ate"              ,"","","MV_PAR02","D",08 ,0,0,"G",/*cValid*/,/*cF3*/,,,"MV_PAR02",       ,,,"",         ,,,,,,,,,,,,aHelpPor02)
	PutSx1(cPerg,"03","Curva A"               ,"","","MV_PAR03","N",03 ,0,0,"G",/*cValid*/,/*cF3*/,,,"MV_PAR03",       ,,,"",         ,,,,,,,,,,,,aHelpPor03)
	PutSx1(cPerg,"04","Curva B"               ,"","","MV_PAR04","N",03 ,0,0,"G",/*cValid*/,/*cF3*/,,,"MV_PAR04",       ,,,"",         ,,,,,,,,,,,,aHelpPor04)
	PutSx1(cPerg,"05","Curva C"               ,"","","MV_PAR05","N",03 ,0,0,"G",/*cValid*/,/*cF3*/,,,"MV_PAR05",       ,      ,      ,""    ,      ,      ,      ,,,,,,,,,,aHelpPor05)	 
	PutSx1(cPerg,"06","Atualiza Produto?"     ,"","","MV_PAR06","N",01 ,0,2,"C",      ,       ,,,"MV_PAR06", "SIM" , "SIM", "SIM", "SIM", "NAO", "NAO", "NAO",,,,,,,,,,aHelpPor06)

Return