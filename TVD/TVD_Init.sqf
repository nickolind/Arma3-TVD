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


this setVariable ["TVD_TaskObject", [west, 500, "Уничтожить Грады"]];

0 - сторона, которой назначена задача
1 - цена вопроса
2 - текст задачи
3 - если True - задача считается выполненной. Общая проверка: ( (!(alive _un) || (isNull)) || (_un getVariable "TVD_TaskObject" select 2) )

*/

private ["_i","_ownerSide","_unitSide","_mLock"];

//-------------Параметры, которые можно/нужно настроить в ТВД для правильной работы-------------------
TVD_sides = _this select 0;
TVD_capZonesCount = _this select 1;			//Количество присутствующих на миссии зон для захвата.
TVD_RetreatPossible = _this select 2;			//[east,west,resistance] - If side has possibility to retreat on a mission
TVD_ZoneGain = _this select 3;			//Количество очков за владение одной зоной (50 по умолчанию)
TVD_RetreatRatio = _this select 4;		//Если останется меньше данного процента - у КСа появится возможность отступить
//------------------------------------------------

TVD_capZones = [];
TVD_InitScore = [0,0,0];
TVD_ValUnits = [];
TVD_TaskObjectsList = [0,0];
trgBase_side0 setVariable ["TVD_BaseSide", TVD_sides select 0];
trgBase_side1 setVariable ["TVD_BaseSide", TVD_sides select 1];

TVD_sidesInfScore = [0,0];
TVD_sidesValScore = [0,0];
TVD_sidesZonesScore = [0,0];
TVD_sidesResScore = [0,0];

timeToEnd = -1;
TVD_HeavyLosses = sideLogic;
TVD_SideCanRetreat = [false, false, false];		//When the retreat conditions are met
TVD_SideRetreat = sideLogic;
TVD_MissionLog = [];

colorToSide = compile preprocessFileLineNumbers "TVD\TVD_util_ColorToSide.sqf";
SideToColor = compile preprocessFileLineNumbers "TVD\TVD_util_SideToColor.sqf";
sideToIndex = compile preprocessFileLineNumbers "TVD\TVD_util_sideToIndex.sqf";
TVD_unitRole = compile preprocessFileLineNumbers "TVD\TVD_util_unitRole.sqf";
// TVD_util_autoEvaluate = compile preprocessFileLineNumbers "TVD\TVD_util_autoEvaluate.sqf";
TVD_addSideScore = compile preprocessFileLineNumbers "TVD\TVD_util_addSideScore.sqf";
TVD_Logger = compile preprocessFileLineNumbers "TVD\TVD_util_logger.sqf";
TVD_util_MissionLogWriter = compile preprocessFileLineNumbers "TVD\TVD_util_MissionLogWriter.sqf";
TVD_util_DebriefWriter = compile preprocessFileLineNumbers "TVD\TVD_util_debriefWriter.sqf";

TVD_CaptureVehicle = compile preprocessFileLineNumbers "TVD\TVD_CaptureVehicle.sqf";
TVD_EndMissionPreps = compile preprocessFileLineNumbers "TVD\TVD_EndMissionPreps.sqf";
TVD_HeavyLossesOverride = compile preprocessFileLineNumbers "TVD\TVD_HeavyLossesOverride.sqf";
TVD_HeavyLossesHandler = compile preprocessFileLineNumbers "TVD\TVD_HeavyLossesHandler.sqf";
TVD_HQTransfer = compile preprocessFileLineNumbers "TVD\TVD_HQTransfer.sqf";
// TVD_PreEndMission = compile preprocessFileLineNumbers "TVD\TVD_PreEndMission.sqf";
TVD_Retreat = compile preprocessFileLineNumbers "TVD\TVD_Retreat.sqf";
TVD_ScoreKeeper = compile preprocessFileLineNumbers "TVD\TVD_ScoreKeeper.sqf";
TVD_SendToRes = compile preprocessFileLineNumbers "TVD\TVD_SendToRes.sqf";
TVD_SendToResMan = compile preprocessFileLineNumbers "TVD\TVD_SendToResMan.sqf";
TVD_TaskCompleted = compile preprocessFileLineNumbers "TVD\TVD_TaskCompleted.sqf";
TVD_TasksKeeper = compile preprocessFileLineNumbers "TVD\TVD_TasksKeeper.sqf";
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
	_mLock = 0;
	
	for "_i" from 0 to (TVD_capZonesCount - 1) do {
		{
			if ((_x getVariable  ["Marker", "false"]) == ("mZone_" + str _i)) then {
				_mLock = _x getVariable ["Lock",0];
			};
		} forEach (allMissionObjects "Logic");
		TVD_capZones pushBack [ ("mZone_" + str _i), (getMarkerColor ("mZone_" + str _i)) call colorToSide, (_mLock == 1) ];
		//[ИмяМаркера, Цвет-ПринадлежностьСтороне, Блокированный]
	};
};



