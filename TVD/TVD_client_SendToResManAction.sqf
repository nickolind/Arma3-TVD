/*
null = [] execVM "TVD\TVD_client_SendToResManAction.sqf";
*/

// #define PR(x) private ['x']; x
// #define curTrigger[] trgBase_side0; trgBase_side0

private ["_us","_actID","_actAdded","_actTargets"];

_actTargets = [];
_actID = -1;
_actAdded = 0;

waitUntil {sleep 5; !(isNull player) && (WMT_pub_frzState >= 3) }; //==3 when freeze over, ==1 when freeze up			// + чтобы работало на клиентском сервере

while {true} do {
	
	waitUntil {sleep 5; ( 
		( ( (player in list trgBase_side0) && (side group player == TVD_sides select 0) ) 
		|| 
		( (player in list trgBase_side1) && (side group player == TVD_sides select 1) ) )
	&& _actAdded != 1 ) };
		
	_actTargets = [];

	{
		if ((side group _x in TVD_sides) && (side group _x != side group player) && (_x != player)) then {
							
			_actID = _x addAction [format ["<t color='#ffffff'>Отправить пленника (%1) в тыл</t>", name _x], {
							/*
							target (_this select 0): Object - the object which the action is assigned to
							caller (_this select 1): Object - the unit that activated the action
							ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
							arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
							*/
				_us = if ((_this select 0) in list trgBase_side0) then {0} else {1};		//Сторона, которая отправляет пленника к себе и получает за нее очки

				if !(TVD_RetreatPossible select ([east,west,resistance] find (TVD_sides select _us))) then {		//Если у стороны нет тылов - отправлять в тылы ничего нельзя
					
					titleText ["Невозможно отправить пленника в тыл.", "PLAIN DOWN"];
				} else {
					[[ [_this select 0, _this select 1], { 
						null = [_this select 0, _this select 1] call TVD_SendToResMan;
					}],"BIS_fnc_call", false] call BIS_fnc_MP;		//Вызываем функцию на сервере, передаем цель и вызвавшего Действие
				};
				
				
			}, nil, 0, false, true, "", "((_target in list trgBase_side0) || (_target in list trgBase_side1)) && (alive _target) && (_target getVariable ['ace_captives_ishandcuffed', false])"]; // Перевод на ACE 	// (_target getVariable 'AGM_isCaptive')
			
			_actTargets pushBack [_x, _actID];
		};

	} forEach playableUnits;

	waitUntil {sleep 1; ( !(player in list trgBase_side0) && !(player in list trgBase_side1) ) };

	{					
		(_x select 0) removeAction (_x select 1);
	} forEach _actTargets;
	
};

