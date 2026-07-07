#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC002
Emissão do Pedido de Vendas

@sample		U_RTEC002(cNumAte)

@param		cNumAte - Numero do Chamado

@author		Alessandro Smaha
@since		22/05/2014
@version 	P11
/*/
//-------------------------------------------------------------------

User Function RTEC002(cNumPed)

Local wnrel   	:= "RTEC002"  	 	// Nome do Arquivo utilizado no Spool
Local Titulo 	:= "Emissao do Pedido de Vendas - Field Service"
Local cDesc1 	:= "Este programa ira emitir o pedido de vendas criado no sistema"
Local cDesc2 	:= "com ou sem liberacao ou a emissao da nota fiscal."
Local cDesc3 	:= "Informe os parametros de selecao para emissao dos Pedidos"
Local nReg   	:= 0
Local nomeprog	:= "RTEC002.PRW"		// nome do programa
Local cString 	:= "AB1"				// Alias utilizado na Filtragem
Local lDic    	:= .F. 					// Habilita/Desabilita Dicionario
Local lComp   	:= .F. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .T. 					// Habilita/Desabilita o Filtro
Local lImpRel 	:= .F.

Default cNumPed := ""

Private Tamanho := "M" 					// P/M/G
Private Limite  := 132 					// 80/132/220
Private aReturn := { 	"Zebrado",;		// [1] Reservado para Formulario	//"Zebrado"
						1,;				// [2] Reservado para N§ de Vias
						"Administracao",;	// [3] Destinatario					//"Administracao"
						2,;				// [4] Formato => 1-Comprimido 2-Normal
						2,;	    		// [5] Midia   => 1-Disco 2-Impressora
						1,;				// [6] Porta ou Arquivo 1-LPT1... 4-COM1...
						"",;				// [7] Expressao do Filtro
						1 } 				// [8] Ordem a ser selecionada						
						// [9]..[10]..[n] Campos a Processar (se houver)

Private m_pag   := 1  				 	// Contador de Paginas
Private nLastKey:= 0  				 	// Controla o cancelamento da SetPrint e SetDefault
Private cPerg   := "RTEC002"  		 	// Pergunta do Relatorio
Private aOrdem  := {}  				 	// Ordem do Relatorio

AjustaSx1(cPerg)	//Ajusta o nome dos parametros

If Empty(cNumPed)
	
	If Pergunte(cPerg,.T.)
		cNumPed := MV_PAR01
	Else
		Return
	EndIf
	
EndIf

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If (nLastKey == 27)
	DbSelectArea(cString)
	DbSetOrder(1)
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If (nLastKey == 27)
	DbSelectArea(cString)
	DbSetOrder(1)
	Set Filter to
	Return
Endif

RptStatus({|lEnd| fImprime(@lEnd,wnRel,cString,nomeprog,Titulo,cNumPed)},Titulo)

Return(.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC002O
Rotina chamada pela Ordem de SErviço do Field Service

@sample		U_RTEC002O()

@author		Alessandro Smaha
@since		27/06/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function RTEC002O() 

	Local cNumPv := ""
	
	cNumPv := fNumPV(AB6->AB6_NUMOS) 
	
	If ! Empty(cNumPv)
           
   		U_RTEC002(cNumPv)  
   		 
 	Else
 	
 		MsgAlert("Pedido de Venda não encontrado para a O.S. " + AB6->AB6_NUMOS + "!","Atenção")
 	
 	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fImprime
Emissao do Pedido de Vendas

@sample		fImprime(lEnd,wnrel,cString,nomeprog,Titulo,cNumAte)

@param		cNumAte - Numero do Chamado

@author		Alessandro Smaha
@since		22/05/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fImprime( lEnd, wnrel, cString, nomeprog, Titulo, cNumPed)

// Variaveis utilizadas para Impressao Do Cabecalho e Rodape
Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo relatorio
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= "" 			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens

// Declaracao de variaveis especificas para este relatorio
Local cCodCli	:= ""
Local cLojCli	:= ""
Local cNrChamado:= "" 
Local cNrOServ 	:= ""
Local cContato	:= ""
Local cAtenden	:= ""
Local cEndEnt	:= ""
Local cCepEnt	:= ""
Local cMunEnt	:= ""
Local cEndCob	:= ""
Local cCepCob	:= ""
Local cMunCob 	:= ""
Local cCodCliT	:= ""
Local cNome		:= ""
Local cEnder	:= ""
Local cCGC		:= ""
Local cRg		:= ""
Local cTpFrete	:= ""
Local cTranspo	:= ""
Local cNomeVen 	:= ""
Local cCondPag 	:= ""
Local cFormPag 	:= ""
Local nI		:= 0
Local nJ		:= 0
Local nLi		:= 0
Local nVlFrete	:= 0
Local nDespesa	:= 0
Local nDescont	:= 0 
Local nPosOs	:= 0
Local nTotQtd  	:= 0
Local nTotGeral	:= 0
Local nCol 		:= 0
Local dEmissao 	:= CtoD("  /  /  ")	
Local aLinha	:= {}
Local aOServico	:= {}
Local aFatura	:= {}

SetRegua(0) // Total de Elementos da regua

IncRegua()

DbSelectArea("AB1")
AB1->(DbSetOrder(1)) // AB1_FILIAL+AB1_NRCHAM

DbSelectArea("AB2")
AB2->(DbSetOrder(1)) // AB2_FILIAL+AB2_NRCHAM+AB2_ITEM+AB2_CODPRO+AB2_NUMSER

DbSelectArea("AB6")
AB6->(DbSetOrder(1)) // AB6_FILIAL+AB6_NUMOS  

DbSelectArea("AB7")
AB7->(DbSetOrder(1)) // AB7_FILIAL+AB7_NUMOS+AB7_ITEM

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

DbSelectArea("Z08")
Z08->(DbSetOrder(1)) // Z08_FILIAL+Z08_CODCLI+Z08_LOJA+Z08_SEQUEN 

DbSelectArea("SC6")
SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

DbSelectArea("SC5")
SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM     

If SC5->(DbSeek(xFilial("SC5")+cNumPed))  

	dEmissao := SC5->C5_EMISSAO
	nVlFrete := SC5->C5_FRETE
	cTpFrete := SC5->C5_TPFRETE
	nDespesa := SC5->C5_DESPESA
	cTranspo := SC5->C5_TRANSP
	nDescont := SC5->C5_DESCONT
	cNomeVen := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
	cCondPag := Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")

	cCodCli := SC5->C5_CLIENTE
	cLojCli := SC5->C5_LOJACLI
	
	
	If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))    
		
	EndIf
	
	cNrChamado := fNrChamado(cNumPed)  
	cNrOServ   := fNumOS(cNumPed)
	
	If !Empty(cNrChamado)
		
		If AB1->(DbSeek(xFilial("AB1")+cNrChamado))
			
			cContato := AB1->AB1_CONTAT 
			cAtenden := AB1->AB1_ATEND 
			
			// Endereço de Cobrança
			cEndCob := Alltrim(SA1->A1_ENDCOB)
			cCepCob := SA1->A1_BAIRROC
			cMunCob := SA1->A1_XCOMPCO 
			
			// Endereço de Entrega			
			If  AB1->AB1_XCDEND == "000" 
				
				cEndEnt := Alltrim(SA1->A1_ENDENT)
				cCepEnt := Transform(SA1->A1_CEPE, "99999-999") 
				cMunEnt := SA1->A1_MUNENT 
						
				cCepEnt += IIf(Empty(cCepEnt),""," - ") + SA1->A1_BAIRROE
				cMunEnt += IIf(Empty(cMunEnt),""," - ") + SA1->A1_ESTE  
				
			Else
			
				If Z08->(DbSeek(xFilial("Z08")+cCodCli+cLojCli+AB1->AB1_XCDEND))
					
					cEndEnt := Alltrim(Z08->Z08_ENDERE)+Iif(Empty(AllTrim(Z08->Z08_EST+Z08->Z08_MUN)),"",", "+Z08->Z08_EST+"-"+AllTrim(Z08->Z08_MUN))
				
				EndIf
				
			EndIf 
			
		Else
		
			Return
			
		EndIf
		
	Else
		
		Return
		
	EndIf
	
	If !Empty(cNrOServ)
		
		If ! AB6->(DbSeek(xFilial("AB6")+cNrOServ))
					
			Return		
		
		EndIf  
	
	Else
	
		Return
		
	EndIf
	
	If lEnd
		@Prow()+1,000 PSay "CANCELADO PELO OPERADOR"
		Return
	Endif
	
	cCodCliT:=	Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_COD") + " - " +;
  				Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_LOJA")
	cNome	:=	Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_NOME")
	cEnder	:=	Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_END")
	cCGC	:=	Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_CGC")
	cRg		:=	Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_INSCR")
	
	If Empty(cRg)
		cRg :=	Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_RG")
	Endif
	
	cFormPag := SC5->C5_CONDPAG

	
	// Funcao que incrementa a linha e verifica a quebra de pagina
	fLinha(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay __PrtThinLine()
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| " + PadR("Empresa",9) + " " + PadR(cCodCliT,31)
	@ nLi,044 PSay "|"
	@ nLi,046 PSay PadR("LOCAL DE ENTREGA",40)
	@ nLi,088 PSay "|"
	@ nLi,090 PSay PadR("ENDERECO DE COBRANCA",40)
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| " + PadR(cNome,40) // STR0012 - "Nome"
	@ nLi,044 PSay "|"
	@ nLi,045 PSay Repl("-",40)
	@ nLi,088 PSay "|"
	@ nLi,089 PSay Repl("-",40)
	@ nLi,131 PSay "|"
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| " + PadR(cEnder,40) // STR0013 - "Endereco"
	@ nLi,044 PSay "|"
	@ nLi,046 PSay PadR(cEndEnt,40)
	@ nLi,088 PSay "|"
	@ nLi,090 PSay PadR(cEndCob,40)
	@ nLi,131 PSay "|"
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| " + PadR(cRg,40) // STR0014 - "Inscr./RG"
	@ nLi,044 PSay "|"
	@ nLi,046 PSay PadR(cCepEnt,40) 
	@ nLi,088 PSay "|"
	@ nLi,090 PSay PadR(cCepCob,40)
	@ nLi,131 PSay "|"
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "| "		// STR0015 - "CPF/CNPJ"
	@ nLi,002 PSay cCGC Picture IIF(Len(cCGC)==14,'@R 99.999.999/9999-99','@R 999.999.999-99')
	@ nLi,044 PSay "|"
	@ nLi,046 PSay PadR(cMunEnt,40) 
	@ nLi,088 PSay "|"
	@ nLi,090 PSay PadR(cMunCob,40) 
	@ nLi,131 PSay "|"
		
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay __PrtThinLine()
	
	// Imprime os dados do pedido
	fLinha(@nLi,2,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay __PrtFatLine()
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "Chamado Tec.: " + cNrChamado	
	@ nLi,066 PSay "Pedido      : " + cNumPed   
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "Ord. Serviço: " + Substr(cNrOServ,1,6)
	@ nLi,066 PSay "Contato     : " + SubStr(cContato,1,49)
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "Emissão     : " + Dtoc(dEmissao)
	@ nLi,066 PSay "Frete       : " + Transform(nVlFrete, "@E 999,999.99") + If(cTpFrete == "C"," - CIF"," - FOB")
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "Operador    : " + cAtenden
	@ nLi,066 PSay "Despesas    : " + Transform(nDespesa, "@E 999,999.99")
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "Transportad.: " + SubStr(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME"),1,49)
	@ nLi,066 PSay "Desconto    : " + Transform(nDescont, "@E 999,999.99")
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "Vendedor    : " + SubStr(cNomeVen,1,49)
	@ nLi,066 PSay "Cond. Pagto : " + SubStr(cCondPag,1,48)
	
	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "Forma Pagto : " + SubStr(cFormPag,1,49)

	fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay __PrtThinLine()
	
	aOServico := {}
	
	// Verifica as OS	
	If SC6->(dbSeek(xFilial("SC6")+cNumPed))
		
		While ! SC6->(Eof()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == cNumPed
			
			nPosOs := aScan(aOServico,{ |x| Alltrim(x) == Substr(SC6->C6_NUMOS,1,8) })
			
			If nPosOs == 0
				
				aAdd( aOServico, Substr(SC6->C6_NUMOS,1,8) )
				
			EndIf
			
			SC6->(DbSkip())
		EndDo
		
	EndIf  
		
	For nJ := 1 to Len(aOServico)
		
		If AB7->(dbSeek(xFilial("AB7")+aOServico[nJ]))
			
			// Impresssao do campo memo da observacao
			aLinha := fMemoObs(AB7->AB7_MEMO1, 120)
			If Len(aLinha) > 0
				For nI := 1 To Len(aLinha)
					fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
					If nI == 1
						@ nLi,000 PSay PadR("Equipamento: ",12)
						@ nLi,013 PSay AB7->AB7_CODPRO
						fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
						@ nLi,000 PSay PadR("Observações: ",12)
					Endif
					@ nLi,013 PSay aLinha[nI]
				Next nI
			Endif
			
		EndIf
		
	Next nJ
	
	// Imprime os produtos/servicos pedidos.
	If SC6->(dbSeek(xFilial("SC6")+cNumPed))
		
		fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay __PrtThinLine()
		
		fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay PadR("Item Produto         Descricao                      UM   Qtde              Vlr Unit.         Vlr Item    %Desc.        Val. Desc.",Limite)
		
		fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay __PrtThinLine()
		
		nTotQtd  := 0
		nTotGeral:= 0
		
		While	SC6->(!Eof()) .AND. xFilial("SC6") == SC6->C6_FILIAL .AND. SC6->C6_NUM == cNumPed
			
			If SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
				
				fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
				@ nLi,000	PSay SC6->C6_ITEM			PICTURE PESQPICT("SUB","UB_ITEM")
				@ nLi,005	PSay SB1->B1_COD			PICTURE PESQPICT("SB1","B1_COD")
				@ nLi,021	PSay PadR(SB1->B1_DESC,30)	PICTURE PESQPICT("SB1","B1_DESC")
				@ nLi,052	PSay SB1->B1_UM				PICTURE PESQPICT("SB1","B1_UM")
				@ nLi,057	PSay SC6->C6_QTDVEN			PICTURE PESQPICT("SUB","UB_QUANT")
				@ nLi,071	PSay SC6->C6_PRCVEN			PICTURE "@E 99,999,999.99"
				@ nLi,088	PSay SC6->C6_VALOR			PICTURE "@E 99,999,999.99"
				@ nLi,105	PSay SC6->C6_DESCONT		PICTURE PESQPICT("SUB","UB_DESC")
				@ nLi,115	PSay SC6->C6_VALDESC		PICTURE PESQPICT("SUB","UB_VALDESC")

				nTotQtd   += SC6->C6_QTDVEN
				nTotGeral += SC6->C6_VALOR
				
			EndIf
				
			SC6->(dbSkip())
		End
		
		// Imprime os totais de quantidade e valor
		fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay __PrtThinLine()
		
		fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,027 PSay PadR("Total das quantidades",23) + Transform(nTotQtd, "@E 99,999,999.99") //"Total das quantidades"
		@ nLi,065 PSay PadR("Valor total Pedido",23) + Transform(nTotGeral, "@E 99,999,999.99") //"Valor total do Pedido"
	Endif 
		
	// 	Condicao(nValTot,cCond,nValIpi,dData0,nValSolid,aImpVar,aE4,nAcrescimo,nInicio3,aDias3)   
	aFatura := Condicao(nTotGeral,SC5->C5_CONDPAG,,SC5->C5_EMISSAO) // Total para o calculo, cod. cond.pgto,data base

	// Imprime as formas de pagamento  
	
	If len(aFatura) > 0
		nCol := 0
		fLinha(@nLi,3,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay __PrtFatLine()
		
		fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay PadR("| Vencto                  Valor || Vencto                  Valor || Vencto                  Valor || Vencto                  Valor |",Limite)
		
		fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 PSay __PrtThinLine()
		
		fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		For nI := 1 to len(aFatura)
			If nCol == 0
				@ nLi,nCol PSay "| " + DtoC(aFatura[nI][1]) + Space(9) + Transform(aFatura[nI][2], "@E 999,999.99")
				nCol+=32
			Else
				@ nLi,nCol PSay "|| " + DtoC(aFatura[nI][1]) + Space(9) + Transform(aFatura[nI][2], "@E 999,999.99")
				nCol+=33
			Endif
			If nCol > 120
				@ nLi,nCol PSay "|"
				fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
				nCol := 0
			Endif
		Next nI
		
		If nCol == 32
			@ nLi,nCol		PSay "||"
			@ nLi,nCol+33	PSay "||"
			@ nLi,nCol+66	PSay "||"
			@ nLi,131		PSay "|"
			fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		ElseIf nCol == 65
			@ nLi,nCol		PSay "||"
			@ nLi,nCol+33	PSay "||"
			@ nLi,131		PSay "|"
			fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		ElseIf nCol == 98
			@ nLi,nCol		PSay "||"
			@ nLi,131		PSay "|"
			fLinha(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		Endif
		@ nLi,000 PSay __PrtThinLine()
	Endif  
	
	aFatura   := {}
	nTotQtd   := 0
	nTotGeral := 0
	
EndIf

// Imprime o rodape do relatorio
Roda(cbCont,cbText,Tamanho)

Set Device To Screen

SetPgEject(.F.)

If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return(.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} fMemoObs
Monta o texto conforme foi digitado pelo operador e quebra as linhas 
no tamanho especificado sem cortar palavras e 
devolve um array com os textos a serem impressos. 

@author Alessandro Smaha
@since  27/06/2014
/*/
//-------------------------------------------------------------------
Static Function fMemoObs(cCodigo,nTam)

