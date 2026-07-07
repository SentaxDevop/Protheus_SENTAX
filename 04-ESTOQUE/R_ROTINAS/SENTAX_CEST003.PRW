#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"                                                                                                               
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'    


//-------------------------------------------------------------------
/*/{Protheus.doc} Giro de estoque
Relatório de Giro de estoque

@author  Henrique Baldin	
@since   21/08/2014                                                


/*/
//-------------------------------------------------------------------
User Function SGiroEst()    // U_SGiroEst()
Local oReport	
Private cPerg := "CGIROEST"
				  	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Data de                               ³
//³ mv_par02               Data ate                              ³
//³ mv_par07               Itens Custo Zerados                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Carregamento das Perguntas
 // AjustaSX1()
	
If !Pergunte(cPerg,.T.)
	Return
EndIf 
	
oReport := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Estrutura do Relatório

@author  Henrique baldin
@since   21/08/2013

/*/
//-------------------------------------------------------------------
Static Function ReportDef()

	Local cTitle    := OemToAnsi("RELATORIO DE GIRO DE ESTOQUE")
	Local cHelp     := OemToAnsi("RELATORIO DE GIRO DE ESTOQUE")
	Local oReport    
	Local oSection 
	
	oReport := tReport():New("cAcurEst",cTitle,cPerg,{|oReport| ReportPrint(oReport)}, )
	
	oReport:SetLandscape()
	oReport:HideParamPage() 
	
	oSection  := trSection():New(oReport,"Giro de Estoque Sentax",,,,,,,.F.)  
   	
   	iF MV_PAR03 == 1
   		trCell():New(oSection,"FILIAL"      ," ","FILIAL"    ,,8 )
		trCell():New(oSection,"ARMAZEM"     ," ","ARMAZEM"   ,,4  )	
   		trCell():New(oSection,"PRODUTO"     ," ","PRODUTO"   ,,16 )
		trCell():New(oSection,"DESCRICAO"   ," ","DESCRICAO" ,,40 )

	ENDIF
    
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Realiza a impressão do relatório

@author  Henrique Baldin
@since   21/08/2014                      


/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
	
	Local nFatTotal := 0
	Local nValorIni := 0
	Local nValorFim := 0
	Local nItenzI := 0
	Local nItenzF := 0
	Local nGMensal := 0
	Local aItenzerado := {}	
	Local oSection  := oReport:Section(1)   
	Private dDataINI  := DTOS(MV_PAR01)
	Private dDataFIM  := DTOS(MV_PAR02) 

   //	APURAR O TOTAL DAS VENDAS NO PERÍODO: NOTAS FISCAIS DE SAÍDA 
   If ( SELECT("SD2TMP") ) > 0
   		dbSelectArea("SD2TMP")
   		SD2TMP->(dbCloseArea())
	EndIf                                                                           
	cQuery := "Select SUM(D2_TOTAL)TOTAL   from SD2010 D3 "
	cQuery += " INNER JOIN SF4010 F4 ON F4_FILIAL = SUBSTRING(D3.D2_FILIAL,1,4) AND F4_CODIGO = D3.D2_TES AND F4.D_E_L_E_T_ =' ' AND F4_ESTOQUE ='S' "
	cQuery += " WHERE D3.D2_FILIAL = '"+cFilAnt+"' "
	cQuery += " AND D3.D2_EMISSAO >='"+dDataINI+"' "
	cQuery += " AND D3.D2_EMISSAO <='"+dDataFIM+"' "
	cQuery += " and D3.D_E_L_E_T_ =' ' "
	cQuery += " GROUP BY  D3.D2_FILIAL "           
	 
	TCQUERY cQuery NEW ALIAS "SD2TMP"
	nFatTotal := SD2TMP->TOTAL
   	//PEGA TODOS OS PRODUTOS.
   	If ( SELECT("SB1TMP") ) > 0
   		dbSelectArea("SB1TMP")
   		SB1TMP->(dbCloseArea())
	EndIf
	cQuery1 := " SELECT B1_COD,B1_DESC  FROM SB1010  WHERE    D_E_L_E_T_ =' '  "
 	TCQUERY cQuery1 NEW ALIAS "SB1TMP"
  	SB1TMP->(DBGotop())   
  	Do While SB1TMP->(!EOF()) 
  		
    //PEGA TODOS OS ARMAZENS.
	If ( SELECT("SB2TMP") ) > 0
   		dbSelectArea("SB2TMP")
   		SB2TMP->(dbCloseArea())
	EndIf
	
	cQuery2 := " SELECT  B2_FILIAL,B2_COD,B2_CM1,B2_LOCAL FROM SB2010  WHERE   B2_FILIAL ='"+cFilAnt+"' AND B2_COD = '"+SB1TMP->B1_COD+"' AND  D_E_L_E_T_ =' '  order by  B2_COD,B2_LOCAL " 
	
	TCQUERY cQuery2 NEW ALIAS "SB2TMP"
  	SB2TMP->(DBGotop())   
  	Do While SB2TMP->(!EOF()) 
  		cProduto := SB2TMP->B2_COD
  		cLocal := SB2TMP->B2_LOCAL
  	    // saldo inicial
  		aSaldos := CalcEst(cProduto ,cLocal , STOD(dDataINI) ) 	  	
  		
  	  	If aSaldos[1] > 0
	  	    iF aSaldos[8] > 0
	  	    	nValorIni:= nValorIni +( aSaldos[1] * aSaldos[8])
	  	    		nItenzI :=  nItenzI +1
	  	    ElseIF  SB2TMP->B2_CM1 > 0 	    
	  	    	nValorIni:= nValorIni +(aSaldos[1] * SB2TMP->B2_CM1) 
	  	    		nItenzI :=  nItenzI +1	  	    		  
	  	    Else
	  	    	nItenzF :=  nItenzF +1
	  	    	aAdd(aItenzerado,{SB2TMP->B2_FILIAL,SB2TMP->B2_COD,SB1TMP->B1_DESC,SB2TMP->B2_LOCAL   })
	       	endif 
	     Endif  	
       	// saldo final
       	aSaldos := CalcEst(cProduto ,cLocal , STOD(dDataFIM) ) 	  	
  	  
  	    iF aSaldos[8] > 0
  	    	nValorFim:= nValorFim + (aSaldos[1] * aSaldos[8])
  	    else
  	    	nValorFim:= nValorFim + (aSaldos[1] * SB2TMP->B2_CM1)	
       	endif 
       	
       
   	SB2TMP->(DBSkip())
  	EndDo             
	SB1TMP->(DBSkip())
  	EndDo
	   
  	
  	oSection:Init()
	
	If  MV_PAR03 == 1
		oReport:SkipLine() 
		For nI := 1 To Len(aItenzerado)
			oSection:Cell("FILIAL"      ):SetValue(aItenzerado[nI,1]) 
			oSection:Cell("ARMAZEM"          ):SetValue( aItenzerado[nI,4]) 
			oSection:Cell("PRODUTO"      ):SetValue(aItenzerado[nI,2])
			oSection:Cell("DESCRICAO"   ):SetValue( aItenzerado[nI,3])
			oSection:PrintLine()                                                       
			oReport:SkipLine() 
		Next nI
	endif
	
	oReport:SkipLine() 
	oReport:SkipLine() 
	oReport:PrintText("Data De:"+DTOC(MV_PAR01)+"  Data Até:"+DTOC(MV_PAR02))
	oReport:PrintText("Item com custo..............."+AllTrim(Transform(nItenzI,"@E 99999")))
	oReport:PrintText("Item Sem Custo..............."+AllTrim(Transform(nItenzF,"@E 99999"))) 
	oReport:SkipLine() 
	oReport:PrintText("ESTOQUE INICIAL............."+AllTrim(Transform(nValorIni,"@E 999,999,999.99"))   )
	oReport:PrintText("ESTOQUE FINAL..............."+AllTrim(Transform(nValorFim,"@E 999,999,999.99")))	
	oReport:PrintText("VENDA NO PERÍODO............"+AllTrim(Transform(nFatTotal,"@E 999,999,999.99")))
	oReport:SkipLine() 	                                                                                                                	
	
	 nGMensal := (nFatTotal / (( nValorFim +  nValorIni  ) /2  ))
	
	oReport:PrintText( "GIRO DE ESTOQUE " + AllTrim(Transform(nGMensal,"@E 999,999.99")) )   
	oReport:SkipLine() 	
	
 	
	oSection:Finish()	
	
	
Return	 


	