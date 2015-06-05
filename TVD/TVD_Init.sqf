/*
null = [sides, capZonesCount, RetreatPossible, ZoneGain, RetreatRatio] call compileFinal preprocessFileLineNumbers "TVD\TVD_Init.sqf";

Вызов из инита юнита:
this setVariable ["TVD_UnitValue",[WEST,100, "sideLeader"]];
this setVariable ["TVD_UnitValue",[independent,100, "role"]];

0 - сторона, к кот приписан
1 - ценность (относительно жизни обычного солдата = 10)
Для юнита-человека
2 - роль:	"squadLeader" - (по умолч.) ком. отделения (обычно = 20) (нужны для передачи командования при смерти КСа - без этого некому будет скомандовать отступление и пр.)
			"sideLeader" - КС (обычно = 100) (должен быть только один)
			"sideVIP" - некий VIP (ценность соразмено его важности)

Отсчет от жизни 1 бойца = 10 очкам

*/

private ["_i","_ownerSide","_unitSide"];

//-------------Параметры, которые можно/нужно настроить в ТВД для правильной работы-------------------
TVD_sides = _this select 0;
TVD_capZonesCount = _this select 1;			//Количество присутствующих на миссии зон для захвата.
TVD_RetreatPossible = _this select 2;			//[east,west,resistance] - If side has possibility to retreat on a mission
TVD_ZoneGain = _this select 3;			//Количество очков за владение одной зоной (50 по умолчанию)
TVD_RetreatRatio = _this select 4;		//Если останется меньше данного процента - у КСа появится возможность отступить
//------------------------------------------------

TVD_capZones = [];
TVD_InitScore = [0,0];
TVD_ValUnits = [];
trgBase_side0 setVariable ["TVD_BaseSide", TVD_sides select 0];
trgBase_side1 setVariable ["TVD_BaseSide", TVD_sides select 1];

TVD_sidesInfScore = [0,0];
TVD_sidesValScore = [0,0];
TVD_sidesZonesScore = [0,0];
TVD_sidesResScore = [0,0];

timeToEnd = false;
TVD_HeavyLosses = sideLogic;
TVD_SideCanRetreat = [false, false, false];		//When the retreat conditions are met
TVD_SideRetreat = sideLogic;
TVD_MissionLog = [];

colorToSide = compileFinal preprocessFileLineNumbers "TVD\TVD_util_ColorToSide.sqf";
SideToColor = compileFinal preprocessFileLineNumbers "TVD\TVD_util_SideToColor.sqf";
sideToIndex = compileFinal preprocessFileLineNumbers "TVD\TVD_util_sideToIndex.sqf";
TVD_unitRole = compileFinal preprocessFileLineNumbers "TVD\TVD_util_unitRole.sqf";
TVD_Logger = compile preprocessFileLineNumbers "TVD\TVD_util_logger.sqf";
TVD_util_MissionLogWriter = compile preprocessFileLineNumbers "TVD\TVD_util_MissionLogWriter.sqf";
TVD_util_DebriefWriter = compile preprocessFileLineNumbers "TVD\TVD_util_debriefWriter.sqf";

TVD_CaptureVehicle = compile preprocessFileLineNumbers "TVD\TVD_CaptureVehicle.sqf";
TVD_EndMissionPreps = compile preprocessFileLineNumbers "TVD\TVD_EndMissionPreps.sqf";
TVD_HeavyLossesOverride = compile preprocessFileLineNumbers "TVD\TVD_HeavyLossesOverride.sqf";
TVD_HQTransfer = compile preprocessFileLineNumbers "TVD\TVD_HQTransfer.sqf";
TVD_Retreat = compile preprocessFileLineNumbers "TVD\TVD_Retreat.sqf";
TVD_ScoreKeeper = compile preprocessFileLineNumbers "TVD\TVD_ScoreKeeper.sqf";
TVD_SendToRes = compile preprocessFileLineNumbers "TVD\TVD_SendToRes.sqf";
TVD_SendToResMan = compile preprocessFileLineNumbers "TVD\TVD_SendToResMan.sqf";
TVD_WinCalculations = compile preprocessFileLineNumbers "TVD\TVD_WinCalculations.sqf";




//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
waitUntil {sleep 3; time > 0};
publicVariable "TVD_sides";
publicVariable "TVD_RetreatPossible";
publicVariable "TVD_SideCanRetreat";




//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
waitUntil {sleep 5; WMT_pub_frzState >= 3}; //==3 when freeze over, ==1 when freeze up

//--- Настройка: количество зон
if (TVD_capZonesCount != 0) then {
	for "_i" from 0 to (TVD_capZonesCount - 1) do {
		TVD_capZones pushBack [ ("mZone_" + str _i), (getMarkerColor ("mZone_" + str _i)) call colorToSide ];
	};
};



