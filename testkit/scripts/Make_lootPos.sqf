/*
	Get Loot Position
	Made for DayZ Epoch please ask permission to use/edit/distribute email vbawol@veteranbastards.com.
*/
private ["_new","_type","_config","_checkLoot","_lootPos","_smallPos","_iPos","_veh","_zedPos","_tagColor","_closestMarker","_removePos","_canSpawn","_lootPositions","_nearBy","_item","_smallPositions","_positionsZombie","_zheightChanged","_pos","_ppos","_worldPos"];

_new = _this select 3;

if (isNil "DZE_LootSpawnMarkers") then {DZE_LootSpawnMarkers = [];};
if (isNil "DZE_LootCheckMarkers") then {DZE_LootCheckMarkers = [];};
if (isNil "DZE_TestLoot") then {DZE_TestLoot = [];};
if (isNil "Base_Z_height") then {Base_Z_height = 0.5;};

// Select the building
if(_new == "select") then {
	if(!isnull cursortarget) then {
		DZE_target = cursortarget;
		hintsilent str(typeOf DZE_target);
	};
};

// Mark all loot and zed positions in the building if they exist -  does not work in editor because CfgLoot is not loaded.
if (_new == "markall") exitWith {
	if (isNil "DZE_target") exitWith {systemChat "Please select a target first.";};
	_type = typeOf DZE_target;
	_config = missionConfigFile >> "CfgLoot" >> "Buildings" >> _type;
	if !(isClass _config) exitWith {systemChat "You need to add this building to CfgLoot first";};
	_checkLoot = (count (getArray (_config >> "lootPos"))) > 0;
	if !(_checkLoot) exitWith {systemChat "This building has no loot spawn points";};
	
	_lootPos = getArray (_config >> "lootPos");
	{
		_iPos = DZE_target modelToWorld _x;
		//_veh = createVehicle ["Sign_arrow_down_EP1", _iPos, [], 0, "CAN_COLLIDE"];
		_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
		_veh setPosATL _iPos;
		DZE_LootCheckMarkers set [count DZE_LootCheckMarkers, _veh];
	} count _lootPos;
	
	_smallPos = getArray (_config >> "lootPosSmall");
	{
		_iPos = DZE_target modelToWorld _x;
		//_veh = createVehicle ["Sign_arrow_down_EP1", _iPos, [], 0, "CAN_COLLIDE"];
		_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
		_veh setPosATL _iPos;
		_tagColor = "#(argb,8,8,3)color(0,0,1,0.5,ca)";
		_veh setobjecttexture [0,_tagColor];
		DZE_LootCheckMarkers set [count DZE_LootCheckMarkers, _veh];
	} count _smallPos;
	
	_zedPos = getArray (_config >> "zedPos");
	{
		_iPos = DZE_target modelToWorld _x;
		//_veh = createVehicle ["Sign_sphere10cm_EP1", _iPos, [], 0, "CAN_COLLIDE"];
		_veh = "Sign_sphere10cm_EP1" createVehicleLocal [0,0,0];
		_veh setPosATL _iPos;
		_tagColor = "#(argb,8,8,3)color(0,1,0,0.5,ca)";
		_veh setobjecttexture [0,_tagColor];
		DZE_LootCheckMarkers set [count DZE_LootCheckMarkers, _veh];
	} count _zedPos;
	
	systemChat format ["%1 Loot Positions Marked.",(count _lootPos)];
	systemChat format ["%1 Small Loot Positions Marked.",(count _smallPos)];
	systemChat format ["%1 Zombie Positions Marked.",(count _zedPos)];
};

if (_new == "tag remove") exitWith {
	if (isNil "DZE_target") exitWith {systemChat "Please select a target first.";};
	//_closestMarker = nearestObject [player, "Sign_arrow_down_EP1"]; // nearestObject scans 50 meters.
	_closestMarkers = nearestObjects [player, ["Sign_arrow_down_EP1"], 3]; // you can adjust the scan distance with nearestObjects.
	if ((count _closestMarkers) == 0) exitWith {systemChat "No markers near player.";};
	_closestMarker = _closestMarkers select 0;
	if (_closestMarker == DZE_vehTarget) then {_closestMarker = _closestMarkers select 1;};
	if (isNil "_closestMarker") exitWith {systemChat "No marker selected";};
	_removePos = DZE_target worldToModel (getPosATL _closestMarker);
	diag_log text format ["%1: REMOVE: %2",(typeOf DZE_target),_removePos];
	systemChat format ["Loot spawn at %1 tagged for removal.",_removePos];
	deleteVehicle _closestMarker; // Visual confirmation of which marker was selected.
};

// Delete all of the markers created above
if (_new == "clearall") exitWith {
	systemChat format ["%1 Markers Removed.",(count DZE_LootCheckMarkers)];
	{
		deleteVehicle _x;
	} count DZE_LootCheckMarkers;
	DZE_LootCheckMarkers = nil;
};

