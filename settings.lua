local AddonName, TankHelper = ...
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

function TankHelper:GetColor(name)
	local r = THTAB[name .. "_r"]
	local g = THTAB[name .. "_g"]
	local b = THTAB[name .. "_b"]
	local a = THTAB[name .. "_a"]

	return r, g, b, a
end

function TankHelper:SetColor(name, r, g, b, a)
	THTAB[name .. "_r"] = r
	THTAB[name .. "_g"] = g
	THTAB[name .. "_b"] = b
	THTAB[name .. "_a"] = a
	TankHelper:UpdateColors(frameCockpit)
	TankHelper:UpdateColors(frameWorldMarkers)
	TankHelper:UpdateColors(frameTargetMarkers)
	TankHelper:UpdateColors(frameExtras)
end

function TankHelper:UpdateColors(frame)
	if TankHelper:GetColor("BGColor") == nil then
		TankHelper:SetColor("BGColor", 0, 0, 0, 0.4)
	end

	if TankHelper:GetColor("BRColor") == nil then
		TankHelper:SetColor("BRColor", 0, 0, 0, 0.2)
	end

	local r1, g1, b1, a1 = TankHelper:GetColor("BRColor")
	local r2, g2, b2, a2 = TankHelper:GetColor("BGColor")
	if frame then
		if MouseIsOver(frame) and a1 < 0.15 then
			a1 = 0.15
		end

		frame.tBRl:SetColorTexture(r1, g1, b1, a1)
		frame.tBRr:SetColorTexture(r1, g1, b1, a1)
		frame.tBRt:SetColorTexture(r1, g1, b1, a1)
		frame.tBRb:SetColorTexture(r1, g1, b1, a1)
		--frame.texture:SetColorTexture( r1, g1, b1, a1 )
		frame.tBG:SetColorTexture(r2, g2, b2, a2)
	end
end

function TankHelper:ShowColorPicker(r, g, b, a, changedCallback)
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc = changedCallback, changedCallback
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = a ~= nil, 1 - a
	ColorPickerFrame.previousValues = {r, g, b, a}
	ColorPickerFrame:SetColorRGB(r, g, b)
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = a ~= nil, 1 - a
	ColorPickerFrame:Hide() -- Need to run the OnShow handler.
	ColorPickerFrame:Show()
end

function TankHelper:AddColorPicker(name, parent, x, y)
	local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
	btn:SetSize(140, 25)
	btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	btn:SetText(TankHelper:GT(name))
	btn:SetScript(
		"OnClick",
		function()
			local r, g, b, a = TankHelper:GetColor(name)
			TankHelper:ShowColorPicker(
				r,
				g,
				b,
				a,
				function(restore)
					local newR, newG, newB, newA
					if restore then
						newR, newG, newB, newA = unpack(restore)
					else
						newA, newR, newG, newB = 1 - OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
					end

					TankHelper:SetColor(name, newR, newG, newB, newA)
				end
			)
		end
	)
end

