//---------------------------------------------------------------------------------------
//  FILE:    X2AbilityCharges_TakeThis
//  AUTHOR:  (Pavonis Interactive)
//  PURPOSE OF REMAKE : changed hardcoded ability, made more compact (as value is defined in a struct now)
//--------------------------------------------------------------------------------------- 


class X2AbilityCharges_TR_TakeThisCharge extends X2AbilityCharges;

var int AbilityCharges;

function int GetInitialCharges(XComGameState_Ability Ability, XComGameState_Unit Unit)
{
    local int Charges;

    Charges = AbilityCharges;
    return Charges;
}

defaultproperties
{
    AbilityCharges=1
}