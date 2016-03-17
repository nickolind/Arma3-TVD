/*
null = [] execVM "TVD\TVD_EndMissionHandler.sqf";

TVD_EndMissionHandler = compile preprocessFileLineNumbers "TVD\TVD_EndMissionHandler.sqf";
null = [] call TVD_EndMissionHandler;
*/

private ["_message","_showTo"];

// _endCause = _this select 0;
// _sideHeavyLosses = _this select 1;


em_result = false;
em_ttw = 0;
em_actContinueAdded = -1;
em_bonus = 2;
em_extended = false;
_showTo = [];

switch (_this select 0) do {

	//------Вышло время
	case 1: {
		
	};
	
	
	//------Потери
	case 2: {
		_showTo pushBack (TVD_Sides select (1 - (TVD_Sides find (_this select 1))));
		_message = "Количество вражеских сил на поле боя слишком мало.";
	};
	
	
	//------Сторона отступила
	case 3: {
		_showTo = TVD_Sides;
		_message = format ["Сторона %1 отступила.", _this select 1];
		em_bonus = 0;
	};
	
	
	//------Выполнена ключевая задача
	case 4: {
		_showTo = TVD_Sides;
		_message = format ["%1 выполнили КЛЮЧЕВУЮ задачу.", _this select 1];
	};
};

if (TVD_TimeExtendPossible) then {
	// Доделать
} else {
	em_ttw = 60 min ((WMT_Global_LeftTime select 0) - 300);
	publicVariable "em_ttw";
	publicVariable "em_actContinueAdded";
	publicVariable "em_bonus";
	publicVariable "em_extended";
};

[[ [_showTo, _message], {
	if ( isNil{TVD_Curator} ) then {TVD_Curator = objNull};
	if ( (isServer) || (side group player in (_this select 0)) || !(alive player) || (player == TVD_Curator) ) then {
		private ["_time","_waitTime"];
		
		[format ["%1<br/><br/>Миссия завершится через %2", _this select 1, [em_ttw,"MM:SS"] call BIS_fnc_secondsToString],0,0,5,0.2] call bis_fnc_dynamictext;
		
		_time = serverTime;
		_waitTime = em_ttw;	
		// _bonus = _this select 2;	

		while {true} do {
			_waitTime = 0 max (em_ttw - (serverTime - _time));
			
			if !(isDedicated) then {	
			
				hint format ["%1\n\nМиссия завершится через:\n\n%2\n\n(КС может продлить (%3 раз(а)))", _this select 1, [_waitTime,"MM:SS"] call BIS_fnc_secondsToString, em_bonus];	
				
				if (em_extended) then {
					em_extended = false;
					publicVariable "em_extended";
					["Миссия продлена КСом",0,0,3,0.2] call bis_fnc_dynamictext;
				};
				
					
				if ( !isNil{player getVariable "TVD_UnitValue" select 2} ) then {
					if ( (player getVariable "TVD_UnitValue" select 2 in ["sideLeader","execSideLeader"]) && (_waitTime < 60) && (em_actContinueAdded != -2) ) then {
						titleText ["Вы можете продлить время, если сторона не успевает выполнить задачи.\nИспользуйте ActionMenu >> 'Продлить миссию'.", "PLAIN DOWN"];
						
						if (em_actContinueAdded == -1) then {
							em_actContinueAdded = player addAction ["<t color='#ffffff'>КС: Продлить миссию (до +5 мин.)</t>", {
								
								em_ttw = em_ttw + (300 min ((WMT_Global_LeftTime select 0) - 300));
								publicVariable "em_ttw";
								player removeAction em_actContinueAdded;
								em_actContinueAdded = -1;
								publicVariable "em_actContinueAdded";
								em_bonus = em_bonus - 1;
								publicVariable "em_bonus";
								em_extended = true;
								publicVariable "em_extended";
								
							}, 1, 0, false, true, "", "(em_actContinueAdded != -2)"];
						};
					};
				};
					
			};
			
			if (isServer) then {
				
				if ( (WMT_Global_LeftTime select 0 <= 300) || (em_bonus <= 0) ) then {
					em_actContinueAdded = -2;
					publicVariable "em_actContinueAdded";
				};

			};
			
			if (_waitTime <= 1) exitWith {	
				if (isServer) then {em_result = true};
			};
			sleep 1;
		};
	};
		
}],"BIS_fnc_call"] call BIS_fnc_MP;

waitUntil {sleep 1; em_result};

true
