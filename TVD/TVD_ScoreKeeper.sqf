/*
_scoreKeeperVars = [10,0,0];
TVD_ScoreKeeper = compile preprocessFileLineNumbers "TVD\TVD_ScoreKeeper.sqf";
_scoreKeeperVars = _scoreKeeperVars call TVD_ScoreKeeper;

*/
private ["_infUpdate", "_valUpdate", "_zoneUpdate", "_counter"];

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
// if ( (valUpdate != ({ ( alive _x ) && !(isNull _x) } count ((TVD_ValUnits select 0) + (TVD_ValUnits select 1))) ) || (_counter >= 10) ) then {
	TVD_sidesValScore = [0,0];
	
	for "_i" from 0 to 1 do {	{
			if ( !( alive _x ) || (isNull _x) ) then {
				if (!isNil {_x getVariable "TVD_UnitValue"}) then {_x setVariable ["TVD_UnitValue", nil, true];};
				//(TVD_ValUnits select _i) deleteAt _forEachIndex;
			} else {
				TVD_sidesValScore set [_i, (TVD_sidesValScore select _i) + (_x getVariable ["TVD_UnitValue", 0] select 1)];
			};
		} forEach (TVD_ValUnits select _i); 
	};
		
	// valUpdate = ({ ( alive _x ) && !(isNull _x) } count ((TVD_ValUnits select 0) + (TVD_ValUnits select 1)));
// };


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
[_counter, _infUpdate, _valUpdate, TVD_sidesInfScore, TVD_sidesValScore, TVD_sidesZonesScore]
