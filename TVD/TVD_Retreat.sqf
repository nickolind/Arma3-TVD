/*
null = [] execVM "TVD\TVD_Retreat.sqf";

TVD_Retreat = compile preprocessFileLineNumbers "TVD\TVD_Retreat.sqf";
null = [] call TVD_Retreat;
*/
private ["_sideRetreats","_sideStays","_trigger","_stats","_retLossLog","_un"];

_sideRetreats = _this select 0;
_sideStays = sideLogic;
_trigger = objNull;
_retLossLog = parseText "";

if (_sideRetreats == TVD_sides select 0) then {_trigger = trgBase_side0; _sideStays = TVD_sides select 1};
if (_sideRetreats == TVD_sides select 1) then {_trigger = trgBase_side1; _sideStays = TVD_sides select 0};

_trigger setTriggerActivation ["ANY","PRESENT",true];
{																		//Убиваем всех кто не в зоне из отступившей стороны
	if ((side group _x == _sideRetreats) && !(_x in list _trigger)) then { 
		[[ [], { 	["<t color='#e50000'>Вас бросили при отступлении</t>", 0, 0.7, 4, 0.2] spawn bis_fnc_dynamictext; 	 }],"BIS_fnc_call", _x] call BIS_fnc_MP; 
		
		if !(isNil{_x getVariable "TVD_UnitValue" select 2}) then {
			_retLossLog = composeText [_retLossLog, parseText format ["%1(%2), ", name _x, (_x getVariable "TVD_UnitValue" select 2) call TVD_unitRole]];
		} else {
			_retLossLog = composeText [_retLossLog, parseText format ["%1, ", name _x]];
		};
		
		_x setDamage 1;
	};
} forEach playableUnits;

null = [] call TVD_WinCalculations; 		//Пересчитать TVD_ValUnits, иначе в цикле ниже может быть выход за пределы массива изза юнитов "soldier"

//Вся техника не в зоне эвакуации становится захваченной врагом
for "_i" from 0 to (count TVD_ValUnits - 1) do {
	_un = TVD_ValUnits select _i;
	if ( !(_un in list _trigger) && ( (_un getVariable "TVD_UnitValue" select 0) == _sideRetreats) ) then {
		
		_un setVariable ["TVD_CapOwner", _sideStays];
		// ["retreatLoss", _un] call TVD_util_MissionLogWriter;
		_retLossLog = composeText [_retLossLog, parseText format ["%1, ", getText (configFile >> "CfgVehicles" >> (typeof _un) >> "displayName")]];
	};
};

//Отдаем под контроль другой стороне все зоны и очки за них, соответственно, тоже
{
	if !(_x select 2) then {
		if (getMarkerColor (_x select 0) == (_sideRetreats call SideToColor)) then {
			_retLossLog = composeText [_retLossLog, parseText format ["%1, ", markerText (_x select 0)]];
		};
		(_x select 0) setMarkerColor (_sideStays call SideToColor);
	};
} forEach TVD_capZones;

//Высчитываем общий счет без учета того, что сторона отступила - для лога и сравнения значений потом
_stats = [] call TVD_WinCalculations;
null = [_stats] call TVD_Logger;

//Потери стороны при отступлении:
["retreatLossList",_retLossLog,TVD_sides find _sideRetreats] call TVD_util_MissionLogWriter;

true 