#INCLUDE "PROTHEUS.CH"   
//-------------------------------------------------------------------
/* Função para acinar gatilho buscando o codigo do vendedor amarrado
ao operador do televendas no relacionamento com o cliente. Será acionado
o gatilho no preenchimento do atendimento do Call center.
                
@sample		U_TMKA1010()
@author		Débora Friebe
@since		24/06/2015     
@version 	P11  
-------------------------------------------------------------------  
Alteracao do gatilho para ativar novo codigo no televendas buscando o codigo
do grupo de tele do cadastro do cliente.
                
@author		Débora Friebe
@since	    06/07/2017  
@version 	P11  
 --------------------------------------------------------------------*/

User Function TMKA1010(cVend2)

Local cVend := ""  
Local cTele := "" 
Local cVend2 := ""
Local aAreaSA1 := SA1->(GetArea()) // Preserva o ambiente ativo. 
Local aAreaSU7 := SU7->(GetArea())  
Local cUsr := RetCodUsr()
Local cOper := "" 
Local cGrtele := "" 
                            
cOper := Posicione("SU7", 4, xFilial("SU7")+cUsr, "U7_VEND") // 1=Sim;2=Nao  
cGrtele := Posicione("SA1", 1, xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, "A1_XGRTELE")
cTele := Posicione("SA1", 1, xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, "A1_XTELEVE") 
cVend2 := Posicione("SU7", 1, xFilial("SU7")+cTele, "U7_CODVEN")

  If cOper == "1" .and. cGrtele <> " "   
    cVend := cGrtele
  ENDIF 
  
  IF cOper == "1" .and. Empty(cGrtele)
     cVend := cVend2
  EndIf   
	                                                             
  If cOper == "2"  
   	cVend := " "
  EndIF   
  
RestArea(aAreaSA1) // Restaura um ambiente salvo anteriormente pela função GETAREA().
RestArea(aAreaSU7) 

Return cVend