Local cString	:= MSMM(cCodigo,nTam)		// Carrega o memo da base de dados
Local nI		:= 0    					// Contador dos caracteres
Local nJ		:= 0    					// Contador dos caracteres
Local nL		:= 0						// Contador das linhas
Local cLinha	:= ""						// Guarda a linha editada no campo memo
Local aLinhas	:= {}						// Array com o memo dividido em linhas

nPosFim := AT(Replicate("-",40), cString ) - 1

If nPosFim > 0
	cString := Substr(cString,1,nPosFim)
EndIf

For nI := 1 TO Len(cString)
	If (MsAscii(SubStr(cString,nI,1)) <> 13) .AND. (nL < nTam)
		// Enquanto não houve enter na digitacao e a linha nao atingiu o tamanho maximo
		cLinha+=SubStr(cString,nI,1)
		nL++
	Else
		// Se a linha atingiu o tamanho maximo ela vai entrar no array
		If MsAscii(SubStr(cString,nI,1)) <> 13
			nI--
			For nJ := Len(cLinha) To 1 Step -1
				// Verifica se a ultima palavra da linha foi quebrada, entao retira e passa pra frente
				If SubStr(cLinha,nJ,1) <> " "
					nI--
					nL--
				Else
					Exit
				Endif
			Next nJ
			// Se a palavra for maior que o tamanho maximo entao ela vai ser quebrada
			If nL <=0
				nL := Len(cLinha)
			Endif
		Endif
		
		// Testa o valor de nL para proteger o fonte e insere a linha no array
		If nL >= 0
			cLinha := SubStr(cLinha,1,nL)
			AAdd(aLinhas, cLinha)
			cLinha := ""
			nL := 0
		Endif
	Endif
