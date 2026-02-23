#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <dhooks>
#include <left4dhooks>

#define PLUGIN_VERSION "1.3h-2025/10/8"
public Plugin myinfo =
{
	name = "[L4D2] Full Auto Scar",
	author = "Miuwiki, Harry",
	description = "Full auto fire mode for Scar",
	version = PLUGIN_VERSION,
	url = "http://www.miuwiki.site"
}

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	RegPluginLibrary("miuwiki_autoscar");

	CreateNative("miuwiki_IsClientHoldAutoScar",			Native_IsClientHoldAutoScar);
	CreateNative("miuwiki_GetAutoScarSwitchTime",			Native_GetAutoScarSwitchTime);
	CreateNative("miuwiki_GetAutoPrimaryAttackTime",		Native_GetAutoScarPrimaryAttackTime);
	CreateNative("miuwiki_GetAutoSecondaryAttackTime",		Native_GetAutoScarSecondaryAttackTime);

	bLate = late;
	return APLRes_Success;
}

#define GAMEDATA "l4d2_aim_down_sight_fix"

#define SHOOT_EMPTY 			"weapons/clipempty_rifle.wav"
#define ZOOM_Sound 				"weapons/hunting_rifle/gunother/hunting_rifle_zoom.wav"
#define DEFAULT_ATTACK2_TIME 	0.4

#define SCAR_WORLD_MODEL 		"models/w_models/weapons/w_desert_rifle.mdl"
#define SWITCH_SEQUENCE 		4

int
	g_scar_precache_index,
	g_Offset_BrustAttackTime;

Handle
	g_SDKCall_SeondaryAttack,
	g_SDKCall_PrimaryAttack,
	g_SDKCall_CanAttack;

DynamicHook
	g_DynamicHook_ItemPostFrame;

StringMap
	g_WeaponHookIds; // Map weapon entity index -> hookid

ConVar
	cvar_l4d2_scar_cycletime;

enum struct GlobalConVar
{
	float scarcycletime;
}
GlobalConVar
	cvar;

enum struct PlayerData
{
	bool  fullautomode;
	bool  needrelease;
	bool  inzoom;
	bool  pendingDisableAuto;

	int   animcount;
	int   lastAction;
	float primaryattacktime;
	float secondaryattacktime;
	float switchendtime;
	
	// Per-player weapon attributes
	float cycleTime;
	char  weaponClass[64];
}
PlayerData
	player[MAXPLAYERS + 1];

bool 
	g_bADSPluginAvailable = false;

public void OnPluginStart()
{
	g_WeaponHookIds = new StringMap();
	g_bADSPluginAvailable = LibraryExists("l4d2_aim_down_sight");
	LoadGameData();
	cvar_l4d2_scar_cycletime    = CreateConVar("l4d2_aim_down_sight_fix_cycletime", "0.11", "Auto fire cycle time. [min 0.03, 0=Same as weapon default cycle time]", FCVAR_NOTIFY, true, 0.0);

	GetCvars();
	cvar_l4d2_scar_cycletime.AddChangeHook(ConVarChanged_Cvars);

	AutoExecConfig(true, "l4d2_aim_down_sight_fix");

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	
	if(bLate)
	{
		LateLoad();
	}
}

void LoadGameData()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAMEDATA);
	if( !FileExists(sPath) ) 
		SetFailState("\n==========\nMissing required file: \"%s\".\n==========", sPath);

	GameData hGameData = new GameData(GAMEDATA);
	if(hGameData == null) 
		SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

	char func[256];
	FormatEx(func, sizeof(func), "CTerrorGun::PrimaryAttack");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, func);
	if( !(g_SDKCall_PrimaryAttack = EndPrepSDKCall()) )
		SetFailState("failed to start sdkcall \"%s\"", func);
	
	FormatEx(func, sizeof(func), "CTerrorWeapon::SecondaryAttack");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, func);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if( !(g_SDKCall_SeondaryAttack = EndPrepSDKCall()) )
		SetFailState("failed to start sdkcall \"%s\"", func);

	FormatEx(func, sizeof(func), "CTerrorPlayer::CanAttack");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, func);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if( !(g_SDKCall_CanAttack = EndPrepSDKCall()) )
		SetFailState("failed to start sdkcall \"%s\"", func);

	FormatEx(func, sizeof(func), "CTerrorGun::ItemPostFrame");
	g_DynamicHook_ItemPostFrame = DynamicHook.FromConf(hGameData, func);
	if( !g_DynamicHook_ItemPostFrame )
		SetFailState("Failed to start dynamic hook about \"%s\".", func);

	g_Offset_BrustAttackTime = hGameData.GetOffset("ScarBrustTime");
	delete hGameData;
}

