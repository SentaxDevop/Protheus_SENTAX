#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
/*
+-----------------------------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                                         !
+-----------------------------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                                          !
+--------------------------+--------------------------------------------------------------------+
! Tipo                     ! Ponto de entrada                                                   !
+--------------------------+--------------------------------------------------------------------+
! Módulo                   ! Faturamento                                                        !
+--------------------------+--------------------------------------------------------------------+
! Nome                     !  MATA450                                                           !
+--------------------------+--------------------------------------------------------------------+
! Descrição                !Pontos de entrada da rotina mata450                                 !
+--------------------------+--------------------------------------------------------------------+
! Autor                    ! Rodrigo Favero                                                     !
+--------------------------+--------------------------------------------------------------------+
! Data de Criação          ! 25/03/2013                                                         !
+--------------------------+--------------------------------------------------------------------+
!   ATUALIZAÇÕES                                                                                !
+------------------------------------+-----------+---------+---------+--------------------------+
! Descricao detalhada da atualização !Nome do    ! Analista!Data     !                          !
!                                    !Solicitante! Respons.!Atualiz. !                          !
+------------------------------------+-----------+---------+---------+--------------------------+
*/
User Function MA450MNU()

aAdd(aRotina,{"Analise Empresas","U_MFAT001", 0 , 6,0,.F.})  

PUTMV( "ST_CLLIBOK", "" ) // Limpa o conteúdo do parâmetro

Return
  
  
//---------------------------------------------------------------------------
/*/{Protheus.doc} MA450COR  
Ponto de entrada que pertence à rotina de liberação de estoque, MATA450, 
Usado, em conjunto com o ponto MA455COR, para alterar os textos da legenda, 
que representam o status do pedido.

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 aRet, array com a legenda

/*/    
//---------------------------------------------------------------------------                                                     
User Function MA450COR()

	Local aCoresAnt := PARAMIXB            		
	Local aCores    := {}	
	Local nI        := 0

	AAdd(aCores,{"BR_AMARELO"  ,"Pedido de Venda apto a faturar"})	  	
	
	For nI := 1 To Len(aCoresAnt)

									//"BR_AZUL|BR_PRETO|BR_AMARELO|BR_LARANJA|BR_MARROM")	-- Antigo
		If !(aCoresAnt[nI][1]  $ "ENABLE|BR_AZUL|BR_MARROM|BR_PRETO|BR_AMARELO|BR_LARANJA" ) 
			AAdd(aCores,{aCoresAnt[nI][1],aCoresAnt[nI][2]})		
		EndIf
	
	Next nI

//	AAdd(aCores,{"PMSEDT1"   ,"Bloqueio por Regra"})
//	AAdd(aCores,{"PMSEDT2"   ,"Bloqueio por Verba"})
	AAdd(aCores,{"PMSTASK1"  ,"Bloqueio de Credito"})
	AAdd(aCores,{"BR_CANCEL" ,"Rejeitado na Liberacao do Credito"})
	AAdd(aCores,{"PMSEDT4"   ,"Bloqueio de Estoque"})
	AAdd(aCores,{"PMSEDT3"   ,"Bloqueio WMS "})	
	AAdd(aCores,{"BR_PINK"   ,"Bloqueio TMS"})	  

Return aCores


//---------------------------------------------------------------------------
/*/{Protheus.doc} M450LEG  
Este ponto de entrada pertence à rotina de liberação de crédito, MATA450(). 
Usado, para alterar cores do “browse” do cadastro, que representam
o “status” do pedido.

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 aRet, com as cores para o browse.

/*/    
//---------------------------------------------------------------------------                      
User Function M450LEG()

	Local aCoresAnt := PARAMIXB 
	Local aCores := {}                                     
	
	
	Local nI := 0
	
	For nI := 1 To Len(aCoresAnt)                                 
                                                 
	                            //"BR_AZUL|BR_PRETO|BR_AMARELO|BR_LARANJA|BR_MARROM" -- antigo
		If !(aCoresAnt[nI][2] $ "ENABLE|BR_AZUL|BR_MARROM|BR_PRETO|BR_AMARELO|BR_LARANJA" )
		
			AAdd(aCores,{aCoresAnt[nI][1],aCoresAnt[nI][2]})
		
		EndIf
	                                                
	Next nI	
	

	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '01'  ","BR_AMARELO" }) //01 - Apto a Faturar
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '02'  ","PMSEDT1"    }) //02 - Bloqueio por Regra
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '03'  ","PMSEDT2"    }) //03 - Bloqueio por Verba
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '04'  ","PMSTASK1"   }) //04 - Bloqueio de Crédito
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '05'  ","BR_CANCEL"  }) //05 - Rejeitado na Liberação do Credito
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '06'  ","PMSEDT4"    }) //06 - Bloqueio de Estoque
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '07'  ","PMSEDT3"    }) //07 - Bloqueio WMS
	AAdd(aCores,{"  U_MFAT005(SC9->C9_FILIAL,SC9->C9_PEDIDO,SC9->C9_ITEM) == '08'  ","BR_PINK"    }) //08 - Bloqueio TMS


