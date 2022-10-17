
THname = THname or "X"

function THmsg(str)
	print("|c0000ffff" .. "[" .. "|cff8888ff" .. THname .. "|c0000ffff" .. "] " .. str)
end

function THdeb(str)
	if THdebUG then
		print("[DEB] " .. str)
	end
end

function pTab(tab)
	print("pTab", tab)
	if type(tab) == "table" then
		for i, v in pairs(tab) do
			if type(v) == "table" then
				pTab(v)
			else
				print(i, v)
			end
		end
	else
		print(tab)
	end
	print("----------------------------------")
end

function stringR(num, dec)
	local d = dec
	if dec == nil then
		d = 2
	end
	return string.format("%." .. d .. "f", num)
end