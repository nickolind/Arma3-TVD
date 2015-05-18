/*
sideToIndex = compileFinal preprocessFileLineNumbers "TVD\TVD_util_sideToIndex.sqf";
_side call sideToIndex;
*/
switch (_this) do 
	{
		case WEST:		{1};
		case EAST:		{0};
		case RESISTANCE:{2};
		case CIVILIAN:	{3};
		default 		{-1}
	};