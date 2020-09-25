/*
 * Author: woofer
 * Assign a new actor according to actor autoswitch.
 * If nothing is passed to the function, it assumes values from actorAutoSwitch settings.
 * If a unit is passed to the function it will migrate all properties to this new actor.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * New Actor <OBJECT>
 *
 * Example:
 * [player] call indiCam_fnc_actorSwitch
 *
 * Public: No
 */

// Default setting, make better by figuring out how params really work
private _newActor = player;

// Edited: Removed useless code

// Get all the current autoswitch preferences
private _switchSide = indiCam_var_actorSwitchSettings select 0; // Actor switch SIDE [0=WEST,1=EAST,2=resistance,3=civilian,4=all,5=actorSide]
private _switchPlayersOnly = indiCam_var_actorSwitchSettings select 1; 		  // Restrict to players only
private _switchProximity = indiCam_var_actorSwitchSettings select 2; 		  // random unit within this proximity of actor (-1 means closest)
private _autoSwitchDurationSwitch = indiCam_var_actorSwitchSettings select 3; // Actor auto switch is off/on
private _autoSwitchDuration = indiCam_var_actorSwitchSettings select 4; 	  // Actor auto switch duration
	
/* ----------------------------------------------------------------------------------------------------
									In case where no unit was passed to the function
   ---------------------------------------------------------------------------------------------------- */

