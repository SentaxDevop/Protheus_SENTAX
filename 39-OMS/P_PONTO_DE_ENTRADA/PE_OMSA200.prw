#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} OM200FIM
Ponto de entrada no final do carregamento.

@return 	lógico
@author 	Alessandro Smaha
@since 	 	18/03/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function OM200FIM()

	lWMS := GetNewPar("ST_APIWMS",.F.)
    
	fAtuTransp() 

	If ExistBlock("RFAT002")
		fBuscaAt( DAK->DAK_FILIAL, DAK->DAK_COD, DAK->DAK_SEQCAR ) 
	EndIf

	If lWMS
		//LAYZE FUZINATO
        Processa({|| U_fExpIteX('E')}, "Processando") 
		MsgInfo('Carga :'+DAI->DAI_COD+' gerada com sucesso!!') 
	End
	
Return 

//Layze Fuzinato - 15/09/2021
User Function OM200US()

Private aRotina:= PARAMIXB

aadd(aRotina,{'WMS - Separar', "Processa({|| U_fExpIteX('E')}, 'Processando')" , 0 , 2,0,NIL})


Return aRotina 



//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuTransp
Atualiza a transportadora caso o usuário confirme

@return 	lógico
@author 	Alessandro Smaha
@since 	 	18/03/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuTransp()
	              
	Local cPedAtu := ""
	Local nOpcx    := 0
	Local cCarga   := DAK->DAK_COD 
	Local cSeqCar  := DAK->DAK_SEQCAR
	Local aButtons := {}
	Local cTransp
	Local oGetCdTr
	Local oGetNmTr 
	Local oCancel 
	Local oOK
	Local cGetCdTr  := Space(TamSx3("C5_TRANSP")[1])  
	Local cGetNmTr  := Space(TamSx3("A4_NOME")[1])
	Local cParTrans := Alltrim(SuperGetMv("ST_XTRANSP", .T.,""))   
	
	Static oDlg   

	cQuery := " SELECT C9_FILIAL, C9_PEDIDO, C5_TRANSP " 
	cQuery += " FROM " + RetSQLName("SC9")+" SC9 "
	cQuery += " LEFT JOIN "+RetSQLName("SC5")+" SC5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cQuery += " 	AND C9_CARGA = '"+cCarga+"' "
	cQuery += " 	AND SC9.D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY C9_FILIAL, C9_PEDIDO, C5_TRANSP "
			
	cQuery := ChangeQuery(cQuery)
	
	If ( SELECT("TRB") ) > 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TRB" 
	
	DbSelectArea("TRB")	  
	TRB->(DbGoTop())

	If ( MsgYesNo(	"Deseja inFormar a transportadora para o(s) pedido(s) que não estão preenchidas para a carga "+cCarga+"?",;
					"Transportadora / Pedidos") )
	
		DEFINE MSDIALOG oDlg TITLE "Transportadora" FROM 000, 000  TO 120, 320 COLORS 0, 16777215 PIXEL
			
			@ 010, 007 SAY cTransp  PROMPT "Código:"  SIZE 020, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 025, 007 SAY cNomeTr  PROMPT "Nome:"    SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL       
			
			@ 007, 029 MSGET oGetCdTr VAR cGetCdTr    SIZE 032, 010 OF oDlg VALID fValidCpo(cGetCdTr,@cGetNmTr,@oGetNmTr) COLORS 0, 16777215 F3 "SA4" HASBUTTON PIXEL
			@ 022, 029 MSGET oGetNmTr VAR cGetNmTr    SIZE 125, 010 OF oDlg COLORS 0, 16777215 WHEN .F. HASBUTTON PIXEL 
			
			@ 042, 070 BUTTON oCancel PROMPT "Cancel" SIZE 037, 012 OF oDlg ACTION {|| nOpcx := 0, oDlg:End() } PIXEL
			@ 042, 115 BUTTON oOK     PROMPT "Ok"     SIZE 038, 012 OF oDlg ACTION {|| nOpcx := 1, oDlg:End() } PIXEL
			
		ACTIVATE MSDIALOG oDlg CENTERED
					
	EndIf 
	
	If nOpcx == 0
		cGetCdTr := cParTrans 
	EndIf

	cPedAtu := ""
	 
	If !Empty(cGetCdTr)  
		
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM  
		
		TRB->(DbGoTop())
		
		While !TRB->(Eof())
		
			If SC5->(DbSeek(xFilial("SC5")+TRB->C9_PEDIDO))  
			
		    	If Empty(SC5->C5_TRANSP) 
		    	
		    		RecLock("SC5",.F.)
				   		SC5->C5_TRANSP := cGetCdTr 
					SC5->(MsUnLock())
					
		    		cPedAtu += IIF(Empty(cPedAtu),"",", ")+SC5->C5_NUM 
		    		
				EndIf 
						
			EndIf    
			
			TRB->(DbSkip())
			
		Enddo  
		
	EndIf     
		
	If !Empty(cPedAtu)
		MsgInfo("O(s) pedido(s) Foram alterados para transportadora "+cGetCdTr+" para a carga "+cCarga+"!")
	EndIf
	
