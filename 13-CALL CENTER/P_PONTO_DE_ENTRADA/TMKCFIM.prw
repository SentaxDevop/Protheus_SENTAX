//-------------------------------------------------------------------
/*/{Protheus.doc} TMKCFIM
Ponto de entrada no final da gravação do telecobrança.

@author Suelen Regina de Souza
@since 27/12/2013
@version P11
/*/
//-------------------------------------------------------------------
#include "totvs.ch"
#include "protheus.ch"                                                                      
#INCLUDE "topconn.ch"

User Function TMKCFIM()
Local cQuery 	:= ""
Local nSeqZ18 	:= 0
Local _cMemo	:= ""               
Local aAreaACG	:= {}


If (TkGetTipoAte()== "3") .or. FUNNAME() <> "TMKA350" //SOMENTE EXECUTA SE FOR TELECOBRANÇA.  

	RECLOCK("ACF",.F.)
	ACF->ACF_OPERAT := TkOperador() 
	ACF->(MsUnlock())   
	
	//CONTROLE DE LIGAÇÃO PARA MENSURAR NO B.I. POSTERIORMENTE - SUELEN 28/04/2014
	//OU SEJA, TODA VEZ QUE OPERADOR ENTRA NO COBRANÇA E FAZ UMA INTERAÇÃO.
    
	RECLOCK("SZ1",.F.)
	SZ1->Z1_FILIAL := ACF->ACF_FILIAL
	SZ1->Z1_CODIGO := ACF->ACF_CODIGO
	SZ1->Z1_CLIENT := ACF->ACF_CLIENT
	SZ1->Z1_LOJA   := ACF->ACF_LOJA
	SZ1->Z1_OPERAD := TkOperador()
	SZ1->Z1_STATUS := ACF->ACF_STATUS
	SZ1->Z1_DATA   := dDatabase
	SZ1->Z1_HORA   := Time()  
	SZ1->(MsUnlock())
	
	
   /*	nPPrefix	:= Ascan(aHeader, {|x| x[2] == "ACG_PREFIX"} )
	nPTitulo	:= Ascan(aHeader, {|x| x[2] == "ACG_TITULO"} )
	nPParcel	:= Ascan(aHeader, {|x| x[2] == "ACG_PARCEL"} )
	nPTipo		:= Ascan(aHeader, {|x| x[2] == "ACG_TIPO  "} )
	
	
   	For nI := 1 To Len(aCols)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao dos itens do atendimento de Telecobranca³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ACG->(FieldPos("ACG_FILORI"))  > 0)
			nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
			If nPFilOrig > 0
				cFilOrig := aCols[nI][nPFilOrig]
			Else
				cFilOrig := xFilial("SE1")
			Endif
		Else
			cFilOrig := xFilial("SE1")
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados dos titulos cobrados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE1")
		DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
		If DbSeek(cFilOrig + M->ACF_CLIENT + M->ACF_LOJA + aCols[nI][nPPrefix] + aCols[nI][nPTitulo] + aCols[nI][nPParcel] + aCols[nI][nPTipo])
			
			DbSelectArea("Z8Z")
			DbSetOrder(1)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
			If DbSeek(cFilOrig + M->ACF_CLIENT + M->ACF_LOJA + aCols[nI][nPPrefix] + aCols[nI][nPTitulo] + aCols[nI][nPParcel] + aCols[nI][nPTipo])
				
				RecLock("SE1", .F.)
				SE1->E1_VENCTO 		:= Z8Z->Z8Z_VENCTO
				SE1->E1_VENCREA 	:= Z8Z->Z8Z_VENCRE
				SE1->E1_HIST 		:= Z8Z->Z8Z_HIST
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se ainda nao houve baixa para o titulo, significa que os dados de   ³
				//³Desconto Financeiro, Descrescimo e Acrescimo poderao ser alterados. ³
				//³No Financeiro os Acrescimos, Decrescimos e Descontos, sao concedidos³
				//³somente na primeira baixa do titulo. Se existirem novos valores     ³
				//³o usuario  devera informar manualmente na baixa de titulo.		   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  Empty(SE1->E1_BAIXA)
					SE1->E1_DESCFIN		:= Z8Z->Z8Z_DESCFI			// Percentual de Desconto Financeiro
					SE1->E1_LIDESCF		:= Z8Z->Z8Z_LIDESC			// Data Limite para Desconto Financeiro
					SE1->E1_ACRESC		:= Z8Z->Z8Z_ACRESC			// Valor de Acrescimo
					SE1->E1_DECRESC		:= Z8Z->Z8Z_DECRES			// Valor de Descrescimo
					
					If (SE1->(FieldPos("E1_DESCJUR")) > 0) .AND. (ACG->(FieldPos("ACG_DESCJU")) > 0)
						SE1->E1_DESCJUR		:= Z8Z->Z8Z_DESCJUR			// Percentual de Desconto sobre Juros
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Os Saldos de Acrescimo e Decrescimo devem ser atualizados       ³
					//³para serem avaliados no momento da baixa do titulo. 			   ³
					//³Os Saldos sao atualizados ate que o titulo seja baixado, 	   ³
					//³apos a baixa (parcial), o mesmo nao podera ser alterado.        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE1->E1_SDACRES		:= Z8Z->Z8Z_SDACRE	    	// Saldo de Acrescimo
					SE1->E1_SDDECRE		:= Z8Z->Z8Z_SDDECR			// Saldo de Descrescimo
				Endif
				
				SE1->(MsUnLock())
				
				RecLock("Z8Z",.F.)
				Z8Z->(dbDelete())
				Z8Z->(MsUnLock())
				
			ENDIF
		Endif
	NEXT    */
