-- enUS English
local _, TankHelper = ...

function TankHelper:LangenUS()
	local thlang = TankHelper:GetLangTab()
	local ethlang = TankHelper:GetELangTab()
	-- Pulltimer
	thlang.pullinx = "Pull in %0.1f"
	thlang.go = "GO"
	thlang.auto = "Automatic"
	thlang.onlythirdparty = "Use countdown from other addons"
	thlang.onlyth = "Use Tank Helper countdown"
	thlang.both = "Use Both"
	-- Status
	thlang.ready = "Ready"
	thlang.youmustbeinaninstance = "You must be in an Instance"
	thlang.youmustbeinagrouporaraid = "You must be in a group or a raid"
	thlang.playerdead = "Player dead"
	thlang.playerlowhp = "Player low hp"
	thlang.playernotfull = "Player not full"
	thlang.playerhavenotenoughpower = "Player have not enough power"
	--Settings
	thlang.showalways = "Show Always"
	thlang.showtranslation = "Show Translation"
	thlang.targettingdelay = "Targetting Delay: %0.1f"
	thlang.scalecockpit = "Scale Cockpit: %0.1f"
	thlang.scalestatus = "Scale Status: %0.1f"
	thlang.ibr = "Column Spacing: %0.1f"
	thlang.cbr = "Row Spacing: %0.1f"
	thlang.obr = "Outer Border: %0.1f"
	thlang.iconsize = "Icon Size: %0.1f"
	thlang.fixposition = "Fixed Position"
	thlang.hidestatus = "Hide Status Frame"
	thlang.nameplatethreat = "Show Nameplate Threat"
	thlang.pulltimermode = "Pulltimer Mode"
	thlang.onlytank = "Automatic marking as tank only"
	thlang.hidelastrow = "Hide last row"
	thlang.brcolor = "Border Color"
	thlang.bgcolor = "Background Color"
	thlang.healthmax = "Status - Warning till %0.1f%% Health"
	thlang.powermax = "Status - Warning till %0.1f%% Mana"
	thlang.statusonlyhealers = "Status - Show Only Healers Info"
	thlang.healer = "Healer"

	for i, v in pairs(thlang) do
		ethlang[i] = v
	end
end