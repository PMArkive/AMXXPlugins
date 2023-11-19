#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <orpheu>
#include <orpheu_advanced>
#include "../libtfc_const.inc"
#include "../libtfc_timers.inc"
#include "../libtfc_player.inc"

#define PLUGIN "Lib TFC: Timers"
#define VERSION "0.1"
#define AUTHOR "hlstriker"

new OrpheuFunction:g_OrphFunc_Timer_AutoKickReset;
new OrpheuFunction:g_OrphFunc_Timer_Infection;
new OrpheuFunction:g_OrphFunc_Timer_Hallucination;
new OrpheuFunction:g_OrphFunc_Timer_Tranquilisation;
new OrpheuFunction:g_OrphFunc_Timer_HealthRot;
new OrpheuFunction:g_OrphFunc_Timer_Regeneration;
new OrpheuFunction:g_OrphFunc_Timer_DetpackSet;
new OrpheuFunction:g_OrphFunc_Timer_FinishedBuilding;
new OrpheuFunction:g_OrphFunc_Timer_SpyUndercoverThink;
new OrpheuFunction:g_OrphFunc_Timer_DispenserRefillPlayer;
new OrpheuFunction:g_OrphFunc_Timer_ReturnItem;
new OrpheuFunction:g_OrphFunc_Timer_DelayedResult;
new OrpheuFunction:g_OrphFunc_Timer_EndRoundEnd;
new OrpheuFunction:g_OrphFunc_Timer_Birthday;

new OrpheuFunction:g_OrphFunc_CDispenserRefillThinker__Spawn;

new bool:g_bInDispenserTouchHook;
new g_iCreatedEntityDuringDispenserTouchHook;


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("libtfc_timers_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	
	g_OrphFunc_Timer_AutoKickReset			= OrpheuGetFunction("Timer_AutokickThink", "CBaseEntity");
	g_OrphFunc_Timer_Infection				= OrpheuGetFunction("Timer_Infection", "CBaseEntity");
	g_OrphFunc_Timer_Hallucination			= OrpheuGetFunction("Timer_Hallucination", "CBaseEntity");
	g_OrphFunc_Timer_Tranquilisation		= OrpheuGetFunction("Timer_Tranquilisation", "CBaseEntity");
	g_OrphFunc_Timer_HealthRot				= OrpheuGetFunction("Timer_HealthRot", "CBaseEntity");
	g_OrphFunc_Timer_Regeneration			= OrpheuGetFunction("Timer_Regeneration", "CBaseEntity");
	g_OrphFunc_Timer_DetpackSet				= OrpheuGetFunction("Timer_DetpackSet", "CBaseEntity");
	g_OrphFunc_Timer_FinishedBuilding		= OrpheuGetFunction("Timer_FinishedBuilding", "CBaseEntity");
	g_OrphFunc_Timer_SpyUndercoverThink		= OrpheuGetFunction("Timer_SpyUndercoverThink", "CBaseEntity");
	g_OrphFunc_Timer_DispenserRefillPlayer	= OrpheuGetFunction("Timer_DispenserRefillPlayer", "CDispenserRefillThinker");
	g_OrphFunc_Timer_ReturnItem				= OrpheuGetFunction("Timer_ReturnItem", "CBaseEntity");
	g_OrphFunc_Timer_DelayedResult			= OrpheuGetFunction("Timer_DelayedResult", "CBaseEntity");
	g_OrphFunc_Timer_EndRoundEnd			= OrpheuGetFunction("Timer_EndRoundEnd", "CBaseEntity");
	g_OrphFunc_Timer_Birthday				= OrpheuGetFunction("Timer_Birthday", "CBaseEntity");
	
	g_OrphFunc_CDispenserRefillThinker__Spawn = OrpheuGetFunction("Spawn", "CDispenserRefillThinker");
	
	register_forward(FM_CreateEntity, "fwd_CreateEntity_Post", 1);
	RegisterHam(Ham_Touch, "building_dispenser", "OnTouch_DispenserTouch_Pre");
	RegisterHam(Ham_Touch, "building_dispenser", "OnTouch_DispenserTouch_Post", 1);
}

public plugin_natives()
{
	register_library("libtfc_timers");
	
	register_native("LibTFC_Timers_FindTimer", "_LibTFC_Timers_FindTimer");
	register_native("LibTFC_Timers_CreateTimer", "_LibTFC_Timers_CreateTimer");
}