//-------------Посчет очков за контроллируемые сторонами зоны
{
	if ((_x select 1) in TVD_sides) then {
		_ownerSide = TVD_sides find (_x select 1);
		TVD_InitScore set [_ownerSide, (TVD_InitScore select _ownerSide) + TVD_ZoneGain];
	} else {
		[_x select 0] spawn {
			while {true} do {
				[[ [_this select 0], {	
					hint format ["ОШИБКА!\nЗОНЕ\n\n%1\n\nНЕ ПРИПИСАНА ИЗНАЧАЛЬНАЯ СТОРОНА-ВЛАДЕЛЕЦ.", _this select 0];	// У зоны всегда должна быть выставленна изначальная сторона-владелец из списка сторон TVD_sides
				}],"BIS_fnc_call"] call BIS_fnc_MP;
				sleep (5 + random 5);
			};
		};
			//TVD_InitScore set [0, (TVD_InitScore select 0) + TVD_ZoneGain];		// Если зона на старте миссии никому не принадлежит, то формально она приписывается Стороне0 - на расстановку сил не влияет, однако без такого хака, очки за зоны выпадут из формулы и нарушится баланс (полезут отрицательные соотношения).
	};
} forEach TVD_capZones;


//-------------Посчет живой силы воюющих сторон
{	
	if ( (side _x in TVD_sides) ) then {
		if (!isNil {_x getVariable "TVD_UnitValue"}) then {
			_unitSide = TVD_sides find ( _x getVariable "TVD_UnitValue" select 0 );
			
			TVD_InitScore set [_unitSide, (TVD_InitScore select _unitSide) + (_x getVariable "TVD_UnitValue" select 1)];
			TVD_ValUnits pushBack _x;
						
			if (!isNil {_x getVariable "TVD_UnitValue" select 2}) then { 					//Если картодел назначил роль ценному пеху
				if ( _x getVariable "TVD_UnitValue" select 2 == "sideLeader") then {
					_x addMPEventHandler ["mpkilled", {if (isServer) then {null = ["slTransfer", _this select 0] call TVD_HQTransfer;}}];		
				};
			} else {												//Если картодел сам не назначил роль - роль по умолчанию ком.отделения.
				_x getVariable "TVD_UnitValue" pushBack "squadLeader"; 						//Добавляем элемент в массив
				_x setVariable ["TVD_UnitValue", _x getVariable "TVD_UnitValue", true];		//Броандкастим обновленное значение
			};		//Убрать когда напишу util_autoEvaluate
			
															//Вызывает логРайтер, который в конце вызовет скорКипер, который удалит TVD_UnitValue убитого юнита
			_x addMPEventHandler ["mpkilled", {if (isServer) then {null = ["killed", _this select 0] call TVD_util_MissionLogWriter;}}];		// Важно чтобы этот мпэвентхнедлер был вторым, иначе он затрет данные TVD_UnitValue и TVD_HQTransfer не сработает
																																				
		} else {
			_unitSide = TVD_sides find (side _x);
			TVD_InitScore set [_unitSide, (TVD_InitScore select _unitSide) + 10];
		};
		
		_x setVariable ['AGM_isCaptive', false, true];
	};
} forEach AllUnits;


//------------Подсчет техники воющих сторон
{
	if (!isNil {_x getVariable "TVD_UnitValue"}) then {
		_unitSide = TVD_sides find ( _x getVariable "TVD_UnitValue" select 0 );
		
		TVD_InitScore set [_unitSide, (TVD_InitScore select _unitSide) + (_x getVariable "TVD_UnitValue" select 1)];
		TVD_ValUnits pushBack _x;
		
		_x setVariable ["TVD_CapOwner", _x getVariable "TVD_UnitValue" select 0];		//Выставляем изначальную сторону принадлежности техники (позже понадобится для определения, захвачена ли техника врагом)
		
		_x setVariable ["TVD_SentToRes", 0, true];
		
		_x addEventHandler ["GetIn",{											//Проверка, юнит чьей стороны сел в машину. Для проверки, захвачена ли техника врагом.
			[_this select 0, _this select 2] call TVD_CaptureVehicle;
		}];
		// _x addMPEventHandler ["mpkilled", {if (isServer) then {["killed", _this select 0] call TVD_util_MissionLogWriter;}}];
		_x addMPEventHandler ["mpkilled", {if ( (isServer) && (((_this select 0) getVariable "TVD_UnitValue" select 1 ) > 1) ) then {["killed", _this select 0] call TVD_util_MissionLogWriter;}}];		//Не срабатывать на технику с ценностью <= 10 (транспортные машины, обычно)
	};
} forEach vehicles;

publicVariable "TVD_ValUnits";