Return   


//-------------------------------------------------------------------
/*/{Protheus.doc} fValidCpo
Validação para a transportadora inFormada

@return 	lógico
@author 	Alessandro Smaha
@since 	 	18/03/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fValidCpo(cCodTran,cNomeTran,oNomeTran)

	Local lRetOK := .T.

	If !Empty(cCodTran)

		DbSelectArea("SA4")
		SA4->(DbSetOrder(1))
		If !SA4->(DbSeek(xFilial("SA4")+cCodTran))		   	
	   		MsgAlert("Tranportadora "+cCodTran+" não encontrada!","Atenção")
	   		lRetOK := .F. 
	   	Else
	   		cNomeTran := SA4->A4_NOME	
		EndIf 
		
	Else 
	
		MsgAlert("Tranportadora não pode ser vazio!","Atenção")   
		lRetOK := .F.
	
	EndIf  
	
	oNomeTran:Refresh()

Return                  


//-------------------------------------------------------------------
/*/{Protheus.doc} OS200EST
Ponto de entrada antes da efetivação no estorno da carga

@return 	lógico
@author 	Alessandro Smaha
@since 	 	27/03/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function OS200EST()
     
	Local cCarga := "" 
	Local cItemc := ""
	Local lRetOk := .T.
		
	// Rotina para limpar campo da transportadora no pedido de venda
	If FunName() == "OMSA200"	
	
		cCarga := PARAMIXB[1]
		cItemc := PARAMIXB[2] 
		
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
		
		DbSelectArea("DAI")
		DAI->(DbSetOrder(1)) // DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
		If DAI->(DbSeek(xFilial("DAI")+cCarga+cItemc))  
		
			While DAI->(!Eof()) .AND. xFilial("DAI") == DAI->DAI_FILIAL .AND. cCarga  == DAI->DAI_COD .AND. cItemc == DAI->DAI_SEQCAR
			    
			    If SC5->(DbSeek(xFilial("SC5")+DAI->DAI_PEDIDO))   
			        
			    	RecLock("SC5",.F.)
				   		SC5->C5_TRANSP := Space(TamSx3("C5_TRANSP")[1])
					SC5->(MsUnLock())
			    
			    EndIf
			
				DAI->(DbSkip()) 
				
			EndDo
		
		EndIf
	
	EndIf

Return lRetOk

//-------------------------------------------------------------------
/*/{Protheus.doc} OM200QRY
Ponto de entrada para alterar a query de seleção de pedidos para 
montar a carga.
Utilizado para filtrar pedidos com bloqueio e com transportadora.

@return 	cRet	 Query de seleção 
@param 		PARAMIXB  	[1] Query padrão,
						[2] Array com os tipos de carga
   
@author 	Thiago Henrique dos Santos
@since 	 	01/09/2014
@version 	P11

/*/
//-------------------------------------------------------------------	
User Function OM200QRY()

	Local cRet := PARAMIXB[1]

	cRet += " AND SC6.C6_NUM NOT IN ("+;
			" SELECT SC6TMP.C6_NUM FROM "+RetSqlName("SC6")+" SC6TMP "+;
			" WHERE SC6TMP.C6_FILIAL = SC6.C6_FILIAL AND SC6TMP.C6_NUM = SC6.C6_NUM AND SC6TMP.D_E_L_E_T_ <> '*' "+;
			" AND SC6TMP.C6_ITEM NOT IN ("+;
			" SELECT SC9TMP.C9_ITEM FROM "+RetSqlName("SC9")+" SC9TMP "+;	
			" WHERE SC9TMP.C9_PEDIDO = SC6TMP.C6_NUM "+;
			" AND SC9TMP.C9_ITEM = SC6TMP.C6_ITEM"+;
			" AND SC9TMP.C9_QTDLIB = SC6TMP.C6_QTDVEN"+;
			" AND SC9TMP.C9_BLCRED = '" + Space(TamSx3("C9_BLCRED")[1])+"' "+;
			" AND SC9TMP.C9_BLEST = '" + Space(TamSx3("C9_BLEST")[1])+"' "+;
			" AND SC9TMP.D_E_L_E_T_ <> '*') "+;
			") "
	//cRet += " AND SC6.C6_TES != '"+ GetMv('ST_TESFTSE') +"' "

	U_AOMS006(cRet)
			 	  