/*
// Generate loot on all existing spawn points to check integrity - does not work in editor because CfgLoot is not loaded.
if(_new == "generateloot") exitWith {
	if (!tk_editorMode) exitWith {systemChat "You can only use this function in editor mode."};
	if (isNil "DZE_target") exitWith {systemChat "Please select a target first.";};
	_type = typeOf DZE_target;
	_config = missionConfigFile >> "CfgLoot" >> "Buildings" >> _type;
	_canSpawn = isClass (_config);
	if !(_canSpawn) exitWith {diag_log "You need to add this building to CfgLoot first";};
	
	_lootPositions = getArray (_config >> "lootPos");
	{
		
		_iPos = DZE_target modelToWorld _x;
		_nearBy = nearestObjects [_iPos, ["ReammoBox","WeaponHolder","WeaponHolderBase"], 1];
		if (count _nearBy == 0) then {
			_item = createVehicle ["WeaponHolder", _iPos, [], 0.0, "CAN_COLLIDE"];
			_item addMagazineCargoGlobal ["Skin_Worker1_DZ",1];
			_item setPosATL _iPos;
			DZE_TestLoot set [count DZE_TestLoot, _item];
		} else {
			diag_log format["position too close: %1", _iPos];
		};
	} count _lootPositions;

	_smallPositions = getArray (_config >> "lootPosSmall");
	{
		_iPos = DZE_target modelToWorld _x;
		_nearBy = nearestObjects [_iPos, ["ReammoBox","WeaponHolder","WeaponHolderBase"], 1];
		if (count _nearBy == 0) then {
		
			_item = createVehicle ["WeaponHolder", _iPos, [], 0.0, "CAN_COLLIDE"];
			_item addMagazineCargoGlobal ["ItemPainkiller",1];
			_item setPosATL _iPos;
			DZE_TestLoot set [count DZE_TestLoot, _item];
		} else {
			diag_log format["position too close: %1", _iPos];
		};
	} count _smallPositions;
	
	_positionsZombie = getArray (_config >> "lootPosZombie");
	{
		_iPos = DZE_target modelToWorld _x;
		
		//_veh = createVehicle ["Sign_sphere10cm_EP1", _iPos, [], 0, "CAN_COLLIDE"];
		_veh = "Sign_sphere10cm_EP1" createVehicleLocal [0,0,0];
		_veh setPosATL _iPos;
		_tagColor = "#(argb,8,8,3)color(0,1,0,0.5,ca)";
		_veh setobjecttexture [0,_tagColor];
		
	} count _positionsZombie;
};
*/

if (_new == "exit") exitWith {
	{
		deleteVehicle _x;
	} count DZE_LootSpawnMarkers;
	DZE_vehTarget = nil;
	DZE_target = nil;
	call tk_lootSpawnPoints;
};

// All of the options above exit this script when completed. There should already be a target selected if it gets this far in the script.
if (isNil "DZE_target") exitWith {systemChat "Please select a target first.";};

_type = typeOf DZE_target;

_zheightChanged = false;

switch (_new) do
{
	case "up":			{Base_Z_height = Base_Z_height + 0.1; _zheightChanged = true;};
	case "down":		{Base_Z_height = Base_Z_height - 0.1; _zheightChanged = true;};
	case "up_small":	{Base_Z_height = Base_Z_height + 0.01; _zheightChanged = true;};
	case "down_small":	{Base_Z_height = Base_Z_height - 0.01; _zheightChanged = true;};
};

_pos = player modeltoworld [0,1.5,Base_Z_height];

if(_new == "tag zed spawn") then {
	_pos = player modeltoworld [0,0,0.875];
};

_ppos = DZE_target worldToModel _pos;
_worldPos = _pos;

if (isnil "DZE_vehTarget") then {
	//DZE_vehTarget = createVehicle ["Sign_arrow_down_EP1", _worldPos, [], 0, "CAN_COLLIDE"];
	DZE_vehTarget = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	DZE_vehTarget setPosATL _worldPos;
	DZE_vehTarget attachto [player]; 
	DZE_LootSpawnMarkers set [count DZE_LootSpawnMarkers, DZE_vehTarget];
};

if (!isnull(DZE_vehTarget) and _zheightChanged) then {
	detach DZE_vehTarget;
	DZE_vehTarget setPosATL _worldPos;
	DZE_vehTarget attachto [player];
};

if(_new == "tag zed spawn") then {
	//_veh = createVehicle ["Sign_sphere10cm_EP1", _worldPos, [], 0, "CAN_COLLIDE"];
	_veh = "Sign_sphere10cm_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	_tagColor = "#(argb,8,8,3)color(0,1,0,0.5,ca)";
	_veh setobjecttexture [0,_tagColor];
	DZE_LootSpawnMarkers set [count DZE_LootSpawnMarkers, _veh];
};

if(_new == "tag loot") then {
	//_veh = createVehicle ["Sign_arrow_down_EP1", _worldPos, [], 0, "CAN_COLLIDE"];
	_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	DZE_LootSpawnMarkers set [count DZE_LootSpawnMarkers, _veh];
};

if(_new == "tag loot small") then {
	//_veh = createVehicle ["Sign_arrow_down_EP1", _worldPos, [], 0, "CAN_COLLIDE"];
	_veh = "Sign_arrow_down_EP1" createVehicleLocal [0,0,0];
	_veh setPosATL _worldPos;
	_tagColor = "#(argb,8,8,3)color(0,0,1,0.5,ca)";
	_veh setobjecttexture [0,_tagColor];
	DZE_LootSpawnMarkers set [count DZE_LootSpawnMarkers, _veh];
};

if(_new in ["tag loot","tag zed spawn","tag loot small"]) then {
	diag_log text format ["%1 : %2 | %3", _type,_ppos,_new];
	copyToClipboard format ["%1 : %2", _type,_ppos];
	hintsilent format ["SAVED %1\n%2", _type,_ppos];
};