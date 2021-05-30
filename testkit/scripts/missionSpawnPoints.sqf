// Create Mission Spawn Points by JasonTM.

private ["_new","_pos","_marker","_goodSpot"];

if (isNil "DZE_MissionSpawnMarkers") then {DZE_MissionSpawnMarkers = [];};

_new = _this select 3;

if (_new == "loop") exitWith {
	for "_i" from 1 to 1000 do {
		_pos = [getMarkerPos "center",0,((getMarkerSize "center") select 1) * .75,30,0,.2,0] call BIS_fnc_findSafePos;
		_goodSpot = true;
		if (count _pos == 2 && {!(_pos in DZE_MissionSpawnMarkers)}) then {
			{
				if ((getMarkerPos _x) distance _pos < 100) exitWith {
					_goodSpot = false;
				};
			} count DZE_MissionSpawnMarkers;
			if (_goodSpot) then {
				_marker = createMarkerLocal [str _pos, _pos];
				_marker setMarkerColorLocal "ColorBlack";
				_marker setMarkerTypeLocal "mil_dot";
				_marker setMarkerTextLocal (str _i + " Position");
				DZE_MissionSpawnMarkers set [count DZE_MissionSpawnMarkers, _marker];
			};
		};
	};
	systemChat format ["You have created %1 markers.",(count DZE_MissionSpawnMarkers)];
	diag_log formatText ["You have created %1 markers.",(count DZE_MissionSpawnMarkers)];
};

if (_new == "setMarker") exitWith {
	_pos = getPos player;
	_pos = [_pos select 0, _pos select 1]; // convert to 2d positions

	// Posts the player's position to the client rpt
	//diag_log format["Mission position: %1",_pos];

	// Sets markers on the map in game so that you can keep track of positions
	_marker = createMarkerLocal [str _pos, _pos];
	_marker setMarkerColorLocal "ColorBlack";
	_marker setMarkerTypeLocal "mil_dot";
	_marker setMarkerTextLocal "Mission Position";

	systemChat format["Mission Position Created at %1", _pos];

	DZE_MissionSpawnMarkers set [count DZE_MissionSpawnMarkers, _marker];
};

if (_new == "remove") exitWith {
	_removed = false;
	{
		_playerPos = getPos player;
		_markerPos = getMarkerPos _x;
		if ((_playerPos distance _markerPos) < 50) exitWith {
			DZE_MissionSpawnMarkers set [_forEachIndex, "remove"];
			DZE_MissionSpawnMarkers = DZE_MissionSpawnMarkers - ["remove"];
			deleteMarkerLocal _x;
			systemChat format ["Marker Position at %1 Removed",_markerPos];
			_removed = true;
		};
	} forEach DZE_MissionSpawnMarkers;
	if (!_removed) then{systemChat "You need to be within 50 meters of a marker to remove it";};
	
};

if (_new == "generate") exitWith {
	// NOTE: You cannot place all positions in one horizontal array because the Arma 2 RPT has single line length limits. A long list will get cut off.
	{
		_markerPos = getMarkerPos _x;
		// convert to 2d positions
		if (_forEachIndex == ((count DZE_MissionSpawnMarkers) -1)) then {
			diag_log text format ["%1",[_markerPos select 0,_markerPos select 1]]; // the last element in an array does not have a comma after it.
		} else {
			diag_log text format ["%1,",[_markerPos select 0,_markerPos select 1]];
		};
	} forEach DZE_MissionSpawnMarkers;
	systemChat format["%1 positions posted to the client rpt",(count DZE_MissionSpawnMarkers)];
};