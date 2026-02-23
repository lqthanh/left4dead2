#pragma semicolon 1
#pragma newdecls optional

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <dhooks>

#define PLUGIN_VERSION "1.0"

// Variables
Handle hHook_SelectWeightedSequence = null;
Handle hHook_SendWeaponAnim = null;
Handle hWeaponHolster = null;
KeyValues hWeaponData = null;
KeyValues hActivityList = null;
Handle hGetWeaponInfoByID = null;
int iOS;
int EntStore[2049];
int onbutton[MAXPLAYERS + 1];
bool bZoom[MAXPLAYERS + 1];
int ads_key;
bool bPass;
bool g_bDebug = false;

public Plugin myinfo = 
{
	name = "[L4D2] Aim Down Sight",
	description = "Aim Down Sight for L4D2",
	author = "lqthanh",
	version = PLUGIN_VERSION,
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion engine = GetEngineVersion();
	if( engine != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	RegPluginLibrary("l4d2_aim_down_sight");
	CreateNative("l4d2_aim_down_sight_IsClientInADS", Native_IsClientInADS);
	CreateNative("l4d2_aim_down_sight_PlayADSAnimation", Native_PlayADSAnimation);
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	PrintToServer("[ADS] Plugin starting...");
	
	GameData gamedata = LoadGameConfigFile("l4d2_aim_down_sight");
	if (!gamedata)
		SetFailState("Can't load gamedata \"l4d2_aim_down_sight.txt\" or not found");
	
	PrintToServer("[ADS] GameData loaded successfully");
	
	iOS = gamedata.GetOffset("Os");
	
	// Setup DHooks - Use manual offset instead of conf
	hHook_SelectWeightedSequence = DHookCreate(208 - iOS, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity);
	if (!hHook_SelectWeightedSequence)
		SetFailState("Failed to create DHook: SelectWeightedSequence");
	DHookAddParam(hHook_SelectWeightedSequence, HookParamType_Int);
	PrintToServer("[ADS] DHook SelectWeightedSequence created (offset: %d)", 208 - iOS);
	
	hHook_SendWeaponAnim = DHookCreate(252 - iOS, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity);
	DHookAddParam(hHook_SendWeaponAnim, HookParamType_Int);
	
	hWeaponHolster = DHookCreate(266 - iOS, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity);
	DHookAddParam(hWeaponHolster, HookParamType_CBaseEntity);
	
	// Setup SDK Call
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "GetWeaponInfo");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hGetWeaponInfoByID = EndPrepSDKCall();
	if (!hGetWeaponInfoByID)
		SetFailState("Can't find signature \"GetWeaponInfo\".");
	PrintToServer("[ADS] SDK Calls setup complete");
	
	delete gamedata;
	
	// Load activity list
	hActivityList = new KeyValues("");
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), "data/left4dhooks.l4d2.cfg");
	PrintToServer("[ADS] Loading activity list from: %s", buffer);
	if (!hActivityList.ImportFromFile(buffer))
	{
		LogError("[ADS] WARNING: Failed to load activity list from %s", buffer);
		PrintToServer("[ADS] WARNING: Activity list not loaded - custom animations will not work");
		PrintToServer("[ADS] Plugin will still work with basic ADS functionality");
	}
	else
	{
		PrintToServer("[ADS] Activity list loaded successfully");
	}
	
	// Register commands and events
	RegServerCmd("ads_reload", Command_Reload);
	LoadWeaponData();
	PrintToServer("[ADS] Commands registered");
	
	HookEvent("weapon_zoom", Event_WeaponZoom, EventHookMode_Post);
	HookEvent("weapon_drop", Event_WeaponDrop, EventHookMode_Post);
	PrintToServer("[ADS] Events hooked");
	
	// Create ConVars
	ConVar cvar;
	cvar = CreateConVar("ads_debug", "0", "Enable debug logging");
	cvar.AddChangeHook(OnConVarChanged);
	
	cvar = CreateConVar("ads_key", "0", "Key to activate ADS. 0 = Zoom key (MOUSE 3), 1 = Walk key (SHIFT), 2 = Duck key (CTRL)");
	cvar.AddChangeHook(OnConVarChanged);
	
	LoadConVars();
	AutoExecConfig(true, "l4d2_aim_down_sight");
	PrintToServer("[ADS] Plugin loaded successfully!");
	PrintToServer("[ADS] Use 'sm_ads_debug' to toggle debug mode");
	PrintToServer("[ADS] Use 'sm_ads_test' to test ADS on your weapon");
}

void LoadConVars()
{
	g_bDebug = FindConVar("ads_debug").BoolValue;
	ads_key = FindConVar("ads_key").IntValue;
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	LoadConVars();
}

