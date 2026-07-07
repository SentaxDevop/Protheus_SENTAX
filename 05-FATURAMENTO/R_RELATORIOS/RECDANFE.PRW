#include "Protheus.ch"
#include "FWMVCDEF.CH" 
//==================================================================================================//
//	Programa: RECDANFE		|	Autor: Luis Paulo							|	Data: 20/06/2022	//
//==================================================================================================//
//	Descrição: Funcao responsavel pela impressao de recibo complementar da DANFE					//
//	-																								//
//==================================================================================================//
User Function RECDANFE(oDanfe)

oDanfe:StartPage()

nLinha := 0025

oFont10   := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)
oFont10N  := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)

oFont8    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)
oFont8N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)

oDanfe:Box(020,200,150,420)

oDanfe:Say(nLinha +=10	,210,"PROCEDIMENTO PARA DEVOLUÇÃO",oFont10N:oFont)

oDanfe:Say(nLinha +=15	,210,"Devolução após a recepção da mercadoria.",oFont10:oFont)

oDanfe:Say(nLinha +=15	,210,"Para devolver as mercadorias que ja tenha recebido, o destinatário",oFont8:oFont)
oDanfe:Say(nLinha +=10	,210,"deverá emitir uma DANFE indicado:",oFont8:oFont)

oDanfe:Say(nLinha +=15	,210,"a) Número, data e valor desde DANFE;",oFont8:oFont)
oDanfe:Say(nLinha +=10	,210,"b) Motivo da devolução;",oFont8:oFont)
oDanfe:Say(nLinha +=10	,210,"c) Menção do valor do IPI correspondente ao produto;",oFont8:oFont)
oDanfe:Say(nLinha +=10	,210,"d) Destaque do ICMS correspondente ao produto;",oFont8:oFont)
oDanfe:Say(nLinha +=10	,210,"e) Discriminação de valores;",oFont8:oFont)
oDanfe:Say(nLinha +=10	,210,"f) Demais Obrigações;",oFont8:oFont)

//oDanfe:Line(nLinha +=10	,020,nLinha,250, 0,"-4")

oDanfe:Box(nLinha +=50,150,370,470)

oDanfe:Say(nLinha +=10	,160,"RECUSA DO DESTINATÁRIO EM RECEBER/ENTREGAR A MERCADORIA",oFont10N:oFont)
oDanfe:Say(nLinha +=10	,280,"DECLARAÇÃO",oFont10:oFont)

oDanfe:Say(nLinha +=15	,160,"Declaramos que deixamos de receber as mercadorias constantes nesta DANFE pelos motivos que",oFont8:oFont)
oDanfe:Say(nLinha +=10	,160,"expomos:",oFont8:oFont)

oDanfe:Say(nLinha +=15	,160,"____________________________________________________________________________",oFont8:oFont)
oDanfe:Say(nLinha +=15	,160,"____________________________________________________________________________",oFont8:oFont)
oDanfe:Say(nLinha +=15	,160,"____________________________________________________________________________",oFont8:oFont)
oDanfe:Say(nLinha +=15	,160,"____________________________________________________________________________",oFont8:oFont)

oDanfe:Say(nLinha +=20	,160,"_______________________________________ _______de__________________de________",oFont8:oFont)
oDanfe:Say(nLinha +=20	,160,"_____________________________________ _______________________________________",oFont8:oFont)
oDanfe:Say(nLinha +=10	,160, Space(17) + "Ass. Tranportador CNPJ" + Space(40) +"Ass. Destinatário CNPJ",oFont8:oFont)

/*
oDanfe:Say(nLinha +=15	,025,"Projeto: "		        ,oFont8N:oFont)
oDanfe:Say(nLinha +=10	,025,"Número: "	                ,oFont8N:oFont)
oDanfe:Say(nLinha +=10	,025,"Coordenador: "            ,oFont8N:oFont)
oDanfe:Say(nLinha +=10	,025,"CPF: "	                ,oFont8N:oFont)
oDanfe:Say(nLinha +=15	,025,"Assinatura: Este documento foi assinado digitalmente mediante login e senha de acesso,"	,oFont8N:oFont)
oDanfe:Say(nLinha +=10	,025,"seguindo as políticas de segurança da FUNPAR."	,oFont8N:oFont)

oDanfe:SayAlign (nLinha +=10, 025		, "NOME" 				    , oFont8N:oFont,0552,,,0,)
oDanfe:SayAlign (nLinha +=08, 025		, " Nome Teste"		, oFont8:oFont,0552,,,0,)

oDanfe:SayAlign (nLinha +=15, 025		, "OBS" 				    , oFont8N:oFont,0552,,,0,)
oDanfe:SayAlign (nLinha +=08, 025		, "obs teste"			    , oFont8:oFont,0552,,,0,)


oDanfe:Say(nLinha +=30,025,"Data Recebimento: " + DTOC(dDatabase) ,oFont8N:oFont)
*/
oDanfe:EndPage()

//oDanfe:Print()
Return()
