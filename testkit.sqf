#define ALLOWED ["123456789","123456789"]
//#define ANTICHEAT //Uncomment to run testkit_ac.sqf on non-privileged clients

tk_postList = true; // Posts contents of the list box to the rpt.

"PVDZ_getTickTime" addPublicVariableEventHandler {
	private ["_caller","_exitReason","_key","_name","_param","_type","_uid","_value"];
	
	_value = _this select 1;
	_uid = _value select 0;
	{
		if (_uid == getPlayerUID _x) exitWith {
			if (_uid in ALLOWED) then {
				_caller = _x;
				_name = if (alive _x) then {name _x} else {"DeadPlayer"};
				if (count _value == 1) then {
					PVDZ_login = {call compile preprocessFileLineNumbers "testkit\init.sqf"};
					//Only server can send this variable. Clients are kicked by BE if they try to send it. Do not allow in publicvariable.txt
					//Only send to client that owns the authorized UID regardless of who sent the request
					(owner _x) publicVariableClient "PVDZ_login";
					diag_log format["TESTKIT - Authorized startup by %1(%2)",_name,_uid];
				};
			} else {
#ifdef ANTICHEAT
				PVDZ_login = {
					#include "testkit_ac.sqf"
				};
				(owner _x) publicVariableClient "PVDZ_login";
#endif
			};
		};
	} count allUnits;
	
	if (count _value == 1) exitWith {};
	_type = _value select 1;
	_param = _value select 2;
	_key = _value select 3;
	
	_exitReason = [_this,"TESTKIT",_caller,_key,_uid,_caller] call server_verifySender;
	if (_exitReason != "") exitWith {diag_log _exitReason};
	
	if (_uid in ALLOWED) then {
		diag_log format["TESTKIT - Authorized server execution by %1(%2): %3",_name,_uid, switch (_type) do {
				case 1: { [_caller,_param] call tk_serverSpawnObject; format["spawned %1",_param select 0] };
				case 2: {
					dayzSetDate = [2012,8,2,_param,1];
					publicVariable "dayzSetDate";
					setDate dayzSetDate;
					format["set server to %1time",if (_param == 11) then {"day"} else {"night"}]
				};
				case 3: {
					if (isClass (configFile >> "CfgWeapons" >> "Chainsaw")) then { // Epoch check
						_param spawn {
							DZE_WeatherEndThread = true;
							publicVariable "DZE_WeatherEndThread";
							uiSleep 5;
							PVDZE_SetWeather = call {
								if (_this == 0) exitWith {[0, 0, 0, 0, 0, 0, "NONE", false];}; // sunny
								if (_this == 1) exitWith {[1, 0, 1, 0, 0, 0, "NONE", false];}; // raining
								if (_this == 2) exitWith {[1, 0, 0, 0, 0, 1, "NONE", false];}; // snowing
								if (_this == 3) exitWith {[1, 0, 0, 0, 0, 1, "NONE", true];}; // blizzard
							};
							publicVariable "PVDZE_SetWeather";
							0 setRain (PVDZE_SetWeather select 2); 0 setOvercast (PVDZE_SetWeather select 0); 0 setFog 0; setWind [0, 0, true];
							format["Set server weather to %1",(["sunny","raining","snowing","blizzard"] select _this)];
						};
					} else {
						drn_DynamicWeatherEventArgs = [_param,random _param,_param,"none",_param,0,-1,-1];
						publicVariable "drn_DynamicWeatherEventArgs";
						drn_DynamicWeatherEventArgs call drn_fnc_DynamicWeather_SetWeatherLocal;
						format["set server to %1 weather",if (_param == 0) then {"sunny"} else {"rainy"}]
					};
				};
				case 4: {
					PVCDZ_hlt_Bandage = [_param,_caller];
					PVCDZ_hlt_Epi = [_param,_caller,"ItemEpinephrine"];
					PVCDZ_hlt_PainK = [_param,_caller];
					PVCDZ_hlt_Transfuse = [_param,_caller,12000];
					PVCDZ_hlt_AntiB = [_param,_caller];
					PVCDZ_hlt_Morphine = [_param,_caller];				
					{
						if (_param getVariable [_x,false]) then {
							_param setVariable [_x,false,true];
						};
					} count ["NORRN_unconscious","USEC_isCardiac","USEC_inPain"];
					{owner _param publicVariableClient _x;} count ["PVCDZ_hlt_Bandage","PVCDZ_hlt_Epi","PVCDZ_hlt_Morphine","PVCDZ_hlt_PainK","PVCDZ_hlt_Transfuse","PVCDZ_hlt_AntiB"];
					_param setVariable ["medForceUpdate",true,false];
					format["gave meds to %1",_param]
				};
			}
		];
	};
};

