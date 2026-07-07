 #INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopCONN.CH"
//-------------------------------------------------------------------

/*/{Protheus.doc} ATMK006
Manutencao de Metas de Vendas
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------CHAMADA TELA PRINCIPAL------------------------------------------------
User Function ATMK006(lImprime)
Local oMBrowse
Default lImprime:=.f.
Private lImp:=lImprime
Private CCADASTRO :="Lista Atendimento"

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("Z19")

IF limp

    // nPos:=aScan(oMBrowse:AHEADER,   {|X| ALLTRIM(X[2]) == 'Z19_TELE' })
  
    // MessageBox("DENTRO IMPRESSAO cTele:" + cTele ,"Processamento ARMK006 8",1)
	
	//oMBrowse:SetFilterDefault( "Z19_TELE=='"+oGdList:ACOLS[oMBrowse:nAt][nPos]+"'" )
	
	oMBrowse:SetFilterDefault( "Z19_TELE=='" + Alltrim(cTele) + "'" )  // Rogerio
	oMBrowse:AddFilter('Mes Ano', "Z19_MES='"+SUBSTR(DTOS(DDATABASE),5,2)+"' .AND. Z19_ANO='"+SUBSTR(DTOS(DDATABASE),1,4)+"'", .F., .T.)
	
	//oMBrowse:SetFilterDefault( "Z19_MES=='"+SUBST(DTOS(DDATABASE),5,2)+"'" )
	//oMBrowse:SetFilterDefault( "Z19_ANO=='"+SUBST(DTOS(DDATABASE),1,4)+"'" )
Else
	oMBrowse:SetMenuDef("SENTAX_ATMK006")	
EndIF
oMBrowse:AddLegend('Z19->Z19_STATUS=="1"',"GREEN" ,"Na periodicidade"    )
oMBrowse:AddLegend('Z19->Z19_STATUS=="2"',"BLUE" ,"Fora periodicidade"    )
oMBrowse:AddLegend('Z19->Z19_STATUS=="3"',"GRAY" ,"Sem ped. period."    )
oMBrowse:AddLegend('Z19->Z19_STATUS=="4"',"PINK" ,"Inativo"    )


oMBrowse:AddStatusColumns({|| Status() }/*bStatus*/, {|| Legend() }/*bLDblClick*/)
//oMBrowse:SetLocate()
oMBrowse:DisableDetails()

oMBrowse:Activate()


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Modeldef
MONTA O MODELO DE DADOS
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function Modeldef()

Local oStructZ19 := Nil
Local oModel     := Nil
Local aAux       := {}

