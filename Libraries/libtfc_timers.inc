#if defined _libtfc_timers_included
  #endinput
#endif
#define _libtfc_timers_included



/*
 * Timer types.
*/
enum TimerTypeTFC
{
	TFC_TIMER_NONE					= -1,
	
	/*
	* Ticks when the player's teamkill autokick count is to be reset to 0.
	* classname: ak_timer
	* 
	* Default owner: CBasePlayer. The player that is close to being autokicked for teamkilling.
	* Default initial nextthink: tfc_autokick_time.value
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* none
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(player_to_reset_tk_counter_for, TFC_TIMER_TK_AUTO_KICK_RESET, seconds_before_counter_resets);
	*/
	TFC_TIMER_TK_AUTO_KICK_RESET	= 0,
	
	/*
	* Ticks for an infected player. Checks to see if the timer should die. Tries to find more players to infect in radius of infected. Deals damage to infected.
	* classname: timer
	* 
	* Default owner: CBasePlayer. The player who is infected.
	* Default initial nextthink: 2.0
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* timer->pev->enemy = infecterPlayer;
	* infectedPlayer->tfstate |= TFC_STATE_INFECTED
	* infectedPlayer->infection_team_no = infecterPlayer->team_no
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(player_to_infect, TFC_TIMER_INFECTION, seconds_before_first_infection, entity_that_did_infecting);
	*/
	TFC_TIMER_INFECTION				= 2,
	
	/*
	* Ticks while a player is hallucinating.
	* classname: timer
	* 
	* Default owner: CBasePlayer. The player that is hallucinating.
	* Default initial nextthink: 0.3
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* hallucPlayer->tfstate |= TFC_STATE_HALLUCINATING
	* timer->pev->health = 150 (the higher the starting timer health the longer the halluc lasts)
	* timer->team_no = hallucPlayer->team_no
	* 
	* NOTES:
	* ---
	* Each tick decreases the timer's health value by 2.5.
	* It ticks every 0.3 seconds until the timer's health value is 0.
	* Medics hallucinate for half the duration.
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(hallucinating_player, TFC_TIMER_HALLUCINATION, seconds_before_first_hallucination, seconds_for_hallucination_to_last);
	*/
	TFC_TIMER_HALLUCINATION			= 3,
	
	/*
	* Ticks when a player's tranq effect should end.
	* classname: timer
	* 
	* Default owner: CBasePlayer. The player who is tranquilized.
	* Default initial nextthink: 15.0
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* tranqedPlayer->tfstate |= TFC_STATE_TRANQUILISED (call CBasePlayer::TeamFortress_SetSpeed(tranqedPlayer) after setting this flag)
	* timer->team_no = enemy_player_team_number (doesn't appear to be used though)
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(tranqed_player, TFC_TIMER_TRANQ_END, seconds_for_tranq_to_last);
	*/
	TFC_TIMER_TRANQ_END				= 4,
	
	/*
	* Ticks while a player's health is above their max. Decreases their health by 1 each tick.
	* classname: timer
	* 
	* Default owner: CBasePlayer. The player whos health is above max.
	* Default initial nextthink: 5.0
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* rotPlayer->items |= TFC_ITEM_SUPERHEALTH
	* timer->pev->enemy = entity (only set this if you want Respawn() to be called when healthrot ends, otherwise use 0)
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(player_to_rot, TFC_TIMER_HEALTH_ROT, seconds_before_first_health_rot, entity_to_respawn_on_rot_end);
	*/
	TFC_TIMER_HEALTH_ROT			= 5,
	
	/*
	* Ticks for a player to increase their health to max. Each tick increases health by 2.
	* classname: timer
	* 
	* Default owner: CBasePlayer. The medic when spawning.
	* Default initial nextthink: 3.0
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* none
	* 
	* NOTES:
	* This timer does NOT destroy itself when the player is at full hp. It lasts until they die.
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(player_to_regen, TFC_TIMER_HEALTH_REGEN, seconds_before_first_regen);
	*/
	TFC_TIMER_HEALTH_REGEN			= 6,
	
	/*
	* Ticks when a detpack is done being set. Creates a "detpack" entity at the owner's location.
	* classname: timer
	* 
	* Default owner: CBasePlayer. The player that set the detpack.
	* Default initial nextthink: 3.0
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* player->is_detpacking = 1
	* player->tfstate |= TFC_STATE_CANT_MOVE (call CBasePlayer::TeamFortress_SetSpeed(player) after setting this flag)
	* timer->pev->health = how long the detpack entity should be set for (5-50 seconds)
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(player_setting_detpack, TFC_TIMER_SET_DETPACK, seconds_before_detpack_is_set, seconds_before_detpack_explodes);
	*/
	TFC_TIMER_SET_DETPACK			= 9,
	
	/*
	* Ticks when an engineer's buildable finishes building.
	* classname: timer
	* 
	* Default owner: CBasePlayer. The engineer that started building.
	* Default initial nextthink: (sentry: 5.0) (teleports: 4.0) (dispenser: 2.0)
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* player->building = (CTFSentrygunBase::CreateSentryBase) (CTFTeleporter::CreateTeleporter) (CTFDispenser::CreateDispenser)
	* player->is_building = 1
	* player->tfstate |= TFC_STATE_CANT_MOVE (call CBasePlayer::TeamFortress_SetSpeed(player) after setting this flag)
	* 
	* NOTES:
	* ---
	* Call CreateSentryBase/CreateTeleporter/CreateDispenser, then call CBaseEntity::CheckArea(buildable, player) to make sure there's room for it.
	* Check players pev->flags to make sure player is on ground.
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(player_thats_building, TFC_TIMER_FINISHED_BUILDING, seconds_before_build_completes, entity_being_built);
	*/
	TFC_TIMER_FINISHED_BUILDING		= 11,
	
