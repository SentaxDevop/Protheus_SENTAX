#include "Protheus.ch"
#include "FWMVCDEF.CH" 
 
Static __LogTela    := NIL
 
//==================================================================================================//
//	Programa: CRMA980		|	Autor: Luis Paulo							|	Data: 24/05/2022	//
//==================================================================================================//
//	Descrição: PE do cadastro de cliente new														//
//	-																								//
//==================================================================================================//
User Function CRMA980() ///cXXX1,cXXX2,cXXX3,cXXX4,cXXX5,cXXX6 

    Local aParam        := PARAMIXB
    Local xRet          := .T.
    Local lIsGrid       := .F.
    Local cIDPonto      := ''
    Local cIDModel      := ''
    Local cIDForm       := ''
    Local cEvento       := ''
    Local cCampo        := ''
    Local cConteudo     := ''
    Local oObj          := aParam[1]  //If Alltrim(cObj) == "CRMA980"
    Local oSA1 			:= nil
    Local _nOper		:= nil
    Local cNomeUser	    := ""
    Local cHoraBase     := ""
    Local nX            := 1
    Local bCampoSA1     := { |x| SA1->(Field(x)) }      
    Local cCpoSA1       := ""
    Local cCadastro     := Alltrim("A1_LOJA/A1_PESSOA/A1_TIPO/A1_NOME/A1_NREDUZ/A1_END/A1_BAIRRO/A1_EST/A1_COD_MUN/A1_CEP/A1_DDD/A1_TEL/A1_PAIS/A1_CONTATO/A1_INSCR/A1_EMAIL")
    Local cCpoBlq       := Alltrim("A1_BAIRROC/A1_BAIRROE/A1_ESTC/A1_ESTE/A1_XCDMUEN/A1_REGIAO/A1_MUNE/A1_XDESREG/A1_CEPC/A1_SIMPLES/A1_SIMPNAC/A1_NVESTN/A1_XGRTELE") //A1_X_PISCA
    Local cSA1          := "SA1"

    If aParam <> NIL
    
        oObj        := aParam[1]
        cIDPonto    := aParam[2]
        cIDModel    := aParam[3]
        lIsGrid     := (Len(aParam) > 3)
        
        oSA1 		:= oObj:GetModel('SA1MASTER')
        _nOper		:= oSA1:GetOperation()

        IF Type("__lBloq") == "U" //Não existe a variavel.
            Public __lBloq  := .f.
        EndIf 

        IF Type("__lMAIL") == "U" //Não existe a variavel.
            Public __lMAIL  := .f.
        EndIf 

        If cIDPonto == 'FORMPRE'
    
            cEvento     := aParam[4]
            cCampo      := aParam[5]
            cConteudo   := If( ValType(aParam[6]) == 'C',;
                            "'" + aParam[6] + "'",;
                            If( ValType(aParam[6]) == 'N',;
                                AllTrim(Str(aParam[6])),;
                                If( ValType(aParam[6]) == 'D',;
                                    DtoC(aParam[6]),;
                                    If(ValType(aParam[4]) == 'L',;
                                        If(aParam[4], '.T.', '.F.'),;
                                        ''))))
            cIDForm     := oObj:GetID()
    
        ElseIf cIDPonto == 'FORMPOS'
    
            cIDForm     := oObj:GetID()
    
        ElseIf cIDPonto == 'FORMCOMMITTTSPRE' .OR. cIDPonto == 'FORMCOMMITTTSPOS'
    
            cConteudo   := If( ValType(aParam[4]) == 'L',;
                            If( aParam[4], '.T.', '.F.'),;
                            '')
    
        EndIf
    
        If cIDPonto == 'MODELVLDACTIVE'
            //Valida se o Modelo do Cadastro de Clientes pode ou não ser exibido ao usuário
    
        ElseIf cIDPonto == 'MODELPRE'
            //Antes da alteração de qualquer campo do Modelo.
    
        ElseIf cIDPonto == 'FORMPRE'
            //Antes da alteração de qualquer campo do Formulário.
            
        ElseIf cIDPonto == 'BUTTONBAR'
            //Adicionando um botão na barra de botões da rotina
    
        ElseIf cIDPonto == 'FORMPOS'
            //Chamada na validação final do formulário
            
        ElseIf  cIDPonto == 'MODELPOS'
            //Chamada na validação total do modelo
            //Exclusão
            If (_nOper == 5) //M030EXC
                    Reclock( "SA1" , .F.)
                    SA1->A1_XDTALT 	:= dDatabase
                    SA1->A1_XUSRALT := cNomeUser
                    SA1->A1_XHRALT 	:= cHoraBase
                    SA1->(MsUnlock())
            
            //Alteração
            ElseIf (_nOper == 4) //MA030TOK
                    If !__lBloq
                        cCpoSA1   := cCadastro + cCpoBlq 
                        xRet      := IIf(M->A1_EST == 'EX', Empty(M->A1_CGC),!Empty(M->A1_CGC)) 

                        __lBloq := .F.

                        For nX := 1 to SA1->(FCount())
                            
                            If Alltrim(Field(nX)) $ cCpoSA1
                                If !( &( cSA1 + "->" + (Field(nX))) == &("M->" + (Field(nX))) )
                                    __lBloq := .t.
                                EndIf 
                            EndIf 

                            If Alltrim(Field(nX)) $ ("A1_XTELEVE|A1_VEND|A1_X_PISCA")
                                If !( &( cSA1 + "->" + (Field(nX))) == &("M->" + (Field(nX))) )
                                    __lMAIL := .t.
                                EndIf 
                            EndIf 
		
                        Next nX 
                        
                        If !xRet 
                                Alert("CNPJ INVÁLIDO OU NÃO PREENCHIDO.")                                 
                        ElseIf M->A1_MSBLQL =='1' .AND. Empty(M->A1_XFINCON)
                            If SA1->A1_MSBLQL <> '1'
                                xRet:= .F.         	
                                Alert("INFORME O MOTIVO DO BLOQUEIO CADASTRAL.")
                            Endif
                        Endif
                            
                        //obriga a digitação do grupo de cliente quando a inscriçã estadual é diferente de branco
                        If !Empty(Alltrim(M->A1_INSCR)) .AND. Alltrim(M->A1_INSCR) != 'ISENTO'
                            If Empty(Alltrim(M->A1_GRPTRIB))
                                xRet := .F.
                                Alert('Informe o Grupo de Clientes')
                            EndIf
                        EndIf

                        //Workflow inclusão/alteração
                        If __lBloq   	
                            U_MCOM004()
                        End

                        If __lMAIL
                            U_MCOM004()
                        End
                    
                    EndIf 

                    If !xRet
                        __lBloq := .F.
                    EndIf

            //Inclusão
            ElseIf (_nOper == 3) .And. ValType(oSA1) != "U"//MA030TOK
                bCampoSA1 := { |x| SA1->(Field(x)) }      
                cCpoSA1   := Alltrim("A1_BAIRRO/A1_BAIRROC/A1_BAIRROE/A1_EST/A1_COD_MUN/A1_ESTC/A1_ESTE/A1_XCDMUEN/A1_REGIAO/A1_MUNE/A1_XDESREG/A1_DDD/A1_CEP/A1_CEPC/A1_CEP/A1_TEL/A1_SIMPLES/A1_SIMPNAC/A1_VEND/A1_NVESTN/A1_NOMVEND/A1_XTELEVE/A1_ATEND/A1_X_PISCA/A1_CONTATO/A1_XGRTELE" )
                xRet      := IIf(M->A1_EST == 'EX', Empty(M->A1_CGC),!Empty(M->A1_CGC)) 


                If !xRet                
                        Alert("CNPJ INVÁLIDO OU NÃO PREENCHIDO.")                         
                ElseIf M->A1_MSBLQL =='1' .AND. Empty(M->A1_XFINCON)
                    If SA1->A1_MSBLQL <> '1'
                        xRet:= .F.         	
                        Alert("INFORME O MOTIVO DO BLOQUEIO CADASTRAL.")
                    Endif
                Endif 

                //obriga a digitação do grupo de cliente quando a inscriçã estadual é diferente de branco
                If !Empty(Alltrim(M->A1_INSCR)) .AND. Alltrim(M->A1_INSCR) != 'ISENTO'
                    If Empty(Alltrim(M->A1_GRPTRIB))
                        xRet := .F.
                        Alert('Informe o Grupo de Clientes')
                    EndIf
                EndIf

            EndIf 

        ElseIf cIDPonto == 'FORMCOMMITTTSPRE'
            //Chamada antes da gravação da tabela do formulário
    
        ElseIf cIDPonto == 'FORMCOMMITTTSPOS'
            //Chamada após a gravação da tabela do formulário
            
        ElseIf cIDPonto == 'MODELCOMMITTTS'
            //Chamada após a gravação total do modelo e dentro da transação
    
        ElseIf cIDPonto == 'MODELCOMMITNTTS'
            //Chamada após a gravação total do modelo e fora da transação
            If (_nOper == 3) //M030INC
                    cNomeUser	  := UsrRetName(__cUserID)
                    cHoraBase     := Left(Time(),5)
                    
                    If !Empty(Alltrim(SA1->A1_INSCR)) .AND. Alltrim(SA1->A1_INSCR) != 'ISENTO'
                        If Empty(Alltrim(SA1->A1_GRPTRIB))
                            If !IsBlind()
                                Alert('O grupo de clientes estava em branco e foi preenchido com CON!')
                            EndIf 

                            Reclock( "SA1" , .F.)		
                            SA1->A1_GRPTRIB := 'CON'
                            SA1->(MsUnlock())
                        EndIf
                    EndIf

                    Reclock( "SA1" , .F.)
                    SA1->A1_XDTALT 	:= dDatabase
                    SA1->A1_XUSRALT := cNomeUser
                    SA1->A1_XHRALT 	:= cHoraBase
                    SA1->(MsUnlock()) 
                    

                    IF Type("INCLUI") == "U" //Não existe a variavel.
                        INCLUI := .T.
                    EndIf 

                    IF Type("ALTERA") == "U" //Não existe a variavel.
                        ALTERA := .F.
                    EndIf 
                    
                    // workflow inclusão/alteração   	
                    U_MCOM004()

                    Conout("")
                    Conout("Cliente --> " + SA1->A1_COD + "/" +  SA1->A1_LOJA)
                    If Alltrim(SA1->A1_XTELEVE) == "000229"
                            Reclock( "SA1" , .F.)
                            SA1->A1_MSBLQL := "2"
                            SA1->(MsUnlock())

                            Conout("Cliente liberado --> " + SA1->A1_COD + "/" +  SA1->A1_LOJA)

                            StartJob("U_fExpCli", GetEnvServer(), .T., 'C',.T.,SA1->A1_COD,SA1->A1_LOJA)
                        Else
                            U_fExpCli('C') //Envio de cliente para o WMS
                    EndIf                

                ElseIf (_nOper == 4)  //MALTCLI
                    cNomeUser	  := UsrRetName(__cUserID)
                    cHoraBase     := Left(Time(),5)

                    //gravando o usuario, data e hora da ultima alteração
                    Reclock( "SA1" , .F.)
                    SA1->A1_XDTALT 	:= dDatabase
                    SA1->A1_XUSRALT := cNomeUser
                    SA1->A1_XHRALT 	:= cHoraBase  

                    if U_StIsBlq() .and. nModulo != 6
                            SA1->A1_MSBLQL := "1"
                        Else 
                            If __lBloq
                                SA1->A1_MSBLQL := "1"
                            EndIf
                    Endif
                    SA1->(MsUnlock())

                    // workflow inclusão/alteração   	
                    //U_MCOM004()

                    If __lBloq
                        __lBloq := .f.
                    EndIf               

            EndIf 
    
        ElseIf cIDPonto == 'MODELCANCEL'
            //O botão 'FECHAR' foi acionado no modelo do Cadastro de Clientes
             
        EndIf
    
    EndIf
 
Return xRet

