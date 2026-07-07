/*
+--------------------------------------------------------------------------+
! Função    ! ACOM000I   ! Autor !Luis                ! Data ! 12/12/2022  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Exibe log de importacao.                                     !
+-----------+--------------------------------------------------------------+
*/
User Function ACOM000I(_cDir,_cArqLg,_cDirTemp)

CPYS2T(_cDir + _cArqLg, _cDirTemp)

//FErase(cDir+cAArq)
ShellExecute( "open", _cDirTemp + Alltrim(_cArqLg) , "" , "" ,  1 )

Return()
