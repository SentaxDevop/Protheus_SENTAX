#include "totvs.ch"
#include "protheus.ch"

Static lFWCodFil := FindFunction("FWCodFil")

//-------------------------------------------------------------------------------
/*/{Protheus.doc} REST002
Relatório poder De/Em Terceiro resumido por NF

@author  Leandro Natan Bonette Santos
@since   01/07/2015
@return  uRet, nil
@author  Anderson Rocha (versão Sentax 22/09/2015)

/*/
//-------------------------------------------------------------------------------
User Function REST003()

Local oReport := Nil

Private cPerg      := "REST003"
Private cPictSaldo := X3Picture("F2_VALBRUT") 

oReport := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do relatório

@author    Leandro Natan Bonette Santos
@since     29/06/2015
@version   1.0
@return    oReport, Objeto TReport configurado

/*/
//-------------------------------------------------------------------------------
Static Function ReportDef(nReg)

Local oReport    := Nil
Local oSection1  := Nil

Local aOrdem     := {}

Local cFilePrint := "REST003_"+Dtos(MSDate())+StrTran(Time(),":","")
Local cTitle     := "Relacao de materiais de Terceiros e em Terceiros por NF resumido"
Local cDescric   := ""

cDescric += "Este programa ira emitir o Relatorio de NFs de Materiais "
cDescric += "de Terceiros em nosso poder e/ou nosso Material em "
cDescric += "poder de Terceiros."

Aadd( aOrdem, " Tipo/Codigo/Loja " )  

//Carrega as perguntas
Pergunte("REST003",.T.)

If mv_par09 == 1 //Relatório versao sintetica
	oReport := TReport():New(cFilePrint,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cDescric) 
ElseIf mv_par09 == 2 //Relatório versão analitica
	oReport := TReport():New(cFilePrint,cTitle,cPerg, {|oReport| RepPrt(oReport)},cDescric) 
End 

oReport:SetLandscape()    

Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,"Produto / Fornecedor",{"SB6","SF3","SX5","SA1","SA2"},aOrdem)
oSection1:SetTotalInLine(.F.)  

//Relatório versao sintetica
If mv_par09 == 1
    
	//Colunas do relatório
	TRCell():New(oSection1,'B6_CLIFOR'   ,'SB6',"Codigo"             ,/*Picture*/,TamSX3('B6_CLIFOR'  )[1]       ,.F.)
	TRCell():New(oSection1,'B6_LOJA'     ,'SB6',"Loja"               ,/*Picture*/,TamSX3('B6_CLIFOR'  )[1]       ,.F.)
	TRCell():New(oSection1,'NOME'        ,''   ,""                   ,/*Picture*/,TamSX3('A1_NREDUZ'  )[1]       ,.F.)
	TRCell():New(oSection1,'B6_DOC'      ,'SB6',"Nota"               ,/*Picture*/,TamSX3('B6_DOC'     )[1]       ,.F.)
	TRCell():New(oSection1,'B6_SERIE'    ,'SB6',"Serie"              ,/*Picture*/,TamSX3('B6_SERIE'   )[1]       ,.F.)
	TRCell():New(oSection1,'TOTAL'       ,''   ,"Valor"              ,cPictSaldo,TamSX3('D2_VALBRUT'  )[1]       ,.F.)
	TRCell():New(oSection1,'SALDO'       ,''   ,"Saldo"              ,cPictSaldo,TamSX3('D2_VALBRUT'  )[1]       ,.F.)
	//TRCell():New(oSection1,'F3_EMISSAO'  ,'SF3',"Emissão"            ,/*Picture*/,TamSX3('F3_EMISSAO' )[1]+2     ,.F.)
	TRCell():New(oSection1,'FT_EMISSAO'  ,'SFT',"Emissão"            ,/*Picture*/,TamSX3('FT_EMISSAO' )[1]+2     ,.F.)	
	TRCell():New(oSection1,'DIASATRASO'  ,'',"Dias em Aberto"        ,/*Picture*/)
	//TRCell():New(oSection1,'F3_CFO'      ,'SF3',"CFOP"               ,/*Picture*/,TamSX3('F3_CFO'     )[1]       ,.F.)
	TRCell():New(oSection1,'FT_CFOP'     ,'SFT',"CFOP"               ,/*Picture*/,TamSX3('FT_CFOP'    )[1]       ,.F.)	
	TRCell():New(oSection1,'X5_DESCRI'   ,'SX5',"Descrição"          ,/*Picture*/,TamSX3('X5_DESCRI'  )[1]       ,.F.)      
	
	//Totalizadores do relatório
	oBreak1 := TRBreak():New(oSection1,"","Total",.F.)   
	TRFunction():New(oSection1:Cell("TOTAL"),,"SUM",oBreak1,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("SALDO"),,"SUM",oBreak1,,,,.F.,.F.)  
 	
