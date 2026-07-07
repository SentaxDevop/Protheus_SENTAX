#INCLUDE "PROTHEUS.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} NFA015MN
Ponto de Entrada para incluir rotina no menu do CT-e
                
@sample		U_NFA015MN()

@author		Alessandro Smaha
@since		14/01/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
//User Function NFA015MN()
//
//Local aTempRot := PARAMIXB[1]
//
//aAdd( aTempRot, { "Pré-Nota Autom.", "U_ACOM001()", 0, 2 })
//
//Return aTempRot


//-------------------------------------------------------------------
/*/{Protheus.doc} NFA015CM
Ponto de Entrada para tratar itens lançados na pré nota do CT-e
                
@sample		U_NFA015CM()

@author		Alessandro Smaha
@since		22/06/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function NFA015CM()

Local aTempAux := PARAMIXB[1]                                             
Local cTesPro  := Alltrim(GetMv("NF_TESCTE",,""))
Local cPrdPedg := AllTrim(GetMV("NF_XPRDPDG",,""))
Local cTesPedg := AllTrim(GetMV("NF_XTESPDG",,""))
Local nPosPrd  := AScan(aTempAux[1],{|x| AllTrim(Upper(x[1])) == "D1_COD" })
Local nPosCta  := AScan(aTempAux[1],{|x| AllTrim(Upper(x[1])) == "D1_CONTA" })
Local nPosCC   := AScan(aTempAux[1],{|x| AllTrim(Upper(x[1])) == "D1_CC" })  
Local nPosTes  := AScan(aTempAux[1],{|x| AllTrim(Upper(x[1])) == "D1_TES" })  
Local cCodPro  := ""
Local nK       := 0
Local lPrdPedg := .F.   

If nPosCta > 0 
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
	For nK := 1 to Len(aTempAux)
		cCodPro := aTempAux[nK][nPosPrd][2]
		If SB1->(DbSeek(xFilial("SB1") + cCodPro))	
	    	aTempAux[nK][nPosCta][2] := SB1->B1_CONTA
			aTempAux[nK][nPosCC][2]  := SB1->B1_CC
		EndIf
	Next nK
EndIf

If nPosTes > 0 
	For nK := 1 to Len(aTempAux)
		cCodPro := aTempAux[nK][nPosPrd][2]
		If SB1->(DbSeek(xFilial("SB1") + cCodPro)) .And. AllTrim(cCodPro) == cPrdPedg	
			aTempAux[nK][nPosTes][2] := cTesPedg
			lPrdPedg := .T.
		Else
			aTempAux[nK][nPosTes][2] := cTesPro
		EndIf
	Next nK
	
	If lPrdPedg
		For nK := 1 to Len(aTempAux)
			cCodPro := aTempAux[nK][nPosPrd][2]
			If SB1->(DbSeek(xFilial("SB1") + cCodPro)) .And. AllTrim(cCodPro) != cPrdPedg	
				aTempAux[nK][nPosTes][2] := "016"
			EndIf
		Next nK
	EndIf
EndIf

Return aTempAux
