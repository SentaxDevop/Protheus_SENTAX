/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+
!Modulo            ! Financeiro                                              !
+------------------+---------------------------------------------------------+
!Nome              ! SENTAX_RFIN003                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Relatorio de titulos sem boleto                         !
+------------------+---------------------------------------------------------+
!Autor             ! Mário Lúcio Blasi Faria                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 26/03/2013                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 										    !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+ 
*/
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"

#DEFINE CRLF (chr(13)+chr(10))

User Function RFIN003() 

	Local oReport 
	               
	Private cPerg := padr("RFIN003",10)

	CriaSx1() 
	if !Pergunte(cPerg,.T.) 
		return .F.
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()  
        
Return   
     
/*
+------------+------------------------------------------------------------+
! Descricao  ! Rotina para criar a estrutura do relatorio Analítico       !
+------------+------------------------------------------------------------+
! Sintaxe    ! ReportDef()                                               !
+------------+------------------------------------------------------------+
! Parametros ! Nenhum                                                     !
+------------+------------------------------------------------------------+
*/   

Static Function ReportDef()
	Local cTitle	:= OemToAnsi ("Relação de titulos sem boleto.")  
	Local cHelp		:= OemToAnsi ("Permite gerar relatório de titulos sem boleto.")
	Local oReport             

	Local oTitulo

	Local oQtitulo
	Local cAlias  	:= getNextAlias()        
	
	oReport	:= TReport():New("RFIN003",cTitle,cPerg,{|oReport| RepPrint(oReport,cAlias)},cHelp)

	oTitulo := TRSection():New(oReport,"",{"SE1","SA1","SC5"})
	trCell():new(oTitulo,"E1_PREFIXO"	,"SE1","Prefixo"	,PesqPict("SE1","E1_PREFIXO")	,TamSx3("E1_PREFIXO")[1]+1)  
	trCell():new(oTitulo,"E1_NUM"		,"SE1","Número"		,PesqPict("SE1","E1_NUM")		,TamSx3("E1_NUM")[1]+1)   
	trCell():new(oTitulo,"E1_PARCELA"	,"SE1","Parcela"	,PesqPict("SE1","E1_PARCELA")	,TamSx3("E1_PARCELA")[1]+1)  	
	trCell():new(oTitulo,"E1_VALOR"		,"SE1","Valor"		,PesqPict("SE1","E1_VALOR")		,TamSx3("E1_VALOR")[1]+1) 	
	trCell():new(oTitulo,"A1_COD"		,"SA1","Cód.Cli."	,PesqPict("SA1","A1_COD")		,TamSx3("A1_COD")[1]+1)	
//	trCell():new(oTitulo,"A1_LOJA"		,"SA1","Lj.Cli."	,PesqPict("SA1","A1_LOJA")		,TamSx3("A1_LOJA")[1]+1)
	trCell():new(oTitulo,"A1_NOME"		,"SA1","Cliente"	,PesqPict("SA1","A1_NOME")		,41)
	trCell():new(oTitulo,"A1_XIMPBOL"	,"SA1","Imp.Bol."	,PesqPict("SA1","A1_XIMPBOL")	,8)
	trCell():new(oTitulo,"A1_XBCOBOL"	,"SA1","Bco.Bol."	,PesqPict("SA1","A1_XBCOBOL")	,TamSx3("A1_XBCOBOL")[1]+1)  
	trCell():new(oTitulo,"CONDPAG"		,""   ,"Cond.Pag."	,"!@"							,20)
	trCell():new(oTitulo,"E1_XFORMA"	,"SE1","Form.Pag."	,PesqPict("SE1","E1_XFORMA")	,TamSx3("E1_XFORMA")[1]+1)
	 
	oReport:SetTotalInLine(.F.)
	oTitulo:SetTotalInLine(.F.)
	
//	Totalizacao     
	trFunction():New(oTitulo:Cell("E1_VALOR"),"","SUM",,,,,.F.,.T.) 

Return (oReport)       

