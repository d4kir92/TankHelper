local _, TankHelper = ...
function TankHelper:CreateDropdown(opts)
	local Menu = LibStub("LibDropDown"):NewButton(opts.parent, "MyMenuButton")
	Menu:SetPoint("TOPLEFT", 0, -4)
	Menu:SetJustifyH("LEFT")
	Menu:SetStyle("DEFAULT")
	Menu:SetText(opts.defaultVal)
	for i, v in pairs(opts.items) do
		Menu:Add(
			{
				text = v.Name,
				args = {i, v.Code},
				func = function(sel, button, key, value)
					opts.changeFunc(Menu, value)
					Menu:SetText(D4:Trans(value))
				end
			}
		)
	end

	local text = Menu:CreateFontString(nil, "ARTWORK")
	text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
	text:SetPoint("LEFT", Menu, "RIGHT", 0, 4)
	if opts.title then
		text:SetText(D4:Trans(opts.title))
	end

	return Menu
end
