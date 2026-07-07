#INCLUDE "PROTHEUS.CH"    
#INCLUDE "TOPCONN.CH"   
//------------------------------------------------------------------- 
/*/{Protheus.doc} A410EXC()
RETORNA SE DEVE EXCLUIR O PEDIDO DE VENDAS
Chamado no programa de exclusão de Pedidos de Venda

@author Alessandro Smaha 
@since 03/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function A410EXC()
    
	Local cFilPed	:= ""
	Local cNumPed 	:= ""
	Local lRetOk 	:= .T.
      
	If !INCLUI .AND. !ALTERA .AND. FunName() == "MATA410"
		
		DbSelectArea("AB1")
	   	AB1->(DbSetOrder(1))	// AB1_FILIAL+AB1_NRCHAM
	    
		cFilPed	:= SC5->C5_FILIAL
		cNumPed := SC5->C5_NUM
		 	                 
		cQuery := " SELECT AB2_FILIAL, AB2_NRCHAM "
		cQuery += " FROM "+RetSqlName('AB2')+" AB2 , "
		cQuery += " 	(	SELECT TOP 1 C6_FILIAL, SUBSTRING(C6_NUMOS,1,6) C6_NUMOS " 
		cQuery += " 		FROM "+RetSqlName('SC6')+" SC6 "
		cQuery += " 		WHERE C6_FILIAL = '"+cFilPed+"' AND C6_NUM = '"+cNumPed+"' " 
		cQuery += "    			AND C6_NUMOS <> '' "
		cQuery += "    			AND SC6.D_E_L_E_T_ <> '*' ) AS A "
		cQuery += " WHERE A.C6_FILIAL = AB2_FILIAL AND A.C6_NUMOS = SUBSTRING(AB2_NUMOS,1,6) AND AB2.D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY AB2_FILIAL, AB2_NRCHAM "	 
			 
		If select("TRB1")<>0
			TRB1->(dbclosearea())
		EndIf 
		
		TcQuery cQuery new Alias "TRB1"  
	       
		DbSelectArea("TRB1")
		TRB1->(DbGoTop()) 
		
		If TRB1->(!Eof())  
			 	
		 	While TRB1->(!Eof()) 
	
	 			If AB1->(DbSeek(TRB1->(AB2_FILIAL+AB2_NRCHAM)))
					RecLock("AB1",.F.)
						AB1->AB1_XTIPO := "3" // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk 
					AB1->(MsUnLock())			
		 		EndIf
		 					
				TRB1->(DbSkip())
			
			EndDo	
					 	
		EndIf 
		
	EndIf
		
Return lRetOk