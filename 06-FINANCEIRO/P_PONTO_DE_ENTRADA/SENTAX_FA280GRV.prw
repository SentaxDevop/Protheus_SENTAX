#Include 'Protheus.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FA280GRV
Ponto de entrada utilizado na rotina Faturas a Receber que permite efetuar validações 
diversas no processo logo após o término da transação e gravação do(s) novo(s) título(s).

O novo título estará posicionado na tabela SE1.

@description
LOCALIZAÇÃO: Função FA280AUT - Marcação dos títulos para emissão de fatura.
EM QUE PONTO: No término da transação de gravação do novo título

@author TOTVS

/*/
//--------------------------------------------------------------------------------------------------
User Function FA280GRV()

	Local aArea    := GetArea()
	Local aAreaSE1 := SE1->(GetArea())   
	

	/*
	 * Permite alterar o texto do campo E1_XFORMA
	 */
	fXFormaPag()
	
	RestArea(aAreaSE1)
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fXFormaPag
Grava a informação da condição de pagamento no campo E1_XFORMA

@author Leandro Natan Bonette Santos
@since 07/05/2014
@version P11

/*/
//-------------------------------------------------------------------
Static Function fXFormaPag()

	Local oDlgCond    := Nil
	Local oGetFroma   := Nil
		
	Local cAliasQry := GetNextAlias()
	Local cGetForma := CriaVar("E1_XFORMA")
	
	Local nOpc := 0

	DEFINE MSDIALOG oDlgCond TITLE 'Forma de Pagamento' FROM 0,0 TO 135,320 PIXEL

	TGROUP():new(5,5,63,158,,oDlgCond,,,.T.)	

	@012,010 SAY "Forma de pagamento" OF oDlgCond SIZE 60,15 PIXEL
	@011,070 GET oGetForma VAR cGetForma OF oDlgCond SIZE 80,08 PIXEL PICTURE PesqPict("SE1","E1_XFORMA")
	
	TButton():New(40,110,'Confirmar'  ,oDlgCond, {|| nOpc := 1, oDlgCond:End() },40,12,,,,.T.) 	
	TButton():New(40, 65,'Cancelar'   ,oDlgCond, {|| oDlgCond:End() },40,12,,,,.T.)  
	
	ACTIVATE MSDIALOG oDlgCond CENTER
	
	If nOpc == 1
	
		BeginSql Alias cAliasQry
		
			
			SELECT	E1_FILIAL,
					E1_PREFIXO,
					E1_NUM,
					E1_PARCELA,
					E1_TIPO 
					
			FROM %Table:SE1%
			
			WHERE	E1_FILIAL  = %xFilial:SE1%				AND
					E1_PREFIXO = %Exp:SE1->E1_PREFIXO%		AND
					E1_NUM     = %Exp:SE1->E1_NUM%			AND
					E1_TIPO    = %Exp:SE1->E1_TIPO%			AND
					E1_CLIENTE = %Exp:SE1->E1_CLIENTE%		AND
					E1_LOJA    = %Exp:SE1->E1_LOJA%			AND
					
					%NotDel%
						
			ORDER BY E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO
			
		EndSql
		
		If (cAliasQry)->(!EoF())
		
			SE1->(DbSetOrder(1))
			
			While (cAliasQry)->(!EoF())
			
				cChave := (cAliasQry)->( E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO )
								
				If SE1->(DbSeek(cChave))
				
					RecLock("SE1",.F.)
					SE1->E1_XFORMA := cGetForma
					MsUnlock()
				
				EndIf
		
			
				(cAliasQry)->(DbSkip())
			End
			
		EndIf
			
	   
	
	EndIf

Return