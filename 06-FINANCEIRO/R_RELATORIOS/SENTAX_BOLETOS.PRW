#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF (chr(13)+chr(10))
/*/{Protheus.doc} SENTAX_BOLETOS
Chamada de impressão dos boletos

@author Gisele Morais
@since 12/01/2012
@version P11 R8

@history 10/08/2017, dirlei@afsouza, inclusão do banco 237-Bradesco

@type function
/*/
User Function BOLETOS()
//User Function SE_BOLBB()

//Local   nOpc       := 0
//Local   aDesc      := {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
PRIVATE Exec       := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''

Private _CMV_PAR10 := 1 //AFSOUZA - VARIÁVEL UTILIZADA PARA SUBSTITUIR O ANTIGO MV_PAR10 "COBRANÇA REGISTRADA"
Private cPerg := "BOLS"

dbSelectArea("SE1")
SE1->(DBSetOrder(01))

validPerg()
Pergunte (cPerg,.F.)
Private lAbortPrint  := .F.
@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Impressao de Boletos"
@ 02,02 SAY "Este programa tem como objetivo imprimir os boletos do"
@ 03,02 SAY "Financeiro."
@ 04,02 SAY ""
@ 01,01 TO 5,25

@ 91,089 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg,.t.)
@ 91,118 BMPBUTTON TYPE 1 ACTION OKProc()
@ 91,146 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
ACTIVATE DIALOG oDlg5 Centered
Return

Static Function OkProc

DbSelectArea("SA6")
SA6->(DbSetOrder(1))

If SA6->(DbSeek(xFilial("SA6")+MV_PAR05+MV_PAR06+MV_PAR07))
	
	If SA6->A6_XCTGRTA == "1"
		
		ShowHelpDlg("CTAGARANT",{"Não é possível gerar um borderô para uma conta garantida"},1,;
		{"Selecione outro banco"})
		
		Return
		
	EndIf
	
	If AllTrim(MV_PAR05) == "237" .and. AllTrim(MV_PAR06) == "05755" .and. !(AllTrim(MV_PAR07) == "0115813")
		FWAlertHelp("Conta inválida para o portador BRADESCO.", "Informe a conta 0115813 e prossiga com a operação.")
		Return
	End

EndIf

If Empty(AllTrim(DtoS(MV_PAR10)))
	Aviso("Boletos","Campo data de emissão inválido.", {'Ok'}, 1)
	Return
EndIf

PegaDados()
dbselectArea("TRA")
dbGoTop()
SelSE1()

Return Nil
/*
+---------------------------------------------------------------------------+
!	Montar Relatorio		                                                !
+---------------------------------------------------------------------------+
*/
Static Function MontaRel()

Local oPrint
Local n 	    := 0
Local aDadosEmp := { SM0->M0_NOMECOM																		,; 	//Nome da Empresa
					Transform(SM0->M0_CEPCOB,"@R 99999-999")												,; 	//CEP
					SM0->M0_ENDCOB                                                          				,; 	//Endereço
					AllTrim(SM0->M0_BAIRCOB) +"-"+ AllTrim(SM0->M0_CIDCOB) +"-"+ SM0->M0_ESTCOB				,; 	//Complemento
					"PABX/FAX: "+ SM0->M0_TEL																,; 	//Telefones
					Transform(IIf(MV_PAR05 == '033',"08532602000100",SM0->M0_CGC),"@R 99.999.999/9999-99")	,; 	//CGC
					"I.E.: "+ AllTrim(SM0->M0_INSC) 														}	//I.E
Local aDadosTit   := {}
Local aDadosBanco := {}
Local aDatSacado  := {}
Local i           := 1
Local CB_RN_NN    := {}
//Local nRec        := 0
Local _nVlrAbat   := 0
Local lPrint      := .F.
Local cNomeBco    := ''
Local cBordero	  := ""

Private xDac      := ''
Private xCarteira := ''

oPrint:= TMSPrinter():New( )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:Setup()
oPrint:StartPage()   // Inicia uma nova página
dbGoTop()
ProcRegua(RecCount())

DbSelectArea("SE1")
Set Filter To
SE1->(DBSetOrder(1))

While !TRA->(Eof()) .And. TRA->E1_NUM <= MV_PAR04
	If !Empty(TRA->OK)
		lPrint := .T.
		nMulta := 0.02 * TRA->E1_SALDO
		xMDia  := TRA->E1_SALDO*TRA->E1_VALJUR/100
		
		If (MV_PAR05 == '104')
			aBolText := {"Até o vencimento pagável em qualquer banco ou casas lotéricas",;
			"Após o vencimento cobrar juros de 0,2% ao dia",;
			"Não dispensar cobrança de juros em nenhuma hipótese",;
			"Sujeito a protesto após 5 dias do vencimento"}
		ElseIf (MV_PAR05 == '033')
			
			aBolText := {"Protesto automático após 07 dias (depósito não quita boleto)"	,;	
						"Não dispensar cobrança de juros em nenhuma hipotese"			,; 
						"Após vencimento cobrar juros ao dia de 0,2% "					,;
						"NOTA FISCAL: " + TRA->E1_NUM									}

		Else
			aBolText := {"Protesto automático após 05 dias (depósito não quita boleto)",;	//Encaminhar ao SERASA após 05 dias corridos do vencimento",;
			"",;
			"Não dispensar cobrança de juros em nenhuma hipotese",; //	"Após vencimento cobrar R$ " + Alltrim(Transform(xMDia, "@E 9,999.99")) + "  por dia de atraso",;
			"Após vencimento cobrar juros ao dia de 0,2% "}
		EndIf
		
		DbSelectArea("SA6")
		DbSetOrder(1)// filial+ banco + agencia + conta
		If !(DbSeek(xFilial('SA6') + MV_PAR05 + MV_PAR06 + MV_PAR07))
			Alert("Banco Não localizado! Verifique os dados digitados e se a Filial esta correta.")
			Return
		EndIF
		//(E1_PORTADO + E1_AGEDEP + E1_CONTA),.T.)
		
		DbSelectArea("SEE")
		DbSetOrder(1)// filial+ banco + agencia + conta + subconta
		If !(DbSeek(xFilial('SEE')+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON)+MV_PAR08,.T.))
			Alert("Parametro de banco nao localizado! Verifique os dados digitados e se a Filial esta correta.")
			Return
		EndIf
		
		//Chama função para gerar bordero
		If Empty(TRA->E1_NUMBOR)
			cBordero :=	U_AFIN002(SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON)
		Else
			cBordero := TRA->E1_NUMBOR
		EndIf
		
		xDac      := ALLTRIM(SA6->A6_DVCTA)
		//xCarteira := Iif(MV_PAR05 == '341','109',Iif(MV_PAR05 == '104','RG',Iif(MV_PAR05 == "237","09",Iif(MV_PAR05 == "001","17",Iif(_CMV_PAR10 <> 1 .And. MV_PAR05 == '399', 'CNR','00')))))
		//cNomeBco  := Iif(MV_PAR05 == '341','ITAU',Iif(MV_PAR05 == '104','',Iif(MV_PAR05 == "237","BRADESCO",Iif(MV_PAR05 == "001","BANCO DO BRASIL",Iif(MV_PAR05 == '399','HSBC',Alltrim(SA6->A6_NOME))))))
		
		If MV_PAR05 == '341'
			xCarteira	:= '109'
			cNomeBco 	:= 'ITAU'
		ElseIf MV_PAR05 == '104'
			xCarteira	:= 'RG'
			cNomeBco 	:= ''
		ElseIf MV_PAR05 == '237'
			xCarteira	:= '02'
			cNomeBco 	:= 'BRADESCO'
		ElseIf MV_PAR05 == '001'
			xCarteira	:= '17'
			cNomeBco 	:= 'BANCO DO BRASIL'
		ElseIf MV_PAR05 == '399'
			xCarteira	:= 'CNR'
			cNomeBco 	:= 'HSBC'
		ElseIf MV_PAR05 == '033'
			xCarteira	:= '101'
			cNomeBco 	:= 'SANTANDER'			
		Else
			xCarteira	:= '00'
			cNomeBco 	:= Alltrim(SA6->A6_NOME)			
		End
			
		aDadosBanco := { SA6->A6_COD				,;   //1 Numero do Banco
						AllTrim(cNomeBco)			,;   //2 Nome do Banco
						AllTrim(SA6->A6_AGENCIA)	,;   //3 Agência
						AllTrim(SA6->A6_NUMCON)		,;   //4 Conta Corrente
						xCarteira					,;   //5 Carteira
						SA6->A6_COD					,;   //6 Codigo no SA6
						AllTrim(SEE->EE_CODEMP) }        //7 Codigo de Convenio
		
		dbSelectArea('SA1')
		SA1->(DBSeek(xFilial('SA1') + TRA->E1_CLIENTE + TRA->E1_LOJA))
		
		aDatSacado := { AllTrim(SA1->A1_NOME)	,;   //Razão Social
						AllTrim(SA1->A1_COD )	,;   //Código
						AllTrim(SA1->A1_END )	,;   //Endereço
						AllTrim(SA1->A1_MUN )	,;   //Cidade
						SA1->A1_EST				,;   //Estado
						SA1->A1_CEP				,;   //CEP
						SA1->A1_CGC				,;   //CGC
						SA1->A1_XMSGBOL } 			 //Mensagem fixa no boleto
		_nVlrAbat := SomaAbat(TRA->E1_PREFIXO,TRA->E1_NUM,TRA->E1_PARCELA,"R",1,,TRA->E1_CLIENTE,TRA->E1_LOJA)
		_cPrefixo := TRA->E1_PREFIXO
		_nTitulo  := TRA->E1_NUM
		
		IF !Empty(TRA->E1_PARCELA)
			_nTitulo  := _nTitulo + ' - ' + TRA->E1_PARCELA
		ENDIF

		//If MV_PAR05 == '033'
		//	_nTitulo := TRA->E1_IDCNAB
		//End
		
		_dEmissao := TRA->E1_EMISSAO
		_dVenc    := TRA->E1_VENCREA
		_nSaldo   := TRA->E1_SALDO
		_nDecres  := TRA->E1_DECRESC
		_nAcres   := TRA->E1_ACRESC
		xParcela  := TRA->E1_PARCELA
		
		//CB_RN_NN  := Ret_cBarra( Subs(aDadosBanco[1],1,3)+'9', aDadosBanco[3],ALLTRIM(aDadosBanco[4])+ALLTRIM(xDac) ,;
		//aDadosBanco[5],AllTrim(TRA->E1_NUM)+AllTrim(TRA->E1_PARCELA),(TRA->E1_SALDO-_nVlrAbat),aDadosBanco[6],TRA->E1_VENCREA,TRA->E1_PREFIXO)
		//Correcao em 18.04.12 - Substituicao de Valor de Abatimento por Decrescimo (Gisele Morais)
		CB_RN_NN := Ret_cBarra( SubStr(aDadosBanco[1],1,3)+'9', aDadosBanco[3],AllTrim(aDadosBanco[4]) + AllTrim(xDac) ,;
					aDadosBanco[5],AllTrim(TRA->E1_NUM)+AllTrim(TRA->E1_PARCELA),((TRA->E1_SALDO+_nAcres)-_nDecres),aDadosBanco[6],TRA->E1_VENCREA,TRA->E1_PREFIXO)
		
		aDadosTit := { AllTrim(_nTitulo)   					,; //Número do título
						_dEmissao            				,; //Data da emissão do título
						Date()               				,; //Data da emissão do boleto
						_dVenc               		   		,; //Data do vencimento
						((_nSaldo + _nAcres) - _nDecres)	,; //Valor do título
						CB_RN_NN[3]							,; //Nosso Numero
						xParcela }						       //parcela incluido em 18/02/03
						//(_nSaldo - _nVlrAbat),;		       //Valor do título
		
		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
		n := n + 1
		i := i + 1
	EndIF
	
	TRA->(dbSkip())
	IncProc()