local function InitSettings()
	local colgreen = {0, 1, 0, 1}
	TH_Settings = {}
	D4:SetVersion(AddonName, 132362, "1.7.1")
	local settingname = "TankHelper |T132362:16:16:0:0|t by |cff3FC7EBD4KiR |T132115:16:16:0:0|t"
	TH_Settings.panel = CreateFrame("Frame", settingname, UIParent)
	TH_Settings.panel.name = settingname
	local Y = -14
	local H = 14
	local BR = 24
	local settings_header = {}
	settings_header.frame = TH_Settings.panel
	settings_header.parent = TH_Settings.panel
	settings_header.x = 10
	settings_header.y = Y
	settings_header.text = settingname
	settings_header.textsize = 24
	TankHelper:CreateText(settings_header)
	Y = Y - BR
	if UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then
		local settings_onlytank = {}
		settings_onlytank.name = "onlytank"
		settings_onlytank.parent = TH_Settings.panel
		settings_onlytank.checked = TankHelper:GetConfig("onlytank", false)
		settings_onlytank.text = "onlytank"
		settings_onlytank.x = 10
		settings_onlytank.y = Y
		settings_onlytank.dbvalue = "onlytank"
		settings_onlytank.color = colgreen
		TankHelper:CreateCheckBox(settings_onlytank)
		Y = Y - 24
	end

	local settings_combineall = {}
	settings_combineall.name = "combineall"
	settings_combineall.parent = TH_Settings.panel
	settings_combineall.checked = TankHelper:GetConfig("combineall", false)
	settings_combineall.text = "combineall"
	settings_combineall.x = 10
	settings_combineall.y = Y
	settings_combineall.dbvalue = "combineall"
	settings_combineall.color = colgreen
	settings_combineall.func = TankHelper.UpdateDesign
	TankHelper:CreateCheckBox(settings_combineall)
	Y = Y - 24
	local settings_showalways = {}
	settings_showalways.name = "showalways"
	settings_showalways.parent = TH_Settings.panel
	settings_showalways.checked = TankHelper:GetConfig("showalways", false)
	settings_showalways.text = "showalways"
	settings_showalways.x = 10
	settings_showalways.y = Y
	settings_showalways.dbvalue = "showalways"
	settings_showalways.color = colgreen
	TankHelper:CreateCheckBox(settings_showalways)
	Y = Y - 24
	Y = Y - 10
	local settings_channel = {}
	settings_channel.name = "PULLTIMERMODE"
	settings_channel.parent = TH_Settings.panel
	settings_channel.text = "PULLTIMERMODE"
	settings_channel.value = TankHelper:GetConfig("PULLTIMERMODE", "AUTO")
	settings_channel.x = 0
	settings_channel.y = Y
	settings_channel.dbvalue = "PULLTIMERMODE"
	settings_channel.tab = {
		{
			Name = "AUTO",
			Code = "AUTO"
		},
		{
			Name = "ONLYTHIRDPARTY",
			Code = "ONLYTHIRDPARTY"
		},
		{
			Name = "ONLYTH",
			Code = "ONLYTH"
		},
		{
			Name = "BOTH",
			Code = "BOTH"
		},
	}

	TankHelper:CreateDropDown(settings_channel)
	Y = Y - 40
	local settings_showtranslation = {}
	settings_showtranslation.name = "showtranslation"
	settings_showtranslation.parent = TH_Settings.panel
	settings_showtranslation.checked = TankHelper:GetConfig("showtranslation", true)
	settings_showtranslation.text = "showtranslation"
	settings_showtranslation.x = 10
	settings_showtranslation.y = Y
	settings_showtranslation.dbvalue = "showtranslation"
	settings_showtranslation.color = colgreen
	TankHelper:CreateCheckBox(settings_showtranslation)
	local settings_hidestatus = {}
	settings_hidestatus.name = "hidestatus"
	settings_hidestatus.parent = TH_Settings.panel
	settings_hidestatus.checked = TankHelper:GetConfig("hidestatus", true)
	settings_hidestatus.text = "hidestatus"
	settings_hidestatus.x = 300
	settings_hidestatus.y = Y
	settings_hidestatus.dbvalue = "hidestatus"
	settings_hidestatus.color = colgreen
	TankHelper:CreateCheckBox(settings_hidestatus)
	Y = Y - 24
	local settings_fixposition = {}
	settings_fixposition.name = "fixposition"
	settings_fixposition.parent = TH_Settings.panel
	settings_fixposition.checked = TankHelper:GetConfig("fixposition", false)
	settings_fixposition.text = "fixposition"
	settings_fixposition.x = 10
	settings_fixposition.y = Y
	settings_fixposition.dbvalue = "fixposition"
	settings_fixposition.color = colgreen
	TankHelper:CreateCheckBox(settings_fixposition)
	if UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then
		local settings_statusonlyhealers = {}
		settings_statusonlyhealers.name = "statusonlyhealers"
		settings_statusonlyhealers.parent = TH_Settings.panel
		settings_statusonlyhealers.checked = TankHelper:GetConfig("statusonlyhealers", true)
		settings_statusonlyhealers.text = "statusonlyhealers"
		settings_statusonlyhealers.x = 300
		settings_statusonlyhealers.y = Y
		settings_statusonlyhealers.dbvalue = "statusonlyhealers"
		settings_statusonlyhealers.color = colgreen
		TankHelper:CreateCheckBox(settings_statusonlyhealers)
	end

	Y = Y - 24
	local settings_hidelastrow = {}
	settings_hidelastrow.name = "hidelastrow"
	settings_hidelastrow.parent = TH_Settings.panel
	settings_hidelastrow.checked = TankHelper:GetConfig("hidelastrow", false)
	settings_hidelastrow.text = "hidelastrow"
	settings_hidelastrow.x = 10
	settings_hidelastrow.y = Y
	settings_hidelastrow.dbvalue = "hidelastrow"
	settings_hidelastrow.color = colgreen
	settings_hidelastrow.func = TankHelper.UpdateDesign
	TankHelper:CreateCheckBox(settings_hidelastrow)
	local settings_healthmax = {}
	settings_healthmax.name = "healthmax"
	settings_healthmax.parent = TH_Settings.panel
	settings_healthmax.value = TankHelper:GetConfig("healthmax", 0.9)
	settings_healthmax.text = "healthmax"
	settings_healthmax.x = 300
	settings_healthmax.y = -200
	settings_healthmax.min = 0.1
	settings_healthmax.max = 1.0
	settings_healthmax.steps = 0.1
	settings_healthmax.decimals = 1
	settings_healthmax.dbvalue = "healthmax"
	settings_healthmax.percentage = true
	settings_healthmax.w = 300
	settings_healthmax.color = {0, 1, 0, 1}
	TankHelper:CreateSlider(settings_healthmax)
	Y = Y - 24
	local settings_nameplatethreat = {}
	settings_nameplatethreat.name = "nameplatethreat"
	settings_nameplatethreat.parent = TH_Settings.panel
	settings_nameplatethreat.checked = TankHelper:GetConfig("nameplatethreat", true)
	settings_nameplatethreat.text = "nameplatethreat"
	settings_nameplatethreat.x = 10
	settings_nameplatethreat.y = Y
	settings_nameplatethreat.dbvalue = "nameplatethreat"
	settings_nameplatethreat.color = colgreen
	settings_nameplatethreat.func = function()
		TankHelper:ThinkNameplates(true)
	end

	TankHelper:CreateCheckBox(settings_nameplatethreat)
	local settings_powermax = {}
	settings_powermax.name = "powermax"
	settings_powermax.parent = TH_Settings.panel
	settings_powermax.value = TankHelper:GetConfig("powermax", 0.9)
	settings_powermax.text = "powermax"
	settings_powermax.x = 300
	settings_powermax.y = -230
	settings_powermax.min = 0.1
	settings_powermax.max = 1.0
	settings_powermax.steps = 0.1
	settings_powermax.decimals = 1
	settings_powermax.dbvalue = "powermax"
	settings_powermax.percentage = true
	settings_powermax.w = 300
	settings_powermax.color = {0, 1, 0, 1}
	TankHelper:CreateSlider(settings_powermax)
	Y = Y - H
	Y = Y - BR
	local settings_scalestatus = {}
	settings_scalestatus.name = "scalestatus"
	settings_scalestatus.parent = TH_Settings.panel
	settings_scalestatus.value = TankHelper:GetConfig("scalestatus", 1)
	settings_scalestatus.text = "scalestatus"
	settings_scalestatus.x = 300
	settings_scalestatus.y = -260
	settings_scalestatus.min = 0.1
	settings_scalestatus.max = 2.0
	settings_scalestatus.steps = 0.1
	settings_scalestatus.decimals = 1
	settings_scalestatus.dbvalue = "scalestatus"
	settings_scalestatus.w = 300
	settings_scalestatus.color = {0, 1, 0, 1}
	settings_scalestatus.func = TankHelper.UpdateDesign
	TankHelper:CreateSlider(settings_scalestatus)
	Y = -320
	local settings_targettingdelay = {}
	settings_targettingdelay.name = "targettingdelay"
	settings_targettingdelay.parent = TH_Settings.panel
	settings_targettingdelay.value = TankHelper:GetConfig("targettingdelay", 0.8)
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
	Y = Y - H
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
	TankHelper:AddColorPicker("BRColor", TH_Settings.panel, 450, -50)
	TankHelper:AddColorPicker("BGColor", TH_Settings.panel, 450, -75)
	InterfaceOptions_AddCategory(TH_Settings.panel)
end

local THloaded = false
local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" and not THloaded then
		THloaded = true
		InitSettings()
		TankHelper:InitSetup()
	end
end

frame:SetScript("OnEvent", frame.OnEvent)