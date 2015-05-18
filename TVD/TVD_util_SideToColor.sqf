/*
SideToColor = compileFinal preprocessFileLineNumbers "TVD\TVD_util_SideToColor.sqf";
_sideColor call SideToColor;
*/

switch (_this) do 
{
	case WEST:		{"ColorBlufor"};
	case EAST:		{"ColorOpfor"};
	case RESISTANCE:{"ColorIndependent"};
	case CIVILIAN:	{"ColorCivilian"};
	default 		{"ColorBlack"}
};
