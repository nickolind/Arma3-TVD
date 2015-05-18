/*
colorToSide = compileFinal preprocessFileLineNumbers "TVD\TVD_util_ColorToSide.sqf";
_colorToSide call colorToSide;
*/
switch (_this) do 
	{
		case "ColorBlufor":		{WEST};
		case "ColorBLUFOR":		{WEST};
		case "ColorWEST":		{WEST};
		case "ColorOpfor":		{EAST};
		case "ColorOPFOR":		{EAST};
		case "ColorEAST":		{EAST};
		case "ColorIndependent":{RESISTANCE};
		case "ColorGUER":		{RESISTANCE};
		case "ColorCivilian":	{CIVILIAN};
		case "ColorCIV":		{CIVILIAN};
		default 		{sideLogic}
	};