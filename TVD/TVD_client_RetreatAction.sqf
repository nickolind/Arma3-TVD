/*
null = [] execVM "TVD\TVD_client_RetreatAction.sqf";
*/

waitUntil{ sleep 1; !(isNull player) };

if (!isNil {player getVariable "TVD_UnitValue"}) then {
	private ["_us","_unitValue"];
	
	_us = [east,west,resistance] find (side group player);
	_unitValue = player getVariable "TVD_UnitValue";
	
	waitUntil {sleep 1; !isNil {TVD_RetreatPossible} };
	
	if (!isNil {_unitValue select 2}) then {
	
		//Команда на отступление
		if ( ((_unitValue select 2 == "sideLeader") || (_unitValue select 2 == "execSideLeader")) && (TVD_RetreatPossible select _us) ) then {
			[] spawn {
				private ["_usC","_rand","_ai","_i"];
				
				_usC = [east,west,resistance] find (side player);
				waitUntil {sleep 5; TVD_SideCanRetreat select _usC};
				
				retrAction = 1;
				actIndex = [];
				
				player addAction ["<t color='#ffffff'>КС: Команда на отступление</t>", {
					retrAction = 2;
				}, 1, 0, false, false, "", "(retrAction == 1) && (timeToEnd == -1)"];
				
				player addAction ["<t color='#ffffff'>ОТСТУПЛЕНИЕ: Подтвердить завершение миссии</t>", {
					retrAction = 3;
					_rand = 1 + floor random 5;
					for "_i" from 0 to 6 do {
						if (_i == _rand) then {
							_ai = player addAction ["<t color='#ffffff'>ОТСТУПЛЕНИЕ: Подтвердить (все кто СЕЙЧАС не в тыловой зоне - сдадутся в плен)</t>", {
								retrAction = 0;
								{player removeAction _x} forEach actIndex;
								actIndex = nil;
								TVD_SideRetreat = side player;
								publicVariableServer "TVD_SideRetreat";
							}, 1, 0, false, true, "", "(timeToEnd == -1)"];
							actIndex pushBack _ai;
						} else {
							_ai = player addAction ["<t color='#8BC8D6'>ОТСТУПЛЕНИЕ: Отмена</t>", {
								retrAction = 1;
								{player removeAction _x} forEach actIndex;
								actIndex = [];
							}, 1, 0, false, true, "", ""];
							actIndex pushBack _ai;
						};
					};	
				}, 1, 0, false, false, "", "(retrAction == 2) && (timeToEnd == -1)"];
				
				player addAction ["<t color='#8BC8D6'>ОТСТУПЛЕНИЕ: Отмена</t>", {
					retrAction = 1;
				}, 1, 0, false, true, "", "(retrAction == 2)"];
			};
		};
		
		
		/*
		//Команда передачи командования другому
		if ( (_unitValue select 2 == "execSideLeader") ) then {
			[] spawn {
				private ["_rand","_ai","_i"];
				
				transAction = 1;
				
				player addAction ["КС: Передать командование стороной", {
					transAction = 2;
					
					for "_i" from 0 to 6 do {
						if (_i == _rand) then {
							_ai = player addAction ["<t color='#ffffff'>ОТСТУПЛЕНИЕ: Да, я уверен - завершить миссию</t>", {
								transAction = 0;
								{player removeAction _x} forEach actIndex;
								actIndex = nil;
								TVD_SideRetreat = side player;
								publicVariableServer "TVD_SideRetreat";
							}, 1, 0, false, true, "", ""];
							actIndex pushBack _ai;
						} else {
							_ai = player addAction ["<t color='#8BC8D6'>ОТСТУПЛЕНИЕ: Отмена</t>", {
								transAction = 1;
								{player removeAction _x} forEach actIndex;
								actIndex = [];
							}, 1, 0, false, true, "", ""];
							actIndex pushBack _ai;
						};
					};	
					
				}, 1, 0, false, true, "", "transAction == 1"];
				
				// player addAction ["<t color='#ffffff'>ПЕРЕДАТЬ: Подтвердить</t>", {
					
					// transAction = 3;
					// _rand = 1 + floor random 5;
					
					
				// }, 1, 0, false, true, "", "transAction == 2"];
				
				player addAction ["<t color='#8BC8D6'>ПЕРЕДАТЬ КОМАНДОВАНИЕ: Отмена</t>", {
					transAction = 1;
				}, 1, 0, false, true, "", "transAction == 2"];
			};
		};
		*/
	};
};