EndDo

oPrint:EndPage()     // Finaliza a página
If lPrint
	oPrint:Preview()     // Visualiza antes de imprimir
Endif

Return nil

/*
+---------------------------------------------------------------------------+
!	Impressao de Boletos	                                                !
+---------------------------------------------------------------------------+
*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)  //Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

Local oFont8
Local oFont9
Local oFont10
Local oFont16
Local oFont16n
Local oFont24
Local i := 0
//Local aCoords1 := {2000,1900,2100,2300}
//Local aCoords2 := {2270,1900,2340,2300}
//Local oBrush
Local cLogo    := ''
Local _cNN     := ''
Local cMsg1    := ''
Local cMsg2    := ''
Local cMsg3    := ''
Local cDVAge   := AllTrim(POSICIONE("SA6",1,XFILIAL("SA6")+MV_PAR05+aDadosBanco[3],"A6_DVAGE"))
Local cCodBen33:= '0173839'

If ( MV_PAR05 == '341' )
	_cNN := '109/'+aDadosTit[6]
ElseIf ( MV_PAR05 == '104' )
	cLogo :='\system\caixa.bmp'
	_cNN := aDadosTit[6]
ElseIf MV_PAR05 == "237"
	cLogo := "\system\bradesco.bmp"
	_cNN := AllTrim(aDadosTit[6])
ElseIf ( MV_PAR05 == '399' )
	cLogo :='\system\hsbc.bmp'
	_cNN := aDadosTit[6]
ElseIf ( MV_PAR05 == '001' )
	cLogo :='\system\BB.bmp'
	_cNN := aDadosTit[6]
ElseIf ( MV_PAR05 == '033' )

	cDVAge   := AllTrim(POSICIONE("SA6",1,XFILIAL("SA6") + MV_PAR05 + PADR(aDadosBanco[3],5,"") + aDadosBanco[4],"A6_DVAGE"))

	cLogo :='\system\SANTANDER.bmp'

	_cNN := aDadosTit[6]	

	_cE1Numbco	:=	Alltrim(_cNN) + Alltrim(u_digMod11(_cNN))

EndIf


oFont8   := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Arial",9, ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,18,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)

If (MV_PAR05 == '341')
	cMsg1 := "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO ITAÚ"
	cMsg2 := "APÓS O VENCIMENTO, SOMENTE NO ITAÚ"
	cMSg3 := ''
ElseIf (MV_PAR05 == '104')
	cMsg1 := "PREFERENCIALMENTE NAS LOTÉRICAS ATÉ O VALOR LIMITE"
	cMsg2 := ''
	cMSg3 := ''
ElseIf MV_PAR05 == "237"
	cMsg1 := "PAGAVEL PREFERENCIALMENTE NA REDE BRADESCO OU NO"
	cMsg2 := "BRADESCO EXPRESSO"
	cMSg3 := ""
ElseIf (MV_PAR05 == '399')
	cMsg1 := "PAGAR PREFERENCIALMENTE EM AGÊNCIA DO HSBC"
	cMsg2 := ''
	cMSg3 := ''
ElseIf (MV_PAR05 == '001')
	//cMsg1 := "Pagável em qualquer banco até o vencimento. Após, atualize o boleto no site bb.com.br"
	cMsg1 := "Pagável em qualquer banco."
	cMsg2 := ''
	cMSg3 := ''
ElseIf (MV_PAR05 == '033')
	//cMsg1 := "Pagável em qualquer banco até o vencimento. Após, atualize o boleto no site bb.com.br"
	cMsg1 := "PAGÁVEL PREFERENCIALMENTE NO BANCO SANTANDER"
	cMsg2 := ''
	cMSg3 := ''
EndIf

oPrint:StartPage() // Inicia uma nova página

/*----------------------------------------------/
/	Primeira Via								/
/----------------------------------------------*/
oPrint:Line (150,100,150,2300)
oPrint:Line (150,550,50,550)
oPrint:Line (150,800,50,800)

//oPrint:SayBitmap(linha,coluna,"C:\SUAPASTA\SUAIMAGEM.BMP",largura,altura)
If (MV_PAR05 == '104')
	oPrint:SayBitmap(50,100,cLogo,450,70)
	oPrint:Say (50,567,aDadosBanco[1]+'-0',oFont24)
ElseIf (MV_PAR05 == '399')
	oPrint:SayBitmap(50,100,cLogo,450,70)
	oPrint:Say (50,567,aDadosBanco[1]+'-9',oFont24)
ElseIf MV_PAR05 == "237"
	oPrint:SayBitmap(55,100,cLogo,400,80)
	oPrint:Say (55,567,aDadosBanco[1]+'-2',oFont24)
ElseIf (MV_PAR05 == '033')
	oPrint:SayBitmap(50,130,cLogo,300,100)	
	oPrint:Say (50,567,aDadosBanco[1]+'-7',oFont24)	
Else
	//oPrint:Say (50,100,aDadosBanco[2],oFont24)
	oPrint:SayBitmap(55,100,cLogo,450,70)
	oPrint:Say (50,567,aDadosBanco[1]+"-9",oFont24)
EndIf
oPrint:Say (70,820,CB_RN_NN[2],oFont14)

//linhas horizontais
oPrint:Line (220,1900,220,2300 )
oPrint:Line (245/*290*/,100,245/*290*/,1900/*2300*/ )
oPrint:Line (290,1900,290,2300)
oPrint:Line (360,100,360,2300 )
oPrint:Line (425,100,425,2300 )
oPrint:Line (490,100,490,2300 )

//linhas verticais
oPrint:Line (360,500,490,500)
oPrint:Line (425,750,490,750)
oPrint:Line (360,1000,490,1000)
oPrint:Line (245/*290*/,1350,425,1350)
oPrint:Line (360,1550,490,1550)
                                                               
oPrint:Say  (150,100 ,"Local de Pagamento"                           								,oFont8)
oPrint:Say  (150,400 ,cMsg1                                          								,oFont10)
oPrint:Say  (180,400 ,cMsg2                                          								,oFont10)
oPrint:Say  (220,400 ,cMsg3                                          								,oFont10)

oPrint:Say  (150,1910,"Vencimento"                                   								,oFont8)
oPrint:Say  (175,2010,dtoc(aDadosTit[4])                           									,oFont10)

oPrint:Say  (220,1910,"Agência/Código Beneficiário"													,oFont8)
If MV_PAR05 == '104'
	oPrint:Say  (245,1950,ALLTRIM(aDadosBanco[3])+'/'+ALLTRIM(aDadosBanco[7]),oFont10)
ElseIf MV_PAR05 == '033'
	oPrint:Say  (245,1950,ALLTRIM(aDadosBanco[3])+'/'+cCodBen33,oFont10)
Else
	oPrint:Say  (245,1950,ALLTRIM(aDadosBanco[3]+"-"+cDVAge)+' / '+ALLTRIM(aDadosBanco[4])+IIF(xDac <> '','-' + xDac,'') ,oFont10)
Endif
oPrint:Say  (245/*290*/,100 ,"Beneficiário",oFont8)
oPrint:Say  (280/*315*/,100 ,aDadosEmp[1],oFont10)
oPrint:Say  (320/*315*/,100 ,aDadosEmp[2] +" "+ AllTrim(aDadosEmp[3]) +" "+ aDadosEmp[4] ,oFont10)

oPrint:Say  (245/*290*/,1355,"CNPJ/CPF",oFont8)
oPrint:Say  (280/*315*/,1455,aDadosEmp[6],oFont10)

oPrint:Say  (290,1910,"Nosso Número"                                  								,oFont8)
IF (MV_PAR05=='104')
	oPrint:Say  (315,1950,LEFT(_cNN,2)+'/'+SUBS(_cNN,3,LEN(_cNN)-3)+'-'+RIGHT(_cNN,1)				,oFont10)
ElseIF(MV_PAR05=='399' .AND. _CMV_PAR10 == 1)
	oPrint:Say  (315,1950,SUBS(_cNN,1,LEN(_cNN)-1)+'-'+RIGHT(_cNN,1)								,oFont10)
ElseIF(MV_PAR05=='399' .AND. _CMV_PAR10 <> 1)
	oPrint:Say  (315,1950,SUBS(_cNN,1,LEN(_cNN)-3)+'-'+RIGHT(_cNN,3)								,oFont10)
ElseIf MV_PAR05 == "237"
	oPrint:Say  (315,1950,xCarteira +"/"+ SubStr(_cNN,1,11) +"-"+ Right(_cNN,1),oFont10) 
ElseIf MV_PAR05 == "033"
	oPrint:Say  (315,1950,_cE1Numbco,oFont10) 

Else
	oPrint:Say  (315,1950,"3097391"+_cNN															,oFont10)
EndIf

oPrint:Say  (360,100 ,"Data do Documento"                             								,oFont8)
oPrint:Say  (385,100 ,DTOC(aDadosTit[3])                             								,oFont10)

oPrint:Say  (360,505 ,"Número do Documento"                            								,oFont8)
oPrint:Say  (385,605 ,aDadosTit[1]                                     								,oFont10)

oPrint:Say  (360,1005,"Espécie"                                        								,oFont8)
oPrint:Say  (385,1105,"DM"                                             								,oFont10)

oPrint:Say  (360,1355,"Aceite"                                         			 					,oFont8)
oPrint:Say  (385,1455,"NAO"                                             							,oFont10)

oPrint:Say  (360,1555,"Data do Processamento"                           							,oFont8)
oPrint:Say  (385,1655,dtoc(aDadosTit[2])                                							,oFont10)

oPrint:Say  (360,1910,"(=)Valor do Documento"                           							,oFont8)
oPrint:Say  (385,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) 							,oFont10)

oPrint:Say  (425,100 ,"Data de Operação"  															,oFont8)
oPrint:Say  (450,150 ,dtoc(aDadosTit[2])   															,oFont10)

oPrint:Say  (425,505 ,"Carteira"                                        							,oFont8)
oPrint:Say  (450,555 ,xCarteira                                         							,oFont10)

oPrint:Say  (425,755 ,"Espécie Moeda"                                   							,oFont8)
oPrint:Say  (450,805 ,"R$"                                              							,oFont10)

oPrint:Say  (425,1005,"Quant. Moeda"                                    							,oFont8)
oPrint:Say  (425,1555,"Valor da Moeda"                                  							,oFont8)