Next nI

// Se o nL > 0, eh porque o usuario nao deu enter no fim do memo e eu adiciono a linha no array.
If nL >= 0
	cLinha := SubStr(cLinha,1,nL)
	AAdd(aLinhas, cLinha)
	cLinha := ""
	nL := 0
Endif

Return(aLinhas)


//-------------------------------------------------------------------
/*/{Protheus.doc} fMemoObs
Incrementa o contador de linhas para impressão nos relatorios e 
verifica se uma nova pagina sera iniciada. 

@param	nLi      - Numero da linha em que sera impresso            
		nInc     - Quantidade de linhas a serem incrementadas      
		nMax     - Numero maximo de linhas por pagina              
		Titulo   - Titulo do cabecalho do relatorio                
		cCabec1  - Primeira linha do lalbel do relatorio           
		cCabec2  - Segunda linha do label do relatorio             
		NomeProg - Nome do programa que sera impresso no cabecalho 
		Tamanho  - Tamanho de colunas do relatorio                 
		
@author Alessandro Smaha
@since  27/06/2014
/*/
//-------------------------------------------------------------------

Static Function fLinha(	nLi, nInc, nMax, titulo, cCabec1, cCabec2, nomeprog, tamanho)

Local nChrComp	:= IIF(aReturn[4]==1,15,18)