void LateLoad()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client))
			continue;

		// Initialize player data for late load since OnClientConnected won't be called
		player[client].fullautomode = false;

		OnClientPutInServer(client);
	}

    // Hook weapons for players already in auto mode
    int entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, "weapon_rifle_desert")) != INVALID_ENT_REFERENCE)
    {
        if (!IsValidEntity(entity))
            continue;

        // g_DynamicHook_ItemPostFrame.HookEntity(Hook_Post, entity, DhookCallback_ItemPostFrame);

        int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
        if (owner > 0 && owner <= MaxClients && IsClientInGame(owner) && player[owner].fullautomode)
        {
            HookWeapon(entity);
        }
    }
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

public void OnConfigsExecuted()
{
	GetCvars();
}

void GetCvars()
{
	cvar.scarcycletime 		= cvar_l4d2_scar_cycletime.FloatValue;
}

public void OnAllPluginsLoaded()
{
	g_bADSPluginAvailable = LibraryExists("l4d2_aim_down_sight");
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "l4d2_aim_down_sight"))
	{
		g_bADSPluginAvailable = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(StrEqual(name, "l4d2_aim_down_sight"))
	{
		g_bADSPluginAvailable = false;
	}
}

public void OnMapStart()
{
	PrecacheSound(SHOOT_EMPTY);
	PrecacheSound(ZOOM_Sound);
	g_scar_precache_index = PrecacheModel(SCAR_WORLD_MODEL);
}

public void OnClientConnected(int client)
{
	if( IsFakeClient(client) )
		return;
	
	player[client].inzoom				= false;
	player[client].fullautomode			= false;
	player[client].needrelease			= false;
	player[client].pendingDisableAuto	= false;

	player[client].animcount			= 0;
	player[client].lastAction			= 0; // 0=When survivors are unable to move, 1=When switching to automatic mode or when cutting the gun, 2=No modifications
	player[client].primaryattacktime	= 0.0;
	player[client].secondaryattacktime	= 0.0;
	player[client].switchendtime		= 0.0;
	
	// Initialize weapon attributes with defaults
	player[client].cycleTime			= 0.0;
}

public void OnClientPutInServer(int client)
{
	if( IsFakeClient(client) )
		return;
	
	SDKHook(client, SDKHook_WeaponSwitchPost, SDKCallback_SwitchDesert);
	SDKHook(client, SDKHook_PostThink, SDKCallback_OnClientPostThink);
}

//Triggered when switching weapons
//Triggered when scroll wheel or Q switches weapons
void SDKCallback_SwitchDesert(int client, int weapon)
{
	if (GetClientTeam(client) != 2) {
		return;
	}

	if( weapon < 1 || !IsValidEntity(weapon) )
		return;

	// Load weapon attributes for this player's current weapon
	LoadPlayerWeaponAttributes(client, weapon);

	if( player[client].fullautomode )
	{
		// since predict will cause sound problem and no ammo trace, we predict scar whatever which mode it use.
		SetEntProp(client, Prop_Data, "m_bPredictWeapons", 0);
		// Hook weapon when in auto mode
		HookWeapon(weapon);
	}
	else
	{
		SetEntProp(client, Prop_Data, "m_bPredictWeapons", 1);
		// Unhook weapon when in triple tap mode to reduce overhead
		UnHookWeapon(weapon);
	}
}

void SDKCallback_OnClientPostThink(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if( weapon < 1 || !IsValidEntity(weapon) )
		return;

	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if( viewmodel < 1 || !IsValidEntity(viewmodel) )
		return;

	int animcount = GetEntProp(viewmodel, Prop_Send, "m_nAnimationParity");
	if( player[client].fullautomode
		&& player[client].animcount != animcount 
		&& GetEntProp(viewmodel, Prop_Send, "m_nLayerSequence") == SWITCH_SEQUENCE )
	{
		player[client].lastAction = 1;
		player[client].needrelease = true;
		player[client].switchendtime = GetGameTime() + 0.97;
	}

	player[client].animcount = animcount;
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for(int i = 0; i <= MaxClients; i++)
	{
		player[i].lastAction			= 0;
		player[i].primaryattacktime		= 0.0;
		player[i].secondaryattacktime	= 0.0;
		player[i].switchendtime			= 0.0;
	}
}

