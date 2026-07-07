#INCLUDE 'PROTHEUS.CH'

User Function TK271ROTM()

    Local aRotUser  := {} //Adiciona Rotina Customizada aos botoes do Browse

    If __cUserId == "000314" //Somente para michele farias.
        aAdd( aRotUser, { 'Alterar Chamadas' ,'U_ATMK015', 0 , 4 })
    EndIf

  aAdd(aRotUser,{'Baixar SAC', 'U_ATMK016()', 0, 5})

Return(aRotUser)


