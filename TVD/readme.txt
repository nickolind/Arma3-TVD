���� ���������� / ��������� ������ �� ���:

2. ������� ���� ��� �������/���������, ������� �� mZone_ + �����, �������� ���� � ������ capZones

3. � ������ ���� ��������� ������ WMT Point

4. ��������� �������� ������ ������ (10 ��� ������� ����, 20 - �����, 40 - ��������, 100 - �� � ��)
	1)�������� ������� - init="this setVariable [""TVD_UnitValue"",[independent,100,""sideLeader""]];";

5. ������� ������� ���� ��� ������ �������, ���� ��� ������ ���������.

6. � TVD_init.sqf:
	- TVD_sides - ��������� �������
	- TVD_capZones - ������ ��������� ���� - �������� ���������
	- ������ 74 - ��������� ���� ����� ����
	
7. � init.sqf:
	wmt_hl_sidelimits = [-1,-1,-1];		//[east, west, resistance]
	wmt_hl_ratio = [-1,-1,-1];
	TVD_hl_ratio = [0.1,0.1,0.1];
	
� initPlayerLocal.sqf:
	null = [] execVM "TVD\TVD_InitPlayerLocal.sqf";
	
� initPlayerLocal.sqf:
	null = [] spawn compileFinal preprocessFileLineNumbers "TVD\TVD_Main.sqf";