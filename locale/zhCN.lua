-- zhCN Simplified Chinese
local _, TankHelper = ...
function TankHelper:LangzhCN()
	local thlang = TankHelper:GetLangTab()
	-- Pulltimer
	thlang.pullinx = "%0.1f 秒后开怪"
	thlang.go = "上"
	thlang.auto = "自动"
	thlang.onlythirdparty = "使用其他插件的倒计时"
	thlang.onlyth = "使用坦克助手倒计时"
	thlang.both = "同时使用两者"
	-- Status
	thlang.ready = "就位"
	thlang.youmustbeinaninstance = "你必须在一个副本中"
	thlang.youmustbeinagrouporaraid = "你必须在一个小队或团队中"
	thlang.playerdead = "玩家死亡"
	thlang.playerlowhp = "玩家低血量"
	thlang.playernotfull = "玩家血量未满"
	thlang.playerhavenotenoughpower = "玩家法力不足"
	--Settings
	thlang.showalways = "总是显示"
	thlang.showtranslation = "显示翻译"
	thlang.targettingdelay = "目标标记延迟：%0.1f"
	thlang.scalecockpit = "框体缩放：%0.1f"
	thlang.scalestatus = "状态提示缩放：%0.1f"
	thlang.ibr = "水平间距：%0.1f"
	thlang.cbr = "垂直间距：%0.1f"
	thlang.obr = "外边框：%0.1f"
	thlang.iconsize = "图标大小: %0.1f"
	thlang.fixposition = "锁定位置"
	thlang.hidestatus = "隐藏状态框"
	thlang.nameplatethreat = "在姓名上显示威胁值"
	thlang.pulltimermode = "开怪倒数模式"
	thlang.onlytank = "只在担任坦克时自动标记"
	thlang.brcolor = "边框颜色"
	thlang.bgcolor = "背景颜色"
	thlang.healthmax = "生命值低于 %0.1f%% 时警示状态"
	thlang.powermax = "法力值低于 %0.1f%% 时警示状态"
	thlang.statusonlyhealers = "只显示治疗的状态"
	thlang.healer = "治疗"
	thlang.combineall = "合并工具栏"
	thlang.fixedpositionisenabled = "位置已锁定"
end
