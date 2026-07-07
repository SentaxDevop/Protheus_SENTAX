#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"    
#INCLUDE "TOPCONN.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC005
Relatório de Controle de Pontuação dos Técnicos
                
@sample		U_RTEC005()

@author		Alessandro Smaha
@since		03/09/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
// ALTERAÇÃO DA QUERY PARA GERACAO NA p12, ANALISE DE ERRO
User Function RTEC005()

Local lValOk		:= .T.
Local oReport
Local cUsrPerm		:= Alltrim(GetMv("ST_USRGTEC",.F.,"")) 

Private cPerg		:= "RTEC005"   
Private _nDiaMes	:= 0
Private _aMesAno	:= {} 

If !RetCodUsr() $ cUsrPerm
	MsgAlert("Usuário sem permissão para acessar esta rotina! Verificar parâmetro de acesso!","Atenção - [ST_USRGTEC]")
    Return
EndIf

//fAjustaSX1()
If !Pergunte(cPerg,.T.) 
 	lValOk := .F. 
Else     
	If MV_PAR05==2   
		If Val(MV_PAR01) < 1 .Or. Val(MV_PAR01) > 12                    
			lValOk := .F. 
			MsgAlert("Mês de referência informado é inválido!","Atenção")
		ElseIf Val(MV_PAR02) < 2010 
			lValOk := .F. 
			MsgAlert("Ano de referência informado é inválido!","Atenção")	
		EndIf
	Else
		If Val(MV_PAR01) < 0 .Or. Val(MV_PAR01) > 12                    
			lValOk := .F. 
			MsgAlert("Mês de referência informado é inválido!","Atenção")
		EndIf
		If Val(MV_PAR02) < 2010 .Or. Empty(MV_PAR02)
			lValOk := .F. 
			MsgAlert("Ano de referência informado é inválido!","Atenção")	
		EndIf	
	EndIf		             
EndIf

If lValOk	
	oReport := ReportDef()
	oReport:PrintDialog()	
EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Configura o objeto TReport. 

@sample	ReportDef() 

