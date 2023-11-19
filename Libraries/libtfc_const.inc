#if defined _libtfc_const_included
  #endinput
#endif
#define _libtfc_const_included


#define TFC_MAX_PLAYERS 32                     // The maximum number of players in a server.
#define TFC_PLAYER_BUFFER TFC_MAX_PLAYERS + 1  // The maximum number of players in a server + 1.


/**
 * The maximum number of players in a server.
 */
#define TFC_DEAD_NO          0 // Alive
#define TFC_DEAD_DYING       1 // Playing death animation or still falling off of a ledge waiting to hit ground
#define TFC_DEAD_DEAD        2 // Dead, lying still
#define TFC_DEAD_RESPAWNABLE 3 // The player is ready to respawn
#define TFC_DEAD_DISCARDBODY 4
#define TFC_DEAD_FEIGNING    5 // Feigning death


/**
 * Gives an additional 50% damage reduction against certain damage types.
 * When a users pev->armorvalue reaches 0 the players armorclass variable is set to 0.
 * A player can be given an armorclass value via goal entities.
 * 
 * WARNING:
 * These are not associated with the TFC_ARMORTYPE_* or the TFC_ARMORTYPEABSORB_* values.
 */
#define TFC_ARMORCLASS_NORMAL  0  // No additional damage reduction.
#define TFC_ARMORCLASS_KEVLAR  1  // 50% damage reduction against shells.
#define TFC_ARMORCLASS_WOODEN  2  // 50% damage reduction against nails.
#define TFC_ARMORCLASS_BLAST   4  // 50% damage reduction against explosions.
#define TFC_ARMORCLASS_SHOCK   8  // 50% damage reduction against electricity.
#define TFC_ARMORCLASS_CERAMIC 16 // 50% damage reduction against fire.


/*
 * The armortype absorption percentages.
 * These are the percentages associated with the TFC_ARMORTYPE_* values.
 * 
 * WARNING:
 * These are not associated with the TFC_ARMORCLASS_* values.
*/
#define TFC_ARMORTYPEABSORB_NONE   0.0
#define TFC_ARMORTYPEABSORB_LIGHT  0.3
#define TFC_ARMORTYPEABSORB_MEDIUM 0.6
#define TFC_ARMORTYPEABSORB_HEAVY  0.8


/*
 * The TFState flags.
 * Some of them might not be used?
*/
#define TFC_STATE_NONE            0
#define TFC_STATE_GRENPRIMED      1      // Whether the player has a primed grenade
#define TFC_STATE_RELOADING       2      // Whether the player is reloading
#define TFC_STATE_ALTKILL         4      // #TRUE if killed with a weapon not in self.weapon: NOT USED ANYMORE
#define TFC_STATE_RANDOMPC        8      // Whether Playerclass is random, new one each respawn
#define TFC_STATE_INFECTED        16     // set when player is infected by the bioweapon
#define TFC_STATE_INVINCIBLE      32     // Player has permanent Invincibility (Usually by GoalItem)
#define TFC_STATE_INVISIBLE       64     // Player has permanent Invisibility (Usually by GoalItem)
#define TFC_STATE_QUAD            128    // Player has permanent Quad Damage (Usually by GoalItem)
#define TFC_STATE_RADSUIT         256    // Player has permanent Radsuit (Usually by GoalItem)
#define TFC_STATE_BURNING         512    // Is on fire
#define TFC_STATE_GRENTHROWING    1024   // is throwing a grenade, but not thrown yet
#define TFC_STATE_AIMING          2048   // is using the laser sight
#define TFC_STATE_ZOOMOFF         4096   // doesn't want the FOV changed when zooming
#define TFC_STATE_RESPAWN_READY   8192   // is waiting for respawn, and has pressed fire
#define TFC_STATE_HALLUCINATING   16384  // set when player is hallucinating
#define TFC_STATE_TRANQUILISED    32768  // set when player is tranquilised
#define TFC_STATE_CANT_MOVE       65536  // set when player is setting a detpack and during cease fire
#define TFC_STATE_RESET_FLAMETIME 131072 // set when the player has to have his flames increased in health


