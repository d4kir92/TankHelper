-- ruRU Russian

local AddOnName, TankHelper = ...

function TankHelper:LangruRU()
	local thlang = TankHelper:GetLangTab()
	
	-- Pulltimer
	thlang.pullinx = "Атакуйте VALUE"
	thlang.go = "Идти"
	thlang.auto = "Автоматически"
	thlang.onlythirdparty = "Использовать обратный отсчет из других аддонов"
	thlang.onlyth = "Использовать обратный отсчет от Tank Helper"
	thlang.both = "Использовать оба"

	-- Status
	thlang.ready = "Готовность"
	thlang.youmustbeinaninstance = "Вы должны быть в подземелье"
	thlang.youmustbeinagrouporaraid = "Вы должны быть в группе или рейде"
	thlang.playerdead = "Игрок мертв"
	thlang.playerlowhp = "Игрок с низким здоровьем"
	thlang.playernotfull = "Игрок не с полным здоровьем"
	thlang.playerhavenotenoughpower = "Игроку не хватает силы"

	--Settings
	thlang.showtranslation = "Показать Перевод"
	thlang.ibr = "Расстояние между столбцами: VALUE"
	thlang.cbr = "Расстояние между рядами: VALUE"
	thlang.obr = "Внешняя граница: VALUE"
	thlang.iconsize = "Размер значка: VALUE"
	thlang.fixposition = "исправить положение"
	thlang.hidestatus = "Скрыть рамку состояния"
	thlang.nameplatethreat = "Показать угрозу для таблички"
end
