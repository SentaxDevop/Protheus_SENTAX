//----------------------------------------------------------
//Importação do titulos do contas a receber de outro sistema
//----------------------------------------------------------
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

User Function IMPTIT()

Private _aArea := GetArea()
Private _cArq  := Space(08)
Private cFil   := ""                  //Filial
Private cPre   := ""                  //Prefixo
Private cNat   := ""                  //Natureza
Private cTip   := ""                  //Tipo
Private cSit   := ""                  //Situacao
Private cPor   := ""                  //Portador
Private cAge   := ""                  //Agencia
Private cCon   := ""                  //Conta

Private cCli   := ""
Private cLoj   := ""

If (Select("TMP") <> 0)
	dbSelectArea("TMP")
	dbCloseArea()
Endif		
           
//Definicoes de tela
#define CLR_HBLUE      16711680       // RGB(   0,   0, 255 )
#define CLR_HGREEN        65280       // RGB(   0, 255,   0 )
#define CLR_HGRAY      12632256       // RGB( 192, 192, 192 )
#define CLR_HRED            255       // RGB( 255,   0,   0 )
#define CLR_YELLOW        65535       // RGB( 255, 255,   0 )
#define CLR_WHITE      16777215       // RGB( 255, 255, 255 )
                                                                             
//Interface                                                
DEFINE FONT oFnt NAME "Arial" SIZE 6,22 BOLD

@ 125,200 To 309,571 DIALOG oLeDBF TITLE OemToAnsi("Importação Contas a Receber")
@ 005,002 To 050,183
oSay1 := tSay():New(10,05,{||OemToAnsi("Esta rotina irá importar os titulos a receber através de arquivo. ")},oLeDBF,,oFnt,,,,.T.,CLR_BLUE,CLR_RED,300,20)
oSay2 := tSay():New(34,05,{||OemToAnsi("O arquivo deverá estar na pasta SYSTEM do sistema, em formato DBF.")},oLeDBF,,oFnt,,,,.T.,,CLR_RED,300,20)
oSay3 := tSay():New(55,05,{||"Informe o nome do arquivo sem extensão e aguarde o processamento...         " },oLeDBF,,oFnt,,,,.T.,CLR_BLUE,CLR_RED,300,20)
@ 068,002 To 090,060
@ 075,005 Get _cArq PICTURE "@!" SIZE 40,30
@ 077,045 Say ".DBF"

@ 75,126 BMPBUTTON TYPE 01 ACTION OkLeDBF()
@ 75,156 BMPBUTTON TYPE 02 ACTION Close(oLeDBF)

Activate Dialog oLeDBF Centered

Return                                         

//---------------------
Static Function OkLeDBF

//Arquivos e ordens utilizados
dbSelectArea("SE1")
SE1->(dbSetOrder(1))

//Verifica se o arquivo para importação existe
_cArq := Alltrim(_cArq)+".DBF"

If !File(_cArq)
   MsgStop("Arquivo "+_cArq+" Inexistente... Verifique","Atenção")
   Return
Endif

//Abre o arquivo para importação
//Use &_cArq Alias TMP Shared New
dbSelectArea("TMP")
//Index on TMP->CODPRO To CODIGO

//Iniciando o processamento
Processa({|| RunCont() },"Processando Informações...")
Return

//Funcao auxiliar chamada pela PROCESSA
Static Function RunCont()

//Conta os registros
ProcRegua(RecCount())

//Inicia controle transações
Begin Transaction
                
