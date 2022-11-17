-- zhTW Traditional Chinese

local AddOnName, TankHelper = ...

function TankHelper:LangzhTW()
	local thlang = TankHelper:GetLangTab()
	
	-- Pulltimer
	thlang.pullinx = "拉怪於 VALUE 後"
	thlang.go = "上"
	thlang.auto = "自動"
	thlang.onlythirdparty = "使用其他插件的倒計時"
	thlang.onlyth = "使用坦克助手倒計時"
	thlang.both = "同時使用"

	-- Status
	thlang.ready = "準備好"
	thlang.youmustbeinaninstance = "你必須在一個副本中"
	thlang.youmustbeinagrouporaraid = "你必須在一個小組或一個團隊中"
	thlang.playerdead = "玩家死亡"
	thlang.playerlowhp = "玩家低生命值"
	thlang.playernotfull = "玩家未滿"
	thlang.playerhavenotenoughpower = "玩家沒有足夠能量"

	--Settings
	thlang.showtranslation = "顯示翻譯"
	thlang.ibr = "欄間距: VALUE"
	thlang.cbr = "行間距: VALUE"
	thlang.obr = "外邊框: VALUE"
	thlang.iconsize = "圖示大小: VALUE"
	thlang.fixposition = "固定位置"
	thlang.hidestatus = "隱藏狀態框"
	thlang.nameplatethreat = "顯示銘牌威脅"
end
