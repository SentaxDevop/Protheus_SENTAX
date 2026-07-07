#INCLUDE "TOTVS.CH"

User Function PEV084()
Local cParam    := PARAMIXB[1]
Local aWebCols  := {}
Conout('Passou pelo ponto de entrada PEV084. - Parametro : '+Str(cParam))     

Do Case    
Case cParam == 1			
	aAdd( aWebCols, { "BUDGETID", "D" } )		
	aAdd( aWebCols, { "REGISTERDATE", "D" } )		
	aAdd( aWebCols, { "CUSTOMERCODE", "N", 	{ "BRWCUSTOMER", { "CCUSTOMERCODE", "CCODE" }, 	{ "CCUSTOMERUNIT", "CUNIT" } },{ "CCODE", "CUNIT", "CDESCRIPTION" } } )	
	aAdd( aWebCols, "CUSTOMERUNIT" )		
 /*	aAdd( aWebCols, { "DELIVERYCUSTOMER", "N", 	{ "BRWCUSTOMER", ;													
												{ "CDELIVERYCUSTOMER", "CCODE" }, ;
												{ "CDELIVERYUNITCODE", "CUNIT" } ;
												}, ;
												{ "CCODE", "CUNIT", "CDESCRIPTION" } } )		
	aAdd( aWebCols, "DELIVERYUNITCODE" )					
	*/aAdd( aWebCols, { "PAYMENTPLANCODE", "N", { "BRWPAYMENTPLAN", ;													
											  { "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
											  }, ;
											  { "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
	aAdd( aWebCols, { "PRICELISTCODE", "D" } ) 	
  	aAdd( aWebCols,   "CJ_XVLDESC"  ) 
 //	aAdd( aWebCols,  "DISCOUNT1" )		
 //	aAdd( aWebCols, { "DISCOUNT2", "D" } )		
 //	aAdd( aWebCols, { "DISCOUNT3", "D" } )		
 //	aAdd( aWebCols, { "DISCOUNT4", "D" } )		
	aAdd( aWebCols, "QUOTATIONORORDERID" )		
	aAdd( aWebCols,  "FREIGHTVALUE" )		
	aAdd( aWebCols, { "INSURANCEVALUE", "D" } )		
	aAdd( aWebCols, { "ADDITIONALEXPENSEVALUE", "D" } )		
	aAdd( aWebCols, { "INDEPENDENTFREIGHT", "D" } )		
	aAdd( aWebCols, { "EXPIRATIONDATE", "D" } )		
	aAdd( aWebCols, { "INDEMNITYVALUE", "D" } )		
	aAdd( aWebCols, { "INDEMNITYPERCENTAGE", "D" } )		
	aAdd( aWebCols, { "DESCRIPTIONSTATUS", "D" } ) 
	// campo customizado
  	aAdd( aWebCols,   "CJ_XMENORC"  ) 
  	aAdd( aWebCols,   "CJ_XMENOR1"  )  
 
   //	aAdd( aWebCols,   "CJ_PROSPE"  )
  	//aAdd( aWebCols,   "CJ_XMEN"  )  Nao aceta campo memo , dis que variavel nao existe. ** TESTAR  É PARA ACEITAR

	
Case cParam == 2 			
  //	aAdd( aWebCols, { "PRODUCTID", "N", { "GETCATALOG",{ "CPRODUCTID", "CPRODUCTCODE" }                                           },{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )
	aAdd( aWebCols, { "PRODUCTID", "N", { "GETCATALOG",{ "CPRODUCTID", "CPRODUCTCODE" } ,{ "CPRODUCTDESCRIPTION", "CDESCRIPTION"} },{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )		
	aAdd( aWebCols, { "PRODUCTDESCRIPTION", "N", 30, .T. } )		
	aAdd( aWebCols, { "QUANTITY", "N", 3 } )		
	aAdd( aWebCols, { "NETUNITPRICE", "N", 9, .T. } )		
	aAdd( aWebCols, { "CUSTOMERBUDGETID", "N", 5 } )		
	aAdd( aWebCols, { "NETTOTAL", "N", 0, .F. } )		
EndCase 
Return aWebCols