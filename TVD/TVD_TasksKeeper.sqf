/*

TVD_TasksKeeper = compile preprocessFileLineNumbers "TVD\TVD_TasksKeeper.sqf";
null = [] call TVD_TasksKeeper;

*/

private ["_un","_i","_tasksCount","_tk_Handler","_endCause","_endIt","_sufferSide"];


_endIt = _this select 0;
_endCause = if (count _this >= 2) then {[0,0,1,2,3] select (_this select 1)} else {-1};	// 0 - админ/время, 1 - потери, 2 - отступление, 3 - задачи выполнены
_sufferSide = sideLogic; 
if (_endCause == 1) then {_sufferSide = TVD_HeavyLosses};
if (_endCause == 2) then {_sufferSide = TVD_SideRetreat};
// if (_endCause == 3) then {_sufferSide = TVD_sides select (1 - (TVD_sides find TVD_MissionComplete))};
_tasksCount = count TVD_TaskObjectsList;

_tk_Handler = {
	private ["_unitL","_iL","_sideL","_us","_messageL","_showMessageTo"];
	_iL = _this select 0;
	_unitL = TVD_TaskObjectsList select _iL;
	_sideL = _unitL getVariable "TVD_TaskObject" select 0;
	_us = TVD_sides find _sideL;
	_messageL = _unitL getVariable "TVD_TaskObject" select 2;
	_showMessageTo = _unitL getVariable "TVD_TaskObject" select 3;

	// (_un getVariable "TVD_TaskObject") set [4, true];
	TVD_TaskObjectsList set [_us, (TVD_TaskObjectsList select _us) + 1];
	
	TVD_InitScore set [1-_us, (TVD_InitScore select (1-_us)) + (_unitL getVariable ["TVD_TaskObject", 0] select 1)];
	// TVD_sidesResScore set [_us, (TVD_sidesResScore select _us) + (_unitL getVariable ["TVD_TaskObject", 0] select 1)];
	
	//Если задача ключевая - присвоить переменной TVD_MissionComplete сторону-победителя
	if (_unitL getVariable "TVD_TaskObject" select 5) then {TVD_MissionComplete = _sideL};
	
	_unitL setVariable ["TVD_TaskObjectStatus", "success", true];
	_unitL setVariable ["TVD_TaskObject", nil, true];
	TVD_TaskObjectsList deleteAt _iL;
	
	
	
	[_sideL,_messageL,_showMessageTo] call TVD_TaskCompleted;
};



for [{_i=2},{_i<=(_tasksCount - 1)},{_i=_i+1}] do {
	_un = TVD_TaskObjectsList select _i;
	
	if ( (isNull _un) || (isNil {_un getVariable "TVD_TaskObject"}) || ((_un getVariable "TVD_TaskObjectStatus") in ["fail","success"]) ) then {
		_un setVariable ["TVD_TaskObject", nil, true];
		_un setVariable ["TVD_TaskObjectStatus", "fail", true];
		TVD_TaskObjectsList deleteAt _i;
		_i = _i - 1;
	} else {
		switch (true) do {
		
			case (_un isKindOf "EmptyDetector") : {
				
				if (_endCause >= 0) then {
					if ( (call compile ((_un getVariable "TVD_TaskObject" select 4) select _endCause) ) && ((_un getVariable "TVD_TaskObject" select 0) != _sufferSide) ) then {
						_un setTriggerStatements ["true", "", ""];
						waitUntil {sleep 0.1; (triggerActivated _un)};
					};
				};
				
				if (triggerActivated _un) exitWith {
					[_i] call _tk_Handler;
					_i = _i - 1;
				};
				
				if (_endIt) then {
					_un setVariable ["TVD_TaskObjectStatus", "fail", true];
					_un setVariable ["TVD_TaskObject", nil, true];
					TVD_TaskObjectsList deleteAt _i;
					_i = _i - 1;
				};
			};
			
			case (_un isKindOf "logic") : {
			
				if (_endCause >= 0) then {
					if ( (call compile ((_un getVariable "TVD_TaskObject" select 4) select _endCause) ) && ((_un getVariable "TVD_TaskObject" select 0) != _sufferSide) ) then {
						_un setVariable ["WMT_TaskEnd", true, true];
					};
				};

				if (!isNil {_un getVariable "WMT_TaskEnd"}) exitWith {
					if (_un getVariable "WMT_TaskEnd") then {
						[_i] call _tk_Handler;
						_i = _i - 1;
					};
				};
				
				if (_endIt) then {
					_un setVariable ["TVD_TaskObjectStatus", "fail", true];
					_un setVariable ["TVD_TaskObject", nil, true];
					TVD_TaskObjectsList deleteAt _i;
					_i = _i - 1;
				};
			};
		};
	};
	
	_tasksCount = count TVD_TaskObjectsList;
};

_tasksCount


