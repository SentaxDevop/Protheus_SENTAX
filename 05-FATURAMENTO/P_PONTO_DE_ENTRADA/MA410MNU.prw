#include "rwmake.ch"

/*/{Protheus.doc} MA410MNU
    Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina
    @type function
    @version 1.0
    @author Alfred Andersen
    @since 9/11/2025
/*/
User Function MA410MNU()

	Local aSubRot := {}

	aadd(aSubRot, {"WMS - Envia Pedido"       , "U_XXfPnlWMS()", 0, 4, 0, NIL})
	aadd(aSubRot, {"WMS - Envia NF"           , "U_AWMS001()"  , 0, 4, 0, NIL})
	aadd(aSubRot, {'Remove Bloqueio de Edição', "U_AFAT013"    , 0, 4})


    aadd(aRotina, {"Informativo"            , "U_FATA1003(SC5->C5_NUM)", 0, 4, 0, NIL})
    aadd(aRotina, {"Consulta Log Bloq Regra", "U_CFAT001"              , 0, 6, 0, nil})
    aadd(aRotina, {"Cyberlog"               , aSubRot                  , 0, 4, 0, NIL})

Return()
