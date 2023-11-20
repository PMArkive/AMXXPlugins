#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <orpheu>
#include "../libtfc_const.inc"
#include "../libtfc_player.inc"
#include "../libtfc_misc.inc"
#include "../libtfc_timers.inc"

#define PLUGIN "Lib TFC: Player"
#define VERSION "0.1"
#define AUTHOR "hlstriker"

new OrpheuFunction:g_OrphFunc_TeamFortress_TeamGetNoPlayers;
new OrpheuFunction:g_OrphFunc_TeamFortress_TeamSet;
new OrpheuFunction:g_OrphFunc_TeamFortress_SetSpeed;
new OrpheuFunction:g_OrphFunc_ChangeClass;

new g_iMaxPlayers;
new bool:g_bIsForceChangingTeams;

// This is needed since ResetHud is called right before the player switches teams while they are alive.
// It's also needed to prevent OnDeath from being called when the player joins spectate after connecting.
new bool:g_bIsSpawned[TFC_PLAYER_BUFFER];

// This is needed to call the ChangeTeam forward when the player goes spectate.
new TeamTFC:g_iLastSetTeam[TFC_PLAYER_BUFFER];

new g_iForwardOnSpawn       = -1;
new g_iForwardOnDeath       = -1;
new g_iForwardOnChangeTeam  = -1;
new g_iForwardOnChangeClass = -1;


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("libtfc_player_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	g_iMaxPlayers = get_maxplayers();
	
	g_OrphFunc_TeamFortress_TeamGetNoPlayers = OrpheuGetFunction("TeamFortress_TeamGetNoPlayers");         // sub_3007BA40
	g_OrphFunc_TeamFortress_TeamSet          = OrpheuGetFunction("TeamFortress_TeamSet", "CBasePlayer");   // sub_30046D90
	g_OrphFunc_TeamFortress_SetSpeed         = OrpheuGetFunction("TeamFortress_SetSpeed", "CBasePlayer");  // sub_30046540
	g_OrphFunc_ChangeClass                   = OrpheuGetFunction("ChangeClass", "CBasePlayer");            // sub_30044F60
	
	OrpheuRegisterHook(g_OrphFunc_TeamFortress_TeamSet, "OnOrph_TeamFortress_TeamSet", OrpheuHookPre);
	OrpheuRegisterHook(g_OrphFunc_TeamFortress_TeamGetNoPlayers, "OnOrph_TeamFortress_TeamGetNoPlayers", OrpheuHookPre);
	OrpheuRegisterHook(g_OrphFunc_ChangeClass, "OnOrph_ChangeClass", OrpheuHookPre);

	RegisterHam(Ham_TFC_Killed, "player", "OnKilled_Post", 1);

	register_event("ResetHUD", "Event_ResetHUD_Dead", "bd"); // Use "ResetHUD" instead of "Spectator" to detect when a player goes spec. "Spectator" is called after the flag is dropped.
	register_event("ResetHUD", "Event_ResetHUD_Alive", "be");

	// register_message(get_user_msgid("Spectator"), "msg_Spectator");

	g_iForwardOnSpawn       = CreateMultiForward("LibTFC_Player_OnSpawn", ET_IGNORE, FP_CELL);
	g_iForwardOnDeath       = CreateMultiForward("LibTFC_Player_OnDeath", ET_IGNORE, FP_CELL);
	g_iForwardOnChangeTeam  = CreateMultiForward("LibTFC_Player_OnChangeTeam", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	g_iForwardOnChangeClass = CreateMultiForward("LibTFC_Player_OnChangeClass", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);

	// Make sure we block "fullupdate" so players can't call our ResetHUD hooks at will.
	register_clcmd("fullupdate", "Command_BlockCommand");
}

public plugin_end()
{
	DestroyForward(g_iForwardOnSpawn);
	DestroyForward(g_iForwardOnDeath);
	DestroyForward(g_iForwardOnChangeTeam);
	DestroyForward(g_iForwardOnChangeClass);
}

public plugin_natives()
{
	register_library("libtfc_player");
	
	register_native("LibTFC_Player_IsPlayer", "_LibTFC_Player_IsPlayer");
	register_native("LibTFC_Player_IsAlive", "_LibTFC_Player_IsAlive");

	register_native("LibTFC_Player_SetPlayerClass", "_LibTFC_Player_SetPlayerClass");
	register_native("LibTFC_Player_GetPlayerClass", "_LibTFC_Player_GetPlayerClass");
	
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
	
	register_native("LibTFC_Player_SetHealthValue", "_LibTFC_Player_SetHealthValue");
	register_native("LibTFC_Player_GetHealthValue", "_LibTFC_Player_GetHealthValue");
	
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
	
	register_native("LibTFC_Player_CallSetSpeed", "_LibTFC_Player_CallSetSpeed");
	
	register_native("LibTFC_Player_SetNumFlames", "_LibTFC_Player_SetNumFlames");
	register_native("LibTFC_Player_GetNumFlames", "_LibTFC_Player_GetNumFlames");
	register_native("LibTFC_Player_Ignite", "_LibTFC_Player_Ignite");
	
	register_native("LibTFC_Player_SetDisguised", "_LibTFC_Player_SetDisguised");
	register_native("LibTFC_Player_GetDisguisedAsTeam", "_LibTFC_Player_GetDisguisedAsTeam");
	register_native("LibTFC_Player_GetDisguisedAsClass", "_LibTFC_Player_GetDisguisedAsClass");
	
	register_native("LibTFC_Player_SetDisguisedAsPlayer", "_LibTFC_Player_SetDisguisedAsPlayer");
	register_native("LibTFC_Player_GetDisguisedAsPlayer", "_LibTFC_Player_GetDisguisedAsPlayer");
	
	register_native("LibTFC_Player_SetNextSuicideTime", "_LibTFC_Player_SetNextSuicideTime");
	register_native("LibTFC_Player_GetNextSuicideTime", "_LibTFC_Player_GetNextSuicideTime");
	
	register_native("LibTFC_Player_SetBattleID", "_LibTFC_Player_SetBattleID");
	register_native("LibTFC_Player_GetBattleID", "_LibTFC_Player_GetBattleID");
	
	register_native("LibTFC_Player_SetNumTeamKills", "_LibTFC_Player_SetNumTeamKills");
	register_native("LibTFC_Player_GetNumTeamKills", "_LibTFC_Player_GetNumTeamKills");
}


public bool:_LibTFC_Player_IsPlayer(iPlugin, iParams)
{
	return (1 <= get_param(1) <= g_iMaxPlayers);
}

public bool:_LibTFC_Player_IsAlive(iPlugin, iParams)
{
	return bool:IsAlive(get_param(1));
}

IsAlive(iClient)
{
	if(GetCurrentTeam(iClient) == TFC_TEAM_SPECTATE) {
		return false;
	}

	new iDeadFlag = entity_get_int(iClient, EV_INT_deadflag);
	return (iDeadFlag == TFC_DEAD_NO || iDeadFlag == TFC_DEAD_FEIGNING);
}


public _LibTFC_Player_SetNumTeamKills(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "teamkills", get_param(2));
}

