-- By D4KiR

local THBORDERALPHA = 0.5

local obr = 6 -- Outside Border
local ibr = 1 -- Icon Border
local cbr = 3 -- Cell Border
local iconsize = 16
local iconbr = 4
local iconbtn = iconsize + 2 * iconbr

local tid = 1
local pt = {3, 5, 10, 20}
local wms = {5, 6, 3, 2, 7, 1, 4, 8}
local updatewms = true

local ricons1 = {}
local ricons1bg = {}
local ricons2 = {}

local rows = 3
local cols = 9
if not IsRaidMarkerActive then
	rows = 2
end

frameCockpit = CreateFrame("Frame", "frameCockpit", UIParent)
frameCockpit:SetPoint("Center", UIParent, "Center")
frameCockpit:SetSize(cols * iconbtn + (cols - 1) * ibr + 2 * obr, rows * iconbtn + (rows - 1) * cbr + 2 * obr)
frameCockpit:SetClampedToScreen( true )
frameCockpit:SetMovable(true)
frameCockpit:EnableMouse(true)
frameCockpit:RegisterForDrag("LeftButton")
frameCockpit:SetScript("OnDragStart", function( self )
	frameCockpit:StartMoving()
end)
frameCockpit:SetScript("OnDragStop", function( self )
	frameCockpit:StopMovingOrSizing()

	local point, parent, relativePoint, ofsx, ofsy = self:GetPoint()
			
	THTAB["frameCockpit" .. "point"] = point
	THTAB["frameCockpit" .. "parent"] = parent
	THTAB["frameCockpit" .. "relativePoint"] = relativePoint
	THTAB["frameCockpit" .. "ofsx"] = ofsx
	THTAB["frameCockpit" .. "ofsy"] = ofsy
end)
frameCockpit.texture = frameCockpit:CreateTexture(nil, "BACKGROUND")
frameCockpit.texture:SetColorTexture(0, 0, 0, 0.4)
frameCockpit.texture:SetAllPoints(frameCockpit)

frameCockpit.texture2 = frameCockpit:CreateTexture(nil, "BACKGROUND")
frameCockpit.texture2:SetColorTexture(0, 0, 0, 0.2)

function THRW(msg)
	if THBUILD ~= "RETAIL" and IsInRaid() and (UnitIsGroupAssistant("PLAYER") or UnitIsGroupLeader("PLAYER")) then
		SendChatMessage(msg, "RAID_WARNING")
	else
		if IsInInstance() then
			SendChatMessage(msg)
		else
			print("[TANK HELPER] " .. THGT("youmustbeinaninstance", nil, true) .. "!")
		end
	end
end

function THPullIn(t)
	if C_PartyInfo and C_PartyInfo.DoCountdown then
		C_PartyInfo.DoCountdown(t);
	end
	if IsInInstance() then
		local tab = {}
		tab["VALUE"] = t
		THRW(THGT("pullinx", tab))
		for i = 1, t do
			C_Timer.After( i, function()
				if t - i == 0 then
					THRW(THGT("go") .. "!")
				else
					THRW(t - i)
				end
			end )
		end
	else
		print("[TANK HELPER] " .. THGT("youmustbeinaninstance", nil, true) .. "!")
	end
end



function ResetIcons1()
	for i, v in pairs(ricons1) do
		if frameCockpit:IsShown() then
			v.bgtexture:SetTexture("")
		end
	end
end



function THUpdateRaidIcons()
	for i = 1, 9 do
		local rembtn = frameCockpit["btn" .. i].texture
		if i == 9 then
			if not GetRaidTargetIndex("TARGET") or GetRaidTargetIndex("TARGET") == 0 then
				rembtn:SetDesaturated(true);
			else
				rembtn:SetDesaturated(false);
			end
		else
			if ( not UnitExists("TARGET") ) then
				rembtn:SetDesaturated(true);
			else
				rembtn:SetDesaturated(false);
			end
		end
	end
