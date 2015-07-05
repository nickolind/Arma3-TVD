/*
null = [] execVM "TVD\TVD_WinCalculations.sqf";

TVD_WinCalculations = compile preprocessFileLineNumbers "TVD\TVD_WinCalculations.sqf";
null = [] call TVD_WinCalculations;
*/
private ["_retrOn","_endOpt","_statsUpdated","_scoreRatio", "_ratioDiff", "_sidesInfScore", "_sidesValScore", "_sidesZonesScore", "_sidesResScore", "_InitScore", "_winSide", "_superiority", "_ratioBalance","_sRegain"];

_retrOn = -1;
_endOpt = -1;
if (count _this >= 1) then {_endOpt = _this select 0};
if (count _this >= 2) then {_retrOn = _this select 1};			//0 или 1 для массива: TVD_sides = [side0, side1];
_sRegain = 0.0;

_statsUpdated = [_endOpt,0,0] call TVD_ScoreKeeper;

_InitScore = TVD_InitScore;
_sidesInfScore = _statsUpdated select 3;
_sidesValScore = _statsUpdated select 4;
_sidesZonesScore = _statsUpdated select 5;
_sidesResScore = _statsUpdated select 6;

_scoreRatio = [0.0,0.0];

for "_i" from 0 to 1 do {
	// ratio if ((_InitScore select _i) != 0) then {_scoreRatio set [_i, round( (_InitScore select _i - (( (_sidesInfScore select _i) + (_sidesValScore select _i) + (_sidesZonesScore select _i) + (_sidesResScore select _i) ) / (_InitScore select _i)) ) * 1000) / 10];};	// 100.0
	if ((_InitScore select _i) != 0) then {_scoreRatio set [1-_i, round(((_InitScore select _i) - ( (_sidesInfScore select _i) + (_sidesValScore select _i) + (_sidesZonesScore select _i) + (_sidesResScore select _i) ) ) / ((_InitScore select 0) + (_InitScore select 1) + (_InitScore select 2)) * 1000 ) / 10 ];};	// 100.0

};

if (_retrOn != -1) then {
	
	_sRegain = ( (0 max (_scoreRatio select (1-_retrOn))) - (0 min (_scoreRatio select _retrOn)) ) / 2;
	_scoreRatio set [1-_retrOn, (_scoreRatio select (1-_retrOn)) - _sRegain];		//если сторона отступила, половина полученных очков преимущества другой стороны отнимаются
	
	null = ["retreatScore", (TVD_sides select _retrOn), _sRegain] call TVD_util_MissionLogWriter;
};


_ratioDiff = (_scoreRatio select 0) - (_scoreRatio select 1);
if (_ratioDiff > 0) then {_winSide = TVD_sides select 0} else {_winSide = TVD_sides select 1};
switch (true) do {
	case (abs(_ratioDiff) > 22) : {		//Сокрушительная победа
		_superiority = 3;
	};
	case (abs(_ratioDiff) > 12) : {		//Уверенная победа
		_superiority = 2;
	};
	case (abs(_ratioDiff) > 7) : {		//Преимущественная победа
		_superiority = 1;
	};
	DEFAULT {		//Ничья
		_winSide = sideLogic;
		_superiority = 0;
	};
};

_ratioBalance = 100.0 min (0.0 max (50.0 + _ratioDiff));	//При тотальных потерях стороны, у нее может быть отрицательный _scoreRatio. А игрокам отрицательные проценты ни к чему, поэтому чрезмерные величины впихиваем в рамки от 0 до 100 %.


//Результат:													//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2, [_scoreRatio0, _scoreRatio1]
[	_winSide, 					//0 - Победившая сторона,
	_superiority, 				//1 - Степень победы,
	_ratioBalance,				//2 - Процент преимущества стороны 0
	100.0 - _ratioBalance,		//3 - Процент преимущества стороны 1
	[_scoreRatio select 0, _scoreRatio select 1]		//4 - % ресурсов от изначальных
]

