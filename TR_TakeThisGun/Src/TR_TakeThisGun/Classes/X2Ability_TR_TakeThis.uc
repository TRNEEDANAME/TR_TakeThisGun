//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_TR_TakeThis.uc
//  AUTHOR:  TRNEEDANAME  --  2025/05/09
// DATE MODIFIED : 2025/05/10
//  PURPOSE: Make the "You'll need this" perk, WOTC non LWOTC
// It devolved into madness fast
//---------------------------------------------------------------------------------------


class X2Ability_TR_TakeThis extends X2Ability config(TR_TakeThis);

// We do a bit of struct as table weirdness
struct TablePair
{
    var name name;
    var int value;
};

// Default ability stuff
var config int TR_TakeThis_APCost; // 1 by default
var config bool TR_TakeThis_ConsumeAllAP; // false by default
var config int TR_TakeThis_Range; // 96 by default
var config bool TR_TakeThis_GrantAbilityToClass;
var config array<name> TR_TakeThis_Classes;

// Charges
var config int TR_TakeThis_ChargesDefault;
var config name TR_TakeThis_ChargesBonusAbility;
var config int TR_TakeThis_ChargesBonusAmount;
var config int TR_TakeThis_ChargeCost;

var config bool TR_TakeThis_ChargesBonusAllowAbilities;
var config array<TablePair> TR_TakeThis_ChargesBonusAbilities;

// Exclude conditions madness
var config bool TR_TakeThis_ChangeAbilityUnitCondition; // false
var config bool TR_TakeThis_ExcludeDead; // true 
var config bool TR_TakeThis_ExcludeHostileToSource; // true
var config bool TR_TakeThis_ExcludeFriendlyToSource; // false
var config bool TR_TakeThis_FailOnNonUnits; // true
var config bool TR_TakeThis_ExcludeAlien; // true
var config bool TR_TakeThis_ExcludeRobotic; // true
var config bool TR_TakeThis_RequireWithinRange; // true
var config bool TR_TakeThis_IsPlayerControlled; // true
var config bool TR_TakeThis_IsImpaired; // false
var config bool TR_TakeThis_RequireSquadmates; // true
var config bool TR_TakeThis_ExcludeNonCivilian; // true

// Gun stat change
var config int TR_TakeThis_AimChange; // 50 by default
var config int TR_TakeThis_SightChange; // 15 by default
var config int TR_TakeThis_DetectionRadiusChange; // 9 by default
var config int TR_TakeThis_MobilityChange; // -1 by default

// Items to give
var config bool TR_TakeThis_GiveItems; // false by default
var config array<name> TR_TakeThis_ItemsToGive; // Empty by default
var config array<name> TR_TakeThis_SlotForItems; // Empty by default

// Extra stats changed
var config bool TR_TakeThis_ChangeExtraStats; // False by default
var config array <TablePair> TR_TakeThis_ExtraStats; // Empty by default

// Random abilities to give
var config bool TR_TakeThis_AddRandomAbilities; // False by default
var config int TR_TakeThis_RandAbilitiesChance; // 50 by default
var config array<name> TR_TakeThis_RandAbilitiesToAdd;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(TR_TakeThis());

    return Templates;
}


