#include "protheus.ch"
#include "apvt100.ch"
#Include "topconn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} AACD003()
Função para expedição de volumes via ACD.

@sample		U_AACD003()
   
@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function AACD003()

Local lOk := .F.

Private cCodTrans := ""
Private cCodOpe := CBRetOpe()
Private aNotasRom := {}
Private cSeriePar := SuperGetMv('ST_XSERACD',,'1')
Private cMotori := ""
Private cPlaca  := ""
Private _nTempo := 3000

Conout("Rotina de Expedicao [AACD003]")

DbSelectArea("Z07")
Z07->(DbSetOrder(1)) // Z07_FILIAL+Z07_DOC+Z07_VOLUME

If Empty(cCodOpe)
	VTAlert("Operador nao cadastrado","Aviso",.T.,_nTempo) 
	Return .F.
EndIf

While !lOk
	
	cCodTrans   := Space(TamSx3("A4_COD")[1])
	cDesTrans   := Space(TamSx3("A4_NOME")[1])
	cMotori     := Space(30)
	cPlaca		:= Space(7)
	VTClear()
	@ 0,00 VTSAY 'Expedição'
	@ 2,00 VTSAY 'Transportad.:' VTGet cCodTrans  pict '@!' VALID fVldTrans(cCodTrans,@cDesTrans) F3 "SA4"
	@ 5,00 VTSAY 'Motorista:'
	@ 6,00 VTGet cMotori 	  pict '@!' VALID !Empty(cMotori)
	@ 7,00 VTSAY 'Placa:'        VTGet cPlaca	  pict '@!' VALID fVldPlaca(cPlaca) .or. VtLastkey() == 5
	VTRead
	If VtLastKey() == 27
		Exit
	EndIf
	If !Empty(cCodTrans) .AND. !Empty(cMotori) .AND. !Empty(cPlaca)
		lOk := .T.
		fLeVolumes(cCodTrans)
	EndIf
	
EndDo

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fLeVolumes()
Conrerencia de volumes de notas para gerar o romaneio     

@sample		fLeVolumes(cCodTrans)

@param		cCodTrans - Código da Transportadora

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fLeVolumes(cCodTrans)

Local lOk     := .F.
Local lRomOk  := .F.
Local cNota   := ""
Local nQtdeOk := 0
Local nQtdeTt := 0

bKey06 := VTSetKey(06,{|| fFaltas()}, "Faltantes")   // CTRL+F
bkey09 := VTSetKey(09,{|| fInforma()},"Informacoes") // CTRL+I
bKey14 := VTSetKey(14,{|| fNotasRom()},"Notas")      // CTRL+N
bKey01 := VTSetKey(01,{|| fAtalhos()},"Atalhos")     // CTRL+A

While !lOk
	
	cEtiqProd := Space(TamSx3("F2_DOC")[1]+3)
	VTClear()
	@ 0,00 VTSAY 'Expedição'
	@ 2,00 VTSAY 'NF '+cNota+' '+StrZero(nQtdeOk,3)+'/'+StrZero(nQtdeTt,3)
	If nQtdeOk == nQtdeTt .AND. ! Empty(aNotasRom)
		@ 4,00 VTSAY '(S) Gera Romaneio'
	ElseIf ! Empty(aNotasRom)
		@ 4,00 VTSAY '(CTRL+A) Atalhos'
	EndIf
	@ 6,00 VTSAY 'Leia o volume:'
	@ 7,00 VTGET cEtiqProd pict '@!' Valid fVldEtiVol(cEtiqProd,,cCodTrans,@lRomOk,@cNota,@nQtdeOk,@nQtdeTt)
	VTRead
	If lRomOk
		Exit
	ElseIf VTLastkey() == 27
		If ! VTYesNo('Confirma a saida?','Atencao',.T.)
			Loop
		EndIf
		If !Empty(aNotasRom)
			If ! VTYesNo('Os itens serão estornados para nova conferencia!'+CRLF+CRLF+'Confirma?','Atencao',.T.)
				Loop
			EndIf
		EndIf
		fAtuCBK(.T.)
		Exit
	EndIf
	