/**
 * this function trigger when player holding scar
 * -This function will only be triggered when holding a scar rifle.
 * -It will be triggered when climbing a ladder, and it will be triggered when being knocked away.
 * -The machine gun on map will not trigger when holding
 * -It does not trigger when being dragged away by Smoker.
 * -Being controlled by SI will trigger
 */
MRESReturn DhookCallback_ItemPostFrame(int pThis)
{
	int client = GetEntPropEnt(pThis, Prop_Send, "m_hOwnerEntity");
	if( client < 1 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client) )
		return MRES_Ignored;

	if( !player[client].fullautomode ) // although we are not in automode, but we have weapon on hand so set the tickcount/
	{
		player[client].lastAction = 0;
		return MRES_Ignored;
	}

	if( GetEntProp(pThis, Prop_Send, "m_iWorldModelIndex") == g_scar_precache_index )
	{
		for(int i = 0; i < 3; i++)
		{
			//使用StoreToAddress 換圖時有機率會導致崩潰 crash: tier0.dll + 0x1991d
			//StoreToAddress(temp + view_as<Address>(4 * i), 0, NumberType_Int32);

			SetEntData(pThis, g_Offset_BrustAttackTime + (4 * i), 0);
		}
	}

	int clip             = GetEntProp(pThis, Prop_Send, "m_iClip1");
	float currenttime    = GetGameTime();

	SetEntPropFloat(pThis, Prop_Send, "m_flNextPrimaryAttack", currenttime + 100);
	SetEntPropFloat(pThis, Prop_Send, "m_flNextSecondaryAttack", currenttime + 100);
	

	if(player[client].lastAction == 0)
	{
		player[client].needrelease = true;
		player[client].switchendtime = currenttime + 0.3;
		player[client].lastAction	= 2;
		SetEntProp(client, Prop_Data, "m_bPredictWeapons", 0);
		
		return MRES_Ignored;
	}
	else if( player[client].lastAction == 1 ) 
	{
		player[client].needrelease = true;
		player[client].lastAction	= 2;
		SetEntProp(client, Prop_Data, "m_bPredictWeapons", 0);
		return MRES_Ignored;
	}
	else
	{
		if(IsGettingUp(client) || IsClientOnLadder(client))
		{
			player[client].lastAction	= 0;
			SetEntProp(client, Prop_Data, "m_bPredictWeapons", 0);
			
			return MRES_Ignored;
		}
	}

	static int button;
	button = GetClientButtons(client);
	// seondary first
	if( (button & IN_ATTACK2) && CanSecondaryAttack(client) )
	{
		if( currenttime > player[client].secondaryattacktime )
		{
			// PrintToChat(client, "attacking, time %f", currenttime);
			SetEntPropFloat(pThis, Prop_Send, "m_flNextSecondaryAttack", currenttime);
			SDKCall(g_SDKCall_SeondaryAttack, pThis);
			player[client].secondaryattacktime = currenttime + DEFAULT_ATTACK2_TIME;
		}
		return MRES_Ignored; // ignore in_attack and in_reload when pushing pushing.
	}

	if( (button & IN_ATTACK) && CanPrimaryAttack(client, clip) )
	{
		if( currenttime > player[client].primaryattacktime
			&& currenttime > player[client].secondaryattacktime ) // not allow in attack2
		{
			SetEntPropFloat(pThis, Prop_Send, "m_flNextPrimaryAttack", currenttime);
			SDKCall(g_SDKCall_PrimaryAttack, pThis);
			SetEntPropFloat(pThis, Prop_Send, "m_flNextPrimaryAttack", currenttime + 100.0);
			
			// Determine cycle time: SCAR uses cvar if > 0, others use weapon default
			float nextAttackTime;
			if(cvar.scarcycletime > 0.0 && StrEqual(player[client].weaponClass, "weapon_rifle_desert"))
			{
				nextAttackTime = cvar.scarcycletime;
				PrintToServer("[AutoWeapon] Fire (SCAR custom): nextAttack in %.3fs", nextAttackTime);
			}
			else if(player[client].cycleTime > 0.0)
			{
				nextAttackTime = player[client].cycleTime;
				PrintToServer("[AutoWeapon] Fire (weapon default): nextAttack in %.3fs (cycleTime: %.3f)", 
					nextAttackTime, player[client].cycleTime);
			}
			else
			{
				nextAttackTime = 0.1; // Emergency fallback
				PrintToServer("[AutoWeapon] WARNING: Invalid cycleTime, using fallback 0.1");
			}
			
			player[client].primaryattacktime = currenttime + nextAttackTime;
		}
		return MRES_Ignored; // ignore IN_RELOAD when pushing attack button.
	}


	int reserverammo = L4D_GetReserveAmmo(client, pThis);
	
	// When player presses reload button or auto-reload triggers (empty clip), 
	// set flag to disable auto mode safely outside of this callback
	if( (button & IN_RELOAD) || (clip == 0 && reserverammo > 0 && currenttime > player[client].secondaryattacktime) )
	{
		// Set flag to disable auto mode (will be processed in OnPlayerRunCmd)
		player[client].pendingDisableAuto = true;
		
		// Reset attack timings to allow normal game reload behavior
		SetEntPropFloat(pThis, Prop_Send, "m_flNextPrimaryAttack", currenttime);
		SetEntPropFloat(pThis, Prop_Send, "m_flNextSecondaryAttack", currenttime);
		
		PrintToServer("[AutoWeapon] Reload detected - will disable auto mode");
		
		// Return and let game engine handle the reload
		return MRES_Ignored;
	}

	return MRES_Ignored;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity))
		return;
}

