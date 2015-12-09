/*


TVD_util_DebriefWriter = compile preprocessFileLineNumbers "TVD\TVD_util_debriefWriter.sqf";
[] call TVD_util_DebriefWriter;
*/

private ["_zonesList","_outcome","_missionResults","_sColor","_si0","_si1","_si","_textOut", "_winner", "_us"];

_outcome = _this select 0;
_missionResults = _this select 1;
_winner = if (_missionResults select 0 == sideLogic) then {"-"} else {str (_missionResults select 0)};

_zonesList = [];

_sColor = ["#ed4545","#457aed","#27b413","#d16be5","#ffffff"];		//Цвета для сторон - [east, west, resistance, civilian, sideLogic] find _x
_si0 = (TVD_sides select 0) call sideToIndex;
_si1 = (TVD_sides select 1) call sideToIndex;
// _si = [_si0, _si1];


//0. Блок хеадера присоединяется уже на клиентской машине

//1. Блок причины завершения:
switch (_outcome) do {
	case 0: {_outcome = parseText "<t size='1.0' color='#fbbd2c' align='center' shadow='2'>Миссия завершена администратором</t><br/>"};
	case 1: {_outcome = parseText "<t size='1.2' color='#fbbd2c' align='center' shadow='2'>Время вышло</t><br/>"};
	case 2: {	_us = [east, west, resistance, civilian, sideLogic] find TVD_HeavyLosses; 									//Выдаст ошибку, если завершать миссию с параметром TVD_HeavyLosses = sideLogic - нужно указать, какая сторона понесла тяжелые потери
				_outcome = parseText format ["<t size='1.0' color='#fbbd2c' align='center' shadow='2'>У стороны осталось слишком мало живой силы на поле боя:<br/><t color='%1'>%2</t><br/>", _sColor select _us, TVD_sides select (TVD_sides find TVD_HeavyLosses)]};
	case 3: {	_us = [east, west, resistance, civilian, sideLogic] find TVD_SideRetreat;									//Выдаст ошибку, если завершать миссию с параметром TVD_SideRetreat = sideLogic - нужно указать, какая сторона отступила
				_outcome = parseText format ["<t size='1.1' color='#fbbd2c' align='center' shadow='2'>Сторона успешно отступила:<br/><t color='%1'>%2</t><br/>", _sColor select _us, TVD_sides select (TVD_sides find TVD_SideRetreat)]};
	case 4: {	_us = [east, west, resistance, civilian, sideLogic] find TVD_MissionComplete;									//Выдаст ошибку, если завершать миссию с параметром TVD_SideRetreat = sideLogic - нужно указать, какая сторона отступила
				_outcome = parseText format ["<t size='1.1' color='#fbbd2c' align='center' shadow='2'>Сторона выполнила ключевую задачу:<br/><t color='%1'>%2</t><br/>", _sColor select _us, TVD_sides select (TVD_sides find TVD_MissionComplete)]};
};

//Список зон для основного блока под "Контроллируемые зоны":
{
	_zonesList pushBack parseText format ["<t align='right' size='0.7' shadow='2' color='%1'>%2</t>", _sColor select ([east, west, resistance, civilian, sideLogic] find (_x select 1) ), markerText (_x select 0) ];
} forEach TVD_capZones;
zonesList = _zonesList;

//Основной блок:
// (разбит на две колонки)
_textOut = composeText [_outcome,
	parseText "<t size='1.0' align='center' shadow='2'>----------------------------------------------------------</t><br/>",
	parseText "<t size='1.2' align='center' shadow='2'>Итоги миссии:<br/></t>", 
	parseText "<t size='0.9' underline='true' shadow='2'>Соотношение преимущества сторон:</t><br/>",
	parseText format ["<t align='center'> <t size='1.8' color='%1'>%2&#37;</t>   &lt;-&gt;   <t size='1.8' color='%3'>%4&#37;</t></t><br/>",_sColor select _si0, _missionResults select 2, _sColor select _si1, _missionResults select 3], 										
	parseText format ["<t align='center' size='0.7'>(Победила сторона: <t  color='%1'>%2</t>)</t><br/>",_sColor select ([east, west, resistance, civilian, sideLogic] find (_missionResults select 0)), _winner], 										
	parseText "<t size='0.9' underline='true' shadow='2'>Осталось на поле боя:</t>", 	parseText "<t size='0.9' underline='true' shadow='2' align='right'>Потери личного состава:</t><br/>",		
	parseText format ["<t color='%1'>%2</t>   &lt;-&gt;   <t color='%3'>%4</t>",_sColor select _si0, TVD_PlayerCountNow select _si0, _sColor select _si1, TVD_PlayerCountNow select _si1], 
																							parseText format ["<t align='right'> <t color='%1'>%2</t>   &lt;-&gt;   <t color='%3'>%4</t></t><br/>",_sColor select _si0, (TVD_playerCountInit select _si0) - (TVD_PlayerCountNow select _si0) - (TVD_RetrCount select 0),_sColor select _si1, (TVD_playerCountInit select _si1) - (TVD_PlayerCountNow select _si1) - (TVD_RetrCount select 1)],
	parseText " ", 																			parseText "<t align='right'> </t><br/>",
	parseText "<t underline='true' shadow='2'>Лог событий:</t>",							parseText "<t underline='true' shadow='2' align='right'>Контролируемые зоны:</t>"
];


//Блок лога:
//Тоже разбит на 2 колонки. Слева - лог событий влияющих на балансировку, справа - список зон, окрашенных в цвет стороны, которой они принадлежат в момент окончания
if (count TVD_MissionLog >= count _zonesList) then {		//расчет сколько строчек понадобится под лог. Берется большее из из двух: колво строк в мишн логе и колво зон
	{
		_zLine = "";
		if ((count _zonesList -1) >= _forEachIndex) then {_zLine = _zonesList select _forEachIndex};
		
		_textOut = composeText [_textOut, parseText "<br/>",
			_x,																			_zLine
		];
	} forEach TVD_MissionLog;

} else {
	{
		_mlLine = "";
		if ((count TVD_MissionLog -1) >= _forEachIndex) then {_mlLine = TVD_MissionLog select _forEachIndex};
		
		_textOut = composeText [_textOut, parseText "<br/>",
			_mlLine,																	 _x
		];
	} forEach _zonesList;
};

_textOut