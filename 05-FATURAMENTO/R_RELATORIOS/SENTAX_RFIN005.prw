#include "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} RFIN005
RELATORIO DE POSIÇÃO TITULOS A RECEBER
@author João AFSouza
@since 22/05/2020
@version 1.0
@example u_RFIN005 ()
/*/

User Function  RFIN005()


Private cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := "de acordo com os parametros informados pelo usuario."
Private cDesc3       := "RFIN005"
Private titulo       := "Posicao de titulos a receber SENTAX"

Private cPerg        := "RFIN005"
Private wnrel        := "RFIN005" // Coloque aqui o nome do arquivo usado para impressao em disco
Private aReturn      := {'Zebrado', 1,'Administracao', 2, 2, 1, '',1}
Private nTipo        := 18
Private tamanho      := "G"
Private nomeprog     := "RFIN005" // Coloque aqui o nome do programa para impressao no cabecalho
Private m_pag        := 01
Private nSaldoR      := 0

Private	aAreaSa1 := SA1->(GetArea('SA1'))
Private	aAreaSe1 := SE1->(GetArea('SE1'))


Private cString := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta os parametros.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg := PadR (cPerg,10," ")
_AjustaSX1(cPerg)

//----------------------------------------------------------------------//
//³ Monta a interface padrao com o usuario...                           ³
//----------------------------------------------------------------------//

If	( ! Pergunte(cPerg,.T.) )
	Return
Else
	Private  cCliI       := mv_par01  //Do Cliente?
	Private  cCliF       := mv_par02  //Até o Cliente?
	Private  cLojaI      := mv_par03  //Da Loja?
	Private  cLojaF      := mv_par04  //Até a Loja?
	Private  cPrxI       := mv_par05  //Do prefixo?
	Private  cPrxF       := mv_par06  //Até o prefixo?
	Private  cBancoI     := mv_par07  //Do Banco?
	Private  cBancoF     := mv_par08  //Até o Banco?
	Private  cVctoI      := mv_par09  //Do Vencimento?
	Private  cVctoF      := mv_par10  //Até o Vencimento?
	Private  cNatzI      := mv_par11  //Da Natureza?
	Private  cNatzF      := mv_par12  //ATé a Natureza?
	Private  cEmissI     := mv_par13  //Da emissao?
	Private  cEmissF     := mv_par14  //Até a emissao?
	Private  cTipos      := mv_par15  //Imprime Tipos?
	Private  cNTipos     := mv_par15  //Não Imprime Tipos?
	Private	 cFilI    	 := mv_par16  //Da Filial?
	Private	 cFilF     	 := mv_par17  //Até a Filial?
	Private  cDtBase     := mv_par18  //Data Base
EndIf

wnrel:=SetPrint(cString,wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

// Chama a função de processamento do relatório.

VETRL2()

//__________________________________________________________________________________________________________________________________________________
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VETRL1 º Autor ³ JOAO EDENILSON     º Data ³  10/02/15      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao que chama o relatorio Análitico                     º±±
±±º  o.        Posicao de Titulos a Receber                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Static Function                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VETRL2()

processa( {|| reguaPD2()} )
Return



Static Function reguaPD2()

Public oPrn   := tAvPrinter():New( "Posição Títulos a receber" ),;
oBrush		  := TBrush():New(,4),;    // Definicao de Preenchimento
oPen		  := TPen():New(0,5,CLR_BLACK),;  // Definicao da Espessura da Impressao
cLogotipo 	  := "\SYSTEM\SENTAX.JPG",;
oFont6N 	  := TFont():New( "Arial",,06,,.T.,,,,,.F.),;  // Definicao das Fontes (Instaladas no Windows)
oFont6		  := TFont():New( "Arial",,06,,.F.,,,,,.F.),;
oFont7N	      := TFont():New( "Arial",,07,,.T.,,,,,.F.),;
oFont7		  := TFont():New( "Arial",,07,,.F.,,,,,.F.),;
oFont8N		  := TFont():New( "Arial",,08,,.T.,,,,,.F.),;
oFont8		  := TFont():New( "Arial",,08,,.F.,,,,,.F.),;
oFont9N		  := TFont():New( "Arial",,09,,.T.,,,,,.F.),;
oFont9		  := TFont():New( "Arial",,09,,.F.,,,,,.F.),;
oFont10N	  := TFont():New( "Arial",,10,,.T.,,,,,.F.),;
oFont10		  := TFont():New( "Arial",,10,,.F.,,,,,.F.),;
oFont11N	  := TFont():New( "Arial",,11,,.T.,,,,,.F.),;
oFont11 	  := TFont():New( "Arial",,11,,.F.,,,,,.F.),;
oFont12N	  := TFont():New( "Arial",,12,,.T.,,,,,.F.),;
oFont12	      := TFont():New( "Arial",,12,,.F.,,,,,.F.),;
oFont13N	  := TFont():New( "Arial",,13,,.T.,,,,,.F.),;
oFont13	      := TFont():New( "Arial",,13,,.F.,,,,,.F.),;
oFont14N	  := TFont():New( "Arial",,14,,.T.,,,,,.F.),;
oFont14	      := TFont():New( "Arial",,14,,.F.,,,,,.F.),;
oFont15N	  := TFont():New( "Arial",,15,,.T.,,,,,.F.),;
oFont15	      := TFont():New( "Arial",,15,,.F.,,,,,.F.),;
oFont16N	  := TFont():New( "Arial",,16,,.T.,,,,,.F.),;
oFont16	      := TFont():New( "Arial",,17,,.F.,,,,,.F.)

aArray    := {}   // array para função de exportar para excel
aCabec    := {}   // array para função de exportar para excel

oPrn:SetLandscape()

_cQry := " SELECT E1_FILIAL FILIAL,                                                  "
_cQry += " E1_CLIENTE		CODCLI,                                                  "
_cQry += " E1_LOJA			LOJA,                                                    "
_cQry += " E1_NOMCLI		NOMECLI,                                                 "
_cQry += " E1_PREFIXO       PRF,                                                     "
_cQry += " E1_NUM           NUMERO,                                                  "
_cQry += " E1_PARCELA       PARCELA,                                                 "
_cQry += " E1_MOEDA         MOEDA,                                                   "
_cQry += " E1_TIPO          TIPO,                                                    "
_cQry += " E1_NATUREZ       NATUREZA,                                                "
_cQry += " E1_EMISSAO       DTEMISS,                                                 "
_cQry += " E1_VENCORI       DTVENCTO,                                                "
_cQry += " E1_VENCREA       VENCTOREAL,                                              "
_cQry += " E1_PORTADO       BANCO,                                                   "
_cQry += " E1_VALOR         VALOR,                                                   "
_cQry += " E1_SALDO         SALDO,                                                   "
_cQry += " E1_VALJUR        JUROS,                                                   "   
_cQry += " E1_BAIXA         BAIXA                                                    "
_cQry += " FROM "+ RetSQLName("SE1") +" SE1                                			 "     
_cQry += " INNER JOIN "+ RetSQLName("SA1") +" SA1  ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_='' "
_cQry += " WHERE  SE1.D_E_L_E_T_=' '                                                 "
//If !Empty(mv_par15)    // Deseja imprimir apenas os tipos do parametro 15
//	_cQry += " 		AND E1_TIPO IN "+FormatIn(mv_par15,";")                          "
If !Empty(Mv_par15)// Deseja excluir os tipos do parametro 15
	_cQry += " 		AND E1_TIPO NOT IN "+FormatIn(mv_par15,";")                      "
EndIf

_cQry += "   AND E1_CLIENTE BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"'   		 "
_cQry += "   AND E1_LOJA    BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"'  			 "
_cQry += "   AND E1_PREFIXO BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"'  			 "
_cQry += "   AND E1_PORTADO BETWEEN '"+ MV_PAR07 +"' AND '"+ MV_PAR08 +"'   		 "
_cQry += "   AND E1_VENCORI BETWEEN '"+ DTOS(mv_par09)+"' AND '"+DTOS(mv_par10)+"'   "
_cQry += "   AND E1_NATUREZ BETWEEN '"+ MV_PAR11 +"' AND '"+ MV_PAR12 +"'            "
_cQry += "   AND E1_EMISSAO BETWEEN '"+ DTOS(mv_par13)+"' AND '"+DTOS(mv_par14)+"'   "
_cQry += "   AND E1_FILIAL  BETWEEN '"+ MV_PAR16 +"' AND '"+ MV_PAR17 +"'   		 "  
_cQry += "   AND A1_GRPVEN BETWEEN  '"+ MV_PAR19 +"' AND '"+ MV_PAR20 +"'   		 " 
//_cQry += "   AND E1_NUM = '000003811'                                              "  
_cQry += "   AND (E1_BAIXA >= '"+DTOS(MV_PAR18)+"' OR E1_SALDO <> 0)                 " 
//_cQry += "   AND (E5_DTDISPO >= '"+DTOS(MV_PAR18)+"' OR E1_SALDO <> 0)             " 
_cQry += "      ORDER BY E1_FILIAL, E1_NOMCLI                                        "

//Memowrite("c:\RelSep.txt",_cQry)

TCQUERY _cQry NEW ALIAS "TMP2"

TMP2->(dbGoTop())

if (TMP2->(Eof()))
	MsgAlert('Não existe relação para os parâmetros informados!')
	TMP2->(DbCloseArea())
	return
endif

nCount := 0
Count To nCount
TMP2->(dbGoTop())

oPrn:StartPage()  // Inicio da Pagina
CabecPd()         // Imprime o Cabecalho

cont      := 0
nLinha    := 250
_nTotCli  := 0  // variavel totalizadora do relatório por cliente.
_nTotSld  := 0
_nTotVlr  := 0
_nTotGSld := 0
_nTotGVlr := 0
_nTotGVcr := 0
_dtprod   := " "


Procregua(nCount)

//Array que contém o cabeçalho que será enviado para o excel

AADD(aCabec,{"FILIAL","C",04,0})
AADD(aCabec,{"CLIENTE","C",006,0})
AADD(aCabec,{"LOJA","C",004,0})
AADD(aCabec,{"NOME CLIENTE","C",020,0})
AADD(aCabec,{"PRFX","C",003,0})
AADD(aCabec,{"NUMERO","C",010,0})
AADD(aCabec,{"PARC.","N",004,0})
AADD(aCabec,{"TIPO","C",004,0})
AADD(aCabec,{"NATUREZA","C",010,0})
AADD(aCabec,{"EMISSAO","D",008,0})
AADD(aCabec,{"VCTO REAL","D",008,0})
AADD(aCabec,{"BANCO","N",004,0})
AADD(aCabec,{"VALOR","N",015,0})
AADD(aCabec,{"AVENCER","N",015,0})
AADD(aCabec,{"JUROS","N",015,0})
AADD(aCabec,{"SALDO","N",015,0})
AADD(aCabec,{"DT_BAIXA","D",008,0})



TMP2->(dbGoTop())
_cCodcli := TMP2->CODCLI   // Codigo do cliente.
While !TMP2->(Eof())
	
	Incproc("Aguarde processando " + cValToChar(nCount) + " registros.")
	
	if (cont == 41)
		oPrn:EndPage() // Fim da Pagina
		cont := 0
		nLinha := 250
		oPrn:StartPage()
		CabecPD()
	endif
	
	/*
	// Parametros da função SaldoTit---- que será utilizada para calcular o saldo do título de acordo com a data base.
	Parâmetro 1 (Caractere) => Número do Prefixo
	Parâmetro 2 (Caractere) => Número do Titulo
	Parâmetro 3 (caractere) => Parcela
	Parâmetro 4 (Caractere) => Tipo
	Parâmetro 5 (Caractere) => Natureza
	Parâmetro 6 (Caractere)  => Carteira R/P
	Parâmetro 7 (Caractere) => Conforme Parâmetro 6 se for = 'R' Código Cliente se não Código Fornecedor.
	Parâmetro 8 (Numerico) => Moeda
	Parâmetro 9 (Data) =>  Data para Conversão
	Parâmetro 10 (Data) => Data Baixa a ser considerada.
	Parâmetro 11 (Caractere) => Loja do Tipo
	Parâmetro 12 (Caractere) => Filial do Titulo
	Parâmetro 13 (Numerico) => Taxa da Moeda
	Parâmetro 14 (Numerico) => Tipo de Data para compor saldo(baixa/dispo/digit)
	*/
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(TMP2->FILIAL+TMP2->PRF+TMP2->NUMERO+TMP2->PARCELA+TMP2->TIPO)
	_cSaldo   := 0
	_cFil     := xFilial("SE1")
	_nVlrComp := 0
	//_dDtRef   := Stod(mv_par18)
	
	nSaldo  := SaldoTit( TMP2->PRF , TMP2->NUMERO , TMP2->PARCELA , TMP2->TIPO , TMP2->NATUREZA , "R" , TMP2->CODCLI , TMP2->MOEDA , , MV_PAR18 , TMP2->LOJA  )
	//	SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,1,dDataBase,dDataBase,SE1->E1_LOJA,xFilial("SE1"))
	
	If  nSaldo <> 0
		
		
		/*/ ---------------totaliza o saldo do titulo por cliente --------------------------------------------------
		If  _cCodcli <> TMP2->CODCLI
			
			oPrn:Say(nLinha + 10,045,"Total do cliente:",oFont9N)
			
			oPrn:Box(nLinha,1950,nLinha + 50,2150)
			oPrn:Box(nLinha,040, nLinha + 50,3200)
			oPrn:Say(nLinha + 10,2145,transform(_nTotVlr,"@E 999,999,999.99"),oFont8N,30, 10, ,1,)
			
			oPrn:Box(nLinha,2550,nLinha + 50,2750)
			oPrn:Say(nLinha + 10,2745,transform(_nTotSld,"@E 999,999,999.99"),oFont8N,30, 10, ,1,)
			
			_nTotSld  := 0
			_nTotVlr  := 0
			_cCodcli  := TMP2->CODCLI
			nLinha := nLinha + 50
			cont := cont + 1
		endIf
		
		// ---------------fim----------------------------------- --------------------------------------------------/*/
		
		
		// Este bloco é usado para verificar se houve compensação de títulos entre filiais
		//----------------------------------------------------------------------------------------------------------------------------------------------------------
		if select("TMP3") > 0
			dbSelectArea("TMP3")
			dbCloseArea()
		endIf
		
		// Verifica se o título teve compensação entre filiais....
		_cQry := " SELECT SUM(E5_VALOR) VLRCOMP          "
		_cQry += " FROM "+ RetSQLName("SE5") +" SE5      "
		_cQry += " WHERE E5_NUMERO='"+TMP2->NUMERO+"'    "
		_cQry += "   AND D_E_L_E_T_=' '                  "
		_cQry += "   AND SUBSTRING(E5_FILORIG,1,2)='"+ Substr(_cFil,1,2) +"'       "
		_cQry += "   AND E5_PREFIXO ='"+TMP2->PRF+"'     "
		_cQry += "   AND E5_PARCELA ='"+TMP2->PARCELA+"' "
		_cQry += "   AND E5_TIPO    ='"+TMP2->TIPO+"'    "
		_cQry += "   AND E5_CLIENTE ='"+TMP2->CODCLI+"'  "
		_cQry += "   AND E5_LOJA    ='"+TMP2->LOJA+"'    "
		_cQry += "   AND E5_RECPAG  ='R'                 "
		_cQry += "   AND E5_MOTBX   ='CMP'               "
		_cQry += "   AND E5_DATA    <='"+ DTOS(MV_PAR18)+"'    "   
		
		TCQUERY _cQry NEW ALIAS "TMP3"
		
		TMP3->(dbGoTop())
		
		/*
		if (TMP3->(Eof()))
			MsgAlert('Não existe relação para os parâmetros informados!')
			TMP3->(DbCloseArea())
			return
		endif 
		*/
		
		If select("TMP4") > 0
			dbSelectArea("TMP4")
			dbCloseArea()
		endIf
		
		// Verifica se o título teve estorno de compensação entre filiais....
		_cQry := " SELECT SUM(E5_VALOR) ESTCOMP          "
		_cQry += " FROM "+ RetSQLName("SE5") +" SE5      "
		_cQry += " WHERE E5_NUMERO='"+TMP2->NUMERO+"'    "
		_cQry += "   AND D_E_L_E_T_=' '                  "
     	_cQry += "   AND SUBSTRING(E5_FILORIG,1,2)='"+ Substr(_cFil,1,2) +"'       "
		_cQry += "   AND E5_PREFIXO ='"+TMP2->PRF+"'     "
		_cQry += "   AND E5_PARCELA ='"+TMP2->PARCELA+"' "
		_cQry += "   AND E5_TIPO    ='"+TMP2->TIPO+"'    "
		_cQry += "   AND E5_CLIENTE ='"+TMP2->CODCLI+"'  "
		_cQry += "   AND E5_LOJA    ='"+TMP2->LOJA+"'    "
		_cQry += "   AND E5_RECPAG  ='P'                 "      
		_cQry += "   AND E5_TIPODOC ='ES'                "
		_cQry += "   AND E5_MOTBX   ='CMP'               "
		_cQry += "   AND E5_DATA    <='"+ DTOS(MV_PAR18)+"'    "
		
		TCQUERY _cQry NEW ALIAS "TMP4"
		
		TMP4->(dbGoTop())
		
		/*
		If (TMP4->(Eof()))
			MsgAlert('Não existe relação para os parâmetros informados!')
			TMP4->(DbCloseArea())
			return
		endif
		*/
		
		_nVlrComp := TMP3->VLRCOMP  
		_nEstComp := TMP4->ESTCOMP   
	
		If _nVlrComp <> 0  //.OR. TMP3->FILIAL <> TMP2->FILIAL
			_cSaldo   := TMP2->VALOR - _nVlrComp + _nEstComp
		Else
			_cSaldo   := nSaldo
		EndIf
		// fim --- Se houve compensação substrai o valor baixado do saldo do título.
		//----------------------------------------------------------------------------------------------------------------------------------------------------------
		
		// Impressão dos Dados
		_dtemiss := Substr (TMP2->DTEMISS,7,2)+"/" + Substr (TMP2->DTEMISS,5,2)+"/" + Substr(TMP2->DTEMISS, 1,4)
		_dtvctoR := Substr (TMP2->VENCTOREAL,7,2)+"/" + Substr (TMP2->VENCTOREAL,5,2)+"/" + Substr(TMP2->VENCTOREAL, 1,4)
		_dtBaixa := Substr (TMP2->BAIXA,7,2)+"/" + Substr (TMP2->BAIXA,5,2)+"/" + Substr(TMP2->BAIXA, 1,4)
		
		oPrn:Box(nLinha,040,nLinha + 50,150)
		oPrn:Say(nLinha + 10,045,TMP2->FILIAL,oFont9)
		
		oPrn:Box(nLinha,150,nLinha + 50,350)
		oPrn:Say(nLinha + 10,155,TMP2->CODCLI,oFont9)
		
		oPrn:Box(nLinha,350,nLinha + 50,460)
		oPrn:Say(nLinha + 10,355,TMP2->LOJA,oFont8)
		
		oPrn:Box(nLinha,460,nLinha + 50,900)
		oPrn:Say(nLinha + 10,465,TMP2->NOMECLI,oFont8)
		
		oPrn:Box(nLinha,900,nLinha + 50,1000)
		oPrn:Say(nLinha + 10,905,TMP2->PRF,oFont8)
		
		oPrn:Box(nLinha,1000,nLinha + 50,1150)
		oPrn:Say(nLinha + 10,1005,TMP2->NUMERO,oFont8)
		
		oPrn:Box(nLinha,1150,nLinha + 50,1250)
		oPrn:Say(nLinha + 10,1155,TMP2->PARCELA,oFont8)
		
		oPrn:Box(nLinha,1250,nLinha + 50,1350)
		oPrn:Say(nLinha + 10,1255,TMP2->TIPO,oFont8)
		
		oPrn:Box(nLinha,1350,nLinha + 50,1500)
		oPrn:Say(nLinha + 10,1355,TMP2->NATUREZA,oFont8)
		
		oPrn:Box(nLinha,1500,nLinha + 50,1670)
		oPrn:Say(nLinha + 10,1505,_dtemiss,oFont8) // DATA DA EMISSAO
		
		oPrn:Box(nLinha,1670,nLinha + 50,1850)
		oPrn:Say(nLinha + 10,1675,_dtvctoR,oFont8) // DATA VENCIMENTO REAL
		
		oPrn:Box(nLinha,1850,nLinha + 50,1950)
		oPrn:Say(nLinha + 10,1855,TMP2->BANCO,oFont8)
		
		oPrn:Box(nLinha,1950,nLinha + 50,2150)
		oPrn:Say(nLinha + 10,2145,cValTochar(transform(TMP2->VALOR,"@E 999,999,999.99")),oFont8,30, 10, ,1,)
		
		oPrn:Box(nLinha,2150,nLinha + 50,2350)
		oPrn:Say(nLinha + 10,2345,cValTochar(transform(TMP2->SALDO,"@E 999,999,999.99")),oFont8,30, 10, ,1,)
		
		oPrn:Box(nLinha,2350,nLinha + 50,2550)
		oPrn:Say(nLinha + 10,2545,cValTochar(transform(TMP2->JUROS,"@E 999,999,999.99")),oFont8,30, 10, ,1,)
		
		oPrn:Box(nLinha,2550,nLinha + 50,2750)
		oPrn:Say(nLinha + 10,2745,transform(_cSaldo,"@E 999,999,999.99"),oFont8,30, 10, ,1,)
		
		oPrn:Box(nLinha,2750,nLinha + 50,3250)
		oPrn:Say(nLinha + 10,2755,_dtBaixa,oFont8)
		//oPrn:Say(nLinha + 10,2755,Substr(TMP2->HIST,1,36),oFont8)
		
		// inclementa valor do saldo a cada alteração de codigo de cliente.
		//_nTotSld += _cSaldo
		//_nTotVlr += TMP2->VALOR
		
		// inclementa valor do saldo a cada alteração de codigo de cliente.
		_nTotGSld += _cSaldo
		_nTotGVlr += TMP2->VALOR
		_nTotGVcr += TMP2->SALDO  // saldo a vencer
		
		
		nLinha := nLinha + 50
		cont := cont + 1
		
		// array que carrega dados da Query para exportar para excel
		aADD(aArray,;
		{"." + TMP2->FILIAL,;
		"." + TMP2->CODCLI,;
		"." + TMP2->LOJA,;
		TMP2->NOMECLI,;
		TMP2->PRF,;
		TMP2->NUMERO,;
		"." + TMP2->PARCELA,;
		TMP2->TIPO,;
		"." + TMP2->NATUREZA,;
		_dtemiss,;
		_dtvctoR,;
		"."+ TMP2->BANCO,;
		TMP2->VALOR,;
		TMP2->SALDO,;
		TMP2->JUROS,;
		_cSaldo,;
		_dtBaixa})
		
	EndIf
	TMP2->(dbSkip())
	