@author	Alessandro Smaha
@since	29/09/2014
@return	oReport - Objeto de impressão do relatório
/*/
//-------------------------------------------------------------------   
Static Function ReportDef() 

Local cTituRel	:= "Controle de Pontuação dos Técnicos"
Local cDescRel 	:= "Este programa ira emitir o relatório "+cTituRel
Local aOrdem   	:= {} 
Local nMesRef	:= Val(MV_PAR01)
Local nAnoRef	:= Val(MV_PAR02)  
Local lSinteti	:= IIF(MV_PAR05==2,.T.,.F.) // 1=Analítico, 2=Sintético 
Local nK		:= 0 
Local cDiaRef	:= ""
Local cMesRef	:= ""
Local oReport  
Local oSection1
Local oBreak1

oReport := TReport():New(cPerg,cTituRel,cPerg, {|oReport| ReportPrint(oReport)},cDescRel)   
 
If lSinteti // Sintético 
 
	_aMesAno := fAtuMesAno( Val(MV_PAR01), Val(MV_PAR02) )
			
	oReport:SetTotalInLine(.F.) 
	oReport:HideParamPage()
	
	oReport:SetLandscape()       // Define orientação de página do relatório como paisagem
	oReport:DisableOrientation() // Desabilita a seleção da orientação (Retrato/Paisagem) 	

	oSection1 := TRSection():New(oReport,"Técnico",{})
	
	TRCell():New(oSection1, "NOMTEC","QRY1","Nome","@!",35)
	
	TRCell():New(oSection1, "QMES01","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES01","QRY1",Substr(MesExtenso(_aMesAno[01][1]),1,3)+"/"+cValToChar(_aMesAno[01][2]),"@E 9999999.99",9) // ,,,"CENTER",,"CENTER")	
	
	TRCell():New(oSection1, "QMES02","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES02","QRY1",Substr(MesExtenso(_aMesAno[02][1]),1,3)+"/"+cValToChar(_aMesAno[02][2]),"@E 9999999.99",9) // ,,,"CENTER",,"CENTER")	
	
	TRCell():New(oSection1, "QMES03","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES03","QRY1",Substr(MesExtenso(_aMesAno[03][1]),1,3)+"/"+cValToChar(_aMesAno[03][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")

	TRCell():New(oSection1, "QMES04","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES04","QRY1",Substr(MesExtenso(_aMesAno[04][1]),1,3)+"/"+cValToChar(_aMesAno[04][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")	
	
	TRCell():New(oSection1, "QMES05","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES05","QRY1",Substr(MesExtenso(_aMesAno[05][1]),1,3)+"/"+cValToChar(_aMesAno[05][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection1, "QMES06","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES06","QRY1",Substr(MesExtenso(_aMesAno[06][1]),1,3)+"/"+cValToChar(_aMesAno[06][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")	
	
	TRCell():New(oSection1, "QMES07","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")		
	TRCell():New(oSection1, "MES07","QRY1",Substr(MesExtenso(_aMesAno[07][1]),1,3)+"/"+cValToChar(_aMesAno[07][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection1, "QMES08","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES08","QRY1",Substr(MesExtenso(_aMesAno[08][1]),1,3)+"/"+cValToChar(_aMesAno[08][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")	
	
	TRCell():New(oSection1, "QMES09","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES09","QRY1",Substr(MesExtenso(_aMesAno[09][1]),1,3)+"/"+cValToChar(_aMesAno[09][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection1, "QMES10","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES10","QRY1",Substr(MesExtenso(_aMesAno[10][1]),1,3)+"/"+cValToChar(_aMesAno[10][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")	
	
	TRCell():New(oSection1, "QMES11","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES11","QRY1",Substr(MesExtenso(_aMesAno[11][1]),1,3)+"/"+cValToChar(_aMesAno[11][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection1, "QMES12","QRY1","Qtd","@E 9999",4) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection1, "MES12","QRY1",Substr(MesExtenso(_aMesAno[12][1]),1,3)+"/"+cValToChar(_aMesAno[12][2]),"@E 999999.99",9) // ,,,"CENTER",,"CENTER")
	
	oSection1:Cell("MES01"):nHeaderAlign := 3 // 1-Esquerda, 2-Center ou 3-Direita. 
	oSection1:Cell("MES02"):nHeaderAlign := 3
	oSection1:Cell("MES03"):nHeaderAlign := 3
	oSection1:Cell("MES04"):nHeaderAlign := 3
	oSection1:Cell("MES05"):nHeaderAlign := 3
	oSection1:Cell("MES06"):nHeaderAlign := 3
	oSection1:Cell("MES07"):nHeaderAlign := 3
	oSection1:Cell("MES08"):nHeaderAlign := 3
	oSection1:Cell("MES09"):nHeaderAlign := 3
	oSection1:Cell("MES10"):nHeaderAlign := 3
	oSection1:Cell("MES11"):nHeaderAlign := 3
	oSection1:Cell("MES12"):nHeaderAlign := 3

	oSection1:Cell("QMES01"):nHeaderAlign := 3 // 1-Esquerda, 2-Center ou 3-Direita. 
	oSection1:Cell("QMES02"):nHeaderAlign := 3
	oSection1:Cell("QMES03"):nHeaderAlign := 3
	oSection1:Cell("QMES04"):nHeaderAlign := 3
	oSection1:Cell("QMES05"):nHeaderAlign := 3
	oSection1:Cell("QMES06"):nHeaderAlign := 3
	oSection1:Cell("QMES07"):nHeaderAlign := 3
	oSection1:Cell("QMES08"):nHeaderAlign := 3
	oSection1:Cell("QMES09"):nHeaderAlign := 3
	oSection1:Cell("QMES10"):nHeaderAlign := 3
	oSection1:Cell("QMES11"):nHeaderAlign := 3
	oSection1:Cell("QMES12"):nHeaderAlign := 3
   
	oBreak1 := TRBreak():New(oSection1,"","Total",.F.) 
	TRFunction():New(oSection1:Cell("MES01"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES02"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES03"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES04"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES05"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES06"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES07"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES08"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES09"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES10"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES11"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection1:Cell("MES12"),,"SUM",oBreak1,,,,.F.,.F.)

/*	
	oSection2 := TRSection():New(oSection1,"Metas",{}) //Rogerio 31/10
	
	TRCell():New(oSection2, "NOMTEC","QRY1","","@!",25)
	
	TRCell():New(oSection2, "MES01","QRY1",Substr(MesExtenso(_aMesAno[01][1]),1,3)+"/"+cValToChar(_aMesAno[01][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection2, "MES02","QRY1",Substr(MesExtenso(_aMesAno[02][1]),1,3)+"/"+cValToChar(_aMesAno[02][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection2, "MES03","QRY1",Substr(MesExtenso(_aMesAno[03][1]),1,3)+"/"+cValToChar(_aMesAno[03][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection2, "MES04","QRY1",Substr(MesExtenso(_aMesAno[04][1]),1,3)+"/"+cValToChar(_aMesAno[04][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection2, "MES05","QRY1",Substr(MesExtenso(_aMesAno[05][1]),1,3)+"/"+cValToChar(_aMesAno[05][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection2, "MES06","QRY1",Substr(MesExtenso(_aMesAno[06][1]),1,3)+"/"+cValToChar(_aMesAno[06][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection2, "MES07","QRY1",Substr(MesExtenso(_aMesAno[07][1]),1,3)+"/"+cValToChar(_aMesAno[07][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection2, "MES08","QRY1",Substr(MesExtenso(_aMesAno[08][1]),1,3)+"/"+cValToChar(_aMesAno[08][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection2, "MES09","QRY1",Substr(MesExtenso(_aMesAno[09][1]),1,3)+"/"+cValToChar(_aMesAno[09][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection2, "MES10","QRY1",Substr(MesExtenso(_aMesAno[10][1]),1,3)+"/"+cValToChar(_aMesAno[10][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	
	TRCell():New(oSection2, "MES11","QRY1",Substr(MesExtenso(_aMesAno[11][1]),1,3)+"/"+cValToChar(_aMesAno[11][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	TRCell():New(oSection2, "MES12","QRY1",Substr(MesExtenso(_aMesAno[12][1]),1,3)+"/"+cValToChar(_aMesAno[12][2]),"@E 999,999.99",10) // ,,,"CENTER",,"CENTER")
	
	oSection2:Cell("MES01"):nHeaderAlign := 3 // 1-Esquerda, 2-Center ou 3-Direita. 
	oSection2:Cell("MES02"):nHeaderAlign := 3
	oSection2:Cell("MES03"):nHeaderAlign := 3
	oSection2:Cell("MES04"):nHeaderAlign := 3
	oSection2:Cell("MES05"):nHeaderAlign := 3
	oSection2:Cell("MES06"):nHeaderAlign := 3
	oSection2:Cell("MES07"):nHeaderAlign := 3
	oSection2:Cell("MES08"):nHeaderAlign := 3
	oSection2:Cell("MES09"):nHeaderAlign := 3
	oSection2:Cell("MES10"):nHeaderAlign := 3
	oSection2:Cell("MES11"):nHeaderAlign := 3
	oSection2:Cell("MES12"):nHeaderAlign := 3
*/
   		       
