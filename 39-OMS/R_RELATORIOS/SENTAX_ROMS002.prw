#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"                                                                                 

#define nLinMax 2650	// Numero maximo de Linhas
#define nColIni 0070	// Coluna inicial
#define nCol001	0070	// Data	/ Informações entrega 1	
#define nCol002	0250	// Hora
#define nCol003	0350	// Nota Fiscal
#define nCol004	0550	// Série
#define nCol005	0660	// Volumes
#define nCol006	0790	// Razão
#define nCol007	1050	// Informações entrega 2
#define nCol008	1350	// Val. Bruto NF
#define nCol009	1650	// Municipio
#define nCol010	2120	// Estado  
#define nColMax	2220	// Numero maximo de Colunas	 
#define nEspaco	0030 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ROMS002 
Relatório do Romaneio
	
@author		Alessandro Smaha
@since		15/05/2014

/*/
//-------------------------------------------------------------------------------
User Function ROMS002(cCodRom1,lAuto)
 
Local aArea 	:= GetArea()
Local aAreaSA1 	:= SA1->(GetArea())
Local aAreaSA4 	:= SA4->(GetArea())
Local aAreaSD2 	:= SD2->(GetArea()) 
Local lImpRel	:= .F.

Default cCodRom1 := ""  
Default lAuto	 := .F.

Private cPerg := "ROMS002" 
Private _oFontC10  := TFont():New("Courier",10,10,,.F.,,,,.T.,.F.)	//Courier 10 sem negrigo
Private _oFontC10N := TFont():New("Courier",10,10,,.T.,,,,.T.,.F.)	//Courier 10 com negrigo
Private _oFontA12  := TFont():New("Arial",  12,12,,.F.,,,,.T.,.F.)	//Arial   12 sem negrigo
Private _oFontC12N := TFont():New("Courier",12,12,,.T.,,,,.T.,.F.)	//Courier 12 com negrigo 
Private _oFontA14  := TFont():New("Arial",  14,14,,.F.,,,,.T.,.F.)	//Arial   14 sem negrigo
Private _oFontA14N := TFont():New("Arial",  14,14,,.T.,,,,.T.,.F.)	//Arial   14 com negrigo
	             
AjustaSx1(cPerg) 

If !Empty(cCodRom1)

	Pergunte(cPerg,.F.)
	
	MV_PAR01 := cCodRom1 	   			   			// Romaneio de
	MV_PAR02 := cCodRom1 				   			// Romaneio até
	MV_PAR03 := SPACE(TAMSX3("A4_COD")[1]) 			// Transportadora de
	MV_PAR04 := REPLICATE("Z",TAMSX3("A4_COD")[1])	// Transportadora ate
	MV_PAR05 := SPACE(TAMSX3("D2_DOC")[1])			// NF de
	MV_PAR06 := REPLICATE("Z",TAMSX3("D2_DOC")[1])	// NF até
	MV_PAR07 := CTOD ("  /  /    ")					// Emissão de
	MV_PAR08 := CTOD ("01/01/2050")					// Emissão até  
	MV_PAR09 := 2									// Tipo de Impressão 1=Curitiba,2=Interior 
	
	lImpRel	:= .T. 
	
Else   

	If Pergunte(cPerg,.T.) 
		lImpRel	:= .T.
	EndIf
	
EndIf

If lImpRel
	fDefineRel(lAuto)     	
EndIF

Return        


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fDefineRel 
Definições do relatório
	
@author		Alessandro Smaha
@since		15/05/2014

/*/
//-------------------------------------------------------------------------------
Static Function fDefineRel(lAuto)

Local cAliasTemp := GetNextAlias()   
Local lCuritiba	:= IIF( MV_PAR09 == 1 , .T., .F. ) // 1=Curitiba, 2=Interior

