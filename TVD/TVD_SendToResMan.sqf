﻿/*
null = [] execVM "TVD\TVD_SendToResMan.sqf";

TVD_SendToResMan = compile preprocessFileLineNumbers "TVD\TVD_SendToResMan.sqf";
null = [] call TVD_SendToResMan;
*/

private ["_capOwner","_us","_cu_target","_cu_caller","_amount","_passData"];


_cu_target = _this select 0;						// (_this select 0) - _target
_cu_caller = _this select 1;						// (_this select 1) - _caller
_capOwner = if (_cu_target in list trgBase_side0) then {TVD_sides select 0} else {TVD_sides select 1};		//Сторона, которая отправляет солдата к себе в тыл и получает за него очки
_us = TVD_sides find _capOwner;
_passData = [];



//Сообщение ближайшим игрокам
{
	if (isPlayer _x) then { 
		[[ [name _cu_target, _capOwner], { 
			titleText [format ["Пленник (%1) отправлен в тыл стороны %2.",_this select 0, _this select 1], "PLAIN DOWN"];
		}],"BIS_fnc_call", _x] call BIS_fnc_MP;
	};
} forEach (_cu_target nearEntities 50) + [TVD_Curator];


_passData pushBack (name _cu_target);
_passData pushBack (side group _cu_target);//(_cu_target getVariable "TVD_UnitValue" select 0);
_passData pushBack (if (isnil {_cu_target getVariable "TVD_UnitValue" select 2}) then {""} else {
	((_cu_target getVariable "TVD_UnitValue" select 2) call TVD_unitRole);
});
_passData pushBack (_cu_target getVariable "TVD_GroupID");


if (!isNil {_cu_target getVariable "TVD_UnitValue"}) then {
	_amount = _cu_target getVariable "TVD_UnitValue" select 1;
} else {
	_amount = TVD_SoldierCost;
};


_cu_target setVariable ["TVD_soldierSentToRes", true];

TVD_sidesResScore set [_us, (TVD_sidesResScore select _us) + _amount];

if (isPlayer _cu_target) then { 
	[[ [], { 	["<t color='#e50000'>Вас отправили в тыловой лагерь военно-пленных.</t>", 0, 0.7, 6, 0.2] spawn bis_fnc_dynamictext; 	 }],"BIS_fnc_call", _cu_target] call BIS_fnc_MP; 
};

_cu_target setDamage 1;

null = ["sentToResMan", _passData] call TVD_util_MissionLogWriter;

_passData
