#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//////////////////////////////////////////////////////////////////////
// Fonte criado para centralizar operações pontuais no Call Center //
/////////////////////////////////////////////////////////////////////

/*/{Protheus.doc} WHENSUC
    Função responsável por validar a edição dos campos na tabela SUC (SAC / Telemarketing)
    @type function
    @version 1.0
    @author Alfred Andersen
    @since 07/07/2023
    @requester Kleber Moro
    @consultancy Harpia
    @site www.harpiaconsultoria.com
/*/
User Function WHENSUC()

    Local lRet     as Logical
    Local cUser    as Character
    Local cUserSAC as Character

    lRet     := .F.
    cUser    := __cUserID
    cUserSAC := GetNewPar("ST_WHENSUC","000314|000374|000391") //Michele | Luana | Vitor

    IF !(INCLUI)

        IF cUser $ cUserSAC
            lRet := .T.
        END
    
    ELSE

        lRet := .T.

    END

Return lRet


/*/{Protheus.doc} CalcIPI
    Realiza o calculo do valor do IPI parea constar no relatório do orçamento o que consta na tela do call center 
    @type function
    @version 1.0
    @author Alfred Andersen
    @since 8/28/2024
/*/
User Function CalcIPI(cCodSUA)

    Local nTotalIPI := 0
    Local nItAtu    := 0
    Local aArea     := GetArea()

    If !(FWIsInCallStack( "U_Tmkr3A" ))

        DbSelectArea("SUA")
        SUA->(DbSetOrder(1))
        SUA->(DbSeek(FWxFilial("SUA")+(cCodSUA)))

    End

    DbSelectArea("SUB")
    SUB->(DbSetOrder(1))
    SUB->(DbSeek(FWxFilial("SUB")+cCodSUA))

    //Posiciona no cliente atual
    DbSelectArea("SA1")
    SA1->(DbSeek(FWxFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA))
    
    //Inicializa a função fiscal para poder simular os valores dos impostos
    MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "N", SA1->A1_TIPO, Nil, Nil, Nil, Nil, "MATA461")

    If !Empty(SA1->A1_NATUREZ)
        MaFisAlt("NF_NATUREZA",SA1->A1_NATUREZ)
    End

    While	(!Eof())							.AND.;
            xFilial("SUB") == SUB->UB_FILIAL	.AND.;
            SUA->UA_NUM    == SUB->UB_NUM

        nItAtu++
        
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbSeek(FWxFilial("SB1")+SUB->UB_PRODUTO))

        //Adicionando o produto para o cálculo dos impostos
        MaFisAdd(SB1->B1_COD, SUB->UB_TES, SUB->UB_QUANT, SUB->UB_VRUNIT, 0, "", "", , 0, 0, 0, 0, SUB->UB_VLRITEM, 0, SB1->(RecNo()))
        
        //Retorna a alíquota de IPI e de ICMS do item 1
        nAliqIPI := MaFisRet(nItAtu, 'IT_VALIPI')
        
        //Se tiver alíquota de IPI
        If(nAliqIPI > 0)
            
            nTotalIPI += nAliqIPI

        EndIf

        dbSelectArea("SUB")
        dbSkip()
    End

    //Encerra a função fiscal
    MaFisEnd()

    RestArea( aArea )

Return nTotalIPI
