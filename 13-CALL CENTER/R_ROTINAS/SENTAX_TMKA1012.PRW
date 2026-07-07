


User Function TMKA1012
lRet:=.t.

if ALTERA
    nPosItem:=aScan(aHeader,{|X|ALLTRIM(X[2])=='C6_ITEM'})
    DBSelectArea('SUB')
    DbSetOrder(3)
    if(dbSeek(xFilial('SUB')+SC5->C5_NUM+aCols[n][nPosItem]))
        If IsBlind()
            cLogTxt := "O valor deste item não será alterado pois a origem é CALLCENTER - [TMKA1012]"
            Conout(cLogTxt)		
        Else
            ALERT('O valor deste item não será alterado pois a origem é CALLCENTER')
        End
        lRet:=.f.
    endif
ENDIF
return lRet