/*
 * The items flags.
 * 
 * WARNING:
 * If you want to check which armor the player currently has you should use
 * the LibTFC_Player_GetArmorType function instead. It will be the most accurate incase the
 * player's armortype variable goes out of sync with the item flags variable.
*/
#define TFC_ITEM_NONE                 0
#define TFC_ITEM_ARMOR1               8192     // Don't use this value. Use the LibTFC_Player_GetArmorType function instead.
#define TFC_ITEM_ARMOR2               16384    // Don't use this value. Use the LibTFC_Player_GetArmorType function instead.
#define TFC_ITEM_ARMOR3               32768    // Don't use this value. Use the LibTFC_Player_GetArmorType function instead.
#define TFC_ITEM_SUPERHEALTH          65536    // Has healthrot (meaning the player has a timer ticking their health above max down until it reaches max).
#define TFC_ITEM_HAS_BLUE_GOAL_ITEM   131072   // Has a blue goal item. Ex: Red player has blue flag.
#define TFC_ITEM_HAS_RED_GOAL_ITEM    262144   // Has a red goal item. Ex: Blue player has red flag.
#define TFC_ITEM_HAS_YELLOW_GOAL_ITEM 16777216 // Has a yellow goal item. Ex: Blue player has yellow flag.
#define TFC_ITEM_HAS_GREEN_GOAL_ITEM  33554432 // Has a green goal item. Ex: Blue player has green flag.
#define TFC_ITEM_INVISIBILITY         524288   // Somewhat invisible
#define TFC_ITEM_INVULNERABILITY      1048576  // God mode, cannot be killed
#define TFC_ITEM_RADIATIONSUIT        2097152  // TODO: See what this does.
#define TFC_ITEM_QUAD                 4194304  // Quad, 4x damage multiplier


/*
 * The weapons flags.
*/
#define TFC_WPNFLAG_NONE             0
#define TFC_WPNFLAG_HOOK             1      // Seems to be unused
#define TFC_WPNFLAG_BIOWEAPON        2
#define TFC_WPNFLAG_MEDIKIT          4
#define TFC_WPNFLAG_SPANNER          8
#define TFC_WPNFLAG_AXE              16
#define TFC_WPNFLAG_SNIPER_RIFLE     32
#define TFC_WPNFLAG_AUTO_RIFLE       64
#define TFC_WPNFLAG_SHOTGUN          128
#define TFC_WPNFLAG_SUPER_SHOTGUN    256
#define TFC_WPNFLAG_NAILGUN          512
#define TFC_WPNFLAG_SUPER_NAILGUN    1024
#define TFC_WPNFLAG_GRENADE_LAUNCHER 2048
#define TFC_WPNFLAG_FLAMETHROWER     4096
#define TFC_WPNFLAG_ROCKET_LAUNCHER  8192
#define TFC_WPNFLAG_INCENDIARY       16384
#define TFC_WPNFLAG_ASSAULT_CANNON   32768
#define TFC_WPNFLAG_LIGHTNING        65536  // Seems to be unused
#define TFC_WPNFLAG_DETPACK          131072
#define TFC_WPNFLAG_TRANQ            262144
#define TFC_WPNFLAG_RAILGUN          524288



/*
 * Weapon IDs.
*/
enum WeaponTFC
{
	TFC_WPNID_NONE = 0,
	TFC_WPNID_HOOK,      // Seems to be unused
	TFC_WPNID_BIOWEAPON, // Seems to be unused
	TFC_WPNID_MEDIKIT,
	TFC_WPNID_SPANNER,
	TFC_WPNID_AXE,
	TFC_WPNID_SNIPER_RIFLE,
	TFC_WPNID_AUTO_RIFLE,
	TFC_WPNID_TF_SHOTGUN,
	TFC_WPNID_SUPER_SHOTGUN,
	TFC_WPNID_NAILGUN,
	TFC_WPNID_SUPER_NAILGUN,
	TFC_WPNID_GRENADE_LAUNCHER,
	TFC_WPNID_FLAMETHROWER,
	TFC_WPNID_ROCKET_LAUNCHER,
	TFC_WPNID_INCENDIARY,
	TFC_WPNID_UNKNOWN16, // Seems to be unused
	TFC_WPNID_ASSAULT_CANNON,
	TFC_WPNID_LIGHTNING, // Seems to be unused
	TFC_WPNID_DETPACK,   // Seems to be unused
	TFC_WPNID_TRANQ,
	TFC_WPNID_RAILGUN,
	TFC_WPNID_PIPEBOMB_LAUNCHER,
	TFC_WPNID_KNIFE,
	TFC_WPNID_BENCHMARK  // Seems to be unused
};