oPrint:Say  (490,100 ,"Instruções (Todas informações deste boleto são de exclusiva responsabilidade do beneficiário.)" ,oFont8)
oPrint:Say  (520,150 ,aBolText[1]                                       							,oFont10)
oPrint:Say  (565,150 ,aBolText[2]                                       							,oFont10)
oPrint:Say  (610,150 ,aBolText[3]                                       							,oFont10)
oPrint:Say  (655,150 ,aBolText[4]                                       							,oFont10)
oPrint:Say  (700,150 ,aDatSacado[8]                                       							,oFont10)

oPrint:Say  (425,1910,"(-)Desconto"                                     							,oFont8)
oPrint:Say  (490,1910,"(-)Outras Deduções/Abatimento"                   							,oFont8)
oPrint:Say  (560,1910,"(+)Mora/Multa/Juros"                                   						,oFont8)
oPrint:Say  (630,1910,"(+)Outros Acréscimos"                            							,oFont8)
oPrint:Say  (700,1910,"(=)Valor Cobrado"                                							,oFont8)

oPrint:Say  (770,100 ,"Pagador"                                          							,oFont8)
oPrint:Say  (770,400 ,aDatSacado[1]                                     							,oFont9)
oPrint:Say  (871,1700,"CNPJ/CPF - "+ IIF(Len(AllTrim(aDatSacado[7])) == 11,Transform(aDatSacado[7],"@R 999.999.999-99"), Transform(aDatSacado[7],"@R 99.999.999/9999-99")),oFont9)

oPrint:Say  (818,400 ,aDatSacado[3]                                     							,oFont9)
oPrint:Say  (871,400 ,aDatSacado[4]+' - '+aDatSacado[5]+' CEP '+aDatSacado[6] 						,oFont9)

//oPrint:Say  (818,1910,_cNN,oFont9)

oPrint:Say  (922,100 ,"Sacador/Avalista"                                							,oFont8)
oPrint:Say  (922,400 ,aDadosEmp[1]                               									,oFont9)

//oPrint:Say  (922,2000 ,"Código de Baixa"                                							,oFont8)

//oPrint:Say  (962,100,"Recebimento através do cheque num.                    do banco            ." 	,oFont8)
oPrint:Say  (962,1650,"Autenticação Mecânica - RECIBO DO PAGADOR"                 							,oFont8)
//oPrint:Say  (982 ,100,"Esta quitação só terá validade após o pagamento do cheque pelo" 				,oFont8)
//oPrint:Say  (1002,100,"banco sacado."																,oFont8)

oPrint:Line (150,1900,770,1900 )
oPrint:Line (560,1900,560,2300 )
oPrint:Line (630,1900,630,2300 )
oPrint:Line (700,1900,700,2300 )
oPrint:Line (770,100,770,2300 )

oPrint:Line (957,100,957,2300  )

//Gambiarra, descobrir como mudar tipo da linha.
For i := 100 to 2300 step 50
	oPrint:Line( 1083, i, 1083, i+30)
Next i

/*----------------------------------------------/
/	Segunda Via									/
/----------------------------------------------*/
oPrint:Line (1180,100,1180,2300)
oPrint:Line (1180,550,1080,550)
oPrint:Line (1180,800,1080,800)

If (MV_PAR05 == '104')
	oPrint:SayBitmap(1080,100,cLogo,450,70)
	oPrint:Say  (1080,567,aDadosBanco[1]+'-0'                                   							,oFont24)
ElseIf (MV_PAR05 == '399')
	oPrint:SayBitmap(1080,100,cLogo,450,70)
	oPrint:Say  (1080,567,aDadosBanco[1]+'-9'																,oFont24)
ElseIf MV_PAR05 == "237"
	oPrint:SayBitmap(1085,100,cLogo,400,80)
	oPrint:Say (1085,567,aDadosBanco[1]+'-2',oFont24)
ElseIf (MV_PAR05 == '033')
	oPrint:SayBitmap(1080,130,cLogo,300,100)
	oPrint:Say  (1080,567,aDadosBanco[1]+'-7',oFont24)	
Else
	//oPrint:Say  (1080,100,aDadosBanco[2]                                    								,oFont24)
	oPrint:SayBitmap(1080,100,cLogo,450,70)
	oPrint:Say  (1080,567,aDadosBanco[1]+'-9'	                                   							,oFont24)
EndIf
oPrint:Say  (1100,820,CB_RN_NN[2]                                      									,oFont14)

//Linhas Horizontais
oPrint:Line (1250,1900,1250,2300 )
oPrint:Line (1275/*1320*/,100,1275/*1320*/,1900/*2300*/)
oPrint:Line (1320,1900,1320,2300 )
oPrint:Line (1390,100,1390,2300 )
oPrint:Line (1455,100,1455,2300 )
oPrint:Line (1520,100,1520,2300 )

//Linhas Verticais
oPrint:Line (1390,500,1520,500)
oPrint:Line (1455,750,1520,750)
oPrint:Line (1390,1000,1520,1000)
oPrint:Line (1275/*1320*/,1350,1455,1350)
oPrint:Line (1390,1550,1520,1550)

oPrint:Say  (1180,100 ,"Local de Pagamento"                             								,oFont8)
oPrint:Say  (1180,400 ,cMsg1                                            								,oFont10)
oPrint:Say  (1210,400 ,cMsg2                                            								,oFont10)
oPrint:Say  (1250,400 ,cMsg3                                            								,oFont10)
oPrint:Say  (1180,1910,"Vencimento"                                     								,oFont8)
oPrint:Say  (1205,2010,dtoc(aDadosTit[4])                         										,oFont10)

oPrint:Say  (1250,1910,"Agência/Código Beneficiário" ,oFont8)
If MV_PAR05 == '104'
	oPrint:Say  (1275,1950,ALLTRIM(aDadosBanco[3])+'/'+ALLTRIM(aDadosBanco[7]),oFont10)//Agencia(SA6) + Cod.Empresa(SEE)
ElseIf MV_PAR05 == '033'
	oPrint:Say  (1275,1950,ALLTRIM(aDadosBanco[3])+'/'+cCodBen33,oFont10)
Else
	oPrint:Say  (1275,1950,ALLTRIM(aDadosBanco[3]+"-"+cDVAge)+' / '+ALLTRIM(aDadosBanco[4])+IIF(xDac <> '','-' + xDac,''),oFont10)//Agencia+Conta (SA6)
EndIf

oPrint:Say  (1275/*1320*/,100 ,"Beneficiário",oFont8)
oPrint:Say  (1310/*1345*/,100 ,aDadosEmp[1],oFont10)
oPrint:Say  (1345/*1345*/,100 ,aDadosEmp[2] +" "+ AllTrim(aDadosEmp[3]) +" "+ aDadosEmp[4],oFont10)

oPrint:Say  (1275/*1320*/,1355,"CNPJ/CPF",oFont8)
oPrint:Say  (1310/*1345*/,1455,aDadosEmp[6],oFont10)

oPrint:Say  (1320,1910,"Nosso Número"                                   								,oFont8)
IF (MV_PAR05=='104')
	oPrint:Say  (1345,1950,LEFT(_cNN,2)+'/'+SUBS(_cNN,3,LEN(_cNN)-3)+'-'+RIGHT(_cNN,1)					,oFont10)
ElseIF(MV_PAR05=='399' .AND. _CMV_PAR10 == 1 )
	oPrint:Say  (1345,1950,SUBS(_cNN,1,LEN(_cNN)-1)+'-'+RIGHT(_cNN,1)									,oFont10)
ElseIF(MV_PAR05=='399' .AND. _CMV_PAR10 <> 1 )
	oPrint:Say  (1345,1950,SUBS(_cNN,1,LEN(_cNN)-3)+'-'+RIGHT(_cNN,3)									,oFont10)
ElseIf MV_PAR05 == "237"
	oPrint:Say  (1345,1950,xCarteira +"/"+ SubStr(_cNN,1,11) +"-"+ Right(_cNN,1),oFont10)    
ElseIf MV_PAR05 == "033"
	oPrint:Say  (1345,1950,_cE1Numbco,oFont10) 	            
Else
	oPrint:Say  (1345,1950,"3097391"+_cNN															    ,oFont10)
EndIf

oPrint:Say  (1390,100 ,"Data do Documento"                              								,oFont8)
oPrint:Say  (1415,100 ,DTOC(aDadosTit[3])                               								,oFont10)

oPrint:Say  (1390,505 ,"Número do Documento"                            								,oFont8)
oPrint:Say  (1415,605 ,aDadosTit[1]                                     								,oFont10)

oPrint:Say  (1390,1005,"Espécie"                                        								,oFont8)
oPrint:Say  (1415,1105,"DM"                                             								,oFont10)

oPrint:Say  (1390,1355,"Aceite"                                         								,oFont8)
oPrint:Say  (1415,1455,"NAO"                                           								 	,oFont10)

oPrint:Say  (1390,1555,"Data do Processamento"                          								,oFont8)
oPrint:Say  (1415,1655,dtoc(aDadosTit[2])                               								,oFont10)

oPrint:Say  (1390,1910,"(=)Valor do Documento"                          								,oFont8)
oPrint:Say  (1415,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) 							,oFont10)

oPrint:Say  (1455,100 ,"Data de Operação"  																,oFont8)
oPrint:Say  (1480,150,DTOC(aDadosTit[2] )  ,oFont10)

oPrint:Say  (1455,505 ,"Carteira"                                       								,oFont8)
oPrint:Say  (1480,555 ,xCarteira                                        								,oFont10)

oPrint:Say  (1455,755 ,"Espécie Moeda"                                  								,oFont8)
oPrint:Say  (1480,805 ,"R$"                                             								,oFont10)

oPrint:Say  (1455,1005,"Quant. Moeda"                                   								,oFont8)
oPrint:Say  (1455,1555,"Valor da Moeda"                                 								,oFont8)

oPrint:Say  (1520,100 ,"Instruções (Todas informações deste boleto são de exclusiva responsabilidade do beneficiário.)" ,oFont8)
oPrint:Say  (1550,150 ,aBolText[1]                                      								,oFont10)
oPrint:Say  (1600,150 ,aBolText[2]                                      								,oFont10)
oPrint:Say  (1650,150 ,aBolText[3]                                      								,oFont10)
oPrint:Say  (1700,150 ,aBolText[4]                                      								,oFont10)

oPrint:Say  (1455,1910,"(-)Desconto"                                    								,oFont8)
oPrint:Say  (1520,1910,"(-)Outras Deduções/Abatimento"                  								,oFont8)
oPrint:Say  (1590,1910,"(+)Mora/Multa/Juros"                                  								,oFont8)
oPrint:Say  (1660,1910,"(+)Outros Acréscimos"                           								,oFont8)
oPrint:Say  (1730,1910,"(=)Valor Cobrado"                               								,oFont8)

oPrint:Say  (1800,100 ,"Pagador"                                         								,oFont8)
oPrint:Say  (1800,400 ,aDatSacado[1]                                    								,oFont9)
oPrint:Say  (1898,1700,"CNPJ/CPF - "+ IIF(Len(AllTrim(aDatSacado[7])) == 11,Transform(aDatSacado[7],"@R 999.999.999-99"), Transform(aDatSacado[7],"@R 99.999.999/9999-99")),oFont9)

