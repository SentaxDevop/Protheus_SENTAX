#include "APWEBEX.CH"
#include "topconn.CH"


User Function ATMK008()

Private ckEY  := Embaralha(HttpGet->ckey,1) //Filial
if substr(ckEY,1,5)=='23912'
	OpenSM0()	
	RPCSETENV('01', '020201')
	cRec:=substr(ckEY,6)
	cHTML:=montaHtml(cRec,ckEY)
Else
	
	cHTML:="endereco invalido!"

EndIF	
return (cHTML) 




Static Function montaHtml(cRec,cKey)

cSql:=" select "//U7_NOME,
cSql+=" Z20_EMISSA,Z20_ANEXA,Z20_ATENDI,Z20_NOME,Z20_OBS,Z20.R_E_C_N_O_,* "
cSql+=" from Z20010 Z20 "
//cSql+=" INNER JOIN SU7010 SU7 "
//cSql+=" ON U7_COD = Z20_RESP  "
cSql+=" where "
cSql+=" Z20.D_E_L_E_T_<>'*' "
//cSql+=" AND SU7.D_E_L_E_T_<>'*' "
cSql+=" and Z20.R_E_C_N_O_= "+cRec+" "

IF Select('TRBZ')<>0
	TRBZ->(DBCloseArea())
EndIF

TCquery cSql New Alias 'TRBZ'

if TRBZ->(eof())
	return "Nenhum atendimento relacionados"
