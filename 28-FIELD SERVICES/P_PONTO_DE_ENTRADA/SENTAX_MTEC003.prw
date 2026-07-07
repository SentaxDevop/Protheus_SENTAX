#include 'protheus.ch'
#include 'parmtype.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MTEC003
Valida datas de apontamento de OS
                

@author		Thiago Henrique dos santos
@since		15/06/2018     
@version 	P12
@param		cOS - Codigo da OS
			dData - data informada
@return 	lRet - .t. se data válida, .f. caso contrário    
 
/*/
//-------------------------------------------------------------------
user function MTEC003(cOS, dData)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaAB9 := AB9->(GetArea())  

DbSelectArea("AB6")
AB6->(DbSetOrder(1))

if AB6->(DbSeek(xFilial("AB6")+substr(cOS,1,6)))

	If dData < AB6->AB6_EMISSA
		lRet := .F.
		alert("Data informada não pode ser anterior à data de emissão da OS: "+DToC(AB6->AB6_EMISSA))
	Endif    
	
	If dData > DDATABASE
		lRet := .F.
   		alert("Data informada não pode ser maior que a data base "+DToC(DDATABASE))
	Endif
Endif  
	
If lRet

	DbSelectArea("AB9")
	AB9->(DbSetOrder(1))	
	AB9->(DbSeek(xFilial("AB9")+cOS))
	
	While lret .And. AB9->(!Eof()) .and. xFilial("AB9")+cOS == AB9->(AB9_FILIAL+AB9_NUMOS)
	
		If AB9->AB9_DTFIM <> dData .AND. M->AB9_SEQ <> AB9->AB9_SEQ
			lRet := .F.
	 		alert("Data informada não pode ser diferente de atendimento já gravado: "+DToC(AB9->AB9_DTFIM))
		Endif  
		
		AB9->(DbSkip())
	Enddo  

Endif

AB9->(RestArea(aAreaAB9))
RestArea(aArea)
	
return lRet