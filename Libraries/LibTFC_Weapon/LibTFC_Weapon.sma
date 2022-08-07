#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include "../libtfc_weapon"
#include "../libtfc_player"

#define PLUGIN "Lib TFC: Weapon"
#define VERSION "0.3"
#define AUTHOR "hlstriker"


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("libtfc_weapon_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY);
}

public plugin_natives()
{
	register_library("libtfc_weapon");
	
	register_native("LibTFC_Weapon_GetSlot", "_LibTFC_Weapon_GetSlot");
	register_native("LibTFC_Weapon_GetPosition", "_LibTFC_Weapon_GetPosition");
	register_native("LibTFC_Weapon_GetPrimaryAmmoName", "_LibTFC_Weapon_GetPrimaryAmmoName");
	register_native("LibTFC_Weapon_GetPrimaryAmmoMax", "_LibTFC_Weapon_GetPrimaryAmmoMax");
	register_native("LibTFC_Weapon_GetSecondaryAmmoName", "_LibTFC_Weapon_GetSecondaryAmmoName");
	register_native("LibTFC_Weapon_GetSecondaryAmmoMax", "_LibTFC_Weapon_GetSecondaryAmmoMax");
	register_native("LibTFC_Weapon_GetName", "_LibTFC_Weapon_GetName");

	register_native("LibTFC_Weapon_SetRoundsRemaining", "_LibTFC_Weapon_SetRoundsRemaining");
	register_native("LibTFC_Weapon_GetRoundsRemaining", "_LibTFC_Weapon_GetRoundsRemaining");
	register_native("LibTFC_Weapon_GetClipSizeMax", "_LibTFC_Weapon_GetClipSizeMax");
	register_native("LibTFC_Weapon_UsesClip", "_LibTFC_Weapon_UsesClip");
	register_native("LibTFC_Weapon_IsFullyLoaded", "_LibTFC_Weapon_IsFullyLoaded");

	register_native("LibTFC_Weapon_GetId", "_LibTFC_Weapon_GetId");
	register_native("LibTFC_Weapon_GetFlags", "_LibTFC_Weapon_GetFlags");
	register_native("LibTFC_Weapon_GetWeight", "_LibTFC_Weapon_GetWeight");

	register_native("LibTFC_Weapon_IsReloading", "_LibTFC_Weapon_IsReloading");

	register_native("LibTFC_Weapon_SetNextPrimaryAttack", "_LibTFC_Weapon_SetNextPrimaryAttack");
	register_native("LibTFC_Weapon_GetNextPrimaryAttack", "_LibTFC_Weapon_GetNextPrimaryAttack");

	register_native("LibTFC_Weapon_SetNextReload", "_LibTFC_Weapon_SetNextReload");
	register_native("LibTFC_Weapon_GetNextReload", "_LibTFC_Weapon_GetNextReload");

	register_native("LibTFC_Weapon_SendAnimation", "_LibTFC_Weapon_SendAnimation");
}


public _LibTFC_Weapon_SendAnimation(iPlugin, iParams)
{
	new iWeapon = get_param(1);
	new iOwner = entity_get_edict2(iWeapon, EV_ENT_owner);
	if(!LibTFC_Player_IsPlayer(iOwner))
	{
		return false;
	}

	new iAnim = get_param(2);
	entity_set_int(iOwner, EV_INT_weaponanim, iAnim);

	message_begin_f(MSG_ONE, SVC_WEAPONANIM, _, iOwner);
	write_byte(iAnim);
	write_byte(entity_get_int(iWeapon, EV_INT_body));
	message_end();
	
	return true;
}


public _LibTFC_Weapon_GetWeight(iPlugin, iParams)
{
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	new iInfo = GetHamItemInfo(itemInfo, Ham_ItemInfo_iWeight);
	FreeHamItemInfo(itemInfo);

	return iInfo;
}


public _LibTFC_Weapon_GetFlags(iPlugin, iParams)
{
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	new iInfo = GetHamItemInfo(itemInfo, Ham_ItemInfo_iFlags);
	FreeHamItemInfo(itemInfo);

	return iInfo;
}


public _LibTFC_Weapon_GetSecondaryAmmoMax(iPlugin, iParams)
{
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	new iInfo = GetHamItemInfo(itemInfo, Ham_ItemInfo_iMaxAmmo2);
	FreeHamItemInfo(itemInfo);

	return iInfo;
}


