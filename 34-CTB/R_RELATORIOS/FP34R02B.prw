#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"
#include "TbiCode.ch" 
#INCLUDE "PROTHEUS.CH"
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: FP34R02B		|	Autor: Luis Paulo							|	Data: 12/04/2018	//
//==================================================================================================//
//	Descrição: Impressao do Relatório Sintético de contas Excel										//
//																									//
//==================================================================================================//
User Function FP34R02B(dDtaIni,dDtaFim,_cTFu02)
Local 	oExcel
//Local 	cDir    	:= "C:\TEMP\"
Local 	cArq    	:= "Rel Sint Plan Ctas "+_cTFu02+" FP34R02B "+Alltrim(cUserName)+".xml"
Local 	nLinha		:= 1
Local 	_cCad		:= "Gerar XML"
Local 	_cDirTmp 	:= "C:\TEMP\"
Local 	_cDir 		:= GetSrvProfString("Startpath","")
Local 	cSldAnt		:= ""
Local 	cSldDeb		:= ""
Local 	cSldCre		:= ""
Local 	cSldAtu		:= ""
Local 	nSoma1		:= 0
Local 	nSoma2		:= 0
Local 	nSoma3		:= 0
Local 	nSoma4		:= 0
Local cContaNew		:= ""
Local cContaAtu		:= ""
Local cTpCta		:= ""
Local cTpNew		:= ""
Local cDescri		:= ""
Private _cPerg		:="GERAXML1"
Private cAlias		:= GetNextAlias()

If Buscar()
	MsgAlert("Não existem dados!!!, favor verificar os parâmetros!!")
	Return .T.
EndIf

