#include "totvs.ch"
#include "FileIO.ch" 
#define ENTER Chr(13) + Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³mfin001   ºAutor  ³Henrique            º Data ³  04/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Vare arquivo de retorno do serasa faz alteraçoes           º±±
±±º          ³  de data de pagamento                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function mfin001() // U_mfin001()
Local cPerg       	:= "PERSERASA"
    

If !Pergunte(cPerg,.T.)
	Return()
EndIf  
        
  

Processa({|| RunAdd() },"Processando...")

Return ()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ RUNCONT  º Autor ³ Henrique            º Data ³  08/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunCont
Local lEmp := .F.   
 ProcRegua(len(aLinhas))
If len(aLinhas) > 0
	For i:=1 to len(aLinhas) 
		If  substr(aLinhas[i],1,2)  = "00"
	 		dtfin := Substr(aLinhas[i],51,2)+"/"+Substr(aLinhas[i],49,2)+"/"+Substr(aLinhas[i],45,4)
	 	  	If SM0->M0_CGC == Substr(aLinhas[i],23,14)
	 	  		lEmp := .T.
	 	  	endif	
	 	endif
	 	If lEmp
			If substr(aLinhas[i],1,2)== "01"
				// Vare SE1...
				DbSelectArea("SE1")
				DbSetOrder(1)
				DbSeek(xFilial("SE1")+Substr(aLinhas[i],68,3)+Substr(aLinhas[i],71,9)+Substr(aLinhas[i],80,2)+Substr(aLinhas[i],82,3))
				IncProc("Atualizando Registros. Aguarde...Nota : "+Substr(aLinhas[i],71,9)+" Serie : "+Substr(aLinhas[i],80,2) ) 
					If EMPTY(SE1->E1_BAIXA)
				    	aLinhas[i]:=    ENTER+ Substr(aLinhas[i],1,57)+"        "+Substr(aLinhas[i],66,131)
					ELSE 
						If CTOD(dtfin ) > SE1->E1_BAIXA
							IF nSaldo == 1
								IF SE1->E1_SALDO >0
									aLinhas[i]:=   ENTER+ Substr(aLinhas[i],1,57)+"        "+Substr(aLinhas[i],66,131)
								ELSE			
									aLinhas[i]:=   ENTER+ Substr(aLinhas[i],1,57)+DTOS(SE1->E1_BAIXA)+Substr(aLinhas[i],66,131)
		 						ENDIF
		 					ELSE
		 						aLinhas[i]:=   ENTER+ Substr(aLinhas[i],1,57)+DTOS(SE1->E1_BAIXA)+Substr(aLinhas[i],66,131)	
		 					ENDIF 
						ELSE
							aLinhas[i]:=   ENTER+ Substr(aLinhas[i],1,57)+"        "+Substr(aLinhas[i],66,131)
						ENDIF
					ENDIF	   
			ELSE
				IF !(substr(aLinhas[i],2,1) $ "0/1")
					aLinhas[i]:=   ENTER+ aLinhas[i] 
				ENDIF
			EndIf
		Else
				MsgAlert("Este Arquivo não pertence a esta filial","Atenção")
				I := LEN(aLinhas)
				fClose(nHd2) 

		EndIf     
 	 // GRAVA EM NOVO ARQUIVO
 		FWRITE (nHd2,aLinhas[i],LEN(aLinhas[i])) 
	NEXT		               
ENDIF

fClose(nHd2) 

Return()   

Static Function RunAdd  
Local lMsg := .T.
Private aLinhas   := {} 
Private cArqTxt := " "
Private nSaldo
Private nHdl 


nSaldo := MV_PAR02
// Abre arquivo origem

// CRIA COPIA PARA MANIPULAÇÃO MAS NAO FUNCIONOU , AREA DE TRABALHO EM USO
carqdest := substr(MV_PAR01,1,(len(TRIM(MV_PAR01))-4))+"processado.txt"


cArqTxt  := TRIM(MV_PAR01)  
nHdl     := FT_FUse(cArqTxt)
If nHdl  < 0
	MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser aberto! Verifique os parametros.","Atenção!")
	Return
Endif   
FT_FGoTop() 
 ProcRegua(FT_FLASTREC())

While !FT_FEOF()
	AADD(aLinhas,FT_FREADLN())
 		IncProc("Lendo Nota. Nota : "+Substr(FT_FREADLN(),71,9)+" Serie : "+Substr(FT_FREADLN(),80,2) +" Aguarde...")
	FT_FSKIP() 
	
Enddo

FT_FUSE()
FClose(nHdl)
ProcRegua(Len(aLinhas))
carqdest := substr(MV_PAR01,1,(len(TRIM(MV_PAR01))-4))+"processado.txt"

nHd2 :=FCREATE(carqdest, 0) 
If nHd2 == -1
	MsgAlert("O arquivo de nome "+carqdest+" não pode ser Criado! Verifique se ja foi criado ou esta Aberto.","Atenção!")
	Return
Endif 
           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Processa({|| RunCont() },"Processando...")

Return() 
