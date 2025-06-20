//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_TR_TakeThis.uc
//  AUTHOR:  TRNEEDANAME  --  2025/05/09
// DATE MODIFIED : 2025/05/20
//  PURPOSE: Make the "You'll need this" perk from LW2 / LWOTC for WOTC
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
    local X2AbilityTemplate                     Template;
    local X2WeaponTemplate                      WeaponTemplate;
    local X2AbilityCost_ActionPoints            ActionPointCost;
    local X2Condition_UnitProperty              UnitPropertyCondition;
    local X2AbilityTarget_Single                SingleTarget;
    local X2AbilityCharges_TR_TakeThisCharge    Charges;
    local X2AbilityCost_Charges                 ChargeCost;
    local X2Condition_UnitInventory             TargetWeaponCondition;
    local X2Effect_TR_TemporaryItem             TemporaryItemEffect;
    local X2Effect_PersistentStatChange         StatEffect;
    local X2Condition_AbilityProperty           ShooterAbilityCondition;
    local NamePair                              StatPair;
    local XComGameState_Item                    ItemState;
    local XComGameState_Ability                 Ability;
    local X2CharacterTemplateManager            CharMgr;
    local X2CharacterTemplate                   CharacterTemplate;
    local X2Effect_TR_AddRandomAbilities        RandAbilityEffect;
    local name                                  ClassName;
    local int                                   i, j, k;
    // LWOTC
    local int                                   OfficerRank;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'TR_TakeThis');
    Template.IconImage = "img:///UILibrary_LWOTC.LW_AbilityTakeThis";
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.bDisplayInUITooltip = false;
    Template.bLimitTargetIcons = true;

    SingleTarget = new class'X2AbilityTarget_Single';
    SingleTarget.bIncludeSelf = false;
    Template.AbilityTargetStyle = SingleTarget;

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

    if (default.TR_TakeThis_ChargesBonusAllowAbilities)
    {
        foreach default.TR_TakeThis_ChargesBonusAbilities(StatPair)
        {
            Charges.BonusAbilityCharges += StatPair.value;
        }
    }
    Template.AbilityCharges = Charges;

    if (default.TR_TakeThis_AddRandomAbilities)
    {
        RandAbilityEffect = new class'X2Effect_TR_AddRandomAbilities';
        RandAbilityEffect.RandAbilities = default.TR_TakeThis_RandAbilitiesToAdd;
        RandAbilityEffect.ChancePercent = default.TR_TakeThis_RandAbilitiesChance;
        Template.AddTargetEffect(RandAbilityEffect);
    }

    // Items to give
    if (default.TR_TakeThis_GiveItems)
    {
        for (j = 0; j < default.TR_TakeThis_ItemsToGive.Length; j++)
        {
            // Add the item
            ItemState = new class'XComGameState_Item';
            ItemState.ItemName = default.TR_TakeThis_ItemsToGive[j];
            ItemState.Slot = SlotNameToInvSlot(default.TR_TakeThis_SlotForItems[j]);
            TemporaryItemEffect.AddItem(ItemState);
        }
    }

    ChargeCost = new class'X2AbilityCost_Charges';
    ChargeCost.NumCharges = default.TR_TakeThis_ChargeCost;
    Template.AbilityCosts.AddItem(ChargeCost);

    Template.HideErrors.AddItem('AA_CannotAfford_Charges');

    Template.AddShooterEffectExclusions();

    UnitPropertyCondition = new class'X2Condition_UnitProperty';

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
    UnitPropertyCondition.IsImpaired = default.TR_TakeThis_IsImpaired; // false
    UnitPropertyCondition.RequireSquadmates = default.TR_TakeThis_RequireSquadmates;
    UnitPropertyCondition.ExcludeNonCivilian = default.TR_TakeThis_ExcludeNonCivilian;
    UnitPropertyCondition.WithinRange = default.TR_TakeThis_Range; // 96 = 1 adjacent tile
    Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

    ShooterAbilityCondition = new class'X2Condition_AbilityProperty';
    ShooterAbilityCondition.OwnerHasSoldierAbilities.AddItem ('PistolStandardShot');
    ShooterAbilityCondition.TargetMustBeInValidTiles = false;
    Template.AbilityShooterConditions.AddItem(ShooterAbilityCondition);

    TargetWeaponCondition = new class 'X2Condition_UnitInventory';
    TargetWeaponCondition.ExcludeWeaponCategory = 'pistol';
    TargetWeaponCondition.RelevantSlot = eInvSlot_Utility;
    Template.AbilityTargetConditions.AddItem (TargetWeaponCondition);

    ItemState = Ability.GetSourceWeapon();

    TemporaryItemEffect = new class'X2Effect_TR_TemporaryItem';
    TemporaryItemEffect.EffectName = 'TakeThisEffect';
    TemporaryItemEffect.ItemName = GetWeaponBasedTech(ItemState, 'pistol', 'pistol', true);
    TemporaryItemEffect.bIgnoreItemEquipRestrictions = true;
    TemporaryItemEffect.BuildPersistentEffect(1, true, false);
    TemporaryItemEffect.DuplicateResponse = eDupe_Ignore;
    Template.AddTargetEffect(TemporaryItemEffect);