EndDo

vtsetkey(06,bkey06)
vtsetkey(09,bkey09)
vtsetkey(14,bkey14)
vtsetkey(01,bkey01)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldEtiVol()
Valida a etiqueta lida
 
@sample		fLeVolumes(cEtiqProd,lEstorna,cCodTrans,lRomOk,cNota,nQtdeOk,nQtdeTt)

@param		cEtiqProd	- Código da Etiqueta de produto
			lEstorna 	- Lógico para estornar o produto 
			cCodTrans 	- Código da transportadora 
			lRomOk 		- Lógico para romaneio OK
			cNota  		- Numero da Nota
			nQtdeOk	 	- Quantidade lida
			nQtdeTt		- Quantidade total 
 
@return		lLógico 	- Validação da etiqueta de volume	

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fVldEtiVol(cEtiqProd,lEstorna,cCodTrans,lRomOk,cNota,nQtdeOk,nQtdeTt)

Local nQE := fQtdExped()
Local cCodDoc := Substr(cEtiqProd,1,9)
Local cNumRom := ""
Local lRetOk	:= .T.

Default lEstorna:= .f.

If Empty(cEtiqProd)
	
	Return .F.
	
EndIf

If ! Empty(cNota)
	
	If nQtdeOk <> nQtdeTt .AND. cNota <> cCodDoc
		
		VTAlert("Finalize a leitura dos volumes da nota "+cNota+" para ler a próxima nota!","Aviso",.T.,_nTempo,2)
		VTKeyBoard(chr(20))
		Return .F.
		
	EndIf
	
EndIf

If Alltrim(Upper(cEtiqProd)) == "S"
	
	// Finaliza e gera o romaneio
	If VTYesNo('Confirma a geração do ROMANEIO?','Atencao',.T.)
		
		VtClearBuffer()
		
		If Empty(aNotasRom)
			
			VTAlert("Realize a leitura dos Volumes. Não foi informado nenhum volume para geração do romaneio!","Aviso",.T.,_nTempo,2)
			VTKeyBoard(chr(20))
			Return .F.
			
		EndIf
		
		If fVolumeOk()
			
			lRomOk := .T.
			
			If fGeraRom(@cNumRom)
				VtClearBuffer()
				VTAlert("Imprimindo Romaneio "+cNumRom+"!","Aviso",.T.,_nTempo,2)
				fImprRom(cNumRom)
			Else
				VTAlert("Erro ao gerar Romaneio!","Aviso",.T.,_nTempo,2)
			EndIf
			
			VtClearBuffer()
			VTKeyBoard(chr(20))
			
			Return .T.
			
		Else
			
			Return .F.
			
		EndIf
		
	Else
		Return .F.
	EndIf
	
EndIf

If Z07->(DbSeek(xFilial("Z07")+cEtiqProd))
	If Z07->Z07_STATUS == "2" // 1=Não;2=Sim
		VTAlert("A Etiqueta deste volume já foi lida!","Aviso",.T.,_nTempo,2)
		VtClearBuffer()
		VTkeyBoard(chr(20))
		Return .f.
	EndIf
EndIf

If !fValNota(cCodDoc+cSeriePar,cCodTrans)
	Return .f.
EndIf

If !Z07->(DbSeek(xFilial("Z07")+cEtiqProd))
	VTAlert("A Etiqueta lida é inválida para nota "+cCodDoc+"!","Aviso",.T.,_nTempo,2)
	VtClearBuffer()
	VTkeyBoard(chr(20))
	Return .f.
EndIf

If !fVldVolume(cEtiqProd,lEstorna,@nQtdeOk,@nQtdeTt)
	Return .f.
EndIf

If Empty(nQtdeTt)
	cNota := ""
