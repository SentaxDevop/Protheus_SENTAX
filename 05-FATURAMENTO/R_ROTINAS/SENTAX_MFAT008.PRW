#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT008
Rotina para atualizar cadastro de clientes

@sample		U_MFAT008()

@author		Alessandro Smaha
@since		14/07/2015
@version 	P11
/*/
//-------------------------------------------------------------------
User Function MFAT008()
                     
Local nOpca 	:= 0  
Local nUsado	:= 0  
Local cQuery	:= ""  
Local cUsado   	:= CHR(0)+CHR(0)+CHR(1) 
Local aButtons 	:= {}
Local aPergs	:= {}    
Local aRetCpo	:= {}  
Local aSize    	:= MsAdvSize(.T.)
       
Private aHeadTmp	:= {}
Private aColsTmp	:= {}
Private dDataPrc 	:= dDatabase-1 
Private oItens

Static oDlg   

//aAdd(aButtons,{"USER", {|| U_MFAT008C() }, "Atualizar Cadastro"}) 
             
aAdd( aPergs ,{1, "Data"	   ,dDataPrc	  			,""  ,"",""   ,""   ,50         ,.T.})
  
If ParamBox(aPergs ,"Data de Faturamento",aRetCpo)
	dDataPrc := aRetCpo[1]   
Else
	Return
EndIf 

If Empty(dDataPrc)
	Return
Else 
	
	aAdd( aHeadTmp,{"Cliente"	,"CLIENTE"		,PesqPict("SA1","A1_COD"),TamSX3("A1_COD")[1],	  TamSX3("A1_COD")[2],  ".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Loja"		,"LOJA"			,PesqPict("SA1","A1_LOJA"), TamSX3("A1_LOJA")[1], TamSX3("A1_LOJA")[2], ".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{"Nome"		,"NOME"	  		,PesqPict("SA1","A1_NOME"), TamSX3("A1_NOME")[1], TamSX3("A1_NOME")[2], ".F.",cUsado,"C",,"R"} )
	aAdd( aHeadTmp,{""	  		,"OK"	  		,"@!", 2, 0, ".F.",cUsado,"C",,"R"} )
          
	Processa({|| fAtuGrd() } )	
	
EndIf

If !Empty(aColsTmp)
	
	DEFINE MSDIALOG oDlg TITLE "Clientes desatualizados" FROM 000, 000  TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL
		
		oItens := MsNewGetDados():New(1,1,aSize[6]/2-5,aSize[5]/2,0,"AllwaysTrue",,,,,,,,"AllwaysTrue",oDlg,aHeadTmp,aColsTmp)
				
		oItens:oBrowse:lUseDefaultColors := .F.
		oItens:oBrowse:SetBlkBackColor( { || U_MFAT008A( oItens:aCols, oItens:nAt, aHeadTmp ) } )
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,{|| U_MFAT008C() },{|| nOpca := 2, oDlg:End() } ) // CENTERED
	
Else

	Msginfo("Clientes estão atualizados na data "+DtoC(dDataPrc)+"!","Aviso")

EndIf	
	
Return
               

//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT008C
Rotina para alterar o cadastro de cliente

@sample		U_MFAT008C()

@author		Alessandro Smaha
@since		14/07/2015
@version 	P11
/*/
//-------------------------------------------------------------------
User Function MFAT008C()

Local cCodCli	:= oItens:aCols[oItens:nAt][1]
Local cCodLoj	:= oItens:aCols[oItens:nAt][2]      

Local cNomeUser	:= UsrRetName(__cUserID)
Local cHoraBase  := Left(Time(),5)

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
If !SA1->(DbSeek(xFilial("SA1")+cCodCli+cCodLoj))
		MsgAlert("Cliente "+cCodCli+" e loja "+cCodLoj+" não cadastrado!") 
	Return
EndIf 

cCadastro := "Cad. Clientes - ALTERAR"
xRet := AxAltera( "SA1", SA1->(Recno()), 3 ) 

