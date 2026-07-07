//-------------------------------------------------------------------
/*/{Protheus.doc} TMKA1006
Função de DE / PARA para troca de carteira dos operadores do cadastro
de cliente

@author Suelen Regina de Souza
@since 27/12/2013
@version P11
/*/
//-------------------------------------------------------------------
#include "totvs.ch"
#include "topconn.ch"                                                               

User Function TMKA1006()
Local aArea     	:= GetArea()
Local oDlg
Local cPerg         := "TMKA1006" //Guarda o nome da pergunta
Local oOk			:= LoadBitMap(GetResources(), "LBOK")
Local oNo			:= LoadBitMap(GetResources(), "LBNO")
Local lMarca		:= .F.
Local aF4For 		:= {}      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a chamada da pergunta                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte(cPerg,.T.)
	Return()
EndIf

cQuery := " SELECT * "
cQuery += "   FROM " + RetSQLName("SA1")+ " "
cQuery += "  WHERE D_E_L_E_T_ = ' ' " 
cQuery += "    AND A1_XTELEVE = '" + MV_PAR01 + "'"
cQuery += " ORDER BY A1_COD, A1_LOJA"

cQuery := ChangeQuery(cQuery)

cAliasTmp := "TMPSA1"

dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasTMP, .F., .f.)

                                                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o arquivo de trabalho                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cAliasTMP)->(DbGotop())
DO WHILE (cAliasTMP)->(!EOF())

	Aadd(aF4For,{ lMarca, (cAliasTMP)->A1_COD, (cAliasTMP)->A1_LOJA, Alltrim((cAliasTMP)->A1_NOME), (cAliasTMP)->A1_XTELEVE, POSICIONE("SU7",1, xFilial("SU7") + (cAliasTMP)->A1_XTELEVE , "U7_NOME") })
	
	(cAliasTMP)->(DbSkip())
ENDDO
 
IF EMPTY(aF4For)

	Aadd(aF4For,{lMarca, , , , , })
	
ENDIF

aTitCampos := {" ","Codigo","Loja","Nome","Operador","Nome"}

DEFINE MSDIALOG oDlg FROM  0,0 TO 502,990 TITLE "Transferencia de Carteira" PIXEL

@ 003, 004  TO 45, 493 LABEL "Informações da Transferencia" OF oDlg  PIXEL

nLin := 15

@ nLin,010    	SAY "Do Operador"        SIZE 80, 7  OF oDlg PIXEL
@ nLin-2,65 	GET MV_PAR01	    	 WHEN .F.   OF oDlg PIXEL

@ nLin, 120    	SAY "Nome"     		     SIZE 35, 7  OF oDlg PIXEL
@ nLin-2,146 	GET POSICIONE("SU7",1, xFilial("SU7") + MV_PAR01 , "SU7->U7_NOME")  WHEN .F.   OF oDlg PIXEL

nLin += 15

@ nLin,010    	SAY "Para o Operador"    SIZE 80, 7  OF oDlg PIXEL
@ nLin-2,65 	GET MV_PAR02      			 WHEN .F. OF oDlg PIXEL

@ nLin, 120    	SAY "Nome"     		     SIZE 35, 7  OF oDlg PIXEL
@ nLin-2,146 	GET POSICIONE("SU7",1, xFilial("SU7") + MV_PAR02 , "SU7->U7_NOME")        		 WHEN .F.   OF oDlg PIXEL

nLin += 17

@ nLin, 004  TO 232, 493 LABEL "Clientes para Transferencia" OF oDlg  PIXEL

oListBox := TWBrowse():New(55,8,481,173,,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oListBox:SetArray(aF4For)
oListBox:bLDblClick := { || aF4For[oListBox:nAt,1] := !aF4For[oListBox:nAt,1]}
oListBox:bLine		:= { || {if(aF4For[oListBox:nAT][1],oOk,oNo) , aF4For[oListBox:nAT][2] , aF4For[oListBox:nAT][3], aF4For[oListBox:nAT][4], aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6]}}

@ 236, 005 BUTTON "Marca/Desmarca"   SIZE 50,11 FONT oDlg:oFont ACTION (MarDes()) OF oDlg PIXEL

@ 236, 060 BUTTON "Confirmar"   	 SIZE 50,11 FONT oDlg:oFont ACTION (ConfTela(),oDlg:End())  OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg


Return
                                                                       
//-------------------------------------------------------------------
/*/{Protheus.doc} TMKA1006
Marca e Desmarca os Registros da Tela

@author Suelen Regina de Souza
@since 27/12/2013
@version P11
/*/
//-------------------------------------------------------------------

Static Function MarDes()

FOR I:=1 TO LEN(oListBox:AARRAY)
	IF oListBox:AARRAY[I][1]
		oListBox:AARRAY[I][1] := .F.
		oListBox:DrawSelect()
	ELSE 
		oListBox:AARRAY[I][1] := .T. 
		oListBox:DrawSelect()
	ENDIF                  
NEXT     
 
oListBox:Refresh()

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} TMKA1006
Marca e Desmarca os Registros da Tela

@author Suelen Regina de Souza
@since 27/12/2013
@version P11
/*/
//-------------------------------------------------------------------]
Static Function ConfTela()     

DbSelectArea("SA1")
SA1->(dbSetOrder(1)) 

FOR I:=1 TO LEN(oListBox:AARRAY)
	IF oListBox:AARRAY[I][1]
		
		SA1->(DbGotop())
		IF SA1->(DbSeek(xFilial("SA1") + oListBox:AARRAY[I][2] + oListBox:AARRAY[I][3]))
			RecLock("SA1",.F.)
			SA1->A1_XTELEVE := MV_PAR02 
			SA1->A1_ATEND	:= SUBSTR(POSICIONE("SU7",1, xFilial("SU7") + MV_PAR02 , "U7_NOME"),1,TAMSX3("U7_NOME")[1])
			SA1->(MsUnLock())
		ENDIF 
	
	ENDIF                  
NEXT     

Return

