//-------------------------------------------------------------------------------------------------------------
//Atualiza natureza financeira dos itens das notas fiscais de saída conforme tipo do atendimento no Call Center
//-------------------------------------------------------------------------------------------------------------
#include "protheus.ch"
#include "topconn.ch"

User Function MSD2460()

Local aArea	 := GetArea()             
Local cPed	 := SC5->C5_NUM
Local cQuery := ""

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea("TRB")
Endif

//Seleciona registros
cQuery := "SELECT UB_XNAT, UB_XOPER, UB_TES, UB_NUMPV "
cQuery += "FROM "
cQuery += RetSqlName("SUB")
cQuery += " WHERE "
cQuery += "       D_E_L_E_T_ = ' ' AND "
cQuery += "       UB_FILIAL = '"+xFilial("SUB")+"' AND "
cQuery += "       UB_NUMPV = '"+cPed+"' "
	
TcQuery cQuery New Alias "TRB"

If TRB->(!EoF())
	//Grava SC5  

	RecLock("SC5",.F.)	
	SC5->C5_MENPAD  := Posicione("SF4",1,xFilial("SF4")+TRB->UB_TES,"F4_FORMULA")
	SC5->C5_OPERADO := Posicione("SUA",8,xFilial("SUA")+cPed,"UA_OPERADO")
	SC5->C5_XIMPBOL := Posicione("SUA",8,xFilial("SUA")+cPed,"UA_XIMPBOL")
	SC5->C5_XBCOBOL := Posicione("SUA",8,xFilial("SUA")+cPed,"UA_XBCOBOL")
	MsUnlock()
	
	
	//Grava SD2 
	RecLock("SD2",.F.)
	SD2->D2_XNAT  := TRB->UB_XNAT
	SD2->D2_XOPER := TRB->UB_XOPER
	MsUnlock()
	
                     

EndIf

TRB->(DbCloseArea())


RestArea(aArea)


Return