BeginSql  Alias cAliasTemp
	
	SELECT DISTINCT Z04_FILIAL, Z04_COD, Z04_SEQ,Z04_NFISCA, Z04_SERIE,Z04_CLIENT,Z04_LOJA, Z04_TOTALV ,Z04_VALOR ,Z04_DATA, 
					Z04_HORA, Z03_TRANSP, Z03_IDUSER, Z03_PLACA, Z03_MOTORI, A4_NOME, A1_NOME, A1_MUN, A1_EST, 
					( 	SELECT SUM(D2_QUANT) 
						FROM %Table:SD2% SD2 
						WHERE 	D2_FILIAL = Z04_FILIAL 
								AND D2_DOC = Z04_NFISCA 
								AND D2_SERIE = Z04_SERIE 
								AND SD2.%NotDel% ) AS QUANT 
	FROM %Table:Z04% Z04 
	INNER JOIN %Table:Z03% Z03 ON (	Z04_FILIAL = Z03_FILIAL AND Z04_COD = Z03_COD 
												AND Z03_TRANSP  >= %Exp:MV_PAR03% 
												AND Z03_TRANSP  <= %Exp:MV_PAR04%  
												AND Z03.%NotDel%) 
	LEFT JOIN %Table:SA4% SA4 ON 	A4_FILIAL  = %xFilial:SA4%
									AND A4_COD = Z03_TRANSP 
									AND SA4.%NotDel%
	LEFT JOIN %Table:SA1% SA1 ON 	A1_FILIAL  = %xFilial:SA1%
									AND A1_COD = Z04_CLIENT  
									AND A1_LOJA = Z04_LOJA
									AND SA1.%NotDel%
	WHERE  Z04_FILIAL = %xFilial:Z04%
		AND Z04_COD 	BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND Z04_NFISCA 	BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
		AND Z04_DATA 	BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% 
		AND Z04.%NotDel%   
	ORDER BY  Z04_COD		

EndSql

DbSelectArea(cAliasTemp)

(cAliasTemp)->(DbGoTop())

If (cAliasTemp)->(!Eof())

	If !lAuto
		Processa( { || fPrintRel(cAliasTemp,lAuto,lCuritiba) } )
	Else
		fPrintRel(cAliasTemp,lAuto,lCuritiba)
	Endif

ElseIf !lAuto

	Alert("Não existem dados a serem impressos com os parâmetros selecionados.")
Else

	Conout("Não existem dados a serem impressos com os parâmetros selecionados.")

Endif

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fPrintRel 
Impressão do relatório
	
@author		Alessandro Smaha
@since		15/05/2014