/*
+------------+--------------------------------------------------------------+
! Descricao  ! Rotina para impressão do relatorio                         	!
+------------+--------------------------------------------------------------+
! Sintaxe    ! RepPrint(oReport,cAlias)                                 	!
+------------+--------------------------------------------------------------+
! Parametros ! oReport: Estrutura do relatório                            	!
!            ! cAlias: Alias temporário                                     !
+------------+--------------------------------------------------------------+
*/                  
static function RepPrint(oReport,cAlias) 

	Local oTitulo 	:= oReport:Section(1)
	Local cQuery	:= "" 
	Local cCondPag	:= ""
	
	cQuery := "	SELECT " + CRLF 
	cQuery += "		DISTINCT(SE1.E1_PREFIXO), SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_VALOR, " + CRLF  
	cQuery += "		SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_XIMPBOL, SA1.A1_XBCOBOL, " + CRLF  
	cQuery += "		ISNULL(SC5.C5_CONDPAG + '-' + SE4.E4_DESCRI,'') CONDPAG, " + CRLF 
	cQuery += "		E1_XFORMA " + CRLF  
	cQuery += "	FROM " + RetSqlName("SE1") + " SE1 " + CRLF 
	cQuery += "	INNER JOIN " + RetSqlName("SA1") + " SA1 ON " + CRLF
	cQuery += "			SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
	cQuery += "		AND	SA1.A1_COD = SE1.E1_CLIENTE " + CRLF   
	cQuery += "		AND SA1.A1_LOJA = SE1.E1_LOJA " + CRLF
	cQuery += "		AND SA1.D_E_L_E_T_ <> '*' " + CRLF  
	cQuery += "	LEFT JOIN " + RetSqlName("SC5") + " SC5 ON " + CRLF 
	cQuery += "			SC5.C5_FILIAL = '" + xFilial("SC5") + "' " + CRLF  
	cQuery += "		AND SC5.C5_NUM = SE1.E1_PEDIDO " + CRLF   
 	cQuery += "		AND SC5.D_E_L_E_T_ <> '*' " + CRLF  
	cQuery += "	LEFT JOIN " + RetSqlName("SE4") + " SE4 ON " + CRLF 
	cQuery += "			SE4.E4_FILIAL = '" + xFilial("SE4") + "' " + CRLF  
	cQuery += "		AND SE4.E4_CODIGO = SC5.C5_CONDPAG " + CRLF  
	cQuery += "		AND SE4.D_E_L_E_T_ <> '*' " + CRLF 
	cQuery += "	WHERE " + CRLF   
	cQuery += "			SE1.E1_FILIAL = '" + xFilial("SE1") + "' " + CRLF 
	cQuery += "		AND SE1.E1_CLIENTE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' " + CRLF 
	cQuery += "		AND SE1.E1_LOJA BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' " + CRLF 
	cQuery += "		AND SE1.E1_EMISSAO BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' " + CRLF 
	cQuery += "		AND SE1.E1_VENCREA BETWEEN '" + DtoS(MV_PAR07) + "' AND '" + DtoS(MV_PAR08) + "' " + CRLF 
	cQuery += "		AND (SE1.E1_EMISSAO = SE1.E1_VENCTO OR SA1.A1_XIMPBOL <> 'S' OR SA1.A1_XBCOBOL = ' ' OR SE1.E1_XFORMA <> 'BOL') " + CRLF
	cQuery += "		AND SE1.D_E_L_E_T_ <> '*' " + CRLF   
	cQuery += "	ORDER BY SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA " + CRLF  

	Memowrite("c:\temp\RFIN003.txt",cQuery)

	oTitulo:BeginQuery()
	TcQuery cQuery New Alias (cAlias) 
	oTitulo:EndQuery()

	(cAlias)->(dbGoTop())
	nQtdReg := 0
	Count to nQtdReg
	(cAlias)->(dbGoTop())
	oReport:SetMeter(nQtdReg)
    
	oTitulo:init() 
	While !(cAlias)->(Eof()) .And. !oReport:Cancel()   
        
        oTitulo:Cell("E1_PREFIXO"):SetValue((cAlias)->E1_PREFIXO)
        oTitulo:Cell("E1_NUM"):SetValue((cAlias)->E1_NUM) 
        oTitulo:Cell("E1_PARCELA"):SetValue((cAlias)->E1_PARCELA) 
        oTitulo:Cell("E1_VALOR"):SetValue((cAlias)->E1_VALOR)
        oTitulo:Cell("A1_COD"):SetValue((cAlias)->A1_COD)
