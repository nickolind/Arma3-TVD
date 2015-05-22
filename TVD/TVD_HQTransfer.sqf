/*
null = [] execVM "TVD\TVD_HQTransfer.sqf";

TVD_HQTransfer = compile preprocessFileLineNumbers "TVD\TVD_HQTransfer.sqf";
null = [] call TVD_HQTransfer;
*/

private ["_unit","_unitValue","_u2Val"];

_unit = _this select 1;

switch (_this select 0) do {
	case "slTransfer" : {
		_unitValue = _unit getVariable "TVD_UnitValue";
		scopeName "depth1";
		
		
		{	
			if ( (side _x == _unitValue select 0) ) then {
				
				{
					if (!isNil {_x getVariable "TVD_UnitValue"}) then {
						_u2Val = _x getVariable "TVD_UnitValue";
						
						//if (!isNil {_u2Val select 2}) then {
							if (_u2Val select 2 == "squadLeader") then {
								
								_u2Val set [2, "execSideLeader"];
								_x setVariable ["TVD_UnitValue", _x getVariable "TVD_UnitValue", true];
								
								_eh_index = _x addMPEventHandler ["mpkilled", {if (isServer) then {null = ["slTransfer",_this select 0] call TVD_HQTransfer;}}];
								_x setVariable ["TVD_HQ_eh_mpkilled_index", _eh_index, true];
								
								//Добавить команду на отступление
								[[ [], {
									null = [] execVM "TVD\TVD_InitPlayerLocal.sqf";
								}],"BIS_fnc_call", _x] call BIS_fnc_MP;
								
								
								//Уведомить других о смене КСа
								[[ [_x], {
									if (!isNil {player getVariable "TVD_UnitValue"}) then {
										["taskAssigned",[0, format ["%1 принял командование стороной", name (_this select 0)]]] call bis_fnc_showNotification;
									};
								}],"BIS_fnc_call", side _x] call BIS_fnc_MP;
								
								
								breakTo "depth1";
							};
						//};
					};
				} forEach units _x;
			};	
		} forEach allGroups;
	};
	
};



