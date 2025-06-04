class X2Ability_TR_TakeThisGun extends X2Ability config(TR_TakeThis);

struct TablePair
{
	var name name;
	var int value;
};

struct OfficerAbilitiesGivePerRank
{
    var int rank;
    var array<name> abilities;
};

struct OfficerAbilitiesGivePerRankRand
{
    var int rank;
	var array<int> RandAbilitiesChance;
    var array<name> abilities;
};

struct AbilityMetaData
{
    var name TemplateName;
    var string Description;
    var string IconPath;
};

struct AbilityActionPointSettings
{
    var int APCost;
    var bool ConsumeAllAP;
    var int Range;
    var name SlotName;
};

struct AbilityStatMods
{
    var int AimChange;
    var int SightChange;
    var int DetectionRadiusChange;
    var int MobilityChange;
    var bool ChangeExtraStats;
    var array<TablePair> ExtraStats;
};

struct AbilityCharge
{
    var int ChargesDefault;
    var name ChargesBonusAbility;
    var int ChargeBonusAmount;
    var int ChargeCost;
    var bool ChargesBonusAllowAbilities;
    var array<TablePair> ChargesBonusAbilities;
};

struct AbilityTargetingConditions
{
    var bool ChangeAbilityUnitCondition;
    var bool ExcludeDead;
    var bool ExcludeHostileToSource;
    var bool ExcludeFriendlyToSource;
    var bool FailOnNonUnits;
    var bool ExcludeAlien;
    var bool ExcludeRobotic;
    var bool RequireWithinRange;
    var bool IsPlayerControlled;
    var bool IsImpaired;
    var bool RequireSquadmates;
    var bool ExcludeNonCivilian;
};

struct AbilityWeaponSpec
{
    var name WeaponName;
    var name WeaponType;
    var name OwnerAbilityToCheck;
    var array<name> StdAbilityToAdd;
    var bool Has5Tier;
    var bool GiveItems;
    var array<name> ItemsToGive;
    var array<name> SlotForItems;
};

struct AbilityRandomAssignment
{
    var bool RandAbilities;
    var int RandAbilitiesChance;
    var array<name> RandAbilitiesToAdd;
};

struct AbilityClassGrant
{
    var bool GrantAbilityToClasses;
    var array<name> Classes;
};

struct AbilityOfficerGrant
{
    var array<OfficerAbilitiesGivePerRank> OfficerAbilitiesGivePerRank;
    var array<OfficerAbilitiesGivePerRankRand> OfficerAbilitiesGivePerRankRand;
};

struct native TR_TakeThisGun_AbilityStruct
{
    var AbilityMetaData Meta;
    var AbilityActionPointSettings ActionPoints;
    var AbilityStatMods Stats;
    var AbilityCharge Charges;
    var AbilityTargetingConditions Targeting;
    var AbilityWeaponSpec WeaponSpec;
    var AbilityRandomAssignment Random;
    var AbilityClassGrant ClassGrant;
    var AbilityOfficerGrant OfficerGrant;

    structdefaultproperties
    {
        Meta=(IconPath="img:///UILibrary_LWOTC.LW_AbilityTakeThis")
    }
};

var config array<TR_TakeThisGun_AbilityStruct> Abilities;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    local TR_TakeThisGun_AbilityStruct AbilityConfig;

	// Just for fun
	// I used Create Immunity abilities as a base
    foreach default.Abilities(AbilityConfig)
    {
        Templates.AddItem(TR_TakeThisGun_Abilities(AbilityConfig));
    }

    return Templates;
}