end



local Y = 1
for i = 1, 9 do
	frameCockpit["btn" .. i] = CreateFrame("Button", "btn" .. i, frameCockpit)
	frameCockpit["btn" .. i]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (i - 1) * (iconbtn + ibr), -obr)
	frameCockpit["btn" .. i]:SetSize(iconbtn, iconbtn)

	frameCockpit["btn" .. i].bgtexture = frameCockpit["btn" .. i]:CreateTexture(nil, "OVERLAY")

	frameCockpit["btn" .. i].bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
	frameCockpit["btn" .. i].bgtexture:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
	frameCockpit["btn" .. i].bgtexture:SetSize(iconbtn * 1.2, iconbtn * 1.2)
	frameCockpit["btn" .. i].bgtexture:SetPoint("CENTER", frameCockpit["btn" .. i], "CENTER", 0, 0)
	frameCockpit["btn" .. i].bgtexture:SetVertexColor(1, 1, 0, THBORDERALPHA)

	frameCockpit["btn" .. i].texture = frameCockpit["btn" .. i]:CreateTexture(nil, "ARTWORK")
	if i < 9 then
		frameCockpit["btn" .. i].texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i);
	else
		frameCockpit["btn" .. i].texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
	end
	frameCockpit["btn" .. i].texture:SetSize(iconsize, iconsize)
	frameCockpit["btn" .. i].texture:SetPoint("CENTER", frameCockpit["btn" .. i], "CENTER", 0, 0)

	frameCockpit["btn" .. i]:RegisterForClicks("LeftButtonDown", "RightButtonDown")

	frameCockpit["btn" .. i]:SetScript("OnClick", function(self, btn, down)
		if btn == "LeftButton" then
			if i < 9 then
				SetRaidTarget("TARGET", i);
			else
				SetRaidTarget("TARGET", 0);
				THUpdateRaidIcons();
			end
		elseif btn == "RightButton" and i < 9 then
			ResetIcons1()
			if THGetConfig("autoselect", nil) ~= i then
				if frameCockpit:IsShown() then
					self.bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
				end
				THTAB["autoselect"] = i
			else
				THTAB["autoselect"] = nil
			end
		end
	end)
	table.insert(ricons1, frameCockpit["btn" .. i])

	-- Raid icon secondary
	if IsRaidMarkerActive then
		frameCockpit["btnwm" .. i] = CreateFrame("Button", "btnwm" .. i, frameCockpit, "SecureActionButtonTemplate")
		frameCockpit["btnwm" .. i]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (i - 1) * (iconbtn + ibr), -obr - iconbtn - cbr)
		frameCockpit["btnwm" .. i]:SetSize(iconbtn, iconbtn)

		frameCockpit["btnwm" .. i].texture = frameCockpit["btnwm" .. i]:CreateTexture(nil, "ARTWORK")
		frameCockpit["btnwm" .. i].texture:SetTexture("Interface\\RaidFrame\\Raid-WorldPing");
		frameCockpit["btnwm" .. i].texture:SetSize(iconsize, iconsize)
		frameCockpit["btnwm" .. i].texture:SetPoint("CENTER", frameCockpit["btnwm" .. i], "CENTER", 0, 0)
		frameCockpit["btnwm" .. i].texture:SetDrawLayer("ARTWORK", 1)

		frameCockpit["btnwm" .. i].texture2 = frameCockpit["btnwm" .. i]:CreateTexture(nil, "ARTWORK")
		if i < 9 then
			frameCockpit["btnwm" .. i].texture2:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i);
		else
			frameCockpit["btnwm" .. i].texture2:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
		end
		frameCockpit["btnwm" .. i].texture2:SetSize(iconsize / 1.2, iconsize / 1.2)
		frameCockpit["btnwm" .. i].texture2:SetPoint("BOTTOMLEFT", frameCockpit["btnwm" .. i], "BOTTOMLEFT", 0, 0)
		frameCockpit["btnwm" .. i].texture2:SetDrawLayer("ARTWORK", 2)
		frameCockpit["btnwm" .. i].texture2:SetVertexColor(1, 1, 1, 1)

		frameCockpit["btnwm" .. i]:SetAttribute("type", "macro")
		if i < 9 then
			frameCockpit["btnwm" .. i]:SetAttribute("macrotext1", "/wm " .. wms[i])
			frameCockpit["btnwm" .. i]:SetAttribute("macrotext2", "/cwm " .. wms[i])
		else
			frameCockpit["btnwm" .. i]:SetAttribute("macrotext1", "/cwm 0")
			frameCockpit["btnwm" .. i]:SetAttribute("macrotext2", "/cwm 0")
		end

		frameCockpit["btnwm" .. i]:RegisterForClicks("LeftButtonDown", "RightButtonDown")

		local btn = frameCockpit["btnwm" .. i]
		function btn.think()
			local btn1 = frameCockpit["btnwm" .. i].texture
			local btn2 = frameCockpit["btnwm" .. i].texture2

			if i < 9 then
				if IsRaidMarkerActive and frameCockpit["btnwm" .. i].status ~= IsRaidMarkerActive(wms[i]) then
					frameCockpit["btnwm" .. i].status = IsRaidMarkerActive(wms[i])

					updatewms = true

					if frameCockpit["btnwm" .. i].status == false then
						btn1:SetDesaturated(true);
						btn2:SetDesaturated(true);

						btn1:SetAlpha(0.5);
						btn2:SetAlpha(0.5);
					else
						btn1:SetDesaturated(false);
						btn2:SetDesaturated(false);

						btn1:SetAlpha(1);
						btn2:SetAlpha(1);
					end
				end
			elseif updatewms then
				updatewms = false
				local canremove = false
				for i = 1, 8 do
					if IsRaidMarkerActive and IsRaidMarkerActive(wms[i]) then
						canremove = true
						break
					end
				end
				if canremove == false then
					btn1:SetDesaturated(true);
					btn2:SetDesaturated(true);

					btn1:SetAlpha(0.5);
					btn2:SetAlpha(0.5);
				else
					btn1:SetDesaturated(false);
					btn2:SetDesaturated(false);

					btn1:SetAlpha(1);
					btn2:SetAlpha(1);
				end
			end
			C_Timer.After( 0.33, btn.think )
		end
		btn.think()
		
		table.insert(ricons2, frameCockpit["btnwm" .. i])
		Y = Y + 1
	end

	-- Pulltimer
	if i <= #pt then
		frameCockpit["btnp" .. i] = CreateFrame("Button", "btnp" .. i, frameCockpit, "UIPanelButtonTemplate")
		frameCockpit["btnp" .. i]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (i - 1) * (iconbtn + ibr), -obr - Y * (iconbtn + cbr))
		frameCockpit["btnp" .. i]:SetSize(iconbtn, iconbtn)
		frameCockpit["btnp" .. i]:SetText(pt[i])

		frameCockpit["btnp" .. i]:SetScript("OnClick", function(self, btn, down)
			THPullIn(pt[i])
		end)
	end