EndDo

// Totaliza o ultimo Cliente... porque é final de arquivo
/*/-------------------------------------------------------------------------------------------------

oPrn:Say(nLinha + 10,045,"Total dp cliente:",oFont9N)

oPrn:Box(nLinha,1950,nLinha + 50,2150)
oPrn:Box(nLinha,040, nLinha + 50,3200)
oPrn:Say(nLinha + 10,2145,transform(_nTotVlr,"@E 999,999,999.99"),oFont8N,30, 10, ,1,)

oPrn:Box(nLinha,2550,nLinha + 50,2750)
oPrn:Say(nLinha + 10,2745,transform(_nTotSld,"@E 999,999,999.99"),oFont8N,30, 10, ,1,)

_nTotSld  := 0
_nTotVlr  := 0
nLinha := nLinha + 50
cont   := cont + 1
//-------------------------------------------------------------------------------------------------/*/


// Total Geral do relatório
//-------------------------------------------------------------------------------------------------
nLinha := nLinha + 50

oPrn:Say(nLinha + 10,045,"Total Geral:",oFont9N)
oPrn:Box(nLinha,040, nLinha + 50,3250)

oPrn:Box(nLinha,1950,nLinha + 50,2150)
oPrn:Say(nLinha + 10,2145,transform(_nTotGVlr,"@E 999,999,999.99"),oFont8N,30, 10, ,1,)

