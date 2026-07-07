/*
+--------------------------------------------------------------------------+
! Função    ! ACOM000H   ! Autor !Luis                ! Data ! 12/12/2022  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Cria log de importacao.                                      !
+-----------+--------------------------------------------------------------+
*/
User Function ACOM000H(_cDir,_cArqLg,_nhdllog)

//cria arquivo de log
_cDir := "\log_integracoes\"
If !ExistDir(_cDir)
	//cria diretorio
	MakeDir(_cDir)
EndIf

_cArqLg  := Alltrim(_cArqLg) + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "_9999"  + ".TXT"
_nhdllog := msFCreate( Alltrim(_cDir + _cArqLg) )

Return(_nhdllog)
