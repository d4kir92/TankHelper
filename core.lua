local _, TankHelper = ...
local THBORDERALPHA = 0.5
local obr = 6 -- Outside Border
local ibr = 1 -- Icon Border
local cbr = 3 -- Cell Border
local iconsize = 16
local iconbr = 4
local iconbtn = iconsize + 2 * iconbr
local pt = {3, 5, 10, 20}
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
function TankHelper:CreateButton(name, parent)
	local btn = CreateFrame("Button", name, parent)
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

function TankHelper:RW(msg)
	if TankHelper:GetWoWBuild() ~= "RETAIL" and IsInRaid() and (UnitIsGroupAssistant("PLAYER") or UnitIsGroupLeader("PLAYER")) then
		SendChatMessage(msg, "RAID_WARNING")
	elseif not InCombatLockdown() then
		if TankHelper:ShouldShow() then
			SendChatMessage(msg, "PARTY")
		else
			TankHelper:MSG(TankHelper:Trans("youmustbeinagrouporaraid", true) .. "!")
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
				if C_PartyInfo and C_PartyInfo.DoCountdown then
					C_PartyInfo.DoCountdown(t)
				end
			end
		else
			if C_PartyInfo and C_PartyInfo.DoCountdown then
				C_PartyInfo.DoCountdown(t)
			end
		end

		if (TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "AUTO" and (not TankHelper:IsAddOnLoaded("DBM-Core") and not TankHelper:IsAddOnLoaded("BigWigs"))) or TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "ONLYTH" or TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "BOTH" or TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "ONLYTHIRDPARTY" and not TankHelper:IsAddOnLoaded("DBM-Core") and not TankHelper:IsAddOnLoaded("BigWigs") then
			if TankHelper:GetConfig("PULLTIMERMODE", "AUTO") == "ONLYTHIRDPARTY" and not TankHelper:IsAddOnLoaded("DBM-Core") and not TankHelper:IsAddOnLoaded("BigWigs") then
				TankHelper:MSG("Found no Thirdparty countdown addon" .. "!" .. " Using Default timer.")
			end

			TankHelper:RW(format(TankHelper:Trans("pullinx", TankHelper:GetLang()), t))
			for cou = 1, t do
				C_Timer.After(
					cou,
					function()
						local leftT = t - cou
						if leftT == 0 then
							TankHelper:RW(TankHelper:Trans("go", TankHelper:GetLang()) .. "!")
						else
							TankHelper:RW(leftT)
						end
					end
				)
			end
		end
	else
		TankHelper:MSG(TankHelper:Trans("youmustbeinagrouporaraid", TankHelper:GetLang()) .. "!")
	end
end

function TankHelper:ResetIcons1()
	for btnId, v in pairs(ricons1) do
		if THTargetMarkers:IsShown() then
			v.bgtexture:SetTexture("")
		end
	end
end

function TankHelper:UpdateRaidIcons()
	for rmId = 0, 8 do
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

function TankHelper:CheckUnit(unit, dead, health, power)
	if UnitExists(unit) then
		local can = true
		if TankHelper:GetConfig("statusonlyhealers", true) and UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then
			local role = UnitGroupRolesAssigned(unit)
			if role ~= "HEALER" then
				can = false
			end
		end

		if can then
			local hpercent = UnitHealth(unit) / UnitHealthMax(unit)
			if hpercent < health then
				health = hpercent
			end

			local powertype = UnitPowerType(unit)
			if powertype == 0 and UnitPower(unit) > 0 and UnitPowerMax(unit) > 0 then
				local ppercent = UnitPower(unit) / UnitPowerMax(unit)
				if ppercent < power then
					power = ppercent
				end
			end
		end

		if UnitIsDead(unit) then
			dead = true
		end
	end

	return dead, health, power
end

