#INCLUDE 'PROTHEUS.CH'
//----------------------------------------------------------------------------------------
/*/{Protheus.doc} MA103BUT
Permite ao usuário adicionar opções na barra de menus EnchoiceBar.
@author TOTVS
@return aButtons, Array (vetor) de opções de usuário
@description
O Ponto de Entrada MA103BUT, chamado a partir do código-fonte MATA103.PRW, 
permite ao usuário adicionar opções na barra de menus EnchoiceBar.
http://tdn.totvs.com.br/pages/releaseview.action?pageId=102269141
/*/
//----------------------------------------------------------------------------------------
User Function MA103BUT()

	Local aButtons := {}
                          
	If !INCLUI .AND.!ALTERA 
		aadd(aButtons, {'DEVOLNF', {||U_MCOM001()}, 'Chave NF-e'})
	EndIf

Return aButtons

//---------------------------------------------------------------------------------------------
//Ponto de entrada executado na vinculação do item do documento de entrada ao pedido de compras
//---------------------------------------------------------------------------------------------
User Function MT103IPC()

	Local aArea     := GetArea()    
	
	Local nLinha      := PARAMIXB[1]                                       
	
	Local nPCod       := aScan(aHeader,{|X| ALLTRIM(X[2]) == "D1_COD"})
	Local nPDescric   := aScan(aHeader,{|X| ALLTRIM(X[2]) == "D1_DESCRIC"})
	Local nPosXCODPRF := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_XCODPRF"})
	
	aCols[nLinha][nPDescric]  := Posicione("SB1",1,xFilial("SB1")+aCols[nLinha][nPCod],"B1_DESC")

	aCols[nLinha][nPosXCODPRF] := SC7->C7_XCODPRF

	

	RestArea(aArea)

Return(.T.)


// PEs NFACIL
//---------------------------------------------------------------------
/*/{Protheus.doc} MT100AGR
O ponto de entrada é chamado após a confirmação da NF, porém fora da transação. Isto foi feito pois clientes que utilizavam TTS e tinham interface com o usuario no ponto MATA100 "travavam" os registros utilizados, causando parada para outros usuarios que estavam acessando a base.

@author 	Alessandro Smaha
@since 		14/01/2016
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
User Function MT100AGR()

Local aArea	   := GetArea()  

If INCLUI .OR. ALTERA
	
	//Realiza a manifestação
	U_NFAC025(1)         

ElseIf !INCLUI .AND. !ALTERA

	// Atualiza o status do xml ingrado
	U_NFAC025(2) 	

EndIf

RestArea(aArea)

Return Nil