EndIF
cHtml:="" 
Web Extended Init cHtml
	
 cHtml:=' <!DOCTYPE html>'
 cHtml+=' <html lang="pt-br">'
 cHtml+=' <head>'
	cHtml+=' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> '
 //cHtml+='     <meta charset="utf-8">'
 cHtml+='     <meta http-equiv="X-UA-Compatible" content="IE=edge">'
 cHtml+='     <meta name="viewport" content="width=device-width, initial-scale=1">'
 cHtml+='     <title> Atendimento CallCenter </title> '
 cHtml+='     <link href="imagens-gen/bootstrap.min.css" rel="stylesheet" type="text/css">'
 cHtml+='     <link href="imagens-gen/style6.css" rel="stylesheet">'
 cHtml+='     <!--[if lt IE 9]>'
 cHtml+='     <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>'
 cHtml+='     <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>'
 cHtml+='     <![endif]-->'
 cHtml+=' </head>'
 cHtml+=' <body>'
 cHtml+=' '
 cHtml+='     <form name="form1" method="post" action="U_atmk008p.APW?key='+Embaralha(ckey,0)+'">'
 cHtml+='           <section class="docs-body">'
 cHtml+='               <div class="row">'
 cHtml+='                    <div class="col-xs-12"> RECADO TELEVENDAS</div>'
 cHtml+='               </div>'
 cHtml+='          </section>'
 cHtml+='          <div class="row">'
 cHtml+='               <div class="col-xs-2"> Tele:</div>'
 cHtml+='               <div class="col-xs-2"> Data:  </div>'
 cHtml+='               <div class="col-xs-1"> Atendimento</div>'
 cHtml+='               <div class="col-xs-7"> Cliente:</div>'
 cHtml+='          </div>'
 cHtml+='          <div class="row">'
 cHtml+='              <div class="col-xs-2">'
 cHtml+='                <input class="form-control" type="text" name="Tele" maxlength="11" placeholder="Tele" value="'+TRBZ->Z20_NRESP+'" disabled="disabled"> '
 cHtml+='               </div>'
 cHtml+='               <div class="col-xs-2">'
 cHtml+='                <input class="form-control" type="text" name="Data" maxlength="11" placeholder="Data" value="'+DTOC(STOD(TRBZ->Z20_EMISSA))+'" disabled="disabled"> '
 cHtml+='               </div>'
 cHtml+='               <div class="col-xs-1">'
 cHtml+='                <input class="form-control" type="text" name="Atendimento" maxlength="11" placeholder="999999" value="'+TRBZ->Z20_ATENDI+'" disabled="disabled"> '
 cHtml+='               </div>'
 cHtml+=' '
 cHtml+='               <div class="col-xs-6">'
 cHtml+='                <input class="form-control" type="text" name="Cliente" maxlength="11" placeholder="Nome do cliente" value="'+TRBZ->Z20_NOME+'" disabled="disabled"> '
 cHtml+='               </div>'
 cHtml+=' '
 cHtml+='          </div>'
 cHtml+=' '
 cHtml+='          <div class="row">'
 cHtml+='               <div class="col-xs-2"> Mensagem:</div>'
 cHtml+='          </div>'
 cHtml+='          <div class="row">'
 cHtml+='               <div class="col-xs-11">'
 cHtml+='                    <textarea class="form-control" rows="3" disabled="disabled">'+TRBZ->Z20_OBS+'</textarea>'
 cHtml+='               </div>'
 cHtml+='          </div>'     
 IF TRBZ->Z20_ANEXA =='S'
	 cHtml+='          <div class="row">'
	 cHtml+='               <div class="col-xs-6">Historico de Compras do Cliente</div>'
	 cHtml+='          </div>'
	 cHtml+=' '
	 cHtml+='          <div class="row">'	
	 cHtml+='          '
	 cHtml+='               <div class="panel panel-default col-md-11">'
	 cHtml+='                  <table class="table">'
	 cHtml+='                    <thead>'
	 cHtml+='                         <tr>'
	 cHtml+='                           <th>Filial</th>'
	 cHtml+='                           <th>Produto</th>'
	 cHtml+='                           <th>Descrição</th>'
	 cHtml+='                           <th>Ult.Compra</th>'
	 cHtml+='                           <th>Quantidade</th>'
	 cHtml+='                           <th>Periodicidade</th>'
	 cHtml+='                           <th>$ Ult.Venda</th> '  
	 cHtml+='                           <th>Prc.Otimo</th> '
	 cHtml+='                           <th>Ult.Venda</th> '
	 cHtml+='                            <th>Quant. </th> '
	 cHtml+='                            <th>Menor Prc.</th> '
	 cHtml+='                            <th>Tabela</th>    '
	 cHtml+='                         </tr>'
	 cHtml+='                    </thead>'
	 	aProd:=fMontaQry()
               
		for nFor:=1 to len(aprod)
		 cHtml+='                    <tbody>'
		 cHtml+='                         <tr>'
		 cHtml+='                           <td>'+aprod[nFor][2]+'</td>'
		 cHtml+='                           <td>'+aprod[nFor][3]+'</td>'
		 cHtml+='                           <td>'+aprod[nFor][4]+'</td>'
		 cHtml+='                           <td>'+aprod[nFor][5]+'</td>'
		 cHtml+='                           <td>'+TRANSFORM(aprod[nFor][6],'@E 999,999,999.99')+'</td>'
		 cHtml+='                           <td>'+TRANSFORM(aprod[nFor][7],'@E 999,999,999.99')+'</td>'
		 cHtml+='                           <td>'+TRANSFORM(aprod[nFor][8],'@E 999,999,999.99')+'</td> '
		 cHtml+='                           <td>'+TRANSFORM(aprod[nFor][9],'@E 999,999,999.99')+'</td> '
		 cHtml+='                           <td>'+TRANSFORM(aprod[nFor][10],'@E 999,999,999.99')+'</td> '
		 cHtml+='                           <td>'+aprod[nFor][11]+'</td> '
		 cHtml+='                           <td>'+TRANSFORM(aprod[nFor][12],'@E 999,999,999.99')+'</td> '
 		 cHtml+='                           <td>'+aprod[nFor][13]+'</td> '		 
		 cHtml+='                         </tr>'
		 cHtml+='                  </tbody>'
	 NExt
	 cHtml+='               </table>'
	 cHtml+='               </div>          '
	 cHtml+='          </div>'
