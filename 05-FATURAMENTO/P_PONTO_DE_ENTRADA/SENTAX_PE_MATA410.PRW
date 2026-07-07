/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Nome              ! SENTAX_PE_MATA410                                       !
+------------------+---------------------------------------------------------+
!Descricao         ! Pontos de entrada da rotina MAT410 - Pedido de Venda    !
+------------------+---------------------------------------------------------+
!Autor             ! Mário Lúcio Blasi Faria                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/04/2013                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 										    !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+ 
*/
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"

#DEFINE CRLF (chr(13)+chr(10))

/*
+------------------+---------------------------------------------------------+
!Nome              ! M410GET                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Este ponto de entrada pertence à rotina de pedidos de   !
!                  ! venda, MATA410(). Está localizado na rotina de          !
!                  ! alteração do pedido, A410ALTERA(). É executado após a   !
!                  ! gravação das alterações.                                !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 04/04/2013                                              !
+------------------+---------------------------------------------------------+
!Autor             ! Mário Lúcio Blasi Faria                                 !
+------------------+---------------------------------------------------------+
*/
User Function MT410ALT()
                        
	Local aArea		:= GetArea()
	Local aAreaSC5	:= GetArea("SC5")
 	Local cAlias	:= GetNextAlias()	
	Local cQuery	:= ""
	
	cQuery := "	SELECT C6_FILIAL, C6_ITEM, C6_ITEM " + CRLF 
	cQuery += "	FROM " + RetSqlName("SC6") + " " + CRLF 
	cQuery += "	WHERE " + CRLF 
	cQuery += "			C6_FILIAL = '" + xFilial("SC6") + "' " + CRLF
	cQuery += "		AND C6_NUM = '" + SC5->C5_NUM + "' " + CRLF
	cQuery += "		AND C6_BLOQUEI <> ' ' " + CRLF 
	cQuery += "		AND D_E_L_E_T_ <> '*' " + CRLF 

	Memowrite("c:\temp\MT410ALT.txt",cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)
	
	(cAlias)->(dbGoTop())
	        
	If !(cAlias)->(Eof()) 
		
		dbSelectArea("SC5")
		
		If RecLock("SC5")
			SC5->C5_BLQ := "1"
			SC5->(MsUnLock())
		Endif
				
	EndIf   
	
	(cAlias)->(DbCloseArea())
	
	//--------------------------------------------------------------------------	
	// Apaga o log de liberação do pedido
	//--------------------------------------------------------------------------
	RecLock("SC5",.F.)

	SC5->C5_XULIBCR := ""                 //Usuario liberacao credito
	SC5->C5_XDLIBCR := CTOD("  /  /    ") //Data liberacao credio
	SC5->C5_XHLIBCR := ""                 //Hora Liberacao credito
		
	SC5->C5_XULIBET := ""                 //Usuario liberacao estoque
	SC5->C5_XDLIBET := CTOD("  /  /    ") //Data liberacao estoque
	SC5->C5_XHLIBET := ""                 //Hora Liberacao estoque
	
	SC5->C5_XULIBRG := ""                 //Usuário liberação regra
	SC5->C5_XDLIBRG := CTOD("  /  /    ") //Data liberação regra
	SC5->C5_XHLIBRG := ""                 //Hora liberação regra
	 
	If ALTERA
		SC5->C5_XDALTER := dDataBase 	
		SC5->C5_XHALTER := Time()
	EndIf
			
	MsUnlock()
	//--------------------------------------------------------------------------

	RestArea(aArea)
	RestArea(aAreaSC5)

Return  


//-------------------------------------------------------------------
/*/{Protheus.doc}  MT410ACE
 Ponto-de-Entrada: MT410ACE - Verificar acessos dos usuários 
 Criado para bloquear alteração de pedido com carga montada.
@author  Anderson Roberto Franco de Souza
@since   18/10/2013
@return lRet 	.T. se permitido, .F. caso contrário  
/*/    
//-------------------------------------------------------------------
User Function MT410ACE()
Local lRet:=.T.   
// retirei a mensagem abaixo pois já existe uma mensagem padrão, mas não bloqueava a alteração
IF ALTERA
	If OmsHasCg(SC5->C5_NUM)
	//	MsgAlert("Carga em andamento. Não é possível alterar o pedido.","MT410ACE")
		lRet:=.F.
	EndIf    
