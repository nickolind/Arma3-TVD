/*
Вызов из init.sqf:

null = [
	sides, 
	capZonesCount, 
	RetreatPossible, 
	ZoneGain, 
	RetreatRatio
] spawn compileFinal preprocessFileLineNumbers "TVD\TVD_Main.sqf";

------------------------------------------

Пример со значениями по умолчанию:

null = [
	[west, independent], 
	0, 
	[true,true,true], 
	50, 
	0.75
] spawn compileFinal preprocessFileLineNumbers "TVD\TVD_Main.sqf";

------------------------------------------

Пример с минимальными настройками (не указанные будут как в примере выше:

null = [ [west, independent] ] spawn compileFinal preprocessFileLineNumbers "TVD\TVD_Main.sqf";

------------------------------------------

*/

//Убрать ВМТ лимиты (-1 все) и выставить ТВД аналоги
wmt_hl_sidelimits = [-1,-1,-1];		//[east, west, resistance]
wmt_hl_ratio = [-1,-1,-1];

if (!isnil{"TVD_Ext\TVD_fnc_init.sqf"}) then {[] call compileFinal preprocessFileLineNumbers "TVD_Ext\TVD_fnc_init.sqf"};


//-------------CLIENT PART
if !(isDedicated) then {
	null = [] execVM "TVD\TVD_client_RetreatAction.sqf";
	null = [] execVM "TVD\TVD_client_SendToResAction.sqf";
	null = [] execVM "TVD\TVD_client_SendToResManAction.sqf";
};


//-------------SERVER PART
if (isServer) then {
	
	private ["_missionResults","_TVD_sides","_TVD_capZonesCount","_TVD_RetreatPossible","_TVD_ZoneGain","_TVD_RetreatRatio"];
	
	//----------- Инициализация функций и переменных: ----------------------------------------------------------------------------
	
	_TVD_sides = 			_this select 0;
	_TVD_capZonesCount = 	if (count _this > 1) then {_this select 1} else {0};			//Количество присутствующих на миссии зон для захвата.
	_TVD_RetreatPossible = 	if (count _this > 2) then {_this select 2} else {[true,true,true]};			//[east,west,resistance] - If side has possibility to retreat on a mission
	_TVD_ZoneGain = 		if (count _this > 3) then {_this select 3} else {50};					//Количество очков за владение одной зоной (50 по умолчанию)
	_TVD_RetreatRatio = 	if (count _this > 4) then {_this select 4} else {0.75};				//Если останется меньше данного процента - у КСа появится возможность отступить
	
	null = [
		_TVD_sides, 
		_TVD_capZonesCount, 
		_TVD_RetreatPossible, 
		_TVD_ZoneGain, 
		_TVD_RetreatRatio
	] call compileFinal preprocessFileLineNumbers "TVD\TVD_Init.sqf";

	_TVD_sides = nil;
	_TVD_capZonesCount = nil;
	_TVD_RetreatPossible = nil;
	_TVD_ZoneGain = nil;
	_TVD_RetreatRatio = nil;
	
	//-----------Оснвной блок после завершения инициализации: ----------------------------------------------------------------------------

	waitUntil {sleep 5; (WMT_pub_frzState >= 3) && (!isNil {WMT_Global_LeftTime})}; //==3 when freeze over, ==1 when freeze up

	sleep 30;
	
	[] spawn {		//Раз в 10мин пишем в лог состояние миссии (на случай непредвиденного завершения, чтобы оценить результаты миссии)
		private ["_mTime","_mWaitTime"];
		
		while {!timeToEnd} do {				
			
			_mTime = diag_tickTime;
			_mWaitTime = 0.0;
			
			["scheduled"] call TVD_util_MissionLogWriter;
			
			waitUntil {
				sleep 2; 
				_mWaitTime = diag_tickTime - _mTime;
				_mWaitTime > 600
			};
		};
	};
	
	// [TVD_capZones] spawn {		//Раз в 10 сек проверка
		// private ["",""];
		
		// while {!timeToEnd} do {				
			
			
		// };
	// };

	[] spawn TVD_HeavyLossesOverride;

	while {!timeToEnd} do {
		
		
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
	
};