public _LibTFC_Player_GetNumTeamKills(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBaseEntity", "teamkills");
}


public _LibTFC_Player_SetBattleID(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "tf_id", get_param(2));
}

public _LibTFC_Player_GetBattleID(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBaseEntity", "tf_id");
}


public _LibTFC_Player_SetDisguisedAsPlayer(iPlugin, iParams)
{
	new iClient = get_param(1);
	new iTarget = get_param(2);
	LibTFC_Timers_CreateTimer(iClient, TFC_TIMER_FINISH_DISGUISING, 0.0, _:GetCurrentTeam(iTarget), _:GetPlayerClass(iTarget));
	set_ent_data_entity(iClient, "CBaseEntity", "undercover_target", iTarget);
}

public _LibTFC_Player_GetDisguisedAsPlayer(iPlugin, iParams)
{
	return max(0, get_ent_data_entity(get_param(1), "CBaseEntity", "undercover_target"));
}


public _LibTFC_Player_SetDisguised(iPlugin, iParams)
{
	LibTFC_Timers_CreateTimer(get_param(1), TFC_TIMER_FINISH_DISGUISING, 0.0, get_param(2), get_param(3));
}

public TeamTFC:_LibTFC_Player_GetDisguisedAsTeam(iPlugin, iParams)
{
	return TeamTFC:get_ent_data(get_param(1), "CBaseEntity", "undercover_team");
}

