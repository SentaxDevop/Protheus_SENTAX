#Include "rwmake.ch"
#include "ap5mail.ch"
#include "totvs.ch"
#Include "topconn.ch"
//==================================================================================================//
//	Programa: MailTo 	|	Autor: Luis											|	Data: 21/11/2022//
//==================================================================================================//
//	Descrição: Rotina para envio de e-mails 						 								//
//																									//
//==================================================================================================//
User Function MailTo(_cTo, _cSubject, _cFrom, _cNomeFrom, _cBody, _aAnexo)
Local cMailServer 	:= Getmv("MV_RELSERV") 	                                                                                                                                                         
Local cMailConta 	:= GetMv("MV_RELACNT") 				//Conta de e-mail
Local cMailSenha 	:= GETMV("MV_RELPSW")				//Senha conta de e-mail
Local cAssunto 		:= _cSubject						//Assunto da mensagem
Local cMail 		:= _cTo								//Destinatário de e-mail
Local cMensagem 	:= _cBody							//Mensagem
Local _cOrigem 		:= GetNewPar("MV_RELFROM", "") 		//Origem da mensagem
Local lOK 			:= .F. 								//Retorno da função
Local _lAuth 		:= .F. 								// autenticação de e-mail
Local _aAnexo 		:= IIF( _aAnexo == NIL, "", _aAnexo) //Anexo

IF Empty(GETMV('MV_RELSERV'))
	Conout("Servidor não encontrado")
	Return(.T.)

Endif

cMensagem += CRLF+CRLF

cMensagem += " Atenção, este é um e-mail automático gerado por sistema. "
cMensagem += " Não responda e não classifique como SPAM. "+CRLF
cMensagem += " -------------------------------------------------------------------------------------------------------------- "+CRLF
cMensagem += " Esta mensagem, incluindo seu(s) anexo(s), pode conter informações privilegiadas e/ou de caráter confidencial  "
cMensagem += " em decorrência de relação contratual e/ou da Lei nº 13.709/18 (Lei Geral de Proteção de Dados Pessoais - LGPD), " 
cMensagem += " não podendo ser retransmitida sem autorização expressa do remetente. Se você recebeu esta mensagem por engano,  "
cMensagem += " por favor, informe-nos e apague-a; não copie ou divulgue seu conteúdo." 


CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOK
  
If ( !lOK )
  	//Help(" ", 1, "ACAA170_01")	
  	Conout("Nao Autenticou")
  Else	
  	//Conout("Autenticou")
	_lAuth := MailAuth(cMailConta, cMailSenha)	
	If !_lAuth
			GET mail error cError
			Conout(cError)
			lOK := .F.
		Else
	
			SEND MAIL FROM _cOrigem TO AllTrim(cMail) SUBJECT cAssunto BODY cMensagem attachment _aAnexo RESULT lSendOk 
		  	
			If (!lSendOk)
					GET mail error cError
					Conout(cError)
					lOK := .F.
					Conout("Não Enviou")
				Else
					//Conout("Enviou")
			EndIf                                                    
			
	EndIf
EndIf

DISCONNECT SMTP SERVER

Return(lOK)
