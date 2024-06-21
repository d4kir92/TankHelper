local _, TankHelper = ...
TankHelper:SetAddonOutput("TankHelper", 132362)
function TankHelper:GetConfig(str, val)
	local setting = val
	THTAB = THTAB or {}
	if THTAB[str] == nil then
		THTAB[str] = val
	end

	setting = THTAB[str]

	return setting
end