end

-- Ready Check
frameCockpit["btnReadycheck"] = CreateFrame("Button", "btnReadycheck", frameCockpit, "UIPanelButtonTemplate")
frameCockpit["btnReadycheck"]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (5 - 1) * (iconbtn + ibr), -obr - Y * (iconbtn + cbr))
if IsRaidMarkerActive or InitiateRolePoll then
	frameCockpit["btnReadycheck"]:SetSize(50, iconbtn)
	frameCockpit["btnReadycheck"]:SetText(string.sub(READY_CHECK, 1, 6))
else
	frameCockpit["btnReadycheck"]:SetSize(100, iconbtn)
	frameCockpit["btnReadycheck"]:SetText(string.sub(READY_CHECK, 1, 12))
end
frameCockpit["btnReadycheck"]:SetScript("OnClick", function(self, btn, down)
	DoReadyCheck();
end)

-- Role Check
if InitiateRolePoll then
	frameCockpit["btnRolepoll"] = CreateFrame("Button", "btnRolepoll", frameCockpit, "UIPanelButtonTemplate")
	frameCockpit["btnRolepoll"]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (5 - 1) * (iconbtn + ibr) + ibr + 50, -obr - Y * (iconbtn + cbr))
	frameCockpit["btnRolepoll"]:SetSize(50, iconbtn)
	frameCockpit["btnRolepoll"]:SetText(string.sub(ROLE_POLL, 1, 6))
	frameCockpit["btnRolepoll"]:SetScript("OnClick", function(self, btn, down)
		InitiateRolePoll();
	end)