Action Command_Reload(int args)
{
	LoadWeaponData();
	return Plugin_Handled;
}

void LoadWeaponData()
{
	delete hWeaponData;
	hWeaponData = new KeyValues("");
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), "data/l4d2_aim_down_sight.txt");
	
	if (g_bDebug)
		PrintToServer("[ADS] Loading weapon data from: %s", buffer);
	
	if (!hWeaponData.ImportFromFile(buffer))
	{
		LogError("[ADS] Failed to load weapon data from %s", buffer);
		if (g_bDebug)
			PrintToServer("[ADS] Weapon data file not found - using default behavior");
	}
	else if (g_bDebug)
	{
		PrintToServer("[ADS] Weapon data loaded successfully");
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (classname[0] == 'w' 
		&& StrContains(classname, "weapon_") == 0 
		&& (StrContains(classname, "pistol") != -1
		|| StrContains(classname, "shotgun") != -1
		|| StrContains(classname, "smg") != -1
		|| StrContains(classname, "sniper") != -1
		|| StrContains(classname, "rifle") != -1)
		&& StrContains(classname, "spawn") == -1
	)
	{
		if (g_bDebug)
			PrintToServer("[ADS] Hooking weapon entity: %s [%d]", classname, entity);
		
		DHookEntity(hHook_SelectWeightedSequence, false, entity, _, DH_OnSelectWeightedSequence);
		SDKHook(entity, SDKHook_ReloadPost, OnCustomWeaponReload);
		DHookEntity(hWeaponHolster, true, entity, _, DH_OnGunHolsterPost);
		EntStore[entity] = 0;
	}
}

// Hook: SelectWeightedSequence
public MRESReturn DH_OnSelectWeightedSequence(int weapon, Handle hReturn, Handle hParams)
{
	if (bPass)
		return MRES_Ignored;
	
	int activity = DHookGetParam(hParams, 1);
	int originalActivity = activity;
	int sequence = -1;
	int owner = GetWeaponOwner(weapon);
	
	switch (activity)
	{
		case 193, 1264, 1403: // ACT_VM_RELOAD
		{
			if (GetWeaponClip(weapon) == 0)
				activity = 1269;
			
			if (owner > 0 && bZoom[owner])
			{
				SetWeaponHelpingHandState(weapon, 6);
				activity = 1877; // ACT_PRIMARY_VM_RELOAD
			}
		}
		case 1250, 1254: // ACT_VM_MELEE
		{
			if (owner > 0 && bZoom[owner])
			{
				SetWeaponHelpingHandState(weapon, 6);
				activity = 1876; // ACT_PRIMARY_VM_SECONDARYATTACK
			}
		}
		case 1252: // ACT_VM_PRIMARYATTACK_LAYER
		{
			if (owner > 0)
			{
				if (GetWeaponClip(weapon) > 0)
				{
					if (bZoom[owner])
					{
						SetWeaponHelpingHandState(weapon, 6);
						activity = 1875; // ACT_PRIMARY_VM_PRIMARYATTACK
					}
				}
				else
				{
					activity = bZoom[owner] ? 1878 : 194; // ACT_PRIMARY_VM_DRYFIRE : ACT_VM_DRYFIRE
				}
			}
		}
		case 1276: // ACT_VM_DEPLOY
		{
			if (!EntStore[weapon])
			{
				if (GetWeaponClip(weapon) > 0)
				{
					activity = 181; // ACT_VM_DRAW
					EntStore[weapon] = 1;
				}
			}
			if (owner > 0)
				bZoom[owner] = false;
		}
	}
	
	// Try custom animation first
	sequence = GetCustomWeaponAnim(weapon, activity);
	if (sequence != -1)
	{
		DHookSetReturn(hReturn, sequence);
		return MRES_Supercede;
	}
	
	// If activity changed, try to find sequence
	if (activity != originalActivity)
	{
		bPass = true;
		sequence = SelectWeightedSequence(weapon, activity);
		bPass = false;
		
		if (sequence != -1)
		{
			DHookSetReturn(hReturn, sequence);
			return MRES_Supercede;
		}
	}
	
	return MRES_Ignored;
}