ENDIF
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} M410PVNF
O ponto de entrada para validar preparação de documento no pedido.

@author 	Thiago Henrique dos Santos
@since 	 	13/08/2014
@version 	P11
@return 	lRet	.T. se permite preparar doc, .F. caso contrário
/*/
//-------------------------------------------------------------------

User Function M410PVNF()
Local lRet := .T.
Private PARAMIXB := {"",""}   

If SC5->C5_TIPO <> 'D'
	
	U_AFAT001() //verifica transportadora
	 
	lRet := U_AFAT002() //Valida faturamento parcial 
	
	If lRet
		
		If SC5->C5_PESOL == 0 .OR. SC5->C5_PBRUTO == 0 .OR. Empty(SC5->C5_ESPECI1)
			AtuPesPv() //Atualiza Peso Liquido e Bruto do pedido e especie
			//AbrTelPs() //Abre a tela para mostrar para o usuário o que foi alterado, sendo este a conferencia final do que foi alterado pelo sistema.
		EndIf 
			
	EndIf

	//Inclusão da nova informação para atendimento a Reforma Tributária 
	Reclock("SC5",.F.)
		SC5->C5_FECENT := dDatabase
	MsUnLock()

Endif

Return lRet

//Atualiza peso liquido e bruto
Static Function AtuPesPv()
Local cQry 		:= ""
Local cAliasC5	:= GetNextAlias()

cQry := " SELECT ISNULL(SUM(PESOB),0) PESO_B,ISNULL(SUM(PESOL),0) PESO_L "
cQry += " FROM ( "
cQry += " 	SELECT QTD * SB1.B1_PESBRU AS PESOB, QTD * SB1.B1_PESO AS PESOL "
cQry += " 	FROM ( "
cQry += " 			SELECT C6_PRODUTO,SUM(C6_QTDVEN) AS QTD "
cQry += " 			FROM "+ RetSqlName("SC6") +" SC6 WITH(NOLOCK) "
cQry += " 			WHERE SC6.D_E_L_E_T_ = '' "
cQry += " 			AND SC6.C6_FILIAL = '"+ SC5->C5_FILIAL +"' "
cQry += " 			AND SC6.C6_NUM  = '"+SC5->C5_NUM+"' "
cQry += " 			GROUP BY C6_PRODUTO "
cQry += " 		) A "
cQry += " 	INNER JOIN "+ RetSqlName("SB1") +" SB1 WITH(NOLOCK) ON SB1.B1_COD = A.C6_PRODUTO AND SB1.D_E_L_E_T_ = '' "
cQry += " 	) B "

TcQuery cQry New Alias (cAliasC5)

DbSelectArea((cAliasC5))
(cAliasC5)->(DbGoTop())

If !(cAliasC5)->(EOF())

	RecLock("SC5",.F.)
	SC5->C5_PESOL	:= (cAliasC5)->PESO_B //PESO_L
	SC5->C5_PBRUTO	:= (cAliasC5)->PESO_B
	SC5->C5_ESPECI1	:= "CAIXAS"
	SC5->(MsUnlock())

EndIf 

(cAliasC5)->(DbCloseArea())
Return()


Static Function  AbrTelPs()
Local aArea	 		:=	GetArea()
Local nBtoOk		:= 0
Local lRet			:= .t.
Private aFiltros 	:=  { 	SC5->C5_PESOL,;
							SC5->C5_PBRUTO,;
							SC5->C5_VOLUME1,;
							SC5->C5_ESPECI1,;
						}

If !Empty(aFiltros[1]) .And. !Empty(aFiltros[2]) .And. !Empty(aFiltros[3]) .And. !Empty(aFiltros[4]) 
	//MsgInfo("Os dados de peso, volume e especie estão informados,Verifique os dados de peso liquido, bruto, volume e peso!")
	Return .t.
EndIF

Define MsDialog oDlg TITLE "Informações do Pedido de Venda" From 001,001 to 250,1120 Pixel

oGrpFil := TGroup():New(035,005,90,525,"Pedido de Venda",oDlg,CLR_HBLUE,,.T.)

oSayAtr := tSay():New(052,007,{|| "Peso Liq:"   },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetAtr := tGet():New(050,035,{|u| if(PCount()>0,aFiltros[1]:=u,aFiltros[1])}, oGrpFil,40,9,'@E 999,999,999.9999',,,,,,,.T.,,,,,,,.F.,,,'aFiltros[1]')

oSayAtr := tSay():New(052,090,{|| "Peso Bruto:"   },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetAtr := tGet():New(050,122,{|u| if(PCount()>0,aFiltros[2]:=u,aFiltros[2])}, oGrpFil,40,9,'@E 999,999,999.9999',,,,,,,.T.,,,,,,,.F.,,'','aFiltros[2]')

oSayAtr := tSay():New(052,175,{|| "Volume:"  },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetAtr := tGet():New(050,200,{|u| if(PCount()>0,aFiltros[3]:=u,aFiltros[3])}, oGrpFil,40,9,'@E 999,999,999.9999', { ||  },,,,,,.T.,,, { ||  } ,,,,.F.,,,'aFiltros[3]')

oSayAtr := tSay():New(052,255,{|| "Especie:"  },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetAtr := tGet():New(050,285,{|u| if(PCount()>0,aFiltros[4]:=u,aFiltros[4])}, oGrpFil,50,9,'@!', { ||  },,,,,,.T.,,, { ||  } ,,,,.F.,,,'aFiltros[4]')

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )

If nBtoOk == 0
		MsgAlert("Cancelado pelo usuário") //Em producao
		lRet := .t.
	
	Else
		RecLock("SC5",.F.)
		SC5->C5_PESOL	:= aFiltros[1]
		SC5->C5_PBRUTO	:= aFiltros[2]
		SC5->C5_VOLUME1	:= aFiltros[3]
		SC5->C5_ESPECI1	:= aFiltros[4]
		SC5->(MsUnlock())		
EndIf

RestArea(aArea)
Return(lRet)

//---------------------------------------------------------------------------
/*/{Protheus.doc} MA410LEG
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). 
Usado, em conjunto com o ponto MA410COR, para alterar os textos da legenda, 
que representam o “status” do pedido.

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 aRet, array com a legenda

