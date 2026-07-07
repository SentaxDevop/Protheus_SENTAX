#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} AT460GRV
Ponto disparado após a atualização do atendimento da OS.

@sample		U_AT460GRV()

@author		Alessandro Smaha
@since		02/12/2016
@version 	P11
/*/
//-------------------------------------------------------------------
User Function AT460GRV()

Local nOpcx 	:= PARAMIXB[1]
Local aAreaAB6	:= AB6->(GetArea())
Local aAreaAB7	:= AB7->(GetArea())
Local aAreaAB9	:= AB9->(GetArea())
Local cMarca	:= ""
Local cTipoEn	:= ""

If nOpcx <> 3 // [3] Exclusao [1] Inclusao [2] Alteracao
	DbSelectArea("AB6")
	AB6->(DbSetOrder(1)) // AB6_FILIAL+AB6_NUMOS
	If AB6->(DbSeek(xFilial("AB6")+Substr(AB9->AB9_NUMOS,1,6)))
		If Empty(AB6->AB6_XUSREF)
			If AB6->AB6_STATUS $ "BE" // A=Aberto;B=Atendida;E=Encerrado
				RecLock("AB6",.F.)
				AB6->AB6_XUSREF := UsrFullName(RetCodUsr())
				AB6->AB6_XDATEF := AB9->AB9_DTFIM
				AB6->AB6_XHOREF := AB9->AB9_HRFIM
				AB6->AB6_XCDTEC := AB9->AB9_CODTEC
				AB6->(MsUnlock())
			EndIf
		EndIf
		cNumOs := Substr(AB9->AB9_NUMOS,1,6)
		If AB7->(DbSeek(xFilial("AB7")+cNumOs))
			If AB9->AB9_TIPO == '1' // 1=Encerrado;2=Em Aberto
				// Encerra todos os itens da OS.
				cMarca := GetMark(,"AB6","AB6_OK")
				RecLock("AB6",.F.)
				AB6->AB6_OK		:= cMarca 	// Marcado -> Encerrado
				AB6->AB6_STATUS	:= "E"  	// A=Aberto;E=Encerrado
				AB6->(MsUnlock())
				cTipoEn := "4"
			Else // Deixa em aberto todos os itens da OS, com excessão do primeiro item.
				//AB7->(DbSkip()) // Pula o primeiro item
				cTipoEn := "3"
			EndIf
			// Encerra os itens da OS...
			While AB7->(!Eof()) .AND. xFilial("AB7")+cNumOs == AB7->(AB7_FILIAL+AB7_NUMOS)
				RecLock("AB7",.F.)
				AB7->AB7_TIPO := cTipoEn // 1=O.S.;2=Pedido Gerado;3=Em Atendimento;4=Atendido;5=Encerrado
				AB7->(MsUnlock())
				AB7->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aAreaAB6)
RestArea(aAreaAB7)
RestArea(aAreaAB9)

Anali_Z22()      // Gravacao tabela relacionamento tecnico

Return


///////////////////////////////////////////////////////////////////////////////////////////
STATIC Function Anali_Z22()

Local  lRetorno := .T.
Local  cNumOsIt := ''
Local nOpcx 	:= PARAMIXB[1]
Local aAreaAB6	:= AB6->(GetArea())
Local aAreaAB7	:= AB7->(GetArea())
Local aAreaAB9	:= AB9->(GetArea())

// MessageBox("Chamando Rotina MTEC003","Processamento at460grv",1)

cNumOsIt := AB9->AB9_NUMOS
cCodTec  := AB9->AB9_CODTEC
cCodSeq  := AB9->AB9_SEQ

If nOpcx == 1  // Se inclusao, inseri registros na z22
	
	// percorre a ab6 / ab7 para identificar a Os e os produtos
	// percorre a ab9 e aba para identificar o tecnico
	// insere os registros na z22
	// guarda ambiente
	
	
	AB6->( DbSetOrder( 1) )
	If !AB6->( DbSeek( xFilial("AB6")+ Substring(cNumOsIt,1,6) ) )  // Nao localizou registros, ira atualizar
		MessageBox("Problemas ao localizar referencia na Tabela AB6","Atencao - PE_AT460GRV",1)
		Return(Nil)
	Endif
	
	AB9->( DbSetOrder(1) )
	If !AB9->( DbSeek( xFilial("AB9")+ cNumOsIt + cCodTec + cCodSeq) )
		MessageBox("Problemas ao localizar referencia na Tabela AB9","Atencao - PE_AT460GRV",1)
		Return(Nil)
	Endif
	
	AB7->( DbSetOrder(1) )
	If !AB7->( DbSeek( xFilial("AB7")+ cNumOsIt ) )  // Nao localizou registros, ira atualizar
		MessageBox("Problemas ao localizar referencia na Tabela AB7","Atencao - PE_AT460GRV",1)
		Return(Nil)
	Endif
	
	//	   Do While !AB7->(Eof()) .AND. AB7->AB7_FILIAL = XFILIAL("AB7") .and. AB7->AB7_NUMOS + AB7->AB7_ITEM == cNumOsIt	   // Grava somente o item os todos os itens
	
	Do While !AB7->(Eof()) .AND. AB7->AB7_FILIAL = XFILIAL("AB7") .and. AB7->AB7_NUMOS == Substring(cNumOsIt,1,6)	   // Grava somente o item os todos os itens
		
		Z22->( DbSetOrder (1) )
		If !Z22->( DbSeek( xFilial("Z22") + cNumOsIt + cCodTec + cCodSeq + AB7->AB7_CODPRO))  // Nao localizou registros
			If RecLock("Z22", .T.)
				Z22->Z22_FILIAL := xFilial("Z22")
				Z22->Z22_NUMOS  := Substring(cNumOsIt,1,8)
				// Z22->Z22_ITEM   := Substring(cNumOsIt,7,2)
				
				Z22->Z22_ITEM   := AB7->AB7_ITEM
				Z22->Z22_PROD   := AB7->AB7_CODPRO
				Z22->Z22_CODPRB := AB7->AB7_CODPRB
				Z22->Z22_NUMSER := AB7->AB7_NUMSER
				Z22->Z22_CODTEC := cCodTec
				Z22->Z22_SEQ    := cCodSeq
				Z22->Z22_DATAAT := AB9->AB9_DTFIM
				/*
				Z22->Z22_QTDREA :=
				Z22->Z22_PONTOS :=
				*/
				MsUnlock()
			Endif
		Endif
		AB7->( DbSkip() )
	Enddo
	