oPrn:Box(nLinha,2150,nLinha + 50,2350)
oPrn:Say(nLinha + 10,2345,transform(_nTotGVcr,"@E 999,999,999.99"),oFont8N,30, 10, ,1,)

oPrn:Box(nLinha,2550,nLinha + 50,2750)
oPrn:Say(nLinha + 10,2745,transform(_nTotGSld,"@E 999,999,999.99"),oFont8N,30, 10, ,1,)

//-------------------------------------------------------------------------------------------------
oPrn:EndPage() // Fim da Pagina
oPrn:Preview()
/*
If MsgBox("Deseja gerar planilha Excel?","Confirme","YESNO")  // chama a função para exportar para excel.
	U_TOEXCELA(aArray,aCabec)
endif
*/
If MsgYesNo("Deseja gerar planilha Excel?")
	U_TOEXCELA("Posicao de titulos a receber Sentax", aCabec, aArray)
endif

TMP2->(DbCloseArea())

Return

Static Function CabecPD()

oPrn:Box(45,40,200,460)//Quadradinho do Logo
oPrn:SayBitMap(70,60,cLogotipo,350,80)  // Imprime o Logotipo

oPrn:Box(45,460,200,3250)//Quadradinho do cabeçalho
oPrn:Say(55,900 ,("Posição títulos a receber Sentax "),oFont12N)