end

-- Discord
frameCockpit["btnDiscord"] = CreateFrame("Button", "btnDiscord", frameCockpit, "UIPanelButtonTemplate")
frameCockpit["btnDiscord"]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + 100 + ibr + 100 + ibr, -obr - Y * (iconbtn + cbr))
frameCockpit["btnDiscord"]:SetSize(iconbtn, iconbtn)
frameCockpit["btnDiscord"]:SetText("D")
frameCockpit["btnDiscord"]:SetScript("OnClick", function(self, btn, down)
	local s = CreateFrame("Frame", nil, UIParent) -- or you actual parent instead
	s:SetSize(300, 2 * iconbtn + 2 * 10)
	s:SetPoint("CENTER")

	s.texture = s:CreateTexture(nil, "BACKGROUND")
	s.texture:SetColorTexture(0, 0, 0, 0.5)
	s.texture:SetAllPoints(s)

	s.text = s:CreateFontString(nil,"ARTWORK") 
	s.text:SetFont(STANDARD_TEXT_FONT, 11, "")
	s.text:SetText("Feedback")
	s.text:SetPoint("CENTER", s, "TOP", 0, -10)

	local eb = CreateFrame("EditBox", "logEditBox", s, "InputBoxTemplate")
	eb:SetFrameStrata("DIALOG")
	eb:SetSize(280, iconbtn)
	eb:SetAutoFocus(false)
	eb:SetText("https://discord.gg/UeBsafs")
	eb:SetPoint("TOPLEFT", 10, -10 - iconbtn)

	s.close = CreateFrame("Button", "closediscord", s, "UIPanelButtonTemplate")
	s.close:SetFrameStrata("DIALOG")
	s.close:SetPoint("TOPLEFT", 300 - 10 - iconbtn, -10)
	s.close:SetSize(iconbtn, iconbtn)
	s.close:SetText("X")
	s.close:SetScript("OnClick", function(self, btn, down)
		s:Hide()
	end)
end)



frameCockpit:RegisterEvent("PLAYER_ENTERING_WORLD")
frameCockpit:RegisterEvent("PLAYER_TARGET_CHANGED")
frameCockpit:RegisterEvent("RAID_TARGET_UPDATE")
frameCockpit:RegisterEvent("UNIT_HEALTH")
frameCockpit:RegisterEvent("UNIT_POWER_UPDATE")
frameCockpit:RegisterEvent("GROUP_ROSTER_UPDATE");
frameCockpit:RegisterEvent("RAID_ROSTER_UPDATE");
frameCockpit:HookScript("OnEvent", function(self, e, ...)
	--if not InCombatLockdown() then
	if e == "PLAYER_ENTERING_WORLD" then
		if THGetConfig("autoselect", nil) ~= nil then
			local btn = frameCockpit["btn" .. THGetConfig("autoselect", nil)]
			if frameCockpit:IsShown() then
				btn.bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
			end
		end
	end

	if e == "PLAYER_ENTERING_WORLD" or e == "PLAYER_TARGET_CHANGED" or e == "RAID_TARGET_UPDATE" then
		THUpdateRaidIcons()
	end

	if e == "PLAYER_TARGET_CHANGED" then
		if UnitExists("TARGET") and UnitIsEnemy("TARGET", "PLAYER") then--and GetRaidTargetIndex("TARGET") == nil and id ~= nil then
			if (GetRaidTargetIndex("TARGET") == nil) and THGetConfig("autoselect", nil) ~= nil then
				SetRaidTarget("TARGET", THGetConfig("autoselect", nil));
			end
		end
	end

	if e == "UNIT_HEALTH" or e == "UNIT_POWER_UPDATE" or e == "GROUP_ROSTER_UPDATE" or e == "RAID_ROSTER_UPDATE" then
		THSetStatusText()
	end
end)



