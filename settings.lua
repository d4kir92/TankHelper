local _, TankHelper = ...
local thset = nil
local DEFAULT_WIDTH = 520
local DEFAULT_HEIGHT = 520
function TankHelper:UpdateColors(frame)
	if THTAB["BGColor_R"] == nil then TankHelper:SetColor("BGColor", 0, 0, 0, 0.4) end
	if THTAB["BRColor_R"] == nil then TankHelper:SetColor("BRColor", 0, 0, 0, 0.2) end
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

TankHelper.LANGUAGES = {{"English", "enUS"}, {"Deutsch", "deDE"}, {"Español (España)", "esES"}, {"Español (México)", "esMX"}, {"Français", "frFR"}, {"Italiano", "itIT"}, {"한국어", "koKR"}, {"Português (Brasil)", "ptBR"}, {"Русский", "ruRU"}, {"简体中文", "zhCN"}, {"繁體中文", "zhTW"}}
local Translate = TankHelper.Trans
function TankHelper:GetLang()
	return THTAB and THTAB["LANGUAGE"] or (TankHelper:GetConfig("showtranslation", true) and GetLocale() or "enUS")
end

function TankHelper:Trans(key, lang, ...)
	return Translate(self, key, lang or self:GetLang(), ...)
end

function TankHelper:GetLanguageName()
	for _, info in ipairs(self.LANGUAGES) do
		if info[2] == self:GetLang() then return info[1] end
	end
	return self:GetLang()
end

function TankHelper:RefreshSettingsLanguage()
	if not thset then return end
	for _, info in ipairs(thset.translatedElements or {}) do
		local text = self:Trans(info.key)
		if info.widget.slider then text = format(text, info.widget.slider:GetValue()) end
		if info.widget.Label then info.widget.Label:SetText(text) end
		local element = info.widget.uiElement or info.widget.element
		if element then self.UI:SetLabel(element, text) end
		if info.widget.SetValue and info.widget.value then info.widget:SetValue(info.widget.value) end
	end

	if thset.search and thset.search.Hint then thset.search.Hint:SetText(self:Trans("LID_SEARCH")) end
	thset.Language:SetText(self:GetLanguageName())
	self:UpdateTankHealerMarkerButton()
end

function TankHelper:SetLanguage(lang)
	THTAB["LANGUAGE"] = lang
	self:RefreshSettingsLanguage()
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

local function AddCheckbox(key, default, func, added)
	local value = THTAB[key]
	if value == nil then value = default end
	return thset:AddCheckbox({
		["label"] = "LID_" .. key,
		["search"] = key,
		["value"] = value,
		["added"] = added,
		["func"] = function(newValue)
			THTAB[key] = newValue
			if func then func() end
		end
	})
end

