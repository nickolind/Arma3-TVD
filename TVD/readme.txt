План построения / настройки миссии на ТВД:

2. Создать зоны для захвата/удержания, назвать их mZone_ + номер, добавить зоны в список capZones

3. К каждой зоне привязать модуль WMT Point

4. Прописать ценность важным юнитам (10 это обычный боец, 20 - комод, 40 - взводный, 100 - кс и тд)
	1)Командир стороны - init="this setVariable [""TVD_UnitValue"",[independent,100,""sideLeader""]];";

5. Создать тыловую зону для каждой стороны, куда они смогут отступить.

6. В TVD_init.sqf:
	- TVD_sides - выставить стороны
	- TVD_capZones - должен содержать зоны - названия триггеров
	- строка 74 - выставить цену одной зоны
	
7. В init.sqf:
	wmt_hl_sidelimits = [-1,-1,-1];		//[east, west, resistance]
	wmt_hl_ratio = [-1,-1,-1];
	TVD_hl_ratio = [0.1,0.1,0.1];
	
В initPlayerLocal.sqf:
	null = [] execVM "TVD\TVD_InitPlayerLocal.sqf";
	
В initPlayerLocal.sqf:
	null = [] spawn compileFinal preprocessFileLineNumbers "TVD\TVD_Main.sqf";