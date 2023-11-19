#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <orpheu>
#include "../libtfc_const.inc"
#include "../libtfc_misc.inc"

#define PLUGIN "Lib TFC: Misc"
#define VERSION "0.1"
#define AUTHOR "hlstriker"


new OrpheuFunction:g_OrphFunc_GetTeamName;

new g_msgID_TextMsg;


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("libtfc_misc_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	
	g_msgID_TextMsg = get_user_msgid("TextMsg");
	
	g_OrphFunc_GetTeamName = OrpheuGetFunction("GetTeamName");	// sub_3007B9A0
}

public plugin_natives()
{
	register_library("libtfc_misc");
	
	register_native("LibTFC_Misc_GetClassDefaultWeaponFlags", "_LibTFC_Misc_GetClassDefaultWeaponFlags");
	register_native("LibTFC_Misc_GetTeamName", "_LibTFC_Misc_GetTeamName");
	register_native("LibTFC_Misc_ClientPrint", "_LibTFC_Misc_ClientPrint");
}



public _LibTFC_Misc_GetClassDefaultWeaponFlags(iPlugin, iParams)
{
	new PlayerClassTFC:class = PlayerClassTFC:get_param(1);
	
	switch(class)
	{
		case TFC_CLASS_SCOUT:		return TFC_WPNFLAG_AXE | TFC_WPNFLAG_SHOTGUN | TFC_WPNFLAG_NAILGUN;
		case TFC_CLASS_SNIPER:		return TFC_WPNFLAG_AXE | TFC_WPNFLAG_SNIPER_RIFLE | TFC_WPNFLAG_AUTO_RIFLE | TFC_WPNFLAG_NAILGUN;
		case TFC_CLASS_SOLDIER:		return TFC_WPNFLAG_AXE | TFC_WPNFLAG_SHOTGUN | TFC_WPNFLAG_SUPER_SHOTGUN | TFC_WPNFLAG_ROCKET_LAUNCHER;
		case TFC_CLASS_DEMOMAN:		return TFC_WPNFLAG_AXE | TFC_WPNFLAG_SHOTGUN | TFC_WPNFLAG_GRENADE_LAUNCHER | TFC_WPNFLAG_DETPACK;
		case TFC_CLASS_MEDIC:		return TFC_WPNFLAG_BIOWEAPON | TFC_WPNFLAG_MEDIKIT | TFC_WPNFLAG_SHOTGUN | TFC_WPNFLAG_SUPER_SHOTGUN | TFC_WPNFLAG_SUPER_NAILGUN;
		case TFC_CLASS_HWGUY:		return TFC_WPNFLAG_AXE | TFC_WPNFLAG_SHOTGUN | TFC_WPNFLAG_SUPER_SHOTGUN | TFC_WPNFLAG_ASSAULT_CANNON;
		case TFC_CLASS_PYRO:		return TFC_WPNFLAG_AXE | TFC_WPNFLAG_SHOTGUN | TFC_WPNFLAG_FLAMETHROWER | TFC_WPNFLAG_INCENDIARY;
		case TFC_CLASS_SPY:			return TFC_WPNFLAG_AXE | TFC_WPNFLAG_SUPER_SHOTGUN | TFC_WPNFLAG_NAILGUN | TFC_WPNFLAG_TRANQ;
		case TFC_CLASS_ENGINEER:	return TFC_WPNFLAG_SPANNER | TFC_WPNFLAG_SUPER_SHOTGUN | TFC_WPNFLAG_RAILGUN;
		case TFC_CLASS_CIVILIAN:	return TFC_WPNFLAG_AXE;
	}
	
	return TFC_WPNFLAG_NONE;
}


public _LibTFC_Misc_GetTeamName(iPlugin, iParams)
{
	new TeamTFC:team = TeamTFC:get_param(1);
	
	if(team < TeamTFC:0 || team > TeamTFC:4)
		return set_string(2, "", get_param(3));
	
	if(team == TFC_TEAM_SPECTATE)
		return set_string(2, "SPECTATOR", get_param(3));
	
	static szTeamName[32];
	OrpheuCall(g_OrphFunc_GetTeamName, _:team, szTeamName, charsmax(szTeamName));
	
	return set_string(2, szTeamName, get_param(3));
}


public _LibTFC_Misc_ClientPrint(iPlugin, iParams)
{
	static szMessageName[192], szParam1[192], szParam2[192], szParam3[192], szParam4[192];
	get_string(3, szMessageName, charsmax(szMessageName));
	get_string(4, szParam1, charsmax(szParam1));
	get_string(5, szParam2, charsmax(szParam2));
	get_string(6, szParam3, charsmax(szParam3));
	get_string(7, szParam4, charsmax(szParam4));
	
	UTIL_ClientPrint(get_param(1), get_param(2), szMessageName, szParam1, szParam2, szParam3, szParam4);
}

UTIL_ClientPrint(iClient=0, iMsgDest=print_chat, szMessageName[]="", szParam1[]="", szParam2[]="", szParam3[]="", szParam4[]="")
{
	message_begin(iClient ? MSG_ONE : MSG_ALL, g_msgID_TextMsg, {0,0,0}, iClient);
	write_byte(iMsgDest);
	write_string(szMessageName);
	
	if(szParam1[0])
		write_string(szParam1);
	
	if(szParam2[0])
		write_string(szParam2);
	
	if(szParam3[0])
		write_string(szParam3);
	
	if(szParam4[0])
		write_string(szParam4);
	
	message_end();
}