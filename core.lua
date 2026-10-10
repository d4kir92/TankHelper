local _, TankHelper = ...
local THBORDERALPHA = 0.5
local obr = 6 -- Outside Border
local ibr = 1 -- Icon Border
local cbr = 3 -- Cell Border
local iconsize = 16
local iconbr = 4
local iconbtn = iconsize + 2 * iconbr
local pt = {3, 5, 10, 20, 60, 300}
local THStatusColor = {1, 1, 1, 1}
local updatewms = true
local ricons1 = {}
local ricons2 = {}
local rows = 3
local cols = 9
local markScale = 2
local WMN = 8
local WMIds = {}
local wms = {5, 6, 3, 2, 7, 1, 4, 8}
local targetRevision = 0
function TankHelper:UpdateRaidManager()
	if InCombatLockdown() then return end
	local manager = CompactRaidFrameManager
	if not manager then return end
	local hide = TankHelper:GetConfig("hideraidmanager", true)
	manager.thHiddenFrames = manager.thHiddenFrames or {}
	for _, region in ipairs({manager:GetRegions()}) do
		region:SetAlpha(hide and 0 or 1)
	end

	manager:EnableMouse(not hide)
	for _, child in ipairs({manager:GetChildren()}) do
		if child ~= manager.container and child ~= manager.containerResizeFrame then
			if not child.thVisibilityHooked then
				child.thVisibilityHooked = true
				child:HookScript("OnShow", function(sel)
					if TankHelper:GetConfig("hideraidmanager", true) and not InCombatLockdown() then
						manager.thHiddenFrames[sel] = true
						sel:Hide()
					end
				end)
			end

			if hide then
				if child:IsShown() then
					manager.thHiddenFrames[child] = true
					child:Hide()
				end
			elseif manager.thHiddenFrames[child] then
				manager.thHiddenFrames[child] = nil
				child:Show()
			end
		end
	end

	if not hide and CompactRaidFrameManager_UpdateShown then CompactRaidFrameManager_UpdateShown(manager) end
end

function TankHelper:UpdateRaidManagerIcons()
	if not THExtras then return end
	local manager = CompactRaidFrameManager
	local display = manager and manager.displayFrame
	local options = display and (display.leaderOptions or display)
	for _, info in ipairs({{"btnReadycheck", "readyCheckButton", "GM-icon-readyCheck", READY_CHECK}, {"btnRolepoll", "rolePollButton", "GM-icon-roles", ROLE_POLL}}) do
		local button = THExtras[info[1]]
		if button then
			local source = options and options[info[2]]
			local texture = source and source:GetNormalTexture()
			local atlas = texture and texture.GetAtlas and texture:GetAtlas()
			if not atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(info[3]) then atlas = info[3] end
			if atlas or (texture and texture:GetTexture()) then
				if not button.icon then
					button.icon = button:CreateTexture(nil, "ARTWORK")
					button.icon:SetPoint("CENTER")
				end

				button.icon:SetSize(iconbtn, iconbtn)
				if atlas then
					button.icon:SetAtlas(atlas)

				else
					button.icon:SetTexture(texture:GetTexture())
					button.icon:SetTexCoord(texture:GetTexCoord())
				end

				button:SetText("")
			else
				button:SetText(info[4])
			end

			button:SetScript("OnEnter", function(sel)
				GameTooltip:SetOwner(sel, "ANCHOR_RIGHT")
				GameTooltip:SetText(info[4])
				GameTooltip:Show()
			end)
			button:SetScript("OnLeave", function() GameTooltip:Hide() end)
		end
	end
end
function TankHelper:CreateInvisibleButton(name, parent)
	local btn = CreateFrame("Button", name, parent, "SecureActionButtonTemplate")
	btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	--btn.text:SetFont(STANDARD_TEXT_FONT, 11, "")
	btn.text:SetText("")
	btn.text:SetPoint("CENTER", btn, "CENTER", 0, 0)
	function btn:SetText(text)
		btn.text:SetText(text)
	end
	return btn
end

function TankHelper:ShouldShow()
	return IsInInstance() or UnitInParty("PLAYER") or UnitInRaid("PLAYER")
end

local function GetPartyUnitForRole(role)
	local units = {"PLAYER", "party1", "party2", "party3", "party4"}
	for _, unit in ipairs(units) do
		if UnitExists(unit) then
			local assignedRole = UnitGroupRolesAssigned(unit)
			if not TankHelper:IsSecret(assignedRole) and assignedRole == role then return unit end
		end
	end
end

local function IsUnitNearby(unit)
	if unit == "PLAYER" then return true end
	if not UnitIsConnected(unit) or not UnitIsVisible(unit) then return false end
	if UnitInRange == nil then return true end
	local inRange, checkedRange = UnitInRange(unit)
	if TankHelper:IsSecret(inRange) or TankHelper:IsSecret(checkedRange) then return true end
	return not checkedRange or inRange
end

function TankHelper:GetRaidIconText(index)
	return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. index .. ":16|t"
end

TankHelper.roleMarkConfirmed = {}
TankHelper.ownMarkTime = 0
function TankHelper:NeedsRoleMark(role, unit, icon)
	local marker = GetRaidTargetIndex(unit)
	if TankHelper:IsSecret(marker) then return TankHelper:GetConfig("marktankhealerwrong", false) and TankHelper.roleMarkConfirmed[role] ~= unit .. ":" .. icon end
	if marker == nil then return true end
	if marker == icon then return false end
	if TankHelper:GetConfig("marktankhealerwrong", false) then return true end
	local autoIcon = TankHelper:GetConfig("autoselect", 8)
	return autoIcon ~= -1 and marker == autoIcon
end

function TankHelper:OnRaidTargetUpdate()
	if GetTime() - TankHelper.ownMarkTime > 1.5 then TankHelper.roleMarkConfirmed = {} end
end

function TankHelper:UpdateTankHealerMarkerButton()
	if THMarkTankAndHealer == nil or InCombatLockdown() then return end
	local tankIcon = TankHelper:GetConfig("marktankicon", 6)
	local healerIcon = TankHelper:GetConfig("markhealericon", 5)
	local inInstance, instanceType = IsInInstance()
	if UnitGroupRolesAssigned == nil or not TankHelper:GetConfig("marktankhealer", true) or not inInstance or instanceType ~= "party" or IsInRaid() or UnitIsDeadOrGhost("PLAYER") then
		THMarkTankAndHealer:Hide()
		return
	end

	local tankUnit = GetPartyUnitForRole("TANK")
	local healerUnit = GetPartyUnitForRole("HEALER")
	if tankUnit and healerIcon == tankIcon then healerUnit = nil end
	if tankUnit and not IsUnitNearby(tankUnit) then tankUnit = nil end
	if healerUnit and not IsUnitNearby(healerUnit) then healerUnit = nil end
	local markTank = tankUnit and TankHelper:NeedsRoleMark("TANK", tankUnit, tankIcon)
	local markHealer = healerUnit and TankHelper:NeedsRoleMark("HEALER", healerUnit, healerIcon)
	local macro = ""
	THMarkTankAndHealer.pending = {}
	if markTank then
		macro = "/tm [@" .. tankUnit .. "] !" .. tankIcon
		THMarkTankAndHealer.pending["TANK"] = tankUnit .. ":" .. tankIcon
	end

	if markHealer then
		if macro ~= "" then macro = macro .. "\n" end
		macro = macro .. "/tm [@" .. healerUnit .. "] !" .. healerIcon
		THMarkTankAndHealer.pending["HEALER"] = healerUnit .. ":" .. healerIcon
	end

	if macro == "" then
		THMarkTankAndHealer:Hide()
	else
		if markTank and markHealer then
			THMarkTankAndHealer:SetText(TankHelper:Trans("LID_marktankandhealer", TankHelper:GetLang(), TankHelper:GetRaidIconText(tankIcon), TankHelper:GetRaidIconText(healerIcon)))
		elseif markTank then
			THMarkTankAndHealer:SetText(TankHelper:Trans("LID_marktank", TankHelper:GetLang(), TankHelper:GetRaidIconText(tankIcon)))
		else
			THMarkTankAndHealer:SetText(TankHelper:Trans("LID_markhealer", TankHelper:GetLang(), TankHelper:GetRaidIconText(healerIcon)))
		end
		THMarkTankAndHealer:SetWidth(math.max(220, THMarkTankAndHealer:GetTextWidth() + 40))
		THMarkTankAndHealer:SetAttribute("macrotext", macro)
		THMarkTankAndHealer:Show()
	end
