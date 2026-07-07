/*---------------------------------------------------------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Relatórios                                              |
+------------------+---------------------------------------------------------+
|Modulo            | Financeiro                                              |
+------------------+---------------------------------------------------------+
|Nome              | RFIN002                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Exportação do relatório sellout para arquivo texto      |
+------------------+---------------------------------------------------------+
|Autor             | Clederson Bahl e Dotti                                  |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 02/04/2012                                              |
+------------------+---------------------------------------------------------+
|   ATUALIZACOES                                                             |
+-------------------------------------------+-----------+-----------+--------+
|   Descricao detalhada da atualizacao      |Nome do    | Analista  |Data da |
|                                           |Solicitante| Respons.  |Atualiz.|
+-------------------------------------------+-----------+-----------+--------+
| Alteração na rotina, repassando os para-  | Amaral    | Lucas     | 05/10/ |
| metros de data e as unidades corretas.    |           | Chagas    | 2012   |
+-------------------------------------------+-----------+-----------+-------*/

#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include "FILEIO.CH"


User Function RFIN002()	
	Local 	_aItens := {"Sentax/Gibraltar",;	// Códigos 010101,020201,020202,020203,020204
						"Arvoredo"}				// Códigos 030301        
	Local nOpca	:= 0
	Private _cTit 	:= "Seleção de parâmetros"
	Private _dDtDe  := CtoD("//")
	Private _dDtAte := CtoD("//")
	Private _cDirDes:= Space(60)
	Private _cEmp   := 0
	Private oDlg


	DEFINE MSDIALOG oDlg Title _cTit FROM 003,001 TO 250, 350 PIXEL 
	
		@ 005,005 Say "Empresa:"
		@ 005,035 ComboBox _cEmp Items _aItens Size 60,30
		@ 020,005 Say "De:"
		@ 020,035 Get _dDtDe Size 40,20 
		@ 035,005 Say "Até:"
		@ 035,035 Get _dDtAte Size 40,20 
		@ 050,005 Say "Destino:"
		@ 050,035 Get _cDirDes Size 80,20 Picture "@!" F3 "DIR"
		
		@ 080,100 Button "_OK" 		Size 30,10 Action (nOpca:=1,oDlg:End())
		@ 080,135 Button "_Sair" 	Size 30,10 Action oDlg:End()
		
	ACTIVATE MSDIALOG oDlg Centered   
	
	If nOpca == 1
	
		RFIN002PROC()
	
	Else
	
		MsgAlert("Operação não realizada!","Atenção")     
	
	EndIf
	
Return


