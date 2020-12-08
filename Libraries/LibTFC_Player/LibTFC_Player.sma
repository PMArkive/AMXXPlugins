#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <orpheu>
#include "../libtfc_const"
#include "../libtfc_player"
#include "../libtfc_misc"

#define PLUGIN "Lib TFC: Player"
#define VERSION "0.1"
#define AUTHOR "hlstriker"



new OrpheuFunction:g_OrphFunc_TeamFortress_TeamGetNoPlayers;
new OrpheuFunction:g_OrphFunc_TeamFortress_TeamSet;


new bool:g_bIsForceChangingTeams;


new g_iClientOffsetDiff_Linux = 3;
new g_iClientOffsetDiff_Mac = 3;

new g_iClientOffset_PlayerClassNext = 8;
new g_iClientOffset_PlayerClassLast = 9;
new g_iClientOffset_ArmorClass = 11;
new g_iClientOffset_GrenadesPrimaryAmount = 14;
new g_iClientOffset_GrenadesSecondaryAmount = 15;
new g_iClientOffset_GrenadesPrimaryType = 16;
new g_iClientOffset_GrenadesSecondaryType = 17;
new g_iClientOffset_DisguiseType = 22;
new g_iClientOffset_IsBuilding = 23;
new g_iClientOffset_IsSettingDetpack = 24;
new g_iClientOffset_IsFeigning = 25;
new g_iClientOffset_IsUnableToSpyOrTeleport = 26;
new g_iClientOffset_RemovePrimedGrenade = 29;
new g_iClientOffset_TFState = 35;
new g_iClientOffset_Items = 36;
new g_iClientOffset_GrenadePrimedSlot = 38;
new g_iClientOffset_CurAmmoShells = 53;
new g_iClientOffset_MaxAmmoShells = 50;
new g_iClientOffset_CurAmmoNails = 55;
new g_iClientOffset_MaxAmmoNails = 54;
new g_iClientOffset_CurAmmoCells = 57;
new g_iClientOffset_MaxAmmoCells = 56;
new g_iClientOffset_CurAmmoRockets = 59;
new g_iClientOffset_MaxAmmoRockets = 58;
new g_iClientOffset_CurAmmoDetpacks = 51;
new g_iClientOffset_MaxAmmoDetpacks = 52;
new g_iClientOffset_ArmorValueMax = 62;
new g_iClientOffset_CurrentTeamNumber = 74;
new g_iClientOffset_Lives = 75;
new g_iClientOffset_InfectionTeamNumber = 76;
new g_iClientOffset_Score = 77;

new g_iClientOffset_RespawnTime = 78;

new g_iClientOffset_BuildingEntity = 80;

new g_iClientOffset_HasDispenser = 85;
new g_iClientOffset_HasSentry = 86;
new g_iClientOffset_HasTeleportEntry = 87;
new g_iClientOffset_HasTeleportExit = 88;


new g_iClientOffset_CurrentWeapon = 90;


new g_iClientOffset_LastSaveMeSound = 104;


new g_iClientOffset_LegDamage = 108;
new g_iClientOffset_OldLegDamage = 112;




new g_iClientOffset_NextTeamOrClassChange = 457;



public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("libtfc_player_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	
	g_OrphFunc_TeamFortress_TeamGetNoPlayers = OrpheuGetFunction("TeamFortress_TeamGetNoPlayers");	// sub_3007BA40
	g_OrphFunc_TeamFortress_TeamSet = OrpheuGetFunction("TeamFortress_TeamSet", "CBasePlayer");	// sub_30046D90
	
	OrpheuRegisterHook(g_OrphFunc_TeamFortress_TeamGetNoPlayers, "OnOrph_TeamFortress_TeamGetNoPlayers", OrpheuHookPre);
}

