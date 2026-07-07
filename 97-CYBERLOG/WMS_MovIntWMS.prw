//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
 
//Variáveis Estáticas
Static cTitulo := "Movimentações Internas ERP x WMS CyberLog"
   
User Function CadZA8MI
    Local aArea   := GetArea()
    Local oBrowse

    Private bLeg:= {||fLeg()}
    Private bVJson:= {||fVJson()}
    Private bEJson:= {||fMovInt()} 

    //Cria um browse para a ZA8
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZA8")
    oBrowse:SetDescription(cTitulo)
    oBrowse:setMenuDef('WMS_MOVINTWMS')
    oBrowse:SetFilterDefault( 'ZA8->ZA8_TIPO == "MI"' )
    oBrowse:SetUseFilter(.T.)
    oBrowse:DisableDetails()

	oBrowse:AddLegend( "ZA8->ZA8_STAWMS == ' ' "		,"BR_BRANCO"    ,"Não Enviado" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'E' "		,"BR_AZUL"      ,"Enviado" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'R' "		,"BR_AZUL_CLARO","Reenviado" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'F' "		,"BR_VERMELHO"  ,"Falha no Envio" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'X' "		,"BR_PRETO"     ,"Falha no retorno" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'O' "		,"BR_VERDE"     ,"Retorno com Sucesso" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'C' "		,"BR_CANCEL"    ,"Estornado" )
    
    oBrowse:Activate()
      
    RestArea(aArea)
Return Nil
 
  //-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} MenuDef
