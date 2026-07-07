#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} AFAT004
Rotina para gravar o log para registros de volumes de notas
                
@sample		U_AFAT004(cConteudo)

@author		Alessandro Smaha
@since		28/09/2016
@version 	P11  
/*/
//-------------------------------------------------------------------
User Function AFAT004( cFilPos, cDocPos, cSerPos, dEmiPos, nVolAnt, nVolNov, cRotPos, dDatAtu, cHorAtu, cUsrPos, cObsPos )

Local cDirLog	:= "\log_fat\"
Local cArqLog	:= "SENTAX_FAT_VOLUME_"+StrZero(Year(dDatAtu),4)+"_"+StrZero(Month(dDatAtu),2)+".LOG"
Local nHandle	:= 0
Local cConteudo	:= ""

MontaDir(cDirLog) // Cria o diretorio se não existir
 
If File( cDirLog + cArqLog ) 
	nHandle := fOpen( cDirLog + cArqLog, FO_READWRITE+FO_SHARED ) 
Else
	nHandle := FCreate( cDirLog + cArqLog ) 
	cConteudo += "Filial|Documento|Série|Emissao|Volume Ant.|Volume Novo|Rotina|Data Atual|Hora Atual|Usuário|Observações|"+CHR(13)+CHR(10)   
EndIf

If nHandle == -1   
	Conout(cJobFid+"[AFAT004]"+"Não foi possível abrir ou criar o arquivo: " + cArqLog )			
Else  
	cConteudo += 	Alltrim(cFilPos)+"|"+;
					Alltrim(cDocPos)+"|"+;
					Alltrim(cSerPos)+"|"+;
					DtoC(dEmiPos)+"|"+;
					cValToChar(nVolAnt)+"|"+;
					cValToChar(nVolNov)+"|"+;
					Alltrim(cRotPos)+"|"+;
					DtoC(dDatAtu)+"|"+;
					Alltrim(cHorAtu)+"|"+;
					Alltrim(cUsrPos)+"|"+;
					Alltrim(cObsPos)+"|"+CHR(13)+CHR(10)
	FSeek(nHandle,0,2)
	FWrite(nHandle, cConteudo)   
	FClose(nHandle)
EndIf								
 
Return
