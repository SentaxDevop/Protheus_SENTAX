#INCLUDE "PROTHEUS.CH"


//---------------------------------------------------------------------------
/*/{Protheus.doc} TK271LEG  
Alteração do texto das cores da legenda

@author  Leandro Natan Bonette Santos
@since   04/09/2014                    
@param   cTipoAte, caracter, Indica a qual rotina o Operador terá acesso: 
         1 - Telemarketing / 2 - Televendas / 3 - Telecobrança
         
@return	 aRet, Array com 2 posições. 1º - Cor da legenda / 2º - Texto da legenda

/*/    
//---------------------------------------------------------------------------
User Function TK271LEG(cTipoAte)

	Local aCores := {}
	
	If cTipoAte == "2" //Televendas

		AAdd(aCores,{"BR_MARRON"  	,"Atendimento" })
		AAdd(aCores,{"BR_AZUL"		,"Orçamento" })
		AAdd(aCores,{"BR_VERDE"    	,"Pedido em aberto"})
		AAdd(aCores,{"BR_VERMELHO" 	,"NF.Emitida" })
		AAdd(aCores,{"BR_PRETO"    	,"Cancelado" })
		AAdd(aCores,{"BR_AMARELO"   ,"Pedido Apto a Faturar"})
		AAdd(aCores,{"PMSEDT1"      ,"Bloqueio por Regra"})
		AAdd(aCores,{"PMSEDT2"      ,"Bloqueio por Verba"})
		AAdd(aCores,{"PMSTASK1"     ,"Bloqueio de Crédito"})
		AAdd(aCores,{"BR_CANCEL"    ,"Rejeitado na Liberação do Credito"})
		AAdd(aCores,{"PMSEDT4"      ,"Bloqueio de Estoque"})
		AAdd(aCores,{"PMSEDT3"      ,"Bloqueio WMS"})
		AAdd(aCores,{"BR_PINK"      ,"Bloqueio TMS"})
			
	EndIf
	
Return aCores


//---------------------------------------------------------------------------
/*/{Protheus.doc} TK271COR  
Esse ponto de entrada permite a customização das cores de identificação das
linhas do mbrowse, de acordo com as regras do cliente.

@author  Leandro Natan Bonette Santos
@since   04/09/2014                                            
@param	 cTipoAte, caracter, 1-Telemarketing / 2-Televendas / 3-Telecobrança 
		 Para os tipos 4 e 5 não há exibição de cores
@return	 aRet,  Array com estrutura de duas posições, na qual a primeira 
				posição indica a regra e a segunda indica a cor

/*/    
//---------------------------------------------------------------------------
User Function TK271COR(cTipoAte)   

	Local aCores := {}  
	
              
	If cTipoAte == "2" //Televendas

		//AAdd(aCores,{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. Empty(SUA->UA_DOC))" , "BR_VERDE"   }) // Faturamento - VERDE
		AAdd(aCores,{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 1 .AND. !Empty(SUA->UA_DOC))", "BR_VERMELHO"}) // Faturado - VERMELHO
		AAdd(aCores,{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 2)"	, "BR_AZUL"   })						// Orcamento - AZUL
		AAdd(aCores,{"(EMPTY(SUA->UA_CODCANC) .AND. VAL(SUA->UA_OPER) == 3)"	, "BR_MARRON" }) 						// Atendimento - MARRON
		AAdd(aCores,{"(!EMPTY(SUA->UA_CODCANC))","BR_PRETO"		}) 														// Cancelado
	                                                                                              
	
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '01'  ","BR_AMARELO" }) //01 - Apto a Faturar
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '02'  ","PMSEDT1"    }) //02 - Bloqueio por Regra
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '03'  ","PMSEDT2"    }) //03 - Bloqueio por Verba
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '04'  ","PMSTASK1"   }) //04 - Bloqueio de Crédito
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '05'  ","BR_CANCEL"  }) //05 - Rejeitado na Liberação do Credito
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '06'  ","PMSEDT4"    }) //06 - Bloqueio de Estoque
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '07'  ","PMSEDT3"    }) //07 - Bloqueio WMS
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '08'  ","BR_PINK"    }) //08 - Bloqueio TMS
		AAdd(aCores,{"  U_MFAT005(SUA->UA_FILIAL,SUA->UA_NUMSC5) == '09'  ","BR_VERDE"   }) //09 - Pedido em aberto
		
	EndIf


Return aCores


//-------------------------------------------------------------------
/*/{Protheus.doc} TMKCBPRO
Ponto de Entrada que permite a inclusão de botões na enchoice 
do histórico de Telemarketing.
                
@sample		U_TMKCBPRO()

@return 	aButtons - Array com as opções do menu

@author		Alessandro Smaha
@since		10/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function TMKCBPRO()

Local aButRet := {}       
    
If INCLUI .OR. ALTERA
  
	AADD( aButRet, {"Preço Ótimo", {|| U_ATMK001() }, "Preço Ótimo" } )    
	
	If FunName() $ "TMKA271|TMKA350|TMKA280|ATMK007" 
		DbSelectArea("XX4")
		A020CodUnq()//tratamento para bug xx4 no telecobranca
		SetKey( 25, { || U_ATMK003() } ) // CTRL + Y
		SetKey( VK_F11,{ || U_FATA1004() } )    
		AADD( aButRet, {"Histórico Consolidado", {|| U_ATMK003() }, "Histórico Consolidado" } )
	EndIf
	
EndIf

Return (aButRet)          
 

//-------------------------------------------------------------------
/*/{Protheus.doc} TK271END
Exeutado na confimacao do atendimento para gravação da lista de contato
                
@sample		U_TMKCBPRO()

@return 	nil

@author		Rodrigo Slisinski
@since		20/07/2017     
@version 	P11  
/*/
//-------------------------------------------------------------------
/*User Function TK271BOK()
	
U_ATMK007A()

Return .f.  */       