nLi := 200

oPrn:Box(nLi,040,nLi + 50,150)
oPrn:Say(nLi + 10,045,"Filial",oFont9N)

oPrn:Box(nLi,150,nLi + 50,350)
oPrn:Say(nLi + 10,155,"Cliente",oFont9N)

oPrn:Box(nLi,350,nLi + 50,460)
oPrn:Say(nLi + 10,355,"Loja",oFont9N)

oPrn:Box(nLi,460,nLi + 50,900)
oPrn:Say(nLi + 10,465,"Nome Cliente",oFont9N)

oPrn:Box(nLi,900,nLi + 50,1000)
oPrn:Say(nLi + 10,905,"Prfx",oFont9N)

oPrn:Box(nLi,1000,nLi + 50,1150)
oPrn:Say(nLi + 10,1005,"Numero",oFont9N)

oPrn:Box(nLi,1150,nLi + 50,1250)
oPrn:Say(nLi + 10,1155,"Parc.",oFont9N)

oPrn:Box(nLi,1250,nLi + 50,1350)
oPrn:Say(nLi + 10,1255,"Tipo",oFont9N)

oPrn:Box(nLi,1350,nLi + 50,1500)
oPrn:Say(nLi + 10,1355,"Natureza",oFont9N)

oPrn:Box(nLi,1500,nLi + 50,1670)
oPrn:Say(nLi + 10,1505,"Emissao",oFont9N)