public PlayerClassTFC:_LibTFC_Player_GetDisguisedAsClass(iPlugin, iParams)
{
	return PlayerClassTFC:get_ent_data(get_param(1), "CBaseEntity", "undercover_skin");
}


public _LibTFC_Player_SetNumFlames(iPlugin, iParams)
{
	SetNumFlames(get_param(1), get_param(2));
}

SetNumFlames(iClient, iNumFlames)
{
	set_ent_data_float(iClient, "CBaseEntity", "numflames", float(iNumFlames));
}

public _LibTFC_Player_GetNumFlames(iPlugin, iParams)
{
	return floatround(get_ent_data_float(get_param(1), "CBaseEntity", "numflames"));
}

public _LibTFC_Player_Ignite(iPlugin, iParams)
{
	new iClient = get_param(1);
	new iInflictor = get_param(2);
	
	if(get_param(3))
		SetArmorClassMask(iClient, GetArmorClassMask(iClient) & ~TFC_ARMORCLASS_CERAMIC);
	
	ExecuteHam(Ham_TakeDamage, iClient, iInflictor, iInflictor, 0.1, 0x1000000);
}


public _LibTFC_Player_CallSetSpeed(iPlugin, iParams)
{
	CallSetSpeed(get_param(1))
}

CallSetSpeed(iClient)
{
	OrpheuCallSuper(g_OrphFunc_TeamFortress_SetSpeed, iClient);
}


public _LibTFC_Player_SetInfectionTeamNumber(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "infection_team_no", get_param(2));
}

public TeamTFC:_LibTFC_Player_GetInfectionTeamNumber(iPlugin, iParams)
{
	return TeamTFC:get_ent_data(get_param(1), "CBaseEntity", "infection_team_no");
}


public _LibTFC_Player_SetBuildingEntity(iPlugin, iParams)
{
	set_ent_data_entity(get_param(1), "CBaseEntity", "building", max(0, get_param(2)));
}

public _LibTFC_Player_GetBuildingEntity(iPlugin, iParams)
{
	return max(0, get_ent_data_entity(get_param(1), "CBaseEntity", "building"));
}


public _LibTFC_Player_SetLegDamage(iPlugin, iParams)
{
	new iClient = get_param(1);
	new Float:fNewLegDamage = get_param_f(2);
	
	if(fNewLegDamage == GetOldLegDamage(iClient))
		return;
	
	set_ent_data_float(iClient, "CBaseEntity", "leg_damage", fNewLegDamage);
	
	// Set the old leg damage to a value that is not equal to the new leg damage.
	// This will make the game update the player with the leg damage user message.
	set_ent_data_float(iClient, "CBaseEntity", "old_leg_damage", fNewLegDamage + 1.0);
	
	CallSetSpeed(iClient);
}

public Float:_LibTFC_Player_GetLegDamage(iPlugin, iParams)
{
	return get_ent_data_float(get_param(1), "CBaseEntity", "leg_damage");
}

Float:GetOldLegDamage(iClient)
{
	return get_ent_data_float(iClient, "CBaseEntity", "old_leg_damage");
}


public _LibTFC_Player_SetLastMedicCallTime(iPlugin, iParams)
{
	set_ent_data_float(get_param(1), "CBaseEntity", "last_saveme_sound", get_param_f(2));
}

public Float:_LibTFC_Player_GetLastMedicCallTime(iPlugin, iParams)
{
	return get_ent_data_float(get_param(1), "CBaseEntity", "last_saveme_sound");
}


public WeaponTFC:_LibTFC_Player_GetDeployedWeaponID(iPlugin, iParams)
{
	return WeaponTFC:floatround(get_ent_data_float(get_param(1), "CBaseEntity", "current_weapon"));
}


public _LibTFC_Player_SetHasTeleporterExit(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "has_exit_teleporter", get_param(2));
}