ENDIF

IF funname() == "TMKA350" .OR. funname() == "TMKA280"


	cQuery := " SELECT MAX(Z18_ORDEM) AS Z18_ORDEM "
	cQuery += " FROM "+RetSqlName('Z18')
	cQuery += " WHERE "
	cQuery += "      Z18_FILIAL = '"+xFilial('Z18')+"' AND Z18_CODIGO = '"+ACF->ACF_CODIGO+"' AND D_E_L_E_T_ != '*' "
	
	If (Select("QRYZ18") <> 0)
		DbSelectArea("QRYZ18")
		QRYZ18->(DbCloseArea())
	Endif
	
	
	TCQUERY cQuery NEW ALIAS "QRYZ18"
	DbSelectArea('QRYZ18')
	QRYZ18->(DbGoTop())
	
	If !QRYZ18->(EOF())
		nSeqZ18 := QRYZ18->Z18_ORDEM
	EndIf 
	
	QRYZ18->(DbCloseArea()) 
	
	nSeqZ18++
		
	RECLOCK("Z18",.T.)
	Z18->Z18_FILIAL := ACF->ACF_FILIAL
	Z18->Z18_CODIGO := ACF->ACF_CODIGO
	Z18->Z18_CLIENT := ACF->ACF_CLIENT
	Z18->Z18_LOJA   := ACF->ACF_LOJA
	Z18->Z18_OPERAD := TkOperador()
	Z18->Z18_STATUS := ACF->ACF_STATUS
	Z18->Z18_DATA   := dDatabase
	Z18->Z18_HORA   := Time()  
	Z18->Z18_ORDEM  := nSeqZ18
	Z18->Z18_TIPOOP := ACF->ACF_OPERA
	Z18->Z18_CODCON := ACF->ACF_CODCON
	Z18->Z18_OBS	   := ACF->ACF_OBSLIG	
	Z18->(MsUnlock())


//	_cMemo	:= MSMM(ACF->ACF_CODOBS,,,,3) 
 //	_cMemo	+= chr(13)+chr(10)+ACF->ACF_OBSLIG
	RECLOCK("ACF",.F.)   
	ACF->ACF_OBSLIG	:= ""
	ACF->(MsUnlock())   
 //	MSMM(ACF->ACF_CODOBS,,,_cMemo,1,,,"ACF","ACF_CODOBS")

	
ENDIF

If TkGetTipoAte()== "3" .AND. ProcName(1) == "TK274GRVTLC"
 	aAreaACG := ACG->(GetArea())
 	DbSelectArea("ACG")
 	ACG->(DbSetOrder(1))	// ACG_FILIAL+ACG_CODIGO+ACG_PREFIX+ACG_TITULO+ACG_PARCEL+ACG_TIPO+ACG_FILORI 
 	If ACG->(DbSeek(xFilial("ACG") + ACF->ACF_CODIGO))
 		While !ACF->(EOF()) .AND. (ACG->ACG_FILIAL + ACG->ACG_CODIGO == xFilial("ACG") + ACF->ACF_CODIGO)
			If Empty(ACG->ACG_TITULO)
				RecLock("ACG",.F.)
				ACG->(DbDelete())
				ACG->(MsUnlock())			
			EndIf 
			ACG->(DbSkip())
		EndDo
	EndIf 	
 	RestArea(aAreaACG)
EndIf

Return