//Relatório versao analitica
ElseIf mv_par09 == 2	
    
	//Colunas do relatório
	TRCell():New(oSection1,'B6_CLIFOR'   ,'SB6',"Codigo"             ,/*Picture*/,TamSX3('B6_CLIFOR'  )[1]       ,.F.)
	TRCell():New(oSection1,'B6_LOJA'     ,'SB6',"Loja"               ,/*Picture*/,TamSX3('B6_CLIFOR'  )[1]       ,.F.)
	TRCell():New(oSection1,'NOME'        ,''   ,""                   ,/*Picture*/,40					       ,.F.)
	TRCell():New(oSection1,'B6_DOC'      ,'SB6',"Nota"               ,/*Picture*/,TamSX3('B6_DOC'     )[1]+3     ,.F.)
	TRCell():New(oSection1,'B6_SERIE'    ,'SB6',"Serie"              ,/*Picture*/,TamSX3('B6_SERIE'   )[1]       ,.F.)
	TRCell():New(oSection1,'B6_PRODUTO'  ,'SB6',"Produto"            ,/*Picture*/,TamSX3('B6_PRODUTO' )[1]       ,.F.)
	TRCell():New(oSection1,'B1_DESC'     ,'SB1',"Descrição"          ,/*Picture*/,TamSX3('B1_DESC'    )[1]       ,.F.)
	TRCell():New(oSection1,'B6_QUANT'    ,'SB6',"Quantidade"         ,/*Picture*/,TamSX3('B6_QUANT'   )[1]       ,.F.) 
	//TRCell():New(oSection1,'SALDO'		 ,'SB6',"Saldo"		         ,/*Picture*/,TamSX3('B6_QUANT'   )[1]       ,.F.) 
	TRCell():New(oSection1,'TOTAL'       ,''   ,"Valor"              ,cPictSaldo,TamSX3('D2_VALBRUT'  )[1]       ,.F.) 
	//TRCell():New(oSection1,'F3_EMISSAO'  ,'SF3',"Emissão"            ,/*Picture*/,TamSX3('F3_EMISSAO' )[1]       ,.F.)
	TRCell():New(oSection1,'FT_EMISSAO'  ,'SFT',"Emissão"            ,/*Picture*/,TamSX3('FT_EMISSAO' )[1]       ,.F.)	
	TRCell():New(oSection1,'DIASATRASO'  ,'',"Dias aberto"        ,/*Picture*/)
	//TRCell():New(oSection1,'F3_CFO'      ,'SE3',"CFOP"               ,/*Picture*/,TamSX3('F3_CFO'     )[1]       ,.F.)
	TRCell():New(oSection1,'FT_CFOP'     ,'SFT',"CFOP"               ,/*Picture*/,TamSX3('FT_CFOP'    )[1]       ,.F.)	
	TRCell():New(oSection1,'X5_DESCRI'   ,'SX5',"Descrição"          ,/*Picture*/,TamSX3('X5_DESCRI'  )[1]       ,.F.)   
	
	//Totalizadores do relatório
	oBreak1 := TRBreak():New(oSection1,"","Total Geral",.F.)   
	TRFunction():New(oSection1:Cell("B6_QUANT"),,"SUM",oBreak1,,,,.F.,.F.) 
	//TRFunction():New(oSection1:Cell("SALDO"),,"SUM",oBreak1,,,,.F.,.F.)
 	TRFunction():New(oSection1:Cell("TOTAL"),,"SUM",oBreak1,,,,.F.,.F.)

EndIf   

Return(oReport)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório      
VERSAO SINTETICA

@author  Leandro Natan Bonette Santos
@since   29/06/2015
@param   oReport, objeto, Objeto TReport
@return  nil, Nulo  