// fix that keeping press IN_ATTACK before switch weapon will not fire again after switch complete. 
public Action OnPlayerRunCmd(int client, int &buttons)
{
	// Handle pending auto mode disable (from reload)
	if( player[client].pendingDisableAuto )
	{
		if( IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2 )
		{
			int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if( active_weapon > 0 && IsValidEntity(active_weapon) )
			{
				// Safely disable auto mode outside of weapon callback
				player[client].fullautomode = false;
				player[client].lastAction = 0;
				
				// Unhook weapon
				UnHookWeapon(active_weapon);
				
				// Re-enable prediction
				SetEntProp(client, Prop_Data, "m_bPredictWeapons", 1);
				
				PrintToServer("[AutoWeapon] Auto mode disabled - switched to normal reload");
			}
		}
		player[client].pendingDisableAuto = false;
	}
	
	if( !player[client].needrelease )
		return Plugin_Continue;
	
	if( !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2 )
		return Plugin_Continue;
	
	buttons &= ~(IN_ATTACK|IN_RELOAD);
	player[client].needrelease = false;


	return Plugin_Changed;
}

public void OnPlayerRunCmdPost(int client, int buttons)
{
	if( !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2 )
		return;

	if (IsUsingMinigun(client))
	{
		player[client].lastAction = 0;
		return;
	}

	// Toggle auto mode with ZOOM button (524288)
	if( buttons & 524288 )
	{
		if( player[client].inzoom )
			return;
		
		int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if( active_weapon < 1 || !IsValidEntity(active_weapon) )
			return;

		float now = GetGameTime();
		if(player[client].fullautomode)
		{
			if(player[client].switchendtime > now)
			{
				return;
			}
		}
		else
		{
			if(GetEntPropFloat(active_weapon, Prop_Data, "m_flNextPrimaryAttack") >= GetGameTime())
			{
				return;
			}
		}

		player[client].inzoom = true;
		player[client].fullautomode = !player[client].fullautomode;
		PlaySoundAroundClient(client, ZOOM_Sound);
		if( !player[client].fullautomode )
		{
			SetEntPropFloat(active_weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.1);
			SetEntPropFloat(active_weapon, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 0.2);

			SetEntProp(client, Prop_Data, "m_bPredictWeapons", 1);
			player[client].lastAction = 0;
			// Unhook to reduce server overhead
			UnHookWeapon(active_weapon);
		}
		else
		{
			SetEntProp(client, Prop_Data, "m_bPredictWeapons", 0);
			player[client].lastAction = 1;
			player[client].needrelease = true;
			player[client].switchendtime = GetGameTime() + 0.2;
			// Hook only when in auto mode
			HookWeapon(active_weapon);
		}
	}
	else
	{
		player[client].inzoom = false;
	}
}

// ============================================================================
// Helper
// ============================================================================

bool CanSecondaryAttack(int client)
{
	if( !SDKCall(g_SDKCall_CanAttack, client) )
		return false;
	
	return true;
}

bool CanPrimaryAttack(int client, int clip)
{
	if( clip == 0 || player[client].switchendtime > GetGameTime())
		return false;
		
	if( !SDKCall(g_SDKCall_CanAttack, client) )
		return false;
	
	return true;
}