end

function TankHelper:RW(msg)
	local SendChatMessage = getglobal("SendChatMessage")
	if IsInRaid() and (UnitIsGroupAssistant("PLAYER") or UnitIsGroupLeader("PLAYER")) then
		SendChatMessage(msg, "RAID_WARNING")
	elseif not InCombatLockdown() then
		if TankHelper:ShouldShow() then
			if IsInRaid() then
				SendChatMessage(msg, "RAID")
			else
				SendChatMessage(msg, "PARTY")
			end
		else
			TankHelper:MSG(TankHelper:Trans("LID_youmustbeinagrouporaraid", true) .. "!")
		end
	end
end

function TankHelper:PullIn(t)
	if TankHelper:ShouldShow() then
		if TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "AUTO" or TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "ONLYTHIRDPARTY" or TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "BOTH" then
			if SlashCmdList["DEADLYBOSSMODS"] then
				SlashCmdList["DEADLYBOSSMODS"]("pull " .. t)
			elseif TankHelper:IsAddOnLoaded("BigWigs") then
				DEFAULT_CHAT_FRAME.editBox:SetText("/pull " .. t)
				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
			else
				if C_PartyInfo and C_PartyInfo.DoCountdown then C_PartyInfo.DoCountdown(t) end
			end
		else
			if C_PartyInfo and C_PartyInfo.DoCountdown then C_PartyInfo.DoCountdown(t) end
		end

		if TankHelper:GetWoWBuild() ~= "RETAIL" and ((TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "AUTO" and (not TankHelper:IsAddOnLoaded("DBM-Core") and not TankHelper:IsAddOnLoaded("BigWigs"))) or TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "ONLYTH" or TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "BOTH" or TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "ONLYTHIRDPARTY" and not TankHelper:IsAddOnLoaded("DBM-Core") and not TankHelper:IsAddOnLoaded("BigWigs")) then
			if TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "ONLYTHIRDPARTY" and not TankHelper:IsAddOnLoaded("DBM-Core") and not TankHelper:IsAddOnLoaded("BigWigs") then TankHelper:MSG("Found no Thirdparty countdown addon" .. "!" .. " Using Default timer.") end
			TankHelper:RW(format(TankHelper:Trans("LID_pullinx", TankHelper:GetLang()), t))
			for cou = 1, t do
				TankHelper:After(cou, function()
					local leftT = t - cou
					if leftT == 0 then
						TankHelper:RW(TankHelper:Trans("LID_go", TankHelper:GetLang()) .. "!")
					else
						TankHelper:RW(leftT)
					end
				end, "PULLIN")
			end
		end
	else
		TankHelper:MSG(TankHelper:Trans("LID_youmustbeinagrouporaraid", TankHelper:GetLang()) .. "!")
	end
end

function TankHelper:ResetIcons1()
	for btnId, v in pairs(ricons1) do
		v.bgtexture:SetTexture("")
	end
end

function TankHelper:UpdateAutoSelectHighlight()
	TankHelper:ResetIcons1()
	local btn = THTargetMarkers["btnM" .. TankHelper:GetConfig("autoselect", 8)]
	if btn and btn.bgtexture then btn.bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert") end
end

function TankHelper:UpdateRaidIcons()
	for rmId = 0, 8 do
		if THTargetMarkers["btnM" .. rmId] then
			local rembtn = THTargetMarkers["btnM" .. rmId].texture
			if rmId == 0 then
				if not GetRaidTargetIndex("TARGET") or GetRaidTargetIndex("TARGET") == 0 then
					rembtn:SetDesaturated(true)
				else
					rembtn:SetDesaturated(false)
				end
			else
				if not UnitExists("TARGET") then
					rembtn:SetDesaturated(true)
				else
					rembtn:SetDesaturated(false)
				end
			end
		end
	end
end

function TankHelper:CheckUnit(unit, dead, health, power)
	if UnitExists(unit) then
		local can = true
		if TankHelper:GetConfig("statusonlyhealers", true) and UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then
			local role = UnitGroupRolesAssigned(unit)
			if role ~= "HEALER" then can = false end
		end

		if can then
			local hpercent = UnitHealth(unit) / UnitHealthMax(unit)
			if hpercent < health then health = hpercent end
			local powertype = UnitPowerType(unit)
			if powertype == 0 and UnitPower(unit) > 0 and UnitPowerMax(unit) > 0 then
				local ppercent = UnitPower(unit) / UnitPowerMax(unit)
				if ppercent < power then power = ppercent end
			end
		end

		if UnitIsDead(unit) then dead = true end
	end
	return dead, health, power
end

function TankHelper:InitFrame(frame, px, py)
	frame:SetPoint("Center", UIParent, "Center", px, py)
	frame:SetSize(cols * iconbtn + (cols - 1) * ibr + 2 * obr, rows * iconbtn + (rows - 1) * cbr + 2 * obr)
	TankHelper:SetClampedToScreen(frame, true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(sel)
		if not TankHelper:GetConfig("fixposition", false) then
			if InCombatLockdown() then return end
			sel:StartMoving()
		else
			TankHelper:MSG(TankHelper:Trans("LID_fixedpositionisenabled", TankHelper:GetLang()) .. "!")
		end
	end)

	frame:SetScript("OnDragStop", function(sel)
		if not TankHelper:GetConfig("fixposition", false) then
			if InCombatLockdown() then return end
			local name = TankHelper:GetName(frame)
			frame:StopMovingOrSizing()
			local point, _, relativePoint, ofsx, ofsy = sel:GetPoint()
			THTAB[name .. "point"] = point
			THTAB[name .. "parent"] = nil
			THTAB[name .. "relativePoint"] = relativePoint
			THTAB[name .. "ofsx"] = ofsx
			THTAB[name .. "ofsy"] = ofsy
		else
			TankHelper:MSG(TankHelper:Trans("LID_fixedpositionisenabled", TankHelper:GetLang()) .. "!")
		end
	end)

	frame.tBRl = frame:CreateTexture(nil, "BACKGROUND")
	frame.tBRr = frame:CreateTexture(nil, "BACKGROUND")
	frame.tBRt = frame:CreateTexture(nil, "BACKGROUND")
	frame.tBRb = frame:CreateTexture(nil, "BACKGROUND")
	frame.tBG = frame:CreateTexture(nil, "BACKGROUND")
	TankHelper:UpdateColors(frame)
end

function TankHelper:ShowCombinedAll()
	THCockpit:Show()
	if IsRaidMarkerActive and TankHelper:GetConfig("hideworldmarks", false) == false then
		THWorldMarkers:Show()
	else
		THWorldMarkers:Hide()
	end

	if TankHelper:GetConfig("hidetargetmarks", false) == false then
		THTargetMarkers:Show()
	else
		THTargetMarkers:Hide()
	end

	if TankHelper:GetConfig("hidespecialbar", false) == false then
		THExtras:Show()
	else
		THExtras:Hide()
	end

	THCockpit:EnableMouse(true)
	THWorldMarkers:EnableMouse(false)
	THTargetMarkers:EnableMouse(false)
	THExtras:EnableMouse(false)
end

function TankHelper:HideCombinedAll()
	THCockpit:Hide()
	THWorldMarkers:Hide()

	THTargetMarkers:Hide()
	THExtras:Hide()
	THCockpit:EnableMouse(true)
	THWorldMarkers:EnableMouse(false)
	THTargetMarkers:EnableMouse(false)
	THExtras:EnableMouse(false)
end

