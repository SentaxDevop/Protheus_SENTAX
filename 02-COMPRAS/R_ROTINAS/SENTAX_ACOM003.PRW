#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ACOM003
Geração da pré-nota para produtos não cadastrados. Utilizada no 
nFácil, chamado no PE NFA003MN.
                
@sample		U_ACOM003()

@author		Alessandro Smaha
@since		15/01/2016     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function ACOM003() 
       
Local aRet		:= {}
Local aPerg		:= {}
Local cCodProd 	:= Space(TamSx3("B1_COD")[1])
Local cEspecie	:= Space(TamSx3("F1_ESPECIE")[1]) 
Local cForLoj	:= ""
Local cNomFor	:= ""
Local cDocSer	:= ""
Local cFornLoja
Local oGEspecie
Local oGFornLoja
Local oGNome
Local oGNotaSer
Local oGProduto
Local oSEspecie
Local oSNome
Local oSNotaSer
Local oSProduto
Local nOpca	:= 0
Local oBCancel, oBOK
Static oDlg

DbSelectArea("SA2")
SA2->(DbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
If Empty(Z1Z->Z1Z_FORNEC) .OR. !SA2->(DbSeek(xFilial("SA2")+Z1Z->Z1Z_FORNEC+Z1Z->Z1Z_LOJA))
	MsgAlert("Fornecedor com o cnpj "+Z1Z->Z1Z_CGC+" não cadastrado!","Atenção")
	Return .F.
EndIf

If Z1Z->Z1Z_STATUS $ "136" // 1=Lancada; 2=Dísponivel, 3=Cancelada; 4=Erro Integração; 5=Erro Sefaz; 6=Recusada
	MsgAlert("Apenas notas com status de disponível, erro de integração ou erro no sefaz podem gerar pré-nota a partir desta opção!","Atenção")
	Return .F.
EndIf

cForLoj := Alltrim(SA2->A2_COD) +" / "+ Alltrim(SA2->A2_LOJA)
cNomFor := Alltrim(SA2->A2_NOME)
cDocSer := Alltrim(Z1Z->Z1Z_DOC) +" / "+ Alltrim(Z1Z->Z1Z_SERIE)

DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 220, 350 COLORS 0, 16777215 PIXEL
	
	@ 010, 015 SAY oSNotaSer 	PROMPT "Nota / Série ?" 		SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 027, 015 SAY cFornLoja 	PROMPT "Fornecedor / Loja ?" 	SIZE 051, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045, 015 SAY oSNome 		PROMPT "Nome ?" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 062, 015 SAY oSProduto 	PROMPT "Produto ?" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, 015 SAY oSEspecie 	PROMPT "Espécie ?" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	
	@ 007, 070 MSGET oGNotaSer 	VAR cDocSer 	SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 025, 070 MSGET oGFornLoja VAR cForLoj 	SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 043, 070 MSGET oGNome 	VAR cNomFor 	SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 060, 070 MSGET oGProduto 	VAR cCodProd 	SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SB1" HASBUTTON
	@ 077, 069 MSGET oGEspecie 	VAR cEspecie 	SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "42"  HASBUTTON
	
	@ 092, 075 BUTTON oBCancel 	PROMPT "Cancelar" 	ACTION (nOpca:=0,oDlg:End()) SIZE 037, 012 OF oDlg PIXEL
	@ 092, 125 BUTTON oBOK 		PROMPT "OK"    		ACTION (nOpca:=1,oDlg:End()) SIZE 037, 012 OF oDlg PIXEL
	
ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	
	If MsgYesNo("Confirma a geração da Pré-Nota?","Atenção")
		
		Processa( {|lEnd| fGeraPre( cCodProd, cEspecie ) }, "Aguarde...", "Gerando pré-nota...",.T.)
		
	EndIf
	
EndIf

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} fGeraPre
Rotina para gerar a pré nota

@author 	Alessandro Smaha
@since 		04/01/2016
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
Static Function fGeraPre( cCodProd, cEspecie )

