-- zhTW Traditional Chinese
local _, TankHelper = ...
function TankHelper:LangzhTW()
	local thlang = TankHelper:GetLangTab()
	-- Pulltimer
	thlang.pullinx = "%0.1f 秒後開怪"
	thlang.go = "上"
	thlang.auto = "自動"
	thlang.onlythirdparty = "使用其他插件的倒計時"
	thlang.onlyth = "使用坦克助手倒計時"
	thlang.both = "同時使用兩者"
	-- Status
	thlang.ready = "就位"
	thlang.youmustbeinaninstance = "你必須在一個副本中"
	thlang.youmustbeinagrouporaraid = "你必須在一個小組或一個團隊中"
	thlang.playerdead = "玩家死亡"
	thlang.playerlowhp = "玩家低生命值"
	thlang.playernotfull = "玩家狀態未滿"
	thlang.playerhavenotenoughpower = "玩家法力不足"
	--Settings
	thlang.showalways = "總是顯示"
	thlang.showtranslation = "顯示翻譯"
	thlang.targettingdelay = "目標標記延遲：%0.1f"
	thlang.scalecockpit = "框體縮放：%0.1f"
	thlang.scalestatus = "狀態提示縮放：%0.1f"
	thlang.ibr = "欄間距：%0.1f"
	thlang.cbr = "行間距：%0.1f"
	thlang.obr = "外邊框：%0.1f"
	thlang.iconsize = "圖示大小：%0.1f"
	thlang.fixposition = "鎖定位置"
	thlang.hidestatus = "隱藏狀態框"
	thlang.nameplatethreat = "在名條上顯示威脅值"
	thlang.pulltimermode = "開怪倒數模式"
	thlang.onlytank = "只在擔任坦克時啟用自動標記"
	thlang.brcolor = "邊框顏色"
	thlang.bgcolor = "背景顏色"
	thlang.healthmax = "生命值低於 %0.1f%% 時警示狀態"
	thlang.powermax = "法力值低於 %0.1f%% 時警示狀態"
	thlang.statusonlyhealers = "只顯示補師的狀態"
	thlang.healer = "補師"
	thlang.combineall = "整合所有工具條"
	thlang.fixedpositionisenabled = "位置已鎖定"
end