function TankHelper:InitFrames()
	if TankHelper:GetWoWBuild() ~= "CLASSIC" then
		WMN = 8
		wms = {5, 6, 3, 2, 7, 1, 4, 8}
		WMIds = {
			[1] = 1,
			[2] = 2,
			[3] = 3,
			[4] = 4,
			[5] = 5,
			[6] = 6,
			[7] = 7,
			[8] = 8,
		}
	else
		WMN = 5
		wms = {5, 3, 2, 1, 4}
		WMIds = {
			[1] = 1,
			[2] = 3,
			[3] = 4,
			[4] = 6,
			[5] = 7,
		}
	end

	THCockpit = CreateFrame("Frame", "THCockpit", UIParent)
	THWorldMarkers = CreateFrame("Frame", "THWorldMarkers", UIParent)
	THTargetMarkers = CreateFrame("Frame", "THTargetMarkers", UIParent)
	THExtras = CreateFrame("Frame", "THExtras", UIParent)
	THStatus = CreateFrame("Frame", "THStatus", UIParent)
	local markerHolder = CreateFrame("Frame", "THMarkTankAndHealerHolder", UIParent)
	markerHolder:SetAllPoints(UIParent)
	markerHolder:SetFrameStrata("DIALOG")
	RegisterStateDriver(markerHolder, "visibility", "[combat] hide; show")
	local menuButtonTemplate = TankHelper:CheckTemplates("MainMenuFrameButtonTemplate") and "MainMenuFrameButtonTemplate" or "GameMenuButtonTemplate"
	THMarkTankAndHealer = CreateFrame("Button", "THMarkTankAndHealer", markerHolder, "SecureActionButtonTemplate," .. menuButtonTemplate)
	THMarkTankAndHealer:SetWidth(220)
	if THTAB["THMarkTankAndHealer" .. "point"] then
		THMarkTankAndHealer:SetPoint(THTAB["THMarkTankAndHealer" .. "point"], UIParent, THTAB["THMarkTankAndHealer" .. "relativePoint"], THTAB["THMarkTankAndHealer" .. "ofsx"], THTAB["THMarkTankAndHealer" .. "ofsy"])
	else
		THMarkTankAndHealer:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end

	THMarkTankAndHealer:SetFrameStrata("DIALOG")
	TankHelper:SetClampedToScreen(THMarkTankAndHealer, true)
	THMarkTankAndHealer:SetMovable(true)
	THMarkTankAndHealer:RegisterForDrag("RightButton")
	THMarkTankAndHealer:SetScript("OnDragStart", function(sel)
		if InCombatLockdown() then return end
		sel:StartMoving()
	end)

	THMarkTankAndHealer:SetScript("OnDragStop", function(sel)
		if InCombatLockdown() then return end
		sel:StopMovingOrSizing()
		local point, _, relativePoint, ofsx, ofsy = sel:GetPoint()
		THTAB["THMarkTankAndHealer" .. "point"] = point
		THTAB["THMarkTankAndHealer" .. "relativePoint"] = relativePoint
		THTAB["THMarkTankAndHealer" .. "ofsx"] = ofsx
		THTAB["THMarkTankAndHealer" .. "ofsy"] = ofsy
		sel:ClearAllPoints()
		sel:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
	end)

	C_Timer.NewTicker(1, function() TankHelper:UpdateTankHealerMarkerButton() end)
	THMarkTankAndHealer:RegisterForClicks("LeftButtonDown")
	THMarkTankAndHealer:SetAttribute("type", "macro")
	THMarkTankAndHealer:SetAttribute("pressAndHoldAction", "1")
	THMarkTankAndHealer:HookScript("OnClick", function(sel)
		TankHelper.ownMarkTime = GetTime()
		for role, key in pairs(sel.pending or {}) do
			TankHelper.roleMarkConfirmed[role] = key
		end
	end)

	THMarkTankAndHealer:Hide()
	THTabMarker = CreateFrame("Button", "THTabMarker", UIParent, "SecureActionButtonTemplate")
	THTabMarker:RegisterForClicks("LeftButtonDown")
	THTabMarker:SetAttribute("type", "macro")
	THTabMarker:SetAttribute("pressAndHoldAction", "1")
	THTabMarker:HookScript("OnClick", function()
		TankHelper.ownMarkTime = GetTime()
	end)
	TankHelper:InitFrame(THCockpit, 0, 0)
	TankHelper:InitFrame(THWorldMarkers, 0, 0)
	TankHelper:InitFrame(THTargetMarkers, 0, -40)
	TankHelper:InitFrame(THExtras, 0, -80)
	local Y = 1
	for btnId = 0, 8 do
		THTargetMarkers["btnM" .. btnId] = TankHelper:CreateInvisibleButton("btnM" .. btnId, THTargetMarkers)
		THTargetMarkers["btnM" .. btnId]:SetPoint("TOPLEFT", THTargetMarkers, "TOPLEFT", obr + (btnId - 1) * (iconbtn + ibr), -obr)
		THTargetMarkers["btnM" .. btnId]:SetSize(iconbtn, iconbtn)
		THTargetMarkers["btnM" .. btnId].bgtexture = THTargetMarkers["btnM" .. btnId]:CreateTexture(nil, "OVERLAY")
		THTargetMarkers["btnM" .. btnId].bgtexture:SetTexture("")
		THTargetMarkers["btnM" .. btnId].bgtexture:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
		THTargetMarkers["btnM" .. btnId].bgtexture:SetPoint("CENTER", THTargetMarkers["btnM" .. btnId], "CENTER", 0, 0)
		THTargetMarkers["btnM" .. btnId].bgtexture:SetVertexColor(1, 1, 0, THBORDERALPHA)
		THTargetMarkers["btnM" .. btnId].texture = THTargetMarkers["btnM" .. btnId]:CreateTexture(nil, "ARTWORK")
		if btnId > 0 then
			THTargetMarkers["btnM" .. btnId].texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. btnId)
		else
			THTargetMarkers["btnM" .. btnId].texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		end

		THTargetMarkers["btnM" .. btnId].bgtexture:SetSize(iconsize * markScale, iconbtn * markScale)
		THTargetMarkers["btnM" .. btnId].texture:SetSize(iconsize, iconsize)
		THTargetMarkers["btnM" .. btnId].texture:SetPoint("CENTER", THTargetMarkers["btnM" .. btnId], "CENTER", 0, 0)
		THTargetMarkers["btnM" .. btnId]:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		THTargetMarkers["btnM" .. btnId]:SetAttribute("type", "macro")
		THTargetMarkers["btnM" .. btnId]:SetAttribute("typerelease", "macro")
		THTargetMarkers["btnM" .. btnId]:SetAttribute("macrotext", "/tm " .. btnId)
		THTargetMarkers["btnM" .. btnId]:SetAttribute("pressAndHoldAction", "1")
		THTargetMarkers["btnM" .. btnId]:HookScript("OnClick", function(sel, btn, down)
			if btn == "LeftButton" then
				if UnitCanAttack("PLAYER", "TARGET") then TankHelper.ownMarkTime = GetTime() end
				pcall(function() TankHelper:UpdateRaidIcons() end)
			elseif btn == "RightButton" and btnId > 0 then
				if TankHelper:GetConfig("autoselect", 8) ~= btnId then
					THTAB["autoselect"] = btnId
				else
					THTAB["autoselect"] = -1
				end

				TankHelper:UpdateAutoSelectHighlight()
				TankHelper:UpdateTabMarker()
			end
		end)

		table.insert(ricons1, THTargetMarkers["btnM" .. btnId])
		if IsRaidMarkerActive and btnId <= WMN then
			THWorldMarkers["THBtnRM" .. btnId] = CreateFrame("Button", "THBtnRM" .. btnId, THWorldMarkers, "SecureActionButtonTemplate")
			THWorldMarkers["THBtnRM" .. btnId]:SetPoint("TOPLEFT", THWorldMarkers, "TOPLEFT", obr + (btnId - 1) * (iconbtn + ibr), -obr)
			THWorldMarkers["THBtnRM" .. btnId]:SetSize(iconbtn, iconbtn)
			THWorldMarkers["THBtnRM" .. btnId].texture = THWorldMarkers["THBtnRM" .. btnId]:CreateTexture(nil, "ARTWORK")
			THWorldMarkers["THBtnRM" .. btnId].texture:SetTexture("Interface\\RaidFrame\\Raid-WorldPing")
			THWorldMarkers["THBtnRM" .. btnId].texture:SetSize(iconsize, iconsize)
			THWorldMarkers["THBtnRM" .. btnId].texture:SetPoint("CENTER", THWorldMarkers["THBtnRM" .. btnId], "CENTER", 0, 0)
			THWorldMarkers["THBtnRM" .. btnId].texture:SetDrawLayer("ARTWORK", 1)
			THWorldMarkers["THBtnRM" .. btnId].tBG = THWorldMarkers["THBtnRM" .. btnId]:CreateTexture(nil, "ARTWORK")
			if btnId > 0 then
				THWorldMarkers["THBtnRM" .. btnId].tBG:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. WMIds[btnId])
			else
				THWorldMarkers["THBtnRM" .. btnId].tBG:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			end

			THWorldMarkers["THBtnRM" .. btnId].tBG:SetSize(iconsize / 1.2, iconsize / 1.2)
			THWorldMarkers["THBtnRM" .. btnId].tBG:SetPoint("BOTTOMLEFT", THWorldMarkers["THBtnRM" .. btnId], "BOTTOMLEFT", 0, 0)
			THWorldMarkers["THBtnRM" .. btnId].tBG:SetDrawLayer("ARTWORK", 2)
			THWorldMarkers["THBtnRM" .. btnId].tBG:SetVertexColor(1, 1, 1, 1)
			if THWorldMarkers["THBtnRM" .. btnId].SetMouseClickEnabled then THWorldMarkers["THBtnRM" .. btnId]:SetMouseClickEnabled(true) end
			THWorldMarkers["THBtnRM" .. btnId]:SetAttribute("type1", "worldmarker")
			THWorldMarkers["THBtnRM" .. btnId]:SetAttribute("type2", "worldmarker")
			THWorldMarkers["THBtnRM" .. btnId]:SetAttribute("marker1", wms[btnId])
			THWorldMarkers["THBtnRM" .. btnId]:SetAttribute("marker2", wms[btnId])
			if btnId == 0 then
				THWorldMarkers["THBtnRM" .. btnId]:SetAttribute("action1", "clear")
				THWorldMarkers["THBtnRM" .. btnId]:SetAttribute("action2", "clear")
			else
				THWorldMarkers["THBtnRM" .. btnId]:SetAttribute("action1", "set")
				THWorldMarkers["THBtnRM" .. btnId]:SetAttribute("action2", "clear")
			end

			THWorldMarkers["THBtnRM" .. btnId]:RegisterForClicks("AnyUp", "AnyDown")
			local btn = THWorldMarkers["THBtnRM" .. btnId]
			function btn:updateMarker()
				local btn1 = THWorldMarkers["THBtnRM" .. btnId].texture
				local btn2 = THWorldMarkers["THBtnRM" .. btnId].tBG
				if btnId > 0 then
					local active = IsRaidMarkerActive and IsRaidMarkerActive(wms[btnId])
					if TankHelper:IsSecret(active) then
						THWorldMarkers["THBtnRM" .. btnId].status = nil
						updatewms = true
						local desaturation = C_CurveUtil.EvaluateColorValueFromBoolean(active, 0, 1)
						local alpha = C_CurveUtil.EvaluateColorValueFromBoolean(active, 1, 0.5)
						btn1:SetDesaturation(desaturation)
						btn2:SetDesaturation(desaturation)
						btn1:SetAlpha(alpha)
						btn2:SetAlpha(alpha)
					elseif IsRaidMarkerActive and THWorldMarkers["THBtnRM" .. btnId].status ~= active then
						THWorldMarkers["THBtnRM" .. btnId].status = active
						updatewms = true
						if THWorldMarkers["THBtnRM" .. btnId].status == false then
							btn1:SetDesaturated(true)
							btn2:SetDesaturated(true)
							btn1:SetAlpha(0.5)
							btn2:SetAlpha(0.5)
						else
							btn1:SetDesaturated(false)
							btn2:SetDesaturated(false)
							btn1:SetAlpha(1)
							btn2:SetAlpha(1)
						end
					end
				elseif updatewms then
					updatewms = false
					local canremove = false
					for rmId = 1, WMN do
						local active = IsRaidMarkerActive and IsRaidMarkerActive(wms[rmId])
						if TankHelper:IsSecret(active) or active then
							canremove = true
							break
						end
					end

					if canremove == false then
						btn1:SetDesaturated(true)
						btn2:SetDesaturated(true)
						btn1:SetAlpha(0.5)
						btn2:SetAlpha(0.5)
					else
						btn1:SetDesaturated(false)
						btn2:SetDesaturated(false)
						btn1:SetAlpha(1)
						btn2:SetAlpha(1)
					end
				end
			end

			btn:RegisterEvent("RAID_TARGET_UPDATE")
			btn:RegisterEvent("GROUP_ROSTER_UPDATE")
			btn:RegisterEvent("PLAYER_ENTERING_WORLD")
			btn:SetScript("OnEvent", function(_, event) btn:updateMarker() end)
			btn:updateMarker()
			table.insert(ricons2, THWorldMarkers["THBtnRM" .. btnId])
			Y = Y + 1
		else
			THWorldMarkers:Hide()
		end

		if btnId >= 1 and btnId <= #pt then
			local PullName = "btnPull" .. btnId
			THExtras[PullName] = TankHelper:CreateInvisibleButton(PullName, THExtras)
			THExtras[PullName]:SetPoint("TOPLEFT", THExtras, "TOPLEFT", obr + (btnId - 1) * (iconbtn + ibr), -obr)
			THExtras[PullName]:SetSize(iconbtn, iconbtn)
			THExtras[PullName]:SetText(pt[btnId])
			THExtras[PullName]:SetScript("OnClick", function(sel, btn, down) TankHelper:PullIn(pt[btnId]) end)
		end
	end

	THExtras["btnReadycheck"] = TankHelper:CreateInvisibleButton("btnReadycheck", THExtras)
	THExtras["btnReadycheck"]:SetSize(iconbtn, iconbtn)

	THExtras["btnReadycheck"]:SetScript("OnClick", function(sel, btn, down) DoReadyCheck() end)
	if InitiateRolePoll then
		THExtras["btnRolepoll"] = TankHelper:CreateInvisibleButton("btnRolepoll", THExtras)
		THExtras["btnRolepoll"]:SetSize(iconbtn, iconbtn)
		THExtras["btnRolepoll"]:SetText(string.sub(ROLE_POLL, 1, 6))
		THExtras["btnRolepoll"]:SetScript("OnClick", function(sel, btn, down) InitiateRolePoll() end)
	end

	TankHelper:UpdateRaidManagerIcons()
	TankHelper:UpdateRaidManager()
	THExtras["btnDiscord"] = TankHelper:CreateInvisibleButton("btnDiscord", THExtras)
	THExtras["btnDiscord"]:SetPoint("TOPLEFT", THExtras, "TOPLEFT", obr + 100 + ibr + 100 + ibr, -obr - Y * (iconbtn + cbr))
	THExtras["btnDiscord"]:SetSize(iconbtn, iconbtn)
	THExtras["btnDiscord"]:SetText("D")
	THExtras["btnDiscord"]:SetScript("OnClick", function(sel, btn, down)
		if TankHelper.discordWindow then
			TankHelper.discordWindow:SetShown(not TankHelper.discordWindow:IsShown())
			return
		end

		local s = CreateFrame("Frame", "TankHelperDiscordWindow", UIParent)
		TankHelper.discordWindow = s
		s:SetSize(300, 2 * iconbtn + 2 * 10)
		s:SetPoint("CENTER")
		s.texture = s:CreateTexture(nil, "BACKGROUND")
		s.texture:SetColorTexture(0, 0, 0, 0.5)
		s.texture:SetAllPoints(s)
		s.text = s:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		s.text:SetText("Feedback")
		s.text:SetPoint("CENTER", s, "TOP", 0, -10)
		local eb = CreateFrame("EditBox", "TankHelperDiscordEditBox", s, "InputBoxTemplate")
		eb:SetFrameStrata("DIALOG")
		eb:SetSize(280, iconbtn)
		eb:SetAutoFocus(false)
		eb:SetText("https://discord.gg/Ymv5MamPd5")
		eb:SetPoint("TOPLEFT", 10, -10 - iconbtn)
		s.close = TankHelper:CreateButton("TankHelperDiscordClose", s)
		s.close:SetFrameStrata("DIALOG")
		s.close:SetPoint("TOPLEFT", 300 - 10 - iconbtn, -10)
		s.close:SetSize(iconbtn, iconbtn)
		s.close:SetText("X")
		s.close:SetScript("OnClick", function(se, sbtn, sdown) s:Hide() end)
	end)

	THCockpit:RegisterEvent("PLAYER_ENTERING_WORLD")
	THCockpit:RegisterEvent("PLAYER_TARGET_CHANGED")
	THCockpit:RegisterEvent("RAID_TARGET_UPDATE")
	THCockpit:RegisterEvent("UNIT_HEALTH")
	THCockpit:RegisterEvent("UNIT_POWER_UPDATE")
	THCockpit:RegisterEvent("GROUP_ROSTER_UPDATE")
	THCockpit:RegisterEvent("RAID_ROSTER_UPDATE")
	THCockpit:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	THCockpit:RegisterEvent("ROLE_CHANGED_INFORM")
	THCockpit:RegisterEvent("PLAYER_REGEN_ENABLED")
	THCockpit:RegisterEvent("PLAYER_DEAD")
	THCockpit:RegisterEvent("PLAYER_ALIVE")
	THCockpit:RegisterEvent("PLAYER_UNGHOST")
	THCockpit:RegisterEvent("ADDON_LOADED")
	THCockpit:RegisterEvent("UPDATE_BINDINGS")
	THCockpit:HookScript("OnEvent", function(sel, e, ...)
		if (e == "PLAYER_ENTERING_WORLD" or e == "GROUP_ROSTER_UPDATE" or e == "RAID_ROSTER_UPDATE" or e == "PLAYER_REGEN_ENABLED") and TankHelper.DesignThink then TankHelper:DesignThink() end
		if e == "PLAYER_ENTERING_WORLD" or e == "ADDON_LOADED" or e == "GROUP_ROSTER_UPDATE" or e == "PLAYER_REGEN_ENABLED" then TankHelper:UpdateRaidManager() end
		if e == "PLAYER_ENTERING_WORLD" or e == "ADDON_LOADED" then TankHelper:UpdateRaidManagerIcons() end
		if e == "PLAYER_ENTERING_WORLD" or e == "GROUP_ROSTER_UPDATE" or e == "RAID_ROSTER_UPDATE" or e == "PLAYER_ROLES_ASSIGNED" or e == "ROLE_CHANGED_INFORM" or e == "PLAYER_REGEN_ENABLED" or e == "UPDATE_BINDINGS" then TankHelper:UpdateTabMarker() end
		if e == "PLAYER_ENTERING_WORLD" then TankHelper:UpdateAutoSelectHighlight() end

		if e == "PLAYER_TARGET_CHANGED" and TankHelper:GetWoWBuild() ~= "RETAIL" then
			targetRevision = targetRevision + 1
			local revision = targetRevision
			TankHelper:After(TankHelper:GetConfig("targettingdelay", 0.0), function() if revision == targetRevision then TankHelper:TargetIconLogic() end end, "Targetting Delay")
		end

		if e == "UNIT_HEALTH" or e == "UNIT_POWER_UPDATE" or e == "GROUP_ROSTER_UPDATE" or e == "RAID_ROSTER_UPDATE" then TankHelper:SetStatusText() end
		if e == "RAID_TARGET_UPDATE" then TankHelper:OnRaidTargetUpdate() end
		if e == "PLAYER_ENTERING_WORLD" or e == "GROUP_ROSTER_UPDATE" or e == "RAID_ROSTER_UPDATE" or e == "PLAYER_ROLES_ASSIGNED" or e == "ROLE_CHANGED_INFORM" or e == "RAID_TARGET_UPDATE" or e == "PLAYER_REGEN_ENABLED" or e == "PLAYER_DEAD" or e == "PLAYER_ALIVE" or e == "PLAYER_UNGHOST" then TankHelper:UpdateTankHealerMarkerButton() end
	end)

	THStatus:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	THStatus:SetSize(THCockpit:GetWidth(), 1 * iconbtn + 4 * obr)
	TankHelper:SetClampedToScreen(THStatus, true)
	THStatus:SetMovable(true)
	THStatus:EnableMouse(true)
	THStatus:RegisterForDrag("LeftButton")
	THStatus:SetScript("OnDragStart", function(sel)
		if not TankHelper:GetConfig("fixposition", false) then
			THStatus:StartMoving()
		else
			TankHelper:MSG(TankHelper:Trans("LID_fixedpositionisenabled", TankHelper:GetLang()) .. "!")
		end
	end)

	THStatus:SetScript("OnDragStop", function(sel)
		if not TankHelper:GetConfig("fixposition", false) then
			THStatus:StopMovingOrSizing()
			local point, _, relativePoint, ofsx, ofsy = sel:GetPoint()
			THTAB["THStatus" .. "point"] = point
			THTAB["THStatus" .. "parent"] = nil
			THTAB["THStatus" .. "relativePoint"] = relativePoint
			THTAB["THStatus" .. "ofsx"] = ofsx
			THTAB["THStatus" .. "ofsy"] = ofsy
		else
			TankHelper:MSG(TankHelper:Trans("LID_fixedpositionisenabled", TankHelper:GetLang()) .. "!")
		end
	end)

	THStatus.texture = THStatus:CreateTexture(nil, "BACKGROUND")
	THStatus.texture:SetAllPoints(THStatus)
	THStatus.text = THStatus:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	THStatus.text:SetText("")
	THStatus.text:SetPoint("CENTER", THStatus, "CENTER", 0, 0)
	THStatus:Hide()
	function TankHelper:DesignThink()
		THStatus:SetMovable(not TankHelper:GetConfig("fixposition", false))
		THStatus:EnableMouse(not TankHelper:GetConfig("fixposition", false))
		if TankHelper:GetConfig("hidestatus", true) then
			THStatus:Hide()
		else
			if TankHelper:ShouldShow() then
				THStatus:Show()
			else
				THStatus:Hide()
			end
		end

		if not InCombatLockdown() then
			THCockpit:SetMovable(not TankHelper:GetConfig("fixposition", false))
			THCockpit:EnableMouse(not TankHelper:GetConfig("fixposition", false))
			if TankHelper:GetConfig("combineall", false) then
				if TankHelper:GetConfig("showalways", false) then
					TankHelper:ShowCombinedAll()
				else
					if TankHelper:ShouldShow() then
						TankHelper:ShowCombinedAll()
					else
						TankHelper:HideCombinedAll()
					end
				end
			else
				if TankHelper:GetConfig("showalways", false) then
					if IsRaidMarkerActive and TankHelper:GetConfig("hideworldmarks", false) == false then
						THWorldMarkers:Show()
					else
						THWorldMarkers:Hide()
					end

					if TankHelper:GetConfig("hidetargetmarks", false) == false then
						THTargetMarkers:Show()
					else
						THTargetMarkers:Hide()
					end

					if TankHelper:GetConfig("hidespecialbar", false) == false then
						THExtras:Show()
					else
						THExtras:Hide()
					end
				else
					if TankHelper:ShouldShow() then
						if IsRaidMarkerActive and TankHelper:GetConfig("hideworldmarks", false) == false then
							THWorldMarkers:Show()
						else
							THWorldMarkers:Hide()
						end

						if TankHelper:GetConfig("hidetargetmarks", false) == false then
							THTargetMarkers:Show()
						else
							THTargetMarkers:Hide()
						end

						if TankHelper:GetConfig("hidespecialbar", false) == false then
							THExtras:Show()
						else
							THExtras:Hide()
						end
					else
						THWorldMarkers:Hide()
						THTargetMarkers:Hide()
						THExtras:Hide()
					end
				end

				THCockpit:Hide()
				THWorldMarkers:EnableMouse(true)
				THTargetMarkers:EnableMouse(true)
				THExtras:EnableMouse(true)
			end
		end
	end
