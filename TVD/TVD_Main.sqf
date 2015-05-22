/*
null = [] execVM "TVD\TVD_Main.sqf";

TVD_Main = compile preprocessFileLineNumbers "TVD\TVD_Main.sqf";
null = [] spawn TVD_Main;
*/
//----------- Инициализация функций и переменных: ----------------------------------------------------------------------------

null = [] call compileFinal preprocessFileLineNumbers "TVD\TVD_Init.sqf";

//-----------Оснвной блок после завершения инициализации: ----------------------------------------------------------------------------

private ["_missionResults"];

waitUntil {sleep 5; (WMT_pub_frzState >= 3) && (!isNil {WMT_Global_LeftTime})}; //==3 when freeze over, ==1 when freeze up

sleep 30;

[] spawn {
	while {!timeToEnd} do {			//Раз в 3мин пишем в лог состояние миссии (на случай непредвиденного завершения, чтобы оценить результаты миссии)	
		
		[[] call TVD_WinCalculations] call TVD_Logger;					//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2, [_scoreRatio0, _scoreRatio1]
		sleep 180;
	
	};
};

[] spawn TVD_HeavyLossesOverride;

while {!timeToEnd} do {
	
	//---------------- Потенциал обновлять данные до одного раза в 10-30 сек (пока не нужно):
	
	// if ( ((serverTime - _timer) > 30) ) then {				//Вызов обновления данных по потерям каждые 30 сек.
		// _scoreKeeperVars = _scoreKeeperVars call TVD_ScoreKeeper;
		// _missionResults = [TVD_InitScore, TVD_sidesInfScore, TVD_sidesValScore, TVD_sidesZonesScore] call TVD_WinCalculations;		//Вычисление победителя
		// _timer = serverTime;
	// };
	
	
	//Здесь обрабатывать события, прерывающие миссию
	//----------------------
	switch (true) do {
		//------Прерывание миссии админом
		case (!isNil {WMT_Global_EndMission}): {
			_missionResults = [] call TVD_WinCalculations;			//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2, [_scoreRatio0, _scoreRatio1]
			timeToEnd = true;
			[_missionResults,0,true] spawn TVD_EndMissionPreps;
		};
		
		//------Вышло время
		case (WMT_Global_LeftTime select 0  < 300): {
			_missionResults = [] call TVD_WinCalculations;			//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2, [_scoreRatio0, _scoreRatio1]
			timeToEnd = true;
			[_missionResults,1,false] spawn TVD_EndMissionPreps;
		};
		
		//------Потери 90%
		case (TVD_HeavyLosses != sideLogic): {
			_missionResults = [] call TVD_WinCalculations;			//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2, [_scoreRatio0, _scoreRatio1]
			timeToEnd = true;
			[_missionResults, 2,false] spawn TVD_EndMissionPreps;
		};
		
		//------Сторона отступила
		case (TVD_SideRetreat != sideLogic): {
			_missionResults = [TVD_SideRetreat] call TVD_Retreat;
					// Функция TVD_WinCalculations вызывается из TVD_Retreat - нет надобности вызывать еще раз из Main
						//_missionResults = [] call TVD_WinCalculations;
			timeToEnd = true;
			[_missionResults,3,false] spawn TVD_EndMissionPreps;
		};
	};
	//----------------------
	
	sleep 3;
};