Static Function RFIN002PROC()
	// Parâmetro que determina o fornecedor e loja a ser considerado
	Local cCod		:= GetNewPar("ES_FORNEC", "000001/23")
	Local cCodFor	:= SubStr(cCod, 1, AT("/", cCod) - 1)
	Local cCodLoj	:= SubStr(cCod, AT("/", cCod) + 1, Len(cCod))
	Local aStru		:= {}
	Local cQuery	:= ""
	Local cUnid		:= ""
	
	Private cLinha	:= ""
	Private cSepara := "|"
	Private nArq    := 0
	Private nCont	:= 0
	Private cDtEnv	:= CToD("//")
	Private cDtEmiss:= CToD("//")
	Private cDtFec	:= CToD("//")
	
	/*
	aStru 	:= { 	{ "TIPO", "C", 001, 00 }, ;
					{ "Texto91", "C", 008, 00 }, ;
					{ "SHIPTO"   , "C", 001, 00 }, ;
					{ "CD_CLIENTE", "C", 015, 00 }, ;	//C_CLIENT_S_CLIENTE
					{ "RAZAOSOCIA", "C", 080, 00 }, ;	//C_CLIENT_S_RAZAOSOCIAL
					{ "CNPJ", "C", 020, 00 }, ;
					{ "CPF"  , "C", 020, 00 }, ;
					{ "ENDERECO", "C", 080, 00 }, ;
					{ "CL_CEP", "C", 009, 00 }, ;		//C_CLIENT_S_EC_CEP
					{ "CL_UF", "C", 002, 00 }, ;		//C_CLIENT_S_EC_UF
					{ "CL_BAIRRO" , "C", 040, 00 }, ;	//C_CLIENT_S_EC_BAIRRO
					{ "CL_CIDADE" , "C", 040, 00 }, ;	//C_CLIENT_S_EC_CIDADE
					{ "CL_TELEFON", "C", 030, 00 }, ;	//C_CLIENT_S_EC_TELEFONE
					{ "PAIS" , "C", 002, 00 }, ;		//BR
					{ "CL_CONTATO" , "C", 070, 00 }, ;	//C_CLIENT_S_EC_CONTATO
					{ "TIPODENEG" , "C", 003, 00 }, ;	//114//TIPODENEGOCIO
					{ "ZONA" , "C", 070, 00 }, ;		//BANCO
					{ "PD_VENDEDO" , "C", 010, 00 }, ;	//M_PEDIDO_C_VENDED_S_VENDEDOR1
					{ "PD_NMVEN" , "C", 080, 00 }, ;	//C_VENDED_S_NOME
					{ "M_PRODUTO" , "C", 001, 00 }, ;	//B RANCO M_PEDIDO_C_PRODUT_S_PRODUTO
					{ "EAN" , "C", 001, 00 }, ;			//BRANCO
					{ "PROD_CODFO" , "C", 008, 00 }, ;	//C_PRODUT_S_CODFOR
					{ "QUANTIDADE" , "C", 014, 00 }, ;	//M_NFSAID_F_QUANTIDADE
					{ "VALORTOTAL" , "C", 015, 00 }, ;	//M_NFSAID_F_VALORTOTAL
					{ "VLRUNIT" , "C", 014, 00 }, ;		//M_NFSAID_F_VALORUNITARIO
					{ "EXPR1" , "C", 003, 00 }, ;		//BRL
					{ "EXPR2" , "C", 010, 00 }, ;		//Data de Faturamento aaaa/mm/dd				
					{ "AB" , "C", 003, 00 }, ;			//BRANCO
					{ "TIPOFATURA" , "C", 003, 00 }, ;	//F-FATURA;	C- NF DEVOLUCAO
					{ "NFSAID" , "C", 035, 00 }, ;		//NUMERO DA NF EMITIDA M_NFSAID_S_DOCUMENTO
					{ "AK" , "C", 002, 00 }, ;			//CS CAIXA OU PK PACOTE
					{ "AF" , "C", 002, 00 }, ;			//BRANCO
					{ "AG" , "C", 002, 00 }, ;			//BRANCO
					{ "Texto100" , "C", 001, 00 }, ;	//COPIA DA COLUNA AE CS CAIXA OU PK PACOTE
					{ "AJ" , "C", 002, 00 }, ;			//BRANCO
					{ "Texto105" , "C", 002, 00 }, ;	//BRANCO
					{ "EXPR7" , "C", 010, 00 }, ;		//DT FECHAMENTO aaaa/mm/dd
					{ "Texto102", "C", 010, 00 }}		//Corresponde à data em que o arquivo está sendo enviado à K-C.SEMPRE DEVE ESTAR NO PADRÃO = aaaa/mm/dd
	*/	
	
	If File(_cDirDes)
		MsgAlert("Arquivo já existe." + CHR(13) + CHR(10) + "Processo abortado.")
		Return
	EndIf
	
	nArq := FCreate(_cDirDes)	
	If nArq == - 1
		MsgAlert("Não foi possível abrir arquivo para escrita." + CHR(13) + CHR(10) + "Processo abortado.")
		Return
	EndIf	

	cQuery := "SELECT * FROM "+RetSQLName("SA1")+" SA1, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SB1")+" SB1  WHERE "
	cQuery += "     B1_COD = D2_COD "
	// cQuery += " AND B1_FILIAL = D2_FILIAL " // Alteração para considerar o cadastro de produto compartilhado
	// Campo criado para selecionar os produtos para sellout
	cQuery += "AND NOT (B1_SELLOUT = 'N') "
	//cQuery += "AND  NOT B1_COD  IN ('30180235','30175768','30152702','30180225') "
	// Considerando fornecedor e loja do produto (códigos buscados em parâmetro)
	cQuery += "AND B1_PROC = '" + cCodFor + "' "
	cQuery += "AND B1_LOJPROC = '" + cCodLoj + "' "
	
	// Empresa escolhida => Sentax/Gibraltar
	If "Sentax" $ _cEmp
		cQuery += "AND D2_FILIAL IN ('010101','020201','020202','020203','020204') "  //SENTAX/GIBRALTAR
	// Empresa escolhida => Arvoredo
	Else
		cQuery += "AND D2_FILIAL IN ('030301') " //030301 ARVOREDO
	EndIf
	
	cQuery += "AND D2_CLIENTE = A1_COD "
	cQuery += "AND D2_LOJA    = A1_LOJA   "
	cQuery += "AND (D2_EMISSAO >= " + dToS(_dDtDe) + " AND D2_EMISSAO <= " + dToS(_dDtAte) + ") "
	cQuery += "AND SA1.D_E_L_E_T_  <> '*' "
	cQuery += "AND SD2.D_E_L_E_T_  <> '*' "
	cQuery += "AND SB1.D_E_L_E_T_  <> '*' " 
	cQuery += " ORDER BY D2_EMISSAO " 

	If Select("TRB1") <> 0 
	   DBselectArea("TRB1")
	   DBCloseArea()
	EndIf
	
	TCQuery cQuery New Alias "TRB1"
	
	cDtEmiss:= ""  
	// Data de envio (data atual no formato aaaa/mm/dd)
	cDtEnv := Subs(DToS(dDataBase),1,4)+"/"+Subs(DToS(dDataBase),5,2)+"/"+Subs(DToS(dDataBase),7,2)
	// Data do fechamento (data fim do período apontado no formato aaaa/mm/dd)
	cDtFec := Subs(DToS(_dDtAte  ),1,4)+"/"+Subs(DToS(_dDtAte  ),5,2)+"/"+Subs(DToS(_dDtAte  ),7,2)
	
	dbEval({|| nCont++})

	RptStatus({|lEnd| RFIN002PR() }, "Aguarde...", "Processando...")
	

