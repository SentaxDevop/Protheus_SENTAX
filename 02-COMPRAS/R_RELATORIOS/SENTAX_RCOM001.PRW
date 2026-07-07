#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCOM0011  ºAutor  ³Anderson Franco     º Data ³  30/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de conferência cega chamado no apos a inclusao   º±±
±±º          ³ da pre-nota                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Alteracoes Henrique Baldin        º  Data ³  30/09/13   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RCOM001() 
	Local oReport 
	               
  	Private cPerg := padr("RCOM001",10)
  /*
	CriaSx1() 
	if !Pergunte(cPerg,.T.) 
		return .F.
	EndIf
    */
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
	Local cTitle	:= OemToAnsi ("Relação de itens da NF de entrada.")  
	Local cHelp		:= OemToAnsi ("Permite gerar relatório de itens para conferência cega.")
	Local oReport             

    Local oSection
	Local oPreNFi

	Local oQtitulo
	Local cAlias  	:= getNextAlias()        
	Local oSection
   	Local oSection1
	
                            
	oReport	:= TReport():New("RCOM001",cTitle,""      ,{|oReport| RepPrint(oReport)},cHelp) 
	oReport:SetPortrait()   
	
	//Section do cabeçalho do relatório  que contem dados do cabçalho da nota
 	oSection  := TRSection():New(oReport,"Nota",{"SF1"})
 	TRCell():New(oSection,"F1_DTDIGIT","SF1","DT_DIGIT  ")
 	TRCell():New(oSection,"F1_DOC",    "SF1","DOCUMENTO  ")
	TRCell():New(oSection,"F1_SERIE",  "SF1"," SERIE ")
	TRCell():New(oSection,"F1_FORNECE","SF1","FORNECEDOR ","",30) 
 
	
	//Section do Corpo do relatório onde contem os itens
   	oSection1 := TRSection():New(oSection,"ITENS","SD1")
	trCell():new(oSection1,"D1_ITEM"	,"SD1","Item"	   ,PesqPict("SD1","D1_ITEM") ,TamSx3("D1_ITEM")[1]+1 )  
	trCell():new(oSection1,"D1_COD"	    ,"SD1","Código"	   ,PesqPict("SD1","D1_COD")  ,TamSx3("D1_COD")[1]+1 )   
    trCell():new(oSection1,"B1_DESC"    ,"SB1","Descrição" ,PesqPict("SB1","B1_DESC") ,TamSx3("B1_DESC")[1]+1 )  	
//   	trCell():new(oSection1,"B1_DESC"    ,"SB1","Descrição" ,PesqPict("SB1","B1_DESC") ,30 )  	
	trCell():new(oSection1,"D1_UM"	    ,"SD1","UN"		   ,PesqPict("SD1","D1_UM")	  ,TamSx3("D1_UM")[1]+1 ) 	
	trCell():new(oSection1,"QTDE"		,""   ,"Qtde"	   ,""		                  ,10,,{|| cQtde})	
	  
	oReport:SetTotalInLine(.F.)
	
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
static function RepPrint(oReport) 

	Local oSection  := oReport:Section(1)
	Local oSection1 := oSection:Section(1)
	Local _cQuery	:= getnextAlias() 
	Local cFornece  :=" "    

	BeginSql Alias _cQuery 
	SELECT SF1.F1_FILIAL,SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_FORNECE,SF1.F1_LOJA, SF1.F1_EMISSAO,
	substring( SF1.F1_DTDIGIT ,7,4)+'/'+substring(SF1.F1_DTDIGIT ,5,2)+'/'+substring(SF1.F1_DTDIGIT ,1,4) as F1_DTDIGIT, 
	SD1.D1_ITEM,SD1.D1_COD,SB1.B1_DESC,SD1.D1_UM,'______________' QTDE,A2_NREDUZ
	FROM %Table:SF1% SF1 
	 INNER JOIN %Table:SD1% SD1 ON
	            SD1.%NotDel% AND
	            SD1.D1_FILIAL = SF1.F1_FILIAL AND
	            SD1.D1_DOC = SF1.F1_DOC AND 
	            SD1.D1_SERIE = SF1.F1_SERIE AND
                SD1.D1_FORNECE = SF1.F1_FORNECE AND
               	SD1.D1_LOJA  =  SF1.F1_LOJA 
	INNER JOIN  %Table:SB1% SB1 ON   
            	SB1.B1_FILIAL  = %xFilial:SB1% AND 
				SB1.%NotDel% AND 
				SB1.B1_COD = SD1.D1_COD 
	INNER JOIN  %Table:SA2% SA2 ON 
            	SA2.A2_FILIAL  = %xFilial:SA2% AND 
				SA2.%NotDel% AND 
				SA2.A2_COD = SF1.F1_FORNECE AND 
				SA2.A2_LOJA = SF1.F1_LOJA			
	WHERE                                                    
	SF1.%NotDel%  AND 
	SF1.F1_FILIAL = %Exp:SF1->F1_FILIAL% AND 
	SF1.F1_DOC = %Exp:SF1->F1_DOC%  AND 
	SF1.F1_SERIE = %Exp:SF1->F1_SERIE%  AND
	SF1.F1_FORNECE = %Exp:SF1->F1_FORNECE%  AND     
	SF1.F1_LOJA = %Exp:SF1->F1_LOJA%     
	ORDER BY SD1.D1_ITEM
	EndSql
    (_cQuery)->(dbGoTop())
   /*	nQtdReg := 0
	Count to nQtdReg
	(_cQuery)->(dbGoTop())
	oReport:SetMeter(nQtdReg) */
     cFornece := (_cQuery)->F1_FORNECE +"-"+(_cQuery)->F1_LOJA +" "+(_cQuery)->A2_NREDUZ            
	oSection:init()      
	oSection:Cell("F1_DTDIGIT"):SetValue((_cQuery)->F1_DTDIGIT)
	oSection:Cell("F1_DOC"):SetValue((_cQuery)->F1_DOC)
    oSection:Cell("F1_SERIE"):SetValue((_cQuery)->F1_SERIE) 
	oSection:Cell("F1_FORNECE"):SetValue(cFornece)     
	oSection:PrintLine()         
	
	oSection1:init() 
     	oSection1:Cell("D1_ITEM"):SetValue("")
        oSection1:Cell("D1_COD"):SetValue("" ) 
        oSection1:Cell("B1_DESC"):SetValue("" ) 
        oSection1:Cell("D1_UM"):SetValue("" )
        oSection1:Cell("QTDE"):SetValue("" )      
       	oSection1:PrintLine()
 		oReport:IncMeter() 
    	oReport:SkipLine()
	While !(_cQuery)->(Eof()) .And. !oReport:Cancel()   
        
        oSection1:Cell("D1_ITEM"):SetValue((_cQuery)->D1_ITEM)
        oSection1:Cell("D1_COD"):SetValue((_cQuery)->D1_COD) 
        oSection1:Cell("B1_DESC"):SetValue((_cQuery)->B1_DESC) 
        oSection1:Cell("D1_UM"):SetValue((_cQuery)->D1_UM)
        oSection1:Cell("QTDE"):SetValue((_cQuery)->QTDE)     


		oSection1:PrintLine()	
		
		(_cQuery)->(dbSkip())
		oReport:IncMeter() 
    	oReport:SkipLine() 
    
    EndDo
	oSection1:Finish()
	oSection:Finish()
	
	 
	
return          