frameStatus = CreateFrame("Frame", "frameStatus", UIParent)
frameStatus:SetPoint("Center", UIParent, "Center")
frameStatus:SetSize(frameCockpit:GetWidth(), 1 * iconbtn + 4 * obr)
frameStatus:SetClampedToScreen( true )
frameStatus:SetMovable(true)
frameStatus:EnableMouse(true)
frameStatus:RegisterForDrag("LeftButton")
frameStatus:SetScript("OnDragStart", function( self )
	frameStatus:StartMoving()
end)
frameStatus:SetScript("OnDragStop", function( self )
	frameStatus:StopMovingOrSizing()

	local point, parent, relativePoint, ofsx, ofsy = self:GetPoint()
	
	THTAB["frameStatus" .. "point"] = point
	THTAB["frameStatus" .. "parent"] = parent
	THTAB["frameStatus" .. "relativePoint"] = relativePoint
	THTAB["frameStatus" .. "ofsx"] = ofsx
	THTAB["frameStatus" .. "ofsy"] = ofsy
end)

frameStatus.texture = frameStatus:CreateTexture(nil, "BACKGROUND")
frameStatus.texture:SetColorTexture(0, 0, 0, 0.3)
frameStatus.texture:SetAllPoints(frameStatus)

frameStatus.text = frameStatus:CreateFontString(nil,"ARTWORK") 
frameStatus.text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
frameStatus.text:SetText("")
frameStatus.text:SetPoint("CENTER", frameStatus, "CENTER", 0, 0)

frameDesign = CreateFrame("Frame", "frameDesign", UIParent)
function THDesignThink()
	if not InCombatLockdown() then
		if THGetConfig("hidestatus", false) then
			frameStatus:Hide()
		else
			if UnitInParty("PLAYER") or UnitInRaid("PLAYER") then
				frameStatus:Show()
			else
				frameStatus:Hide()
			end
		end

		frameCockpit:SetMovable(not THGetConfig("fixposition", false))
		frameCockpit:EnableMouse(not THGetConfig("fixposition", false))
		frameStatus:SetMovable(not THGetConfig("fixposition", false))
		frameStatus:EnableMouse(not THGetConfig("fixposition", false))
	end

	C_Timer.After( 0.33, THDesignThink )
end
C_Timer.After( 0.1, THDesignThink )



