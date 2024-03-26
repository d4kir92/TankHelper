-- deDE German Deutsch
local _, TankHelper = ...
function TankHelper:LangdeDE()
	local thlang = TankHelper:GetLangTab()
	-- Pulltimer
	thlang.pullinx = "Angriff in %0.1f"
	thlang.go = "LOS"
	thlang.auto = "Automatisch"
	thlang.onlythirdparty = "Von anderen Addons den Countdown verwenden"
	thlang.onlyth = "Von Tank Helper den Countdown verwenden"
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
	thlang.targettingdelay = "Verzögerung bei der Zielerfassung: %0.1f"
	thlang.scalecockpit = "Skalierung Cockpit: %0.1f"
	thlang.scalestatus = "Skalierung Status: %0.1f"
	thlang.ibr = "Spaltenabstand: %0.1f"
	thlang.cbr = "Zeilenabstand: %0.1f"
	thlang.obr = "Äußere Grenze: %0.1f"
	thlang.iconsize = "Symbolgröße: %0.1f"
	thlang.fixposition = "Fixierte Position"
	thlang.hidestatus = "Statusfenster verstecken"
	thlang.nameplatethreat = "Zeige Namenschild Bedrohung"
	thlang.pulltimermode = "Pulltimer Modus"
	thlang.onlytank = "Automatische Kennzeichnung nur als Tank"
	thlang.hidelastrow = "Letzte Reihe ausblenden"
	thlang.brcolor = "Randfarbe"
	thlang.bgcolor = "Hintergrundfarbe"
	thlang.healthmax = "Status - Warnung bis %0.1f%% Gesundheit"
	thlang.powermax = "Status - Warnung bis %0.1f%% Mana"
	thlang.statusonlyhealers = "Status - Nur Heiler info anzeigen"
	thlang.healer = "Heiler"
	thlang.combineall = "Alle Leisten verbinden"
	thlang.fixedpositionisenabled = "Fixierte Position ist aktiviert"
end