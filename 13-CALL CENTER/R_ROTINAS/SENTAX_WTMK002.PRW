#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} wtmk002
gera planilha de projecao de vendas e envia por e-mail gerentes

@author		Rodrigo@afsouza.com.br
@since		11/05/2021
@version	P12

@return 	Nil, nenhum

@type function
/*/
//-------------------------------------------------------------------
User Function wtmk002()
    Local __cEmp	    := "01"
    Local __cFil	    := "020201"
    Private nHandle     := 0      
    Private cNumCond    := space(10)
    Private lFist       :=.f.

    nerros:=0

    RPCSetType(3)  
    If !RpcSetEnv(__cEmp,__cFil,,,,GetEnvServer(),{ }) 
            Conout("")
            Conout("Empresa nao localizada")
        Else 
            lRpcSetEnv := .F.
    EndIf

    DbSelectArea("SX6")
    DbSetOrder(1)

    Conout('**********************WF de Projecao de Vendas-WTMK002****************************')
    Conout('**********************WF de Projecao de Vendas-WTMK002****************************')
    Conout('**********************WF de Projecao de Vendas-WTMK002****************************')

    if FirstDate(ddatabase)  == ddatabase .AND. GETMV(SX_PROCWF)<>ddatabase
        PUTMV('SX_PROCWF', DDATABASE)
        DDATABASE:=DDATABASE-1
        PUTMV('SX_PROCWF', DDATABASE)
        cUpd:= "update SA3010 SET A3_XDTWF='"+DtOS(DDATABASE-1)+"' and A3_COD IN (SELECT A3_GEREN FROM SA3010 WHERE D_E_L_E_T_<>'*')"
    EndIF
    
    cSql:=" SELECT *, R_E_C_N_O_ REC FROM SA3010 "
    cSql+="	 WHERE A3_COD IN (SELECT A3_GEREN FROM SA3010 WHERE D_E_L_E_T_<>'*') "
    // cSql+="	 WHERE A3_COD IN ('900000') "
    cSql+="	 AND A3_MSBLQL<>'1' "
    cSql+="	 AND A3_XVENWF='S' "
    cSql+="	 AND D_E_L_E_T_<>'*' "
    

    // cSql+=" order by VEND.A3_COD"
    if SELECT('TRBA')<>0
        TRBA->(DBCLOSEAREA())
    ENDIF

    tcQuery cSql new alias 'TRBA'
    ncont:=0
    WHILE !TRBA->(EOF())   
        ncont++
        conout("PRocessando "+CVALTOCHAR(ncont))
        cMail:=alltrim(TRBA->A3_EMAIL)

        if (!empty(cMail))
            cMail+=';'
        Endif

        cMail+= GetMV("ST_MAILTI")
        //cMail:=""
        
        GERAXLS(TRBA->A3_COD)
        conout(TRBA->A3_COD +' '+TRBA->A3_NOME)

        cMensagem:="Prezado(a) "+TRBA->A3_NOME+'<br>'
        cMensagem+="Segue relação de vendas de sua equipe<br>"+chr(13)+chr(10)

        cSql:=" SELECT MESANO,REGIAO, VEND, NVEND, META, "
        cSql+=" 	SUM(PRCVEN) AS VENDIDO,"
        cSql+=" 	SUM(DPRCVEN) AS DEVOLUCAO,"
        cSql+=" 	SUM(PRCVEN-DPRCVEN) AS VALOR_ATINGIDO,"
        cSql+=" 	SUM(PRCVEN-DPRCVEN)/META*100 AS PERC_ATINGIDO,"
        cSql+=" 	META - SUM(PRCVEN-DPRCVEN) FALTA_ATINGIR,"
        cSql+=" 	(META - SUM(PRCVEN-DPRCVEN))/META*100 AS PERC_FALTA_ATINGIR,"
        cSql+=" 	SUM(PRCVEN-DPRCVEN)/TOTAL_PASSADO*TOTAL_DIAS PROJECAO,"
        cSql+=" 	(SUM(PRCVEN-DPRCVEN)/TOTAL_PASSADO*TOTAL_DIAS)/META*100 AS META_PROJETADA,"
        cSql+=" 	TOTAL_DIAS,"
        cSql+=" 	TOTAL_PASSADO,"
        cSql+=" 	TOTAL_DIAS-	TOTAL_PASSADO DIAS_RESTNTES,"
        //cSql+=" 	(META - SUM(PRCVEN-DPRCVEN))/(TOTAL_DIAS-	TOTAL_PASSADO) FALTA_POR_DIA,"
        cSql+=" 	NULLIF((META - SUM(PRCVEN-DPRCVEN)),(TOTAL_DIAS-TOTAL_PASSADO)) as FALTA_POR_DIA, "
        cSql+=" 	SUM(MAQUINAS) AS MAQUINAS,"
        cSql+=" 	SUM(ECOLAB) AS ECOLAB,"
        cSql+=" 	SUM(RUBBERMAID) AS RUBBERMAID,"
        cSql+=" 	SUM(LAVAZZA) AS LAVAZZA"
        cSql+=" 
        cSql+=" FROM [Vw_Metas_Vend2]"
        cSql+=" WHERE MESANO='"+substr(DtOS(DDATABASE),1,4)+"/"+substr(DtOS(DDATABASE),5,2)+"'"
        cSql+=" AND VEND IN (SELECT A3_COD FROM SA3010 "
        cSql+="  						 WHERE A3_GEREN='"+TRBA->A3_COD+"' "
        cSql+="  						 AND D_E_L_E_T_<>'*' "
        cSql+="  						 AND A3_MSBLQL<>'1') "
        cSql+=" GROUP BY MESANO,REGIAO, VEND, NVEND, META,TOTAL_DIAS,TOTAL_PASSADO "

        if(SELECT('TRBGER')<>0)
            TRBGER->(DBCloseArea())
        ENDIF
        tcQuery cSql new alias 'TRBGER'
        lTemTel:=.f.
        if !TRBGER->(Eof())
            lTemTel:=.t.
        ENDIF

        cSql:=" SELECT MESANO,REGIAO, VEND, NVEND, META, "
        cSql+=" 	SUM(PRCVEN) AS VENDIDO,"
        cSql+=" 	SUM(DPRCVEN) AS DEVOLUCAO,"
        cSql+=" 	SUM(PRCVEN-DPRCVEN) AS VALOR_ATINGIDO,"
        cSql+=" 	SUM(PRCVEN-DPRCVEN)/META*100 AS PERC_ATINGIDO,"
        cSql+=" 	META - SUM(PRCVEN-DPRCVEN) FALTA_ATINGIR,"
        cSql+=" 	(META - SUM(PRCVEN-DPRCVEN))/META*100 AS PERC_FALTA_ATINGIR,"
        cSql+=" 	SUM(PRCVEN-DPRCVEN)/TOTAL_PASSADO*TOTAL_DIAS PROJECAO,"
        cSql+=" 	(SUM(PRCVEN-DPRCVEN)/TOTAL_PASSADO*TOTAL_DIAS)/META*100 AS META_PROJETADA,"
        cSql+=" 	TOTAL_DIAS,"
        cSql+=" 	TOTAL_PASSADO,"
        cSql+=" 	TOTAL_DIAS-	TOTAL_PASSADO DIAS_RESTNTES,"
    // cSql+=" 	(META - SUM(PRCVEN-DPRCVEN))/(TOTAL_DIAS-	TOTAL_PASSADO) FALTA_POR_DIA,"
        cSql+=" 	NULLIF((META - SUM(PRCVEN-DPRCVEN)),(TOTAL_DIAS-TOTAL_PASSADO)) as FALTA_POR_DIA, "    
        cSql+=" 	SUM(MAQUINAS) AS MAQUINAS,"
        cSql+=" 	SUM(ECOLAB) AS ECOLAB,"
        cSql+=" 	SUM(RUBBERMAID) AS RUBBERMAID,"
        cSql+=" 	SUM(LAVAZZA) AS LAVAZZA"
        cSql+=" 
        cSql+=" FROM [Vw_Metas1]"
        cSql+=" WHERE MESANO='"+substr(DtOS(DDATABASE),1,4)+"/"+substr(DtOS(DDATABASE),5,2)+"'"
        cSql+=" AND VEND IN (SELECT A3_COD FROM SA3010 "
        cSql+="  						 WHERE A3_GEREN='"+TRBA->A3_COD+"' "
        cSql+="  						 AND D_E_L_E_T_<>'*' "
        cSql+="  						 AND A3_MSBLQL<>'1') "
        cSql+=" GROUP BY MESANO,REGIAO, VEND, NVEND, META,TOTAL_DIAS,TOTAL_PASSADO "

        if(SELECT('TRBGERv')<>0)
            TRBGERv->(DBCloseArea())
        ENDIF
        tcQuery cSql new alias 'TRBGERv'
        lTemVend:=.f.
        if !TRBGERv->(Eof())
            lTemVend:=.t.
        EndIf
        cMensagem+=' <!DOCTYPE html>'
        cMensagem+=' <html>'
        cMensagem+=' <style>'
        cMensagem+=' table, th, td {'
        cMensagem+='   border:1px solid black;'
        cMensagem+=' }'
        cMensagem+=' </style>'
        cMensagem+=' <body>'
        cMensagem+=' '
        if lTemTel
            cMensagem+=' <h2>Projeção de vendas - TELEVENDAS</h2>'
            cMensagem+=' '
            cMensagem+=' <table style="width:100%;border-collapse: collapse;text-align: center;">'
            cMensagem+='   <thead>  '
            cMensagem+='     <tr>'
            cMensagem+='       <th>Ano /  Mês</th>'
            cMensagem+='       <th>Regiao</th>'
            cMensagem+='       <th>Código Vendedor</th>'
            cMensagem+='       <th>Nome Vendedor</th>'
            cMensagem+='       <th>Meta</th>'
            cMensagem+='       <th>Total Vendido</th>'
            cMensagem+='       <th>Devolução</th>'
            cMensagem+='       <th>Valor Atingido</th>'
            cMensagem+='       <th>% Atingido</th>'
            cMensagem+='       <th>Falta Atingir</th>'
            cMensagem+='       <th>% Falta Atingir</th>'
            // cMensagem+='       <th>% Hoje</th>'
            cMensagem+='       <th>Total Dias</th>'
            cMensagem+='       <th>Dias Passados</th>'
            cMensagem+='       <th>Projeção</th>'
            cMensagem+='       <th>Meta Projetada</th>'
            cMensagem+='       <th>Dias Restantes</th>'
            cMensagem+='       <th>Falta por Dia</th>'
            cMensagem+='       <th>Maquinas</th>'
            cMensagem+='       <th>Ecolab</th>'
            cMensagem+='       <th>RubberMaid</th>'
            cMensagem+='       <th>Lavazza</th>'
            cMensagem+='   </tr>'
            cMensagem+=' </thead>'
            cMensagem+=' <tbody>'
            ntMeta:=0
            nAting:=0
            nFaltAtingir:=0
            nProj:=0
            nMaq:=0
            nEcolab:=0
            nRubber:=0
            nLavazza:=0
            nDev:=0
            While !TRBGER->(eof())

                ntMeta+=TRBGER->META
                nAting+=TRBGER->VALOR_ATINGIDO
                nFaltAtingir+=TRBGER->FALTA_ATINGIR
                nProj+=TRBGER->PROJECAO
                nMaq+=TRBGER->MAQUINAS
                nEcolab+=TRBGER->ECOLAB
                nLavazza+=TRBGER->LAVAZZA
                nRubber+=TRBGER->RUBBERMAID
                nDev+=TRBGER->DEVOLUCAO
                if (TRBGER->META_PROJETADA<100)
                    cMensagem+='   <tr style="text-align: center;" bgcolor="#FF0000">'
                else
                    cMensagem+='   <tr style="text-align: center;" bgcolor="#32CD32">'
                EndIf
                cMensagem+='     <td>'+TRBGER->MESANO+'</td>'
                cMensagem+='     <td>'+TRBGER->REGIAO+'</td>'
                cMensagem+='     <td>'+TRBGER->VEND+'</td>'
                cMensagem+='     <td>'+TRBGER->NVEND+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->META,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->VENDIDO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->DEVOLUCAO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->VALOR_ATINGIDO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->PERC_ATINGIDO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->FALTA_ATINGIR,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->PERC_FALTA_ATINGIR,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+CVALTOCHAR(TRBGER->TOTAL_DIAS)+'</td>'
                cMensagem+='     <td>'+CVALTOCHAR(TRBGER->TOTAL_PASSADO)+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->PROJECAO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->META_PROJETADA,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+CVALTOCHAR(TRBGER->DIAS_RESTNTES)+'</td>'
                cMensagem+='     <td>'+CVALTOCHAR(TRBGER->FALTA_POR_DIA)+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->MAQUINAS,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->ECOLAB,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->RUBBERMAID,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGER->LAVAZZA,"@E 999,999,999.99")+'</td>'
                cMensagem+='   </tr>'
                TRBGER->(dbSkip())
            EndDO
                cMensagem+='   <tr style="text-align: center;" >'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(ntMeta,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(nDev,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(nAting,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(nFaltAtingir,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(nProj,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(nMaq,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(nEcolab,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(nRubber,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(nLavazza,"@E 999,999,999.99")+'</td>'
                cMensagem+='   </tr>'
            cMensagem+=' </tbody> '
            cMensagem+=' </table>'
            cMensagem+=' '
        EndIf
        IF lTemVend
            cMensagem+=' <tr>'
            cMensagem+=' <h2>Projeção de vendas - VENDEDORES</h2>'
            cMensagem+=' '
            cMensagem+=' <table style="width:100%;border-collapse: collapse;text-align: center;">'
            cMensagem+='   <thead>  '
            cMensagem+='     <tr>'
            cMensagem+='       <th>Ano /  Mês</th>'
            cMensagem+='       <th>Regiao</th>'
            cMensagem+='       <th>Código Vendedor</th>'
            cMensagem+='       <th>Nome Vendedor</th>'
            cMensagem+='       <th>Meta</th>'
            cMensagem+='       <th>Total Vendido</th>'
            cMensagem+='       <th>Devolução</th>'
            cMensagem+='       <th>Valor Atingido</th>'
            cMensagem+='       <th>% Atingido</th>'
            cMensagem+='       <th>Falta Atingir</th>'
            cMensagem+='       <th>% Falta Atingir</th>'
            // cMensagem+='       <th>% Hoje</th>'
            cMensagem+='       <th>Total Dias</th>'
            cMensagem+='       <th>Dias Passados</th>'
            cMensagem+='       <th>Projeção</th>'
            cMensagem+='       <th>Meta Projetada</th>'
            cMensagem+='       <th>Dias Restantes</th>'
            cMensagem+='       <th>Falta por Dia</th>'
            cMensagem+='       <th>Maquinas</th>'
            cMensagem+='       <th>Ecolab</th>'
            cMensagem+='       <th>RubberMaid</th>'
            cMensagem+='       <th>Lavazza</th>'
            cMensagem+='   </tr>'
            cMensagem+=' </thead>'
            cMensagem+=' <tbody>'
            ntMeta:=0
            nAting:=0
            nFaltAtingir:=0
            nProj:=0
            nMaq:=0
            nEcolab:=0
            nRubber:=0
            nLavazza:=0
            nDev:=0
            While !TRBGERv->(eof())

                ntMeta+=TRBGERv->META
                nAting+=TRBGERv->VALOR_ATINGIDO
                nFaltAtingir+=TRBGERv->FALTA_ATINGIR
                nProj+=TRBGERv->PROJECAO
                nMaq+=TRBGERv->MAQUINAS
                nEcolab+=TRBGERv->ECOLAB
                nLavazza+=TRBGERv->LAVAZZA
                nRubber+=TRBGERv->RUBBERMAID
                nDev+=TRBGERv->DEVOLUCAO
                if (TRBGERv->META_PROJETADA<100)
                    cMensagem+='   <tr style="text-align: center;" bgcolor="#FF0000">'
                else
                    cMensagem+='   <tr style="text-align: center;" bgcolor="#32CD32">'
                EndIf
                cMensagem+='     <td>'+TRBGERv->MESANO+'</td>'
                cMensagem+='     <td>'+TRBGERv->REGIAO+'</td>'
                cMensagem+='     <td>'+TRBGERv->VEND+'</td>'
                cMensagem+='     <td>'+TRBGERv->NVEND+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->META,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->VENDIDO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->DEVOLUCAO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->VALOR_ATINGIDO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->PERC_ATINGIDO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->FALTA_ATINGIR,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->PERC_FALTA_ATINGIR,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+CVALTOCHAR(TRBGERv->TOTAL_DIAS)+'</td>'
                cMensagem+='     <td>'+CVALTOCHAR(TRBGERv->TOTAL_PASSADO)+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->PROJECAO,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->META_PROJETADA,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+CVALTOCHAR(TRBGERv->DIAS_RESTNTES)+'</td>'
                cMensagem+='     <td>'+CVALTOCHAR(TRBGERv->FALTA_POR_DIA)+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->MAQUINAS,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->ECOLAB,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->RUBBERMAID,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(TRBGERv->LAVAZZA,"@E 999,999,999.99")+'</td>'
                cMensagem+='   </tr>'
                TRBGERv->(dbSkip())
            EndDO
                cMensagem+='   <tr style="text-align: center;" >'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(ntMeta,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(nDev,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(nAting,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(nFaltAtingir,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(nProj,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td></td>'
                cMensagem+='     <td>'+TRANSFORM(nMaq,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(nEcolab,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(nRubber,"@E 999,999,999.99")+'</td>'
                cMensagem+='     <td>'+TRANSFORM(nLavazza,"@E 999,999,999.99")+'</td>'
                cMensagem+='   </tr>'
                cMensagem+=' </tbody> '
                cMensagem+=' </table>'
                cMensagem+=' '
        EndIf
        cMensagem+=' </body>'
        cMensagem+=' </html>'

        lEnv:=.f.
        lEnv:=SendMail(cMail,"PROJEÇÃO DE VENDAS EQUIPE GERENTE CODIGO "+TRBA->A3_COD,cMensagem,'\plan_vendas\'+ALLTRIM(TRBA->A3_COD)+'.xlsx')
        if lEnv
            cUpd:= "update SA3010 SET A3_XDTWF='"+DtOS(DDATABASE)+"' WHERE R_E_C_N_O_ ="+CVALTOCHAR(TRBA->REC)+""
            TcSqlExec(cUpd)
        else
                nerros++
        EndIf


        if nerros>10
            //Return
        EndiF
        TRBA->(DbSkip())
    EndDo

return




static function fGetXML(cTexto)

FWrite(nHandle,FwNoAccent(cTexto) + chr(13) + chr(10))

return

Static Function buscadados(cCodVend)

cSql:=" SELECT COD_PRODUTO,GRUPOPROD,GRPROD,VEND.A3_EMAIL EMAILVEND, VEND.A3_GEREN, GERENTE.A3_EMAIL AS EMAILGERENTE, "+chr(13)+chr(10)
cSql+=" 	COD_FIL, EMISSAO, VEND.A3_COD,VEND.A3_NOME,VEND_UA2, NUAVEND2,OPERADOR,NF,NOTAORIGEM,PEDIDO,COD_CLIENTE,HISTORICO,TMK, ITEM,PRODUTO,FORNECEDOR, QUANTI, PRCVEN,CUSTO PRCCOM, VENDA-FRETE TOTAL_VENDA, DEVOLUCAO,VENDA-FRETE+DEVOLUCAO TOTAL_GERAL  "+chr(13)+chr(10)
cSql+=" 	FROM SA3010 VEND "+chr(13)+chr(10)
cSql+=" 	LEFT JOIN SA3010 GERENTE "+chr(13)+chr(10)
cSql+=" 		on VEND.A3_FILIAL = GERENTE.A3_FILIAL "+chr(13)+chr(10)
cSql+=" 		AND VEND.A3_GEREN = GERENTE.A3_COD "+chr(13)+chr(10)
cSql+=" 		AND GERENTE.D_E_L_E_T_<>'*' "+chr(13)+chr(10)
cSql+=" 	INNER JOIN VENDAS  "+chr(13)+chr(10)
cSql+=" 		ON COD_VEND = VEND.A3_COD "+chr(13)+chr(10)
cSql+="  where EMISSAO LIKE '"+substr(dtos(DDATABASE),1,6)+"%' "+chr(13)+chr(10)
cSql+="  AND  (VEND.A3_COD IN ( SELECT A3_COD FROM SA3010 "+chr(13)+chr(10)
cSql+=" 						 WHERE A3_GEREN='"+cCodVend+"' "+chr(13)+chr(10)
cSql+=" 						 AND D_E_L_E_T_<>'*' "+chr(13)+chr(10)
cSql+=" 						 AND A3_MSBLQL<>'*') OR  "+chr(13)+chr(10)
cSql+=" 						 VENDAS.VEND_UA2 IN ( SELECT A3_COD FROM SA3010"+chr(13)+chr(10)
cSql+=" 						 WHERE A3_GEREN='"+cCodVend+"'"+chr(13)+chr(10)
cSql+=" 						 AND D_E_L_E_T_<>'*'"+chr(13)+chr(10)
cSql+=" 						 AND A3_MSBLQL<>'1') )"+chr(13)+chr(10)
cSql+="  AND  (VENDAS.CFOP NOT IN ('5908','6908','1909','2909') )"+chr(13)+chr(10)
cSql+="  and VEND.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
cSql+="  order by COD_FIL,VEND.A3_COD,VEND_UA2,EMISSAO,OPERADOR "+chr(13)+chr(10) 


if select('TRAB') != 0
	TRAB->(dbCloseArea())
endif
TCQuery cSql New Alias 'TRAB'

Return 

STATIC Function SendMail(cTo,cAssunto,cBody,cAnexo)

Local cServer    := GETMV("MV_RELSERV")
Local cAccount   := GETMV("MV_RELACNT")
Local cPassword  := GETMV("MV_RELPSW")
Local cFrom      := GETMV("MV_RELFROM")


lRet := EnvMail(cAccount,cPassword,cServer,cFrom,cTo,cAssunto,cBody,cAnexo)

Return lRet



Static Function EnvMail(cEnviaSMTP,cPassword,cServer,cEnvia,cTo,cAssunto,cHTML,cAnexo)

Local oMail  		:= NIL
Local oMessage  	:= NIL
Local nErro 		:= 0
Local lRet 			:= .T.
Local cSMTPServer	:= substr(cServer,1,at(':',cserver)-1 )
Local cSMTPUser		:= cEnviaSMTP
Local cSMTPPass		:= cPassword
Local cMailFrom		:= "SENTAX <"+cEnvia+">"
Local nPort	   		:= val(substr(cServer,at(':',cserver)+1))
Local lUseAuth		:= GetMV("MV_RELAUTH",,.T.)
Local cPara 		:= cTo //Destinatário
Local lTLS			:= GetMV("MV_RELTLS ",.F.,.F.)
Local nTOUT			:= GetMV("MV_RELTIME",.F.,120)

DEFAULT cAssunto := ""
DEFAULT cHTML := ""

cMsg :=chtml// StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cHTML, ";"), "&", "&amp;"), " ", "&nbsp;"), ">", "&gt;"), "<", "&lt;"), CRLF, "<BR>")

If !lTLS
	//MailSMTPOn
	CONNECT SMTP SERVER cSMTPServer ACCOUNT cSMTPUser PASSWORD cSMTPPass RESULT lRet
	If 	lRet
		SEND MAIL FROM cMailFrom ;
		TO cPara ;
		SUBJECT cAssunto ;
		BODY cMsg;
		ATTACHMENT ;
		RESULT lRet
		If !lRet
			GET MAIL ERROR cMAilError
			ConOut("Erro no envio do e-mail " + RTrim(cMAilError)) //"Erro no envio do e-mail "
		EndIf
		DISCONNECT SMTP SERVER
	Else
		GET MAIL ERROR cMAilError
		ConOut("Erro na conexão:" +  RTrim(cErro)) //"Erro na conexão:"
	EndIf
	
Else
	oMail := TMailManager():New()
	oMail:SetUseTLS(.T.)
    oMail:SetUseSSL(.f.)
	oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort  )
	oMail:SetSmtpTimeOut( nTOUT )
	nErro := oMail:SmtpConnect()
	
	If lUseAuth
		nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
		If nErro <> 0
			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')') //"Erro de Autenticacao "
			lRet := .F.
		Endif
	Endif
	
	if nErro <> 0
		
		// Recupera erro
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := '***UNKNOW***'
		conout(cMAilError)
		
		Conout("Erro de Conexão SMTP "+str(nErro,4)) //"Erro de Conexão SMTP "
		oMail:SMTPDisconnect()
		
		lRet := .F.
		
	Endif
	conout(chr(13)+chr(10)+"___________________________________________________________________________________________")
	conout(cpara)
	conout(chr(13)+chr(10)+"___________________________________________________________________________________________")
	If lRet
		oMessage := TMailMessage():New()
		oMessage:Clear()
		oMessage:cFrom	:= cMailFrom
		oMessage:cTo	:= cPara
		oMessage:cSubject	:= cAssunto
		oMessage:cBody		:= cMsg  
	   	nRet := oMessage:AttachFile( cAnexo )
		nErro := oMessage:Send( oMail )
		
		if nErro <> 0
			xError := oMail:GetErrorString(nErro)
			Conout("Erro de Envio SMTP" +str(nErro,4)+" ("+xError+")") //"Erro de Envio SMTP "
			lRet := .F.
		Endif
		
		oMail:SMTPDisconnect()
		FreeObj(oMessage)
	Endif
	
	FreeObj(oMail)
	
EndIf

Return lRet

static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

 
 
static function GERAXLS(cCodVend)

    local cPath := "\plan_vendas\"  // /spool/ para uma geração no server
    local cArquivo := cPath + "exemplo.rel"

    local lRet := .F.
    local oFileW 
    local oPrtXlsx 
 
    buscadados(cCodVend)
    cNome:=TRBA->A3_NOME
    cArquivo := cPath +ALLTRIM(cCodVend)+".rel"
    oFileW := FwFileWriter():New(cArquivo)
    oPrtXlsx := FwPrinterXlsx():New()

    

    lRet := oPrtXlsx:Activate(cArquivo, oFileW)
 
    lRet := oPrtXlsx:AddSheet("Minha Plan1")
 
    
    //PRIMEIRA LINHA E PRIMEIRA COLUNA
    cFont := FwPrinterFont():Calibri()
    nSize := 14
    lItalic := .T.
    lBold := .T.
    lUnderlined := .T.
    // Comando 'Fonte' com Calibri 14, itálico, negrito e sublinhado
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    // Comando 'Formato de Célula' com cor de texto e fundo personalizadas
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "00008B", "FFFFFF", "" )
 
    nColFrom := 1
    nColTo := 25
    nWidth := 24
    lRet := oPrtXlsx:SetColumnsWidth(nColFrom, nColTo, nWidth)
 
    nRow := 1
    nCol := 1
    // Texto em A1
    lRet := oPrtXlsx:SetText(nRow, nCol, ALLTRIM(cCodVend)+"-"+TRBA->A3_NOME)
 //PRIMEIRA LINHA E PRIMEIRA COLUNA ---FIM

//SEGUNDA LINHA
    // cFont := FwPrinterFont():getFromName("Calibri")
    cFont :=  FwPrinterFont():getFromName("Verdana")
    nSize := 11
    lItalic := .F.
    lBold := .T.
    lUnderlined := .F.
    // Calibri 11
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    lRet := oPrtXlsx:ResetCellsFormat()
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "FFFFFF", "00008B", "FFFFFF", "" )
    nRow := 2
    nCol := 1
    lRet := oPrtXlsx:SetText(nRow, nCol, "GRUPO")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "FILIAL")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "EMISSAO")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "VEND")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "NVEND")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "TELEVENDAS")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "NTELEV")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "OPERADOR")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "NOTA")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "NF_ORIGEM")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "PEDIDO")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "COD_CLI")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "FANTASIA")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "MARKETING")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "GRUPO")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "DESC.GRUPO")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "ITEM")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "PRODUTO")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "DESCRICAO")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "NOME_FORNEC")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "QUANT")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "PRCVEN")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "PRCCOM")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "Tot_venda")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "Tot_Dev")
    nCol++
    lRet := oPrtXlsx:SetText(nRow, nCol, "Tot_Geral")
    nCol++

    Ret := oPrtXlsx:ResetCellsFormat()

    while !TRAB->(EOF())
       
        nRow++
        nCol := 1
        lRet := oPrtXlsx:SetText(nRow, nCol, "SENTAX")
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol, ALLTRIM(TRAB->COD_FIL))
        nCol++

        lRet := oPrtXlsx:SetText(nRow, nCol,dtoc(STOD(TRAB->EMISSAO)))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,ALLTRIM(TRAB->A3_COD))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,ALLTRIM(TRAB->A3_NOME))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,TRAB->VEND_UA2)
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->NUAVEND2))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->OPERADOR))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->NF))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->NOTAORIGEM))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->PEDIDO))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->COD_CLIENTE))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->HISTORICO))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->TMK))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->GRPROD))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->GRUPOPROD))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->ITEM))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->COD_PRODUTO))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->PRODUTO))
        nCol++
        lRet := oPrtXlsx:SetText(nRow, nCol,alltrim(TRAB->FORNECEDOR))
        nCol++
        lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(CVALTOCHAR(TRAB->QUANTI)))
        nCol++
        lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(CVALTOCHAR(TRAB->PRCVEN)))
        nCol++
        lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(CVALTOCHAR(TRAB->PRCCOM)))
        nCol++
        lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(CVALTOCHAR(TRAB->TOTAL_VENDA)))
        nCol++
        lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(CVALTOCHAR(TRAB->DEVOLUCAO)))
        nCol++
        lRet := oPrtXlsx:SetNumber(nRow, nCol,alltrim(CVALTOCHAR(TRAB->TOTAL_GERAL)))

        TRAB->(DBSKIP())
    EndDo

 
    lRet := oPrtXlsx:toXlsx()
 
return 