Else // Analitico           
	 	
	oReport:SetTotalInLine(.F.) 
	oReport:HideParamPage()
	
	oReport:SetLandscape()       // Define orientação de página do relatório como paisagem
	oReport:DisableOrientation() // Desabilita a seleção da orientação (Retrato/Paisagem) 	

	oSection1 := TRSection():New(oReport,"Pontos",{})
	
	TRCell():New(oSection1, "Z22_NUMOS"	,"QRY1","NUMERO OS"				,"",20)
	TRCell():New(oSection1, "Z22_CODTEC","QRY1","TECNICO"				,"",20)  
	TRCell():New(oSection1, "AA1_NOMTEC","QRY1","NOME DO TECNICO"		,"",20)
	TRCell():New(oSection1, "Z22_SEQ"	,"QRY1","SEQUENCIA"				,"",20)
	TRCell():New(oSection1, "Z22_DATAAT","QRY1","DATA ATENDIM"			,"",20)
	TRCell():New(oSection1, "Z22_ITEM"	,"QRY1","ITEM"					,"",20)
	TRCell():New(oSection1, "Z22_PROD"	,"QRY1","COD PRODUTO"			,"",20)
	TRCell():New(oSection1, "B1_DESC"	,"QRY1","NOME DO PRODUTO/EQTO"	,"",20)
	TRCell():New(oSection1, "Z22_CODPRB","QRY1","OCORRENCIA"			,"",20)
	TRCell():New(oSection1, "AAG_DESCRI","QRY1","DESCRICAO OCORRENCIA"	,"",20)
	TRCell():New(oSection1, "AAG_XPONTO","QRY1","PTO OCORRENCIA"		,"",20)
	TRCell():New(oSection1, "Z22_QTDREA","QRY1","QTD EQTOS"				,"",20)
	TRCell():New(oSection1, "Z22_PONTOS","QRY1","TOTAL PONTOS"			,"",20)
	    	 	
	oBreak1 := TRBreak():New(oSection1,"","Total Pontos",.F.)
	
	TRFunction():New(oSection1:Cell("Z22_PONTOS"),,"SUM",oBreak1,,,,.F.,.F.)  
	 	
EndIf
	
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função de impressão do relatório.

@sample	ReportPrint(oReport)

@param	oReport - Objeto do tReport para impressão

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//-------------------------------------------------------------------   
Static Function ReportPrint(oReport)

Local cQuery	:= ""  
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oReport:Section(1):Section(1) 	// Define a secao 2 do relatorio
Local nMesRef	:= Val(MV_PAR01)
Local nAnoRef	:= Val(MV_PAR02)
Local lSinteti	:= IIF(MV_PAR05==2,.T.,.F.) // 1=Analítico, 2=Sintético
Local nMedia	:= 0  
Local nCor      := 0 	
Local nCinza    := 14803425 // Numero RGB da cor cinza
Local nBranco   := 16777215 // Numero RGB da cor branca 
Local lMeta		:= .T.  // Alterado para .f. Nao sera mais impresso a meta  - Rogerio 11/12
Local cGrpAux	:= "" 
Local cCompTit	:= ""
Local cStrTit   := ""

If MV_PAR03 == MV_PAR04
	cCompTit := ' ('+MV_PAR03+'-'+Alltrim(Substr(Posicione("AA1",1,xFilial("AA1")+MV_PAR03,"AA1_NOMTEC"),1,20))+'.)'
Else 
	cCompTit := ' (de '+IIF(Empty(MV_PAR03),'""',MV_PAR03)+' até '+IIF(Empty(MV_PAR04),'""',MV_PAR04)+')'
EndIF
		