end

function TankHelper:TargetIconLogic()
	if TankHelper:GetWoWBuild() == "RETAIL" then return false end
	if UnitGroupRolesAssigned and (TankHelper:GetWoWBuildNr() > 19999 or TankHelper:IsForever()) then
		local role = UnitGroupRolesAssigned("PLAYER")
		if TankHelper:GetConfig("onlytank", false) and (role == "HEALER" or role == "DAMAGER") then return false end
	end

	if TankHelper:GetConfig("autoselect", 8) == -1 then return false end
	if not UnitExists("TARGET") then return false end
	if not UnitCanAttack("TARGET", "PLAYER") then return false end
	if GetRaidTargetIndex("TARGET") ~= nil then return false end
	if IsInRaid() and (UnitIsGroupAssistant("PLAYER") or UnitIsGroupLeader("PLAYER")) then
		SetRaidTarget("TARGET", TankHelper:GetConfig("autoselect", 8))
	elseif not IsInRaid() then
		SetRaidTarget("TARGET", TankHelper:GetConfig("autoselect", 8))
	end
	return true
end

function TankHelper:CanTabMark()
	if TankHelper:GetWoWBuild() ~= "RETAIL" then return false end
	local icon = TankHelper:GetConfig("autoselect", 8)
	if icon == -1 then return false end
	if UnitGroupRolesAssigned and TankHelper:GetConfig("onlytank", false) then
		local role = UnitGroupRolesAssigned("PLAYER")
		if role == "HEALER" or role == "DAMAGER" then return false end
	end

	if IsInRaid() and not UnitIsGroupAssistant("PLAYER") and not UnitIsGroupLeader("PLAYER") then return false end
	return true