//-------------Посчет очков за контроллируемые сторонами зоны
{
	if ((_x select 1) in TVD_sides) then {
		_ownerSide = TVD_sides find (_x select 1);
		TVD_InitScore set [_ownerSide, (TVD_InitScore select _ownerSide) + TVD_ZoneGain];
	} else {
		TVD_InitScore set [2, (TVD_InitScore select 2) + TVD_ZoneGain]; 
		// Если зона на старте миссии никому не принадлежит, то формально она становится нейтральной:
		// Очки за нее добавляются к общему пулу очков, но преимущества ни одна из сторон не получает.
		
		/*
		[[ [_x select 0], {	
			while {true} do {
				hint format ["ОШИБКА!\nЗОНЕ\n\n%1\n\nНЕ ПРИПИСАНА ИЗНАЧАЛЬНАЯ СТОРОНА-ВЛАДЕЛЕЦ.", _this select 0];	// У зоны всегда должна быть выставленна изначальная сторона-владелец из списка сторон TVD_sides
				sleep (5 + random 5);
			};
		}],"BIS_fnc_call"] call BIS_fnc_MP;
		*/
	};
} forEach TVD_capZones;




//--------------Составление массива задач миссии
{
	if (!isNil {_x getVariable "TVD_TaskObject"}) then {   
		if (isNil {_x getVariable "TVD_TaskObject" select 4}) then {
			_x getVariable "TVD_TaskObject" pushBack ["false","false","false"]
		
		
		} else {		//Проверка правильности условий задачи - если результат в кавычках не Boolean (== true || == false), будет выдаваться ошибка
			{
				if !( (call compile _x) || !(call compile _x) ) exitWith {
					[[ [_x], {	
						while {true} do {
							hint format ["ОШИБКА!\nОшибка в условии задачи:\n\n%1", _this select 0];
							sleep (5 + random 5);
						};
					}],"BIS_fnc_call"] call BIS_fnc_MP;
				};
			} forEach (_x getVariable "TVD_TaskObject" select 4);
		};
		
		_x setVariable ["TVD_TaskObjectStatus", "", true];
		
		TVD_TaskObjectsList pushBack _x;
	};
} forEach allMissionObjects "";




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
			_x addMPEventHandler ["mpkilled", {	if (isServer) then {["killed", _this select 0] call TVD_util_MissionLogWriter}	}];		// Важно чтобы этот мпэвентхнедлер был вторым, иначе он затрет данные TVD_UnitValue и TVD_HQTransfer не сработает
																																
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
		if (_unitSide == -1) then {_unitSide = 2};
		
		TVD_InitScore set [_unitSide, (TVD_InitScore select _unitSide) + (_x getVariable "TVD_UnitValue" select 1)];
		TVD_ValUnits pushBack _x;
		
		_x setVariable ["TVD_CapOwner", _x getVariable "TVD_UnitValue" select 0];		//Выставляем изначальную сторону принадлежности техники (позже понадобится для определения, захвачена ли техника врагом)
		
		_x setVariable ["TVD_SentToRes", 0, true];
		
		_x addEventHandler ["GetIn",{											//Проверка, юнит чьей стороны сел в машину. Для проверки, захвачена ли техника врагом.
			[_this select 0, _this select 2] call TVD_CaptureVehicle;
		}];
		// _x addMPEventHandler ["mpkilled", {if (isServer) then {["killed", _this select 0] call TVD_util_MissionLogWriter;}}];
		
		_x addMPEventHandler ["mpkilled", {	if ( (isServer) && (((_this select 0) getVariable "TVD_UnitValue" select 1 ) > 1) ) then {["killed", _this select 0] call TVD_util_MissionLogWriter}	}];		//Не срабатывать на технику с ценностью <= 10 (транспортные машины, обычно)
	};
} forEach vehicles;


publicVariable "TVD_ValUnits";