Return aCores

//---------------------------------------------------------------------------
/*/{Protheus.doc} MT450END
Ponto de Entrada pertencente à rotina "Liberação de Crédito" (MATA450). 
Está localizado no processamento da avaliação automática de crédito por pedidos, 
MA450PROCES(). É executado ao final do processamento de cada item.

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 uRet, nulo

/*/    
//---------------------------------------------------------------------------                      
User Function MT450END()

	If FUNNAME() <> "MATA450"
		//------------------------------------------------------------
		// Informa o usuário, data e hora da liberação do estoque
		//------------------------------------------------------------
		RecLock("SC5",.F.)
		SC5->C5_XULIBET := RetCodUsr()
		SC5->C5_XDLIBET := Date()
		SC5->C5_XHLIBET := Time()
		MsUnlock()
		//------------------------------------------------------------
	EndIf

Return
                   

//---------------------------------------------------------------------------
/*/{Protheus.doc} MTA450T
APOS ATUALIZACAO DO SC9 NA LIB. PEDIDO
Executado apos atualizacao do SC9 na liberacao do pedido.

@author  Leandro Natan Bonette Santos
@since   11/09/2014
@return	 uRet, nulo

/*/    
//---------------------------------------------------------------------------                      
User Function MTA450T()
                                    

	If FUNNAME() == "MATA450" //Mata450 - Liberação de credito - Automático     
      
		//------------------------------------------------------------
		// Informa o usuário, data e hora da liberação de CREDITO
		//------------------------------------------------------------
		RecLock("SC5",.F.)
		SC5->C5_XULIBCR := RetCodUsr()
		SC5->C5_XDLIBCR := Date()
		SC5->C5_XHLIBCR := Time()
		MsUnlock()
		//------------------------------------------------------------
	
	EndIf
	
	If FUNNAME() == "MATA455"

		//------------------------------------------------------------
		// Informa o usuário, data e hora da liberação do ESTOQUE
		//------------------------------------------------------------
		RecLock("SC5",.F.)
		SC5->C5_XULIBET := RetCodUsr()
		SC5->C5_XDLIBET := Date()
		SC5->C5_XHLIBET := Time()
		MsUnlock()
		//------------------------------------------------------------
	
	EndIf

Return     


//---------------------------------------------------------------------------
/*/{Protheus.doc} MT450FIM
Este ponto pertence à rotina de liberação de crédito, MATA450(). 
Está localizado na liberação manual do crédito por pedido A450LIBMAN(). 
É executado ao final da liberação de um pedido

@author  Leandro Natan Bonette Santos
@since   11/09/2014
@param   cPedido, caracter, número do pedido liberado
@return	 uRet, nulo

/*/    
//---------------------------------------------------------------------------                      
User Function MT450FIM()
                   
	//MATA450 - Liberação de credito - Manual
	If FUNNAME() == "MATA450"
		//------------------------------------------------------------
		// Informa o usuário, data e hora da liberação de CREDITO
		//------------------------------------------------------------
		RecLock("SC5",.F.)
		SC5->C5_XULIBCR := RetCodUsr()
		SC5->C5_XDLIBCR := Date()
		SC5->C5_XHLIBCR := Time()
		MsUnlock()
		//------------------------------------------------------------
	EndIf
	
Return
 

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA450I
PONTO DE ENTRADA APOS ATUALIZACAO DA LIBERACAO DO PEDIDO 
Executado apos atualizacao da liberacao de pedido.
                
@sample		U_MTA450I()

@author		Alessandro Smaha
@since		27/04/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function MTA450I()

Local aArea := GetArea() // Grava a area atual
Local _lret := .T.
Local dLimLib 	:= ParamIXB[2]    
Local nValTot	:= 0   
Local nOpcA		:= 0
Local lPergte 	:= .F. 
Local aButtons	:= {}   
Local aRotAuto	:= {}    
Local nModBkp	:= nModulo  
Local cModBkp	:= cModulo 
Local cParClLib	:= GetMV("ST_CLLIBOK",,"xxxxxx")  