oStructZ19 := FWFormStruct(1,"Z19") //cria estrutura baseada no (dicionario)
oModel:= MPFormModel():New("ATMK006M")//cria o modelo de dados
oModel:SetDescription("Modelo de dados de Metas de Vendas")//descricao do modelo de dados
oModel:AddFields("ATMK006_Z19",  , oStructZ19 , {|| .T.}/*Pre-Validacao*/,{|| .T.}/*Pos-Validacao*/,/*Carga*/)//ADICIONA O COMPONENT AO FORMULARIO
oModel:GetModel ("ATMK006_Z19"):SetDescription("Dados de Metas de Vendas") //DESCRICAO DADOS
oModel:SetPrimaryKey({"Z19_FILIAL+Z19_MES+Z19_ANO"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
MONTA O MODELO DA INTERFACE
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oStructZ19
Local oModel := FWLoadModel("SENTAX_ATMK006")

oStructZ19 := FWFormStruct(2,"Z19")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( "ATMK006_Z19" , oStructZ19)
oView:CreateHorizontalBox("CABEC",100)
oView:SetOwnerView( "ATMK006_Z19","CABEC")
oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Status
mONTA A LEGENDA DE STATUS NA TELA DO BROWSE
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Status()

Local cImgRPO := ""

If Z19->Z19_STATU2=='1'
	cImgRPO:="BR_MARROM"
ElseIF Z19->Z19_STATU2=='2'
	cImgRpo := "BR_VERDE"
ElseIF Z19->Z19_STATU2=='3'
	cImgRpo := "BR_VERMELHO"
ElseIF Z19->Z19_STATU2=='4'
	cImgRpo := "BR_AMARELO"
ElseIF Z19->Z19_STATU2=='5'
	cImgRpo := "BR_AZUL"
ElseIF Z19->Z19_STATU2=='6'
	cImgRpo := "BR_PINK"
ElseIF Z19->Z19_STATU2=='7'
	cImgRpo := "BR_BRANCO"
ElseIF Z19->Z19_STATU2=='8'
	cImgRpo := "BR_LARANJA"
EndIF

Return cImgRPO

//-------------------------------------------------------------------
/*/{Protheus.doc} Legend
MONTA A LEGENDA DE STATUS NA TELA DO BROWSE
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Legend()

// Array das Legendas
Local aLegenda := {	{"BR_MARROM"		, "Não Realizado"	 		}, ;
{"BR_VERDE"			, "Pedido"				 	}, ;
{"BR_VERMELHO"		, "Comprou concorrente"		}, ;
{"BR_AMARELO"		, "Comprou com vendedor"	}, ;
{"BR_AZUL"			, "Orçamento"				}, ;
{"BR_PINK"			, "Tem estoque"				}, ;
{"BR_BRANCO"		, "Outro motivo"			}, ;
{"BR_LARANJA"		, "Reagendado"				}}"


BrwLegenda("Satus","Legenda",aLegenda)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
monta menu da rotina
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
// Local aRotina := {}  -- Rogerio 25/09
Private aRotina := {}

if !lImp
	ADD OPTION aRotina Title 'Visualizar' 	Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina Title 'Incluir' 		Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 		Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 4 ACCESS 0
	
	//ADD OPTION aRotina Title 'Excluir' 		Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 		Action 		'U_PER_EXCL()' OPERATION 3 ACCESS 0
	
	ADD OPTION aRotina Title 'Imprimir' 	Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 8 ACCESS 0
	ADD OPTION aRotina Title 'Gera Meta' 	Action 		'U_geraMeta()' 			 OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Recalcula' 	Action 		'U_repMeta()' 			 OPERATION 3 ACCESS 0
Else
	
	ADD OPTION aRotina Title 'Visualizar' 	Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina Title 'Incluir' 		Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 		Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 4 ACCESS 0 DISABLE MENU
	
	// ADD OPTION aRotina Title 'Excluir' 		Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 5 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina Title 'Excluir' 		Action 		'U_PER_EXCL()' OPERATION 3 ACCESS 0 DISABLE MENU
	
	ADD OPTION aRotina Title 'Imprimir' 	Action 		'VIEWDEF.SENTAX_ATMK006' OPERATION 8 ACCESS 0
	ADD OPTION aRotina Title 'Gera Meta' 	Action 		'U_geraMeta()' 			 OPERATION 3 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina Title 'Recalcula' 	Action 		'U_repMeta()' 			 OPERATION 3 ACCESS 0 DISABLE MENU
EndIF

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} geraMeta
Programa de calculo de metas
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------


User Function geraMeta()

Local oProcess//incluído o parâmetro lEnd para controlar o cancelamento da janela
Local cPerg:="STATMK006"
Private lEnd:=.t.
criasx1(cPerg)
IF !pergunte(cPerg)
	Return
EndIF

//Processa({||ProcMeta(.f.)} ,"Processando calculo de metas","Aguarde...",lAbort)
oProcess := MsNewProcess():New({|lEnd| ProcMeta(@oProcess, @lEnd , .f.) },"Processando metas","Lendo Cadastro de clientes",.T.)
oProcess:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} geraMeta
Programa de calculo de metas
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------


User Function repMeta()


Local oProcess//incluído o parâmetro lEnd para controlar o cancelamento da janela
Local cPerg:="STATMK006"
Private lEnd:=.t.

criasx1(cPerg)
IF !pergunte(cPerg)
	Return
EndIF
                                                                    
oProcess := MsNewProcess():New({|lEnd| ProcMeta(@oProcess, @lEnd , .T.) },"Processando metas","Lendo Cadastro de clientes",.T.)
oProcess:Activate()


//Processa({||ProcMeta(.t.)} ,"Reprocessando metas","Aguarde...",lAbort)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcMeta
Programa que processa o  calculo de metas
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------


Static Function ProcMeta(oProcess,lEnd,lRepro)


default lEnd	:= .f.

buscaDados()
       
nContT:=0
While !TRA1->(eof())
	nContT++
	TRA1->(dbSkip())
EndDO


oProcess:SetRegua1(nContT)
oProcess:SetRegua2(0)

ProcRegua(0)

nCont:=0
TRA1->(dbGotop())
While !TRA1->(eof())
	nCont++
	
	if lEnd
    	return
    EndIF        
		
	oProcess:IncRegua1("Calculando METAS...")
	oProcess:IncRegua2('Processando Cliente:  ' +TRA1->A1_COD+'-'+TRA1->A1_LOJA+'   '+cValtoChar(nCont) + ' de ' +cValtoChar(nContT))

	if substr(dtos((STOD(TRA1->A1_ULTCOM )+TRA1->A1_X_FREQ)),1,6)==substr(dtos(ddatabase),1,6)
		cStat1:="1"		
	ElseIf substr(dtos((STOD(TRA1->A1_ULTCOM )+TRA1->A1_X_FREQ)),1,6) > substr(dtos(ddatabase),1,6)
		cStat1:="2"
	ElseIf substr(dtos((STOD(TRA1->A1_ULTCOM )+TRA1->A1_X_FREQ)),1,6) < substr(dtos(ddatabase),1,6) ;
		.and. ddatabase - STOD(TRA1->A1_ULTCOM)+TRA1->A1_X_FREQ  <= 90  // Alteracao regra Rogerio 25/09
		cStat1:="1"
	ElseIf substr(dtos((STOD(TRA1->A1_ULTCOM )+TRA1->A1_X_FREQ)),1,6) < substr(dtos(ddatabase),1,6) ;
		.and. ddatabase - STOD(TRA1->A1_ULTCOM)+TRA1->A1_X_FREQ  <= 365 ;
		.and. ddatabase - STOD(TRA1->A1_ULTCOM)+TRA1->A1_X_FREQ  > 90 // Alteracao regra Rogerio 25/09
		cStat1:="3"
	Else
		cStat1:="4"
	EndIF

	if nCont == 1
		DBSelectArea('Z19')
		DBSetOrder(1)
		if DBSeek(xFilial('Z19')+MV_PAR02+MV_PAR01) .and. !lRepro
			alert("Este período ja foi calculado")
			return
		EndIf
	EndIf
	DBSelectArea('Z19')
	DBSetOrder(1)
	if DBSeek(xFilial('Z19')+MV_PAR02+MV_PAR01+TRA1->A1_COD+TRA1->A1_LOJA)
		RECLOCK('Z19',.f.)
		nMedia := CalcFat(MV_PAR04)/MV_PAR04
		IF nMedia==0
			nMedia := CalcFat(MV_PAR05)/MV_PAR05 
			IF nMedia>0
			     conout('maior')
			endif
		EndIF
				
		Z19->Z19_META 		:= nMedia+(nMedia*(mv_par03/100))
		Z19->Z19_MEDIA 		:= nMedia
		Z19->Z19_DDD		:= TRA1->A1_DDD
		Z19->Z19_TEL		:= TRA1->A1_TEL
		Z19->Z19_NROCOM		:= TRA1->A1_NROCOM
		Z19->Z19_NVEND		:= POSICIONE('SA3',1,XFILIAL('SA3')+TRA1->A1_VEND,'A3_NOME')
		
		// Rogerio C Lemos 21/09 - Revisao quando reprocessa, nao estava atualizando TELE e Vendedor		
		Z19->Z19_TELE 		:= TRA1->A1_XTELEVE
		Z19->Z19_VEND 		:= TRA1->A1_VEND
		Z19->Z19_STATUS 	:= cStat1
				
	Else
		RECLOCK('Z19',.T.)
		Z19->Z19_FILIAL 	:= xFilial('Z19')
		Z19->Z19_ANO 		:= MV_PAR01
		Z19->Z19_MES 		:= MV_PAR02
		Z19->Z19_STATUS 	:= cStat1
		Z19->Z19_STATU2 	:= "1"
		Z19->Z19_CLIENTE 	:= TRA1->A1_COD
		Z19->Z19_LOJA 		:= TRA1->A1_LOJA
		Z19->Z19_NOMCLI 	:= TRA1->A1_NOME
		Z19->Z19_CONTATO 	:= TRA1->A1_CONTATO
		Z19->Z19_UF 		:= TRA1->A1_EST
		Z19->Z19_CIDADE 	:= TRA1->A1_MUN
		Z19->Z19_VEND 		:= TRA1->A1_VEND
		Z19->Z19_ULTCOM 	:= STOD(TRA1->A1_ULTCOM)
		Z19->Z19_PERIOD 	:= TRA1->A1_X_FREQ
		Z19->Z19_POTEN 		:= TRA1->A1_X_POTEN
		Z19->Z19_TELE 		:= TRA1->A1_XTELEVE
		Z19->Z19_DDD		:= TRA1->A1_DDD
		Z19->Z19_TEL		:= TRA1->A1_TEL
		Z19->Z19_NROCOM		:= TRA1->A1_NROCOM
		Z19->Z19_NVEND		:= POSICIONE('SA3',1,XFILIAL('SA3')+TRA1->A1_VEND,'A3_NOME')
				
		nMedia := CalcFat(MV_PAR04)/MV_PAR04
		IF nMedia==0
			nMedia := CalcFat(MV_PAR05)/MV_PAR05 
			IF nMedia>0
			     conout('maior')
			endif
		EndIF
		Z19->Z19_META 		:= nMedia+(nMedia*(mv_par03/100))
		Z19->Z19_MEDIA 		:= nMedia
		Z19->Z19_EFICIEN 	:= 0
		//Z19->Z19_PEDMES 	:= ""
		//Z19->Z19_FATMES 	:= ""
		//Z19->Z19_DTFAT 	:= ""
		//Z19->Z19_RETORN 	:= ""
		//Z19->Z19_DTINI 	:= ""
		//Z19->Z19_DTFIM 	:= ""
		//Z19->Z19_NATEN 	:= ""
		
	ENDIF
	
	Z19->(MsUnlock())	
	
	TRA1->(dbSkip())
EndDO

Return


///////////////////////////////////////////////////////////////////////


User Function PER_EXCL()

LOCAL _cIDUserTele := AllTrim(GetNewPar("MV_XAGTEL","      "))
Local lOk := .F.

If Alltrim( __CUSERID) $ _cIDUserTele  // Usuario autorizado

   // MsgInfo("Usuario Autorizado a efetuar exclusão da Meta!!!")
   
   FWExecView("Exclusao", 'SENTAX_ATMK006', 5 , , { || lOk := .T. },,,,{ || .T. } ) //Exclusão
   
   If lOk    
       MsgInfo("Exclusão Efetuada com Sucesso !!!")
   Else 
       MsgAlert("Este iten nao foi excluido. Favor verificar !!!")
   Endif
          
   
Else
   MsgInfo("ATKM006 - Usuario não Autorizado a efetuar exclusão da Meta !!!")
Endif


Return .t.

///////////////////////////////////////////////////////////////////////


Static Function buscadados()

cSql:=" SELECT * "+CRLF
cSql+=" 	FROM "+RetSqlName('SA1')+" SA1"+CRLF
cSql+=" WHERE A1_MSBLQL<>1 "+CRLF
cSql+=" AND SA1.D_E_L_E_T_<>'*'"+CRLF
cSql+=" order by A1_COD,A1_LOJA"

if Select('TRA1')<>0
	TRA1->(DBCloseArea())
EndIF

TcQuery cSql new Alias 'TRA1'

Return


static Function CalcFat(numMes)

Local cDtIni 	:= DTOS(BIFDay( Month( DDATABASE ) - (numMes	) ))
Local aValMes	:= {}
Local nFor		:= 0
Local nRet 	:=0

cSql:=" select SUM(D2_TOTAL) VALOR "+chr(13)+chr(10)
cSql+=" from "+RetSqlName('SD2')+" SD2"+chr(13)+chr(10)
cSql+=" INNER JOIN "+RetSqlName('SF4')+" SF4"+chr(13)+chr(10)
cSql+=" 	ON F4_FILIAL = SUBSTRING(D2_FILIAL,1,4)"+chr(13)+chr(10)
cSql+=" 	AND F4_CODIGO = D2_TES"+chr(13)+chr(10)
cSql+=" 	AND F4_DUPLIC ='S'"+chr(13)+chr(10)
cSql+=" 	AND SF4.D_E_L_E_T_='' "
cSql+=" INNER JOIN "+RetSqlName('SB1')+" SB1 "
cSql +="		ON B1_FILIAL = '' "
cSql +="		AND B1_COD = D2_COD "
cSql +="		AND B1_GRUPO <> '0600' "  //maquinas
cSql+=" 		AND SB1.D_E_L_E_T_='' "
cSql+=" WHERE D2_CLIENTE =  '"+TRA1->A1_COD+"'"+chr(13)+chr(10)
cSql+=" AND D2_LOJA = '"+TRA1->A1_LOJA+"' "+chr(13)+chr(10)
cSql+=" AND D2_EMISSAO >='"+ cDtIni +"'"+chr(13)+chr(10)
cSql+=" AND D2_EMISSAO <'"+DTOS(BIFDay( Month( DDATABASE ))) +"'"+chr(13)+chr(10)
cSql+=" AND SD2.D_E_L_E_T_='' "


if Select('TRFAT')<>0
	TRFAT->(DBCloseArea())
EndIF

TcQuery cSql new Alias 'TRFAT'

While !TRFAT->(eof())
	nRet:=TRFAT->VALOR
	TRFAT->(dbSkip())
EndDO

Return nRet




//-------------------------------------------------------------------
/*/{Protheus.doc} criasx1
Cria as perguntas na tabela SX1
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
@param cPerg = Nome da pergunta cadastrada na SX1
/*/
//-------------------------------------------------------------------

Static Function criasx1(cPerg)
PutSX1(cPerg, "01", "ANO REF:"            , "", "", "mv_ch1", "C", 04,  0, 0, "G", "u_VALANO()", ""   , "", "", "mv_par01", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "02", "MES REF:"            , "", "", "mv_ch2", "C", 02,  0, 0, "G", "u_VALMES()", ""   , "", "", "mv_par02", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "03", "% AJUSTE:"           , "", "", "mv_ch3", "N", 06,  2, 0, "G", "", ""   , "", "", "mv_par03", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "04", "N.MESES 1ª MEDIA"    , "", "", "mv_ch4", "N", 06,  0, 0, "G", "", ""   , "", "", "mv_par04", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "05", "N.MESES 2ª MEDIA"    , "", "", "mv_ch5", "N", 06,  0, 0, "G", "", ""   , "", "", "mv_par05", "","","","","","","","","","","","","","","","")
Return


User Function VALANO()
IF LEN((ALLTRIM(mv_par01)))==2
	if year(stod('20'+ALLTRIM(mv_par01)+'0101'))<>0
		mv_par01:='20'+ALLTRIM(mv_par01)
		return .t.
	EndIF
Elseif LEN((ALLTRIM(mv_par01)))==4
	
	if year(stod(ALLTRIM(mv_par01)+'0101'))<>0
		return .t.
	EndIF
Else
	alert('Digite o ano com 2 ou 4 caracteres')
	return .f.
EndIF

Return .t.

User Function VALMES()
if val(mv_par02)>=1 .and. val(mv_par02)<=12
	mv_par02:=padl(alltrim(mv_par02),2,'0')
Else
	alert("Digite o mes correto!")
	return .f.
EndIf

Return .t.