Elseif nOpcx == 2 // verifica a existencia dos registros na z22
	
	AB6->( DbSetOrder( 1) )
	If !AB6->( DbSeek( xFilial("AB6")+ Substring(cNumOsIt,1,6) ) )  // Nao localizou registros, ira atualizar
		MessageBox("Problemas ao localizar referencia na Tabela AB6","Atencao - PE_AT460GRV",1)
		Return(Nil)
	Endif
	
	AB9->( DbSetOrder(1) )
	If !AB9->( DbSeek( xFilial("AB9")+ cNumOsIt + cCodTec + cCodSeq) )
		MessageBox("Problemas ao localizar referencia na Tabela AB9","Atencao - PE_AT460GRV",1)
		Return(Nil)
	Endif
	
	AB7->( DbSetOrder(1) )
	If !AB7->( DbSeek( xFilial("AB7")+ cNumOsIt ) )  // Nao localizou registros, ira atualizar
		MessageBox("Problemas ao localizar referencia na Tabela AB7","Atencao - PE_AT460GRV",1)
		Return(Nil)
	Endif
	
	// Do While !AB7->(Eof()) .AND. AB7->AB7_FILIAL = XFILIAL("AB7") .and. AB7->AB7_NUMOS + AB7->AB7_ITEM == cNumOsIt
	Do While !AB7->(Eof()) .AND. AB7->AB7_FILIAL = XFILIAL("AB7") .and. AB7->AB7_NUMOS == Substring(cNumOsIt,1,6)	   // Grava somente o item os todos os itens
		
		Z22->( DbSetOrder (1) )
		If Z22->( DbSeek( xFilial("Z22") + cNumOsIt + cCodTec + cCodSeq + Substr(AB7->AB7_CODPRO,1,15) ))  // Nao localizou registros
			If RecLock("Z22", .F.)
				// Z22->Z22_FILIAL := xFilial("Z22")
				// Z22->Z22_NUMOS  := Substring(cNumOsIt,1,6)
				// Z22->Z22_ITEM   := Substring(cNumOsIt,7,2)
				//Z22->Z22_PROD   := AB7->AB7_CODPRO
				Z22->Z22_CODPRB := AB9->AB9_CODPRB
				//Z22->Z22_NUMSER := AB7->AB7_NUMSER
				// Z22->Z22_CODTEC := cCodTec
				// Z22->Z22_SEQ    := cCodSeq
				Z22->Z22_DATAAT := AB9->AB9_DTFIM
				// Z22->Z22_QTDREA :=
				// Z22->Z22_PONTOS :=
				MsUnlock()
			Endif
		Endif
		AB7->( DbSkip() )
	Enddo
	