/*/
//-------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

//Chamada para relatório versão sintética
 
Local oSection1  := oReport:Section(1)
Local nOrdem     := oReport:GetOrder()
Local cAliasQry  := GetNextAlias()
Local cAliasQry2 := GetNextAlias()

Local aSaldo     := {}
Local aSaldosNF  := {}

Local nSaldo     := 0
Local nPrUnit    := 0
Local nTotal     := 0
Local nPosSaldo  := 0

Local cOrdem     := ""
Local cTipo      := ""
Local cTpCliFor  := ""
Local cDoc       := ""
Local cSerie     := ""
Local cCliFor    := ""
Local cLojCliFor := ""
Local cProdNf    := ""
Local cFilialSF4 := ""
Local cVendedor  := ""

//Verifica qual o titiulo será impresso no relatório
If MV_PAR07 == 1
	oReport:SetTitle("RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - CLIENTE / FORNECEDOR")
ElseIf MV_PAR07 == 2
	oReport:SetTitle("RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - CLIENTE / FORNECEDOR")
Else
	oReport:SetTitle("RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - CLIENTE / FORNECEDOR")
EndIf

//Verifica se a tabela SF4 (TES) esta compartilhada ou exclusiva. Isso influencia nos filtros do relatório
If lFWCodFil .And. (MsMdoFil("SF4")[3]=="E".Or.MsMdoFil("SF4")[2]=="E".Or.MsMdoFil("SF4")[1]=="E")
	If MsMdoFil("SF4")[3] == "E"
		nLen := Len(FwCompany("SF4"))
	EndIf
	If MsMdoFil("SF4")[2] == "E"
		nLen += Len(FwUnitBusiness("SF4"))
	EndIf
	If MsMdoFil("SF4")[1] == "E"
		nLen += Len(FwFilial("SF4"))
	EndIf
//	cFilialSF4 := "% SF4.F4_FILIAL = '" + SubStr(xFilial("SF4"),1,nLen) + "' AND %"
	cFilialSF4 := "% SF4.F4_FILIAL <> ' ' AND %"
Else
//	cFilialSF4 := "% SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND %"
	cFilialSF4 := "% SF4.F4_FILIAL <> ' ' AND %"

EndIf

//Verifica se lista notas de terceiros ou em terceiros
If MV_PAR07 == 1
	cTipo  := "% AND SB6.B6_TIPO = 'D' %"
ElseIf MV_PAR07 == 2
	cTipo  := "% AND SB6.B6_TIPO = 'E' %"
Else
	cTipo  := "%%"
EndIf

// Filtra vendedor
If !Empty(MV_PAR10)
	cVendedor := "% AND SA1.A1_VEND = '"+ AllTrim(MV_PAR10) +"' %"
Else
	cVendedor := "%%"
EndIf

	//MOnta query para extrair dados
	BeginSql Alias cAliasQry
		
		COLUMN F3_EMISSAO AS DATE
		
		SELECT	SB6.B6_FILIAL,
				SB6.B6_TPCF,
				SB6.B6_CLIFOR,
				SB6.B6_LOJA, 
				(CASE WHEN SB6.B6_TPCF = %Exp:'C'% 
					THEN SA1.A1_NOME 
					ELSE SA2.A2_NOME 
					END ) NOME,
				SB6.B6_DOC,
				SB6.B6_SERIE,
				SUM(SB6.B6_QUANT * SB6.B6_PRUNIT) TOTAL,
				//SF3.F3_CFO,
				//SF3.F3_EMISSAO,  
				SFT.FT_CFOP,
				SFT.FT_EMISSAO,		
				SX5.X5_DESCRI
	
		FROM	%Table:SB6%	SB6
				
		JOIN	%Table:SF4%	SF4 ON
		%Exp:cFilialSF4%
		SF4.F4_CODIGO  = SB6.B6_TES		AND
		SF4.F4_PODER3 <> %Exp:'D'%     	AND
		SF4.%NotDel%
		/*
		LEFT JOIN	%Table:SF3%	SF3 ON
		SF3.F3_FILIAL   = %xFilial:SF3%	AND
		SF3.F3_NFISCAL  = SB6.B6_DOC	AND
		SF3.F3_SERIE    = SB6.B6_SERIE	AND
		SF3.F3_CLIEFOR  = SB6.B6_CLIFOR AND
		SF3.F3_LOJA     = SB6.B6_LOJA	AND
		SF3.%NotDel%
		*/
		LEFT JOIN	%Table:SFT%	SFT ON
		SFT.FT_FILIAL   = %xFilial:SFT%	 AND
		SFT.FT_NFISCAL  = SB6.B6_DOC	 AND
		SFT.FT_SERIE    = SB6.B6_SERIE	 AND
		SFT.FT_CLIEFOR  = SB6.B6_CLIFOR  AND
		SFT.FT_LOJA     = SB6.B6_LOJA	 AND
		SFT.FT_PRODUTO  = SB6.B6_PRODUTO AND		
		SFT.%NotDel%  
	
		/*
		INNER JOIN SD2010 SD2 ON D2_FILIAL = FT_FILIAL AND
		D2_DOC 		= FT_NFISCAL AND
		D2_SERIE 	= FT_SERIE AND
		D2_CLIENTE 	= FT_CLIEFOR AND
		D2_LOJA 	= FT_LOJA AND
		D2_COD 		= FT_PRODUTO AND
		D2_ITEM 	= FT_ITEM AND
		D2_IDENTB6 	= B6_IDENT AND
		SD2.%NotDel%  
	
		LEFT JOIN	%Table:SX5%	SX5 ON
		SX5.X5_TABELA   = %Exp:'13'%	AND
		SX5.X5_CHAVE    = SF3.F3_CFO	AND
		SX5.%NotDel%
		*/
	
		LEFT JOIN	%Table:SX5%	SX5 ON
		SX5.X5_TABELA   = %Exp:'13'%	AND
		SX5.X5_CHAVE    = SFT.FT_CFOP	AND
		SX5.%NotDel%
	
		LEFT JOIN	%Table:SA2%	SA2 ON
		SA2.A2_COD      = SB6.B6_CLIFOR AND
		SA2.A2_LOJA     = SB6.B6_LOJA	AND
		SA2.%NotDel%
		
		LEFT JOIN	%Table:SA1%	SA1 ON
		SA1.A1_COD      = SB6.B6_CLIFOR	AND
		SA1.A1_LOJA     = SB6.B6_LOJA	AND
		SA1.%NotDel%
		%Exp:cVendedor%	
		
		WHERE	SB6.B6_FILIAL = %xFilial:SB6%	AND
				((SB6.B6_TPCF = %Exp:'C'% AND B6_CLIFOR >= %Exp:MV_PAR01%	AND B6_CLIFOR <= %Exp:MV_PAR02% )  OR
				( SB6.B6_TPCF = %Exp:'F'% AND B6_CLIFOR >= %Exp:MV_PAR03% 	AND B6_CLIFOR <= %Exp:MV_PAR04% )) AND
				SB6.B6_DTDIGIT >= %Exp:DTOS(MV_PAR05)%	AND
				SB6.B6_DTDIGIT <= %Exp:DTOS(MV_PAR06)%	AND
				SB6.B6_QUANT   <> 0						AND
				SB6.%NotDel%		
				%Exp:cTipo%		
			
		GROUP BY	SB6.B6_FILIAL,
					SB6.B6_TPCF,
					SB6.B6_CLIFOR,
					SB6.B6_LOJA,
					SB6.B6_DOC,
					SB6.B6_SERIE,
					//SF3.F3_CFO,
					//SF3.F3_EMISSAO,  
					SFT.FT_CFOP,
					SFT.FT_EMISSAO,		
					SX5.X5_DESCRI,
					SA1.A1_NOME,
					SA2.A2_NOME
		
		//ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SF3.F3_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA
		ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SFT.FT_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA		
		
	EndSql
