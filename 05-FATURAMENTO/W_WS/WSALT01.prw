#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'RESTFUL.CH'
#Include "TopConn.ch"


/*/{Protheus.doc} WSALT01
@author Guilherme Moreira | AfSOUZA
@since 18/05/2020
@see https://www.restapitutorial.com/httpstatuscodes.html
@version 1.0.1'
@type method 
@description Desclaracao da fachada do Web Service
/*/


WSRESTFUL WSALT01 DESCRIPTION "Servico REST que retorna informacoes dos CLIENTES para integracao com Altura | v1.0.010" 

WSDATA CODDIST			As STRING 
WSDATA EMISSDE 			As STRING 
WSDATA EMISSAT 			As STRING 
WSDATA AUTHORIZATION	As String


WSMETHOD GET DESCRIPTION "Post sem Parametro de Header | v1.0.010" WSSYNTAX "/?CODDIST&EMISSDE&EMISSAT"

END WSRESTFUL


/*-------------------------------------------------------*\
| Busca as infos enviadas na URL e no Header              |
\*-------------------------------------------------------*/
WSMETHOD GET WSSERVICE WSALT01

	Local aArea      := GetArea()
	Local aRet       := {}
	Local aReturn    := {}
	Local aURL       := {}
	Local cCoddist   := ''
	Local cCodFilial := ''
	Local cElapsed   := ''
	Local cEmat      := ''
	Local cEmde      := ''
	Local cErro      := ''
	Local cMens      := ""
	Local lRest      := .T.
	Local nHrIni     := timecounter()

	
	Private oJsonRet := JsonObject():New()

	Default ::CODDIST	:= ''
	Default ::EMISSDE	:= ''
	Default ::EMISSAT	:= ''

	::SetContentType("application/json")

	U_fLog('INICIO da execucao do WS Altura','Integracao ALTURA')

	
	/*-------------------------------------------------------*\
	| Busca as infos enviadas na URL e no Header              |
	\*-------------------------------------------------------*/
	aURL		:= ::aURLParms
	cCoddist	:= ::CODDIST
	cEmde		:= ::EMISSDE
	cEmat		:= ::EMISSAT
	
	/*-------------------------------------------------------*\
	|              Prepara ambiente                           |
	\*-------------------------------------------------------*/
	//RPCSetType(3)  

	If cCoddist == "50001607"    

		If cFilAnt <> "020201"
			
			cMens := "CODDIST não válido para esse tenantid. Para este código de Distribuidor informe no Header do tenantid o conteúdo: 020201"
			
			aReturn := {400, .F., cMens}

		Else
			cCodFilial := " '020201' "
			U_fLog('LOGANDO NA EMPRESA GIBRALTAR-CURITIBA ' + cFilAnt ,'Integracao ALTURA')
		End

	ElseIf cCoddist == "42025761"

		If cFilAnt <> "020204"
			
			cMens := "CODDIST não válido para esse tenantid. Para este código de Distribuidor informe no Header do tenantid o conteúdo: 020204"
			
			aReturn := {400, .F., cMens}

		Else
			cCodFilial := " '020204' "
			U_fLog('LOGANDO NA EMPRESA GIBRALTAR-MARILIA ' + cFilAnt ,'Integracao ALTURA')
		End

	ElseIf cCoddist == "10224492"

		If cFilAnt <> "020207"
			
			cMens := "CODDIST não válido para esse tenantid. Para este código de Distribuidor informe no Header do tenantid o conteúdo: 020207"
			
			aReturn := {400, .F., cMens}

		Else
			cCodFilial := " '020207' "
			U_fLog('LOGANDO NA EMPRESA GIBRALTAR-CAMPO GRANDE ' + cFilAnt,'Integracao ALTURA')
		End	

	ElseIf cCoddist == "40076697"

		If cFilAnt <> "030301"
			
			cMens := "CODDIST não válido para esse tenantid. Para este código de Distribuidor informe no Header do tenantid o conteúdo: 030301"
			
			aReturn := {400, .F., cMens}

		Else
			cCodFilial := " '030301' "
			U_fLog('LOGANDO NA EMPRESA GIBRALTAR-ARVOREDO ' + cFilAnt ,'Integracao ALTURA')
		End

	EndIf 

	If Len(aReturn) > 0

		SetRestFault(aReturn[1],aReturn[3])
		Return .F. 

	End

	/*--------------------------------------------------*\
	| Busca o código do usuário com base no login dele   |
	\*--------------------------------------------------*/
	/*PswOrder(2)
	If PswSeek( cUser, .T. )
		cUserID := PswID() // Retorna o ID do usuário
	EndIf*/

	/*-------------------------------------------------------*\
	| Valida se as infos recebidas estao de acordo            |
	\*-------------------------------------------------------*/
	Do Case
		Case Empty(cCoddist)
		SetRestFault(400,"Uma variavel do Filtro nao foi informada: CODIGO DISTRIBUIDOR")
		lRest := .F.

		Case Empty(cEmde)
		SetRestFault(400,"Uma variavel do Filtro nao foi informada: EMISSAO DE")
		lRest := .F.

		Case Empty(cEmat)
		SetRestFault(400,"Uma variavel do Filtro nao foi informada: EMISSAO ATE ")
		lRest := .F.

		Case (val(cEmat) - val(cEmde)) > 200 // essa condição foi ajustada desta maneira pois as funções De data nao estao funcionando.
		SetRestFault(400,"Uma variavel do Filtro nao foi informada:  O RANGE DE DATA NAO PODE SER MAIOR QUE 2 MESES")
		lRest := .F.
	End Case

	/*-------------------------------------------------------*\
	| Monta o Json de retorno com base nas infos recebidas    |
	\*-------------------------------------------------------*/
	If lRest
		aRet := U_WSALT01(cEmde, cEmat, cCodFilial,cErro)

		If ! aRet[1]
			SetRestFault(aRet[2], aRet[3])
			lRest := aRet[1]
			U_fLog('Erro na execucao do WS: ' + aRet[3], 'Integracao ALTURA')
		Else
			//conout(oJsonRet:tojson())
			::SetResponse(oJsonRet:tojson())
		EndIf
	EndIf


	RestArea(aArea)

	cDiff	:= cvaltochar(timecounter()- nHrIni)
	cElapsed := substr(cDiff,1,at('.',cDiff)+3) + 'ms'


	U_fLog('FIM da execucao do WS Listas.','Integracao ALTURA')
	U_fLog('Tempo decorrido: ' + cElapsed,'Integracao ALTURA')

	//RpcClearEnv()

