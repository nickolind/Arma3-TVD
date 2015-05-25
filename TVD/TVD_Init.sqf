/*
null = [] spawn compileFinal preprocessFileLineNumbers "TVD\TVD_Init.sqf";

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
TVD_sides = [west, independent];
TVD_capZonesCount = 0;			//Количество присутствующих на миссии зон для захвата.
TVD_RetreatRatio = 0.75;		//Если останется меньше данного процента - у КСа появится возможность отступить
TVD_RetreatPossible = [true,true,false];			//[east,west,resistance] - If side has possibility to retreat on a mission
publicVariable "TVD_RetreatPossible";
//------------------------------------------------

TVD_capZones = [];
TVD_InitScore = [0,0];
TVD_ValUnits = [];

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
TVD_Logger = compile preprocessFileLineNumbers "TVD\TVD_util_logger.sqf";
TVD_util_MissionLogWriter = compile preprocessFileLineNumbers "TVD\TVD_util_MissionLogWriter.sqf";
TVD_util_DebriefWriter = compile preprocessFileLineNumbers "TVD\TVD_util_debriefWriter.sqf";

TVD_HQTransfer = compile preprocessFileLineNumbers "TVD\TVD_HQTransfer.sqf";
TVD_ScoreKeeper = compile preprocessFileLineNumbers "TVD\TVD_ScoreKeeper.sqf";
TVD_WinCalculations = compile preprocessFileLineNumbers "TVD\TVD_WinCalculations.sqf";
TVD_EndMissionPreps = compile preprocessFileLineNumbers "TVD\TVD_EndMissionPreps.sqf";
TVD_HeavyLossesOverride = compile preprocessFileLineNumbers "TVD\TVD_HeavyLossesOverride.sqf";
TVD_Retreat = compile preprocessFileLineNumbers "TVD\TVD_Retreat.sqf";
TVD_SendToRes = compile preprocessFileLineNumbers "TVD\TVD_SendToRes.sqf";




//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
waitUntil {sleep 3; time > 0};
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
	_ownerSide = TVD_sides find (_x select 1);
	TVD_InitScore set [_ownerSide, (TVD_InitScore select _ownerSide) + 50];
} forEach TVD_capZones;


//-------------Посчет живой силы воюющих сторон
{	
	if ( (side _x in TVD_sides) ) then {
		if (!isNil {_x getVariable "TVD_UnitValue"}) then {
			_unitSide = TVD_sides find ( _x getVariable "TVD_UnitValue" select 0 );
			
			TVD_InitScore set [_unitSide, (TVD_InitScore select _unitSide) + (_x getVariable "TVD_UnitValue" select 1)];
			TVD_ValUnits pushBack _x;
			_x addMPEventHandler ["mpkilled", {if (isServer) then {null = ["killed", _this select 0] call TVD_util_MissionLogWriter;}}];
			
			if (!isNil {_x getVariable "TVD_UnitValue" select 2}) then { 					//Если картодел назначил роль ценному пеху
				if ( _x getVariable "TVD_UnitValue" select 2 == "sideLeader") then {
					_x addMPEventHandler ["mpkilled", {if (isServer) then {null = ["slTransfer", _this select 0] call TVD_HQTransfer;}}];
				};
			} else {												//Если картодел сам не назначил роль - роль по умолчанию ком.отделения.
				_x getVariable "TVD_UnitValue" pushBack "squadLeader"; 						//Добавляем элемент в массив
				_x setVariable ["TVD_UnitValue", _x getVariable "TVD_UnitValue", true];		//Броандкастим обновленное значение
			};		//Убрать когда напишу util_autoEvaluate
		} else {
			_unitSide = TVD_sides find (side _x);
			TVD_InitScore set [_unitSide, (TVD_InitScore select _unitSide) + 10];
		};
	};
} forEach AllUnits;


//------------Подсчет техники воющих сторон
{
	if (!isNil {_x getVariable "TVD_UnitValue"}) then {
		_unitSide = TVD_sides find ( _x getVariable "TVD_UnitValue" select 0 );
		
		TVD_InitScore set [_unitSide, (TVD_InitScore select _unitSide) + (_x getVariable "TVD_UnitValue" select 1)];
		TVD_ValUnits pushBack _x;
		
		_x setVariable ["TVD_CapOwner", _x getVariable "TVD_UnitValue" select 0];		//Выставляем изначальную сторону принадлежности техники (позже понадобится для определения, захвачена ли техника врагом)
		
		null = [_x] call TVD_SendToRes;
		
		_x addEventHandler ["GetIn",{											//Проверка, юнит чьей стороны сел в машину. Для проверки, захвачена ли техника врагом.
			if (side (_this select 2) in TVD_sides) then {
				(_this select 0) setVariable ["TVD_CapOwner", side (_this select 2)];
			};
		}];
		_x addMPEventHandler ["mpkilled", {if (isServer) then {null = ["killed", _this select 0] call TVD_util_MissionLogWriter;}}];
	};
} forEach vehicles;