/*/
//-------------------------------------------------------------------------------
Static Function fPrintRel(cAliasTemp,lAuto,lCuritiba)  

Local nTotItm	:= 0
Local nTotVol	:= 0             
Local nTotVal	:= 0
Local nPage		:= 1
Local li		:= 0 
Local cHoraAtu	:= Time()
Local dDataAtu  := dDataBase

Local lImpTot	:= .F.

PRIVATE cFileName	:= "ROMS002_"+cEmpAnt+"_"+cFilAnt+"_"+Dtos(MSDate())+"_"+StrTran(Time(),":","")   
PRIVATE oPrint   
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1, "", 1, 1, 1, "",1 }
PRIVATE dOpeDe  	:= ctod("")
PRIVATE dOpeAte 	:= ctod("") 
PRIVATE cSitua  	:= ""
PRIVATE cTipo   	:= ""
PRIVATE cOpera  	:= ""
PRIVATE cEmpDe  	:= ""
PRIVATE cConDe  	:= ""
PRIVATE cVerCo  	:= ""
PRIVATE cSubDe  	:= ""
PRIVATE cVerSu  	:= ""
PRIVATE cTitulo     := "Romaneio"
PRIVATE cDesc1      := "Impressão Romaneio de Transportadoras"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cTamanho    := "G"    
Private oPrint

ProcRegua(0)
IncProc("Processando... Aguarde")

If lAuto

	oPrint := FWMSPrinter():New(cFileName,IMP_SPOOL, .T., , .T.,.F.,,"HP_ROMANEIO",.T.)
	oPrint:SetPortrait()
  
	oPrint:cPrinter := "HP_ROMANEIO" 
	oPrint:lServer  := .T.

Else 

	oPrint := FWMSPrinter():New(cFileName,IMP_SPOOL)
	oPrint:SetPortrait() 

Endif       

oPrint:SetResolution(72)

If (cAliasTemp)->(!Eof()) 
     
	oPrint:StartPage()
	fPrintCab(@li,@nPage,(cAliasTemp)->Z03_TRANSP,(cAliasTemp)->A4_NOME,(cAliasTemp)->Z04_COD,(cAliasTemp)->Z03_PLACA,(cAliasTemp)->Z03_MOTORI,nPage,dDataAtu,cHoraAtu)	
	cTransp := (cAliasTemp)->Z03_TRANSP
	
	While (cAliasTemp)->(!Eof())
	
		nTotItm++ 
		nTotVol += (cAliasTemp)->Z04_TOTALV
		nTotVal += (cAliasTemp)->Z04_VALOR  
		lImpTot	:= .T. 
		cCodMot := Capital((cAliasTemp)->Z03_MOTORI)
		cCodUsr := Capital((cAliasTemp)->Z03_IDUSER)
	
		If cTransp <> (cAliasTemp)->Z03_TRANSP   
			// Imprime totais                
			lImpTot	:= .F.
			fImpTotal(@li,@nPage,@nTotItm,@nTotVol,@nTotVal,cCodUsr,cCodMot)
			oPrint:EndPage() // Finaliza a pagina
			oPrint:StartPage()
			nPage++
			fPrintCab(@li,@nPage,(cAliasTemp)->Z03_TRANSP,(cAliasTemp)->A4_NOME,(cAliasTemp)->Z04_COD,(cAliasTemp)->Z03_PLACA,(cAliasTemp)->Z03_MOTORI,nPage,dDataAtu,cHoraAtu)	
		EndIf 
		
		If lCuritiba
			
			If li > (nLinMax-380) 
				oPrint:Line( li + nEspaco, nColIni, li + nEspaco, nColMax )
		   		oPrint:EndPage() // Finaliza a pagina
				oPrint:StartPage()
				nPage++
				fPrintCab(@li,@nPage,(cAliasTemp)->Z03_TRANSP,(cAliasTemp)->A4_NOME,(cAliasTemp)->Z04_COD,(cAliasTemp)->Z03_PLACA,(cAliasTemp)->Z03_MOTORI,nPage,dDataAtu,cHoraAtu)	
		   	EndIf
		   	
		Else
				
			If li > (nLinMax-220) 
				oPrint:Line( li + nEspaco, nColIni, li + nEspaco, nColMax )
		   		oPrint:EndPage() // Finaliza a pagina
				oPrint:StartPage()
				nPage++
				fPrintCab(@li,@nPage,(cAliasTemp)->Z03_TRANSP,(cAliasTemp)->A4_NOME,(cAliasTemp)->Z04_COD,(cAliasTemp)->Z03_PLACA,(cAliasTemp)->Z03_MOTORI,nPage,dDataAtu,cHoraAtu)	
		   	EndIf     
		   	
	   	EndIf
	   	
	   	li += nEspaco 

		oPrint:Say(li, nCol001, DtoC(StoD((cAliasTemp)->Z04_DATA)), _oFontC10) 
		oPrint:Say(li, nCol002, Substr((cAliasTemp)->Z04_HORA,1,2)+":"+Substr((cAliasTemp)->Z04_HORA,3,2), _oFontC10)
		oPrint:Say(li, nCol003, (cAliasTemp)->Z04_NFISCA, _oFontC10) 
		oPrint:Say(li, nCol004, Alltrim((cAliasTemp)->Z04_SERIE), _oFontC10)
		oPrint:Say(li, nCol005, Transform((cAliasTemp)->Z04_TOTALV,PesqPict("SF2","F2_VOLUME1")), _oFontC10)
		oPrint:Say(li, nCol006, Substr((cAliasTemp)->A1_NOME,1,40), _oFontC10)
		oPrint:Say(li, nCol008, Transform((cAliasTemp)->Z04_VALOR,PesqPict("Z04","Z04_VALOR")), _oFontC10)
		oPrint:Say(li, nCol009, Substr((cAliasTemp)->A1_MUN,1,30), _oFontC10)
		oPrint:Say(li, nCol010, (cAliasTemp)->A1_EST, _oFontC10) 
		
		If lCuritiba
		
	  	 	li += nEspaco + nEspaco + nEspaco	  	 	
	  	 	oPrint:Say(li, nCol002, Replicate("-",32)+" INFORMAÇÕES DA ENTREGA "+Replicate("-",33), _oFontC12N)   
	  	 	
	  	 	li += nEspaco + nEspaco 
	  	 	oPrint:Say(li, nCol002, "(  ) FALTA DE MERCADORIA"			, _oFontC12N)
	  	 	oPrint:Say(li, nCol007, "(  ) FORA DO HORÁRIO DE ENTREGA"	, _oFontC12N)
	  	 	
	  	 	li += nEspaco + nEspaco
	  	 	oPrint:Say(li, nCol002, "(  ) CLIENTE FECHADO NO HORÁRIO COMERCIAL"	, _oFontC12N)
	  	 	oPrint:Say(li, nCol007, "(  ) ENTREGA PREJUDICADA POR HORÁRIO" 		, _oFontC12N)

			li += nEspaco + nEspaco
	  	 	oPrint:Say(li, nCol002, "(  ) ENDEREÇO INCORRETO"			, _oFontC12N)  
	  	 	
	  	 	li += nEspaco + nEspaco 
	  	 	
		EndIf
		
		(cAliasTemp)->(DbSkip())
	EndDo
	If lImpTot
		fImpTotal(@li,@nPage,@nTotItm,@nTotVol,@nTotVal,cCodUsr,cCodMot)
		oPrint:EndPage() // Finaliza a pagina
	EndIf
EndIf 

oPrint:Print()

Return    


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fImpTotal 
Impressão dos totalizadores
	
@author		Alessandro Smaha
@since		15/05/2014

/*/
//-------------------------------------------------------------------------------
Static Function fImpTotal(li,nPage,nTotItm,nTotVol,nTotVal,cCodUsr,cMotorista)

