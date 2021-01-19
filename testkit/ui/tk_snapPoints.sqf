private ["_action1","_action2","_action3","_action4","_action5","_action6","_action7","_action8","_action9","_action10","_action11","_action12","_action13","_action14","_action15","_action16"];

if (isNil "tk_snap_actions") then {tk_snap_actions = [];};
if (isNil "_action14") then {_action14 = -1;};
if (isNil "_action15") then {_action15 = -1;};

tk_snapPointsOn = !tk_snapPointsOn;

if (tk_snapPointsOn) then {
	_action1 = player addAction ["Select Target", "testkit\scripts\dze_snappoints.sqf", "select", 99];
	_action2 = player addAction ["Tag Top", "testkit\scripts\dze_snappoints.sqf", "tag_top", 99];
	_action3 = player addAction ["Tag Bottom", "testkit\scripts\dze_snappoints.sqf", "tag_bottom", 99];
	_action4 = player addAction ["Tag Front", "testkit\scripts\dze_snappoints.sqf", "tag_front", 99];
	_action5 = player addAction ["Tag Back", "testkit\scripts\dze_snappoints.sqf", "tag_back", 99];
	_action6 = player addAction ["Tag Left", "testkit\scripts\dze_snappoints.sqf", "tag_left", 99];
	_action7 = player addAction ["Tag Right", "testkit\scripts\dze_snappoints.sqf", "tag_right", 99];
	_action8 = player addAction ["Raise Z .1", "testkit\scripts\dze_snappoints.sqf", "up", 99, false,false,"User17"];
	_action9 = player addAction ["Lower Z .1", "testkit\scripts\dze_snappoints.sqf", "down", 99,false,false,"User18"];
	_action10 = player addAction ["Raise Z .01", "testkit\scripts\dze_snappoints.sqf", "up_small", 99, false,false,"User19"];
	_action11 = player addAction ["Lower Z .01", "testkit\scripts\dze_snappoints.sqf", "down_small", 99, false,false,"User20"];
	_action12 = player addAction ["Raise Z .001", "testkit\scripts\dze_snappoints.sqf", "up_micro", 99, false,false];
	_action13 = player addAction ["Lower Z .001", "testkit\scripts\dze_snappoints.sqf", "down_micro", 99, false,false];
	if (!tk_editorMode) then {_action14 = player addAction ["Mark Existing Positions", "testkit\scripts\dze_snappoints.sqf", "markall", 99];}; // does not work in editor mode.
	if (!tk_editorMode) then {_action15 = player addAction ["Remove Check Markers", "testkit\scripts\dze_snappoints.sqf", "clearall", 99];}; // does not work in editor mode.
	_action16 = player addAction ["Exit", "testkit\scripts\dze_snappoints.sqf", "exit", 99];
	
	
	{
		tk_snap_actions set [count tk_snap_actions, _x];
	} count [_action1,_action2,_action3,_action4,_action5,_action6,_action7,_action8,_action9,_action10,_action11,_action12,_action13,_action14,_action15,_action16];
	
	["DZE Snap Points Tool",true] call tk_scriptToggle;
	
} else {
	{
		player removeAction _x;
	} count tk_snap_actions;
	
	tk_snap_actions = nil;
	if !(isNil "DZE_vehTarget") then {deleteVehicle DZE_vehTarget;};
	DZE_vehTarget = nil;
		
	["DZE Snap Points Tool",false] call tk_scriptToggle;
	
};