	/*
	* Ticks when a player is finished disguising.
	* classname: timer
	* 
	* Default owner: CBasePlayer. The player that is disguising.
	* Default initial nextthink: 4.0 to disguise as team already disguised as. 8.0 to disguise as other team.
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* player->is_undercover = TFC_DISGUISE_DISGUISING
	* timer->team_no = team_to_disguise_as
	* timer->pev->skin = class_to_disguise_as
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(player_to_disguise, TFC_TIMER_FINISH_DISGUISING, seconds_takes_to_disguise, team_to_disguise_as, class_to_disguise_as);
	*/
	TFC_TIMER_FINISH_DISGUISING		= 13,
	
	/*
	* Ticks while the player that touched the dispenser is being refilled.
	* classname: timer
	* 
	* Default owner: CTFDispenser. The dispenser being used.
	* Default initial nextthink: 0.2
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* timer->m_hDispenser = dispenser
	* timer->m_hPlayer = the player that touched the dispenser
	* timer->m_InitialUsePoint = the player's origin when they touched the dispenser
	* 
	* NOTES:
	* ---
	* The timer kills itself if the player_to_refill goes out of range of their initial location.
	* 
	* The classname by default is blank "" because Spawn never gets called for CDispenserRefillThinker entities.
	* The timer_type by default is 0 because of the same reason.
	* CDispenserRefillThinker::Spawn is supposed to set both the classname and timer_type.
	* The timer library will force call Spawn to fix this issue.
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(dispenser_entity, TFC_TIMER_DISPENSER_REFILL, seconds_before_first_refill, player_to_refill);
	*/
	TFC_TIMER_DISPENSER_REFILL		= 14,
	
	/*
	* Ticks when an item_tfgoal should be returned.
	* classname: timer
	* 
	* Default owner: CBaseEntity. The item_tfgoal.
	* Default initial nextthink: 0.1 or 0.5 depending on what activates the timer
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* timer->weapon = 1 or 2 or 3 (TODO: What are these values?)
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(item_tfgoal_entity, TFC_TIMER_ITEM_TFGOAL_RETURN, seconds_before_item_tfgoal_returns, unknown_value);
	*/
	TFC_TIMER_ITEM_TFGOAL_RETURN	= 100,
	
	/*
	* Ticks when a tfgoal should call DoResults.
	* classname: timer
	* 
	* Default owner: CBaseEntity. The goal entity.
	* Default initial nextthink: goal->delay_time
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* timer->pev->enemy = activating_player
	* timer->weapon = should_add_bonuses
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(tfgoal_entity, TFC_TIMER_TFGOAL_DO_RESULTS, seconds_before_do_results_called, activating_player, should_add_bonuses);
	*/
	TFC_TIMER_TFGOAL_DO_RESULTS		= 101,
	
	/*
	* Ticks when the round end, ends. Basically when a new round begins. Think of the map avanti. Allows players to move again. Ends cease fire.
	* classname: timer
	* 
	* Default owner: CBaseEntity. The goal entity.
	* Default initial nextthink: goal->m_flEndRoundTime
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* none
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(tfgoal_entity, TFC_TIMER_ENDROUND_END, seconds_before_endround_ends);
	*/
	TFC_TIMER_ENDROUND_END			= 102,
	
	
	
	// The following timer types don't have a timer_type specified in game code.
	// The timer_type probably defaults to 0.
	// Just use a custom value for these.
	
	/*
	* Ticks when a birthday message and party sounds should play.
	* classname: timer
	* 
	* Default owner: CWorld.
	* Default initial nextthink: 60.0
	* 
	* Variables to set directly after creating the timer entity:
	* ---
	* timer->weapon = 10
	* 
	* Creation usage:
	* ---
	* LibTFC_Timers_CreateTimer(0, TFC_TIMER_BIRTHDAY, seconds_before_starting);
	*/
	TFC_TIMER_BIRTHDAY				= 1000
};



/**
 * Finds a timer by owner and by timer type.
 * If owner is -1 and timer_type is TFC_TIMER_NONE then this function will return any timer.
 * 
 * @param owner				The timer's owner entity. If the owner is -1 then it will only do a timer_type search.
 * @param timer_type		The timer's type. If the type is TFC_TIMER_NONE then it will only do an owner search.
 * @param start_search_ent	The entity index after which to begin searching from. Use -1 to start from the first entity.
 *
 * @return		The timer's entity index found, 0 otherwise.
 */
native LibTFC_Timers_FindTimerByOwner(owner=-1, TimerTypeTFC:timer_type=TFC_TIMER_NONE, start_search_ent=-1);


/**
 * Creates a new timer.
 * 
 * @param owner					The timer's owner entity.
 * @param timer_type			The timer's type.
 * @param initial_think_delay	The delay before the timer's initial think tick. Use -1.0 to use the game's default.
 * @param arg1					Additional argument depending on the timer_type. See the TimerTypeTFC enum for usage.
 * @param arg2					Additional argument depending on the timer_type. See the TimerTypeTFC enum for usage.
 *
 * @return		The timer's entity index found, 0 otherwise.
 */
native LibTFC_Timers_CreateTimer(owner, TimerTypeTFC:timer_type, Float:initial_think_delay=-1.0, arg1=0, arg2=0);
