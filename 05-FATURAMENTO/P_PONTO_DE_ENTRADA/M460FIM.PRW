#include "rwmake.ch"
#include "topconn.ch"

User Function M460FIM()

	Local aArea   := GetArea()
	Local cMsgBlq := Alltrim(SuperGetMv("ST_XMSGEN", .T., "S"))  
	Local nRecSc5 := 0
	Local oObjICMS

	If !(Alltrim(SC5->C5_TIPO) $ "D/B") //Utiliza fornecedor

			nRecSc5 := SC5->(Recno())

			M460FIM_01()

			// M460FIM_02() // ALTERADO POR SMAHA - ERRO DE CHAVE DUPLICADA 

			M460FIM_03()  

			// Verifica se existe endereço de entrega diferente do fiscal
			If FunName() $ "MATA461|MATA460A|MATA460B" .AND. cMsgBlq == "S" .AND. ExistBlock("RFAT002")
				// MATA461 - FAT/PEDIDO DE VENDA/PREP. DOCS | MATA460A - FAT/PEDIDO DE VENDA/DOC. SAIDA/PREP. DOCS | MATA460B - OMS/PREP. DOCS - CARGA     
				fEndDifere(SC5->C5_FILIAL,SC5->C5_NUM)       
			EndIf

			//---------------------------------------------------------------------------
			/*/{Protheus.doc} M460FIM 
			Gravar dados de metas de vendas

			@author  Rodrigo Slisinski
			@since   10/08/2017                    
			@param   nil
			@return	 nil

			/*/    
			//---------------------------------------------------------------------------


			cSql:=" SELECT COUNT(*)cnt FROM ("
			cSql+=" 	SELECT  SUBSTRING(F2_EMISSAO,1,6) MESES FROM "+RetSqlName('SF2')+" SF2"
			cSql+=" 	INNER JOIN "+RetSqlName('SD2')+" SD2"
			cSql+=" 		ON D2_FILIAL = F2_FILIAL"
			cSql+=" 		AND D2_DOC = F2_DOC"
			cSql+=" 		AND D2_SERIE = F2_SERIE"
			cSql+=" 		AND SD2.D_E_L_E_T_<>'*'"
			cSql+=" 	INNER JOIN  "+RetSqlName('SF4')+"  SF4"
			cSql+=" 		ON F4_FILIAL ='"+xFilial('SF4')+"'"
			cSql+=" 		AND F4_CODIGO = D2_TES"
			cSql+=" 	WHERE  F2_CLIENTE ='"+SF2->F2_CLIENTE+"'"
			cSql+=" 		AND F2_LOJA='"+SF2->F2_LOJA+"'"
			cSql+=" 		AND F2_EMISSAO >= GETDATE()-365"
			cSql+=" 		AND F4_DUPLIC = 'S'
			cSql+=" 		AND SF2.D_E_L_E_T_<>'*'"
			cSql+=" GROUP BY SUBSTRING(F2_EMISSAO,1,6))HH
			IF Select('TRF2')<>0
				TRF2->(DBCloseArea())
			EndIF
			TCQuery cSql New ALias 'TRF2'
			nPeriod:=0
			iF !TRF2->(EOF())
				nperiod:=INT(TRF2->cnt/12)
			EndIf

			dbSelectArea('SA2')
			DBSetOrder(1)
			If DBSeek(xFilial('SA1')+SF2->F2_CLIENTE+SF2->F2_LOJA)
				Reclock('SA1',.F.)
				SA1->A1_X_FREQ:=nPeriod
				msUnlock()
			Endif

			dbSelectArea('Z19')
			DBSetOrder(1)
			If DBSeek(xFilial('Z19')+substr(dtos(SF2->F2_EMISSAO),5,2)+substr(dtos(SF2->F2_EMISSAO),1,4)+SF2->F2_CLIENTE+SF2->F2_LOJA)
				RECLOCK('Z19',.F.)
				Z19->Z19_ULTCOM := SF2->F2_EMISSAO
				Z19->Z19_DTFAT := SF2->F2_EMISSAO
				Z19->Z19_FATMES:= Z19->Z19_FATMES+SF2->F2_VALBRUT
				Z19->Z19_EFICIE:= Z19->Z19_FATMES/Z19->Z19_META * 100
				MsUnlock()
			Endif

			If SC5->C5_FILIAL == "020201"
				U_AWMS001() //Envia para o WMS a informação de faturamento.
			End

			//Responsável por gerar os dados bancários no título para impressão do boleto na DANFE
			If Alltrim(SC5->C5_XFORMA) == "BOL" .Or. (Empty(SC5->C5_XFORMA) .And. !Empty(SC5->C5_X_PVSIM)) //Se forma de Pgto for Bol ou o Pedido é de Origem do SFA
				U_AFAT011(SC5->C5_FILIAL,SC5->C5_NUM,SF2->F2_DOC, SF2->F2_SERIE)
			End

			/*
			oObjICMS := TICMSSTExclusion():New()
			oObjICMS:cProcessName := "INCLUSION OF OUTPUT INVOICE
			oObjICMS:Process()
			*/

		Else 

	EndIf 

	FreeObj(oObjICMS)
	RestArea(aArea)
	
