/*
TVD_addSideScore = compileFinal preprocessFileLineNumbers "TVD\TVD_util_addSideScore.sqf";
[_side, _score, _message] call TVD_addSideScore;
*/

private ["_us","_score","_message","_showMessageTo"];

_us = TVD_sides find (_this select 0);
_score = _this select 1;
_message = _this select 2;
_showMessageTo = _this select 3;

switch (_us) do {
	case -1: {
		[[ [_this], {	
			hint format ["ОШИБКА!\nСторона\n\n%1\n\nне верна.\nДопустимые стороны:\n%2\n\n(TVD_addSideScore)", _this select 0, TVD_sides];	// У зоны всегда должна быть выставленна изначальная сторона-владелец из списка сторон TVD_sides
		}],"BIS_fnc_call"] call BIS_fnc_MP;
	};
	default {
		TVD_sidesResScore set [_us, (TVD_sidesResScore select _us) + _score];
		[_this select 0,_message,_showMessageTo] call TVD_TaskCompleted;
		// ["taskCompleted",_message, _us] call TVD_util_MissionLogWriter;
	};
};