// Check if a unit was passed to the script. If not, use current autoswitch settings.
if (str _this == "[]") then { // There really should be a more elegant way to do this check, right?


private _case = (indiCam_var_actorSwitchSettings select 0);	// If nothing was passed, assume switch occurs between what is currently set

// Executes the proper function for each mode and kills the current running one.
switch (_case) do { // Edited: Refactor actor list

	case 0: { // Edited: Players and AI Units near players outside base
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switch among Players and AI Units near players outside base.", _case];};
				
				private _camPlayerUnits = playableUnits;
				private _camUnits = [];
				
				if !(isNull btc_gear_object) then { // Exclude all players at base, this can improve performance, because there are always many players at base
					_camPlayerUnits = _camPlayerUnits - (_camPlayerUnits inAreaArray [getPosWorld btc_gear_object, 300, 300]);
				};

				{ // Get all units near players (including players itself or other players, so we use pushBackUnique)
					{
						_camUnits pushBackUnique _x;
					} forEach (allUnits inAreaArray [getPosWorld _x, 150, 150]);
				} forEach _camPlayerUnits;

				if !(isNull btc_gear_object) then { // Exclude other units at base (such as AI)
					_camUnits = _camUnits - (_camUnits inAreaArray [getPosWorld btc_gear_object, 300, 300]);
				};

				if (((count _camUnits) < 1) && {!(isNull btc_create_object)}) then { // If there's no unit in _camUnits, we can choose players near logistics point, or use static weapons to observe base
					_camUnits = playableUnits + (_camPlayerUnits inAreaArray [getPosWorld btc_create_object, 100, 100]);
				};

				if !((count _camUnits) < 1) then { // If there's units in _camUnits, use them
					_newActor = selectRandom _camUnits;
				} else { // If there's still no unit in _camUnits, just use a random unit
					_newActor = selectRandom allUnits;
				};
			};
			
	case 1: { // Edited: Players outside base
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switch among Players outside base.", _case];};

				private _camPlayerUnits = playableUnits;
				private _camUnits = [];
				
				if !(isNull btc_gear_object) then { // Exclude all players at base, this can improve performance, because there are always many players at base
					_camPlayerUnits = _camPlayerUnits - (_camPlayerUnits inAreaArray [getPosWorld btc_gear_object, 300, 300]);
				};

				_camUnits = _camPlayerUnits; // Use _camPlayerUnits as _camUnits

				if (((count _camUnits) < 1) && {!(isNull btc_create_object)}) then { // If there's no unit in _camUnits, we can choose players near logistics point, or use static weapons to observe base
					_camUnits = playableUnits + (_camPlayerUnits inAreaArray [getPosWorld btc_create_object, 100, 100]);
				};

				if !((count _camUnits) < 1) then { // If there's units in _camUnits, use them
					_newActor = selectRandom _camUnits;
				} else { // If there's still no unit in _camUnits, just use a random unit
					_newActor = selectRandom allUnits;
				};
			};
			
	case 2: { // Edited: AI Units near players outside base
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switch among AI Units near players outside base.", _case];};

				private _camPlayerUnits = playableUnits;
				private _camUnits = [];
				
				if !(isNull btc_gear_object) then { // Exclude all players at base, this can improve performance, because there are always many players at base
					_camPlayerUnits = _camPlayerUnits - (_camPlayerUnits inAreaArray [getPosWorld btc_gear_object, 300, 300]);
				};

				{ // Get all units near players (including players itself or other players, so we use pushBackUnique)
					{
						_camUnits pushBackUnique _x;
					} forEach (allUnits inAreaArray [getPosWorld _x, 150, 150]);
				} forEach _camPlayerUnits;

				if !(isNull btc_gear_object) then { // Exclude other units at base (such as AI)
					_camUnits = _camUnits - (_camUnits inAreaArray [getPosWorld btc_gear_object, 300, 300]);
				};

				_camUnits = _camUnits - _camPlayerUnits; // Exclude players

				if (((count _camUnits) < 1) && {!(isNull btc_create_object)}) then { // If there's no unit in _camUnits, we can choose players near logistics point, or use static weapons to observe base
					_camUnits = playableUnits + (_camPlayerUnits inAreaArray [getPosWorld btc_create_object, 100, 100]);
				};

				if !((count _camUnits) < 1) then { // If there's multiple units in _camUnits, use them
					_newActor = selectRandom _camUnits;
				} else { // If there's still no unit in _camUnits, just use a random unit
					_newActor = selectRandom allUnits;
				};
			};
			
	case 3: { // Edited: Players and AI Units near players within current actor's group outside base
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switch among Players and AI Units near players within current actor's group outside base.", _case];};

				private _camPlayerUnits = units (group indiCam_actor);
				private _camUnits = [];

				if !(isNull btc_gear_object) then { // Exclude all players at base, this can improve performance, because there are always many players at base
					_camPlayerUnits = _camPlayerUnits - (_camPlayerUnits inAreaArray [getPosWorld btc_gear_object, 300, 300]);
				};

				{ // Get all units near players (including players itself or other players, so we use pushBackUnique)
					{
						_camUnits pushBackUnique _x;
					} forEach (allUnits inAreaArray [getPosWorld _x, 150, 150]);
				} forEach _camPlayerUnits;

				if !(isNull btc_gear_object) then { // Exclude other units at base (such as AI)
					_camUnits = _camUnits - (_camUnits inAreaArray [getPosWorld btc_gear_object, 300, 300]);
				};

				if (((count _camUnits) < 1) && {!(isNull btc_create_object)}) then { // If there's no unit in _camUnits, we can choose players near logistics point, or use static weapons to observe base
					_camUnits = playableUnits + (_camPlayerUnits inAreaArray [getPosWorld btc_create_object, 100, 100]);
				};

				if !((count _camUnits) < 1) then { // If there's units in _camUnits, use them
					_newActor = selectRandom _camUnits;
				} else { // If there's still no unit in _camUnits, just use a random unit
					_newActor = selectRandom allUnits;
				};
			};
	
	case 4: { // Edited: Players and AI Units near players within current actor's group
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switch among Players and AI Units near players within current actor's group.", _case];};

				private _camPlayerUnits = units (group indiCam_actor);
				private _camUnits = [];

				{ // Get all units near players (including players itself or other players, so we use pushBackUnique)
					{
						_camUnits pushBackUnique _x;
					} forEach (allUnits inAreaArray [getPosWorld _x, 150, 150]);
				} forEach _camPlayerUnits;

				if (((count _camUnits) < 1) && {!(isNull btc_create_object)}) then { // If there's no unit in _camUnits, we can choose players near logistics point, or use static weapons to observe base
					_camUnits = playableUnits + (_camPlayerUnits inAreaArray [getPosWorld btc_create_object, 100, 100]);
				};

				if !((count _camUnits) < 1) then { // If there's units in _camUnits, use them
					_newActor = selectRandom _camUnits;
				} else { // If there's still no unit in _camUnits, just use a random unit
					_newActor = selectRandom allUnits;
				};
			};
			
	case 5: { // Edited: Players within current actor's group
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switch among Players within current actor's group.", _case];};

				private _camPlayerUnits = units (group indiCam_actor);
				private _camUnits = [];

				if (((count _camUnits) < 1) && {!(isNull btc_create_object)}) then { // If there's no unit in _camUnits, we can choose players near logistics point, or use static weapons to observe base
					_camUnits = playableUnits + (_camPlayerUnits inAreaArray [getPosWorld btc_create_object, 100, 100]);
				};

				if !((count _camUnits) < 1) then { // If there's units in _camUnits, use them
					_newActor = selectRandom _camUnits;
				} else { // If there's still no unit in _camUnits, just use a random unit
					_newActor = selectRandom allUnits;
				};
			};
	
	case 6: { // Random Units everywhere
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switch between all on current side.", _case];};

				_newActor = selectRandom allUnits;

				// _unitArray = allUnits - [player,indiCam_actor];
				// {
				// 	if (side _x == _actorSide) then {_sortedArray pushback _x};
				// } forEach _unitArray;
				// if (count _sortedArray > 1) then {_newActor = selectRandom _sortedArray} else {/*No other unit was to be found, do nothing*/ };
			};
	// Edited: Below haven't modified by me
	case 7: { // Random unit search started within distance actor side
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switching to units on current side within given distance.", _case];};
				
				_unitArray = allUnits - [player,indiCam_actor];

				{
					if (side _x == _actorSide) then {_sortedArray pushback _x};
				} forEach _unitArray;
			};
			
	case 8: { // Random unit within group of current unit
				if (indiCam_debug) then {systemChat format ["Case: %1 - Auto switch between units in current group.", _case];};

				_newActor = selectRandom allUnits;

				// _unitArray = (units group indiCam_actor);
				// _unitArray = _unitArray - [player];
				
				// if ( (count _unitArray) > 0 ) then {_newActor = selectRandom _unitArray} else {/*No other unit was to be found, do nothing*/ };
				
			};
			

}; // End of switch

/* ----------------------------------------------------------------------------------------------------
									In case where a unit was passed													
   ---------------------------------------------------------------------------------------------------- */

// If there was something passed to this script, use that.
} else {
	_newActor = (_this select 0);
};