Return lRest


	/*/{Protheus.doc} GetValor
	@author Guilherme Moreira | AFSOUZA
	@since 18/05/2020
	@param cEmpe, characters, Empresa base para a busca de informações
	@param cFiliall, characters, Filial base para a busca de informações 
	@param cEmide, characters, Emissao inicial para a pesquisa 
	@param cEmiat, characters, Emissao Final para a pesquisa 
	@param cJsonRet, characters, Json com o retorno da query
	@return uRet, undefined, Retorna o valor para a chave informada 
	@type function
	@version 1.0.1
	/*/


User function WSALT01(cEmide, cEmiat, cCodFil,cError)


	Local cClient   := GETMV("MV_CLIALTU")
	Local cCliAtu	:= " "
	Local cNota		:= " "
	Local cMsg 		:= " "
	Local nLenCli	:= 0
	Local nLenVen	:= 0
	Local nLenIts	:= 0
	
	Local lRet := .T.
	
	
	U_fLog('Codigo em validacao'+ cCodFil,'WSALT01')
	U_fLog('CONTEUDO CFILL' + " " + xfilial() ,'WSALT01')

	cQuery := "   SELECT                                                                 "
	cQuery += "      ROW_NUMBER() OVER(ORDER BY SD2.D2_DOC) [NLINHA],	                 "
	cQuery += "      SF2.F2_FILIAL [FILIAL],										     "
	cQuery += "      SD2.D2_DOC [NFISCAL],                                               "
	cQuery += "      SD2.D2_EMISSAO [EMISSAO],                                           "
	cQuery += "      SA1.A1_VEND [COD_VEND],                                             "
	cQuery += "      A3VEN.A3_NREDUZ [VENDEDOR],                                         "
	cQuery += "      A3VEN.A3_CODUSR [USRVEND],                                          "
	cQuery += "      SA1.A1_COD_MUN  [CODMUN],                                           "
	cQuery += "      SA1.A1_MUN      [MUN],                                              "
	cQuery += "      SA1.A1_COD      [CODCLI],                                           "
	cQuery += "      SA1.A1_NOME     [NOMCLI],                                           "
	cQuery += "      SA1.A1_CGC      [CNPJ],                                             "
	cQuery += "      SA1.A1_END      [ENDR],                                             "
	cQuery += "      SA1.A1_CEP      [CEP],                                              "	
	cQuery += "      SA1.A1_EST      [UF],                                               "
	cQuery += "      SA1.A1_BAIRRO   [BAIRRO],                                           "
	cQuery += "      SA1.A1_TEL      [TELEFONE],                                         "	
	cQuery += "      SA1.A1_CONTATO  [CONTATO],                                          "
	cQuery += "      SD2.D2_COD      [COD_PRODUTO],                                      "
	cQuery += "      SB1.B1_DESC      [PRODUTO],                                         "
	cQuery += "      SB1.B1_CODBAR   [CODBARRAS],                                        "
	cQuery += "      'NOMBRE PROVEEDOR' [PROVEEDOR],                                     "
	cQuery += "      SA1.A1_SATIV1   [TPNEGOCIO],                                        "
	cQuery += "      ATIVIDADE.X5_CHAVE   [CODNEGOCIO],                                 "
	//cQuery += "      CASE WHEN SD2.D2_TIPO ='D' THEN 1 ELSE 0 END [TIPOV],             "
	cQuery += "      SD2.D2_TIPO [TIPOV],            									 "
	cQuery += "      SD2.D2_QUANT [QUANTI],                                              "
	cQuery += "      SD2.D2_CUSTO1 [CUSTO],                                              "
	cQuery += "      SD2.D2_PRCVEN [UNITARIO],                                           "
	cQuery += "      SD2.D2_TOTAL [VENDA]                                                "
	cQuery += "               FROM                                                       "
	cQuery += "     "+RetSQLName('SD2')+" SD2                                            "
	cQuery += "               INNER JOIN                                                 "
	cQuery += "                  "+RetSQLName('SF2')+" SF2                               "
	cQuery += "                  ON SF2.F2_FILIAL = SD2.D2_FILIAL                        "
	cQuery += "                  AND SF2.F2_DOC = SD2.D2_DOC                             "
	cQuery += "                  AND SF2.F2_SERIE = SD2.D2_SERIE                         "
	cQuery += "                  AND SF2.F2_CLIENTE = SD2.D2_CLIENTE                     "
	cQuery += "                  AND SF2.F2_LOJA = SD2.D2_LOJA                           "
	cQuery += "                  AND SF2.F2_DUPL != ' '                                  "
	cQuery += "                  AND SF2.F2_TIPO IN                                      "
	cQuery += "                  (                                                       "
	cQuery += "                     'N',                                                 "
	cQuery += "                     'D'                                                  "
	cQuery += "                  )                                                       "
	cQuery += "                  AND SF2.D_E_L_E_T_ != '*'                               "
	cQuery += "               INNER JOIN                                                 "
	cQuery += "                   "+RetSQLName('SA1')+" SA1                              "
	cQuery += "                  ON SA1.A1_COD = SD2.D2_CLIENTE                          "
	cQuery += "                  AND SA1.A1_LOJA = SD2.D2_LOJA                           "
	cQuery += "                   AND SA1.A1_COD NOT IN ("+ cClient + " )                "
	cQuery += "                 AND SA1.D_E_L_E_T_ != '*'                                "
	cQuery += "              INNER JOIN                                                  "
	cQuery += "                   "+RetSQLName('SB1')+" SB1                              "
	cQuery += "                  ON SB1.B1_COD = SD2.D2_COD                              "
	cQuery += "                  AND B1_SELLOUT = 'S' 							         "
	cQuery += "                  AND SB1.D_E_L_E_T_ != '*'                               "
	cQuery += "               INNER JOIN                                                 "
	cQuery += "                   "+RetSQLName('SBM')+" SBM                              "
	cQuery += "                 ON SB1.B1_GRUPO = SBM.BM_GRUPO                           "
	cQuery += "                 AND SB1.B1_GRUPO BETWEEN  '0401' AND '0499'              "
	cQuery += "                 AND SBM.D_E_L_E_T_ != '*'                                "
	cQuery += "               LEFT JOIN                                                  "
	cQuery += "                  "+RetSQLName('SA3')+" A3VEN                             "
	cQuery += "                 ON A3VEN.A3_COD = SA1.A1_VEND                            "
	cQuery += "                 AND A3VEN.D_E_L_E_T_ != '*'                              "
	cQuery += "               LEFT JOIN                                                  "
	cQUery += "                 "+RetSQLName('SX5')+" REGIAO                             "    
	cQuery += "                  ON REGIAO.X5_TABELA = 'A2'                              "
	cQuery += "                  AND REGIAO.X5_CHAVE = A1_REGIAO                         "
	cQuery += "                  AND REGIAO.D_E_L_E_T_ != '*'                            "
	cQuery += "               LEFT JOIN                                                  "
	cQuery += "                  "+RetSQLName('SX5')+" ATIVIDADE                         "
	cQuery += "                  ON ATIVIDADE.X5_TABELA = 'T3'                           "
	cQuery += "                 AND ATIVIDADE.X5_CHAVE = A1_SATIV1                       "
	cQuery += "                 AND ATIVIDADE.D_E_L_E_T_ != '*'                          "
	cQuery += "           WHERE                                                          "
	cQuery += "              SD2.D_E_L_E_T_ != '*'                                       "
	cQuery += "              AND SD2.D2_FILIAL IN ("+ cCodFil + " )                      "
	cQuery += "              AND SD2.D2_EMISSAO BETWEEN '"+ cEmide +  "'   AND '"+ cEmiat    +"' "
	cQuery += "            ORDER BY                                                      "
	cQuery += "              A1_COD,                                                     "
	cQuery += "              D2_EMISSAO,                                                 "
	cQuery += "              D2_DOC,                                                     "
	cQuery += "              D2_ITEM ASC                                                 "

	if Select('QRYSD2')<> 0
		DBCloseArea('QRYSD2') 
	EndIF
	TcQuery cQuery New Alias 'QRYSD2'

	oJsonRet["CLIENTES"] := {}

	/*-----------------------------------------------------*\
	| Verifica se o retorno da query não foi vazio          |
	\*-----------------------------------------------------*/

    U_fLog('Montagem de Json','WSALT01')
	If !QRYSD2->(eof())	
		While !QRYSD2->(eof())	

			If cCliAtu <> QRYSD2->CODCLI
				
				nLenVen := 0
				nLenIts	:= 0
							
				AADD(oJsonRet["CLIENTES"],JsonObject():New())
				nLenCli := len(oJsonRet["CLIENTES"])
				oJsonRet["CLIENTES"][nLenCli]["Filial"] 			:= alltrim(QRYSD2->FILIAL)
				oJsonRet["CLIENTES"][nLenCli]["CodigoDoCliente"]	:= alltrim(QRYSD2->CODCLI) 
				oJsonRet["CLIENTES"][nLenCli]["RAZAO_SOCIAL"]       := alltrim(QRYSD2->NOMCLI) 
				oJsonRet["CLIENTES"][nLenCli]["CNPJ/CPF"]        	:= alltrim(QRYSD2->CNPJ) 
				oJsonRet["CLIENTES"][nLenCli]["ENDERECO"]           := alltrim(QRYSD2->ENDR)
				oJsonRet["CLIENTES"][nLenCli]["CEP"]                := alltrim(QRYSD2->CEP) 
				oJsonRet["CLIENTES"][nLenCli]["UF"]                 := alltrim(QRYSD2->UF) 
				oJsonRet["CLIENTES"][nLenCli]["BAIRRO"]             := alltrim(QRYSD2->BAIRRO) 
				oJsonRet["CLIENTES"][nLenCli]["CIDADE"]             := alltrim(QRYSD2->MUN) 
				oJsonRet["CLIENTES"][nLenCli]["TELEFONE"]           := alltrim(QRYSD2->TELEFONE) 
				oJsonRet["CLIENTES"][nLenCli]["CONTATO"]            := alltrim(QRYSD2->CONTATO) 
				oJsonRet["CLIENTES"][nLenCli]["SUB_SEGMENTO"]		:= alltrim(QRYSD2->CODNEGOCIO)
				oJsonRet["CLIENTES"][nLenCli]["CODIGO_VENDEDOR"]    := alltrim(QRYSD2->COD_VEND) 
				oJsonRet["CLIENTES"][nLenCli]["NOME_VENDEDOR"]      := alltrim(QRYSD2->VENDEDOR)
				oJsonRet["CLIENTES"][nLenCli]["VENDAS"]      		:= {}
				
			EndIf
			
			If cNota <> QRYSD2->NFISCAL
				nLenIts	:= 0
				AADD(oJsonRet["CLIENTES"][nLenCli]["VENDAS"],JsonObject():New())
				nLenVen := len(oJsonRet["CLIENTES"][nLenCli]["VENDAS"])
				oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["NUMERO_NOTA"]		:= alltrim(QRYSD2->NFISCAL)
				oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["TIPO_DOCUMENTO"]	:= alltrim(QRYSD2->TIPOV)
				oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["DATA_DE_VENDA"]	:= alltrim(QRYSD2->EMISSAO)
				oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"]			:= {}
			
			EndIf
			
			AADD(oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"], JsonObject():New())
			nLenIts :=  len(oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"])
			oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"][nLenIts]["CODIGO_INTERNO"]	:= alltrim(QRYSD2->COD_PRODUTO)
			oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"][nLenIts]["CODIGO_EAN_PRODUTO"]:= alltrim(QRYSD2->CODBARRAS)
			oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"][nLenIts]["DESC_PRODUTO"]		:= alltrim(QRYSD2->PRODUTO)
			oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"][nLenIts]["QUANTIDADE"]		:= QRYSD2->QUANTI
			oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"][nLenIts]["PRECO_UNITARIO"]	:= QRYSD2->UNITARIO
			oJsonRet["CLIENTES"][nLenCli]["VENDAS"][nLenVen]["ITENS"][nLenIts]["TOTAL_ITEM"]		:= QRYSD2->VENDA
				
			cCliAtu := QRYSD2->CODCLI	
			cNota	:= QRYSD2->NFISCAL
			QRYSD2->(DbSkip())				
			
		EndDo
	Else
		cMsg := "Nao foram encontrados registros para os parametros enviados"
		lRet := .F.
		cError := "400"
		U_fLog('Nao foram encontrados registros para os parametros enviados', 'Integracao ALTURA')
	EndIf


Return {lRet,cError,cMsg}


/*/{Protheus.doc} fLog
@author Guilherme Moreira  | AFSOUZA
@since 18/05/2020
@description Funcao responsavel por gerar um Log padronizado
@param cTxt, characters, Mensagem a ser exibida no LOG
@param cTit, characters, Titulo da dialog de Erro. Geralmente o nome da funcao em execucao
/*/
User Function fLog(cTxt, cTit)

	Local cDtHora
	Default cTit := 'EXECUCAO'
	cDtHora := DTOC(DATE()) + ' ' + Time() + ' - '

	Conout(cDtHora + '[' + cTit + '] ' + cTxt)

Return NIL
