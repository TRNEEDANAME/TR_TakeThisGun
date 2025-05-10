//---------------------------------------------------------------------------------------
//  FILE:    XComGameState_Effect_TemporaryItem
//  AUTHOR:  Amineri (Pavonis Interactive)
//  PURPOSE: Persistent Effect for managing temp items
//  PURPOSE OF REMAKE : Name conflict, no changes done
//--------------------------------------------------------------------------------------- 

class XComGameState_TR_Effect_TemporaryItem extends XComGameState_Effect dependson(X2Effect_TR_TemporaryItem);

var array<StateObjectReference> TemporaryItems; // temporary items granted only for the duration of the tactical mission

defaultproperties
{
	bTacticalTransient=true;
}