local THStatusColor = { 1, 1, 1, 1 }
function THSetStatusText()
	if frameCockpit == nil or frameStatus == nil then
		return
	end
	
	if not THGetConfig("hidestatus", false) then
		local text = THGT("ready", nil, true) .. "!"
		THStatusColor = {0, 1, 0, 0.5}

		if InCombatLockdown() then
			text = GARRISON_LANDING_STATUS_MISSION_COMBAT .. "!"
			THStatusColor = {1, 0, 0, 0.75}
		else
			local health = 1
			local power = 1
			local dead = false

			if UnitExists("PLAYER") then --not UnitIsDead("PARTY" .. i) then
				local percent = UnitHealth("PLAYER") / UnitHealthMax("PLAYER")
				if percent < health then
					health = percent
				end

				local powertype = UnitPowerType("PLAYER")
				local percent2 = UnitPower("PLAYER") / UnitPowerMax("PLAYER")
				if powertype == 0 and percent2 < power then
					power = percent2
				end
				
				if UnitIsDead("PLAYER") then
					dead = true
				end
			end

			for i = 1, 4 do
				if UnitExists("PARTY" .. i) then --not UnitIsDead("PARTY" .. i) then
					local percent = UnitHealth("PARTY" .. i) / UnitHealthMax("PARTY" .. i)
					if percent < health then
						health = percent
					end

					local powertype = UnitPowerType("PARTY" .. i)
					if powertype == 0 and UnitPower("PARTY" .. i) > 0 and UnitPowerMax("PARTY" .. i) > 0 then
						if UnitPower("PARTY" .. i) / UnitPowerMax("PARTY" .. i) < power then
							power = UnitPower("PARTY" .. i) / UnitPowerMax("PARTY" .. i)
						end
					end

					if UnitIsDead("PARTY" .. i) then
						dead = true
					end
				end
			end

			if dead then
				text = THGT("playerdead", nil, true) .. "!"
				THStatusColor = {0, 0, 0, 1}
			elseif health < 0.3 then
				text = THGT("playerlowhp", nil, true) .. "!"
				THStatusColor = {1, 0, 0, 1 - health + 0.1}
			elseif health < 0.9 then
				text = THGT("playernotfull", nil, true) .. "!"
				THStatusColor = {1, 0, 0, 1 - health + 0.1}
			elseif power < 0.9 then
				text = THGT("playerhavenotenoughpower", nil, true) .. "!"
				THStatusColor = {0, 0, 1, 1 - power + 0.1}
			end
		end
		
		frameStatus.text:SetText( text )
		if frameStatus.texture.SetColorTexture and THStatusColor[1] and THStatusColor[2] and THStatusColor[3] then
			frameStatus.texture:SetColorTexture( THStatusColor[1], THStatusColor[2], THStatusColor[3], THStatusColor[4] )
		end
	end
end



