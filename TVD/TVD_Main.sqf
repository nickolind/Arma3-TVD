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

private ["_missionResults","_TVD_sides","_TVD_capZonesCount","_TVD_RetreatPossible","_TVD_ZoneGain","_TVD_RetreatRatio","_checkTasks","_endCause","_counter"];

//Убрать ВМТ лимиты (-1 все) и выставить ТВД аналоги
wmt_hl_sidelimits = [-1,-1,-1];		//[east, west, resistance]
wmt_hl_ratio = [-1,-1,-1];



//-------------CLIENT PART
if !(isDedicated) then {
	null = [] execVM "TVD\TVD_client_RetreatAction.sqf";
	null = [] execVM "TVD\TVD_client_SendToResAction.sqf";
	null = [] execVM "TVD\TVD_client_SendToResManAction.sqf";
	null = [] execVM "TVD\TVD_client_retreatSoldierAction.sqf";
};


//-------------SERVER PART
if (isServer) then {
	
	_counter = 0;
	
	
	//----------- Инициализация функций и переменных: ----------------------------------------------------------------------------
	
	_TVD_sides = 			_this select 0;
	_TVD_capZonesCount = 	if (count _this > 1) then {_this select 1} else {0};			//Количество присутствующих на миссии зон для захвата.
	_TVD_RetreatPossible = 	if (count _this > 2) then {_this select 2} else {[true,true,true]};			//[east,west,resistance] - If side has possibility to retreat on a mission
	_TVD_ZoneGain = 		if (count _this > 3) then {_this select 3} else {50};					//Количество очков за владение одной зоной (50 по умолчанию)
	_TVD_RetreatRatio = 	if (count _this > 4) then {_this select 4} else {0.9};				//Если останется меньше данного процента - у КСа появится возможность отступить
	
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

	sleep 10;
	
	[] spawn {		//Раз в 5мин пишем в лог состояние миссии (на случай непредвиденного завершения, чтобы оценить результаты миссии)
		private ["_mTime","_mWaitTime"];
		
		while {true} do {				
			
			_mTime = diag_tickTime;
			_mWaitTime = 0.0;
			
			[] call TVD_WinCalculations;
			["scheduled"] call TVD_util_MissionLogWriter;
			
			waitUntil {
				sleep 2; 
				_mWaitTime = diag_tickTime - _mTime;
				_mWaitTime > 600
			};
		};
	};
	

	[] spawn {		//Раз в 10 сек проверка состояния задач
		while {(timeToEnd == -1) && (count TVD_TaskObjectsList > 2)} do {				
			null = [false] call TVD_TasksKeeper;
			sleep 10;
		};
	};

	[] spawn TVD_HeavyLossesOverride;

	

	while {(timeToEnd == -1)} do {
		
		
		//Здесь обрабатывать события, прерывающие миссию
		//----------------------
		switch (true) do {
		
		
			//------Прерывание миссии админом
			case (!isNil {WMT_Global_EndMission}): {
				_endCause = 0;
				
				timeToEnd = _endCause;
				
				waitUntil {
					sleep 1;
					_counter = _counter + 1;
					([(_counter >= 5), _endCause] call TVD_TasksKeeper == 2)
				};
				
				_missionResults = [_endCause] call TVD_WinCalculations;			//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2, [_scoreRatio0, _scoreRatio1]
				[_missionResults,_endCause, true] spawn TVD_EndMissionPreps;
			};
			
			
			
			//------Вышло время
			case (WMT_Global_LeftTime select 0  < 300): {
				_endCause = 1;
				timeToEnd = _endCause;
				
				waitUntil {
					sleep 1;
					_counter = _counter + 1;
					([(_counter >= 10), _endCause] call TVD_TasksKeeper == 2)
				};
				
				// em_result = [_endCause] call TVD_EndMissionHandler;
				
				_missionResults = [_endCause] call TVD_WinCalculations;			//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2, [_scoreRatio0, _scoreRatio1]			
				[_missionResults,_endCause, false] spawn TVD_EndMissionPreps;
			};
			
			
			
			//------Потери
			case (TVD_HeavyLosses != sideLogic): {
				_endCause = 2;
				em_result = false;
				timeToEnd = _endCause;
				
				[_endCause] spawn {
					waitUntil {
						if (em_result) exitWith {true};
						if ([false, _this select 0] call TVD_TasksKeeper == 2) exitWith {true};
						sleep 2;
					};
				};
				
				em_result = [_endCause, TVD_HeavyLosses] call TVD_EndMissionHandler;
				
				null = [true, _endCause] call TVD_TasksKeeper;
				
				_missionResults = [_endCause] call TVD_WinCalculations;			// Функция TVD_WinCalculations вызывается из TVD_HeavyLossesHandler - нет надобности вызывать еще раз из Main			
				[_missionResults, _endCause, false] spawn TVD_EndMissionPreps;
			};
			
			
			
			//------Сторона отступила
			case (TVD_SideRetreat != sideLogic): {
				_endCause = 3;
				// sr_result = false;
				em_result = false;
				timeToEnd = _endCause;
				
				[_endCause] spawn {
					waitUntil {
						// if (sr_result) exitWith {true};
						if (em_result) exitWith {true};
						if ([false, _this select 0] call TVD_TasksKeeper == 2) exitWith {true};
						sleep 1;
					};
				};
				
				sleep 5;
				
				// sr_result = [TVD_SideRetreat] call TVD_Retreat;
				null = [TVD_SideRetreat] call TVD_Retreat;
				em_result = [_endCause, TVD_SideRetreat] call TVD_EndMissionHandler;
				
				null = [true, _endCause] call TVD_TasksKeeper;
						//Теперь компенсируем потери отступившей стороны и пишем в лог об этом
				_missionResults = [_endCause, TVD_sides find TVD_SideRetreat] call TVD_WinCalculations;		//Отступает сторона 0 или сторона 1 из TVD_sides			
				sleep 3;
				[_missionResults,_endCause, false] spawn TVD_EndMissionPreps;
			};
			
			
			
			//------Выполнена ключевая задача
			case (TVD_MissionComplete != sideLogic): {
				_endCause = 4;
				em_result = false;
				timeToEnd = _endCause;
				
				[_endCause] spawn {
					waitUntil {
						if (em_result) exitWith {true};
						if ([false, _this select 0] call TVD_TasksKeeper == 2) exitWith {true};
						sleep 2;
					};
				};
				
				em_result = [_endCause, TVD_MissionComplete] call TVD_EndMissionHandler;
				
				null = [true, _endCause] call TVD_TasksKeeper;
						//Теперь компенсируем потери отступившей стороны и пишем в лог об этом
				_missionResults = [_endCause] call TVD_WinCalculations;			// Функция TVD_WinCalculations вызывается из TVD_HeavyLossesHandler - нет надобности вызывать еще раз из Main			
				[_missionResults,_endCause, false] spawn TVD_EndMissionPreps;
			};
		};
		//----------------------
		
		sleep 3;
	};
	
};

