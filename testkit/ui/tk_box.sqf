private ["_near","_pos","_crate","_param"];

_crate = ["AmmoBoxBig","DZ_AmmoBoxFlatUS"] select tk_isEpoch; // Epoch crate can hold multiple backpacks.
if (tk_editorMode) exitWith {_crate createVehicle (getPos player);};
_param = _this select 0;

systemChat "Creating box and adding items. Please wait..";
_near = player nearObjects [_crate,50];
_pos = getPosATL player;
if (surfaceIsWater _pos) then {_pos = ATLToASL _pos;};
tk_doneSpawning = nil;
PVDZ_getTickTime = [getPlayerUID player,1,[_crate,_pos,_param],dayz_authKey];
publicVariableServer "PVDZ_getTickTime";

[_near,_crate] spawn {
	private ["_arrow","_box","_near","_startTime","_crate"];
	
	_near = _this select 0;
	_crate = _this select 1;
	_startTime = diag_tickTime;
	
	waitUntil {
		uiSleep 1;
		//(count (player nearObjects [_crate,50]) != count _near or (diag_tickTime - _startTime > 15))
		(count (player nearObjects [_crate,50]) != count _near)
	};
	
	_box = objNull;
	{
		if !(_x in _near) exitWith {
			_box = _x;
		};
	} count (player nearObjects [_crate,50]);
	
	_box hideObject true;
	_arrow = "Sign_arrow_down_large_EP1" createVehicleLocal [0,0,0];
	_arrow setPos (getPosATL _box);
	
	waitUntil {
		uiSleep .4;
		(!isNil "tk_doneSpawning")
	};
	
	deleteVehicle _arrow;
	_box hideObject false;
	player reveal _box;
	systemChat format["Completed adding items to box in %1 seconds",diag_tickTime - _startTime];
};