static function AddStatEffects(X2AbilityTemplate Template)
{
	local X2AbilityTemplate						Template;
	local X2WeaponTemplate                      WeaponTemplate;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local X2AbilityTarget_Single				SingleTarget;
	local X2AbilityCharges_TR_TakeThisCharge	Charges;
	local X2AbilityCost_Charges					ChargeCost;
	local X2Condition_UnitInventory				TargetWeaponCondition;
	local X2Effect_TR_TemporaryItem				TemporaryItemEffect;
	local X2Effect_PersistentStatChange			StatEffect;
	local X2Effect_TR_AddRandomAbilities        RandAbilityEffect;
	local X2Condition_AbilityProperty			ShooterAbilityCondition;
	local NamePair                              StatPair;
	local XComGameState_Item                    ItemState;
	local XComGameStateContext_Ability          AbilityContext;
	local XComGameStateContext_Ability          Context;
	local X2CharacterTemplateManager            CharMgr;
	local X2CharacterTemplate                   CharacterTemplate;
	local name                                  ClassName;
	local bool                                  bAlreadyHasAbility;
	local int                                   i, j, k;

	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityConfig.TemplateName);

	Template.IconImage = "img:///UILibrary_LWOTC.LW_AbilityTakeThis";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.bDisplayInUITooltip = false;
    Template.bLimitTargetIcons = true;

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.bIncludeSelf = false;
	Template.AbilityTargetStyle = SingleTarget;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = AbilityConfig.APCost;
	ActionPointCost.bConsumeAllPoints = AbilityConfig.ConsumeAllAP;
    Template.AbilityCosts.AddItem(ActionPointCost);

    Charges.InitialCharges = AbilityConfig.ChargesDefault;
    Charges.BonusAbility = AbilityConfig.ChargesBonusAbility;
    Charges.BonusAbilityCharges =  AbilityConfig.ChargeBonusAmount;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = AbilityConfig.ChargeCost;
	Template.AbilityCosts.AddItem(ChargeCost);

	Template.HideErrors.AddItem('AA_CannotAfford_Charges');

	Template.AddShooterEffectExclusions();

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	if(AbilityConfig.ChangeAbilityUnitCondition)
	{
		UnitPropertyCondition.ExcludeDead = AbilityConfig.ExcludeDead;
		UnitPropertyCondition.ExcludeHostileToSource = AbilityConfig.ExcludeHostileToSource;
		UnitPropertyCondition.ExcludeFriendlyToSource = AbilityConfig.ExcludeFriendlyToSource;
		UnitPropertyCondition.FailOnNonUnits = AbilityConfig.FailOnNonUnits;
		UnitPropertyCondition.ExcludeAlien = AbilityConfig.ExcludeAlien;
		UnitPropertyCondition.ExcludeRobotic = AbilityConfig.ExcludeRobotic;
		UnitPropertyCondition.RequireWithinRange = AbilityConfig.RequireWithinRange;
		UnitPropertyCondition.IsPlayerControlled = AbilityConfig.IsPlayerControlled;
		UnitPropertyCondition.IsImpaired = AbilityConfig.IsImpaired; // false
		UnitPropertyCondition.RequireSquadmates = AbilityConfig.RequireSquadmates;
		UnitPropertyCondition.ExcludeNonCivilian = AbilityConfig.ExcludeNonCivilian;
	}
	else
	{
		UnitPropertyCondition.ExcludeDead = true;
		UnitPropertyCondition.ExcludeHostileToSource = true;
		UnitPropertyCondition.ExcludeFriendlyToSource = false;
		UnitPropertyCondition.FailOnNonUnits = true;
		UnitPropertyCondition.ExcludeAlien = true;
		UnitPropertyCondition.ExcludeRobotic = true;
		UnitPropertyCondition.RequireWithinRange = true;
		UnitPropertyCondition.IsPlayerControlled = true;
		UnitPropertyCondition.IsImpaired = false;
		UnitPropertyCondition.RequireSquadmates = true;
		UnitPropertyCondition.ExcludeNonCivilian = true;
	}

	UnitPropertyCondition.WithinRange = AbilityConfig.Range;	// 96 = 1 adjacent tile
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	ShooterAbilityCondition = new class'X2Condition_AbilityProperty';
	ShooterAbilityCondition.OwnerHasSoldierAbilities.AddItem (AbilityConfig.OwnerAbilityToCheck);
	ShooterAbilityCondition.TargetMustBeInValidTiles = false;
	Template.AbilityShooterConditions.AddItem(ShooterAbilityCondition);

	TargetWeaponCondition = new class 'X2Condition_UnitInventory';
	TargetWeaponCondition.ExcludeWeaponCategory = AbilityConfig.WeaponType;
	TargetWeaponCondition.RelevantSlot = SlotNameToInvSlot(AbilityConfig.SlotName);
	Template.AbilityTargetConditions.AddItem (TargetWeaponCondition);

	TemporaryItemEffect = new class'X2Effect_TR_TemporaryItem';
	TemporaryItemEffect.EffectName = 'TakeThisEffect';

	TemporaryItemEffect.ItemName = GetWeaponBasedTech(ItemState, AbilityConfig.WeaponType, AbilityConfig.WeaponName, AbilityConfig.Has5Tier);

	TemporaryItemEffect.bIgnoreItemEquipRestrictions = true;
	TemporaryItemEffect.BuildPersistentEffect(1, true, false);
	TemporaryItemEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect(TemporaryItemEffect);

	// Standard ability to add
	for (i = 0; i < AbilityConfig.StdAbilityToAdd.length; i++)
	{
		WeaponTemplate.Abilities.AddItem(AbilityConfig.StdAbilityToAdd[i]);
	}

	// Give items ?
	if (AbilityConfig.GiveItems)
	{
		for (k = 0; k < AbilityConfig.ItemsToGive.Length; k++)
		{
			// Add the item
			ItemState = new class'XComGameState_Item';
			ItemState.ItemName = AbilityConfig.ItemsToGive[k];
			ItemState.Slot = SlotNameToInvSlot(AbilityConfig.SlotForItems[k]);
			TemporaryItemEffect.AddItem(ItemState);
		}
    }

    // Abilities are added via RNGesus
    if (AbilityConfig.RandAbilities)
    {
        RandAbilityEffect = new class'X2Effect_TR_AddRandomAbilities';
        RandAbilityEffect.RandAbilities = AbilityConfig.RandAbilitiesToAdd;
        RandAbilityEffect.ChancePercent = AbilityConfig.RandAbilitiesChance;
        Template.AddTargetEffect(RandAbilityEffect);
    }

    if (AbilityConfig.GrantAbilityToClasses)
    {
        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

        for (i = 0; i < AbilityConfig.Classes.Length; i++)
        {
            ClassName = AbilityConfig.Classes[i];
            CharacterTemplate = CharMgr.FindCharacterTemplate(ClassName);

            if (CharacterTemplate != none)
            {
                bAlreadyHasAbility = false;

                for (j = 0; j < CharacterTemplate.Abilities.Length; j++)
                {
                    if (CharacterTemplate.Abilities[j] == AbilityConfig.TemplateName)
                    {
                        bAlreadyHasAbility = true;
                        break;
                    }
                }

                if (!bAlreadyHasAbility)
                {
                    CharacterTemplate.Abilities.AddItem(AbilityConfig.TemplateName);
                }
            }
            else
            {
                `LOG("TR_TakeThisGun_Abilities ERROR: Could not find class template for " $ ClassName,, 'XCom_Gameplay');
            }
        }
    }


    StatEffect = new class 'X2Effect_PersistentStatChange';
    StatEffect.AddPersistentStatChange (eStat_Offense, AbilityConfig.AimChange); // 50 by default
    StatEffect.AddPersistentStatChange (eStat_SightRadius, AbilityConfig.SightChange); // 15 by default
    StatEffect.AddPersistentStatChange (eStat_DetectionRadius, AbilityConfig.DetectionRadiusChange); // 9 by default
    StatEffect.AddPersistentStatChange (eStat_Mobility, AbilityConfig.MobilityChange); // -1 by default

    foreach AbilityConfig.ExtraStats(StatPair)
    {
        StatEffect.AddPersistentStatChange(StatNameToEnum(StatPair.name), StatPair.value);
    }

    StatEffect.BuildPersistentEffect (1, true, false, false);
    StatEffect.SetDisplayInfo(ePerkBuff_Passive, class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[eStat_Offense], Template.GetMyLongDescription(), Template.IconImage, false);
    Template.AddTargetEffect(StatEffect);

    Template.bShowActivation = true;
    Template.bSkipFireAction = true;
    Template.CustomFireAnim = 'HL_SignalBark';
    Template.ActivationSpeech = 'HoldTheLine';

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    return Template;
}

static function name GetWeaponBasedTech(XComGameState_Item ItemState, name weaponType, name weaponName, bool has5Tier)
{
    local X2WeaponTemplate WeaponTemplate;
    local name ResultSuffix;
    local string weaponNameStr;
    local string resultStr;

    if (ItemState == none)
    {
        return '';
    }
 
    WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());

    // If weapon category doesn't match, fallback to vanilla logic
    switch (WeaponTemplate.WeaponCat)
    {
        case 'conventional': ResultSuffix = 'CV'; break;
        case 'magnetic': ResultSuffix = '_MG'; break;
        case 'WeaponTech_T3': ResultSuffix = '_T3'; break;
        case 'WeaponTech_T4': ResultSuffix = '_T4'; break;
        case 'beam': ResultSuffix = '_BM'; break;
    }
    // 5TWO only
    else if (class'Help'.static.IsModActive('WOTCIridarWeaponOverhaulVanilla'))
    {
        switch (WeaponTemplate.WeaponCat)
        {
            case 'conventional': ResultSuffix = '_CV'; break;
            case 'magnetic': ResultSuffix = '_MG'; break;
            case 'WeaponTech_T3': ResultSuffix = '_T3'; break;
            case 'WeaponTech_T4': ResultSuffix = '_T4'; break;
            case 'beam': ResultSuffix = '_BM'; break;
        }
    }
    else
    {
        // Vanilla fallback logic again
        switch (WeaponTemplate.WeaponTech)
        {
            case 'conventional': ResultSuffix = '_CV'; break;
            case 'magnetic': ResultSuffix = '_MG'; break;
            case 'beam': ResultSuffix = '_BM'; break;
        }
    }

    // Convert weaponName to string, concatenate, and convert back to name
    weaponNameStr = string(weaponName);
    resultStr = string(ResultSuffix);
    return name(weaponNameStr $ resultStr);
}
static function ECharStatType StatNameToEnum(name StatName)
{
    switch (StatName)
    {
        case 'Mobility': return eStat_Mobility;
        case 'Aim': return eStat_Offense;
        case 'Will': return eStat_Will;
        case 'HP': return eStat_HP;
        case 'Dodge': return eStat_Dodge;
        case 'Defense': return eStat_Defense;
        case 'Hacking': return eStat_Hacking;
        case 'PsiOffense': return eStat_PsiOffense;
        case 'SightRadius': return eStat_SightRadius;
        case 'DetectionRadius': return eStat_DetectionRadius;
        default: return eStat_Invalid; // Failsafe
    }
}

static function EInventorySlot SlotNameToInvSlot(name SlotName)
{
    switch (SlotName)
    {
        case 'Primairy': return eInvSlot_PrimaryWeapon;
        case 'Secondary': return eInvSlot_SecondaryWeapon;
        case 'Tertiary': return eInvSlot_TertiaryWeapon;
        case 'Quaternary': return eInvSlot_QuaternaryWeapon;
        case 'Quinary': return eInvSlot_QuinaryWeapon;
        case 'Senary': return eInvSlot_SenaryWeapon;
        case 'Septenary': return eInvSlot_SeptenaryWeapon;
        case 'Heavy': return eInvSlot_HeavyWeapon;
        default: return eInvSlot_PrimaryWeapon; // in doubt, return primairy slot
    }
}
