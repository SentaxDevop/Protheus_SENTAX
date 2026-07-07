#INCLUDE "TOTVS.CH"
   


//-------------------------------------------------------------------
/*/{Protheus.doc} CurvaABCF
Funcao que valida valores informado nos campos 
MV_PAR03
MV_PAR04
MV_PAR05



@author  Henrique Baldin	
@since   13/08/2014                                                


/*/
//-------------------------------------------------------------------
User Function VpegABC()
Local lRet := .T.
           
If MV_PAR03 >=100 .OR. MV_PAR03 <0
    MsgAlert("Valor da Curva A nao pode ser Superior a 100 ou menor que 0")
	lRet :=.F.
EndIf
If MV_PAR04 >=100 .OR. MV_PAR04 <0
    MsgAlert("Valor da Curva B nao pode ser Superior a 100  ou menor que 0")
	lRet :=.F.
EndIf
If lRet
	MV_PAR05 := 100 - (MV_PAR03 + MV_PAR04) 
EndIf

Return(lRet)