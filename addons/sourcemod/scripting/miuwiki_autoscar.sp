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
	CreateNative("miuwiki_GetAutoScarReloadTime",			Native_GetAutoScarReloadTime);
	CreateNative("miuwiki_GetAutoPrimaryAttackTime",		Native_GetAutoScarPrimaryAttackTime);
	CreateNative("miuwiki_GetAutoSecondaryAttackTime",		Native_GetAutoScarSecondaryAttackTime);

	bLate = late;
	return APLRes_Success;
}

#define GAMEDATA "l4d2_aim_down_sight_fix"

#define SHOOT_EMPTY      "weapons/clipempty_rifle.wav"

#define SCAR_WORLD_MODEL      "models/w_models/weapons/w_desert_rifle.mdl"
#define SCAR_SWITCH_SEQUENCE 4

#define DEFAULT_RELOAD_TIME  3.2
#define DEFAULT_ATTACK2_TIME 0.4
#define NOT_IN_RELOAD        0.0

int
	g_scar_precache_index,
	g_Offset_BrustAttackTime;

Handle
	g_SDKCall_FinishReload,
	g_SDKCall_AbortReload,
	g_SDKCall_SeondaryAttack,
	g_SDKCall_PrimaryAttack,
	g_SDKCall_CanAttack;

DynamicHook
	g_DynamicHook_ItemPostFrame;

StringMap
	g_WeaponHookIds; // Map weapon entity index -> hookid

ConVar
	cvar_l4d2_scar_cycletime,
	cvar_l4d2_scar_button;

enum struct GlobalConVar
{
	float cycletime;
	int iButtons;
}
GlobalConVar
	cvar;

enum struct PlayerData
{
	bool  fullautomode;
	bool  needrelease;
	bool  shoveinreload;
	bool  inzoom;

	int   animcount;
	int   lastAction;
	float primaryattacktime;
	float secondaryattacktime;
	float switchendtime;
	float reloadendtime;
	float lastshowinfotime;
}
PlayerData
	player[MAXPLAYERS + 1];

int 
	g_iMaxClip;
float 
	g_fReloadTime,
	g_fCycleTime;

bool 
	g_bADSPluginAvailable = false;

public void OnPluginStart()
{
	g_WeaponHookIds = new StringMap();
	g_bADSPluginAvailable = LibraryExists("l4d2_aim_down_sight");
	LoadGameData();
	cvar_l4d2_scar_cycletime    = CreateConVar("miuwiki_autoscar_cycletime", 	"0.11", 	"Scar full Auto cycle time. [min 0.03, 0=Same as Triple Tap default cycle time]", FCVAR_NOTIFY, true, 0.0);
	cvar_l4d2_scar_button		= CreateConVar("miuwiki_autoscar_buttons", 		"524288", 	"Press which button to trigger full auto mode, 131072=Shift, 4=Ctrl, 32=Use, 8192=Reload, 524288=Middle Mouse\nYou can add numbers together, ex: 655360=Shift + Middle Mouse", FCVAR_NOTIFY);

	GetCvars();
	cvar_l4d2_scar_cycletime.AddChangeHook(ConVarChanged_Cvars);
	cvar_l4d2_scar_button.AddChangeHook(ConVarChanged_Cvars);

	AutoExecConfig(true,       "miuwiki_autoscar");

	AddCommandListener(CmdListen_weapon_reparse_server, "weapon_reparse_server");

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	
	if(bLate)
	{
		LateLoad();
	}
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
            HookScarWeapon(entity);
        }
    }
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	cvar.cycletime    		= cvar_l4d2_scar_cycletime.FloatValue;
	cvar.iButtons 	  		= cvar_l4d2_scar_button.IntValue;
}

