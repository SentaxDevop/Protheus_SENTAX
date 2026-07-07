User Function ATMK010()

Local oMBrowse

oMBrowse := FWMBrowse():New()
	
nPos:=aScan(oGdList:AHEADER,{|X|ALLTRIM(X[2])=='Z19_TELE'})

oMBrowse:SetFilterDefault( "Z19_TELE=='"+oGdList:ACOLS[oGdList:nAt][nPos]+"'" )
oMBrowse:SetMenuDef("XXXXXXXXXX")
oMBrowse:AddLegend('Z19->Z19_STATUS=="1"',"GREEN" ,"Na periodicidade"    )          
oMBrowse:AddLegend('Z19->Z19_STATUS=="2"',"BLUE" ,"Fora periodicidade"    )          
oMBrowse:AddLegend('Z19->Z19_STATUS=="3"',"GRAY" ,"Sem ped. period."    )          
oMBrowse:AddLegend('Z19->Z19_STATUS=="4"',"PINK" ,"Inativo"    )          


//oMBrowse:AddStatusColumns({|| Status() }/*bStatus*/, {|| Legend() }/*bLDblClick*/)
oMBrowse:SetAlias("Z19")
oMBrowse:SetLocate()
oMBrowse:DisableDetails()

oMBrowse:Activate()


Return