function TankHelper:InitFrame(frame, px, py)
	frame:SetPoint("Center", UIParent, "Center", px, py)
	frame:SetSize(cols * iconbtn + (cols - 1) * ibr + 2 * obr, rows * iconbtn + (rows - 1) * cbr + 2 * obr)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript(
		"OnDragStart",
		function(sel)
			if not TankHelper:GetConfig("fixposition", false) then
				frame:StartMoving()
			else
				TankHelper:MSG(TankHelper:Trans("fixedpositionisenabled", TankHelper:GetLang()) .. "!")
			end
		end
	)

	frame:SetScript(
		"OnDragStop",
		function(sel)
			if not TankHelper:GetConfig("fixposition", false) then
				frame:StopMovingOrSizing()
				local point, parent, relativePoint, ofsx, ofsy = sel:GetPoint()
				THTAB[frame:GetName() .. "point"] = point
				THTAB[frame:GetName() .. "parent"] = parent
				THTAB[frame:GetName() .. "relativePoint"] = relativePoint
				THTAB[frame:GetName() .. "ofsx"] = ofsx
				THTAB[frame:GetName() .. "ofsy"] = ofsy
			else
				TankHelper:MSG(TankHelper:Trans("fixedpositionisenabled", TankHelper:GetLang()) .. "!")
			end
		end
	)

	frame.tBRl = frame:CreateTexture(nil, "BACKGROUND")
	frame.tBRr = frame:CreateTexture(nil, "BACKGROUND")
	frame.tBRt = frame:CreateTexture(nil, "BACKGROUND")
	frame.tBRb = frame:CreateTexture(nil, "BACKGROUND")
	frame.tBG = frame:CreateTexture(nil, "BACKGROUND")
	frame:HookScript(
		"OnUpdate",
		function(sel, elapsed)
			frame.hovered = frame.hovered or false
			if frame.hovered ~= MouseIsOver(frame) then
				frame.hovered = MouseIsOver(frame)
				if TankHelper.UpdateColors then
					TankHelper:UpdateColors(frame)
				end
			end
		end
	)

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
	if IsRaidMarkerActive and TankHelper:GetConfig("hideworldmarks", false) == false then
		THWorldMarkers:Show()
	else
		THWorldMarkers:Hide()
	end

	THTargetMarkers:Hide()
	THExtras:Hide()
	THCockpit:EnableMouse(true)
	THWorldMarkers:EnableMouse(false)
	THTargetMarkers:EnableMouse(false)
	THExtras:EnableMouse(false)
end

