/*
null = [] execVM "TVD\TVD_WinCalculations.sqf";

TVD_WinCalculations = compile preprocessFileLineNumbers "TVD\TVD_WinCalculations.sqf";
null = [TVD_InitScore, TVD_sidesInfScore, TVD_sidesValScore, TVD_sidesZonesScore] call TVD_WinCalculations;
*/
private ["_retrOn","_statsUpdated","_scoreRatio", "_ratioDiff", "_sidesInfScore", "_sidesValScore", "_sidesZonesScore", "_sidesResScore", "_InitScore", "_winSide", "_superiority", "_ratioBalance","_sRegain"];

_retrOn = -1;
if (count _this >= 1) then {_retrOn = _this select 0};			//0 или 1 для массива: TVD_sides = [side0, side1];

_statsUpdated = [10,0,0] call TVD_ScoreKeeper;

_InitScore = TVD_InitScore;
_sidesInfScore = _statsUpdated select 3;
_sidesValScore = _statsUpdated select 4;
_sidesZonesScore = _statsUpdated select 5;
_sidesResScore = _statsUpdated select 6;

_scoreRatio = [0,0];

for "_i" from 0 to 1 do {
	if ((_InitScore select _i) != 0) then {_scoreRatio set [_i, round( ( (_sidesInfScore select _i) + (_sidesValScore select _i) + (_sidesZonesScore select _i) + (_sidesResScore select _i) ) / (_InitScore select _i) * 1000) / 10];};	// 100.0
	
	if (_retrOn == _i) then {
		_sRegain = ((100.0 - (_scoreRatio select _i)) / 2);
		_scoreRatio set [_i, (_scoreRatio select _i) + _sRegain];		//половина потерянных очков преимущества стороны возвращены, если сторона отступила
		null = ["retreatScore", (TVD_sides select _i), _sRegain] call TVD_util_MissionLogWriter;
	};
};

_ratioDiff = (_scoreRatio select 0) - (_scoreRatio select 1);
if (_ratioDiff > 0) then {_winSide = TVD_sides select 0} else {_winSide = TVD_sides select 1};
switch (true) do {
	case (abs(_ratioDiff) > 45) : {		//Сокрушительная победа
		_superiority = 3;
	};
	case (abs(_ratioDiff) > 30) : {		//Уверенная победа
		_superiority = 2;
	};
	case (abs(_ratioDiff) > 15) : {		//Преимущественная победа
		_superiority = 1;
	};
	DEFAULT {		//Ничья
		_winSide = sideLogic;
		_superiority = 0;
	};
};

_ratioBalance = round(((_scoreRatio select 0) / ( (_scoreRatio select 0) + (_scoreRatio select 1) ) ) * 1000) / 10;


//Результат:													//Формат вывода TVD_WinCalculations: _winSide, _superiority (0,1,2,3), _ratioBalance1, _ratioBalance2, [_scoreRatio0, _scoreRatio1]
[	_winSide, 					//0 - Победившая сторона,
	_superiority, 				//1 - Степень победы,
	_ratioBalance,				//2 - Процент преимущества стороны 0
	100 - _ratioBalance,		//3 - Процент преимущества стороны 1
	[_scoreRatio select 0, _scoreRatio select 1]		//4 - % ресурсов от изначальных
]

