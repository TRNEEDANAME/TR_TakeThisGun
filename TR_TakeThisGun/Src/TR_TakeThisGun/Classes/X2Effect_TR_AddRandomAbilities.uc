//---------------------------------------------------------------------------------------
//  FILE:    X2Effect_TR_AddRandomAbilities.uc
//  AUTHOR:  TRNEEDANAME  --  2025/05/10
// DATE MODIFIED : 2025/05/10
//  PURPOSE: Random abilities, because you'll take more RNGesus in your life right ?
//---------------------------------------------------------------------------------------

class X2Effect_TR_AddRandomAbilities extends X2Effect;

var array<name> RandAbilities;
var int ChancePercent;

simulated function TR_ApplyEffect(XComGameState_Effect EffectGameState, const out EffectAppliedData AppliedData)
{
	local int i;
	local float RandRoll;
	local XComGameState_Item TargetItem;
	local X2WeaponTemplate WeaponTemplate;

	TargetItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(AppliedData.TargetStateObjectRef.ObjectID));
	if (TargetItem == none)
		return;

	WeaponTemplate = X2WeaponTemplate(TargetItem.GetMyTemplate());
	if (WeaponTemplate == none)
		return;

	// Add abilities with random chance
	for (i = 0; i < RandAbilities.Length; i++)
	{
		RandRoll = `SYNC_RAND(100);
		if (RandRoll < ChancePercent)
		{
			WeaponTemplate.Abilities.AddItem(RandAbilities[i]);
		}
	}
}
