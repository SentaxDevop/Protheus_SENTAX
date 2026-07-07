#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de Entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! FIN - Financeiro                                        !
+------------------+---------------------------------------------------------+
!Nome              ! SENTAX_F650VAR                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. reltorio de retorno...                             !
+------------------+---------------------------------------------------------+
!Autor             ! Luiz Fernando                                           !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 09/07/2012                                              !
+------------------+---------------------------------------------------------+
*/
User Function FR650FIL()
Local cBanco   := mv_par03
Local aParTit := PARAMIXB
Local cNsNum   := aParTit[1][4]
Local cNumTit  := AllTrim(aParTit[1][01])
LOCAL cQuery   := ""       
LOCAL lPos     := .F.      
Local cVencrea := SubStr(aParTit[1][14],74,8)


/*----------------------------------------------------------*
|Verifica se eh contas a pagar ou receber                   |
*-----------------------------------------------------------*/
If mv_par07<>1 //mv_par07==1,"SE1","SE2"
     Return SE2->(Found())
ElseIf SE1->(Found()) .AND. ( !Empty(cNumTit) .AND. SubStr(cNumTit,1,10) <> "0000000000" )
	Return .T.
EndIf
					
	/*----------------------------------------------------------
	|	BUSCA POR NOSSO NUMERO									|
	-----------------------------------------------------------*/
	If cBanco == '104' .And. !Empty(cNsNum) .And. !Empty(cBanco)	
	
		cVencrea := SubStr(cVencrea,5,4) + SubStr(cVencrea,3,2) + SubStr(cVencrea,1,2)
	
		cQuery := "SELECT R_E_C_N_O_ AS E1_RECNO FROM "+RetSQLName("SE1")
		cQuery += " WHERE  "
		//cQuery += " E1_FILIAL = '"+xFilial("SE1")+"' AND "
		cQuery += " E1_NUMBCO = '"+cNsNum+"' AND "
		cQuery += " E1_PORTADO = '"+cBanco+"' AND "
		cQuery += " E1_VENCREA = '"+cVencrea+"' AND "
		cQuery += " D_E_L_E_T_ <> '*' "
		If Select("TBSA1") <> 0
		   DBSelectArea("TBSA1")
		   DBCloseArea()
		EndIf		
		TCQuery cQuery New Alias "TBSA1"
		
		If !TBSA1->(Eof())
			SE1->(dbGoTo(TBSA1->E1_RECNO))
			
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
									
			cEspecie := SE1->E1_TIPO
			cNumTit  := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)
			cCliFor	 := SE1->E1_CLIENTE+" "+SE1->E1_LOJA
			cNomeCli := SA1->A1_NOME
			cTipo    := SE1->E1_TIPO	
			cCNPJ	 := SA1->A1_CGC	    
			cParcela := SE1->E1_PARCELA			

			lPos := .T.  

		EndIf		
		
		TBSA1->(DbCloseArea())
		If Select("TBSA1") <> 0
		   DBSelectArea("TBSA1")
		   DBCloseArea()
		EndIf		
	EndIf
	DBSelectArea("SE1")	
Return lPos
