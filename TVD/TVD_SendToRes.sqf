/*
null = [] execVM "TVD\TVD_SendToRes.sqf";

TVD_SendToRes = compile preprocessFileLineNumbers "TVD\TVD_SendToRes.sqf";
null = [] call TVD_SendToRes;
*/
private ["_time","_waitTime","_us","_originalUs","_str_target","_str_caller","_unitName","_amount","_trig"];


_str_target = _this select 0;						// (_this select 0) - _target
_str_caller = _this select 1;						// (_this select 1) - _caller
_us = if (_str_target in list trgBase_side0) then {0} else {1};		//Сторона, которая отправляет технику к себе и получает за нее очки

_str_target setVariable ["TVD_SentToRes", 1, true];	
_unitName = getText (configFile >> "CfgVehicles" >> (typeof _str_target) >> "displayName");
_amount = 0;

// "SmokeShellRed" createVehicle position _str_target;
_trig = false;

//Сообщение что отправка в тыл началась
{
	if (isPlayer _x) then { 
		[[ [_unitName], { 
			titleText [format ["%1 - начата отправка в тыл...",_this select 0], "PLAIN DOWN"];
		}],"BIS_fnc_call", _x] call BIS_fnc_MP;
	};
} forEach (_str_target nearEntities 50);

//пока машина пустая - отсчитывать 3 минуты, затем удалять.
//если кто сел в машину - сброс
_time = diag_tickTime;
_waitTime = 0.0;

while {true} do {
	_waitTime = diag_tickTime - _time;

	if ( (( {alive _x} count crew _str_target) > 0) || !(alive _str_target)) exitWith {
		_str_target setVariable ["TVD_SentToRes", 0, true];
		//Cообщение что отправка в тыл отменена - titleText
		{
			if (isPlayer _x) then { 
				[[ [_unitName], { 
					titleText [format ["%1 - отправка в тыл отменена.",_this select 0], "PLAIN DOWN"];
				}],"BIS_fnc_call", _x] call BIS_fnc_MP;
			};
		} forEach (_str_target nearEntities 50);
	};
	
	if ((_waitTime > 150) && !(_trig)) then {	"SmokeShellRed" createVehicle position _str_target; _trig = true };
	
	if (_waitTime > 180) exitWith {	
		
		_originalUs = TVD_sides find (_str_target getVariable "TVD_UnitValue" select 0);		//Изначальная принадлежность техники
		
		if  (_us != _originalUs) then {													//Если текущая сторона-владелец отличается от изначальной - то захватившей стороне перепадает 50% ценности техники (изначальной стороне, соответственно -100%)
			_amount = (_str_target getVariable ["TVD_UnitValue", 0] select 1) / 2;
		} else {
			_amount = _str_target getVariable ["TVD_UnitValue", 0] select 1;			//Если текущая сторона-владелец НЕ отличается от изначальной - то начисление как обычно
		};
		
		TVD_sidesResScore set [_us, (TVD_sidesResScore select _us) + _amount];
	
		//Запись в логе что машина отправлена в тыл
		null = ["sentToRes", _str_target, _us] call TVD_util_MissionLogWriter;
		
		if (!isNil {_str_target getVariable "TVD_UnitValue"}) then {_str_target setVariable ["TVD_UnitValue", nil, true];};
		TVD_ValUnits deleteAt (TVD_ValUnits find _str_target);
		deleteVehicle _str_target;
		//Cообщение что отправка в тыл завершена
		{
			if (isPlayer _x) then { 
				[[ [_unitName], { 
					titleText [format ["%1 - успешно отправлен в тыл.",_this select 0], "PLAIN DOWN"];
				}],"BIS_fnc_call", _x] call BIS_fnc_MP;
			};
		} forEach (_str_target nearEntities 50);
		
		[[] call TVD_WinCalculations] call TVD_Logger;//Вызов логгера
	};
	
	sleep 1;
};

