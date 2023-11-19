#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <hamsandwich>
#include "../../Libraries/libtfc_weapon.inc"
#include "../../Libraries/libtfc_player.inc"
#include "../../Libraries/libtfc_const.inc"


new const PLUGIN[] = "Auto Reload";
new const VERSION[] = "1.2";
new const AUTHOR[] = "hlstriker";


const SEQ_RELOAD_SHOTGUN = 3;
const SEQ_RELOAD_SUPER_SHOTGUN = 3;
const SEQ_RELOAD_GRENADE_LAUNCHER = 4;
const SEQ_RELOAD_PIPE_LAUNCHER = 6;
const SEQ_RELOAD_RPG = 8;

new const SZ_WEAPONS_WITH_CLIP[][] =
{
	"tf_weapon_shotgun",
	"tf_weapon_supershotgun",
	"tf_weapon_gl",
	"tf_weapon_rpg",
	"tf_weapon_pl",
};


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("auto_reload_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY);
	
	for(new i=0; i<sizeof(SZ_WEAPONS_WITH_CLIP); i++)
	{
		RegisterHam(Ham_Item_PostFrame, SZ_WEAPONS_WITH_CLIP[i], "OnItemPostFrame_Pre", 0);
		RegisterHam(Ham_Item_PostFrame, SZ_WEAPONS_WITH_CLIP[i], "OnItemPostFrame_Post", 1);
	}
}

public OnItemPostFrame_Pre(iWeapon)
{
	static iOwner;
	iOwner = entity_get_edict2(iWeapon, EV_ENT_owner);
	if(!LibTFC_Player_IsPlayer(iOwner))
	{
		return;
	}

	// Return if already reloading.
	if(LibTFC_Weapon_IsReloading(iWeapon))
	{
		return;
	}

	// Return if can't reload yet.
	if(LibTFC_Weapon_GetNextPrimaryAttack(iWeapon) >= 0 || LibTFC_Weapon_GetNextReload(iWeapon) >= 0)
	{
		return;
	}

	// Return if weapon doesn't use a clip, or if weapon is already fully loaded.
	if(!LibTFC_Weapon_UsesClip(iWeapon) || LibTFC_Weapon_IsFullyLoaded(iWeapon))
	{
		return;
	}

	// Set the player as pressing their reload key.
	entity_set_int(iOwner, EV_INT_button, entity_get_int(iOwner, EV_INT_button) | IN_RELOAD);

	// Use the button mask on the weapon to tell the weapons post frame we are trying to force reload.
	entity_set_int(iWeapon, EV_INT_button, entity_get_int(iWeapon, EV_INT_button) | IN_RELOAD);
}

public OnItemPostFrame_Post(iWeapon)
{
	// Return if not force reloading.
	if(!(entity_get_int(iWeapon, EV_INT_button) & IN_RELOAD))
	{
		return;
	}

	// Clear force reload bit.
	entity_set_int(iWeapon, EV_INT_button, entity_get_int(iWeapon, EV_INT_button) & ~IN_RELOAD);

	// Didn't end up reloading.
	if(!LibTFC_Weapon_IsReloading(iWeapon))
	{
		return;
	}

	switch(LibTFC_Weapon_GetId(iWeapon))
	{
		case TFC_WPNID_TF_SHOTGUN: LibTFC_Weapon_SendAnimation(iWeapon, SEQ_RELOAD_SHOTGUN);
		case TFC_WPNID_SUPER_SHOTGUN: LibTFC_Weapon_SendAnimation(iWeapon, SEQ_RELOAD_SUPER_SHOTGUN);
		case TFC_WPNID_GRENADE_LAUNCHER: LibTFC_Weapon_SendAnimation(iWeapon, SEQ_RELOAD_GRENADE_LAUNCHER);
		case TFC_WPNID_PIPEBOMB_LAUNCHER: LibTFC_Weapon_SendAnimation(iWeapon, SEQ_RELOAD_PIPE_LAUNCHER);
		case TFC_WPNID_ROCKET_LAUNCHER: LibTFC_Weapon_SendAnimation(iWeapon, SEQ_RELOAD_RPG);
	}
}