tk_serverSpawnObject = {
	private ["_type","_caller","_class","_config","_count","_id","_ignoreMagazines","_ignoreWeapons","_list","_name","_object","_pos","_option","_include","_ignoreBackpacks","_temp","_ammo"];
	_caller = _this select 0;
	_class = (_this select 1) select 0;
	_pos = (_this select 1) select 1;
	_option = (_this select 1) select 2; // 0 - weapons, 1 - building supplies, 2 - items, 3 - backpacks, 4 - clothes, 5 - vanilla

	_object = _class createVehicle _pos;
	//_id = format ["%1",ceil(random 8000)];
	//_object setVariable ["CharacterID",_id,true];
	//_object setVariable ["lastUpdate",diag_ticktime,false];
	//_object setVariable ["ObjectUID",_id,true];
	//dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_object];
	clearBackpackCargoGlobal _object;
	clearMagazineCargoGlobal _object;
	clearWeaponCargoGlobal _object;
	
	if (_class in ["AmmoBoxBig","DZ_AmmoBoxFlatUS"]) then {
		if (tk_postList) then {diag_log "BEGIN LIST OF CLASSNAMES";};
		_object setVariable ["permaLoot",true,false];
		
		call {
			if (_option == 0) exitWith { // long guns, handguns, ammo, and attachments
				_ignoreWeapons = ["Mosin_BR_DZ"];
				_config = configFile >> "CfgWeapons";
				_count = 0;
				_list = [];
				_list resize (count _config);
				_temp = [];
				{
					_type = _config select _count;
					_count = _count + 1;
					_name = configName _type;
					if (isClass _type && {getNumber (_type >> "type") in [1,2]} && {(["_DZ",_name] call fnc_inString) || {["_DZE",_name] call fnc_inString}} && {!(["_BASE",_name] call fnc_inString)} && {!(["_base",_name] call fnc_inString)} && {!(_name in _ignoreWeapons)}) then {
						_object addWeaponCargoGlobal [_name,1];
						_ammoArr = getArray (_config >> _name >> "magazines");
						if (count _ammoArr > 0) then {
							_ammo = _ammoArr select 0;
							if !(_ammo in _temp) then {
								_temp = _temp + [_ammo];
								_object addMagazineCargoGlobal [_ammo,20];
							};
						};
						//if (tk_postList) then {diag_log _name;};
						if (tk_postList) then {diag_log [_name,_ammo];};
					};
				} count _list;
				
				_ignoreMagazines = [];
				_config = configFile >> "CfgMagazines";
				for "_i" from 0 to (count _config) - 1 do {
					_type = _config select _i;
					_name = configName _type;
					if (isClass _type && {["Attachment_",_name] call fnc_inString} && {!(_name in _ignoreMagazines)}) then {
						_object addMagazineCargoGlobal [_name,1];
						if (tk_postList) then {diag_log _name;};
					};
				};
			};
			if (_option == 1) exitWith { // building supplies
				_include = ["plot_pole_kit","ItemComboLock","ItemTringleWoodFloor","ItemTriangleWoodWall","door_frame_kit","door_kit","door_locked_kit"];
				_tkstorage = ["outhouse_kit","wooden_shed_kit","wooden_shed_kit2","wood_shack_kit","wood_shack_kit2","storage_shed_kit","storage_shed_kit2","ItemGunRackKit","ItemGunRackKit2","ItemWoodCrateKit","ItemWoodCrateKit2","ItemVault","ItemVault2","ItemTallSafe","ItemLockbox","ItemLockbox2","ItemLockboxWinter","ItemLockboxWinter2","cook_tripod_kit","stoneoven_kit","commode_kit","wardrobe_kit","fridge_kit","washing_machine_kit","server_rack_kit","atm_kit","armchair_kit","sofa_kit","arcade_kit","vendmachine1_kit","vendmachine2_kit"];
				_ignoreMagazines = [];
				_config = configFile >> "CfgMagazines";
				_count = 0;
				_list = [];
				_list resize (count _config);
				{
					_type = _config select _count;
					_count = _count + 1;
					_name = configName _type;
					if (isClass _type && ((["cinder",_name] call fnc_inString) || {["metal_",_name] call fnc_inString} || {["ItemWood",_name] call fnc_inString} || {["PartWood",_name] call fnc_inString} || {["glass_floor_",_name] call fnc_inString} || {_name in _include}) && {!(_name in _ignoreMagazines)}) then {
						_object addMagazineCargoGlobal [_name,20];
						if (tk_postList) then {diag_log _name;};
					};
					if (_name in _tkstorage) then {
						_object addMagazineCargoGlobal [_name,5];
						if (tk_postList) then {diag_log _name;};
					};
					
				} count _list;
			};
			if (_option == 2) exitWith { // Misc box
				/*
				_ignoreWeapons = [
					"ItemCore","MineE","ItemMatchbox_base","ItemMatchboxEmpty","ItemKnife_Base","ItemKnife1",
					"ItemKnife2","ItemKnife3","ItemKnife4","ItemKnife5","ItemKnifeBlunt","MeleeFlashlight",
					"MeleeFlashlightRed"
				];
				_ignoreParents = ["FakeWeapon","ItemMatchbox"];
				_config = configFile >> "CfgWeapons";
				_count = 0;
				_list = [];
				_list resize (count _config);
				{
					_type = _config select _count;
					_count = _count + 1;
					_name = configName _type;
					if (isClass _type && {!(isNumber (_type >> "keyid"))} && {getNumber (_type >> "type") in [4096,131072]} && {getNumber (_type >> "scope") > 1} && {!(["Broken",_name] call fnc_inString)} && {!(configName(inheritsFrom _type) in _ignoreParents)} && {!(_name in _ignoreWeapons)}) then {
						_object addWeaponCargoGlobal [_name,1];
						if (tk_postList) then {diag_log _name;};
					};
				} count _list;
				*/
				_ignoreMagazines = [
					"bloodBagBase","SkinBase","wholeBloodBagBase","ItemAntibiotic_base","ItemAntibioticEmpty",
					"ItemBriefcase_Base","ItemBriefcaseEmpty","ItemSilvercase_Base","ItemSodaEmpty","TrashTinCan",
					"ItemFuelcanEmpty","ItemJerrycanEmpty","ItemFuelBarrelEmpty",
					"ItemJerryMixed","ItemJerryMixed1","ItemJerryMixed2","ItemJerryMixed3","ItemJerryMixed4"
				];
				_ignoreParents = ["FakeMagazine","ItemAntibiotic","ItemSodaEmpty","ItemWaterBottle","TrashTinCan"];
				_config = configFile >> "CfgMagazines";
				_count = 0;
				_list = [];
				_list resize (count _config);
				{
					_type = _config select _count;
					_count = _count + 1;
					_name = configName _type;
					if (isClass _type && {getNumber (_type >> "scope") > 1} && {!(["Rnd",_name] call fnc_inString)} && {!(["Skin_",_name] call fnc_inString)} && {!(["_Swing",_name] call fnc_inString)} && {!(["Attachment_",_name] call fnc_inString)} && {!(["cinder_",_name] call fnc_inString)} && {!(["metal_",_name] call fnc_inString)} && {!(["ItemWood",_name] call fnc_inString)} && {!(["PartWood",_name] call fnc_inString)} && {!isNumber (_type >> "worth") || getNumber (_type >> "worth") in [100,10000]} && {!(configName(inheritsFrom _type) in _ignoreParents)} && {!(_name in _ignoreMagazines)}) then {
						_object addMagazineCargoGlobal [_name,1];
						if (tk_postList) then {diag_log _name;};
					};
				} count _list;
				
			};
			if (_option == 3) exitWith { // backpacks
				// The Epoch crates were modified by Airwaves Man to accept 100 backpacks :)
				_config = configFile >> "CfgVehicles";
				_count = 0;
				_list = [];
				_list resize (count _config);
				{
					_type = _config select _count;
					_count = _count + 1;
					_name = configName _type;
					if (isClass _type && {getText (_type >> "vehicleClass") == "Backpacks"} && {["_DZE1",_name] call fnc_inString || {["_DZE2",_name] call fnc_inString}}) then {
						_object addBackpackCargoGlobal [_name,1];
						if (tk_postList) then {diag_log _name;};
					};
				} count _list;
			};
			
			if (_option == 4) exitWith { // all clothes
				_ignoreMagazines = [];
				_config = configFile >> "CfgMagazines";
				for "_i" from 0 to (count _config) - 1 do {
					_type = _config select _i;
					_name = configName _type;
					if (isClass _type && {["Skin_",_name] call fnc_inString} && {!(_name in _ignoreMagazines)}) then {
						_object addMagazineCargoGlobal [_name,1];
						if (tk_postList) then {diag_log _name;};
					};
				};
			};
			
			if (_option == 5) exitWith { // vanilla
				_ignoreParents = ["FakeWeapon","ItemMatchbox"];
				_config = configFile >> "CfgWeapons";
				_count = 0;
				_list = [];
				_list resize (count _config);
				{
					_type = _config select _count;
					_count = _count + 1;
					_name = configName _type;
					if (isClass _type && {!isNumber (_type >> "keyid")} && {isNumber (_type >> "type")} && {getNumber (_type >> "scope") > 1} && {getText (_type >> "picture") != ""} && {!(getNumber (_type >> "type") in [1,2]) or (!isClass (_type >> "ItemActions") or {count (_type >> "ItemActions") < 1})} && {!(configName(inheritsFrom _type) in _ignoreParents)} && {!(_name in _ignoreWeapons)}) then {
						_object addWeaponCargoGlobal [_name,4];
						if (tk_postList) then {diag_log _name;};
					};
				} count _list;
						
				_ignoreParents = ["FakeMagazine","ItemAntibiotic","ItemSodaEmpty","ItemWaterBottle","TrashTinCan"];
				_config = configFile >> "CfgMagazines";
				_count = 0;
				_list = [];
				_list resize (count _config);
				{
					_type = _config select _count;
					_count = _count + 1;
					_name = configName _type;
					if (isClass _type && {getNumber (_type >> "scope") > 1} && {getText (_type >> "picture") != ""} && {!isNumber (_type >> "worth") or getNumber (_type >> "worth") in [100,10000]} && {!(configName(inheritsFrom _type) in _ignoreParents)} && {!(_name in _ignoreMagazines)}) then {
						_object addMagazineCargoGlobal [_name,20];
						if (tk_postList) then {diag_log _name;};
					};
				} count _list;
				_object addBackpackCargoGlobal ["DZ_Backpack_EP1",1];
			};
		};
		tk_doneSpawning = true;
		(owner _caller) publicVariableClient "tk_doneSpawning";
	} else {
		// Vanilla vehicle. No 388 method to get objectID, so position will not save until next restart
		_pos set [2,0];
		format["CHILD:308:%1:%2:%3:%4:%5:%6:%7:%8:%9:",dayZ_instance,_class,0,_id,[0,_pos],[[[],[]],[[],[]],[[],[]]],[],1,_id] call server_hiveWrite;
		_object setVelocity [0,0,1];
		_object call fnc_veh_ResetEH;
	};
};