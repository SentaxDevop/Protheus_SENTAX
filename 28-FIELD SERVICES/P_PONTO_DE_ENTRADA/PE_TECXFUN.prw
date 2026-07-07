#INCLUDE "PROTHEUS.CH"    
#INCLUDE "TOPCONN.CH"                
//------------------------------------------------------------------- 
/*/{Protheus.doc} AT410GRV()
Ponto de Entrada (existente na Função AT450Grava) disparado na 
rotina TECA450, após efetivação da OS em Pedido. Está localizado 
no Fonte TECXFUN.

@param cMsg - String de mensagem de log

@author Alessandro Smaha 
@since 03/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function AT410GRV() 
    
	If FunName() == "TECA450"  
		If Empty(M->C5_MENNOTA)
			M->C5_MENNOTA := Alltrim(AB6->AB6_XMNOTA) 
		Else
		    M->C5_MENNOTA := Alltrim(M->C5_MENNOTA)+" "+Alltrim(AB6->AB6_XMNOTA) 
		EndIf 
	EndIf

Return  
 
 
//------------------------------------------------------------------- 
/*/{Protheus.doc} TECXSC5()
Após gravar o Pedido de Venda na efetivação da Ordem de Serviço. 
Após o término da gravação do Pedido de Venda, na efetivacao da O.S.

@param cMsg - String de mensagem de log

@author Alessandro Smaha 
@since 03/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function TECXSC5()
      
	Local cNumPed := SC5->C5_NUM 
	 
	// Altera o status para encerrado no atendimento...
	If Funname() == 'TECA450'
		
		DbSelectArea("AB1")
	   	AB1->(DbSetOrder(1))	// AB1_FILIAL+AB1_NRCHAM
	
		DbSelectArea("AB2")
	   	AB2->(DbSetOrder(1))	// AB2_FILIAL+AB2_NRCHAM+AB2_ITEM+AB2_CODPRO+AB2_NUMSER
	   		
		cNumPed := SC5->C5_NUM
		
		cQuery := " SELECT AB2_NRCHAM "
		cQuery += " FROM "+RetSqlName('AB2')+" AB2 "
		cQuery += " WHERE AB2_FILIAL = '"+xFilial("AB2")+"' "
		cQuery += " 	AND AB2.D_E_L_E_T_ <> '*' "
		cQuery += " 	AND AB2_NUMOS IN (	SELECT C6_NUMOS " 
		cQuery += " 	   					FROM "+RetSqlName('SC6')+" SC6 "
		cQuery += " 	   					WHERE SC6.D_E_L_E_T_ <> '*' "
		cQuery += " 							AND C6_FILIAL = '"+xFilial("SC6")+"' "
		cQuery += " 		 					AND C6_NUM = '"+cNumPed+"' "
		cQuery += " 						GROUP BY C6_NUMOS) " 
		cQuery += " GROUP BY AB2_NRCHAM "
		cQuery += " ORDER BY AB2_NRCHAM "				
			 
		If select("TRB1")<>0
			TRB1->(dbclosearea())
		EndIf 
		
		TcQuery cQuery new Alias "TRB1"  
	       
		DbSelectArea("TRB1")
		TRB1->(DbGoTop()) 
		
		If TRB1->(!Eof())  
			 	
		 	While TRB1->(!Eof()) 
	
	 			If AB1->(DbSeek(xFilial("AB1")+TRB1->AB2_NRCHAM))
					RecLock("AB1",.F.)
						AB1->AB1_XTIPO := "5" // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk 
					AB1->(MsUnLock())			
		 		EndIf
		 					
				TRB1->(DbSkip())
			
			EndDo	
					 	
		EndIf 
		
	EndIf
		
Return       


//------------------------------------------------------------------- 
/*/{Protheus.doc} AT450GRV()
Ponto de Entrada executado no final da gravação das Ordens de Serviço.

@author		Alessandro Smaha 
@since		20/06/2014
@version	P11 
/*/ 
//-------------------------------------------------------------------
User Function AT450GRV() 

Local aArea    := GetArea()
Local cClasAB2 := ""
Local dDataEnc := CtoD("//")
Local cHoraEnc := ""
Local cEstOs   := ""
Local cMunOs   := ""