If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
    
	// Alterado por smaha 27/04/2015
	
	If Alltrim(SA1->A1_RISCO) == 'A'
	
		// A pergunta não deve ocorrer, pois o cliente é liberado automaticamente.   	
		    
	Else
	
		If Empty(SA1->A1_VENCLC) .OR. Empty(SA1->A1_LC) 
		
			lPergte := .T.
		
		ElseIf SA1->A1_VENCLC <= dDataBase .OR. SA1->A1_LC <= fValCli( SA1->A1_COD, SA1->A1_LOJA )
			
			lPergte := .T.
				
		EndIf 
		
		If lPergte .AND. Alltrim(SA1->(A1_COD+A1_LOJA)) <> Alltrim(cParClLib)
	        
	        /* Melissa pediu para tirar a mensagem abaixo... 28/04/2015
			// Trecho Jair de
			If SA1->A1_VENCLC  <> dLimLib	
				If MsgYesNo("A data de vencimento do Limite de Credito:"+DTOC(SA1->A1_VENCLC)+" é diferente a data Limite de Liberação:"+DTOC(dLimLib)+". Deseja Alterar?")
					SA1->(RecLock("SA1",.F.))
					SA1->A1_VENCLC := dLimLib
					SA1->(MSUnlock())
				EndIf		
			EndIf 
			// Trecho Jair ate    
			*/
						
			If MsgYesNo("Deseja revisar as informações de análise de crédito do Cliente ?","Atenção") 
			    
                nModulo := 6 // Financeiro
                cModulo := "FIN"  
                Private aRotina := {}
				aAdd(aRotina, {"Pesquisar", "AxPesqui", 0, 1})
				aAdd(aRotina, {"Visualizar", "AxVisual", 0, 2})
				aAdd(aRotina, {"Incluir", "AxInclui", 0, 3})
				aAdd(aRotina, {"Alterar", "AxAltera", 0, 4})
				aAdd(aRotina, {"Excluir", "AxDeleta", 0, 5})
				nOpcA := AxAltera("SA1",SA1->(RecNo()),4)
				
				nModulo := nModBkp 
				cModulo := cModBkp 
				
			EndIf 
			
			PUTMV( "ST_CLLIBOK", SA1->(A1_COD+A1_LOJA) )
		
		EndIf   
			
	EndIf
	
EndIf

If FUNNAME() == "MATA450" .AND. ParamIxb[1] == 1
      
	//------------------------------------------------------------
	// Informa o usuário, data e hora da liberação de CREDITO
	//------------------------------------------------------------
	RecLock("SC5",.F.)
	SC5->C5_XULIBCR := RetCodUsr()
	SC5->C5_XDLIBCR := Date()
	SC5->C5_XHLIBCR := Time()
	MsUnlock()
	//------------------------------------------------------------
	
EndIf

                
RestArea( aArea ) // Restaura a area atual

Return(_lret)    

 
//-------------------------------------------------------------------
/*/{Protheus.doc} fValCli
Cadastro de Requisições de Horas Extras 
                
@sample		fValCli( cCodCli, cLojCli )

@return 	nValTot - Valor total de pedidos não faturados e titulos
@author		Alessandro Smaha
@since		27/04/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fValCli( cCodCli, cLojCli )

Local nValTot 	:= 0
Local cQuery	:= ""

If ( Select("TQRY") ) > 0
	DbSelectArea("TQRY")
	TQRY->(dbCloseArea())
EndIf    

cQuery += " SELECT SUM(VAL_TOT) VALOR_TOTAL "
cQuery += " FROM ( "
cQuery += " 		SELECT C6_FILIAL FILIAL, C6_NUM PEDIDO, SUM(C6_QTDVEN * C6_PRCVEN) VAL_TOT " 
cQuery += " 		FROM "+RetSqlName("SC6")+" SC6 "
cQuery += " 		WHERE SC6.D_E_L_E_T_ <> '*' " 
cQuery += " 			AND C6_FILIAL + C6_NUM IN (	SELECT C5_FILIAL + C5_NUM CHAVE " 
cQuery += " 										FROM "+RetSqlName("SC5")+" SC5 "
cQuery += " 										WHERE C5_CLIENTE = '"+cCodCli+"' " 
cQuery += " 											AND C5_LOJACLI = '"+cLojCli+"' "
cQuery += " 											AND C5_NOTA = '' "
cQuery += " 											AND SC5.D_E_L_E_T_ <> '*' ) " 
cQuery += " 		GROUP BY C6_FILIAL, C6_NUM "	
cQuery += " 		UNION ALL "
cQuery += " 		SELECT E1_FILIAL, E1_NUM, E1_SALDO "
cQuery += " 		FROM "+RetSqlName("SE1")+" SE1 " 
cQuery += " 		WHERE E1_CLIENTE = '"+cCodCli+"' "
cQuery += " 			AND E1_LOJA = '"+cLojCli+"' "
cQuery += " 			AND E1_SALDO > 0 "
cQuery += " 			AND SE1.D_E_L_E_T_ <> '*') AS B "
 
TCQUERY cQuery NEW ALIAS "TQRY" 
	
DbSelectArea("TQRY") 
TQRY->(DbGoTop())   

If TQRY->(!Eof())

	nValTot := TQRY->VALOR_TOTAL 

EndIf

Return nValTot
