local _, TankHelper = ...
local thset = nil
local DEFAULT_WIDTH = 520
local DEFAULT_HEIGHT = 520
function TankHelper:UpdateColors(frame)
	if TankHelper:GetColor("BGColor", "UpdateColors") == nil then TankHelper:SetColor("BGColor", 0, 0, 0, 0.4) end
	if TankHelper:GetColor("BRColor", "UpdateColors") == nil then TankHelper:SetColor("BRColor", 0, 0, 0, 0.2) end
	local r1, g1, b1, a1 = TankHelper:GetColor("BRColor", "UpdateColors")
	local r2, g2, b2, a2 = TankHelper:GetColor("BGColor", "UpdateColors")
	if frame then
		if frame.IsMouseOver == nil then
			TankHelper:ERR("TankHelper:UpdateColors(frame) => IsMouseOver missing")
			return
		end

		if frame:IsMouseOver() and a1 < 0.15 then a1 = 0.15 end
		if frame.tBRl and frame.tBRr and frame.tBRt and frame.tBRb then
			frame.tBRl:SetColorTexture(r1, g1, b1, a1)
			frame.tBRr:SetColorTexture(r1, g1, b1, a1)
			frame.tBRt:SetColorTexture(r1, g1, b1, a1)
			frame.tBRb:SetColorTexture(r1, g1, b1, a1)
		end

		if frame.tBG then frame.tBG:SetColorTexture(r2, g2, b2, a2) end
	end
end

function TankHelper:GetLang()
	if TankHelper:GetConfig("showtranslation", true) then return nil end
	return "enUS"
end

function TankHelper:ToggleSettings()
	if thset == nil then return end
	thset:Toggle()
end

local function UpdateAllColors()
	TankHelper:UpdateColors(THCockpit)
	TankHelper:UpdateColors(THWorldMarkers)
	TankHelper:UpdateColors(THTargetMarkers)
	TankHelper:UpdateColors(THExtras)
end

local function GetCollapsed(key)
	if key == nil then return nil end
	if type(THTAB) ~= "table" then return nil end
	if type(THTAB["COLLAPSED"]) ~= "table" then return nil end
	return THTAB["COLLAPSED"][key]
end

local function SetCollapsed(key, collapsed)
	if key == nil then return end
	if type(THTAB) ~= "table" then return end
	if type(THTAB["COLLAPSED"]) ~= "table" then THTAB["COLLAPSED"] = {} end
	if collapsed then
		THTAB["COLLAPSED"][key] = true
	else
		THTAB["COLLAPSED"][key] = nil
	end
end

local function AddCategory(key)
	thset:AddCategory({
		["label"] = "LID_" .. key,
		["key"] = key,
		["search"] = key
	})
end

local function AddCheckbox(key, default, func)
	local value = THTAB[key]
	if value == nil then value = default end
	thset:AddCheckbox({
		["label"] = "LID_" .. key,
		["search"] = key,
		["value"] = value,
		["func"] = function(newValue)
			THTAB[key] = newValue
			if func then func() end
		end
	})
end

local function AddSlider(key, default, min, max, step, decimals, func)
	thset:AddSlider({
		["label"] = "LID_" .. key,
		["search"] = key,
		["value"] = TankHelper:GetConfig(key, default),
		["min"] = min,
		["max"] = max,
		["step"] = step,
		["decimals"] = decimals,
		["func"] = function(value)
			THTAB[key] = value
			if func then func() end
		end
	})
end

local function AddColorPicker(key, default, func)
	if THTAB[key .. "_R"] == nil then TankHelper:SetColor(key, default.R, default.G, default.B, default.A) end
	local r, g, b, a = TankHelper:GetColor(key, "AddColorPicker")
	thset:AddColorPicker({
		["label"] = "LID_" .. key,
		["search"] = key,
		["value"] = {
			["r"] = r,
			["g"] = g,
			["b"] = b,
			["a"] = a
		},
		["func"] = function(newR, newG, newB, newA)
			TankHelper:SetColor(key, newR, newG, newB, newA)
			if func then func() end
		end
	})
end

