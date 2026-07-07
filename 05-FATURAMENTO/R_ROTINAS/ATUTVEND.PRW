#include "totvs.ch"
#include "topconn.ch"
#Include 'Protheus.ch'
//==================================================================================================//
//	Programa: ATUTVEND		|	Autor: Luis Paulo							|	Data: 17/05/2022	//
//==================================================================================================//
//	Descrição: Para alterar o vendedor do cadastro de cliente.                                      //
//                                                                                                  //
//==================================================================================================//
User Function ATUTVEND()
Local aArea         := GetArea()
Local 	aParamBox 	:= {}
Private aRet 		:= {}
Private lCentered	:= .T.

AAdd(aParamBox, { 1, "Vendedor Origem?"			    ,Space(6),"","","SA3"	,"",0,.F.}) // Tipo caractere
AAdd(aParamBox, { 1, "Vendedor Destino?"			,Space(6),"","","SA3"	,"",0,.F.}) // Tipo caractere

If ParamBox(aParamBox,"Transferencia de carteira de vendedor", @aRet,, ,lCentered, , , , , .T., .T.)//@aRet Array com respostas - Par 11 salvar perguntas
    AtuVend()
Endif

RestArea(aArea)
Return()


Static Function AtuVend()
Local lRet  := .t.
Local cQry  := ""
Local cErro := ""

DbSelectArea("SA3")
SA3->(DbSetOrder(1))
SA3->(DbGoTop())
If !SA3->(DbSeek(xFilial("SA3") + aRet[1]))
    lRet := .f.
EndIf

DbSelectArea("SA3")
SA3->(DbSetOrder(1))
SA3->(DbGoTop())
If !SA3->(DbSeek(xFilial("SA3") + aRet[2]))
    lRet := .f.
EndIf

If lRet 
        cQry := "UPDATE SA1010 SET A1_VEND = '"+aRet[2]+"' WHERE D_E_L_E_T_ = '' AND A1_VEND = '"+aRet[1]+"' "
        If TCSqlExec(cQry) < 0
                
                cErro := TCSQLError()

                Conout("")
                Conout("TCSQLError() " + cErro)
                Conout("")

                MsgInfo(cErro,"SENTAX")
            Else 
                MsgInfo("Finalizado!","SENTAX")
        EndIf 

    Else
        MsgAlert("Verifique o número dos vendedores, pois um deles ou os dois estão errados!","SENTAX")
EndIf 

Return()
