#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------
/*/{Protheus.doc} F650DESCR
Permite alterar a descrição da ocorrência no relatório de retorno do CNAB

@author  Leandro Natan Bonette Santos
@since   16/03/2017
@return  cDescric, nova descrição

/*/
//--------------------------------------------------------------------------
User Function F650DESCR()

	Local cDescric := PARAMIXB[1]
                                                                                
	If MV_PAR03 == "104" .AND. MV_PAR07 == 1 .AND. SubStr(cDescric,1,2) == "06" 	                     
		//Caixa Econômica - CNAB a Receber e ocorrência 06-Liquidação
		If nValRec <> SE1->E1_VALOR
			cDescric := "X06-LIQ. VALOR DIFERENTE"
		EndIf	
	EndIf

Return cDescric 