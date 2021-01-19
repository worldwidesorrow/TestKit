/*
	Create and Edit DayZ Epoch Snap points
	Made for ebayShopper's Testkit by JasonTM
*/
private ["_points","_new","_type","_config","_smallPos","_iPos","_veh","_zedPos","_closestMarker","_removePos","_canSpawn","_lootPositions","_nearBy","_item","_smallPositions","_positionsZombie","_zheightChanged","_pos","_ppos","_worldPos"];

_new = _this select 3;

if (isNil "DZE_SnapPointMarkers") then {DZE_SnapPointMarkers = [];};
if (isNil "DZE_SnapPointCheckMarkers") then {DZE_SnapPointCheckMarkers = [];};
if (isNil "SnapPoint_Z_height") then {SnapPoint_Z_height = 0.5;};

// Select the object
if(_new == "select") then {
	if(!isnull cursortarget) then {
		DZE_target = cursortarget;
		hintsilent str(typeOf DZE_target);
	};
};

// Mark all snap points on the object if they exist -  does not work in editor because SnapBuilding is not loaded.
if (_new == "markall") exitWith {
	if (isNil "DZE_target") exitWith {systemChat "Please select a target first.";};
	_type = typeOf DZE_target;
	_config = configFile >> "SnapBuilding" >> _type;
	if !(isClass _config) exitWith {systemChat "This object has no snap points!";};
	_points = getArray (_config >> "points");
	{
		_iPos = [(_x select 0),(_x select 1),(_x select 2)];
		_iPos = DZE_target modelToWorld _iPos;
		_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
		_veh setPosATL _iPos;
		DZE_SnapPointCheckMarkers set [count DZE_SnapPointCheckMarkers, _veh];
	} forEach _points;
};

// Delete all of the markers created above
if (_new == "clearall") exitWith {
	systemChat format ["%1 Markers Removed.",(count DZE_SnapPointCheckMarkers)];
	{
		deleteVehicle _x;
	} count DZE_SnapPointCheckMarkers;
	DZE_SnapPointCheckMarkers = nil;
};

if (_new == "exit") exitWith {
	{
		deleteVehicle _x;
	} count DZE_SnapPointMarkers;
	DZE_vehTarget = nil;
	DZE_target = nil;
	call tk_snapPoints;
};

// All of the options above exit this script when completed. There should already be a target selected if it gets this far in the script.
if (isNil "DZE_target") exitWith {systemChat "Please select a target first.";};

_type = typeOf DZE_target;

_zheightChanged = false;

switch (_new) do
{
	case "up":			{SnapPoint_Z_height = SnapPoint_Z_height + 0.1; _zheightChanged = true;};
	case "down":		{SnapPoint_Z_height = SnapPoint_Z_height - 0.1; _zheightChanged = true;};
	case "up_small":	{SnapPoint_Z_height = SnapPoint_Z_height + 0.01; _zheightChanged = true;};
	case "down_small":	{SnapPoint_Z_height = SnapPoint_Z_height - 0.01; _zheightChanged = true;};
	case "up_micro":	{SnapPoint_Z_height = SnapPoint_Z_height + 0.001; _zheightChanged = true;};
	case "down_micro":	{SnapPoint_Z_height = SnapPoint_Z_height - 0.001; _zheightChanged = true;};
};

_worldPos = player modeltoworld [0,1.5,SnapPoint_Z_height];
_ppos = DZE_target worldToModel _worldPos;

if (isnil "DZE_vehTarget") then {
	DZE_vehTarget = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	DZE_vehTarget setPosATL _worldPos;
	DZE_vehTarget attachto [player]; 
	DZE_SnapPointMarkers set [count DZE_SnapPointMarkers, DZE_vehTarget];
};

if (!isnull(DZE_vehTarget) and _zheightChanged) then {
	detach DZE_vehTarget;
	DZE_vehTarget setPosATL _worldPos;
	DZE_vehTarget attachto [player];
};

if(_new == "tag_top") exitWith {
	_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	DZE_TargetPosTempTop = (_ppos select 2); // Used to calculate the midpoint with "tag_bottom"
	DZE_SnapPointMarkers set [count DZE_SnapPointMarkers, _veh];
	diag_log text format ["%2 - {0,0,%1,$STR_EPOCH_ACTION_SNAP_TOP},",(_ppos select 2),_type];
	hintsilent "Snap Point Saved";
};

if(_new == "tag_bottom") exitWith {
	_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	DZE_SnapPointMarkers set [count DZE_SnapPointMarkers, _veh];
	diag_log text format ["%2 - {0,0,%1,$STR_EPOCH_ACTION_SNAP_PIVOT},",(_ppos select 2),_type];
	hintsilent "Snap Point Saved";
	if !(isNil "DZE_TargetPosTempTop") then {
		diag_log text format ["The midpoint is %1",((DZE_TargetPosTempTop - (_ppos select 2))/2)]; // Calculate the midpoint of the object
		DZE_TargetPosTempTop = nil;
	};
};

if(_new == "tag_back") exitWith {
	_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	DZE_SnapPointMarkers set [count DZE_SnapPointMarkers, _veh];
	diag_log text format ["%2 - {0,%1,0,$STR_EPOCH_ACTION_SNAP_BACK},",(_ppos select 1),_type];
	hintsilent "Snap Point Saved";
};

if(_new == "tag_front") exitWith {
	_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	DZE_SnapPointMarkers set [count DZE_SnapPointMarkers, _veh];
	diag_log text format ["%2 - {0,%1,0,$STR_EPOCH_ACTION_SNAP_FRONT},",(_ppos select 1),_type];
	hintsilent "Snap Point Saved";
};

if(_new == "tag_left") exitWith {
	_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	DZE_SnapPointMarkers set [count DZE_SnapPointMarkers, _veh];
	diag_log text format ["%2 - {%1,0,0,$STR_EPOCH_ACTION_SNAP_LEFT},",(_ppos select 0),_type];
	hintsilent "Snap Point Saved";
};

if(_new == "tag_right") exitWith {
	_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	DZE_SnapPointMarkers set [count DZE_SnapPointMarkers, _veh];
	diag_log text format ["%2 - {%1,0,0,$STR_EPOCH_ACTION_SNAP_RIGHT},",(_ppos select 0),_type];
	hintsilent "Snap Point Saved";
};