Return

Static Function RFIN002PR() 

    // Parâmetro que determina o fornecedor e loja a ser considerado
	Local cCod		:= GetNewPar("ES_FORNEC", "000001/23")
	Local cCodFor	:= SubStr(cCod, 1, AT("/", cCod) - 1)
	Local cCodLoj	:= SubStr(cCod, AT("/", cCod) + 1, Len(cCod))                            
	Local cDataMax  := ""
	Local dDataMax  := CtoD("//")  
	Local cCliPar   := GetMV("ST_CLIENKC",,"") 
	Local cDdd 		:= ""
	Local cTel 		:= ""
	Local cAtiv		:= ""
	Local cCodProd	:= ""
	
	DbSelectArea("SA5")
	SA5->(DbSetOrder(1)) // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
	
	SetRegua(nCont)
	TRB1->(dbGoTop())
	Do While !TRB1->(Eof())
		IncRegua() 
		
		If dDataMax < StoD(TRB1->D2_EMISSAO)
			dDataMax := StoD(TRB1->D2_EMISSAO)
		EndIf
		 
		TRB1->(DbSkip())
	EndDo  
			
	cDataMax := Subs(DToS(dDataMax),1,4)+"/"+Subs(DToS(dDataMax),5,2)+"/"+Subs(DToS(dDataMax),7,2)

	SetRegua(nCont)
	TRB1->(dbGoTop())
	Do While !TRB1->(Eof())
		IncRegua()
		
		If cDtEmiss <> TRB1->D2_EMISSAO
			cLinha := ""
		    //RecLock("TRBKB",.T.)
			//TRBKB->TIPO := "H"
			cLinha += "H" + cSepara
			If Alltrim(TRB1->D2_FILIAL ) $ "010101,020201,020202,020203,020204"
				//TRBKB->Texto91 := "40136773"  //40076697 (arvoredo) 40136773(parana)
				cLinha += "40136773" + cSepara //40076697 (arvoredo) 40136773(parana)
			Else
				//TRBKB->Texto91 := "40076697"  //40076697 (arvoredo) 40136773(parana)
				cLinha += "40076697" + cSepara //40076697 (arvoredo) 40136773(parana)
			EndIf
			//SHIPTO
			cLinha += "" + cSepara
			//CD_CLIENTE
			cLinha += "" + cSepara
			//RAZAOSOCIA
			cLinha += "" + cSepara
			//CNPJ
			cLinha += "" + cSepara
			//CPF
			cLinha += "" + cSepara
			//ENDERECO
			cLinha += "" + cSepara
			//CL_CEP
			cLinha += "" + cSepara
			//CL_UF
			cLinha += "" + cSepara
			//CL_BAIRRO
			cLinha += "" + cSepara
			//CL_CIDADE
			cLinha += "" + cSepara
			//CL_TELEFON
			cLinha += "" + cSepara
			//TRBKB->PAIS := "BR"
			cLinha += "BR" + cSepara
			//CL_CONTATO
			cLinha += "" + cSepara
			//TIPODENEG
			cLinha += "" + cSepara
			//ZONA
			cLinha += "" + cSepara
			//PD_VENDEDO
			cLinha += "" + cSepara
			//PD_NMVEN
			cLinha += "" + cSepara
			//M_PRODUTO
			cLinha += "" + cSepara
			//EAN
			cLinha += "" + cSepara
			//PROD_CODFO
			cLinha += "" + cSepara
			//QUANTIDADE
			cLinha += "" + cSepara
			//VALORTOTAL
			cLinha += "" + cSepara
			//VLRUNIT
			cLinha += "" + cSepara
			//EXPR1
			cLinha += "" + cSepara			
			//TRBKB->EXPR2 := Subs(TRB1->D2_EMISSAO,1,4)+"/"+Subs(TRB1->D2_EMISSAO,5,2)+"/"+Subs(TRB1->D2_EMISSAO,7,2)//Data de Faturamento aaaa/mm/dd
			cLinha += Subs(TRB1->D2_EMISSAO,1,4)+"/"+Subs(TRB1->D2_EMISSAO,5,2)+"/"+Subs(TRB1->D2_EMISSAO,7,2) + cSepara //Data de Faturamento aaaa/mm/dd
			//AB
			cLinha += "" + cSepara
			//TIPOFATURA
			cLinha += "" + cSepara
			//NFSAID
			cLinha += "" + cSepara
			//AK
			cLinha += "" + cSepara
			//AF
			cLinha += "" + cSepara
			//AG
			cLinha += "" + cSepara
			//Texto100
			cLinha += "" + cSepara
			//AJ
			cLinha += "" + cSepara
			//Texto105
			cLinha += "" + cSepara
			//TRBKB->EXPR7 := cDtFec//DT FECHAMENTO aaaa/mm/dd
			cLinha += cDtFec + cSepara //DT FECHAMENTO aaaa/mm/dd
			//TRBKB->Texto102 := cDtEnv//Corresponde à data em que o arquivo está sendo enviado à K-C.SEMPRE DEVE ESTAR NO PADRÃO = aaaa/mm/dd
			cLinha += cDtEnv + cSepara //Corresponde à data em que o arquivo está sendo enviado à K-C.SEMPRE DEVE ESTAR NO PADRÃO = aaaa/mm/dd
			//MSUnLock()
			cLinha += CHR(13) + CHR(10)
			FWrite(nArq, cLinha, Len(cLinha))
			cLinha := ""
		EndIf
		
		cLinha := ""
		//RecLock("TRBKB",.T.)
		//TRBKB->TIPO := "D"
		//Tipo
		cLinha += "D" + cSepara // Coluna A
		//Texto91
		If Alltrim(TRB1->D2_FILIAL) $ "010101,020201,020202,020203,020204" // Coluna B
			//TRBKB->Texto91 := "40136773"  //40076697 (arvoredo) 40136773(parana)
			cLinha += "40136773" + cSepara //40076697 (arvoredo) 40136773(parana)
		Else
			//TRBKB->Texto91 := "40076697"  //40076697 (arvoredo) 40136773(parana)	
			cLinha += "40076697" + cSepara
		EndIf			

		//TRBKB->SHIPTO"   , "N", 001, 00 }, ;
		cLinha += "" + cSepara // Coluna C
		//TRBKB->CD_CLIENTE := TRB1->A1_COD
		cLinha += AllTrim(TRB1->A1_COD) + cSepara // Coluna D
		//TRBKB->RAZAOSOCIA := TRB1->A1_NOME
		cLinha += AllTrim(TRB1->A1_NOME) + cSepara // Coluna E
		
		
		If LEN(Alltrim(TRB1->A1_CGC)) > 11 // Coluna F e G
			//TRBKB->CNPJ := TRB1->A1_CGC
			cLinha += AllTrim(TRB1->A1_CGC) + cSepara
			cLinha += "" + cSepara
		Else
			//TRBKB->CPF  := TRB1->A1_CGC
			cLinha += "" + cSepara
			cLinha += AllTrim(TRB1->A1_CGC) + cSepara
		EndIf
		
		//TRBKB->ENDERECO := TRB1->A1_END
		cLinha += AllTrim(TRB1->A1_END) + cSepara // Coluna H
		
		// Zera o CEP se não houver
		If Empty(TRB1->A1_CEP) // Coluna I
		//	TRBKB->CL_CEP := "00000-000"
			cLinha += "00000-000" + cSepara
		Else
		//	TRBKB->CL_CEP := Subs(TRB1->A1_CEP,1,5)+"-"+Subs(TRB1->A1_CEP,6,3)
			cLinha += Subs(TRB1->A1_CEP,1,5)+"-"+Subs(TRB1->A1_CEP,6,3) + cSepara
		EndIf
		
		//TRBKB->CL_UF  := TRB1->A1_EST
		cLinha += AllTrim(TRB1->A1_EST) + cSepara // Coluna J
		//TRBKB->CL_BAIRRO := TRB1->A1_BAIRRO
		cLinha += AllTrim(TRB1->A1_BAIRRO) + cSepara // Coluna K
		//TRBKB->CL_CIDADE := TRB1->A1_MUN
		cLinha += AllTrim(TRB1->A1_MUN) + cSepara // Coluna L
		//TRBKB->CL_TELEFON := TRB1->(A1_DDD+A1_TEL) 
		
		cDdd := "("+StrZero(Val(TRB1->A1_DDD),2)+")"
		cTel := Alltrim(TRB1->A1_TEL)
		cTel := StrTran(cTel,"-","") 
		cTel := StrTran(cTel," ","") 
		If Len(cTel) > 4 
	   		cTel := cDdd + " " + Substr(cTel,1,Len(cTel)-4) + "-" + Substr(cTel,Len(cTel)-3,4)
	 	Else
	 		cTel := "0"
	 	EndIf
		
		cLinha += cTel + cSepara // Coluna M
		//TRBKB->PAIS := "BR"
		cLinha += "BR" + cSepara // Coluna N
		//TRBKB->CL_CONTATO := TRB1->A1_CONTATO
        cLinha += AllTrim(TRB1->A1_CONTATO) + cSepara // Coluna O
		//TRBKB->TIPODENEG := "114"               
		
		cAtiv := Alltrim(TRB1->A1_SATIV1)
		If ! Empty(cAtiv)
		 	cAtiv := Substr(cAtiv,Len(cAtiv)-2,3)
		EndIf
		
		cLinha += cAtiv + cSepara	//cLinha += "114" + cSepara	// Coluna P
		//TRBKB->ZONA" , "C", 070, 00 }, ;//BRANCO
		cLinha += "" + cSepara // Coluna Q
		//TRBKB->PD_VENDEDO := TRB1->A1_VEND
		// Vendedor não pode conter vazio
		If Empty(TRB1->A1_VEND)  // Coluna R e S
			cLinha += "001" + cSepara
			//TRBKB->PD_NMVEN := POSICIONE("SA3",01,xFilial("SA3")+"001","A3_NOME")
			cLinha += AllTrim(POSICIONE("SA3",01,xFilial("SA3")+"001","A3_NOME")) + cSepara
		Else
			cLinha += AllTrim(TRB1->A1_VEND) + cSepara
			//TRBKB->PD_NMVEN := POSICIONE("SA3",01,xFilial("SA3")+TRB1->A1_VEND,"A3_NOME")
			cLinha += AllTrim(POSICIONE("SA3",01,xFilial("SA3")+TRB1->A1_VEND,"A3_NOME")) + cSepara
		EndIf
		
		//TRBKB->M_PEDIDO_C_PRODUT_S_PRODUTO" , "C", 001, 00 }, ;//BRANCO
		cLinha += "" + cSepara // Coluna T
		//TRBKB->EAN" , "C", 001, 00 }, ;//BRANCO
		cLinha += "" + cSepara // Coluna U
		//TRBKB->PROD_CODFO := TRB1->D2_COD          
		
		cCodProd := ""
				
		If Alltrim(TRB1->A1_COD) $ cCliPar 	 
			cCodProd := AllTrim(TRB1->B1_FABRIC)		
		EndIf   
		
		If Empty(cCodProd) 		
	  		If SA5->(DbSeek(xFilial("SA5")+cCodFor+cCodLoj+TRB1->D2_COD))		
		   		cCodProd := Alltrim(SA5->A5_CODPRF)
			Else
				cCodProd := RetNum(AllTrim(TRB1->D2_COD))
			EndIf		
		EndIf
		//lert("ccodprod: "+cCodProd+"|TRB: "+TRB1->D2_COD) 
		If Empty(cCodProd)
			cLinha += RetNum(AllTrim(TRB1->D2_COD)) + cSepara // Coluna V			
		Else
			cLinha += cCodProd + cSepara // Coluna V			
		Endif
		
		//TRBKB->QUANTIDADE := cValToChar(TRB1->D2_QUANT)
		cLinha += cValToChar(Int(TRB1->D2_QUANT)) + cSepara // Coluna W
		//TRBKB->VALORTOTAL  := cValToChar(TRB1->D2_TOTAL)
		cLinha += cValToChar(TRB1->D2_TOTAL) + cSepara // Coluna X
		//TRBKB->VLRUNIT := cValToChar(TRB1->D2_PRCVEN)
		cLinha += Alltrim(StrTran(Transform(Round(TRB1->D2_PRCVEN,2),"@E 99999999999.99"),",",".")) + cSepara // Coluna Y
		//TRBKB->EXPR1 := "BRL"
		cLinha += "BRL" + cSepara // Coluna Z   
		
		// COLUNA AA
		
		//TRBKB->EXPR2 := Subs(TRB1->D2_EMISSAO,1,4)+"/"+Subs(TRB1->D2_EMISSAO,5,2)+"/"+Subs(TRB1->D2_EMISSAO,7,2)//Data de Faturamento aaaa/mm/dd
		cLinha += Subs(TRB1->D2_EMISSAO,1,4)+"/"+Subs(TRB1->D2_EMISSAO,5,2)+"/"+Subs(TRB1->D2_EMISSAO,7,2) + cSepara // Coluna AA
		//TRBKB->AB" , "C", 003, 00 }, ;//BRANCO
		cLinha += "" + cSepara // Coluna AB
		//TRBKB->TIPOFATURA :=  "F" //F-FATURA;	C- NF DEVOLUCAO
		cLinha += "F" + cSepara //F-FATURA;	C- NF DEVOLUCAO // Coluna AC
		//TRBKB->NFSAID := TRB1->D2_DOC //NUMERO DA NF EMITIDA
		cLinha += AllTrim(TRB1->D2_DOC) + cSepara //NUMERO DA NF EMITIDA // Coluna AD
		
		if (TRB1->B1_UM == 'RF') .OR. (TRB1->B1_UM == 'GL') .OR. (TRB1->B1_UM == 'RL')
			cUnid := "PK" //PK PACOTE
		else
			cUnid := "CS" //CS CAIXA
		endif		
		//TRBKB->AE := "CS"//CS CAIXA OU PK PACOTE
		cLinha += cUnid + cSepara // Coluna AE		
		//TRBKB->AF" , "C", 002, 00 }, ;//BRANCO
		cLinha += "" + cSepara // Coluna AF
		//TRBKB->AG" , "C", 002, 00 }, ;//BRANCO
		cLinha += "" + cSepara // Coluna AG		
		//TRBKB->AH := "CS"//COPIA DA COLUNA AE CS CAIXA OU PK PACOTE
		cLinha += cUnid + cSepara // Coluna AH		
		//TRBKB->AJ" , "C", 002, 00 }, ;//BRANCO
		cLinha += "" + cSepara // Coluna AI
		//TRBKB->Texto105" , "C", 002, 00 }, ;//BRANCO
		cLinha += "" + cSepara // Coluna AJ   
		
		// Coluna AK
				
		//TRBKB->EXPR7 := cDtEnv		//DT FECHAMENTO aaaa/mm/dd
		cLinha += cDataMax + cSepara //DT FECHAMENTO aaaa/mm/dd
		
		// Coluna AL
		
		//TRBKB->Texto102 := cDtEnv	//Corresponde à data em que o arquivo está sendo enviado à K-C.SEMPRE DEVE ESTAR NO PADRÃO = aaaa/mm/dd
		cLinha += cDtEnv+ cSepara //Corresponde à data em que o arquivo está sendo enviado à K-C.SEMPRE DEVE ESTAR NO PADRÃO = aaaa/mm/dd
		//MSUnLock()
		cLinha += CHR(13) + CHR(10)
		FWrite(nArq, cLinha, Len(cLinha))
		
		cDtEmiss := TRB1->D2_EMISSAO
	
		TRB1->(DBSkip())		
	EndDo

	// Fecha o arquivo em uso
	FClose(nArq)

	If Select("TRB1") <> 0 
	   DBselectArea("TRB1")
	   DBCloseArea()
	EndIf
    
Return