function TankHelper:InitFrames()
	if TankHelper:GetWoWBuild() == "RETAIL" then
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
	TankHelper:InitFrame(THCockpit, 0, 0)
	TankHelper:InitFrame(THWorldMarkers, 0, 0)
	TankHelper:InitFrame(THTargetMarkers, 0, -40)
	TankHelper:InitFrame(THExtras, 0, -80)
	local Y = 1
	for btnId = 0, 8 do
		THTargetMarkers["btnM" .. btnId] = TankHelper:CreateButton("btnM" .. btnId, THTargetMarkers)
		THTargetMarkers["btnM" .. btnId]:SetPoint("TOPLEFT", THTargetMarkers, "TOPLEFT", obr + (btnId - 1) * (iconbtn + ibr), -obr)
		THTargetMarkers["btnM" .. btnId]:SetSize(iconbtn, iconbtn)
		THTargetMarkers["btnM" .. btnId].bgtexture = THTargetMarkers["btnM" .. btnId]:CreateTexture(nil, "OVERLAY")
		THTargetMarkers["btnM" .. btnId].bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
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
		THTargetMarkers["btnM" .. btnId]:SetScript(
			"OnClick",
			function(sel, btn, down)
				if btn == "LeftButton" then
					if btnId > 0 and GetRaidTargetIndex("TARGET") ~= btnId then
						SetRaidTarget("TARGET", btnId)
					else
						SetRaidTarget("TARGET", 0)
						TankHelper:UpdateRaidIcons()
					end
				elseif btn == "RightButton" and btnId > 0 then
					TankHelper:ResetIcons1()
					if TankHelper:GetConfig("autoselect", 8) ~= btnId then
						if THTargetMarkers:IsShown() then
							sel.bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
						end

						THTAB["autoselect"] = btnId
					else
						THTAB["autoselect"] = -1
					end
				end
			end
		)

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
			THWorldMarkers["THBtnRM" .. btnId]:SetMouseClickEnabled(true)
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
			function btn.tk_think()
				local btn1 = THWorldMarkers["THBtnRM" .. btnId].texture
				local btn2 = THWorldMarkers["THBtnRM" .. btnId].tBG
				if btnId > 0 then
					if IsRaidMarkerActive and THWorldMarkers["THBtnRM" .. btnId].status ~= IsRaidMarkerActive(wms[btnId]) then
						THWorldMarkers["THBtnRM" .. btnId].status = IsRaidMarkerActive(wms[btnId])
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
						if IsRaidMarkerActive and IsRaidMarkerActive(wms[rmId]) then
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

				C_Timer.After(0.33, btn.tk_think)
			end

			btn:tk_think()
			table.insert(ricons2, THWorldMarkers["THBtnRM" .. btnId])
			Y = Y + 1
		else
			THWorldMarkers:Hide()
		end

		if btnId <= #pt then
			local PullName = "btnPull" .. btnId
			THExtras[PullName] = TankHelper:CreateButton(PullName, THExtras)
			THExtras[PullName]:SetPoint("TOPLEFT", THExtras, "TOPLEFT", obr + (btnId - 1) * (iconbtn + ibr), -obr)
			THExtras[PullName]:SetSize(iconbtn, iconbtn)
			THExtras[PullName]:SetText(pt[btnId])
			THExtras[PullName]:SetScript(
				"OnClick",
				function(sel, btn, down)
					TankHelper:PullIn(pt[btnId])
				end
			)
		end
	end

	THExtras["btnReadycheck"] = TankHelper:CreateButton("btnReadycheck", THExtras)
	if IsRaidMarkerActive or InitiateRolePoll then
		THExtras["btnReadycheck"]:SetSize(50, iconbtn)
		THExtras["btnReadycheck"]:SetText(string.sub(READY_CHECK, 1, 6))
	else
		THExtras["btnReadycheck"]:SetSize(100, iconbtn)
		THExtras["btnReadycheck"]:SetText(string.sub(READY_CHECK, 1, 12))
	end

	THExtras["btnReadycheck"]:SetScript(
		"OnClick",
		function(sel, btn, down)
			DoReadyCheck()
		end
	)

	if InitiateRolePoll then
		THExtras["btnRolepoll"] = TankHelper:CreateButton("btnRolepoll", THExtras)
		THExtras["btnRolepoll"]:SetSize(50, iconbtn)
		THExtras["btnRolepoll"]:SetText(string.sub(ROLE_POLL, 1, 6))
		THExtras["btnRolepoll"]:SetScript(
			"OnClick",
			function(sel, btn, down)
				InitiateRolePoll()
			end
		)
	end

	THExtras["btnDiscord"] = TankHelper:CreateButton("btnDiscord", THExtras)
	THExtras["btnDiscord"]:SetPoint("TOPLEFT", THExtras, "TOPLEFT", obr + 100 + ibr + 100 + ibr, -obr - Y * (iconbtn + cbr))
	THExtras["btnDiscord"]:SetSize(iconbtn, iconbtn)
	THExtras["btnDiscord"]:SetText("D")
	THExtras["btnDiscord"]:SetScript(
		"OnClick",
		function(sel, btn, down)
			local s = CreateFrame("Frame", nil, UIParent)
			s:SetSize(300, 2 * iconbtn + 2 * 10)
			s:SetPoint("CENTER")
			s.texture = s:CreateTexture(nil, "BACKGROUND")
			s.texture:SetColorTexture(0, 0, 0, 0.5)
			s.texture:SetAllPoints(s)
			s.text = s:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			s.text:SetText("Feedback")
			s.text:SetPoint("CENTER", s, "TOP", 0, -10)
			local eb = CreateFrame("EditBox", "logEditBox", s, "InputBoxTemplate")
			eb:SetFrameStrata("DIALOG")
			eb:SetSize(280, iconbtn)
			eb:SetAutoFocus(false)
			eb:SetText("https://discord.gg/Ymv5MamPd5")
			eb:SetPoint("TOPLEFT", 10, -10 - iconbtn)
			s.close = TankHelper:CreateButton("closediscord", s)
			s.close:SetFrameStrata("DIALOG")
			s.close:SetPoint("TOPLEFT", 300 - 10 - iconbtn, -10)
			s.close:SetSize(iconbtn, iconbtn)
			s.close:SetText("X")
			s.close:SetScript(
				"OnClick",
				function(se, sbtn, sdown)
					s:Hide()
				end
			)
		end
	)

	C_Timer.After(4, TankHelper.UpdateTargetIcon)
	THCockpit:RegisterEvent("PLAYER_ENTERING_WORLD")
	THCockpit:RegisterEvent("PLAYER_TARGET_CHANGED")
	THCockpit:RegisterEvent("RAID_TARGET_UPDATE")
	THCockpit:RegisterEvent("UNIT_HEALTH")
	THCockpit:RegisterEvent("UNIT_POWER_UPDATE")
	THCockpit:RegisterEvent("GROUP_ROSTER_UPDATE")
	THCockpit:RegisterEvent("RAID_ROSTER_UPDATE")
	THCockpit:RegisterEvent("ADDON_LOADED")
	THCockpit:HookScript(
		"OnEvent",
		function(sel, e, ...)
			if e == "PLAYER_ENTERING_WORLD" and TankHelper:GetConfig("autoselect", 8) ~= -1 then
				local btn = THTargetMarkers["btnM" .. TankHelper:GetConfig("autoselect", 8)]
				if THTargetMarkers:IsShown() then
					btn.bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
				end
			end

			if (e == "PLAYER_ENTERING_WORLD" or e == "PLAYER_TARGET_CHANGED" or e == "RAID_TARGET_UPDATE") and (not UnitExists("TARGET") or not UnitIsEnemy("TARGET", "PLAYER")) then
				TankHelper:UpdateRaidIcons()
			end

			if e == "PLAYER_TARGET_CHANGED" then
				TankHelper:TargetIconLogic()
			end

			if e == "UNIT_HEALTH" or e == "UNIT_POWER_UPDATE" or e == "GROUP_ROSTER_UPDATE" or e == "RAID_ROSTER_UPDATE" then
				TankHelper:SetStatusText()
			end
		end
	)

	THStatus:SetPoint("Center", UIParent, "Center")
	THStatus:SetSize(THCockpit:GetWidth(), 1 * iconbtn + 4 * obr)
	THStatus:SetClampedToScreen(true)
	THStatus:SetMovable(true)
	THStatus:EnableMouse(true)
	THStatus:RegisterForDrag("LeftButton")
	THStatus:SetScript(
		"OnDragStart",
		function(sel)
			if not TankHelper:GetConfig("fixposition", false) then
				THStatus:StartMoving()
			else
				TankHelper:MSG(TankHelper:Trans("fixedpositionisenabled", TankHelper:GetLang()) .. "!")
			end
		end
	)

	THStatus:SetScript(
		"OnDragStop",
		function(sel)
			if not TankHelper:GetConfig("fixposition", false) then
				THStatus:StopMovingOrSizing()
				local point, parent, relativePoint, ofsx, ofsy = sel:GetPoint()
				THTAB["THStatus" .. "point"] = point
				THTAB["THStatus" .. "parent"] = parent
				THTAB["THStatus" .. "relativePoint"] = relativePoint
				THTAB["THStatus" .. "ofsx"] = ofsx
				THTAB["THStatus" .. "ofsy"] = ofsy
			else
				TankHelper:MSG(TankHelper:Trans("fixedpositionisenabled", TankHelper:GetLang()) .. "!")
			end
		end
	)

	THStatus.texture = THStatus:CreateTexture(nil, "BACKGROUND")
	THStatus.texture:SetAllPoints(THStatus)
	THStatus.text = THStatus:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	THStatus.text:SetText("")
	THStatus.text:SetPoint("CENTER", THStatus, "CENTER", 0, 0)
	frameDesign = CreateFrame("Frame", "frameDesign", UIParent)
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

		C_Timer.After(0.33, TankHelper.DesignThink)
	end

	TankHelper:DesignThink()