Local aMt140c 	:= {}
Local aMt140i 	:= {}
Local aItensZ3Z := {}
Local nI        := 0
Local nJ	    := 0
Local cError 	:= ""
Local cWarning 	:= ""
Local cNomeArq  := ""
Local cAviso	:= ""
Local cMemo		:= ""
Local cPedItAmr := ""
Local cPedItVlr := ""
Local cItem		:= ""
Local cDifItem	:= ""
Local cItemXml	:= ""  
Local cArqXML	:= ""  
Local cCfopXml	:= ""
Local nBckSm0 	:= SM0->(Recno())
Local cCondPg 	:= Alltrim(SuperGetMv("NF_XNFLCPG"))
Local lManifest	:= IIF(Alltrim(SuperGetMv("NF_XNFLMAN")) $ "1",.T.,.F.) // 1=Pre-nota; 2=Classificacao
Local cPathSrv  := AllTrim(GetSrvProfString("StartPath","\"))+"Temp\"
Local lParPcNfe := SuperGetMv("MV_PCNFE", .T., .F.) // Nota Fiscal tem que ser amarrada a um Pedido de Compra
Local lPedidos  := .T.
Local lValPedi  := .T.
Local nItem		:= 0
Local nTotItens := 0
Local nTotQntde := 0
Local nRecSA2   := 0
Local aItensPc  := {}
Local lCont	  	:= .T.
Local nValPed 	:= 0
Local nQtdPed 	:= 0
Local cChvZ1Z  	:= ""

Private _oXmltmp    
Private _lOKPCNfe	:= .F.

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

If !Empty(cCodProd) .AND. SB1->(DbSeek(xFilial("SB1")+cCodProd))
		
	cLocalPd := SB1->B1_LOCPAD
	cUmProd	 := SB1->B1_UM
	cCCPedC	 := SB1->B1_CC
	cConta	 := SB1->B1_CONTA
	cItCta	 := SB1->B1_ITEMCC 
	
Else
   
	MsgAlert("Produto não encontrado! "+cCodProd,"Atenção")
	Return .F.

EndIf

cNFNum  	:= Z1Z->Z1Z_DOC
cNFSeri 	:= Z1Z->Z1Z_SERIE
dDtEmis 	:= Z1Z->Z1Z_EMISSAO
cChvNfe 	:= Z1Z->Z1Z_CHAVE 
cChvZ1Z  	:= Z1Z->(Z1Z_SERIE+Z1Z_DOC+Z1Z_FORNEC+Z1Z_LOJA)

aAdd(aMt140c,{"F1_FILIAL"  ,xFilial("SF1")  })
aAdd(aMt140c,{"F1_TIPO"    ,"N"			    })
aAdd(aMt140c,{"F1_FORMUL"  ," "             })
aAdd(aMt140c,{"F1_DOC"     ,cNFNum          })
aAdd(aMt140c,{"F1_SERIE"   ,cNFSeri         })
aAdd(aMt140c,{"F1_EMISSAO" ,dDtEmis         })
aAdd(aMt140c,{"F1_FORNECE" ,SA2->A2_COD     })
aAdd(aMt140c,{"F1_LOJA"    ,SA2->A2_LOJA    })
aAdd(aMt140c,{"F1_ESPECIE" ,cEspecie		})
aAdd(aMt140c,{"F1_CHVNFE"  ,cChvNfe			})

ProcRegua(0)  

DbSelectArea("Z2Z")
Z2Z->(DbSetOrder(2)) // Z2Z_FILIAL+Z2Z_SERIE+Z2Z_DOC+Z2Z_FORNEC+Z2Z_LOJA+Z2Z_ITEM

If Z2Z->(DbSeek(xFilial("Z2Z")+cChvZ1Z))

	While Z2Z->(!Eof()) .AND. xFilial("Z2Z") == Z2Z->Z2Z_FILIAL .AND. cChvZ1Z == Z2Z->(Z2Z_SERIE+Z2Z_DOC+Z2Z_FORNEC+Z2Z_LOJA)
			
		IncProc("Importando Itens... Aguarde")
		
		nJ++
		
		cItem := StrZero(nJ,4)
		
		nQntde   := Z2Z->Z2Z_QUANTI
		nValUni	 := Z2Z->Z2Z_VALTOT / Z2Z->Z2Z_QUANTI
		vTotPro  := Z2Z->Z2Z_VALTOT
		cNumPed	 := ""
		cItePed	 := ""
				
		aAdd(aMt140i,{	{"D1_FILIAL" ,xFilial("SD1")        ,Nil},;
						{"D1_ITEM"   ,cItem					,Nil},;
						{"D1_DOC"    ,cNFNum                ,Nil},;
						{"D1_SERIE"  ,cNFSeri               ,Nil},;
						{"D1_FORNECE",SA2->A2_COD           ,Nil},;
						{"D1_LOJA"   ,SA2->A2_LOJA          ,Nil},;
						{"D1_EMISSAO",dDtEmis               ,Nil},;
						{"D1_TIPO"   ,"N"                   ,Nil},;
						{"D1_COD"    ,cCodProd			    ,Nil},;
						{"D1_UM"     ,cUmProd	            ,Nil},;
						{"D1_QUANT"  ,nQntde  				,Nil},;
						{"D1_VUNIT"  ,nValUni 				,Nil},;
						{"D1_TOTAL"  ,vTotPro			    ,Nil},;
						{"D1_CONTA"  ,cConta       			,Nil},;
						{"D1_ITEMCTA",cItCta      			,Nil},;
						{"D1_CC"     ,cCCPedC         		,Nil},;
						{"D1_LOCAL"  ,cLocalPd		        ,Nil},;
						{"D1_TES"    ,""	 		        ,Nil},;
						{"D1_DTDIGIT",dDtEmis	            ,Nil},;
						{"D1_PEDIDO" ,cNumPed       	    ,".T."},;
						{"D1_ITEMPC" ,cItePed	          	,".T."}})
		  
		Z2Z->(DbSkip())
		
	EndDo

Else
    
	cAviso += "Itens não encontrados! (Chave: "+Alltrim(cChvZ1Z)+")."+chr(13)+chr(10)
		
EndIf

If Empty(cAviso)
	
	lMsErroAuto := .F.
	
	// Pré nota
	MSExecAuto({|x,y,z|Mata140(x,y,z)},aMt140c,aMt140i,3)
	
	If lMsErroAuto    
	
		mostraErro()
		
	Else
		
		_cTpOper 	:= "210200=Confirmacao da Operacao" // 210200 – Confirmação da Operação / 210210 – Ciência da Operação / 210220 – Desconhecimento da Operação / 210240 – Operação não Realizada
		_cMotivo	:= ""
		cSitXml     := ""
		cProtocolo  := Z1Z->Z1Z_PROTOC
		
		// Realiza a Manifestação de Destinatário como Confirmação da Operação
		If lManifest
			Processa( { |lEnd| U_NFAC014(cChvNfe,_cTpOper,@_cMotivo,"",@cSitXml,@cProtocolo) }, "Aguarde...", "Manifestação - Confirmação da Operação...",.F.)
		EndIf
		
		MsgInfo("Geração de Pré-Nota concluída!"+chr(13)+chr(10)+chr(13)+chr(10)+_cMotivo,"Aviso")
		
		Z1Z->(DbSetOrder(2)) // Z1Z_FILIAL+Z1Z_CHAVE
		
		If Z1Z->(DbSeek(xFilial("Z1Z")+cChvNfe))
			
			RecLock("Z1Z",.F.)
	   			Z1Z->Z1Z_STATUS := "1" // 1=Lancada;2=Dísponivel,3=Cancelada;4=Erro Integração;5=Erro Sefaz;6=Recusada
		   		Z1Z->Z1Z_PROTOC := cProtocolo
			Z1Z->(MsUnLock())
			
		EndIf
		
	Endif
	
Else
	
	MsgAlert(cAviso,"Erro")
	
EndIf

Return .T.