/*
null = [] execVM "TVD\TVD_util_logger.sqf";

TVD_Logger = compile preprocessFileLineNumbers "TVD\TVD_util_logger.sqf";
[[] call TVD_WinCalculations] call TVD_Logger; 
[] call TVD_Logger;
*/
private ["_missionResults","_outcome","_si0","_si1","_textLine","_pushLine"];

// if ( isNil{TVD_ExportLog} ) then { TVD_ExportLog = []; };
TVD_ExportLog = [];

_missionResults = _this select 0;
_outcome = "";
if (count _this >= 2) then {
	switch (_this select 1) do {
		case 0 : { _outcome = "Миссия завершена администратором"};
		case 1 : { _outcome = "Время вышло"};
		case 2 : { _outcome =  format ["У стороны осталось слишком мало живой силы на поле боя: %1", TVD_HeavyLosses]};
		case 3 : { _outcome =  format ["Сторона успешно отступила: %1", TVD_SideRetreat]};
		case 4 : { _outcome =  format ["Сторона выполнила ключевую задачу: %1", TVD_SideRetreat]};
	};
};

_si0 = [east, west, resistance, civilian, sideLogic] find (TVD_sides select 0);
_si1 = [east, west, resistance, civilian, sideLogic] find (TVD_sides select 1);

_pushLine = {
	diag_log (_this select 0);
	TVD_ExportLog pushBack (str (_this select 0));
};

		// _textLine =	parseText format ["//------------------------------------------------------------//"];
		// [_textLine] call _pushLine;
		
		
		_textLine =	parseText format ["//------------------------------------------------------------//"];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD Mission Status Report:"];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["Mission date/time: %1", date];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["missionStart: %1", missionStart];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["winSide: %1;   Supremacy: %2;   Supremacy Ratio: %3 - %4   Current Score: %5", _missionResults select 0, _missionResults select 1, _missionResults select 2, _missionResults select 3, _missionResults select 4];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["Soldiers Dead: %1 - %2;   Soldiers Present: %3 - %4", (TVD_playerCountInit select _si0) - (TVD_PlayerCountNow select _si0) - (TVD_RetrCount select 0), (TVD_playerCountInit select _si1) - (TVD_PlayerCountNow select _si1) - (TVD_RetrCount select 1), TVD_PlayerCountNow select _si0, TVD_PlayerCountNow select _si1];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["EndMission Reason: %1", _outcome];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["Vars:"];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD_sides = %1", TVD_sides];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD_InitScore = %1", TVD_InitScore];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD_ValUnits = %1", TVD_ValUnits];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD_capZones = %1", TVD_capZones];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD_sidesInfScore = %1", TVD_sidesInfScore];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD_sidesValScore = %1", TVD_sidesValScore];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD_sidesZonesScore = %1", TVD_sidesZonesScore];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["TVD_sidesResScore = %1", TVD_sidesResScore];
		[_textLine] call _pushLine;
		_textLine =	parseText format ["Mission Log:"];
		[_textLine] call _pushLine;
		{
			_textLine =	parseText format ["%1", _x];
			[_textLine] call _pushLine;
		} forEach TVD_MissionLog;
		_textLine =	parseText format ["//------------------------------------------------------------//"];
		[_textLine] call _pushLine;
		
if ( !isNil{TVD_Curator} ) then {  
	(owner TVD_Curator) publicVariableClient "TVD_ExportLog";
	
	[[ [], { 
		diag_log parseText format ["TVD_ExportLog:"];
		{
			diag_log parseText format ["%1", str _x];
		} forEach TVD_ExportLog;
	}],"BIS_fnc_call", TVD_Curator] call BIS_fnc_MP;
};