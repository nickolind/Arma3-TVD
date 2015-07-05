/*
TVD_addSideScore = compileFinal preprocessFileLineNumbers "TVD\TVD_util_addSideScore.sqf";
[side, score, _logIt, _message, _notify] spawn TVD_addSideScore;
*/

private ["_us","_score","_message","_logIt","_notify"];

_us = TVD_sides find (_this select 0);
_score = _this select 1;

_logIt = if (count _this >= 3) then {_this select 2} else {false};
_message = if (count _this >= 4) then {_this select 3} else {""};
_notify = if (count _this >= 5) then {_this select 4} else {false};

waitUntil {sleep 1; !(isNil "TVD_sidesResScore") };

switch (_us) do {
	case -1: {
		[[ [_this], {	
			hint format ["ОШИБКА!\nСторона\n\n%1\n\nне верна.\nДопустимые стороны:\n%2\n\n(TVD_addSideScore)", _this select 0, TVD_sides];	// У зоны всегда должна быть выставленна изначальная сторона-владелец из списка сторон TVD_sides
		}],"BIS_fnc_call"] call BIS_fnc_MP;
	};
	default {
		TVD_InitScore set [1-_us, (TVD_InitScore select (1-_us)) + _score];
		
		// TVD_sidesResScore set [_us, (TVD_sidesResScore select _us) + _score];
		
		if (_logIt) then {
			[_this select 0,_message,_notify] call TVD_TaskCompleted;
		};
	};
};