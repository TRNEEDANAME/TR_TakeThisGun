//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_TR_TakeThis.uc
//  AUTHOR:  TRNEEDANAME  --  2025/05/09
// DATE MODIFIED : 2025/05/10
//  PURPOSE: Make the "You'll need this" perk, WOTC non LWOTC
//---------------------------------------------------------------------------------------


class X2Ability_TR_TakeThis extends X2Ability config(TR_TakeThis);


// Default ability stuff
var config int TR_TakeThis_APCost; // 1 by default
var config bool TR_TakeThis_ConsumeAllAP; // false by default
var config int TR_TakeThis_Range; // 96 by default

// Charges
var config int TR_TakeThis_ChargesDefault;
var config int TR_TakeThis_ChargeCost;

// Exclude conditions madness
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
    AddChargeCost(Template);
    Template.HideErrors.AddItem('AA_CannotAfford_Charges');
    Template.AddShooterEffectExclusions();
    AddTargetConditions(Template);
    AddShooterAbilityCondition(Template);
    AddTargetWeaponCondition(Template);
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
    Template.AbilityCharges = Charges;
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

