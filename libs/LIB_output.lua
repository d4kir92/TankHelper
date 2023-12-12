local _, TankHelper = ...
local THDebug = false
function TankHelper:MSG(msg)
	print("|cff3FC7EB" .. "[TankHelper |T132362:16:16:0:0|t]|r " .. msg)
end

function TankHelper:deb(str)
	if THDebug then
		print("[DEB] " .. str)
	end
end