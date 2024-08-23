local AddonName, TankHelper = ...
local thset = nil
local Y = 0
function TankHelper:GetColor(name)
	THTAB = THTAB or {}
	local r = THTAB[name .. "_r"]
	local g = THTAB[name .. "_g"]
	local b = THTAB[name .. "_b"]
	local a = THTAB[name .. "_a"]

	return r, g, b, a
end

function TankHelper:SetColor(name, r, g, b, a)
	THTAB = THTAB or {}
	THTAB[name .. "_r"] = r
	THTAB[name .. "_g"] = g
	THTAB[name .. "_b"] = b
	THTAB[name .. "_a"] = a
	TankHelper:UpdateColors(THCockpit)
	TankHelper:UpdateColors(THWorldMarkers)
	TankHelper:UpdateColors(THTargetMarkers)
	TankHelper:UpdateColors(THExtras)
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

		if frame.tBRl and frame.tBRr and frame.tBRt and frame.tBRb then
			frame.tBRl:SetColorTexture(r1, g1, b1, a1)
			frame.tBRr:SetColorTexture(r1, g1, b1, a1)
			frame.tBRt:SetColorTexture(r1, g1, b1, a1)
			frame.tBRb:SetColorTexture(r1, g1, b1, a1)
		end

		if frame.tBG then
			frame.tBG:SetColorTexture(r2, g2, b2, a2)
		end
	end
end

function TankHelper:GetLang()
	if TankHelper:GetConfig("showtranslation", true) then return nil end

	return "enUS"
end

function TankHelper:ShowColorPicker(r, g, b, a, changedCallback)
	if ColorPickerFrame.SetupColorPickerAndShow then
		local info = {}
		info.swatchFunc = changedCallback
		info.hasOpacity = true
		info.opacityFunc = changedCallback
		info.cancelFunc = changedCallback
		info.extraInfo = "TEST"
		info.r = r
		info.g = g
		info.b = b
		info.opacity = a
		ColorPickerFrame:SetupColorPickerAndShow(info)
	else
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.swatchFunc = changedCallback, changedCallback, changedCallback
		ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = a ~= nil, 1 - a
		ColorPickerFrame.previousValues = {r, g, b, a}
		if ColorPickerFrame.SetColorRGB then
			ColorPickerFrame:SetColorRGB(r, g, b)
		end

		ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = a ~= nil, 1 - a
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
	end
end

function TankHelper:AddColorPicker(name, parent, x)
	local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
	btn:SetSize(140, 25)
	btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, Y)
	btn:SetText(TankHelper:Trans(name))
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
						local alpha = 1
						if ColorPickerFrame.GetColorAlpha then
							alpha = ColorPickerFrame:GetColorAlpha()
						else
							alpha = OpacitySliderFrame:GetValue()
						end

						if TankHelper:GetWoWBuild() ~= "RETAIL" then
							alpha = 1 - alpha
						end

						newA, newR, newG, newB = alpha, ColorPickerFrame:GetColorRGB()
					end

					TankHelper:SetColor(name, newR, newG, newB, newA)
				end
			)
		end
	)

	Y = Y - 30
end

function TankHelper:ToggleSettings()
	if thset then
		if thset:IsShown() then
			thset:Hide()
		else
			thset:Show()
		end
	end
end

function TankHelper:CreateCategory(name)
	if Y == 0 then
		Y = Y - 5
	else
		Y = Y - 30
	end

	TankHelper:AddCategory(
		{
			["name"] = name,
			["parent"] = thset.SC,
			["pTab"] = {"TOPLEFT", 5, Y},
		}
	)

	Y = Y - 20
end

function TankHelper:CreateCheckBox(key, lstr, x, value, func)
	THTAB = THTAB or {}
	value = value or false
	local val = THTAB[key]
	if val == nil then
		val = value
	end

	x = x or 5
	TankHelper:CreateCheckbox(
		{
			["name"] = key,
			["parent"] = thset.SC,
			["pTab"] = {"TOPLEFT", x, Y},
			["value"] = val,
			["funcV"] = function(sel, checked)
				THTAB[key] = checked
				if func then
					func()
				end
			end
		}
	)

	Y = Y - 20
