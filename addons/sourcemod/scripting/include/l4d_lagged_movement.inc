#if defined  _l4d_lagged_movement_included_
 #endinput
#endif
#define _l4d_lagged_movement_included_

/**
 * @brief Given the requested value, returns the required value to set considering all plugins wanting to set the m_flLaggedMovementValue value.
 * @remarks The last plugin requesting this value in the same frame will be the one writing the value.
 * @remarks Typically plugins set the m_flLaggedMovementValue in a PreThinkPost function.
 *
 * @notes Highly suggest viewing "Weapons Movement Speed" plugin by "Silvers" and adding the "Fix movement speed bug when jumping or staggering" code
 * @notes from that plugin to your plugins PreThinkPost function before setting the m_flLaggedMovementValue value. This fixes bugs with the m_flLaggedMovementValue
 * @Notes causing player to jump faster or slower when the value is changed from 1.0.
 *
 * @Notes View the "Weapons Movement Speed" plugin source to make this plugin optionally used if detected.
 * @Notes Example code usage: SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", L4D_LaggedMovement(client, 2.0));
 *
 * @param client	Client index of the person we're changing the speed value on
 * @param value		The speed we want to set on this player
 * @param forced	If forcing the value it will override all other plugins setting the value
 *
 * @return			The speed value we need to set
 */
native float L4D_LaggedMovement(int client, float value, bool forced = false);