end

local ts = 0
local setts = 0
local targetGUID = UnitGUID("TARGET")
function TankHelper:TargetIconLogic()
	if UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then
		local role = UnitGroupRolesAssigned("PLAYER")
		if TankHelper:GetConfig("onlytank", true) and role ~= "TANK" then return false end -- Only Tank?
	end

	if TankHelper:GetConfig("autoselect", 8) == -1 then return false end -- no Auto marking
	-- No Unit
	if not UnitExists("TARGET") then
		ts = GetTime()
		targetGUID = nil

		return true
	end

	if GetRaidTargetIndex("TARGET") ~= nil then return true end -- Already Has Raid Target Icon
	-- if target is the current one
	if targetGUID and UnitGUID("TARGET") == targetGUID and ts <= GetTime() and setts <= GetTime() then
		if IsInRaid() and (UnitIsGroupAssistant("PLAYER") or UnitIsGroupLeader("PLAYER")) then
			setts = GetTime() + 0.1
			SetRaidTarget("TARGET", TankHelper:GetConfig("autoselect", 8))
		elseif not IsInRaid() then
			SetRaidTarget("TARGET", TankHelper:GetConfig("autoselect", 8))
		end
	end

	-- if is not enemy reset the time
	if not UnitIsEnemy("TARGET", "PLAYER") then
		ts = GetTime()
		targetGUID = nil
	else
		-- switch from enemy to enemy, then add delay
		if targetGUID and UnitGUID("TARGET") ~= targetGUID then
			ts = GetTime() + TankHelper:GetConfig("targettingdelay", 0.0)
		end

		targetGUID = UnitGUID("TARGET")
	end

	return true