local function AddSlider(key, default, min, max, step, decimals, func, added)
	return thset:AddSlider({
		["label"] = "LID_" .. key,
		["search"] = key,
		["value"] = TankHelper:GetConfig(key, default),
		["added"] = added,
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

local markerIconDropdowns = {}
local function UpdateMarkerIconDropdowns()
	for _, dropdown in ipairs(markerIconDropdowns) do
		dropdown:SetEnabled(THTAB["marktankhealer"] ~= false)
	end
end

local function AddMarkerIconDropdown(key, default)
	local choices = {}
	for index = 1, 8 do
		tinsert(choices, {
			["value"] = index,
			["label"] = TankHelper:GetRaidIconText(index) .. " " .. (_G["RAID_TARGET_" .. index] or index)
		})
	end

	local dropdown = thset:AddDropdown({
		["label"] = "LID_" .. key,
		["search"] = key,
		["value"] = TankHelper:GetConfig(key, default),
		["choices"] = choices,
		["func"] = function(value)
			THTAB[key] = value
			TankHelper:UpdateTankHealerMarkerButton()
		end
	})

	dropdown.uiElement.depth = dropdown.uiElement.depth + 1
	tinsert(markerIconDropdowns, dropdown)
end

local function IsTransparentBlack(key)
	return THTAB[key .. "_R"] == 0 and THTAB[key .. "_G"] == 0 and THTAB[key .. "_B"] == 0 and THTAB[key .. "_A"] == 0
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
	if THTAB["COLORDEFAULTS_FIXED"] == nil then
		if IsTransparentBlack("BRColor") then TankHelper:SetColor("BRColor", 0, 0, 0, 0.2) end
		if IsTransparentBlack("BGColor") then TankHelper:SetColor("BGColor", 0, 0, 0, 0.4) end
		THTAB["COLORDEFAULTS_FIXED"] = true
	end

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

	thset.translatedElements = {}
	for _, method in ipairs({"AddCategory", "AddCheckbox", "AddSlider", "AddDropdown", "AddColorPicker"}) do
		local original = thset[method]
		thset[method] = function(win, tab)
			local widget = original(win, tab)
			tinsert(win.translatedElements, {
				widget = widget,
				key = tab.label
			})

			if widget.slider then widget.slider:HookScript("OnValueChanged", function() TankHelper:RefreshSettingsLanguage() end) end
			return widget
		end
	end

	function thset.LanguageMenu(_, root)
		root:CreateTitle(TankHelper:Trans("LID_LANGUAGE"))
		for _, info in ipairs(TankHelper.LANGUAGES) do
			local lang = info[2]
			root:CreateRadio(format("%s (%s)", info[1], lang), function() return TankHelper:GetLang() == lang end, function() TankHelper:SetLanguage(lang) end)
		end
	end

	if TankHelper:GetWoWBuild() == "RETAIL" and TankHelper:CheckTemplates("WowStyle1DropdownTemplate") then
		thset.Language = CreateFrame("DropdownButton", "TankHelperSettings_Language", thset.titleBar or thset, "WowStyle1DropdownTemplate")
		thset.Language:SetScale(0.8)
		thset.Language:SetSize(162.5, 25)
		thset.Language:SetPoint("TOPLEFT", thset.titleBar or thset, "TOPLEFT", 10, -1.25)
		thset.Language:SetSelectionText(function() return TankHelper:GetLanguageName() end)
		thset.Language:SetTooltip(function(tooltip) tooltip:SetText(TankHelper:Trans("LID_LANGUAGE")) end)
		thset.Language:SetupMenu(thset.LanguageMenu)
	else
		thset.Language = TankHelper:CreateButton("TankHelperSettings_Language", thset.titleBar or thset)
		thset.Language:SetSize(130, 20)
		thset.Language:SetPoint("TOPLEFT", thset.titleBar or thset, "TOPLEFT", 7, -2)
		thset.Language.Arrow = thset.Language:CreateTexture(nil, "OVERLAY")
		thset.Language.Arrow:SetTexture("Interface\ChatFrame\UI-ChatIcon-ScrollDown-Up")
		thset.Language.Arrow:SetSize(16, 16)
		thset.Language.Arrow:SetPoint("RIGHT", thset.Language, "RIGHT", -2, 0)
		thset.Language:SetScript("OnClick", function(sel)
			if MenuUtil and MenuUtil.CreateContextMenu then
				MenuUtil.CreateContextMenu(sel, thset.LanguageMenu)
			else
				local current = 1
				for i, info in ipairs(TankHelper.LANGUAGES) do
					if info[2] == TankHelper:GetLang() then current = i end
				end

				TankHelper:SetLanguage(TankHelper.LANGUAGES[current % #TankHelper.LANGUAGES + 1][2])
			end
		end)
	end

	thset.Language:SetText(TankHelper:GetLanguageName())
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

	AddCheckbox("hideraidmanager", true, function() TankHelper:UpdateRaidManager() end, "2026-10-07")
	AddCategory("design")
	AddCheckbox("showalways", false, function() if TankHelper.DesignThink then TankHelper:DesignThink() end end)
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
		["A"] = 0.2
	}, UpdateAllColors)

	AddColorPicker("BGColor", {
		["R"] = 0,
		["G"] = 0,
		["B"] = 0,
		["A"] = 0.4
	}, UpdateAllColors)

	if IsRaidMarkerActive then
		AddCategory("worldmarks")
		AddCheckbox("hideworldmarks", false, TankHelper.UpdateDesign)
	end

	AddCategory("targetmarks")
	AddCheckbox("hidetargetmarks", false, TankHelper.UpdateDesign)
	AddCheckbox("onlytank", false, function() TankHelper:UpdateTabMarker() end)
	AddCheckbox("marktankhealer", true, function()
		TankHelper:UpdateTankHealerMarkerButton()
		UpdateMarkerIconDropdowns()
	end)

	AddMarkerIconDropdown("marktankicon", 6)
	AddMarkerIconDropdown("markhealericon", 5)
	UpdateMarkerIconDropdowns()
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
	local nameplateThreat = AddCheckbox("nameplatethreat", false, function()
		TankHelper:UpdateThreatDisplays()
		thset:UpdateDependencies()
	end)

	local function IsNameplateThreatEnabled()
		return THTAB["nameplatethreat"] == true
	end

	for _, widget in ipairs({AddCheckbox("nameplatethreaticon", true, TankHelper.UpdateThreatDisplays, "2026-10-08"), AddCheckbox("nameplatethreathealthcolor", false, TankHelper.UpdateThreatDisplays, "2026-10-08"), AddSlider("nameplatethreatx", 0, -200, 200, 1, 0, TankHelper.UpdateThreatPositions, "2026-10-08"), AddSlider("nameplatethreaty", 70, -150, 150, 1, 0, TankHelper.UpdateThreatPositions, "2026-10-08")}) do
		thset:AddRequirement(widget, nameplateThreat)
		thset:AddDependency(widget, IsNameplateThreatEnabled)
	end

	thset:UpdateDependencies()
	AddCategory("status")
	AddCheckbox("hidestatus", true)
	if UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then AddCheckbox("statusonlyhealers", true) end
	AddSlider("healthmax", 0.9, 0.1, 1.0, 0.1, 1)
	AddSlider("powermax", 0.9, 0.1, 1.0, 0.1, 1)
	thset:ResumeLayout()
	TankHelper:RefreshSettingsLanguage()
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
		TankHelper:SetVersion(132362, "1.12.5")
		TankHelper:InitSettings()
		TankHelper:InitSetup()
	end
end

frame:SetScript("OnEvent", frame.OnEvent)
