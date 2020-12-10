#if defined _libtfc_player_included
  #endinput
#endif
#define _libtfc_player_included


/**
 * Sets the number of flames on the player.
 * Setting to 0 will extinguish the fire, otherwise it acts as the the fire damage amount * 2.
 * Player's can't take flame damage if they have TFC_ARMORCLASS_CERAMIC set.
 * This is used in game logic only and not a visual flame count.
 * Cannot ignite if player is underwater.
 * 
 * @param num_flames		The number of flames on the player.
 *
 * @noreturn
 */
native LibTFC_Player_SetNumFlames(client, num_flames);

/**
 * Gets the number of flames on the player.
 *
 * @return		The number of flames on the player.
 */
native LibTFC_Player_GetNumFlames(client);

/**
 * Ignites the player catching them on fire.
 * You can call LibTFC_Player_SetNumFlames() directly after this to increase flame damage.
 * 
 * @param inflictor				The entity that attacked this player to ignite them.
 * @param remove_ceramic_armor	If a player's ceramic armor should be removed or not.
 *
 * @noreturn
 */
native LibTFC_Player_Ignite(client, inflictor=0, bool:remove_ceramic_armor=false);


/**
 * Calls the CBasePlayer::TeamFortress_SetSpeed game function.
 * This function will set the player's speed according to certain attributes on that player.
 * Ex: If you set TFC_STATE_TRANQUILISED in a player's state mask they will need this function called.
 *
 * @noreturn
 */
native LibTFC_Player_CallSetSpeed(client);


/**
 * Sets the team number of the medic that infected this player.
 * 
 * @param team_number		The team number of the medic that infected this player.
 *
 * @noreturn
 */
native LibTFC_Player_SetInfectionTeamNumber(client, TeamTFC:team_number);

/**
 * Gets the team number of the medic that infected this player.
 *
 * @return		The team number of the medic that infected this player.
 */
native TeamTFC:LibTFC_Player_GetInfectionTeamNumber(client);


/**
 * Sets the player's building entity (ex: engineer sentry/dispenser/teleport).
 * This is the entity in the process of being built.
 * 
 * @param building_entity		The entity index being built, or 0 to clear the building_entity.
 *
 * @noreturn
 */
native LibTFC_Player_SetBuildingEntity(client, building_entity);

/**
 * Gets the player's building entity (ex: engineer sentry/dispenser/teleport).
 * This is the entity in the process of being built.
 *
 * @return		The entity index being built, 0 if entity is invalid.
 */
native LibTFC_Player_GetBuildingEntity(client);


/**
 * Sets the player's leg damage.
 * The default max is 6.0.
 * 
 * @param leg_damage		The amount of leg damage to give this player.
 *
 * @noreturn
 */
native LibTFC_Player_SetLegDamage(client, Float:leg_damage);

/**
 * Gets the player's leg damage.
 *
 * @return		The amount of leg damage this player has.
 */
native Float:LibTFC_Player_GetLegDamage(client);


/**
 * Sets the player's last medic call time.
 * 
 * @param last_medic_call_time		The gametime in which the player last called for a medic.
 *
 * @noreturn
 */
native LibTFC_Player_SetLastMedicCallTime(client, Float:last_medic_call_time);

/**
 * Gets the player's last medic call time.
 *
 * @return		The gametime in which the player last called for a medic.
 */
native Float:LibTFC_Player_GetLastMedicCallTime(client);


/**
 * Sets the player's currently deployed weapon entity.
 *
 * @return		True on success, false otherwise.
 */
// TODO: Implement this. Deploy this weapon entity.
//native bool:LibTFC_Player_SetDeployedWeaponEnt(client, weapon_entity);

/**
 * Gets the player's currently deployed weapon entity.
 *
 * @return		The player's currently deployed weapon entity.
 */
// TODO: Implement this.
//native LibTFC_Player_GetDeployedWeaponEnt(client);


/**
 * Sets the player's currently deployed weapon ID.
 *
 * @return		True on success, false otherwise.
 */
// TODO: Implement this. Search for equipped weapon entity based on ID and deploy it.
//native bool:LibTFC_Player_SetDeployedWeaponID(client, WeaponTFC:weapon);

