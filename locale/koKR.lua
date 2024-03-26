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
	thlang.showalways = "항상 표시"
	thlang.showtranslation = "번역 보기"
	thlang.targettingdelay = "타겟팅 지연: %0.1f"
	thlang.scalecockpit = "스케일 콕핏: %0.1f"
	thlang.scalestatus = "스케일 상태: %0.1f"
	thlang.ibr = "열 간격: %0.1f"
	thlang.cbr = "행 간격: %0.1f"
	thlang.obr = "외부 테두리: %0.1f"
	thlang.iconsize = "아이콘 사이즈: %0.1f"
	thlang.fixposition = "위치 고정"
	thlang.hidestatus = "상태 프레임 숨기기"
	thlang.nameplatethreat = "명판 위협 표시"
	thlang.pulltimermode = "풀타이머 모드"
	thlang.onlytank = "탱크 전용으로 자동 표시"
	thlang.hidelastrow = "마지막 행 숨기기"
	thlang.brcolor = "테두리 색상"
	thlang.bgcolor = "배경색"
	thlang.healthmax = "상태 - %0.1f%% 건강까지 경고"
	thlang.powermax = "상태 - %0.1f%% 마나까지 경고"
	thlang.statusonlyhealers = "상태 - 힐러 정보만 표시"
	thlang.healer = "힐러"
	thlang.combineall = "모든 바 결합"
	thlang.fixedpositionisenabled = "고정 위치가 활성화됨"
end