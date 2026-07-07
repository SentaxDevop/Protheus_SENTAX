//-------------------------------------
//Impressão recibo pagamento do cliente
//-------------------------------------
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function FINA1000()

Local cNomeArq   := ""  
Local lRet       := .F.                 
Local aCampos    := {}
Local aBrowse    := {}
Local bOk        := {|| lRet := .T.,IIF(lRet,MONTAREL(),),oDlg:END()}
Local bCancel    := {|| lRet := .F.,oDlg:END()}
Local aButtons   := {}     
Local aPergs     := {} 
Private lMarca   := .F.
Private Tamanho  := "M"
Private cTitulo  := "Impressao Recibo Cliente"
Private cDesc1   := "Este programa destina-se a impressão do recibo do cliente"
Private cDesc2   := ""
Private cDesc3   := ""
Private cString  := "SE1"
Private wNrel    := "FIN1000"
Private lEnd     := .F.
Private cPerg    := "FIN1000"
Private aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
Private nLastKey := 0

SX1->(dbSeek(xFilial("SX1")+cPerg,.T.))                                                                  
If SX1->(!Found())
	AADD(aPergs,{"Prefixo  ","Prefixo  ","Prefixo  ","mv_ch1","C",03,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SE1001","","","",""})
	AADD(aPergs,{"Numero   ","Numero   ","Numero   ","mv_ch2","C",09,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aPergs,{"Tipo     ","Tipo     ","Tipo     ","mv_ch3","C",03,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aPergs,{"Visualiza","Visualiza","Visualiza","mv_ch4","N",01,0,0,"C","","MV_PAR04","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","",""})

	AjustaSx1("FIN1000",aPergs)
Endif

Pergunte(cPerg,.F.)

Wnrel := SetPrint(cString,Wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

If nLastKey == 27
	Set Filter to
	Return
Endif                 

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

If (Select("TRB") <> 0)
	dbSelectArea("TRB")
	dbCloseArea()
Endif		

dbSelectArea("SE1")
                                                                                                                                            
AADD(aCampos,{"E1_FILIAL"	,"C",TAMSX3('E1_FILIAL')[1],0})
AADD(aCampos,{"E1_FLAG"		,"C",02,0})
AADD(aCampos,{"E1_PREFIXO"	,"C",03,0})
AADD(aCampos,{"E1_NUM"		,"C",09,0})
AADD(aCampos,{"E1_PARCELA"	,"C",02,0})
AADD(aCampos,{"E1_TIPO"		,"C",03,0})
AADD(aCampos,{"E1_CLIENTE"	,"C",06,0})
AADD(aCampos,{"E1_LOJA"		,"C",02,0})
AADD(aCampos,{"E1_NOMCLI"	,"C",30,0})
AADD(aCampos,{"E1_EMISSAO"	,"D",08,0})
AADD(aCampos,{"E1_VENCREA"	,"D",08,0})
AADD(aCampos,{"SALDO"		,"N",12,2})


AADD(aBrowse,{"E1_FLAG   ","       ","@!",TAMSX3('E1_FILIAL')[1],0,".T."})
AADD(aBrowse,{"E1_FILIAL","       ","@!",02,0,".T."})
AADD(aBrowse,{"E1_PREFIXO","Prefixo","@!",03,0,".T."}) 
AADD(aBrowse,{"E1_NUM    ","Numero ","@!",09,0,".T."}) 
AADD(aBrowse,{"E1_PARCELA","Parcela","@!",02,0,".T."})
AADD(aBrowse,{"E1_TIPO   ","Tipo   ","@!",03,0,".T."})
AADD(aBrowse,{"E1_CLIENTE","Cliente","@!",06,0,".T."})
AADD(aBrowse,{"E1_LOJA   ","Loja   ","@!",02,0,".T."})
AADD(aBrowse,{"E1_NOMCLI ","Nome   ","@!",30,0,".T."})
AADD(aBrowse,{"E1_EMISSAO","Emissão","@!",08,0,".T."})
AADD(aBrowse,{"E1_VENCREA","Vencto ","@!",08,0,".T."})
AADD(aBrowse,{"SALDO     ","Saldo  ","@E 9,999,999.99",12,2,".T."})

//cNomeArq := CriaTrab(aCampos,.T.)
//dbUseArea(.T.,__LocalDriver,cNomeArq,"TRB",.F.,.F.)  
if select('TRB')>0	
	TRB->(dbCloseArea())
Endif
oTmp := FWTemporaryTable( ):New('TRB')
oTmp:SetFields(aCampos)
oTmp:AddIndex("01", { "E1_FILIAL","E1_PREFIXO", "E1_NUM", "E1_PARCELA"} )
oTmp:Create( )
_cNomeArq:= oTmp:GetAlias( )
        

cQuery := " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, SUM(E1_SALDO) SALDO "
cQuery += " FROM " + RetSQLName("SE1") + " SE1 "
cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND E1_PREFIXO = '"+mv_par01+"' "
cQuery += " AND E1_NUM = '"+mv_par02+"' "
cQuery += " AND E1_TIPO = '"+mv_par03+"' "
cQuery += " GROUP BY  E1_FILIAL,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA "
cQuery += " ORDER BY E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "

SqlToTrb(cQuery,aCampos,"TRB")

TRB->(dbGoTop())
AADD(aButtons,{"EDIT",{|| MarkAll(lMarca)},"Marca Todos","Marca Todos"})

@ 143,290 To 447,955 Dialog oDlg Title OemToAnsi("Impressão Recibo Cliente")
@ 030,001 To 150,334 Browse "TRB" Fields aBrowse Mark "E1_FLAG" Object oFields

InitMark()

Activate Dialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))

Return

//------------------------
Static Function MONTAREL()

Local oPrint
Local oFont6
Local oFont6n
Local oFont8
Local oFont8n
Local oFont10
Local oFont10n                 
Local oFont12
Local oFont12n
Local oFont14
Local oFont14n
Local nRow1  := 0
Local nTotal := 0
Local Lin    := 0
Local aBmp   := "SENTAXBR.JPG"
Local aBmp1  := "PACMAN.JPG"

oFont6   := TFont():New("Arial",9,6,.T.,.T.,5,.T.,5,.T.,.F.)
oFont6n  := TFont():New("Arial",9,6,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8n  := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10n := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12n := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)

oPrint := TMSPrinter():New("Recibo Cliente")

oPrint:ResetPrinter()
oPrint:SetPortrait()
oPrint:StartPage()

If !oPrint:IsPrinterActive()
	oPrint:SetUp()
Endif

TRB->(dbGoTop())
While TRB->(!Eof())
	If Marked("E1_FLAG")
		nTotal := nTotal + TRB->SALDO
	Endif
   	TRB->(dbSkip())
Enddo

ProcRegua(RecCount())
TRB->(dbGoTop())
If TRB->(!Eof())
	IncProc("Processando... Aguarde")

	//Box primeira via
	oPrint:Box(0050,0150,1470,2350) 

	//Box segunda via
	oPrint:Box(1600,0150,3030,2350) 

    //Logo primeira via
	oPrint:SayBitmap(nRow1+0100,0200,aBmp,0350,0200 )

    //Logo segunda via
	oPrint:SayBitmap(nRow1+1650,200,aBmp,0350,0200 )

	//Cabeçalho primeira via
	oPrint:Say  (nRow1+0100,2300,"RECIBO",oFont8n,,,,1)
	oPrint:Say  (nRow1+0150,2300,TRB->E1_NUM,oFont12,,,,1)
	oPrint:Say  (nRow1+0200,2300,"VALOR",oFont8n,,,,1)
	oPrint:Say  (nRow1+0250,2300,Transform(nTotal,"@E 9,999,999.99"),oFont12,,,,1)

	oPrint:Say  (nRow1+0100,0600,UPPER(Alltrim(SM0->M0_NOMECOM)),oFont12)
	oPrint:Say  (nRow1+0150,0600,UPPER(Alltrim(SM0->M0_ENDENT)),oFont12)
	oPrint:Say  (nRow1+0200,0600,UPPER(Alltrim(SM0->M0_BAIRENT)),oFont12)
	oPrint:Say  (nRow1+0200,1300,UPPER(Alltrim(Transform(SM0->M0_CEPENT,"@R 99999-999"))),oFont12)
	oPrint:Say  (nRow1+0250,0600,UPPER(Alltrim(SM0->M0_CIDENT)),oFont12)
	oPrint:Say  (nRow1+0250,1300,UPPER(Alltrim(SM0->M0_ESTENT)),oFont12)
	oPrint:Say  (nRow1+0300,0600,"FONE: "+UPPER(Alltrim(Transform(SM0->M0_TEL,"@R 9999-9999"))),oFont12)
	oPrint:Say  (nRow1+0300,1300,"FAX: "+UPPER(Alltrim(Transform(SM0->M0_FAX,"@R 9999-9999"))),oFont12)

	oPrint:Line (nRow1+0350,0200,nRow1+0350,2300)
	oPrint:Line (nRow1+0360,0200,nRow1+0360,2300)

	//Cabeçalho segunda via
	oPrint:Say  (nRow1+1650,2300,"RECIBO",oFont8n,,,,1)
	oPrint:Say  (nRow1+1700,2300,TRB->E1_NUM,oFont12,,,,1)
	oPrint:Say  (nRow1+1750,2300,"VALOR",oFont8n,,,,1)
	oPrint:Say  (nRow1+1800,2300,Transform(nTotal,"@E 9,999,999.99"),oFont12,,,,1)

	oPrint:Say  (nRow1+1650,0600,UPPER(Alltrim(SM0->M0_NOMECOM)),oFont12)
	oPrint:Say  (nRow1+1700,0600,UPPER(Alltrim(SM0->M0_ENDENT)),oFont12)
	oPrint:Say  (nRow1+1750,0600,UPPER(Alltrim(SM0->M0_BAIRENT)),oFont12)
	oPrint:Say  (nRow1+1750,1300,UPPER(Alltrim(Transform(SM0->M0_CEPENT,"@R 99999-999"))),oFont12)
	oPrint:Say  (nRow1+1800,0600,UPPER(Alltrim(SM0->M0_CIDENT)),oFont12)
	oPrint:Say  (nRow1+1800,1300,UPPER(Alltrim(SM0->M0_ESTENT)),oFont12)
	oPrint:Say  (nRow1+1850,0600,"FONE: "+UPPER(Alltrim(Transform(SM0->M0_TEL,"@R 9999-9999"))),oFont12)
	oPrint:Say  (nRow1+1850,1300,"FAX: "+UPPER(Alltrim(Transform(SM0->M0_FAX,"@R 9999-9999"))),oFont12)

	oPrint:Line (nRow1+1900,0200,nRow1+1900,2300)
	oPrint:Line (nRow1+1910,0200,nRow1+1910,2300)

	//Informações cliente primeira via
	oPrint:Say  (nRow1+0390,0200,"INFORMAÇÕES CLIENTE",oFont8n)
	oPrint:Line (nRow1+0440,0200,nRow1+0440,2300)
	oPrint:Say  (nRow1+0470,0200,Alltrim(TRB->E1_CLIENTE)+"-"+Alltrim(TRB->E1_LOJA)+" / "+Posicione("SA1",1,xFilial("SA1")+TRB->E1_CLIENTE+TRB->E1_LOJA,"A1_NOME"),oFont10)
	oPrint:Say  (nRow1+0520,0200,Posicione("SA1",1,xFilial("SA1")+TRB->E1_CLIENTE+TRB->E1_LOJA,"A1_END"),oFont10)

	//Informações cliente segunda via
	oPrint:Say  (nRow1+1940,0200,"INFORMAÇÕES CLIENTE",oFont8n)
	oPrint:Line (nRow1+1990,0200,nRow1+1990,2300)
	oPrint:Say  (nRow1+2020,0200,Alltrim(TRB->E1_CLIENTE)+"-"+Alltrim(TRB->E1_LOJA)+" / "+Posicione("SA1",1,xFilial("SA1")+TRB->E1_CLIENTE+TRB->E1_LOJA,"A1_NOME"),oFont10)
	oPrint:Say  (nRow1+2070,0200,Posicione("SA1",1,xFilial("SA1")+TRB->E1_CLIENTE+TRB->E1_LOJA,"A1_END"),oFont10)

	//Dados titulo primeira via
	oPrint:Say  (nRow1+0620,0200,"REFERENTE AO(S) TITULO(S)",oFont8n)
	oPrint:Line (nRow1+0670,0200,nRow1+0670,2300)

	oPrint:Say  (nRow1+0690,0200,"PRE",oFont6n)
	oPrint:Say  (nRow1+0690,0280,"NÚMERO",oFont6n)
	oPrint:Say  (nRow1+0690,0480,"PC",oFont6n)
	oPrint:Say  (nRow1+0690,0580,"TP",oFont6n)
	oPrint:Say  (nRow1+0690,0780,"CLIENTE",oFont6n)
	oPrint:Say  (nRow1+0690,1400,"EMISSÃO",oFont6n)
	oPrint:Say  (nRow1+0690,1650,"VENCIMENTO",oFont6n)
	oPrint:Say  (nRow1+0690,2300,"VALOR",oFont6n,,,,1)

	oPrint:Line (nRow1+0720,0200,nRow1+0720,2300)

	nLin := 0700

	TRB->(dbGoTop())
	While TRB->(!Eof())
		If Marked("E1_FLAG")
			nlin := nLin + 50
			oPrint:Say  (nRow1+nLin,0200,Alltrim(TRB->E1_PREFIXO),oFont10)
			oPrint:Say  (nRow1+nLin,0280,Alltrim(TRB->E1_NUM),oFont10)
			oPrint:Say  (nRow1+nLin,0480,Alltrim(TRB->E1_PARCELA),oFont10)
			oPrint:Say  (nRow1+nLin,0580,Alltrim(TRB->E1_TIPO),oFont10)
			oPrint:Say  (nRow1+nLin,0780,Alltrim(TRB->E1_NOMCLI),oFont10)
			oPrint:Say  (nRow1+nLin,1400,Substr(Dtos(TRB->E1_EMISSAO),7,2)+"/"+Substr(Dtos(TRB->E1_EMISSAO),5,2)+"/"+Substr(Dtos(TRB->E1_EMISSAO),1,4),oFont10)
			oPrint:Say  (nRow1+nLin,1650,Substr(Dtos(TRB->E1_VENCREA),7,2)+"/"+Substr(Dtos(TRB->E1_VENCREA),5,2)+"/"+Substr(Dtos(TRB->E1_VENCREA),1,4),oFont10)
			oPrint:Say  (nRow1+nLin,2300,Transform(TRB->SALDO,"@E 9,999,999.99"),oFont10,,,,1)
    	Endif
		TRB->(dbSkip())		
	Enddo    

	//Dados titulo segunda via
	oPrint:Say  (nRow1+2170,0200,"REFERENTE AO(S) TITULO(S)",oFont8n)
	oPrint:Line (nRow1+2220,0200,nRow1+2220,2300)

	oPrint:Say  (nRow1+2240,0200,"PRE",oFont6n)
	oPrint:Say  (nRow1+2240,0280,"NÚMERO",oFont6n)
	oPrint:Say  (nRow1+2240,0480,"PC",oFont6n)
	oPrint:Say  (nRow1+2240,0580,"TP",oFont6n)
	oPrint:Say  (nRow1+2240,0780,"CLIENTE",oFont6n)
	oPrint:Say  (nRow1+2240,1400,"EMISSÃO",oFont6n)
	oPrint:Say  (nRow1+2240,1650,"VENCIMENTO",oFont6n)
	oPrint:Say  (nRow1+2240,2300,"VALOR",oFont6n,,,,1)

	oPrint:Line (nRow1+2270,0200,nRow1+2270,2300)

	nLin := 2250

	TRB->(dbGoTop())
	While TRB->(!Eof())
		If Marked("E1_FLAG")
			nlin := nLin + 50
			oPrint:Say  (nRow1+nLin,0200,Alltrim(TRB->E1_PREFIXO),oFont10)
			oPrint:Say  (nRow1+nLin,0280,Alltrim(TRB->E1_NUM),oFont10)
			oPrint:Say  (nRow1+nLin,0480,Alltrim(TRB->E1_PARCELA),oFont10)
			oPrint:Say  (nRow1+nLin,0580,Alltrim(TRB->E1_TIPO),oFont10)
			oPrint:Say  (nRow1+nLin,0780,Alltrim(TRB->E1_NOMCLI),oFont10)
			oPrint:Say  (nRow1+nLin,1400,Substr(Dtos(TRB->E1_EMISSAO),7,2)+"/"+Substr(Dtos(TRB->E1_EMISSAO),5,2)+"/"+Substr(Dtos(TRB->E1_EMISSAO),1,4),oFont10)
			oPrint:Say  (nRow1+nLin,1650,Substr(Dtos(TRB->E1_VENCREA),7,2)+"/"+Substr(Dtos(TRB->E1_VENCREA),5,2)+"/"+Substr(Dtos(TRB->E1_VENCREA),1,4),oFont10)
			oPrint:Say  (nRow1+nLin,2300,Transform(TRB->SALDO,"@E 9,999,999.99"),oFont10,,,,1)
    	Endif
		TRB->(dbSkip())		
	Enddo    

	//Rodapé primeira via
	oPrint:Say  (nRow1+1050,0200,"A IMPORTÂNCIA DE",oFont8n)
	oPrint:Line (nRow1+1100,0200,nRow1+1100,2300)
	oPrint:Say  (nRow1+1130,0200,EXTENSO(nTotal),oFont10)
	oPrint:Line (nRow1+1180,0200,nRow1+1180,2300)

	oPrint:Say  (nRow1+1350,0200,"_________/_________/_________",oFont8n)
	oPrint:Say  (nRow1+1400,0365,"DATA",oFont10)
	oPrint:Line (nRow1+1380,1550,nRow1+1380,2300)
	oPrint:Say  (nRow1+1400,1775,"ASSINATURA",oFont10)

	//Rodapé segunda via
	oPrint:Say  (nRow1+2600,0200,"A IMPORTÂNCIA DE",oFont8n)
	oPrint:Line (nRow1+2650,0200,nRow1+2650,2300)
	oPrint:Say  (nRow1+2680,0200,EXTENSO(nTotal),oFont10)
	oPrint:Line (nRow1+2730,0200,nRow1+2730,2300)

	oPrint:Say  (nRow1+2900,0200,"_________/_________/_________",oFont8n)
	oPrint:Say  (nRow1+2950,0365,"DATA",oFont10)
	oPrint:Line (nRow1+2930,1500,nRow1+2930,2300)
	oPrint:Say  (nRow1+2950,1775,"ASSINATURA",oFont10)

    //Logo pacman
	oPrint:SayBitmap(nRow1+1510,0005,aBmp1,0050,0050 )
    
	//Linha pontilhada
	oPrint:Say	(nRow1+1520,0050,Replicate("- ",2350) , oFont6n)
Endif

oPrint:EndPage()

If mv_par04 == 1
	oPrint:Preview()
Else
	oPrint:Print()
Endif

dbSelectArea("TRB")
dbCloseArea("TRB")

oPrint:END()

Return

//-----------------------------------------------------------
//Rotina utilizada para inicialização das marcações no browse
//-----------------------------------------------------------
Static Function InitMark()

TRB->(dbGoTop())
While TRB->(!Eof())                             
	RecLock("TRB",.F.)
	TRB->E1_FLAG := ThisMark()
	TRB->(MsUnlock())
			
	TRB->(dbSkip())	
Enddo      

TRB->(dbGoTop())

Return

//---------------------------------------
//Marca todos os registros para impressão
//---------------------------------------    
Static Function MarkAll(lMarca)

Local nRecAtu := TRB->(Recno())

TRB->(dbGoTop())
While TRB->(!Eof())
	Reclock("TRB",.F.)
	TRB->E1_FLAG := IIF(lMarca,Space(2),GetMark())
	TRB->(MsUnlock())

	TRB->(dbSkip())
Enddo	

TRB->(dbGoTop(nRecAtu))
lMarca := !lMarca

Return        

Static Function AjustaSX1()
Local aArea:= GetArea() 
PutSx1("FIN1000","01","Prefixo  ","Prefixo","Prefixo    ","mv_ch1","C",03,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SE1001","","","","")
PutSx1("FIN1000","01","Numero   ","Numero   ","Numero   ","mv_ch2","C",09,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSx1("FIN1000","01","Tipo     ","Tipo     ","Tipo     ","mv_ch3","C",03,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSx1("FIN1000","01","Visualiza","Visualiza","Visualiza","mv_ch4","N",01,0,0,"C","","MV_PAR04","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","")

RestArea(aArea)
Return()