/**
 * Gets the player's currently deployed weapon ID.
 *
 * @return		The player's currently deployed weapon ID.
 */
native WeaponTFC:LibTFC_Player_GetDeployedWeaponID(client);


/**
 * Sets if a player has a teleporter exit or not.
 *
 * @noreturn
 */
native LibTFC_Player_SetHasTeleporterExit(client, bool:has_teleporter_exit);

/**
 * Gets if a player has a teleporter exit or not.
 *
 * @return		True if player has a teleporter exit, false otherwise.
 */
native bool:LibTFC_Player_GetHasTeleporterExit(client);


/**
 * Sets if a player has a teleporter entrance or not.
 *
 * @noreturn
 */
native LibTFC_Player_SetHasTeleporterEntrance(client, bool:has_teleporter_entrance);

/**
 * Gets if a player has a teleporter entrance or not.
 *
 * @return		True if player has a teleporter entrance, false otherwise.
 */
native bool:LibTFC_Player_GetHasTeleporterEntrance(client);


/**
 * Sets if a player has a sentry gun or not.
 *
 * @noreturn
 */
native LibTFC_Player_SetHasSentry(client, bool:has_sentry);

/**
 * Gets if a player has a sentry gun or not.
 *
 * @return		True if player has a sentry gun, false otherwise.
 */
native bool:LibTFC_Player_GetHasSentry(client);


/**
 * Sets if a player has a dispenser or not.
 *
 * @noreturn
 */
native LibTFC_Player_SetHasDispenser(client, bool:has_dispenser);

/**
 * Gets if a player has a dispenser or not.
 *
 * @return		True if player has a dispenser, false otherwise.
 */
native bool:LibTFC_Player_GetHasDispenser(client);


/**
 * Sets the player's next respawn time.
 * 
 * @param next_respawn_time		The gametime in which the player can next respawn.
 *
 * @noreturn
 */
native LibTFC_Player_SetRespawnTime(client, Float:next_respawn_time);

/**
 * Gets the player's next respawn time.
 *
 * @return		The gametime in which the player can next respawn.
 */
native Float:LibTFC_Player_GetRespawnTime(client);


/**
 * Sets the player's score (frags).
 * 
 * param score		The player's new score.
 *
 * @noreturn
 */
native LibTFC_Player_SetScore(client, score);

/**
 * Gets the player's score.
 *
 * @return		The player's score.
 */
native LibTFC_Player_GetScore(client);


/**
 * Sets the player's lives remaining.
 * Players are automatically moved to spectate after they die with their last life.
 * 
 * param lives		The number of lives the player has. -1 is unlimited.
 *
 * @noreturn
 */
native LibTFC_Player_SetLives(client, lives);

/**
 * Gets the player's lives remaining.
 *
 * @return		The player's lives remaining.
 */
native LibTFC_Player_GetLives(client);


/**
 * Sets the player's next team or class change time.
 * 
 * @param next_team_or_class_change		The gametime in which the player can next change teams or class.
 *
 * @noreturn
 */
native LibTFC_Player_SetNextTeamOrClassChange(client, Float:next_team_or_class_change);

/**
 * Gets the player's next team or class change time.
 *
 * @return		The player's next team or class change time.
 */
native Float:LibTFC_Player_GetNextTeamOrClassChange(client);


/**
 * Sets the player to a new team.
 *
 * @return			True on success, false otherwise.
 */
native bool:LibTFC_Player_ChangeTeam(client, TeamTFC:new_team);

/**
 * Gets the player's current team.
 *
 * @return		The player's current team.
 */
native TeamTFC:LibTFC_Player_GetTeam(client);


/**
 * Sets the player's current armor value.
 *
 * @noreturn
 */
native LibTFC_Player_SetArmorValue(client, Float:armor_value);

/**
 * Gets the player's current armor value.
 *
 * @return		The player's current armor value.
 */
native Float:LibTFC_Player_GetArmorValue(client);


/**
 * Sets the player's maximum armor value.
 *
 * @noreturn
 */
native LibTFC_Player_SetArmorValueMax(client, Float:armor_value_max);

/**
 * Gets the player's maximum armor value.
 *
 * @return		The player's maximum armor value.
 */
native Float:LibTFC_Player_GetArmorValueMax(client);


