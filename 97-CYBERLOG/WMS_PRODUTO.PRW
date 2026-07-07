#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "FWPRINTSETUP.CH" 
#INCLUDE "APWEBEX.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PARMTYPE.CH"

User Function fVJsonPr
Local cJson:= U_fGrJson( GetMv('FZ_WSWMS1') )

EECVIEW( cJson )

Return


User Function fExpProd(cOPc) 

	Local aSB1	:= GetArea()
	Local cPerg	:= PadR('WMSEXPSB1',10)
	Local aRet	:= {}

	If cOPc == 'M'
		fSX1ExpPro(cPerg)
		If Pergunte(cPerg,.T.)

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(FWxFilial("SB1")+MV_PAR01,.T.))
			While ! SB1->(Eof()) .and. SB1->B1_COD <= MV_PAR02

				IncProc("Exportando Codigo " + SB1->B1_COD)
						aRet:= U_fConJson(GetMv('FZ_WSWMS1'))
				SB1->(DbSkip())
			End
		Endif
	else
			aRet:= U_fConJson(GetMv('FZ_WSWMS1'),'SB1',1,'B1_FILIAL+B1_COD',M->B1_FILIAL+M->B1_COD)
	ENDIF

	If aRet[1]
		FWAlertSuccess("Produto enviado com sucesso para o WMS." + CRLF + "Retorno:(" + aRet[2] + ")")
	else
		FWAlertError("Falha no envio do produto para o WMS. Retorno:(" + aRet[2] + ")")
	End

	RestArea(aSB1)

Return


Static Function fSX1ExpPro(cPerg)

cPerg := PADR(cPerg,10)

CheckSX1(cPerg, "01", "Produto De?"		, "Produto De?"		, "Produto De?"		, "mv_ch1"		, "C", TamSX3("B1_COD")[1], 0, 0, "G", "", "SB1"	,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "02", "Produto Ate?"	, "Produto Ate?"	, "Produto Ate?"	, "mv_ch2"		, "C", TamSX3("B1_COD")[1], 0, 0, "G", "", "SB1"	,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

Return()

