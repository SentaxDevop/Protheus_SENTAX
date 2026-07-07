#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} F050MDVC
Ponto de Entrada para Cálculo da data de vencimento de impostos
                
@sample		U_F050MDVC()

@author		Alessandro Smaha
@since		26/09/2016
@version 	P11  
/*/
//-------------------------------------------------------------------
User function F050MDVC()                 

Local dNextDay := ParamIxb[1] // Data Calculada pelo Sistema
Local cImposto := Alltrim(ParamIxb[2])
Local dEmissao := ParamIxb[3]
Local dVencRea := ParamIxb[5]
Local nNextMes := Month(dEmissao)+1

If cImposto $ "IRRF"  

	nNextMes := Month(dEmissao)+1   
      
	//Calcula data 20 do próximo mes
	dNextDay := CTOD("20/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+;
				Substr(Str(Iif(nNextMes==13,Year(dEmissao)+1,Year(dEmissao))),2))

	dNextday := DataValida(dNextday,.F.) // Retorna a data anterior valida -> .T. posterga -> próximo dia últil - .F. retrocede -> últil anterior.

ElseIf cImposto $ "PIS,CSLL,COFINS"  

	nNextMes := Month(dVencRea)+1

	//Calcula data 20 do próximo mes
	dNextDay := CTOD("20/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+;
				Substr(Str(Iif(nNextMes==13,Year(dVencRea)+1,Year(dVencRea))),2))

	dNextday := DataValida(dNextday,.F.) // Retorna a data anterior valida. 

EndIf

Return dNextDay