Return cRet
      
//--------------------------------------------------------------------------------------
/*/{Protheus.doc} OM200TPC
Ponto de entrada antes da montagem do array de pedidos para montar cargas, 
permite selecionar os pedidos que serão exibidos.

@author  Leandro Natan Bonette Santos
@since 	 18/10/2016
@return  lRet - Se .T. permite o item, .F. caso contrário

/*/
//--------------------------------------------------------------------------------------
User Function OM200TPC()

	//Retorna sempre .T. para desconsiderar o preenchimento do campo B1_TIPCAR
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OM200OK
Ponto de entrada para validar montagem de carga.
Utilizado para não permitir pedidos de serviço e produto em uma mesma carga.

@return 	lRet - Se .T. permite montagem, .F. caso contrário
@author 	Thiago Henrique dos Santos

@since 	 	01/09/2014

@version 	P11    

/*/
//-------------------------------------------------------------------

User function OM200OK()
Local aArea	 	:= GetArea()
Local lRet 		:= fVldTes()

If lRet

	lRet := ValItemPed()

Endif

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldTrans
Função para validar se as Tes utilizadas nos pedidos que estao compondo a carga sao compativeis 

@return 	lógico
@author 	Henrique baldin
@since 	 	25/06/2014
@version 	P11
/*/
//-------------------------------------------------------------------	
Static Function fVldTes()

Local lRetOk := .T.
Local cTes     := GetMV("ST_TESSERC",,"524")        
Local cPed     := "Não é permitido selecionar pedidos com TES de serviço e com TES de produto em uma mesma carga. "
Local lTesServ := .F.  
Local cPedSer  := "Pedidos com TES de Serviço : "
Local lTesVend := .F.
Local cPedVend := "Pedidos com TES de Produto : "
Local aTesS    := {}
Local aAreaSC6 := SC6->(GetArea())
Local i	:= 0
                                    
For i:= 1 to len(PARAMIXB[1])

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbSeek( PARAMIXB[1,i,12] + PARAMIXB[1,i,5]))  
	While ( SC6->(!Eof()) .AND. SC6->C6_FILIAL == PARAMIXB[1,i,12]  .AND. SC6->C6_NUM == PARAMIXB[1,i,5] )		
	
		AAdd(aTesS,{SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_TES})
		
	    SC6->(DbSkip())
	 EndDo
next i   

For i := 1 To Len(aTesS) 
	If aTesS[i,3] $ cTes
		lTesServ := .T. 
		If ! (aTesS[i,2] $ cPedSer) 
			cPedSer  +=  CRLF + aTesS[i,2]
		Endif  
	Else
		lTesVend := .T.
		If ! (aTesS[i,2] $ cPedVend)
			cPedVend  +=  CRLF + aTesS[i,2]
		Endif 
	EndIf
next i


If lTesServ .AND. lTesVend
	lRetOk := .F.
    Aviso("Carga Bloqueada", cPed +CRLF +cPedSer+CRLF +cPedVend ,{"OK"},3)
endif	

SC6->(RestArea(aAreaSC6))

	
Return lRetOk


//-------------------------------------------------------------------
/*/{Protheus.doc} ValItemPed
Valida se todos itens de determinado pedido Forma selecionados 

@return 	Se .T., valida item, .F. caso contrário
@author 	Thiago Henrique dos Santos
@since 	 	25/06/2014
@version 	P11
/*/
//-------------------------------------------------------------------	
Static Function ValItemPed()
Local lRet 		:= .T.
Local aAreaTRB 	:= TRBPED->(GetArea())
Local nI 		:= 1 
Local aPed 		:= {}
Local cPed 		:= ""
Local aParamB	:=  PARAMIXB[1] //{ aArrayMan, aArrayCarga, nPosCarga}
Local __cPed 	:= ""
Local __cFil 	:= ""
Local cQry 		:= ""
Local cAliasB1	:= GetNextAlias()
Local cCRLF		:= CRLF
Local cItem 	:= "PEDIDO  PRODUTO" + cCRLF

TRBPED->(DbSetOrder(1))

For nI:= 1 To Len(PARAMIXB[1])

		
	TRBPED->(DbSeek( PARAMIXB[1,nI,12] + PARAMIXB[1,nI,5]))
	  
	While ( TRBPED->(!Eof()) .AND. TRBPED->PED_FILORI + TRBPED->PED_PEDIDO == PARAMIXB[1,nI,12]+PARAMIXB[1,nI,5] )

		__cPed 	:=  TRBPED->PED_PEDIDO + "/"

		If Empty(TRBPED->PED_MARCA) .AND. AScan(aPed,{|x|x == TRBPED->PED_PEDIDO}) < 1	
			AAdd(aPed,TRBPED->PED_PEDIDO)
			lRet := .F.
		Endif
		
	    TRBPED->(DbSkip())
	    
	EndDo

