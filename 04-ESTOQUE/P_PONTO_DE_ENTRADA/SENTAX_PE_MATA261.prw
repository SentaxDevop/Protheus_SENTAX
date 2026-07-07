#INCLUDE "rwmake.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MA261LIN()
VALIDAÇÃO ADICIONAL NAS LINHAS DA GETDADOS
LOCALIZAÇÃO   : Localizado no final da função A261LinOk( ) .
EM QUE PONTO : E chamado no final da validação da função A261LinOk( ),
que sera chamado para cada linha de transferencia incluida no Browse.
Pode ser utilizado para validar o movimento.

@return 	lógico
@author João E. Lopes
@since 12/08/2019
@version P12
/*/
//-------------------------------------------------------------------

User function MA261LIN()

Local lRet     := .T.
Local nLin 	   := PARAMIXB[1]
Local lUsrOk   := RetCodUsr() $ GETMV("SX_USRTRAN", , "000000" )

Local lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

// Como há duplicidade dos mesmos campos na linha, deve-se usar colunas fixas (como definido no MATA261)
Local nPosCODOri  := 1 					//Codigo do Produto Origem
Local nPosCODDes  := 6 					//Codigo do Produto Destino
Local nPosLOCOri  := 4					//Armazem Origem
Local nPosLOCDes  := Iif(!lPyme,9,8)	//Armazem Destino
//Local nPosLoTCTL  := Iif(!lPyme,12,9)	//Lote de Controle
//Local nPosLotDes  := Iif(!lPyme,20,17)  //Lote Destino
//Local nPosQUANT	  := Iif(!lPyme,16,13)	//Quantidade

// Variaveis para validação do motivo da transferência.  // Joao 03/09/2015
Local cLocOri     := aCols[nLin,nPosLOCOri]
Local cLocDes     := aCols[nLin,nPosLOCDes]
Local cCodOri     := aCols[nLin,nPosCODOri]
Local cCodDes     := aCols[nLin,nPosCODDes]


IF !aCols[nLin,LEN(aCols[nLin])] 
	
	If !lUsrOk

		// Mesmo os usuário tendo permissao para transferência, não poderá executar se o Armazém de origem for 80.
		IF aCols[nLin,nPosLOCOri]=="80"
			MsgAlert("Não é possivel realizar transferência de estoque cujo o local de origem é "+ALLTRIM(aCols[nLin,nPosLOCOri])+" !","AMZORIG-MA261LINB")
			lRet := .F.
		EndIf
		
		// Conferi se produto de origem e destino são diferentes.
		If Alltrim(cCodOri) <> Alltrim(cCodDes)
			// Se usuário estiver permitido a realizar transferência no parâmetro ST_XUSRTRO e Codigo de origem e destino for diferente, permite a transferência.
			If !(__CUserId $ ALLTRIM(GETMV("ST_XUSRTRF")))
				MsgAlert("Produto de origem: "+ALLTRIM(aCols[nLin,nPosCODOri])+" diferente do produto de destino: " +ALLTRIM(aCols[nLin,nPosCODDes])+", transferência não permitida para usuário: "+__CUserId+"!","PRODDIF-MA261LINC")
				//	APMSGALERT("Usuário não autorizado a realizar transfências de estoque no sistema!","XUSRTRF-MA261LINA")
				lRet := .F.
			EndIf
		EndIf

	EndIf
	
EndIf

Return lRet
