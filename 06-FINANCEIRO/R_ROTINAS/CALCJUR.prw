#include "Protheus.ch"
#include "FWMVCDEF.CH" 
//==================================================================================================//
//	Programa: CALCJURS		|	Autor: Luis Paulo							|	Data: 24/10/2022	//
//==================================================================================================//
//	Descrição: Funcao para calcular os juros do boleto Santander									//
//	-																								//
//==================================================================================================//
User Function CALCJURS()
    Local cRet := "000000000000000" //15,2
    Local nVlr := 0
    Local nTam := 13

    If !Empty(SE1->E1_PORCJUR)
        nVlr := (((SE1->E1_SALDO + SE1->E1_ACRESC) - SE1->E1_DECRESC) * SE1->E1_PORCJUR )
    else
        nVlr := ((((SE1->E1_SALDO + SE1->E1_ACRESC) - SE1->E1_DECRESC) * 0.06 ) / 30) //Multiplica pelo percentual de 6% mes e depois divide por 30
    End

    If nVlr < 0.01
        nVlr := 0.01
    EndIf 

    If SE1->E1_PORTADO == '033'
        nTam := 15
    End
        
    cRet := StrZero( If(!Empty(SE1->E1_PORCJUR),nVlr,(nVlr * 100)), nTam)

Return(cRet)