public void OnAllPluginsLoaded()
{
	g_bADSPluginAvailable = LibraryExists("l4d2_aim_down_sight");
	if(g_bADSPluginAvailable)
	{
		PrintToServer("[AutoScar] ADS plugin detected - Enhanced animations enabled");
	}
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "l4d2_aim_down_sight"))
	{
		g_bADSPluginAvailable = true;
		PrintToServer("[AutoScar] ADS plugin loaded");
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(StrEqual(name, "l4d2_aim_down_sight"))
	{
		g_bADSPluginAvailable = false;
		PrintToServer("[AutoScar] ADS plugin unloaded");
	}
}

#define ZOOM_Sound "weapons/hunting_rifle/gunother/hunting_rifle_zoom.wav"
public void OnMapStart()
{
	PrecacheSound(ZOOM_Sound);

	g_scar_precache_index = PrecacheModel(SCAR_WORLD_MODEL);

	PrecacheSound(SHOOT_EMPTY);
}

public void OnClientConnected(int client)
{
	if( IsFakeClient(client) )
		return;
	
	player[client].inzoom				= false;
	player[client].fullautomode			= false;
	player[client].needrelease			= false;
	player[client].shoveinreload		= false;

	player[client].animcount			= 0;
	player[client].lastAction			= 0; // 0=When survivors are unable to move, 1=When switching to automatic mode or when cutting the gun, 2=No modifications
	player[client].primaryattacktime	= 0.0;
	player[client].secondaryattacktime	= 0.0;
	player[client].switchendtime		= 0.0;
	player[client].reloadendtime		= 0.0;
	player[client].lastshowinfotime		= 0.0;
}