public _LibTFC_Weapon_GetPrimaryAmmoMax(iPlugin, iParams)
{
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	new iInfo = GetHamItemInfo(itemInfo, Ham_ItemInfo_iMaxAmmo1);
	FreeHamItemInfo(itemInfo);

	return iInfo;
}


public _LibTFC_Weapon_GetPosition(iPlugin, iParams)
{
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	new iInfo = GetHamItemInfo(itemInfo, Ham_ItemInfo_iPosition);
	FreeHamItemInfo(itemInfo);

	return iInfo;
}


public _LibTFC_Weapon_GetSlot(iPlugin, iParams)
{
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	new iInfo = GetHamItemInfo(itemInfo, Ham_ItemInfo_iSlot);
	FreeHamItemInfo(itemInfo);

	return iInfo;
}


public WeaponTFC:_LibTFC_Weapon_GetId(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBasePlayerItem", "m_iId");
}


public _LibTFC_Weapon_GetRoundsRemaining(iPlugin, iParams)
{
	return get_ent_data(get_param(1), "CBasePlayerWeapon", "m_iClip");
}

public _LibTFC_Weapon_SetRoundsRemaining(iPlugin, iParams)
{
	set_ent_data(get_param(1), "CBasePlayerWeapon", "m_iClip", get_param(2));
}

public _LibTFC_Weapon_GetClipSizeMax(iPlugin, iParams)
{
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	new iInfo = GetHamItemInfo(itemInfo, Ham_ItemInfo_iMaxClip);
	FreeHamItemInfo(itemInfo);

	return iInfo;
}

public _LibTFC_Weapon_UsesClip(iPlugin, iParams)
{
	return LibTFC_Weapon_GetClipSizeMax(get_param(1)) > 0;
}

public _LibTFC_Weapon_IsFullyLoaded(iPlugin, iParams)
{
	new iWeapon = get_param(1);
	return LibTFC_Weapon_GetRoundsRemaining(iWeapon) >= LibTFC_Weapon_GetClipSizeMax(iWeapon);
}


public _LibTFC_Weapon_SetNextPrimaryAttack(iPlugin, iParams)
{
	return set_ent_data_float(get_param(1), "CBasePlayerWeapon", "m_flNextPrimaryAttack", get_param_f(2));
}

public Float:_LibTFC_Weapon_GetNextPrimaryAttack(iPlugin, iParams)
{
	return get_ent_data_float(get_param(1), "CBasePlayerWeapon", "m_flNextPrimaryAttack");
}


public _LibTFC_Weapon_IsReloading(iPlugin, iParams)
{
	new iWeapon = get_param(1);
	return get_ent_data(iWeapon, "CBasePlayerWeapon", "m_fInReload") || get_ent_data(iWeapon, "CBasePlayerWeapon", "m_fInSpecialReload");
}


public _LibTFC_Weapon_GetPrimaryAmmoName(iPlugin, iParams)
{
	static szInfo[32];
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	GetHamItemInfo(itemInfo, Ham_ItemInfo_pszAmmo1, szInfo, charsmax(szInfo));
	FreeHamItemInfo(itemInfo);

	return set_string(2, szInfo, get_param(3));
}

public _LibTFC_Weapon_GetSecondaryAmmoName(iPlugin, iParams)
{
	static szInfo[32];
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	GetHamItemInfo(itemInfo, Ham_ItemInfo_pszAmmo2, szInfo, charsmax(szInfo));
	FreeHamItemInfo(itemInfo);

	return set_string(2, szInfo, get_param(3));
}

public _LibTFC_Weapon_GetName(iPlugin, iParams)
{
	static szInfo[32];
	new itemInfo = CreateHamItemInfo();
	ExecuteHam(Ham_Item_GetItemInfo, get_param(1), itemInfo);
	GetHamItemInfo(itemInfo, Ham_ItemInfo_pszName, szInfo, charsmax(szInfo));
	FreeHamItemInfo(itemInfo);

	return set_string(2, szInfo, get_param(3));
}


public _LibTFC_Weapon_SetNextReload(iPlugin, iParams)
{
	return set_ent_data_float(get_param(1), "CBasePlayerWeapon", "m_flNextReload", get_param_f(2));
}

public Float:_LibTFC_Weapon_GetNextReload(iPlugin, iParams)
{
	return get_ent_data_float(get_param(1), "CBasePlayerWeapon", "m_flNextReload");
}