public _LibTFC_Timers_FindTimer(iPlugin, iParams)
{
	new iTimerOwner = get_param(1);
	new TimerTypeTFC:timerType = TimerTypeTFC:get_param(2);
	new iStartEnt = get_param(3);
	
	new iTimer1 = 0;
	if(timerType == TFC_TIMER_NONE || timerType == TFC_TIMER_TK_AUTO_KICK_RESET)
	{
		iTimer1 = FindTimer(iTimerOwner, timerType, "ak_timer", iStartEnt);
	}
	
	new iTimer2 = 0;
	if(timerType == TFC_TIMER_NONE || timerType != TFC_TIMER_TK_AUTO_KICK_RESET)
	{
		iTimer2 = FindTimer(iTimerOwner, timerType, "timer", iStartEnt);
	}
	
	// Return the timer with the lowest index.
	if(iTimer1 && iTimer2)
	{
		return min(iTimer1, iTimer2);
	}
	else if(iTimer1)
	{
		return iTimer1;
	}
	else if(iTimer2)
	{
		return iTimer2;
	}
	
	return 0;
}

FindTimer(iOwner, TimerTypeTFC:timerType, const szTimerClassName[], iStartEnt)
{
	new iTimer = iStartEnt;
	while((iTimer = find_ent_by_class(iTimer, szTimerClassName)) != 0)
	{
		if(timerType != TFC_TIMER_NONE && timerType != GetTimerType(iTimer))
			continue;
		
		if(iOwner != -1 && iOwner != entity_get_edict2(iTimer, EV_ENT_owner))
			continue;
		
		return iTimer;
	}
	
	return 0;
}

TimerTypeTFC:GetTimerType(iEnt)
{
	return TimerTypeTFC:get_ent_data(iEnt, "CBaseEntity", "timer_type");
}


public _LibTFC_Timers_CreateTimer(iPlugin, iParams)
{
	new iTimerOwner = get_param(1);
	new TimerTypeTFC:timerType = TimerTypeTFC:get_param(2);
	new Float:fInitialThinkDelay = get_param_f(3);
	
	if(fInitialThinkDelay < 0.0)
	{
		// Set default values.
		switch(timerType)
		{
			case TFC_TIMER_TK_AUTO_KICK_RESET:	fInitialThinkDelay = 180.0;	// TODO: tfc_autokick_time cvar value
			case TFC_TIMER_INFECTION:			fInitialThinkDelay = 2.0;
			case TFC_TIMER_HALLUCINATION:		fInitialThinkDelay = 0.3;
			case TFC_TIMER_TRANQ_END:			fInitialThinkDelay = 15.0;
			case TFC_TIMER_HEALTH_ROT:			fInitialThinkDelay = 5.0;
			case TFC_TIMER_HEALTH_REGEN:		fInitialThinkDelay = 3.0;
			case TFC_TIMER_SET_DETPACK:			fInitialThinkDelay = 3.0;
			case TFC_TIMER_FINISHED_BUILDING:	fInitialThinkDelay = 5.0;	// TODO: (sentry: 5.0) (teleports: 4.0) (dispenser: 2.0)
			case TFC_TIMER_FINISH_DISGUISING:	fInitialThinkDelay = 4.0;	// TODO: 4.0 to disguise as team already disguised as. 8.0 to disguise as other team
			case TFC_TIMER_DISPENSER_REFILL:	fInitialThinkDelay = 0.2;
			case TFC_TIMER_ITEM_TFGOAL_RETURN:	fInitialThinkDelay = 0.1;	// TODO: 0.1 or 0.5 depending on what activates the timer
			case TFC_TIMER_TFGOAL_DO_RESULTS:	fInitialThinkDelay = 1.0;	// TODO: iTimerOwner->delay_time
			case TFC_TIMER_ENDROUND_END:		fInitialThinkDelay = 1.0;	// TODO: iTimerOwner->m_flEndRoundTime
			case TFC_TIMER_BIRTHDAY:			fInitialThinkDelay = 60.0;
		}
	}
	
	new iTimer = CreateTimerTFC(iTimerOwner, timerType, fInitialThinkDelay);
	if(!iTimer)
		return 0;
	
	switch(timerType)
	{
		case TFC_TIMER_INFECTION:			InitInfection(iTimer, iTimerOwner, get_param(4));
		case TFC_TIMER_HALLUCINATION:		InitHallucination(iTimer, iTimerOwner, float(get_param(4)));
		case TFC_TIMER_TRANQ_END:			InitTranqEnd(iTimer, iTimerOwner);
		case TFC_TIMER_HEALTH_ROT:			InitHealthRot(iTimer, iTimerOwner, get_param(4));
		case TFC_TIMER_SET_DETPACK:			InitSetDetpack(iTimer, iTimerOwner, float(get_param(4)), bool:get_param(5));
		case TFC_TIMER_FINISHED_BUILDING:	InitFinishedBuilding(iTimerOwner, get_param(4), bool:get_param(5));
		case TFC_TIMER_FINISH_DISGUISING:	InitFinishDisguising(iTimer, iTimerOwner, get_param(4), get_param(5));
		case TFC_TIMER_DISPENSER_REFILL:	InitDispenserRefill(iTimer, iTimerOwner, get_param(4));
		case TFC_TIMER_ITEM_TFGOAL_RETURN:	InitItemTFGoalReturn(iTimer, get_param(4));
		case TFC_TIMER_TFGOAL_DO_RESULTS:	InitTFGoalDoResults(iTimer, get_param(4), get_param(5));
	}
	
	return iTimer;
}