end

function TankHelper:UpdateTabMarker()
	if THTabMarker == nil then return end
	if InCombatLockdown() then return end
	local keys = {}
	if TankHelper:CanTabMark() then
		for _, key in pairs({GetBindingKey("TARGETNEARESTENEMY")}) do
			if key and key ~= "" then table.insert(keys, key) end
		end
	end

	local macro = "/targetenemy\n/tm [harm,nodead] ~" .. TankHelper:GetConfig("autoselect", 8)
	local state = table.concat(keys, ",") .. "|" .. macro
	if THTabMarker.state == state then return end
	THTabMarker.state = state
	ClearOverrideBindings(THTabMarker)
	if #keys == 0 then
		THTabMarker:SetAttribute("macrotext", nil)
		return
	end

	THTabMarker:SetAttribute("macrotext", macro)
	for _, key in ipairs(keys) do
		SetOverrideBindingClick(THTabMarker, false, key, "THTabMarker", "LeftButton")
	end
end

function TankHelper:SetStatusText()
	if THCockpit == nil or THStatus == nil then return end
	if not TankHelper:GetConfig("hidestatus", true) then
		local text = TankHelper:Trans("LID_ready", TankHelper:GetLang()) .. "!"
		THStatusColor = {0, 1, 0, 0.5}
		if InCombatLockdown() then
			text = GARRISON_LANDING_STATUS_MISSION_COMBAT .. "!"
			THStatusColor = {1, 0, 0, 0.75}
		else
			local health = 1
			local power = 1
			local dead = false
			dead, health, power = TankHelper:CheckUnit("PLAYER", dead, health, power)
			for id = 1, 4 do
				dead, health, power = TankHelper:CheckUnit("PARTY" .. id, dead, health, power)
			end

			for id = 1, 40 do
				dead, health, power = TankHelper:CheckUnit("RAID" .. id, dead, health, power)
			end

			if dead then
				text = TankHelper:Trans("LID_playerdead", TankHelper:GetLang()) .. "!"
				THStatusColor = {0, 0, 0, 1}
			elseif health < 0.3 then
				text = TankHelper:Trans("LID_playerlowhp", TankHelper:GetLang()) .. "!"
				THStatusColor = {1, 0, 0, 1 - health + 0.1}
			elseif health < TankHelper:GetConfig("healthmax", 0.9) then
				text = TankHelper:Trans("LID_playernotfull", TankHelper:GetLang()) .. "!"
				THStatusColor = {1, 0, 0, 1 - health + 0.1}
			elseif power < TankHelper:GetConfig("powermax", 0.9) then
				text = TankHelper:Trans("LID_playerhavenotenoughpower", TankHelper:GetLang()) .. "!"
				THStatusColor = {0, 0, 1, 1 - power + 0.1}
			end
		end

		if TankHelper:GetConfig("statusonlyhealers", true) and UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then text = format("%s: %s", TankHelper:Trans("LID_healer", TankHelper:GetLang()), text) end
		THStatus.text:SetText(text)
		if THStatus.texture.SetColorTexture and THStatusColor[1] and THStatusColor[2] and THStatusColor[3] then
			if THStatusColor[4] > 1 then THStatusColor[4] = 1 end
			if THStatusColor[4] < 0 then THStatusColor[4] = 0 end
			THStatus.texture:SetColorTexture(THStatusColor[1], THStatusColor[2], THStatusColor[3], THStatusColor[4])
		end
	end