Next nI

/*
__cPed := Substr(__cPed,1,Len( Alltrim(__cPed) ) - 1 )

If !lRet
	For nI := 1 to len(aPed)
	
		cPed += CRLF+aPed[nI]
	
	Next

	 Aviso("Carga Bloqueada","Não é permitido a geração de carga parcial de pedidos de venda." +CRLF+;
	 							"Verifique os seguintes pedidos parcialmente selecionados: "+cPed ,{"OK"},3)
	 
Endif


If lRet 

	cQry := " SELECT C6_FILIAL, C6_NUM,C6_PRODUTO,B1_DESC "
	cQry += " FROM SC6010 SC6 "
	cQry += " INNER JOIN SB1010 SB1 ON SB1.B1_COD = SC6.C6_PRODUTO AND SB1.D_E_L_E_T_ = '' AND SB1.B1_TIPCAR = '' "
	cQry += " WHERE SC6.D_E_L_E_T_ = '' "
	cQry += " AND SC6.C6_FILIAL = '"+xFilial("SC6")+"'"
	cQry += " AND SC6.C6_NUM IN "+ FormatIn(__cPed,"/") +""

	TCQuery cQry New Alias (cAliasB1)

	DBSelectArea((cAliasB1))
	(cAliasB1)->(DbGoTop())

	While !(cAliasB1)->(EOF())
		lRet := .f.
		
		cItem += (cAliasB1)->C6_NUM + " " + Alltrim((cAliasB1)->C6_PRODUTO)

		(cAliasB1)->(DbSkip())
	EndDo

	If !lRet
		MsgInfo(cItem)
	EndIf

EndIf 
*/

TRBPED->(RestArea(aAreaTRB))

Return lRet

                      
//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaAt
Rotina para verificar endereços diferentes
                
@sample		fBuscaAt( cFilDAK, cCarDAK, cSeqDAK )

@author		Alessandro Smaha
@since		22/04/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fBuscaAt( cFilDAK, cCarDAK, cSeqDAK )

Local cQuery	:= "" 
Local cPedsVen	:= ""
 
If (Select("TQRY") <> 0)		
	DbSelectArea("TQRY")
	TQRY->(DbCloseArea())		
Endif

cQuery := " SELECT UB_FILIAL, UB_NUMPV "
cQuery += " FROM "+RetSQLName("DAK")+" DAK " 
cQuery += " INNER JOIN "+RetSQLName("DAI")+" DAI ON DAI_FILIAL = DAK_FILIAL " 
cQuery += " 	AND DAI_COD = DAK_COD " 
cQuery += " 	AND DAI_SEQCAR = DAK_SEQCAR " 
cQuery += " 	AND DAI.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+RetSQLName("SUB")+" SUB ON UB_FILIAL = DAK_FILIAL "
cQuery += " 	AND UB_NUMPV = DAI_PEDIDO "
cQuery += " 	AND SUB.D_E_L_E_T_ <> '*' "	
cQuery += " INNER JOIN "+RetSQLName("SUA")+" SUA ON UA_FILIAL = UB_FILIAL "
cQuery += " 	AND UA_NUM = UB_NUM "
cQuery += " 	AND UA_XENDDIF = '2' "
cQuery += " 	AND SUA.D_E_L_E_T_ <> '*' "	
cQuery += " WHERE DAK_FILIAL = '"+cFilDAK+"' " 
cQuery += " 	AND DAK_COD = '"+cCarDAK+"' " 
cQuery += " 	AND DAK_SEQCAR = '"+cSeqDAK+"' " 
cQuery += " 	AND DAK.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY UB_FILIAL, UB_NUMPV "
cQuery += " ORDER BY UB_FILIAL, UB_NUMPV "

TCQuery cQuery new Alias "TQRY"  

TQRY->(DbGoTop())

If TQRY->(!Eof())  
	
	While TQRY->(!Eof())      
	
		cPedsVen += IIF(Empty(cPedsVen),"",", ") + Alltrim(TQRY->UB_NUMPV)

		TQRY->(DbSkip()) 
		
	EndDo

EndIf   

If !Empty(cPedsVen)
     
	MsgAlert("IMPORTANTE! NOTA FISCAL EMITIDA CONTENDO ENDEREÇO DE ENTREGA DIFERENTE DO ENDEREÇO FISCAL. PEDIDO(S): "+cPedsVen+".","Aviso")    
	
EndIf

Return 
