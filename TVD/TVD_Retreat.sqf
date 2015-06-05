/*
null = [] execVM "TVD\TVD_Retreat.sqf";

TVD_Retreat = compile preprocessFileLineNumbers "TVD\TVD_Retreat.sqf";
null = [] call TVD_Retreat;
*/
private ["_sideRetreats","_sideStays","_trigger","_stats"];

_sideRetreats = _this select 0;
_sideStays = sideLogic;
_trigger = objNull;

if (_sideRetreats == TVD_sides select 0) then {_trigger = trgBase_side0; _sideStays = TVD_sides select 1};
if (_sideRetreats == TVD_sides select 1) then {_trigger = trgBase_side1; _sideStays = TVD_sides select 0};

_trigger setTriggerActivation ["ANY","PRESENT",true];
{																		//Убиваем всех кто не в зоне из отступившей стороны
	if ((side group _x == _sideRetreats) && !(_x in list _trigger)) then { 
		[[ [], { 	["<t color='#e50000'>Вас бросили при отступлении</t>", 0, 0.7, 4, 0.2] spawn bis_fnc_dynamictext; 	 }],"BIS_fnc_call", _x] call BIS_fnc_MP; 
		_x setDamage 1;
	};
} forEach playableUnits;

null = [] call TVD_WinCalculations; 		//Пересчитать TVD_ValUnits, иначе в цикле ниже может быть выход за пределы массива изза юнитов "soldier"

//Вся техника не в зоне эвакуации становится захваченной врагом
for "_i" from 0 to (count TVD_ValUnits - 1) do {
	_un = TVD_ValUnits select _i;
	if ( !(_un in list _trigger) && ( (_un getVariable "TVD_UnitValue" select 0) == _sideRetreats) ) then {
		
		_un setVariable ["TVD_CapOwner", _sideStays];
		
		null = ["retreatLoss", _un] call TVD_util_MissionLogWriter;
	};
	
};

//Отдаем под контроль другой стороне все зоны и очки за них, соответственно, тоже
{
	(_x select 0) setMarkerColor (_sideStays call SideToColor);
} forEach TVD_capZones;

//Высчитываем общий счет без учета того, что сторона отступила - для лога и сравнения значений потом
_stats = [] call TVD_WinCalculations;
null = [_stats] call TVD_Logger;

//Теперь компенсируем потери отступившей стороны и пишем в лог об этом
_stats = [TVD_sides find _sideRetreats] call TVD_WinCalculations;		//Отступает сторона 0 или сторон 1 из TVD_sides


_stats