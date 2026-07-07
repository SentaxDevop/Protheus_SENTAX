#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TKGRPED
Ponto de entrada executado antes de gravar um chamado de Televendas.
                
@sample		U_TKGRPED()

@author		Alessandro Smaha
@since		03/03/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function TKGRPED(	nLiquido, aParcelas, cOpera, cNum, ;
		cCodLig, cCodPagto, cOpFat, cCodTransp)

	Local lRetOk 	:= .T.
	Local cImpOper	:= GetMV("ST_XRISCEN",,"N") // Permite entregas por transportadora com endereco de entrega diferente do endereco fiscal? Ex. N ou S

	Local lExecuta := .T.
	Local nCount   := 1

	If Alltrim(FUNNAME()) <> 'RPC'
		lExecuta := .F.
	EndIf

	IF lExecuta
		For nCount := 1 to Len(ProcName())
			If Alltrim(ProcName(nCount)) == "U_M410STTS"
				lExecuta := .F.
			EndIf
		Next

		If lExecuta

			If M->UA_XENDDIF == "2" // 1=Não e 2=Sim

				If M->UA_XENTPRO == "1" // 1=Não e 2=Sim

					If MV_PAR45 <> SA1->A1_EST .AND. !Empty(MV_PAR45)  // MV_PAR45 Alimentado no PE TMKVCP.

						lRetOk := .F.

					ElseIf cImpOper == "N"

						lRetOk := .F.

					EndIf

				EndIf

			EndIf

			If ! lRetOk

				If IsBlind()

					cLogTxt := "NÃO É PERMITIDO ENTREGA EM ESTADO DIFERENTE DO ESTADO DA COMPRA DO CLIENTE. FAZER CONFORME EXIGÊNCIAS LEGAIS, UTILIZAR OPERAÇÃO "
					cLogTxt += "FISCAL PREVISTA EM LEI PARA ESTE PROCEDIMENTO, CASO TENHA DÚVIDAS, PROCURE O RESPONSÁVEL FISCAL PELA SUA EMPRESA. - [TKGRPED]"
					Conout(cLogTxt)

				Else

					MsgAlert(	"NÃO É PERMITIDO ENTREGA EM ESTADO DIFERENTE DO ESTADO DA COMPRA DO CLIENTE. FAZER CONFORME EXIGÊNCIAS LEGAIS, UTILIZAR OPERAÇÃO "+;
						"FISCAL PREVISTA EM LEI PARA ESTE PROCEDIMENTO, CASO TENHA DÚVIDAS, PROCURE O RESPONSÁVEL FISCAL PELA SUA EMPRESA.","Atenção")
				End

			Else // Verifica se endereço de entrega para Faturamento ou Orçamento

				If M->UA_OPER $ "12"
					If Empty(M->UA_ENDENT)

						If IsBlind()

							cLogTxt := "ENDEREÇO DE ENTREGA NÃO INFORMADO! - [TKGRPED]"
							Conout(cLogTxt)
							
						Else

							MsgAlert("ENDEREÇO DE ENTREGA NÃO INFORMADO!","Atenção")
						End

						lRetOk := .F.
					EndIf
				EndIf

			EndIf

		EndIf

	EndIf

Return lRetOk