If lSinteti // Sintético ou Analitico
	 
	cQuery := fSintetico()	  	   
	If ( Select("QRY1") ) > 0
		DbSelectArea("QRY1")
		QRY1->(DbCloseArea())
	EndIf        	
	TCQUERY cQuery NEW ALIAS "QRY1"   
	
	
	cQuer := fSintetic1()	  	   
	If ( Select("QRY1") ) > 0
		DbSelectArea("QRY1")
		QRY1->(DbCloseArea())
	EndIf   
	TCQUERY cQuer NEW ALIAS "QRY1"   
	
	
	oReport:SetMeter(0)
	oReport:SetTitle( oReport:Title() + " - Técnicos - "+MesExtenso(nMesRef)+" / "+cValToChar(nAnoRef)+cCompTit  + " - Valor por ponto: R$ " + AllTrim(Trans(mv_par08,'@E 999,999,999.99')) ) // Sintético 
	 
	DbSelectArea("QRY1")
	
	QRY1->(DbGoTop())
	
	If !QRY1->(Eof())  
	
		While !oReport:Cancel() .AND. !QRY1->(Eof()) 
									
			nMedia := (	QRY1->MES01 + QRY1->MES02 + QRY1->MES03 + QRY1->MES04 + QRY1->MES05 + QRY1->MES06 +; 
						QRY1->MES07 + QRY1->MES08 + QRY1->MES09 + QRY1->MES10 + QRY1->MES11 + QRY1->MES12 ) / 12 * mv_par08 
			 			
			
			If lMeta                  

				oSection1:Init()     
			
				oSection1:Cell("QMES01"):SetValue( NoRound(QRY1->MES01, 1) )
				oSection1:Cell("MES01"):SetValue( NoRound(QRY1->MES01 * MV_PAR08, 2) )
				oSection1:Cell("QMES02"):SetValue( NoRound(QRY1->MES02, 1) )
				oSection1:Cell("MES02"):SetValue( NoRound(QRY1->MES02 * MV_PAR08, 2) )
				oSection1:Cell("QMES03"):SetValue( NoRound(QRY1->MES03, 1) )
				oSection1:Cell("MES03"):SetValue( NoRound(QRY1->MES03 * MV_PAR08, 2) )
				oSection1:Cell("QMES04"):SetValue( NoRound(QRY1->MES04, 1) )
				oSection1:Cell("MES04"):SetValue( NoRound(QRY1->MES04 * MV_PAR08, 2) )
				oSection1:Cell("QMES05"):SetValue( NoRound(QRY1->MES05, 1) )
				oSection1:Cell("MES05"):SetValue( NoRound(QRY1->MES05 * MV_PAR08, 2) )
				oSection1:Cell("QMES06"):SetValue( NoRound(QRY1->MES06, 1) )
				oSection1:Cell("MES06"):SetValue( NoRound(QRY1->MES06 * MV_PAR08, 2) )
				oSection1:Cell("QMES07"):SetValue( NoRound(QRY1->MES07, 1) )
				oSection1:Cell("MES07"):SetValue( NoRound(QRY1->MES07 * MV_PAR08, 2) )
				oSection1:Cell("QMES08"):SetValue( NoRound(QRY1->MES08, 1) )
				oSection1:Cell("MES08"):SetValue( NoRound(QRY1->MES08 * MV_PAR08, 2) )
				oSection1:Cell("QMES09"):SetValue( NoRound(QRY1->MES09, 1) )
				oSection1:Cell("MES09"):SetValue( NoRound(QRY1->MES09 * MV_PAR08, 2) )
				oSection1:Cell("QMES10"):SetValue( NoRound(QRY1->MES10, 1) )
				oSection1:Cell("MES10"):SetValue( NoRound(QRY1->MES10 * MV_PAR08, 2) )
				oSection1:Cell("QMES11"):SetValue( NoRound(QRY1->MES11, 1) )
				oSection1:Cell("MES11"):SetValue( NoRound(QRY1->MES11 * MV_PAR08, 2) )
				oSection1:Cell("QMES12"):SetValue( NoRound(QRY1->MES12, 1) )
				oSection1:Cell("MES12"):SetValue( NoRound(QRY1->MES12 * MV_PAR08, 2) )
				oSection1:Cell("QMES01"):SetValue( NoRound(QRY1->MES01, 1) )
				oSection1:PrintLine()				
			
				lMeta := .F.
			
			Else
			
				oSection1:Cell("QMES01"):SetValue( NoRound(QRY1->MES01, 1) )
				oSection1:Cell("MES01"):SetValue( NoRound(QRY1->MES01 * MV_PAR08, 2) )
				oSection1:Cell("QMES02"):SetValue( NoRound(QRY1->MES02, 1) )
				oSection1:Cell("MES02"):SetValue( NoRound(QRY1->MES02 * MV_PAR08, 2) )
				oSection1:Cell("QMES03"):SetValue( NoRound(QRY1->MES03, 1) )
				oSection1:Cell("MES03"):SetValue( NoRound(QRY1->MES03 * MV_PAR08, 2) )
				oSection1:Cell("QMES04"):SetValue( NoRound(QRY1->MES04, 1) )
				oSection1:Cell("MES04"):SetValue( NoRound(QRY1->MES04 * MV_PAR08, 2) )
				oSection1:Cell("QMES05"):SetValue( NoRound(QRY1->MES05, 1) )
				oSection1:Cell("MES05"):SetValue( NoRound(QRY1->MES05 * MV_PAR08, 2) )
				oSection1:Cell("QMES06"):SetValue( NoRound(QRY1->MES06, 1) )
				oSection1:Cell("MES06"):SetValue( NoRound(QRY1->MES06 * MV_PAR08, 2) )
				oSection1:Cell("QMES07"):SetValue( NoRound(QRY1->MES07, 1) )
				oSection1:Cell("MES07"):SetValue( NoRound(QRY1->MES07 * MV_PAR08, 2) )
				oSection1:Cell("QMES08"):SetValue( NoRound(QRY1->MES08, 1) )
				oSection1:Cell("MES08"):SetValue( NoRound(QRY1->MES08 * MV_PAR08, 2) )
				oSection1:Cell("QMES09"):SetValue( NoRound(QRY1->MES09, 1) )
				oSection1:Cell("MES09"):SetValue( NoRound(QRY1->MES09 * MV_PAR08, 2) )
				oSection1:Cell("QMES10"):SetValue( NoRound(QRY1->MES10, 1) )
				oSection1:Cell("MES10"):SetValue( NoRound(QRY1->MES10 * MV_PAR08, 2) )
				oSection1:Cell("QMES11"):SetValue( NoRound(QRY1->MES11, 1) )
				oSection1:Cell("MES11"):SetValue( NoRound(QRY1->MES11 * MV_PAR08, 2) )
				oSection1:Cell("QMES12"):SetValue( NoRound(QRY1->MES12, 1) )
				oSection1:Cell("MES12"):SetValue( NoRound(QRY1->MES12 * MV_PAR08, 2) )

				oSection1:PrintLine()  
				
			EndIf 
			
			QRY1->(DbSkip())
					
		EndDo
	
	EndIf 
	
	If !lMeta
		oSection1:Finish()
	EndIf
		 
