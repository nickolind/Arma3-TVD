/*
null = [] execVM "TVD\TVD_client_retreatSoldierAction.sqf";
*/

// #define PR(x) private ['x']; x
// #define curTrigger[] trgBase_side0; trgBase_side0

private ["_us","_srAllow"];

_srAllow = true;

srActID = -1;

waitUntil {sleep 5; !(isNull player) && (WMT_pub_frzState >= 3) }; //==3 when freeze over, ==1 when freeze up			// + чтобы работало на клиентском сервере

if !(side group player in TVD_sides) exitWith {};

scopeName "rsaMain";

while {alive player} do {
	
	waitUntil {sleep 5; if !(alive player) then {breakTo "rsaMain"}; ( 
		( ( (player in list trgBase_side0) && (side group player == TVD_sides select 0) ) 
		|| 
		( (player in list trgBase_side1) && (side group player == TVD_sides select 1) ) )
	&& (TVD_SideCanRetreat select ([east,west,resistance] find (side group player)) )	) };
	
	// Если боец - КС стороны, то он не может сам отступить. Только скомандовать всей стороне отступление.
	if ( !isNil{player getVariable "TVD_UnitValue" select 2} ) then {
		if (player getVariable "TVD_UnitValue" select 2 in ["sideLeader","execSideLeader"]) then {_srAllow = false} else {_srAllow = true};
	} else {_srAllow = true};
		
	srAct = 1;
	srActIDapprove = -1;
	srActIDCancel = -1;
	srActID = -1;
		
	if (_srAllow) then {
		
		srActID = player addAction ["<t color='#ff4c4c'>Самостоятельно отступить в свой тыл</t>", {
			srAct = 2;
			
			
			srActIDapprove = (_this select 1) addAction ["<t color='#ff4c4c'>САМОСТОЯТЕЛЬНО ОТСТУПИТЬ: Подтвердить</t>", {

							/*
							target (_this select 0): Object - the object which the action is assigned to
							caller (_this select 1): Object - the unit that activated the action
							ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
							arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
							*/
				srAct = 0;
				(_this select 1) removeAction srActIDapprove;
				(_this select 1) removeAction srActIDCancel;			
				(_this select 1) removeAction srActID;			
				
				_us = if ((_this select 0) in list trgBase_side0) then {0} else {1};		//Сторона, которая отправляет пленника к себе и получает за нее очки

				if !(TVD_RetreatPossible select ([east,west,resistance] find (TVD_sides select _us))) then {		//Если у стороны нет тылов - отправлять в тылы ничего нельзя
					
					titleText ["Невозможно. У стороны нет тылов.", "PLAIN DOWN"];
				} else {
					[[ [_this select 0], { 
						null = [_this select 0] call TVD_RetreatSoldier;
					}],"BIS_fnc_call", false] call BIS_fnc_MP;		//Вызываем функцию на сервере, передаем цель и вызвавшего Действие
				};
				
				
			}, nil, 0, false, true, "", "(_this == _target) && !(_this getVariable ['ACE_isUnconscious', false]) && !(_this getVariable ['ace_captives_ishandcuffed', false])"];
			// }, nil, 0, false, true, "", "(_this == _target) && !(_this getVariable ['AGM_isUnconscious', false]) && !(_this getVariable ['AGM_isCaptive', false])"];		//Перевод на ACE
			
			
			srActIDCancel = (_this select 1) addAction ["<t color='#8BC8D6'>САМОСТОЯТЕЛЬНО ОТСТУПИТЬ: Отмена</t>", {
				srAct = 1;
				(_this select 1) removeAction srActIDapprove;
				(_this select 1) removeAction srActIDCancel;
			}, nil, 0, false, true, "", "(_this == _target) && !(_this getVariable ['ACE_isUnconscious', false]) && !(_this getVariable ['ace_captives_ishandcuffed', false])"];
			// }, nil, 0, false, true, "", "(_this == _target) && !(_this getVariable ['AGM_isUnconscious', false]) && !(_this getVariable ['AGM_isCaptive', false])"];		//Перевод на ACE
		
		
		
		}, nil, 0, false, false, "", "(_this == _target) && !(_this getVariable ['ACE_isUnconscious', false]) && !(_this getVariable ['ace_captives_ishandcuffed', false]) && (srAct == 1)"];
		// }, nil, 0, false, false, "", "(_this == _target) && !(_this getVariable ['AGM_isUnconscious', false]) && !(_this getVariable ['AGM_isCaptive', false]) && (srAct == 1)"]; 	//Перевод на ACE
	};
	
	
	
	
	
	
	
	
	
	// srActID = player addAction ["<t color='#ff0000'>САМОСТОЯТЕЛЬНО ОТСТУПИТЬ: Подтвердить</t>", {

					/*
					target (_this select 0): Object - the object which the action is assigned to
					caller (_this select 1): Object - the unit that activated the action
					ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
					arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
					*/
		// srAct = 0;			
		
		// _us = if ((_this select 0) in list trgBase_side0) then {0} else {1};		//Сторона, которая отправляет пленника к себе и получает за нее очки

		// if !(TVD_RetreatPossible select ([east,west,resistance] find (TVD_sides select _us))) then {		//Если у стороны нет тылов - отправлять в тылы ничего нельзя
			
			// titleText ["Невозможно. У стороны нет тылов.", "PLAIN DOWN"];
		// } else {
			// [[ [_this select 0], { 
				// null = [_this select 0] call TVD_RetreatSoldier;
			// }],"BIS_fnc_call", false] call BIS_fnc_MP;		//Вызываем функцию на сервере, передаем цель и вызвавшего Действие
		// };
		
		
	// }, nil, 0, false, true, "", "(_this == _target) && !(_this getVariable ['AGM_isUnconscious', false]) && !(_this getVariable ['AGM_isCaptive', false]) && (srAct == 2)"];
	
	
	// player addAction ["<t color='#8BC8D6'>САМОСТОЯТЕЛЬНО ОТСТУПИТЬ: Отмена</t>", {
		// srAct = 1;
	// }, nil, 0, false, true, "", "(_this == _target) && !(_this getVariable ['AGM_isUnconscious', false]) && !(_this getVariable ['AGM_isCaptive', false]) && (srAct == 2)"];


	waitUntil {sleep 1; ( (!(vehicle player in list trgBase_side0) && !(vehicle player in list trgBase_side1)) || !(alive player) ) };
			
	if (srActIDapprove != -1) then {player removeAction srActIDapprove};
	if (srActIDCancel != -1) then {player removeAction srActIDCancel};
	if (srActID != -1) then {player removeAction srActID};
	
};

