#Include 'protheus.ch'
#Include 'topconn.ch'                 
#include 'colors.ch'   

//-------------------------------------------------------------------
/*/{Protheus.doc} AFAT003
Rotina para liberação de pedidos com bloqueio, gerando o novo pedido de remessa e atualizando a TES para 

@author Felipe Toazza Caldeira
@return  
@since 14/04/2016
@version 1.0

/*/
//-------------------------------------------------------------------

User Function AFAT003()

Private cAlias		:= "SC5"                      
Private aCores		:= {}
Private cCadastro 	:= 'Liberação Pedidos de Remessa'

AADD(aCores,{"C5_XBLCOM == ' ' .OR. C5_XBLCOM == '2'" ,"BR_VERDE"})
AADD(aCores,{"C5_XBLCOM == '1'" ,"BR_VERMELHO"})


aRotina := {{ "Pesquisa    	  ","AxPesqui"  , 0, 1},;
			{ "Visualizar	  ","A410Visual", 0, 2},; 
			{ "Liberar Remessa","U_AFAT003B", 0, 6},;
			{ "Legenda        ","U_AFAT003L", 0, 6};
			}

mBrowse(6,1,22,75,cAlias,,,,,,aCores)
                      
Return
	
		

//-------------------------------------------------------------------
/*/{Protheus.doc} AFAT003B
Realiza a liberação do pedido para faturamento e criação do pedido de remessa

@author Felipe Toazza Caldeira
@since  14/04/2016            
                  
/*/
//-------------------------------------------------------------------
User Function AFAT003B()

	If !RetCodUsr() $ GetMv("ST_USAPROV")
		Alert('Usuário não tem permissão para executar esta rotina!')
		Return
	EndIf

	If SC5->C5_XBLCOM != '1'
		If !MsgYesNo('Este pedido não é um pedido para entrega futura! Deseja realmente transformá-lo em pedido para entrega futura?')
			Return                                                                                                                     
		EndIf
	EndIf

	If !Empty(Alltrim(SC5->C5_NOTA))
		Alert('Este pedido já teve nota emitida! Não é possível realizar nenhuma operação!')
		Return	
	EndIf

	If !Empty(Alltrim(SC5->C5_XPEDOR))
		Alert('Este pedido é um pedido filho de remessa. Não é possivel executar nenhuma operação sobre ele!')
		Return	
	EndIf
                                               
	cQuery := "SELECT * 
	cQuery += " FROM "+ RetSqlname('SC5')
	cQuery += " WHERE C5_FILIAL = '"+ SC5->C5_FILIAL +"' 
	cQuery += " AND C5_XPEDOR = '"+ SC5->C5_NUM +"' 
	cQuery += " AND D_E_L_E_T_ != '*' "
	TcQuery cQuery New Alias "TRB"
	
	DbSelectArea('TRB')
	TRB->(DbGoTop())
	
	If !TRB->(EOF())
		Alert('Este Pedido já teve sua liberação realizada!')
		TRB->(DbCloseArea())
		Return		
	EndIf
	
	TRB->(DbCloseArea())
	
	//AlteraPed()
	reclock('SC5',.f.)
	SC5->C5_XBLCOM := '2'
	msunlock('SC5')
		
	MsgInfo('Operação realizada com sucesso!','Liberação Entrega Futura')

Return 
                      

//-------------------------------------------------------------------
/*/{Protheus.doc} AFAT003L
Legenda do Borwse Inicial de Liberação de Pedidos

@author Felipe Toazza Caldeira
@since  14/04/2016                              
/*/
//-------------------------------------------------------------------
User Function AFAT003L()

Local aLegenda := {}

AADD(aLegenda,{"BR_VERMELHO" ,"Bloqueado  "})
AADD(aLegenda,{"BR_VERDE   " ,"Liberado   "})

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil

               
//-------------------------------------------------------------------
/*/{Protheus.doc} AlteraPed
Função de alteração do pedido pai

@author Felipe Toazza Caldeira
@since  14/04/2016                              
/*/
//-------------------------------------------------------------------
Static Function AlteraPed()
Local aMata410c := {}
Local aMata410i	:= {}
            
	cPedAux := SC5->C5_NUM
	// monta cabeçalho do pedido de venda base para alteração
	aAdd( aMata410c , { "C5_NUM"  	 , SC5->C5_NUM          	, nil } ) 
	aAdd( aMata410c , { "C5_TIPO"    , SC5->C5_TIPO          	, nil } ) 
	aAdd( aMata410c , { "C5_CLIENTE" , SC5->C5_CLIENTE 	 		, nil } ) 
	aAdd( aMata410c , { "C5_LOJACLI" , SC5->C5_LOJACLI 			, nil } ) 
	aAdd( aMata410c , { "C5_CONDPAG" , SC5->C5_CONDPAG    		, nil } ) 
	aAdd( aMata410c , { "C5_XBLCOM"  , '2'    					, nil } ) 	
	
	DbSelectArea('SC6')
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

	While !SC6->(EOF()) .AND. SC5->C5_FILIAL+SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM 	
		
	//adiciona a linha
		aAdd(aMata410i,{;
						{ "C6_ITEM"    , SC6->C6_ITEM  		, nil},;
						{ "C6_PRODUTO" , SC6->C6_PRODUTO  	, nil},;
						{ "C6_DESCRI"  , SC6->C6_DESCRI   	, nil},;
						{ "C6_UM"      , SC6->C6_UM	       	, nil},;
						{ "C6_QTDVEN"  , SC6->C6_QTDVEN 	, nil},;
						{ "C6_PRCVEN"  , SC6->C6_PRCVEN 	, nil},;
						{ "C6_VALOR"   , SC6->C6_VALOR  	, nil},;
						{ "C6_OPER   " , Alltrim(GetMv("ST_OPREM")) , nil}})

		SC6->(DbSkip())
   	EndDo

	Begin Transaction 
	
	lMsErroAuto := .F.
	// executa Alteração	
	msExecAuto({|x,y,z|Mata410(x,y,z)},aMata410c,aMata410i,4)
	
	//verifica se houve erro
	If lMsErroAuto
		lErro := .T.	
		MostraErro()
		DisarmTransaction()
		Return
	Else           
		//Realiza incliusão de Pedido De Remessa
		IncluiPed(cPedAux)
	Endif
    
	End Transaction

Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} AlteraPed
Função de inclusão do pedido de remessa

