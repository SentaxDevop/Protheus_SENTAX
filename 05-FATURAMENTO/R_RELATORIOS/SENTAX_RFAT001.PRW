#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"                                                                                                               
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'    
/*/{Protheus.doc}  
Relatório de NFS com itens separados para expedição, mas não expedidas
@author  Anderson Roberto Franco de Souza
@since   04/10/2013
@return  
/*/    

User Function RFAT001() 
	Local oReport 
    Local aPergs   := {} 	               
  	Private cPerg := padr("RFAT001",10)
  	
  //Pergunte(cPerg,.T.)
    MV_PAR01:=doctos()
	oReport := ReportDef()
	oReport:PrintDialog()  
        
Return   

*--------------------------------------------------------------------
STATIC FUNCTION doctos()
LOCAL oDLG,bOK,bCANCEL,aBUTTONS,cRET
*
cRET     := Space(500)
bOK      := {|| nBTOP := 1,oDLG:END()}
bCANCEL  := {|| nBTOP := 0,oDLG:END()}
aBUTTONS := {}

DEFINE MSDIALOG oDLG TITLE "Notas Fiscais não expedidas" FROM 0,0 TO 125,960 OF oMainWnd PIXEL 
  @ 30,010 SAY "Informe as NF's e Série:" PIXEL OF oDLG
  @ 40,010 MSGET cRet SIZE 400,010  PIXEL OF oDLG
ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED

RETURN(cRET)     
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
	Local cTitle	:= OemToAnsi ("Relação de NFs emitidas e não expedidas")  
	Local cHelp		:= OemToAnsi ("Permite gerar relatório das Notas e itens consolidados.")
	Local oReport             

    Local oSection
	Local oPreNFi

	Local oQtitulo
	Local cAlias  	:= getNextAlias()        
	Local oSection
   	Local oSection1
	
                            
	oReport	:= TReport():New("RFAT001",cTitle,""      ,{|oReport| RepPrint(oReport)},cHelp) 
	oReport:SetPortrait()   
	
	//Section do cabeçalho do relatório  que contem dados do cabçalho da nota
 	oSection  := TRSection():New(oReport,"Nota",{"SF1"})
 	TRCell():New(oSection,"F2_DOC",    "SF2","DOCUMENTO  ")
	TRCell():New(oSection,"F2_SERIE",  "SF2"," SERIE ")
	TRCell():New(oSection,"F2_CLIENTE","SF2","CLIENTE","",30) 
 
	
	//Section do Corpo do relatório onde contem os itens
   	oSection1 := TRSection():New(oSection,"ITENS","SD2")
	trCell():new(oSection1,"D2_COD"	    ,"SD2","Código"	   ,PesqPict("SD2","D2_COD")  ,TamSx3("D2_COD")[1]+1 )   
    trCell():new(oSection1,"B1_DESC"    ,"SB1","Descrição" ,PesqPict("SB1","B1_DESC") ,TamSx3("B1_DESC")[1]+1 )  	
	trCell():new(oSection1,"D2_UM"	    ,"SD2","UM"		   ,PesqPict("SD2","D2_UM")	  ,TamSx3("D2_UM")[1]+1 ) 	
	trCell():new(oSection1,"D2_QUANT"	,"SD2","Qtde"      ,PesqPict("SD2","D2_QUANT"),TamSx3("D2_QUANT")[1]+1 )
	  
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
Local cCliente  :=" "    
  
//Local 	cLista:="(" + CriaIn(Alltrim(MV_PAR01)) +")"
Local 	cLista:=CriaIn(Alltrim(MV_PAR01))
If cLista == '()'
	cLista := "('')"
Endif        

BeginSql Alias _cQuery 
	SELECT SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA, SA1.A1_NOME,SD2.D2_COD,SB1.B1_DESC,SD2.D2_UM,SD2.D2_QUANT 
	FROM %Table:SF2% SF2
	INNER JOIN SD2010 SD2 
	ON
	SD2.%NotDel% AND   
	SD2.D2_FILIAL=%xFilial:SD2% AND 
	SF2.F2_FILIAL = SD2.D2_FILIAL AND
	SF2.F2_DOC = SD2.D2_DOC AND
	SF2.F2_SERIE = SD2.D2_SERIE
	INNER JOIN %Table:SA1% SA1
	ON
	SA1.%NotDel% AND    
	SA1.A1_FILIAL=%xFilial:SA1% AND 	
	SA1.A1_COD = SF2.F2_CLIENTE AND 
	SA1.A1_LOJA = SF2.F2_LOJA
	INNER JOIN %Table:SB1% SB1
	ON
	SB1.%NotDel% AND  
	SB1.B1_FILIAL=%xFilial:SB1% AND 	
	SB1.B1_COD = SD2.D2_COD 
	WHERE SF2.D_E_L_E_T_ = ' ' AND 
	SF2.F2_FILIAL=%xFilial:SF2% AND 
	SF2.F2_DOC + SF2.F2_SERIE IN (%Exp:cLista%)
	ORDER BY SF2.F2_DOC, SF2.F2_SERIE
