#include "rwmake.ch"
#include "topconn.ch"
#include "TOTVS.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} EmailCob
Responsavel por enviar e-mail de cobrança

@return 	
@author 	Henrique Baldin
@since 	 	28/05/2014
@version 	P11
/*/
//-------------------------------------------------------------------
User Function EmailCob(aPars) 

	DEFAULT aPars := {"01","020201"}

	RpcClearenv()

	RpcSetType( 3 )
	RpcSetEnv( aPars[1], aPars[2])

 	SendMail()

	RpcClearEnv()

Return

Static Function SendMail()

	Local cQuery   := ""
	Local oHtml    := ""  
	Local cStatus  := ""
	Local oProcess  
	Local cProcess
	Local cDias    := "7" //GetMV("ST_DMAILC",,"7")
	local cMailCob := ""      
	
	// tabelas abrem apenas  apos instanciar...
	cDias    := GetMV("ST_DMAILC",,"7") 
	cMailCob := SuperGetMV("ST_MAILCOB",,"cobranca2@sentax.com.br")
	cSrvPar  := GetMV("MV_RELSERV")

	Conout("---===========================")
	Conout(cSrvPar)
	Conout("---===========================")

	// consulta para pegar os titulos que iram vencer nos proximos 7 dias
	cQuery := "Select DISTINCT E1_CLIENTE ,E1_LOJA from SE1010 E1"
	cQuery += "  inner join SA1010 A1 on A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND A1_XIMPBOL = 'S' AND A1.D_E_L_E_T_ =' ' "
	cQuery += "  where E1_VENCREA >= '"+ DTOS(dDataBase) +"' " //DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0)
	cQuery += "    AND E1_VENCREA <= '"+ DTOS((dDataBase + Val(cDias)) ) +"' " //dateadd(day,"+cDias+",getdate())
	cQuery += "    AND E1_XFORMA = 'BOL'"
	cQuery += "    AND E1_SALDO > 0 "
	// cQuery += "    AND E1_CLIENTE IN('7403','7497'  )"
	cQuery += "    AND E1_XEMCOB ='F' "  // NAO FOI MANDADO E-MAIL AINDA
	cQuery += "    AND E1_XIMPBOL ='S' "//  IMPRIME BOLETO
	cQuery += "    AND E1.D_E_L_E_T_ =' ' ORDER BY E1_CLIENTE "   

	If ( SELECT("TRB1") ) > 0
		dbSelectArea("TRB1")
		TRB1->(dbCloseArea())
	EndIf

	Conout("")
	Conout(cQuery)
	Conout("")

	TCQUERY cQuery NEW ALIAS "TRB1"	

	DbSelectArea("TRB1")
	TRB1->(DbGoTop())

	If !Empty(TRB1->E1_CLIENTE)  // VERIFICA SE ENCONTROU ALGUM REGISTRO

		While !( TRB1->(EOF()) )
		
			cQuery1 := " SELECT * "
			cQuery1 += " FROM SE1010 "
			cQuery1 += " WHERE  E1_VENCREA 		>= '"+ DTOS(dDataBase) +"' " //DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0)
			cQuery1 += "    AND E1_VENCREA 		<= '"+ DTOS( (dDataBase + Val(cDias)) ) +"' " //dateadd(day,"+cDias+",getdate())
			cQuery1 += "    AND E1_XFORMA 		= 'BOL' "
			cQuery1 += "    AND E1_CLIENTE 		= '"+TRB1->E1_CLIENTE+"' "    
			cQuery1 += "    AND E1_LOJA			= '"+TRB1->E1_LOJA+"' "
			cQuery1 += "    AND E1_XIMPBOL 		='S' "	
			cQuery1 += "    AND E1_SALDO 		> 0 "		
			cQuery1 += "    AND D_E_L_E_T_ 		=' ' "		
			cQuery1 += "    ORDER BY E1_CLIENTE " 
			
			If ( SELECT("TRB2") ) > 0
				DbSelectArea("TRB2")
				TRB2->(DbCloseArea())
			EndIf
		
			TCQUERY cQuery1 NEW ALIAS "TRB2"
	
			//Abre area tabela Cliente
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))   
			SA1->(DbSeek(xfilial("SA1") + TRB2->E1_CLIENTE + TRB2->E1_LOJA))
				
				// Dispara E-mail..
				If !Empty(SA1->A1_X_EMAIL)

						Conout("")
						Conout("Enviando para....")
						Conout(Alltrim(SA1->A1_X_EMAIL))
						Conout("Enviando para....")
						Conout("")
						
						cProcess := OemToAnsi("000001")//OemToAnsi("COBRAN") //OemToAnsi("Cobran") // Numero do Processo
						cStatus  := OemToAnsi("001000")
						
						oProcess := nil 

						oProcess := TWFProcess():New(cProcess,OemToAnsi("Comunicado Grupo Sentax"))
					
						oProcess:NewTask("Envio E-mail lembrete de cobranca","\workflow\mailcob.html")
						
						oHtml:= oProcess:oHtml
						// cobranca2@sentax.com.br
						oProcess:cSubject := OemToAnsi( "Comunicado de vencimento - " + Alltrim(SA1->A1_NOME) )
						// endereço E-mail destinatario  
						oProcess:cTo  := Alltrim(SA1->A1_X_EMAIL)
						oProcess:cCC  := Alltrim(cMailCob)
						oProcess:cBCC := GetMV("ST_MAILTI")

						oHtml:ValByName("it.titulo",{})
						oHtml:ValByName("it.emissao",{})
						oHtml:ValByName("it.vencimento",{})
						oHtml:ValByName("it.valor",{})

						While ( TRB2->(!Eof()) )
							AAdd(oHtml:ValByName("it.titulo"),TRB2->E1_NUM)
							AAdd(oHtml:ValByName("it.emissao"),SUBSTR(TRB2->E1_EMISSAO,7,2) + "/" + SUBSTR(TRB2->E1_EMISSAO,5,2) + "/" + SUBSTR(TRB2->E1_EMISSAO ,1,4) )
							AAdd(oHtml:ValByName("it.vencimento"),SUBSTR(TRB2->E1_VENCREA,7,2) + "/" + SUBSTR(TRB2->E1_VENCREA,5,2) + "/" + SUBSTR(TRB2->E1_VENCREA ,1,4) )
							AAdd(oHtml:ValByName("it.valor"), Transform(TRB2->E1_VALOR, "@E 999999.99")) 
							
							// Altera campo flag para nao mandar novamente e-mail a nao ser que seja alterado 
							
							_cQuery := "UPDATE " + RetSqlName("SE1") + " "
							_cQuery += "   SET E1_XEMCOB ='T' "
							_cQuery += " WHERE  E1_FILIAL = '"+TRB2->E1_FILIAL+"' "
							_cQuery += "  AND R_E_C_N_O_ ='"+ LTRIM(STR(TRB2->R_E_C_N_O_)) +"'  "
											
							If TCSQLExec(_cQuery)   
								Conout("")    
								Conout("erro na queryyy")
								Conout("")
							EndIf 
							
							TRB2->(DBSkip())
						EndDo            
						
						oHtml:ValByName("RODAPE",getRodape())
						
						Sleep(500)
						/*
						cRetWF := oProcess:Start('\workflow\copia\')

						Sleep(1000)
						If File( '\workflow\copia\' + cRetWF)
							Conout("")
							Conout('Arquivo copiado com sucesso')
							Conout("")
							Conout("")
							Conout("ID WF -> " + cRetWF)
							Conout("")
						EndIf
						*/
						cRetWF := oProcess:Start() 

						Conout("")
						Conout("ID WF -> " + cRetWF)
						Conout("")
						
						Sleep(1000)

						oProcess:Finish()

						Sleep(2000)
					
					Else 
						Conout("")
						Conout("E-mail nao cadastro para o cliente -> " + TRB2->E1_CLIENTE +"/"+ TRB2->E1_LOJA)
						Conout("")
				EndIf 

			TRB1->(DBSkip())
		EndDo

	EndIf 