li+=nEspaco+nEspaco
	
oPrint:Say(li, nCol001, "Total", _oFontC10)
li+=5
oPrint:Line(li+3,nColIni,li,nColMax) 

li+=nEspaco

oPrint:Say(li, nCol003, cValToChar(nTotItm), _oFontC10)   
oPrint:Say(li, nCol005, Transform(nTotVol,PesqPict("SF2","F2_VOLUME1")), _oFontC10)
oPrint:Say(li, nCol008, Transform(nTotVal,PesqPict("Z04","Z04_VALOR")) , _oFontC10)

li := nLinMax+100
 
oPrint:SayAlign (li, nCol001,   Replicate("_",50), 		_oFontA14N, nColMax/2,  100, , 2, 1 ) 
oPrint:SayAlign (li, nColMax/2, Replicate("_",50),		_oFontA14N, nColMax/2,  100, , 2, 1 )  

li+=nEspaco+10

oPrint:SayAlign (li, nCol001,   Upper(cMotorista),						_oFontA14N, nColMax/2,  100, , 2, 1 )
oPrint:SayAlign (li, nColMax/2, Upper(Alltrim(UsrFullName(cCodUsr))),	_oFontA14N, nColMax/2,  100, , 2, 1 ) 

li+=nEspaco+10  

oPrint:SayAlign (li, nCol001,   "Motorista",	   		_oFontA14N, nColMax/2,  100, , 2, 1 )
oPrint:SayAlign (li, nColMax/2, "Conferente",			_oFontA14N, nColMax/2,  100, , 2, 1 ) 

nTotItm := 0
nTotVol := 0
nTotVal := 0
	
Return  


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fPrintCab 
Impressão do cabeçalho
	
@author		Alessandro Smaha
@since		15/05/2014

