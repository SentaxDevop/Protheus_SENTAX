#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TMKVCP
Ponto de Entrada após o fechamento da tela de condição de pagamento, 
independente de confirmação ou cancelamento
                
@sample		U_TMKVCP()

@author		Alessandro Smaha
@since		03/03/2015
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function TMKVCP(	cCodTransp	,oCodTransp		,cTransp	,oTransp,;
						cCob		,oCob			,cEnt		,oEnt,;
						cCidadeC	,oCidadeC		,cCepC		,oCepC,;
						cUfC		,oUfC			,cBairroE	,oBairroE,;
						cBairroC	,oBairroC		,cCidadeE	,oCidadeE,;
						cCepE		,oCepE			,cUfE		,oUfE,;
						nOpc		,cNumTlv		,cCliente	,cLoja,;
						cCodPagto	,aParcelas)

Local lRetOk 	:= .T.
Local cImpOper	:= GetMV("ST_XRISCEN",,"N") // Permite entregas por transportadora com endereco de entrega diferente do endereco fiscal? Ex. N ou S
         
If Alltrim(Upper(SA1->A1_END)) == Alltrim(Upper(cEnt)) .AND. ; 				// ENDEREÇO, BAIRRO, CIDADE, CEP, UF   
		Alltrim(Upper(SA1->A1_BAIRRO)) == Alltrim(Upper(cBairroE)) .AND. ; 
		Alltrim(Upper(SA1->A1_MUN))	== Alltrim(Upper(cCidadeE)) .AND. ; 
		Alltrim(SA1->A1_CEP) == Alltrim(cCepE) .AND. ; 
		Alltrim(Upper(SA1->A1_EST))	== Alltrim(Upper(cUfE)) 

	M->UA_XENDDIF := "1" // 1=Não e 2=Sim 
	
Else
	          
	M->UA_XENDDIF := "2" 
	
	MV_PAR45 := cUfE // Guarda nesta var para utilizar no PE TKGRPED do TMKA273D.PRW.
	
	If Alltrim(Upper(SA1->A1_EST)) <> Alltrim(Upper(SA1->A1_ESTE)) .AND. cImpOper == "S" .AND. M->UA_XENTPRO == "1" // 1=Não e 2=Sim
	    
   		cEnt 		:= SA1->A1_ENDENT   
   		cBairroE	:= SA1->A1_BAIRROE  
   		cCidadeE	:= SA1->A1_MUNE              
   		cCepE		:= SA1->A1_CEPE
   		cUfE		:= SA1->A1_ESTE
	
	EndIf
            
EndIf 

If M->UA_OPER $ "12" // Atribui a variável de memória para validar no PE TKGRPED...
	M->UA_ENDENT := cEnt
EndIf

Return lRetOk



//-------------------------------------------------------------------
/*/{Protheus.doc} TMKTRANS
Ponto de entrada permite ao usuário a escolha da transportadora e 
dos dados de entrega de acordo com alguma regra de negócio 
específica.
                
@sample		U_TMKTRANS()

@author		Alessandro Smaha
@since		13/09/2016
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function TMKTRANS(aRetTrans)

Local nK := 0

If !Empty(aRetTrans)
	For nK := 1 to Len(aRetTrans)
		If ValType(aRetTrans[nK]) <> "C"
			Loop
		Else 
			Do Case
				Case nK == 3 
					aRetTrans[nK] := SA1->A1_ENDENT					
				Case nK == 4 
					aRetTrans[nK] := SA1->A1_BAIRROE
				Case nK == 5 
					aRetTrans[nK] := SA1->A1_MUNE
				Case nK == 6 
					aRetTrans[nK] := SA1->A1_CEPE
				Case nK == 7 
					aRetTrans[nK] := SA1->A1_ESTE
			Endcase
		Endif
	Next nK
EndIf

Return aRetTrans