Return

//--------------------------
Static Function M460FIM_01()

	Local cNumAte 	:= "" 
	Local cFormSC5	:= ""  
	Local cForma	:= ""

	Private cNat := ""
	Private cImp := SC5->C5_XIMPBOL
	Private cBco := SC5->C5_XBCOBOL  

	cSql:="  SELECT                                   "
	cSql+=" 	D2_XNAT                               "
	cSql+="  	FROM "+RetSqlName('SD2')+" SD2        "
	cSql+="  	WHERE D2_FILIAL = '"+xFilial('SC5')+"'"
	cSql+=" 	AND   SD2.D_E_L_E_T_<>'*'             "
	cSql+=" 	AND   D2_DOC = '"+SC5->C5_NOTA+"'     "
	cSql+=" 	AND   D2_SERIE = '"+SC5->C5_SERIE+"'  "
	cSql+=" 	AND   D2_PEDIDO = '"+SC5->C5_NUM+"'   "
	cSql+="     GROUP BY D2_XNAT                      "

	IF Select('TXNT')<>0
		TXNT->(DBCloseArea())
	EndIF
	TCQuery cSql New ALias 'TXNT'

	If !TXNT->(EOF())
		cNat := TXNT->D2_XNAT
	EndIf


	cFormSC5 := SC5->C5_XFORMA 
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	cNumAte := fBuscaAte( SC5->C5_FILIAL, SC5->C5_NUM )   

	DbSelectArea("SL4") 
	SL4->(DbSetOrder(1)) // L4_FILIAL+L4_NUM+L4_ORIGEM

	If SE1->(dbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC))  

		SL4->(DbSeek(xFilial("SL4")+cNumAte+"SIGATMK"))       

		While SE1->(!Eof()) .and. xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM
			// Busca a forma de negociação conforme a forma negociada no CallCenter...
			If SL4->L4_FILIAL == xFilial("SL4") .AND. SL4->L4_NUM == cNumAte .AND. Alltrim(SL4->L4_ORIGEM) == "SIGATMK" .AND. SL4->(!EOF())  
				cForma := SL4->L4_FORMA 
				SL4->(DbSkip())
			Else
				cForma := SC5->C5_XFORMA
			EndIf
			If RecLock("SE1",.F.)
				SE1->E1_NATUREZ := cNat  
				SE1->E1_XIMPBOL := cImp
				SE1->E1_PORTADO := cBco 
				SE1->E1_XFORMA	:= cForma
				SE1->(MsUnLock())
			Endif   

			SE1->(dbSkip())
		Enddo  

	EndIf

Return

/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Módulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Nome              ! M460FIM_02                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Após a geração da NF de saída, inicia-se o processo de  !
!                  ! verificação para preenchimento da AA3.                  !
+------------------+---------------------------------------------------------+
!Autor             ! Marcos Vinicius Perusselo                               !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 16/09/2013                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+-------*/

