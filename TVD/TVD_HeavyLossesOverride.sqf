﻿/*
Boolean = [] execVM "TVD\TVD_HeavyLossesOverride.sqf";

TVD_HeavyLossesOverride = compile preprocessFileLineNumbers "TVD\TVD_HeavyLossesOverride.sqf";
Boolean = [] spawn TVD_HeavyLossesOverride; 
*/

private ["_endtimer","_playerratio","_resistanceFriendSide","_playersActualBegin","_playersActualNow"];

if (isNil "TVD_hl_sidelimits") then {
	TVD_hl_sidelimits = [0,0,0];
};

if (isNil "TVD_hl_ratio") then {
	TVD_hl_ratio = [0.1,0.1,0.1];
};

waitUntil {sleep 5; (!isNil{wmt_playerCountInit}) && (!isNil{wmt_PlayerCountNow})};

_endtimer = false;

_resistanceFriendSide = switch (true) do {
	case (west in ([resistance] call BIS_fnc_friendlySides)) : {west};
	case (east in ([resistance] call BIS_fnc_friendlySides)) : {east};
	default {sideUnknown};
	
};

while {not _endtimer} do {
	{
		_playerratio = TVD_hl_ratio select _foreachindex;
		if ( not _endtimer and {_x in [east,west] or _resistanceFriendSide == sideUnknown} ) then {
			_playersActualBegin = (wmt_playerCountInit select _foreachindex) + ( if (_x == _resistanceFriendSide) then {wmt_playerCountInit select 2} else {0} );
			_playersActualNow = (wmt_PlayerCountNow select _foreachindex) + ( if (_x == _resistanceFriendSide) then {wmt_PlayerCountNow select 2} else {0} );

			if ( _playersActualBegin != 0 ) then {
				if ( (_playersActualNow / _playersActualBegin < TVD_RetreatRatio) && !(TVD_SideCanRetreat select _foreachindex) ) then {			//Проверка, были ли достаточные потери у стороны, чтобы дать возможность КСу отступить
					TVD_SideCanRetreat set [_foreachindex, true];
					publicVariable "TVD_SideCanRetreat";
				};
			
				if ( _playerratio !=0 and {_playersActualNow / _playersActualBegin < _playerratio} ) exitWith {_endtimer = true; TVD_HeavyLosses = _x};
				if ( _playersActualNow <= ( TVD_hl_sidelimits select _foreachindex ) ) exitWith {_endtimer = true; TVD_HeavyLosses = _x};
			};
		};
	} forEach [east,west,resistance];
	sleep 10;
};