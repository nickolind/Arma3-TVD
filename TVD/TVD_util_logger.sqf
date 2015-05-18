/*
null = [] execVM "TVD\TVD_util_logger.sqf";

TVD_Logger = compile preprocessFileLineNumbers "TVD\TVD_util_logger.sqf";
[] call TVD_Logger;
*/
private ["_missionResults"];

_missionResults = _this select 0;

		diag_log	parseText format ["//------------------------------------------------------------//"];
		diag_log	parseText format ["TVD Mission Status Report:"];
		diag_log	parseText format ["Mission date/time: %1", date];
		diag_log	parseText format ["missionStart: %1", missionStart];
		diag_log	parseText format ["winSide: %1;   Supremacy: %2;   Supremacy Ratio: %3 - %4   Current Score: %5", _missionResults select 0, _missionResults select 1, _missionResults select 2, _missionResults select 3, _missionResults select 4];
		diag_log	parseText format ["Vars:"];
		diag_log	parseText format ["TVD_sides = %1", TVD_sides];
		diag_log	parseText format ["TVD_InitScore = %1", TVD_InitScore];
		diag_log	parseText format ["TVD_ValUnits = %1", TVD_ValUnits];
		diag_log	parseText format ["TVD_capZones = %1", TVD_capZones];
		diag_log	parseText format ["TVD_sidesInfScore = %1", TVD_sidesInfScore];
		diag_log	parseText format ["TVD_sidesValScore = %1", TVD_sidesValScore];
		diag_log	parseText format ["TVD_sidesZonesScore = %1", TVD_sidesZonesScore];
		diag_log	parseText format ["TVD_MissionLog = %1", TVD_MissionLog];
		diag_log	parseText format ["//------------------------------------------------------------//"];

