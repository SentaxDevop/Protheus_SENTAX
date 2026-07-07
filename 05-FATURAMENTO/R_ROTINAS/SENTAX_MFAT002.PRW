#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"


//-------------------------------------------------------------------
/*SENTAX_MFAT002
Mostra pedidos bloqueados
//------------------------------------------------------------------- 
*/
User Function MFAT002()

Local oRelation
Local oFWLayer
Local oPanel
Local aCoors := FWGetDialogSize(oMainWnd)
Local cAlias := "QRY_TMP"   

Local aCores := {{" U_MFAT005(TRB->FILIAL,TRB->PEDIDO,'',.T.) == '09' ", "ENABLE"    , "Pedido em aberto"    },;               //09 - Pedido em aberto
				 {" U_MFAT005(TRB->FILIAL,TRB->PEDIDO,'',.T.) == '02' ", "PMSEDT1"   , "Bloqueio por Regra"  },;               //02 - Bloqueio por Regra
				 {" U_MFAT005(TRB->FILIAL,TRB->PEDIDO,'',.T.) == '03' ", "PMSEDT2"   , "Bloqueio por Verba"  },;               //03 - Bloqueio por Verba
				 {" U_MFAT005(TRB->FILIAL,TRB->PEDIDO,'',.T.) == '04' ", "PMSTASK1"  , "Bloqueio de Crédito" },;               //04 - Bloqueio de Crédito
				 {" U_MFAT005(TRB->FILIAL,TRB->PEDIDO,'',.T.) == '05' ", "BR_CANCEL" , "Rejeitado na Liberação do Credito"},;  //05 - Rejeitado na Liberação do Credito
				 {" U_MFAT005(TRB->FILIAL,TRB->PEDIDO,'',.T.) == '06' ", "PMSEDT4"   , "Bloqueio de Estoque"},;                //06 - Bloqueio de Estoque
				 {" U_MFAT005(TRB->FILIAL,TRB->PEDIDO,'',.T.) == '07' ", "PMSEDT3"   , "Bloqueio WMS"       },;                //07 - Bloqueio WMS
				 {" U_MFAT005(TRB->FILIAL,TRB->PEDIDO,'',.T.) == '08' ", "BR_PINK"   , "Bloqueio TMS" }}                       //08 - Bloqueio TMS



Private oMBrowseAll
Private oDlg 
Private _oDlg1 
Private dDtIni:=DDATABASE - 30

                    
  

DEFINE MSDIALOG oDlg TITLE "Pedidos Bloqueados" FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL
// define a barra de botões
Define buttonBar oBar size 70,70 3D TOP of oDlg
//Define Button Resource "PMSRRFSH"       of oBar Action u_COPA156A() Prompt "Atualiza"   ToolTip "Atualiza Browse"
Define Button Resource "CANCEL"         of oBar Action ::end()      Prompt "Sair"          ToolTip "Sair"

oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.F.,.T.)
oFWLayer:AddCollumn("TELA",100,.T.,"UP")
oFWLayer:AddWindow("TELA","oPanel","Pedidos bloqueados",80,.F.,.T.,,"UP",{ || })
oFWLayer:AddWindow("TELA","oPanel2","Opcoes",20,.F.,.T.,,"UP",{ || })


oPanel := oFWLayer:GetWinPanel("TELA","oPanel","UP")   
oPanel2 := oFWLayer:GetWinPanel("TELA","oPanel2","UP")   

/*aCores := {{"Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' },;		//Pedido em Aberto
			{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" ,'DISABLE'},;		   	//Pedido Encerrado
			{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)",'BR_AMARELO'},;
			{ "C5_BLQ == '1'",'BR_AZUL'},;	//Pedido Bloquedo por regra
			{ "C5_BLQ == '2'",'BR_LARANJA'}}	//Pedido Bloquedo por verba
  */
  