static function X2AbilityTemplate TR_TakeThisGun_Abilities(TR_TakeThisGun_AbilityStruct AbilityConfig)
{
    local X2AbilityTemplate Template;
    local X2AbilityCost_ActionPoints ActionPointCost;
    local X2AbilityCharges_TR_TakeThisCharge Charges;
    local X2AbilityCost_Charges ChargeCost;
    local X2Condition_UnitProperty UnitPropertyCondition;
    local X2AbilityTarget_Single SingleTarget;
    local X2Condition_AbilityProperty ShooterAbilityCondition;
    local X2Condition_UnitInventory TargetWeaponCondition;
    local X2Effect_TR_TemporaryItem TemporaryItemEffect;
    local X2Effect_PersistentStatChange StatEffect;
    local TablePair StatPair;
    local int i, k;
	local string StatDesc;
	local string StatNameStr;


    `CREATE_X2ABILITY_TEMPLATE(Template, AbilityConfig.Meta.TemplateName);

    Template.IconImage = AbilityConfig.Meta.IconPath;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.bDisplayInUITooltip = false;
    Template.bLimitTargetIcons = true;

    // Target style
    SingleTarget = new class'X2AbilityTarget_Single';
    SingleTarget.bIncludeSelf = false;
    Template.AbilityTargetStyle = SingleTarget;

    // Action Point Cost
    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = AbilityConfig.ActionPoints.APCost;
    ActionPointCost.bConsumeAllPoints = AbilityConfig.ActionPoints.ConsumeAllAP;
    Template.AbilityCosts.AddItem(ActionPointCost);

    // Charges
    Charges = new class'X2AbilityCharges_TR_TakeThisCharge';
    Charges.InitialCharges = AbilityConfig.Charges.ChargesDefault;
    Charges.BonusAbility = AbilityConfig.Charges.ChargesBonusAbility;
    Charges.BonusAbilityCharges = AbilityConfig.Charges.ChargeBonusAmount;
    if (AbilityConfig.Charges.ChargesBonusAllowAbilities)
    {
        foreach AbilityConfig.Charges.ChargesBonusAbilities(StatPair)
        {
            Charges.BonusAbilityCharges += StatPair.value;
        }
    }
    Template.AbilityCharges = Charges;

    // Charge Cost
    ChargeCost = new class'X2AbilityCost_Charges';
    ChargeCost.NumCharges = AbilityConfig.Charges.ChargeCost;
    Template.AbilityCosts.AddItem(ChargeCost);

    Template.HideErrors.AddItem('AA_CannotAfford_Charges');
    Template.AddShooterEffectExclusions();

    // Targeting Conditions
    UnitPropertyCondition = new class'X2Condition_UnitProperty';
    UnitPropertyCondition.ExcludeDead = AbilityConfig.Targeting.ExcludeDead;
    UnitPropertyCondition.ExcludeHostileToSource = AbilityConfig.Targeting.ExcludeHostileToSource;
    UnitPropertyCondition.ExcludeFriendlyToSource = AbilityConfig.Targeting.ExcludeFriendlyToSource;
    UnitPropertyCondition.FailOnNonUnits = AbilityConfig.Targeting.FailOnNonUnits;
    UnitPropertyCondition.ExcludeAlien = AbilityConfig.Targeting.ExcludeAlien;
    UnitPropertyCondition.ExcludeRobotic = AbilityConfig.Targeting.ExcludeRobotic;
    UnitPropertyCondition.RequireWithinRange = AbilityConfig.Targeting.RequireWithinRange;
    UnitPropertyCondition.IsPlayerControlled = AbilityConfig.Targeting.IsPlayerControlled;
    UnitPropertyCondition.IsImpaired = AbilityConfig.Targeting.IsImpaired;
    UnitPropertyCondition.RequireSquadmates = AbilityConfig.Targeting.RequireSquadmates;
    UnitPropertyCondition.ExcludeNonCivilian = AbilityConfig.Targeting.ExcludeNonCivilian;
    UnitPropertyCondition.WithinRange = AbilityConfig.ActionPoints.Range;
    Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

    // Shooter Ability Condition
    ShooterAbilityCondition = new class'X2Condition_AbilityProperty';
    ShooterAbilityCondition.OwnerHasSoldierAbilities.AddItem(AbilityConfig.WeaponSpec.OwnerAbilityToCheck);
    ShooterAbilityCondition.TargetMustBeInValidTiles = false;
    Template.AbilityShooterConditions.AddItem(ShooterAbilityCondition);

    // Target Weapon Condition
    TargetWeaponCondition = new class'X2Condition_UnitInventory';
    TargetWeaponCondition.ExcludeWeaponCategory = AbilityConfig.WeaponSpec.WeaponType;
    TargetWeaponCondition.RelevantSlot = SlotNameToInvSlot(AbilityConfig.ActionPoints.SlotName);
    Template.AbilityTargetConditions.AddItem(TargetWeaponCondition);

    // Temporary Item Effect
    TemporaryItemEffect = new class'X2Effect_TR_TemporaryItem';
    TemporaryItemEffect.EffectName = 'TakeThisEffect';
    TemporaryItemEffect.ItemName = GetWeaponBasedTech(
        none, // You may want to pass the actual ItemState here if available
        AbilityConfig.WeaponSpec.WeaponType,
        AbilityConfig.WeaponSpec.WeaponName,
        AbilityConfig.WeaponSpec.Has5Tier
    );
    TemporaryItemEffect.bIgnoreItemEquipRestrictions = true;
    TemporaryItemEffect.BuildPersistentEffect(1, true, false);
    TemporaryItemEffect.DuplicateResponse = eDupe_Ignore;
    Template.AddTargetEffect(TemporaryItemEffect);

    // Give Items
    if (AbilityConfig.WeaponSpec.GiveItems)
    {
        for (k = 0; k < AbilityConfig.WeaponSpec.ItemsToGive.Length; k++)
        {
            local XComGameState_Item ItemState;
            ItemState = new class'XComGameState_Item';
            ItemState.ItemName = AbilityConfig.WeaponSpec.ItemsToGive[k];
            ItemState.Slot = SlotNameToInvSlot(AbilityConfig.WeaponSpec.SlotForItems[k]);
            TemporaryItemEffect.AddItem(ItemState);
        }
    }

    // Random Abilities
    if (AbilityConfig.Random.RandAbilities)
    {
        RandAbilityEffect = new class'X2Effect_TR_AddRandomAbilities';
        RandAbilityEffect.RandAbilities = AbilityConfig.Random.RandAbilitiesToAdd;
        RandAbilityEffect.ChancePercent = AbilityConfig.Random.RandAbilitiesChance;
        Template.AddTargetEffect(RandAbilityEffect);
    }

    // Grant to Classes
    if (AbilityConfig.ClassGrant.GrantAbilityToClasses)
    {
        local X2CharacterTemplateManager CharMgr;
        local X2CharacterTemplate CharacterTemplate;
        local name ClassName;
        local bool bAlreadyHasAbility;
        local int j;

        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
        for (i = 0; i < AbilityConfig.ClassGrant.Classes.Length; i++)
        {
            ClassName = AbilityConfig.ClassGrant.Classes[i];
            CharacterTemplate = CharMgr.FindCharacterTemplate(ClassName);

            if (CharacterTemplate != none)
            {
                bAlreadyHasAbility = false;
                for (j = 0; j < CharacterTemplate.Abilities.Length; j++)
                {
                    if (CharacterTemplate.Abilities[j] == AbilityConfig.Meta.TemplateName)
                    {
                        bAlreadyHasAbility = true;
                        break;
                    }
                }
                if (!bAlreadyHasAbility)
                {
                    CharacterTemplate.Abilities.AddItem(AbilityConfig.Meta.TemplateName);
                }
            }
            else
            {
                `LOG("TR_TakeThisGun_Abilities ERROR: Could not find class template for " $ ClassName,, 'XCom_Gameplay');
            }
        }
    }

    // Stat Effects
    StatEffect = new class 'X2Effect_PersistentStatChange';
    StatEffect.AddPersistentStatChange(eStat_Offense, AbilityConfig.Stats.AimChange);
    StatEffect.AddPersistentStatChange(eStat_SightRadius, AbilityConfig.Stats.SightChange);
    StatEffect.AddPersistentStatChange(eStat_DetectionRadius, AbilityConfig.Stats.DetectionRadiusChange);
    StatEffect.AddPersistentStatChange(eStat_Mobility, AbilityConfig.Stats.MobilityChange);
    foreach AbilityConfig.Stats.ExtraStats(StatPair)
    {
        StatEffect.AddPersistentStatChange(StatNameToEnum(StatPair.name), StatPair.value);
    }
    StatEffect.BuildPersistentEffect(1, true, false, false);

	// Build a description string for all stat changes
	StatDesc = "";
	if (AbilityConfig.Stats.AimChange != 0)
	{
	    StatDesc $= string(AbilityConfig.Stats.AimChange) $ " " $ class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[eStat_Offense] $ ", ";
	}
	if (AbilityConfig.Stats.SightChange != 0)
	{
	    StatDesc $= string(AbilityConfig.Stats.SightChange) $ " " $ class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[eStat_SightRadius] $ ", ";
	}
	if (AbilityConfig.Stats.DetectionRadiusChange != 0)
	{
	    StatDesc $= string(AbilityConfig.Stats.DetectionRadiusChange) $ " " $ class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[eStat_DetectionRadius] $ ", ";
	}
	if (AbilityConfig.Stats.MobilityChange != 0)
	{
	    StatDesc $= string(AbilityConfig.Stats.MobilityChange) $ " " $ class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[eStat_Mobility] $ ", ";
	}

	// Add extra stats from the array
	foreach AbilityConfig.Stats.ExtraStats(StatPair)
	{
	    StatNameStr = class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[StatNameToEnum(StatPair.name)];
	    StatDesc $= string(StatPair.value) $ " " $ StatNameStr $ ", ";
	}

	// Remove trailing comma and space, if present
	if (Len(StatDesc) >= 2)
	{
	    StatDesc = Left(StatDesc, Len(StatDesc) - 2);
	}

	StatEffect.SetDisplayInfo(
	    ePerkBuff_Passive,
	    StatDesc,
	    Template.GetMyLongDescription(),
	    Template.IconImage,
    	false
	);

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