nLi+=nInc
If nLi > nMax .or. nLi < 5
	nLi := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nChrComp)
	nLi++
Endif

Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} fNrChamado()
Busca o nr do chamado a partir do pedido

@param	cNumPed      - Numero da linha em que sera impresso            

@author Alessandro Smaha
@since  27/06/2014
/*/
//-------------------------------------------------------------------
Static Function fNrChamado(cNumPed)

Local cQuery 		:= ""
Local cNrChamado 	:= ""

cQuery := " SELECT AB2_NRCHAM "
cQuery += " FROM "+RetSqlName('AB2')+" AB2 "
cQuery += " WHERE AB2_FILIAL = '"+xFilial("AB2")+"' "
cQuery += " 	AND AB2.D_E_L_E_T_ <> '*' "
cQuery += " 	AND AB2_NUMOS IN (	SELECT C6_NUMOS "
cQuery += " 	   					FROM "+RetSqlName('SC6')+" SC6 "
cQuery += " 	   					WHERE SC6.D_E_L_E_T_ <> '*' "
cQuery += " 							AND C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " 		 					AND C6_NUM = '"+cNumPed+"' "
cQuery += " 						GROUP BY C6_NUMOS) "
cQuery += " GROUP BY AB2_NRCHAM "
cQuery += " ORDER BY AB2_NRCHAM "

If select("QCHM")<>0
	QCHM->(dbclosearea())
EndIf

TcQuery cQuery new Alias "QCHM"

DbSelectArea("QCHM")
QCHM->(DbGoTop())

If QCHM->(!Eof())
	cNrChamado := QCHM->AB2_NRCHAM
EndIf

Return cNrChamado



//-------------------------------------------------------------------
/*/{Protheus.doc} fNumOS()
Busca o nr da OS a partir do pedido