end

function TankHelper:UpdateTargetIcon()
	TankHelper:TargetIconLogic()
	C_Timer.After(0.1, TankHelper.UpdateTargetIcon)
end

function TankHelper:SetStatusText()
	if THCockpit == nil or THStatus == nil then return end
	if not TankHelper:GetConfig("hidestatus", true) then
		local text = TankHelper:Trans("ready", TankHelper:GetLang()) .. "!"
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
				text = TankHelper:Trans("playerdead", TankHelper:GetLang()) .. "!"
				THStatusColor = {0, 0, 0, 1}
			elseif health < 0.3 then
				text = TankHelper:Trans("playerlowhp", TankHelper:GetLang()) .. "!"
				THStatusColor = {1, 0, 0, 1 - health + 0.1}
			elseif health < TankHelper:GetConfig("healthmax", 0.9) then
				text = TankHelper:Trans("playernotfull", TankHelper:GetLang()) .. "!"
				THStatusColor = {1, 0, 0, 1 - health + 0.1}
			elseif power < TankHelper:GetConfig("powermax", 0.9) then
				text = TankHelper:Trans("playerhavenotenoughpower", TankHelper:GetLang()) .. "!"
				THStatusColor = {0, 0, 1, 1 - power + 0.1}
			end
		end

		if TankHelper:GetConfig("statusonlyhealers", true) and UnitGroupRolesAssigned and TankHelper:GetWoWBuildNr() > 19999 then
			text = format("%s: %s", TankHelper:Trans("healer", TankHelper:GetLang()), text)
		end

		THStatus.text:SetText(text)
		if THStatus.texture.SetColorTexture and THStatusColor[1] and THStatusColor[2] and THStatusColor[3] then
			if THStatusColor[4] > 1 then
				THStatusColor[4] = 1
			end

			if THStatusColor[4] < 0 then
				THStatusColor[4] = 0
			end

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
		C_Timer.After(0.1, TankHelper.UpdateDesign)

		return
	end

	local scalecockpit = TankHelper:GetConfig("scalecockpit", 1)
	local scalestatus = TankHelper:GetConfig("scalestatus", 1)
	if THTAB["obr"] ~= nil and THTAB["obr"] >= 16 then
		THTAB["obr"] = 6
	end

	if THTAB["ibr"] ~= nil and THTAB["ibr"] >= 16 then
		THTAB["ibr"] = 1
	end

	if THTAB["cbr"] ~= nil and THTAB["cbr"] >= 16 then
		THTAB["cbr"] = 3
	end

	obr = TankHelper:GetConfig("obr", 6) -- Outer Border
	ibr = TankHelper:GetConfig("ibr", 1) -- Column Spacer
	cbr = TankHelper:GetConfig("cbr", 3) -- Row Spacer
	iconsize = TankHelper:GetConfig("iconsize", 16)
	iconbr = iconsize / 4
	iconbtn = iconsize + 2 * iconbr
	THCockpit:SetScale(scalecockpit)
	THTargetMarkers:SetScale(scalecockpit)
	THWorldMarkers:SetScale(scalecockpit)
	THExtras:SetScale(scalecockpit)
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

	for pId = 0, 8 do
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

	local bw = obr + (5 - 1) * (iconbtn + ibr)
	local bsw = THExtras:GetWidth() - bw - obr - iconsize - ibr
	if IsRaidMarkerActive or InitiateRolePoll then
		bsw = bsw / 2
	end

	if TankHelper:GetConfig("hidespecialbar", false) and TankHelper:GetConfig("combineall", false) then
		THExtras["btnReadycheck"]:Hide()
	else
		THExtras["btnReadycheck"]:ClearAllPoints()
		THExtras["btnReadycheck"]:SetPoint("BOTTOMRIGHT", THExtras, "BOTTOMRIGHT", -(obr + iconbtn + bsw), obr)
		THExtras["btnReadycheck"]:SetSize(bsw, iconbtn)
		THExtras["btnReadycheck"]:Show()
	end

	if InitiateRolePoll then
		if TankHelper:GetConfig("hidespecialbar", false) and TankHelper:GetConfig("combineall", false) then
			THExtras["btnRolepoll"]:Hide()
		else
			THExtras["btnRolepoll"]:ClearAllPoints()
			THExtras["btnRolepoll"]:SetPoint("BOTTOMRIGHT", THExtras, "BOTTOMRIGHT", -(obr + iconbtn), obr)
			THExtras["btnRolepoll"]:SetSize(bsw, iconbtn)
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
	TankHelper:ResetIcons1()
	C_Timer.After(
		1,
		function()
			if TankHelper:GetConfig("autoselect", 8) ~= -1 then
				local btn = THTargetMarkers["btnM" .. TankHelper:GetConfig("autoselect", 8)]
				if THTargetMarkers:IsShown() then
					btn.bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
				end
			end
		end
	)

	local point, parent, relativePoint, ofsx, ofsy = nil
	if TankHelper:GetConfig("combineall", false) then
		point = THTAB["THCockpit" .. "point"]
		parent = THTAB["THCockpit" .. "parent"]
		relativePoint = THTAB["THCockpit" .. "relativePoint"]
		ofsx = THTAB["THCockpit" .. "ofsx"]
		ofsy = THTAB["THCockpit" .. "ofsy"]
		if point and THCockpit then
			THCockpit:ClearAllPoints()
			THCockpit:SetPoint(point, parent, relativePoint, ofsx, ofsy)
		else
			THCockpit:ClearAllPoints()
			THCockpit:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end

		if THWorldMarkers then
			THWorldMarkers:ClearAllPoints()
			THWorldMarkers:SetPoint("CENTER", THCockpit, "CENTER", 0, 0)
		end

		if THTargetMarkers then
			THTargetMarkers:ClearAllPoints()
			THTargetMarkers:SetPoint("TOP", THCockpit, "TOP", 0, 0)
		end

		if THExtras then
			THExtras:ClearAllPoints()
			THExtras:SetPoint("BOTTOM", THCockpit, "BOTTOM", 0, 0)
		end
	else
		point = THTAB["THWorldMarkers" .. "point"]
		parent = THTAB["THWorldMarkers" .. "parent"]
		relativePoint = THTAB["THWorldMarkers" .. "relativePoint"]
		ofsx = THTAB["THWorldMarkers" .. "ofsx"]
		ofsy = THTAB["THWorldMarkers" .. "ofsy"]
		if point and THWorldMarkers then
			THWorldMarkers:ClearAllPoints()
			THWorldMarkers:SetPoint(point, parent, relativePoint, ofsx, ofsy)
		else
			THWorldMarkers:ClearAllPoints()
			THWorldMarkers:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end

		point = THTAB["THTargetMarkers" .. "point"]
		parent = THTAB["THTargetMarkers" .. "parent"]
		relativePoint = THTAB["THTargetMarkers" .. "relativePoint"]
		ofsx = THTAB["THTargetMarkers" .. "ofsx"]
		ofsy = THTAB["THTargetMarkers" .. "ofsy"]
		if point and THTargetMarkers then
			THTargetMarkers:ClearAllPoints()
			THTargetMarkers:SetPoint(point, parent, relativePoint, ofsx, ofsy)
		else
			THTargetMarkers:ClearAllPoints()
			THTargetMarkers:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end

		point = THTAB["THExtras" .. "point"]
		parent = THTAB["THExtras" .. "parent"]
		relativePoint = THTAB["THExtras" .. "relativePoint"]
		ofsx = THTAB["THExtras" .. "ofsx"]
		ofsy = THTAB["THExtras" .. "ofsy"]
		if point and THExtras then
			THExtras:ClearAllPoints()
			THExtras:SetPoint(point, parent, relativePoint, ofsx, ofsy)
		else
			THExtras:ClearAllPoints()
			THExtras:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end
	end

	point = THTAB["THStatus" .. "point"]
	parent = THTAB["THStatus" .. "parent"]
	relativePoint = THTAB["THStatus" .. "relativePoint"]
	ofsx = THTAB["THStatus" .. "ofsx"]
	ofsy = THTAB["THStatus" .. "ofsy"]
	if point and THStatus then
		THStatus:ClearAllPoints()
		THStatus:SetPoint(point, parent, relativePoint, ofsx, ofsy)
	else
		THStatus:ClearAllPoints()
		THStatus:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end

	local cl_rows = 0
	if TankHelper:GetConfig("hideworldmarks", false) == false then
		cl_rows = cl_rows + 1
	end

	if TankHelper:GetConfig("hidetargetmarks", false) == false then
		cl_rows = cl_rows + 1
	end

	if TankHelper:GetConfig("hidespecialbar", false) == false then
		cl_rows = cl_rows + 1
	end

	THCockpit:SetSize(cols * iconbtn + (cols - 1) * ibr + 2 * obr, cl_rows * iconbtn + (cl_rows - 1) * cbr + 2 * obr)
	TankHelper:UpdateFrameDesign(THCockpit)