Menudef
@type function
@version 12.1.27
@author Carlos Cleuber
@since 30/01/2021
/*/ 
Static Function MenuDef()
    Local aRot := {}
      
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar'                          ACTION 'VIEWDEF.WMS_MOVINTWMS'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'                             ACTION 'VIEWDEF.WMS_MOVINTWMS'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'                             ACTION 'VIEWDEF.WMS_MOVINTWMS'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'                             ACTION 'VIEWDEF.WMS_MOVINTWMS'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    //ADD OPTION aRot TITLE "CyberLog - Valida JSon WMS"	        ACTION 'eval(bVJson)'                   OPERATION 9                      ACCESS 0 
    //ADD OPTION aRot TITLE "CyberLog - Envia Mov.Int. JSon WMS"	ACTION 'eval(bEJson)'                   OPERATION 9                      ACCESS 0 
    // Alterado por Júlio Soares em 09/03/2021
    ADD OPTION aRot TITLE "Valida Envio WMS"	                ACTION 'eval(bVJson)'                   OPERATION 9                      ACCESS 0 
    ADD OPTION aRot TITLE "Envia Mov.Int. WMS"	                ACTION 'eval(bEJson)'                   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 
    ADD OPTION aRot Title 'Legenda'                             ACTION 'eval(bLeg)'			            OPERATION 9                      ACCESS 0
    
Return aRot
 
 //-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version 12.1.27 
@author Carlos Cleuber
@since 30/01/2021
/*/ 
Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente 3 campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel    := NIL
    Local oStruCab  := FWFormStruct(1, 'ZA8')
    Local oStruGrid := FWFormStruct(1, 'ZA8')
    Local aRelation := {}
 
    //Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
    oModel := MPFormModel():New('MdlZA8M',/*bPreValidacao*/, {|oModel| fVldTOK(oModel)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    oStruCab:removeField("ZA8_FILIAL")
    oStruCab:removeField("ZA8_ITEM")
    oStruCab:removeField("ZA8_PRODUT")
    oStruCab:removeField("ZA8_DESC")
    oStruCab:removeField("ZA8_UM")
    oStruCab:removeField("ZA8_ARMORI")
    oStruCab:removeField("ZA8_ENDORI")
    oStruCab:removeField("ZA8_ARMDES")
    oStruCab:removeField("ZA8_ENDDES")
    oStruCab:removeField("ZA8_LOTECT")
    oStruCab:removeField("ZA8_DTVALID")
    oStruCab:removeField("ZA8_QUANT")
    oStruCab:removeField("ZA8_STAWMS")
    oStruCab:removeField("ZA8_TM")
    oStruCab:removeField("ZA8_CF")    

    oStruGrid:removeField("ZA8_FILIAL")
    oStruGrid:removeField("ZA8_DOC")
    //Alterado por Júlio Soares em 11/03/2021
    //oStruGrid:removeField("ZA8_ARMDES")
    oStruGrid:removeField("ZA8_EMISSA")
    oStruGrid:removeField("ZA8_USRREQ")
    oStruGrid:removeField("ZA8_TIPO")
        
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('CabZA8', NIL, oStruCab)
    oModel:AddGrid('GridZA8', 'CabZA8', oStruGrid )

    //Adiciona o relacionamento de Filho, Pai
	aAdd(aRelation, {'ZA8_FILIAL', 'Iif(!INCLUI, ZA8_FILIAL, FWxFilial("ZA8"))'} )
	aAdd(aRelation, {'ZA8_DOC'  , 'Iif(!INCLUI, ZA8_DOC, ZA8_DOC  )'} ) 


    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('GridZA8', aRelation, ZA8->(IndexKey(1)))
      
    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("GridZA8"):SetMaxLine(999)
    oModel:SetDescription("Transferencias entre Protheus X WMS CyberLog")
    oModel:SetPrimaryKey({})
 
Return oModel

//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} ViewDef
Viewdef
@type function
@version 12.1.27
@author Carlos Cleuber
@since 30/01/2021
/*/ 
Static Function ViewDef()
    Local oModel    := ModelDef() 
    Local oView     := FWFormView():New() 
    Local oStruCab  := FWFormStruct(2, "ZA8")
    Local oStruGRID := FWFormStruct(2, "ZA8")

    oStruCab:removeField("ZA8_FILIAL")
    oStruCab:removeField("ZA8_ITEM")
    oStruCab:removeField("ZA8_PRODUT")
    oStruCab:removeField("ZA8_DESC")
    oStruCab:removeField("ZA8_UM")
    oStruCab:removeField("ZA8_ARMORI")
    oStruCab:removeField("ZA8_ENDORI")
    oStruCab:removeField("ZA8_ARMDES")
    oStruCab:removeField("ZA8_ENDDES")
    oStruCab:removeField("ZA8_LOTECT")
    oStruCab:removeField("ZA8_DTVALI")
    oStruCab:removeField("ZA8_QUANT")
    oStruCab:removeField("ZA8_STAWMS")
    oStruCab:removeField("ZA8_TM")    
    oStruCab:removeField("ZA8_CF")    

    oStruGrid:removeField("ZA8_FILIAL")
    oStruGrid:removeField("ZA8_DOC")
    oStruGrid:removeField("ZA8_EMISSA")
    oStruGrid:removeField("ZA8_ARMDES")
    oStruGrid:removeField("ZA8_ENDDES")
    oStruGrid:removeField("ZA8_USRREQ")
    oStruGrid:removeField("ZA8_STAWMS")
    oStruGrid:removeField("ZA8_TIPO")
 
    //Cria o View
    oView:SetModel(oModel)              
 
    //Cria uma área de Field vinculando a estrutura do cabeçalho com CabZA8, e uma Grid vinculando com GridZA8
    oView:AddField('VIEW_ZA8', oStruCab, 'CabZA8')
    oView:AddGrid ('GRID_ZA8', oStruGRID, 'GridZA8' )
 
    //O cabeçalho (MAIN) terá 15% de tamanho, e o restante de 85% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 15)
    oView:CreateHorizontalBox("GRID", 85)
 
    //Vincula o MAIN com a VIEW_ZA8 e a GRID com a GRID_ZA8
    oView:SetOwnerView('VIEW_ZA8', 'MAIN')
    oView:SetOwnerView('GRID_ZA8', 'GRID')

    //Define o campo incremental da grid como o ZA8_ITEM
    oView:AddIncrementField('GRID_ZA8', 'ZA8_ITEM')
Return oView


//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} fVldTOK
Funcao Validacao dos campos
@type function
@version 12.1.27
@author Carlos Cleuber
@since 30/01/2021
/*/ 
Static Function fVldTOK(oModel)
Local oModelGRID    := FWModelActive()
Local aSaveLine 	:= FWSaveRows()
Local cEndERP	    := alltrim(SuperGetMV("FZ_XENDERP"))
Local cEndWMS	    := alltrim(SuperGetMV("FZ_XENDWMS"))
Local cArmERP       := substr(cEndERP,1,2)
Local cArmWMS       := substr(cEndWMS,1,2)
Local cArmOri	    := ''
Local cProduto	    := ''
Local nDeletados    := 0
Local nLinAtual     := 0
Local lRet  		:= .T.
Local _x            := 1

If lRet
    //Percorrendo todos os itens da grid
    For nLinAtual := 1 To oModelGRID:GetModel("GridZA8"):Length() 
        //Posiciona na linha
        oModelGRID:GetModel("GridZA8"):GoLine(nLinAtual) 
        /*
        cArmOri	    := oModel:GetModel('GridZA8'):GetValue('ZA8_ARMORI')
        cProduto	:= oModel:GetModel('GridZA8'):GetValue('ZA8_PRODUT')        
        
        If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+cProduto,1) != "S"
            lRet :=.F.
            Help( , , 'Produto' , , '[Linha'+ cvaltochar(nLinAtual)+ '] - Produto não esta configurado para integração com WMS Cyberlog!', 1, 0, , , , , , {"Favor utilizar um produto valido para integração!"})        
        Endif
        If lRet .and. !cArmOri $ cArmERP .and. !cArmOri $ cArmWMS
            lRet :=.F.
            Help( , , 'Armazém Origem' , , '[Linha'+ cvaltochar(nLinAtual)+ '] - Armazém Origem não esta configurado para integração com WMS Cyberlog!', 1, 0, , , , , , {"Favor utilizar um armazém valido para integração!"})
        Endif
        */
        // Trecho alterado por Júlio Soares em 11/03/2021
        cProduto	:= oModel:GetModel('GridZA8'):GetValue('ZA8_PRODUT')        
        cArmOri	    := oModel:GetModel('GridZA8'):GetValue('ZA8_ARMORI')
        cArmDes	    := oModel:GetModel('GridZA8'):GetValue('ZA8_ARMDES')
        _aLocERP := StrTokArr(getmv('FZ_XENDERP'),';')
        
        for _x := 1 to len (_aLocERP)
            if _x == 1
                cEnderp := substr(_aLocERP[_x],1,2)
            else
                cEnderp += '/'+ substr(_aLocERP[_x],1,2)
            endif
        next

        _aLocWMS := StrTokArr(getmv('FZ_XENDWMS'),';')
        for _x := 1 to len (_aLocWMS)
            if _x == 1
                cEndwms := substr(_aLocWMS[_x],1,2)
            else
                cEndwms += '/'+ substr(_aLocWMS[_x],1,2)
            endif
        next

        /*If lRet .and. !cArmOri $ cEnderp .and. !cArmDes $ cEndwms
            lRet :=.F.
            Help( , , 'Armazém Origem' , , '[Linha'+ cvaltochar(nLinAtual)+ '] - Armazém Origem não esta configurado para integração com WMS Cyberlog!', 1, 0, , , , , , {"Favor utilizar um armazém valido para integração!"})
        Endif*/
        // Fim alteração Júlio Soares

        //Se a linha for excluida, incrementa a variável de deletados, senão irá incrementar o valor digitado em um campo na grid
        If oModelGRID:GetModel("GridZA8"):IsDeleted()
            nDeletados++
        EndIf
    Next nLinAtual

    //Se o tamanho da Grid for igual ao número de itens deletados, acusa uma falha
    If oModelGRID:GetModel("GridZA8"):Length()==nDeletados
        lRet :=.F.
        Help( , , 'Dados Inválidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha válida!"})
    EndIf
        
Endif

//FWRestRows( aSaveLine )

Return lRet


//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} fVJson
Rotina para mostrar o Json do Lote
@version 12.1.27
@type function
@author Carlos CLeuber
@since 31/01/2021
/*/
Static Function fVJson
Local cJson:= ''
Local cKey:= ZA8->(ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT)

cJson:= U_fGrJson( GetMv('FZ_WSWMS8'), 'ZA8', 1, 'ZA8_FILIAL+ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT', FWxFilial('ZA8')+cKey )
EECVIEW( cJson )

Return

//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} fExpTrf
Função para exportar os registros 
@type function
@author Carlos CLeuber
@since 31/01/2021
@version 12.1.27
/*/
Static Function fMovInt()
Local aZA8          := GetArea()
Local aCabMv        := {}
Local aItemMv       := {}
Local aToTItMv      :={}

Local cFilZa8       := ZA8->ZA8_FILIAL
Local cCodSol		:= ZA8->ZA8_DOC
Local cDoc          := ""

Private cCodigoTM   := ZA8->ZA8_TM
Private cCodProd    := ZA8->ZA8_PRODUT
Private cUnid       := ZA8->ZA8_UM

Private lMsErroAuto := .f.
Private lMsHelpAuto := .T. // se .t. direciona as mensagens de help

DbSelectArea("ZA8")
ZA8->(DbSetOrder(1)) //ZA8_FILIAL, ZA8_DOC, ZA8_ITEM, ZA8_PRODUT, ZA8_LOTECT, R_E_C_N_O_, D_E_L_E_T_
ZA8->(DbGoTop())
If ZA8->(DbSeek(cFilZa8 + cCodSol))
    
    While !ZA8->(EOF()) .And. ZA8->ZA8_FILIAL == cFilZa8  .And. ZA8->ZA8_DOC == cCodSol
        
        nRec := ZA8->(RECNO())
        
        If Alltrim(ZA8->ZA8_STAWMS) == "E"
            ZA8->(DbSkip())
            Loop
        EndIf
         
        cDoc        := NextNumero("SD3",2,"D3_DOC",.T.)
        
        aCabMv      := {}
        aToTItMv    := {}
        aItemMv     := {}

        aAdd(aCabMv,{"D3_DOC"       ,cDoc               , NIL})
        aAdd(aCabMv,{"D3_TM"        ,ZA8->ZA8_TM        , NIL})
        aAdd(aCabMv,{"D3_EMISSAO"   ,ZA8->ZA8_EMISSA    , NIL})
        //aAdd(aCabMv,{"D3_CC" ,"        ", NIL})

        aAdd(aItemMv,{"D3_COD"       ,ZA8->ZA8_PRODUT    ,NIL})
        aAdd(aItemMv,{"D3_QUANT"     ,ZA8->ZA8_QUANT     ,NIL})
        aAdd(aItemMv,{"D3_LOCAL"     ,ZA8->ZA8_ARMORI    ,NIL})
        //aAdd(aItemMv,{"D3_UM"        ,ZA8->ZA8_PRODUT    ,NIL})
        //aAdd(aItemMv,{"D3_LOTECTL"   ,ZA8->ZA8_LOTECT    ,NIL})
        //aAdd(aItemMv,{"D3_LOCALIZ"   ,ZA8->ZA8_ENDORI    ,NIL})


        aAdd(aToTItMv,aItemMv) 
        
        lMsErroAuto := .f.
        lMsHelpAuto := .t. // se .t. direciona as mensagens de help

        MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabMv,aToTItMv,3)
        If lMsErroAuto 
                MostraErro("") 
            
            Else
                cKey:= ZA8->(ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT)
                //GetMv('FZ_WSWMS8') == "007"
                aRet:= U_fConJson(GetMv('FZ_WSWMS8'), 'ZA8', 1, 'ZA8_FILIAL+ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT', FWxFilial('ZA8') + cKey )
                If aRet[1]
                        DbSelectArea("ZA8")
                        ZA8->(DbGoTop())
                        ZA8->(DbGoTo(nRec))
                        
                        RecLock("ZA8",.F.)
                        ZA8->ZA8_STAWMS:= "E"
                        ZA8->(MsUnlock())
                    
                    Else
                        DbSelectArea("ZA8")
                        ZA8->(DbGoTop())
                        ZA8->(DbGoTo(nRec))

                        RecLock("ZA8",.F.)
                        ZA8->ZA8_STAWMS:= "F"
                        ZA8->(MsUnlock())
                EndIf

        EndIf

        ZA8->(DbSkip())
    EndDo

EndIf 

RestArea(aZA8)
Return()


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fLeg
Legenda Painel Integracao WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 15/01/2021
/*/
Static Function fLeg()

Local	aLegenda  := {	{'BR_BRANCO'	,'Item não Integrado ao WMS'}		,;
						{'BR_AZUL'		,'Item enviado ao WMS'}				,;
						{'BR_AZUL_CLARO','Item Renviado ao WMS'}			,;
						{'BR_VERMELHO'	,'Item com falha no envio do WMS'}	,;
						{'BR_PRETO'		,'Item com falha no retorno do WMS'},;
						{'BR_VERDE'		,'Item com sucesso no retorno'}		,;
						{'BR_CANCEL'	,'Item Estornado'}}

BrwLegenda("Painel de Integração",'Legenda',aLegenda)

Return .T.


//iif(existblock('VALZA8MI'),U_VALZA8MI(1),.T.)
//validação existente
//Vazio() .OR. ExistCpo("SB1")
user function VALZA8MI(_nSeq)
    
    local _Ret := .T.
    
    // Faz validação se o produto integra WMS - iif(existblock('VALZA8MI'),U_VALZA8MI(1),.T.) na validação do campo ZA8_PRODUT
    if _nSeq == 1
        if !empty(alltrim(M->(ZA8_PRODUT)))
           // if posicione('SBZ',1,xFilial('SBZ')+M->(ZA8_PRODUT),'BZ_XINTWMS') <> 'S'
                //Comentado em 18-10-2022 - Luis pois a validacao anterior, estava comentada, logo o sistema nao validava nd e ainda brecava o processo erroneamente.
                //alert('O produto [ '+alltrim(M->(ZA8_PRODUT))+' ] não tem integração com o WMS. Utilize a transferência padrão.')  
                //_Ret := .F.
           // endif
        endif
    // Faz validação do armazém de origem - iif(existblock('VALZA8MI'),U_VALZA8MI(2),.T.) na validação do campo ZA8_ARMORI
    /*elseif _nSeq == 2
        if !(empty(alltrim(M->ZA8_ARMORI)))
            _aLocais := StrTokArr(getmv('FZ_XENDERP'),';')
            for _x := 1 to len (_aLocais)
                if _x == 1
                    _cArms := substr(_aLocais[_x],1,2)
                else
                    _cArms += ' / '+ substr(_aLocais[_x],1,2)
                endif
            next
            if aScan(_aLocais,{ |x| substr(alltrim(x),1,2) == alltrim(M->ZA8_ARMORI)}) == 0
                _Ret := .F.
                alert('O armazém [ '+alltrim(M->(ZA8_ARMORI))+' ] não pode ser utilizado conforme parâmetro [ FZ_XENDERP ]. Utilize uma das opções ['+_cArms+'].')
            endif
        endif
    // Faz validação do endereço de origem - iif(existblock('VALZA8MI'),U_VALZA8MI(3),.T.) na validação do campo ZA8_ENDORI
    elseif _nSeq == 3
        if !(empty(alltrim(M->ZA8_ENDORI)))
            _aLocais := StrTokArr(getmv('FZ_XENDERP'),';')
            for _x := 1 to len (_aLocais)
                if _x == 1
                    cEnde := substr(_aLocais[_x],3,4)
                else
                    cEnde += ' / '+ substr(_aLocais[_x],3,4)
                endif
            next
            if aScan(_aLocais,{ |x| substr(alltrim(x),3,4) == alltrim(M->ZA8_ENDORI)}) == 0
                _Ret := .F.
                alert('O endereço [ '+alltrim(M->(ZA8_ENDORI))+' ] não pode ser utilizado conforme parâmetro [ FZ_XENDERP ]. Utilize uma das opções ['+cEnde+'].')
            endif
        endif
    // Faz validação do armazém de destino - iif(existblock('VALZA8MI'),U_VALZA8MI(4),.T.) na validação do campo ZA8_ARMDEST
    /*elseif _nSeq == 4
        if !(empty(alltrim(M->ZA8_ARMDES)))
            _aLocais := StrTokArr(getmv('FZ_XENDWMS'),';')
            for _x := 1 to len (_aLocais)
                if _x == 1
                    _cArms := substr(_aLocais[_x],1,2)
                else
                    _cArms += ' / '+ substr(_aLocais[_x],1,2)
                endif
            next
            if aScan(_aLocais,{ |x| substr(alltrim(x),1,2) == alltrim(M->ZA8_ARMDES)}) == 0
                _Ret := .F.
                alert('O armazém [ '+alltrim(M->(ZA8_ARMDES))+' ] não pode ser utilizado conforme parâmetro [ FZ_XENDWMS ]. Utilize uma das opções ['+_cArms+'].')
            endif
        endif*/
    // Faz validação do endereço de destino - iif(existblock('VALZA8MI'),U_VALZA8MI(5),.T.) na validação do campo ZA8_ENDDES
    /*elseif _nSeq == 5
        if !(empty(alltrim(M->ZA8_ENDDES)))
            _aLocais := StrTokArr(getmv('FZ_XENDWMS'),';')
            for _x := 1 to len (_aLocais)
                if _x == 1
                    cEnde := substr(_aLocais[_x],3,4)
                else
                    cEnde += ' / '+ substr(_aLocais[_x],3,4)
                endif
            next
            if aScan(_aLocais,{ |x| substr(alltrim(x),3,4) == alltrim(M->ZA8_ENDDES)}) == 0
                _Ret := .F.
                alert('O endereço [ '+alltrim(M->(ZA8_ENDDES))+' ] não pode ser utilizado conforme parâmetro [ FZ_XENDWMS ]. Utilize uma das opções ['+cEnde+'].')
            endif
        endif*/
    // Faz validação do endereço de destino - iif(existblock('VALZA8MI'),U_VALZA8MI(5),.T.) na validação do campo ZA8_ENDDES
    elseif _nSeq == 6
        if !(empty(alltrim(dtos(M->ZA8_EMISSA))))
            if M->ZA8_EMISSA <> ddatabase
                _Ret := .F.
                alert('A datade emissão do documento deve ser a mesma logada no sistema.[*TEMP]')
            endif
        else
            _Ret := .F.
            alert('Informa a data de emissão do documento.[*TEMP]')
        endif
    endif


return(_Ret)