function THUpdatePosAndSize()
	if THTAB["obr"] ~= nil and THTAB["obr"] >= 16 then
		THTAB["obr"] = 6
	end
	if THTAB["ibr"] ~= nil and THTAB["ibr"] >= 16 then
		THTAB["ibr"] = 1
	end
	if THTAB["cbr"] ~= nil and THTAB["cbr"] >= 16 then
		THTAB["cbr"] = 3
	end
	obr = THGetConfig("obr", 6) 				-- Outer Border
	ibr = THGetConfig("ibr", 1) 				-- Column Spacer
	cbr = THGetConfig("cbr", 3) 				-- Row Spacer
	iconsize = THGetConfig("iconsize", 16)
	iconbr = iconsize / 4
	iconbtn = iconsize + 2 * iconbr

	local THROW = 1
	
	frameCockpit:SetSize(cols * iconbtn + (cols - 1) * ibr + 2 * obr, rows * iconbtn + (rows - 1) * cbr + 2 * obr)
	frameCockpit.texture:SetAllPoints(frameCockpit)
	local sw, sh = frameCockpit:GetSize()
	frameCockpit.texture2:SetSize(sw - 2 * obr, sh - 2 * obr)
	frameCockpit.texture2:SetPoint("CENTER", frameCockpit, "CENTER", 0, 0)

	for i = 1, 9 do
		frameCockpit["btn" .. i]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (i - 1) * (iconbtn + ibr), -obr)
		frameCockpit["btn" .. i]:SetSize(iconbtn, iconbtn)

		frameCockpit["btn" .. i].texture:SetPoint("CENTER", frameCockpit["btn" .. i], "CENTER", 0, 0)
		frameCockpit["btn" .. i].texture:SetSize(iconsize, iconsize)
	end

	if IsRaidMarkerActive then
		THROW = THROW + 1
		for i = 1, 9 do
			frameCockpit["btnwm" .. i]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (i - 1) * (iconbtn + ibr), -obr - iconbtn - cbr)
			frameCockpit["btnwm" .. i]:SetSize(iconbtn, iconbtn)

			frameCockpit["btnwm" .. i].texture:SetPoint("CENTER", frameCockpit["btnwm" .. i], "CENTER", 0, 0)
			frameCockpit["btnwm" .. i].texture:SetSize(iconsize, iconsize)

			frameCockpit["btnwm" .. i].texture2:SetPoint("BOTTOMLEFT", frameCockpit["btnwm" .. i], "BOTTOMLEFT", 0, 0)
			frameCockpit["btnwm" .. i].texture2:SetSize(iconsize / 1.2, iconsize / 1.2)
		end
	end
	
	for i = 1, 9 do
		if i <= #pt then
			frameCockpit["btnp" .. i]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (i - 1) * (iconbtn + ibr), -obr - THROW * (iconbtn + cbr))
			frameCockpit["btnp" .. i]:SetSize(iconbtn, iconbtn)
		end
	end

	local bw = obr + (5 - 1) * (iconbtn + ibr) 	-- Before width
	local aw = obr + iconbtn + ibr				-- After width
	local bsw = frameCockpit:GetWidth() - bw - aw  -- Button size width
	if IsRaidMarkerActive or InitiateRolePoll then
		bsw = bsw - ibr 	-- Space between the two
		bsw = bsw / 2		-- Two buttons
	end

	frameCockpit["btnReadycheck"]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (5 - 1) * (iconbtn + ibr), -obr - THROW * (iconbtn + cbr))
	frameCockpit["btnReadycheck"]:SetSize(bsw, iconbtn)

	if IsRaidMarkerActive then
		frameCockpit["btnRolepoll"]:SetPoint("TOPLEFT", frameCockpit, "TOPLEFT", obr + (5 - 1) * (iconbtn + ibr) + ibr + bsw, -obr - THROW * (iconbtn + cbr))
		frameCockpit["btnRolepoll"]:SetSize(bsw, iconbtn)
	end
	
	frameCockpit["btnDiscord"]:ClearAllPoints()
	frameCockpit["btnDiscord"]:SetSize(iconbtn, iconbtn)
	frameCockpit["btnDiscord"]:SetPoint("BOTTOMRIGHT", frameCockpit, "BOTTOMRIGHT", -obr, obr)

	frameStatus:SetSize(frameCockpit:GetWidth(), 1 * iconbtn + 4 * obr)

	ResetIcons1()
	C_Timer.After( 1, function()
		if THGetConfig("autoselect", nil) ~= nil then
			local btn = frameCockpit["btn" .. THGetConfig("autoselect", nil)]
			if frameCockpit:IsShown() then
				btn.bgtexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
			end
		end
	end )

	local point = THTAB["frameCockpit" .. "point"]
	local parent = THTAB["frameCockpit" .. "parent"]
	local relativePoint = THTAB["frameCockpit" .. "relativePoint"]
	local ofsx = THTAB["frameCockpit" .. "ofsx"]
	local ofsy = THTAB["frameCockpit" .. "ofsy"]
	if point and frameCockpit then
		frameCockpit:ClearAllPoints()
		frameCockpit:SetPoint( point, parent, relativePoint, ofsx, ofsy )
	end

	point = THTAB["frameStatus" .. "point"]
	parent = THTAB["frameStatus" .. "parent"]
	relativePoint = THTAB["frameStatus" .. "relativePoint"]
	ofsx = THTAB["frameStatus" .. "ofsx"]
	ofsy = THTAB["frameStatus" .. "ofsy"]
	if point and frameStatus then
		frameStatus:ClearAllPoints()
		frameStatus:SetPoint( point, parent, relativePoint, ofsx, ofsy )
	end
end