oPrint:Say  (1848,400 ,aDatSacado[3]                                    								,oFont9)
oPrint:Say  (1898,400 ,aDatSacado[4]+' - '+aDatSacado[5]+' CEP '+aDatSacado[6] 							,oFont9)

//oPrint:Say  (1848,1910,_cNN),oFont9)

oPrint:Say  (1952,100 ,"Sacador/Avalista"                               								,oFont8)
oPrint:Say  (1945,400 ,aDadosEmp[1]                               										,oFont9)

//oPrint:Say  (1952,2000 ,"Código de Baixa"                               								,oFont8)

oPrint:Say  (1992,1620,"Autenticação Mecânica - FICHA DE COMPENSAÇÃO"                                   ,oFont8)

oPrint:Line (1180,1900,1800,1900 )
oPrint:Line (1590,1900,1590,2300 )
oPrint:Line (1660,1900,1660,2300 )
oPrint:Line (1730,1900,1730,2300 )
oPrint:Line (1800,100,1800,2300 )

If (MV_PAR05 <> '104')
	oPrint:Line (1987,100,1987,2300  )
	
	//Gambiarra, descobrir como mudar tipo da linha.
	For i := 100 to 2300 step 50
		oPrint:Line(2213, i, 2213, i+30)
	Next i
	
	/*----------------------------------------------/
	/	Terceira Via								/
	/----------------------------------------------*/
	oPrint:Line (2363,100,2363,2300)
	oPrint:Line (2363,550,2263,550 )
	oPrint:Line (2363,800,2263,800 )
	
	
	If (MV_PAR05 == '399')
		oPrint:SayBitmap(2263,100,cLogo,450,70)
		oPrint:Say  (2263,567,aDadosBanco[1]+'-9',oFont24)
	ElseIf MV_PAR05 == "237"
		oPrint:SayBitmap(2265,100,cLogo,400,80)
		oPrint:Say (2265,567,aDadosBanco[1]+'-2',oFont24)
	ElseIf (MV_PAR05 == '033')
		oPrint:SayBitmap(2263,120,cLogo,300,100)
		oPrint:Say (2265,567,aDadosBanco[1]+'-7',oFont24)			
	Else
		//oPrint:Say  (2263,100,aDadosBanco[2],oFont24)
		oPrint:SayBitmap(2263,130,cLogo,450,70)
		oPrint:Say  (2263,567,aDadosBanco[1]+'-9',oFont24)
	EndIf
	oPrint:Say  (2263,820,CB_RN_NN[2],oFont14)
	
	//Linhas Horizontais
	oPrint:Line (2433,1900,2433,2300 )
	oPrint:Line (2458/*2503*/,100,2458/*2503*/,1900/*2300*/)
	oPrint:Line (2503,1900,2503,2300)
	oPrint:Line (2573,1900,2573,2300)
	oPrint:Line (2573,100,2573,2300 )
	oPrint:Line (2638,100,2638,2300 )
	oPrint:Line (2703,100,2703,2300 )

	//Linhas Verticais	
	oPrint:Line (2573,500,2703,500)
	oPrint:Line (2638,750,2703,750)
	oPrint:Line (2573,1000,2703,1000)
	oPrint:Line (2458/*2503*/,1350,2638,1350)
	oPrint:Line (2573,1550,2703,1550)
	
	oPrint:Say  (2363,100 ,"Local de Pagamento"                             								,oFont8)
	oPrint:Say  (2363,400 ,cMsg1 ,oFont10)
	oPrint:Say  (2395,400 ,cMsg2 ,oFont10)
	oPrint:Say  (2435,400 ,cMsg3 ,oFont10)
	oPrint:Say  (2363,1910,"Vencimento"                                     								,oFont8)
	oPrint:Say  (2388,2010,dtoc(aDadosTit[4])                               								,oFont10)
	
	
	oPrint:Say  (2433,1910,"Agência/Código Beneficiário"                         								,oFont8)
	If MV_PAR05 == '033'
		oPrint:Say  (2458,1950,ALLTRIM(aDadosBanco[3])+'/'+cCodBen33,oFont10)
	Else
		oPrint:Say  (2458,1950,ALLTRIM(aDadosBanco[3]+"-"+cDVAge)+' / '+ALLTRIM(aDadosBanco[4])+IIF(xDac <> '','-' + xDac,''),oFont10)
	END

	oPrint:Say  (2458/*2503*/,100 ,"Beneficiário",oFont8)
	oPrint:Say  (2493/*2528*/,100 ,aDadosEmp[1],oFont10)
	oPrint:Say  (2528,100 ,aDadosEmp[2] +" "+ AllTrim(aDadosEmp[3]) +" "+ aDadosEmp[4],oFont10)
		
	oPrint:Say  (2458/*2503*/,1355,"CNPJ/CPF",oFont8)
	oPrint:Say  (2493/*2528*/,1455,aDadosEmp[6],oFont10)
	
	oPrint:Say  (2503,1910,"Nosso Número"                                 									,oFont8)
	IF (MV_PAR05=='104')
		oPrint:Say  (2528,1950,LEFT(_cNN,2)+'/'+SUBS(_cNN,3,LEN(_cNN)-3)+'-'+RIGHT(_cNN,1)					,oFont10)
	ElseIF(MV_PAR05=='399' .AND. _CMV_PAR10 == 1 )
		oPrint:Say  (2528,1950,SUBS(_cNN,1,LEN(_cNN)-1)+'-'+RIGHT(_cNN,1)									,oFont10)
	ElseIF(MV_PAR05=='399' .AND. _CMV_PAR10 <> 1 )
		oPrint:Say  (2528,1950,SUBS(_cNN,1,LEN(_cNN)-3)+'-'+RIGHT(_cNN,3)									,oFont10)
	ElseIf MV_PAR05 == "237"
		oPrint:Say  (2528,1950,xCarteira +"/"+ SubStr(_cNN,1,11) +"-"+ Right(_cNN,1),oFont10)
	ElseIf MV_PAR05 == "033"
		oPrint:Say  (2528,1950,_cE1Numbco,oFont10) 		                                
	Else
		oPrint:Say  (2528,1950,"3097391"+_cNN															    ,oFont10)
	EndIf
	
	oPrint:Say  (2573,100 ,"Data do Documento"                            									,oFont8)
	oPrint:Say  (2598,100 ,DTOC(aDadosTit[3])                             									,oFont10)
	
	oPrint:Say  (2573,505 ,"Número do Documento"                          									,oFont8)
	oPrint:Say  (2598,605 ,aDadosTit[1]                                   									,oFont10)
	
	oPrint:Say  (2573,1005,"Espécie"                                      									,oFont8)
	oPrint:Say  (2598,1105,"DM"                                           									,oFont10)
	
	oPrint:Say  (2573,1355,"Aceite"                                       									,oFont8)
	oPrint:Say  (2598,1455,"NAO"                                          									,oFont10)
	
	oPrint:Say  (2573,1555,"Data do Processamento"                        									,oFont8)
	oPrint:Say  (2598,1655,dtoc(aDadosTit[2])                       										,oFont10)
	
	oPrint:Say  (2573,1910,"(=)Valor do Documento"                        									,oFont8)
	oPrint:Say  (2598,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) 							,oFont10)
	
	oPrint:Say  (2638,100 ,"Uso do Banco"                             										,oFont8)
	oPrint:Say  (2663,150 ," "     		                            										,oFont10)
	
	oPrint:Say  (2638,505 ,"Carteira"                                       								,oFont8)
	oPrint:Say  (2663,555 ,xCarteira                                        								,oFont10)
	
	oPrint:Say  (2638,755 ,"Espécie Moeda"                                  								,oFont8)
	oPrint:Say  (2663,805 ,"R$"                                             								,oFont10)
	
	oPrint:Say  (2638,1005,"Quant. Moeda"                                   								,oFont8)
	oPrint:Say  (2638,1555,"Valor da Moeda"                                 								,oFont8)
	
	oPrint:Say  (2703,100 ,"Instruções (Todas informações deste boleto são de exclusiva responsabilidade do beneficiário.)" ,oFont8)
	oPrint:Say  (2733,150 ,aBolText[1]                                      								,oFont10)
	oPrint:Say  (2773,150 ,aBolText[2]                                      								,oFont10)
	oPrint:Say  (2823,150 ,aBolText[3]                                      								,oFont10)
	oPrint:Say  (2873,150 ,aBolText[4]                                      								,oFont10)
	
	oPrint:Say  (2638,1910,"(-)Desconto"                                    								,oFont8)
	oPrint:Say  (2703,1910,"(-)Outras Deduções/Abatimento"                  								,oFont8)
	oPrint:Say  (2773,1910,"(+)Mora/Multa/Juros"                                  								,oFont8)
	oPrint:Say  (2843,1910,"(+)Outros Acréscimos"                           								,oFont8)
	oPrint:Say  (2913,1910,"(=)Valor Cobrado"                               								,oFont8)
	
	oPrint:Say  (2983,100 ,"Pagador"                                         								,oFont8)
	oPrint:Say  (2983,400 ,aDatSacado[1]                                    								,oFont9)
	oPrint:Say  (3081,1700,"CNPJ/CPF - "+ IIF(Len(AllTrim(aDatSacado[7])) == 11,Transform(aDatSacado[7],"@R 999.999.999-99"), Transform(aDatSacado[7],"@R 99.999.999/9999-99")),oFont9)
	
	oPrint:Say  (3031,400 ,aDatSacado[3]                                    								,oFont9)
	oPrint:Say  (3081,400 ,aDatSacado[4]+' - '+aDatSacado[5]+' CEP '+aDatSacado[6] 							,oFont9)
	
	//oPrint:Say  (3031,1910,_cNN,oFont9)
	
	oPrint:Say  (3133,100 ,"Sacador/Avalista"                               								,oFont8)
	oPrint:Say  (3133,400 ,aDadosEmp[1]                               										,oFont9)
	
	//oPrint:Say  (3133,2000 ,"Código de Baixa"                               								,oFont8)
	
	oPrint:Say  (3172,1400,"Autenticação Mecânica - Ficha de Compensação"   								,oFont8)
	
	oPrint:Line (2363,1900,2983,1900 )
	oPrint:Line (2773,1900,2773,2300 )
	oPrint:Line (2843,1900,2843,2300 )
	oPrint:Line (2913,1900,2913,2300 )
	oPrint:Line (2983,100,2983,2300 )
	
	oPrint:Line (3167,100,3167,2300  )
EndIf
/*Parametros:
01 cTypeBar String com o tipo do codigo de barras: "EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128", "INT25","MAT25,"IND25","CODABAR","CODE3_9"
02 nRow       Numero da Linha em centimentros
03 nCol       Numero da coluna em centimentros
04 cCode      String com o conteudo do codigo
05 oPr        Obejcto Printer
06 lcheck     Se calcula o digito de controle
07 Cor        Numero da Cor, utilize a "common.ch"
08 lHort      Se imprime na Horizontal
09 nWidth     Numero do Tamanho da barra em centimetros
10 nHeigth    Numero da Altura da barra em milimetros
11 lBanner    Se imprime o linha em baixo do codigo
12 cFont      String com o tipo de fonte
13 cMode      String com o modo do codigo de barras CODE128
*/
If (MV_PAR05 == '104')
	MSBAR("INT25",17.3,1.6,CB_RN_NN[1],oPrint,.F.,,,,1.8,,,,.F.)    // IMPressao em Jato de Tinta HP 660
