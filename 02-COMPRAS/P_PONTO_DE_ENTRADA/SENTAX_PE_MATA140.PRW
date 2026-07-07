#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} SF1140I  
 Ponto de Entrada apos atualizacao de todos os dados inclusao do documento de entrada   

@author  Anderson Roberto Franco de Souza
@since   27/09/2013

@return Nil, nenhum  
/*/    
User Function SF1140I() 

Local _aArea:= GetArea()  

If FunName() <> "NFAC003" // Rotina NFAC003 é do nFácil...
       
	// conforme alinhado com o Mauricio, este relatório não está sendo utilizado devido a estrutura fisica da sentax.
	//If MsgYesNo("Imprimir relatório de conferência cega ?", "Conferência CEGA")   
	//   U_RCOM001()
	//EndIf 

	If Alltrim(SF1->F1_ESPECIE) == "SPED" .AND. Alltrim(SF1->F1_TIPO) == "N"
		If MsgYesNo("Deseja Imprimir Etiquetas de Produto ?", "Impressora ARGOX") // Adicionado em 14/05/2014 por Alessandro Smaha   
		   U_ROMS004A() 
		EndIf  
	EndIf

EndIf

RestArea(_aArea)

Return     

// PEs NFACIL
//---------------------------------------------------------------------
/*/{Protheus.doc} MT140SAI
Responsável por controlar a interface de um pre-documento de entrada.
Ponto de entrada disparado antes do retorno da rotina ao browse.
Dessa forma, a tabela SF1 pode ser reposicionada antes do retorno 
ao browse.

@author 	Alessandro Smaha
@since 		14/01/2016
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
User Function MT140SAI()

	Local cTitWMS	:= "Integração WMS"
	Local lIntegra	:= !Empty(SD1->D1_PEDIDO)
	Local oObjeto
     
	//Inclusão
	If PARAMIXB[1] == 3 .And. PARAMIXB[7] == 1 .And. lIntegra .And. SD1->D1_FILIAL = '020201'
		
		//Se for nota de importação 
		If FWISINCALLSTACK('EICDI154')
			nOpc := 1
		Else	
			//Definição de envio automático para o WMS compete ao usuário decidir na hora do lançamento
			nOpc := Aviso(cTitWMS, "Deseja enviar para o Cyberlog essa Pré Nota Fiscal de Entrada?", {"Sim", "Não"}, 2, "Protheus >> Cyberlog")
		End
		
		If nOpc == 1
		
			oObjeto := TIntegracaoProtheusxWMSCyberlog():New()

			/*
			PARAMIXB[2] = Número da nota
			PARAMIXB[3] = Série da nota
			PARAMIXB[4] = Fornecedor
			PARAMIXB[5] = Loja
			PARAMIXB[6] = Tipo
			*/
			If oObjeto:EnviaPreNFparaWMS(PARAMIXB[2],PARAMIXB[3],PARAMIXB[4],PARAMIXB[5],PARAMIXB[6])

				If FWISINCALLSTACK('EICDI154')
					Conout("Envio da nota de importação realizado com sucesso! " + cTitWMS)
				Else
					FWAlertSuccess("Envio realizado com sucesso!",cTitWMS)
				End
				
			Else

				If FWISINCALLSTACK('EICDI154')
					Conout("Ocorreu um erro no envio da nota de importação! Verifique os logs. " + cTitWMS)
				Else
					FWAlertError("Ocorreu um erro! Verifique os logs. ",cTitWMS)
				End

			END

			FREEOBJ( oObjeto )
		
		ElseIf nOpc == 2
			
			FWAlertWarning("Integração pendente! Utilize: Painel Integração Cyberlog X Protheus", cTitWMS)

		EndIf

	End


	// Verifica se é exclusão
	If PARAMIXB[1] == 5  

		// Verifica se foi confirmado (Ok)
		If PARAMIXB[7] == 1
					
			// Atualiza o status do xml ingrado
			U_NFAC025(2)    
			
		EndIf
		
	EndIf

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} MT140PC
Ponto de Entrada para o tratamento do parâmetro MV_PCNFE (Nota Fiscal 
tem que ser amarrada a um Pedido de Compra ?)

@author 	Alessandro Smaha
@since 		14/01/2016
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
User Function MT140PC()

Local lRetOk := .T.

// Valida a obrigatoriedade da amarração do pedido de venda
lRetOk := U_NFAC025(3) 

If lRetOk
	If Funname() == "NFAC003"
		lRetOk := .F.
	EndIf
EndIf

Return lRetOk
