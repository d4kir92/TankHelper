
local AddOnName, TankHelper = ...

local BuildNr = select(4, GetBuildInfo())
local Build = "CLASSIC"
if BuildNr >= 100000 then
	Build = "RETAIL"
elseif BuildNr > 29999 then
	Build = "WRATH"
elseif BuildNr > 19999 then
	Build = "TBC"
end

function TankHelper:GetWoWBuildNr()
	return BuildNr
end

function TankHelper:GetWoWBuild()
	return Build
end

local function InitSettings()
	local colred = {0, 1, 0, 1}
	TH_Settings = {}
	local settingname = "TankHelper |T132362:16:16:0:0|t by |cff3FC7EBD4KiR |T132115:16:16:0:0|t"
	TH_Settings.panel = CreateFrame("Frame", settingname, UIParent)
	TH_Settings.panel.name = settingname

	local Y = -14
	local H = 16
	local BR = 30

	local settings_header = {}
	settings_header.frame = TH_Settings.panel
	settings_header.parent = TH_Settings.panel
	settings_header.x = 10
	settings_header.y = Y
	settings_header.text = settingname
	settings_header.textsize = 24
	TankHelper:CreateText(settings_header)
	Y = Y - BR

	if UnitGroupRolesAssigned then
		local settings_onlytank = {}
		settings_onlytank.name = "onlytank"
		settings_onlytank.parent = TH_Settings.panel
		settings_onlytank.checked = TankHelper:GetConfig("onlytank", false)
		settings_onlytank.text = "onlytank"
		settings_onlytank.x = 10
		settings_onlytank.y = Y
		settings_onlytank.dbvalue = "onlytank"
		settings_onlytank.color = colred
		TankHelper:CreateCheckBox(settings_onlytank)
		Y = Y - 24
	end

	local settings_showalways = {}
	settings_showalways.name = "showalways"
	settings_showalways.parent = TH_Settings.panel
	settings_showalways.checked = TankHelper:GetConfig( "showalways", false )
	settings_showalways.text = "showalways"
	settings_showalways.x = 10
	settings_showalways.y = Y
	settings_showalways.dbvalue = "showalways"
	settings_showalways.color = colred
	TankHelper:CreateCheckBox(settings_showalways)
	Y = Y - 24

	Y = Y - 10
	local settings_channel = {}
	settings_channel.name = "PULLTIMERMODE"
	settings_channel.parent = TH_Settings.panel
	settings_channel.text = "PULLTIMERMODE"
	settings_channel.value = TankHelper:GetConfig( "PULLTIMERMODE", "AUTO" )
	settings_channel.x = 0
	settings_channel.y = Y
	settings_channel.dbvalue = "PULLTIMERMODE"
	settings_channel.tab = {
		{ Name = "AUTO", Code = "AUTO" },
		{ Name = "ONLYTHIRDPARTY", Code = "ONLYTHIRDPARTY" },
		{ Name = "ONLYTH", Code = "ONLYTH" },
		{ Name = "BOTH", Code = "BOTH" },
	}
	TankHelper:CreateComboBox(settings_channel)
	Y = Y - 40

	local settings_showtranslation = {}
	settings_showtranslation.name = "showtranslation"
	settings_showtranslation.parent = TH_Settings.panel
	settings_showtranslation.checked = TankHelper:GetConfig("showtranslation", true)
	settings_showtranslation.text = "showtranslation"
	settings_showtranslation.x = 10
	settings_showtranslation.y = Y
	settings_showtranslation.dbvalue = "showtranslation"
	settings_showtranslation.color = colred
	TankHelper:CreateCheckBox(settings_showtranslation)
	Y = Y - 24

	local settings_fixposition = {}
	settings_fixposition.name = "fixposition"
	settings_fixposition.parent = TH_Settings.panel
	settings_fixposition.checked = TankHelper:GetConfig("fixposition", false)
	settings_fixposition.text = "fixposition"
	settings_fixposition.x = 10
	settings_fixposition.y = Y
	settings_fixposition.dbvalue = "fixposition"
	settings_fixposition.color = colred
	TankHelper:CreateCheckBox(settings_fixposition)
	Y = Y - 24

	local settings_hidestatus = {}
	settings_hidestatus.name = "hidestatus"
	settings_hidestatus.parent = TH_Settings.panel
	settings_hidestatus.checked = TankHelper:GetConfig("hidestatus", false)
	settings_hidestatus.text = "hidestatus"
	settings_hidestatus.x = 10
	settings_hidestatus.y = Y
	settings_hidestatus.dbvalue = "hidestatus"
	settings_hidestatus.color = colred
	TankHelper:CreateCheckBox(settings_hidestatus)
	Y = Y - 24

	local settings_hidelastrow = {}
	settings_hidelastrow.name = "hidelastrow"
	settings_hidelastrow.parent = TH_Settings.panel
	settings_hidelastrow.checked = TankHelper:GetConfig("hidelastrow", false)
	settings_hidelastrow.text = "hidelastrow"
	settings_hidelastrow.x = 10
	settings_hidelastrow.y = Y
	settings_hidelastrow.dbvalue = "hidelastrow"
	settings_hidelastrow.color = colred
	settings_hidelastrow.func = TankHelper.UpdateDesign
	TankHelper:CreateCheckBox(settings_hidelastrow)
	Y = Y - 24

	local settings_nameplatethreat = {}
	settings_nameplatethreat.name = "nameplatethreat"
	settings_nameplatethreat.parent = TH_Settings.panel
	settings_nameplatethreat.checked = TankHelper:GetConfig( "nameplatethreat", true )
	settings_nameplatethreat.text = "nameplatethreat"
	settings_nameplatethreat.x = 10
	settings_nameplatethreat.y = Y
	settings_nameplatethreat.dbvalue = "nameplatethreat"
	settings_nameplatethreat.color = colred
	settings_nameplatethreat.func = function() TankHelper:ThinkNameplates( true ) end
	TankHelper:CreateCheckBox(settings_nameplatethreat)
	Y = Y - 24



	Y = Y - BR
	local settings_targettingdelay = {}
	settings_targettingdelay.name = "targettingdelay"
	settings_targettingdelay.parent = TH_Settings.panel
	settings_targettingdelay.value = TankHelper:GetConfig( "targettingdelay", 0.8 )
	settings_targettingdelay.text = "targettingdelay"
	settings_targettingdelay.x = 10
	settings_targettingdelay.y = Y
	settings_targettingdelay.min = 0.0
	settings_targettingdelay.max = 5.0
	settings_targettingdelay.steps = 0.1
	settings_targettingdelay.decimals = 1
	settings_targettingdelay.dbvalue = "targettingdelay"
	settings_targettingdelay.color = {0, 1, 0, 1}
	settings_targettingdelay.func = TankHelper.UpdateDesign
	TankHelper:CreateSlider(settings_targettingdelay)
	Y = Y - H - H



	Y = Y - BR
	local settings_scalecockpit = {}
	settings_scalecockpit.name = "scalecockpit"
	settings_scalecockpit.parent = TH_Settings.panel
	settings_scalecockpit.value = TankHelper:GetConfig("scalecockpit", 1)
	settings_scalecockpit.text = "scalecockpit"
	settings_scalecockpit.x = 10
	settings_scalecockpit.y = Y
	settings_scalecockpit.min = 0.1
	settings_scalecockpit.max = 2.0
	settings_scalecockpit.steps = 0.1
	settings_scalecockpit.decimals = 1
	settings_scalecockpit.dbvalue = "scalecockpit"
	settings_scalecockpit.color = {0, 1, 0, 1}
	settings_scalecockpit.func = TankHelper.UpdateDesign
	TankHelper:CreateSlider(settings_scalecockpit)
	Y = Y - H

	Y = Y - BR
	local settings_scalestatus = {}
	settings_scalestatus.name = "scalestatus"
	settings_scalestatus.parent = TH_Settings.panel
	settings_scalestatus.value = TankHelper:GetConfig("scalestatus", 1)
	settings_scalestatus.text = "scalestatus"
	settings_scalestatus.x = 10
	settings_scalestatus.y = Y
	settings_scalestatus.min = 0.1
	settings_scalestatus.max = 2.0
	settings_scalestatus.steps = 0.1
	settings_scalestatus.decimals = 1
	settings_scalestatus.dbvalue = "scalestatus"
	settings_scalestatus.color = {0, 1, 0, 1}
	settings_scalestatus.func = TankHelper.UpdateDesign
	TankHelper:CreateSlider(settings_scalestatus)
	Y = Y - H

	Y = Y - BR
	local settings_obr = {}
	settings_obr.name = "obr"
	settings_obr.parent = TH_Settings.panel
	settings_obr.value = TankHelper:GetConfig("obr", 6)
	settings_obr.text = "obr"
	settings_obr.x = 10
	settings_obr.y = Y
	settings_obr.min = 0
	settings_obr.max = 12
	settings_obr.steps = 1
	settings_obr.decimals = 0
	settings_obr.dbvalue = "obr"
	settings_obr.color = {0, 1, 0, 1}
	settings_obr.func = TankHelper.UpdateDesign
	TankHelper:CreateSlider(settings_obr)
	Y = Y - H
	
	Y = Y - BR
	local settings_ibr = {}
	settings_ibr.name = "ibr"
	settings_ibr.parent = TH_Settings.panel
	settings_ibr.value = TankHelper:GetConfig("ibr", 1)
	settings_ibr.text = "ibr"
	settings_ibr.x = 10
	settings_ibr.y = Y
	settings_ibr.min = 0
	settings_ibr.max = 12
	settings_ibr.steps = 1
	settings_ibr.decimals = 0
	settings_ibr.dbvalue = "ibr"
	settings_ibr.color = {0, 1, 0, 1}
	settings_ibr.func = TankHelper.UpdateDesign
	TankHelper:CreateSlider(settings_ibr)
	Y = Y - H

	Y = Y - BR
	local settings_cbr = {}
	settings_cbr.name = "cbr"
	settings_cbr.parent = TH_Settings.panel
	settings_cbr.value = TankHelper:GetConfig("cbr", 3)
	settings_cbr.text = "cbr"
	settings_cbr.x = 10
	settings_cbr.y = Y
	settings_cbr.min = 0
	settings_cbr.max = 12
	settings_cbr.steps = 1
	settings_cbr.decimals = 0
	settings_cbr.dbvalue = "cbr"
	settings_cbr.color = {0, 1, 0, 1}
	settings_cbr.func = TankHelper.UpdateDesign
	TankHelper:CreateSlider(settings_cbr)
	Y = Y - H

	Y = Y - BR
	local settings_iconsize = {}
	settings_iconsize.name = "iconsize"
	settings_iconsize.parent = TH_Settings.panel
	settings_iconsize.value = TankHelper:GetConfig("iconsize", 16)
	settings_iconsize.text = "iconsize"
	settings_iconsize.x = 10
	settings_iconsize.y = Y
	settings_iconsize.min = 8
	settings_iconsize.max = 64
	settings_iconsize.steps = 2
	settings_iconsize.decimals = 0
	settings_iconsize.dbvalue = "iconsize"
	settings_iconsize.color = {0, 1, 0, 1}
	settings_iconsize.func = TankHelper.UpdateDesign
	TankHelper:CreateSlider(settings_iconsize)
	Y = Y - H

	InterfaceOptions_AddCategory(TH_Settings.panel)
end

local THloaded = false
local THSETUP = false

local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" and not THloaded then
		THloaded = true

		InitSettings()

		THSETUP = true

		TankHelper:InitSetup()
	end
end
frame:SetScript("OnEvent", frame.OnEvent)