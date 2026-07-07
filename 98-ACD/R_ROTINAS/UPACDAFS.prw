#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³UPACDAFS  ³ Autor ³ MICROSIGA             ³ Data ³ 13/03/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Principal                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UPACDAFS()
	
	cArqEmp 		:= "SigaMat.Emp"
	__cInterNet 	:= Nil
	
	PRIVATE cMessage
	PRIVATE aArqUpd	 := {}
	PRIVATE aREOPEN	 := {}
	PRIVATE oMainWnd
	Private nModulo 	:= 51 // modulo SIGAHSP
	
	Set Dele On
	
	lEmpenho				:= .F.
	lAtuMnu					:= .F.
	
	Processa({|| ProcATU()},"Processando [UPACDAFS]","Aguarde , processando preparação dos arquivos")
	
Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcATU   ³ Autor ³                       ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao dos arquivos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Baseado na funcao criada por Eduardo Riera em 01/02/2002   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcATU()    
	
	Local cTexto    	:= ""
	Local cFile     	:= ""
	Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"
	Local nRecno    	:= 0
	Local nI        	:= 0
	Local nX        	:= 0
	Local aRecnoSM0 	:= {}
	Local lOpen     	:= .F.
	
	ProcRegua(1)
	IncProc("Verificando integridade dos dicionários....")
	If (lOpen := IIF(Alias() <> "SM0", MyOpenSm0Ex(), .T. ))
		
		dbSelectArea("SM0")
		dbGotop()
		While !Eof()
			If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
			dbSkip()
		EndDo
		
		If lOpen
			For nI := 1 To Len(aRecnoSM0)
				SM0->(dbGoto(aRecnoSM0[nI,1]))
				RpcSetType(2)
				RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
				nModulo := 51 // modulo SIGAHSP
				lMsFinalAuto := .F.
				cTexto += Replicate("-",128)+CHR(13)+CHR(10)
				cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)
				
				ProcRegua(8)
				
				Begin Transaction
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o dicionario de arquivos.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc("Analisando Dicionario de Arquivos...")
				cTexto += GeraSX2()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o dicionario de dados.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc("Analisando Dicionario de Dados...")
				cTexto += GeraSX3()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza os indices.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc("Analisando arquivos de índices. "+"Empresa : "+SM0->M0_CODIGO+" Filial : "+SM0->M0_CODFIL+"-"+SM0->M0_NOME)
				cTexto += GeraSIX()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza os Consulta padrao.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc("Analisando Consulta Padrão...")
				cTexto += GeraSXB() 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza os parametros      .³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc("Analisando Parâmetros...")
				cTexto += GeraSX6() 
				
				
				End Transaction
				
				__SetX31Mode(.F.)
				For nX := 1 To Len(aArqUpd)
					IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
					If Select(aArqUpd[nx])>0
						dbSelecTArea(aArqUpd[nx])
						dbCloseArea()
					EndIf
					X31UpdTable(aArqUpd[nx])
					If __GetX31Error()
						Alert(__GetX31Trace())
						Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
						cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
					EndIf
					dbSelectArea(aArqUpd[nx])
				Next nX
				
				RpcClearEnv()
				If !( lOpen := MyOpenSm0Ex() )
					Exit
				EndIf
			Next nI
			
			If lOpen
				
				cTexto 				:= "Log da atualizacao " + CHR(13) + CHR(10) + cTexto
				__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)
				
				DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
				DEFINE MSDIALOG oDlg TITLE "Atualizador [UPACDAFS] - Atualizacao concluida." From 3,0 to 340,417 PIXEL
				@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
				DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
				ACTIVATE MSDIALOG oDlg CENTER
				
			EndIf
			
		EndIf
		
	EndIf
	
Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0Ex³ Autor ³Sergio Silveira       ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyOpenSM0Ex()
	
	Local lOpen := .F.
	Local nLoop := 0
	
	For nLoop := 1 To 20
	//	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. )
		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex("SIGAMAT.IND")
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
	
	If !lOpen
		Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 )
	EndIf
	