InitTFGoalDoResults(iTimer, iActivatingPlayer, iShouldAddBonuses)
{
	entity_set_edict(iTimer, EV_ENT_enemy, iActivatingPlayer);
	set_ent_data(iTimer, "CBaseEntity", "weapon", iShouldAddBonuses);
}

InitItemTFGoalReturn(iTimer, iUnknown)
{
	set_ent_data(iTimer, "CBaseEntity", "weapon", iUnknown);
}

InitDispenserRefill(iTimer, iDispenserEntity, iPlayerToRefill)
{
	set_ent_data_entity(iTimer, "CDispenserRefillThinker", "m_hDispenser", iDispenserEntity);
	set_ent_data_entity(iTimer, "CDispenserRefillThinker", "m_hPlayer", iPlayerToRefill);
	
	new Float:fOrigin[3];
	entity_get_vector(iPlayerToRefill, EV_VEC_origin, fOrigin);
	set_ent_data_vector(iTimer, "CDispenserRefillThinker", "m_InitialUsePoint", fOrigin);
}

InitFinishDisguising(iTimer, iPlayerDisguising, iTeamToDisguiseAs, iClassToDisguiseAs)
{
	LibTFC_Player_SetDisguiseType(iPlayerDisguising, TFC_DISGUISE_DISGUISING);
	set_ent_data(iTimer, "CBaseEntity", "team_no", iTeamToDisguiseAs);
	entity_set_int(iTimer, EV_INT_skin, iClassToDisguiseAs);
}

InitFinishedBuilding(iBuildingPlayer, iEntityBeingBuilt, bool:bShouldFreezePlayer)
{
	LibTFC_Player_SetBuildingEntity(iBuildingPlayer, iEntityBeingBuilt);
	
	if(bShouldFreezePlayer)
	{
		LibTFC_Player_SetIsBuilding(iBuildingPlayer, true);
		LibTFC_Player_SetStateMask(iBuildingPlayer, LibTFC_Player_GetStateMask(iBuildingPlayer) | TFC_STATE_CANT_MOVE);
		LibTFC_Player_CallSetSpeed(iBuildingPlayer);
	}
}

InitSetDetpack(iTimer, iPlayerSettingDetpack, Float:fSecondsBeforeExplosion, bool:bShouldFreezePlayer)
{
	entity_set_float(iTimer, EV_FL_health, fSecondsBeforeExplosion);
	
	if(bShouldFreezePlayer)
	{
		LibTFC_Player_SetIsSettingDetpack(iPlayerSettingDetpack, true);
		LibTFC_Player_SetStateMask(iPlayerSettingDetpack, LibTFC_Player_GetStateMask(iPlayerSettingDetpack) | TFC_STATE_CANT_MOVE);
		LibTFC_Player_CallSetSpeed(iPlayerSettingDetpack);
	}
}

InitHealthRot(iTimer, iRotPlayer, iEntityToRespawnOnRotEnd)
{
	LibTFC_Player_SetItemsMask(iRotPlayer, LibTFC_Player_GetItemsMask(iRotPlayer) | TFC_ITEM_SUPERHEALTH);
	entity_set_edict(iTimer, EV_ENT_enemy, iEntityToRespawnOnRotEnd);
}

InitTranqEnd(iTimer, iTranqedPlayer)
{
	LibTFC_Player_SetStateMask(iTranqedPlayer, LibTFC_Player_GetStateMask(iTranqedPlayer) | TFC_STATE_TRANQUILISED);
	
	set_ent_data(iTimer, "CBaseEntity", "team_no", _:((LibTFC_Player_GetTeam(iTranqedPlayer) == TFC_TEAM_BLUE) ? TFC_TEAM_RED : TFC_TEAM_BLUE));
	LibTFC_Player_CallSetSpeed(iTranqedPlayer);
}

