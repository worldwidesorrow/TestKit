private ["_action1","_action2","_action3"];

if (isNil "tk_mission_actions") then {tk_mission_actions = [];};

tk_missionSpawnPointsOn = !tk_missionSpawnPointsOn;

if (tk_missionSpawnPointsOn) then {
	_action1 = player addAction ["Place Marker", "testkit\scripts\missionSpawnPoints.sqf", "setMarker", 99];
	_action2 = player addAction ["Remove Marker", "testkit\scripts\missionSpawnPoints.sqf", "remove", 99];
	_action3 = player addAction ["Generate Array", "testkit\scripts\missionSpawnPoints.sqf", "generate", 99];
	
	{
		tk_mission_actions set [count tk_mission_actions, _x];
	} count [_action1,_action2,_action3];
	
	["DZE Mission Spawn Point Tool",true] call tk_scriptToggle;
	
} else {
	{
		player removeAction _x;
	} count tk_mission_actions;
	
	tk_mission_actions = nil;
	if !(isNil "DZE_MissionSpawnMarkers") then {
		systemChat format ["Removed %1 Mission Markers",(count DZE_MissionSpawnMarkers)];
		{
			deleteMarkerLocal _x;
		} count DZE_MissionSpawnMarkers;
		
		DZE_MissionSpawnMarkers = nil;
	};
		
	["DZE Mission Spawn Point Tool",false] call tk_scriptToggle;
	
};