static function X2AbilityTemplate TR_TakeThis()
{
    local X2AbilityTemplate Template;
    `CREATE_X2ABILITY_TEMPLATE(Template, 'TR_TakeThis');
    Template.IconImage = "img:///UILibrary_LWOTC.LW_AbilityTakeThis";
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.bDisplayInUITooltip = false;
    Template.bLimitTargetIcons = true;

    Template.AbilityTargetStyle = CreateSingleTarget();
    AddActionPointCost(Template);
    AddCharges(Template);
    AddRandomAbilities(Template);
    AddItemsToGive(Template);
    AddChargeCost(Template);
    Template.HideErrors.AddItem('AA_CannotAfford_Charges');
    Template.AddShooterEffectExclusions();
    AddTargetConditions(Template);
    AddShooterAbilityCondition(Template);
    AddTargetWeaponCondition(Template);
    AddTemporaryItemEffect(Template);
    GrantAbilityToClasses(Template);
    //AddOfficerEffectsIfLWOTC(Template);
    AddStatEffects(Template);

    Template.bShowActivation = true;
    Template.bSkipFireAction = true;
    Template.CustomFireAnim = 'HL_SignalBark';
    Template.ActivationSpeech = 'HoldTheLine';
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    return Template;
}

static function X2AbilityTarget_Single CreateSingleTarget()
{
    local X2AbilityTarget_Single SingleTarget;
    SingleTarget = new class'X2AbilityTarget_Single';
    SingleTarget.bIncludeSelf = false;
    return SingleTarget;
}

static function AddActionPointCost(X2AbilityTemplate Template)
{
    local X2AbilityCost_ActionPoints ActionPointCost;
    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = default.TR_TakeThis_APCost;
    ActionPointCost.bConsumeAllPoints = default.TR_TakeThis_ConsumeAllAP;
    Template.AbilityCosts.AddItem(ActionPointCost);
}

static function AddCharges(X2AbilityTemplate Template)
{
    local X2AbilityCharges_TR_TakeThisCharge Charges;
    local TablePair StatPair;
    Charges = new class'X2AbilityCharges_TR_TakeThisCharge';
    Charges.InitialCharges = default.TR_TakeThis_ChargesDefault;
    Charges.BonusAbility = default.TR_TakeThis_ChargesBonusAbility;
    Charges.BonusAbilityCharges = default.TR_TakeThis_ChargesBonusAmount;
    if (default.TR_TakeThis_ChargesBonusAllowAbilities)
    {
        foreach default.TR_TakeThis_ChargesBonusAbilities(StatPair)
        {
            Charges.BonusAbilityCharges += StatPair.value;
        }
    }
    Template.AbilityCharges = Charges;
}

static function AddRandomAbilities(X2AbilityTemplate Template)
{
    local X2Effect_TR_AddRandomAbilities RandAbilityEffect;
    if (default.TR_TakeThis_AddRandomAbilities)
    {
        RandAbilityEffect = new class'X2Effect_TR_AddRandomAbilities';
        RandAbilityEffect.RandAbilities = default.TR_TakeThis_RandAbilitiesToAdd;
        RandAbilityEffect.ChancePercent = default.TR_TakeThis_RandAbilitiesChance;
        Template.AddTargetEffect(RandAbilityEffect);
    }
}

static function AddItemsToGive(X2AbilityTemplate Template)
{
    local int j;
    local XComGameState_Item ItemState;
    local X2Effect_TR_TemporaryItem TemporaryItemEffect;
    if (default.TR_TakeThis_GiveItems)
    {
        TemporaryItemEffect = new class'X2Effect_TR_TemporaryItem';
        for (j = 0; j < default.TR_TakeThis_ItemsToGive.Length; j++)
        {
            ItemState = new class'XComGameState_Item';
            ItemState.ItemName = default.TR_TakeThis_ItemsToGive[j];
            ItemState.Slot = SlotNameToInvSlot(default.TR_TakeThis_SlotForItems[j]);
            TemporaryItemEffect.AddItem(ItemState);
        }
        Template.AddTargetEffect(TemporaryItemEffect);
    }
}

static function AddChargeCost(X2AbilityTemplate Template)
{
    local X2AbilityCost_Charges ChargeCost;
    ChargeCost = new class'X2AbilityCost_Charges';
    ChargeCost.NumCharges = default.TR_TakeThis_ChargeCost;
    Template.AbilityCosts.AddItem(ChargeCost);
}

static function AddTargetConditions(X2AbilityTemplate Template)
{
    local X2Condition_UnitProperty UnitPropertyCondition;
    UnitPropertyCondition = new class'X2Condition_UnitProperty';
    UnitPropertyCondition.ExcludeDead = default.TR_TakeThis_ExcludeDead;
    UnitPropertyCondition.ExcludeHostileToSource = default.TR_TakeThis_ExcludeHostileToSource;
    UnitPropertyCondition.ExcludeFriendlyToSource = default.TR_TakeThis_ExcludeFriendlyToSource;
    UnitPropertyCondition.FailOnNonUnits = default.TR_TakeThis_FailOnNonUnits;
    UnitPropertyCondition.ExcludeAlien = default.TR_TakeThis_ExcludeAlien;
    UnitPropertyCondition.ExcludeRobotic = default.TR_TakeThis_ExcludeRobotic;
    UnitPropertyCondition.RequireWithinRange = default.TR_TakeThis_RequireWithinRange;
    UnitPropertyCondition.IsPlayerControlled = default.TR_TakeThis_IsPlayerControlled;
    UnitPropertyCondition.IsImpaired = default.TR_TakeThis_IsImpaired;
    UnitPropertyCondition.RequireSquadmates = default.TR_TakeThis_RequireSquadmates;
    UnitPropertyCondition.ExcludeNonCivilian = default.TR_TakeThis_ExcludeNonCivilian;
    UnitPropertyCondition.WithinRange = default.TR_TakeThis_Range;
    Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);
}

static function AddShooterAbilityCondition(X2AbilityTemplate Template)
{
    local X2Condition_AbilityProperty ShooterAbilityCondition;
    ShooterAbilityCondition = new class'X2Condition_AbilityProperty';
    ShooterAbilityCondition.OwnerHasSoldierAbilities.AddItem('PistolStandardShot');
    ShooterAbilityCondition.TargetMustBeInValidTiles = false;
    Template.AbilityShooterConditions.AddItem(ShooterAbilityCondition);
}

static function AddTargetWeaponCondition(X2AbilityTemplate Template)
{
    local X2Condition_UnitInventory TargetWeaponCondition;
    TargetWeaponCondition = new class'X2Condition_UnitInventory';
    TargetWeaponCondition.ExcludeWeaponCategory = 'pistol';
    TargetWeaponCondition.RelevantSlot = eInvSlot_Utility;
    Template.AbilityTargetConditions.AddItem(TargetWeaponCondition);
}

static function AddTemporaryItemEffect(X2AbilityTemplate Template)
{
    local XComGameState_Item ItemState;
    local X2Effect_TR_TemporaryItem TemporaryItemEffect;
    ItemState = none; // Replace with actual logic if needed
    TemporaryItemEffect = new class'X2Effect_TR_TemporaryItem';
    TemporaryItemEffect.EffectName = 'TakeThisEffect';
    TemporaryItemEffect.ItemName = GetWeaponBasedTech(ItemState, 'pistol', 'pistol', true);
    TemporaryItemEffect.bIgnoreItemEquipRestrictions = true;
    TemporaryItemEffect.BuildPersistentEffect(1, true, false);
    TemporaryItemEffect.DuplicateResponse = eDupe_Ignore;
    Template.AddTargetEffect(TemporaryItemEffect);
}

static function GrantAbilityToClasses(X2AbilityTemplate Template)
{
    local X2CharacterTemplateManager CharMgr;
    local X2CharacterTemplate CharacterTemplate;
    local name ClassName;
    local int i;
    if (default.TR_TakeThis_GrantAbilityToClass)
    {
        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
        for (i = 0; i < default.TR_TakeThis_Classes.Length; i++)
        {
            ClassName = default.TR_TakeThis_Classes[i];
            CharacterTemplate = CharMgr.FindCharacterTemplate(ClassName);
            if (CharacterTemplate != none)
            {
                CharacterTemplate.Abilities.AddItem('TR_TakeThis');
            }
        }
    }
}

/*static function AddOfficerEffectsIfLWOTC(X2AbilityTemplate Template)
{
	local int k;
	if (class'Help'.static.IsModActive('LongWarOfTheChosen'))
	{
		// We get current officer
		OfficerRank = 0;
	    local XComGameState_Unit TargetUnit;
		local XComGameState_Unit_LWOfficer OfficerComp;

		OfficerComp = GetOfficerComponent(Unit);
		if (OfficerComp != none)
		{
			OfficerRank = OfficerComp.GetOfficerRank();
		}

		if (AbilityConfig.OfficerGrantAbilities)
		{
			if (AbilityConfig.OfficerGrantAbilitiesRNG && AbilityConfig.OfficerAbilitiesGivePerRankRand.Rank == OfficerRank)
			{
				for (k = 0; k < AbilityConfig.OfficerAbilitiesGivePerRankRand.Length; k++)
				{
					RandAbilityEffect = new class'X2Effect_TR_AddRandomAbilities';
					RandAbilityEffect.RandAbilities = AbilityConfig.OfficerAbilitiesGivePerRankRand[k].abilities;
					RandAbilityEffect.ChancePercent = AbilityConfig.OfficerAbilitiesGivePerRankRand[k].RandAbilitiesChance;
					Template.AddTargetEffect(RandAbilityEffect);
				}
			}

			else if (AbilityConfig.OfficerAbilitiesGivePerRank.Rank == OfficerRank)
			{
				for (k = 0; k < AbilityConfig.OfficerAbilitiesGivePerRank.Length; k++)
				{
					RandAbilityEffect = new class'X2Effect_TR_AddRandomAbilities';
					RandAbilityEffect.RandAbilities = AbilityConfig.OfficerAbilitiesGivePerRank[k].abilities;
					RandAbilityEffect.ChancePercent = 100;
					Template.AddTargetEffect(RandAbilityEffect);
				}
			}
		}
	}
}*/

static function AddStatEffects(X2AbilityTemplate Template)
{
    local X2Effect_PersistentStatChange StatEffect;
    StatEffect = new class 'X2Effect_PersistentStatChange';
    StatEffect.AddPersistentStatChange(eStat_Offense, default.TR_TakeThis_AimChange);
    StatEffect.AddPersistentStatChange(eStat_SightRadius, default.TR_TakeThis_SightChange);
    StatEffect.AddPersistentStatChange(eStat_DetectionRadius, default.TR_TakeThis_DetectionRadiusChange);
    StatEffect.AddPersistentStatChange(eStat_Mobility, default.TR_TakeThis_MobilityChange);
    StatEffect.BuildPersistentEffect(1, true, false, false);
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[eStat_Offense], Template.GetMyLongDescription(), Template.IconImage, false);
    Template.AddTargetEffect(StatEffect);
}