Else // Analitico

	cQuery := fAnalitico()
	  	   
	If ( Select("QRY1") ) > 0
		DbSelectArea("QRY1")
		QRY1->(DbCloseArea())
	EndIf        
	
	TCQUERY cQuery NEW ALIAS "QRY1"   
	
	oReport:SetMeter(0)
	If Empty(MV_PAR01)
		cStrTit := " - Analítico - "+ cValToChar(nAnoRef)
	Else
		cStrTit := " - Analítico - "+MesExtenso(MV_PAR01)+"/"+cValToChar(nAnoRef)
	EndIf
	
	oReport:SetTitle( oReport:Title() + cStrTit )
	 
	DbSelectArea("QRY1")
	
	QRY1->(DbGoTop())
	
	oSection1:Init()
	
	While !oReport:Cancel() .AND. !QRY1->(Eof())
		    
		oSection1:Cell("Z22_NUMOS"):SetValue(QRY1->Z22_NUMOS)
		oSection1:Cell("Z22_CODTEC"):SetValue(QRY1->Z22_CODTEC) 
		oSection1:Cell("AA1_NOMTEC"):SetValue(QRY1->AA1_NOMTEC)
		oSection1:Cell("Z22_SEQ"):SetValue(QRY1->Z22_SEQ)
		oSection1:Cell("Z22_DATAAT"):SetValue(SubStr(QRY1->Z22_DATAAT,7,2)+"/"+SubStr(QRY1->Z22_DATAAT,5,2)+"/"+SubStr(QRY1->Z22_DATAAT,1,4))
		oSection1:Cell("Z22_ITEM"):SetValue(QRY1->Z22_ITEM)
		oSection1:Cell("Z22_PROD"):SetValue(QRY1->Z22_PROD)
		oSection1:Cell("B1_DESC"):SetValue(QRY1->B1_DESC)
		oSection1:Cell("Z22_CODPRB"):SetValue(QRY1->Z22_CODPRB)
		oSection1:Cell("AAG_DESCRI"):SetValue(QRY1->AAG_DESCRI)
		oSection1:Cell("AAG_XPONTO"):SetValue(QRY1->AAG_XPONTO)
		oSection1:Cell("Z22_QTDREA"):SetValue(QRY1->Z22_QTDREA)
		oSection1:Cell("Z22_PONTOS"):SetValue(QRY1->Z22_PONTOS)

	    oSection1:PrintLine() 
	    				
		QRY1->(DbSkip()) 	  
					
	EndDo 
	
	oSection1:Finish() 					

EndIf
					
Return        
       

