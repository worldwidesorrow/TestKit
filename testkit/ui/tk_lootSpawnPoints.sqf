private ["_action1","_action2","_action3","_action4","_action5","_action6","_action7","_action8","_action9","_action10","_action11","_action12","_action13"];

if (isNil "tk_player_actions") then {tk_player_actions = [];};
if (isNil "_action9") then {_action9 = -1;};
if (isNil "_action10") then {_action10 = -1;};
if (isNil "_action12") then {_action12 = -1;};

tk_lootSpawnPointsOn = !tk_lootSpawnPointsOn;

if (tk_lootSpawnPointsOn) then {
	_action1 = player addAction ["Select Target", "testkit\scripts\Make_lootPos.sqf", "select", 99];
	_action2 = player addAction ["Tag Loot Pos", "testkit\scripts\Make_lootPos.sqf", "tag loot", 99];
	_action3 = player addAction ["Tag Small Pos", "testkit\scripts\Make_lootPos.sqf", "tag loot small", 99];
	_action4 = player addAction ["Tag Zed Position", "testkit\scripts\Make_lootPos.sqf", "tag zed spawn", 99];
	_action5 = player addAction ["Raise Z .1", "testkit\scripts\Make_lootPos.sqf", "up", 99, false,false,"User17"];
	_action6 = player addAction ["Lower Z .1", "testkit\scripts\Make_lootPos.sqf", "down", 99,false,false,"User18"];
	_action7 = player addAction ["Raise Z .01", "testkit\scripts\Make_lootPos.sqf", "up_small", 99, false,false,"User19"];
	_action8 = player addAction ["Lower Z .01", "testkit\scripts\Make_lootPos.sqf", "down_small", 99, false,false,"User20"];
	if (!tk_editorMode) then {_action9 = player addAction ["Mark Existing Positions", "testkit\scripts\Make_lootPos.sqf", "markall", 99];}; // does not work in editor mode.
	if (!tk_editorMode) then {_action10 = player addAction ["Remove Check Markers", "testkit\scripts\Make_lootPos.sqf", "clearall", 99];}; // does not work in editor mode.
	_action11 = player addAction ["Tag For Removal", "testkit\scripts\Make_lootPos.sqf", "tag remove", 99];
	//_action12 = player addAction ["Generate Loot", "testkit\scripts\Make_lootPos.sqf", "generateloot", 99]; // does not work in editor mode.
	_action13 = player addAction ["Exit", "testkit\scripts\Make_lootPos.sqf", "exit", 99];
	
	
	{
		tk_player_actions set [count tk_player_actions, _x];
	} count [_action1,_action2,_action3,_action4,_action5,_action6,_action7,_action8,_action9,_action10,_action11,_action12,_action13];
	
	["DZE Loot Tool",true] call tk_scriptToggle;
	
} else {
	{
		player removeAction _x;
	} count tk_player_actions;
	
	tk_player_actions = nil;
	if !(isNil "DZE_vehTarget") then {deleteVehicle DZE_vehTarget;};
	DZE_vehTarget = nil;
		
	["DZE Loot Tool",false] call tk_scriptToggle;
	
};