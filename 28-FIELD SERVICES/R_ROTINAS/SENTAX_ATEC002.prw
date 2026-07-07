#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#Include "TOPCONN.CH"  
#Include "RWMAKE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ATEC002
Monta a tela para consulta padrão de técnicos Disponiveis

@author Alessandro Smaha
@since  09/07/2013  
/*/
//-------------------------------------------------------------------
User Function ATEC002() 
 
	Local aAreaSA1  := SA1->(GetArea())
	Local aAreaAA3  := AA3->(GetArea())
	Local lRet		:= .T.
	Local aTitulo	:= {}
	Local aCabec	:= {}
	Local aCodigos  := {}
	Local aItens    := {} 
	Local aButtons	:= {}
	Local nX		:= 0
	Local nRet		:= 0
	Local lCancel   := .T.
	Local cDescri 	:= ""  
	
	DbSelectArea("AA1")
	AA1->(DbSetOrder(1))
	AA1->(DbGoTop())
	While ! AA1->(Eof()) 		
		If AA1->AA1_ALOCA == "1" // 1=Disponivel;2=Indisponivel	
			Aadd( aItens, { AA1->AA1_CODTEC, AA1->AA1_NOMTEC } )  
		EndIf
		AA1->(DbSkip()) 
	EndDo
		    
	cDescri := "Técnicos Disponiveis"
	 	
	If Len(aItens) > 0
			
		Aadd(aTitulo,'Código' )
		Aadd(aTitulo,'Nome' )

		aCabec := aClone(aTitulo)
				
		nRet := TmsF3Array( aTitulo, aItens, OemToAnsi(cDescri), lCancel,aButtons, aCabec )
			 	
		If !Empty(nRet) 
		
			VAR_IXB := IIF(Empty(M->AB6_XCDAUX),"",Alltrim(M->AB6_XCDAUX)+";") + aItens[nRet][1]
			  
		EndIf
		
	Endif  
	    	                 
	RestArea(aAreaSA1)   
	RestArea(aAreaAA3) 
	
Return (lRet)