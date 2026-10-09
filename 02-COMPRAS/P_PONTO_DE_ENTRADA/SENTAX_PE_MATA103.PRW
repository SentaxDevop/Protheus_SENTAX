#INCLUDE 'PROTHEUS.CH'
//----------------------------------------------------------------------------------------
/*/{Protheus.doc} MA103BUT
Permite ao usuário adicionar opções na barra de menus EnchoiceBar.
@author TOTVS
@return aButtons, Array (vetor) de opções de usuário
@description
O Ponto de Entrada MA103BUT, chamado a partir do código-fonte MATA103.PRW, 
permite ao usuário adicionar opções na barra de menus EnchoiceBar.
http://tdn.totvs.com.br/pages/releaseview.action?pageId=102269141
/*/
//----------------------------------------------------------------------------------------
User Function MA103BUT()

	Local aButtons := {}
                          
	If !INCLUI .AND.!ALTERA 
		aadd(aButtons, {'DEVOLNF', {||U_MCOM001()}, 'Chave NF-e'})
	EndIf

Return aButtons

//---------------------------------------------------------------------------------------------
//Ponto de entrada executado na vinculação do item do documento de entrada ao pedido de compras
//---------------------------------------------------------------------------------------------
User Function MT103IPC()

	Local aArea     := GetArea()    
	
	Local nLinha      := PARAMIXB[1]                                       
	
	Local nPCod       := aScan(aHeader,{|X| ALLTRIM(X[2]) == "D1_COD"})
	Local nPDescric   := aScan(aHeader,{|X| ALLTRIM(X[2]) == "D1_DESCRIC"})
	Local nPosXCODPRF := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_XCODPRF"})
	
	aCols[nLinha][nPDescric]  := Posicione("SB1",1,xFilial("SB1")+aCols[nLinha][nPCod],"B1_DESC")

	aCols[nLinha][nPosXCODPRF] := SC7->C7_XCODPRF

	

	RestArea(aArea)

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} fTelaMsg() 
Abre a Tela para o usuário informar o motivo da devolução.
                
@sample		fTelaMsg() 

@author		Alessandro Smaha
@since		02/02/2015 
@version 	P11  
/*/
//------------------------------------------------------------------- 
Static Function fTelaMsg() 

Local aButtons := {}
Local oGetMot
Local cGetMot 	:= "" 
Local oGetVal
Local nGetVal 	:= 0
Local lRetOk	:= .F.
//Local oMotAlt  
Local nOpcx 	:= 0  
Static oDlg    

cGetMot := Padr(SF1->F1_MENNOTA,250)

DEFINE MSDIALOG oDlg TITLE "Devolução" FROM 000, 000  TO 160, 650 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME // Cria Dialog sem o botão de Fechar.
          
	@ 035, 002 SAY oSayUser PROMPT "Usuário Autorizou Devolução: "+Alltrim(Upper(UsrFullName(RetCodUsr()))) SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 045, 002 SAY oSayValr PROMPT "Valor Transporte:" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 002 SAY oSayDesc PROMPT "Motivo da Devolução:" SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 043, 050 MSGET oGetVal VAR nGetVal SIZE 050, 010 PICTURE PesqPict("SF1","F1_XVALTRA") OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
    @ 065, 002 MSGET oGetMot VAR cGetMot SIZE 300, 010 PICTURE "@!" VALID fValidMot(cGetMot,@lRetOk) OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
   
	oDlg:lEscClose     := .F. //Nao permite sair ao se pressionar a tecla ESC.

	EnchoiceBar(oDlg, {|| nOpcx := 1, IIF(lRetOk,oDlg:End(),.F.) }, {|| nOpcx := 0 },,aButtons)

ACTIVATE MSDIALOG oDlg CENTERED
     
cGetMot := Alltrim(cGetMot)  

If nOpcx == 1	// Motivo da Devolução
	RecLock("SF1",.F.)
		SF1->F1_XUSRDEV := RetCodUsr()	// Usuario Autorizou devolução
   		SF1->F1_XMOTDEV := cGetMot   
   		SF1->F1_XVALTRA := nGetVal
	SF1->(MsUnLock())
EndIf			

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} fValidMot() 
Valida o motivo informado pelo usuário
                
@sample		fValidMot() 

@author		Alessandro Smaha
@since		02/02/2015 
@version 	P11  
/*/
//------------------------------------------------------------------- 
Static Function fValidMot(cGetMot,lRetOk)
        
cGetMot := Alltrim(cGetMot) 

If Len(cGetMot) >= 10
	lRetOk := .T.
Else
	MsgAlert("O motivo da devolução deve ter no mínimo 10 caracteres!","Atenção")
	lRetOk := .F.
EndIf

Return

// PEs NFACIL
//---------------------------------------------------------------------
/*/{Protheus.doc} MT100AGR
O ponto de entrada é chamado após a confirmação da NF, porém fora da transação. Isto foi feito pois clientes que utilizavam TTS e tinham interface com o usuario no ponto MATA100 "travavam" os registros utilizados, causando parada para outros usuarios que estavam acessando a base.

@author 	Alessandro Smaha
@since 		14/01/2016
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
User Function MT100AGR()

Local aArea	   := GetArea()  

If INCLUI .OR. ALTERA
	
	//Realiza a manifestação
	U_NFAC025(1)         

ElseIf !INCLUI .AND. !ALTERA

	// Atualiza o status do xml ingrado
	U_NFAC025(2) 	

EndIf

RestArea(aArea)

Return Nil
