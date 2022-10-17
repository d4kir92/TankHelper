-- enUS English

thlang = thlang or {}
ethlang = ethlang or {}

function THthlang_enUS()
	-- Pulltimer
	thlang.pullinx = "Pull in VALUE"
	thlang.go = "GO"
	
	-- Status
	thlang.ready = "Ready"
	thlang.youmustbeinaninstance = "You must be in an Instance"
	thlang.playerdead = "Player dead"
	thlang.playerlowhp = "Player low hp"
	thlang.playernotfull = "Player not full"
	thlang.playerhavenotenoughpower = "Player have not enough power"

	--Settings
	thlang.showalways = "Show Always"
	thlang.showtranslation = "Show Translation"
	thlang.ibr = "Column Spacing: VALUE"
	thlang.cbr = "Row Spacing: VALUE"
	thlang.obr = "Outer Border: VALUE"
	thlang.iconsize = "Icon Size: VALUE"
	thlang.fixposition = "Fixed Position"
	thlang.hidestatus = "Hide Status Frame"
	thlang.nameplatethreat = "Show Nameplate Threat"
	
	for i, v in pairs(thlang) do
		ethlang[i] = v
	end
end
THthlang_enUS()

