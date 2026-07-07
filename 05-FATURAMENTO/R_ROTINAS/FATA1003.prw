//-----------------------------------------
//Informa volume e peso no pedido de vendas
//-----------------------------------------
#include "protheus.ch"
#include "topconn.ch"

User Function FATA1003()

//Variáveis
Private aArea    := GetArea("SC5")   

Private cPerg    := "FTA1003" 
Private cValid   := ""
Private cF3      := ""
Private cPicture := ""
Private cDef01   := ""
Private cDef02   := ""
Private cDef03   := ""
Private cDef04   := ""
Private cDef05   := ""

Private cHelpP01 := "Informe Peso Liquido	    "
Private cHelpP02 := "Informe Peso Bruto		    "
Private cHelpP03 := "Informe Quantidade Volumes "
Private cHelpP04 := "Informe Especie Volumes    "
Private cHelpP05 := "Informe Tipo Frete         "
Private cHelpP06 := "Informe Transportadora     "
Private cHelpP07 := "Informe Nome Transportadora"

//Private aHelpP01 := {}
//Private aHelpP02 := {}
//Private aHelpP03 := {}
//Private aHelpP04 := {}
//Private aHelpP05 := {}
//Private aHelpP06 := {}
//Private aHelpP07 := {}   

Private aPergs   := {}

/*
//Cria perguntas e help caso não existam
AADD(aHelpP01, "Informe Peso Liquido	   ")
AADD(aHelpP02, "Informe Peso Bruto		   ")
AADD(aHelpP03, "Informe Quantidade Volumes ")
AADD(aHelpP04, "Informe Especie Volumes    ")
AADD(aHelpP05, "Informe Tipo Frete         ")
AADD(aHelpP06, "Informe Transportadora     ")
AADD(aHelpP07, "Informe Nome Transportadora")

/*
SX1->(dbSeek(xFilial("SX1")+cPerg,.T.))
If SX1->(!Found())
AADD(aPergs,{"Peso Liquido  ","Peso Liquido  ","Peso Liquido  ","mv_ch1","N",07,2,0,"C","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aPergs,{"Peso Bruto    ","Peso Bruto    ","Peso Bruto    ","mv_ch2","N",07,2,0,"C","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aPergs,{"Qtde Volumes  ","Qtde Volumes  ","Qtde Volumes  ","mv_ch3","N",04,0,0,"C","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aPergs,{"Especie       ","Especie       ","Especie       ","mv_ch4","C",10,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aPergs,{"Tipo Frete    ","Tipo Frete    ","Tipo Frete    ","mv_ch5","N",01,0,3,"C","","MV_PAR05","CIF","","","","","FOB","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aPergs,{"Transportadora","Transportadora","Transportadora","mv_ch6","C",06,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SA4001","","","",""})
AADD(aPergs,{"Nome          ","Nome          ","Nome          ","mv_ch7","C",40,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1(cPerg,aPergs)

PutSX1Help("P.FTA100301.",aHelpP01,,)
PutSX1Help("P.FTA100302.",aHelpP02,,)
PutSX1Help("P.FTA100303.",aHelpP03,,)
PutSX1Help("P.FTA100304.",aHelpP04,,)
PutSX1Help("P.FTA100305.",aHelpP05,,)
PutSX1Help("P.FTA100306.",aHelpP06,,)
PutSX1Help("P.FTA100307.",aHelpP07,,)
Endif
*/
/*
u_zPutSX1(cPerg, "01", "Peso Liquido  ","MV_PAR01", "MV_CH1","N",07,2,"C",cValid,cF3,cPicture,cDef01,cDef02,cDef03,cDef04,cDef05,cHelpP01)
u_zPutSX1(cPerg, "02", "Peso Bruto    ","MV_PAR02", "MV_CH2","N",07,2,"C",cValid,cF3,cPicture,cDef01,cDef02,cDef03,cDef04,cDef05,cHelpP02)
u_zPutSX1(cPerg, "03", "Qtde Volumes  ","MV_PAR03", "MV_CH3","N",04,0,"C",cValid,cF3,cPicture,cDef01,cDef02,cDef03,cDef04,cDef05,cHelpP03)
u_zPutSX1(cPerg, "04", "Especie       ","MV_PAR04", "MV_CH4","C",10,0,"G",cValid,cF3,cPicture,cDef01,cDef02,cDef03,cDef04,cDef05,cHelpP04)
u_zPutSX1(cPerg, "05", "Tipo Frete    ","MV_PAR05", "MV_CH5","N",01,0,"C",cValid,cF3,cPicture,"CIF" ,"FOB" ,cDef03,cDef04,cDef05,cHelpP05)
u_zPutSX1(cPerg, "06", "Transportadora","MV_PAR06", "MV_CH6","C",06,0,"G",cValid,"SA4001",cPicture,cDef01,cDef02,cDef03,cDef04,cDef05,cHelpP06)
u_zPutSX1(cPerg, "07", "Nome          ","MV_PAR07", "MV_CH7","C",40,0,"G",cValid,cF3,cPicture,cDef01,cDef02,cDef03,cDef04,cDef05,cHelpP07)  
*/

If Empty(SC5->C5_NOTA)
	If !Pergunte(cPerg,.T.)
		RestArea(aArea)
		Return
	Endif
	If RecLock("SC5",.F.)
		SC5->C5_PESOL   := IIF(mv_par01 == 0,SC5->C5_PESOL,mv_par01)
		SC5->C5_PBRUTO  := IIF(mv_par02 == 0,SC5->C5_PBRUTO,mv_par02)
		SC5->C5_VOLUME1 := IIF(mv_par03 == 0,SC5->C5_VOLUME1,mv_par03)
		SC5->C5_ESPECI1 := IIF(Empty(mv_par04),SC5->C5_ESPECI1,mv_par04)
		SC5->C5_TPFRETE := IIF(mv_par05 == 1,"C","F")
		SC5->C5_TRANSP	:= IIF(Empty(mv_par06),Space(TamSx3("C5_TRANSP")[1]),mv_par06)
		MsUnLock()
	Endif
Else
	ShowHelpDlg("Aviso", {"Pedidos faturados não podem ser alterados.",""},5,{"Exclua a nota fiscal de saída." ,""},5)
Endif

RestArea(aArea)

Return