public void OnConfigsExecuted()
{
	GetCvars();

	OnNextFrame_weapon_reparse_server();
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

	if( GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex") != g_scar_precache_index )
	{
		SetEntProp(client, Prop_Data, "m_bPredictWeapons", 1);
		return;
	}

	if( player[client].fullautomode )
	{
		// since predict will cause sound problem and no ammo trace, we predict scar whatever which mode it use.
		SetEntProp(client, Prop_Data, "m_bPredictWeapons", 0);
		// Hook weapon when in auto mode
		HookScarWeapon(weapon);
	}
	else
	{
		SetEntProp(client, Prop_Data, "m_bPredictWeapons", 1);
		// Unhook weapon when in triple tap mode to reduce overhead
		UnhookScarWeapon(weapon);
	}
}

void SDKCallback_OnClientPostThink(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if( weapon < 1 || !IsValidEntity(weapon) )
		return;

	if( GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex") != g_scar_precache_index )
		return;

	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if( viewmodel < 1 || !IsValidEntity(viewmodel) )
		return;

	int animcount = GetEntProp(viewmodel, Prop_Send, "m_nAnimationParity");
	if( player[client].fullautomode
		&& player[client].animcount != animcount 
		&& GetEntProp(viewmodel, Prop_Send, "m_nLayerSequence") == SCAR_SWITCH_SEQUENCE )
	{
		player[client].lastAction = 1;
		player[client].needrelease = true;
		player[client].switchendtime = GetGameTime() + 0.97;
		player[client].reloadendtime = NOT_IN_RELOAD;
	}

	player[client].animcount = animcount;
}

Action CmdListen_weapon_reparse_server(int client, const char[] command, int argc)
{
	RequestFrame(OnNextFrame_weapon_reparse_server);

	return Plugin_Continue;
}

void OnNextFrame_weapon_reparse_server()
{

	g_iMaxClip = L4D2_GetIntWeaponAttribute("weapon_rifle_desert", L4D2IWA_ClipSize);
	g_fReloadTime = L4D2_GetFloatWeaponAttribute("weapon_rifle_desert", L4D2FWA_ReloadDuration);
	if(g_fReloadTime <= 0.0) g_fReloadTime = 3.32; //just in case
	g_fCycleTime = L4D2_GetFloatWeaponAttribute("weapon_rifle_desert", L4D2FWA_CycleTime);
	if(g_fCycleTime <= 0.0) g_fCycleTime = 0.07; //just in case
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for(int i = 0; i <= MaxClients; i++)
	{
		player[i].lastAction			= 0;
		player[i].primaryattacktime		= 0.0;
		player[i].secondaryattacktime	= 0.0;
		player[i].switchendtime			= 0.0;
		player[i].reloadendtime			= 0.0;
		player[i].lastshowinfotime		= 0.0;
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

	for(int i = 0; i < 3; i++)
	{
		//使用StoreToAddress 換圖時有機率會導致崩潰 crash: tier0.dll + 0x1991d
		//StoreToAddress(temp + view_as<Address>(4 * i), 0, NumberType_Int32);

		SetEntData(pThis, g_Offset_BrustAttackTime + (4 * i), 0);
	}

	int clip             = GetEntProp(pThis, Prop_Send, "m_iClip1");
	float currenttime    = GetGameTime();

	SetEntPropFloat(pThis, Prop_Send, "m_flNextPrimaryAttack", currenttime + 100);
	SetEntPropFloat(pThis, Prop_Send, "m_flNextSecondaryAttack", currenttime + 100);
	

	if(player[client].lastAction == 0)
	{
		player[client].needrelease = true;
		player[client].switchendtime = currenttime + 0.3; 
		player[client].reloadendtime = NOT_IN_RELOAD;
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
			player[client].reloadendtime = NOT_IN_RELOAD;
			player[client].lastAction	= 0;
			SetEntProp(client, Prop_Data, "m_bPredictWeapons", 0);
			
			return MRES_Ignored;
		}
	}
	
	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");

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
			if( player[client].reloadendtime != NOT_IN_RELOAD )
				player[client].shoveinreload = true;
		}
		return MRES_Ignored; // ignore in_attack and in_reload when pushing pushing.
	}

	if( (button & IN_ATTACK) && CanPrimaryAttack(client, clip) )
	{
		if( currenttime > player[client].primaryattacktime
			&& currenttime > player[client].secondaryattacktime ) // not allow in attack2
		{
			// PrintToChat(client, "attacking, time %f", currenttime);
			SetEntPropFloat(pThis, Prop_Send, "m_flNextPrimaryAttack", currenttime);
			SDKCall(g_SDKCall_PrimaryAttack, pThis);
			SetEntPropFloat(pThis, Prop_Send, "m_flNextPrimaryAttack", currenttime + 100.0);
			if(cvar.cycletime <= 0.0)
				player[client].primaryattacktime = currenttime + g_fCycleTime;
			else
				player[client].primaryattacktime = currenttime + cvar.cycletime;
		}
		return MRES_Ignored; // ignore IN_RELOAD when pushing attack button.
	}


	int reserverammo = L4D_GetReserveAmmo(client, pThis);
	if( CanReload(client, clip))
	{
		if(clip == 0 && reserverammo > 0 
		&& currenttime > player[client].secondaryattacktime )
		{
			SDKCall(g_SDKCall_AbortReload, pThis);
			EmitSoundToClient(client, SHOOT_EMPTY);
			SetEntProp(viewmodel, Prop_Send, "m_nLayerSequence", 8);
			SetEntPropFloat(viewmodel, Prop_Send, "m_flLayerStartTime", currenttime);
			SetEntPropFloat(pThis, Prop_Send, "m_flPlaybackRate", DEFAULT_RELOAD_TIME / g_fReloadTime);
			player[client].reloadendtime = currenttime + g_fReloadTime;
			player[client].shoveinreload = false;

			return MRES_Ignored; 
		}

		if( (button & IN_RELOAD) && clip > 0 && reserverammo > 0 )
		{
			L4D_SetReserveAmmo(client, pThis, reserverammo + clip);
			SetEntProp(pThis, Prop_Send, "m_iClip1", 0);

			SDKCall(g_SDKCall_AbortReload, pThis);
			//EmitSoundToClient(client, SHOOT_EMPTY);
			SetEntProp(viewmodel, Prop_Send, "m_nLayerSequence", 8);
			SetEntPropFloat(viewmodel, Prop_Send, "m_flLayerStartTime", currenttime);
			SetEntPropFloat(pThis, Prop_Send, "m_flPlaybackRate", DEFAULT_RELOAD_TIME / g_fReloadTime);
			player[client].reloadendtime = currenttime + g_fReloadTime;
			player[client].shoveinreload = false;
			
		}
	}

	// reload complete
	if( player[client].reloadendtime != NOT_IN_RELOAD && currenttime >= player[client].reloadendtime )
	{
		SDKCall(g_SDKCall_FinishReload, pThis);
		player[client].reloadendtime = NOT_IN_RELOAD;
		if( player[client].shoveinreload )
			SetEntProp(viewmodel, Prop_Send, "m_nLayer", 0);

		SetEntPropFloat(viewmodel, Prop_Send, "m_flLayerStartTime", 0.0);
		SetEntPropFloat(pThis, Prop_Send, "m_flPlaybackRate", 1.0);
	}

	return MRES_Ignored;
}


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

	if( player[client].reloadendtime != NOT_IN_RELOAD )
		return false;
		
	if( !SDKCall(g_SDKCall_CanAttack, client) )
		return false;
	
	return true;
}