@author Felipe Toazza Caldeira
@since  14/04/2016                              
/*/
//-------------------------------------------------------------------
Static Function IncluiPed(cPedAux)
Local aMata410c := {}
Local aMata410i	:= {}

	// monta cabeçalho do pedido de venda base para INCLUSAO
	aAdd( aMata410c , { "C5_NUM"  		, GETSXENUM("SC5","C5_NUM")	, nil } ) 
	aAdd( aMata410c , { "C5_TIPO"    	, SC5->C5_TIPO          	, nil } ) 
	aAdd( aMata410c , { "C5_CLIENTE" 	, SC5->C5_CLIENTE 		 	, nil } ) 
	aAdd( aMata410c , { "C5_LOJACLI" 	, SC5->C5_LOJACLI 			, nil } ) 
	aAdd( aMata410c , { "C5_CONDPAG" 	, SC5->C5_CONDPAG    		, nil } ) 
	aAdd( aMata410c , { "C5_XPEDOR"  	, cPedAux					, nil } ) 
	aAdd( aMata410c , { "C5_XBLCOM"  	, '2'    					, nil } ) 	
	aAdd( aMata410c , { "C5_MENNOTA" 	, SC5->C5_MENNOTA 	 		, nil } ) 
	aAdd( aMata410c , { "C5_MENPAD" 	, SC5->C5_MENPAD 			, ".T." } ) 
	aAdd( aMata410c , { "C5_XFORMA" 	, SC5->C5_XFORMA    		, nil } ) 
	aAdd( aMata410c , { "C5_TIPLIB" 	, SC5->C5_TIPLIB 	 		, nil } ) 
	aAdd( aMata410c , { "C5_XENDENT" 	, SC5->C5_XENDENT 			, nil } ) 
	aAdd( aMata410c , { "C5_XBAIENT" 	, SC5->C5_XBAIENT    		, nil } ) 
	aAdd( aMata410c , { "C5_XCEPENT" 	, SC5->C5_XCEPENT 	 		, nil } ) 
	aAdd( aMata410c , { "C5_XESTENT" 	, SC5->C5_XESTENT 			, nil } ) 
	aAdd( aMata410c , { "C5_XMUNENT" 	, SC5->C5_XMUNENT    		, nil } ) 
	aAdd( aMata410c , { "C5_XOBSLOG" 	, SC5->C5_XOBSLOG 	 		, nil } ) 

	DbSelectArea('SC6')
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

	While !SC6->(EOF()) .AND. SC5->C5_FILIAL+SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM 	
		
	//adiciona a linha
		aAdd(aMata410i,{;
						{ "C6_ITEM"    	, SC6->C6_ITEM  	, nil},;
						{ "C6_PRODUTO" 	, SC6->C6_PRODUTO  	, nil},;
						{ "C6_DESCRI"  	, SC6->C6_DESCRI   	, nil},;
						{ "C6_UM"      	, SC6->C6_UM	    , nil},;
						{ "C6_QTDVEN"  	, SC6->C6_QTDVEN 	, nil},;
						{ "C6_PRCVEN"  	, SC6->C6_PRCVEN 	, nil},;
						{ "C6_VALOR"   	, SC6->C6_VALOR  	, nil},;
						{ "C6_OPER"     , Alltrim(GetMv("ST_OPSIREM")) , nil},;
						{ "C6_PRELIST"	, SC6->C6_PRELIST  	, nil},;
						{ "C6_PEDCLI" 	, SC6->C6_PEDCLI  	, nil},;
						{ "C6_NUMPCOM" 	, SC6->C6_NUMPCOM  	, nil},;
						{ "C6_ITEMPC" 	, SC6->C6_ITEMPC  	, nil}})

		SC6->(DbSkip())
   	EndDo
	
	lMsErroAuto := .F.
	// executa Alteração	
	msExecAuto({|x,y,z|Mata410(x,y,z)},aMata410c,aMata410i,3)
	
	//verifica se houve erro
	If lMsErroAuto
		lErro := .T.	
		MostraErro()
		DisarmTransaction()
		Return             
	Else
		DbSelectArea('SUA')
		DbSetOrder(8)
		DbgoTop()
		If SUA->(DbSeek(xFilial('SUA')+cPedAux))
			RecLock('SUA',.F.)
			SUA->UA_XPEDREM := SC5->C5_NUM
			MsUnlock()
		EndIf
		
		MsgInfo('Operação realizada com sucesso!')	
	Endif

Return