/**
 * Sets the player's backpack ammo maximum amount for a particular ammo type.
 *
 * @return		True on success, false otherwise
 */
native bool:LibTFC_Player_SetAmmoBackpackMax(client, AmmoTypeTFC:ammo_type, amount_max);

/**
 * Gets the player's backpack ammo maximum amount for a particular ammo type.
 *
 * @return		The maximum ammo value for this particular ammo type.
 */
native LibTFC_Player_GetAmmoBackpackMax(client, AmmoTypeTFC:ammo_type);


/**
 * Sets the player's backpack ammo amount for a particular ammo type.
 *
 * @return		True on success, false otherwise
 */
native bool:LibTFC_Player_SetAmmoBackpack(client, AmmoTypeTFC:ammo_type, amount);

/**
 * Gets the player's backpack ammo amount for a particular ammo type.
 *
 * @return		The amount of ammo for this particular ammo type.
 */
native LibTFC_Player_GetAmmoBackpack(client, AmmoTypeTFC:ammo_type);


/**
 * Sets the player's items mask.
 * Uses TFC_ITEM_* flags for the mask.
 *
 * @noreturn
 */
native LibTFC_Player_SetItemsMask(client, items_mask);

/**
 * Gets the player's items mask.
 * Uses TFC_ITEM_* flags for the mask.
 *
 * @return		The player's items mask.
 */
native LibTFC_Player_GetItemsMask(client);


/**
 * Sets the player's currently equipped armor type.
 * 
 * WARNING:
 * This function is not associated with the TFC_ARMORCLASS_* values.
 * 
 * @param custom_absorption_percent		A custom percent of damage to absorb. 0.0: 0% and 1.0: 100%
 *
 * @return								True on success, false otherwise.
 */
native bool:LibTFC_Player_SetArmorType(client, ArmorTypeTFC:armor_type, Float:custom_absorption_percent=0.5);

/**
 * Gets the player's currently equipped armor type.
 * 
 * WARNING:
 * This function is not associated with the TFC_ARMORCLASS_* values.
 *
 * @return		The armor type.
 */
native ArmorTypeTFC:LibTFC_Player_GetArmorType(client);

/**
 * Gets the player's currently equipped armor type's absorption percent.
 * The absorption percent can match a TFC_ARMORTYPEABSORB_* flag or be a custom amount.
 * 
 * WARNING:
 * This function is not associated with the TFC_ARMORCLASS_* values.
 *
 * @return		The armor type's absorption percent.
 */
native Float:LibTFC_Player_GetArmorTypeAbsorptionPercent(client);


/**
 * Sets if a player's primed grenade should be removed or not.
 *
 * @noreturn
 */
native LibTFC_Player_SetRemovePrimedGrenade(client, bool:should_remove_primed_grenade);

/**
 * Gets if this player is set to have their primed grenade removed or not.
 *
 * @return		True if player's primed grenade is set to be removed, false otherwise.
 */
native bool:LibTFC_Player_IsRemovingPrimedGrenade(client);


/**
 * Sets the slot of the current primed grenade.
 *
 * @noreturn
 */
native LibTFC_Player_SetGrenadePrimedSlot(client, GrenadeSlotTFC:grenade_slot);

/**
 * Gets the slot of the current or last primed grenade.
 * This will return the slot of the last primed grenade even if there is no longer a primed grenade.
 *
 * @return		The grenade slot.
 */
native GrenadeSlotTFC:LibTFC_Player_GetGrenadePrimedSlot(client);


/**
 * Sets the player's tfstate mask.
 * Uses TFC_STATE_* flags for the mask.
 *
 * @noreturn
 */
native LibTFC_Player_SetStateMask(client, state_mask);

/**
 * Gets the player's tfstate mask.
 * Uses TFC_STATE_* flags for the mask.
 *
 * @return		The player's tfstate mask.
 */
native LibTFC_Player_GetStateMask(client);


/**
 * Sets the player's ability to use spy abilities/teleport or not.
 *
 * @noreturn
 */
native LibTFC_Player_SetUnableToSpyOrTeleport(client, bool:unable_to_spy_or_teleport);

/**
 * Gets the player's ability to use spy abilities/teleport or not.
 *
 * @return		True if player is not allowed to use spy abilities/teleport, false otherwise.
 */
