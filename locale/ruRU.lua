-- ruRU Russian
local _, TankHelper = ...
function TankHelper:LangruRU()
	local thlang = TankHelper:GetLangTab()
	-- Pulltimer
	thlang.pullinx = "Атакуйте %0.1f"
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
	thlang.showalways = "Показывать всегда"
	thlang.showtranslation = "Показать Перевод"
	thlang.targettingdelay = "Задержка наведения на цель: %0.1f"
	thlang.scalecockpit = "Кабина масштаба: %0.1f"
	thlang.scalestatus = "Статус масштаба: %0.1f"
	thlang.ibr = "Расстояние между столбцами: %0.1f"
	thlang.cbr = "Расстояние между рядами: %0.1f"
	thlang.obr = "Внешняя граница: %0.1f"
	thlang.iconsize = "Размер значка: %0.1f"
	thlang.fixposition = "исправить положение"
	thlang.hidestatus = "Скрыть рамку состояния"
	thlang.nameplatethreat = "Показать угрозу для таблички"
	thlang.pulltimermode = "Режим тянучки"
	thlang.onlytank = "Автоматическая маркировка как только танк"
	thlang.brcolor = "Цвет границы"
	thlang.bgcolor = "Цвет фона"
	thlang.healthmax = "Статус - Предупреждение до %0.1f%% здоровья"
	thlang.powermax = "Статус - предупреждение до %0.1f%% маны"
	thlang.statusonlyhealers = "Статус - показывать информацию только о лекарях"
	thlang.healer = "Целитель"
	thlang.combineall = "Объединить все бары"
	thlang.fixedpositionisenabled = "Фиксированная позиция включена"
end
