#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include "../../Libraries/libtfc_weapon"


new const PLUGIN[] = "Auto Reload";
new const VERSION[] = "1.0";
new const AUTHOR[] = "hlstriker";


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
		RegisterHam(Ham_Item_PostFrame, SZ_WEAPONS_WITH_CLIP[i], "OnItemPostFrame_Post", 1);
	}
}

public OnItemPostFrame_Post(iWeapon)
{
	// Return if already reloading.
	if(LibTFC_Weapon_IsReloading(iWeapon))
	{
		return;
	}

	// Return if can't reload yet.
	if(LibTFC_Weapon_GetNextPrimaryAttack(iWeapon) >= 0)
	{
		return;
	}

	// Return if weapon doesn't use a clip, or if weapon is already fully loaded.
	if(!LibTFC_Weapon_UsesClip(iWeapon) || LibTFC_Weapon_IsFullyLoaded(iWeapon))
	{
		return;
	}

	ExecuteHam(Ham_Weapon_Reload, iWeapon);
}