end

function TankHelper:InitSetup()
	if not InCombatLockdown() then
		TankHelper:InitFrames()
		TankHelper:UpdateDesign()
		TankHelper:SetStatusText()
	else
		C_Timer.After(0.15, TankHelper.InitSetup)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_CREATED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
function TankHelper:UpdateThreatStatus(np, reset)
	if np.th_threat == nil then return end
	local unit = np.unit
	if np.UnitFrame ~= nil then
		unit = np.UnitFrame.unit
	end

	if unit == nil then
		unit = strlower(np:GetName())
	end

	local _, _, scaledPercentage, _, _ = UnitDetailedThreatSituation("PLAYER", unit)
	if TankHelper:GetConfig("nameplatethreat", false) and scaledPercentage and not reset then
		scaledPercentage = tonumber(string.format("%.0f", scaledPercentage))
		np.th_threat.text:SetText(scaledPercentage .. "%")
		if scaledPercentage > 100 then
			np.th_threat.texture:SetTexture("Interface\\COMMON\\Indicator-Yellow")
			np.th_threat.texture:SetTexCoord(0, 1, 0, 1)
			np.th_threat.texture:SetAlpha(1)
			np.th_threat.text:SetTextColor(1, 1, 0, 1)
		elseif scaledPercentage == 100 then
			np.th_threat.texture:SetTexture("Interface\\MINIMAP\\Minimap_shield_normal")
			np.th_threat.texture:SetTexCoord(0, 1, 0, 1)
			np.th_threat.texture:SetAlpha(0.33)
			np.th_threat.text:SetTextColor(0, 1, 0, 0.33)
		elseif scaledPercentage == 0 then
			np.th_threat.texture:SetTexture("Interface\\WORLDSTATEFRAME\\CombatSwords")
			np.th_threat.texture:SetTexCoord(0, 0.5, 0, 0.5)
			np.th_threat.texture:SetAlpha(1)
			np.th_threat.text:SetTextColor(1, 0, 0, 1)
		else
			np.th_threat.texture:SetTexture("Interface\\WORLDSTATEFRAME\\CombatSwords")
			np.th_threat.texture:SetTexCoord(0, 0.5, 0, 0.5)
			np.th_threat.texture:SetAlpha(1)
			np.th_threat.text:SetTextColor(1, 1, 0, 1)
		end
	else
		np.th_threat.text:SetText(-1 .. "%")
		np.th_threat.texture:SetTexture(nil)
		np.th_threat.texture:SetTexCoord(0, 1, 0, 1)
		np.th_threat.texture:SetAlpha(0)
		np.th_threat.text:SetTextColor(0, 0, 0, 0)
	end