Else
	MSBAR("INT25",27.4,1.6,CB_RN_NN[1],oPrint,.F.,,,,1.8,,,,.F.)    // IMPressao em Jato de Tinta HP 660
EndIf

oPrint:EndPage() // Finaliza a página

Return Nil

/*
+---------------------------------------------------------------------------+
!	Modulos 10 e 11			                                                !
+---------------------------------------------------------------------------+
*/
Static Function Modulo10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
WHILE L > 0
	P := VAL(SUBSTR(cData, L, 1))
	IF (B)
		P := P * 2
		IF P > 9
			P := P - 9
		ENDIF
	ENDIF
	D := D + P
	L := L - 1
	B := !B
ENDDO
D := 10 - (Mod(D,10))
IF D = 10
	D := 0
ENDIF
RETURN(D)
/**/
Static Function Modulo11(cData)
LOCAL L, D, P := 0
L := LEN(cdata)
D := 0
P := 1
WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	IF P = 9
		P := 1
	ENDIF
	L := L - 1
ENDDO
D := 11 - (mod(D,11))
IF (D == 0 .Or. D == 1 .Or. D > 9)
	D := 1
ENDIF
RETURN(D)
/**/

Static Function Mod11NN(cData)

LOCAL L, D, P := 0
L := LEN(cdata)
D := 0
P := 1

WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	
	IF (_CMV_PAR10 == 1 .AND. MV_PAR05 == '399') //Apenas para HSBC - Cob. Registrada
		IF(P = 7)
			P := 1
		ENDIF
	ELSE  //Demais bancos
		IF (P = 9)
			P := 1
		ENDIF
	ENDIF
	L := L - 1
ENDDO
D := 11 - (mod(D,11))
IF (_CMV_PAR10 == 1 .AND. MV_PAR05 == '399') //Apenas para HSBC - Cob. Registrada
	IF(D == 0 .OR. D == 1 .OR. D > 9)
		D := 0
	ENDIF
ELSE
	IF (D > 9)
		D := 0
	ENDIF
ENDIF

Return D


Static Function Modulo11NN(cData)

Local nL, nD, nP := 0
nL := Len(cData)
nD := 0
nP := 1

While nL > 0
	nP := nP + 1
	nD := nD + (Val(SubStr(cData, nL, 1)) * nP)
	
	If nP == 7
		nP := 1
	EndIf
	
	nL := nL - 1
End

nD := 11 - (Mod(nD,11))

If nD == 10
	cDv := "P"
ElseIf nD > 10
	cDv := "0"
Else
	cDv := Str(nD)	
EndIf

Return cDv


/*
+---------------------------------------------------------------------------+
!	Retorna os strings para impressão do Boleto                             !
+---------------------------------------------------------------------------+
*/
//--------------------->	ITAU	<---------------------------------------//
//CB = String para o cód.barras, RN = String com o número digitável
//Cobrança não identificada, número do boleto = Título + Parcela
//                             1     2      3       4         5       6      7         8      9
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cCarteira,cNroDoc,nValor,cCodBanco,dVencto,cPref)

//LOCAL bldocnufinal := STRZERO(VAL(cNroDoc),8)
LOCAL blvalorfinal := STRZERO(nValor*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
//LOCAL dvcc 		   := 0
LOCAL dvcl         := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL CC	       := ''
LOCAL CL	       := ''
//LOCAL DJ	       := ''
LOCAL s            := ''
LOCAL _nFator      := dVencto - If(dVencto >= Ctod('22/02/25'),CtoD('29/05/22'),CtoD("07/10/97"))
LOCAL _nFator2     := dVencto - CTOD("03/07/2000")
LOCAL _cCart	   := ''
LOCAL _cConta	   := ''

//Local cCodBar   := ""
//Local cLinDig   := ""
//Local cNossoNum := ""
//Local cDigVer   := ""
//Local cAux      := ""   
//LOCAL NNB       := ""

//------------------> Dados Conta <-------------------------------------
If MV_PAR05 == '341'
	_cCart	   := '109'
	_cConta	   := PADL(ALLTRIM(STRTRAN(cConta,"-","")),6,"0")
ElseIf MV_PAR05 == "237"
	_cCart := "09"
ElseIf MV_PAR05 == '399'
	_cCart	   := '00'
	_cConta	   := PADL(ALLTRIM(STRTRAN(cConta,"-","")),7,"0")
ElseIf MV_PAR05 == '001'
	_cCart	   := '17'
ElseIf MV_PAR05 == '033'
	_cCart	   := '101'	
	_cConta	   := PADL(ALLTRIM(STRTRAN(cConta,"-","")),9,"0")	
Else
	_cConta	   := PADL(ALLTRIM(STRTRAN(cConta,"-","")),10,"0")
EndIf

//------------------> NOSSO NUMERO <-------------------------------------
cNTit := TRA->E1_PREFIXO+TRA->E1_NUM+TRA->E1_PARCELA+TRA->E1_TIPO

SEE->(DBSelectArea('SEE'))
SEE->(DBSEEK(xFilial('SEE')+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08))
SE1->(DBGoTop())

If SE1->(MSSeek(xFilial("SE1")+cNTit))
	
	If (MV_PAR05 == '399')//HSBC - Cob. Registrada (Tam.10)
		NN := NNHsbc()
	ElseIf (MV_PAR05 == '341')
		NN := NNItau()
	ElseIf (MV_PAR05 == '104')
		NN := NNCef()
		CC := PADL(ALLTRIM(STRTRAN(SEE->EE_CODEMP,"-","")),7,"0")
	ElseIf (MV_PAR05 == "237")
		NN := NN237()  
	ElseIf (MV_PAR05 == "001")
		NN := NN001()  
	ElseIf (MV_PAR05 == "033")
		NN := NN033() 
	EndIf
	
EndIf

If (MV_PAR05 == "033")

	//Constroi a linha digitável
	banco := "033"
	
	//1o Bloco
	_cDigNNum	:=	u_digMod11(Substr(SE1->E1_NUMBCO,1,12)) // Digito verificador do nosso numero para cobrança santander
	_cE1Numbco	:=	alltrim(substr(SE1->E1_NUMBCO,1,12))+ _cDigNNum
	
	cLinha1:=banco + '99' + Substr(SEE->EE_CODEMP,1,4)
	cLinha1+=DigitoBol(cLinha1)
	cLinha1:=SubStr(cLinha1,1,5)+"."+SubStr(cLinha1,6,len(cLinha1)) + "  "
	
	//2o Bloco
	cLinha2:=substr(Substr(SEE->EE_CODEMP,5,len(SEE->EE_CODEMP)),1,3) +	substr(_cE1Numbco,1,7)
	cLinha2+=DigitoBol(cLinha2)
	cLinha2:=SubStr(cLinha2,1,5)+"."+SubStr(cLinha2,6,len(cLinha2)) + "  "
	
	//3o Bloco
	cLinha3:=alltrim(SubStr(_cE1Numbco,8,len(_cE1Numbco))) + "0" + _cCart
	cLinha3+=DigitoBol(cLinha3)
	cLinha3:=alltrim(SubStr(cLinha3,1,5))+"."+alltrim(SubStr(cLinha3,6,len(cLinha3))) + "  "
	
	//Montagem do valor liquido para o boleto (Vinicius SMS em 02/06/2014)
	nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nVlrDoc	 := Round((((SE1->E1_SALDO+SE1->E1_ACRESC)-SE1->E1_DECRESC)*100)-(nVlrAbat*100),0)/100
	
	//4o Bloco (digitao)
	cDigitao := DigBar(banco+'9'+ Str(_nFator,4) + StrZero((nVlrDoc)*100,10) + "9" + Substr(SEE->EE_CODEMP,1,7) + _cE1Numbco + "0" + _cCart)
	
	//5o Bloco
	cLinha4:=alltrim(Str(_nFator,4)) + StrZero((nVlrDoc)*100,10)

	RN := cLinha1 + cLinha2 + cLinha3 + cDigitao + "  " + cLinha4

	//Prepara Cod. de Barras
	CB := banco+'9'+ cDigitao + Str(_nFator,4) + StrZero((nVlrDoc)*100,10) + "9" + Substr(SEE->EE_CODEMP,1,7) + _cE1Numbco + "0" + _cCart

End

/*---------------------------------------------------------------------------------------------
|                                                                                             |
------------------------>		HSBC	<------------------------------------------------------*/
If (MV_PAR05 == '399')
	//Calcula DV do Nosso Numero
	//dvnn := Mod11NN(NN)
	//NN   := SubStr(NN,1,10) + Alltrim(Str(dvnn))
	NN   := SubStr(NN,1,11)
	//Definicao do CODIGO DE BARRAS
	s := cBanco + Alltrim(Str(_nFator2)) + blvalorfinal + SubStr(NN,1,11) + SubStr(AllTrim(cAgencia),1,4) + SubStr(_cConta,1,7) + '001'
	dvcb := modulo11(s)
	CB := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s, 5, 39)
	
	//LINHA DIGITAVEL (Representacao Numerica Cod. Barra)
	//	CAMPO 1:
	//	AAA = Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//DDDDD = Cinco primeiros digitos no nosso numero
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := cBanco + SUBSTR(NN,1,5)
	dv   := modulo10(s)
	RN   := SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 4) + AllTrim(Str(dv)) + '  '
	//	CAMPO 2:
	//	DDDDDD = Restante do Nosso Numero
	//    AAAA = Cod. Agencia
	//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := SUBSTR(NN,6,6) + SUBSTR(cAgencia,1,4)
	dv   := modulo10(s)
	RN   := RN + SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//	CAMPO 3:
	// GGGGGGG = Numero da Conta + DAC da mesma
	//	   HH  = Zeros (Nao utilizado)
	//       C = Cod. Aplicativo = 1
	//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := _cConta + '001'
	dv   := modulo10(s)
	RN   := RN + SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	RN   := RN + AllTrim(Str(dvcb)) + '  '
	//*	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	RN   := RN + Alltrim(Str(_nFator2)) + blvalorfinal
	
	/*---------------------------------------------------------------------------------------------
	|                                                                                             |
	---------------------------------> ITAU <----------------------------------------------------*/