TMP->(dbGoTop())
While TMP->(!Eof())
	IncProc("Importando Registros... Aguarde")

	SE1->(dbSeek(xFilial("SE1")+TMP->E1_NUM,.T.))
	If SE1->(!Found())
			If Reclock("SE1",.T.)      
				//Valida a Filial
				Do Case
					Case Alltrim(TMP->E1_FILIAL) == "001"
						cFil := "010101"
					Case Alltrim(TMP->E1_FILIAL) == "004"
						cFil := "030301"					
					Case Alltrim(TMP->E1_FILIAL) == "005"
						cFil := "020201"
					Case Alltrim(TMP->E1_FILIAL) == "006"
						cFil := "020202"												
					Otherwise
						cFil := ""
				EndCase
			    
				//Valida o Prefixo
				Do Case
					Case Alltrim(TMP->E1_PREFIXO) $ "CHD/CHE"
						cPre := "CHE"										
					Case Alltrim(TMP->E1_PREFIXO) == "SER"
						cPre := "2"																
					Case Alltrim(TMP->E1_PREFIXO) == "DP2"
						cPre := "MAN"																						
					Case Alltrim(TMP->E1_PREFIXO) == "SER"
						cPre := "2"																						
					Otherwise
						cPre := "1"
				EndCase			
				
				//Valida a Natureza
				Do Case
					Case Alltrim(TMP->E1_PORTADO) == "617"
						cNat := "10111"                     //Permuta
					Case Alltrim(TMP->E1_PORTADO) == "621"
						cNat := "10112"			         	//Leasing (Rec. Residual)		
					Case Alltrim(TMP->E1_PORTADO) == "620"
						If Alltrim(TMP->E1_PREFIXO) == "SER"
							cNat := "10103"			        //Locacao de Maq.
						Else
							cNat := "10110"                 //Venda de Maq.
						EndIf
					Otherwise
						cNat := "10101"
				EndCase
				
				//Valida o Tipo
				Do Case
					Case Alltrim(TMP->E1_TIPO) == "FAT"
						cTip := "FT"
					Case Alltrim(TMP->E1_TIPO) $ "CHD/CHP"
						cTip := "CH"
					Case Alltrim(TMP->E1_TIPO) == "DEV"
						cTip := "NCC"						
					Otherwise
						cTipo := "NF"						
				EndCase
				
				//Valida a Situacao
				Do Case
					Case Alltrim(TMP->E1_PORTADO) == "619"
						cSit := "H"
					Case Alltrim(TMP->E1_PORTADO) == "614"
						cSit := "F"
					Case Alltrim(TMP->E1_PORTADO) $ "341/104/399"
						cSit := "1"						
					Case Alltrim(TMP->E1_PORTADO) == "615"
						If Alltrim(TMP->E1_CONTA) == "TERCEIRIZA"
							cSit := "1"
						Else
							cSit := "0"
						EndIf
					Otherwise
						cSit := "0"
				EndCase
				
				//Valida o Portador
				Do Case
					Case Alltrim(TMP->E1_PORTADO) $ "104/399/341"
						cPor := Alltrim(TMP->E1_PORTADO)
					Case Alltrim(TMP->E1_PORTADO) $ "613/614"
						cPor := "900"
					Case Alltrim(TMP->E1_PORTADO) == "615"
						If Alltrim(TMP->E1_CONTA) == "TERCEIRIZA"
							cPor := "901"
						Else
							cPor := ""
						EndIf
					Otherwise
						cPor := ""
				EndCase
				
				//Valida a Agencia
				Do Case				
					Case Alltrim(TMP->E1_PORTADO) $ "104/399/341"
						cAge := Alltrim(TMP->E1_AGEDEP)
					Case Alltrim(TMP->E1_PORTADO) $ "613/614"
						cAge := "00001"			   
					Case Alltrim(TMP->E1_PORTADO) == "615"
						If Alltrim(TMP->E1_CONTA) == "TERCEIRIZA"
							cAge := "00001"
						Else
							cAge := ""
						EndIf			
					Otherwise
						cAge := ""
				EndCase
				
				//Valida a Conta
				Do Case
					Case Alltrim(TMP->E1_PORTADO) $ "104/399/341"
						cCon := Alltrim(TMP->E1_CONTA)
					Case Alltrim(TMP->E1_PORTADO) $ "613,614"
						cCon := "0000000001"
					Case Alltrim(TMP->E1_PORTADO) == "615"
						If Alltrim(TMP->E1_CONTA) == "TERCEIRIZA"
							cCon := "0000000001"
						Else
							cCon := ""
						EndIf
					Otherwise
						cCon := ""
				EndCase				
			
				SE1->E1_FILIAL  := cFil
				SE1->E1_PREFIXO := cPre
				SE1->E1_NUM 	:= Alltrim(TMP->E1_NUM)  
                SE1->E1_XSERASA := IIF(Alltrim(TMP->E1_PORTADO) == "615" .AND. Alltrim(TMP->E1_CONTA) == "SERASA", "S", "N")
				SE1->E1_PARCELA := Alltrim(TMP->E1_PARCELA)
				SE1->E1_PORTADO	:= cPor
				SE1->E1_AGEDEP	:= cAge
				SE1->E1_CONTA	:= cCon								
				SE1->E1_TIPO 	:= cTip
				SE1->E1_NATUREZ	:= cNat 
				SE1->E1_SITUACA := cSit				
				SE1->E1_EMISSAO := TMP->E1_EMISSAO
				SE1->E1_EMIS1 	:= TMP->E1_EMISSAO
				SE1->E1_VENCTO 	:= TMP->E1_VENCTO
				SE1->E1_VENCORI := TMP->E1_VENCTO 
				SE1->E1_VENCREA := TMP->E1_VENCTO				
				SE1->E1_MOEDA 	:= Val("1")
				SE1->E1_OCORREN := "01" 
				SE1->E1_STATUS 	:= "A"               
				SE1->E1_FLUXO   := "S"
				SE1->E1_TIPODES := "1"     
				SE1->E1_FILORIG := cFil
				SE1->E1_MULTNAT := "2"
				SE1->E1_PROJPMS := "2"   
				SE1->E1_MODSPB  := "1"   
				SE1->E1_SCORGP  := "2" 
				SE1->E1_RELATO  := "2"   
				SE1->E1_APLVLMN := "1"
				SE1->E1_ORIGEM 	:= "FINA040"
				SE1->E1_NUMBCO  := TMP->E1_NUMBCO
  				
                cCli := SUBSTR(TMP->E1_CLIENTE,1,6)
                cLoj := SUBSTR(TMP->E1_LOJA,1,2)
                                
  				SE1->E1_CLIENTE	:= cCli
  				SE1->E1_LOJA	:= cLoj
  				//MsgInfo(cCli + "-" + cLoj + "-", "Teste")
  				SE1->E1_NOMCLI  := SUBSTR(POSICIONE("SA1",1,xFilial("SA1")+cCli+cLoj,"A1_NREDUZ"),1,20)
                
				SE1->E1_VALOR   := Round(Val(TMP->E1_VALOR),2) 
				SE1->E1_SALDO   := Round(Val(TMP->E1_SALDO),2) 
				SE1->E1_VLCRUZ  := Round(Val(TMP->E1_VALOR),2) 
                SE1->E1_XIMPORT := "S"
		 		MsUnlock("SE1")
			Endif              
	Endif
		TMP->(dbSkip())
Enddo

/*Private cQuery  := ""

cQuery := " UPDATE "
cQuery += RetSqlName("SE1")+" SE1,"+RetSqlName("SA1")+" SA1"
cQuery += " SET "
cQuery += " E1_NOMCLI = A1_NREDUZ "
cQuery += " WHERE "
cQuery += " E1_CLIENTE+E1_LOJA = A1_COD+A1_LOJA "

TcSqlExec(cQuery)
*/

//Finaliza controle transações
End Transaction

Return