-- deDE German Deutsch
local _, TankHelper = ...
function TankHelper:LangkoKR()
	local thlang = TankHelper:GetLangTab()
	-- Pulltimer
	thlang.pullinx = "%0.1f 가져 오기"
	thlang.go = "이동"
	thlang.auto = "자동"
	thlang.onlythirdparty = "다른 애드온의 카운트다운 사용"
	thlang.onlyth = "탱크 도우미 카운트다운 사용"
	thlang.both = "둘 다 사용"
	-- Status
	thlang.ready = "준비"
	thlang.youmustbeinaninstance = "인스턴스에 있어야합니다"
	thlang.youmustbeinagrouporaraid = "그룹 또는 레이드에 속해 있어야 합니다"
	thlang.playerdead = "플레이어 사망"
	thlang.playerlowhp = "플레이어 낮은 체력"
	thlang.playernotfull = "플레이어가 꽉 차지 않음"
	thlang.playerhavenotenoughpower = "플레이어의 자원이 충분하지 않습니다"
	--Settings
	thlang.showtranslation = "번역 보기"
	thlang.ibr = "열 간격: %0.1f"
	thlang.cbr = "행 간격: %0.1f"
	thlang.obr = "외부 테두리: %0.1f"
	thlang.iconsize = "아이콘 사이즈: %0.1f"
	thlang.fixposition = "위치 고정"
	thlang.hidestatus = "상태 프레임 숨기기"
	thlang.nameplatethreat = "명판 위협 표시"
	thlang.brcolor = "Border Color"
	thlang.bgcolor = "Background Color"
end