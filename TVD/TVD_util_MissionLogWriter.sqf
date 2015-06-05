/*

TVD_util_MissionLogWriter = compile preprocessFileLineNumbers "TVD\TVD_util_MissionLogWriter.sqf";
[_type,_obj, _int] call TVD_util_MissionLogWriter;
"killed"
"retreat"
*/


private ["_unit","_type","_side","_varInt","_varArray","_timeStamp","_unitSide","_sColor","_si0","_si1","_plot","_unitName","_sidesRatio","_missionResults","_lCancel","_unitRole"];

_type = _this select 0;
_varInt = if (count _this >= 3) then {_this select 2} else {0};


_timeStamp = parseText format ["<t size='0.7' shadow='2' color='#CCCCCC'>%1: </t>",[daytime*3600] call BIS_fnc_secondsToString];
_sColor = ["#ed4545","#457aed","#27b413","#d16be5","#ffffff"];
_lCancel = false;

switch (_type) do {
	
	case "scheduled": {
		_si0 = [east, west, resistance, civilian, sideLogic] find (TVD_sides select 0);
		_si1 = [east, west, resistance, civilian, sideLogic] find (TVD_sides select 1);
		
		_plot = composeText [parseText "<t size='0.7' shadow='2'>Статус миссии. </t>",
			//Живые
			parseText format ["<t size='0.7' shadow='2'>Живых: <t color='%1'>%2</t>-<t color='%3'>%4</t>. </t>",_sColor select _si0, wmt_PlayerCountNow select _si0, _sColor select _si1, wmt_PlayerCountNow select _si1],
			//Мертвые
			parseText format ["<t size='0.7' shadow='2'>Потери: <t color='%1'>%2</t>-<t color='%3'>%4</t>. <br/></t>",_sColor select _si0, (wmt_playerCountInit select _si0) - (wmt_PlayerCountNow select _si0),_sColor select _si1, (wmt_playerCountInit select _si1) - (wmt_PlayerCountNow select _si1)],
			//Зоны
			parseText format ["<t size='0.7' shadow='2'>Владение зонами: <t color='%1'>%2</t>-<t color='%3'>%4</t>. </t>",_sColor select _si0, {_x select 1 == TVD_sides select 0} count TVD_capZones,_sColor select _si1, {_x select 1 == TVD_sides select 1} count TVD_capZones]
		];
	};
	
	case "capVehicle": {
		_unit = _this select 1;
		_si0 = [east, west, resistance, civilian, sideLogic] find (_unit getVariable "TVD_UnitValue" select 0 );
		_unitName = getText (configFile >> "CfgVehicles" >> (typeof _unit) >> "displayName");
		_side = TVD_sides select _varInt;		//В данном случае varInt передает индекс стороны из массива TVD_sides
		_si1 = [east, west, resistance, civilian, sideLogic] find _side;
		
		_plot = parseText format ["<t size='0.7' shadow='2'><t color='%1'>%2</t> захватили <t color='%3'>%4</t>.</t>", _sColor select _si1, _side, _sColor select _si0, _unitName];
	};
	
	case "sentToRes": {
		_unit = _this select 1;
		_si0 = [east, west, resistance, civilian, sideLogic] find (_unit getVariable "TVD_UnitValue" select 0 );
		_unitName = getText (configFile >> "CfgVehicles" >> (typeof _unit) >> "displayName");
		_side = TVD_sides select _varInt;		//В данном случае varInt передает индекс стороны из массива TVD_sides
		_si1 = [east, west, resistance, civilian, sideLogic] find _side;
		
		_plot = parseText format ["<t size='0.7' shadow='2'><t color='%1'>%2</t> отправили <t color='%3'>%4</t> в свои тылы.</t>", _sColor select _si1, _side, _sColor select _si0, _unitName];
	};
	
	case "retreatScore": {
		_side = _this select 1;
		_si0 = [east, west, resistance, civilian, sideLogic] find _side;
		_plot = parseText format ["<t size='0.7' shadow='2'>Отступив, сторона <t color='%1'>%2</t> компенсировала<br/><t color='%1'>&#126;%3&#37;</t> потерянного преимущества.</t>", _sColor select _si0, _side, _varInt];
	};
	
	case "retreatLossList": {
		_side = TVD_sides select _varInt;		//В данном случае varInt передает индекс стороны из массива TVD_sides
		_si0 = [east, west, resistance, civilian, sideLogic] find _side;

		_plot = parseText format ["<t size='0.7' shadow='2'>Потери <t color='%1'>%2</t> при отступлении: <t color='%1'>%3</t></t>", _sColor select _si0, _side, _this select 1];
	};
	
	case "killed": {
		_unit = _this select 1;
		_unitSide = TVD_sides find ( _unit getVariable "TVD_UnitValue" select 0 );
		_si0 = [east, west, resistance, civilian, sideLogic] find (_unit getVariable "TVD_UnitValue" select 0 );
		
		if (_unit isKindof "Man") then {
			if (!isNil{_unit getVariable "TVD_UnitValue" select 2}) then {
				if (_unit getVariable "TVD_UnitValue" select 2 == "soldier") exitWith {
					_lCancel = true;
				};
			};
			_unitName = name _unit;
			_unitRole = (_unit getVariable "TVD_UnitValue" select 2) call TVD_unitRole;
			_plot = parseText format ["<t size='0.7' shadow='2'><t color='%1'>%2(%3)</t> пропал без вести.</t>", _sColor select _si0, _unitName, _unitRole];
		} else {
			_unitName = getText (configFile >> "CfgVehicles" >> (typeof _unit) >> "displayName");
			_plot = parseText format ["<t size='0.7' shadow='2'><t color='%1'>%2</t> <t color='#FFB23D'>был уничтожен.</t></t>", _sColor select _si0, _unitName];		//fbbd2c
		};
	};
};


if !(_lCancel) then {
	//Дописываем в начало сообщения данные по соотношению сил
	_missionResults = [] call TVD_WinCalculations;		//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2

	_si0 = [east, west, resistance, civilian, sideLogic] find (TVD_sides select 0);
	_si1 = [east, west, resistance, civilian, sideLogic] find (TVD_sides select 1);
	_sidesRatio = parseText format ["<t size='0.7' shadow='2'>(<t color='%1'>%2&#37;</t>-<t color='%3'>%4&#37;</t>) </t>",_sColor select _si0, _missionResults select 2, _sColor select _si1, _missionResults select 3];

	TVD_MissionLog pushBack composeText [_timeStamp, _sidesRatio, _plot];

	[_missionResults] call TVD_Logger;		
};
