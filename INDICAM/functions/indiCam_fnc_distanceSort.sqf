/*
 * Author: woofer
 * Sorts a list of units according to 2D-proximity from a point/object.
 * If no arguments are passed, it will list and sort ALL units with respect to the actor.
 *
 * Arguments:
 * 0: Units [<OBJECT>]
 * 1: Target <OBJECT>
 * 2: Max Distance <NUMBER> -1 will include entire terrain
 *
 * Return Value:
 * Sorted Units [<OBJECT>]
 *
 * Example:
 * [allUnits, myActor, 10] call indiCam_fnc_actorSwitch
 *
 * Public: No
 */

//TODO- This function needs to check its input

// Prolly needs if ( isNull (_this select 0) ) then {};
private _array = allunits;			// If no argument is passed, assume allunits
private _target = indiCam_actor;	// If no argument is passed, assume actor
private _maxDistance = -1;			// If no argument is passed, assume entire terrain

private _distance = [];				// Making private
private _sortedArray = [];			// Making private

params ["_array","_target","_maxDistance"];

{
	// Check 2D distance
	_distance = _x distance2D _target;
	
	// Only add the unit to the list if the distance is less than maximum distance allowed, or if _maxDistance is set to -1.
	if ( (_distance < _maxDistance) or (_maxDistance == -1) ) then {
		// Store unit and corresponding distance in an array that can be sorted
		_sortedArray pushBack [_distance, _x];
	};
	
} forEach _array;

// Sort the list with ascending distances
_sortedArray sort true;

_outputArray = _sortedArray apply {_x select 1};
_outputArray;
