-- By D4KiR

THBUILD = "CLASSIC"
if select(4, GetBuildInfo()) > 90000 then
	THBUILD = "RETAIL"
elseif select(4, GetBuildInfo()) > 29999 then
	THBUILD = "WRATH"
elseif select(4, GetBuildInfo()) > 19999 then
	THBUILD = "TBC"
end

local function InitSettings()
	local colred = {0, 1, 0, 1}
	TH_Settings = {}
	local settingname = THname
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
	THCreateText(settings_header)
	Y = Y - BR

	-- showtranslation
	local settings_showtranslation = {}
	settings_showtranslation.name = "showtranslation"
	settings_showtranslation.parent = TH_Settings.panel
	settings_showtranslation.checked = THGetConfig("showtranslation", true)
	settings_showtranslation.text = "showtranslation"
	settings_showtranslation.x = 10
	settings_showtranslation.y = Y
	settings_showtranslation.dbvalue = "showtranslation"
	--settings_showtranslation.func = RUI
	settings_showtranslation.color = colred
	THCreateCheckBox(settings_showtranslation)
	Y = Y - 24

	-- fixposition
	local settings_fixposition = {}
	settings_fixposition.name = "fixposition"
	settings_fixposition.parent = TH_Settings.panel
	settings_fixposition.checked = THGetConfig("fixposition", false)
	settings_fixposition.text = "fixposition"
	settings_fixposition.x = 10
	settings_fixposition.y = Y
	settings_fixposition.dbvalue = "fixposition"
	--settings_fixposition.func = RUI
	settings_fixposition.color = colred
	THCreateCheckBox(settings_fixposition)
	Y = Y - 24

	-- hidestatus
	local settings_hidestatus = {}
	settings_hidestatus.name = "hidestatus"
	settings_hidestatus.parent = TH_Settings.panel
	settings_hidestatus.checked = THGetConfig("hidestatus", false)
	settings_hidestatus.text = "hidestatus"
	settings_hidestatus.x = 10
	settings_hidestatus.y = Y
	settings_hidestatus.dbvalue = "hidestatus"
	--settings_hidestatus.func = RUI
	settings_hidestatus.color = colred
	THCreateCheckBox(settings_hidestatus)
	Y = Y - 24

	-- nameplatethreat
	local settings_nameplatethreat = {}
	settings_nameplatethreat.name = "nameplatethreat"
	settings_nameplatethreat.parent = TH_Settings.panel
	settings_nameplatethreat.checked = THGetConfig( "nameplatethreat", true )
	settings_nameplatethreat.text = "nameplatethreat"
	settings_nameplatethreat.x = 10
	settings_nameplatethreat.y = Y
	settings_nameplatethreat.dbvalue = "nameplatethreat"
	--settings_nameplatethreat.func = RUI
	settings_nameplatethreat.color = colred
	THCreateCheckBox(settings_nameplatethreat)
	Y = Y - 24

	-- obr
	Y = Y - BR
	local settings_obr = {}
	settings_obr.name = "obr"
	settings_obr.parent = TH_Settings.panel
	settings_obr.value = THGetConfig("obr", 6)
	settings_obr.text = "obr"
	settings_obr.x = 10
	settings_obr.y = Y
	settings_obr.min = 0
	settings_obr.max = 12
	settings_obr.steps = 1
	settings_obr.decimals = 0
	settings_obr.dbvalue = "obr"
	settings_obr.color = {0, 1, 0, 1}
	settings_obr.func = THUpdatePosAndSize
	THCreateSlider(settings_obr)
	Y = Y - H
	
	-- ibr
	Y = Y - BR
	local settings_ibr = {}
	settings_ibr.name = "ibr"
	settings_ibr.parent = TH_Settings.panel
	settings_ibr.value = THGetConfig("ibr", 1)
	settings_ibr.text = "ibr"
	settings_ibr.x = 10
	settings_ibr.y = Y
	settings_ibr.min = 0
	settings_ibr.max = 12
	settings_ibr.steps = 1
	settings_ibr.decimals = 0
	settings_ibr.dbvalue = "ibr"
	settings_ibr.color = {0, 1, 0, 1}
	settings_ibr.func = THUpdatePosAndSize
	THCreateSlider(settings_ibr)
	Y = Y - H

	-- cbr
	Y = Y - BR
	local settings_cbr = {}
	settings_cbr.name = "cbr"
	settings_cbr.parent = TH_Settings.panel
	settings_cbr.value = THGetConfig("cbr", 3)
	settings_cbr.text = "cbr"
	settings_cbr.x = 10
	settings_cbr.y = Y
	settings_cbr.min = 0
	settings_cbr.max = 12
	settings_cbr.steps = 1
	settings_cbr.decimals = 0
	settings_cbr.dbvalue = "cbr"
	settings_cbr.color = {0, 1, 0, 1}
	settings_cbr.func = THUpdatePosAndSize
	THCreateSlider(settings_cbr)
	Y = Y - H

	-- iconsize
	Y = Y - BR
	local settings_iconsize = {}
	settings_iconsize.name = "iconsize"
	settings_iconsize.parent = TH_Settings.panel
	settings_iconsize.value = THGetConfig("iconsize", 16)
	settings_iconsize.text = "iconsize"
	settings_iconsize.x = 10
	settings_iconsize.y = Y
	settings_iconsize.min = 8
	settings_iconsize.max = 64
	settings_iconsize.steps = 2
	settings_iconsize.decimals = 0
	settings_iconsize.dbvalue = "iconsize"
	settings_iconsize.color = {0, 1, 0, 1}
	settings_iconsize.func = THUpdatePosAndSize
	THCreateSlider(settings_iconsize)
	Y = Y - H

	InterfaceOptions_AddCategory(TH_Settings.panel)
end

THloaded = false
THSETUP = false

local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" and not THloaded then
		THloaded = true

		InitSettings()

		THSETUP = true

		THSetup()
	end
end
frame:SetScript("OnEvent", frame.OnEvent)