end

function TankHelper:ToggleTextures(frame, show)
	if show then
		frame.tBG:Show()
		frame.tBRl:Show()
		frame.tBRr:Show()
		frame.tBRt:Show()
		frame.tBRb:Show()
	else
		frame.tBG:Hide()
		frame.tBRl:Hide()
		frame.tBRr:Hide()
		frame.tBRt:Hide()
		frame.tBRb:Hide()
	end
end

function TankHelper:UpdateFrameDesign(frame)
	local sw, sh = frame:GetSize()
	frame.tBG:SetSize(sw - 2 * obr, sh - 2 * obr)
	frame.tBG:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.tBRl:SetSize(obr, sh - 2 * obr)
	frame.tBRr:SetSize(obr, sh - 2 * obr)
	frame.tBRt:SetSize(sw, obr)
	frame.tBRb:SetSize(sw, obr)
	frame.tBRl:SetPoint("LEFT", frame, "LEFT", 0, 0)
	frame.tBRr:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	frame.tBRt:SetPoint("TOP", frame, "TOP", 0, 0)
	frame.tBRb:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)
	if TankHelper:GetConfig("combineall", false) then
		if frame == THCockpit then
			TankHelper:ToggleTextures(THCockpit, true)
		else
			TankHelper:ToggleTextures(THWorldMarkers, false)
			TankHelper:ToggleTextures(THTargetMarkers, false)
			TankHelper:ToggleTextures(THExtras, false)
		end
	else
		if frame == THCockpit then
			TankHelper:ToggleTextures(THCockpit, false)
		else
			TankHelper:ToggleTextures(THWorldMarkers, true)
			TankHelper:ToggleTextures(THTargetMarkers, true)
			TankHelper:ToggleTextures(THExtras, true)
		end
	end
end

