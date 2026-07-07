/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! FIN - Financeiro                                        !
+------------------+---------------------------------------------------------+
!Nome              ! AFIN002                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Transferência para bordêro para geração nosso número    !
+------------------+---------------------------------------------------------+
!Autor             ! PAULO AFONSO ERZINGER JUNIOR                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 22/11/2010                                              !
+------------------+---------------------------------------------------------+
*/

#include "rwmake.ch"
#include "protheus.ch"

User Function AFIN002(cBanco,cAgencia,cConta)

	Local cNumBord	:= ""
	Local cSituacao := "1"
	Local cSituAnt	:= "0"
	Local aArea	    := GetArea()
	Local aAreaSA1	:= GetArea("SA1")
	Local aAreaSEA	:= GetArea("SEA")

	Do Case
		Case cBanco == "001"
			cNumBord := "B"
		Case cBanco == "104"
			cNumBord := "C"
		Case cBanco == "341"
			cNumBord := "I"
		Case cBanco == "356"
			cNumBord := "R"
		Case cBanco == "399"
			cNumBord := "H"
		Case cBanco == "237"
			cNumBord := "H"
		Case cBanco == "033"
			cNumBord := "S"		
	EndCase

	cNumBord += SUBSTR(dtos(ddatabase),3,2)+sfMesBord()+SUBSTR(dtos(ddatabase),7,2) 

	If !(FwIsIncallStack("U_RFAT014"))
		dbSelectArea("SE1") 
		SE1->(dbSetOrder(1))
		SE1->(dbGoTop())
		SE1->(dbSeek(TRA->E1_FILIAL+TRA->E1_PREFIXO+TRA->E1_NUM+TRA->E1_PARCELA+TRA->E1_TIPO))
	End

	RecLock("SE1",.F.)
	SE1->E1_PORTADO	:= cBanco
	SE1->E1_AGEDEP	:= cAgencia
	SE1->E1_CONTA	:= cConta
	SE1->E1_SITUACA	:= cSituacao
	SE1->E1_NUMBOR	:= cNumBord
	SE1->E1_DATABOR	:= dDataBase
	SE1->(MsUnlock())

	dbSelectArea("SEA") // TITULOS ENVIADO AO BANCO
	SEA->(dbSetOrder(1))
	SEA->(dbGoTop())
	If dbseek(xfilial('SEA')+cNumBord+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
		While SEA->(!EOF()) .AND. SEA->EA_FILIAL == xFilial('SEA');
					.AND. cNumBord == SEA->EA_NUMBOR;
					.AND. SE1->E1_PREFIXO == SEA->EA_PREFIXO;
					.AND. SE1->E1_NUM     == SEA->EA_NUM;
					.AND. SE1->E1_PARCELA == SEA->EA_PARCELA;
					.AND. SE1->E1_TIPO    == SEA->EA_TIPO
		
			RecLock("SEA",.F.)
			SEA->(dbDelete())
			SEA->(MsUnLock())
		
			dbSelectArea("SEA")
			SEA->(dbSkip())
		EndDo	
	EndIf

	RecLock("SEA",.T.)
	SEA->EA_FILIAL  := xFilial("SEA")
	SEA->EA_PREFIXO := SE1->E1_PREFIXO
	SEA->EA_NUM     := SE1->E1_NUM
	SEA->EA_PARCELA := SE1->E1_PARCELA
	SEA->EA_TIPO    := SE1->E1_TIPO
	SEA->EA_PORTADO := cBanco
	SEA->EA_AGEDEP  := cAgencia
	SEA->EA_NUMCON  := cConta
	SEA->EA_NUMBOR  := cNumBord
	SEA->EA_DATABOR := dDataBase
	SEA->EA_CART    := 'R'
	SEA->EA_SITUACA := cSituacao
	SEA->EA_SITUANT := cSituAnt

	//Utilização da comunicação babcária via API do Protheus
	If Alltrim(cBanco) == "001" .And. xFilial("SEA") == "020201"
		SEA->EA_FILORIG := xFilial("SEA")
		SEA->EA_PORTANT := cBanco
		SEA->EA_AGEANT  := cAgencia
		SEA->EA_CONTANT := cConta
		//SEA->EA_BORAPI  := "S"
		SEA->EA_SUBCTA  := "000"
		SEA->EA_ESPECIE := "2"
	End

	SEA->(MsUnLock())

	RestArea(aAreaSEA)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return(cNumBord)

//Funcao que Retorna o Mes em LETRA para o BORDERO
Static Function sfMesBord()
	Local cRet	:= ""
	Local dMes	:= dDataBase
	
	if     month(dMes)==01 ; cRet := "A"
	elseif month(dMes)==02 ; cRet := "B"
	elseif month(dMes)==03 ; cRet := "C"           
	elseif month(dMes)==04 ; cRet := "D"
	elseif month(dMes)==05 ; cRet := "E"
	elseif month(dMes)==06 ; cRet := "F"
	elseif month(dMes)==07 ; cRet := "G"
	elseif month(dMes)==08 ; cRet := "H"
	elseif month(dMes)==09 ; cRet := "I"
	elseif month(dMes)==10 ; cRet := "J"
	elseif month(dMes)==11 ; cRet := "L"
	elseif month(dMes)==12 ; cRet := "M"
	endif

Return cRet