/*/    
//---------------------------------------------------------------------------
User Function MA410LEG()

	Local aCoresAnt := PARAMIXB     
	Local aCores    := {}	
	Local nI        := 0

	//Inclui a legenda em aberto antes para a ordem ficar correta	
	AAdd(aCores,{"ENABLE"      ,"Pedido de Venda em aberto"})	  	
	AAdd(aCores,{"BR_AMARELO"  ,"Pedido de Venda apto a faturar"})	  	

	/*
		Remove as legendas:
		
		Pedido de Venda em aberto (ENABLE)
		Pedido de Venda liberado (BR_AMARELO)
		Pedido de Venda com Bloqueio de Regra (BR_AZUL)
		Pedido de Venda com Bloqueio de Verba (BR_LARANJA)
		
	 */	       
	For nI := 1 To Len(aCoresAnt)
	
		If !(aCoresAnt[nI][1] $ "ENABLE|BR_AMARELO|BR_AZUL|BR_LARANJA")		
		     AAdd(aCores,{aCoresAnt[nI][1],aCoresAnt[nI][2]})
		EndIf
	
	Next nI

	If AllTrim(FUNNAME()) <> "MATA455"
		AAdd(aCores,{"PMSEDT1"   ,"Bloqueio por Regra"})
		AAdd(aCores,{"PMSEDT2"   ,"Bloqueio por Verba"})	
	EndIf                     	

	AAdd(aCores,{"PMSTASK1"  ,"Bloqueio de Credito"})
	AAdd(aCores,{"BR_CANCEL" ,"Rejeitado na Liberacao do Credito"})
	AAdd(aCores,{"PMSEDT4"   ,"Bloqueio de Estoque"})
	AAdd(aCores,{"PMSEDT3"   ,"Bloqueio WMS"})	
	AAdd(aCores,{"BR_PINK"   ,"Bloqueio TMS"})	 
	AAdd(aCores,{"BR_MARROM"   ,"Liberado WMS"})	 



Return aCores                     


