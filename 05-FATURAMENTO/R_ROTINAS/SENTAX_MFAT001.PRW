#include "totvs.ch"
#include "topconn.ch"

/*
+-----------------------------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                                         !
+-----------------------------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                                          !
+--------------------------+--------------------------------------------------------------------+
! Tipo                     ! Rotina                                                             !
+--------------------------+--------------------------------------------------------------------+
! Módulo                   ! Faturamento                                                        !
+--------------------------+--------------------------------------------------------------------+
! Nome                     !  MFAT001                                                           !
+--------------------------+--------------------------------------------------------------------+
! Descrição                !Consulta de analise de credito de todas as empresas                 !
+--------------------------+--------------------------------------------------------------------+
! Autor                    ! Rodrigo Favero                                                     !
+--------------------------+--------------------------------------------------------------------+
! Data de Criação          ! 25/03/2013                                                         !
+--------------------------+--------------------------------------------------------------------+
!   ATUALIZAÇÕES                                                                                !
+------------------------------------+-----------+---------+---------+--------------------------+
! Descricao detalhada da atualização !Nome do    ! Analista!Data     !                          !
!                                    !Solicitante! Respons.!Atualiz. !                          !
+------------------------------------+-----------+---------+---------+--------------------------+
*/


User Function MFAT001(cParCodigo,cParLoja)


Local oCodigo
Local oDesc
Local oGrau    
Local oGroup1
Local oLoja
Local oSay1
Local oSay2
Local oSay3
Local oSay4        
Local cChave := ""
Local cDesc     := Space(TamSX3("A1_NOME")[1])  

Private cCodigo := IIF( cParCodigo == Nil, Space(TamSX3("A1_COD")[1]) , cParCodigo)
Private cLoja   := IIF( cParLoja   == Nil, Space(TamSX3("A1_LOJA")[1]), cParLoja  )

Private cGrau   := " "
Private cUsado   := CHR(0)+CHR(0)+CHR(1)
Private aHeader  := {}
Private aCols    := {}  
Private aArea    := GetArea()
Static oDlg           



if funname() == "MATA450A"
	cChave := A1_COD+A1_LOJA
	dbselectarea("SA1")
	SA1->(DBSetOrder(1))
	if !SA1->(DBSeek(xFilial("SA1")+cChave))
		Alert("Cadastro de cliente nao encontrado, verificar cadastro - "+SC9->C9_CLIENTE) 
		Return
	endif
	
ElseIf FUNNAME() $ "TECA300/FATA210" //Chamado Tecnico - Field Service / Liberação de Pedidos - Faturamento

	If Empty(cCodigo) .OR. Empty(cLoja)
		ShowHelpDlg("NOCLI",{"Codigo do cliente vazio"},1,;
		                    {"Preencha o codigo do cliente"})
		Return
	endif
	
	dbselectarea("SA1")
	SA1->(DBSetOrder(1))
	If !SA1->(DBSeek(xFilial("SA1")+cCodigo+cLoja))

		ShowHelpDlg("NOCLI",{"Codigo do cliente invalido"},1,;
		                    {"Preencha corretamente o codigo do cliente"})
		Return
	
	EndIf
	
else
	dbselectarea("SA1")
	SA1->(DBSetOrder(1))
	if !SA1->(DBSeek(xFilial("SA1")+SC9->(C9_CLIENTE+C9_LOJA)))
		Alert("Cadastro de cliente nao encontrado, verificar cadastro - "+SC9->C9_CLIENTE) 
		Return
	endif
endif

cCodigo  := SA1->A1_COD                      
cDesc    := SA1->A1_NOME
cLoja    := SA1->A1_LOJA
cGrau    := SA1->A1_RISCO
nLimCred := SA1->A1_LC                                  


DEFINE MSDIALOG oDlg TITLE "Análise de Crédito" FROM 000, 000  TO 370, 650 COLORS 0, 16777215 PIXEL
	@ 016, 003 MSGET oCodigo  VAR cCodigo  SIZE 030, 010 WHEN .F. OF oDlg COLORS 0, 16777215 PIXEL
	@ 016, 036 MSGET oDesc    VAR cDesc    SIZE 180, 010 WHEN .F. OF oDlg COLORS 0, 16777215 PIXEL
	@ 016, 221 MSGET oLoja    VAR cLoja    SIZE 020, 010 WHEN .F. OF oDlg COLORS 0, 16777215 PIXEL
	@ 016, 246 MSGET oGrau    VAR cGrau    SIZE 015, 010 WHEN .F. OF oDlg COLORS 0, 16777215 PIXEL
	@ 016, 266 MSGET oLimCred VAR nLimCred PICTURE "@E 99,999,999,999.99" SIZE 056, 010 WHEN .F. OF oDlg COLORS 0, 16777215 PIXEL	
	@ 008, 003 SAY oSay1 PROMPT "Código"  SIZE 025, 007  OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 036 SAY oSay2 PROMPT "Cliente" SIZE 025, 007  OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 221 SAY oSay3 PROMPT "Loja"    SIZE 025, 007  OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 245 SAY oSay4 PROMPT "G.Risco"    SIZE 025, 007  OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 267 SAY oSay4 PROMPT "Limite Crédito"  SIZE 045, 007  OF oDlg COLORS 0, 16777215 PIXEL
	@ 032, 004 GROUP oGroup1 TO 168, 320 PROMPT "Empresas" OF oDlg COLOR 0, 16777215 PIXEL 	
	@ 173, 282 BUTTON oButton1 PROMPT "Sair" ACTION oDlg:End() SIZE 037, 010 OF oDlg PIXEL  
	fWBrowse1()