oPrn:Box(nLi,1670,nLi + 50,1850)
oPrn:Say(nLi + 10,1675,"Dt.Vcto.",oFont9N)

oPrn:Box(nLi,1850,nLi + 50,1950)
oPrn:Say(nLi + 10,1855,"Bco.",oFont9N)

oPrn:Box(nLi,1950,nLi + 50,2150)
oPrn:Say(nLi + 10,1955,"Valor",oFont9N)

oPrn:Box(nLi,2150,nLi + 50,2350)
oPrn:Say(nLi + 10,2155,"À Vencer",oFont9N)

oPrn:Box(nLi,2350,nLi + 50,2550)
oPrn:Say(nLi + 10,2355,"Juros",oFont9N)

oPrn:Box(nLi,2550,nLi + 50,2750)
oPrn:Say(nLi + 10,2555,"Saldo",oFont9N)

oPrn:Box(nLi,2750,nLi + 50,3250)
oPrn:Say(nLi + 10,2755,"Dt.Baixa",oFont9N)


SA1->(RestArea(aAreaSa1))
SE1->(RestArea(aAreaSe1))
SE1->(DbCloseArea())

Return


//__________________________________________________________________________________________________________________________________________________
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ _AjustaSX1ºAutor ³Joao Edenilson Lopes º Data ³  20/08/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o SX1 - Arquivo de Perguntas..                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _AjustaSX1(cPerg)
//dbSelectArea("SX1")
//SX1->(dbSetOrder(1))