void PlaySoundAroundClient(int client, const char[] sSoundName)
{
	EmitSoundToAll(sSoundName, client, SNDCHAN_AUTO, SNDLEVEL_AIRCRAFT, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

bool IsGettingUp(int client) 
{
	int Activity;

	Activity = PlayerAnimState.FromPlayer(client).GetMainActivity();

	switch (Activity) 
	{
		//case L4D2_ACT_TERROR_SHOVED_FORWARD_MELEE, // 633, 634, 635, 636: stumble
		//	L4D2_ACT_TERROR_SHOVED_BACKWARD_MELEE,
		//	L4D2_ACT_TERROR_SHOVED_LEFTWARD_MELEE,
		//	L4D2_ACT_TERROR_SHOVED_RIGHTWARD_MELEE: 
		//		return true;

		case L4D2_ACT_TERROR_POUNCED_TO_STAND: // 771: get up from hunter
			return true;

		case L4D2_ACT_TERROR_HIT_BY_TANKPUNCH, // 521, 522, 523: HIT BY TANK PUNCH
			L4D2_ACT_TERROR_IDLE_FALL_FROM_TANKPUNCH,
			L4D2_ACT_TERROR_TANKPUNCH_LAND:
			return true;

		case L4D2_ACT_TERROR_CHARGERHIT_LAND_SLOW: // 526: get up from charger
			return true;

		case L4D2_ACT_TERROR_HIT_BY_CHARGER, // 524, 525, 526: flung by a nearby Charger impact
			L4D2_ACT_TERROR_IDLE_FALL_FROM_CHARGERHIT: 
			return true;

		//case L4D2_ACT_TERROR_INCAP_TO_STAND: // 697, revive from incap or death
		//{
		//	if(!L4D_IsPlayerIncapacitated(client)) // 被電擊器救起來
		//	{
		//		return true;
		//	}
		//}
	}

	return false;
}

bool IsClientOnLadder(int client)
{
    return GetEntityMoveType(client) == MOVETYPE_LADDER;
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

void HookWeapon(int weapon)
{
	if (weapon < 1 || !IsValidEntity(weapon))
		return;
	
	char key[16];
	IntToString(weapon, key, sizeof(key));
	
	// Check if already hooked
	int dummy;
	if (g_WeaponHookIds.GetValue(key, dummy))
		return;
	
	// Hook and store hookid
	int hookid = g_DynamicHook_ItemPostFrame.HookEntity(Hook_Post, weapon, DhookCallback_ItemPostFrame);
	g_WeaponHookIds.SetValue(key, hookid);
}

void UnHookWeapon(int weapon)
{
	if (weapon < 1 || !IsValidEntity(weapon))
		return;
	
	char key[16];
	IntToString(weapon, key, sizeof(key));
	
	int hookid;
	if (g_WeaponHookIds.GetValue(key, hookid))
	{
		// Unhook and remove from map
		DynamicHook.RemoveHook(hookid);
		g_WeaponHookIds.Remove(key);
	}
}

// ============================================================================
// Weapon Attributes
// ============================================================================

/**
 * Load weapon attributes for a specific player and weapon
 * This allows the plugin to work with any weapon type
 */
void LoadPlayerWeaponAttributes(int client, int weapon)
{
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
		return;
	
	if (weapon < 1 || !IsValidEntity(weapon))
		return;
	
	// Get weapon classname
	char classname[64];
	GetEntityClassname(weapon, classname, sizeof(classname));
	
	// Load attributes using Left4DHooks
	player[client].cycleTime = L4D2_GetFloatWeaponAttribute(classname, L4D2FWA_CycleTime);
	strcopy(player[client].weaponClass, sizeof(player[].weaponClass), classname);
	
	// Debug print
	PrintToServer("[AutoWeapon] Client %N switched to %s", client, classname);
}

// ============================================================================
// Native
// ============================================================================

int Native_IsClientHoldAutoScar(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %d", client);
	}
	
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not in game", client);
	}

	if (IsFakeClient(client) || GetClientTeam(client) != L4D_TEAM_SURVIVOR || !IsPlayerAlive(client))
	{
		return false;
	}

	int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if( active_weapon < 1 || !IsValidEntity(active_weapon) )
		return false;

	return player[client].fullautomode;
}

any Native_GetAutoScarSwitchTime(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %d", client);
	}
	
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not in game", client);
	}

	return player[client].switchendtime;
}

any Native_GetAutoScarPrimaryAttackTime(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %d", client);
	}
	
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not in game", client);
	}

	return player[client].primaryattacktime;
}

any Native_GetAutoScarSecondaryAttackTime(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %d", client);
	}
	
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not in game", client);
	}

	return player[client].secondaryattacktime;
}
