/*
TVD_unitRole = compileFinal preprocessFileLineNumbers "TVD\TVD_util_unitRole.sqf";
_role call TVD_unitRole;
*/
switch (_this) do 
	{
		case "sideLeader":		{"КС"};
		case "execSideLeader":	{"исп.КС"};
		case "squadLeader":		{"КО"};
		case "sniper":			{"Снайпер"};
		case "vip":				{"VIP"};
		case "soldier":			{""};
		default 		{_this}
	};