public bool:_LibTFC_Player_GetHasTeleporterExit(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "has_exit_teleporter");
}


public _LibTFC_Player_SetHasTeleporterEntrance(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "has_entry_teleporter", get_param(2));
}

public bool:_LibTFC_Player_GetHasTeleporterEntrance(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "has_entry_teleporter");
}


public _LibTFC_Player_SetHasSentry(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "has_sentry", get_param(2));
}

public bool:_LibTFC_Player_GetHasSentry(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "has_sentry");
}


public _LibTFC_Player_SetHasDispenser(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "has_dispenser", get_param(2));
}

public bool:_LibTFC_Player_GetHasDispenser(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "has_dispenser");
}


public _LibTFC_Player_SetRespawnTime(iPlugin, iParams)
{
	SetRespawnTime(get_param(1), get_param_f(2));
}

SetRespawnTime(iClient, Float:fRespawnTime)
{
	set_ent_data_float(iClient, "CBaseEntity", "respawn_time", fRespawnTime);
}

public Float:_LibTFC_Player_GetRespawnTime(iPlugin, iParams)
{
	return Float:get_ent_data_float(get_param(1), "CBaseEntity", "respawn_time");
}


public _LibTFC_Player_SetScore(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "real_frags", get_param(2));
}

public _LibTFC_Player_GetScore(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBaseEntity", "real_frags");
}


public _LibTFC_Player_SetLives(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "lives", get_param(2));
}

public _LibTFC_Player_GetLives(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBaseEntity", "lives");
}


public _LibTFC_Player_SetHealthValue(iPlugin, iParams)
{
	entity_set_float(get_param(1), EV_FL_health, get_param_f(2));
}

public Float:_LibTFC_Player_GetHealthValue(iPlugin, iParams)
{
	return entity_get_float(get_param(1), EV_FL_health);
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
	set_ent_data_float(get_param(1), "CBaseEntity", "maxarmor", get_param_f(2));
}

public Float:_LibTFC_Player_GetArmorValueMax(iPlugin, iParams)
{
	return get_ent_data_float(get_param(1), "CBaseEntity", "maxarmor");
}


public bool:_LibTFC_Player_SetAmmoBackpackMax(iPlugin, iParams)
{
	new iClient = get_param(1);
	new AmmoTypeTFC:ammoType = AmmoTypeTFC:get_param(2);
	new iAmount = get_param(3);
	
	switch(ammoType)
	{
		case TFC_AMMOTYPE_SHELLS:	set_ent_data(iClient, "CBaseEntity", "maxammo_shells", iAmount);
		case TFC_AMMOTYPE_NAILS:	set_ent_data(iClient, "CBaseEntity", "maxammo_nails", iAmount);
		case TFC_AMMOTYPE_CELLS:	set_ent_data(iClient, "CBaseEntity", "maxammo_cells", iAmount);
		case TFC_AMMOTYPE_ROCKETS:	set_ent_data(iClient, "CBaseEntity", "maxammo_rockets", iAmount);
		case TFC_AMMOTYPE_DETPACKS:	set_ent_data(iClient, "CBaseEntity", "maxammo_detpack", iAmount);
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
		case TFC_AMMOTYPE_SHELLS:	return get_ent_data(iClient, "CBaseEntity", "maxammo_shells");
		case TFC_AMMOTYPE_NAILS:	return get_ent_data(iClient, "CBaseEntity", "maxammo_nails");
		case TFC_AMMOTYPE_CELLS:	return get_ent_data(iClient, "CBaseEntity", "maxammo_cells");
		case TFC_AMMOTYPE_ROCKETS:	return get_ent_data(iClient, "CBaseEntity", "maxammo_rockets");
		case TFC_AMMOTYPE_DETPACKS:	return get_ent_data(iClient, "CBaseEntity", "maxammo_detpack");
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
		case TFC_AMMOTYPE_SHELLS:	set_ent_data(iClient, "CBaseEntity", "ammo_shells", iAmount);
		case TFC_AMMOTYPE_NAILS:	set_ent_data(iClient, "CBaseEntity", "ammo_nails", iAmount);
		case TFC_AMMOTYPE_CELLS:	set_ent_data(iClient, "CBaseEntity", "ammo_cells", iAmount);
		case TFC_AMMOTYPE_ROCKETS:	set_ent_data(iClient, "CBaseEntity", "ammo_rockets", iAmount);
		case TFC_AMMOTYPE_DETPACKS:	set_ent_data(iClient, "CBaseEntity", "ammo_detpack", iAmount);
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
		case TFC_AMMOTYPE_SHELLS:	return get_ent_data(iClient, "CBaseEntity", "ammo_shells");
		case TFC_AMMOTYPE_NAILS:	return get_ent_data(iClient, "CBaseEntity", "ammo_nails");
		case TFC_AMMOTYPE_CELLS:	return get_ent_data(iClient, "CBaseEntity", "ammo_cells");
		case TFC_AMMOTYPE_ROCKETS:	return get_ent_data(iClient, "CBaseEntity", "ammo_rockets");
		case TFC_AMMOTYPE_DETPACKS:	return get_ent_data(iClient, "CBaseEntity", "ammo_detpack");
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
	set_ent_data(get_param(1), "CBaseEntity", "items", get_param(2));
}

public _LibTFC_Player_GetItemsMask(iPlugin, iParams)
{
	return GetItemsMask(get_param(1));
}

GetItemsMask(iClient)
{
	return get_ent_data(iClient, "CBaseEntity", "items");
}


public _LibTFC_Player_SetRemovePrimedGrenade(iPlugin, iParams)
{
	SetRemovePrimedGrenade(get_param(1), bool:get_param(2));
}

SetRemovePrimedGrenade(iClient, bool:bShouldRemove)
{
	set_ent_data(iClient, "CBaseEntity", "bRemoveGrenade", bShouldRemove);
}

public bool:_LibTFC_Player_IsRemovingPrimedGrenade(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "bRemoveGrenade");
}