//---------------------------------------------------------------------------
/*/{Protheus.doc} MA410COR 
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). 
Usado, em conjunto com o ponto MA410LEG, para alterar cores do “browse” 
do cadastro, que representam o “status” do pedido.

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 aRet, array com as cores para o "browse"

/*/    
//---------------------------------------------------------------------------
User Function MA410COR()

	Local aCoresAnt := PARAMIXB	
	Local aCores    := {}	
	Local nI        := 0	


	
	For nI := 1 To Len(aCoresAnt)

		/*
			Remove as legendas:
			
			Pedido de Venda em aberto (ENABLE)
			Pedido de Venda liberado (BR_AMARELO)
			Pedido de Venda com Bloqueio de Regra (BR_AZUL)
			Pedido de Venda com Bloqueio de Verba (BR_LARANJA)
			
		 */	       
		If !(aCoresAnt[nI][2] $ "ENABLE|BR_AMARELO|BR_AZUL|BR_LARANJA")		
			AAdd(aCores,{aCoresAnt[nI][1],aCoresAnt[nI][2]})		
		EndIf
	
	Next nI


	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '01'  ","BR_AMARELO" }) //01 - Apto a Faturar
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '10'  ","BR_MARROM"  }) //10 - Liberado WMS
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '02'  ","PMSEDT1"    }) //02 - Bloqueio por Regra
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '03'  ","PMSEDT2"    }) //03 - Bloqueio por Verba
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '04'  ","PMSTASK1"   }) //04 - Bloqueio de Crédito
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '05'  ","BR_CANCEL"  }) //05 - Rejeitado na Liberação do Credito
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '06'  ","PMSEDT4"    }) //06 - Bloqueio de Estoque
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '07'  ","PMSEDT3"    }) //07 - Bloqueio WMS
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '08'  ","BR_PINK"    }) //08 - Bloqueio TMS
	AAdd(aCores,{"  U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '09'  ","ENABLE"     }) //09 - Pedido em aberto
	


Return aCores

//---------------------------------------------------------------------------
/*/{Protheus.doc} MT410CPY
O ponto de entrada MT410CPY é executado após o preenchimento do acols e das
variaveis da enchoice, antes da apresentação da tela, permitindo alteração 
do acols e variaveis da enchoice.

@author  Leandro Natan Bonette Santos
@since   15/09/2014
@return	 uRet, nulo

/*/    
//---------------------------------------------------------------------------
User Function MT410CPY()


	//--------------------------------------------------------------------------	
	// Apaga o log de liberação do pedido
	//--------------------------------------------------------------------------
	M->C5_XULIBCR := ""                 //Usuario liberacao credito
	M->C5_XDLIBCR := CTOD("  /  /    ") //Data liberacao credio
	M->C5_XHLIBCR := ""                 //Hora Liberacao credito
		
	M->C5_XULIBET := ""                 //Usuario liberacao estoque
	M->C5_XDLIBET := CTOD("  /  /    ") //Data liberacao estoque
	M->C5_XHLIBET := ""                 //Hora Liberacao estoque
	
	M->C5_XULIBRG := ""                 //Usuário liberação regra
	M->C5_XDLIBRG := CTOD("  /  /    ") //Data liberação regra
	M->C5_XHLIBRG := ""                 //Hora liberação regra
	//--------------------------------------------------------------------------

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} A410CONS
PE para INCLUIR BOTOES NA ENCHOICEBAR
É chamada no momento de montar a enchoicebar do pedido de vendas, 
e serve para incluir mais botões com rotinas de usuário.
                
@sample		U_A410CONS()

@return 	aBotoes - Array com botões do usuário

@author		Alessandro Smaha
@since		13/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function A410CONS()

Local aArea    := GetArea()
Local aBotoes  := {} 
local cUsrTran := alltrim(GetMV('ST_USRTRAN'))  

If AllTrim(FunName()) == "MATA410"
	aAdd(aBotoes,{"PRECO"  ,{|| U_ATMK002()  },'Preço Ótimo', 'Preço Ótimo' })
	
	if __CUSERID $ cUsrTran
		aadd(aBotoes,{"PRECO",{|| U_MFAT011()},'Custo Prod.','Custo Prod.'})
	endif
EndIf

RestArea(aArea)

Return(aBotoes)            