BeginSql alias "QRY_TMP"
	%noparser%    
	SELECT	FILIAL,
			PEDIDO,
			SC5.C5_EMISSAO EMISSAO,
			CLIENTE,
			LOJA,
			ABERTO,
			ESTOQUE,
			CREDSIM,
			REGRASIM,
			FATPAR, 
			SC5.C5_XULIBCR,
			SC5.C5_XDLIBCR,
			SC5.C5_XHLIBCR,
			SC5.C5_XULIBET,
			SC5.C5_XDLIBET,
			SC5.C5_XHLIBET,
			SC5.C5_XULIBRG,
			SC5.C5_XDLIBRG,
			SC5.C5_XHLIBRG
			
	FROM
	(
		SELECT FILIAL,PEDIDO, CLIENTE, LOJA,SUM(ABERTO) ABERTO,SUM(ESTOQUE)  ESTOQUE,SUM(CREDITO) CREDSIM,SUM(REGRA) REGRASIM,SUM(FATPAR) FATPAR FROM
		(
		
			SELECT	DISTINCT C5_FILIAL FILIAL,C5_NUM    PEDIDO, C5_CLIENTE CLIENTE, C5_LOJACLI LOJA, 1 ABERTO, 0 ESTOQUE,0 CREDITO, 0 REGRA, 0 FATPAR FROM SC5010 WHERE %NotDel% AND C5_LIBEROK=' ' AND C5_NOTA=' ' AND C5_BLQ=' '
			UNION ALL
			SELECT	DISTINCT C9_FILIAL FILIAL,C9_PEDIDO PEDIDO, C9_CLIENTE CLIENTE, C9_LOJA    LOJA, 0 ABERTO, 1 ESTOQUE,0 CREDITO, 0 REGRA, 0 FATPAR FROM SC9010 WHERE %NotDel% AND C9_BLEST = '02'
			UNION ALL
			SELECT	DISTINCT C9_FILIAL FILIAL,C9_PEDIDO PEDIDO, C9_CLIENTE CLIENTE, C9_LOJA    LOJA, 0 ABERTO, 0 ESTOQUE,1 CREDITO, 0 REGRA, 0 FATPAR FROM SC9010 WHERE %NotDel% AND C9_BLCRED <> '10' AND C9_BLCRED <> '  '  
			UNION ALL
			SELECT	DISTINCT C5_FILIAL FILIAL,C5_NUM    PEDIDO, C5_CLIENTE CLIENTE, C5_LOJACLI LOJA, 0 ABERTO, 0 ESTOQUE,0 CREDITO, 1 REGRA, 0 FATPAR FROM SC5010 WHERE %NotDel% AND C5_BLQ ='1' 
			UNION ALL
			SELECT	DISTINCT C6_FILIAL FILIAL,C6_NUM    PEDIDO, C6_CLI     CLIENTE, C6_LOJA    LOJA, 0 ABERTO, 0 ESTOQUE,0 CREDITO, 0 REGRA, 1 FATPAR FROM SC6010 WHERE %NotDel% AND C6_QTDENT!=C6_QTDVEN AND C6_NOTA!=' '
		
		) BLQ
	
		GROUP BY FILIAL,PEDIDO, CLIENTE, LOJA
		
	) TEMP, SC5010 SC5
	WHERE
	SC5.%NotDel% 		   AND
	SC5.C5_FILIAL = FILIAL AND 
	SC5.C5_NUM    = PEDIDO AND
	SC5.C5_EMISSAO BETWEEN %Exp:DTOS(ddtini)% AND %Exp:DTOS(DDATABASE)% 
	ORDER BY FILIAL,PEDIDO,CLIENTE,LOJA

EndSQL                  
cQRY:=GetLastQuery()[2]     

QRY_TMP->(DbCloseArea())

DEFINE FWBROWSE oMBrowseAll  DATA QUERY ALIAS "TRB" QUERY cQRY OF oPanel 

//Legendas do Browse
aEval(aCores,{|aX| oMBrowseAll:AddLegend(aX[1],aX[2],aX[3]) })