ACTIVATE MSDIALOG oDlg CENTERED



RestArea(aArea)
Return



//------------------------------------------------
Static Function fWBrowse1()
//------------------------------------------------
Local oWBrowse1
Local nOpc       := 2                                   


//Busca dados para o grid
MFAT001A()

//Cria aHeader de produtos
AADD(aHeader,{"Empresa"               ,"Empresa"       ,"@!", 50,0,".F.",cUsado,"C",,"R"} )
AADD(aHeader,{"Títulos em Aberto"     ,"TitAbert"      ,"@E 999,999,999.99", 14,2,".F.",cUsado,"N",,"R"} )
AADD(aHeader,{"Títulos vencidos"      ,"TitVenci"      ,"@E 999,999,999.99", 14,2,".F.",cUsado,"N",,"R"} )

oWBrowse1:= MsNewGetDados():New(041, 008,162,315,nOpc, "AllwaysTrue()","","",,,,,,,oDLG, aHeader, aCols)
oWBrowse1:Disable() //o objeto fica desabilitado para alterações

Return



//Gera informações para o grid--------------------
Static Function MFAT001A()
//------------------------------------------------
Local cEmpr := ""
Local cFili := ""
Local cDesc := ""      
Local nLimCred := 0
Local nTitAber := 0
Local nTitVenc := 0
Local cQuery   := ""
Local cAlias   := GetNextAlias()
Local aInfo    := {}
      


DBSelectArea("SM0")
SM0->(DBSetOrder(1))
SM0->(DBGoTop())

                    
While SM0->(!Eof()) 
	cEmpr := SM0->M0_CODIGO
	cFili := SM0->M0_CODFIL                                
	fInfo(@aInfo,cFili)  
	
	if !Empty(aInfo[3])
		cDesc := SubStr(ALLTRIM(SM0->M0_CODFIL)+" - "+alltrim(aInfo[3]), 1, 50)
		
		//Busca todos os títulos em aberto	
		cQuery := " SELECT SUM(E1_SALDO) SALDO"
		cQuery += " FROM SE1"+cEmpr+"0 SE1 "       
		cQuery += " WHERE E1_FILIAL = '"+cFili+"'" 
		cQuery += " AND E1_CLIENTE = '"+cCodigo+"'"
		cQuery += " AND E1_LOJA = '"+cLoja+"'"
		cQuery += " AND E1_SALDO > 0"
		cQuery += " AND E1_TIPO  NOT IN('PR', 'NCC', 'RA')"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		If Select(cAlias) <> 0
			DBSelectArea(cAlias)
			DBCloseArea()
		EndIf  
		
		TCQUERY cQuery New Alias (cAlias) 
		
		nTitAber := (cAlias)->SALDO      
		
		(cAlias)->(DBCloseArea())
		
		
		//Busca todos os títulos em aberto e vencidos
		cQuery := " SELECT SUM(E1_SALDO) SALDO"
		cQuery += " FROM SE1"+cEmpr+"0 SE1 "
		cQuery += " WHERE E1_FILIAL = '"+cFili+"'" 
		cQuery += " AND E1_CLIENTE = '"+cCodigo+"'"
		cQuery += " AND E1_LOJA = '"+cLoja+"'"
		cQuery += " AND E1_SALDO > 0"
		cQuery += " AND E1_VENCREA < '"+dtos(dDataBase)+"'"   //17/05/2022 - Luciane pediu para deixar dDataBase-1
		cQuery += " AND E1_TIPO  NOT IN('PR', 'NCC', 'RA')"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		If Select(cAlias) <> 0
			DBSelectArea(cAlias)
			DBCloseArea()
		EndIf  
		
		TCQUERY cQuery New Alias (cAlias) 
		
		
		nTitVenc := (cAlias)->SALDO
		
		(cAlias)->(DBCloseArea())
		                                 
	    //Adiciona dados ao acols                           
		aAdd(aCols, {cDesc, nTitAber, nTitVenc, .F.})        
		                       
	endif
	SM0->(DBSkip())
enddo

Return