/*/
//-------------------------------------------------------------------------------
Static Function fPrintCab(li,nPage,cCdTrans,cNmTrans,cCodRom,cPlaca,cMotorista,nPage,dDataAtu,cHoraAtu)

Local cLogo 	:= "lgrl000.JPG"  

li := 050

oPrint:Line(li,nColIni,li,nColMax)
      
oPrint:SayBitmap( li+5,nColIni, cLogo, 180, 30)

// hor -> 0 esquerda 1 direita 2 centralizado ## ver -> 0 centralizado 1 - superior 2 - inferior

oPrint:SayAlign (li, nCol001, "Folha: "+cValToChar(nPage),	_oFontA14, nColMax-70, 100, , 1, 1 ) ; li += nEspaco+10 

oPrint:SayAlign (li, nCol001, "SIGA/ROMS002/v.11",			_oFontA14, nColMax,    100, , 0, 1 ) 
oPrint:SayAlign (li, nCol001, "Romaneio", 			   		_oFontA14, nColMax-70, 100, , 2, 1 )
oPrint:SayAlign (li, nCol001, "Dt.Ref: "+DtoC(dDataAtu), 	_oFontA14, nColMax-70, 100, , 1, 1 ) ; li += nEspaco+10  

oPrint:SayAlign (li, nCol001, "Hora: "+cHoraAtu,			_oFontA14, nColMax,    100, , 0, 1 )
oPrint:SayAlign (li, nCol001, "Emissão: "+DtoC(dDataAtu),	_oFontA14, nColMax-70, 100, , 1, 1 )  ; li += nEspaco+10  

oPrint:SayAlign (li, nCol001, "Empresa: "+Alltrim(FwGrpName())+" / Filial: "+;
								Alltrim(FwFilialName()),_oFontA14, nColMax, 100, , 0, 1 )


li+=nEspaco+nEspaco+020   

oPrint:Line(li,nColIni,li,nColMax) 

li+=nEspaco+nEspaco 

oPrint:say(li, nCol001, "Transportadora: "+cCdTrans+" - "+cNmTrans,_oFontC10);li+=nEspaco
oPrint:say(li, nCol001, "Romaneio: "+cCodRom,_oFontC10);li+=nEspaco
oPrint:say(li, nCol001, "Placa: "+cPlaca,_oFontC10);li+=nEspaco
oPrint:say(li, nCol001, "Motorista: "+cMotorista,_oFontC10)  

li+=nEspaco

oPrint:Line(li,nColIni,li,nColMax) 

li+=nEspaco+nEspaco

oPrint:say(li, nCol001, "Data",		   		_oFontC10)
oPrint:say(li, nCol002, "Hora", 			_oFontC10)
oPrint:say(li, nCol003, "Nota Fiscal", 		_oFontC10)  
oPrint:say(li, nCol004, "Série", 	   		_oFontC10)
oPrint:say(li, nCol005, "Volume",	 	   	_oFontC10)
oPrint:say(li, nCol006, "Razão Social",		_oFontC10)
oPrint:say(li, nCol008, "    Vlr. Bruto NF",_oFontC10)
oPrint:say(li, nCol009, "Município" ,  		_oFontC10)
oPrint:say(li, nCol010, "Estado", 	   		_oFontC10)
li+=5
oPrint:Line(li,nColIni,li,nColMax) 

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do programa
	
@author		Alessandro Smaha
@since		15/05/2014
/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1()

	Local aHelpPerg  := {}
	
	aAdd(aHelpPerg,{"Código Romaneio De"})
	aAdd(aHelpPerg,{"Código Romaneio Até"})

	aAdd(aHelpPerg,{"Da Transportadora."})
	aAdd(aHelpPerg,{"Até a Transportadora."  })

	aAdd(aHelpPerg,{"Da Nota Fiscal "})
	aAdd(aHelpPerg,{"Até a Nota Fiscal "})

	aAdd(aHelpPerg,{"Data Emissão De."})
	aAdd(aHelpPerg,{"Até Data Emissão."  })
   
	aAdd(aHelpPerg,{"Tipo de impressão.", "Layout para Curitiba ou Interior"  })

	PutSX1(cPerg,"01","Romaneio de:"      	,"" ,"" ,"MV_CH1" ,"C",6,0,0,"G","","" 	,"018" 	,"S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})
	PutSX1(cPerg,"02","Até Romaneio:"     	,"" ,"" ,"MV_CH2" ,"C",6,0,0,"G","","" 	,"018" 	,"S","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPerg[2] ,{},{})
	PutSX1(cPerg,"03","Da Transportadora?"  ,"" ,"" ,"MV_CH3" ,"C",6,0,0,"G","","S04",""   	,"S","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPerg[3] ,{},{})
	PutSX1(cPerg,"04","Até Transportadora?" ,"" ,"" ,"MV_CH4" ,"C",6,0,0,"G","","S04",""   	,"S","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPerg[4] ,{},{})
	PutSX1(cPerg,"05","Da NF?"  			,"" ,"" ,"MV_CH5" ,"C",9,0,0,"G","","SF2",""   	,"S","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPerg[5] ,{},{})
	PutSX1(cPerg,"06","Até NF?" 			,"" ,"" ,"MV_CH6" ,"C",9,0,0,"G","","SF2",""    ,"S","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPerg[6] ,{},{})
	PutSX1(cPerg,"07","Data Emissão De?"    ,"" ,"" ,"MV_CH7" ,"D",8,0,0,"G","",""    ,"001","S","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPerg[7] ,{},{})
	PutSX1(cPerg,"08","Data Emissão ate?"   ,"" ,"" ,"MV_CH8" ,"D",8,0,0,"G","",""    ,"001","S","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPerg[8] ,{},{})
	PutSx1(cPerg,"09","Tipo Impressão?"		,"" ,"" ,"MV_CH9" ,"N",1,0,0,"C","","",""	   	,"S","MV_PAR09","Curitiba","","","","Interior","","","","","","","","","","","",aHelpPerg[9] ,{},{})
	
Return