#define PLUGIN_VERSION 		"1.00"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar g_hCvarAllow, g_hCvarMPGameMode, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarInfected, g_hCvarKeys, g_hCvarTimed, g_hCvarTimeout;
int g_iCvarInfected, g_iCvarKeys, g_iCvarTimed, g_iClassTank;
bool g_bCvarAllow, g_bLeft4Dead2;
float g_fCvarTimeout;



// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D & L4D2] Magnum Shove Fire",
	author = "lqthanh",
	description = "Ignites infected when shoved by players holding magnum.",
	version = PLUGIN_VERSION,
	url = ""
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test == Engine_Left4Dead ) g_bLeft4Dead2 = false;
	else if( test == Engine_Left4Dead2 ) g_bLeft4Dead2 = true;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_hCvarAllow = CreateConVar(		"l4d_shove_magnum_fire_allow",			"1",			"0=Plugin off, 1=Plugin on.", CVAR_FLAGS );
	g_hCvarModes = CreateConVar(		"l4d_shove_magnum_fire_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff = CreateConVar(		"l4d_shove_magnum_fire_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog = CreateConVar(		"l4d_shove_magnum_fire_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarInfected = CreateConVar(		"l4d_shove_magnum_fire_infected",		"511",			"Which infected to affect: 1=Common, 2=Witch, 4=Smoker, 8=Boomer, 16=Hunter, 32=Spitter, 64=Jockey, 128=Charger, 256=Tank, 511=All.", CVAR_FLAGS );
	g_hCvarKeys = CreateConVar(			"l4d_shove_magnum_fire_keys",			"1",			"Which key combination to use when shoving: 1=Shove key. 2=Reload + Shove keys.", CVAR_FLAGS );
	g_hCvarTimed = CreateConVar(		"l4d_shove_magnum_fire_timed",			"256",			"These infected use l4d_shove_magnum_fire_timeout, otherwise they burn forever. 0=None, 1=All, 2=Witch, 4=Smoker, 8=Boomer, 16=Hunter, 32=Spitter, 64=Jockey, 128=Charger, 256=Tank.", CVAR_FLAGS );
	g_hCvarTimeout = CreateConVar(		"l4d_shove_magnum_fire_timeout",		"10.0",			"0=Forever. How long should the infected be ignited for?", CVAR_FLAGS );
	CreateConVar(						"l4d_shove_magnum_fire_version",		PLUGIN_VERSION,	"Molotov Shove plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,				"l4d_shove_magnum_fire");

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarInfected.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarKeys.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTimed.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTimeout.AddChangeHook(ConVarChanged_Cvars);

	g_iClassTank = g_bLeft4Dead2 ? 9 : 6;
}

// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iCvarInfected = g_hCvarInfected.IntValue;
	g_iCvarKeys = g_hCvarKeys.IntValue;
	g_iCvarTimed = g_hCvarTimed.IntValue;
	g_fCvarTimeout = g_hCvarTimeout.FloatValue;
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;
		HookEvent("round_end", Event_RoundEnd);
		HookEvent("entity_shoved", Event_EntityShoved);
		HookEvent("player_shoved", Event_PlayerShoved);
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
		UnhookEvent("round_end", Event_RoundEnd);
		UnhookEvent("entity_shoved", Event_EntityShoved);
		UnhookEvent("player_shoved", Event_PlayerShoved);
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		g_iCurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if( IsValidEntity(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}

		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}

public void OnMapStart()
{
	
}

public void OnMapEnd()
{
	ResetPlugin();
}

void ResetPlugin()
{
	
}

// ====================================================================================================
//					EVENTS
// ====================================================================================================
void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!g_bCvarAllow || !IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	if (GetClientTeam(client) != 2 || !CheckWeapon(client))
		return;

	if (IsReloading(client))
		return;

	static bool lastPressed[MAXPLAYERS + 1];

	bool nowPressed = (buttons & IN_ATTACK2) != 0;

	if (nowPressed && !lastPressed[client])
	{
		DecreaseAmmo(client);
	}

	lastPressed[client] = nowPressed;
}

void Event_EntityShoved(Event event, const char[] name, bool dontBroadcast)
{
	int infected = g_iCvarInfected & (1<<0);
	int witch = g_iCvarInfected & (1<<1);
	if( infected || witch )
	{
		int client = GetClientOfUserId(event.GetInt("attacker"));

		if( g_iCvarKeys == 1 || GetClientButtons(client) & IN_RELOAD )
		{
			if( CheckWeapon(client) && !IsReloading(client))
			{
				int target = event.GetInt("entityid");

				char sTemp[32];
				GetEntityClassname(target, sTemp, sizeof(sTemp));

				if( infected && strcmp(sTemp, "infected") == 0 )
				{
					HurtPlayer(target, client, 0);
				}
				else if( witch && strcmp(sTemp, "witch") == 0 )
				{
					HurtPlayer(target, client, g_iCvarTimed == 1 || g_iCvarTimed & (1<<1));
				}
			}
		}
	}
}

void Event_PlayerShoved(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));

	if( g_iCvarKeys == 1 || GetClientButtons(client) & IN_RELOAD )
	{
		int target = GetClientOfUserId(event.GetInt("userid"));
		if( GetClientTeam(target) == 3 && CheckWeapon(client) && !IsReloading(client))
		{
			int class = GetEntProp(target, Prop_Send, "m_zombieClass") + 1;
			if( class == g_iClassTank ) class = 8;
			if( g_iCvarInfected & (1 << class) )
			{
				HurtPlayer(target, client, class);
			}
		}
	}
}