bool CanReload(int client, int clip)
{
	if( player[client].switchendtime > GetGameTime())
		return false;

	if( player[client].reloadendtime != NOT_IN_RELOAD )
		return false;
		
	if( !SDKCall(g_SDKCall_CanAttack, client) )
		return false;

	if( clip >= g_iMaxClip)
		return false;
	
	return true;
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
	FormatEx(func, sizeof(func), "CTerrorGun::AbortReload");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, func);
	if( !(g_SDKCall_AbortReload = EndPrepSDKCall()) )
		SetFailState("failed to start sdkcall \"%s\"", func);
	
	FormatEx(func, sizeof(func), "CTerrorGun::FinishReload");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, func);
	if( !(g_SDKCall_FinishReload = EndPrepSDKCall()) )
		SetFailState("failed to start sdkcall \"%s\"", func);

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

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity))
		return;

	// Don't auto-hook, only hook when player switches to auto mode
	// This reduces overhead for Triple Tap mode
	if( strcmp(classname, "weapon_rifle_desert") == 0 )
	{
		// g_DynamicHook_ItemPostFrame.HookEntity(Hook_Post, entity, DhookCallback_ItemPostFrame);
		// Hook will be added in SDKCallback_SwitchDesert if needed
	}
}

// fix that keeping press IN_ATTACK before switch weapon will not fire again after switch complete. 
public Action OnPlayerRunCmd(int client, int &buttons)
{
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

	if( cvar.iButtons & buttons == cvar.iButtons )
	{
		if( player[client].inzoom )
			return;
		
		int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if( active_weapon < 1 || !IsValidEntity(active_weapon) )
			return;

		if( GetEntProp(active_weapon, Prop_Send, "m_iWorldModelIndex") != g_scar_precache_index )
			return;

		float now = GetGameTime();
		if(player[client].fullautomode)
		{
			if(player[client].reloadendtime > now
				|| player[client].switchendtime > now)
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
			UnhookScarWeapon(active_weapon);
		}
		else
		{
			SetEntProp(client, Prop_Data, "m_bPredictWeapons", 0);
			player[client].lastAction = 1;
			player[client].needrelease = true;
			player[client].switchendtime = GetGameTime() + 0.2;
			player[client].reloadendtime = NOT_IN_RELOAD;
			// Hook only when in auto mode
			HookScarWeapon(active_weapon);
		}
	}
	else
	{
		player[client].inzoom = false;
	}
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

void HookScarWeapon(int weapon)
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

void UnhookScarWeapon(int weapon)
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

// Native

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

	if( GetEntProp(active_weapon, Prop_Send, "m_iWorldModelIndex") != g_scar_precache_index )
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

any Native_GetAutoScarReloadTime(Handle plugin, int numParams)
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

	return player[client].reloadendtime;
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