@param	cNumPed      - Numero da linha em que sera impresso            

@author Alessandro Smaha
@since  27/06/2014
/*/
//-------------------------------------------------------------------
Static Function fNumOS(cNumPed)

Local cQuery 		:= ""
Local cOServico 	:= ""

cQuery := " SELECT C6_NUMOS "
cQuery += " FROM "+RetSqlName('SC6')+" SC6 "
cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " 	AND C6_NUM = '"+cNumPed+"' "    
cQuery += " 	AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY C6_NUMOS

If Select("QOSR")<>0
	QOSR->(dbclosearea())
EndIf

TcQuery cQuery new Alias "QOSR"

DbSelectArea("QOSR")
QOSR->(DbGoTop())

If QOSR->(!Eof())
	cOServico := QOSR->C6_NUMOS
EndIf

Return cOServico

  

//-------------------------------------------------------------------
/*/{Protheus.doc} fNumPV()
Busca o nr da OS a partir do pedido

@param	cNumPed      - Numero da linha em que sera impresso            

@author Alessandro Smaha
@since  27/06/2014
/*/
//-------------------------------------------------------------------
Static Function fNumPV(cNumOS)

Local cQuery 		:= ""
Local cOServico 	:= ""

cQuery := " SELECT C6_NUM "
cQuery += " FROM "+RetSqlName('SC6')+" SC6 " 
cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' " 
cQuery += "  	AND SUBSTRING(C6_NUMOS,1,6) = '" + cNumOS + "' " 
cQuery += "  	AND SC6.D_E_L_E_T_ <> '*' " 
cQuery += " GROUP BY C6_NUM "


If Select("QPDV")<>0
	QPDV->(dbclosearea())
EndIf

TcQuery cQuery new Alias "QPDV"

DbSelectArea("QPDV")
QPDV->(DbGoTop())

If QPDV->(!Eof())
	cOServico := QPDV->C6_NUM
EndIf

Return cOServico



//-------------------------------------------------------------------
/*/{Protheus.doc} RTEC002C
Monta a tela para consulta padrão de pedidos de compra