Static Function M460FIM_02()

	//+----------------------------------------------------------------------------+
	//! Declaração de Variáveis.                                                   !
	//+----------------------------------------------------------------------------+
	Local cChave 	:= SF2->(F2_DOC+F2_SERIE)
	Local aGrava 	:= {}
	Local nPos 		:= 0
	Local cObs		:= ""
	Local nX        := 0 
	Local cConteud  := ""  //Migração 12.1.27

	//+----------------------------------------------------------------------------+
	//! Prepara as áreas/tabelas para execução da rotina.                          !
	//+----------------------------------------------------------------------------+
	dbSelectArea("SC6")
	SC6->(dbSetOrder(4))
	SC6->(dbGoTop())

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))

	//+----------------------------------------------------------------------------+
	//! Posiciona a tabela SC6 para buscar as informações dos itens do PdV.        !
	//+----------------------------------------------------------------------------+
	If (SC6->(dbSeek( xFilial("SC6")+cChave )))
		//+----------------------------------------------------------------------------+
		//! Laço para passar por todos os itens do PdV.                                !
		//+----------------------------------------------------------------------------+
		Do While ( SC6->(!EOF()) .AND. (xFilial("SC6")+SC6->(C6_NOTA+C6_SERIE) == xFilial("SF2")+cChave) )
			SF4->(dbGoTop())

			//+----------------------------------------------------------------------------+
			//! Posiciona na tabela de TES para validar o Flag: Atualiza SigaTec.          !
			//+----------------------------------------------------------------------------+
			If (SF4->(dbSeek( xFilial("SF4")+SC6->C6_TES )))
				//+----------------------------------------------------------------------------+
				//! Valida se o campo está como SIM, conforme especificado.                    !
				//+----------------------------------------------------------------------------+
				If (SF4->F4_ATUTEC == "S")
					//+----------------------------------------------------------------------------+
					//! Posiciona a tabela de produtos para buscar informações.                    !
					//+----------------------------------------------------------------------------+
					If (SB1->(dbSeek( xFilial("SB1")+SC6->C6_PRODUTO )))
						/*
						Para produtos onde o GRUPO = MAQ no pedido de vendas o cliente fatura SEMPRE uma unidade por Numero de Série,
						por isso nesse caso basta pegar as informações da venda e alimentar a tabela AA3 para o cliente em questão.
						*/
						If (SB1->B1_GRUPO == "MAQ ")
							//+----------------------------------------------------------------------------+
							//! @ 23/09/2013                                                               !
							//! Se o produto for máquina, o registro na AA3 será gerado automaticamente.   !
							//! Sendo assim, não existe necessidade de criar um novo registro na tabela.   !
							//+----------------------------------------------------------------------------+
							/*
							RecLock("AA3", .T.)
							AA3->AA3_FILIAL	:= xFilial("AA3")
							AA3->AA3_CODCLI	:= SF2->F2_CLIENTE
							AA3->AA3_LOJA	:= SF2->F2_LOJA
							AA3->AA3_CODPRO	:= SC6->C6_PRODUTO
							AA3->AA3_NUMSER	:= SC6->C6_NUMSERI
							AA3->AA3_DTVEND	:= SF2->F2_EMISSAO
							AA3->AA3_DTGAR	:= &(GetMV("MV_FORMGAR"))

							AA3->AA3_CODFAB := SF2->F2_CLIENTE
							AA3->AA3_LOJAFA := SF2->F2_LOJA
							AA3->(MsUnlock())
							*/
							/*
							Para produtos que estão no GRUPO <> MAQ o cliente pode vender 50 (por exemplo) unidades do mesmo produto,
							nesse caso deve-se pegar 1 item alimentar a base de atendimento (AA3) e a quantidade colocada no campo C6_QUANT
							deve ser levado para um NOVO campo na tabela AA3 (Qtde VENDIDA).
							Dessa maneira o cliente possuirá 1 ITEM e saberá quantos foram vendidos para aquele cliente no pedido em questão.

							Para produtos onde o GRUPO <> MAQ não existe número de série, para isso na inclusão da Base de Atendimento MANUAL
							foi desenvolvido um fonte que gera números de série automaticamente, pode-se usar o mesmo fonte para o
							campo C6_NUMSER. O nome do fonte é U_TECNUMSER().
							*/
						Else
							//+----------------------------------------------------------------------------+
							//! Busca o produto no array para acumular as quantidades.                     !
							//! Validação criada para tratar quando existem dois produtos iguais no mesmo  !
							//! pedido de venda.                                                           !
							//+----------------------------------------------------------------------------+
							cConteud := GetMV("MV_FORMGAR")
							If (nPos := aScan(aGrava, { |X| X[3] = SC6->C6_PRODUTO } )) == 0
								aAdd(aGrava, { SF2->F2_CLIENTE, ;
								SF2->F2_LOJA, ;
								SC6->C6_PRODUTO, ;
								U_TECNUMSER(SC6->C6_PRODUTO), ;
								SF2->F2_EMISSAO, ;
								&(cConteud ), ;
								SC6->C6_QTDVEN, ; 
								SF2->F2_DOC })
							Else
								//+----------------------------------------------------------------------------+
								//! Acumula a quantidade no produto.                                           !
								//+----------------------------------------------------------------------------+
								aGrava[nPos, 7] += SC6->C6_QTDVEN
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			SC6->(dbSkip())
		EndDo

		dbSelectArea("AA3")

		//+----------------------------------------------------------------------------+
		//! Grava todos os itens que existem em aGrava.                                !
		//+----------------------------------------------------------------------------+
		If (Len(aGrava) > 0)

			For nX := 1 To (Len(aGrava))

				cObs := "Colocar aqui a observação da Base de Atendimento"

				RecLock("AA3", .T.)
				AA3->AA3_FILIAL	:= xFilial("AA3")
				AA3->AA3_CODCLI	:= aGrava[nX, 1]
				AA3->AA3_LOJA	:= aGrava[nX, 2]
				AA3->AA3_CODPRO	:= aGrava[nX, 3]
				AA3->AA3_NUMSER	:= aGrava[nX, 4]
				AA3->AA3_DTVEND	:= aGrava[nX, 5]
				AA3->AA3_DTGAR	:= aGrava[nX, 6]
				//AA3->AA3_XQTDVE := aGrava[nX, 7]
				AA3->AA3_NFVEND := aGrava[nX, 8]       		

				AA3->AA3_HORDIA := GetNewPar("MV_HOPEDIA", 8)
				AA3->AA3_STATUS := "01"
				AA3->AA3_DIAOPE := GetNewPar("MV_DOPESEM", 5)
				AA3->AA3_DSCPRO := POSICIONE("SB1", 1, xFilial("SB1") + aGrava[nX, 3], "B1_DESC")
				AA3->AA3_CODFAB := aGrava[nX, 1]
				AA3->AA3_LOJAFA := aGrava[nX, 2]   

				MSMM(,TamSx3("AA3_OBS")[1],,cObs,1,,,"AA3","AA3_CODMEM")

				AA3->(MsUnlock())
			Next nX
		EndIf
	EndIf

	Return  


	//------------------------------------------------------------------- 
	/*/{Protheus.doc} M460FIM_03()
	Nova rotina para gravar a base instalada via execauto.

	@author Alessandro Smaha 
	@since 03/04/2014
	@version P11 
	/*/ 
