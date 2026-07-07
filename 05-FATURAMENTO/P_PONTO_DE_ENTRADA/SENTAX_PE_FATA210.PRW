#INCLUDE "PROTHEUS.CH"


//---------------------------------------------------------------------------
/*/{Protheus.doc} FT210COR
Possibilita alterar as regras e cores dos pedidos bloqueados por verbas ou regras.

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 aRet, array com a legenda

/*/    
//---------------------------------------------------------------------------
User Function FT210COR()	

	Local aCores := PARAMIXB
	
	aCores := {	{ " U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '02' ","PMSEDT1"   },; //02 - Bloqueado por Regra
				{ " U_MFAT005(SC5->C5_FILIAL,SC5->C5_NUM) == '03' ","PMSEDT2"   }}  //03 - Bloqueado por Verba	
				

Return aCores                

//---------------------------------------------------------------------------
/*/{Protheus.doc} FT210LEG
Permite alterar as cores da opção legenda na rotina de liberação
por regra ou verba

@author  Leandro Natan Bonette Santos
@since   04/09/2014
@return	 aRet, array com a legenda

/*/    
//---------------------------------------------------------------------------
User Function FT210LEG()

	Local aCores := PARAMIXB
	
	aCores := { {"PMSEDT1"   ,"Pedido Bloqueado por Regra"} ,;
				{"PMSEDT2"   ,"Pedido Bloqueado por Verba"} }

Return aCores              

//---------------------------------------------------------------------------
/*/{Protheus.doc} FT210MNU
Permite incluir novas opções no menu ações relacionadas da rotina de liberação
de regras.

@author  Leandro Natan Bonette Santos
@since   16/12/2014
@return	 uRet, nulo

/*/    
//---------------------------------------------------------------------------
User Function FT210MNU()
      
	aadd(aRotina, {'Analise Empresa', 'U_MFAT001(SC5->C5_CLIENTE,SC5->C5_LOJACLI)', 0, 2, 0, NIL})
	aadd(aRotina, {"Consulta Log"   , "U_CFAT001"                                 , 0, 6, 0, nil})

Return                    
