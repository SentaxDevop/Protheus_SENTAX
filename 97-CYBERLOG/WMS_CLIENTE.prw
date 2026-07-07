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
User Function fExpCli (cOPc,lJob,cCliInf,cLojInf)
	Local aSA1			:= {}
	Local aRet			:= {}
	Local cPerg			:= PadR('WMSEXPSA1',10)
	Local cCRLF			:= CRLF
	Local _cLog			:= ""
	Local _cErro		:= ""
	Local _lErro 		:= .f.
	Local _nhdllog		:= 0
	Local _cDir			:= ""
	Local _cArqLg		:= "Log_Wms_Cli"
	Local _cDirTemp		:= IIF(!IsBlind(),GetTempPath(),"C:\temp")

	Default lJob 		:= .f.
	Default cCliInf 	:= ""
	Default cLojInf 	:= ""

	If cOPc == 'M'
		aSA1 := SA1->(GetArea())

		fSX1ExpCli(cPerg)
		If Pergunte(cPerg,.T.)

			SA1->(DbSetOrder(1))
			SA1->(DbGoTop())
			SA1->(DbSeek(FWxFilial("SA1") + MV_PAR01,.T.))
			While !SA1->(EOF()) .And. SA1->A1_FILIAL == FWxFilial("SA1") .And. SA1->A1_COD <= MV_PAR02

				IncProc("Exportando Codigo Cliente " + SA1->A1_COD)
				
				//Endpoint PESSOA é utilizado tendo em vista a replicação do Cliente para o cadastro de Fornecedor
				aRet:= U_fConJson(GetMv('FZ_WSWMS4'))

				If !aRet[1]
					_lErro := .t.

					_cErro 	+=    Padl(SA1->A1_COD,6)   + Space(2);
						+ Padl(SA1->A1_LOJA,4) 	+ Space(2);
						+ Alltrim(Decodeutf8(aRet[2])) ;
						+ cCRLF

					RecLock("SA1",.F.)
						SA1->A1_XSTAWMS := "F"
					MSUNLOCK()

				Else
					RecLock("SA1",.F.)
						SA1->A1_XSTAWMS := "E"
						SA1->A1_XERPID  := "C"+Alltrim(SA1->A1_COD)+Alltrim(SA1->A1_LOJA)
					MSUNLOCK()
				Endif

				SA1->(DbSkip())
			EndDo

		Endif
		RestArea(aSA1)

	Else
		If lJob
			RPCSetType(3)
			If !RpcSetEnv("01","020201",,,,GetEnvServer(),{ })
				Conout("")
				Conout("Empresa nao localizada")
			Else
				lRpcSetEnv := .F.
			EndIf

			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(FWxFilial("SA1") + cCliInf + cLojInf))

		EndIf

		Conout("")
		Conout("Exportando Codigo --> " + SA1->A1_COD + "/" +  SA1->A1_LOJA)

		//Endpoint PESSOA é utilizado tendo em vista a replicação do Cliente para o cadastro de Fornecedor
		aRet:= U_fConJson(GetMv('FZ_WSWMS4'))
		If aRet[1]

			Conout("")
			Conout("Cliente criado/atualizado no WMS --> " + SA1->A1_COD + "/" +  SA1->A1_LOJA)

			RecLock("SA1",.F.)
                SA1->A1_XSTAWMS := "E"
                SA1->A1_XERPID  := "C"+Alltrim(SA1->A1_COD)+Alltrim(SA1->A1_LOJA)
            MSUNLOCK()

		Else

			Conout("")
			Conout("Cliente NAO criado/atualizado no WMS(ERRO) --> " + SA1->A1_COD + "/" +  SA1->A1_LOJA)
			Conout(aRet[2])
			Conout(aRet[3])

			RecLock("SA1",.F.)
                SA1->A1_XSTAWMS := "F"
            MSUNLOCK()


		Endif

	Endif

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
			FWAlertSuccess("Cliente exportado para o WMS com sucesso!", "Integração WMS - Cliente")
		EndIf
	EndIf

Return

/*/{Protheus.doc} fSX1ExpCli
Cria Grupo de Pergntas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
Static Function fSX1ExpCli(cPerg)

	cPerg := PADR(cPerg,10)

	CheckSX1(cPerg, "01", "Cliente De?"	, "Cliente De?"	, "Cliente De?"	, "mv_ch1"		, "C", TamSX3("A1_COD")[1], 0, 0, "G", "", "SA1"	,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "02", "Cliente Ate?", "Cliente Ate?", "Cliente Ate?", "mv_ch2"		, "C", TamSX3("A1_COD")[1], 0, 0, "G", "", "SA1"	,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

Return()
