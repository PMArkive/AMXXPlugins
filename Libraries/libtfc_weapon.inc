#if defined _libtfc_weapon_included
  #endinput
#endif
#define _libtfc_weapon_included


/**
 * Creates a weapon.
 *
 * @param weapon_id		The weapon id to create.
 * 
 * @return		Returns the weapon entity created, or 0 on failure.
 */
native LibTFC_Weapon_Create(WeaponTFC:weapon_id);

/**
 * Gets a weapon classname by weapon id.
 * 
 * @param weapon_id			The weapon id to get the classname of.
 * @param class_name			Buffer to copy value to.
 * @param maxlength			Maximum buffer size.
 *
 * @return					Number of cells copied from the buffer.
 */
native LibTFC_Weapon_GetWeaponClassByWeaponId(WeaponTFC:weapon_id, class_name[], maxlength);

/**
 * Gets a weapon id by weapon classname.
 * 
 * @param class_name			The weapon classname to get the id of.
 *
 * @return					The weapon id, TFC_WPNID_NONE if not found.
 */
native WeaponTFC:LibTFC_Weapon_GetWeaponIdByWeaponClass(class_name[]);

/**
 * Gets the slot this weapon uses.
 *
 * @param weapon		The weapon.
 * 
 * @return		Returns the slot this weapon uses.
 */
native LibTFC_Weapon_GetSlot(weapon);

/**
 * Gets the position in the slot this weapon uses.
 *
 * @param weapon		The weapon.
 * 
 * @return		Returns the position in the slot this weapon uses.
 */
native LibTFC_Weapon_GetPosition(weapon);

/**
 * Gets the primary ammo name.
 *
 * @param weapon		The weapon.
 * @param ammo_name		Buffer to copy value to.
 * @param maxlength		Maximum buffer size.
 * 
 * @return		Returns bytes written.
 */
native LibTFC_Weapon_GetPrimaryAmmoName(weapon, ammo_name[], maxlength);

/**
 * Gets the primary ammo max amount that can be in the backpack.
 *
 * @param weapon		The weapon.
 * 
 * @return		The primary ammo max.
 */
native LibTFC_Weapon_GetPrimaryAmmoMax(weapon);

/**
 * Gets the secondary ammo name.
 *
 * @param weapon		The weapon.
 * @param ammo_name		Buffer to copy value to.
 * @param maxlength		Maximum buffer size.
 * 
 * @return		Returns bytes written.
 */
native LibTFC_Weapon_GetSecondaryAmmoName(weapon, ammo_name[], maxlength);

/**
 * Gets the secondary ammo max amount that can be in the backpack.
 *
 * @param weapon		The weapon.
 * 
 * @return		The secondary ammo max.
 */
native LibTFC_Weapon_GetSecondaryAmmoMax(weapon);

/**
 * Gets the name of the weapon.
 *
 * @param weapon		The weapon.
 * @param weapon_name		Buffer to copy value to.
 * @param maxlength		Maximum buffer size.
 * 
 * @return		Returns bytes written.
 */
native LibTFC_Weapon_GetName(weapon, weapon_name[], maxlength);

/**
 * Sets the number of rounds in the weapon.
 *
 * @param weapon		The weapon.
 * @param clip_size		The size to set.
 * 
 * @noreturn
 */
native LibTFC_Weapon_SetRoundsRemaining(weapon, clip_size);

/**
 * Gets the number of rounds in the weapon.
 *
 * @param weapon		The weapon.
 * 
 * @return The number of rounds in the weapon.
 */
native LibTFC_Weapon_GetRoundsRemaining(weapon);

/**
 * Gets the number of rounds that can fit in the clip (magazine).
 *
 * @param weapon		The weapon.
 * 
 * @return The number of rounds that can fit in this clip.
 */
native LibTFC_Weapon_GetClipSizeMax(weapon);

/**
 * Checks if a weapon uses a clip (aka a reloadable weapon).
 *
 * @param weapon		The weapon.
 * 
 * @return True if this weapon uses a clip, false otherwise.
 */
native bool:LibTFC_Weapon_UsesClip(weapon);

/**
 * Checks if a weapon is fully loaded.
 *
 * @param weapon		The weapon.
 * 
 * @return True if this weapon is fully loaded, false otherwise.
 */
native bool:LibTFC_Weapon_IsFullyLoaded(weapon);

/**
 * Gets the weapons ID.
 * This is a TFC_WPNID_* value.
 *
 * @param weapon		The weapon.
 * 
 * @return The weapons ID.
 */
native WeaponTFC:LibTFC_Weapon_GetId(weapon);

/**
 * Gets the weapons flags.
 *
 * @param weapon		The weapon.
 * 
 * @return The weapons flags.
 */
native LibTFC_Weapon_GetFlags(weapon);

/**
 * Gets the weapons weight.
 *
 * @param weapon		The weapon.
 * 
 * @return The weapons weight.
 */
native LibTFC_Weapon_GetWeight(weapon);

/**
 * Gets if the weapon is reloading or not.
 *
 * @param weapon		The weapon.
 * 
 * @return True if the weapon is reloading, false otherwise.
 */
native bool:LibTFC_Weapon_IsReloading(weapon);

/**
 * Sets the weapons next primary attack time.
 *
 * @param weapon		The weapon.
 * @param next_attack		The next attack time.
 * 
 * @noreturn
 */
native LibTFC_Weapon_SetNextPrimaryAttack(weapon, Float:next_attack);

/**
 * Gets the weapons next primary attack time.
 *
 * @param weapon		The weapon.
 * 
 * @return The weapons next primary attack time.
 */
native Float:LibTFC_Weapon_GetNextPrimaryAttack(weapon);

/**
 * Sets the weapons next reload time.
 *
 * @param weapon		The weapon.
 * @param next_reload		The next reload time.
 * 
 * @noreturn
 */
native LibTFC_Weapon_SetNextReload(weapon, Float:next_reload);

/**
 * Gets the weapons next reload time.
 *
 * @param weapon		The weapon.
 * 
 * @return The weapons next reload time.
 */
native Float:LibTFC_Weapon_GetNextReload(weapon);

/**
 * Sends an animation sequence to a weapons owner.
 * You can find the sequence indexes in a model viewer.
 *
 * @param weapon		The weapon.
 * @param anim_sequence		The animation sequence to send.
 * 
 * @return  True on success, false otherwise.
 */
native bool:LibTFC_Weapon_SendAnimation(weapon, anim_sequence);