end

function TankHelper:AddComboBox(key, lstr, value, tab)
	Y = Y - 10
	local comboBox = {}
	comboBox.name = key
	comboBox.parent = thset.SC
	comboBox.text = lstr
	if TankHelper:GetConfig(key, value) ~= nil then
		comboBox.value = TankHelper:Trans(TankHelper:GetConfig(key, value))
	else
		comboBox.value = value
	end

	comboBox.x = 50
	comboBox.y = Y
	comboBox.dbvalue = key
	comboBox.tab = tab
	TankHelper:CreateDropDown(comboBox)
	Y = Y - 30
end

function TankHelper:AddSlider(key, lstr, value, min, max, steps, decimals, percentage, func)
	Y = Y - 15
	local slider = {}
	slider.name = key
	slider.parent = thset.SC
	slider.value = TankHelper:GetConfig(key, value)
	slider.text = lstr
	slider.x = 10
	slider.y = Y
	slider.min = min
	slider.max = max
	slider.steps = steps
	slider.decimals = decimals
	slider.dbvalue = "powermax"
	slider.percentage = percentage
	slider.w = 460
	slider.color = {0, 1, 0, 1}
	slider.func = func
	TankHelper:CreateSlider(slider)
	Y = Y - 30
end

function TankHelper:InitSettings()
	THTAB = THTAB or {}
	TankHelper:SetVersion(AddonName, 132362, "1.9.19")
	THTAB["MMBTNTAB"] = THTAB["MMBTNTAB"] or {}
	C_Timer.After(
		0,
		function()
			if THTAB["MMBTN"] == nil then
				THTAB["MMBTN"] = TankHelper:GetWoWBuild() ~= "RETAIL"
			end

			TankHelper:CreateMinimapButton(
				{
					["name"] = "TankHelper",
					["icon"] = 132362,
					["dbtab"] = THTAB,
					["vTT"] = {{"TankHelper |T132362:16:16:0:0|t", "v|cff3FC7EB1.9.19"}, {"Leftclick", "Options"}, {"Rightclick", "Toggle MinimapButton"}},
					["funcL"] = function()
						TankHelper:ToggleSettings()
					end,
					["funcR"] = function()
						THTAB["MMBTN"] = not THTAB["MMBTN"]
						if THTAB["MMBTN"] then
							TankHelper:ShowMMBtn("TankHelper")
						else
							TankHelper:HideMMBtn("TankHelper")
						end
					end
				}
			)

			if THTAB["MMBTN"] then
				TankHelper:ShowMMBtn("TankHelper")
			else
				TankHelper:HideMMBtn("TankHelper")
			end
		end
	)

	TankHelper:AddSlash("th", TankHelper.ToggleSettings)
	TankHelper:AddSlash("tankhelper", TankHelper.ToggleSettings)
	thset = TankHelper:CreateFrame(
		{
			["name"] = "TankHelper Settings Frame",
			["pTab"] = {"CENTER"},
			["sw"] = 520,
			["sh"] = 520,
			["title"] = format("TankHelper |T132362:16:16:0:0|t by |cff3FC7EBD4KiR |T132115:16:16:0:0|t v|cff3FC7EB%s", "1.9.19")
		}
	)

	thset:SetFrameLevel(110)
	thset.SF = CreateFrame("ScrollFrame", "thset_SF", thset, "UIPanelScrollFrameTemplate")
	thset.SF:SetPoint("TOPLEFT", thset, 8, -26)
	thset.SF:SetPoint("BOTTOMRIGHT", thset, -32, 8)
	thset.SC = CreateFrame("Frame", "thset_SC", thset.SF)
	thset.SC:SetSize(thset.SF:GetSize())
	thset.SC:SetPoint("TOPLEFT", thset.SF, "TOPLEFT", 0, 0)
	thset.SF:SetScrollChild(thset.SC)
	Y = 0
	TankHelper:CreateCategory("general")
	TankHelper:CreateCheckBox(
		"MMBTN",
		"MMBTN",
		5,
		TankHelper:GetWoWBuild() ~= "RETAIL",
		function()
			if THTAB["MMBTN"] then
				TankHelper:ShowMMBtn("TankHelper")
			else
				TankHelper:HideMMBtn("TankHelper")
			end
		end
	)

	TankHelper:CreateCheckBox("showtranslation", "showtranslation", 5, true)
	TankHelper:CreateCategory("design")
	TankHelper:CreateCheckBox("showalways", "showalways", 5, false)
	TankHelper:CreateCheckBox("combineall", "combineall", 5, false, TankHelper.UpdateDesign)
	TankHelper:CreateCheckBox("fixposition", "fixposition", 5, false)
	TankHelper:AddSlider("obr", "obr", 6.0, 0.0, 12.0, 1, 0, nil, TankHelper.UpdateDesign)
	TankHelper:AddSlider("ibr", "ibr", 1.0, 0.0, 12.0, 1, 0, nil, TankHelper.UpdateDesign)
	TankHelper:AddSlider("cbr", "cbr", 3.0, 0.0, 12.0, 1, 0, nil, TankHelper.UpdateDesign)
	TankHelper:AddSlider("iconsize", "iconsize", 16.0, 8.0, 64.0, 2, 0, nil, TankHelper.UpdateDesign)
	TankHelper:AddSlider("scalestatus", "scalestatus", 1.0, 0.0, 2.0, 0.1, 1, nil, TankHelper.UpdateDesign)
	TankHelper:AddSlider("scalecockpit", "scalecockpit", 1.0, 0.0, 2.0, 0.1, 1, nil, TankHelper.UpdateDesign)
	TankHelper:AddColorPicker("BRColor", thset.SC, 5, Y)
	TankHelper:AddColorPicker("BGColor", thset.SC, 5, Y)
	if IsRaidMarkerActive then
		TankHelper:CreateCategory("worldmarks")
		TankHelper:CreateCheckBox("hideworldmarks", "hideworldmarks", 5, false, TankHelper.UpdateDesign)
	end

	TankHelper:CreateCategory("targetmarks")
	TankHelper:CreateCheckBox("hidetargetmarks", "hidetargetmarks", 5, false, TankHelper.UpdateDesign)
	TankHelper:CreateCheckBox("onlytank", "onlytank", 5, false)
	TankHelper:CreateCategory("specialbar")
	TankHelper:CreateCheckBox("hidespecialbar", "hidespecialbar", 5, false, TankHelper.UpdateDesign)
	TankHelper:AddSlider("targettingdelay", "targettingdelay", 0.0, 0.0, 5.0, 0.1, 1, nil, TankHelper.UpdateDesign)
	TankHelper:AddComboBox(
		"PULLTIMERMODE",
		"PULLTIMERMODE",
		"AUTO",
		{
			{
				Name = TankHelper:Trans("AUTO"),
				Code = "AUTO"
			},
			{
				Name = TankHelper:Trans("ONLYTHIRDPARTY"),
				Code = "ONLYTHIRDPARTY"
			},
			{
				Name = TankHelper:Trans("ONLYTH"),
				Code = "ONLYTH"
			},
			{
				Name = TankHelper:Trans("BOTH"),
				Code = "BOTH"
			},
		}
	)

	TankHelper:CreateCategory("nameplate")
	TankHelper:CreateCheckBox(
		"nameplatethreat",
		"nameplatethreat",
		5,
		true,
		function()
			TankHelper:ThinkNameplates(true)
		end
	)

	TankHelper:CreateCategory("status")
	TankHelper:CreateCheckBox("hidestatus", "hidestatus", 5, true)
	if UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then
		TankHelper:CreateCheckBox("statusonlyhealers", "statusonlyhealers", 5, true)
	end

	TankHelper:AddSlider("healthmax", "healthmax", 0.9, 0.1, 1.0, 0.1, 1, true)
	TankHelper:AddSlider("powermax", "powermax", 0.9, 0.1, 1.0, 0.1, 1, true)
end

local THloaded = false
local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" and not THloaded then
		THloaded = true
		TankHelper:InitSetup()
		C_Timer.After(
			1,
			function()
				TankHelper:InitSettings()
			end
		)
	end
end

frame:SetScript("OnEvent", frame.OnEvent)