public plugin_natives()
{
	register_library("libtfc_player");
	
	register_native("LibTFC_Player_SetPlayerClassNext", "_LibTFC_Player_SetPlayerClassNext");
	register_native("LibTFC_Player_GetPlayerClassNext", "_LibTFC_Player_GetPlayerClassNext");
	
	register_native("LibTFC_Player_SetPlayerClassLast", "_LibTFC_Player_SetPlayerClassLast");
	register_native("LibTFC_Player_GetPlayerClassLast", "_LibTFC_Player_GetPlayerClassLast");
	
	register_native("LibTFC_Player_SetArmorClassMask", "_LibTFC_Player_SetArmorClassMask");
	register_native("LibTFC_Player_GetArmorClassMask", "_LibTFC_Player_GetArmorClassMask");
	
	register_native("LibTFC_Player_SetGrenadeAmount", "_LibTFC_Player_SetGrenadeAmount");
	register_native("LibTFC_Player_GetGrenadeAmount", "_LibTFC_Player_GetGrenadeAmount");
	
	register_native("LibTFC_Player_GetGrenadeAmountMaxForType", "_LibTFC_Player_GetGrenadeAmountMaxForType");
	register_native("LibTFC_Player_SetGrenadeType", "_LibTFC_Player_SetGrenadeType");
	register_native("LibTFC_Player_GetGrenadeType", "_LibTFC_Player_GetGrenadeType");
	
	register_native("LibTFC_Player_SetDisguiseType", "_LibTFC_Player_SetDisguiseType");
	register_native("LibTFC_Player_GetDisguiseType", "_LibTFC_Player_GetDisguiseType");
	
	register_native("LibTFC_Player_SetIsBuilding", "_LibTFC_Player_SetIsBuilding");
	register_native("LibTFC_Player_GetIsBuilding", "_LibTFC_Player_GetIsBuilding");
	
	register_native("LibTFC_Player_SetIsSettingDetpack", "_LibTFC_Player_SetIsSettingDetpack");
	register_native("LibTFC_Player_GetIsSettingDetpack", "_LibTFC_Player_GetIsSettingDetpack");
	
	register_native("LibTFC_Player_SetIsFeigning", "_LibTFC_Player_SetIsFeigning");
	register_native("LibTFC_Player_GetIsFeigning", "_LibTFC_Player_GetIsFeigning");
	
	register_native("LibTFC_Player_SetUnableToSpyOrTeleport", "_LibTFC_Player_SetUnableToSpyOrTeleport");
	register_native("LibTFC_Player_GetUnableToSpyOrTeleport", "_LibTFC_Player_GetUnableToSpyOrTeleport");
	
	register_native("LibTFC_Player_SetStateMask", "_LibTFC_Player_SetStateMask");
	register_native("LibTFC_Player_GetStateMask", "_LibTFC_Player_GetStateMask");
	
	register_native("LibTFC_Player_SetGrenadePrimedSlot", "_LibTFC_Player_SetGrenadePrimedSlot");
	register_native("LibTFC_Player_GetGrenadePrimedSlot", "_LibTFC_Player_GetGrenadePrimedSlot");
	
	register_native("LibTFC_Player_SetRemovePrimedGrenade", "_LibTFC_Player_SetRemovePrimedGrenade");
	register_native("LibTFC_Player_IsRemovingPrimedGrenade", "_LibTFC_Player_IsRemovingPrimedGrenade");
	
	register_native("LibTFC_Player_SetItemsMask", "_LibTFC_Player_SetItemsMask");
	register_native("LibTFC_Player_GetItemsMask", "_LibTFC_Player_GetItemsMask");
	
	register_native("LibTFC_Player_SetArmorType", "_LibTFC_Player_SetArmorType");
	register_native("LibTFC_Player_GetArmorType", "_LibTFC_Player_GetArmorType");
	register_native("LibTFC_Player_GetArmorTypeAbsorptionPercent", "_LibTFC_Player_GetArmorTypeAbsorptionPercent");
	
	register_native("LibTFC_Player_SetAmmoBackpack", "_LibTFC_Player_SetAmmoBackpack");
	register_native("LibTFC_Player_GetAmmoBackpack", "_LibTFC_Player_GetAmmoBackpack");
	
	register_native("LibTFC_Player_SetAmmoBackpackMax", "_LibTFC_Player_SetAmmoBackpackMax");
	register_native("LibTFC_Player_GetAmmoBackpackMax", "_LibTFC_Player_GetAmmoBackpackMax");
	
	register_native("LibTFC_Player_SetArmorValueMax", "_LibTFC_Player_SetArmorValueMax");
	register_native("LibTFC_Player_GetArmorValueMax", "_LibTFC_Player_GetArmorValueMax");
	
	register_native("LibTFC_Player_SetArmorValue", "_LibTFC_Player_SetArmorValue");
	register_native("LibTFC_Player_GetArmorValue", "_LibTFC_Player_GetArmorValue");
	
	register_native("LibTFC_Player_ChangeTeam", "_LibTFC_Player_ChangeTeam");
	register_native("LibTFC_Player_GetTeam", "_LibTFC_Player_GetTeam");
	
	register_native("LibTFC_Player_SetNextTeamOrClassChange", "_LibTFC_Player_SetNextTeamOrClassChange");
	register_native("LibTFC_Player_GetNextTeamOrClassChange", "_LibTFC_Player_GetNextTeamOrClassChange");
	
	register_native("LibTFC_Player_SetLives", "_LibTFC_Player_SetLives");
	register_native("LibTFC_Player_GetLives", "_LibTFC_Player_GetLives");
	
	register_native("LibTFC_Player_SetScore", "_LibTFC_Player_SetScore");
	register_native("LibTFC_Player_GetScore", "_LibTFC_Player_GetScore");
	
	register_native("LibTFC_Player_SetRespawnTime", "_LibTFC_Player_SetRespawnTime");
	register_native("LibTFC_Player_GetRespawnTime", "_LibTFC_Player_GetRespawnTime");
	
	register_native("LibTFC_Player_SetHasDispenser", "_LibTFC_Player_SetHasDispenser");
	register_native("LibTFC_Player_GetHasDispenser", "_LibTFC_Player_GetHasDispenser");
	
	register_native("LibTFC_Player_SetHasSentry", "_LibTFC_Player_SetHasSentry");
	register_native("LibTFC_Player_GetHasSentry", "_LibTFC_Player_GetHasSentry");
	
	register_native("LibTFC_Player_SetHasTeleporterEntrance", "_LibTFC_Player_SetHasTeleporterEntrance");
	register_native("LibTFC_Player_GetHasTeleporterEntrance", "_LibTFC_Player_GetHasTeleporterEntrance");
	
	register_native("LibTFC_Player_SetHasTeleporterExit", "_LibTFC_Player_SetHasTeleporterExit");
	register_native("LibTFC_Player_GetHasTeleporterExit", "_LibTFC_Player_GetHasTeleporterExit");
	
	register_native("LibTFC_Player_GetDeployedWeaponID", "_LibTFC_Player_GetDeployedWeaponID");
	
	register_native("LibTFC_Player_SetLastMedicCallTime", "_LibTFC_Player_SetLastMedicCallTime");
	register_native("LibTFC_Player_GetLastMedicCallTime", "_LibTFC_Player_GetLastMedicCallTime");
	
	register_native("LibTFC_Player_SetLegDamage", "_LibTFC_Player_SetLegDamage");
	register_native("LibTFC_Player_GetLegDamage", "_LibTFC_Player_GetLegDamage");
	
	register_native("LibTFC_Player_SetBuildingEntity", "_LibTFC_Player_SetBuildingEntity");
	register_native("LibTFC_Player_GetBuildingEntity", "_LibTFC_Player_GetBuildingEntity");
	
	register_native("LibTFC_Player_SetInfectionTeamNumber", "_LibTFC_Player_SetInfectionTeamNumber");
	register_native("LibTFC_Player_GetInfectionTeamNumber", "_LibTFC_Player_GetInfectionTeamNumber");
}