If xRet == 1                  
	//gravando o usuario, data e hora da ultima alteração
	Reclock( "SA1" , .F.)
	SA1->A1_XDTALT 	:= dDatabase
	SA1->A1_XUSRALT := cNomeUser
	SA1->A1_XHRALT 	:= cHoraBase
	MsUnlock()
	aColsTmp[oItens:nAt][4] := "OK"    
EndIf

oItens:oBrowse:SetBlkBackColor( { || U_MFAT008A( oItens:aCols, oItens:nAt, aHeadTmp ) } )

Return   


//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuGrd
Rotina para atualizar grid

@sample		fAtuGrd()

@author		Alessandro Smaha
@since		14/07/2015
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function fAtuGrd()
                   
Local nItem		:= 0
Local cQuery 	:= ""
Local nUsado 	:= Len(aHeadTmp)+1 
   
aColsTmp := {}

ProcRegua(0)

If (Select("QCLI") <> 0)	
	DbSelectArea("QCLI")
	QCLI->(DbCloseArea())	
Endif     
   
cQuery	+= " SELECT F2_CLIENTE, F2_LOJA, A1_NOME "
cQuery	+= " FROM " + RetSQLName("SF2") + " SF2 "
cQuery	+= " INNER JOIN " + RetSQLName("SA1") + " SA1A ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1A.D_E_L_E_T_ <> '*' "
cQuery	+= " WHERE F2_EMISSAO = '"+DtoS(dDataPrc)+"' " 
cQuery	+= " 	AND F2_CLIENTE + F2_LOJA NOT IN ( "
cQuery	+= " 						SELECT A1_COD + A1_LOJA CLIENTE "
cQuery	+= " 						FROM " + RetSQLName("SA1") + " SA1B " 
cQuery	+= " 						WHERE (A1_XUSRALT = 'ELLEN.PACHECO' OR A1_XDTALT >= '20150701') "
cQuery	+= " 							AND SA1B.D_E_L_E_T_ <> '*' "
cQuery	+= " 									) " 
cQuery	+= " 	AND SF2.D_E_L_E_T_ <> '*' "
cQuery	+= " GROUP BY F2_CLIENTE, F2_LOJA, A1_NOME "	
cQuery	+= " ORDER BY F2_CLIENTE, F2_LOJA "

TCQuery cQuery new Alias "QCLI" 

QCLI->(DbGoTop())

If QCLI->(!Eof())   
	While QCLI->(!Eof())  
	
		IncProc("Verificando Clientes...")
	     
	    nItem++
		aAdd(aColsTmp,Array(nUsado))
         
		aColsTmp[nItem][1] := QCLI->F2_CLIENTE
		aColsTmp[nItem][2] := QCLI->F2_LOJA
		aColsTmp[nItem][3] := QCLI->A1_NOME	
		aColsTmp[nItem][4] := ""
		aColsTmp[nItem][5] := .F.
					
		QCLI->(DbSkip())
		
	EndDo
EndIf  
	
Return  
	  

//-------------------------------------------------------------------
/*/{Protheus.doc} MFAT008A
Rotina para atualizar cores do grid
                
@sample		MFAT008A()

@author		Alessandro Smaha
@since		14/07/2015     
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function MFAT008A( aLinha, nLinha, aHeader, nOpcx )

Local nAzul  	:= 15190965 // Azul    	RGB(181,203,231)
Local nBranco 	:= 16777215 // Branco  	RGB(255,255,255)  
Local nVermelho	:= 11513855 // Vermelho RGB(255,175,175)
Local nRet 		:= nBranco 
Local nK		:= 0
          
If nLinha % 2 == 0
         
	nRet := nAzul
	
Else

	nRet := nBranco 

EndIf

If aColsTmp[nLinha][4] == "OK"

	nRet := nVermelho
			
EndIf

Return nRet