Else
	cNota := cCodDoc
EndIf

VtClearBuffer()
VTKeyBoard(chr(20))

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} fVolumeOk()
Valida volumes lidos  

@sample		fVolumeOk()
             
@return		lRetOk - Validação do volume	

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fVolumeOk()

Local nI 		:= 0
Local lRetOk  	:= .T.
Local cVolLido	:= ""
Local cVolTot	:= ""
Local cNumNota	:= ""

DbSelectArea("SF2")
SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

DbSelectArea("CBK")
CBK->(DbSetOrder(1)) // CBK_FILIAL+CBK_DOC+CBK_SERIE+CBK_CLIENT+CBK_LOJA

For nI := 1 to Len(aNotasRom)
	
	cCodNota := aNotasRom[nI]
	
	If SF2->(DbSeek(xFilial("SF2")+cCodNota+cSeriePar))
		
		If CBK->(DbSeek(xFilial("CBK")+cCodNota+cSeriePar))
			
//			U_AFAT004( SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SF2->F2_VOLUME1, CBK->CBK_XQTVOL, "AACD003/fVolumeOk", dDataBase, Time(), UsrFullName(RetCodUsr()), "Valida os volumes para gerar romaneio." ) 	
			U_AFAT004( SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SF2->F2_VOLUME1, CBK->CBK_XQTVOL, "AACD003/fVolumeOk", dDataBase, Time(), "", "Valida os volumes para gerar romaneio." ) 		
			If CBK->CBK_XQTVOL <> SF2->F2_VOLUME1
				
				cVolLido 	:= Padl(cValToChar(CBK->CBK_XQTVOL),3)
				cVolTot		:= Padl(cValToChar(SF2->F2_VOLUME1),3)
				
				cNumNota	:= cCodNota+"-"+cSeriePar
				lRetOk 		:= .F.
				
				Exit
				
			EndIf
			
		EndIf
		
	EndIf
	
Next nI

If !lRetOk
	
	VTAlert("Expedição em aberto!"+CRLF+CRLF+"Nota: "+cNumNota+CRLF+CRLF+"Volumes Lidos: "+cVolLido+CRLF+"Total Volumes: "+cVolTot,"Aviso",.T.,_nTempo,2)
	VtClearBuffer()
	VTkeyBoard(chr(20))
	
EndIf

Return lRetOk


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldVolume()
Valida a etiqueta lida do volume

@sample		fVldVolume(cEtiqProd,lEstorna,nQtdeOk,nQtdeTt)

@param		cEtiqProd	- Código da Etiqueta de produto 
			lEstorna 	- Lógico para estornar o produto 
			nQtdeOk	 	- Quantidade lida
			nQtdeTt		- Quantidade total 

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fVldVolume(cEtiqProd,lEstorna,nQtdeOk,nQtdeTt)

Local  aRetAnalise := {}
Local  nQtdeNota   := 0
Local  nQtdeEmb    := 0
Local  nQtdeNec    := 0

If !lEstorna
	
	aRetAnalise := fAnalisaExp()
	nQtdeNota 	:= aRetAnalise[1]
	nQtdeEmb  	:= aRetAnalise[2]
	nQtdeNec  	:= nQtdeNota - nQtdeEmb
	nQtdeTt		:= nQtdeNota
	
	If nQtdeNec <= 0
		VTAlert("Nao existe saldo a coletar deste volume!","Aviso",.T.,_nTempo,2)
		VtClearBuffer()
		VTkeyBoard(chr(20))
		Return .f.
	EndIf
	
Endif

fAtuCBK(.F.,cEtiqProd,@nQtdeOk,@nQtdeTt)

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuCBK()
Atualiza o status da tabela de Cabecalho de Embarque (CBK)

@sample		fAtuCBK(lFinal,cEtiqProd,nQtdeOk,nQtdeTt)