EndSql
(_cQuery)->(dbGoTop())
               
	oSection:init()      
    cCliente:=""   
    cDoc:=""  
    cSerie:=""
	While !(_cQuery)->(Eof()) .And. !oReport:Cancel() 
	    If cDoc != (_cQuery)->F2_DOC .OR. cSerie != (_cQuery)->F2_SERIE	
	 		cCliente := (_cQuery)->F2_CLIENTE +"-"+(_cQuery)->F2_LOJA +" "+(_cQuery)->A1_NOME 	
	 		oSection:Cell("F2_DOC"):SetValue((_cQuery)->F2_DOC)
	        oSection:Cell("F2_SERIE"):SetValue((_cQuery)->F2_SERIE) 
	     	oSection:Cell("F2_CLIENTE"):SetValue(cCliente)     
			oSection:PrintLine()   
			cDoc:= (_cQuery)->F2_DOC 
			cSerie:= (_cQuery)->F2_SERIE                                                            
	    Endif
		(_cQuery)->(dbSkip()) 
	End       
   	(_cQuery)->(dbCloseArea())  	
//********
BeginSql Alias _cQuery 
	SELECT SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA, SA1.A1_NOME,SD2.D2_COD,SB1.B1_DESC,SD2.D2_UM,SD2.D2_QUANT 
	FROM %Table:SF2% SF2
	INNER JOIN SD2010 SD2 
	ON
	SD2.%NotDel% AND   
	SD2.D2_FILIAL=%xFilial:SD2% AND 
	SF2.F2_FILIAL = SD2.D2_FILIAL AND
	SF2.F2_DOC = SD2.D2_DOC AND
	SF2.F2_SERIE = SD2.D2_SERIE
	INNER JOIN %Table:SA1% SA1
	ON
	SA1.%NotDel% AND    
	SA1.A1_FILIAL=%xFilial:SA1% AND 	
	SA1.A1_COD = SF2.F2_CLIENTE AND 
	SA1.A1_LOJA = SF2.F2_LOJA
	INNER JOIN %Table:SB1% SB1
	ON
	SB1.%NotDel% AND  
	SB1.B1_FILIAL=%xFilial:SB1% AND 	
	SB1.B1_COD = SD2.D2_COD 
	WHERE SF2.D_E_L_E_T_ = ' ' AND 
	SF2.F2_FILIAL=%xFilial:SF2% AND 
	SF2.F2_DOC + SF2.F2_SERIE IN (%Exp:cLista%)
	ORDER BY SD2.D2_COD
EndSql
//********
	(_cQuery)->(dbGoTop())

	oSection1:init() 
   
 	oReport:IncMeter() 
	oReport:SkipLine()
	While !(_cQuery)->(Eof()) .And. !oReport:Cancel()   
	    _cCod:= (_cQuery)->D2_COD    
	    _cDesc:= (_cQuery)->B1_DESC
	    _cUm:= (_cQuery)->D2_UM
	    _nQtdade:= 0    
	    
	 	While !(_cQuery)->(Eof()).And. _cCod == (_cQuery)->D2_COD .And. !oReport:Cancel()   
	 	   _nQtdade+=(_cQuery)->D2_QUANT    
	 	   	(_cQuery)->(dbSkip())
        End
        oSection1:Cell("D2_COD"):SetValue(_cCod) 
        oSection1:Cell("B1_DESC"):SetValue(_cDesc) 
        oSection1:Cell("D2_UM"):SetValue(_cUm)
        oSection1:Cell("D2_QUANT"):SetValue(_nQtdade)     

		oSection1:PrintLine()	
	
		oReport:IncMeter() 
          
    EndDo
	oSection1:Finish()
	oSection:Finish()
	(_cQuery)->(dbCloseArea())  	
return          


Static Function Criain(_cValue)
Local _cIn      := ""
Local _nCount   := 1
Local _nlen		:= 0
Local _cval     := ""
Local _aResult  := {}
Local i
_cValue:=Upper(_cValue)
_nlen:=Len(alltrim(_cValue))
For i:=1 To _nlen
	_cval:=Substr(alltrim(_cValue),i,1)
	if !((_cval >="0" .and. _cval <="9") .or. (_cval >="A" .and. _cval <="Z"))
		if (i-_nCount) > 0
			aadd(_aResult,{Substr(alltrim(_cValue),_nCount,(i-_nCount))})
		endif
		_nCount:=i+1
	elseif i ==_nlen
		aadd(_aResult,{Substr(alltrim(_cValue),_nCount,_nlen)})
	endif
Next i
For i:=1 to len(_aResult)
	if (len(_aResult)  == 1) .or. (i==len(_aResult))
		_cIn+="'"+_aResult[i,1]+"'"
		
	elseif len(_aResult) > 1
		_cIn+="'"+_aResult[i,1]+"',"
	endif
Next i     
_cIn:=Substr(_cIn,2,Len(_cIN)) 
_cIn:=Substr(_cIn,1,Len(_cIN)-1)
return (_cIn)