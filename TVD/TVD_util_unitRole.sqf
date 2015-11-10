/*
TVD_unitRole = compile preprocessFileLineNumbers "TVD\TVD_util_unitRole.sqf";
_role call TVD_unitRole;
*/

switch (_this) do 
	{
		case "sideLeader":		{"КС"};
		case "execSideLeader":	{"исп.КС"};
		case "squadLeader":		{"КО"};
		case "crewTank":		{"Экипаж(Т)"};
		case "crewAPC":			{"Экипаж(БТР)"};
		case "pilot":			{"Пилот"};
		case "sniper":			{"Снайпер"};
		case "vip":				{"Спец-юнит"};
		case "soldier":			{""};
		default 		{""}
	};