EndIF

 cHtml+='               <div class="row">'
 cHtml+='                    <div class="col-xs-2">Resposta do Vendedor:</div>'
 cHtml+='               </div>'
 cHtml+='               <div class="row">'
 cHtml+='                    <div class="col-xs-11">'
 cHtml+='                         <textarea class="form-control" rows="3" name="Resp" placeholder="Digite aqui sua resposta."></textarea>'
 cHtml+='                    </div>'
 cHtml+='               </div>'
 cHtml+='               <div class="row">'
 cHtml+='                    <div class="col-xs-4">Motivo para encerrar a pendencia:</div>'
 cHtml+='               </div>'
 cHtml+='               <div class="row">'
 cHtml+='                    <div class="col-xs-11">'
 cHtml+='                         <select class="form-control"  name="Encerrar" placeholder="Digite aqui o motivo para encerramento.">'
 cHtml+='                          <option>CONTATO REALIZADO</option>'
 cHtml+='                          <option>AGENDADA VISITA</option>'
 cHtml+='                          <option>OUTRO</option>'
 // <!-- 1=CONTATO REALIZADO;2=AGENDADA VISITA;3=OUTRO        -->
 cHtml+='                          </select>'
 //cHtml+='                         <textarea class="form-control" rows="3" name="Encerrar" placeholder="Digite aqui o motivo para encerramento."></textarea>'
 cHtml+='                    </div>'
 cHtml+='               </div>'
 cHtml+='               <div class="row">'
 cHtml+="				'' "
 cHtml+='               </dif>'
 cHtml+='               <div class="row" align = '+"'"+'center'+"'"+'>'
 cHtml+='                    <button type="submit" class="btn btn-success"  onclick="document.submit();">Responder</button>'
 cHtml+='               </div>'
 cHtml+='          </form>'
 cHtml+='     <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>'
 cHtml+='     <script src="script/bootstrap.min.js"></script>'
 cHtml+=' </body>'
 cHtml+=' </html>'
web Extended end
	
	
Return cHtml

