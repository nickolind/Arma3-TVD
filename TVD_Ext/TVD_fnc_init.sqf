/*
null = [] call compileFinal preprocessFileLineNumbers "TVD_Ext\TVD_fnc_init.sqf";
*/

if !(isDedicated) then {
	[] spawn compileFinal preprocessFileLineNumbers "TVD_Ext\TVD_fnc_markBox.sqf";
};