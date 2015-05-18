/*
[WEST, express] execVM "TVD\TVD_EndMissionPreps.sqf";

TVD_EndMissionPreps = compile preprocessFileLineNumbers "TVD\TVD_EndMissionPreps.sqf";
[] spawn TVD_EndMissionPreps;
*/

private ["_outcome","_express","_winner","_textOut","_compText","_missionResults"];


_missionResults =  _this select 0;
_outcome = _this select 1;
_express = if (count _this >= 3) then {_this select 2} else {false};


//	Вывод переменных миссии в лог
null = [_missionResults] call TVD_Logger;


// 	Вывод итоговой информации клиентам

_winner = _missionResults select 0;

_textOut = [_outcome, _missionResults] call TVD_util_DebriefWriter;			//Подготовка блока текста

[[ [_textOut, _winner, _express, _missionResults select 1], {					//..и отправка на все машины
	private ["_textOut","_winner","_timer","_tColor","_compText","_prefs","_express","_sup","_isPlayerWin"];
	
	_textOut = _this select 0;
	_winner = _this select 1;
	_express = _this select 2;
	_sup = _this select 3;
	
	_isPlayerWin = (playerSide in ([_winner] call bis_fnc_friendlysides)) && (_winner != sideLogic);
	if (_isPlayerWin) then {
		_tColor = "#057f05"; 
		_compText = parseText "ПОБЕДА"; 
		_prefs = ["ПРЕИМУЩЕСТВЕННАЯ","СЕРЬЕЗНАЯ","СОКРУШИТЕЛЬНАЯ"];
	} else {
		_tColor = "#7f0505"; 
		_compText = parseText "ПОРАЖЕНИЕ"; 
		_prefs = ["ПРЕИМУЩЕСТВЕННОЕ","СЕРЬЕЗНОЕ","СОКРУШИТЕЛЬНОЕ"];
	};
	
	if (_sup == 0) then {
		_compText = parseText "<t size='2.7' align='center' shadow='2'>НИЧЬЯ</t><br/>";
	} else {
		_compText = composeText [parseText format ["<t size='2.7' color='%1' align='center' shadow='2'>%2 %3</t><br/><br/>", _tColor, _prefs select (_sup-1), _compText]];
	};

	_textOut = composeText [_compText, _textOut];
	
	// Disable damage 
	if(player != vehicle player)then{
		(vehicle player) addEventHandler ['HandleDamage', {false}];
	};
	player addEventHandler ['HandleDamage', {false}];

	
	if (_express) then {			//Спешный вывод таблички
		_timer = serverTime;
		while {serverTime - _timer < 30} do {				//release-fix -- 30
			
			"MISSION RESULTS" hintC _textOut;
		
			hintC_arr_EH = findDisplay 72 displayAddEventHandler ["unload", {
				0 = _this spawn {
					_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
					hintSilent "";
				};
			}];
			
			sleep 0.01;
		};
	} else {						//Красивый вывод таблички

		["<t size='1.5'>Завершение миссии</t>", 0, 0.2, 8, 0.2] spawn bis_fnc_dynamictext;

		sleep 2;
		
		titleText ["","BLACK out", 5];
		sleep 5;
		_timer = serverTime;
		while {serverTime - _timer < 30} do {				//release-fix -- 30
			
			"MISSION RESULTS" hintC _textOut;
		
			hintC_arr_EH = findDisplay 72 displayAddEventHandler ["unload", {
				0 = _this spawn {
					_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
					hintSilent "";
				};
			}];
			
			sleep 0.01;
		};

		["end1",_isPlayerWin,1] call BIS_fnc_endMission;																//release-fix - uncomment
	};
	
}],"BIS_fnc_call"] call BIS_fnc_MP;