//-------------------------------------------------------------------
/*/{Protheus.doc} fSintetico
Monta a query para o relatório sintético...

@sample fSintetico()

@param	oReport - Objeto do tReport para impressão

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//------------------------------------------------------------------- 
Static Function fSintetico()  
	
Local cQuery := ""  
Local nK     := 0   

cQuery += " SELECT CODTEC
cQuery += "       ,NOMTEC
cQuery += "       ,SUM(MES01) MES01
cQuery += "       ,SUM(MES02) MES02
cQuery += "       ,SUM(MES03) MES03
cQuery += "       ,SUM(MES04) MES04
cQuery += "       ,SUM(MES05) MES05
cQuery += "       ,SUM(MES06) MES06
cQuery += "       ,SUM(MES07) MES07
cQuery += "       ,SUM(MES08) MES08
cQuery += "       ,SUM(MES09) MES09
cQuery += "       ,SUM(MES10) MES10
cQuery += "       ,SUM(MES11) MES11
cQuery += "       ,SUM(MES12) MES12
cQuery += "       ,OBS
cQuery += " FROM (
// METAS
cQuery += "			SELECT '000000' AS CODTEC
cQuery += "				  ,' * META * ' NOMTEC
cQuery += "				  ,    

For nK := 1 To 12
	cQuery += " CASE WHEN Z15_ANO + Z15_MES ='"+ cValToChar(_aMesAno[nK][2]) + StrZero(_aMesAno[nK][1],2) +"' 
	cQuery += "		THEN META ELSE 0 
	cQuery += " END MES"+ StrZero(nK,2)
	cQuery += ",   
Next nK
cQuery += "					'' OBS 
cQuery += "			FROM (	SELECT Z15_ANO, Z15_MES, Z15_META META  
cQuery += "					FROM "+ RetSqlName("Z15") +" Z15  
cQuery += " 				WHERE Z15.D_E_L_E_T_ <> '*' ) AS A  

cQuery += " 		UNION ALL

// QUERY PARA MOSTRAR TÉCNICOS QUE NÃO POSSUEM OS LANÇADAS 
cQuery += " 		SELECT AA1_CODTEC, AA1_NOMTEC,0,0,0,0,0,0,0,0,0,0,0,0,AA1_XOBS " 
cQuery += " 		FROM "+RetSqlName("AA1")+" AA1 " 
cQuery += " 		WHERE AA1.D_E_L_E_T_ <> '*' "
If MV_PAR06 == 2 // Mostra Inativos -> 1=Sim; 2=Não
	cQuery += " 			AND AA1_ALOCA = '1' " // 1=Disponivel;2=Indisponivel
EndIf                                                                           
If MV_PAR07 == 2 // Mostra Terceiros -> 1=Sim; 2=Não  
	cQuery += " 						AND AA1_FUNCAO <> '08' " + CHR(13) // Técnico Terceirizado
EndIf          
cQuery += " 		  	AND AA1_CODTEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuery += " UNION ALL " 

// BONUS DOS TÉCNICOS

cQuery += " 		SELECT AA1_CODTEC CODTEC, AA1_NOMTEC NOMTEC, "    
For nK := 1 to 12
	cQuery += " CASE WHEN Z16_ANO+Z16_MES='"+cValToChar(_aMesAno[nK][2])+StrZero(_aMesAno[nK][1],2)+"' THEN BONUS ELSE 0 END MES"+StrZero(nK,2)+", "
Next nK
cQuery += " 			AA1_XOBS OBS " 
cQuery += " 		FROM (	SELECT AA1_CODTEC, AA1_NOMTEC, Z16_ANO, Z16_MES, Z16_BONUS BONUS, AA1_XOBS "  
cQuery += " 				FROM "+RetSqlName("Z16")+" Z16 "   
cQuery += " 				INNER JOIN "+RetSqlName("AA1")+" AA1 ON AA1_CODTEC = Z16_TECNIC AND AA1.D_E_L_E_T_ <> '*' " 
If MV_PAR06 == 2 // Mostra Inativos -> 1=Sim; 2=Não
	cQuery += " 			AND AA1_ALOCA = '1' " // 1=Disponivel;2=Indisponivel
EndIf    
If MV_PAR07 == 2 // Mostra Terceiros -> 1=Sim; 2=Não  
	cQuery += " 						AND AA1_FUNCAO <> '08' " + CHR(13) // Técnico Terceirizado
EndIf          
cQuery += " 		   			AND AA1_CODTEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuery += " 				WHERE Z16.D_E_L_E_T_ <> '*' ) AS C " 	

cQuery += " UNION ALL " 

// PONTOS DE OS DOS TÉCNICOS
cQuery += " 		SELECT CODTEC, NOMTEC, "  
For nK := 1 to 12
	cQuery += " CASE WHEN SUBSTRING(AB9_DTFIM,1,6)='"+cValToChar(_aMesAno[nK][2])+StrZero(_aMesAno[nK][1],2)+;
									"' THEN PONTOS ELSE 0 END MES"+StrZero(nK,2)+", " 
Next nK
cQuery += "   			OBS "
cQuery += " 		FROM (	SELECT AB9_CODTEC CODTEC, AA1_NOMTEC NOMTEC, AA1_XOBS OBS, AB9_DTFIM, SUM(AAG_XPONTO*AB7_XQTDIN) PONTOS " 
cQuery += " 	  			FROM "+RetSqlName("AB7")+" AB7 " 
cQuery += " 	   	 			INNER JOIN "+RetSqlName("AB9")+" AB9 ON AB9_FILIAL = AB7_FILIAL AND AB9_NUMOS = AB7_NUMOS+AB7_ITEM " 
cQuery += " 	   					AND AB9_TIPO = '1' AND AB9.D_E_L_E_T_ <> '*' " 
cQuery += " 	   				INNER JOIN "+RetSqlName("AAG")+" AAG ON AAG_CODPRB = AB9_CODPRB AND AAG.D_E_L_E_T_ <> '*' "
//cQuery += " 	  				INNER JOIN "+RetSqlName("AA7")+" AA7 ON AA7_CODPRO = AB7_CODPRO AND AA7_CODPRB = AAG_CODPRB AND AA7.D_E_L_E_T_ <> '*' " 
cQuery += " 	  				INNER JOIN "+RetSqlName("AA1")+" AA1 ON AA1_CODTEC = AB9_CODTEC AND AA1.D_E_L_E_T_ <> '*' " 
If MV_PAR06 == 2 // Mostra Inativos -> 1=Sim; 2=Não
	cQuery += " 			AND AA1_ALOCA = '1' " // 1=Disponivel;2=Indisponivel
EndIf  
cQuery += " 		   			AND AA1_CODTEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuery += " 	 			WHERE AB7.D_E_L_E_T_ <> '*' " 
cQuery += " 	 			GROUP BY AB9_CODTEC, AA1_NOMTEC, AA1_XOBS,  AB9_DTFIM ) AS PONTOS "
cQuery += " 		) AS B "
cQuery += " GROUP BY CODTEC, NOMTEC, OBS "
cQuery += " ORDER BY NOMTEC "

// Mostra query
//Aviso("Query",cQuery,{"Ok"},3,,,,.T.) 

cQuery := ChangeQuery(cQuery)  
	  	   
Return cQuery  


//-------------------------------------------------------------------
/*/{Protheus.doc} fAnalitico
Monta a query para o relatório analitico...

@sample fAnalitico()

@param	oReport - Objeto do tReport para impressão

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//------------------------------------------------------------------- 
Static Function fAnalitico()  
	
Local cQuery 	:= ""   


