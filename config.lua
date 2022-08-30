-- By D4KiR

THname = "TankHelper |T132362/:16:16:0:0|t by |cFFAAAAFFD4KiR |T132115/:16:16:0:0|t"

SetCVar("ScriptErrors", 1)

function THGetConfig(str, val)
	local setting = val

	THTAB = THTAB or {}

	if THTAB[str] == nil then
		THTAB[str] = val
	end
	setting = THTAB[str]

	return setting
end