public _LibTFC_Player_SetInfectionTeamNumber(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_InfectionTeamNumber, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public TeamTFC:_LibTFC_Player_GetInfectionTeamNumber(iPlugin, iParams)
{
	return TeamTFC:get_pdata_int(get_param(1), g_iClientOffset_InfectionTeamNumber, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetBuildingEntity(iPlugin, iParams)
{
	set_pdata_ehandle(get_param(1), g_iClientOffset_BuildingEntity * 4, max(0, get_param(2)), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetBuildingEntity(iPlugin, iParams)
{
	return max(0, get_pdata_ehandle(get_param(1), g_iClientOffset_BuildingEntity * 4, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac));
}


public _LibTFC_Player_SetLegDamage(iPlugin, iParams)
{
	new iClient = get_param(1);
	new Float:fNewLegDamage = get_param_f(2);
	
	if(fNewLegDamage == GetOldLegDamage(iClient))
		return;
	
	set_pdata_float(iClient, g_iClientOffset_LegDamage, fNewLegDamage, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
	
	// Set the old leg damage to a value that is not equal to the new leg damage.
	// This will make the game update the player with the leg damage user message.
	set_pdata_float(iClient, g_iClientOffset_OldLegDamage, fNewLegDamage + 1.0, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public Float:_LibTFC_Player_GetLegDamage(iPlugin, iParams)
{
	return Float:get_pdata_float(get_param(1), g_iClientOffset_LegDamage, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

Float:GetOldLegDamage(iClient)
{
	return Float:get_pdata_float(iClient, g_iClientOffset_OldLegDamage, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetLastMedicCallTime(iPlugin, iParams)
{
	set_pdata_float(get_param(1), g_iClientOffset_LastSaveMeSound, get_param_f(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public Float:_LibTFC_Player_GetLastMedicCallTime(iPlugin, iParams)
{
	return Float:get_pdata_float(get_param(1), g_iClientOffset_LastSaveMeSound, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public WeaponTFC:_LibTFC_Player_GetDeployedWeaponID(iPlugin, iParams)
{
	return WeaponTFC:floatround(get_pdata_float(get_param(1), g_iClientOffset_CurrentWeapon, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac));
}


public _LibTFC_Player_SetHasTeleporterExit(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_HasTeleportExit, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_GetHasTeleporterExit(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_HasTeleportExit, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetHasTeleporterEntrance(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_HasTeleportEntry, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_GetHasTeleporterEntrance(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_HasTeleportEntry, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetHasSentry(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_HasSentry, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_GetHasSentry(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_HasSentry, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetHasDispenser(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_HasDispenser, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_GetHasDispenser(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_HasDispenser, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetRespawnTime(iPlugin, iParams)
{
	set_pdata_float(get_param(1), g_iClientOffset_RespawnTime, get_param_f(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public Float:_LibTFC_Player_GetRespawnTime(iPlugin, iParams)
{
	return Float:get_pdata_float(get_param(1), g_iClientOffset_RespawnTime, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetScore(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_Score, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetScore(iPlugin, iParams)
{
	return get_pdata_int(get_param(1), g_iClientOffset_Score, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetLives(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_Lives, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetLives(iPlugin, iParams)
{
	return get_pdata_int(get_param(1), g_iClientOffset_Lives, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetArmorValue(iPlugin, iParams)
{
	entity_set_float(get_param(1), EV_FL_armorvalue, get_param_f(2));
}

public Float:_LibTFC_Player_GetArmorValue(iPlugin, iParams)
{
	return entity_get_float(get_param(1), EV_FL_armorvalue);
}


public _LibTFC_Player_SetArmorValueMax(iPlugin, iParams)
{
	set_pdata_float(get_param(1), g_iClientOffset_ArmorValueMax, get_param_f(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public Float:_LibTFC_Player_GetArmorValueMax(iPlugin, iParams)
{
	return Float:get_pdata_float(get_param(1), g_iClientOffset_ArmorValueMax, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public bool:_LibTFC_Player_SetAmmoBackpackMax(iPlugin, iParams)
{
	new iClient = get_param(1);
	new AmmoTypeTFC:ammoType = AmmoTypeTFC:get_param(2);
	new iAmount = get_param(3);
	
	switch(ammoType)
	{
		case TFC_AMMOTYPE_SHELLS:	set_pdata_int(iClient, g_iClientOffset_MaxAmmoShells, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_NAILS:	set_pdata_int(iClient, g_iClientOffset_MaxAmmoNails, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_CELLS:	set_pdata_int(iClient, g_iClientOffset_MaxAmmoCells, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_ROCKETS:	set_pdata_int(iClient, g_iClientOffset_MaxAmmoRockets, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_DETPACKS:	set_pdata_int(iClient, g_iClientOffset_MaxAmmoDetpacks, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		default: return false;
	}
	
	return true;
}

public _LibTFC_Player_GetAmmoBackpackMax(iPlugin, iParams)
{
	new iClient = get_param(1);
	new AmmoTypeTFC:ammoType = AmmoTypeTFC:get_param(2);
	
	switch(ammoType)
	{
		case TFC_AMMOTYPE_SHELLS:	return get_pdata_int(iClient, g_iClientOffset_MaxAmmoShells, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_NAILS:	return get_pdata_int(iClient, g_iClientOffset_MaxAmmoNails, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_CELLS:	return get_pdata_int(iClient, g_iClientOffset_MaxAmmoCells, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_ROCKETS:	return get_pdata_int(iClient, g_iClientOffset_MaxAmmoRockets, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_DETPACKS:	return get_pdata_int(iClient, g_iClientOffset_MaxAmmoDetpacks, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
	}
	
	return 0;
}


public bool:_LibTFC_Player_SetAmmoBackpack(iPlugin, iParams)
{
	new iClient = get_param(1);
	new AmmoTypeTFC:ammoType = AmmoTypeTFC:get_param(2);
	new iAmount = get_param(3);
	
	switch(ammoType)
	{
		case TFC_AMMOTYPE_SHELLS:	set_pdata_int(iClient, g_iClientOffset_CurAmmoShells, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_NAILS:	set_pdata_int(iClient, g_iClientOffset_CurAmmoNails, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_CELLS:	set_pdata_int(iClient, g_iClientOffset_CurAmmoCells, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_ROCKETS:	set_pdata_int(iClient, g_iClientOffset_CurAmmoRockets, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_DETPACKS:	set_pdata_int(iClient, g_iClientOffset_CurAmmoDetpacks, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		default: return false;
	}
	
	return true;
}

public _LibTFC_Player_GetAmmoBackpack(iPlugin, iParams)
{
	new iClient = get_param(1);
	new AmmoTypeTFC:ammoType = AmmoTypeTFC:get_param(2);
	
	switch(ammoType)
	{
		case TFC_AMMOTYPE_SHELLS:	return get_pdata_int(iClient, g_iClientOffset_CurAmmoShells, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_NAILS:	return get_pdata_int(iClient, g_iClientOffset_CurAmmoNails, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_CELLS:	return get_pdata_int(iClient, g_iClientOffset_CurAmmoCells, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_ROCKETS:	return get_pdata_int(iClient, g_iClientOffset_CurAmmoRockets, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_AMMOTYPE_DETPACKS:	return get_pdata_int(iClient, g_iClientOffset_CurAmmoDetpacks, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
	}
	
	return 0;
}


public bool:_LibTFC_Player_SetArmorType(iPlugin, iParams)
{
	new iClient = get_param(1);
	new ArmorTypeTFC:armorType = ArmorTypeTFC:get_param(2);
	
	switch(armorType)
	{
		case TFC_ARMORTYPE_NONE:	SetArmorTypeAbsorptionPercent(iClient, TFC_ARMORTYPEABSORB_NONE);
		case TFC_ARMORTYPE_LIGHT:	SetArmorTypeAbsorptionPercent(iClient, TFC_ARMORTYPEABSORB_LIGHT);
		case TFC_ARMORTYPE_MEDIUM:	SetArmorTypeAbsorptionPercent(iClient, TFC_ARMORTYPEABSORB_MEDIUM);
		case TFC_ARMORTYPE_HEAVY:	SetArmorTypeAbsorptionPercent(iClient, TFC_ARMORTYPEABSORB_HEAVY);
		case TFC_ARMORTYPE_CUSTOM:	SetArmorTypeAbsorptionPercent(iClient, get_param_f(3));
		default: return false;
	}
	
	return true;
}

public ArmorTypeTFC:_LibTFC_Player_GetArmorType(iPlugin, iParams)
{
	new iClient = get_param(1);
	new Float:fAbsorptionPercent = GetArmorTypeAbsorptionPercent(iClient);
	
	switch(fAbsorptionPercent)
	{
		case TFC_ARMORTYPEABSORB_NONE:		return TFC_ARMORTYPE_NONE;
		case TFC_ARMORTYPEABSORB_LIGHT:		return TFC_ARMORTYPE_LIGHT;
		case TFC_ARMORTYPEABSORB_MEDIUM:	return TFC_ARMORTYPE_MEDIUM;
		case TFC_ARMORTYPEABSORB_HEAVY:		return TFC_ARMORTYPE_HEAVY;
	}
	
	return TFC_ARMORTYPE_CUSTOM;
}

public Float:_LibTFC_Player_GetArmorTypeAbsorptionPercent(iPlugin, iParams)
{
	return GetArmorTypeAbsorptionPercent(get_param(1));
}

SetArmorTypeAbsorptionPercent(iClient, Float:fPercent)
{
	entity_set_float(iClient, EV_FL_armortype, fPercent);
}

Float:GetArmorTypeAbsorptionPercent(iClient)
{
	return Float:entity_get_float(iClient, EV_FL_armortype);
}


public _LibTFC_Player_SetItemsMask(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_Items, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetItemsMask(iPlugin, iParams)
{
	return GetItemsMask(get_param(1));
}

GetItemsMask(iClient)
{
	return get_pdata_int(iClient, g_iClientOffset_Items, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetRemovePrimedGrenade(iPlugin, iParams)
{
	SetRemovePrimedGrenade(get_param(1), bool:get_param(2));
}

SetRemovePrimedGrenade(iClient, bool:bShouldRemove)
{
	set_pdata_int(iClient, g_iClientOffset_RemovePrimedGrenade, bShouldRemove, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_IsRemovingPrimedGrenade(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_RemovePrimedGrenade, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetGrenadePrimedSlot(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_GrenadePrimedSlot, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetGrenadePrimedSlot(iPlugin, iParams)
{
	return get_pdata_int(get_param(1), g_iClientOffset_GrenadePrimedSlot, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetStateMask(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_TFState, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetStateMask(iPlugin, iParams)
{
	return GetStateMask(get_param(1));
}

GetStateMask(iClient)
{
	return get_pdata_int(iClient, g_iClientOffset_TFState, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetUnableToSpyOrTeleport(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_IsUnableToSpyOrTeleport, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_GetUnableToSpyOrTeleport(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_IsUnableToSpyOrTeleport, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetIsFeigning(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_IsFeigning, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_GetIsFeigning(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_IsFeigning, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetIsSettingDetpack(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_IsSettingDetpack, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_GetIsSettingDetpack(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_IsSettingDetpack, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetIsBuilding(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_IsBuilding, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public bool:_LibTFC_Player_GetIsBuilding(iPlugin, iParams)
{
	return bool:get_pdata_int(get_param(1), g_iClientOffset_IsBuilding, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetDisguiseType(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_DisguiseType, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public DisguiseTFC:_LibTFC_Player_GetDisguiseType(iPlugin, iParams)
{
	return DisguiseTFC:get_pdata_int(get_param(1), g_iClientOffset_DisguiseType, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public bool:_LibTFC_Player_SetGrenadeType(iPlugin, iParams)
{
	new iClient = get_param(1);
	new GrenadeSlotTFC:grenadeSlot = GrenadeSlotTFC:get_param(2);
	new GrenadeTypeTFC:grenadeType = GrenadeTypeTFC:get_param(3);
	
	switch(grenadeSlot)
	{
		case TFC_GRENADESLOT_PRIMARY:	set_pdata_int(iClient, g_iClientOffset_GrenadesPrimaryType, _:grenadeType, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_GRENADESLOT_SECONDARY:	set_pdata_int(iClient, g_iClientOffset_GrenadesSecondaryType, _:grenadeType, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		default: return false;
	}
	
	return true;
}

public GrenadeTypeTFC:_LibTFC_Player_GetGrenadeType(iPlugin, iParams)
{
	new iClient = get_param(1);
	new GrenadeSlotTFC:grenadeSlot = GrenadeSlotTFC:get_param(2);
	
	switch(grenadeSlot)
	{
		case TFC_GRENADESLOT_PRIMARY:	return GrenadeTypeTFC:get_pdata_int(iClient, g_iClientOffset_GrenadesPrimaryType, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_GRENADESLOT_SECONDARY:	return GrenadeTypeTFC:get_pdata_int(iClient, g_iClientOffset_GrenadesSecondaryType, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
	}
	
	return TFC_GRENTYPE_NONE;
}

public _LibTFC_Player_GetGrenadeAmountMaxForType(iPlugin, iParams)
{
	new GrenadeTypeTFC:grenadeType = GrenadeTypeTFC:get_param(1);
	
	switch(grenadeType)
	{
		case TFC_GRENTYPE_NAIL:			return 2;
		case TFC_GRENTYPE_MIRV:			return 2;
		case TFC_GRENTYPE_CONCUSSION:	return 3;
		case TFC_GRENTYPE_CALTROP:		return 3;
	}
	
	return 4;
}


public bool:_LibTFC_Player_SetGrenadeAmount(iPlugin, iParams)
{
	new iClient = get_param(1);
	new GrenadeSlotTFC:grenadeSlot = GrenadeSlotTFC:get_param(2);
	new iAmount = get_param(3);
	
	switch(grenadeSlot)
	{
		case TFC_GRENADESLOT_PRIMARY:	set_pdata_int(iClient, g_iClientOffset_GrenadesPrimaryAmount, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_GRENADESLOT_SECONDARY:	set_pdata_int(iClient, g_iClientOffset_GrenadesSecondaryAmount, iAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		default: return false;
	}
	
	return true;
}

public _LibTFC_Player_GetGrenadeAmount(iPlugin, iParams)
{
	new iClient = get_param(1);
	new GrenadeSlotTFC:grenadeSlot = GrenadeSlotTFC:get_param(2);
	
	switch(grenadeSlot)
	{
		case TFC_GRENADESLOT_PRIMARY:	return get_pdata_int(iClient, g_iClientOffset_GrenadesPrimaryAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
		case TFC_GRENADESLOT_SECONDARY:	return get_pdata_int(iClient, g_iClientOffset_GrenadesSecondaryAmount, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
	}
	
	return 0;
}


public _LibTFC_Player_SetArmorClassMask(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_ArmorClass, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetArmorClassMask(iPlugin, iParams)
{
	return get_pdata_int(get_param(1), g_iClientOffset_ArmorClass, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetPlayerClassLast(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_PlayerClassLast, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetPlayerClassLast(iPlugin, iParams)
{
	return get_pdata_int(get_param(1), g_iClientOffset_PlayerClassLast, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetPlayerClassNext(iPlugin, iParams)
{
	set_pdata_int(get_param(1), g_iClientOffset_PlayerClassNext, get_param(2), g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public _LibTFC_Player_GetPlayerClassNext(iPlugin, iParams)
{
	return get_pdata_int(get_param(1), g_iClientOffset_PlayerClassNext, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public _LibTFC_Player_SetNextTeamOrClassChange(iPlugin, iParams)
{
	SetNextTeamOrClassChange(get_param(1), get_param_f(2));
}

SetNextTeamOrClassChange(iClient, Float:fNextTeamOrClassChangeTime)
{
	set_pdata_float(iClient, g_iClientOffset_NextTeamOrClassChange, fNextTeamOrClassChangeTime, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}

public Float:_LibTFC_Player_GetNextTeamOrClassChange(iPlugin, iParams)
{
	return Float:get_pdata_float(get_param(1), g_iClientOffset_NextTeamOrClassChange, g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}


public OrpheuHookReturn:OnOrph_TeamFortress_TeamGetNoPlayers(iTeam)
{
	// If we are force changing the player we need to return 0 players on the team.
	// This way the full team check in TeamFortress_TeamSet doesn't trigger.
	if(g_bIsForceChangingTeams)
	{
		OrpheuSetReturn(0);
		return OrpheuOverride;
	}
	
	return OrpheuIgnored;
}

public bool:_LibTFC_Player_ChangeTeam(iPlugin, iParams)
{
	return ChangeTeam(get_param(1), TeamTFC:get_param(2));
}

public TeamTFC:_LibTFC_Player_GetTeam(iPlugin, iParams)
{
	return GetCurrentTeam(get_param(1));
}

bool:ChangeTeam(iClient, TeamTFC:newTeam)
{
	// Make sure deadflag isn't 1 (DEAD_DYING). Otherwise TeamFortress_TeamSet will fail.
	if(entity_get_int(iClient, EV_INT_deadflag) == DEAD_DYING)
		entity_set_int(iClient, EV_INT_deadflag, DEAD_DEAD);
	
	// Make sure we are able to change teams at this time.
	SetNextTeamOrClassChange(iClient, 0.0);
	
	// Try change team.
	g_bIsForceChangingTeams = true;
	new bool:bSuccess = bool:OrpheuCall(g_OrphFunc_TeamFortress_TeamSet, iClient, _:newTeam);
	g_bIsForceChangingTeams = false;
	
	return bSuccess;
}

TeamTFC:GetCurrentTeam(iClient)
{
	return TeamTFC:get_pdata_int(iClient, g_iClientOffset_CurrentTeamNumber , g_iClientOffsetDiff_Linux, g_iClientOffsetDiff_Mac);
}