/* ----------------------------------------------------------------------------------------------------
											Eventhandlers												
   ---------------------------------------------------------------------------------------------------- */

// This is where we strip the previous actor of any previous indicam eventhandlers
// I should probably list all eventhandlers that I defined in here

indiCam_actor removeEventHandler ["GetInMan",indiCam_var_enterVehicleEH];
indiCam_actor removeEventHandler ["GetOutMan",indiCam_var_exitVehicleEH];
indiCam_actor removeEventHandler ["Fired",indiCam_var_actorFiredEH];
indiCam_actor removeEventHandler ["Deleted",indiCam_var_actorDeletedEH];
indiCam_actor removeEventHandler ["Killed",indiCam_var_actorKilledEH];

if (_newACtor != player) then { // Dont bother with eventhandlers on the cameraman.

	// This is where we put any new indicam eventhandlers on the new actor
	indiCam_var_enterVehicleEH = _newActor addEventHandler ["GetInMan", {
		indiCam_var_requestMode == "default";if (indiCam_debug && (indiCam_var_currentMode == "default") ) then {systemChat "actor mounted a vic"};
	}];

	// Detect actor dismounting a vic
	indiCam_var_exitVehicleEH = _newActor addEventHandler ["GetOutMan", {
		indiCam_var_requestMode == "default";if (indiCam_debug && (indiCam_var_currentMode == "default") ) then {systemChat "actor dismounted a vic"};
	}];

	// Detect actor firing his weapon
	indiCam_var_actorFiredEH = _newActor addEventHandler ["Fired", {
		indiCam_var_actorFiredTimestamp = time;if (indiCam_debug && (indiCam_var_currentMode == "default") ) then {systemChat "actor has fired"};
	}];

	// Detect actor getting deleted
	indiCam_var_actorDeletedEH = _newActor addEventHandler ["Deleted", {
		// This is where we stop all eventhandlers
		if (indiCam_debug && indiCam_running) then {systemchat "actor was deleted";};
		//indiCam_actor = player; // Guess this isn't needed
		[] call indiCam_fnc_actorSwitch;
		indiCam_var_requestMode = "default";
	}];

	// Detect actor dying
	indiCam_var_actorKilledEH = _newActor addEventHandler ["Killed", {
		if ( indiCam_debug && indiCam_running ) then {systemChat "indiCam_actor was killed"};
		// Request the actor death scripted scene
		["actorDeath", indiCam_actor] spawn indiCam_scene_selectScripted;
	}];

};

/* ----------------------------------------------------------------------------------------------------
											Return values												
   ---------------------------------------------------------------------------------------------------- */



// Set the actor variable to the newly setup unit
indiCam_actor = _newActor;

// Store current actorSide
indiCam_var_actorSwitchSettings set [5,(side indiCam_actor)];

// Reset the actor switch timer if it's active
if (indiCam_var_actorAutoSwitch) then {
	indiCam_var_actorTimer = time + (indiCam_var_actorSwitchSettings select 4);
};


// Return the new indiCam_actor as well
_newActor;