Elseif nOpcx == 3 // ISINCALLSTACK('At460Exclu')  // Exclui registros na z22
	
	// MessageBox("Excluindo Item AB6","Atencao - PE_AT460GRV",1)
	
	AB6->( DbSetOrder( 1) )
	If !AB6->( DbSeek( xFilial("AB6")+ Substring(cNumOsIt,1,6) ) )  // Nao localizou registros, ira atualizar
		MessageBox("Problemas ao localizar referencia na Tabela AB6","Atencao - PE_AT460GRV",1)
		Return(Nil)
	Endif
	
	/*
	AB9->( DbSetOrder(1) )
	If !AB9->( DbSeek( xFilial("AB9")+ cNumOsIt + cCodTec + cCodSeq) )
	MessageBox("Problemas ao localizar referencia na Tabela AB9","Atencao - PE_AT460GRV",1)
	Return(Nil)
	Endif
	*/
	
	AB7->( DbSetOrder(1) )
	If !AB7->( DbSeek( xFilial("AB7")+ cNumOsIt ) )  // Nao localizou registros, ira atualizar
		MessageBox("Problemas ao localizar referencia na Tabela AB7","Atencao - PE_AT460GRV",1)
		Return(Nil)
	Endif
	
	// Do While !AB7->(Eof()) .AND. AB7->AB7_FILIAL = XFILIAL("AB7") .and. AB7->AB7_NUMOS + AB7->AB7_ITEM == cNumOsIt
	Do While !AB7->(Eof()) .AND. AB7->AB7_FILIAL = XFILIAL("AB7") .and. AB7->AB7_NUMOS == Substring(cNumOsIt,1,6)	   // Grava somente o item os todos os itens
		
		Z22->( DbSetOrder (1) )
		If Z22->( DbSeek( xFilial("Z22") + cNumOsIt + cCodTec + cCodSeq + Substr(AB7->AB7_CODPRO,1,15) ))  // Nao localizou registros
			Do While !Z22->( Eof() ) .AND. Z22->Z22_NUMOS = cNumOsIt .AND. Z22->Z22_CODTEC == cCodTec .AND. Z22->Z22_SEQ == cCodSeq
				If SUBSTRING( Z22->Z22_PROD,1,15) == Substr(AB7->AB7_CODPRO,1,15)
					If Reclock("Z22",.F.)
						DbDelete()
						MsUnlock()
					Endif
				Endif
				Z22->( DbSkip())
			Enddo
		Endif
		AB7->( DbSkip() )
	Enddo
	
Endif

// MessageBox("Inicio da AB9ABA",ProcName(),1)
If nOpcx == 1 .or. nOpcx == 2
	If !IsBlind()
		AB9ABA()  // Rotina para atualizar tabela Z22  OS X Apto OS X Tecnicos
	End
Endif

Return( Nil )


///////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AB9ABA

Local cLinok 	:= "Allwaystrue"
Local cTudook 	:= "Allwaystrue"
Local nOpce 	:= 4 	//define modo de alteração para a enchoice
Local nOpcg 	:= 4 	//define modo de alteração para o grid
Local cFieldok 	:= "Allwaystrue"
Local lRet 		:= .T.
Local cMensagem := ""
Local lVirtual  := .T. 	//Mostra campos virtuais se houver
Local nFreeze	:= 0
Local nAlturaEnc:= 350	//Altura da Enchoice

