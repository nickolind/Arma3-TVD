/*
TVD_TaskCompleted = compile preprocessFileLineNumbers "TVD\TVD_TaskCompleted.sqf";
[_side,_message,_showMessageTo] call TVD_TaskCompleted;
*/

private ["_showMessageTo","_side","_message"];

// _unit = _this select 0;
_side = _this select 0;
_message = _this select 1;
_showMessageTo = _this select 2;


//Отправить сообщение всем.
if (_showMessageTo) then {			//Сделать универсальную переменную - true,false, east,west,resistance - если Bool, то либо всем, либо никому. Если сторона - то сообщение только этой стороне
	[[ [_side, _message], {
		private ["_type"];
		
		if (playerSide == _this select 0) then {
			_type = "TaskSucceeded";
		} else {
			_type = "TaskFailed";
		};
		[_type,[0,_this select 1]] call bis_fnc_showNotification;
	}],"BIS_fnc_call"] call BIS_fnc_MP;
};

//Записать в лог
["taskCompleted",_message, TVD_sides find _side] call TVD_util_MissionLogWriter;