int GetCustomWeaponAnim(int weapon, int activity)
{
	char classname[64];
	GetEntityClassname(weapon, classname, sizeof(classname));
	
	hWeaponData.Rewind();
	if (!hWeaponData.JumpToKey(classname))
		return -1;
	
	if (!hWeaponData.JumpToKey("Animation"))
		return -1;
	
	char activityName[64];
	if (hActivityList.GotoFirstSubKey(false))
	{
		do
		{
			if (activity == hActivityList.GetNum(NULL_STRING, 0))
			{
				hActivityList.GetSectionName(activityName, sizeof(activityName));
				break;
			}
		}
		while (hActivityList.GotoNextKey(false));
		hActivityList.GoBack();
	}
	
	if (activityName[0] == 0)
		return -1;
	
	if (!hWeaponData.JumpToKey(activityName))
		return -1;
	
	int sequence = hWeaponData.GetNum(NULL_STRING, -1);
	if (sequence >= 0)
		return sequence;
	
	// Random from multiple sequences
	if (hWeaponData.GotoFirstSubKey(false))
	{
		ArrayList list = new ArrayList();
		do
		{
			list.Push(hWeaponData.GetNum(NULL_STRING, 0));
		}
		while (hWeaponData.GotoNextKey(false));
		
		sequence = list.Get(GetRandomInt(0, list.Length - 1));
		delete list;
		return sequence;
	}
	
	return -1;
}

// Hook: Weapon Holster
public MRESReturn DH_OnGunHolsterPost(int weapon)
{
	int owner = GetWeaponOwner(weapon);
	if (owner > 0 && bZoom[owner])
	{
		bZoom[owner] = false;
		// Reset the weapon animation to normal idle
		int sequence = SelectWeightedSequence(weapon, 183); // ACT_VM_IDLE
		if (sequence != -1)
		{
			int viewModel = GetEntPropEnt(owner, Prop_Send, "m_hViewModel");
			if (viewModel > 0)
			{
				SetEntProp(viewModel, Prop_Send, "m_nSequence", sequence);
			}
		}
		// Reset helping hand state
		SetWeaponHelpingHandState(weapon, 0);
	}
	return MRES_Ignored;
}

// Hook: Custom Weapon Reload - Inspect weapon when reload with full clip
public Action OnCustomWeaponReload(int weapon)
{
	int owner = GetWeaponOwner(weapon);
	if (owner <= 0 || owner > MaxClients || !IsClientInGame(owner))
		return Plugin_Continue;
	
	// Only inspect when:
	// 1. Clip is full
	// 2. Not in ADS mode (bZoom is false)
	// 3. Weapon is ready (can fire soon)
	if (GetWeaponClip(weapon) >= GetWeaponGunClipSize(weapon) && !bZoom[owner])
	{
		float nextAttack = GetEntDataFloat(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_flNextPrimaryAttack"));
		float gameTime = GetGameTime();
		
		// Check if weapon is idle (ready to fire within 1 second)
		if (gameTime + 1.0 >= nextAttack)
		{
			// Check if player pressed reload button
			int buttons = GetClientButtons(owner);
			if (buttons & IN_RELOAD)
			{
				if (g_bDebug)
					PrintToServer("[ADS] Client %N inspecting weapon", owner);
				
				// Play inspect animation (ACT_VM_FIDGET = 184)
				SendWeaponAnim(weapon, 184);
				return Plugin_Handled;
			}
		}
	}
	
	return Plugin_Continue;
}

// Event: Weapon Zoom
void Event_WeaponZoom(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client <= 0)
		return;
	
	bool zoomed = GetEntProp(client, Prop_Send, "m_iFOV") != 0;
	if (zoomed != bZoom[client])
	{
		int weapon = GetPlayerWeapon(client);
		if (weapon != -1)
			SetupZoom(client, weapon, zoomed);
	}
}

// Event: Weapon Drop
void Event_WeaponDrop(Event event, const char[] name, bool dontBroadcast)
{
	int propid = event.GetInt("propid");
	EntStore[propid] = 0;
}

// Player command processing
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (!IsClientInGame(client) || GetClientTeam(client) != 2 || IsFakeClient(client))
		return Plugin_Continue;
	
	// Debug: Print m_nLayerSequence continuously
	if (g_bDebug)
	{
		int viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
		if (viewModel > 0)
		{
			int layerSequence = GetEntProp(viewModel, Prop_Send, "m_nLayerSequence");
			PrintToServer("[ADS DEBUG] Client %N - m_nLayerSequence: %d", client, layerSequence);
		}
	}
	
	// Determine which button to check based on ads_key
	int adsButton;
	char keyName[16];
	switch (ads_key)
	{
		case 1: // SHIFT key
		{
			adsButton = IN_SPEED;
			Format(keyName, sizeof(keyName), "SHIFT");
		}
		case 2: // CTRL key
		{
			adsButton = IN_DUCK;
			Format(keyName, sizeof(keyName), "CTRL");
		}
		default: // Zoom key (0 or any other value)
		{
			adsButton = IN_ZOOM;
			Format(keyName, sizeof(keyName), "ZOOM");
		}
	}
	
	if (buttons & adsButton)
	{
		if (!(onbutton[client] & adsButton))
		{
			onbutton[client] |= adsButton;
			int activeWeapon = GetPlayerWeapon(client);
			// Allow ADS if: not a sniper, OR using custom key (not zoom key)
			if (activeWeapon != -1 && (!CanZoom(activeWeapon) || ads_key != 0))
			{
				if (g_bDebug)
				{
					char classname[64];
					GetEntityClassname(activeWeapon, classname, sizeof(classname));
					PrintToServer("[ADS] Client %N pressed %s button - Weapon: %s", client, keyName, classname);
				}
				SetupZoom(client, activeWeapon, !bZoom[client]);
			}
		}
	}
	else if (onbutton[client] & adsButton)
	{
		onbutton[client] &= ~adsButton;
	}
	
	return Plugin_Continue;
}