//-------------------------------------------------------------------
/*/{Protheus.doc} MTA410
PE para validação da tela toda no Pedido de Venda.
                
@sample		U_MTA410()

@return 	lRetOk - Lógico

@author		Alessandro Smaha
@since		13/11/2014     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function MTA410()

Local lRetOk := .T.

If lRetOk

	lRetOk := U_ATMK002V(lRetOk)

EndIf     

If lRetOk
	If FunName() == "MATA410" .AND. ALTERA .AND. fVldBlq()  
		fTelaMsg()
	EndIf
EndIf

If lRetOk
	If FunName() == "MATA410" .AND. (ALTERA .OR. INCLUI)  
		lRetOk := fValidaCFOP()
	EndIf
EndIf
	
Return lRetOk     


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldBlq() 
Rotina para verificar se existe bloqueio de credito ou regra
                
@sample		fVldBlq() 

@return 	lBlqPed - Lógico

@author		Alessandro Smaha
@since		23/01/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fVldBlq()  

Local lBlqPed := .F.
Local cPedFil := SC5->C5_FILIAL
Local cPedido := SC5->C5_NUM 
Local cRetPE  := U_MFAT005(cPedFil,cPedido)

If cRetPE == '02' .OR. cRetPE == '04' // Verifica Bloqueio de regra OU Verifica Bloqueado Crédito 

	lBlqPed := .T.
		  
EndIf
	
Return lBlqPed


//-------------------------------------------------------------------
/*/{Protheus.doc} fTelaMsg() 
Abre a Tela para o usuário informar o motivo.
                
@sample		fTelaMsg() 

@author		Alessandro Smaha
@since		23/01/2015     
@version 	P11  
/*/
//------------------------------------------------------------------- 
Static Function fTelaMsg() 

Local aButtons := {}
Local oGetMot
Local cGetMot := ""
Local oMotAlt  
Local nOpcx := 0 
Static oDlg    

cGetMot := Padr(M->C5_XMOTALT,250)

DEFINE MSDIALOG oDlg TITLE "Motivo" FROM 000, 000  TO 120, 600 COLORS 0, 16777215 PIXEL
          
	@ 005, 002 SAY oSayDesc PROMPT "Usuário solicitou ateração: "+Alltrim(UsrFullName(RetCodUsr())) SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 017, 002 SAY oSayDesc PROMPT "Justificativa de Alteração:" SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 002 MSGET oGetMot VAR cGetMot SIZE 290, 010 OF oDlg COLORS 0, 16777215 PIXEL

	EnchoiceBar(oDlg, {|| nOpcx := 1, oDlg:End() }, {|| nOpcx := 0, oDlg:End() },,aButtons)

ACTIVATE MSDIALOG oDlg CENTERED

M->C5_XUSRSOL := RetCodUsr()	// Usuario Solicitou Alteração

If nOpcx == 1	// Motivo da Alteração 		
	M->C5_XMOTALT := cGetMot	 	 
Else	
	M->C5_XMOTALT := "Justificativa não informada."
EndIf			

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fValidaCFOP
Rotina para validar as cfops dos itens do atendimento

@sample		fValidaCFOP()

@author		Alessandro Smaha
@since		23/02/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fValidaCFOP()
                 
Local cCfopRef	:= ""
Local cCfopGrp	:= ""   
Local cCfopPos	:= ""  
Local lRetOk 	:= .T.   
Local cCfopPer	:= GetMV("ST_CFOPPER",,"") 
Local aCfopPer 	:= {}
Local aCfopAux	:= {}   
Local nI		:= 0
Local nPosCf 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CF" })      

aCfopPer := Separa(cCfopPer,'/',.F.) 

If !Empty(aCols) 
	cCfopRef := Alltrim(aCols[1][nPosCf])
EndIf

For nI := 1 to Len(aCfopPer) 

	If Empty(cCfopGrp) .AND. cCfopRef $ aCfopPer[nI] 
     	cCfopGrp := aCfopPer[nI]  
     	Exit
 	EndIf

Next nI

For nI := 1 to Len(aCols) 
    
    cCfopPos := Alltrim(aCols[nI][nPosCf])
    
	If cCfopPos <> cCfopRef 
	
		If ! cCfopPos $ cCfopGrp		
			lRetOk := .F.	    
			Exit		
		EndIf		
	
	EndIf	

Next nI

If !lRetOk   

	MsgAlert("Tipos de operações diferentes no mesmo pedido de vendas!","Operação Indevida")

EndIf

Return lRetOk 
