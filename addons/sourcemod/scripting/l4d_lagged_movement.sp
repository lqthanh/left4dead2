/*
*	Lagged Movement - Plugin Conflict Resolver
*	Copyright (C) 2022 Silvers
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/



#define PLUGIN_VERSION 		"1.0.LQT"

/*======================================================================================
	Plugin Info:

*	Name	:	[L4D & L4D2] Lagged Movement - Plugin Conflict Resolver
*	Author	:	SilverShot
*	Descrp	:	Fixes plugins fighting over the m_flLaggedMovementValue datamap value.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=340345
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.0.LQT (17-Feb-2026)
	- Implement inc.

1.0 (12-Nov-2022)
	- Initial release.

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>

#define CVAR_FLAGS			FCVAR_NOTIFY


ConVar g_hCvarType;
int g_iCvarType, g_iFrame;
float g_fValues[MAXPLAYERS+1];
bool g_bForced[MAXPLAYERS+1];

// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D & L4D2] Lagged Movement - Plugin Conflict Resolver",
	author = "SilverShot",
	description = "Fixes plugins fighting over the m_flLaggedMovementValue netprop value.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=340345"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	CreateNative("L4D_LaggedMovement", Native_LaggedMovement);

	RegPluginLibrary("LaggedMovement");

	return APLRes_Success;
}

public void OnPluginStart()
{
	g_hCvarType = CreateConVar("l4d_lagged_movement_type", "1", "When plugins compete to set a players speed value should the final value be: 1=Average of both. 2=Combined value added from both.", CVAR_FLAGS);
	CreateConVar("l4d_lagged_movement_version", PLUGIN_VERSION, "Lagged Movement - Plugin Conflict Resolver plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true, "l4d_lagged_movement");

	g_hCvarType.AddChangeHook(ConVarChanged_Cvars);
}

public void OnMapEnd()
{
	g_iFrame = 0;
}

public void OnConfigsExecuted()
{
	GetCvars();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iCvarType = g_hCvarType.IntValue;
}

any Native_LaggedMovement(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float value = GetNativeCell(2);
	bool force = GetNativeCell(3);

	// Reset vars on new tick
	int frame = GetGameTickCount();
	if( g_iFrame != frame )
	{
		g_iFrame = frame;

		for( int i = 1; i <= MaxClients; i++ )
		{
			g_fValues[i] = 1.0;
			g_bForced[i] = false;
		}
	}

	// Force value?
	if( force )
	{
		g_bForced[client] = true;
		g_fValues[client] = value;
	}
	else if( !g_bForced[client] ) // Prevent setting if value has been forced
	{
		// Default value, set new value
		if( g_fValues[client] == 1.0 )
		{
			g_fValues[client] = value;
		}
		// Value set, add multiplier and divide to get average result
		else if( value != 1.0 )
		{
			if( g_iCvarType == 1 )
				g_fValues[client] = (g_fValues[client] + value) / 2;
			else
				g_fValues[client] += value;
		}
	}

	// Test output:
	// PrintToChatAll("%d %f %N", GetGameTickCount(), g_fValues[client], client);

	// Return value for plugins to set, last one setting will set the average request from other plugins
	return g_fValues[client];
}