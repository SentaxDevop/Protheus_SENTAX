#Include 'Protheus.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} SX5Nota
Valida Serie de NF

@author 	Thiago Henrique dos Santos
@since 	 	13/08/2014
@version 	P11
@return 	lRet	.T. se permite serie, .F. caso contrário
/*/
//-------------------------------------------------------------------
User Function SX5Nota()
Local lRet := .T.
Local cTes     := Alltrim(GetMV("ST_TESSERC"))
Local aArea	:= GetArea()
Local aAreaSC6 := SC6->(GetArea())

If IsInCallStack("Ma410PvNfs")

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	
	SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
	While SC6->(!Eof()) .AND. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM) .AND. lRet
	
		If Alltrim(SC6->C6_TES) $ cTes .AND. Trim(PadR(SX5->X5_CHAVE,3)) <> "2"
		
			lRet := .F.   		
					
		ElseIf !(Alltrim(SC6->C6_TES) $ cTes) .AND. Trim(PadR(SX5->X5_CHAVE,3)) == "2"
		
			lRet := .F.
   					
		Endif
	
		SC6->(DbSkip())
	Enddo  


Endif

SC6->(RestArea(aAreaSC6))
RestArea(aArea)

Return lRet