InitHallucination(iTimer, iHallucPlayer, Float:fSecondsForHallucToLast)
{
	fSecondsForHallucToLast = fSecondsForHallucToLast * 2.5 / 0.3;
	
	LibTFC_Player_SetStateMask(iHallucPlayer, LibTFC_Player_GetStateMask(iHallucPlayer) | TFC_STATE_HALLUCINATING);
	entity_set_float(iTimer, EV_FL_health, fSecondsForHallucToLast);
	set_ent_data(iTimer, "CBaseEntity", "team_no", _:LibTFC_Player_GetTeam(iHallucPlayer));
}

InitInfection(iTimer, iInfectedPlayer, iInfecterPlayer)
{
	entity_set_edict(iTimer, EV_ENT_enemy, iInfecterPlayer);
	LibTFC_Player_SetStateMask(iInfectedPlayer, LibTFC_Player_GetStateMask(iInfectedPlayer) | TFC_STATE_INFECTED);
	
	if(iInfecterPlayer)
		LibTFC_Player_SetInfectionTeamNumber(iInfectedPlayer, LibTFC_Player_GetTeam(iInfecterPlayer));
}

CreateTimerTFC(iTimerOwner, TimerTypeTFC:timerType, Float:fInitialThinkDelay)
{
	new address = 0;
	switch(timerType)
	{
		case TFC_TIMER_TK_AUTO_KICK_RESET:		address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_AutoKickReset);
		case TFC_TIMER_INFECTION:				address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_Infection);
		case TFC_TIMER_HALLUCINATION:			address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_Hallucination);
		case TFC_TIMER_TRANQ_END:				address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_Tranquilisation);
		case TFC_TIMER_HEALTH_ROT:				address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_HealthRot);
		case TFC_TIMER_HEALTH_REGEN:			address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_Regeneration);
		case TFC_TIMER_SET_DETPACK:				address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_DetpackSet);
		case TFC_TIMER_FINISHED_BUILDING:		address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_FinishedBuilding);
		case TFC_TIMER_FINISH_DISGUISING:		address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_SpyUndercoverThink);
		case TFC_TIMER_DISPENSER_REFILL:		address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_DispenserRefillPlayer);
		case TFC_TIMER_ITEM_TFGOAL_RETURN:		address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_ReturnItem);
		case TFC_TIMER_TFGOAL_DO_RESULTS:		address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_DelayedResult);
		case TFC_TIMER_ENDROUND_END:			address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_EndRoundEnd);
		case TFC_TIMER_BIRTHDAY:				address = OrpheuGetFunctionAddress(g_OrphFunc_Timer_Birthday);
		default:								address = 0;
	}
	
	if(address <= 0)
		return 0;
	
	new szClassName[9];
	switch(timerType)
	{
		case TFC_TIMER_TK_AUTO_KICK_RESET:	copy(szClassName, charsmax(szClassName), "timer");	// thought it was "ak_timer" but maybe it's just "timer" as well.
		default:							copy(szClassName, charsmax(szClassName), "timer");
	}
	
	new iTimer = create_entity(szClassName);
	if(iTimer < 1)
		return 0;
	
	set_ent_data(iTimer, "CBaseEntity", "m_pfnThink", address);
	set_ent_data(iTimer, "CBaseEntity", "timer_type", _:timerType);
	entity_set_edict(iTimer, EV_ENT_owner, iTimerOwner);
	entity_set_float(iTimer, EV_FL_nextthink, get_gametime() + fInitialThinkDelay);
	
	return iTimer;
}


public OrpheuHookReturn:OnTouch_DispenserTouch_Pre(iDispenser, iOther)
{
	g_bInDispenserTouchHook = true;
	g_iCreatedEntityDuringDispenserTouchHook = 0;
	return OrpheuIgnored;
}

public fwd_CreateEntity_Post()
{
	if(g_bInDispenserTouchHook)
		g_iCreatedEntityDuringDispenserTouchHook = get_orig_retval();
}

public OnTouch_DispenserTouch_Post(iDispenser, iOther)
{
	g_bInDispenserTouchHook = false;
	
	if(g_iCreatedEntityDuringDispenserTouchHook <= 0)
		return;
	
	new szClassName[2];
	entity_get_string(g_iCreatedEntityDuringDispenserTouchHook, EV_SZ_classname, szClassName, charsmax(szClassName));
	if(szClassName[0])
		return;
	
	// Call Spawn on CDispenserRefillThinker entities to fix their classname.
	// By default these entities have no classname but calling Spawn will set the classname to "timer".
	OrpheuCall(g_OrphFunc_CDispenserRefillThinker__Spawn, g_iCreatedEntityDuringDispenserTouchHook);
}