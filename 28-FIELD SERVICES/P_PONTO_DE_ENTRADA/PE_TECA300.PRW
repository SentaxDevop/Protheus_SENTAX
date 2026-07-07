#include "protheus.ch"
//------------------------------------------------------------------- 
/*/{Protheus.doc} AT30COR
Ponto de Entrada que permite a customização das cores de identificação das linhas do Mbrowse, de acordo com as regras do cliente.

@author Alessandro Smaha 
@since 07/02/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function AT30COR()
	
	Local aCores 		:= aClone(ParamIXB) 
	Local aNovaRegra 	:= {}
	 
	// 1=Chamado;2=Orçamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk
	aNovaRegra := {	{"AB1_XTIPO == '1'",'BR_VERDE' },; 
					{"AB1_XTIPO == '2'",'BR_BRANCO' },;
					{"AB1_XTIPO == '3'",'BR_AZUL' },;
					{"AB1_XTIPO == '4'",'BR_PRETO' },;
					{"AB1_XTIPO == '5'",'BR_VERMELHO' },;			   
					{"AB1_XTIPO == '6'",'BR_AMARELO'}}
	
	aCores := aClone(aNovaRegra)
	
	If aRotina <> Nil
	                     
		aAdd(aRotina,{ "Suspender/Ativar","U_MTEC001",0,4,0,.T. })
		
	EndIf
		
Return aCores


//------------------------------------------------------------------- 
/*/{Protheus.doc} AT30LEG
Possibilita a inclusão e alteração das cores utilizadas pela rotina TECA300.

@author Alessandro Smaha 
@since 07/02/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function AT30LEG()
	
	Local aCores := aClone(ParamIXB) // Para manipular a regra existente
	    
	aNovaRegra := {	{"BR_VERDE",	"1 - Chamado"},;
					{"BR_BRANCO",	"2 - Orçamento"},;
					{"BR_AZUL",		"3 - O.S."},;
					{"BR_PRETO",	"4 - Suspenso"},;
					{"BR_VERMELHO",	"5 - Encerrado"},;
					{"BR_AMARELO",	"6 - Help Desk"}}

	aCores := aClone(aNovaRegra)
	
Return aCores

 
//------------------------------------------------------------------- 
/*/{Protheus.doc} AT300GRV
Esse ponto de entrada é chamado após o término da gravação do atendimento (chamado técnico).

@author Alessandro Smaha 
@since 07/02/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function AT300GRV()

	Local lAltSts := .F.   
	Local cStatus := "" 
	Local cDescProb := ""

	DbSelectArea("AB2")
	AB2->(DbSetOrder(1)) // AB2_FILIAL+AB2_NRCHAM+AB2_ITEM+AB2_CODPRO+AB2_NUMSER    
	
	DbSelectArea("AB7")
	AB7->(DbSetOrder(1)) // AB7_FILIAL+AB7_NUMOS+AB7_ITEM
	
	If AB2->(DbSeek(xFilial("AB2")+AB1->AB1_NRCHAM)) 
	
		While AB2->(!Eof()) .AND. xFilial("AB2") == AB2->AB2_FILIAL .AND. AB2->AB2_NRCHAM == AB1->AB1_NRCHAM 
		     
			If !(Alltrim(AB2->AB2_TIPO) $ cStatus)
				cStatus += Alltrim(AB2->AB2_TIPO)
			EndIf
			
			If AB2->AB2_TIPO == "3" // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk
			
				If AB7->(DbSeek(xFilial("AB7")+M->AB6_NUMOS+AB2->AB2_ITEM)) 
				
					cDescProb := 	Alltrim(MSMM(AB2->AB2_MEMO,TamSx3("AB2_MEMO2")[1]))+CHR(13)+CHR(10)+;					
									Replicate("-",40)+CHR(13)+CHR(10)+"Quantidade: "+cValToChar(AB2->AB2_XQTDIN)+CHR(13)+CHR(10)+Replicate("-",40) 
					
					RecLock("AB7", .F.)
						AB7->AB7_MEMO1 := MSMM(,TamSX3("AB7_MEMO2")[1],,cDescProb,1,,,"AB7","AB7_MEMO1") 
						AB7->AB7_XQTDIN := AB2->AB2_XQTDIN
					AB7->(MsUnlock())	
				
				EndIf	 
			
			EndIf
			     
	  		AB2->(DbSkip()) 
	  		
		EndDo
		
	EndIf  
	
	If !Empty(cStatus)
	
		//1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk  
		If "6" $ cStatus 	
		   	cStatus := "6"  
		ElseIf "1" $ cStatus
			cStatus := "1"     					
		ElseIf "3" $ cStatus
			cStatus := "3" 
		ElseIf "2" $ cStatus 
	   		cStatus := "2"			
		ElseIf "4" $ cStatus 
		  	cStatus := "4"		
		Else // "5" Encerrado
		   	cStatus := "5"
		EndIf	
		
		RecLock("AB1",.F.)
			AB1->AB1_XTIPO := cStatus
		AB1->(MsUnLock())
	
	EndIf
	
Return      


//------------------------------------------------------------------- 
/*/{Protheus.doc} AT300ALT()
Esse ponto de entrada é acionado na chamada da alteração do chamado técnico, logo após a declaração das variáveis.

