
local AddOnName, TankHelper = ...

local thlang = {}
local ethlang = {}

function TankHelper:GetLangTab()
	return thlang
end

function TankHelper:GetELangTab()
	return ethlang
end

function TankHelper:GT(str, tab, force)
	local strid = string.lower(str)
	local result = thlang[strid]
	local eng = ethlang[strid]
	if result ~= nil and eng ~= nil then
		if tab ~= nil then
			for i, v in pairs(tab) do
				local find = i
				local replace = v
				if find ~= nil and replace ~= nil then
					result = string.gsub(result, find, replace)
					eng = string.gsub(eng, find, replace)
				end
			end
		end
		if force then
			return result
		elseif TankHelper:GetConfig("showtranslation", true) and GetLocale() ~= "enUS" then
			return result
		else
			return eng
		end
	else
		return str
	end
end

function TankHelper:UpdateLanguage()
	TankHelper:LangenUS()
	if GetLocale() == "enUS" then
		TankHelper:LangenUS()
	elseif GetLocale() == "deDE" then
		TankHelper:LangdeDE()
	elseif GetLocale() == "koKR" then
		TankHelper:LangkoKR()
	elseif GetLocale() == "ruRU" then
		TankHelper:LangruRU()
	elseif GetLocale() == "zhTW" then
		TankHelper:LangzhTW()
	end
end
TankHelper:UpdateLanguage()