@param		lFinal		- Lógico para indicar se é final de rotina
			cEtiqProd	- Código da Etiqueta de produto 
			nQtdeOk	 	- Quantidade lida
			nQtdeTt		- Quantidade total 

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuCBK(lFinal,cEtiqProd,nQtdeOk,nQtdeTt)

Local   aRetAnalise := {}
Local   nQtdeNota   := 0
Local   nQtdeExp    := 0

Default lFinal := .F.
Default cEtiqProd := ""

If !lFinal
	
	If Z07->(DbSeek(xFilial("Z07")+cEtiqProd))
		RecLock("Z07",.F.)
		Z07->Z07_STATUS := "2"
		Z07->Z07_DTCONF := dDataBase
		Z07->Z07_HRCONF := Substr(Time(),1,5)
		Z07->(MsUnlock())
	EndIf
	
	aRetAnalise := fAnalisaExp()
	nQtdeNota 	:= aRetAnalise[1]
	nQtdeExp  	:= aRetAnalise[2]
	nQtdeOk++
	
	If nQtdeNota == nQtdeExp
		
		RecLock("CBK",.F.)
		CBK->CBK_XQTVOL := CBK->CBK_XQTVOL + 1
		CBK->CBK_XDTEXP := dDataBase
		CBK->CBK_STATUS := "5"
		CBK->(MsUnlock())
		
		//cTextoMsg := "Expedição Finalizada para a nota "+SF2->F2_DOC+"!"
		//VTAlert(cTextoMsg,"Aviso",.T.,_nTempo)
		nQtdeOk := 0
		nQtdeTt := 0
		
	Else
		
		RecLock("CBK",.F.)
		CBK->CBK_XQTVOL := CBK->CBK_XQTVOL + 1
		CBK->(MsUnlock())
		
	Endif
	
Else
	
	If ! Empty(aNotasRom)
		fAtuVolumes()
		cTextoMsg := "Expedição estornada. Realize a conferência novamente!"
		VTAlert(cTextoMsg,"Aviso",.T.,_nTempo)
		nQtdeOk := 0
		nQtdeTt := 0
	EndIf
	
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuVolumes()
Atualiza status dos volumes

@sample		fAtuVolumes()

@author 	Alessandro Smaha
@since 		19/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuVolumes()

Local nI := 0

For nI := 1 to Len(aNotasRom)
	
	cNumDoc := aNotasRom[nI]
	
	If Z07->(DbSeek(xFilial("Z07")+cNumDoc))
		
		While Z07->(!Eof()) .AND. xFilial("Z07") == Z07->Z07_FILIAL .AND. cNumDoc == Z07->Z07_DOC
			
			RecLock("Z07",.F.) 
			Z07->(DbDelete())
			Z07->(MsUnlock())
			
			Z07->(DbSkip())
			
		EndDo
		
	EndIf
	
	If CBK->(DbSeek(xFilial("CBK")+cNumDoc+cSeriePar))
		RecLock("CBK",.F.)
		CBK->CBK_XQTVOL := 0
		CBK->CBK_XDTEXP := Ctod('  /  /  ')
		CBK->CBK_STATUS := "3"
		CBK->(MsUnlock())
	EndIf
	
Next nI

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fAnalisaExp()
Analisa a necessidade de volume lido

@sample		fAnalisaExp()
    
@return		aRet - Array com quantidades lidas e total de volume

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAnalisaExp()

Local nQtdeVol  := SF2->F2_VOLUME1
Local nQtdeExp  := fQtdExped()

aRet := { nQtdeVol, nQtdeExp }

Return aClone(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} fFaltas()
Mostra volumes que faltam ser lidos

@sample		fFaltas()

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fFaltas()

Local aCab,aSize,aSave := VTSAVE()
Local aHist		:= {}
Local aAreaZ07	:= Z07->(GetArea())

DbSelectArea("Z07")
Z07->(DbSetOrder(1)) // Z07_FILIAL+Z07_DOC+Z07_VOLUME

