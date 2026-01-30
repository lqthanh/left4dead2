#if defined _l4d2_aim_down_sight_included_
	#endinput
#endif
#define _l4d2_aim_down_sight_included_

/**
 * Check if a client is currently in ADS (Aim Down Sight) mode.
 *
 * @param client    Client index
 * @return          True if client is in ADS mode, false otherwise
 * @error           Invalid client index or client not in game
 */
native bool l4d2_aim_down_sight_IsClientInADS(int client);

/**
 * Force a weapon to play a specific animation sequence.
 *
 * @param weapon    Weapon entity index
 * @param sequence  Sequence/activity number to play
 * @return          True on success, false otherwise
 * @error           Invalid weapon entity
 */
native bool l4d2_aim_down_sight_ForceWeaponAnimation(int weapon, int sequence);

/**
 * Set a client's ADS state.
 *
 * @param client    Client index
 * @param adsState  True to enter ADS mode, false to exit
 * @return          True on success, false otherwise
 * @error           Invalid client index or client not in game
 */
native bool l4d2_aim_down_sight_SetClientADSState(int client, bool adsState);

/**
 * Play an ADS animation for a weapon.
 * This will automatically convert normal activities to ADS activities.
 *
 * @param client    Client index holding the weapon
 * @param weapon    Weapon entity index
 * @param activity  Normal activity to play (will be converted to ADS version)
 * @return          True if animation was played, false otherwise
 * @error           Invalid client or weapon
 * @note            Client must be in ADS mode for this to work
 */
native bool l4d2_aim_down_sight_PlayADSAnimation(int client, int weapon, int activity);

/**
 * Get the ADS version of a normal activity.
 *
 * @param activity  Normal activity number
 * @return          Corresponding ADS activity number, or -1 if no mapping exists
 */
native int l4d2_aim_down_sight_GetADSActivity(int activity);

public SharedPlugin __pl_l4d2_aim_down_sight = 
{
	name = "l4d2_aim_down_sight",
	file = "l4d2_aim_down_sight.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_aim_down_sight_SetNTVOptional()
{
	MarkNativeAsOptional("l4d2_aim_down_sight_IsClientInADS");
	MarkNativeAsOptional("l4d2_aim_down_sight_ForceWeaponAnimation");
	MarkNativeAsOptional("l4d2_aim_down_sight_SetClientADSState");
	MarkNativeAsOptional("l4d2_aim_down_sight_PlayADSAnimation");
	MarkNativeAsOptional("l4d2_aim_down_sight_GetADSActivity");
}
#endif
