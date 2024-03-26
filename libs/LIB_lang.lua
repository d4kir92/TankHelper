local _, TankHelper = ...
local thlang = {}
local ethlang = {}
function TankHelper:GetLangTab()
	return thlang
end

function TankHelper:GetELangTab()
	return ethlang
end

function TankHelper:GT(str, force)
	local strid = string.lower(str)
	local result = thlang[strid]
	local eng = ethlang[strid]
	if result ~= nil and eng ~= nil then
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
	elseif GetLocale() == "zhCN" then
		TankHelper:LangzhCN()
	elseif GetLocale() == "zhTW" then
		TankHelper:LangzhTW()
	end
end

TankHelper:UpdateLanguage()