If Z07->(DbSeek(xFilial("Z07")+SF2->F2_DOC))
	While Z07->(!Eof() .and. Z07->(Z07_FILIAL+Z07_DOC) == xFilial('Z07')+SF2->F2_DOC)
		If Z07->Z07_STATUS == '1'
			AADD(aHist,{	Z07->Z07_DOC+'/'+Z07->Z07_VOLUME })
		EndIf
		Z07->(DbSkip())
	EndDo
EndIf

VTClear()
@ 0,0 VTSay "Etiquetas Pendente"
aCab  := {"Nota / Volume"}
aSize := {13}
VTaBrowse(1,0,7,19,aCab,aHist,aSize)
VtRestore(,,,,aSave)

RestArea(aAreaZ07)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fInforma()
Mostra produtos que ja foram lidos

@sample		fInforma()

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fInforma()

Local aCab,aSize,aSave := VTSAVE()
Local aHist		:={}
Local aAreaZ07	:= Z07->(GetArea())

DbSelectArea("Z07")
Z07->(DbSetOrder(1)) // Z07_FILIAL+Z07_DOC+Z07_VOLUME

If Z07->(DbSeek(xFilial("Z07")+SF2->F2_DOC))
	While Z07->(!Eof() .and. Z07->(Z07_FILIAL+Z07_DOC) == xFilial('Z07')+SF2->F2_DOC)
		AADD(aHist,{	IIF(Z07->Z07_STATUS == '2','OK','NÃO'),;
		Z07->Z07_DOC+'/'+Z07->Z07_VOLUME })
		Z07->(DbSkip())
	EndDo
EndIf

VTClear()
@ 0,0 VTSay "Etiquetas Lidas"
aCab  := {"    ","Nota / Volume"}
aSize := {4,13}
VTaBrowse(1,0,7,19,aCab,aHist,aSize)
VtRestore(,,,,aSave)

RestArea(aAreaZ07)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fQtdExped
Busca a quantidade que está ok na expedição (tabela Z07)

@sample		fQtdExped()
 
@return		nQtde - Quantidade de volumes lidos

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fQtdExped()

Local nQtde := 0

If Z07->(DbSeek(xFilial("Z07")+SF2->F2_DOC))
	
	While Z07->(!Eof()) .AND. Z07->Z07_DOC == SF2->F2_DOC
		If Z07->Z07_STATUS == "2" // 1=Não;2=Sim
			nQtde++
		EndIf
		Z07->(DbSkip())
	EndDo
	
EndIf

Return nQtde


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldTrans()
Valida transportadora

@sample		fVldTrans(cTransp,cDesTrans)

@param		cTransp		- Código da Transportadora
			cDesTrans	- Descrição da Transportadora
             
@return		lRetOk - Lógico para validação da transportadora

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fVldTrans(cTransp,cDesTrans)

Local lRetOk := .T.

If Empty(cTransp)
	lRetOk := .F.
	VTKeyBoard(chr(23))
EndIf
If lRetOk
	DbSelectArea("SA4")
	SA4->(dbSetOrder(1)) // A4_FILIAL+A4_COD
	If ! SA4->(dbSeek(xFilial("SA4")+cTransp))
		VTAlert("Transportadora nao cadastrada","Aviso",.T.,_nTempo,2)
		VTKeyBoard(chr(20))
		lRetOk := .F.
	Else
		cDesTrans := SA4->A4_NOME
		@ 3,00 VTSAY cDesTrans
	EndIf
EndIf

Return lRetOk


