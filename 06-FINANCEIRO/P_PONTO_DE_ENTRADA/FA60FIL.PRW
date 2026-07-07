#Include "TOTVS.CH"
#Include 'Protheus.ch' 
#include "rwmake.ch"
#include "TOPCONN.ch"
#include "APWEBEX.CH"
#include "TBICONN.ch"
//==================================================================================================//
//	Programa: FA60FIL		|	Autor: Luis Paulo							|	Data: 07/11/2022	//
//==================================================================================================//
//	Descrição: O PE será executado no filtro de registros que serão processados para a elaboração   //
//  do borderô													                                    //
//																									//
//==================================================================================================//
User Function FA60FIL()
Local _cFil := " E1_SALDO == E1_VALOR "

If MsgYesNo("Deseja processar apenas boletos Santander??? ")
   _cFil += " .AND. E1_PORTADO == '033' .AND. E1_XFORMA == 'BOL' "
Endif	

Return _cFil 
