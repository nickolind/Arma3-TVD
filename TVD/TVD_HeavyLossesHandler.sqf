/*
null = [] execVM "TVD\TVD_HeavyLossesHandler.sqf";

TVD_HeavyLossesHandler = compile preprocessFileLineNumbers "TVD\TVD_HeavyLossesHandler.sqf";
null = [] call TVD_HeavyLossesHandler;
*/

private ["_sideHeavyLosses","_sideWinner","_trigger","_stats","_hevLossLog","_un","_i","_fnc_tasksCount","_tasksCount"];

_sideHeavyLosses = _this select 0;
_sideWinner = sideLogic;
_hevLossLog = parseText "";
hlh_finish = false;
hlh_ttw = 0;
hlh_actContinueAdded = -1;

if (_sideHeavyLosses == TVD_sides select 0) then { _sideWinner = TVD_sides select 1};
if (_sideHeavyLosses == TVD_sides select 1) then { _sideWinner = TVD_sides select 0};

hlh_fnc_tasksCount =  {
	private ["_result","_un","_i"];
	_result = 0;
	
	for [{_i=2},{_i<=(count TVD_TaskObjectsList - 1)},{_i=_i+1}] do {
		_un = TVD_TaskObjectsList select _i;

		if ((_un getVariable "TVD_TaskObject" select 0) == _this select 0) then {_result = _result + 1};
	};
	
	_result
};


/*
if !(TVD_RetreatPossible select ([east,west,resistance] find _sideHeavyLosses)) then {		// Если стороне некуда отступать по условиям миссии, то все оставшееся силы этой стороны становятся захваченными врагом.
	
	if (_sideHeavyLosses == TVD_sides select 0) then { _sideWinner = TVD_sides select 1};
	if (_sideHeavyLosses == TVD_sides select 1) then { _sideWinner = TVD_sides select 0};

	{																		//Убиваем всех кто не в зоне из отступившей стороны
		if ((side group _x == _sideHeavyLosses)) then { 
			[[ [], { 	["<t color='#e50000'>Из-за огромных потерь остатки наших сил сдались в плен.</t>", 0, 0.7, 4, 0.2] spawn bis_fnc_dynamictext; 	 }],"BIS_fnc_call", _x] call BIS_fnc_MP; 
			
			if !(isNil{_x getVariable "TVD_UnitValue" select 2}) then {
				_hevLossLog = composeText [_hevLossLog, parseText format ["%1(%2), ", name _x, (_x getVariable "TVD_UnitValue" select 2) call TVD_unitRole]];
			} else {
				_hevLossLog = composeText [_hevLossLog, parseText format ["%1, ", name _x]];
			};
			
			_x setDamage 1;
		};
	} forEach playableUnits;

	null = [] call TVD_WinCalculations; 		//Пересчитать TVD_ValUnits, иначе в цикле ниже может быть выход за пределы массива изза юнитов "soldier"

	//Вся техника проигравших становится захваченной врагом
	for "_i" from 0 to (count TVD_ValUnits - 1) do {
		_un = TVD_ValUnits select _i;
		if ( ( (_un getVariable "TVD_UnitValue" select 0) == _sideHeavyLosses) && (!isNil {_un getVariable "TVD_CapOwner"}) ) then {
			
			_un setVariable ["TVD_CapOwner", _sideWinner];
			// ["retreatLoss", _un] call TVD_util_MissionLogWriter;
			_hevLossLog = composeText [_hevLossLog, parseText format ["%1, ", getText (configFile >> "CfgVehicles" >> (typeof _un) >> "displayName")]];
		};
	};

	//Отдаем под контроль другой стороне все зоны и очки за них, соответственно, тоже
	{
		if (getMarkerColor (_x select 0) == (_sideHeavyLosses call SideToColor)) then {
			_hevLossLog = composeText [_hevLossLog, parseText format ["%1, ", markerText (_x select 0)]];
		};
		(_x select 0) setMarkerColor (_sideWinner call SideToColor);
	} forEach TVD_capZones;


	//Потери стороны при отступлении:
	["heavyLossesList",_hevLossLog,TVD_sides find _sideWinner] call TVD_util_MissionLogWriter;
};
*/


if ([_sideWinner] call hlh_fnc_tasksCount == 0) then {
	hlh_ttw = 120;
	publicVariable "hlh_ttw";
	hlh_actContinueAdded = -2;
	publicVariable "hlh_actContinueAdded";
} else {
	hlh_ttw = 300 min ((WMT_Global_LeftTime select 0) - 40);
	publicVariable "hlh_ttw";
	publicVariable "hlh_actContinueAdded";
};



[[ [_sideWinner], { 
	if ( (isServer) || (playerSide == _this select 0) ) then {
		private ["_time","_waitTime","_res"];
		
		[format ["Количество вражеских сил на поле боя слишком мало.<br/>Миссия завершится через %1.",[hlh_ttw,"MM:SS"] call BIS_fnc_secondsToString],0,0,5,0.2] call bis_fnc_dynamictext;
		
		_time = serverTime;
		_waitTime = hlh_ttw;	
		_res = -1;		

		while {true} do {
			_waitTime = 0 max (hlh_ttw - (serverTime - _time));
			
			if !(isDedicated) then {	
			
				hint format ["Количество вражеских сил на поле боя слишком мало.\nМиссия завершится через:\n\n%1",[_waitTime,"MM:SS"] call BIS_fnc_secondsToString];	
					
				if ( !isNil{player getVariable "TVD_UnitValue" select 2} ) then {
					if ( (player getVariable "TVD_UnitValue" select 2 in ["sideLeader","execSideLeader"]) && (_waitTime < 60) && (hlh_actContinueAdded != -2) ) then {
						titleText ["Вы можете продлить время, если сторона не успевает выполнить задачи.\nИспользуйте ActionMenu >> 'Продлить миссию'.", "PLAIN DOWN"];
						
						if (hlh_actContinueAdded == -1) then {
							hlh_actContinueAdded = player addAction ["<t color='#ffffff'>КС: Продлить миссию (макс. +5 мин.)</t>", {
								
								hlh_ttw = ((hlh_ttw + 300) min ((WMT_Global_LeftTime select 0) - 40));
								publicVariable "hlh_ttw";
								player removeAction hlh_actContinueAdded;
								hlh_actContinueAdded = -2;
								publicVariable "hlh_actContinueAdded";
								
							}, 1, 0, false, true, "", "(hlh_actContinueAdded != -2)"];
						};
					};
				};
					
			};
			
			if (isServer) then {
				if (_res == 0) then {
					hlh_ttw = 120 min hlh_ttw;
					publicVariable "hlh_ttw";
					hlh_actContinueAdded = -2;
					publicVariable "hlh_actContinueAdded";
					
					hlh_fnc_tasksCount = nil;
				} else {
					_res = [_this select 0] call hlh_fnc_tasksCount;
				};
			};
			
			if (_waitTime <= 1) exitWith {	
				if (isServer) then {hlh_finish = true};
			};
			sleep 1;
		};
	};
		
}],"BIS_fnc_call"] call BIS_fnc_MP;

waitUntil {sleep 1; hlh_finish};

true 