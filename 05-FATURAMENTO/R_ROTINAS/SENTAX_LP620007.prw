//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#include 'parmtype.ch'
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} LP620007
Excbloq para contabilizacao LP620.007
chamada: ExecBlock("LP620007",.F.,.F.)
@author João AFSouza
@since 07/11/2019
@version 1.0
@example u_LP620007 ()
/*/

User Function LP620007() 

	// declaração das variáveis	
	Local _Area   := Alias()
	Local _Ordem  := IndexOrd()
	Local _Reg    := Recno()
	Local _nVal   := 0
	Local _cFil   := SF2->F2_FILIAL
	Local _cDoc   := SF2->F2_DOC 
	Local _cSerie := SF2->F2_SERIE 
	Local _cEmis  := DTOS(SF2->F2_EMISSAO)


	cQuery := "		SELECT                                "
	cQuery += "    D2_VALICM                              "
	cQuery += " FROM " + RetSQLName("SD2") + " SD2        "
	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4  "
	cQuery += "      ON F4_CODIGO = D2_TES                " 
	cQuery += " WHERE                                     "
	cQuery += "    D2_FILIAL = '"+_cFil+"'                "
	cQuery += "    AND SD2.D_E_L_E_T_ = ''                " 
	cQuery += "    AND SF4.D_E_L_E_T_ = ''                "
	cQuery += "    AND D2_DOC = '"+_cDoc+"'               "
	cQuery += "    AND D2_SERIE = '"+_cSerie+"'           "
	cQuery += "    AND D2_EMISSAO = '"+_cEmis+"'          "
	cQuery += "    AND F4_LFICM = 'T'                     "
	cQuery += "    AND                                    "
	cQuery += "    (                                      "
	cQuery += "       D2_CF NOT IN                        "
	cQuery += "       (                                   "
	cQuery += "          '6152',                          "
	cQuery += "          '6910',                          "
	cQuery += "          '5910'                           "
	cQuery += "       )                                   "
	cQuery += "       OR D2_SERIE <> 'E'                  "
	cQuery += "       OR D2_TIPO <> 'D'                   "
	cQuery += "    )                                      "

	If select("TSD2") > 0
		dbSelectArea("TSD2")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TSD2"

	_nVal := TSD2->D2_VALICM

	dbSelectArea(_Area)
	dbSetOrder(_Ordem)
	dbGoto(_Reg)


Return(_nVal)