/*
Вызывается на всех машинах кроме выделенного сервера.

this setVariable ["TVD_markBox", [west,"Ящик с Javelin + 2 ракеты"]];
*/

{
	if !(isNil {_x getVariable "TVD_markBox"}) then {
		
		if (side group player == _x getVariable "TVD_markBox" select 0) then { 	
			[_x, _x getVariable "TVD_markBox" select 1] spawn {
				private ["_markerstr"];
				
				_markerstr = createMarkerLocal [str (_this select 0), position (_this select 0)];
				_markerstr  setMarkerColorLocal "ColorOrange";
				_markerstr  setMarkerTextLocal (_this select 1);
				_markerstr  setMarkerTypeLocal "mil_dot";
				
				waitUntil {sleep 1; time > 300};
				deleteMarkerLocal _markerstr;
			};
		};
	};
} forEach vehicles;