public _LibTFC_Player_SetGrenadePrimedSlot(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "m_iPrimedGrenType", get_param(2));
}

public _LibTFC_Player_GetGrenadePrimedSlot(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBaseEntity", "m_iPrimedGrenType");
}


public _LibTFC_Player_SetStateMask(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "tfstate", get_param(2));
}

public _LibTFC_Player_GetStateMask(iPlugin, iParams)
{
	return GetStateMask(get_param(1));
}

GetStateMask(iClient)
{
	return get_ent_data(iClient, "CBaseEntity", "tfstate");
}


public _LibTFC_Player_SetUnableToSpyOrTeleport(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "is_unableto_spy_or_teleport", get_param(2));
}

public bool:_LibTFC_Player_GetUnableToSpyOrTeleport(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "is_unableto_spy_or_teleport");
}


public _LibTFC_Player_SetIsFeigning(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "is_feigning", get_param(2));
}

public bool:_LibTFC_Player_GetIsFeigning(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "is_feigning");
}


public _LibTFC_Player_SetIsSettingDetpack(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "is_detpacking", get_param(2));
}

public bool:_LibTFC_Player_GetIsSettingDetpack(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "is_detpacking");
}


public _LibTFC_Player_SetIsBuilding(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "is_building", get_param(2));
}

public bool:_LibTFC_Player_GetIsBuilding(iPlugin, iParams)
{
	return bool:get_ent_data(get_param(1), "CBaseEntity", "is_building");
}


public _LibTFC_Player_SetDisguiseType(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "is_undercover", get_param(2));
}

public DisguiseTFC:_LibTFC_Player_GetDisguiseType(iPlugin, iParams)
{
	return DisguiseTFC:get_ent_data(get_param(1), "CBaseEntity", "is_undercover");
}


