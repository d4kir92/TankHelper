-- LIB Design
local _, TankHelper = ...
function TankHelper:CreateText(tab)
	tab.textsize = tab.textsize or 12
	local text = tab.frame:CreateFontString(nil, "ARTWORK")
	tab.frame:SetFrameStrata("HIGH")
	text:SetFont(STANDARD_TEXT_FONT, tab.textsize, "OUTLINE")
	text:SetPoint("TOPLEFT", tab.parent, "TOPLEFT", tab.x, tab.y)
	text:SetText(TankHelper:Trans(tab.text))
	tab.color = tab.color or {1, 1, 1, 1}
	tab.color[1] = tab.color[1] or 1
	tab.color[2] = tab.color[2] or 1
	tab.color[3] = tab.color[3] or 1
	tab.color[4] = tab.color[4] or 1
	text:SetTextColor(tab.color[1], tab.color[2], tab.color[3], tab.color[4])

	return text
end

function TankHelper:CreateCheckBox(tab)
	tab = tab or {}
	tab.parent = tab.parent or UIParent
	tab.tooltip = tab.tooltip or ""
	tab.x = tab.x or 0
	tab.y = tab.y or 0
	local CB = CreateFrame("CheckButton", nil, tab.parent, "ChatConfigCheckButtonTemplate")
	CB:SetPoint("TOPLEFT", tab.x, tab.y)
	CB.tooltip = tab.tooltip
	CB:SetChecked(tab.checked)
	CB:SetScript(
		"OnClick",
		function(sel)
			local status = CB:GetChecked()
			sel:SetChecked(status)
			THTAB[tab.dbvalue] = status
			if tab.func ~= nil then
				tab:func()
			end
		end
	)

	tab.frame = CB
	tab.x = tab.x + 26
	tab.y = tab.y - 6
	tab.color = tab.color or {1, 1, 1, 1}
	CB.text = TankHelper:CreateText(tab)

	return CB
end

function TankHelper:CreateSlider(tab)
	tab = tab or {}
	tab.parent = tab.parent or UIParent
	tab.x = tab.x or 0
	tab.y = tab.y or 0
	tab.w = tab.w or 600
	tab.value = tab.value or 0
	local percentage = tab.percentage or false
	local SL = CreateFrame("Slider", tab.name, tab.parent, "OptionsSliderTemplate")
	SL:SetPoint("TOPLEFT", tab.x, tab.y)
	SL.Low:SetText(tab.min)
	SL.High:SetText(tab.max)
	local v = tab.value
	if percentage then
		v = v * 100
	end

	if tab.text then
		SL.Text:SetText(format(TankHelper:Trans(tab.text), v))
	end

	SL:SetMinMaxValues(tab.min, tab.max)
	SL:SetValue(tab.value)
	SL:SetWidth(tab.w)
	SL:SetObeyStepOnDrag(tab.steps)
	tab.steps = tab.steps or 1
	SL:SetValueStep(tab.steps)
	SL.decimals = tab.decimals or 1
	SL:SetScript(
		"OnValueChanged",
		function(sel, val)
			val = TankHelper:MathR(val, sel.decimals)
			val = val - val % tab.steps
			val = TankHelper:MathR(val, sel.decimals)
			THTAB[tab.dbvalue] = val
			local valu = SL:GetValue()
			if valu then
				if percentage then
					valu = valu * 100
				end

				if tab.text then
					SL.Text:SetText(format(TankHelper:Trans(tab.text), valu))
				end
			end

			if tab.func ~= nil then
				tab:func()
			end
		end
	)

	return EB
end

function TankHelper:CTexture(frame, tab)
	tab.layer = tab.layer or "BACKGROUND"
	local texture = frame:CreateTexture(nil, tab.layer)
	tab.texture = tab.texture or ""
	tab.color = tab.color or {}
	if tab.texture ~= "" then
		tab.color.r = tab.color.r or 1
		tab.color.g = tab.color.g or 1
		tab.color.b = tab.color.b or 1
		tab.color.a = tab.color.a or 1
		texture:SetTexture(tab.texture)
		texture:SetVertexColor(tab.color.r, tab.color.g, tab.color.b, tab.color.a)
	elseif tab.color ~= nil then
		tab.color.r = tab.color.r or 1
		tab.color.g = tab.color.g or 1
		tab.color.b = tab.color.b or 1
		tab.color.a = tab.color.a or 1
		texture:SetColorTexture(tab.color.r, tab.color.g, tab.color.b, tab.color.a)
	else
		texture:SetTexture(tab.texture)
	end

	if tab.autoresize then
		texture:SetAllPoints(frame)
	else
		tab.w = tab.w or frame:GetWidth()
		tab.h = tab.h or frame:GetHeight()
		texture:SetSize(tab.w, tab.h)
		tab.x = tab.x or 0
		tab.y = tab.y or 0
		texture:SetPoint(tab.align or "TOPLEFT", frame, tab.x, tab.y)
	end

	return texture
end

function TankHelper:CreateF(tab)
	tab.w = tab.w or 2
	tab.h = tab.h or 2
	tab.x = tab.x or 0
	tab.y = tab.y or 0
	tab.align = tab.align or "CENTER"
	tab.text = tab.text or "Unnamed"
	tab.textalign = tab.textalign or "CENTER"
	tab.textsize = tab.textsize or tonumber(string.format("%.0f", tab.h * 0.69))
	tab.parent = tab.parent or UIParent
	local frame = CreateFrame("FRAME", tab.name, tab.parent)
	frame:SetWidth(tab.w)
	frame:SetHeight(tab.h)
	frame:SetPoint(tab.align, tab.parent, tab.align, tab.x, tab.y)
	tab.layer = tab.layer or "BACKGROUND"
	frame.texture = TankHelper:CTexture(frame, tab)
	tab.textlayer = tab.textlayer or "ARTWORK"
	frame.text = frame:CreateFontString(nil, tab.textlayer)
	if tab.framestrata ~= nil then
		frame:SetFrameStrata(tab.framestrata)
	else
		frame:SetFrameStrata("HIGH")
	end

	frame.text:SetFont(STANDARD_TEXT_FONT, tab.textsize, "")
	frame.text:SetShadowColor(0, 0, 0, 0.8)
	frame.text:SetShadowOffset(1, -1)
	frame.text:SetPoint(tab.textalign, 0, 0)
	frame.text:SetText(tab.text)
	function frame:SetText(text)
		frame.text:SetText(text)
	end

	frame.oldSetSize = frame.SetSize
	function frame:SetSize(w, h)
		frame:oldSetSize(w, h)
		self.texture:SetSize(w, h)
	end

	return frame
end

function TankHelper:CreateDropDown(tab)
	tab = tab or {}
	tab.parent = tab.parent or UIParent
	tab.tooltip = tab.tooltip or ""
	tab.x = tab.x or 0
	tab.y = tab.y or 0
	local rows = {
		["name"] = tab.name,
		["parent"] = tab.parent,
		["title"] = tab.text,
		["items"] = tab.tab,
		["defaultVal"] = tab.value,
		["changeFunc"] = function(dropdown_frame, dropdown_val)
			--dropdown_val = tonumber( dropdown_val )
			THTAB[tab.dbvalue] = dropdown_val
		end
	}

	local DD = TankHelper:CreateDropdown(rows)
	DD:SetPoint("TOPLEFT", tab.parent, "TOPLEFT", tab.x, tab.y)

	return DD
end