function TankHelper:InitSettings()
	THTAB["MMBTNTAB"] = THTAB["MMBTNTAB"] or {}
	if THTAB["MMBTN"] == nil then THTAB["MMBTN"] = TankHelper:GetWoWBuild() ~= "RETAIL" end
	TankHelper:CreateMinimapButton({
		["name"] = "TankHelper",
		["icon"] = 132362,
		["dbtab"] = THTAB,
		["vTT"] = {{"|T132362:16:16:0:0|t TankHelper", "v" .. TankHelper:GetVersion()}, {TankHelper:Trans("LID_LEFTCLICK"), TankHelper:Trans("LID_OPENSETTINGS")}, {TankHelper:Trans("LID_RIGHTCLICK"), TankHelper:Trans("LID_HIDEMINIMAPBUTTON")}},
		["funcL"] = function() TankHelper:ToggleSettings() end,
		["funcR"] = function()
			THTAB["MMBTN"] = not THTAB["MMBTN"]
			if THTAB["MMBTN"] then
				TankHelper:ShowMMBtn("TankHelper")
			else
				TankHelper:HideMMBtn("TankHelper")
			end
		end,
		["dbkey"] = "MMBTN"
	})

	TankHelper:AddSlash("th", TankHelper.ToggleSettings)
	TankHelper:AddSlash("tankhelper", TankHelper.ToggleSettings)
	TankHelper:SetAppendTab(THTAB)
	thset = TankHelper:CreateUIWindow({
		["name"] = "TankHelperSettings",
		["pTab"] = {"CENTER"},
		["width"] = TankHelper:GetConfig("WINDOWWIDTH", DEFAULT_WIDTH),
		["height"] = TankHelper:GetConfig("WINDOWHEIGHT", DEFAULT_HEIGHT),
		["minWidth"] = 360,
		["minHeight"] = 240,
		["onResize"] = function(width, height)
			THTAB["WINDOWWIDTH"] = width
			THTAB["WINDOWHEIGHT"] = height
		end,
		["getCollapsed"] = function(key) return GetCollapsed(key) end,
		["setCollapsed"] = function(key, collapsed) SetCollapsed(key, collapsed) end,
		["title"] = format("|T132362:16:16:0:0|t TankHelper by |cff55d2ffD4KiR |T132115:16:16:0:0|t v%s", TankHelper:GetVersion())
	})

	thset:SuspendLayout()
	thset:AddSearch()
	AddCategory("general")
	AddCheckbox("MMBTN", TankHelper:GetWoWBuild() ~= "RETAIL", function()
		if THTAB["MMBTN"] then
			TankHelper:ShowMMBtn("TankHelper")
		else
			TankHelper:HideMMBtn("TankHelper")
		end
	end)

	AddCheckbox("showtranslation", true)
	AddCategory("design")
	AddCheckbox("showalways", false)
	AddCheckbox("combineall", false, TankHelper.UpdateDesign)
	AddCheckbox("fixposition", false)
	AddSlider("obr", 6.0, 3.0, 12.0, 1, 0, TankHelper.UpdateDesign)
	AddSlider("ibr", 1.0, 0.0, 12.0, 1, 0, TankHelper.UpdateDesign)
	AddSlider("cbr", 3.0, 0.0, 12.0, 1, 0, TankHelper.UpdateDesign)
	AddSlider("iconsize", 16.0, 8.0, 64.0, 2, 0, TankHelper.UpdateDesign)
	AddSlider("scalestatus", 1.0, 0.1, 2.0, 0.1, 1, TankHelper.UpdateDesign)
	AddSlider("scalecockpit", 1.0, 0.1, 2.0, 0.1, 1, TankHelper.UpdateDesign)
	AddColorPicker("BRColor", {
		["R"] = 0,
		["G"] = 0,
		["B"] = 0,
		["A"] = 0
	}, UpdateAllColors)

	AddColorPicker("BGColor", {
		["R"] = 0,
		["G"] = 0,
		["B"] = 0,
		["A"] = 0
	}, UpdateAllColors)

	if IsRaidMarkerActive then
		AddCategory("worldmarks")
		AddCheckbox("hideworldmarks", false, TankHelper.UpdateDesign)
	end

	AddCategory("targetmarks")
	AddCheckbox("hidetargetmarks", false, TankHelper.UpdateDesign)
	AddCheckbox("onlytank", false)
	AddCategory("specialbar")
	AddCheckbox("hidespecialbar", false, TankHelper.UpdateDesign)
	AddSlider("targettingdelay", 0.0, 0.0, 5.0, 0.1, 1, TankHelper.UpdateDesign)
	thset:AddDropdown({
		["label"] = "LID_PULLTIMERMODE",
		["search"] = "PULLTIMERMODE",
		["value"] = TankHelper:GetConfig("PULLTIMERMODE", "AUTO"),
		["choices"] = {
			{
				["value"] = "AUTO",
				["label"] = "LID_AUTO"
			},
			{
				["value"] = "ONLYTHIRDPARTY",
				["label"] = "LID_ONLYTHIRDPARTY"
			},
			{
				["value"] = "ONLYTH",
				["label"] = "LID_ONLYTH"
			},
			{
				["value"] = "BOTH",
				["label"] = "LID_BOTH"
			},
		},
		["func"] = function(value) THTAB["PULLTIMERMODE"] = value end
	})

	AddCategory("nameplate")
	AddCheckbox("nameplatethreat", false)
	AddCategory("status")
	AddCheckbox("hidestatus", true)
	if UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then AddCheckbox("statusonlyhealers", true) end
	AddSlider("healthmax", 0.9, 0.1, 1.0, 0.1, 1)
	AddSlider("powermax", 0.9, 0.1, 1.0, 0.1, 1)
	thset:ResumeLayout()
end

local THloaded = false
local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" and not THloaded then
		THloaded = true
		THTAB = THTAB or {}
		THTAB["MMBTNTAB"] = THTAB["MMBTNTAB"] or {}
		if THTAB["MMBTN"] == nil then THTAB["MMBTN"] = TankHelper:GetWoWBuild() ~= "RETAIL" end
		TankHelper:SetVersion(132362, "1.10.0")
		TankHelper:InitSettings()
		TankHelper:InitSetup()
	end
end

frame:SetScript("OnEvent", frame.OnEvent)