void HurtPlayer(int target, int client, int class)
{
	char sTemp[16];
	int entity = GetEntPropEnt(target, Prop_Data, "m_hEffectEntity");
	if( entity != -1 && IsValidEntity(entity) )
	{
		GetEntityClassname(entity, sTemp, sizeof(sTemp));
		if( strcmp(sTemp, "entityflame") == 0 )
		{
			return;
		}
	}

	SDKHooks_TakeDamage(target, client, client, 0.0, DMG_BURN);

	if( g_fCvarTimeout && g_iCvarTimed && class )
	{
		if( g_iCvarTimed == 1 || g_iCvarTimed & (1 << class) )
		{
			entity = GetEntPropEnt(target, Prop_Data, "m_hEffectEntity");
			if( entity != -1 )
			{
				GetEntityClassname(entity, sTemp, sizeof(sTemp));
				if( strcmp(sTemp, "entityflame") == 0 )
				{
					SetEntPropFloat(entity, Prop_Data, "m_flLifetime", GetGameTime() + g_fCvarTimeout);
				}
			}
		}
	}
}

bool CheckWeapon(int client)
{
	if( client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 )
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if( weapon > 0 && IsValidEntity(weapon) )
		{
			char sTemp[16];
			GetEntityClassname(weapon, sTemp, sizeof(sTemp));
			if( strncmp(sTemp[7], "pistol_magnum", 7) == 0 )
				return true;
		}
	}
	return false;
}

bool IsReloading(int client)
{
	if( client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client) )
		return false;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if( weapon <= 0 || !IsValidEntity(weapon) )
		return false;
		
	bool isReloading = GetEntProp(weapon, Prop_Send, "m_bInReload") != 0;
		
	int isEmptyClip = GetEntProp(weapon, Prop_Send, "m_iClip1") == 0;

	return isReloading || isEmptyClip;
}

void DecreaseAmmo(int client)
{
	if( client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client) )
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if( weapon <= 0 || !IsValidEntity(weapon) )
		return;

	char classname[64];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if( StrContains(classname, "pistol_magnum") != -1 )
	{
		int ammo = GetEntProp(weapon, Prop_Send, "m_iClip1");
		if( ammo > 1 )
		{
			SetEntProp(weapon, Prop_Send, "m_iClip1", ammo - 2);
		}
	}
}