//If !SX1->(dbSeek(cPerg+"01"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='01'
//sx1->x1_pergunt :='Do Cliente?'
//sx1->x1_variavl :='mv_ch01'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=6
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par01'
//sx1->x1_f3      :='SA1'
//MsUnlock("SX1")


//If !SX1->(dbSeek(cPerg+"02"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='02'
//sx1->x1_pergunt :='Até o Cliente?'
//sx1->x1_variavl :='mv_ch02'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=6
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par02'
//sx1->x1_f3      :='SA1'
//MsUnlock("SX1")

//If !SX1->(dbSeek(cPerg+"03"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='03'
//sx1->x1_pergunt :='Da Loja?'
//sx1->x1_variavl :='mv_ch03'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=2
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par03'
//MsUnlock("SX1")


//If !SX1->(dbSeek(cPerg+"04"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='04'
//sx1->x1_pergunt :='Até a Loja?'
//sx1->x1_variavl :='mv_ch04'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=2
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par04'
//MsUnlock("SX1")

//If !SX1->(dbSeek(cPerg+"05"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='05'
//sx1->x1_pergunt :='Do Prefixo?'
//sx1->x1_variavl :='mv_ch05'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=4
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par05'
//MsUnlock("SX1")


//If !SX1->(dbSeek(cPerg+"06"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='06'
//sx1->x1_pergunt :='Até o Prefixo?'
//sx1->x1_variavl :='mv_ch06'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=4
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par06'
//MsUnlock("SX1")

