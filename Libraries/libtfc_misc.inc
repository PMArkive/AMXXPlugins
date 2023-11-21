#if defined _libtfc_misc_included
  #endinput
#endif
#define _libtfc_misc_included




/**
 * Gets a class's default weapon flag bitmask.
 * These are the TFC_WPNFLAG_* values.
 *
 * @return					The class's default weapon flag bitmask.
 */
native LibTFC_Misc_GetClassDefaultWeaponFlags(PlayerClassTFC:class);


/**
 * Gets a team name for the specified team index.
 * 
 * @param team				A TFC_TEAM_* value.
 * @param team_name			Buffer to copy value to.
 * @param maxlength			Maximum buffer size.
 *
 * @return					Number of cells copied from the buffer.
 */
native LibTFC_Misc_GetTeamName(TeamTFC:team, team_name[], maxlength);


/**
 * A client print function that can pass arguments for localization text.
 * If you don't need to format a titles.txt string then you should probably use client_print() instead.
 * 
 * @param client			Client index, use 0 to display to all clients.
 * @param msg_dest			Message type, see print_* destination constants in amxconst.inc
 * @param message_text		The message text.
 * @param param1			Additional parameter to use for formatting the message_text. Ex: titles.txt arguments
 * @param param2			Additional parameter to use for formatting the message_text. Ex: titles.txt arguments
 * @param param3			Additional parameter to use for formatting the message_text. Ex: titles.txt arguments
 * @param param4			Additional parameter to use for formatting the message_text. Ex: titles.txt arguments
 *
 * @noreturn
 */
native LibTFC_Misc_ClientPrint(client=0, msg_dest=print_chat, message_text[]="", param1[]="", param2[]="", param3[]="", param4[]="");