@author Alessandro Smaha
@since  25/06/2014
/*/
//-------------------------------------------------------------------
User Function RTEC002C()

Local lRet      := .F.

lRet := fConsulta()

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} fConsulta
Monta a tela para consulta padrão

@author Alessandro Smaha
@since  25/06/2014
/*/
//-------------------------------------------------------------------
Static Function fConsulta()

Local lRet		:= .T.
Local aTitulo	:= {}
Local aCabec	:= {}
Local aCodigos  := {}
Local aItens    := {}
Local aButtons	:= {}
Local nX		:= 0
Local nRet		:= 0
Local lCancel   := .T.
Local cDescri 	:= ""
Local cQuery    := ""

//aButtons := { {11, { || U_ATEC001() } } }
cQuery += " SELECT AB2_FILIAL, C5_NUM, C5_EMISSAO, AB2_NUMOS, C5_CLIENTE, C5_LOJACLI, A1_NOME FROM ( "
cQuery += " 	SELECT AB2_FILIAL, C5_NUM, C5_EMISSAO, SUBSTRING(AB2_NUMOS,1,6) AB2_NUMOS, C5_CLIENTE, C5_LOJACLI, A1_NOME "
cQuery += " 	FROM " + RetSqlName('AB2') + " AB2 "
cQuery += " 	INNER JOIN " + RetSqlName('SC6') + " SC6 ON AB2_FILIAL = C6_FILIAL AND AB2_NUMOS = C6_NUMOS AND C6_NUMOS <> '' AND SC6.D_E_L_E_T_ <> '*' "
cQuery += " 	INNER JOIN " + RetSqlName('SC5') + " SC5 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " 	INNER JOIN " + RetSqlName('SA1') + " SA1 ON C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " 	WHERE AB2_FILIAL = '" + xFilial("AB2") + "' "
cQuery += " 		AND AB2.D_E_L_E_T_ <> '*' ) AS TRABA " 
cQuery += " GROUP BY AB2_FILIAL, C5_NUM, C5_EMISSAO, AB2_NUMOS, C5_CLIENTE, C5_LOJACLI, A1_NOME "
cQuery += " ORDER BY C5_NUM, AB2_NUMOS, C5_CLIENTE "