*/	
If (cAliasQry)->(!EoF())
	
	cQryArm := "% " + GetLastQuery()[2] + " %"
	//cQryArm := StrTran(cQryArm,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SF3.F3_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA","")
	cQryArm := StrTran(cQryArm,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SFT.FT_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA","")	
	
	//-------------------------------------------------------
	//Contando total de registros da consulta
	//-------------------------------------------------------
	cQtdQuery := "% " + GetLastQuery()[2] + " %"
	//cQtdQuery := StrTran(cQtdQuery,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SF3.F3_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA","")
	cQtdQuery := StrTran(cQtdQuery,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SFT.FT_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA","")	
	
	BeginSql Alias "QTDQUERY"
		SELECT	COUNT(*) TOTAL
		FROM ( %Exp:cQtdQuery% ) TOTALREG
	EndSql
	
	nTotalDoc := QTDQUERY->TOTAL
	
	QTDQUERY->(DbCloseArea())
	//-------------------------------------------------------
	BeginSql Alias "SB6TMP"
		
		SELECT	SB6.*,
		SB6.R_E_C_N_O_ AS RECNO,
		SF4.F4_PODER3
		
		FROM	%Table:SB6%	SB6
		
		JOIN	%Table:SF4%	SF4	ON
		%Exp:cFilialSF4%
		SF4.F4_CODIGO  = SB6.B6_TES		AND
		SF4.F4_PODER3 <> %Exp:'D'%		AND
		SF4.%NotDel%
		
		WHERE	SB6.B6_FILIAL = %xFilial:SB6%	AND
		
		((SB6.B6_TPCF = %Exp:'C'% AND B6_CLIFOR >= %Exp:MV_PAR01%	AND B6_CLIFOR <= %Exp:MV_PAR02% )  OR
		( SB6.B6_TPCF = %Exp:'F'% AND B6_CLIFOR >= %Exp:MV_PAR03% 	AND B6_CLIFOR <= %Exp:MV_PAR04% )) AND
		
		SB6.B6_DTDIGIT >= %Exp:DTOS(MV_PAR05)%	AND
		SB6.B6_DTDIGIT <= %Exp:DTOS(MV_PAR06)%	AND
		SB6.B6_QUANT   <> 0						AND
		SB6.%NotDel%
		
		%Exp:cTipo%
		
		ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SB6.B6_DOC,SB6.B6_SERIE,SB6.B6_CLIFOR,SB6.B6_LOJA
		
	EndSql

	//Resultado da Query
	_cResQry:= GETLastQuery()[2]
		
	If SB6TMP->(!Eof())
		
		//-------------------------------------------------------
		//Contando total de registros da consulta
		//-------------------------------------------------------
		cQtdQuery := "% " + GetLastQuery()[2] + " %"
		cQtdQuery := StrTran(cQtdQuery,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SB6.B6_DOC,SB6.B6_SERIE,SB6.B6_CLIFOR,SB6.B6_LOJA","")
		
		BeginSql Alias "QTDQUERY"
			SELECT	COUNT(*) TOTAL
			FROM ( %Exp:cQtdQuery% ) TOTALREG
		EndSql
		
		nTotalSld := QTDQUERY->TOTAL
		
		QTDQUERY->(DbCloseArea())
		//-------------------------------------------------------
		
		oReport:SetMsgPrint("Obtendo saldo das notas normais...")
		oReport:SetMeter(nTotalSld)
		
		
		While SB6TMP->(!EoF())
			
			cTpCliFor  := SB6TMP->B6_TPCF
			cDoc       := SB6TMP->B6_DOC
			cSerie     := SB6TMP->B6_SERIE
			cCliFor    := SB6TMP->B6_CLIFOR
			cLojCliFor := SB6TMP->B6_LOJA
			
		
			AAdd(aSaldosNF,{"","","","","",0}) //TpCF,Doc,Serie,Clifor,Loja,Saldo
				
			While SB6TMP->(!EoF()) .AND.	cTpCliFor  == SB6TMP->B6_TPCF 	.AND. ;
				cDoc       == SB6TMP->B6_DOC 	.AND. ;
				cSerie     == SB6TMP->B6_SERIE  .AND. ;
				cCliFor    == SB6TMP->B6_CLIFOR	.AND. ;
				cLojCliFor == SB6TMP->B6_LOJA
				
				
				aSaldo  := SB6TMP->(CalcTerc(B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_IDENT,B6_TES,,MV_PAR05,MV_PAR06))
				nSaldo  := aSaldo[1]
				nPrUnit := IIF(aSaldo[3]==0,SB6TMP->B6_PRUNIT,aSaldo[3])
				
				If Empty(ATail(aSaldosNF)[1])					
					
					ATail(aSaldosNF)[1] := SB6TMP->B6_TPCF
					ATail(aSaldosNF)[2] := SB6TMP->B6_DOC
					ATail(aSaldosNF)[3] := SB6TMP->B6_SERIE
					ATail(aSaldosNF)[4] := SB6TMP->B6_CLIFOR
					ATail(aSaldosNF)[5] := SB6TMP->B6_LOJA					
					ATail(aSaldosNF)[6] := nSaldo * nPrUnit
				Else
					ATail(aSaldosNF)[6] += nSaldo * nPrUnit					
				EndIf
				
				
				oReport:IncMeter()
				SB6TMP->(DbSkip())
			End
			
		End
		
		oReport:SetMsgPrint("Imprimindo documentos normais...")
		oReport:SetMeter(nTotalDoc)
		
		While !oReport:Cancel() .AND. !(cAliasQry)->(Eof())
			
			
			cTipoCF := (cAliasQry)->B6_TPCF
			nTotal  := 0
			
			If cTipoCF == "C"
				oSection1:Cell("NOME"):SetTitle("Cliente")
			Else
				oSection1:Cell("NOME"):SetTitle("Fornecedor")
			EndIf
			
			oSection1:Init()
			
			While !oReport:Cancel() .AND. cTipoCF == (cAliasQry)->B6_TPCF
				
				If oReport:Cancel()
					Exit
				EndIf
				
				nPosSaldo := AScan(aSaldosNF,{|x| x[1] == (cAliasQry)->B6_TPCF .AND. x[2] == (cAliasQry)->B6_DOC .AND. x[3] == (cAliasQry)->B6_SERIE .AND. x[4] == (cAliasQry)->B6_CLIFOR .AND. x[5] == (cAliasQry)->B6_LOJA  } )
					
				//Não mostra documentos sem saldo
				If MV_PAR08 == 2 .AND. aSaldosNF[nPosSaldo][6] == 0
					oReport:IncMeter()
					(cAliasQry)->(DbSkip())
					LOOP
				EndIf
					
				
				//If AllTrim((cAliasQry)->F3_CFO) != "5908" .And. AllTrim((cAliasQry)->F3_CFO) != "6908"
				If AllTrim((cAliasQry)->FT_CFOP) != "5908" .And. AllTrim((cAliasQry)->FT_CFOP) != "6908"				
								
					oSection1:Cell('B6_CLIFOR' ):SetValue((cAliasQry)->B6_CLIFOR  )
					oSection1:Cell('B6_LOJA'   ):SetValue((cAliasQry)->B6_LOJA    )
					oSection1:Cell('NOME'      ):SetValue((cAliasQry)->NOME       )
					oSection1:Cell('B6_DOC'    ):SetValue((cAliasQry)->B6_DOC     )
					oSection1:Cell('B6_SERIE'  ):SetValue((cAliasQry)->B6_SERIE   )
								
					oSection1:Cell('TOTAL'     ):SetValue((cAliasQry)->TOTAL      )
					
					If nPosSaldo == 0
						oSection1:Cell('SALDO' ):SetPicture("@!")
						oSection1:Cell('SALDO' ):SetValue( "")
					Else
						oSection1:Cell('SALDO' ):SetPicture(cPictSaldo)
						oSection1:Cell('SALDO' ):SetValue(aSaldosNF[nPosSaldo][6])
					EndIf
					/*
					oSection1:Cell('F3_EMISSAO'):SetValue((cAliasQry)->F3_EMISSAO )
					oSection1:Cell('DIASATRASO'):SetValue((dDatabase-(cAliasQry)->F3_EMISSAO) )
					oSection1:Cell('F3_CFO'    ):SetValue((cAliasQry)->F3_CFO     )  
					*/
					oSection1:Cell('FT_EMISSAO'):SetValue(STOD((cAliasQry)->FT_EMISSAO ))
					oSection1:Cell('DIASATRASO'):SetValue((dDatabase-STOD((cAliasQry)->FT_EMISSAO)) )
					oSection1:Cell('FT_CFOP'   ):SetValue((cAliasQry)->FT_CFOP    )					
					//oSection1:Cell('X5_DESCRI' ):SetValue((cAliasQry)->X5_DESCRI  )
					
					oSection1:PrintLine()
					nTotal += (cAliasQry)->TOTAL
					
				EndIf
				
				oReport:IncMeter()
				(cAliasQry)->(DbSkip())
			End
		
			oSection1:Finish()
			
		End
	EndIf
	
	SB6TMP->(DbCloseArea())
	
EndIf

oReport:EndPage()

(cAliasQry)->(DbCloseArea())

Return 


//-------------------------------------------------------------------------------
/*/{Protheus.doc} RepPrt
Impressão do relatório  
VERSÂO ANALITICA

@author  Leandro Natan Bonette Santos
@since   29/06/2015
@param   oReport, objeto, Objeto TReport
@return  nil, Nulo

/*/
//-------------------------------------------------------------------------------
Static Function RepPrt(oReport)

Local oSection1  := oReport:Section(1)
Local nOrdem     := oReport:GetOrder()
Local cAliasQry  := GetNextAlias()
Local cAliasQry2 := GetNextAlias()

Local aSaldo     := {}
Local aSaldosNF  := {}

Local nSaldo     := 0
Local nPrUnit    := 0
Local nTotal     := 0
Local nPosSaldo  := 0

Local cOrdem     := ""
Local cTipo      := ""
Local cTpCliFor  := ""
Local cDoc       := ""
Local cSerie     := ""
Local cCliFor    := ""
Local cLojCliFor := ""
Local cProdNf    := ""
Local cFilialSF4 := ""
Local cVendedor  := ""

If MV_PAR07 == 1
	oReport:SetTitle("RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - CLIENTE / FORNECEDOR")
ElseIf MV_PAR07 == 2
	oReport:SetTitle("RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - CLIENTE / FORNECEDOR")
Else
	oReport:SetTitle("RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - CLIENTE / FORNECEDOR")
EndIf

If lFWCodFil .And. (MsMdoFil("SF4")[3]=="E".Or.MsMdoFil("SF4")[2]=="E".Or.MsMdoFil("SF4")[1]=="E")
	If MsMdoFil("SF4")[3] == "E"
		nLen := Len(FwCompany("SF4"))
	EndIf
	If MsMdoFil("SF4")[2] == "E"
		nLen += Len(FwUnitBusiness("SF4"))
	EndIf
	If MsMdoFil("SF4")[1] == "E"
		nLen += Len(FwFilial("SF4"))
	EndIf
	cFilialSF4 := "% SF4.F4_FILIAL = '" + SubStr(xFilial("SF4"),1,nLen) + "' AND %"
Else
	cFilialSF4 := "% SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND %"
EndIf

If MV_PAR07 == 1
	cTipo  := "% AND SB6.B6_TIPO = 'D' %"
ElseIf MV_PAR07 == 2
	cTipo  := "% AND SB6.B6_TIPO = 'E' %"
Else
	cTipo  := "%%"
EndIf

// Filtra vendedor
If !Empty(MV_PAR10)
	cVendedor := "% AND SA1.A1_VEND = '"+ AllTrim(MV_PAR10) +"' %"
Else
	cVendedor := "%%"
EndIf

BeginSql Alias cAliasQry
		           
	COLUMN F3_EMISSAO AS DATE
		
	SELECT	SB6.B6_FILIAL,
	SB6.B6_TPCF,
	SB6.B6_CLIFOR,
	SB6.B6_LOJA,
	(CASE WHEN SB6.B6_TPCF = %Exp:'C'% 
		THEN SA1.A1_NOME 
		ELSE SA2.A2_NOME 
	END ) NOME,
	SB6.B6_DOC,
	SB6.B6_SERIE,
	SB6.B6_PRODUTO,
	SB6.B6_QUANT,
	(SB6.B6_QUANT * SB6.B6_PRUNIT) TOTAL, 
	SB6.B6_IDENT,
	SB6.B6_TES,
	//SF3.F3_CFO,
	//SF3.F3_EMISSAO,
	SFT.FT_CFOP,
	SFT.FT_EMISSAO,		
	SX5.X5_DESCRI
	
	FROM	%Table:SB6%	SB6
				
	JOIN	%Table:SF4%	SF4 ON
	%Exp:cFilialSF4%
	SF4.F4_CODIGO  = SB6.B6_TES		AND
	SF4.F4_PODER3 <> %Exp:'D'%     	AND
	SF4.%NotDel%    
	/*
	LEFT JOIN	%Table:SF3%	SF3 ON
	SF3.F3_FILIAL   = %xFilial:SF3%	AND
	SF3.F3_NFISCAL  = SB6.B6_DOC	AND
	SF3.F3_SERIE    = SB6.B6_SERIE	AND
	SF3.F3_CLIEFOR  = SB6.B6_CLIFOR AND
	SF3.F3_LOJA     = SB6.B6_LOJA	AND
	SF3.%NotDel%
	*/
	LEFT JOIN	%Table:SFT%	SFT ON
	SFT.FT_FILIAL   = %xFilial:SFT%	AND
	SFT.FT_NFISCAL  = SB6.B6_DOC	AND
	SFT.FT_SERIE    = SB6.B6_SERIE	AND
	SFT.FT_CLIEFOR  = SB6.B6_CLIFOR AND
	SFT.FT_LOJA     = SB6.B6_LOJA	AND
	SFT.FT_PRODUTO  = SB6.B6_PRODUTO	AND		
	SFT.%NotDel%  
    /*			
	INNER JOIN SD2010 SD2 ON D2_FILIAL = FT_FILIAL AND
	D2_DOC 		= FT_NFISCAL AND
	D2_SERIE 	= FT_SERIE AND
	D2_CLIENTE 	= FT_CLIEFOR AND
	D2_LOJA 	= FT_LOJA AND
	D2_COD 		= FT_PRODUTO AND
	D2_ITEM 	= FT_ITEM AND
	D2_IDENTB6 	= B6_IDENT AND
	SD2.%NotDel%
	
	LEFT JOIN	%Table:SX5%	SX5 ON
	SX5.X5_TABELA   = %Exp:'13'%	AND
	SX5.X5_CHAVE    = SF3.F3_CFO	AND
	SX5.%NotDel%
	*/
		
	LEFT JOIN	%Table:SX5%	SX5 ON
	SX5.X5_TABELA   = %Exp:'13'%	AND
	SX5.X5_CHAVE    = SFT.FT_CFOP	AND
	SX5.%NotDel%		
	
	LEFT JOIN	%Table:SA2%	SA2 ON
	SA2.A2_COD      = SB6.B6_CLIFOR AND
	SA2.A2_LOJA     = SB6.B6_LOJA	AND
	SA2.%NotDel%
		
	LEFT JOIN	%Table:SA1%	SA1 ON
	SA1.A1_COD      = SB6.B6_CLIFOR	AND
	SA1.A1_LOJA     = SB6.B6_LOJA	AND
	SA1.%NotDel%
	%Exp:cVendedor%
			
	WHERE	SB6.B6_FILIAL = %xFilial:SB6%	AND		
	((SB6.B6_TPCF = %Exp:'C'% AND B6_CLIFOR >= %Exp:MV_PAR01%	AND B6_CLIFOR <= %Exp:MV_PAR02% )  OR
	( SB6.B6_TPCF = %Exp:'F'% AND B6_CLIFOR >= %Exp:MV_PAR03% 	AND B6_CLIFOR <= %Exp:MV_PAR04% )) AND
		
	SB6.B6_DTDIGIT >= %Exp:DTOS(MV_PAR05)%	AND
	SB6.B6_DTDIGIT <= %Exp:DTOS(MV_PAR06)%	AND
	SB6.B6_QUANT   <> 0						AND
   	SB6.B6_SALDO > 0 AND
	SB6.%NotDel%		
	%Exp:cTipo%  
		
	/*
	GROUP BY	SB6.B6_FILIAL,
	SB6.B6_TPCF,
	SB6.B6_CLIFOR,
	SB6.B6_LOJA,
	SB6.B6_DOC,
	SB6.B6_SERIE,
	SB6.B6_PRODUTO,
	SB6.B6_QUANT,
	//SF3.F3_CFO,
	//SF3.F3_EMISSAO,
	SFT.FT_CFOP,
	SFT.FT_EMISSAO,		
	SX5.X5_DESCRI,
	SA1.A1_NOME,
	SA2.A2_NOME  */
	//ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SF3.F3_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA
	ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SFT.FT_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA		
		
EndSql

	//Resultado da Query REMOVER DEPOIS DOS TESTES
	//_cResQry:= GETLastQuery()[2]
		

If (cAliasQry)->(!EoF())
	
	cQryArm := "% " + GetLastQuery()[2] + " %"
//	cQryArm := StrTran(cQryArm,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SF3.F3_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA","")
	cQryArm := StrTran(cQryArm,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SFT.FT_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA","")
	
	//-------------------------------------------------------
	//Contando total de registros da consulta
	//-------------------------------------------------------
	cQtdQuery := "% " + GetLastQuery()[2] + " %"
//	cQtdQuery := StrTran(cQtdQuery,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SF3.F3_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA","")
	cQtdQuery := StrTran(cQtdQuery,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SFT.FT_EMISSAO,SB6.B6_CLIFOR,SB6.B6_LOJA","")	
	
	BeginSql Alias "QTDQUERY"
		SELECT	COUNT(*) TOTAL
		FROM ( %Exp:cQtdQuery% ) TOTALREG
	EndSql
	
	nTotalDoc := QTDQUERY->TOTAL
	
	QTDQUERY->(DbCloseArea())
	//-------------------------------------------------------
	
	
	BeginSql Alias "SB6TMP"
		
		SELECT	SB6.*,
		SB6.R_E_C_N_O_ AS RECNO,
		SF4.F4_PODER3
		
		FROM	%Table:SB6%	SB6
		
		JOIN	%Table:SF4%	SF4	ON
		%Exp:cFilialSF4%
		SF4.F4_CODIGO  = SB6.B6_TES		AND
		SF4.F4_PODER3 <> %Exp:'D'%		AND
		SF4.%NotDel%
		
		WHERE	SB6.B6_FILIAL = %xFilial:SB6%	AND
		
		((SB6.B6_TPCF = %Exp:'C'% AND B6_CLIFOR >= %Exp:MV_PAR01%	AND B6_CLIFOR <= %Exp:MV_PAR02% )  OR
		( SB6.B6_TPCF = %Exp:'F'% AND B6_CLIFOR >= %Exp:MV_PAR03% 	AND B6_CLIFOR <= %Exp:MV_PAR04% )) AND
		
		SB6.B6_DTDIGIT >= %Exp:DTOS(MV_PAR05)%	AND
		SB6.B6_DTDIGIT <= %Exp:DTOS(MV_PAR06)%	AND
		SB6.B6_QUANT   <> 0						AND
		SB6.%NotDel%
		
		%Exp:cTipo%
		
		ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SB6.B6_DOC,SB6.B6_SERIE,SB6.B6_CLIFOR,SB6.B6_LOJA
		
	EndSql
	
	If SB6TMP->(!Eof())
		
		//-------------------------------------------------------
		//Contando total de registros da consulta
		//-------------------------------------------------------
		cQtdQuery := "% " + GetLastQuery()[2] + " %"
		cQtdQuery := StrTran(cQtdQuery,"ORDER BY SB6.B6_FILIAL,SB6.B6_TPCF,SB6.B6_DOC,SB6.B6_SERIE,SB6.B6_CLIFOR,SB6.B6_LOJA","")
		
		BeginSql Alias "QTDQUERY"
			SELECT	COUNT(*) TOTAL
			FROM ( %Exp:cQtdQuery% ) TOTALREG
		EndSql
		
		nTotalSld := QTDQUERY->TOTAL
		
		QTDQUERY->(DbCloseArea())
		//-------------------------------------------------------
		
		oReport:SetMsgPrint("Obtendo saldo das notas normais...")
		oReport:SetMeter(nTotalSld)
		
		
		While SB6TMP->(!EoF())
			
			cTpCliFor  := SB6TMP->B6_TPCF
			cDoc       := SB6TMP->B6_DOC
			cSerie     := SB6TMP->B6_SERIE
			cCliFor    := SB6TMP->B6_CLIFOR
			cLojCliFor := SB6TMP->B6_LOJA
							
			AAdd(aSaldosNF,{"","","","","",0,"","",0}) //TpCF,Doc,Serie,Clifor,Loja,Saldo,Produto,Descrição, Quantidade
			
			While SB6TMP->(!EoF()) .AND.	cTpCliFor  == SB6TMP->B6_TPCF 	.AND. ;
				cDoc       == SB6TMP->B6_DOC 	.AND. ;
				cSerie     == SB6TMP->B6_SERIE  .AND. ;
				cCliFor    == SB6TMP->B6_CLIFOR	.AND. ;
				cLojCliFor == SB6TMP->B6_LOJA
				
				
				aSaldo  := SB6TMP->(CalcTerc(B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_IDENT,B6_TES,,MV_PAR05,MV_PAR06))
				nSaldo  := aSaldo[1]
				nPrUnit := IIF(aSaldo[3]==0,SB6TMP->B6_PRUNIT,aSaldo[3])
				
				If Empty(ATail(aSaldosNF)[1])
					
					
					ATail(aSaldosNF)[1] := SB6TMP->B6_TPCF
					ATail(aSaldosNF)[2] := SB6TMP->B6_DOC
					ATail(aSaldosNF)[3] := SB6TMP->B6_SERIE
					ATail(aSaldosNF)[4] := SB6TMP->B6_CLIFOR
					ATail(aSaldosNF)[5] := SB6TMP->B6_LOJA
					
					ATail(aSaldosNF)[6] := nSaldo * nPrUnit
					
					
					ATail(aSaldosNF)[7] := SB6TMP->B6_PRODUTO
					ATail(aSaldosNF)[8] := (Posicione('SB1',1,xFilial('SB1')+SB6TMP->B6_PRODUTO,'B1_DESC'))
					ATail(aSaldosNF)[9] := SB6TMP->B6_QUANT
					
				Else
					ATail(aSaldosNF)[6] += nSaldo * nPrUnit					
				EndIf
				
				
				oReport:IncMeter()
				SB6TMP->(DbSkip())
			End
			
		End
		
		oReport:SetMsgPrint("Imprimindo documentos normais...")
		oReport:SetMeter(nTotalDoc)
		
		While !oReport:Cancel() .AND. !(cAliasQry)->(Eof())
			
			
			cTipoCF := (cAliasQry)->B6_TPCF
			nTotal  := 0
			
			If cTipoCF == "C"
				oSection1:Cell("NOME"):SetTitle("Cliente")
			Else
				oSection1:Cell("NOME"):SetTitle("Fornecedor")
			EndIf
			
			oSection1:Init()
			
			While !oReport:Cancel() .AND. cTipoCF == (cAliasQry)->B6_TPCF
				
				If oReport:Cancel()
					Exit
				EndIf
						
				//If AllTrim((cAliasQry)->F3_CFO) != "5908" .And. AllTrim((cAliasQry)->F3_CFO) != "6908"
				If AllTrim((cAliasQry)->FT_CFOP) != "5908" .And. AllTrim((cAliasQry)->FT_CFOP) != "6908"				
					
					nQtdSB6 := (cAliasQry)->B6_QUANT
					
					aSldPos  := (cAliasQry)->(CalcTerc(B6_PRODUTO,B6_CLIFOR,B6_LOJA,B6_IDENT,B6_TES,,mv_par07,mv_par08))
					nSldPos  := aSldPos[1]
			
					oSection1:Cell('B6_CLIFOR' ):SetValue((cAliasQry)->B6_CLIFOR  )
					oSection1:Cell('B6_LOJA'   ):SetValue((cAliasQry)->B6_LOJA    )
					oSection1:Cell('NOME'      ):SetValue((cAliasQry)->NOME       )
					oSection1:Cell('B6_DOC'    ):SetValue((cAliasQry)->B6_DOC     )
					oSection1:Cell('B6_SERIE'  ):SetValue((cAliasQry)->B6_SERIE   )
											
					oSection1:Cell('B6_PRODUTO'):SetValue((cAliasQry)->B6_PRODUTO )
					oSection1:Cell('B1_DESC'   ):SetValue(Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->B6_PRODUTO,'B1_DESC') )

					oSection1:Cell('B6_QUANT'  ):SetValue(nSldPos)  
					
					//oSection1:Cell('SALDO'     ):SetValue(nSldPos) 
							
					oSection1:Cell('TOTAL'     ):SetValue((cAliasQry)->TOTAL      )
				
					//oSection1:Cell('F3_EMISSAO'):SetValue((cAliasQry)->F3_EMISSAO )     
					oSection1:Cell('FT_EMISSAO'):SetValue(STOD((cAliasQry)->FT_EMISSAO ))
					//oSection1:Cell('DIASATRASO'):SetValue((dDatabase-(cAliasQry)->F3_EMISSAO) )
					oSection1:Cell('DIASATRASO'):SetValue((dDatabase-STOD((cAliasQry)->FT_EMISSAO)) )					
					//oSection1:Cell('F3_CFO'    ):SetValue((cAliasQry)->F3_CFO     )    
					oSection1:Cell('FT_CFOP'   ):SetValue((cAliasQry)->FT_CFOP    )					
					//oSection1:Cell('X5_DESCRI' ):SetValue((cAliasQry)->X5_DESCRI  )
					
					oSection1:PrintLine()
					//nTotal += (cAliasQry)->TOTAL
					
				EndIf
				
				oReport:IncMeter()
				(cAliasQry)->(DbSkip())
			End
		
			oSection1:Finish()
			
		End
	EndIf
	
	SB6TMP->(DbCloseArea())
	
EndIf

oReport:EndPage()

(cAliasQry)->(DbCloseArea())

Return


Static Function MsMdoFil(cAlias)
Local aSavArea := GetArea()
Local aModo := {"","",""}

//SX2->(dbSetOrder(1))
//If SX2->(dbSeek(cAlias))
//	aModo[1] := SX2->X2_MODO
//	aModo[2] := SX2->X2_MODOUN
//	aModo[3] := SX2->X2_MODOEMP
//EndIf
RestArea(aSavArea)
Return aModo