//-------------------------------------------------------------------
/*/{Protheus.doc} fVldPlaca()
Valida Placa do Veiculo

@sample		fVldPlaca(cPlaca)

@param		cPlaca		- Placa do Veiculo do Motorista

@return		lRetOk - Lógico para validação da placa do veiculo

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fVldPlaca(cPlaca)

Local nI := 0
Local lRetOk := .T.

For nI := 1 to 7
	
	nCodAsc := ASC(Substr(cPlaca,nI,1))
	
	If nI <= 3 // Valida as letras da placa
		If !(nCodAsc >= 65 .AND. nCodAsc <= 90)
			lRetOk := .F.
		EndIf
	Else // Valida os números da placa
		If !(nCodAsc >= 48 .AND. nCodAsc <= 57)
			lRetOk := .F.
		EndIf
	EndIf
	
Next

If !lRetOk
	VTAlert("Placa informada é inválida!","Aviso",.T.,_nTempo,2)
	VTKeyBoard(chr(20))
EndIf

Return lRetOk


//-------------------------------------------------------------------
/*/{Protheus.doc} fValNota()
Valida a nota fiscal opção 1 e nota e série na opção 2.

@sample		fValNota(cChave,cCodTrans)

@param		cChave 		- Número da nota fiscal para busca na SF2
			cCodTrans	- Código da Transportadora

@return		lLogico - Para validação da nota

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fValNota(cChave,cCodTrans)

Local nI := 0

SF2->(dbSetOrder(1))
If ! SF2->(dbSeek(xFilial()+cChave))
	VTAlert("Nota fiscal nao encontrada para esta etiqueta de volume!","Aviso",.T.,_nTempo,2)
	VTKeyBoard(chr(20))
	Return .F.
Else
	If SF2->F2_TRANSP <> cCodTrans
		VTAlert("Transportadora "+SF2->F2_TRANSP+" da Nota Fiscal "+cChave+" é diferente da transportadora informada "+;
		cCodTrans+"!","Aviso",.T.,_nTempo,2)
		VtClearGet("cEtiqProd")  // Limpa o get
		VTGetSetFocus("cEtiqProd")
		Return .F.
	EndIf
EndIf

CBK->(DbSetOrder(1))
If CBK->(DbSeek(xFilial('CBK')+cChave))
	If CBK->CBK_STATUS == "5"
		If ! VTYesNo('Expedição finalizada, deseja estonar os itens?','Atencao',.T.)
			VtClearGet("cEtiqProd")  // Limpa o get
			VTGetSetFocus("cEtiqProd")
			Return .F.
		EndIf
	ElseIf !CBK->CBK_STATUS $ "34"
		VTAlert("Expedição só pode ser realizada para itens separados!","Aviso",.T.,_nTempo,2)
		VTKeyBoard(chr(20))
		Return .F.
	EndIf
Endif

If CBK->(Eof())
	RecLock("CBK",.T.)
	CBK->CBK_FILIAL := xFilial('CBK')
	CBK->CBK_DOC    := SF2->F2_DOC
	CBK->CBK_SERIE  := SF2->F2_SERIE
Else
	RecLock("CBK",.F.)
Endif

CBK->CBK_XDTEXP := Ctod('  /  /  ')
CBK->CBK_STATUS := "4"
CBK->(MsUnlock())

nPosNf := aScan( aNotasRom, { |x| Alltrim(x) == Alltrim(SF2->F2_DOC) } )

If nPosNf == 0
	aAdd(aNotasRom,Alltrim(SF2->F2_DOC))
EndIf

If !Z07->(DbSeek(xFilial('Z07')+SF2->F2_DOC))  
	U_AFAT004( SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SF2->F2_VOLUME1, CBK->CBK_XQTVOL, "AACD003/fValNota", dDataBase, Time(), UsrFullName(RetCodUsr()), "Criando etiquetas de volume após conferência Z07." )
	For nI := 1 to SF2->F2_VOLUME1
		RecLock("Z07",.T.)
		Z07->Z07_FILIAL := xFilial('Z07')
		Z07->Z07_DOC    := SF2->F2_DOC
		Z07->Z07_VOLUME := StrZero(nI,3)
		Z07->Z07_STATUS := "1"
		Z07->(MsUnlock())
	Next nI
Endif

Return .t.