ADD COLUMN oColumn DATA { ||  TRB->FILIAL            }                                              TITLE "Filial"           SIZE    OF oMBrowseAll         
ADD COLUMN oColumn DATA { ||  TRB->PEDIDO            }                                              TITLE "Pedido"           SIZE    OF oMBrowseAll  
ADD COLUMN oColumn DATA { ||  STOD(TRB->EMISSAO)     }                                              TITLE "Emissão"          SIZE    OF oMBrowseAll  
ADD COLUMN oColumn DATA { ||  TRB->CLIENTE           }                                              TITLE "Cliente"          SIZE    OF oMBrowseAll      
ADD COLUMN oColumn DATA { ||  TRB->LOJA              }                                              TITLE "Loja"             SIZE    OF oMBrowseAll       
ADD COLUMN oColumn DATA { ||  POSICIONE("SA1",1,xFilial("SA1")+TRB->CLIENTE+TRB->LOJA,"A1_NOME")}   TITLE "Nome Cliente"     SIZE 30 OF oMBrowseAll   
ADD COLUMN oColumn DATA { ||  If(TRB->ABERTO   == 1 ,"SIM","") }                                    TITLE "Aberto"           SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  If(TRB->FATPAR   == 1 ,"SIM","") }                                    TITLE "Fat.Parc"         SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  If(TRB->ESTOQUE  == 1 ,"SIM","") }                                    TITLE "Blq.Estoque"      SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  If(TRB->CREDSIM  == 1 ,"SIM","") }                                    TITLE "Blq.Credito"      SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  If(TRB->REGRASIM == 1 ,"SIM","") }                                    TITLE "Blq.Regra"        SIZE    OF oMBrowseAll     


ADD COLUMN oColumn DATA { ||  UsrRetName(TRB->C5_XULIBCR) }                                         TITLE "Usr. Lib Credito" SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  STOD(TRB->C5_XDLIBCR)       }                                         TITLE "Data Lib Credito" SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  TRB->C5_XHLIBCR             }                                         TITLE "Hora Lib Credito" SIZE    OF oMBrowseAll     

ADD COLUMN oColumn DATA { ||  UsrRetName(TRB->C5_XULIBET) }                                         TITLE "Usr. Lib Estoque" SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  STOD(TRB->C5_XDLIBET)       }                                         TITLE "Data Lib Estoque" SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  TRB->C5_XHLIBET             }                                         TITLE "Hora Lib Estoque" SIZE    OF oMBrowseAll                                                                                                                                 

ADD COLUMN oColumn DATA { ||  UsrRetName(TRB->C5_XULIBRG) }                                         TITLE "Usr. Lib Regra"   SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  STOD(TRB->C5_XDLIBRG)       }                                         TITLE "Data Lib Regra"   SIZE    OF oMBrowseAll     
ADD COLUMN oColumn DATA { ||  TRB->C5_XHLIBRG             }                                         TITLE "Hora Lib Regra"   SIZE    OF oMBrowseAll     


DEFINE FONT oFontGrande NAME "Courier New" SIZE 9,14    

@008,005 BUTTON "Atualizar" SIZE 045, 011 PIXEL OF oPanel2 ACTION {||oMBrowseAll:Refresh(.T.)}
@008,060 BUTTON "Legenda"   SIZE 045, 011 PIXEL OF oPanel2 ACTION {||U_MFAT002L()}


ACTIVATE FWBROWSE oMBrowseAll
                   

ACTIVATE MSDIALOG oDlg CENTERED

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} MFAT002L             
Legenda da rotina de Pedidos Bloqueados - MFAT002

@author  Leandro Natan Bonette Santos
@since   11/09/2014
@return	 uRet, nulo

/*/    
//---------------------------------------------------------------------------
User Function MFAT002L()

	Local aCores := {}


	AAdd(aCores,{"ENABLE"    ,"Pedido em aberto"})	  
	AAdd(aCores,{"PMSEDT1"   ,"Bloqueio por Regra"})
	AAdd(aCores,{"PMSEDT2"   ,"Bloqueio por Verba"})
	AAdd(aCores,{"PMSTASK1"  ,"Bloqueio de Credito"})
	AAdd(aCores,{"BR_CANCEL" ,"Rejeitado na Liberacao do Credito"})
	AAdd(aCores,{"PMSEDT4"   ,"Bloqueio de Estoque"})
	AAdd(aCores,{"PMSEDT3"   ,"Bloqueio WMS "})	
	AAdd(aCores,{"BR_PINK"   ,"Bloqueio TMS"})	  


	BrwLegenda("Pedidos Bloqueados","Pedidos Bloqueados",aCores)

Return
