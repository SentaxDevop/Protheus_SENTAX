#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"
#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

//==================================================================================================//
//	Programa: FP34R02A		|	Autor: Luis Paulo							|	Data: 12/04/2018	//
//==================================================================================================//
//	Descrição: Impressao do Relatório Sintético de contas 											//
//																									//
//==================================================================================================//
User Function FP34R02A(dDtaIni,dDtaFim)
Local _nF		:= 1
Local aPosiIm	:= {}
Local nCol2		:= 0580
Local cMask		:= GetMv("MV_MASCARA")
Local oFonte

/*fontes*/
Private dDtaIn	:= dDtaIni
Private dDtaFi	:= dDtaFim

Private	oFont05
Private oFont05n
Private oFont06
Private oFont06n
Private oFont07
Private oFont07n
Private oFont08
Private oFont08n
Private oFont09
Private oFont09n
Private oFont10
Private oFont10n
Private oFont11
Private oFont11n
Private oFont12
Private oFont12n
Private oFont13
Private oFont13n
Private oFont14
Private oFont14n
Private oFont15
Private oFont15n
Private oFont16
Private oFont16n
Private oFont17
Private oFont17n
Private oFont18
Private oFont18n
Private nPag		:= 1
Private nLin		:= 0020

NFonte(_nF)			//carrega as fontes

If Buscar()
	MsgAlert("Não existem dados!!!, favor verificar os parâmetros!!")
	Return .T.
EndIf

oPrn:StartPage()
oPrn:Box(010,040,785,580)
aPosiIm	:= Cabec()

