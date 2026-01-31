#pragma semicolon 1
#pragma newdecls optional

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

#define PLUGIN_VERSION "1.0"

// Variables
Handle hHook_SelectWeightedSequence = null;
Handle hHook_SendWeaponAnim = null;
Handle hWeaponHolster = null;
Handle hHook_PrimaryAttack = null;
KeyValues hWeaponData = null;
KeyValues hActivityList = null;
Handle hGetWeaponInfoByID = null;
int iOS;
int EntStore[2049];
int onbutton[MAXPLAYERS + 1];
bool bZoom[MAXPLAYERS + 1];
bool ads_holding_key;
int ads_key;
float ads_recoil_modifier;
float ads_spread_modifier;
float ads_pellet_scatter_modifier;
bool bPass;
KeyValues hRestoreWeaponAttr = null;
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
	RegPluginLibrary("l4d2_aim_down_sight");
	
	CreateNative("l4d2_aim_down_sight_IsClientInADS", Native_IsClientInADS);
	CreateNative("l4d2_aim_down_sight_ForceWeaponAnimation", Native_ForceWeaponAnimation);
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
	PrintToServer("[ADS] iOS offset: %d", iOS);
	
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
	
	hHook_PrimaryAttack = DHookCreate(283 - iOS, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity);
	
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
	RegAdminCmd("sm_ads_debug", Command_DebugToggle, ADMFLAG_ROOT, "Toggle ADS debug mode");
	RegAdminCmd("sm_ads_test", Command_TestADS, ADMFLAG_ROOT, "Test ADS on current weapon");
	LoadWeaponData();
	PrintToServer("[ADS] Commands registered");
	
	HookEvent("weapon_zoom", Event_WeaponZoom, EventHookMode_Post);
	HookEvent("weapon_drop", Event_WeaponDrop, EventHookMode_Post);
	HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
	PrintToServer("[ADS] Events hooked");
	
	// Create ConVars
	ConVar cvar;
	cvar = CreateConVar("ads_debug", "0", "Enable debug logging");
	cvar.AddChangeHook(OnConVarChanged);
	
	cvar = CreateConVar("ads_holding_key", "0", "Enable in ads by holding the zoom key.");
	cvar.AddChangeHook(OnConVarChanged);
	
	cvar = CreateConVar("ads_key", "0", "Key to activate ADS. 0 = Zoom key (MOUSE 3), 1 = Walk key (SHIFT), 2 = Duck key (CTRL)");
	cvar.AddChangeHook(OnConVarChanged);
	
	cvar = CreateConVar("ads_recoil_modifier", "0.5", "Recoil modifier while in ads.");
	cvar.AddChangeHook(OnConVarChanged);
	
	cvar = CreateConVar("ads_spread_modifier", "0.1", "Spread modifier while in ads.");
	cvar.AddChangeHook(OnConVarChanged);
	
	cvar = CreateConVar("ads_pellet_scatter_modifier", "0.5", "Pellet scatter modifier while in ads.");
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
	ads_recoil_modifier = FindConVar("ads_recoil_modifier").FloatValue;
	ads_spread_modifier = FindConVar("ads_spread_modifier").FloatValue;
	ads_pellet_scatter_modifier = FindConVar("ads_pellet_scatter_modifier").FloatValue;
	ads_holding_key = FindConVar("ads_holding_key").BoolValue;
	ads_key = FindConVar("ads_key").IntValue;
	
	if (g_bDebug)
	{
		PrintToServer("[ADS] ConVars loaded:");
		PrintToServer("[ADS] - Recoil modifier: %.2f", ads_recoil_modifier);
		PrintToServer("[ADS] - Spread modifier: %.2f", ads_spread_modifier);
		PrintToServer("[ADS] - Pellet scatter: %.2f", ads_pellet_scatter_modifier);
		PrintToServer("[ADS] - Holding key: %d", ads_holding_key);
		PrintToServer("[ADS] - ADS key: %d (0=Zoom, 1=Shift, 2=Ctrl)", ads_key);
	}
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	LoadConVars();
}

Action Command_Reload(int args)
{
	PrintToServer("[ADS] Reloading weapon data...");
	LoadWeaponData();
	PrintToServer("[ADS] Weapon data reloaded");
	return Plugin_Handled;
}

Action Command_DebugToggle(int client, int args)
{
	g_bDebug = !g_bDebug;
	FindConVar("ads_debug").SetBool(g_bDebug);
	ReplyToCommand(client, "[ADS] Debug mode: %s", g_bDebug ? "ON" : "OFF");
	PrintToServer("[ADS] Debug mode: %s", g_bDebug ? "ON" : "OFF");
	return Plugin_Handled;
}

