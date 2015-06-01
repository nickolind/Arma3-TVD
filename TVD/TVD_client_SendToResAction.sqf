/*
null = [] execVM "TVD\TVD_client_SendToResAction.sqf";
*/

private ["_us"];

waitUntil{ sleep 1; (!(isNull player) && !(isNil {TVD_ValUnits})) };		//Важно дождаться когда сервер сперва передаст клиентам список ценных юнитов

if (isServer) then {
	waitUntil{ sleep 1; count TVD_ValUnits > 0 };
	
	sleep 5;		//Чтобы работало на клиентском сервере
};



{
	if (_x in vehicles) then {
						
		_x addAction [format ["<t color='#ffffff'>Отправить %1 в тыл</t>", getText (configFile >> "CfgVehicles" >> (typeof _x) >> "displayName")], {
						/*
						target (_this select 0): Object - the object which the action is assigned to
						caller (_this select 1): Object - the unit that activated the action
						ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
						arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
						*/
			_us = if ((_this select 0) in list trgBase_side0) then {0} else {1};		//Сторона, которая отправляет технику к себе и получает за нее очки

			if !(TVD_RetreatPossible select ([east,west,resistance] find (TVD_sides select _us))) then {
				
				titleText ["Невозможно отправить технику в тыл.", "PLAIN DOWN"];
			} else {
				[[ [_this select 0, _this select 1], { 
					null = [_this select 0, _this select 1] call TVD_SendToRes;
				}],"BIS_fnc_call", false] call BIS_fnc_MP;		//Вызываем функцию на сервере, передаем цель и вызвавшего Действие
			
			};
			
			
		}, nil, 0, false, true, "", "((_target in list trgBase_side0) || (_target in list trgBase_side1)) && (_target getVariable 'TVD_SentToRes' == 0) && (({alive _x} count crew _target) == 0) && (locked _target != 2)"];
	};

} forEach TVD_ValUnits;