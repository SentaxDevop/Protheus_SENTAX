#INCLUDE "TOTVS.CH"

USER FUNCTION WSUSRFIELD()

 Local cCursor := PARAMIXB[1]
 Local aReturn := {}
Conout('Passou pelo ponto de entrada WSUSRFIELD.')    
 DO CASE
  CASE cCursor == "SCJ"
   conout("WSUSRFIELD - SCJ")
   aAdd( aReturn, "CJ_XVLDESC"  )
   aAdd( aReturn, "CJ_XMENORC" )
   aAdd( aReturn, "CJ_XMENOR1"  ) 
       
   // aAdd( aReturn, "CJ_PROSPE"  )
   //aAdd( aReturn, "CJ_XMEN" ) // nao aceita campo memo pqp..** TESTAR  É PARA ACEITAR
 EndCase

Return( aReturn )