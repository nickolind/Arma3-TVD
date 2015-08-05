/*
null = [] execVM "TVD\TVD_RetreatSoldier.sqf";

TVD_RetreatSoldier = compile preprocessFileLineNumbers "TVD\TVD_RetreatSoldier.sqf";
null = [] call TVD_RetreatSoldier;
*/

private ["_uSide","_us","_restreatingUnit","_amount","_passData"];


_restreatingUnit = _this select 0;						// (_this select 0) - _target
_us = TVD_sides find (side group _restreatingUnit);
_passData = [];


//Сообщение ближайшим игрокам
{
	if ((isPlayer _x) && (side group _x == side group _restreatingUnit)) then { 
		[[ [name _restreatingUnit], { 
			titleText [format ["%1 самостоятельно отступил в тыл.",_this select 0], "PLAIN DOWN"];
		}],"BIS_fnc_call", _x] call BIS_fnc_MP;
	};
} forEach playableUnits;

if (isPlayer _restreatingUnit) then { 
	[[ [], { 	["<t color='#e50000'>Вы самостоятельно отступили в тыл.</t>", 0, 0.7, 6, 0.2] spawn bis_fnc_dynamictext; 	 }],"BIS_fnc_call", _restreatingUnit] call BIS_fnc_MP; 
};

_passData pushBack (name _restreatingUnit);
_passData pushBack (side group _restreatingUnit);//(_restreatingUnit getVariable "TVD_UnitValue" select 0);
_passData pushBack (if (isnil {_restreatingUnit getVariable "TVD_UnitValue" select 2}) then {""} else {
	((_restreatingUnit getVariable "TVD_UnitValue" select 2) call TVD_unitRole);
});

if (!isNil {_restreatingUnit getVariable "TVD_UnitValue"}) then {
	_amount = _restreatingUnit getVariable "TVD_UnitValue" select 1;
} else {
	_amount = TVD_SoldierCost;
};

_restreatingUnit setVariable ["TVD_soldierRetreats", true];

TVD_sidesResScore set [_us, (TVD_sidesResScore select _us) + _amount];

TVD_RetrCount set [_us, (TVD_RetrCount select _us) + 1];



_restreatingUnit setDamage 1;
_restreatingUnit setPos [-1000,-1000,0];
_restreatingUnit spawn {
	sleep 30;
	deleteVehicle _this;
};

// if (!isNil {_restreatingUnit getVariable "TVD_UnitValue"}) then {
	// _restreatingUnit setVariable ["TVD_UnitValue", nil, true];
// };

//Запись в логе что машина отправлена в тыл
null = ["retreatSoldier", _passData] call TVD_util_MissionLogWriter;


_passData

