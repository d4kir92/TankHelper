
thlang = thlang or {}
ethlang = ethlang or {}

function THGT(str, tab, force)
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
		elseif THGetConfig("showtranslation", true) and GetLocale() ~= "enUS" then
			return result
		else
			return eng
		end
	else
		return str
	end
end

function THUpdatethlanguage()
	THthlang_enUS()
	if GetLocale() == "enUS" then
		THthlang_enUS()
	elseif GetLocale() == "deDE" then
		THthlang_deDE()
	elseif GetLocale() == "koKR" then
		THthlang_koKR()
	elseif GetLocale() == "ruRU" then
		THthlang_ruRU()
	elseif GetLocale() == "zhTW" then
		THthlang_zhTW()
	end
end
THUpdatethlanguage()