If FunName() == "TECA300" // Se foi chamado pela efetivação do atendimento em OS
    
	DbSelectArea("AB2")
	AB2->(DbSetOrder(1)) // AB2_FILIAL+AB2_NRCHAM+AB2_ITEM+AB2_CODPRO+AB2_NUMSER    
	
	If AB2->(DbSeek(xFilial("AB2")+AB1->AB1_NRCHAM))
		
		While AB2->(!Eof()) .AND. xFilial("AB2") == AB2->AB2_FILIAL .AND. AB2->AB2_NRCHAM == AB1->AB1_NRCHAM 
		     
			If AB2->AB2_TIPO == "3" // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk
			    
				cClasAB2 := AB2->AB2_CLASSI 
				Exit
				
			EndIf
			     
	  		AB2->(DbSkip()) 
	  		
		EndDo	
		
	EndIf 

	If INCLUI
        		
		If AB1->AB1_XCDEND == "000"        
		
			cMunOs := Alltrim(SA1->A1_MUN) 
			cEstOs := Alltrim(SA1->A1_EST)
					
		Else

			cMunOs := Alltrim(SA1->A1_MUNE)
			cEstOs := Alltrim(SA1->A1_ESTE)
			
		EndIf
			
		// Altera campo de Endereço na O.S. Conforme endereço do atendimento
		RecLock("AB6",.F.)
			AB6->AB6_XCDEND := AB1->AB1_XCDEND  // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk   
			AB6->AB6_NOMCLI := SA1->A1_NOME
			AB6->AB6_UFCLI  := cEstOs 
			AB6->AB6_MUNCLI := cMunOs
			If !Empty(cClasAB2)
				AB6->AB6_XCLASS := cClasAB2	
			EndIf
		AB6->(MsUnLock())
	
	ElseIf ALTERA .AND. !Empty(cClasAB2)
	
		RecLock("AB6",.F.)
	   		AB6->AB6_XCLASS := cClasAB2	
		AB6->(MsUnLock())
	
	EndIf  
	
EndIf

// Grava o Usuário que encerrou a O.S.
If AB6->AB6_STATUS <> 'A' .AND. Empty(AB6->AB6_XDATEF) // A=Aberto;B=Atendida;E=Encerrado
	
	DbSelectArea("AB9")
   	AB9->(DbSetOrder(1))	// AB1_FILIAL+AB1_NRCHAM
   	If AB9->(DbSeek(xFilial("AB9")+AB6->AB6_NUMOS))
   		dDataEnc := AB9->AB9_DTFIM
   		cHoraEnc := AB9->AB9_HRFIM
   	Else
   		dDataEnc := dDataBase
   		cHoraEnc := Substr(Time(),1,5)   	
   	EndIf
    
	RecLock("AB6",.F.)		
		AB6->AB6_XUSREF := UsrFullName(RetCodUsr())
		AB6->AB6_XDATEF := dDataEnc
		AB6->AB6_XHOREF := cHoraEnc
	AB6->(MsUnlock())
EndIf

If FunName() == "TECA640"  

	RecLock("AB6",.F.)		
	AB6->AB6_XDATPR := ABE->ABE_DATA
	AB6->AB6_CONPAG := "101"
	AB6->AB6_NOMCLI := SA1->A1_NOME
	AB6->AB6_UFCLI  := SA1->A1_EST
	AB6->AB6_MUNCLI := SA1->A1_MUN
	AB6->AB6_XCDEND := "999"
	//AB6->AB6_XENDER := U_ATEC001D(AB6->AB6_CODCLI,AB6->AB6_LOJA,AB6->AB6_XCDEND)
	AB6->AB6_XCLASS := "002"
	//AB6->AB6_XDESCL := POSICIONE("SX5",1,XFILIAL("SX5")+"A3"+AB6->AB6_XCLASS,"X5_DESCRI")
	AB6->AB6_ATEND  := cUserName                                    
	MsUnLock("AB6")
	
EndIf

RestArea(aArea)

Return 


//------------------------------------------------------------------- 
/*/{Protheus.doc} AT450OKD()
Ponto de Entrada na Exclusão da O.S., após Confirmação.Antes da 
gravação da alteração da O.S., após a confirmação do usuário.
Ponto disponíivel apenas na versao Protheus.

@author		Alessandro Smaha 
@since		10/07/2014
@version	P11 
/*/ 
//-------------------------------------------------------------------
User Function AT450OKD()

Local lRetOk := .T.
 
If Funname() == "TECA450"
	 
	// Se excluiu, volta o status do chamado para CHAMADO
	If ! INCLUI .AND. ! ALTERA
	
		cQry := " SELECT AB1_NRCHAM "
		cQry += " FROM " + RetSqlName('AB1') + " AB1 "
		cQry += " INNER JOIN " + RetSqlName('AB2') + " AB2 ON AB2_FILIAL = AB1_FILIAL "
		cQry += " 	AND AB2_NRCHAM = AB1_NRCHAM " 
		cQry += " 	AND AB2.D_E_L_E_T_ <> '*' "
		cQry += " WHERE AB1_FILIAL = '" + xFilial('AB1') + "' "  
		cQry += " 	AND SUBSTRING(AB2_NUMOS,1,6) = '"+AB6->AB6_NUMOS+"' "
		cQry += " 	AND AB1.D_E_L_E_T_ <> '*' "
		cQry += " GROUP BY AB1_NRCHAM "
			
	  
		If Select("TQRY") <> 0
			TQRY->(DbCloseArea())
		EndIf      
		
		TcQuery cQry new Alias "TQRY"  
		
		DbSelectArea("AB1")
		AB1->(DbSetOrder(1))
				
		DbSelectArea("TQRY") 
		TQRY->(DbGoTop())  
		While ! TQRY->(Eof()) 
	   		If AB1->(DbSeek(xFilial("AB1")+TQRY->AB1_NRCHAM))
	   			RecLock("AB1",.F.)
					AB1->AB1_XTIPO := "1" // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk 
				AB1->(MsUnLock())	   			
	   			EndIf
			TQRY->(DbSkip())		
		EndDo
	EndIf 
	
EndIf
	
Return lRetOk 