end

local nps = {}
function TankHelper:ThinkNameplates(force)
	if TankHelper:GetConfig("nameplatethreat", false) or force then
		for btnId, np in pairs(nps) do
			TankHelper:UpdateThreatStatus(np)
		end

		C_Timer.After(0.2, TankHelper.ThinkNameplates)
	else
		C_Timer.After(1, TankHelper.ThinkNameplates)
	end
end

C_Timer.After(2, TankHelper.ThinkNameplates)
frame:SetScript(
	"OnEvent",
	function(self, event, ...)
		if event == "NAME_PLATE_CREATED" then
			local np = select(1, ...)
			if np.th_threat == nil then
				np.th_threat = CreateFrame("FRAME", nil, np)
				np.th_threat:SetSize(1, 1)
				np.th_threat:SetPoint("CENTER", np, "CENTER", 0, 0)
				-- np.th_threat:SetIgnoreParentAlpha( true )
				np.th_threat.texture = np:CreateTexture(nil, "OVERLAY")
				np.th_threat.texture:SetSize(42, 42)
				np.th_threat.texture:SetPoint("CENTER", np.th_threat, "TOP", 0, 70)
				np.th_threat.text = np:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				--np.th_threat.text:SetFont( STANDARD_TEXT_FONT, 12, "THINOUTLINE" )
				np.th_threat.text:SetText("Created by TankHelper -> if you see this tell the Dev. You have custom nameplates?")
				np.th_threat.text:SetPoint("CENTER", np.th_threat, "TOP", 0, 70)
				C_Timer.After(
					0.04,
					function()
						TankHelper:UpdateThreatStatus(np)
					end
				)

				C_Timer.After(
					0.1,
					function()
						TankHelper:UpdateThreatStatus(np)
					end
				)

				C_Timer.After(
					0.2,
					function()
						TankHelper:UpdateThreatStatus(np)
					end
				)

				table.insert(nps, np)
			end
		end
	end
)