_cDirTmp := ALLTRIM(cGetFile("Salvar em?|*|",'Salvar em?', 0,'c:\funpar\', .T., GETF_OVERWRITEPROMPT + GETF_LOCALHARD + GETF_RETDIRECTORY,.T.))


oExcel := FWMsExcel():New()		//Instancia a classe
	
oExcel:AddworkSheet("REL SINT CTAS")				//Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable ("REL SINT CTAS","SALDOS")		//Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("REL SINT CTAS","SALDOS","CONTA"			,1,1)
oExcel:AddColumn("REL SINT CTAS","SALDOS","FILIAL"			,2,1)
oExcel:AddColumn("REL SINT CTAS","SALDOS","DESCRICAO"  		,1,1) //( 1-Left,2-Center,3-Right )
oExcel:AddColumn("REL SINT CTAS","SALDOS","SLD ANT"			,3,3)
oExcel:AddColumn("REL SINT CTAS","SALDOS","DEBITO"			,3,3)//Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
oExcel:AddColumn("REL SINT CTAS","SALDOS","CREDITO"			,3,3)
oExcel:AddColumn("REL SINT CTAS","SALDOS","SLD ATUAL"		,3,3)

oExcel:SetFont('Arial')
oExcel:SetFontSize(10)
oExcel:SetTitleBold(.T.)
//oExcel:SetTitleSizeFont(16)
oExcel:SetHeaderBold(.T.)
//oExcel:SetHeaderSizeFont(14)
oExcel:SetBold(.T.)

ProcRegua(0)

cContaNew	:= Alltrim((cAlias)->ZTB_CTACT1)
cContaAtu	:= Alltrim((cAlias)->ZTB_CTACT1)
cTpCta		:= Alltrim((cAlias)->ZTB_TPCTA)
cTpNew		:= Alltrim((cAlias)->ZTB_TPCTA)
While !(cAlias)->(EOF())

	If _cPerg9 == 2 //Trata Subtotais
			cContaNew	:= Alltrim((cAlias)->ZTB_CTACT1)
			cTpNew		:= Alltrim((cAlias)->ZTB_TPCTA)
			
			If cContaNew == cContaAtu
					If Alltrim((cAlias)->ZTB_TPCTA) == '1' //Cta sintetica
							oExcel:SetLineBold(.T.)
							oExcel:Set2LineBold(.T.)
						Else
							oExcel:SetLineBold(.F.)
							oExcel:Set2LineBold(.F.)
					EndIf
					If Alltrim((cAlias)->ZTB_TPCTA) == '2' //Cta Analitica
						nSoma1		+= (cAlias)->ZTB_SLDANT
						nSoma2		+= (cAlias)->ZTB_DEBITO
						nSoma3		+= (cAlias)->ZTB_CREDIT
						nSoma4		+= (cAlias)->ZTB_SLDATU 	
						cDescri		:= Alltrim((cAlias)->ZTB_DESCTA)
					EndIf
					
					cSldAnt		:= Alltrim(Transform(((cAlias)->ZTB_SLDANT),'@E 999,999,999,999.99'))
					cSldAtu		:= Alltrim(Transform(((cAlias)->ZTB_SLDATU),'@E 999,999,999,999.99'))
					cSldDeb		:= Alltrim(Transform((cAlias)->ZTB_DEBITO,'@E 999,999,999,999.99'))
					cSldCre		:= Alltrim(Transform((cAlias)->ZTB_CREDIT,'@E 999,999,999,999.99'))
					oExcel:AddRow("REL SINT CTAS","SALDOS"	,{MascaraCTB((cAlias)->ZTB_CTACT1),Alltrim((cAlias)->ZTB_FILCQ0),Alltrim((cAlias)->ZTB_DESCTA),cSldAnt,cSldDeb,cSldCre,cSldAtu})
					IncProc()
					nLinha++
				
				Else
					
					nSoma1		:= Alltrim(Transform((nSoma1),'@E 999,999,999,999.99'))
					nSoma2		:= Alltrim(Transform((nSoma2),'@E 999,999,999,999.99'))
					nSoma3		:= Alltrim(Transform((nSoma3),'@E 999,999,999,999.99'))
					nSoma4		:= Alltrim(Transform((nSoma4),'@E 999,999,999,999.99'))
					
					If cTpCta == "2" //Analitica
						oExcel:AddRow("REL SINT CTAS","SALDOS"	,{MascaraCTB(cContaAtu),"","", nSoma1 ,nSoma2,nSoma3,nSoma4})
					EndIf
					nSoma1		:= 0
					nSoma2		:= 0
					nSoma3		:= 0
					nSoma4		:= 0
					cContaAtu	:= Alltrim((cAlias)->ZTB_CTACT1)
					cTpCta		:= Alltrim((cAlias)->ZTB_TPCTA)
					Loop
			EndIf
		
		Else
			If Alltrim((cAlias)->ZTB_TPCTA) == '1' //Cta sintetica
					oExcel:SetLineBold(.T.)
					oExcel:Set2LineBold(.T.)
				Else
					oExcel:SetLineBold(.F.)
					oExcel:Set2LineBold(.F.)
			EndIf
			cSldAnt		:= Alltrim(Transform(((cAlias)->ZTB_SLDANT),'@E 999,999,999,999.99'))
			cSldAtu		:= Alltrim(Transform(((cAlias)->ZTB_SLDATU),'@E 999,999,999,999.99'))
			/*
			If ((cAlias)->ZTB_CTACD == '1' .And. (cAlias)->ZTB_SLDANT < 0 .OR. (cAlias)->ZTB_SLDANT = 0) .OR. ((cAlias)->ZTB_CTACD == '2' .And. (cAlias)->ZTB_SLDANT > 0 .OR. (cAlias)->ZTB_SLDANT = 0)
					cSldAnt		:= Alltrim(Transform(ABS((cAlias)->ZTB_SLDANT),'@E 999,999,999,999.99'))
				Else
					cSldAnt		:= "("+ Alltrim(Transform(ABS((cAlias)->ZTB_SLDANT),'@E 999,999,999,999.99')) +")"
			EndIf
			If ((cAlias)->ZTB_CTACD == '1' .And. (cAlias)->ZTB_SLDATU < 0 .OR. (cAlias)->ZTB_SLDATU = 0 ) .OR. ((cAlias)->ZTB_CTACD == '2' .And. (cAlias)->ZTB_SLDATU > 0 .OR. (cAlias)->ZTB_SLDATU = 0)
					cSldAtu		:= Alltrim(Transform(ABS((cAlias)->ZTB_SLDATU),'@E 999,999,999,999.99'))
				Else
					cSldAtu		:= "("+Alltrim(Transform(ABS((cAlias)->ZTB_SLDATU),'@E 999,999,999,999.99'))+")"
			EndIf
			*/
			cSldDeb		:= Alltrim(Transform((cAlias)->ZTB_DEBITO,'@E 999,999,999,999.99'))
			cSldCre		:= Alltrim(Transform((cAlias)->ZTB_CREDIT,'@E 999,999,999,999.99'))
			oExcel:AddRow("REL SINT CTAS","SALDOS"	,{MascaraCTB((cAlias)->ZTB_CTACT1),Alltrim((cAlias)->ZTB_FILCQ0),Alltrim((cAlias)->ZTB_DESCTA),cSldAnt,cSldDeb,cSldCre,cSldAtu})
			IncProc()
			nLinha++
	EndIf
	
	(cAlias)->(DbSkip())

EndDo

If cTpCta == "2" .And. _cPerg9 == 2 //Analitica e subtotais
	nSoma1		:= Alltrim(Transform((nSoma1),'@E 999,999,999,999.99'))
	nSoma2		:= Alltrim(Transform((nSoma2),'@E 999,999,999,999.99'))
	nSoma3		:= Alltrim(Transform((nSoma3),'@E 999,999,999,999.99'))
	nSoma4		:= Alltrim(Transform((nSoma4),'@E 999,999,999,999.99'))
	oExcel:AddRow("REL SINT CTAS","SALDOS"	,{MascaraCTB(cContaAtu),"",cDescri,nSoma1,nSoma2,nSoma3,nSoma4})
EndIf

oExcel:Activate() 				//Habilita o uso da classe, indicando que esta configurada e pronto para uso
	
LjMsgRun( "Gerando o arquivo, aguarde...", _cCad, {|| oExcel:GetXMLFile( cArq ) } )//Cria um arquivo no formato XML do MSExcel 2003 em diante 

oExcel:DEActivate()

//oExcel:GetXMLFile("TESTE.xml")	//Arquivo teste.xml gerado com sucesso no \system\

If __CopyFile( cArq, _cDirTmp + cArq )

	//---------------------------------
	//Exclui a tabela 
	//---------------------------------
	FERASE(_cDir + cArq)

	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( _cDirTmp + cArq )
	oExcelApp:SetVisible(.T.)
Else
	MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretório " + _cDir )
	MsgInfo( "Arquivo não copiado para temporário do usuário." )
Endif
	
Return()

Static Function Buscar()
Local cSql 	:= " "

/* Cria Query */
If Select((cAlias)) <> 0
	DBSelectArea((cAlias))
	(cAlias)->(DBCloseArea())
Endif

cSql :=" SELECT * "+cCRLF
cSql +=" FROM ZTB010 WITH(NOLOCK) "+cCRLF
cSql +=" WHERE D_E_L_E_T_ = '' "+cCRLF
cSql +=" AND ZTB_CODIGO = '"+cCodigo+"' "+cCRLF
cSql +=" ORDER BY ZTB_CTACT1 "+cCRLF

CONOUT(cSql)

TCQuery cSql NEW ALIAS (cAlias)		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.
DBSelectArea((cAlias))
(cAlias)->(DBGoTop())

Return (cAlias)->(EOF())