native bool:LibTFC_Player_GetUnableToSpyOrTeleport(client);


/**
 * Sets the player's feign state.
 *
 * @noreturn
 */
native LibTFC_Player_SetIsFeigning(client, bool:is_feigning);

/**
 * Gets the player's feign state.
 *
 * @return		True if player is feigning, false otherwise.
 */
native bool:LibTFC_Player_GetIsFeigning(client);


/**
 * Sets the player's detpack setting state.
 *
 * @noreturn
 */
native LibTFC_Player_SetIsSettingDetpack(client, bool:is_setting_detpack);

/**
 * Gets the player's detpack setting state.
 *
 * @return		True if player is setting a detpack, false otherwise.
 */
native bool:LibTFC_Player_GetIsSettingDetpack(client);


/**
 * Sets the player's building status.
 *
 * @noreturn
 */
native LibTFC_Player_SetIsBuilding(client, bool:is_building);

/**
 * Gets the player's building status.
 *
 * @return		True if player is building (ex: engineer sentry/dispenser/teleport), false otherwise.
 */
native bool:LibTFC_Player_GetIsBuilding(client);


/**
 * Sets the player's disguise type.
 *
 * @noreturn
 */
native LibTFC_Player_SetDisguiseType(client, DisguiseTFC:disguise_type);

/**
 * Gets the player's disguise type.
 *
 * @return		The disguise type.
 */
native DisguiseTFC:LibTFC_Player_GetDisguiseType(client);


/**
 * Sets the grenade type for a given slot.
 *
 * @return		True on success, false otherwise
 */
native bool:LibTFC_Player_SetGrenadeType(client, GrenadeSlotTFC:grenade_slot, GrenadeTypeTFC:grenade_type);

/**
 * Gets the grenade type for a given slot.
 *
 * @return		The grenade type.
 */
native GrenadeTypeTFC:LibTFC_Player_GetGrenadeType(client, GrenadeSlotTFC:grenade_slot);

/**
 * Gets the maximum number of grenades a player is supposed to have by default for a specific grenade type.
 *
 * @return		The maximum number of grenades for given type.
 */
native LibTFC_Player_GetGrenadeAmountMaxForType(GrenadeTypeTFC:grenade_type);


/**
 * Sets the number of grenades for a grenade slot.
 *
 * @return		True on success, false otherwise
 */
native bool:LibTFC_Player_SetGrenadeAmount(client, GrenadeSlotTFC:grenade_slot, amount);

/**
 * Gets the number of grenades for a grenade slot.
 *
 * @return		The number of grenades.
 */
native LibTFC_Player_GetGrenadeAmount(client, GrenadeSlotTFC:grenade_slot);


/**
 * Sets the player's armor class bitmask.
 * Uses TFC_ARMORCLASS_* flags for the mask.
 * 
 * WARNING:
 * This function is not associated with the TFC_ARMORTYPE_* or the TFC_ARMORTYPEABSORB_* values.
 *
 * @noreturn
 */
native LibTFC_Player_SetArmorClassMask(client, armor_class_mask);

/**
 * Gets the player's armor class bitmask.
 * Uses TFC_ARMORCLASS_* flags for the mask.
 * 
 * WARNING:
 * This function is not associated with the TFC_ARMORTYPE_* or the TFC_ARMORTYPEABSORB_* values.
 *
 * @return		Armor class bitmask.
 */
native LibTFC_Player_GetArmorClassMask(client);


/**
 * Sets the next class this player should spawn as.
 *
 * @noreturn
 */
native LibTFC_Player_SetPlayerClassNext(client, PlayerClassTFC:player_class);

/**
 * Gets the next class this player should spawn as.
 *
 * @return		Class number the player will next spawn as.
 */
native PlayerClassTFC:LibTFC_Player_GetPlayerClassNext(client);


/**
 * Sets the last class this player spawned as.
 *
 * @noreturn
 */
native LibTFC_Player_SetPlayerClassLast(client, PlayerClassTFC:player_class);

/**
 * Gets the last class this player spawned as.
 *
 * @return		Class number the player last spawned as.
 */
native PlayerClassTFC:LibTFC_Player_GetPlayerClassLast(client);