Private  aRotina    := {}

Private cCadastro	:= "Apontamento Quantidade de Atendimentos"
Private aCols 		:= {}
Private aHeader 	:= {}
Private aCpoEnchoice:= {}
// Private aAltEnchoice:= {"C5_CONDPAG","C5_TPFRETE","C5_MENNOTA","C5_ZZPVCL","C5_ZZBOX","C5_ZZEQUIP","C5_ZZMOD1","C5_ZZMOD2","C5_ZZCAIXA"}
Private aAltEnchoice:= {""}

Private cTitulo
Private cAlias1 	:= "AB9"
Private cAlias2 	:= "Z22"

AADD(aRotina,{"Pesquisar","AxPesqui",0,1})
AADD(aRotina,{"Visualizar","AxVisual",0,2})
AADD(aRotina,{"Incluir","AxInclui",0,3})
AADD(aRotina,{"Alterar","AxAltera",0,4})
AADD(aRotina,{"Excluir","AxDeleta",0,5})

Sleep(400)

// Filtrar aqui, somente os registros necessarios
RegToMemory("AB9",.F.)
RegToMemory("Z22",.F.)

DefineCabec()
DefineaCols(nOpcg)

Sleep(400)

lRet := Modelo3(cCadastro,cAlias1,cAlias2,aCpoEnchoice,cLinok,cTudook,nOpce,nOpcg,cFieldok,lVirtual,,aAltenchoice,nFreeze,,,nAlturaEnc)

//retornará como true se clicar no botao confirmar
if lRet
	/*
	cMensagem += "Esta rotina tem a finalidade de salvar a quantidade realizada"+CRLF+CRLF
	cMensagem += "APENAS os campos abaixo SERÃO SALVOS:"+CRLF+CRLF
	
	cMensagem += "Cabeçalho: "+CRLF
	cMensagem += "Nenhum"+CRLF+CRLF
	
	cMensagem += "Itens:"+CRLF
	cMensagem += "Quantidade"+CRLF+CRLF
	*/
	
	// if MsgYesNo(cMensagem+"CONFIRMA ALTERAÇÃO DOS DADOS ?", cCadastro)
	Processa({||Gravar()},cCadastro,"Alterando os dados, aguarde...")
	// endif
else
	RollbackSx8()
endif

Return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function DefineCabec()

Local aZ22   := {"Z22_NUMOS","Z22_CODTEC","Z22_SEQ","Z22_ITEM","Z22_PROD","Z22_CODPRB","Z22_NUMSER","Z22_QTDREA","Z22_PONTOS"}
Local nUsado
aHeader		:= {}
aCpoEnchoice:= {}

nUsado:=0

//Monta a enchoice
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
dbseek(cAlias1)
while SX3->(!eof()) .AND. X3_ARQUIVO == cAlias1
	IF X3USO(X3_USADO) .AND. CNIVEL >= X3_NIVEL
		AADD(ACPOENCHOICE,X3_CAMPO)
	endif
	dbskip()
enddo

//Monta o aHeader do grid conforme os campos definidos no array aZ22 (apenas os campos que deseja)
//Caso contrário, se quiser todos os campos é necessário trocar o "For" por While, para que este faça a leitura de toda a tabela
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
aHeader:={}
For nX := 1 to Len(aZ22)
	If SX3->(DbSeek(aZ22[nX]))
		If X3USO(X3_USADO).And.cNivel>=X3_NIVEL
			nUsado:=nUsado+1
			Aadd(aHeader, {TRIM(X3_TITULO), X3_CAMPO , X3_PICTURE, X3_TAMANHO, X3_DECIMAL,X3_VALID, X3_USADO  , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT})
		Endif
	Endif
Next nX

Return


//////////////////////////////////////////////////////////////////////////////////////////////////
//Insere o conteudo no aCols do grid
Static function DefineaCols(nOpc)

Local nQtdCpo := Len(aHeader)
Local i       := 0
Local nCols   := 0

aCols := {}