//-------------------------------------------------------------------
Static Function M460FIM_03()  

	// Declaração de Variáveis.                                                  
	Local cChave 	:= SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
	Local aGrava 	:= {}
	Local aCab040   := {}  
	Local aItens040 := {} 
	Local nPos 		:= 0
	Local cObs		:= ""  
	Local cGrpPrOk  := Alltrim(SuperGetMv("ST_XGRPPRO", .T., ""))  
	Local nX        := 0 

	Local aAreaSF4  := SF4->(GetArea())
	Local aAreaSB1  := SB1->(GetArea())
	Local aAreaSD2  := SD2->(GetArea())
	Local cConteud := ""  // Migração 12.1.27

	Private lMsErroAuto := .F.

	// Prepara as áreas/tabelas para execução da rotina.                        
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1)) // F4_FILIAL+F4_CODIGO

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	SD2->(DbGoTop())

	// Posiciona a tabela SD2 para buscar as informações dos itens da NF       
	If SD2->(dbSeek( xFilial("SD2")+cChave ))

		//! Laço para passar por todos os itens da NF             
		Do While ( SD2->(!EOF()) .AND. (xFilial("SD2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SF2")+cChave) )

			SF4->(dbGoTop())

			// Posiciona na tabela de TES para validar o Flag: Atualiza SigaTec.      
			If SF4->(dbSeek( xFilial("SF4")+SD2->D2_TES ))

				// Valida se o campo está como SIM, conforme especificado.                  
				If SF4->F4_ATUTEC == "S"

					// Posiciona a tabela de produtos para buscar informações.                 
					If SB1->(dbSeek( xFilial("SB1")+SD2->D2_COD ))
						/*
						Para produtos onde o GRUPO = MAQ no pedido de vendas o cliente fatura SEMPRE uma unidade por Numero de Série,
						por isso nesse caso basta pegar as informações da venda e alimentar a tabela AA3 para o cliente em questão.
						*/
						If SB1->B1_GRUPO $ cGrpPrOk
							//+----------------------------------------------------------------------------+
							//! Busca o produto no array para acumular as quantidades.                     !
							//! Validação criada para tratar quando existem dois produtos iguais no mesmo  !
							//! pedido de venda.                                                           !
							//+----------------------------------------------------------------------------+
							cConteud := GetMV("MV_FORMGAR") //migração 12.1.27
							If (nPos := aScan(aGrava, { |X| Alltrim(X[3]) == Alltrim(SD2->D2_COD) } )) == 0

								aAdd(aGrava, { 	SF2->F2_CLIENTE, ;
								SF2->F2_LOJA, ;
								SD2->D2_COD, ;
								SF2->F2_EMISSAO, ;
								&(cConteud ), ;
								SD2->D2_QUANT, ; 
								SF2->F2_DOC, ;
								SB1->B1_DESC, ;
								SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM) }) 

							Else
								// Acumula a quantidade no produto.                                         
								aGrava[nPos, 6] += SD2->D2_QUANT
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			SD2->(dbSkip())

		EndDo

		// Grava todos os itens que existem em aGrava.                             
		If Len(aGrava) > 0  

			DbSelectArea("AA3") 
			AA3->(DbSetOrder(1)) // AA3_FILIAL+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER

			For nX := 1 To (Len(aGrava))

				aCab040 := {} 
				cChave := aGrava[nX, 9]       

				cNumSerPar := StrZero(Val(aGrava[nX, 1]),6) + StrZero(Val(aGrava[nX, 2]),2) + Substr(Alltrim(aGrava[nX, 3]),1,12)// aGrava[nX, 3] // Número de série será o mesmo código do cliente+loja+produto

				If !AA3->(DbSeek(xFilial("AA3")+aGrava[nX, 1]+aGrava[nX, 2]+aGrava[nX, 3]+cNumSerPar))

					cObs := 	"Inclusão Automática da Base de Atendimento pelo Faturamento"+CHR(13)+CHR(10)+;
					"Nota: "+Alltrim(SF2->F2_DOC)+" Série: "+Alltrim(SF2->F2_SERIE)+" Data: "+DtoC(dDataBase)+" e Hora: "+Time()

					Aadd(aCab040, { "AA3_FILIAL"  , xFilial("AA3"), NIL } )
					Aadd(aCab040, { "AA3_CODCLI"  , aGrava[nX, 1] , NIL } )
					Aadd(aCab040, { "AA3_LOJA"    , aGrava[nX, 2] , NIL } )
					Aadd(aCab040, { "AA3_CODPRO"  , aGrava[nX, 3] , NIL } )
					Aadd(aCab040, { "AA3_NUMSER"  , cNumSerPar    , NIL } )
					Aadd(aCab040, { "AA3_DTVEN"   , aGrava[nX, 4] , NIL } ) 

					Aadd(aCab040, { "AA3_DTGAR"   , aGrava[nX, 5] , NIL } )
					Aadd(aCab040, { "AA3_NFVEND"  , aGrava[nX, 7] , NIL } )
					Aadd(aCab040, { "AA3_HORDIA"  , GetNewPar("MV_HOPEDIA", 8) , NIL } )
					Aadd(aCab040, { "AA3_STATUS"  , "01" 		  , NIL } )
					Aadd(aCab040, { "AA3_DIAOPE"  , GetNewPar("MV_DOPESEM", 5) , NIL } )

					Aadd(aCab040, { "AA3_DSCPRO"  , aGrava[nX, 8] , NIL } )
					Aadd(aCab040, { "AA3_CODFAB"  , aGrava[nX, 1] , NIL } )
					Aadd(aCab040, { "AA3_LOJAFA"  , aGrava[nX, 2] , NIL } ) 

					Aadd(aCab040, { "AA3_OBS"     , cObs          , NIL } )

					TECA040(,aCab040,aItens040,3) 

					If lMsErroAuto   

						MsgAlert(	"Erro ao incluir base instalada para o Cliente/Loja: "+Alltrim(aGrava[nX, 1])+"/"+Alltrim(aGrava[nX, 2])+;
						" e Produto: "+Alltrim(aGrava[nX, 3]),"Atenção [PE M460FIM]")				

					Endif 

				EndIf

			Next nX
		EndIf
	EndIf 

	RestArea(aAreaSF4)
	RestArea(aAreaSB1)
	RestArea(aAreaSD2)

