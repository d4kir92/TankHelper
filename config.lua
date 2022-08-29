-- By D4KiR

THname = "Tank Helper"
THcolorname = "|c008888ff"
THauthor = "D4KiR"
THcolorauthor = "|c0000ffff"

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
