/*
null = [] execVM "TVD\TVD_MissionCompleteHandler.sqf";

TVD_MissionCompleteHandler = compile preprocessFileLineNumbers "TVD\TVD_MissionCompleteHandler.sqf";
null = [] call TVD_MissionCompleteHandler;
*/

private ["_sideWinner","_trigger","_stats","_un","_i","_fnc_tasksCount","_tasksCount"];

_sideWinner = _this select 0;

mch_finish = false;
mch_ttw = 0;
mch_actContinueAdded = -1;



mch_ttw = 300 min ((WMT_Global_LeftTime select 0) - 40);
publicVariable "mch_ttw";
publicVariable "mch_actContinueAdded";



[[ [_sideWinner], { 
	if ( (isServer) || (playerSide == _this select 0) ) then {
		private ["_time","_waitTime","_res"];
		
		[format ["Ключевая задача выполнена.<br/>Миссия завершится через %1.",[mch_ttw,"MM:SS"] call BIS_fnc_secondsToString],0,0,5,0.2] call bis_fnc_dynamictext;
		
		_time = serverTime;
		_waitTime = mch_ttw;	
		_res = -1;		

		while {true} do {
			_waitTime = 0 max (mch_ttw - (serverTime - _time));
			
			if !(isDedicated) then {	
			
				hint format ["Ключевая задача выполнена.\nМиссия завершится через:\n\n%1",[_waitTime,"MM:SS"] call BIS_fnc_secondsToString];	
					

				if ( !isNil{player getVariable "TVD_UnitValue" select 2} ) then {
					if ( (player getVariable "TVD_UnitValue" select 2 in ["sideLeader","execSideLeader"]) && (_waitTime < 60) && (mch_actContinueAdded != -2) ) then {
						titleText ["Вы можете продлить время миссии, если у стороны остались незаконченные дела.\nИспользуйте ActionMenu >> 'Продлить миссию'.", "PLAIN DOWN"];
						
						if (mch_actContinueAdded == -1) then {
							mch_actContinueAdded = player addAction ["<t color='#ffffff'>КС: Продлить миссию (макс. +5 мин.)</t>", {
								
								mch_ttw = ((mch_ttw + 300) min ((WMT_Global_LeftTime select 0) - 40));
								publicVariable "mch_ttw";
								player removeAction mch_actContinueAdded;
								mch_actContinueAdded = -2;
								publicVariable "mch_actContinueAdded";
								
							}, 1, 0, false, true, "", "(mch_actContinueAdded != -2)"];
						};
					};
				};
					
			};
						
			if (_waitTime <= 1) exitWith {	
				if (isServer) then {mch_finish = true};
			};
			sleep 1;
		};
	};
		
}],"BIS_fnc_call"] call BIS_fnc_MP;

waitUntil {sleep 1; mch_finish};

true 