ElseIf (MV_PAR05 == '341')
	//Calcula DV do Nosso Numero
	s:= AllTrim(cAgencia) + SubStr(alltrim(_cConta),1,5) + _cCart + SubStr(alltrim(NN),1,8)
	dvnn := modulo10(s)
	//Definicao do CODIGO DE BARRAS
	s := cBanco + Alltrim(Str(_nFator)) + blvalorfinal + _cCart + SubStr(alltrim(NN),1,8)+Alltrim(Str(dvnn)) +AllTrim(cAgencia) + _cConta + '000'
	dvcb := modulo11(s)
	CB := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s, 5, 39)
	
	//LINHA DIGITAVEL (Representacao Numerica Cod. Barra)
	//	CAMPO 1:
	//	AAA = Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//	CCC = Codigo da Carteira de Cobranca
	//	 DD = Dois primeiros digitos no nosso numero
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := cBanco + _cCart + SUBSTR(NN,1,2)
	dv   := modulo10(s)
	RN   := SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 4) + AllTrim(Str(dv)) + '  '
	//	CAMPO 2:
	//	DDDDDD = Restante do Nosso Numero
	//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
	//	   FFF = Tres primeiros numeros que identificam a agencia
	//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := SUBSTR(NN,3,6) + Alltrim(Str(dvnn)) + SUBSTR(cAgencia, 1, 3)
	dv   := modulo10(s)
	RN   := RN + SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//	CAMPO 3:
	//	     F = Restante do numero que identifica a agencia
	//	GGGGGG = Numero da Conta + DAC da mesma
	//	   HHH = Zeros (Nao utilizado)
	//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := SUBSTR(cAgencia, 4, 1) + _cConta + '000'
	dv   := modulo10(s)
	RN   := RN + SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	RN   := RN + AllTrim(Str(dvcb)) + '  '
	//*	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	RN   := RN + Alltrim(Str(_nFator)) + blvalorfinal

// Banco Bradesco # Implementado em 11/08/2017 dirlei@afsouza
ElseIf (MV_PAR05 == "237")

	// Nosso Número: poderá ser gerado a partir de 00000000001, 00000000002, 11 posições,
	// devendo ser atribuído numero diferenciado para identificação de cada documento na
	// Cobrança Bradesco.
	// Para o cálculo do dígito, será necessário acrescentar o número da carteira à esquerda
	// antes do Nosso Número, e aplicar o módulo 11, com base 7.
	//cAux := NN
	//NN   := _cCart + NN
	//dvNN := Mod11NN(NN) 
	//NN   := cAux + AllTRim(Str(dvNN))

	// Grava E1_NUMBCO
	//RecLock("SE1",.F.)
	//SE1->E1_NUMBCO := NN
	//MsUnlock("SE1")

	/*CAMPO LIVRE*:
	20 a 23  4 Agência Beneficiária (Sem o digito verificador, completar com zeros a esquerda quando necessário)
	24 a 25  2 Carteira
	26 a 36 11 Número do Nosso Número (Sem o digito verificador)
	37 a 43  7 Conta do Beneficiário (Sem o digito verificador, completar com zeros a esquerda quando necessário)
	44 a 44	 1 Zero
	*/
	CL := StrZero(Val(cAgencia),4) + cCarteira + Left(NN,11) + SubStr(cConta,1,7) + "0"
	
	/*Definicao do CODIGO DE BARRAS
	01 a 03  3 Identificação do Banco
	04 a 04  1 Código da Moeda (Real = 9, Outras=0)
	05 a 05  3 Dígito verificador do Código de Barras
	06 a 09  4 Fator de Vencimento
	10 a 19 10 Valor
	*/	
	s    := cBanco + AllTrim(Str(_nFator)) + blvalorfinal + CL
	dvCB := Modulo11(s)
	CB   := SubStr(s, 1, 4) + AllTrim(Str(dvCB)) + SubStr(s, 5)
	
	//LINHA DIGITAVEL (Representacao Numerica Cod. Barra)
	//	CAMPO 1:
	//	AAA = Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//XXXXX = 1ª parte do Campo Livre = 5 primeiras posições
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s  := cBanco + SubStr(CL,1,5)
	dv := Modulo10(s)
	RN := SubStr(s, 1, 5) +"."+ SubStr(s, 6, 4) + AllTrim(Str(dv)) +"  "

	//	CAMPO 2:
	//XXXXXXXXXX = 2ª parte do Campo Livre = da 6a. a 15a. posição
	//	       Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s  := SubStr(CL,6,10)
	dv := Modulo10(s)
	RN := RN + SubStr(s, 1, 5) +"."+ SubStr(s, 6, 5) + AllTrim(Str(dv)) +"  "

	//	CAMPO 3:
	//XXXXXXXXXX = 3ª parte do Campo Livre = 16a. a 25a. posição 
	//        D2 = Dígito Verificador do Campo Livre
	//	       Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s  := SubStr(CL,16,10)
	dv := Modulo10(s)
	RN := RN + SubStr(s, 1, 5) +"."+ SubStr(s, 6, 5) + AllTrim(Str(dv)) +"  "

	//	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	RN := RN + AllTrim(Str(dvcb)) +"  "

	//*	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	RN := RN + AllTrim(Str(_nFator)) + blvalorfina
	
ElseIf (MV_PAR05 == "001")
	
		// Nosso Número: poderá ser gerado a partir de 00000000001, 00000000002, 11 posições,
	// devendo ser atribuído numero diferenciado para identificação de cada documento na
	// Cobrança Bradesco.
	// Para o cálculo do dígito, será necessário acrescentar o número da carteira à esquerda
	// antes do Nosso Número, e aplicar o módulo 11, com base 7.
	//cAux := NN
	//NN   := _cCart + NN
	//dvNN := Mod11NN(NN) 
	//NN   := cAux + AllTRim(Str(dvNN))

	// Grava E1_NUMBCO
	//RecLock("SE1",.F.)
	//SE1->E1_NUMBCO := NN
	//MsUnlock("SE1")

	/*CAMPO LIVRE*:
	20 a 23  4 Agência Beneficiária (Sem o digito verificador, completar com zeros a esquerda quando necessário)
	24 a 25  2 Carteira
	26 a 36 11 Número do Nosso Número (Sem o digito verificador)
	37 a 43  7 Conta do Beneficiário (Sem o digito verificador, completar com zeros a esquerda quando necessário)
	44 a 44	 1 Zero
	*/
   //	CL := StrZero(Val(cAgencia),4) + cCarteira + Left(NN,11) + SubStr(cConta,1,7) + "0"  
	CL := "0000003097391" + AllTrim(NN)+ "17"
	
	/*Definicao do CODIGO DE BARRAS
	01 a 03  3 Identificação do Banco
	04 a 04  1 Código da Moeda (Real = 9, Outras=0)
	05 a 05  3 Dígito verificador do Código de Barras
	06 a 09  4 Fator de Vencimento
	10 a 19 10 Valor
	*/	
	s    := cBanco + AllTrim(Str(_nFator)) + blvalorfinal + CL
	dvCB := Modulo11(s)
	CB   := SubStr(s, 1, 4) + AllTrim(Str(dvCB)) + SubStr(s, 5)

	//LINHA DIGITAVEL (Representacao Numerica Cod. Barra)
	//	CAMPO 1:
	//	AAA = Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//XXXXX = 1ª parte do Campo Livre = 5 primeiras posições
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s  := cBanco + SubStr(CL,1,5)
	dv := Modulo10(s)
	RN := SubStr(s, 1, 5) +"."+ SubStr(s, 6, 4) + AllTrim(Str(dv)) +"  "

	//	CAMPO 2:
	//XXXXXXXXXX = 2ª parte do Campo Livre = da 6a. a 15a. posição
	//	       Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s  := SubStr(CL,6,10)
	dv := Modulo10(s)
	RN := RN + SubStr(s, 1, 5) +"."+ SubStr(s, 6, 5) + AllTrim(Str(dv)) +"  "

	//	CAMPO 3:
	//XXXXXXXXXX = 3ª parte do Campo Livre = 16a. a 25a. posição 
	//        D2 = Dígito Verificador do Campo Livre
	//	       Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s  := SubStr(CL,16,10)
	dv := Modulo10(s)
	RN := RN + SubStr(s, 1, 5) +"."+ SubStr(s, 6, 5) + AllTrim(Str(dv)) +"  "

	//	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	RN := RN + AllTrim(Str(dvcb)) +"  "

	//*	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	RN := RN + AllTrim(Str(_nFator)) + blvalorfinal
	
	
	/*Definicao do CODIGO DE BARRAS
	01 a 03  3 Identificação do Banco
	04 a 04  1 Código da Moeda (Real = 9, Outras=0)
	05 a 05  3 Dígito verificador do Código de Barras
	06 a 09  4 Fator de Vencimento
	10 a 19 10 Valor
	
	/*		Código de barras:
	//CB = String para o cód.barras, RN = String com o número digitável
	
00199755200000558643007170000000000313146880
				   3007170000000
0019dVVVV$$$$$$$$$$000000CCCCCCCnnnnnnnnnncc

	convenio:3097391
	Linha digitável

	00193.00714  70000.000003  03131.468807  9  75520000055864
	00190.0000d  0CCCC.CCCnnd  nnnnn.nnnccd  D  VVVV$$$$$$$$$$

	Onde:

	C: Número do convênio     n: Nosso número (numeração livre)
	D: Dv geral               d: dígito verificador
	c: Carteira               a: Agência
	$: valor                  V: fator de vencimento
	&: Conta corrente
	*/
	
	
	/*---------------------------------------------------------------------------------------------
	|                                                                                             |
	------------------------>		CEF 	<------------------------------------------------------*/