If Select("QPED") <> 0
	QPED->(DbCloseArea())
EndIf

TcQuery cQuery new Alias "QPED"

QPED->(DbGoTop())

While QPED->(!Eof())
	
	Aadd( aItens, { QPED->C5_NUM, DtoC(StoD(QPED->C5_EMISSAO)), QPED->AB2_NUMOS, QPED->C5_CLIENTE, QPED->C5_LOJACLI, QPED->A1_NOME } )
	
	QPED->(DbSkip())
	
EndDo

cDescri := "Pedidos de Venda - Field Service"

If Len(aItens) > 0
	
	Aadd(aTitulo,'Pedido' )
	Aadd(aTitulo,'Emissão' )
	Aadd(aTitulo,'Ordem Serviço' )
	Aadd(aTitulo,'Cliente' )
	Aadd(aTitulo,'Loja' )
	Aadd(aTitulo,'Nome' )
	
	aCabec := aClone(aTitulo)
	
	nRet := TmsF3Array( aTitulo, aItens, OemToAnsi(cDescri), lCancel,aButtons, aCabec )
	
	If !Empty(nRet)
		
		VAR_IXB := aItens[nRet][1]
		
	EndIf
	
Endif

Return(lRet)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do programa

@author		Alessandro Smaha
@since		15/05/2014
/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1()

Local aHelpPerg  := {}

aAdd(aHelpPerg,{"Número do Pedido de Venda"})

PutSX1(cPerg,"01","Pedido de Venda?","" ,"" ,"MV_CH1" ,"C",6,0,0,"G","","STSC6","","S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})

Return