cQuery += " SELECT Z22_NUMOS, " + CHR(13)	
cQuery += " 	Z22_CODTEC,	 " + CHR(13)
cQuery += " 	AA1_NOMTEC,	 " + CHR(13)
cQuery += " 	Z22_SEQ,	 " + CHR(13)
cQuery += " 	Z22_DATAAT,	 " + CHR(13)
cQuery += " 	Z22_ITEM,	 " + CHR(13)
cQuery += " 	Z22_PROD,	 " + CHR(13)
cQuery += " 	B1_DESC,	 " + CHR(13)
cQuery += " 	Z22_CODPRB,	 " + CHR(13)
cQuery += " 	AAG_DESCRI,	 " + CHR(13)
cQuery += " 	AAG_XPONTO,	 " + CHR(13)
cQuery += " 	Z22_QTDREA,	 " + CHR(13)
cQuery += " 	Z22_PONTOS  " + CHR(13)
	
cQuery += " FROM "+RetSqlName("Z22")+" Z22  " + CHR(13)
	
cQuery += " 	INNER JOIN "+RetSqlName("SB1")+" B1 ON B1_COD = Z22_PROD " + CHR(13)
cQuery += " 						AND B1.D_E_L_E_T_ = '' " + CHR(13)
						
cQuery += " 	INNER JOIN "+RetSqlName("AA1")+" AA1 ON AA1_CODTEC = Z22.Z22_CODTEC " + CHR(13)
If MV_PAR06 == 2 // Mostra Inativos -> 1=Sim; 2=Não
	cQuery += " 						AND AA1_ALOCA = '1' " + CHR(13) // 1=Disponivel;2=Indisponivel
EndIf          
If MV_PAR07 == 2 // Mostra Terceiros -> 1=Sim; 2=Não  
	cQuery += " 						AND AA1_FUNCAO <> '08' " + CHR(13) // Técnico Terceirizado
EndIf          
cQuery += " 						 AND AA1.D_E_L_E_T_ = '' " + CHR(13)
						 
cQuery += " 	INNER JOIN "+RetSqlName("AAG")+" AAG ON AAG_CODPRB = Z22_CODPRB " + CHR(13)
cQuery += " 						 AND AAG.D_E_L_E_T_ = '' " + CHR(13)

If Empty(MV_PAR01)
	cQuery += " WHERE LEFT(Z22_DATAAT,4) = '"+ MV_PAR02 +"' " + CHR(13)
Else
	cQuery += " WHERE LEFT(Z22_DATAAT,6) = '"+ MV_PAR02 + PadL(MV_PAR01,2,"0") +"' " + CHR(13)
EndIf
cQuery += " AND Z22_CODTEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CHR(13)
cQuery += " AND Z22.D_E_L_E_T_ = '' " + CHR(13)
cQuery += " ORDER BY Z22_DATAAT, Z22_CODTEC " + CHR(13)

// Mostra query
//Aviso("Query",cQuery,{"Ok"},3,,,,.T.) 
                                                           
cQuery := ChangeQuery(cQuery)  
	  	   
Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} fSintetic1
Monta a query para o relatório sintético...

@sample fSintetic1()

@param	oReport - Objeto do tReport para impressão

@author	RCL
@since	09/12/2017
@return	NIL
/*/
//------------------------------------------------------------------- 
Static Function fSintetic1()  
	
Local cQuer 	:= ""  
Local nK		:= 0   

cQuer += " SELECT CODTEC, NOMTEC,	SUM(MES01) MES01, SUM(MES02) MES02, SUM(MES03) MES03, SUM(MES04) MES04, SUM(MES05) MES05, SUM(MES06) MES06, "
cQuer += " 				SUM(MES07) MES07, SUM(MES08) MES08, SUM(MES09) MES09, SUM(MES10) MES10, SUM(MES11) MES11, SUM(MES12) MES12, OBS "
cQuer += " FROM	( "

// PONTOS DE OS DOS TÉCNICOS
cQuer += " 		SELECT CODTEC, NOMTEC, "  
For nK := 1 to 12
	cQuer += " CASE WHEN SUBSTRING(Z22_DATAAT,1,6)='"+cValToChar(_aMesAno[nK][2])+StrZero(_aMesAno[nK][1],2)+;
									"' THEN PONTOS ELSE 0 END MES"+StrZero(nK,2)+", " 
Next nK
cQuer += "   			OBS "
cQuer += " 		FROM (	SELECT Z22_CODTEC CODTEC, AA1_NOMTEC NOMTEC, '  ' OBS, Z22_DATAAT, SUM(Z22_PONTOS) PONTOS " 
cQuer += " 	  			FROM "+RetSqlName("Z22")+" Z22 " 
cQuer += " 	  				INNER JOIN "+RetSqlName("AA1")+" AA1 ON AA1_CODTEC = Z22_CODTEC AND AA1.D_E_L_E_T_ <> '*' " 
If MV_PAR06 == 2 // Mostra Inativos -> 1=Sim; 2=Não
	cQuer += " 			AND AA1_ALOCA = '1' " // 1=Disponivel;2=Indisponivel
EndIf  
If MV_PAR07 == 2 // Mostra Terceiros -> 1=Sim; 2=Não  
	cQuer += " 						AND AA1_FUNCAO <> '08' " + CHR(13) // Técnico Terceirizado
EndIf          
cQuer += " 		   			AND AA1_CODTEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuer += " 	 			WHERE Z22.D_E_L_E_T_ <> '*' " 
cQuer += " 	 			GROUP BY Z22_CODTEC, AA1_NOMTEC, AA1_XOBS, Z22_DATAAT ) AS PONTOS "
cQuer += " 		) AS B "
cQuer += " GROUP BY CODTEC, NOMTEC, OBS "
cQuer += " ORDER BY NOMTEC "

// Mostra query
//Aviso("Query",cQuer,{"Ok"},3,,,,.T.) 

cQuer := ChangeQuery(cQuer)  
	  	   
Return cQuer  


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuMesAno
Atualiza array com os meses e ano no período de um ano 

@sample	fAtuMesAno( nMes, nAno )

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//-------------------------------------------------------------------  
Static Function fAtuMesAno( nMes, nAno ) 

Local aAux	:= Array(12)
Local nK	:= 0

For nK := 12 To 1 Step -1 

	aAux[nK] := { nMes, nAno }
    
	If nMes == 1 
		nMes := 12 
		nAno -= 1
	Else
	   	nMes -= 1
	EndIf
	
Next nK

Return aAux 


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuDiaMes
Atualiza array com os meses e ano no período de um ano 

@sample	fAtuDiaMes( nMes, nAno )

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//-------------------------------------------------------------------  
Static Function fAtuDiaMes( nMes, nAno ) 

Local aAux		:= {}
Local nK		:= 0 
Local nDiasMes	:= 0  
Local dDataRef	:= StoD(StrZero(nAno,4)+StrZero(nMes,2)+"01") 

nDiasMes := Last_Day(dDataRef)

For nK := 12 To 1 Step -1 

	aAux[nK] := { nMes, nAno }
    
	If nMes == 1 
		nMes := 12 
		nAno -= 1
	Else
	   	nMes -= 1
	EndIf
	
Next nK

Return aAux
 

//-------------------------------------------------------------------
/*/{Protheus.doc} fSomaMes
Função de impressão do relatório.