// Utility functions
void SetupZoom(int client, int weapon, bool zoom)
{
	if (g_bDebug)
		PrintToServer("[ADS] SetupZoom: Client %N, Zoom: %s", client, zoom ? "ON" : "OFF");
	
	int targetActivity = zoom ? 1873 : 183; // ACT_PRIMARY_VM_IDLE : ACT_VM_IDLE
	int sequence = SelectWeightedSequence(weapon, targetActivity);
	
	if (sequence == -1)
	{
		if (g_bDebug)
			PrintToServer("[ADS] Failed to find sequence for activity %d", targetActivity);
		return;
	}
	
	if (g_bDebug)
		PrintToServer("[ADS] Setting zoom state to: %s (sequence: %d)", zoom ? "ADS" : "Normal", sequence);
	
	bZoom[client] = zoom;
	
	float nextAttack = GetEntDataFloat(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_flNextPrimaryAttack"));
	if (GetGameTime() > nextAttack)
	{
		int transitionActivity = zoom ? 1879 : 1881; // ACT_PRIMARY_VM_IDLE_TO_LOWERED : ACT_PRIMARY_VM_LOWERED_TO_IDLE
		SendWeaponAnim(weapon, transitionActivity);
	}
	
	int viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	SetEntProp(viewModel, Prop_Send, "m_nSequence", sequence);
	SetWeaponHelpingHandState(weapon, zoom ? 6 : 0);
}

bool CanZoom(int weapon)
{
	char classname[64];
	GetEntityClassname(weapon, classname, sizeof(classname));
	return (StrContains(classname[7], "sniper", false) != -1 || 
	        StrContains(classname[7], "hunting", false) != -1 || 
	        StrContains(classname[13], "sg552", false) != -1);
}

int SelectWeightedSequence(int entity, int activity)
{
	static Handle hCall = null;
	if (hCall == null)
	{
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetVirtual(208 - iOS);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		hCall = EndPrepSDKCall();
	}
	return SDKCall(hCall, entity, activity);
}

bool SendWeaponAnim(int weapon, int sequence)
{
	static Handle hCall = null;
	if (hCall == null)
	{
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetVirtual(252 - iOS);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		hCall = EndPrepSDKCall();
	}
	return SDKCall(hCall, weapon, sequence);
}

int GetWeaponGunClipSize(int weapon)
{
	static Handle hCall = null;
	if (hCall == null)
	{
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetVirtual(324 - iOS);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		hCall = EndPrepSDKCall();
	}
	return SDKCall(hCall, weapon);
}

int GetPlayerWeapon(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

int GetWeaponOwner(int weapon)
{
	return GetEntPropEnt(weapon, Prop_Data, "m_hOwner");
}

int GetWeaponClip(int weapon)
{
	int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
	return (clip == 254) ? 0 : clip;
}

void SetWeaponHelpingHandState(int weapon, int state)
{
	SetEntProp(weapon, Prop_Send, "m_helpingHandState", state);
}

// ============================================================================
// Native
// ============================================================================

public int Native_IsClientInADS(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
		return false;
	
	return bZoom[client];
}

public int Native_PlayADSAnimation(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int weapon = GetNativeCell(2);
	int activity = GetNativeCell(3);
	
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
		return false;
	
	if (!IsValidEntity(weapon))
		return false;
	
	// Check if client is in ADS mode
	if (!bZoom[client])
		return false;
	
	// Get sequence and play animation
	int sequence = SelectWeightedSequence(weapon, activity);
	if (sequence != -1)
	{
		SetWeaponHelpingHandState(weapon, 6);
		return SendWeaponAnim(weapon, activity);
	}
	
	return false;
}