Return()		 	

//-------------------------------------------------------------------
/*/{Protheus.doc} getRodape
Workaround para solucionar o error.log no HTML para exibir o rodapé

@author 	Leandro Natan Bonette Santos
@since 	 	19/06/2015
@return     cRodape, HTML do rodapé
/*/
//-------------------------------------------------------------------
Static Function getRodape()

	Local cRodape := ""

	cRodape += '<div style="font-size: 13px; color: #202664; font-family: Verdana, Arial, Helvetica, sans-serif;">'
	cRodape += '	<strong>DEPARTAMENTO DE COBRANÇA</strong><br />'
	cRodape += '	<strong>SENTAX DO BRASIL</strong><br />'
	cRodape += '	Distribuidor e Representante Exclusivo: <br />'
	cRodape += '	Kimberly Clark/ Ecolab/ Dixie Toga/ Netter/Rubbermaid/Lavazza<br />'
	cRodape += '	41 3360- 8500<br />'
	cRodape += '	41 8803- 8518<br />'
	cRodape += '	0800 644 0350<br />'
	cRodape += '	Fax: 41 3360-8504/05<br />'
	cRodape += '	<a href="mailto:cobranca2@sentax.com.br">cobranca2@sentax.com.br</a> - <a href="http://www.sentax.com.br">www.sentax.com.br</a> <br />'
	cRodape += '	Grupo Sentax do Brasil:<br />'
	cRodape += '	Gibraltar Ltda/Arvoredo Ltda<br />'
	cRodape += '</div>'

Return cRodape
