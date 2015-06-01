/*

TVD_util_MissionLogWriter = compile preprocessFileLineNumbers "TVD\TVD_util_MissionLogWriter.sqf";
null = [_type,_obj, _int] call TVD_util_MissionLogWriter;
"killed"
"retreat"
*/

private ["_unit","_type","_side","_varInt","_timeStamp","_unitSide","_sColor","_us","_si","_unitName"];

_type = _this select 0;
_varInt = if (count _this >= 3) then {_this select 2} else {0};


//if ( (_unit getVariable "TVD_UnitValue" select 1 ) > 10) then {			//Не срабатывать на технику с ценностью <= 10 (транспортные машины, обычно)
	_timeStamp = [daytime*3600] call BIS_fnc_secondsToString;
	_sColor = ["#e50000","#457aed","#27b413","#d16be5","#ffffff"];
	
	switch (_type) do {
		
		case "sentToRes": {
			_unit = _this select 1;
			_us = [east, west, resistance, civilian, sideLogic] find (_unit getVariable "TVD_UnitValue" select 0 );
			_unitName = getText (configFile >> "CfgVehicles" >> (typeof _unit) >> "displayName");
			_side = TVD_sides select _varInt;		//В данном случае varInt передает индекс стороны из массива TVD_sides
			_si = [east, west, resistance, civilian, sideLogic] find _side;
			
			TVD_MissionLog pushBack parseText format ["<t size='0.7' shadow='2'><t color='#fbbd2c'>%1:</t> <t color='%2'>%3</t> отправили <t color='%4'>%5</t> в свои тылы.</t>",_timeStamp, _sColor select _si, _side, _sColor select _us, _unitName];
		};
		
		case "retreatLoss": {
			_unit = _this select 1;
			_unitSide = TVD_sides find ( _unit getVariable "TVD_UnitValue" select 0 );
			_us = [east, west, resistance, civilian, sideLogic] find (_unit getVariable "TVD_UnitValue" select 0 );
			
			_unitName = if (_unit isKindof "Man") then {name _unit} else { getText (configFile >> "CfgVehicles" >> (typeof _unit) >> "displayName")};
			TVD_MissionLog pushBack parseText format ["<t size='0.7' shadow='2'><t color='#fbbd2c'>%1:</t> В ходе отступления <t color='%2'>%3</t> был оставлен врагу.</t>",_timeStamp, _sColor select _us, _unitName];
		};
		
		case "retreatScore": {
			_side = _this select 1;
			_us = [east, west, resistance, civilian, sideLogic] find _side;
			TVD_MissionLog pushBack parseText format ["<t size='0.7' shadow='2'><t color='#fbbd2c'>%1:</t> Отступив, сторона <t color='%2'>%3</t> компенсировала<br/><t color='%2'>&#126;%4&#37;</t> потерянного преимущества.</t>",_timeStamp, _sColor select _us, _side, _varInt];
		};
		
		case "killed": {
			_unit = _this select 1;
			_unitSide = TVD_sides find ( _unit getVariable "TVD_UnitValue" select 0 );
			_us = [east, west, resistance, civilian, sideLogic] find (_unit getVariable "TVD_UnitValue" select 0 );
			
			if (_unit isKindof "Man") then {
				_unitName = name _unit;
				TVD_MissionLog pushBack parseText format ["<t size='0.7' shadow='2'><t color='#fbbd2c'>%1:</t> <t color='%2'>%3</t> пропал без вести.</t>",_timeStamp, _sColor select _us, _unitName];
			} else {
				_unitName = getText (configFile >> "CfgVehicles" >> (typeof _unit) >> "displayName");
				TVD_MissionLog pushBack parseText format ["<t size='0.7' shadow='2'><t color='#fbbd2c'>%1:</t> <t color='%2'>%3</t> был уничтожен.</t>",_timeStamp, _sColor select _us, _unitName];
			};
		};
	};


	//sleep 3;

	[[] call TVD_WinCalculations] call TVD_Logger;		//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2

//};

