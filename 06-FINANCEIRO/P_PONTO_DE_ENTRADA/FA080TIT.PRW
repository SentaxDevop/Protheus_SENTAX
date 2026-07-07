#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"
//==================================================================================================//
//	Programa: FA080TIT		|	Autor:Luis				                    |	Data: 01/08/2022	//
//==================================================================================================//
//	Descrição: O ponto de entrada FA080TIT sera utilizado na confirmacao da tela de baixa do contas //
// a pagar, antes da gracacao dos dados.															//
//==================================================================================================//
User Function FA080TIT()
Local lRet			:= .T.

If !IsBLind()
    If Type("_cBanco") != "U"
        _cBanco     := cBanco
        _cAgenci    := cAgencia
        _cConta     := cConta
        _cCheque    := cCheque
        _cMotBx     := cMotBx
    EndIf 
    
EndIf 

Return(lRet)
