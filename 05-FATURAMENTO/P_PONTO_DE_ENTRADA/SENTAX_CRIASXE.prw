#include "totvs.ch"
#include "topconn.ch"
#Include 'Protheus.ch'
#INCLUDE "rwmake.ch"
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} CRIASXE
//TODO Corrige numeração sequencial
@author João E. Lopes AFSouza 
@since 01/07/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

user function CRIASXE()

	Local cNum   	:= NIL
	Local aArea  	:= getarea()
	Local aArea2 	:= {}
	Local cAlias 	:= paramixb[1]
	Local cCpoSx8   := paramixb[2]
	Local cAliasSx8 := paramixb[3]
	Local nOrdSX8   := paramixb[4]
	Local cUsa 		:= "SA1/SA2/SC7"   // colocar os alias que irão permitir a execução do P.E.

	Private cZCodSA1 := ""
	Private cZCodSA2 := ""

	if cAlias $ cUsa .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) )	

		qout(cAlias + "-" + cCpoSx8 + "-" + cAliasSx8 + "-" + str(nOrdSX8))

		dbselectarea(cAlias)
		aArea2 := getarea()
		dbsetorder(nOrdSX8)
		dbseek(xfilial()+"Z")
		dbskip(-1)

		cNum := &(cCpoSx8)

		cnum := soma1(cNum)	// fazer o tratamento aqui para a numeracao

		If cAlias = 'SA1'
			AFAT005()	// função de usuário para trazer numeração correta Cliente 	
			cnum := soma1(cZCodSA1)	
			
			If !IsBlind()
				MsgGet2( "Clientes - Indique N.Seq Correto Tab:" + calias, "Campo:"+cCposx8, @cNum, , , )
			EndIf	

		ElseIf cAlias = 'SA2' 
			ACOM004()	// função de usuário para trazer numeração correta fornecedor
			cnum := soma1(cZCodSA2)
			
			If !IsBlind()
				MsgGet2( "Fornec. - Indique N.Seq Correto Tab:" + calias, "Campo:"+cCposx8, @cNum, , , )
			EndIf 

		ElseIf cAlias = 'SC7'
				If !IsBlind() 
					MsgGet2( "Ped.Compras - Indique N.Seq Correto Tab:" + calias, "Campo:"+cCposx8, @cNum, , , )
				EndIf

			Else
				If !IsBlind() 
					MsgGet2( "Indique Num.Seq Correto Tab:" + calias, "Campo:"+cCposx8, @cNum, , , )
				EndIf 	
		EndIf

		restarea(aArea2)
		restarea(aArea)
	end
return cNum


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AFAT005
Ajuste controle de Numeração - SA1
@sample U_AFAT005
@author João AFSouza
@since 16/03/2020
@version 1.0		
IF(INCLUI,GETSXENUM("SA1","A1_COD"),SA1->A1_COD)              
@return nil, Nulo

/*/
//-------------------------------------------------------------------------------

Static Function AFAT005()

	Local aAreaAnt  := GetArea()
	
	cQry := " SELECT TOP 1 A1_COD  CODATUA1     "
	cQry += " FROM "+RetSqlName ("SA1")+" SA1   "
	cQry += " WHERE  D_E_L_E_T_=''              "
	cQry += " ORDER BY R_E_C_N_O_ DESC          "  

	If Select("QrySA1") <> 0
		dbSelectArea("QrySA1")
		QrySA1->(dbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"QrySA1",.F.,.T.)

	cZCodSA1 := QrySA1->CODATUA1 

	RestArea(aAreaAnt)

Return ()	


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004
Ajuste controle de Numeração - SA1
@sample U_AFAT005
@author João AFSouza
@since 24/03/2020
@version 1.0		
IF(INCLUI,GETSXENUM("SA2","A2_COD"),'')                    
@return nil, Nulo

/*/
//-------------------------------------------------------------------------------

Static Function ACOM004()

	Local  aAreaAnt  := GetArea()

	cQry := " SELECT TOP 1 A2_COD  CODATUA2     "
	cQry += " FROM "+RetSqlName ("SA2")+" SA2   "
	cQry += " WHERE  D_E_L_E_T_=''              "
	cQry += " ORDER BY R_E_C_N_O_ DESC          "  

	If Select("QrySA2") <> 0
		dbSelectArea("QrySA2")
		QrySA2->(dbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"QrySA2",.F.,.T.)

	cZCodSA2 := QrySA2->CODATUA2

	RestArea(aAreaAnt)

Return ()	

