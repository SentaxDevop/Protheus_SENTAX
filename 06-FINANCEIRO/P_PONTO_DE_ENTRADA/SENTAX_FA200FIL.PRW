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
!Modulo            ! FINANCEIRO                                              !
+------------------+---------------------------------------------------------+
!Nome              ! SENTAX_FA200FIL                                         !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. Substituir pequisa Cnab(Contas a Receber)          !
+------------------+---------------------------------------------------------+
!Autor             ! Luiz Fernando Berti                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 11/07/2012                                              !
+------------------+---------------------------------------------------------+
*/
User Function FA200FIL
Local aValores := PARAMIXB
Local cNmTt  := aValores[01]//Id.Cnab
Local cNsNum   := aValores[04]//Nosso Numero                 
Local xBuffer  := aValores[16]//Linha Inteira
Local cBanco   := MV_PAR06       
Local cVencrea := SubStr(aValores[16],74,8)
//aValores:=({cNumTit,dBaixa,cTipo,cNsNum,nDespes,nDescont,nAbatim,nValRec,nJuros,nMulta,nOutrDesp,nValCc,dDataCred,cOcorr,cMotBan,xBuffer,dDtVc,{} })
			
/*----------------------------------------------------------
|	PROTHEUS PADRAO											|
-----------------------------------------------------------*/
	If !Empty(cNmTt)
		If mv_par13 == 2
			//Busca por IdCnab (sem filial)
			SE1->(dbSetOrder(19)) // IdCnab
			If SE1->(DbSeek(Substr(cNmTt,1,10)))
				cFilAnt	:= SE1->E1_FILIAL
				If !Empty( xFilial("CT2") )//verifica se a contabilizacao eh exclusiva...
					mv_par11 := 2  //Desligo contabilizacao on-line
				Endif
			Else             
				 DBSelectArea("SE1")
				 DBGoTop()
				 cNumTit:= ""
				 lHelp := .T.
			Endif
		Else
			//Busca por IdCnab
			SE1->(dbSetOrder(16)) // Filial+IdCnab
			If !SE1->(DbSeek(xFilial("SE1")+Substr(cNmTt,1,10)))
				 DBSelectArea("SE1")
				 DBGoTop()
				 cNumTit:= ""
				 lHelp := .T.
			EndIf
		Endif
	EndIf
			
	/*----------------------------------------------------------
    |	BUSCA POR NOSSO NUMERO									|
	------------------------------------------------------------*/
	If !SE1->(Found())	.And. cBanco == "104" .And. !Empty(cNsNum).And. !Empty(cBanco)   
	
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
			lHelp := .F.
		Else
			lHelp := .T.
		EndIf
		If Select("TBSA1") <> 0
		   DBSelectArea("TBSA1")
		   DBCloseArea()
		EndIf
		DBSelectArea("SE1")		
	EndIf	
Return