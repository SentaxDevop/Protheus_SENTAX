#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: M410LIOK		|	Autor: Luis Paulo							|	Data: 02/05/2022	//
//==================================================================================================//
//	Descrição: PE para validar a linha do pedido de venda.                                          //
//                                                                                                  //
//==================================================================================================//
User Function M410LIOK()
Local lRet      := .T.
Local nPosPrd   := Ascan(Aheader,{|x| AllTrim(x[2]) == "C6_PRODUTO" })
Local nPosQtd   := Ascan(Aheader,{|x| AllTrim(x[2]) == "C6_QTDVEN" })

If !aCols[n,Len(aHeader)+1]	

    DbSelectArea("SB1")
    SB1->(dbSetOrder(1))
    SB1->(DbGoTop())
    If SB1->(DbSeek( xFilial("SB1") + Acols[n][nPosPrd] ) )
        
        If SB1->B1_XQTDMUL > 0
            If !(MOD(Acols[n][nPosQtd],SB1->B1_XQTDMUL)  == 0)
                    lRet := .F.
                    If !IsBlind()
                            MsgAlert("Este produto tem configuração para quantidades multiplas, ajuste a quantidade para ser multipla de "+ cValToChar(SB1->B1_XQTDMUL) +" ","SENTAX")
                        Else
                            Conout("Este produto tem configuração para quantidades multiplas, ajuste a quantidade para ser multipla de "+ cValToChar(SB1->B1_XQTDMUL) +" ")
                    EndIf
            EndIf
        EndIf

    EndIf

EndIf 

Return lRet