ProcRegua(nRegs)
nCount		:= 0		
While !cAlias->(EOF())
	
	nCount++
	IncProc('Imprimindo  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	If Alltrim(cAlias->ZTB_TPCTA) == '1'
			oFonte	:= "oFont06n"
		Else
			oFonte	:= "oFont06"
	EndIf
	
	If _cPerg8 == 1
		If (cAlias->ZTB_SLDANT == 0) .And. (cAlias->ZTB_DEBITO == 0) .And. (cAlias->ZTB_CREDIT == 0) .And. (cAlias->ZTB_SLDATU == 0) 
			cAlias->(DbSkip())
			Loop
		EndIf
	EndIf
	
	oPrn:SayAlign (nLin += 10	, aPosiIm[1]	, MascaraCTB(cAlias->ZTB_CTACT1)								, &oFonte,nCol2,,,0,)
	oPrn:SayAlign (nLin 		, aPosiIm[2]	, SUBSTR(cAlias->ZTB_FILCQ0,((Len(cAlias->ZTB_FILCQ0))-4),5)	, &oFonte,nCol2,,,0,)
	oPrn:SayAlign (nLin 		, aPosiIm[3]	, cAlias->ZTB_DESCTA 											, &oFonte,nCol2,,,0,)
	
	If Substr(Alltrim(cAlias->ZTB_CTACT1),1,1) == "1" //Ativo
			
			If cAlias->ZTB_CTACD == '1' //Se devedora
					If (cAlias->ZTB_SLDANT < 0) //Obrigatoriamente fica SEM parenteses, exceto quando virar devedora(estourada)
							oPrn:SayAlign (nLin 	, 0000	, Alltrim(Transform(cAlias->ZTB_SLDANT,'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)	
						
						ElseIf (cAlias->ZTB_SLDANT == 0)
							oPrn:SayAlign (nLin 	, 0000	, Alltrim(Transform(cAlias->ZTB_SLDANT,'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
							
						Else
							oPrn:SayAlign (nLin 	, 0000	, Alltrim(Transform(cAlias->ZTB_SLDANT,'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
					EndIf
					
				Else					//Credora
					If (cAlias->ZTB_SLDANT < 0) //Obrigatoriamente fica COM parenteses, exceto quando virar devedora(estourada)
							oPrn:SayAlign (nLin 	, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
						
						ElseIf (cAlias->ZTB_SLDANT == 0)
							oPrn:SayAlign (nLin 	, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
							
						Else
							oPrn:SayAlign (nLin 	, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
					EndIf
			EndIf
			
		Else //2Passivo-3Resultado-7Apuracao
			If cAlias->ZTB_CTACD == '1' //Se devedora
					
					If (cAlias->ZTB_SLDANT > 0) //Obrigatoriamente fica COM parenteses, exceto quando virar devedora(estourada)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
							
						ElseIf (cAlias->ZTB_SLDANT == 0)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
							
						Else
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)	
					EndIf
					
				Else					//Credora
					If (cAlias->ZTB_SLDANT > 0) //Obrigatoriamente fica SEM parenteses, exceto quando virar devedora(estourada)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
						
						ElseIf (cAlias->ZTB_SLDANT == 0)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
							
						Else
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[4],,,1,)
					EndIf
			EndIf
	EndIf
	
	/*
	//Regra dos parenteses
	If (cAlias->ZTB_CTACD == '1' .And. cAlias->ZTB_SLDANT < 0 .OR. cAlias->ZTB_SLDANT = 0) .OR. (cAlias->ZTB_CTACD == '2' .And. cAlias->ZTB_SLDANT > 0 .OR. cAlias->ZTB_SLDANT = 0)
			
			If Alltrim(cAlias->ZTB_TPCTA) == '1' //Cta sintetica
					oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform(ABS(cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), oFont06n,aPosiIm[4],,,1,)
				Else
					oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform(ABS(cAlias->ZTB_SLDANT),'@E 999,999,999,999.99')), oFont06,aPosiIm[4],,,1,)
			EndIf
			
			
		Else
			If Alltrim(cAlias->ZTB_TPCTA) == '1' //Cta sintetica
					oPrn:SayAlign (nLin 		, 0000	, "("+Alltrim(Transform(ABS(cAlias->ZTB_SLDANT),'@E 999,999,999,999.99'))+")", oFont06n,aPosiIm[4],,,1,)
				Else
					oPrn:SayAlign (nLin 		, 0000	, "("+Alltrim(Transform(ABS(cAlias->ZTB_SLDANT),'@E 999,999,999,999.99'))+")", oFont06,aPosiIm[4],,,1,)
			EndIf
			
	EndIf
	*/
	
	oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform(ABS(cAlias->ZTB_DEBITO),'@E 999,999,999,999.99')), &oFonte,aPosiIm[5],,,1,)
	oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform(ABS(cAlias->ZTB_CREDIT),'@E 999,999,999,999.99')), &oFonte,aPosiIm[6],,,1,)
	
	/*
	//Regra dos parenteses
	If (cAlias->ZTB_CTACD == '1' .And. cAlias->ZTB_SLDATU < 0 .OR. cAlias->ZTB_SLDATU = 0 ) .OR. (cAlias->ZTB_CTACD == '2' .And. cAlias->ZTB_SLDATU > 0 .OR. cAlias->ZTB_SLDATU = 0)
			If Alltrim(cAlias->ZTB_TPCTA) == '1' //Cta sintetica
					oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform(ABS(cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), oFont06n,aPosiIm[7],,,1,)
				Else
					oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform(ABS(cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), oFont06,aPosiIm[7],,,1,)
			EndIf
			
		Else
			If Alltrim(cAlias->ZTB_TPCTA) == '1' //Cta sintetica
					oPrn:SayAlign (nLin 		, 0000	, "("+Alltrim(Transform(ABS(cAlias->ZTB_SLDATU),'@E 999,999,999,999.99'))+")", oFont06n,aPosiIm[7],,,1,)
				Else
					oPrn:SayAlign (nLin 		, 0000	, "("+Alltrim(Transform(ABS(cAlias->ZTB_SLDATU),'@E 999,999,999,999.99'))+")", oFont06,aPosiIm[7],,,1,)
			EndIf
			
	EndIf
	*/
	
	If Substr(Alltrim(cAlias->ZTB_CTACT1),1,1) == "1" //Ativo
			
			If cAlias->ZTB_CTACD == '1' //Se devedora
					
					If (cAlias->ZTB_SLDANT < 0) //Obrigatoriamente fica SEM parenteses, exceto quando virar devedora(estourada)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)	
						
						ElseIf (cAlias->ZTB_SLDANT == 0)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
							
						Else
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
					EndIf
					
				Else					//Credora
					If (cAlias->ZTB_SLDANT < 0) //Obrigatoriamente fica COM parenteses, exceto quando virar devedora(estourada)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
						
						ElseIf (cAlias->ZTB_SLDANT == 0)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
							
						Else
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
					EndIf
					
				
			EndIf
			
		Else //2Passivo-3Resultado-7Apuracao
			If cAlias->ZTB_CTACD == '1' //Se devedora
					
					If (cAlias->ZTB_SLDANT > 0) //Obrigatoriamente fica COM parenteses, exceto quando virar devedora(estourada)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
							
						ElseIf (cAlias->ZTB_SLDANT == 0)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
							
						Else
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)	
					EndIf
					
				Else					//Credora
					If (cAlias->ZTB_SLDANT > 0) //Obrigatoriamente fica SEM parenteses, exceto quando virar devedora(estourada)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
						
						ElseIf (cAlias->ZTB_SLDANT == 0)
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
							
						Else
							oPrn:SayAlign (nLin 		, 0000	, Alltrim(Transform((cAlias->ZTB_SLDATU),'@E 999,999,999,999.99')), &oFonte,aPosiIm[7],,,1,)
					EndIf
			EndIf
	EndIf
	
	If nLin > 770
		nPag++					//Caso o numero de linha maior que 690 pula para próxima pagina
		oPrn:EndPage()			//Fecha a pagina
		oPrn:StartPage()		//Inicia a outra pagina
		nLin		:= 0030
		oPrn:Box(010,040,785,580)
		aPosiIm	:= Cabec()			//135
	EndIf
	
	cAlias->(DbSkip())
EndDo


If nLin > 730
	nPag++					//Caso o numero de linha maior que 690 pula para próxima pagina
	oPrn:EndPage()			//Fecha a pagina
	oPrn:StartPage()		//Inicia a outra pagina
	nLin		:= 0030
	oPrn:Box(010,040,785,580)
	aPosiIm	:= Cabec()			//135
EndIf

DbSelectArea("CVB")
DbOrderNickName("RESPONCTBF")
CVB->(DbGoTop())
If CVB->(DbSeek(xFilial("CVB") + "S"))
	cNomeCTB		:= Alltrim(CVB->CVB_NOME)
	cCRCCTB			:= Alltrim(CVB->CVB_CRC)
	cMailCTB		:= Alltrim(CVB->CVB_EMAIL)
EndIf

oPrn:SayAlign (nLin += 32, 0000	, cNomeCTB , oFont06n,nCol2,,,2,)
oPrn:SayAlign (nLin += 05, 0000	, "Contador CRC/PR "+cCRCCTB+"" , oFont06n,nCol2,,,2,)
oPrn:SayAlign (nLin += 05, 0000	, cMailCTB , oFont06n,nCol2,,,2,)

cAlias->(DBCloseArea())
oPrn:EndPage()		//Finaliza a pagina

Return()


//IMPRIME O CABEÇALHO PRINCIPAL
Static Function Cabec()
Local nCol1		:= 0590
Local nCol2		:= nCol1 - 10
Local nCol3		:= nCol2 - 32
Local cNomFil	:= FWFilialName("01",aSelFil[1])
Local nLinOri	:= 0
Local nCol4		:= 0050
Local aPosiIm	:= {}

cLogotipo := "lgrl01.bmp"
oPrn:SayBitMap( nLin, 0050, cLogotipo, 104, 40)

oPrn:say( nLin, nCol3				, "Pág.: " + Alltrim(Transform(nPag,'@R 999999'))					, oFont06,1400,, 		)
nLinOri	:= nLin

oPrn:say( nLin += 10, nCol3 -= 28	, DTOC(Date()) + " - " + Time()							, oFont06,1400,,		)//-47
oPrn:say( nLin += 10, nCol3 -= 23	, "Rua João Negrão, 280 - Centro" 						, oFont06,1400,,		)//-33
oPrn:say( nLin += 10, nCol3 -= 08	, "CEP 80010-200 - Curitiba - Paraná" 					, oFont06,1400,,		)//-12
oPrn:say( nLin += 10, nCol3 -= 49	, "Telefone |41| 3360-7400 - e-mail funpar@funpar.ufpr.br" 		, oFont06,1400,,		)//-37
//oPrn:say( nLin += 10, nCol3 -= 14	, "www.funpar.ufpr.br | e-mail funpar@funpar.ufpr.br" 	, oFont10,1400,,		)//-14

nLin	:= nLinOri + 0005

If nTipoCab == 2
 		oPrn:SayAlign (nLin, 0000	, "FUNDAÇÃO DA UFPR P/ O DCTC" , oFont06n,nCol2,,,2,)
 	Else
 		oPrn:SayAlign (nLin, 0000	, Alltrim(cNomFil) , oFont06n,nCol2,,,2,) 		
EndIf 
oPrn:SayAlign (nLin += 12, 0000	, "78.350.188/0001-95" , oFont06,nCol2,,,2,)
oPrn:SayAlign (nLin += 12, 0000	, "BALANCETE DE VERIFICACAO, DE "+ DTOC(dDtaIn) + " ATE " + DTOC(dDtaFi)  , oFont06,nCol2,,,2,)

oPrn:line(nLin += 15, 0040, nLin, nCol2 )
oPrn:line(nLin += 02, 0040, nLin, nCol2 )

oPrn:SayAlign (nLin += 05	, nCol4			, "CONTA" 		, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 70	, "FILIAL" 		, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 60	, "DESCRICAO" 	, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4)
oPrn:SayAlign (nLin 		, nCol4 += 190	, "SLD ANT." 	, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4+25)
oPrn:SayAlign (nLin 		, nCol4 += 70	, "DÉBITO" 		, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4+20)
oPrn:SayAlign (nLin 		, nCol4 += 50	, "CRÉDITO" 	, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4+25)
oPrn:SayAlign (nLin 		, nCol4 += 50	, "SLD ATUAL" 	, oFont06,nCol2,,,0,)
aAdd(aPosiIm,nCol4+30)
oPrn:line(nLin += 10, 0040, nLin, nCol2)

Return(aPosiIm)


Static Function NFonte(_nF)
Private	_nFonte	:= _nF

If 	_nFonte == 1
		oFont05 	:= TFont():New("Arial"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Arial"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Arial"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Arial"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Arial"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Arial"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Arial"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Arial"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Arial"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Arial"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Arial"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Arial"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Arial"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Arial"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Arial"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Arial"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Arial"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Arial"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Arial"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Arial"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Arial"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Arial"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Arial"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Arial"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Arial"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Arial"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 2
		oFont05 	:= TFont():New("Times New Roman"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Times New Roman"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Times New Roman"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Times New Roman"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Times New Roman"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Times New Roman"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Times New Roman"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Times New Roman"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Times New Roman"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Times New Roman"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Times New Roman"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Times New Roman"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Times New Roman"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Times New Roman"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Times New Roman"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Times New Roman"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Times New Roman"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Times New Roman"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Times New Roman"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Times New Roman"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Times New Roman"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Times New Roman"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Times New Roman"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Times New Roman"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Times New Roman"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Times New Roman"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 3
		oFont05 	:= TFont():New("Calibri"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Calibri"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Calibri"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Calibri"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Calibri"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Calibri"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Calibri"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Calibri"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Calibri"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Calibri"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Calibri"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Calibri"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Calibri"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Calibri"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Calibri"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Calibri"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Calibri"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Calibri"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Calibri"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Calibri"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Calibri"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Calibri"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Calibri"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Calibri"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Calibri"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Calibri"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 4
		oFont05 	:= TFont():New("Verdana"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Verdana"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Verdana"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Verdana"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Verdana"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Verdana"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Verdana"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Verdana"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Verdana"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Verdana"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Verdana"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Verdana"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Verdana"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Verdana"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Verdana"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Verdana"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Verdana"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Verdana"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Verdana"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Verdana"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Verdana"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Verdana"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Verdana"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Verdana"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Verdana"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Verdana"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 5
		oFont05 	:= TFont():New("Tahoma"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Tahoma"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Tahoma"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Tahoma"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Tahoma"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Tahoma"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Tahoma"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Tahoma"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Tahoma"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Tahoma"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Tahoma"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Tahoma"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Tahoma"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Tahoma"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Tahoma"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Tahoma"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Tahoma"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Tahoma"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Tahoma"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Tahoma"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Tahoma"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Tahoma"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Tahoma"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Tahoma"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Tahoma"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Tahoma"			,18,18,,.T.,,,,.T.,.F.)

	Else
		oFont05 	:= TFont():New("Courier New"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Courier New"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Courier New"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Courier New"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Courier New"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Courier New"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Courier New"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont08n	:= TFont():New("Courier New"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Courier New"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Courier New"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Courier New"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Courier New"			,11,11,,.T.,,,,.T.,.F.)
		oFont12 	:= TFont():New("Courier New"			,12,12,,.F.,,,,.T.,.F.)
		oFont12n	:= TFont():New("Courier New"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Courier New"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Courier New"			,13,13,,.T.,,,,.T.,.F.)
		oFont14		:= TFont():New("Courier New"			,14,14,,.F.,,,,.T.,.F.)
		oFont14n	:= TFont():New("Courier New"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Courier New"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Courier New"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Courier New"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Courier New"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Courier New"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Courier New"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Courier New"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Courier New"			,18,18,,.T.,,,,.T.,.F.)

EndIf

Return()

Static Function Buscar()
Local cSql 	:= " "
Local _aExc

/* Cria Query */
If Select("cAlias") <> 0
	DBSelectArea("cAlias")
	cAlias->(DBCloseArea())
Endif

cSql :=" SELECT * "+cCRLF
cSql +=" FROM ZTB010 WITH(NOLOCK)"+cCRLF
cSql +=" WHERE D_E_L_E_T_ = '' "+cCRLF
cSql +=" AND ZTB_CODIGO = '"+cCodigo+"' "+cCRLF
cSql +=" ORDER BY ZTB_CTACT1 "+cCRLF

CONOUT(cSql)

TCQuery cSql NEW ALIAS 'cAlias'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.
DBSelectArea("cAlias")
cAlias->(DBGoTop())

Return cAlias->(EOF())