public bool:_LibTFC_Player_SetGrenadeType(iPlugin, iParams)
{
	new iClient = get_param(1);
	new GrenadeSlotTFC:grenadeSlot = GrenadeSlotTFC:get_param(2);
	new GrenadeTypeTFC:grenadeType = GrenadeTypeTFC:get_param(3);
	
	switch(grenadeSlot)
	{
		case TFC_GRENADESLOT_PRIMARY:	set_ent_data(iClient, "CBaseEntity", "tp_grenades_1", _:grenadeType);
		case TFC_GRENADESLOT_SECONDARY:	set_ent_data(iClient, "CBaseEntity", "tp_grenades_2", _:grenadeType);
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
		case TFC_GRENADESLOT_PRIMARY:	return GrenadeTypeTFC:get_ent_data(iClient, "CBaseEntity", "tp_grenades_1");
		case TFC_GRENADESLOT_SECONDARY:	return GrenadeTypeTFC:get_ent_data(iClient, "CBaseEntity", "tp_grenades_2");
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
		case TFC_GRENADESLOT_PRIMARY:	set_ent_data(iClient, "CBaseEntity", "no_grenades_1", iAmount);
		case TFC_GRENADESLOT_SECONDARY:	set_ent_data(iClient, "CBaseEntity", "no_grenades_2", iAmount);
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
		case TFC_GRENADESLOT_PRIMARY:	return get_ent_data(iClient, "CBaseEntity", "no_grenades_1");
		case TFC_GRENADESLOT_SECONDARY:	return get_ent_data(iClient, "CBaseEntity", "no_grenades_2");
	}
	
	return 0;
}


public _LibTFC_Player_SetArmorClassMask(iPlugin, iParams)
{
	SetArmorClassMask(get_param(1), get_param(2));
}

public SetArmorClassMask(iClient, iArmorClassMask)
{
	set_ent_data(iClient, "CBaseEntity", "armorclass", iArmorClassMask);
}

public _LibTFC_Player_GetArmorClassMask(iPlugin, iParams)
{
	GetArmorClassMask(get_param(1));
}

GetArmorClassMask(iClient)
{
	return get_ent_data(iClient, "CBaseEntity", "armorclass");
}


public _LibTFC_Player_SetPlayerClassLast(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "lastpc", get_param(2));
}

public _LibTFC_Player_GetPlayerClassLast(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBaseEntity", "lastpc");
}


public _LibTFC_Player_SetPlayerClassNext(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBaseEntity", "nextpc", get_param(2));
}

public _LibTFC_Player_GetPlayerClassNext(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBaseEntity", "nextpc");
}


public _LibTFC_Player_SetNextSuicideTime(iPlugin, iParams)
{
	SetNextSuicideTime(get_param(1), get_param_f(2));
}

SetNextSuicideTime(iClient, Float:fNextSuicideTime)
{
	set_ent_data_float(iClient, "CBasePlayer", "m_fNextSuicideTime", fNextSuicideTime);
}

public Float:_LibTFC_Player_GetNextSuicideTime(iPlugin, iParams)
{
	return get_ent_data_float(get_param(1), "CBasePlayer", "m_fNextSuicideTime");
}


public _LibTFC_Player_SetNextTeamOrClassChange(iPlugin, iParams)
{
	SetNextTeamOrClassChange(get_param(1), get_param_f(2));
}

SetNextTeamOrClassChange(iClient, Float:fNextTeamOrClassChangeTime)
{
	set_ent_data_float(iClient, "CBasePlayer", "m_fNextTeamOrClassChange", fNextTeamOrClassChangeTime);
}

public Float:_LibTFC_Player_GetNextTeamOrClassChange(iPlugin, iParams)
{
	return get_ent_data_float(get_param(1), "CBasePlayer", "m_fNextTeamOrClassChange");
}


public OrpheuHookReturn:OnOrph_TeamFortress_TeamSet(iClient, TeamTFC:iNewTeam)
{
	new TeamTFC:iOldTeam = GetCurrentTeam(iClient); // This will be their old team at this point.
	if(iOldTeam == iNewTeam)
		return OrpheuIgnored;

	OnChangeTeam(iClient, iNewTeam, iOldTeam);
	return OrpheuIgnored;
}

OnChangeTeam(iClient, TeamTFC:iNewTeam, TeamTFC:iOldTeam)
{
	g_iLastSetTeam[iClient] = iNewTeam;
	Forward_OnChangeTeam(iClient, iNewTeam, iOldTeam);
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
	new bool:bSuccess = bool:OrpheuCallSuper(g_OrphFunc_TeamFortress_TeamSet, iClient, _:newTeam);
	g_bIsForceChangingTeams = false;
	
	return bSuccess;
}

