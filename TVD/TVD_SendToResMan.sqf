/*
null = [] execVM "TVD\TVD_SendToResMan.sqf";

TVD_SendToResMan = compile preprocessFileLineNumbers "TVD\TVD_SendToResMan.sqf";
null = [] call TVD_SendToResMan;
*/

private ["_capOwner","_us","_cu_target","_cu_caller","_amount"];


_cu_target = _this select 0;						// (_this select 0) - _target
_cu_caller = _this select 1;						// (_this select 1) - _caller
_capOwner = if (_cu_target in list trgBase_side0) then {TVD_sides select 0} else {TVD_sides select 1};		//Сторона, которая отправляет солдата к себе в тыл и получает за него очки
_us = TVD_sides find _capOwner;



//Сообщение ближайшим игрокам
{
	if (isPlayer _x) then { 
		[[ [name _cu_target, _capOwner], { 
			titleText [format ["Пленник (%1) отправлен в тыл стороны %2.",_this select 0, _this select 1], "PLAIN DOWN"];
		}],"BIS_fnc_call", _x] call BIS_fnc_MP;
	};
} forEach (_cu_target nearEntities 50);

if (!isNil {_cu_target getVariable "TVD_UnitValue"}) then {
	_amount = _cu_target getVariable "TVD_UnitValue" select 1;
} else {
	_amount = 10;
};

TVD_sidesResScore set [_us, (TVD_sidesResScore select _us) + _amount];

if (isPlayer _cu_target) then { 
	[[ [], { 	["<t color='#e50000'>Вас отправили в тыловой лагерь военно-пленных.</t>", 0, 0.7, 6, 0.2] spawn bis_fnc_dynamictext; 	 }],"BIS_fnc_call", _cu_target] call BIS_fnc_MP; 
};
_cu_target setDamage 1;