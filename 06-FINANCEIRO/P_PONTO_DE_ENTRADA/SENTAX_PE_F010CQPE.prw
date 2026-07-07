#Include 'Protheus.ch'

/*/{Protheus.doc} F010CQPE
Ponto de entrada para correção de inconsistências na query padrão da Posicao de Cliente
@type function
@author luizf
@since 25/10/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function F010CQPE()

LOCAL cQry := PARAMIXB[1]

//O campo C6_BLQ tem tamanho 2 e o SQL esta interpretando o espaço em branco nao 
//trazendo registros quando o campo é vazio.
cQry:= StrTran(cQry,"SC6.C6_BLQ NOT IN('R ')","SC6.C6_BLQ <> 'R '")
cQry:= StrTran(cQry,"SC6.C6_BLQ NOT IN('S ')","SC6.C6_BLQ <> 'S ' ")
//Tratamento pois trazia a filial errada do arquivo.
cQry:= StrTran(cQry,"SF4.F4_FILIAL='0101  '","SF4.F4_FILIAL='"+xFilial("SF4")+"'")
cQry:= StrTran(cQry,"SF4.F4_FILIAL='0202  '","SF4.F4_FILIAL='"+xFilial("SF4")+"'")
cQry:= StrTran(cQry,"SF4.F4_FILIAL='0303  '","SF4.F4_FILIAL='"+xFilial("SF4")+"'")
 
Return cQry