TeamTFC:GetCurrentTeam(iClient)
{
	return TeamTFC:get_ent_data(iClient, "CBaseEntity", "team_no");
}


public bool:_LibTFC_Player_SetPlayerClass(iPlugin, iParams)
{
	new iClient = get_param(1);
	SetNextTeamOrClassChange(iClient, 0.0);
	SetNextSuicideTime(iClient, 0.0);
	OrpheuCallSuper(g_OrphFunc_ChangeClass, iClient, get_param(2));
	
	if(get_param(3))
		SetRespawnTime(iClient, 0.0);
}

public PlayerClassTFC:_LibTFC_Player_GetPlayerClass(iPlugin, iParams)
{
	return GetPlayerClass(get_param(1));
}

PlayerClassTFC:GetPlayerClass(iClient)
{
	return PlayerClassTFC:entity_get_int(iClient, EV_INT_playerclass);
}


public Command_BlockCommand(iClient)
{
	return PLUGIN_HANDLED;
}

public Event_ResetHUD_Alive(iClient)
{
	// Use this for when the player is fully alive. Using Ham_Spawn pre and post is unreliable.
	OnSpawn(iClient);
}

OnSpawn(iClient)
{
	if(!IsAlive(iClient))
	{
		return;
	}

	// If the player was already spawned, they couldn't have spawned again.
	// TODO: Respawning by other means should be handled separately.
	if(g_bIsSpawned[iClient]) {
		return;
	}

	g_bIsSpawned[iClient] = true;
	Forward_OnSpawn(iClient);
}

public OnKilled_Post(iClient)
{
	// At this point the player is fully dead. Don't use the DeathMsg event to hook death.
	OnDeath(iClient);
}

public Event_ResetHUD_Dead(iClient)
{
	if(g_iLastSetTeam[iClient] != TFC_TEAM_SPECTATE) {
		new TeamTFC:iOldTeam = g_iLastSetTeam[iClient];
		g_iLastSetTeam[iClient] = TFC_TEAM_SPECTATE;
		Forward_OnChangeTeam(iClient, TFC_TEAM_SPECTATE, iOldTeam);
	}

	// Detecting death from going spectator.
	OnDeath(iClient);
}

OnDeath(iClient)
{
	// If the player was never spawned, they couldn't have died.
	if(!g_bIsSpawned[iClient]) {
		return;
	}

	g_bIsSpawned[iClient] = false;
	Forward_OnDeath(iClient);
}

public client_disconnected(iClient, bool:drop, message[], maxlen)
{
	g_bIsSpawned[iClient] = false;
	g_iLastSetTeam[iClient] = TFC_TEAM_SPECTATE;
}

public OrpheuHookReturn:OnOrph_ChangeClass(iClient, iNewClass)
{
	new iOldClass = _:GetPlayerClass(iClient); // This will be their old class at this point.
	if(iOldClass == iNewClass)
		return OrpheuIgnored;

	OnChangeClass(iClient, iNewClass, iOldClass);
	return OrpheuIgnored;
}

OnChangeClass(iClient, iNewClass, iOldClass)
{
	Forward_OnChangeClass(iClient, iNewClass, iOldClass);
}

Forward_OnSpawn(iClient)
{
	static iReturn;
	ExecuteForward(g_iForwardOnSpawn, iReturn, iClient)
}

Forward_OnDeath(iClient)
{
	static iReturn;
	ExecuteForward(g_iForwardOnDeath, iReturn, iClient)
}

Forward_OnChangeTeam(iClient, TeamTFC:iNewTeam, TeamTFC:iOldTeam)
{
	static iReturn;
	ExecuteForward(g_iForwardOnChangeTeam, iReturn, iClient, _:iNewTeam, _:iOldTeam)
}

Forward_OnChangeClass(iClient, iNewClass, iOldClass)
{
	static iReturn;
	ExecuteForward(g_iForwardOnChangeClass, iReturn, iClient, iNewClass, iOldClass)
}