Return   


//-------------------------------------------------------------------
/*/{Protheus.doc} fEndDifere
Verifica se endereço de entrega é diferente do fiscal 

@sample		fEndDifere(cFilSF2,cSerSF2,cDocSF2)

@author		Alessandro Smaha
@since		04/03/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fEndDifere(cFilSc5,cNumSc5)

	Local aAreaSUA := SUA->(GetArea()) 
	Local lExCarga := .F.

	DbSelectArea("SUA")
	SUA->(DbSetOrder(8)) // UA_FILIAL+UA_NUMSC5

	If SUA->(DbSeek(cFilSc5+cNumSc5))  

		lExCarga := fBuscaSC9(cNumSc5)

		If !lExCarga .AND. SUA->UA_XENDDIF == "2" // 1=Não,2=Sim 

			MsgAlert("IMPORTANTE! NOTA FISCAL EMITIDA CONTENDO ENDEREÇO DE ENTREGA DIFERENTE DO ENDEREÇO FISCAL. PEDIDO: "+Alltrim(cNumSc5)+".","Atenção") 

		EndIf 

	EndIf      

	RestArea(aAreaSUA)

Return     


//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaSC9
Verifica se existe carga para o pedido 

@sample		fBuscaSC9( cNumSc5 )   

@author		Alessandro Smaha
@since		24/04/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fBuscaSC9( cNumSc5 )    

	Local lRetOk := .F.

	DbSelectArea("SC9")
	SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	If SC9->(DbSeek(xFilial("SC9")+cNumSc5)) 

		While SC9->(!Eof()) .AND. xFilial("SC9") == SC9->C9_FILIAL .AND. cNumSc5 == SC9->C9_PEDIDO

			If !Empty(SC9->C9_CARGA)

				lRetOk := .T.	

			EndIf

			SC9->(DbSkip())
		EndDo
	EndIf

Return lRetOk       


//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaAte
Busca o numero do atendimento para o pedido informado

@sample		fBuscaAte( cFilSC5, cNumSC5 )

@return 	cNumAte - Código do Atendimento

@author		Alessandro Smaha
@since		15/04/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
Static Function fBuscaAte( cFilSC5, cNumSC5 )   

	Local cQuery	:= ""
	Local cNumAte 	:= ""

	If (Select("QATE") <> 0)
		DbSelectArea("QATE")
		QATE->(DbCloseArea())
	Endif

	cQuery := " SELECT TOP 1 UB_NUM "
	cQuery += " FROM " + RetSqlName("SUB") + " SUB "
	cQuery += " WHERE UB_FILIAL = '"+cFilSC5+"' AND UB_NUMPV = '"+cNumSC5+"' AND SUB.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY UB_ITEM "  

	TCQuery cQuery new Alias "QATE"

	QATE->(DbGoTop())

	If QATE->(!Eof()) 
		cNumAte := QATE->UB_NUM
	EndIf

Return cNumAte