function TankHelper:UpdateDesign()
	if InCombatLockdown() then
		TankHelper:After(0.16, TankHelper.UpdateDesign, "UpdateDesign InCombat")
		return
	end

	if TankHelper.DesignThink then TankHelper:DesignThink() end
	local scalecockpit = TankHelper:GetConfig("scalecockpit", 1)
	local scalestatus = TankHelper:GetConfig("scalestatus", 1)
	if THTAB["obr"] ~= nil then
		if THTAB["obr"] >= 12 then
			THTAB["obr"] = 12
		elseif THTAB["obr"] <= 3 then
			THTAB["obr"] = 3
		end
	end

	if THTAB["ibr"] ~= nil and THTAB["ibr"] >= 12 then THTAB["ibr"] = 1 end
	if THTAB["cbr"] ~= nil and THTAB["cbr"] >= 12 then THTAB["cbr"] = 3 end
	obr = TankHelper:GetConfig("obr", 6) -- Outer Border
	ibr = TankHelper:GetConfig("ibr", 1) -- Column Spacer
	cbr = TankHelper:GetConfig("cbr", 3) -- Row Spacer
	iconsize = TankHelper:GetConfig("iconsize", 16)
	iconbr = iconsize / 4
	iconbtn = iconsize + 2 * iconbr
	THCockpit:SetScale(scalecockpit)
	local combined = TankHelper:GetConfig("combineall", false)
	for _, bar in ipairs({THTargetMarkers, THWorldMarkers, THExtras}) do
		bar:SetParent(combined and THCockpit or UIParent)
		bar:SetScale(combined and 1 or scalecockpit)
	end
	THStatus:SetScale(scalestatus)
	local THROW = 1
	THTargetMarkers:SetSize(cols * iconbtn + (cols - 1) * ibr + 2 * obr, iconbtn + 2 * obr)
	TankHelper:UpdateFrameDesign(THTargetMarkers)
	THWorldMarkers:SetSize((WMN + 1) * iconbtn + ((WMN + 1) - 1) * ibr + 2 * obr, iconbtn + 2 * obr)
	TankHelper:UpdateFrameDesign(THWorldMarkers)
	THExtras:SetSize(cols * iconbtn + (cols - 1) * ibr + 2 * obr, iconbtn + 2 * obr)
	TankHelper:UpdateFrameDesign(THExtras)
	for mId = 0, 8 do
		local MName = "btnM" .. 8 - mId
		THTargetMarkers[MName]:SetPoint("TOPLEFT", THTargetMarkers, "TOPLEFT", obr + mId * (iconbtn + ibr), -obr)
		THTargetMarkers[MName]:SetSize(iconbtn, iconbtn)
		THTargetMarkers[MName].texture:SetPoint("CENTER", THTargetMarkers[MName], "CENTER", 0, 0)
		THTargetMarkers[MName].texture:SetSize(iconsize, iconsize)
		THTargetMarkers[MName].bgtexture:SetSize(iconsize * markScale, iconsize * markScale)
	end

	if IsRaidMarkerActive then
		THROW = THROW + 1
		for rmId = 0, WMN do
			local RMName = "THBtnRM" .. WMN - rmId
			if THWorldMarkers[RMName] then
				THWorldMarkers[RMName]:SetPoint("TOPLEFT", THWorldMarkers, "TOPLEFT", obr + rmId * (iconbtn + ibr), -obr)
				THWorldMarkers[RMName]:SetSize(iconbtn, iconbtn)
				THWorldMarkers[RMName].texture:SetPoint("CENTER", THWorldMarkers[RMName], "CENTER", 0, 0)
				THWorldMarkers[RMName].texture:SetSize(iconsize, iconsize)
				THWorldMarkers[RMName].tBG:SetPoint("BOTTOMLEFT", THWorldMarkers[RMName], "BOTTOMLEFT", 0, 0)
				THWorldMarkers[RMName].tBG:SetSize(iconsize / 1.2, iconsize / 1.2)
			end
		end
	end

	for pId = 1, #pt do
		if pId <= #pt then
			local PullName = "btnPull" .. pId
			if TankHelper:GetConfig("hidespecialbar", false) and TankHelper:GetConfig("combineall", false) then
				THExtras[PullName]:Hide()
			else
				THExtras[PullName]:SetPoint("TOPLEFT", THExtras, "TOPLEFT", obr + (pId - 1) * (iconbtn + ibr), -obr)
				THExtras[PullName]:SetSize(iconbtn, iconbtn)
				THExtras[PullName]:Show()
			end
		end
	end

	TankHelper:UpdateRaidManagerIcons()

	if TankHelper:GetConfig("hidespecialbar", false) and TankHelper:GetConfig("combineall", false) then
		THExtras["btnReadycheck"]:Hide()
	else
		THExtras["btnReadycheck"]:ClearAllPoints()
		THExtras["btnReadycheck"]:SetPoint("BOTTOMRIGHT", THExtras, "BOTTOMRIGHT", -(obr + (InitiateRolePoll and 2 or 1) * (iconbtn + ibr)), obr)
		THExtras["btnReadycheck"]:SetSize(iconbtn, iconbtn)
		THExtras["btnReadycheck"]:Show()
	end

	if InitiateRolePoll then
		if TankHelper:GetConfig("hidespecialbar", false) and TankHelper:GetConfig("combineall", false) then
			THExtras["btnRolepoll"]:Hide()
		else
			THExtras["btnRolepoll"]:ClearAllPoints()
			THExtras["btnRolepoll"]:SetPoint("BOTTOMRIGHT", THExtras, "BOTTOMRIGHT", -(obr + iconbtn + ibr), obr)
			THExtras["btnRolepoll"]:SetSize(iconbtn, iconbtn)
			THExtras["btnRolepoll"]:Show()
		end
	end

	if TankHelper:GetConfig("hidespecialbar", false) and TankHelper:GetConfig("combineall", false) then
		THExtras["btnDiscord"]:Hide()
	else
		THExtras["btnDiscord"]:ClearAllPoints()
		THExtras["btnDiscord"]:SetSize(iconbtn, iconbtn)
		THExtras["btnDiscord"]:SetPoint("BOTTOMRIGHT", THExtras, "BOTTOMRIGHT", -obr, obr)
		THExtras["btnDiscord"]:Show()
	end

	THStatus:SetSize(THCockpit:GetWidth(), 1 * iconbtn + 4 * obr)
	TankHelper:UpdateAutoSelectHighlight()

	local point, relativePoint, ofsx, ofsy = nil, nil, nil, nil
	if TankHelper:GetConfig("combineall", false) then
		point = THTAB["THCockpit" .. "point"]
		relativePoint = THTAB["THCockpit" .. "relativePoint"]
		ofsx = THTAB["THCockpit" .. "ofsx"]
		ofsy = THTAB["THCockpit" .. "ofsy"]
		if point and THCockpit then
			THCockpit:ClearAllPoints()
			THCockpit:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
		else
			THCockpit:ClearAllPoints()
			THCockpit:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end

		local row = 0
		for _, info in ipairs({{THTargetMarkers, "hidetargetmarks", true}, {THWorldMarkers, "hideworldmarks", IsRaidMarkerActive ~= nil}, {THExtras, "hidespecialbar", true}}) do
			local bar = info[1]
			bar:ClearAllPoints()
			bar:SetPoint("TOPLEFT", THCockpit, "TOPLEFT", 0, -row * (iconbtn + cbr))
			if info[3] and not TankHelper:GetConfig(info[2], false) then row = row + 1 end
		end
	else
		point = THTAB["THWorldMarkers" .. "point"]
		relativePoint = THTAB["THWorldMarkers" .. "relativePoint"]
		ofsx = THTAB["THWorldMarkers" .. "ofsx"]
		ofsy = THTAB["THWorldMarkers" .. "ofsy"]
		if point and THWorldMarkers then
			THWorldMarkers:ClearAllPoints()
			THWorldMarkers:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
		else
			THWorldMarkers:ClearAllPoints()
			THWorldMarkers:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end

		point = THTAB["THTargetMarkers" .. "point"]
		relativePoint = THTAB["THTargetMarkers" .. "relativePoint"]
		ofsx = THTAB["THTargetMarkers" .. "ofsx"]
		ofsy = THTAB["THTargetMarkers" .. "ofsy"]
		if point and THTargetMarkers then
			THTargetMarkers:ClearAllPoints()
			THTargetMarkers:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
		else
			THTargetMarkers:ClearAllPoints()
			THTargetMarkers:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end

		point = THTAB["THExtras" .. "point"]
		relativePoint = THTAB["THExtras" .. "relativePoint"]
		ofsx = THTAB["THExtras" .. "ofsx"]
		ofsy = THTAB["THExtras" .. "ofsy"]
		if point and THExtras then
			THExtras:ClearAllPoints()
			THExtras:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
		else
			THExtras:ClearAllPoints()
			THExtras:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end
	end

	point = THTAB["THStatus" .. "point"]
	relativePoint = THTAB["THStatus" .. "relativePoint"]
	ofsx = THTAB["THStatus" .. "ofsx"]
	ofsy = THTAB["THStatus" .. "ofsy"]
	if point and THStatus then
		THStatus:ClearAllPoints()
		THStatus:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
	else
		THStatus:ClearAllPoints()
		THStatus:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end

	local cl_rows = 0
	if IsRaidMarkerActive and TankHelper:GetConfig("hideworldmarks", false) == false then cl_rows = cl_rows + 1 end
	if TankHelper:GetConfig("hidetargetmarks", false) == false then cl_rows = cl_rows + 1 end
	if TankHelper:GetConfig("hidespecialbar", false) == false then cl_rows = cl_rows + 1 end
	THCockpit:SetSize(cols * iconbtn + (cols - 1) * ibr + 2 * obr, cl_rows * iconbtn + (cl_rows - 1) * cbr + 2 * obr)
	TankHelper:UpdateFrameDesign(THCockpit)
end

function TankHelper:InitSetup()
	if not InCombatLockdown() then
		TankHelper:InitFrames()
		TankHelper:UpdateDesign()
		for _, bar in ipairs({THCockpit, THTargetMarkers, THWorldMarkers, THExtras}) do
			bar.thLastScale = bar:GetScale()
			hooksecurefunc(bar, "SetScale", function(sel)
				local scale = sel:GetScale()
				if scale == sel.thLastScale then return end
				sel.thLastScale = scale
				if TankHelper.scaleRefreshPending then return end
				TankHelper.scaleRefreshPending = true
				TankHelper:After(0, function()
					TankHelper:UpdateDesign()
					TankHelper.scaleRefreshPending = false
				end, "Refresh scaled bars")
			end)
			bar:HookScript("OnSizeChanged", function(sel) TankHelper:UpdateFrameDesign(sel) end)
		end
		TankHelper:SetStatusText()
	else
		TankHelper:After(0.15, TankHelper.InitSetup, "InitSetup")
	end
end

local nps = {}
local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_CREATED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
local threatBars = {}
local function GetThreatHealthBar(np)
	local unitFrame = np.UnitFrame
	if unitFrame == nil then return nil end
	local bar = unitFrame.healthBar
	if bar == nil and unitFrame.HealthBarsContainer then bar = unitFrame.HealthBarsContainer.healthBar end
	if bar == nil or bar:IsForbidden() or type(bar.GetStatusBarColor) ~= "function" then return nil end
	return bar
end

local function IsSameColor(r1, g1, b1, r2, g2, b2)
	if r2 == nil or g2 == nil or b2 == nil then return false end
	return math.abs(r1 - r2) < 0.01 and math.abs(g1 - g2) < 0.01 and math.abs(b1 - b2) < 0.01
end