//		oTitulo:Cell("A1_LOJA"):SetValue((cAlias)->A1_LOJA)
        oTitulo:Cell("A1_NOME"):SetValue(SubStr((cAlias)->A1_NOME,1,40)) 
         
        Do Case
        	Case (cAlias)->A1_XIMPBOL == 'S'
        		cCondPag := "SIM"
        	Case (cAlias)->A1_XIMPBOL == 'N'
        		cCondPag := "NÃO"
 			OtherWise
 				cCondPag := ""	
        EndCase 
        
        oTitulo:Cell("A1_XIMPBOL"):SetValue(cCondPag)
        oTitulo:Cell("A1_XBCOBOL"):SetValue((cAlias)->A1_XBCOBOL)
		oTitulo:Cell("CONDPAG"):SetValue((cAlias)->CONDPAG)
		oTitulo:Cell("E1_XFORMA"):SetValue((cAlias)->E1_XFORMA)
        
		oTitulo:PrintLine()	
		
		(cAlias)->(dbSkip()) 
		oReport:IncMeter() 
    
    EndDo
	oTitulo:Finish()
	
return          

/*
+------------+------------------------------------------------------------+
! Descricao  ! Rotina para criação das perguntas do relatorio             !
+------------+------------------------------------------------------------+
! Sintaxe    ! CriaSx1()                                                  !
+------------+------------------------------------------------------------+
! Parametros ! Nenhum                                                     !
+------------+------------------------------------------------------------+
*/                
static function CriaSx1() 

	PutSx1(cPerg,"01","Cliente De?"	,"Cliente De?"	,"Cliente de?"	,"mv_ch1","C",06,0,0,"G","","SA1","","","mv_par01","","","","","","","","","","","","","","","","",{"Código do cliente"})
	PutSx1(cPerg,"02","Loja De?"	,"Loja De?"		,"Loja de?"		,"mv_ch2","C",02,0,0,"G","",""	 ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Loja do cliente"})  
	
	PutSx1(cPerg,"03","Cliente Até?","Cliente Até?"	,"Cliente Até?"	,"mv_ch3","C",06,0,0,"G","","SA1","","","mv_par03","","","","","","","","","","","","","","","","",{"Código do cliente"})
	PutSx1(cPerg,"04","Loja Até?"	,"Loja Até?"	,"Loja Até?"	,"mv_ch4","C",02,0,0,"G","",""	 ,"","","mv_par04","","","","","","","","","","","","","","","","",{"Loja do cliente"})
	  
	PutSx1(cPerg,"05","Data Emissão De?"	,"Data Emissão De?"		,"Data Emissão De?"		,"mv_ch5","D",08,0,0,"G","",""	 ,"","","mv_par05","","","","","","","","","","","","","","","","",{"Data de emissão"})
	PutSx1(cPerg,"06","Data Emissão Até?"	,"Data Emissão Até?"	,"Data Emissão Até?"	,"mv_ch6","D",08,0,0,"G","",""	 ,"","","mv_par06","","","","","","","","","","","","","","","","",{"Data de emissão"})

	PutSx1(cPerg,"07","Data Vencimento De?"	,"Data Vencimento De?"	,"Data Vencimento De?"	,"mv_ch7","D",08,0,0,"G","",""	 ,"","","mv_par07","","","","","","","","","","","","","","","","",{"Data de vencimento"})
	PutSx1(cPerg,"08","Data Vencimento Até?","Data Vencimento Até?"	,"Data Vencimento Até?"	,"mv_ch8","D",08,0,0,"G","",""	 ,"","","mv_par08","","","","","","","","","","","","","","","","",{"Data de vencimento"})

	
return