//If !SX1->(dbSeek(cPerg+"07"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='07'
//sx1->x1_pergunt :='Do Banco?'
//sx1->x1_variavl :='mv_ch07'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=4
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par07'
//sx1->x1_f3      :='SA6'
//MsUnlock("SX1")


//If !SX1->(dbSeek(cPerg+"08"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='08'
//sx1->x1_pergunt :='Até o banco?'
//sx1->x1_variavl :='mv_ch08'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=4
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par08'
//sx1->x1_f3      :='SA6'
//MsUnlock("SX1")

//If !dbSeek(cPerg+"09")
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.F.)
//EndIf
//sx1->x1_grupo    := cPerg
//sx1->x1_ordem    := '09'
//sx1->x1_pergunt  := 'Do vencimento?'
//sx1->x1_variavl  := 'mv_ch09'
//sx1->x1_tipo     := 'D'
//sx1->x1_tamanho  := 8
//sx1->x1_decimal  := 0
//sx1->x1_gsc      := 'G'
//sx1->x1_var01    := 'mv_par09'
//sx1->(MsUnlock())

//If !dbSeek(cPerg+"10")
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.F.)
//EndIf
//sx1->x1_grupo    := cPerg
//sx1->x1_ordem    := '10'
//sx1->x1_pergunt  := 'Até o vencimento?'
//sx1->x1_variavl  := 'mv_ch10'
//sx1->x1_tipo     := 'D'
//sx1->x1_tamanho  := 8
//sx1->x1_decimal  := 0
//sx1->x1_gsc      := 'G'
//sx1->x1_var01    := 'mv_par10'
//sx1->(MsUnlock())