Return( lOpen )




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraSX2  ³ Autor ³ MICROSIGA             ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSX2()      
	
	Local aArea 			:= GetArea()
	Local i      		:= 0
	Local j      		:= 0
	Local aRegs  		:= {}
	Local cTexto 		:= ''
	Local lInclui		:= .F.
	
	aRegs  := {}
	AADD(aRegs,{"Z07","                                        ","Z07010  ","CONTROLE ETIQUETAS DE VOLUME  ","CONTROLE ETIQUETAS DE VOLUME  ","CONTROLE ETIQUETAS DE VOLUME  ","                                        ","E","E","E",00," ","                                                                                                                                                                                                                                                          "," ",00,"                                                                                                                                                                                                                                                              "})
	
	dbSelectArea("SX2")
	dbSetOrder(1)
	
	For i := 1 To Len(aRegs)
		
		dbSetOrder(1)
		lInclui := !DbSeek(aRegs[i, 1])
		
		cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")
		
		RecLock("SX2", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				If allTrim(Field(j)) == "X2_ARQUIVO"
					aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
				EndIf
				If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
					Loop
				Else
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	Next i
	
	RestArea(aArea)
	
Return('SX2 : ' + cTexto  + CHR(13) + CHR(10))    



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraSX3  ³ Autor ³ MICROSIGA             ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSX3()             
	
	Local aArea 			:= GetArea()
	Local i      		:= 0
	Local j      		:= 0
	Local aRegs  		:= {}
	Local cTexto 		:= ''
	Local lInclui		:= .F.
	
	aRegs  := {}
	AADD(aRegs,{"Z07","01","Z07_FILIAL","C",06,00,"Filial      ","Sucursal    ","Branch      ","Filial do Sistema        ","Sucursal                 ","Branch of the System     ","@!                                           ","                                                                                                                                ","€€€€€€€€€€€€€€€","                                                                                                                                ","      ",01,"şÀ"," "," ","U","N"," "," "," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","033"," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," "," "," ","               ","N","N","N"})
	AADD(aRegs,{"Z07","02","Z07_DOC   ","C",09,00,"Documento   ","Documento   ","Documento   ","Numero do Documento      ","Numero do Documento      ","Numero do Documento      ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","      ",00,"şÀ"," "," ","U","N","A","R"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","N","N","N"})
	AADD(aRegs,{"Z07","03","Z07_VOLUME","C",03,00,"Sequencial  ","Sequencial  ","Sequencial  ","Sequencial do Volume     ","Sequencial do Volume     ","Sequencial do Volume     ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","      ",00,"şÀ"," "," ","U","N","A","R"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","N","N","N"})
	AADD(aRegs,{"Z07","04","Z07_STATUS","C",01,00,"Conferido?  ","Conferido?  ","Conferido?  ","Conferido?               ","Conferido?               ","Conferido?               ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","      ",00,"şÀ"," "," ","U","N","A","R"," ","                                                                                                                                ","1=Nao;2=Sim                                                                                                                     ","                                                                                                                                ","'1'                                                                                                                             ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","N","N","N"})
	AADD(aRegs,{"Z07","05","Z07_DTCONF","D",08,00,"Dt. Conferen","Dt. Conferen","Dt. Conferen","Data da Conferencia      ","Data da Conferencia      ","Data da Conferencia      ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","      ",00,"şÀ"," "," ","U","N","A","R"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","N","N","N"})
	AADD(aRegs,{"Z07","06","Z07_HRCONF","C",05,00,"Hr. Conferen","Hr. Conferen","Hr. Conferen","Hora da Conferencia      ","Hora da Conferencia      ","Hora da Conferencia      ","99:99                                        ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","      ",00,"şÀ"," "," ","U","N","A","R"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","N","N","N"})

	AADD(aRegs,{"CBK","09","CBK_XDTEXP","D",08,00,"Dt. Expedica","Dt. Expedica","Dt. Expedica","Data Expedicao           ","Data Expedicao           ","Data Expedicao           ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","      ",00,"şÀ"," "," ","U","S","A","R"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","N","N","N"})
	AADD(aRegs,{"CBK","10","CBK_XQTVOL","N",12,02,"Qtd. Volume ","Qtd. Volume ","Qtd. Volume ","Quantidade de Volume     ","Quantidade de Volume     ","Quantidade de Volume     ","@E 999,999,999.99                            ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","      ",00,"şÀ"," "," ","U","N","V","R"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","N","N","N"})
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	
	For i := 1 To Len(aRegs)
		
		If(Ascan(aArqUpd, aRegs[i,1]) == 0)
			aAdd(aArqUpd, aRegs[i,1])
		EndIf
		
		dbSetOrder(2)
		lInclui := !DbSeek(aRegs[i, 3])
		
		cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")
		
		RecLock("SX3", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				If allTrim(Field(j)) == "X2_ARQUIVO"
					aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
				EndIf
				If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
					Loop
				Else
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	Next i
		
	RestArea(aArea)   
	
Return('SX3 : ' + cTexto  + CHR(13) + CHR(10))   



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraSX6  ³ Autor ³ MICROSIGA             ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSX6()   
	
	Local aArea 			:= GetArea()
	Local i      		:= 0
	Local j      		:= 0
	Local aRegs  		:= {}
	Local cTexto 		:= ''
	Local nTamFil		:= 0
	 
	aRegs  := {}  
	
	AADD(aRegs,{"010101","ST_XSERACD","C","Serie Utilizada no TelNet (ACD) para expedicao    ","Serie Utilizada no TelNet (ACD) para expedicao    ","Serie Utilizada no TelNet (ACD) para expedicao    ","                                                  ","                                                  ","                                                  ","                                                  ","                                                  ","                                                  ","1                                                                                                                                                                                                                                                         ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","U"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"020201","ST_XSERACD","C","Serie Utilizada no TelNet (ACD) para expedicao    ","Serie Utilizada no TelNet (ACD) para expedicao    ","Serie Utilizada no TelNet (ACD) para expedicao    ","                                                  ","                                                  ","                                                  ","                                                  ","                                                  ","                                                  ","1                                                                                                                                                                                                                                                         ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","U"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"020202","ST_XSERACD","C","Serie Utilizada no TelNet (ACD) para expedicao    ","Serie Utilizada no TelNet (ACD) para expedicao    ","Serie Utilizada no TelNet (ACD) para expedicao    ","                                                  ","                                                  ","                                                  ","                                                  ","                                                  ","                                                  ","1                                                                                                                                                                                                                                                         ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","U"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"030301","ST_XSERACD","C","Serie Utilizada no TelNet (ACD) para expedicao    ","Serie Utilizada no TelNet (ACD) para expedicao    ","Serie Utilizada no TelNet (ACD) para expedicao    ","                                                  ","                                                  ","                                                  ","                                                  ","                                                  ","                                                  ","1                                                                                                                                                                                                                                                         ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","U"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"      ","ST_XIMPACD","C","Indica se a impressao sera realizada via ACD.     ","Indica se a impressao sera realizada via ACD.     ","Indica se a impressao sera realizada via ACD.     ","Utilizar S=Sim e N=nao                            ","Utilizar S=Sim e N=nao                            ","Utilizar S=Sim e N=nao                            ","                                                  ","                                                  ","                                                  ","N                                                                                                                                                                                                                                                         ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","U"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"      ","ST_XEMPTRP","C","Filiais que validam a obrigatoriedade da          ","Filiais que validam a obrigatoriedade da          ","Filiais que validam a obrigatoriedade da          ","Transportadora no faturamento. Ex: 020201;020202  ","Transportadora no faturamento. Ex: 020201;020202  ","Transportadora no faturamento. Ex: 020201;020202  ","                                                  ","                                                  ","                                                  ","020201                                                                                                                                                                                                                                                    ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","U"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"      ","ST_XTRANSP","C","Código da transportadora padrão para o            ","Código da transportadora padrão para o            ","Código da transportadora padrão para o            ","caso o usuário não queira informar a transp. na   ","caso o usuário não queira informar a transp. na   ","caso o usuário não queira informar a transp. na   ","montagem de carga                                 ","montagem de carga                                 ","montagem de carga                                 ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","U"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})

	dbSelectArea("SX6")
	dbSetOrder(1)
		
	For i := 1 To Len(aRegs)
		
		cTexto += IIf( aRegs[i,1] + aRegs[i,2] $ cTexto, "", aRegs[i,1] + aRegs[i,2] + "\")
		
		dbSetOrder(1)
		lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2])
		
		cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")
		
		RecLock("SX6", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				If allTrim(Field(j)) == "X2_ARQUIVO"
					aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
				EndIf
				If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
					Loop
				Else
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	Next i
		
	RestArea(aArea)
	
Return('SX6 : ' + cTexto  + CHR(13) + CHR(10))       


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraSIX  ³ Autor ³ MICROSIGA             ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSIX()   

Local aArea 			:= GetArea()
Local i      		:= 0
Local j      		:= 0
Local aRegs  		:= {}
Local cTexto 		:= ''
Local lInclui		:= .F.

aRegs  := {}
AADD(aRegs,{"Z07","1","Z07_FILIAL+Z07_DOC+Z07_VOLUME                                                                                                                                   ","Documento+Sequencial                                                  ","Documento+Sequencial                                                  ","Documento+Sequencial                                                  ","U","                                                                                                                                                                ","          ","S"})

dbSelectArea("SIX")
dbSetOrder(1)

For i := 1 To Len(aRegs)
	
	If(Ascan(aArqUpd, aRegs[i,1]) == 0)
		aAdd(aArqUpd, aRegs[i,1])
	EndIf
	
	dbSetOrder(1)
	lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2])
	If !lInclui
		TcInternal(60,RetSqlName(aRegs[i, 1]) + "|" + RetSqlName(aRegs[i, 1]) + aRegs[i, 2])
	Endif
	
	cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")
	
	RecLock("SIX", lInclui)
	For j := 1 to FCount()
		If j <= Len(aRegs[i])
			If allTrim(Field(j)) == "X2_ARQUIVO"
				aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
			EndIf
			If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
				Loop
			Else
				FieldPut(j,aRegs[i,j])
			EndIf
		Endif
	Next
	MsUnlock()
Next i

RestArea(aArea)

Return('SIX : ' + cTexto  + CHR(13) + CHR(10))  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraSXB  ³ Autor ³ MICROSIGA             ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica para copia de dicionarios                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSXB()  
	
	Local aArea 			:= GetArea()
	Local i      		:= 0
	Local j      		:= 0
	Local aRegs  		:= {}
	Local cTexto 		:= ''
	Local lInclui		:= .F.
	
	aRegs  := {}
	AADD(aRegs,{"STAA3 ","1","01","DB","Nr. Serie Base Inst.","Nr. Serie Base Inst.","Nr. Serie Base Inst.","AA3                                                                                                                                                                                                                                                       ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","2","01","01","Cod. Cliente + Loja ","Cliente + Tienda + P","Customer + Unit + Pr","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","2","02","06","Nr.serie            ","Num. Serie          ","Serial Numb.        ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","4","01","01","Cod. Cliente        ","Cliente             ","Customer            ","AA3_CODCLIAA3_LOJA                                                                                                                                                                                                                                        ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","4","01","02","Produto/Eqto        ","Produc/Equi.        ","Prod/Equip          ","AA3_CODPRO                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","4","01","03","Nr.Serie            ","Num. Serie          ","Serial Numb.        ","AA3_NUMSER                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","4","02","01","Cod. Cliente        ","Cliente             ","Customer            ","AA3_CODCLIAA3_LOJA                                                                                                                                                                                                                                        ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","4","02","02","Produto/Eqto        ","Produc/Equi.        ","Prod/Equip          ","AA3_CODPRO                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","4","02","03","Nr.Serie            ","Num. Serie          ","Serial Numb.        ","AA3_NUMSER                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","5","01","  ","                    ","                    ","                    ","AA3->AA3_NUMSER                                                                                                                                                                                                                                           ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STAA3 ","6","01","  ","                    ","                    ","                    ","AA3_FILIAL==@#xFilial('AA3') .And. AA3_CODCLI==SA1->A1_COD .And. AA3_LOJA==SA1->A1_LOJA .And. AA3_CODPRO==SB1->B1_COD                                                                                                                                     ","                                                                                                                                                                                                                                                          "})
	
	dbSelectArea("SXB")
	dbSetOrder(1)
	
	For i := 1 To Len(aRegs)
		
		dbSetOrder(1)
		lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2] + aRegs[i, 3] + aRegs[i, 4])
		
		cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")
		
		RecLock("SXB", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				If allTrim(Field(j)) == "X2_ARQUIVO"
					aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
				EndIf
				If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
					Loop
				Else
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	Next i
	
	aRegs  := {}
	AADD(aRegs,{"STZ06 ","1","01","DB","Ocorrencias Entrega ","Ocorrencias Entrega ","Ocorrencias Entrega ","Z06                                                                                                                                                                                                                                                       ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","2","01","01","Codigo Da Ocorrencia","Codigo Da Ocorrencia","Codigo Da Ocorrencia","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","2","02","02","Descricao           ","Descricao           ","Descricao           ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","3","01","01","Cadastra Novo       ","Incluye Nuevo       ","Add New             ","01                                                                                                                                                                                                                                                        ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","4","01","01","Cod. Ocorren        ","Cod. Ocorren        ","Cod. Ocorren        ","Z06_CODOCO                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","4","01","02","Descricao           ","Descricao           ","Descricao           ","Z06_DESOCO                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","4","01","03","Tipo Ocorre.        ","Tipo Ocorre.        ","Tipo Ocorre.        ","Z06_TPCOD                                                                                                                                                                                                                                                 ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","4","02","01","Cod. Ocorren        ","Cod. Ocorren        ","Cod. Ocorren        ","Z06_CODOCO                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","4","02","02","Descricao           ","Descricao           ","Descricao           ","Z06_DESOCO                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","4","02","03","Tipo Ocorre.        ","Tipo Ocorre.        ","Tipo Ocorre.        ","Z06_TPCOD                                                                                                                                                                                                                                                 ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","5","01","  ","                    ","                    ","                    ","Z06->Z06_CODOCO                                                                                                                                                                                                                                           ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STZ06 ","6","01","  ","                    ","                    ","                    ","!(Z06->Z06_CODOCO $ '001x002x003x004x005x')                                                                                                                                                                                                               ","                                                                                                                                                                                                                                                          "})
	
	dbSelectArea("SXB")
	dbSetOrder(1)
	
	For i := 1 To Len(aRegs)
		
		dbSetOrder(1)
		lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2] + aRegs[i, 3] + aRegs[i, 4])
		
		cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")
		
		RecLock("SXB", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				If allTrim(Field(j)) == "X2_ARQUIVO"
					aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
				EndIf
				If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
					Loop
				Else
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	Next i
	
	aRegs  := {}
	AADD(aRegs,{"STSF21","1","01","DB","NF de Saida         ","NF de Saida         ","NF de Saida         ","SF2                                                                                                                                                                                                                                                       ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STSF21","2","01","01","Numero + Serie docto","N. documento + Serie","Document + Series + ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STSF21","4","01","01","Numero              ","N. Documento        ","Document            ","F2_DOC                                                                                                                                                                                                                                                    ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STSF21","4","01","02","Serie Docto.        ","Serie Doc.          ","Series              ","F2_SERIE                                                                                                                                                                                                                                                  ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STSF21","4","01","03","Cliente             ","Cliente             ","Customer            ","F2_CLIENTE                                                                                                                                                                                                                                                ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STSF21","4","01","04","Loja                ","Tienda              ","Unit                ","F2_LOJA                                                                                                                                                                                                                                                   ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STSF21","5","01","  ","                    ","                    ","                    ","SF2->F2_DOC                                                                                                                                                                                                                                               ","                                                                                                                                                                                                                                                          "})
	AADD(aRegs,{"STSF21","5","02","  ","                    ","                    ","                    ","SF2->F2_SERIE                                                                                                                                                                                                                                             ","                                                                                                                                                                                                                                                          "})
	
	dbSelectArea("SXB")
	dbSetOrder(1)
	
	For i := 1 To Len(aRegs)
		
		dbSetOrder(1)
		lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2] + aRegs[i, 3] + aRegs[i, 4])
		
		cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")
		
		RecLock("SXB", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				If allTrim(Field(j)) == "X2_ARQUIVO"
					aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
				EndIf
				If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
					Loop
				Else
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	Next i
	
	RestArea(aArea)
	
Return('SXB : ' + cTexto  + CHR(13) + CHR(10))
