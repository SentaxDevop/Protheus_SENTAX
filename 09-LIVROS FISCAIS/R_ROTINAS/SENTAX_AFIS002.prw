#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} AFIS002
//TODO Monta Janela para consultar e alterar o conteúdo do parametro MV_ESTICM
@author Daniel Rodrigues
@since 17/08/2018
@version 1.0
@return Nil

@type function
/*/
User function AFIS002()

Private cGet1 := PADR(GetMv("MV_ESTICM",,""),200)
Private cGet2 := PADR(GetMv("MV_TESPCNF",,""),200)
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlg1","oGrp1","oSay1","oGet1","oGrp2","oSay2","oGet2","oSBtnOk","oSBtnCanc")

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1     := MSDialog():New( 092,232,257,906," Alteração Parâmetros ",,,.F.,,,,,,.T.,,,.T. )
oGrp1     := TGroup():New( 008,012,032,328," MV_ESTICM ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1     := TSay():New( 018,020,{||"Conteúdo : "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
oGet1     := TGet():New( 016,052,{|u| If(PCount()>0,cGet1:=u,cGet1)},oGrp1,264,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet1",,)
oGrp2     := TGroup():New( 038,012,062,328," MV_TESPCNF ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay2     := TSay():New( 048,020,{||"Conteúdo : "},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,008)
oGet2     := TGet():New( 046,052,{|u| If(PCount()>0,cGet2:=u,cGet2)},oGrp2,264,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet2",,)
oSBtnOk   := SButton():New( 066,300,1,{|| xAtuMV(), oDlg1:End()},oDlg1,,"", )
oSBtnCanc := SButton():New( 066,012,2,{|| oDlg1:End()},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

Return


/*/{Protheus.doc} xAtuMV
//TODO Faz a alteração do parametro MV_ESTICM
@author Daniel Rodrigues
@since 17/08/2018
@version 1.0
@return nil

@type function
/*/
Static Function xAtuMV()

	If MSGYESNO( " Deseja confirmar a alteração do parametro? ", "Confirma" )

		PutMv('MV_ESTICM',cGet1)
		PutMV('MV_TESPCNF',cGet2)

	EndIf

Return