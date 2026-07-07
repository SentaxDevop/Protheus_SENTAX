#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "FWPRINTSETUP.CH" 
#INCLUDE "APWEBEX.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} fExpProd
Função para exportar os registros em Lote
@type function
@since 21/12/2020
@version 12.1.27
/*/
User Function fExpFor(cOPc)

	Local aSA2      := GetArea()
	Local cPerg     := PadR( 'WMSEXPSA2' ,10)
	Local aRet      := {}
	Local cCRLF     := CRLF
	Local _cLog     := ""
	Local _cErro    := ""
	Local _lErro    := .f.
	Local _nhdllog  := 0
	Local _cDir     := ""
	Local _cArqLg   := "Log_Wms_For"
	Local _cDirTemp := IIF(!IsBlind(),GetTempPath(),"C:\temp")

	Default lJob 		:= .f.
	Default cCliInf 	:= ""
	Default cLojInf 	:= ""

	If cOPc == 'M'
		fSX1ExpFor(cPerg)
		If Pergunte(cPerg,.T.)

			SA2->(DbSetOrder(1))
			SA2->(DbSeek(FWxFilial("SA2")+MV_PAR01,.T.))
			While ! SA2->(Eof()) .and. SA2->A2_COD <= MV_PAR02

				IncProc("Exportando Codigo Fornecedor " + SA2->A2_COD)

				//Endpoint PESSOA é utilizado tendo em vista a replicação do Fornecedor para o cadastro de Cliente
				aRet:= U_fConJson(GetMv('FZ_WSWMS4'))
				
				If aRet[1]

					Conout("")
					Conout("Fornecedor criado/atualizado no WMS --> " + SA2->A2_COD + "/" +  SA2->A2_LOJA)

					RecLock("SA2",.F.)
						SA2->A2_XSTAWMS := "E"
						SA2->A2_XERPID  := "F"+Alltrim(SA2->A2_COD)+Alltrim(SA2->A2_LOJA)
					MSUNLOCK()

				else

					_lErro := .t.

					_cErro 	+=    Padl(SA2->A2_COD,6)   + Space(2);
						+ Padl(SA2->A2_LOJA,4) 	+ Space(2);
						+ Alltrim(Decodeutf8(aRet[2])) ;
						+ cCRLF

					RecLock("SA2",.F.)
						SA2->A2_XSTAWMS := "F"
					MSUNLOCK()

				Endif
				SA2->(DbSkip())
			End

		Endif

	Else
		
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(FWxFilial("SA2")+SA2->A2_COD+SA2->A2_LOJA))
		IncProc("Exportando Codigo Fornecedor" + SA2->A2_COD)
		
		//Endpoint PESSOA é utilizado tendo em vista a replicação do Fornecedor para o cadastro de Cliente
		aRet:= U_fConJson(GetMv('FZ_WSWMS4'))
	
		If aRet[1]
			Conout("")
			Conout("Fornecedor criado/atualizado no WMS --> " + SA2->A2_COD + "/" +  SA2->A2_LOJA)

			RecLock("SA2",.F.)
                SA2->A2_XSTAWMS := "E"
                SA2->A2_XERPID  := "F"+Alltrim(SA2->A2_COD)+Alltrim(SA2->A2_LOJA)
            MSUNLOCK()

		Else

			Conout("")
			Conout("Fornecedor NAO criado/atualizado no WMS(ERRO) --> " + SA2->A2_COD + "/" +  SA2->A2_LOJA)
			Conout(aRet[2])
			Conout(aRet[3])

			RecLock("SA2",.F.)
                SA2->A2_XSTAWMS := "F"
            MSUNLOCK()

		Endif
	endif

	If _lErro .And. !IsBlind()
		/*LOG*/
		_nhdllog 	:= U_ACOM000H(@_cDir,@_cArqLg,_nhdllog)	//Cria o arquivo

		_clog 	:= "Log - ENVIO WMS    " + cCRLF + cCRLF
		//_clog 	+= "Arquivo..................: " + Upper(Alltrim(cFile)) + cCRLF
		_clog 	+= "Data.....................: " + Dtoc(date()) + cCRLF
		_clog 	+= "Hora.....................: " + Time() + cCRLF

		_clog 	+= Replicate ("-",60)+ cCRLF + cCRLF
		//          001     12345678        123456789*1   99/99/9999   999,999,999,999.99    12345678901234567
		_clog 	+= "COD     LOJA  ERRO" + cCRLF
		//		   "                                                                                                                                           "
		FWrite( _nhdllog, _clog, Len(_clog) )

		_clog := ""
		_clog := _cErro

		FWrite(_nhdllog, _clog, Len(_clog) )
		_clog 	:= ""

		/* LOG */
		If !FCLOSE(_nhdllog)
			Conout( "Erro ao fechar arquivo, erro numero: " + STR(FERROR()) )
		EndIf

		IncProc("Abrindo Log de importação...")
		U_ACOM000I(_cDir,_cArqLg,_cDirTemp) //exibe arquivo de log

	Else
		If !IsBlind()
			FWAlertSuccess("Fornecedor exportado para o WMS com sucesso!", "Integração WMS - Fornecedor")
		EndIf
	EndIf

	RestArea(aSA2)

Return

/*/{Protheus.doc} fSX1ExpfOR
Cria Grupo de Pergntas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
Static Function fSX1ExpFor(cPerg)

cPerg := PADR(cPerg,10)

CheckSX1(cPerg, "01", "Fornecedor De?"	, "Fornecedor De?"	, "Fornecedor De?"	, "mv_ch1"		, "C", TamSX3("A2_COD")[1], 0, 0, "G", "", "SA2"	,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "02", "Fornecedor Ate?"	, "Fornecedor Ate?"	, "Fornecedor Ate?"	, "mv_ch2"		, "C", TamSX3("A2_COD")[1], 0, 0, "G", "", "SA2"	,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

Return()
