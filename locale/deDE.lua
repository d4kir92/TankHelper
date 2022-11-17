-- deDE German Deutsch

local AddOnName, TankHelper = ...

function TankHelper:LangdeDE()
	local thlang = TankHelper:GetLangTab()

	-- Pulltimer
	thlang.pullinx = "Angriff in VALUE"
	thlang.go = "LOS"
	thlang.auto = "Automatisch"
	thlang.onlythirdparty = "Countdown von anderen Addons verwenden"
	thlang.onlyth = "Countdown von Tank Helper verwenden"
	thlang.both = "Beide verwenden"

	-- Status
	thlang.ready = "Bereit"
	thlang.youmustbeinaninstance = "Du musst in einer Instanz sein"
	thlang.youmustbeinagrouporaraid = "Du musst in einer Gruppe oder einem Schlachtzug sein"
	thlang.playerdead = "Spieler tot"
	thlang.playerlowhp = "Spieler mit wenig Gesundheit"
	thlang.playernotfull = "Spieler ist nicht voll"
	thlang.playerhavenotenoughpower = "Spieler hat nicht genug Kraft"

	--Settings
	thlang.showalways = "Immer anzeigen"
	thlang.showtranslation = "Übersetzung anzeigen"
	thlang.ibr = "Spaltenabstand: VALUE"
	thlang.cbr = "Zeilenabstand: VALUE"
	thlang.obr = "Äußere Grenze: VALUE"
	thlang.iconsize = "Symbolgröße: VALUE"
	thlang.fixposition = "Fixierte Position"
	thlang.hidestatus = "Statusfenster verstecken"
	thlang.nameplatethreat = "Zeige Namenschild Bedrohung"
end
