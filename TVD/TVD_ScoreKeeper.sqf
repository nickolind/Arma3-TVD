/*
_scoreKeeperVars = [10,0,0];
TVD_ScoreKeeper = compile preprocessFileLineNumbers "TVD\TVD_ScoreKeeper.sqf";
_scoreKeeperVars = _scoreKeeperVars call TVD_ScoreKeeper;

*/
private ["_valUpdate", "_zoneUpdate", "_counter","_i","_un","_us"];

_counter = _this select 0;
_infUpdate = _this select 1;
_valUpdate = _this select 2;


// _counter = _counter + 1;

//Подсчет обычных солдат (стандартно - по 10 очков за штуку)
TVD_sidesInfScore = [0,0];

{
	if ( (side group _x in TVD_sides) && (isPlayer _x) && (isNil {_x getVariable "TVD_UnitValue"}) ) then {
		_us = TVD_sides find (side group _x);
		
		if (_x getVariable 'AGM_isCaptive') then {			// !!! _us rewritten
			if ((vehicle _x in list trgBase_side0) || (vehicle _x in list trgBase_side1) ) then {
				//Если солдат пленен и находится на тыловой зоне вражеской стороны:
				if ( 	( (vehicle _x in list trgBase_side0) && ((side group _x) != (trgBase_side0 getVariable "TVD_BaseSide")) ) 
						|| 
						( (vehicle _x in list trgBase_side1) && ((side group _x) != (trgBase_side1 getVariable "TVD_BaseSide")) ) 
				) then {
					_us = 1 - _us;	// Выбирается сторона из TVD_sides, противоположная изначальной стороне юнита - т.е. сторона, захватившая солдата получает всю его ценность себе, тогда как изначальная сторона получает 0. Итого разница составит 200% ценности юнита.	
				};
			};
		};
		
		TVD_sidesInfScore set [_us, (TVD_sidesInfScore select _us) + 10];
	};
} forEach playableUnits;



//Подсчет ценных юнитов (техника, командиры, ... )
TVD_sidesValScore = [0,0];

for "_i" from 0 to (count TVD_ValUnits - 1) do {
	_un = TVD_ValUnits select _i;
	_us = TVD_sides find (_un getVariable "TVD_UnitValue" select 0);
	if ( !( alive _un ) || (isNull _un) ) then {
		if (!isNil {_un getVariable "TVD_UnitValue"}) then {_un setVariable ["TVD_UnitValue", nil, true];};
		TVD_ValUnits deleteAt _i;
		publicVariable "TVD_ValUnits";
		_i = _i - 1;
	} else {
		if (!isNil {_un getVariable "TVD_CapOwner"}) then {		//Если юнит - техника, то у него будет параметр CapOwner
			
			if  ((_un getVariable "TVD_CapOwner") != (_un getVariable "TVD_UnitValue" select 0)) then {		//Если текущая сторона-владелец отличается от изначальной - то захватившей стороне перепадает 50% ценности техники (изначальной стороне, соответственно -100%)
				_us = TVD_sides find (_un getVariable "TVD_CapOwner");		// !!! _us rewritten
				TVD_sidesValScore set [_us, (TVD_sidesValScore select _us) + ((_un getVariable ["TVD_UnitValue", 0] select 1) / 2)];
			} else {
				TVD_sidesValScore set [_us, (TVD_sidesValScore select _us) + (_un getVariable ["TVD_UnitValue", 0] select 1)];		//Если текущая сторона-владелец НЕ отличается от изначальной - то начисление как обычно
			};
			
		} else {	// Этот блок для НЕтехники (нет параметра CapOwner)
			
			if ( (_un getVariable 'AGM_isCaptive') ) then {			// !!! _us rewritten
				if ((vehicle _un in list trgBase_side0) || (vehicle _un in list trgBase_side1) ) then {
					//Если солдат пленен и находится на тыловой зоне вражеской стороны:
					if ( 	( (vehicle _un in list trgBase_side0) && ((_un getVariable "TVD_UnitValue" select 0) != (trgBase_side0 getVariable "TVD_BaseSide")) ) 
							|| 
							( (vehicle _un in list trgBase_side1) && ((_un getVariable "TVD_UnitValue" select 0) != (trgBase_side1 getVariable "TVD_BaseSide")) ) 
					) then {
						_us = 1 - _us;	// Выбирается сторона из TVD_sides, противоположная изначальной стороне юнита - т.е. сторона, захватившая солдата получает всю его ценность себе, тогда как изначальная сторона получает 0. Итого разница составит 200% ценности юнита.	
					};
				};
			}; 
			
			TVD_sidesValScore set [_us, (TVD_sidesValScore select _us) + (_un getVariable ["TVD_UnitValue", 0] select 1)];
		
		};
	};
	
};



//Проверка, изменилась ли принадженость зон -> Подсчет очков за захваченные зоны (в данной миссии - 50 за одну (TVD_ZoneGain))
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
		TVD_sidesZonesScore set [_ownerSide, (TVD_sidesZonesScore select _ownerSide) + TVD_ZoneGain];
	} forEach TVD_capZones;
};


// if (_counter >= 10) then {_counter = 0};
[_counter, _infUpdate, _valUpdate, TVD_sidesInfScore, TVD_sidesValScore, TVD_sidesZonesScore, TVD_sidesResScore]