function THSetup()
	if not InCombatLockdown() then
		THUpdatePosAndSize()
		THSetStatusText()
	else
		C_Timer.After( 0.15, THSetup )
	end
end



-- NAMEPLATE 
local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_CREATED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")

function THUpdateThreatStatus( np, reset )
	if np.UnitFrame == nil then
		C_Timer.After( 0.1, function()
			THUpdateThreatStatus( np, reset )
		end )
		return
	end
	local unit = np.UnitFrame.unit
	if unit then
		if np and np.th_threat ~= nil then
			local isTanking, status, scaledPercentage, rawPercentage, threatValue = UnitDetailedThreatSituation( "PLAYER", unit )

			if THGetConfig( "nameplatethreat", true ) and scaledPercentage and not reset then
				scaledPercentage = tonumber( string.format( "%.0f", scaledPercentage ) )

				np.th_threat.text:SetText( scaledPercentage .. "%" )
				if scaledPercentage > 100 then
					np.th_threat.texture:SetTexture( "Interface\\COMMON\\Indicator-Yellow" )
					np.th_threat.texture:SetTexCoord( 0, 1, 0, 1 )
					np.th_threat.texture:SetAlpha( 1 )
					np.th_threat.text:SetTextColor( 1, 1, 0, 1 )
				elseif scaledPercentage == 100 then
					np.th_threat.texture:SetTexture( "Interface\\MINIMAP\\Minimap_shield_normal" )
					np.th_threat.texture:SetTexCoord( 0, 1, 0, 1 )
					np.th_threat.texture:SetAlpha( 0.33 )
					np.th_threat.text:SetTextColor( 0, 1, 0, 0.33 )
				elseif scaledPercentage == 0 then
					np.th_threat.texture:SetTexture( "Interface\\WORLDSTATEFRAME\\CombatSwords" )
					np.th_threat.texture:SetTexCoord( 0, 0.5, 0, 0.5 )
					np.th_threat.texture:SetAlpha( 1 )
					np.th_threat.text:SetTextColor( 1, 0, 0, 1 )
				else
					np.th_threat.texture:SetTexture( "Interface\\WORLDSTATEFRAME\\CombatSwords" )
					np.th_threat.texture:SetTexCoord( 0, 0.5, 0, 0.5 )
					np.th_threat.texture:SetAlpha( 1 )
					np.th_threat.text:SetTextColor( 1, 1, 0, 1 )
				end
			else
				np.th_threat.text:SetText( -1 .. "%" )

				np.th_threat.texture:SetTexture( nil )
				np.th_threat.texture:SetTexCoord( 0, 1, 0, 1 )
				np.th_threat.texture:SetAlpha( 0 )
				np.th_threat.text:SetTextColor( 0, 0, 0, 0 )
			end
		end
	end

	C_Timer.After( 0.1, function()
		THUpdateThreatStatus( np, reset )
	end )
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "NAME_PLATE_CREATED" then
		local np = select(1, ...)
		if np.th_threat == nil then
			np.th_threat = CreateFrame( "FRAME", nil, np )
			np.th_threat:SetSize( 1, 1 )
			np.th_threat:SetPoint( "CENTER", np, "CENTER", 0, 0 )
			--np.th_threat:SetIgnoreParentAlpha( true )
			
			np.th_threat.texture = np:CreateTexture( nil, "OVERLAY" )
			np.th_threat.texture:SetSize(42, 42)
			np.th_threat.texture:SetPoint( "CENTER", np.th_threat, "TOP", 0, 70 )
			
			np.th_threat.text = np:CreateFontString( nil, "OVERLAY" ) 
			np.th_threat.text:SetFont( STANDARD_TEXT_FONT, 12, "THINOUTLINE" )
			np.th_threat.text:SetText( "CREATED" )
			np.th_threat.text:SetPoint( "CENTER", np.th_threat, "TOP", 0, 70 )

			THUpdateThreatStatus( np )
		end
    end
end)
