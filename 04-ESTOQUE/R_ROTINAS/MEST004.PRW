//Função para zerar o saldo de um armazem
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include 'Protheus.ch' 
#include "rwmake.ch"
#include "TOPCONN.ch"
#include "APWEBEX.CH"
#include "TBICONN.ch"
//==================================================================================================//
//	Programa: MEST004		|	Autor: Luis Paulo							|	Data: 24/10/2022	//
//==================================================================================================//
//	Descrição: Rotina para zerar saldo de armazem													//
//																									//
//==================================================================================================//
User Function MEST004()
//Variaveis Parambox
Local 		aParamBox 	:= {}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private 	oReport		:= Nil

If !(Alltrim(__cUserID) $ "000000/000217")
    MsgInfo("Você nâo tem permissão de acesso para esta rotinas", "Sentax")
    Return
EndIf

	AAdd(aParamBox, { 1,"Amz para baixa?"		,Space(2)       ,"","","NNR"	,"",0,.F.}) // Tipo caractere
    
If ParamBox(aParamBox,"Rotina de baixa de estoque", @aRet,, ,lCentered, , , , , .T., .T.)//@aRet Array com respostas - Par 11 salvar perguntas
    DbSelectArea("NNR")
    NNR->(DbSetOrder(1)) //NNR_FILIAL, NNR_CODIGO, R_E_C_N_O_, D_E_L_E_T_
    NNR->(DbGoTop())
    If NNR->(DbSeek( xFilial("NNR") + aRet[1]))
            If MsgYesNo("Você deseja realmente zerar o AMZ " + aRet[1],"Sentax")
                Processa({|| fBxAmz() },"Zerando saldos.....")   
            EndIf
        
        Else

    EndIf
     
Endif

Return()

Static Function fBxAmz()
Local aArea         := GetArea()
Local cQry          := ""
Local cAlias        := GetNextAlias()
Local cTmSai        := "599"
Local cTmEnt        := "099"
Local aCabec        := {}
Local aItem         := {}
Local aItens        := {}
Local cDocum        := ""
Local lMsErroAuto   := .F.
Local nQtd          := 0
Local lDesbloc	    := .f.
Local nCusto        := 0
Local nRegs         := 0
Local nCount        := ""

cQry  := " SELECT *
cQry  += " FROM SB2010
cQry  += " WHERE D_E_L_E_T_ = ''
cQry  += " AND B2_FILIAL = '"+ xFilial("SB2")+"'
cQry  += " AND B2_LOCAL = '"+ aRet[1]+"'
cQry  += " AND B2_QATU <> 0

TcQuery cQry New Alias (cAlias)
Count to nRegs

DbSelectArea((cAlias))
(cAlias)->(DbGoTop())

ProcRegua(nRegs)
While !(cAlias)->(EOF())
    If cFilant != (cAlias)->B2_FILIAL
        cFilant		:= 	(cAlias)->B2_FILIAL				//Seta a filial correta
        aArea 		:= 	SM0->(GetArea())			//Ajusta SM0

        SM0->(DbSeek( cEmpAnt + (cAlias)->B2_FILIAL ) )//Seta SM0 correta
        If !RpcSetEnv(SM0->M0_CODIGO, (cAlias)->B2_FILIAL)
            MsgAlert("Empresa nao localizada")
            return
        EndIf

    EndIf

    nCount++ 
    IncProc('Processando Saldo Atu Contas  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )

    lDesbloc	:= .f.

    DbSelectArea("SB1")
	SB1->(DbSetOrder(1) ) //B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
	SB1->(DbGoTop())
	If SB1->(DbSeek( xFilial("SB1") + (cAlias)->B2_COD	) ) //Mudando o produto para controlar endereco
		
		If Alltrim(SB1->B1_MSBLQL) == "1" 
			Reclock("SB1",.F.)
			SB1->B1_MSBLQL := "2"
			SB1->(MsUnLock())
			lDesbloc	:= .T.
		EndIf
		
	EndIf

    dDataBase   := STOD("20221026")
    cDocum		:= NextNumero("SD3",2,"D3_DOC",.T.)

    aCabec  := {}
    aItem   := {}
    aItens  := {}

    aAdd(aCabec, {"D3_DOC"		,cDocum			,Nil})
    If (cAlias)->B2_QATU < 0
            aAdd(aCabec, {"D3_TM"		,cTmEnt	,Nil})
        Else 
            aAdd(aCabec, {"D3_TM"		,cTmSai ,Nil})
    EndIf
    aAdd(aCabec, {"D3_EMISSAO"	,dDataBase		,Nil})
    	
    nQtd    := Abs( (cAlias)->B2_QATU - (cAlias)->B2_QTNP)
    nCusto  :=  ( nQtd * (cAlias)->B2_CM1 )

    If nCusto <= 0
        nCusto := 0.1
    EndIf

    aAdd(aItem, {"D3_COD"		,(cAlias)->B2_COD		            ,Nil})	
    aAdd(aItem, {"D3_QUANT"		, nQtd		                        ,Nil})
    aAdd(aItem, {"D3_CUSTO1"	, nCusto	                        ,Nil})
    aAdd(aItem, {"D3_LOCAL"		,(cAlias)->B2_LOCAL		            ,Nil})		
    //aAdd(aItem, {"D3_LOCALIZ"	,(cAlias)->ZD3_ENDORI		,Nil})		
    aAdd(aItem, {"D3_OBSERVA"	,"ZERAR SLD AMZ "+ aRet[1]+" - " + DTOC(dDataBase)      ,Nil})

    // Adiciona o array item no array dos itens para ficar na sintaxe correta.
    aAdd(aItens, aItem)
    If (Len(aCabec) > 0) .And. (Len(aItens)>0)

        // Rotina padrao para movimento interno (mod.2)
        lMsErroAuto := .F.		
        MSExecAuto({|x,y,z| Mata241(x,y,z)},aCabec,aItens,3)

        If lMsErroAuto
            MOSTRAERRO()
            return
        EndIf

    EndIf

    If lDesbloc //Se desbloqueou o produto, bloqueia novamente
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1) ) //B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
		SB1->(DbGoTop())
		If SB1->(DbSeek( xFilial("SB1") + (cAlias)->B2_COD) ) //Mudando o produto para controlar endereco
			If Alltrim(SB1->B1_MSBLQL) == "2" 
				Reclock("SB1",.F.)
				SB1->B1_MSBLQL := "1"
				SB1->(MsUnLock())
			EndIf
		EndIf
	EndIf

    (cAlias)->(DbSkip())
EndDo


RestArea(aArea)
Return()