Action Command_TestADS(int client, int args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "[ADS] This command can only be used in-game");
		return Plugin_Handled;
	}
	
	int weapon = GetPlayerWeapon(client);
	if (weapon == -1)
	{
		ReplyToCommand(client, "[ADS] No weapon equipped");
		return Plugin_Handled;
	}
	
	char classname[64];
	GetEntityClassname(weapon, classname, sizeof(classname));
	ReplyToCommand(client, "[ADS] Current weapon: %s", classname);
	ReplyToCommand(client, "[ADS] Current zoom state: %s", bZoom[client] ? "ADS" : "Normal");
	ReplyToCommand(client, "[ADS] Toggling ADS...");
	
	SetupZoom(client, weapon, !bZoom[client]);
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
	if (classname[0] == 'w' && StrContains(classname, "weapon_") == 0 && StrContains(classname, "spawn") == -1)
	{
		if (g_bDebug)
			PrintToServer("[ADS] Hooking weapon entity: %s [%d]", classname, entity);
		
		DHookEntity(hHook_SelectWeightedSequence, false, entity, _, DH_OnSelectWeightedSequence);
		SDKHook(entity, SDKHook_ReloadPost, OnCustomWeaponReload);
		DHookEntity(hWeaponHolster, true, entity, _, DH_OnGunHolsterPost);
		DHookEntity(hHook_PrimaryAttack, true, entity, _, DH_PrimaryAttackPost);
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
	if (owner > 0)
		bZoom[owner] = false;
	return MRES_Ignored;
}

// Hook: Primary Attack Post
public MRESReturn DH_PrimaryAttackPost(int weapon)
{
	if (hRestoreWeaponAttr != null)
	{
		char sectionName[48];
		hRestoreWeaponAttr.GetSectionName(sectionName, sizeof(sectionName));
		int weaponinfo = StringToInt(sectionName);
		
		if (hRestoreWeaponAttr.GotoFirstSubKey(false))
		{
			do
			{
				hRestoreWeaponAttr.GetSectionName(sectionName, sizeof(sectionName));
				int offset = StringToInt(sectionName);
				float value = hRestoreWeaponAttr.GetFloat(NULL_STRING, 0.0);
				StoreToAddress(view_as<Address>(weaponinfo + offset), view_as<int>(value), NumberType_Int32, true);
			}
			while (hRestoreWeaponAttr.GotoNextKey(false));
		}
		
		delete hRestoreWeaponAttr;
		hRestoreWeaponAttr = null;
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

// Event: Weapon Fire
void Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int weaponid = event.GetInt("weaponid");
	
	// Skip melee weapons
	if (weaponid == 19 || weaponid == 20 || weaponid == 54)
		return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client <= 0 || GetClientTeam(client) != 2)
		return;
	
	int weapon = GetPlayerWeapon(client);
	if (weapon == -1)
		return;
	
	int ammoType = GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType");
	
	// Only process certain ammo types
	switch (ammoType)
	{
		case 1, 2, 3, 5, 6, 7, 8, 9, 10, 17:
		{
			if (bZoom[client])
			{
				int weaponinfo = SDKCall(hGetWeaponInfoByID, weaponid);
				char buffer[48];
				FormatEx(buffer, sizeof(buffer), "%i", weaponinfo);
				hRestoreWeaponAttr = new KeyValues(buffer);
				
				// Modify weapon attributes
				SetToRestoreWeaponAttrFloat(weaponinfo, 3076, ads_recoil_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3080, ads_recoil_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3092, ads_spread_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3088, ads_spread_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3100, ads_spread_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3104, ads_spread_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3108, ads_spread_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3112, ads_spread_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3116, ads_pellet_scatter_modifier);
				SetToRestoreWeaponAttrFloat(weaponinfo, 3120, ads_pellet_scatter_modifier);
			}
		}
	}
}

void SetToRestoreWeaponAttrFloat(int weaponinfo, int offset, float modifier)
{
	Address addr = view_as<Address>(weaponinfo + offset);
	char buffer[48];
	FormatEx(buffer, sizeof(buffer), "%i", offset);
	
	float originalValue = view_as<float>(LoadFromAddress(addr, NumberType_Int32));
	hRestoreWeaponAttr.SetFloat(buffer, originalValue);
	StoreToAddress(addr, view_as<int>(originalValue * modifier), NumberType_Int32, true);
}

// Player command processing
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (!IsClientInGame(client) || GetClientTeam(client) != 2 || IsFakeClient(client))
		return Plugin_Continue;
	
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
		if (ads_holding_key && bZoom[client])
		{
			if (g_bDebug)
				PrintToServer("[ADS] Client %N released %s button (holding mode)", client, keyName);
			SetupZoom(client, GetPlayerWeapon(client), false);
		}
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
// Native Implementations
// ============================================================================

public int Native_IsClientInADS(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
		return false;
	
	return bZoom[client];
}

public int Native_ForceWeaponAnimation(Handle plugin, int numParams)
{
	int weapon = GetNativeCell(1);
	int sequence = GetNativeCell(2);
	
	if (!IsValidEntity(weapon))
		return false;
	
	return SendWeaponAnim(weapon, sequence);
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
	
	if (g_bDebug)
		PrintToServer("[ADS] PlayADSAnimation: Client %N, Activity %d", client, activity);
	
	// Get sequence and play animation
	int sequence = SelectWeightedSequence(weapon, activity);
	if (sequence != -1)
	{
		SetWeaponHelpingHandState(weapon, 6);
		return SendWeaponAnim(weapon, activity);
	}
	
	return false;
}