//If !SX1->(dbSeek(cPerg+"11"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='11'
//sx1->x1_pergunt :='Da natureza?'
//sx1->x1_variavl :='mv_ch11'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=8
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par11'
//MsUnlock("SX1")


//If !SX1->(dbSeek(cPerg+"12"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='12'
//sx1->x1_pergunt :='Até a natureza?'
//sx1->x1_variavl :='mv_ch12'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=8
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par12'
//MsUnlock("SX1")

//If !dbSeek(cPerg+"13")
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.F.)
//EndIf
//sx1->x1_grupo    := cPerg
//sx1->x1_ordem    := '13'
//sx1->x1_pergunt  := 'Da emisssao?'
//sx1->x1_variavl  := 'mv_ch13'
//sx1->x1_tipo     := 'D'
//sx1->x1_tamanho  := 8
//sx1->x1_decimal  := 0
//sx1->x1_gsc      := 'G'
//sx1->x1_var01    := 'mv_par13'
//sx1->(MsUnlock())

//If !dbSeek(cPerg+"14")
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.F.)
//EndIf
//sx1->x1_grupo    := cPerg
//sx1->x1_ordem    := '14'
//sx1->x1_pergunt  := 'Até a emissao?'
//sx1->x1_variavl  := 'mv_ch14'
//sx1->x1_tipo     := 'D'
//sx1->x1_tamanho  := 8
//sx1->x1_decimal  := 0
//sx1->x1_gsc      := 'G'
//sx1->x1_var01    := 'mv_par14'
//sx1->(MsUnlock())

//If !SX1->(dbSeek(cPerg+"15"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='15'
//sx1->x1_pergunt :='Não imprime tipos?'
//sx1->x1_variavl :='mv_ch15'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=16
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par15'
//MsUnlock("SX1")

//If !SX1->(dbSeek(cPerg+"16"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='16'
//sx1->x1_pergunt :='Da Filial?'
//sx1->x1_variavl :='mv_ch16'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=6
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par16'
//sx1->x1_f3      :='SM0'
//MsUnlock("SX1")


//If !SX1->(dbSeek(cPerg+"17"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='17'
//sx1->x1_pergunt :='Até Filial?'
//sx1->x1_variavl :='mv_ch17'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=6
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par17'
//sx1->x1_f3      :='SM0'
//MsUnlock("SX1")


//If !dbSeek(cPerg+"18")
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.F.)
//EndIf
//sx1->x1_grupo    := cPerg
//sx1->x1_ordem    := '18'
//sx1->x1_pergunt  := 'Data de Referência?'
//sx1->x1_variavl  := 'mv_ch18'
//sx1->x1_tipo     := 'D'
//sx1->x1_tamanho  := 8
//sx1->x1_decimal  := 0
//sx1->x1_gsc      := 'G'
//sx1->x1_var01    := 'mv_par18'
sx1->(MsUnlock())


//If !SX1->(dbSeek(cPerg+"19"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='19'
//sx1->x1_pergunt :='Do Grupo de Vendas?'
//sx1->x1_variavl :='mv_ch19'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=6
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par19'
//sx1->x1_f3      :='ACY'
//MsUnlock("SX1")


//If !SX1->(dbSeek(cPerg+"20"))
//	RecLock("SX1",.T.)
//Else
//	RecLock("SX1",.f.)
//EndIf
//sx1->x1_grupo   :=cPerg
//sx1->x1_ordem   :='20'
//sx1->x1_pergunt :='Até Grupo de Vendas?'
//sx1->x1_variavl :='mv_ch20'
//sx1->x1_tipo    :='C'
//sx1->x1_tamanho :=6
//sx1->x1_decimal :=0
//sx1->x1_gsc     :='G'
//sx1->x1_var01   :='mv_par20'
//sx1->x1_f3      :='ACY'
//MsUnlock("SX1")

Return