ElseIf (MV_PAR05 == '104')
	/*NOSSO NÚMERO*:
	- O Nosso Número no SIGCB é composto de 17 posições, sendo as 02 posições iniciais para identificar a
	Carteira e as 15 posições restantes são para livre utilização pelo Cedente.
	- Formato: XY NNNNNNNNNNNNNNN -D, onde:
	X Modalidade/Carteira de Cobrança (1-Registrada/2-Sem Registro)
	Y Emissão do bloqueto (4-Cedente)
	NNNNNNNNNNNNNNN Nosso Número (15 posições livres do Cedente)
	D *Dígito Verificador
	* Dígito Verificador do Nosso Número calculado através do Modulo 11*/
	NN   := '14'+SubStr(NN,1,15)
	dvnn := Mod11NN(NN)//Permite zero(0)
	NN   := SubStr(NN,1,17) + Alltrim(Str(dvnn))
	/*CAMPO LIVRE*:
	Código do Cedente e DV do Código do Cedente
	Nosso Número – Seqüência 1 							= 3ª a 5ª posição do Nosso Número
	Tipo de Cobrança (1-Registrada / 2-Sem Registro)	= 1ª posição do Nosso Numero:
	Nosso Número – Seqüência 2 							= 6ª a 8ª posição do Nosso Número
	Identificador da Emissão do Bloqueto (4-Cedente)	= 2ª posição do Nosso Número:
	Nosso Número – Seqüência 3 							= 9ª a 17ª posição do Nosso Número
	DV do Campo Livre
	*/
	CL	 := SUBSTR(CC,1,7) + SUBSTR(NN,3,3) + '1' +SUBSTR(NN,6,3) + '4' + SUBSTR(NN,9,9)
	dvcl := Mod11NN(CL)//Permite zero(0)
	
	//Definicao do CODIGO DE BARRAS
	s := cBanco + Alltrim(Str(_nFator)) + blvalorfinal + SUBSTR(CL,1,24) + AllTrim(Str(dvcl))
	dvcb := modulo11(s)
	CB := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s, 5, 39)
	
	
	//LINHA DIGITAVEL (Representacao Numerica Cod. Barra)
	//	CAMPO 1:
	//	AAA = Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//XXXXX = 1ª parte do Campo Livre
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	//Solicitar CC (Codigo Cedente)
	s    := cBanco + SUBSTR(CL,1,5)
	dv   := modulo10(s)
	RN   := SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 4) + AllTrim(Str(dv)) + '  '
	//	CAMPO 2:
	//XXXXXXXXXX = 2ª parte do Campo Livre
	//	       Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := SUBSTR(CL,6,10)
	dv   := modulo10(s)
	RN   := RN + SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//	CAMPO 3:
	//XXXXXXXXXX = 3ª parte do Campo Livre
	//        D2 = Dígito Verificador do Campo Livre
	//	       Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := SUBSTR(CL,16,9) + AllTrim(Str(dvcl))
	dv   := modulo10(s)
	RN   := RN + SUBSTR(s, 1, 5) + '.' + SUBSTR(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	RN   := RN + AllTrim(Str(dvcb)) + '  '
	//*	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	RN   := RN + Alltrim(Str(_nFator)) + blvalorfinal
	
EndIf

RETURN({CB,RN,NN})

/*
+---------------------------------------------------------------------------+
!	FUNCOES NECESSARIAS PARA GERAR BOLETO	                                !
+---------------------------------------------------------------------------+
*/
//============================== MarkBrowse para a selecao de titulos ==============================//
Static Function SelSE1()
Local aEstr		:= SE1->(DbStruct())

Private cMarca := GetMark(), lInverte := .f.

aCampos := {}

cQyr := pegadados()
Aadd(aEstr, {"OK","C",2,0})
Aadd(aEstr, {"RECNO","N",10,0})

cNomeArq := CriaTrab(aEstr)
dbUseArea(.T.,__LocalDriver,cNomeArq,'TRA',.F.)

oTmp := FWTemporaryTable( ):New( )
oTmp:SetFields(aEstr)
oTmp:AddIndex("01", { "E1_FILIAL", "E1_NUM", "E1_PARCELA"} )
oTmp:Create( )
_cNomeArq:= oTmp:GetAlias( )

Processa({||SqlToTrb(cQyr, aEstr, "TRA")}) // Cria arquivo temporario
//IndRegua ('TRA',cNomeArq,"TRA->E1_FILIAL+TRA->E1_NUM+TRA->E1_PARCELA",,,"Selecionando Registros...")
IndRegua ('TRA',cNomeArq,"E1_FILIAL+E1_NUM+E1_PARCELA",,,"Selecionando Registros...")

aCampos := {}
AADD(aCampos,{"OK",""," "})
AADD(aCampos,{"E1_NUM","","Titulo"})
AADD(aCampos,{"E1_PARCELA","","Parcela"})   // Nao precisa por Picture
AADD(aCampos,{"E1_EMISSAO","","Emissao"})
AADD(aCampos,{"E1_VENCREA","","Vencimento"})
AADD(aCampos,{"E1_CLIENTE","","Cliente"})
AADD(aCampos,{"E1_LOJA","","Loja"})

TRA->(DBSELECTAREA('TRA'))
TRA->(DBGOTOP())
@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"

oMark := MsSelect():New("TRA","OK",,aCampos,@lInverte,@cMarca,{18,3,125,350})
oMark:oBrowse:bHeaderClick := {|oBrw,nCol| marcdesm(oDlg),oMark:oBrowse:SetFocus(),oMark:oBrowse:Refresh()}
AddColMark(oMark,"OK")
@ 15,30 BUTTON "Inverte"  SIZE 33,10 ACTION MarcDesm(oDlg)
@ 15,40 BUTTON "Cancelar" SIZE 33,10 ACTION (Exec := .F.,Close(oDlg))
@ 15,50 BUTTON "Imprimir" SIZE 33,10 ACTION (Exec := .T.,FiltraBol(oDlg))
ACTIVATE DIALOG oDlg CENTERED

Return

//============================== CHAMA A IMPRESSAO DOS BOLETOS ==============================//

Static Function FiltraBol(oDlg)

Processa({|lEnd|MontaRel()})
DbSelectArea("SE1")
Set Filter to
DbCloseArea()
Delete File (cIndexName + ".IDX")
Close(oDlg)
Close(oDlg5)

Return

//============================== BUSCA DADOS DOS TITULOS ==============================//
static Function PegaDados()

If (Select("TRA") <> 0)
	dbSelectArea("TRA")
	dbCloseArea()
Endif

cQry:= "	SELECT " + CRLF
cQry+= "		DISTINCT(SE1.E1_PREFIXO), SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_PARCELA, " + CRLF
cQry+= "		SE1.E1_EMISSAO, SE1.E1_VENCREA, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_SALDO, SE1.E1_VALJUR, SE1.E1_NUMBOR, " + CRLF
cQry+= "		SE1.E1_DECRESC, SE1.E1_ACRESC, SE1.E1_NUMBCO, SE1.E1_TIPO, SE1.E1_IDCNAB " + CRLF
cQry+= "	FROM " + RetSqlName("SE1") + " SE1 " + CRLF
cQry+= "	INNER JOIN " + RetSqlName("SA1") + " SA1 ON " + CRLF
cQry+= "	        SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
cQry+= "	   	AND	SA1.A1_COD = SE1.E1_CLIENTE " + CRLF
cQry+= " 		AND SA1.A1_LOJA = SE1.E1_LOJA " + CRLF
cQry+= "		AND SA1.A1_XIMPBOL = 'S' " + CRLF
//cQry+= "		AND SA1.A1_XBCOBOL <> ' ' " + CRLF
cQry+= "		AND SA1.A1_XBCOBOL = '"+ MV_PAR05 +"' " + CRLF
cQry+= "		AND SA1.D_E_L_E_T_ <> '*' " + CRLF
cQry+= "	WHERE  " + CRLF
cQry+= "			SE1.E1_FILIAL = '"+xFilial("SE1") + "' " + CRLF
cQry+= " 		AND SE1.E1_PREFIXO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
cQry+= " 		AND SE1.E1_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
cQry+= " 		AND SE1.E1_EMISSAO = '" + DtoS(MV_PAR10) + "' " + CRLF
cQry+= " 		AND SE1.E1_EMISSAO <> SE1.E1_VENCTO " + CRLF
//	cQry+= " 		AND SE1.E1_PEDIDO <> ' ' " + CRLF
//cQry+= " 		AND SE1.E1_XFORMA = 'BOL' " + CRLF
If !Empty(MV_PAR09)
	cQry+= "		AND SE1.E1_NUMBOR = '" + MV_PAR09 + "' " + CRLF
	cQry+= "		AND SE1.E1_PORTADO = '" + MV_PAR05 + "' " + CRLF
	cQry+= " 		AND SE1.E1_AGEDEP = '" + MV_PAR06 + "' " + CRLF
	cQry+= "		AND SE1.E1_CONTA = '" + MV_PAR07 + "' " + CRLF
//ElseIf !Empty(AllTrim(MV_PAR05))
//	cQry+= "		AND SE1.E1_PORTADO = '" + MV_PAR05 + "' " + CRLF
EndIf
cQry+= "   		AND SE1.D_E_L_E_T_ <> '*' " + CRLF
cQry+= "	ORDER BY SE1.E1_NUM,SE1.E1_PARCELA " + CRLF

// Mostra query
//Aviso("Query",cQry,{"Ok"},3,,,,.T.)

Return cQry

//============================== INVERTE SELECAO ==============================//

Static Function  MarcDesm(oDlg)
dbSelectArea("TRA")
DBGotop()
WHILE !TRA->(EOF())
	If !Empty(TRA->OK)
		RECLOCK("TRA",.F.)
		TRA->OK := ""
		TRA->(MsUnlock())
	Else
		RECLOCK("TRA",.F.)
		TRA->OK := cMarca
		TRA->(MsUnlock())
	EndIF
	DbSkip()
EndDo

dlgRefresh(oDlg)
dbgotop()
return


//======================== NOSSO NUMERO ===================================//

//----------------> ITAU <--------------------------------------------------
Static Function NNItau(cTitu,lcnab)

LOCAL nNum     := ''
LOCAL aAreaSE1 := SE1->(GetArea())
LOCAL aAreaSEE := SEE->(GetArea())
lCont := .F.
Lconti :=.f.

If lCnab
	If Empty(SE1->E1_NUMBCO)
		lConti:=.t.
	EndIF
EndIF

If  lConti
	nNum:='0'
Else
	IF !Empty(SE1->E1_NUMBCO)
		nNum:=StrZero(Val(SE1->E1_NUMBCO),8)
	Else
		
		If TYPE("cTitu")=='U'
			lCont := .T.
		Else
			SEE->(dbSetOrder(1))
			lCont := SEE->(MSSeek(xFilial("SEE")+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08))
		EndIF
		IF lCont
			nNum := StrZero(Val(SEE->EE_FAXATU)+1,8)
			RECLOCK("SEE",.F.)
			SEE->EE_FAXATU:=nNum
			SEE->(msUnlock())
			
			RECLOCK("SE1",.F.)
			SE1->E1_NUMBCO:= nNum
			SE1->(msUnlock())
		Else
			Alert("BANCO NAO LOCALIZADO "+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA))
		EndIf
	EndIf
EndIF
RestArea(aAreaSE1)
RestArea(aAreaSEE)
return StrZero(Val(nNum),8)

//----------------> CEF <--------------------------------------------------
Static Function NNCef(cTitu,lcnab)
LOCAL cNN	   	:= ''
LOCAL cNum     	:= ''
//LOCAL cDv		:= ''
LOCAL aAreaSE1 	:= SE1->(GetArea())
LOCAL aAreaSEE 	:= SEE->(GetArea())
lCont := .F.
Lconti :=.f.

If lCnab
	If Empty(SE1->E1_NUMBCO)
		lConti:=.t.
	EndIF
EndIF

If  lConti
	cNum:='0'
Else
	IF !Empty(SE1->E1_NUMBCO)
		cNum:=StrZero(Val(SE1->E1_NUMBCO),15)
		cNN := cNum
	Else
		
		If TYPE("cTitu")=='U'
			lCont := .T.
		Else
			SEE->(dbSetOrder(1))
			lCont := SEE->(MSSeek(xFilial("SEE")+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08))
		EndIF
		IF lCont
			cNum := StrZero(Val(SEE->EE_FAXATU)+1,10)
			RECLOCK("SEE",.F.)
			SEE->EE_FAXATU:= cNum
			SEE->(msUnlock())
			cNN:= cNum
			RECLOCK("SE1", .F.)
			SE1->E1_NUMBCO:= cNN
			SE1->(msUnlock())
		Else
			Alert("BANCO NAO LOCALIZADO "+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA))
		EndIf
	EndIf
EndIF
RestArea(aAreaSE1)
RestArea(aAreaSEE)
return StrZero(Val(cNN),15)

// BRADESCO
Static Function NN237()

Local cNN      := ""
Local cNum     := ""
Local cDv      := ""
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSEE := SEE->(GetArea())

// Nosso Número: poderá ser gerado a partir de 00000000001, 00000000002, 11 posições,
// devendo ser atribuído numero diferenciado para identificação de cada documento na
// Cobrança Bradesco.
// Para o cálculo do dígito, será necessário acrescentar o número da carteira à esquerda
// antes do Nosso Número, e aplicar o módulo 11, com base 7.

