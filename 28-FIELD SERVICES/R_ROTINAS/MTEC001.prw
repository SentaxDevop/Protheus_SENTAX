#include "protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} MTEC001
Altera legenda para suspenso

@author Alessandro Smaha 
@since 07/02/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function MTEC001()

	Local lAlterReg := .F. 
	Local cTipoChm  := "" // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk
	Local cStatChm  := "" // A=Aberto;E=Encerrado  
	Local cUsrMast  := Alltrim(GetNewPar("ST_XUSRMST", "")) 
    Local cCodUsr   := RetCodUsr() 
	Local cNomUsr   := Alltrim(UsrRetName(cCodUsr))
	
	If ! cCodUsr $ cUsrMast
		MsgAlert("Usuário "+cCodUsr+" - "+cNomUsr+" não tem permissão para Ativar/Supender este registro!","Atenção [ST_XUSRMST]")
		Return	
	EndIf
        
    If AB1->AB1_XTIPO == "4"                     
		If MsgYesNo( "Deseja ativar o atendimento "+AB1->AB1_NRCHAM+" ?")
			lAlterReg := .T.
			cTipoChm  := "6"
			cStatChm  := "A"
		EndIf
	ElseIf AB1->AB1_XTIPO == "6"                     
		If MsgYesNo( "Deseja suspender o atendimento "+AB1->AB1_NRCHAM+" ?")
			lAlterReg := .T.
			cTipoChm  := "4"
			cStatChm  := "E"
		EndIf	   
	Else
	 	MsgAlert("Somente chamados com status de Helpdesk podem ser suspensos ou chamados suspensos podem ser ativados!","Atenção")
	EndIf 
	
	If lAlterReg    
	
		RecLock("AB1",.F.)
			AB1->AB1_XTIPO  := cTipoChm 
			AB1->AB1_STATUS := cStatChm 
		AB1->(MsUnLock()) 
		
		DbSelectArea("AB2")
		AB2->(DbSetOrder(1)) // AB2_FILIAL+AB2_NRCHAM+AB2_ITEM+AB2_CODPRO+AB2_NUMSER   
		
		If AB2->(DbSeek(xFilial("AB2")+AB1->AB1_NRCHAM)) 
	
			While AB2->(!Eof()) .AND. AB1->AB1_FILIAL == AB2->AB2_FILIAL .AND. AB2->AB2_NRCHAM == AB1->AB1_NRCHAM 
			     
				RecLock("AB2", .F.)                             
					AB2->AB2_TIPO   := cTipoChm 
					AB2->AB2_STATUS := cStatChm 
				AB2->(MsUnlock())	
				     
		  		AB2->(DbSkip()) 
		  		
			EndDo	
		
		EndIf
		
	EndIf 

Return     