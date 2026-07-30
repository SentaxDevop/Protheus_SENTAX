#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"
//==================================================================================================//
//	Programa: FA080POS		|	Autor:Luis				                    |	Data: 01/08/2022	//
//==================================================================================================//
//	Descrição: O ponto de entrada FA080POS é chamado apos carregar os dados do titulo a ser baixado,//
// antes da visualização de informações na tela. Deste modo será possível alterar variavéis de 		//
// memória com os dados do título. Variáveis disponibilizadas : cBanco , cAgencia, cConta, cCheque	//
//==================================================================================================//
User Function FA080POS()

If !IsBLind()
    IF Type("_cBanco") == "U" //Não existe a variavel.
            Public _cBanco  := ""
            Public _cAgenci := ""
            Public _cConta  := ""
            Public _cCheque := ""
            Public _cMotBx  := ""
            Public _cFilAnt := ""
        Else
            If cFilAnt <> _cFilAnt
                cBanco      := ''
                cAgencia    := ''
                cConta      := ''
                cCheque     := ''
                cMotBx      := ''
            Else
                //SA6->A6_BLOCKED<>'1' .AND. (IIF(CFILANT=='020204' .OR. CFILANT=='020203',SA6->A6_XFILIAL=='020201',SA6->A6_XFILIAL==CFILANT) .OR. EMPTY(SA6->A6_XFILIAL))                                                                                                 
                DbSelectArea("SA6")
                SA6->(DbSetOrder(1)) //A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, R_E_C_N_O_, D_E_L_E_T_
                SA6->(DbGoTop())
                If SA6->(DbSeek( xFilial("SA6") + _cBanco + _cAgenci + _cConta))
                    If Alltrim(SA6->A6_BLOCKED) <> '1' .AND. (IIF(CFILANT=='020204' .OR. CFILANT=='020203' .OR. CFILANT=='020207',SA6->A6_XFILIAL=='020201',SA6->A6_XFILIAL==CFILANT) .OR. EMPTY(SA6->A6_XFILIAL)) 
                        cBanco      := _cBanco
                        cAgencia    := _cAgenci
                        cConta      := _cConta
                        cCheque     := _cCheque
                        cMotBx      := _cMotBx
                    EndIf 

                EndIf 
            End
    EndIF

EndIf

Return()