Static Function fMontaQry()
	Local cQry 		:= ""
	Local cFiltro1	:= ""
	Local cFiltro2	:= ""
	Local cFiltro3	:= ""
	Local cFiltro4	:= ""
	Local cFiltro5	:= ""
	Local cFiltro6	:= ""
	Local cCodCont	:= ""
	Local dDtIni	:= ddatabase-365
	Local dDtFim	:= ddatabase
	
	Local nTendMenor := 0
	Local nTendMaior := 0
	Local cTendMenor := 0
	Local cTendMaior := 0   
	Local nPerComp   := 0 
	Local aColsTmp	 := {}
	Private cParCfop	:= GetMV("ST_TMKCFVE",,"")
	Private cParComo	:= GetMV("ST_TMKCFCO",,"")
	nItem:=0
	cQry := " SELECT DISTINCT D.D2_FILIAL, D.D2_COD, B1_DESC, A1_NROCOM, D.D2_EMISSAO, DMIN, E.D2_PRCVEN, TOTAL_NOTAS, TOTAL_ITENS, 'N' TIPO_C_N "+chr(13)+chr(10)
	cQry += " FROM (	SELECT D2_FILIAL, D2_COD, MAX(MAX) D2_EMISSAO, MAX(MIN) DMIN, SUM(TOT_NOTAS) TOTAL_NOTAS, Sum(TOT_ITENS) TOTAL_ITENS "+chr(13)+chr(10)
	cQry += " 		FROM (	SELECT D2_FILIAL, D2_COD, MAX(D2_EMISSAO) MAX, '' MIN, COUNT(*) TOT_NOTAS, Sum(D2_QUANT) TOT_ITENS "+chr(13)+chr(10)
	cQry += " 				FROM "+RetSQLName("SD2")+" A "+chr(13)+chr(10)
	cQry += " 				WHERE D2_CLIENTE = '"+TRBZ->Z20_CLIENT+"' "+chr(13)+chr(10)
	cQry += " 					AND D2_LOJA = '"+TRBZ->Z20_LOJA+"' "+chr(13)+chr(10)
	If !Empty(cParCfop)
		cQry += " 					AND D2_CF IN ('"+cParCfop+"') "+chr(13)+chr(10)
	EndIf
	cQry += " 					AND A.D2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"' "+chr(13)+chr(10)
	cQry += " 					AND A.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
	cQry += " 				GROUP BY D2_FILIAL, D2_COD "+chr(13)+chr(10)
	cQry += " 				UNION ALL "+chr(13)+chr(10)
	cQry += " 				SELECT D2_FILIAL, D2_COD, '' MAX, MIN(D2_EMISSAO) MIN, 0 TOT_NOTAS, 0 TOT_ITENS "+chr(13)+chr(10)
	cQry += " 				FROM "+RetSQLName("SD2")+" B "+chr(13)+chr(10)
	cQry += " 				WHERE D2_CLIENTE = '"+TRBZ->Z20_CLIENT+"' "+chr(13)+chr(10)
	cQry += " 					AND D2_LOJA = '"+TRBZ->Z20_LOJA+"' "+chr(13)+chr(10)
	If !Empty(cParCfop)
	//	cQry += " 					AND D2_CF IN ('"+cParCfop+"') "+chr(13)+chr(10)
	EndIf
	cQry += " 					AND DATEDIFF (MONTH,D2_EMISSAO,'"+DtoS(dDataBase)+"') <= "+cValToChar(dDataBase-365)+" "+chr(13)+chr(10)
	cQry += " 					AND B.D2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"' "+chr(13)+chr(10)
	cQry += " 					AND B.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
	cQry += " 				GROUP BY D2_FILIAL, D2_COD) AS C "+chr(13)+chr(10)
	cQry += " 		GROUP BY D2_FILIAL, D2_COD) AS D "+chr(13)+chr(10)
	cQry += " LEFT JOIN "+RetSQLName("SD2")+" E ON E.D2_FILIAL = D.D2_FILIAL AND E.D2_COD = D.D2_COD AND E.D2_EMISSAO = D.D2_EMISSAO "+;
	"AND E.D2_CLIENTE = '"+TRBZ->Z20_CLIENT+"' AND E.D2_LOJA = '"+TRBZ->Z20_LOJA+"' AND E.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
	cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = D.D2_COD AND SB1.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
	cQry += " LEFT JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = '"+TRBZ->Z20_CLIENT+"' AND A1_LOJA = '"+TRBZ->Z20_LOJA+"' AND SB1.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)

	cQry += " UNION ALL "+chr(13)+chr(10)

	cQry += " SELECT DISTINCT D.D2_FILIAL, D.D2_COD, B1_DESC, A1_NROCOM, D.D2_EMISSAO, DMIN, E.D2_PRCVEN, TOTAL_NOTAS, TOTAL_ITENS, 'C' TIPO_C_N "+chr(13)+chr(10)
	cQry += " FROM (	SELECT D2_FILIAL, D2_COD, MAX(MAX) D2_EMISSAO, MAX(MIN) DMIN, SUM(TOT_NOTAS) TOTAL_NOTAS, Sum(TOT_ITENS) TOTAL_ITENS "+chr(13)+chr(10)
	cQry += " 		FROM (	SELECT D2_FILIAL, D2_COD, MAX(D2_EMISSAO) MAX, '' MIN, COUNT(*) TOT_NOTAS, Sum(D2_QUANT) TOT_ITENS "+chr(13)+chr(10)
	cQry += " 				FROM "+RetSQLName("SD2")+" A "+chr(13)+chr(10)
	cQry += " 				WHERE D2_CLIENTE = '"+TRBZ->Z20_CLIENT+"' "+chr(13)+chr(10)
	cQry += " 					AND D2_LOJA = '"+TRBZ->Z20_LOJA+"' "+chr(13)+chr(10)
	If !Empty(cParComo)
	//	cQry += " 					AND D2_CF IN ('"+cParComo+"') "+chr(13)+chr(10)
	EndIf
	cQry += " 					AND A.D2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"' "+chr(13)+chr(10)
	cQry += " 					AND A.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
	cQry += " 				GROUP BY D2_FILIAL, D2_COD "+chr(13)+chr(10)
	cQry += " 				UNION ALL "+chr(13)+chr(10)
	cQry += " 				SELECT D2_FILIAL, D2_COD, '' MAX, MIN(D2_EMISSAO) MIN, 0 TOT_NOTAS, 0 TOT_ITENS "+chr(13)+chr(10)
	cQry += " 				FROM "+RetSQLName("SD2")+" B "+chr(13)+chr(10)
	cQry += " 				WHERE D2_CLIENTE = '"+TRBZ->Z20_CLIENT+"' "+chr(13)+chr(10)
	cQry += " 					AND D2_LOJA = '"+TRBZ->Z20_LOJA+"' "+chr(13)+chr(10)
	If !Empty(cParComo)
		//cQry += " 					AND D2_CF IN ('"+cParComo+"') "+chr(13)+chr(10)
	EndIf
	cQry += " 					AND DATEDIFF (MONTH,D2_EMISSAO,'"+DtoS(dDataBase)+"') <= "+cValToChar(ddatabase-365)+" "+chr(13)+chr(10)
	cQry += " 					AND B.D2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"' "+chr(13)+chr(10)
	cQry += " 					AND B.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
	cQry += " 				GROUP BY D2_FILIAL, D2_COD) AS C "+chr(13)+chr(10)
	cQry += " 		GROUP BY D2_FILIAL, D2_COD) AS D "+chr(13)+chr(10)
	cQry += " LEFT JOIN "+RetSQLName("SD2")+" E ON E.D2_FILIAL = D.D2_FILIAL AND E.D2_COD = D.D2_COD AND E.D2_EMISSAO = D.D2_EMISSAO "+;
	"AND E.D2_CLIENTE = '"+TRBZ->Z20_CLIENT+"' AND E.D2_LOJA = '"+TRBZ->Z20_LOJA+"' AND E.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
	cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = D.D2_COD AND SB1.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)
	cQry += " LEFT JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = '"+TRBZ->Z20_CLIENT+"' AND A1_LOJA = '"+TRBZ->Z20_LOJA+"' AND SB1.D_E_L_E_T_ <> '*' "+chr(13)+chr(10)

	cQry += " ORDER BY D.D2_EMISSAO DESC, D.D2_FILIAL, D.D2_COD "+chr(13)+chr(10)

	IF Select('QPER')<>0
		QPER->(DBCloseArea())
	EndIf
	TCQuery cQry New Alias "QPER"

	
		QPER->(DbGoTop())

		If QPER->(!Eof())

			While QPER->(!Eof())

				fBuscaPreco( QPER->D2_COD, QPER->D2_PRCVEN, @nTendMenor, @nTendMaior, @cTendMenor, @cTendMaior )

				If !Empty(QPER->D2_EMISSAO) .AND. !Empty(QPER->DMIN)
					nPerComp := Int( (StoD(QPER->D2_EMISSAO)-StoD(QPER->DMIN)) / (QPER->TOTAL_NOTAS - 1) )
				Else
					nPerComp := 0
				EndIf

				nItem++
				aAdd(aColsTmp,Array(15))

				aColsTmp[nItem][1]  := ""
				aColsTmp[nItem][2]  := QPER->D2_FILIAL
				aColsTmp[nItem][3]  := QPER->D2_COD
				aColsTmp[nItem][4]  := QPER->B1_DESC
				aColsTmp[nItem][5]  := dtoc(StoD(QPER->D2_EMISSAO))	// Ultima Compra)
				aColsTmp[nItem][6]  := 0				   	   	// Quantidade
				aColsTmp[nItem][7]  := nPerComp
				aColsTmp[nItem][8]  := QPER->D2_PRCVEN 			// Alltrim(Transform(QPER->PRECO,PesqPict("SD2","D2_TOTAL")))
				aColsTmp[nItem][9]  := QPER->TOTAL_ITENS   	   	// Quantidade
				aColsTmp[nItem][10]  := nTendMenor
				aColsTmp[nItem][11] := IIF(Empty(cTendMenor),"n/a",cTendMenor)
				aColsTmp[nItem][12] := nTendMaior
				aColsTmp[nItem][13] := IIF(Empty(cTendMaior),"n/a",cTendMaior)
				aColsTmp[nItem][14] := QPER->TIPO_C_N
				aColsTmp[nItem][15] := .F.

				QPER->(DbSkip())
			EndDo
		EndIf

Return aColsTmp


User Function atmk008p(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Private cEnc:=HttpPost->Encerrar
Private cResp:=HttpPost->Resp
Private cKey := Embaralha(HttpGet->key,1)
Private cHtml:=""
Web Extended Init cHtml

if substr(ckEY,1,5)=='23912'
	OpenSM0()	
	RPCSETENV('01', '020201')
	cRec:=substr(ckEY,6)
	 
	 // <!-- 1=CONTATO REALIZADO;2=AGENDADA VISITA;3=OUTRO        -->
	 IF cEnc=='CONTATO REALIZADO' 
	     cMot:='1'
	 EndIF
	 IF cEnc=='AGENDADA VISITA' 
	 	cMot:='2'
	 EndIF
	 IF cEnc=='OUTRO' 
	 	cMot:='3'
	 EndIF 
	
	dbSelectArea('Z20')
	DBGoto(val(cRec))   
	RECLOCK('Z20',.F.)
	Z20->Z20_TXFIM:=cResp
	Z20->Z20_MOTIVO:=cMot
	Msunlock()
	
	cHTML:='Resposta gravada com sucesso!'
Else
	
	cHTML:="endereco invalido!"

EndIF
web Extended end

Return cHTML