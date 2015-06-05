/*
null = [] execVM "TVD\TVD_CaptureVehicle.sqf";

TVD_CaptureVehicle = compile preprocessFileLineNumbers "TVD\TVD_CaptureVehicle.sqf";
null = [] call TVD_CaptureVehicle;

"GetIn" Arguments:
	+ vehicle: Object - Vehicle the event handler is assigned to
	  position: String - Can be either "driver", "gunner", "commander" or "cargo"
	+ unit: Object - Unit that entered the vehicle
	  turret: Array - turret path (since Arma 3 v1.36)

*/

private ["_cVeh","_cUnit"];

_cVeh = _this select 0;
_cUnit = _this select 1;

if ( (side _cUnit in TVD_sides) && (side _cUnit != _cVeh getVariable "TVD_CapOwner") ) then {
	_cVeh setVariable ["TVD_CapOwner", side _cUnit];
	if ((_cVeh getVariable "TVD_UnitValue" select 1 ) > 1) then {
		["capVehicle",_cVeh, TVD_sides find (_cVeh getVariable "TVD_CapOwner")] call TVD_util_MissionLogWriter;
	};
};