local function ApplyThreatHealthColor(np)
	local threat = np.th_threat
	local bar = GetThreatHealthBar(np)
	if threat == nil or bar == nil then return end
	local r, g, b = bar:GetStatusBarColor()
	if TankHelper:IsSecret(r) or TankHelper:IsSecret(g) or TankHelper:IsSecret(b) or type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then return end
	local applied = IsSameColor(r, g, b, threat.appliedR, threat.appliedG, threat.appliedB)
	if threat.wantR == nil then
		if applied and threat.origR ~= nil then bar:SetStatusBarColor(threat.origR, threat.origG, threat.origB) end
		threat.appliedR, threat.appliedG, threat.appliedB = nil, nil, nil
		threat.origR, threat.origG, threat.origB = nil, nil, nil
		return
	end

	if not applied or threat.origR == nil then threat.origR, threat.origG, threat.origB = r, g, b end
	bar:SetStatusBarColor(threat.wantR, threat.wantG, threat.wantB)
	threat.appliedR, threat.appliedG, threat.appliedB = bar:GetStatusBarColor()
end

local function SetThreatHealthColor(np, r, g, b)
	local threat = np.th_threat
	if threat == nil then return end
	if r == nil and threat.wantR == nil and threat.appliedR == nil then return end
	threat.wantR, threat.wantG, threat.wantB = r, g, b
	ApplyThreatHealthColor(np)
end

local threatHealthHooked = false
local function HookThreatHealthColor()
	if threatHealthHooked or type(CompactUnitFrame_UpdateHealthColor) ~= "function" then return end
	threatHealthHooked = true
	hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(unitFrame)
		local np = threatBars[unitFrame]
		if np ~= nil and np.th_threat ~= nil and np.th_threat.wantR ~= nil then ApplyThreatHealthColor(np) end
	end)
end

local function ClearThreatDisplay(np)
	if np.th_threat == nil then return end
	SetThreatHealthColor(np, nil)
	np.th_threat.text:SetText("")
	np.th_threat.text:SetTextColor(0, 0, 0, 0)
	np.th_threat.texture:SetTexture(nil)
	np.th_threat.texture:SetAlpha(0)
end

local function CreateThreatDisplay(np)
	if np.th_threat ~= nil then return end
	np.th_threat = CreateFrame("Frame", nil, np)
	np.th_threat:SetSize(1, 1)
	np.th_threat:SetPoint("CENTER", np, "CENTER", 0, 0)
	np.th_threat.texture = np:CreateTexture(nil, "OVERLAY")
	np.th_threat.texture:SetSize(42, 42)
	np.th_threat.text = np:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	TankHelper:SetFontSize(np.th_threat.text, 12, "THINOUTLINE")
	TankHelper:UpdateThreatPosition(np)
	ClearThreatDisplay(np)
end

function TankHelper:UpdateThreatPosition(np)
	if np.th_threat == nil then return end
	local x = TankHelper:GetConfig("nameplatethreatx", 0)
	local y = TankHelper:GetConfig("nameplatethreaty", 70)
	np.th_threat.texture:ClearAllPoints()
	np.th_threat.texture:SetPoint("CENTER", np.th_threat, "TOP", x, y)
	np.th_threat.text:ClearAllPoints()
	np.th_threat.text:SetPoint("CENTER", np.th_threat, "TOP", x, y)
end

function TankHelper:UpdateThreatPositions()
	for _, np in pairs(nps) do
		TankHelper:UpdateThreatPosition(np)
	end
end

function TankHelper:UpdateThreatDisplays()
	for _, np in pairs(nps) do
		TankHelper:UpdateThreatStatus(np)
	end
end

function TankHelper:UpdateThreatStatus(np, reset)
	if np.th_threat == nil then return end
	local unit = np.th_threat.unit
	if reset or not TankHelper:GetConfig("nameplatethreat", false) or unit == nil or not UnitExists(unit) then
		ClearThreatDisplay(np)
		return
	end

	local status, scaledPercentage
	if type(UnitDetailedThreatSituation) == "function" then
		local ok, _, threatStatus, percentage = pcall(UnitDetailedThreatSituation, "player", unit)
		if ok then
			status = threatStatus
			scaledPercentage = percentage
		end
	end

	if TankHelper:IsSecret(status) or type(status) ~= "number" then
		status = nil
		if type(UnitThreatSituation) == "function" then
			local ok, threatStatus = pcall(UnitThreatSituation, "player", unit)
			if ok and not TankHelper:IsSecret(threatStatus) and type(threatStatus) == "number" then status = threatStatus end
		end
	end

	local hasPercentage = TankHelper:IsSecret(scaledPercentage) or type(scaledPercentage) == "number"
	if not hasPercentage and status == nil then
		ClearThreatDisplay(np)
		return
	end

	local r, g, b = 1, 1, 1
	local text = ""
	local texture = "Interface\\WORLDSTATEFRAME\\CombatSwords"
	local shield = false
	if status == 3 then
		r, g, b = 0, 1, 0
		text = "TANK"
		texture = "Interface\\MINIMAP\\Minimap_shield_normal"
		shield = true
	elseif status == 2 then
		r, g, b = 1, 0.6, 0
		text = "LOSING"
		texture = "Interface\\COMMON\\Indicator-Yellow"
		shield = true
	elseif status == 1 then
		r, g, b = 1, 1, 0
		text = "HIGH"
	elseif status == 0 then
		r, g, b = 1, 0, 0
		text = "LOW"
	end

	if hasPercentage then
		np.th_threat.text:SetFormattedText("%.0f%%", scaledPercentage)
	else
		np.th_threat.text:SetText(text)
	end

	np.th_threat.text:SetTextColor(r, g, b, 1)
	np.th_threat.texture:SetTexture(texture)
	if shield then
		np.th_threat.texture:SetTexCoord(0, 1, 0, 1)
	else
		np.th_threat.texture:SetTexCoord(0, 0.5, 0, 0.5)
	end

	np.th_threat.texture:SetVertexColor(r, g, b, 1)
	local showIcon = TankHelper:GetConfig("nameplatethreaticon", true) == true
	np.th_threat.texture:SetShown(showIcon)
	np.th_threat.texture:SetAlpha(showIcon and 1 or 0)

	if status ~= nil and TankHelper:GetConfig("nameplatethreathealthcolor", false) then
		SetThreatHealthColor(np, r, g, b)
	else
		SetThreatHealthColor(np, nil)
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "NAME_PLATE_CREATED" then
		local np = ...
		if np ~= nil and not np:IsForbidden() then CreateThreatDisplay(np) end
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local unit = ...
		if TankHelper:IsSecret(unit) or type(unit) ~= "string" then return end
		local np = C_NamePlate.GetNamePlateForUnit(unit)
		if np == nil or np:IsForbidden() then return end
		CreateThreatDisplay(np)
		TankHelper:UpdateThreatPosition(np)
		if np.UnitFrame ~= nil then
			threatBars[np.UnitFrame] = np
			HookThreatHealthColor()
		end

		local previousUnit = np.th_threat.unit
		if previousUnit ~= nil then nps[previousUnit] = nil end
		np.th_threat.unit = unit
		nps[unit] = np
		TankHelper:UpdateThreatStatus(np)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		local unit = ...
		if TankHelper:IsSecret(unit) or type(unit) ~= "string" then return end
		local np = nps[unit]
		if np ~= nil then
			TankHelper:UpdateThreatStatus(np, true)
			np.th_threat.unit = nil
			nps[unit] = nil
		end
	else
		local unit = ...
		if not TankHelper:IsSecret(unit) and type(unit) == "string" and nps[unit] ~= nil then
			TankHelper:UpdateThreatStatus(nps[unit])
		else
			for _, np in pairs(nps) do
				TankHelper:UpdateThreatStatus(np)
			end
		end
	end
end)

if false then
	TankHelper:After(1, function()
		TankHelper:SetDebug(true)
		if true then
			TankHelper:DrawDebug("TankHelper DD 1", function()
				local text = ""
				for i, v in pairs(TankHelper:GetCountAfter()) do
					if v > 100 then text = text .. v .. "x: " .. i .. "\n" end
				end
				return text
			end, 14, 1440, 1440, "CENTER", UIParent, "CENTER", 1200, 0)
		end

		if true then
			TankHelper:DrawDebug("TankHelper DD 2", function()
				local text = ""
				for i, v in pairs(TankHelper:GetCountAfterEvents()) do
					if v > 1 then text = text .. v .. "x: " .. i .. "\n" end
				end
				return text
			end, 14, 1440, 1440, "CENTER", UIParent, "CENTER", 100, 0)
		end
	end, "DEBUG")
end
