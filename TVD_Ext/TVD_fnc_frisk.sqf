/*
Вызывается на всех машинах кроме выделенного сервера.


*/

waitUntil {sleep 5; WMT_pub_frzState >= 3}; //==3 when freeze over, ==1 when freeze up


TVD_Ext_addFriskAction = {
	private["_targetUnit","_friskAction"];
	_targetUnit = _this select 0;

	_friskAction = _targetUnit addAction ["<t color='#0353f5'>Обыскать</t>",
		{
			player action ["Gear", (_this select 0)];
			
			{		//Нечитабельный код. Вызывает у клиентов (если юнит - игрок) сообщение. Для каждого юнита в радиусе Н метров от КШМ
				if ((isPlayer _x)) then { 
					[[ [player,(_this select 0)], { 
						hint format ["%1 обыскивает %2",name (_this select 0), name (_this select 1)];
					}],"BIS_fnc_call", _x] call BIS_fnc_MP; 
				};
			} forEach ((_this select 0) nearEntities 5);

		}, 
		[], -1, false, true, "", 
		"(_this != _target) && ((_this distance _target) <= 3) && ( (_target getVariable ['ace_captives_ishandcuffed', false]) || (_target getVariable ['ACE_isUnconscious', false]) )"
	];
	
	waitUntil {sleep 1; (( !(_targetUnit getVariable ['ace_captives_ishandcuffed', false]) && !(_targetUnit getVariable ["ACE_isUnconscious", false]) ) || !(alive _targetUnit)) };
	// waitUntil {sleep 1; (( !(_targetUnit getVariable ["AGM_isCaptive",false]) && !(_targetUnit getVariable ["AGM_isUnconscious", false]) ) || !(alive _targetUnit)) };
	
	_targetUnit removeAction _friskAction;
	
	_targetUnit setVariable ["TVD_friskActionSent", false, true];
	
};

"TVD_Captured" addPublicVariableEventHandler {
	[(_this select 1)] spawn TVD_Ext_addFriskAction;
};

if (isServer) then {
	{
		_x setVariable ["TVD_friskActionSent", false];
	} forEach playableUnits;

	while {true} do {
		{
			if ( ((_x getVariable ['ace_captives_ishandcuffed', false]) || (_x getVariable ["ACE_isUnconscious", false])) && !(_x getVariable ["TVD_friskActionSent", false]) ) then {
				_x setVariable ["TVD_friskActionSent", true];
				TVD_Captured = _x;
				publicVariable "TVD_Captured";
				if !(isDedicated) then {[TVD_Captured] spawn TVD_Ext_addFriskAction};		//Вызов на той же машине, если она - не выделенный сервер.
			}; 
		} forEach playableUnits;
		
		sleep 3;
	};
};