@sample	fSomaMes( nMes, nAno )

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//-------------------------------------------------------------------   
Static Function fSomaMes( nMes, nAno ) 

If nMes == 12
	nMes := 1
	nAno++
Else
	nMes++
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fVoltaMes
Volta 12 meses atrás para impressão do relatório

@sample	fVoltaMes( nMes, nAno )

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//-------------------------------------------------------------------   
Static Function fVoltaMes( nMes, nAno ) 

If nMes <> 12
	nAno -= 1
EndIf

nMes -= 11

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} fAjustaSX1
Prepara as perguntas para o relatório

@author  Alessandro Smaha
@since   30/09/2014
@return  NIL
/*/
//-------------------------------------------------------------------
Static Function fAjustaSX1()  

Local aHelpPor01 := {"Mês de referência para impressão do relatório"}
Local aHelpPor02 := {"Ano de referência para impressão do relatório"}
Local aHelpPor03 := {"A partir do técnico..."}
Local aHelpPor04 := {"... Até o técnico"}
Local aHelpPor05 := {"Impressão Analítica ou Sintética ?"}
Local aHelpPor06 := {"Indica se imprime Técnico Inativo"}
Local aHelpPor07 := {"Impressão deve incluir os Terceiros ?"}
Local aHelpPor08 := {"Indicar valor do Ponto para Calculo referencial"}
    
PutSx1(cPerg,"01","Mês Referência?","Mês Referência?","Mês Referência?",	"MV_CH1","C",02,0,0,"G","","","","","MV_PAR01";
		,,,,"",,,,,,,,,,,,,aHelpPor01)
PutSx1(cPerg,"02","Ano Referência?","Ano Referência?","Mês Referência?",	"MV_CH2","C",04,0,0,"G","","","","","MV_PAR02";
		,,,,"",,,,,,,,,,,,,aHelpPor02)
PutSx1(cPerg,"03","Técnico De ?","Técnico De ?","Técnico De ?",		   		"MV_CH3","C",TAMSX3("AA1_CODTEC")[1],0,0,"G","","AA1","","","MV_PAR03";
		,,,,"",,,,,,,,,,,,,aHelpPor03)
PutSx1(cPerg,"04","Técnico Ate ?","Técnico Ate ?","Técnico Ate ?",			"MV_CH4","C",TAMSX3("AA1_CODTEC")[1],0,0,"G","","AA1","","","MV_PAR04";
		,,,,"",,,,,,,,,,,,,aHelpPor04)
PutSx1(cPerg,"05","Tipo ?","Tipo ?","Tipo ?",								"MV_CH5","N",01,0,0,"C","","","","","MV_PAR05",;
				 						"Analitico","Analitico","Analitico","","Sintetico","Sintetico","Sintetico",,,,,,,,,,aHelpPor05)
PutSx1(cPerg,"06","Mostra inativo ?","Mostra inativo ?","Mostra inativo ?",	"MV_CH6","N",01,0,0,"C","","","","","MV_PAR06",;
				 						"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor06)				 						
PutSx1(cPerg,"07","Imprime Terceiro?","Inclui Terceiro?","Inclui Terceiro?","MV_CH7","N",01,0,0,"C","","","","","MV_PAR07",;
				 						"Sim","Sim","Sim","","Não","Não","Não",,,,,,,,,,aHelpPor07)				 			
PutSx1(cPerg,"08","Valor do Ponto?","Valor do Ponto?","Valor do Ponto?","MV_CH8","N",01,0,0,"C","","","","","MV_PAR08",;
		,,,,"",,,,,,,,,,,,,aHelpPor08)

			 						    	
Return