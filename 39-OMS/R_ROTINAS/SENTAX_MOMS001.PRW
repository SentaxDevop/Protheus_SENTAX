#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} MOMS001
Rotina para chamar a função para atualizar campo 
A1_XENTPRO (Entrega Própria?) para os clientes que 
possuem ponto por setor.
                
@sample		U_MOMS001()

@author		Alessandro Smaha
@since		03/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function MOMS001() 
 
	Processa({|| fProcessa() },"Rotina U_MOMS001 (v1.0)")
                
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Rotina para atualizar campo A1_XENTPRO (Entrega Própria?) para os 
clientes que possuem ponto por setor
                
@sample		fProcessa()

@author		Alessandro Smaha
@since		03/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fProcessa()

Local cQuery	:= ""  
Local cQueryAux	:= ""
Local nCount	:= 0
Local nTotReg	:= 1

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA    

If (Select("TRBA") <> 0)		
	DbSelectArea("TRBA")
	TRBA->(DbCloseArea())		
Endif  

If (Select("TRBB") <> 0)		
	DbSelectArea("TRBB")
	TRBB->(DbCloseArea())		
Endif
	 
cQuery := " SELECT DA7_CLIENT, DA7_LOJA " 
cQuery += " FROM " + RetSQLName("DA7") + " DA7 " 
cQuery += " WHERE DA7.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY DA7_CLIENT, DA7_LOJA "
cQueryAux := cQuery
cQuery += " ORDER BY DA7_CLIENT, DA7_LOJA "

TCQuery cQuery new Alias "TRBA"  
             
cQueryAux := " SELECT COUNT(*) TOTAL_REG FROM (" + cQueryAux + ") AS A " 

TCQuery cQueryAux new Alias "TRBB"

TRBB->(DbGoTop()) 

If TRBB->(!Eof())
	nTotReg := TRBB->TOTAL_REG	
EndIf

nCount := 0
 
TRBA->(DbGoTop())

If TRBA->(!Eof())
	
	While TRBA->(!Eof())  
	
		nCount++  
		
		cValPerc := Round(nCount*100/nTotReg,0)   
		
		IncProc("Atualizando Cad. Cliente - Ent. Própria ?... Aguarde ("+cValToChar(cValPerc)+"%)")
	     
		If SA1->(DbSeek(xFilial("SA1")+TRBA->DA7_CLIENT+TRBA->DA7_LOJA)) 

			RecLock("SA1",.F.)
				SA1->A1_XENTPRO := "2" // 1=Não; 2=Sim
			SA1->(MsUnLock())
		
		EndIf
	
		TRBA->(DbSkip())
	EndDo 
	
EndIf   

MsgInfo("Registros atualizados: "+cValToChar(nCount),"Atenção")
	
Return