dbSelectArea("Z22")
dbSetOrder(1)
dbSeek( xFilial("Z22") + AB9->AB9_NUMOS + AB9->AB9_CODTEC + AB9->AB9_SEQ )
While !Z22->(Eof()) .and. Z22->Z22_FILIAL == xFilial("AB9") .and. Z22->Z22_NUMOS == AB9->AB9_NUMOS .and. Z22->Z22_SEQ == AB9->AB9_SEQ .and. Z22->Z22_CODTEC == AB9->AB9_CODTEC
	AAdd(aCols,array(nQtdCpo + 1))
	nCols++
	For i := 1 To nQtdCpo
		If aHeader[i,10] <> "V"
			aCols[nCols,i] := FieldGet(FieldPos(aHeader[i,2]))
		Else
			Alert("Incluir 1 linha")
			aCols[nCols,i] := Criavar(aHeader[i,2],.T.)
		EndIf
	Next i
	aCols[nCols,nQtdCpo + 1] := .F.
	
	Z22->(dbskip())
EndDo

Return


////////////////////////////////////////////////////////////////////////////////////////////
//Gravar o conteudo dos campos
Static Function Gravar()

Local nNumOS  := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_NUMOS"})
Local nCodTec := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_CODTEC"})
Local nSeq    := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_SEQ"})
Local nItem   := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_ITEM"})
Local nProd   := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_PROD"})
Local nCodPrb := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_CODPRB"})
Local nNumSer := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_NUMSER"})
Local nQtdRea := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_QTDREA"})
Local nPontos := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z22_PONTOS"})
Local nPosCpo := 0
Local nCpo    := 0
Local nI      := 0
Local aReg    := {}

// Local cCamposSC5	:= "C5_CONDPAG|C5_TPFRETE|C5_MENNOTA|C5_ZZPVCL|C5_ZZBOX|C5_ZZEQUIP|C5_ZZMOD1|C5_ZZMOD2|C5_ZZCAIXA"
Local cCamposAB9 := ""
Local cCamposZ22 := "Z22_QTDREA"

Begin Transaction

//Gravando dados do grid
dbSelectArea("Z22")
Z22->(dbSetOrder(1))
Z22->(dbSeek(xFilial("Z22") + AB9->AB9_NUMOS + AB9->AB9_CODTEC))
While !Z22->(Eof()) .And. xFilial("Z22") == Z22->Z22_FILIAL .And. AB9->AB9_NUMOS == Z22->Z22_NUMOS .And. AB9->AB9_CODTEC == Z22->Z22_CODTEC
	AAdd(aReg, Z22->(RecNo()))
	Z22->(dbSkip())
End

Z22->(dbGoTop())
For nI := 1 To Len(aCols)

	If !(aCols[nI, Len(aHeader)+1])
		
		If Z22->(dbSeek( xFilial("Z22") + aCols[nI,nNumOS] + aCols[nI,nCodTec] + aCols[nI,nSeq] + aCols[nI,nProd] + aCols[nI,nItem] ))
			RecLock("Z22",.F.)
			Z22->Z22_QTDREA := aCols[nI,nQtdRea]
			Z22->Z22_PONTOS := aCols[nI,nPontos]
			Z22->(MsUnLock())
		Else
			RecLock("Z22", .T.)
			Z22->Z22_FILIAL := xFilial("Z22")
			Z22->Z22_NUMOS  := aCols[nI,nNumOS]
			Z22->Z22_ITEM   := aCols[nI,nItem]
			Z22->Z22_PROD   := aCols[nI,nProd]
			Z22->Z22_CODPRB := aCols[nI,nCodPrb]
			Z22->Z22_NUMSER := aCols[nI,nNumSer]
			Z22->Z22_CODTEC := aCols[nI,nCodTec]
			Z22->Z22_SEQ    := aCols[nI,nSeq]
			Z22->Z22_DATAAT := AB9->AB9_DTFIM
			Z22->Z22_QTDREA := aCols[nI,nQtdRea]
			Z22->Z22_PONTOS := aCols[nI,nPontos]
			MsUnlock()		
		EndIf
	
	Else
	
		If nI <= Len(aReg)
			Z22->(dbGoTo(aReg[nI]))
			RecLock("Z22",.F.)
			dbDelete()
		EndIf
							
	EndIf

Next nI

End Transaction

Return