/*
 * Player classes.
*/
enum PlayerClassTFC
{
	TFC_CLASS_NONE = 0, // 0
	TFC_CLASS_SCOUT,    // 1
	TFC_CLASS_SNIPER,   // 2
	TFC_CLASS_SOLDIER,  // 3
	TFC_CLASS_DEMOMAN,  // 4
	TFC_CLASS_MEDIC,    // 5
	TFC_CLASS_HWGUY,    // 6
	TFC_CLASS_PYRO,     // 7
	TFC_CLASS_SPY,      // 8
	TFC_CLASS_ENGINEER, // 9
	TFC_CLASS_RANDOM,   // 10
	TFC_CLASS_CIVILIAN  // 11
};


/*
 * Ammo types.
*/
enum AmmoTypeTFC
{
	TFC_AMMOTYPE_NONE = 0,
	TFC_AMMOTYPE_SHELLS,
	TFC_AMMOTYPE_NAILS,
	TFC_AMMOTYPE_CELLS,
	TFC_AMMOTYPE_ROCKETS,
	TFC_AMMOTYPE_DETPACKS
};


/*
 * Grenade slots.
*/
enum GrenadeSlotTFC
{
	TFC_GRENADESLOT_NONE = 0,
	TFC_GRENADESLOT_PRIMARY,
	TFC_GRENADESLOT_SECONDARY
};


/*
 * Grenade types.
*/
enum GrenadeTypeTFC
{
	TFC_GRENTYPE_NONE = 0,   // 0
	TFC_GRENTYPE_NORMAL,     // 1
	TFC_GRENTYPE_CONCUSSION, // 2
	TFC_GRENTYPE_NAIL,       // 3
	TFC_GRENTYPE_MIRV,       // 4
	TFC_GRENTYPE_NAPALM,     // 5
	TFC_GRENTYPE_FLARE,      // 6 - Not used
	TFC_GRENTYPE_GAS,        // 7
	TFC_GRENTYPE_EMP,        // 8
	TFC_GRENTYPE_CALTROP,    // 9
	TFC_GRENTYPE_FLASH       // 10 - Not used
};


/*
 * Spy disguise types.
*/
enum DisguiseTFC
{
	TFC_DISGUISE_NOT_DISGUISED = 0,
	TFC_DISGUISE_DISGUISED,
	TFC_DISGUISE_DISGUISING
};


/*
 * Armor types.
 * 
 * WARNING:
 * These are not associated with the TFC_ARMORCLASS_* values.
*/
enum ArmorTypeTFC
{
	TFC_ARMORTYPE_NONE = 0, // Absorbs 0% (0.0) of damage.
	TFC_ARMORTYPE_LIGHT,    // Absorbs 30% (0.3) of damage (green).
	TFC_ARMORTYPE_MEDIUM,   // Absorbs 60% (0.6) of damage (yellow).
	TFC_ARMORTYPE_HEAVY,    // Absorbs 80% (0.8) of damage (red).
	TFC_ARMORTYPE_CUSTOM    // Absorbs a custom %. Must be set through code.
};


/*
 * Team types.
*/
enum TeamTFC
{
	TFC_TEAM_SPECTATE = 0,
	TFC_TEAM_BLUE,
	TFC_TEAM_RED,
	TFC_TEAM_YELLOW,
	TFC_TEAM_GREEN
};
