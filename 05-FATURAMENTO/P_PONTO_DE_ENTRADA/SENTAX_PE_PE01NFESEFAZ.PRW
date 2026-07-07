#Include 'Protheus.ch'
#Include 'TOPCONN.CH'

#define LFRC chr(13)+chr(10)
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PE01NFESEFAZ
Ponto de entrada na geração do xml da Nfe
adicionado msg de informação sobre nota de exportação no campo de observação(cObsNfe)
@author Jair Matos
@since 22/01/2015
@version P11
@return __nIl
/*/
//---------------------------------------------------------------------------------------------------
User Function PE01NFESEFAZ

	Local cObsNfe	:= ""
	Local aArea 	:= GetArea()
	Local cCRLF		:= CRLF

	//Dados do produto
	Local _PRODUTO 	:= 1
	Local _ANOTA 	:= 5
	Local _AINFOIT 	:= 6

	//DADOS DO _ANOTA
	Local _NFTIPO   := 4

	Local aProd     := PARAMIXB[1]
	Local __nI 		:= 1
	Local _cLote	:= ""
	Local _nCount 	:= 1
	Local _cQry		:= ""
	Local cFilAtu	:= xFilial("SD2")

	Local cAlias	:= GetNextAlias()
	Local cSC9		:= RetSqlName("SC9")
	Local cZC6		:= RetSqlName("ZC6")
	Local cAliasZC7 := ""
	Local cSerie 	:= ""

	Private aNfe 	:= PARAMIXB

	If SF2->F2_EST == 'EX'
			//1 - Verifica  SM4- FORMULAS -indice 1- M4_FILIAL+M4_CODIGO
			DbSelectArea("SM4")
			DbSetOrder(1)
			
			If DbSeek(xFilial("SM4") + '014')
				cObsNfe	:= " "+Alltrim(SM4->M4_FORMULA)+LFRC
			EndIf
			
			//2 - Verifica  CDL- complemento de exportação -indice 1- CDL_FILIAL+CDL_DOC+CDL_SERIE+CDL_CLIENT+CDL_LOJA
			DbSelectArea("CDL")
			DbSetOrder(1)
			If DbSeek(xFilial("CDL")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
				cObsNfe	+= 	"UF/LOCAL DE EMBARQUE: "+Alltrim(CDL->CDL_UFEMB)+"/"+Alltrim(CDL->CDL_LOCEMB)+LFRC
			EndIf
			
			//IMPRIMIR NAS INFORMAÇÕES COMPLEMENTARES
			cObsNfe := LFRC + Alltrim(cObsNfe) + ". Qualquer divergência, ressalvar e/ou recusar no verso da nota, também no CTE da Transportadora."
		
		Else
			cObsNfe := ". Qualquer divergência, ressalvar e/ou recusar no verso da nota, também no CTE da Transportadora." 

	EndIf

	If aNFE[_ANOTA][_NFTIPO] == "1" //Notas de saída

		If ExistBlock("NFEMENC")
			_cMensCli := ExecBlock("NFEMENC",.F.,.F.,{'1'})
			If ( ValType(_cMensCli) != "C" )
				_cMensCli := ""
			Else
				cObsNfe := _cMensCli + cObsNfe
			Endif
		Endif
		
		For __nI := 1 TO Len(aNFE[_PRODUTO])
				
			SB1->(DBSetOrder(1))
			SB1->(DbSeek(xFilial("SB1") + Alltrim(aNFE[_PRODUTO][__nI][2]) ))
			
			_cLote	:= ""
			_nCount := 1

			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbGoTop())
			If SC6->(DbSeek(cFilAtu + aNFE[_AINFOIT][__nI][1] + aNFE[_AINFOIT][__nI][2] ))
				
				_cQry := " SELECT ZC6_LOTE,ZC6_QUANT,* "
				_cQry += " FROM "+cZC6+" "
				_cQry += " WHERE D_E_L_E_T_ = '' "
				_cQry += " AND ZC6_FILIAL = '"+ cFilAtu +"'"
				_cQry += " AND ZC6_NUM    = '"+ aNFE[_AINFOIT][__nI][1] +"'"
				_cQry += " AND ZC6_ITEM = '"+  aNFE[_AINFOIT][__nI][2] +"'"
				_cQry += " AND ZC6_LOTE <> '' "

				TcQuery _cQry New Alias (cAlias)

				If !(cAlias)->(EOF())
					_cLote	:= ""

					While !(cAlias)->(EOF())
						
						_cLote += "Lote: " + Alltrim((cAlias)->ZC6_LOTE) + " - Val: " + DTOC(STOD((cAlias)->ZC6_DTVALI)) + " - Qtd: "+ Alltrim(Str((cAlias)->ZC6_QUANT,14,2)) +", "

						(cAlias)->(DbSkip())
					EndDo
				EndIf 

				(cAlias)->(DbCloseArea())
			EndIf

			If !Empty(_cLote)
				
				_cLote := SubStr(_cLote, 1, Len(_cLote) - 2)

				aNFE[_PRODUTO][__nI][25] := _cLote //InformaçÕes adicionais do produto
			EndIf 

			//CONSULTA SÉRIE
			cAliasZC7 := GetNextAlias()
			cSerie    := ""

			If Select(cAliasZC7) > 0
				dbSelectArea(cAliasZC7)
				dbCloseArea()
			Endif

			BeginSql Alias cAliasZC7
				SELECT 
					ZC7_SERIES
				FROM 
					%Table:ZC7% ZC7 (NOLOCK)
				WHERE ZC7.%notdel% 
					AND ZC7_FILIAL = %xFilial:ZC7%
					AND ZC7_NUM = %Exp:aNFE[_AINFOIT][__nI][1]%
					AND ZC7_ITEM = %Exp:aNFE[_AINFOIT][__nI][2]%
			EndSql

			If (cAliasZC7)->(!Eof())
				
				While (cAliasZC7)->(!Eof())

					cSerie := Alltrim((cAliasZC7)->ZC7_SERIES)
					
					(cAliasZC7)->(dbSkip())		
				Enddo

				If !Empty(cSerie)
					aNFE[_PRODUTO][__nI][25] := Alltrim(aNFE[_PRODUTO][__nI][25]) + "Série(s): " + cSerie + ", "
				End
			
			End

		Next

	EndIf 

	aNfe[2] := Alltrim(aNfe[2]) + " " + Alltrim(cObsNfe)

	RestArea(aArea)

Return aNfe
