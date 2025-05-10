//---------------------------------------------------------------------------------------
//  FILE:    X2AbilityCharges_TakeThis
//  AUTHOR:  (Pavonis Interactive)
//  PURPOSE OF REMAKE : changed hardcoded ability
//--------------------------------------------------------------------------------------- 

class X2AbilityCharges_TR_TakeThisGunCharge extends X2AbilityCharges;

var int BonusAbilityCharges;
var name BonusAbility;
var name BonusItem;

function int GetInitialCharges(XComGameState_Ability Ability, XComGameState_Unit Unit)
{
    local int Charges;

    Charges = InitialCharges;
    if (Unit.HasSoldierAbility(BonusAbility, true))
    {
        Charges += BonusAbilityCharges;
    }
    return Charges;
}

defaultproperties
{
    InitialCharges=1
}