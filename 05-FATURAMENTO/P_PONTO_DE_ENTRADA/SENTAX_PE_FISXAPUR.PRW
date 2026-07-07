#INCLUDE "PROTHEUS.CH"          
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} DADOSTIT
Ponto de entrada que permite alterar o NÚMERO e 
a DATA DE VENCIMENTO do Título na 
Guia de Recolhimento, tabela SF6.
                
@sample		U_DADOSTIT()

@author		Alessandro Smaha
@since		04/04/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------   
User Function DADOSTIT()          

Local cOrigem	:= PARAMIXB[1] //Programa que chamou o ponto
Local aRetOk	:= Array(2)                  
Local cNumDoc 	:= Alltrim(SF2->F2_DOC)
Local dDtVencto	:= SF2->F2_EMISSAO
Local cDigitoN	:= "A" 
Local cBaseCod	:= cNumDoc // Substr(cNumDoc,2,8)
Local lExiste	:= .T. 

If cOrigem $ "MATA460/MATA461/MATA953/MATA954"
	dDtVenc := DataValida(dDtVencto,.T.)
	lExiste := fProcSF6(cNumDoc)

	While lExiste                        
		cNumDoc 	:= cBaseCod + cDigitoN 	
		lExiste 	:= fProcSF6(cNumDoc)
		cDigitoN 	:= Soma1(cDigitoN)	  						
	EndDo
EndIf

If FunName() == "MATA953" .Or. FunName() == "MATA954"
	cNumDoc := StrZero(Val(StrZero(MV_PAR01,2) + StrZero(MV_PAR02,4)),9)
	dDtVenc := LastDay(dDataBase) + 10
EndIf

// Altera Numero / Data Vencimento
aRetOk[1] := cNumDoc	// Número da GNRE
aRetOk[2] := dDtVenc	// Data de Vencimento    

Return aRetOk


//-------------------------------------------------------------------
/*/{Protheus.doc} TITICMST
Ponto de entrada que permite alterar o NÚMERO e 
a DATA DE VENCIMENTO do Título na 
Guia de Recolhimento, tabela SF6.
                
@sample		U_TITICMST()

@author		Alessandro Smaha
@since		21/01/2016     
@version 	P11  
/*/
//------------------------------------------------------------------- 
User Function TITICMST()

Local cOrigem	:= Alltrim(PARAMIXB[1]) //Programa que chamou o ponto 
Local cTipo		:= PARAMIXB[2] //Tipo importação
Local aRetOk	:= {}  
Local lOk 		:= .F.   
Local dDtVencto	:= SF2->F2_EMISSAO

If cOrigem == "MATA460A"

	dDtVencto := DataValida(dDtVencto,.T.)

	SE2->E2_HIST     := "ICMS ST NF "+SF2->F2_DOC    
	SE2->E2_VENCTO   := dDtVencto
	SE2->E2_VENCREA  := dDtVencto 
	SE2->E2_ORIGEM   := "FINA050"
		
EndIf
	
Return aRetOk


//-------------------------------------------------------------------
/*/{Protheus.doc} fProcSF6
Verifica se já existe GNRE para o documento informado
                
@sample		fProcSF6()

@author		Alessandro Smaha
@since		04/04/2016     
@version 	P11  
/*/
//------------------------------------------------------------------- 
Static Function fProcSF6(cNumSF6)

Local lRetOk	:= .F.
Local cQuery 	:= ""  

If (Select("QRYF") <> 0)	
	DbSelectArea("QRYF")
	QRYF->(DbCloseArea())	
Endif

cQuery += " SELECT * " 
cQuery += " FROM " + RetSQLName("SF6") + " SF6 "
cQuery += " WHERE F6_FILIAL = '"+xFilial("SF6")+"' "
cQuery += "		AND F6_NUMERO = '"+cNumSF6+"' "
cQuery += " 	AND SF6.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)

TCQuery cQuery new Alias "QRYF"

QRYF->(DbGoTop())

If QRYF->(!Eof())
	lRetOk := .T.
EndIf

QRYF->(DbCloseArea())

Return lRetOk      
