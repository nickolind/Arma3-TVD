/*
_scoreKeeperVars = [10,0,0];
TVD_ScoreKeeper = compile preprocessFileLineNumbers "TVD\TVD_ScoreKeeper.sqf";
_scoreKeeperVars = _scoreKeeperVars call TVD_ScoreKeeper;

*/
private ["_infUpdate", "_valUpdate", "_zoneUpdate", "_counter","_i","_un","_us","_usC"];

_counter = _this select 0;
_infUpdate = _this select 1;
_valUpdate = _this select 2;


// _counter = _counter + 1;

//Проверка если количество живых солдат изменилось -> Подсчет обычных солдат (стандартно - по 10 очков за штуку)
if ( (_infUpdate != count playableUnits) || (_counter >= 10) ) then {
	for "_i" from 0 to 1 do {
		TVD_sidesInfScore set [_i, 10 * ( { (side _x == TVD_sides select _i) && (isPlayer _x) && (isNil {_x getVariable "TVD_UnitValue"}) } count playableUnits ) ];
	};
	_infUpdate = count playableUnits;
};


//Проверка, изменилось ли количество -> Подсчет ценных юнитов (техника, командиры, ... )
TVD_sidesValScore = [0,0];

for "_i" from 0 to (count TVD_ValUnits - 1) do {
	_un = TVD_ValUnits select _i;
	_us = TVD_sides find (_un getVariable "TVD_UnitValue" select 0);
	if ( !( alive _un ) || (isNull _un) ) then {
		if (!isNil {_un getVariable "TVD_UnitValue"}) then {_un setVariable ["TVD_UnitValue", nil, true];};
		TVD_ValUnits deleteAt _i;
		_i = _i - 1;
	} else {
		if (!isNil {_un getVariable "TVD_CapOwner"}) then {		//Если юнит - техника, то у него будет параметр CapOwner
			if  ((_un getVariable "TVD_CapOwner") != (_un getVariable "TVD_UnitValue" select 0)) then {		//Если текущая сторона-владелец отличается от изначальной - то захватившей стороне перепадает 50% ценности техники (изначальной стороне, соответственно -100%)
				_us = TVD_sides find (_un getVariable "TVD_CapOwner");		// !!! _us rewritten
				TVD_sidesValScore set [_us, (TVD_sidesValScore select _us) + ((_un getVariable ["TVD_UnitValue", 0] select 1) / 2)];
			} else {
				TVD_sidesValScore set [_us, (TVD_sidesValScore select _us) + (_un getVariable ["TVD_UnitValue", 0] select 1)];		//Если текущая сторона-владелец НЕ отличается от изначальной - то начисление как обычно
			};
		} else {
			TVD_sidesValScore set [_us, (TVD_sidesValScore select _us) + (_un getVariable ["TVD_UnitValue", 0] select 1)];
		};
	};
	
};



//Проверка, изменилась ли принадженость зон -> Подсчет очков за захваченные зоны (в данной миссии - 50 за одну)
_zoneUpdate = false;
{
	_curZone = (TVD_capZones select _forEachIndex);
	if ( ( _curZone select 1) != ( (getMarkerColor (_curZone select 0) ) call colorToSide ) ) exitWith {_zoneUpdate = true}; 
} forEach TVD_capZones;
if ( (_zoneUpdate) || (_counter >= 10) ) then {
	TVD_sidesZonesScore = [0,0];
	{
		(TVD_capZones select _forEachIndex) set [1, (getMarkerColor ((TVD_capZones select _forEachIndex) select 0)) call colorToSide];
		_ownerSide = TVD_sides find (_x select 1);
		TVD_sidesZonesScore set [_ownerSide, (TVD_sidesZonesScore select _ownerSide) + 50];
	} forEach TVD_capZones;
};


// if (_counter >= 10) then {_counter = 0};
[_counter, _infUpdate, _valUpdate, TVD_sidesInfScore, TVD_sidesValScore, TVD_sidesZonesScore, TVD_sidesResScore]