//-------------------------------------------------------------------
/*/{Protheus.doc} fImprRom()
Chama a rotina para impressão do romaneio

@sample		fImprRom(cNumRom)

@param		cNumRom	- Código do romaneio para impressão.

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fImprRom(cNumRom)

If !Empty(cNumRom)
	U_ROMS002(cNumRom,.T.)
Else
	VTAlert("NÚMERO DO ROMANEIO NÃO INFORMADO!","Aviso",.T.,_nTempo,2)
	VTKeyBoard(chr(20))
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fGeraRom()
Gera o Romaneio

@sample		fGeraRom(cNumRom)

@param		cNumRom	- Código do romaneio que foi gerado
  
@return		lLogico - Para validação da geração do romaneio

@author 	Alessandro Smaha
@since 		14/02/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fGeraRom(cNumRom)

Local aCpoMaster := {}
Local aCpoDetail := {}
Local aAux   	 := {}
Local aAuxDet 	 := {}
Local nI := 0
Local lRet := .T.
Local oModel

aAdd( aCpoMaster, {'Z03_TRANSP',cCodTrans} )
aAdd( aCpoMaster, {'Z03_PLACA' ,cPlaca} )
aAdd( aCpoMaster, {'Z03_MOTORI',cMotori} )
aAdd( aCpoMaster, {'Z03_ACD',	'1'} )

For nI := 1 to Len(aNotasRom)
	
	aAuxDet := {}
	aAdd(aAuxDet,{'Z04_NFISCA' , aNotasRom[nI]})
	aAdd(aAuxDet,{'Z04_SERIE' ,  cSeriePar})
	aAdd(aAuxDet,{'Z04_SEQ' ,  	 StrZero(nI,3)})
	aAdd(aCpoDetail,aAuxDet)
	
Next nI

oModel := FWLoadModel( 'AOMS001' )

oModel:SetOperation( 3 ) 				// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
oModel:Activate() 						// Antes de atribuirmos os valores dos campos temos que ativar o modelo
oAuxZ03  := oModel:GetModel( 'Z03MASTER' ) 	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
oStruZ03 := oAuxZ03:GetStruct() 			// Obtemos a estrutura de dados do cabeçalho
aAuxZ03  := oStruZ03:GetFields()
If lRet
	For nI := 1 To Len( aCpoMaster )
		
		If ( nPos := aScan( aAuxZ03, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0 // Verifica se os campos passados existem na estrutura do cabeçalho
			
			If !( lAux := oModel:SetValue( 'Z03MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )  // È feita a atribuição do dado aos campo do Model do cabeçalho
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
				// o método SetValue retorna .F.
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf

oAuxZ04  := oModel:GetModel( 'Z04DETAIL' )
oStruZ04 := oAuxZ04:GetStruct()
aAuxZ04  := oStruZ04:GetFields()
nItErro  := 0

If lRet
	
	For nI := 1 To Len(aCpoDetail)
		
		If nI > 1
			If ( nItErro := oAuxZ04:AddLine() ) <> nI // Incluímos uma nova linha de item
				lRet := .F.// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
				Exit
			EndIf
		EndIf
		
		For nJ := 1 To Len(aCpoDetail[nI])  // Loop para validacao e atribuicao de dados dos campos do Model
			If aScan(aAuxZ04,{|x| AllTrim(x[3]) ==  AllTrim(aCpoDetail[nI,nJ,1])}) > 0  // Verifica se os campos passados existem na estrutura do cabecalho
				// Atribui os valores aos campos do Model caso passem pela validacao do formulario
				// referente a tipos de dados, tamanho ou outras incompatibilidades estruturais.
				If !(oModel:SetValue('Z04DETAIL',aCpoDetail[nI,nJ,1],aCpoDetail[nI,nJ,2]))
					lRet := .F.
					nItErro := Len(oModel:GetModel('Z04DETAIL'):aCols)
					Exit
				EndIf
			EndIf
		Next nJ
		
		If !lRet
			Exit
		EndIf
		
	Next nI
	
EndIf

If lRet
	// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados.
	If ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a gravação efetiva dos
		// dados (commit)
		oModel:CommitData()
	EndIf
EndIf
If !lRet
	// Se os dados não foram validados obtemos a descrição do erro para gerar
	// LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()
	// A estrutura do vetor com erro é:
	// [1] identificador (ID) do formulário de origem
	// [2] identificador (ID) do campo de origem
	// [3] identificador (ID) do formulário de erro
	// [4] identificador (ID) do campo de erro
	// [5] identificador (ID) do erro
	// [6] mensagem do erro
	// [7] mensagem da solução
	// [8] Valor atribuído
	// [9] Valor anterior
	
	VTAlert("Erro ao gerar romaneio!","Aviso",.T.,_nTempo,2)
	VTAlert("Erro: "+AllToChar(aErro[6]),"Aviso",.T.,_nTempo,2)
	
Else
	
	cNumRom := Z03->Z03_COD
	
	// Atualiza status na cbk
	DbSelectArea("CBK")
	CBK->(DbSetOrder(1)) //CBK_FILIAL+CBK_DOC+CBK_SERIE+CBK_CLIENT+CBK_LOJA
	
	For nI := 1 to Len(aNotasRom)
		
		If CBK->(DbSeek(xFilial("CBK")+aNotasRom[nI]+cSeriePar))
			
			RecLock("CBK",.F.)
			CBK->CBK_STATUS := "6" // Romaneio Finalizado
			CBK->(MsUnlock())
			
		EndIf
		
	Next nI
	
EndIf
// Desativamos o Model
oModel:DeActivate()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fNotasRom()
Informa as notas que estão no romaneio atual

@sample		fNotasRom()

@author 	Alessandro Smaha
@since 		21/05/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fNotasRom()

Local aCab,aSize,aSave := VTSAVE()
Local aHist:={}
Local nI := 0
Local aAreaCBK	:= CBK->(GetArea())
Local aAreaSF2	:= SF2->(GetArea())

DbSelectArea("SF2")
SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

DbSelectArea("CBK")
CBK->(DbSetOrder(1)) // CBK_FILIAL+CBK_DOC+CBK_SERIE+CBK_CLIENT+CBK_LOJA

For nI := 1 to Len(aNotasRom)
	
	If SF2->(DbSeek(xFilial("SF2")+aNotasRom[nI]+cSeriePar))
		
		If CBK->(DbSeek(xFilial("CBK")+aNotasRom[nI]+cSeriePar))
			
			AADD(aHist,{ aNotasRom[nI],StrZero(CBK->CBK_XQTVOL,3) +'/'+ StrZero(SF2->F2_VOLUME1,3) })
			
		EndIf
		
	EndIf
	
Next nI

VTClear()
@ 0,0 VTSay "Romaneio Atual"
aCab  := {"Nota","Volumes"}
aSize := {9,7}
VTaBrowse(1,0,7,19,aCab,aHist,aSize)
VtRestore(,,,,aSave)

RestArea(aAreaCBK)
RestArea(aAreaSF2)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtalhos()
Informa os atalhos para o usuário ao clicar em CTRL+A

@sample		fAtalhos()

@author		Alessandro Smaha
@since 		21/05/2014
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtalhos()

Local aCab,aSize,aSave := VTSAVE()
Local aHist 	:= {}

AADD(aHist,{ "CTRL+A","Atalhos" })
AADD(aHist,{ "CTRL+F","Faltantes" })
AADD(aHist,{ "CTRL+I","Informações" })
AADD(aHist,{ "CTRL+N","Notas" })

VTClear()
@ 0,0 VTSay "Atalhos"
aCab  := {"Teclas","Descrição"}
aSize := {6,12}
VTaBrowse(1,0,7,19,aCab,aHist,aSize)
VtRestore(,,,,aSave)

Return