dbSelectArea("SEE")
SEE->(dbSetOrder(1))

If !Empty(SE1->E1_NUMBCO)
	cNum := SE1->E1_NUMBCO
	cNN  := cNum
Else
	If SEE->(dbSeek(xFilial("SEE") + MV_PAR05 + MV_PAR06 + MV_PAR07 + MV_PAR08))
		
		cNum := StrZero(Val(SEE->EE_FAXATU)+1,11)
		RecLock("SEE",.F.)
			SEE->EE_FAXATU := cNum
		MsUnlock("SEE")
		
		cNN := cNum
		cNN := xCarteira + cNN
		cDv := Modulo11NN(cNN) 
		cNN := cNum + AllTrim(cDv)

		// Grava E1_NUMBCO
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO := cNN
		MsUnlock("SE1")
		
	Else
	                 
		MsgAlert("Banco não Localizado "+ SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA),"Verifique")

	EndIf

EndIf
RestArea(aAreaSE1)
RestArea(aAreaSEE)

Return cNN

Static Function NN001()

Local cNN      := ""
Local cNum     := ""
//Local cDv      := ""
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSEE := SEE->(GetArea())

dbSelectArea("SEE")
SEE->(dbSetOrder(1))

If SEE->(dbSeek(xFilial("SEE") + MV_PAR05 + MV_PAR06 + MV_PAR07 + MV_PAR08))
		
	if empty(SE1->E1_NUMBCO)
	
		cNum := StrZero(Val(SEE->EE_FAXATU)+1,10)		
		RECLOCK("SEE",.F.)
		SEE->EE_FAXATU:= cNum
		SEE->(msUnlock())
		
		cNN := cNum
		RECLOCK("SE1", .F.)
		SE1->E1_NUMBCO:= cNN
		SE1->(msUnlock())
	
	else
		
		cNN := SE1->E1_NUMBCO

	endif
		
Else
	                 
	MsgAlert("Banco não Localizado "+ SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA),"Verifique")

EndIf

//EndIf

RestArea(aAreaSE1)
RestArea(aAreaSEE)

Return cNN


//----------------> HSBC - Cob. Registrada	<--------------------------------------------------
Static Function NNHsbc(cTitu,lcnab)
LOCAL cNN	   	:= ''
LOCAL cNum     	:= ''
LOCAL cDv		:= ''
LOCAL aAreaSE1 	:= SE1->(GetArea())
LOCAL aAreaSEE 	:= SEE->(GetArea())
lCont := .F.
Lconti :=.f.

If lCnab
	If Empty(SE1->E1_NUMBCO)
		lConti:=.t.
	EndIF
EndIF

If  lConti
	cNum:='0'
Else
	IF !Empty(SE1->E1_NUMBCO)
		cNum:=StrZero(Val(SE1->E1_NUMBCO),10)
		cNN := cNum
	Else
		
		If TYPE("cTitu")=='U'
			lCont := .T.
		Else
			SEE->(dbSetOrder(1))
			lCont := SEE->(MSSeek(xFilial("SEE")+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08))
		EndIF
		IF lCont
			cNum := STRZERO(Val(SEE->EE_FAXATU)+1,5)
			RECLOCK("SEE",.F.)
			SEE->EE_FAXATU := cNum
			SEE->(msUnlock())
			cNN:= STRZERO(Val(SEE->EE_CODEMP),5)+cNum
			cDV:= ALLTRIM(STR(Mod11NN(cNN)))
			cNN:= cNN + cDV
			RECLOCK("SE1", .F.)
			SE1->E1_NUMBCO := cNN
			SE1->(msUnlock())
		Else
			Alert("BANCO NAO LOCALIZADO: "+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA))
		EndIf
	EndIf
EndIF
RestArea(aAreaSE1)
RestArea(aAreaSEE)
return StrZero(Val(cNN),11)

/*/{Protheus.doc} NN033
Função auxiliar de geração do Nosso Número para o banco Santander
@type function
@version 1.0
@author Alfred Andersen
@since 09/01/2023
/*/
Static Function NN033()

Local cNN      := ""
Local cNum     := ""
//Local cDv      := ""
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSEE := SEE->(GetArea())

dbSelectArea("SEE")
SEE->(dbSetOrder(1))

If SEE->(dbSeek(xFilial("SEE") + MV_PAR05 + MV_PAR06 + MV_PAR07 + MV_PAR08))
		
	if empty(SE1->E1_NUMBCO)
	
		cNum := StrZero(Val(SEE->EE_FAXATU)+1,12)		
		RECLOCK("SEE",.F.)
		SEE->EE_FAXATU:= cNum
		SEE->(msUnlock())
		
		cNN := cNum
		RECLOCK("SE1", .F.)
		SE1->E1_NUMBCO:= cNN
		SE1->(msUnlock())
	
	else
		
		cNN := SE1->E1_NUMBCO

	endif
		
Else
	                 
	MsgAlert("Banco não Localizado "+ SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA),"Verifique")

EndIf

//EndIf

RestArea(aAreaSE1)
RestArea(aAreaSEE)

Return cNN

//======================== OUTRAS FUNCOES ===================================//
//Calcular Data Juliana - Utilizado apenas para Tipo Identificador (4)
Static Function DtJul(dVencto)
//LOCAL aAreaSE1 	:= SE1->(GetArea())
//LOCAL aAreaSEE 	:= SEE->(GetArea())
LOCAL dAno      := YEAR(dVencto)
LOCAL dAnoAnt   := dAno -1
LOCAL dAnoFim   := CTOD("31/12/" + STR(dAnoAnt,4))
LOCAL cDias
LOCAL cDJ       := ''

cDias   := dVencto - dAnoFim
cDias   := STRZERO(cdias,3,0)
cDias   += SUBS(STR(dAno,4),4,1)
cDJ     := cDias
return StrZero(Val(cDJ),4)

//============================= CRIA PERGUNTAS =============================//
Static Function ValidPerg()
_cAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := "BOLS"
aRegs:={}

PutSX1(cPerg, "01", "Prefixo de"  , "", "", "mv_ch1", "C", TAMSX3("E1_PREFIXO")[1] 	, 0, 0, "G", "",       , "", "", "mv_par01", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "02", "Prefixo ate" , "", "", "mv_ch2", "C", TAMSX3("E1_PREFIXO")[1] 	, 0, 0, "G", "",       , "", "", "mv_par02", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "03", "Numero de"   , "", "", "mv_ch3", "C", TAMSX3("E1_NUM")[1]     	, 0, 0, "G", "",       , "", "", "mv_par03", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "04", "Numero ate"  , "", "", "mv_ch4", "C", TAMSX3("E1_NUM")[1]  	, 0, 0, "G", "",       , "", "", "mv_par04", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "05", "Banco"       , "", "", "mv_ch5", "C", 3 						, 0, 0, "C", "", "SEE" , "", "", "mv_par05", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "06", "Agencia"     , "", "", "mv_ch6", "C", 5  						, 0, 0, "C", "",       , "", "", "mv_par06", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "07", "Conta"       , "", "", "mv_ch7", "C", 10   					, 0, 0, "C", "",       , "", "", "mv_par07", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "08", "SubConta"    , "", "", "mv_ch8", "C", 3   					   	, 0, 0, "C", "",       , "", "", "mv_par08", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "09", "Bordero"     , "", "", "mv_ch9", "C", TAMSX3("E1_NUMBOR")[1]  	, 0, 0, "G", "",       , "", "", "mv_par09", "","","","","","","","","","","","","","","","")
//PutSx1(cPerg, "10", "Cob.Registrada","","", "mv_cha", "N", 1					   	, 0, 1, "C", "",       , "", "", "mv_par10", "Sim","","","","Nao","","","","","","","","","","","")
PutSx1(cPerg, "10", "Data Emissão", "", "", "mv_chb", "D", 08					   	, 0, 1, "G", "",       , "", "", "mv_par10", "","","","","","","","","","","","","","","","")
dbSelectArea(_cAlias)
Return	 


Static Function Modulo10NN(cData)

	LOCAL L,D,P := 0
	LOCAL B     := .F.
	
	
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
	
Return(Str(D, 1))

/*/{Protheus.doc} DigMod11
Cálculo do dígito do Nosso Número - Banco Santander  
@type function
@version 1.0
@author Alfred Andersen
@since 10/01/2023
/*/
User Function DigMod11(xPar01)

	Local cNum	 	:= 	ALLTRIM(xPar01)
	Local nTSoma	:= 0
	Local nSeq		:= 2
	//Local nTSoma	:= 0
	Local nSoma		:= 0
	Local nSubt		:= 0
	Local nResult	:= 0
	Local i

	// valida se o nosso numero tem 12 digitos, padrao Santander Módulo 11
	if len(cNum) <> 12
		Return -1
	endif
	FOR i:= LEN(cNum) TO 1 STEP -1
		nTSoma := val(SUBSTR(cNum,i,1)) * nSeq
		nSoma += nTSoma
		IF nSeq = 9
			nSeq := 2
		ELSE
			nSeq++
		ENDIF
	NEXT
	nSubt := nSoma%11
	nResult := nSubt
	IF nResult = 10
		nResult := 1
	ELSEIF nResult = 1 .or. nResult = 0
		nResult := 0
	ELSE
		nResult := 11 - nSubt
	ENDIF

Return alltrim(str(nResult))

/*/{Protheus.doc} DIGBAR
Cálculo do Díg Verificador do Cod.Barras - Bco Santander MOD(11) Pesos (2 a 9)  
@type function
@version 1.0 
@author Alfred Andersen
@since 10/01/2023
/*/
Static Function DIGBAR(xPar01)

	Local nCont	:=0
	Local cPeso	:=2
	Local i

	StrTran(xPar01," ","")

	For i:=Len(xPar01) To 1 Step -1
		nCont:=nCont+(Val(SUBSTR(xPar01,i,1))*cPeso)
		cPeso:=cPeso+1
		if cPeso>9
			cPeso:=2
		endif
	Next i

	resto:=((ncont*10)%11)

	If resto==0 .or. resto==1 .or. resto > 9
		nDigbar:='1'
	Else
		nDigbar:=Str(resto,1)
	Endif

Return (nDigbar)

/*/{Protheus.doc} DigitoBol
Cálculo dos dígitos da Linha Digitável - Banco Santander
@type function
@version 1.0 
@author Alfred Andersen
@since 10/01/2023
/*/
Static Function DigitoBol(xPar01)

	Local nCont		:=0
	Local nValor	:=0
	Local cPeso		:=2
	Local i

	StrTran(xPar01," ","")

	For i:=Len(xPar01) to 1 Step -1
		nValor:=(Val(SUBSTR(xPar01,i,1))*cPeso)
		
		If nValor>9
			nValor:=val(substr(alltrim(str(nValor)),1,1))+val(substr(alltrim(str(nValor)),2,1))
		Endif
		
		nCont:=nCont+nValor
		
		cPeso--
		
		If cPeso==0
			cPeso:=2
		Endif
		
	Next i

	resto:=(nCont%10)
	If	resto <> 0
		resto:= 10-resto
	Endif

Return( alltrim(Str(resto)) )