@param cMsg - String de mensagem de log

@author Alessandro Smaha 
@since 03/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function AT300ALT()
              
	Local lRetOk := .T. 
	Local cUsrMast := Alltrim(GetNewPar("ST_XUSRMST", ""))  
	Local cCodUsr  := RetCodUsr() 
	Local cNomUsr  := Alltrim(UsrRetName(cCodUsr))
	
	If !AB1->AB1_XTIPO $ "16" // 1=Chamado;2=Orcamento;3=O.S.;4=Suspenso;5=Encerrado;6=Help Desk  
		MsgAlert("Apenas chamados do tipo CHAMADO e HELPDESK podem ser alterados!","Atenção")
		lRetOk := .F.	
	EndIf
	
	If ! cCodUsr $ cUsrMast

	 	/*If Substr(Upper(AB1->AB1_ATEND),1,15) <> Substr(Upper(CUSUARIO),7,15)
   			MsgAlert("Usuário diferente do usuário que incluiu o atendimento. Não é possível alterar!","Atenção")
			lRetOk := .F.
		ElseIf !AB1->AB1_XTIPO $ "6"
		*/
		If !AB1->AB1_XTIPO $ "6"  
			MsgAlert("Usuário "+cCodUsr+" - "+cNomUsr+" não tem permissão para alterar este registro!","Atenção [ST_XUSRMST]")
			lRetOk := .F. 	
		EndIf
	 
	EndIf
	
Return lRetOk 
                         

//------------------------------------------------------------------- 
/*/{Protheus.doc} AT300EXC()
Ponto de entrada antes de excluir o chamado tecnico

@author Alessandro Smaha 
@since 03/04/2014
@version P11 
/*/ 
//-------------------------------------------------------------------
User Function AT300EXC()  

	Local lRetOk := .T. 

	/*                                         
	If Substr(Upper(AB1->AB1_ATEND),1,15) <> Substr(Upper(CUSUARIO),7,15)  
   		MsgAlert("Usuário diferente do usuário que incluiu o atendimento. Não é possível excluir!","Atenção")
		lRetOk := .F.
	EndIf
	*/
	
Return lRetOk 


//------------------------------------------------------------------- 
/*/{Protheus.doc} AT300BUT
Inclui novos botôes na enchoice da rotina Chamado Técnico

@author  Leandro Natan Bonette Santos
@since   15/12/2014
@return  aRet, array com os novos botões
/*/ 
//-------------------------------------------------------------------
User Function AT300BUT()

	Local aBotoes := {}
                       
	AAdd(aBotoes,{ "BMPGROUP", { || U_MFAT001(M->AB1_CODCLI,M->AB1_LOJA) }, "Analise Empresa" })

Return aBotoes
                                          
