/*
*	Mutant Zombies
*	Copyright (C) 2024 Silvers
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



#define PLUGIN_VERSION		"1.28"

/*======================================================================================
	Plugin Info:

*	Name	:	[L4D & L4D2] Mutant Zombies
*	Author	:	SilverShot
*	Descrp	:	New uncommon infected, mutant zombies.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=175242
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.28 (04-Aug-2024)
	- Fixed "Fire" mutants dying straight away when "check" setting in the data config was set to "1". Thanks to "sonic155" for reporting.
	- Delayed spawning by 1 frame to fix issues with Common Limiter plugins that delete the common on spawn, causing Mutant Zombie effects to stay stuck in the air. Thanks to "Automage" for reporting.

1.27 (19-Feb-2023)
	- Fixed Fire Mutants taking fire damage from other sources. Thanks to "BystanderZK" for reporting.

1.26 (10-Feb-2023)
	- Fixed invincible Fire Mutants. Thanks to "sonic155" and "Maur0" for reporting and testing.
	- Fixed Survivor bots from killing common infected instead of converting them to Fire Mutants.
	- Removed the "Smoke" type key value "color" since it was never meant to exist, the smoke is a particle and color cannot be changed. Thanks to "sonic155" for reporting.

1.25 (03-Feb-2023)
	- Changed the method of converting and preventing Fire Mutants from dying. Thanks to "sonic155" for reporting.
	- Added another check to prevent invisible common remaining alive.

1.24 (02-Feb-2023)
	- Fixed Fire Mutants not attacking when initially ignited.
	- Fixed invincible Fire Mutants bug from the last 3 plugin updates. Thanks to "Mi.Cura" for reporting.

1.23 (27-Jan-2023)
	- Fixed invisible Fire Mutants bug from the last 2 plugin updates. Thanks to "Mi.Cura" for reporting.

1.22 (25-Jan-2023)
	- Added "drop_damage" data config setting to Fire Mutants, allowing dropped fire damage to be controlled independently from the "damage" key.
	- Fixed converting common infected into Fire Mutants when shot by normal bullets.
	- Fixed incendiary bullets not always converting common infected to Fire Mutants.

1.21 (24-Jan-2023)
	- Fixed incendiary bullets not always converting common infected to Fire Mutants.
	- Fixed not setting the config health value on Fire Mutants in some circumstances.
	- Fixed various fire damage causing Fire Mutants to die prematurely.
	- Thanks to "BystanderZK" for reporting and testing.

1.20 (20-Jan-2023)
	- L4D2: Added "incendiary" data config setting to Fire Mutants, allowing common infected to convert to Fire Mutants when shot with Incendiary ammo.
	- Fixed common infected walking through fire not having the charred model effect.

1.19 (15-Dec-2022)
	- Fixed changing "attacker" to entity reference in OnTakeDamage which affects other plugins. Thanks to "Hawkins" for reporting.

1.18 (12-Dec-2022)
	- Fixed "Fire" type not spawning when walking through fire. Thanks to "BystanderZK" for reporting.

1.17 (03-Dec-2022)
	- Fixed invalid entity errors. Thanks to "Mi.Cura" for reporting.

1.16 (15-Aug-2022)
	- Changes to load the "l4d_mutants.cfg" data config based on the z_difficulty value if the file exists.
	- Valid filenames are "l4d_mutants_easy.cfg", "l4d_mutants_normal.cfg", "l4d_mutants_hard.cfg" and "l4d_mutants_impossible.cfg".
	- Requested by "Hawkins".

1.15 (30-Jul-2022)
	- Potential fix for rare server crashes caused by "CBaseEntityOutput::FireOutput". Thanks to "Hawkins" for reporting.

1.14 (07-Jun-2022)
	- Fixed mutant zombies spawning when their "random" data config setting values were set to "0". Thanks to "Winn" for reporting.
	- Removed minimum and maximum value restriction for individual mutants "random" data config setting.

1.13 (12-Sep-2021)
	- L4D1: Fixed constantly spawning Mutant Zombies due to not restricting a line of code for L4D2.

1.12 (09-Oct-2020)
	- Changed "OnClientPostAdminCheck" to "OnClientPutInServer" - to fix any issues if Steam service is down.

1.11 (30-Sep-2020)
	- Fixed compile errors on SM 1.11.

1.10 (15-May-2020)
	- Replaced "point_hurt" entity with "SDKHooks_TakeDamage" function.

1.9 (10-May-2020)
	- Extra checks to prevent "IsAllowedGameMode" throwing errors.
	- Various changes to tidy up code.
	- Various optimizations and fixes.

1.8 (08-Apr-2020)
	- Fixed invalid entity index errors. Thanks to "sxslmk" reporting.

1.7 (01-Apr-2020)
	- Fixed not precaching "env_shake" causing the Bomb type to stutter on first explosion. Thanks to "TiTz" for reporting.
	- Fixed clients giving themselves damage instead of from the server. Thanks to "TiTz" for reporting.
	- Fixed "IsAllowedGameMode" from throwing errors when the "_tog" cvar was changed before MapStart.

1.6 (18-Mar-2020)
	- Changed the random spawn selection method to use >= instead of > value.
	- Now you can specify "random" "1" in the config to make every common infected spawned a Mutant Zombie.
	- This also applies to each types individual "random" setting.

	- Added "uncommon" data config setting. This allows uncommon infected to also be Mutants. Default off.
	- Fixed "check" data config setting from never actually being read.

1.5.1 (28-Jun-2019)
	- Changed PrecacheParticle method.

1.5.0 (05-May-2018)
	- Converted plugin source to the latest syntax utilizing methodmaps. Requires SourceMod 1.8 or newer.
	- Changed cvar "l4d_mutants_modes_tog" now supports L4D1.

1.4.3 (01-Apr-2018)
	- Fixed bug in L4D2.
	- Uploaded correct data config for L4D2, previous one broke Tesla and Spit mutants.

1.4.2 (31-Mar-2018)
	- Tesla Mutants now working in L4D1, with reduced visual effects.

1.4.1 (31-Mar-2018)
	- Added check for very rare and very strange error - "Dragokas"
	- Fixed particle error in L4D1.
	- Fixed bomb position in L4D1.
	- Data config renamed to "l4d_mutants.cfg"

1.4 (23-Mar-2018)
	- Initial support for L4D1.

1.3 (10-May-2012)
	- Added cvar "l4d_mutants_modes_off" to control which game modes the plugin works in.
	- Added cvar "l4d_mutants_modes_tog" same as above, but only works for L4D2.
	- Fixed a bug when gascans etc exploded, which prevented common from being ignited.
	- Fixed a bug with the "random" option in the config not working as expected.

1.2 (15-Jan-2012)
	- Fixed "effects" not setting correctly on "Mind" type.

1.1 (14-Jan-2012)
	- Added command "sm_mutantsrefresh" to refresh the plugin and reload the data config.
	- Fixed "types" config not setting when "random" was set to 0.

1.0 (01-Jan-2012)
	- Initial release.

========================================================================================

	This plugin was made using source code from the following plugins.
	If I have used your code and not credited you, please let me know.

*	Thanks to "AtomicStryker" for "[L4D & L4D2] Boomer Splash Damage"
	https://forums.alliedmods.net/showthread.php?t=98794

*	Thanks to "honorcode23" for "[L4D-L4D2] New custom commands"
	https://forums.alliedmods.net/showthread.php?p=1251446

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
#include <sdkhooks>

#define CVAR_FLAGS				FCVAR_NOTIFY
#define CONFIG_DATA				"data/l4d_mutants.cfg"
#define MAX_ENTS				70
#define MAX_ORDER				32

#define MODEL_PROPANE			"models/props_junk/propanecanister001a.mdl"
#define MODEL_SPRITE			"models/sprites/glow01.spr"
#define PARTICLE_BOMB			"sparks_generic_random"
#define PARTICLE_BOMB1			"flare_burning"
#define PARTICLE_BOMB2			"weapon_molotov_held"
#define PARTICLE_BOMB3			"weapon_pipebomb"
#define PARTICLE_FIRE			"burning_engine_fire"
#define PARTICLE_FIRE2			"fire_medium_base"
#define PARTICLE_SPIT			"spitter_slime_trail"
#define PARTICLE_SPIT2			"spitter_projectile_trail_old"
#define PARTICLE_SPIT_PROJ1		"spitter_projectile_explode"
#define PARTICLE_SPIT_PROJ2		"spitter_projectile_explode_2"
#define PARTICLE_SMOKE			"apc_wheel_smoke1"
#define PARTICLE_DEFIB			"item_defibrillator_body"
#define PARTICLE_ELMOS			"st_elmos_fire_cp0"
#define PARTICLE_TESLA			"electrical_arc_01"
#define PARTICLE_TESLA2			"electrical_arc_01_system"
#define PARTICLE_TESLA3			"st_elmos_fire"
#define PARTICLE_TESLA4			"storm_lightning_02"
#define PARTICLE_TESLA5			"storm_lightning_01"
#define PARTICLE_TESLA6			"impact_ricochet_sparks"
#define PARTICLE_TESLA7			"railroad_wheel_sparks"
#define SOUND_SPIT1				"player/spitter/swarm/spitter_acid_fadeout.wav"
#define SOUND_SPIT2				"player/spitter/swarm/spitter_acid_fadeout2.wav"
#define SOUND_EXPLODE3			"weapons/hegrenade/explode3.wav"
#define SOUND_EXPLODE4			"weapons/hegrenade/explode4.wav"
#define SOUND_EXPLODE5			"weapons/hegrenade/explode5.wav"


static const char g_sSoundsZap[8][25] =
{
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav"
};


ConVar g_hCvarAllow, g_hCvarDifficulty, g_hCvarMPGameMode, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog;
int g_iSpitHurtCount[MAXPLAYERS+1];
float g_fFireHurtCount[MAXPLAYERS+1];
bool g_bLeft4Dead2;
int g_iInfectedBomb[MAX_ENTS][4];
int g_iInfectedFire[MAX_ENTS][3];
int g_iInfectedGhost[MAX_ENTS];
int g_iInfectedMind[MAX_ENTS][5];
int g_iInfectedSmoke[MAX_ENTS][3];
int g_iInfectedSpit[MAX_ENTS][3]; // [0] = Common infected, [1] = ParticleA, [2] = ParticleB
int g_iInfectedTesla[MAX_ENTS][2];
int g_iFireHealth[2048];

// Global variables
int g_iCheckInferno, g_iLoadStatus, g_iPlayerSpawn, g_iRoundStart;
bool g_bCvarAllow, g_bMapStarted, g_bHookCommonSpawn, g_bLateLoad;
// Mind type variables to display the same types to both teams in Versus/Scavenge
int g_iMindOrderCount, g_iMindOrderDone, g_iMindOrderGet, g_iMindOrder[MAX_ORDER];
// Mutant spawn variables
int g_iSpawnAmount, g_iSpawnBomb, g_iSpawnFire, g_iSpawnGhost, g_iSpawnMind, g_iSpawnSmoke, g_iSpawnSpit, g_iSpawnTesla;
bool g_bHookCommonBomb, g_bHookCommonFire, g_bHookCommonGhost, g_bHookCommonMind, g_bHookCommonSmoke, g_bHookCommonSpit, g_bHookCommonTesla;
// Global config variables
int g_iConfCheck, g_iConfLimit, g_iConfRandom, g_iConfTypes, g_iConfUncommon;
// Bomb config variables
int g_iConfBombExplodeA, g_iConfBombExplodeD, g_iConfBombExplodeH, g_iConfBombGlow, g_iConfBombGlowCol, g_iConfBombHealth, g_iConfBombLimit, g_iConfBombRandom, g_iConfBombShake;
float g_fConfBombDamage, g_fConfBombDamageD, g_fConfBombDistance;
// Fire config variables
int g_iConfFireDrop1, g_iConfFireDrop2, g_iConfFireGlow, g_iConfFireGlowCol, g_iConfFireHealth, g_iConfFireLimit, g_iConfFireRandom, g_iConfFireWalk, g_iConfFireIncen;
float g_fConfFireDamage, g_fConfFireTime, g_fConfFireDrop3;
// Ghost config variables
int g_iConfGhostGlow, g_iConfGhostGlowCol, g_iConfGhostHealth, g_iConfGhostLimit, g_iConfGhostOpacity, g_iConfGhostRandom;
float g_fConfGhostDamage;
// Mind config variables
int g_iConfMindEffects, g_iConfMindGlow, g_iConfMindGlowCol, g_iConfMindHealth, g_iConfMindLimit, g_iConfMindRandom;
float g_fConfMindDamage, g_fConfMindDistance;
// Smoke config variables
int g_iConfSmokeGlow, g_iConfSmokeGlowCol, g_iConfSmokeHealth, g_iConfSmokeLimit, g_iConfSmokeRandom;
float g_fConfSmokeDamage2, g_fConfSmokeDamage, g_fConfSmokeDistance;
// Spit config variables
int g_iConfSpitEffects, g_iConfSpitGlow, g_iConfSpitGlowCol, g_iConfSpitHealth, g_iConfSpitHurt, g_iConfSpitLimit, g_iConfSpitRandom, g_iConfSpitWalk;
float g_fConfSpitDamage, g_fConfSpitTime;
// Tesla config variables
int g_iConfTeslaEffects, g_iConfTeslaGlow, g_iConfTeslaGlowCol, g_iConfTeslaHealth, g_iConfTeslaLimit, g_iConfTeslaRandom;
float g_fConfTeslaDamage, g_fConfTeslaForce, g_fConfTeslaForceZ;


enum
{
	TYPE_BOMB	= (1 << 0),
	TYPE_FIRE	= (1 << 1),
	TYPE_GHOST	= (1 << 2),
	TYPE_MIND	= (1 << 3),
	TYPE_SMOKE	= (1 << 4),
	TYPE_SPIT	= (1 << 5),
	TYPE_TESLA	= (1 << 6),
	TYPE_DROP	= (1 << 7)
}

enum
{
	ENUM_PARTICLE_BOMB = 1,
	ENUM_PARTICLE_BOMB1,
	ENUM_PARTICLE_BOMB2,
	ENUM_PARTICLE_BOMB3,
	ENUM_PARTICLE_FIRE,
	ENUM_PARTICLE_FIRE2,
	ENUM_PARTICLE_SMOKE,
	ENUM_PARTICLE_SPIT,
	ENUM_PARTICLE_SPIT2,
	ENUM_PARTICLE_TESLA
}



// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D & L4D2] Mutant Zombies",
	author = "SilverShot",
	description = "New uncommon infected, mutant zombies.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=175242"
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

	g_bLateLoad = late;

	RegPluginLibrary("l4d_mutants");

	return APLRes_Success;
}

public void OnPluginStart()
{
	g_hCvarAllow =			CreateConVar(	"l4d_mutants_allow",		"1",			"0=Plugin off, 1=Plugin on.", CVAR_FLAGS);
	g_hCvarModes =			CreateConVar(	"l4d_mutants_modes",		"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =		CreateConVar(	"l4d_mutants_modes_off",	"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =		CreateConVar(	"l4d_mutants_modes_tog",	"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	CreateConVar(							"l4d2_mutants_version",		PLUGIN_VERSION,	"Mutant Zombies plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,					"l4d_mutants");

	RegAdminCmd("sm_mutantsrefresh",	CmdMutantsRefresh,	ADMFLAG_ROOT,	"Refreshes the plugin and reloads the data config.");
	RegAdminCmd("sm_mutantbomb",		CmdMutantBomb,		ADMFLAG_ROOT,	"Spawns a Mutant Bomb Zombie.");
	RegAdminCmd("sm_mutantfire",		CmdMutantFire,		ADMFLAG_ROOT,	"Spawns a Mutant Fire Zombie.");
	RegAdminCmd("sm_mutantghost",		CmdMutantGhost,		ADMFLAG_ROOT,	"Spawns a Mutant Ghost Zombie.");
	RegAdminCmd("sm_mutantmind",		CmdMutantMind,		ADMFLAG_ROOT,	"Spawns a Mutant Mind Zombie. Usage: sm_mutantmind <type 1=Ghost, 2=Red, 4=Lightning, 8=Yellow, 16=Infected, 32=Thirdstrike, 64=Blue, 128=Sunrise>");
	RegAdminCmd("sm_mutantsmoke",		CmdMutantSmoke,		ADMFLAG_ROOT,	"Spawns a Mutant Smoke Zombie.");
	RegAdminCmd("sm_mutantspit",		CmdMutantSpit,		ADMFLAG_ROOT,	"Spawns a Mutant Spit Zombie.");
	RegAdminCmd("sm_mutanttesla",		CmdMutantTesla,		ADMFLAG_ROOT,	"Spawns a Mutant Tesla Zombie.");
	RegAdminCmd("sm_mutants",			CmdMutants,			ADMFLAG_ROOT,	"Spawns all Mutant Zombies.");

	g_hCvarDifficulty = FindConVar("z_difficulty");
	g_hCvarDifficulty.AddChangeHook(ConVarChanged_Diff);

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
}

public void OnPluginEnd()
{
	g_bCvarAllow = false;
	ResetPlugin(true);
}



// ====================================================================================================
//					MAP END / START
// ====================================================================================================
public void OnMapEnd()
{
	g_bMapStarted = false;
	g_iLoadStatus = 0;
	g_iPlayerSpawn = 0;
	g_iRoundStart = 0;
	g_iMindOrderDone = 0;
	g_iMindOrderCount = 0;
	g_iMindOrderGet = 0;
	ResetPlugin(true);
}

public void OnMapStart()
{
	g_bMapStarted = true;

	PrecacheModel(MODEL_PROPANE, true);
	PrecacheModel(MODEL_SPRITE, true);

	PrecacheParticle(PARTICLE_BOMB2);
	PrecacheParticle(PARTICLE_BOMB3);
	PrecacheParticle(PARTICLE_FIRE);
	PrecacheParticle(PARTICLE_FIRE2);
	PrecacheParticle(PARTICLE_SMOKE);
	PrecacheParticle(PARTICLE_TESLA);
	PrecacheParticle(PARTICLE_TESLA2);
	PrecacheParticle(PARTICLE_TESLA3);
	if( g_bLeft4Dead2 )
	{
		PrecacheParticle(PARTICLE_BOMB);
		PrecacheParticle(PARTICLE_BOMB1);
		PrecacheParticle(PARTICLE_SPIT);
		PrecacheParticle(PARTICLE_SPIT2);
		PrecacheParticle(PARTICLE_SPIT_PROJ1);
		PrecacheParticle(PARTICLE_SPIT_PROJ2);
		PrecacheParticle(PARTICLE_TESLA4);
		PrecacheParticle(PARTICLE_TESLA5);
		PrecacheParticle(PARTICLE_DEFIB);
	} else {
		PrecacheParticle(PARTICLE_ELMOS);
		PrecacheParticle(PARTICLE_TESLA6);
		PrecacheParticle(PARTICLE_TESLA7);
	}

	if( g_bLeft4Dead2 )
	{
		PrecacheSound(SOUND_SPIT1, true);
		PrecacheSound(SOUND_SPIT2, true);
	}
	PrecacheSound(SOUND_EXPLODE3, true);
	PrecacheSound(SOUND_EXPLODE4, true);
	PrecacheSound(SOUND_EXPLODE5, true);

	for( int i = 0; i < 8; i++ )
		PrecacheSound(g_sSoundsZap[i], true);



	// Pre-cache env_shake -_- WTF
	int shake  = CreateEntityByName("env_shake");
	if( shake != -1 )
	{
		DispatchKeyValue(shake, "spawnflags", "8");
		DispatchKeyValue(shake, "amplitude", "16.0");
		DispatchKeyValue(shake, "frequency", "1.5");
		DispatchKeyValue(shake, "duration", "0.9");
		DispatchKeyValue(shake, "radius", "50");
		TeleportEntity(shake, view_as<float>({ 0.0, 0.0, -1000.0 }), NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(shake);
		ActivateEntity(shake);
		AcceptEntityInput(shake, "Enable");
		AcceptEntityInput(shake, "StartShake");
		RemoveEdict(shake);
	}



	// Other
	LoadDataConfig();

	if( g_bLateLoad && g_bCvarAllow )
	{
		LateLoad();
		g_bLateLoad = false;
	}
}

void LateLoad()
{
	g_iLoadStatus = 1;

	for( int i = 1; i <= MaxClients; i++ )
		if( IsClientInGame(i) )
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
}



// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Diff(Handle convar, const char[] oldValue, const char[] newValue)
{
	LoadDataConfig();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();

	if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
		ResetPlugin(true);
		HookEvents(false);
	}

	else if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;
		LateLoad();
		HookEvents(true);
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
		if( g_bMapStarted == false )
			return false;

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



// ====================================================================================================
//					RESET / CLEAN UP
// ====================================================================================================
void ResetPlugin(bool all = false)
{
	g_bHookCommonSpawn = false;
	g_bHookCommonBomb = false;
	g_bHookCommonFire = false;
	g_bHookCommonGhost = false;
	g_bHookCommonMind = false;
	g_bHookCommonSmoke = false;
	g_bHookCommonSpit = false;
	g_bHookCommonTesla = false;

	g_iSpawnBomb = 0;
	g_iSpawnFire = 0;
	g_iSpawnGhost = 0;
	g_iSpawnMind = 0;
	g_iSpawnSmoke = 0;
	g_iSpawnSpit = 0;
	g_iSpawnTesla = 0;

	for( int i = 0; i < MAX_ENTS; i++ )
	{
		DeleteEntity(TYPE_BOMB, i);
		DeleteEntity(TYPE_FIRE, i);
		DeleteEntity(TYPE_GHOST, i);
		DeleteEntity(TYPE_MIND, i);
		DeleteEntity(TYPE_SMOKE, i);
		DeleteEntity(TYPE_SPIT, i);
		DeleteEntity(TYPE_TESLA, i);
	}

	if( all == true )
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			if( IsClientInGame(i) )
			{
				SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}

		int entity = -1;
		while( (entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE )
		{
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamageBomb);
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamageFire);
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnCommonFireDamage);
		}
	}
}

void TurnOffGlow(int entity, int glowcol)
{
	if( !g_bLeft4Dead2 ) return;

	if( IsValidEntRef(entity) )
	{
		int glow = GetEntProp(entity, Prop_Send, "m_glowColorOverride");
		if( glow == glowcol )
		{
			SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(entity, Prop_Send, "m_nGlowRange", 1);
			SetEntProp(entity, Prop_Send, "m_iGlowType", 0);
		}
	}
}

void DeleteEntity(int type, int index)
{
	// Not sure how it is possible, but SM sometimes returns "Array index out-of-bounds (index -1, limit 70)"			- Thanks to "Dragokas" for reporting.
	if( index < 0 )
		return;

	int entity;

	switch( type )
	{
		case TYPE_BOMB:
		{
			if( g_iConfBombGlowCol )
				TurnOffGlow(g_iInfectedBomb[index][0], g_iConfBombGlowCol);

			entity = g_iInfectedBomb[index][1];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			entity = g_iInfectedBomb[index][2];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			entity = g_iInfectedBomb[index][3];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			g_iInfectedBomb[index][0] = 0;
			g_iInfectedBomb[index][1] = 0;
			g_iInfectedBomb[index][2] = 0;
			g_iInfectedBomb[index][3] = 0;
		}

		case TYPE_FIRE:
		{
			if( g_iConfFireGlowCol )
				TurnOffGlow(g_iInfectedFire[index][0], g_iConfFireGlowCol);

			entity = g_iInfectedFire[index][1];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			entity = g_iInfectedFire[index][2];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			g_iInfectedFire[index][0] = 0;
			g_iInfectedFire[index][1] = 0;
			g_iInfectedFire[index][2] = 0;
		}

		case TYPE_GHOST:
		{
			if( g_iConfGhostGlowCol )
				TurnOffGlow(g_iInfectedGhost[index], g_iConfGhostGlowCol);

			entity = g_iInfectedGhost[index];
			if( IsValidEntRef(entity) )
				SetOpacity(entity, 255);

			g_iInfectedGhost[index] = 0;
		}

		case TYPE_MIND:
		{
			if( g_iConfMindGlowCol )
				TurnOffGlow(g_iInfectedMind[index][0], g_iConfMindGlowCol);

			entity = g_iInfectedMind[index][1];
			if( IsValidEntRef(entity) )
			{
				AcceptEntityInput(entity, "TurnOff");
				SetVariantString("OnUser1 !self:Kill::3:-1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}

			entity = g_iInfectedMind[index][2];
			if( IsValidEntRef(entity) )
			{
				float vMins[3]; vMins = view_as<float>({-1.0, -1.0, -1.0});
				float vMaxs[3]; vMaxs = view_as<float>({1.0, 1.0, 1.0});
				SetEntPropVector(entity, Prop_Send, "m_vecMins", vMins);
				SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vMaxs);

				AcceptEntityInput(entity, "TurnOff");
				SetVariantString("OnUser1 !self:Kill::3:-1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}

			entity = g_iInfectedMind[index][3];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			entity = g_iInfectedMind[index][4];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			g_iInfectedMind[index][0] = 0;
			g_iInfectedMind[index][1] = 0;
			g_iInfectedMind[index][2] = 0;
			g_iInfectedMind[index][3] = 0;
			g_iInfectedMind[index][4] = 0;
		}

		case TYPE_SMOKE:
		{
			if( g_iConfSmokeGlowCol )
				TurnOffGlow(g_iInfectedSmoke[index][0], g_iConfSmokeGlowCol);

			entity = g_iInfectedSmoke[index][1];
			if( IsValidEntRef(entity) )
			{
				AcceptEntityInput(entity, "TurnOff");
				SetVariantString("OnUser1 !self:Kill::10:-1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}

			entity = g_iInfectedSmoke[index][2];
			if( IsValidEntRef(entity) )
			{
				SetVariantString("OnUser1 !self:Kill::3:-1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}

			g_iInfectedSmoke[index][0] = 0;
			g_iInfectedSmoke[index][1] = 0;
			g_iInfectedSmoke[index][2] = 0;
		}

		case TYPE_SPIT:
		{
			if( g_iConfSpitGlowCol )
				TurnOffGlow(g_iInfectedSpit[index][0], g_iConfSpitGlowCol);

			entity = g_iInfectedSpit[index][1];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			entity = g_iInfectedSpit[index][2];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			g_iInfectedSpit[index][0] = 0;
			g_iInfectedSpit[index][1] = 0;
			g_iInfectedSpit[index][2] = 0;
		}

		case TYPE_TESLA:
		{
			if( g_iConfTeslaGlowCol )
				TurnOffGlow(g_iInfectedTesla[index][0], g_iConfTeslaGlowCol);

			entity = g_iInfectedTesla[index][1];
			if( IsValidEntRef(entity) )
				RemoveEntity(entity);

			g_iInfectedTesla[index][0] = 0;
			g_iInfectedTesla[index][1] = 0;
		}
	}
}



// ====================================================================================================
//					CFG
// ====================================================================================================
void LoadDataConfig()
{
	char sPath[PLATFORM_MAX_PATH];

	// Load configs based on difficulty, if available
	BuildPath(Path_SM, sPath, sizeof(sPath), CONFIG_DATA);

	// Get difficulty
	char sDiff[64];
	g_hCvarDifficulty.GetString(sDiff, sizeof(sDiff));
	StrToLowerCase(sDiff, sDiff, sizeof(sDiff));

	// Format config "data/l4d_mutants_normal.cfg" for example
	sPath[strlen(sPath) - 4] = 0;
	Format(sPath, sizeof(sPath), "%s_%s.cfg", sPath, sDiff);

	if( FileExists(sPath) == false )
	{
		// Load default config
		BuildPath(Path_SM, sPath, sizeof(sPath), CONFIG_DATA);
		if( !FileExists(sPath) )
		{
			SetFailState("Missing config '%s' please re-install.", CONFIG_DATA);
		}
	}

	KeyValues hFile = new KeyValues("Mutants");
	if( !hFile.ImportFromFile(sPath) )
	{
		delete hFile;
		SetFailState("Error reading config '%s' please re-install.", CONFIG_DATA);
	}

	char sTemp[32];

	if( hFile.JumpToKey("Settings") )
	{
		g_iConfCheck =			hFile.GetNum("check",				0);
		g_iConfLimit =			hFile.GetNum("limit",				0);
		g_iConfLimit =			Clamp(g_iConfLimit,					70);
		g_iConfRandom =			hFile.GetNum("random",				0);
		g_iConfTypes =			hFile.GetNum("types",				0);
		g_iConfTypes =			Clamp(g_iConfTypes,					127);
		g_iConfUncommon =		hFile.GetNum("uncommon",			0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Bomb") )
	{
		g_fConfBombDamage =		hFile.GetFloat("damage",			0.0);
		g_fConfBombDamageD =	hFile.GetFloat("damage_bomb",		0.0);
		g_fConfBombDistance =	hFile.GetFloat("distance",			0.0);
		g_iConfBombExplodeA =	hFile.GetNum("explode_attack",		0);
		g_iConfBombExplodeD =	hFile.GetNum("explode_defend",		0);
		g_iConfBombExplodeH =	hFile.GetNum("explode_headshot",	0);
		g_iConfBombGlow =		hFile.GetNum("glow",				0);
		hFile.GetString("glow_color", sTemp, sizeof(sTemp),			"");
		g_iConfBombGlowCol =	GetColor(sTemp);
		g_iConfBombHealth =		hFile.GetNum("health",				0);
		g_iConfBombLimit =		hFile.GetNum("limit",				0);
		g_iConfBombRandom =		hFile.GetNum("random",				0);
		g_iConfBombShake =		hFile.GetNum("shake",				0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Fire") )
	{
		g_fConfFireDamage =		hFile.GetFloat("damage",			0.0);
		g_iConfFireDrop1 =		hFile.GetNum("drop_attack",			0);
		g_iConfFireDrop2 =		hFile.GetNum("drop_defend",			0);
		g_fConfFireDrop3 =		hFile.GetFloat("drop_damage",		0.0);
		g_iConfFireGlow =		hFile.GetNum("glow",				0);
		hFile.GetString("glow_color", sTemp, sizeof(sTemp),			"");
		g_iConfFireGlowCol =	GetColor(sTemp);
		g_iConfFireHealth =		hFile.GetNum("health",				0);
		g_iConfFireLimit =		hFile.GetNum("limit",				0);
		g_iConfFireLimit =		Clamp(g_iConfFireLimit,				10);
		g_iConfFireRandom =		hFile.GetNum("random",				0);
		g_fConfFireTime =		hFile.GetFloat("time",				0.0);
		g_iConfFireWalk =		hFile.GetNum("walk",				0);
		if( g_bLeft4Dead2 )
			g_iConfFireIncen =	hFile.GetNum("incendiary",			0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Ghost") )
	{
		g_fConfGhostDamage =	hFile.GetFloat("damage",			0.0);
		g_iConfGhostGlow =		hFile.GetNum("glow",				0);
		hFile.GetString("glow_color", sTemp, sizeof(sTemp),			"");
		g_iConfGhostGlowCol =	GetColor(sTemp);
		g_iConfGhostHealth =	hFile.GetNum("health",				0);
		g_iConfGhostLimit =		hFile.GetNum("limit",				0);
		g_iConfGhostLimit =		Clamp(g_iConfGhostLimit,			10);
		g_iConfGhostOpacity =	hFile.GetNum("opacity",				0);
		g_iConfGhostRandom =	hFile.GetNum("random",				0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Mind") )
	{
		g_fConfMindDamage =		hFile.GetFloat("damage",			0.0);
		g_fConfMindDistance =	hFile.GetFloat("distance",			0.0);
		g_iConfMindEffects =	hFile.GetNum("effects",				0);
		g_iConfMindEffects =	Clamp(g_iConfMindEffects,			63);
		g_iConfMindGlow =		hFile.GetNum("glow",				0);
		hFile.GetString("glow_color", sTemp, sizeof(sTemp),			"");
		g_iConfMindGlowCol =	GetColor(sTemp);
		g_iConfMindHealth =		hFile.GetNum("health",				0);
		g_iConfMindLimit =		hFile.GetNum("limit",				0);
		g_iConfMindLimit =		Clamp(g_iConfMindLimit,				10);
		g_iConfMindRandom =		hFile.GetNum("random",				0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Smoke") )
	{
		g_fConfSmokeDamage =	hFile.GetFloat("damage",			0.0);
		g_fConfSmokeDamage2 =	hFile.GetFloat("damage_smoke",		0.0);
		g_fConfSmokeDistance =	hFile.GetFloat("distance",			0.0);
		g_iConfSmokeGlow =		hFile.GetNum("glow",				0);
		hFile.GetString("glow_color", sTemp, sizeof(sTemp),			"");
		g_iConfSmokeGlowCol =	GetColor(sTemp);
		g_iConfSmokeHealth =	hFile.GetNum("health",				0);
		g_iConfSmokeLimit =		hFile.GetNum("limit",				0);
		g_iConfSmokeLimit =		Clamp(g_iConfSmokeLimit,			10);
		g_iConfSmokeRandom =	hFile.GetNum("random",				0);
		hFile.Rewind();
	}

	if( g_bLeft4Dead2 && hFile.JumpToKey("Spit") )
	{
		g_fConfSpitDamage =		hFile.GetFloat("damage",			0.0);
		g_iConfSpitHurt =		hFile.GetNum("damage_multiple",		0);
		g_iConfSpitEffects =	hFile.GetNum("effects",				0);
		g_iConfSpitEffects =	Clamp(g_iConfSpitEffects,			6);
		g_iConfSpitGlow =		hFile.GetNum("glow",				0);
		hFile.GetString("glow_color", sTemp, sizeof(sTemp),			"");
		g_iConfSpitGlowCol =	GetColor(sTemp);
		g_iConfSpitHealth =		hFile.GetNum("health",				0);
		g_iConfSpitLimit =		hFile.GetNum("limit",				0);
		g_iConfSpitLimit =		Clamp(g_iConfSpitLimit,				10);
		g_iConfSpitRandom =		hFile.GetNum("random",				0);
		g_fConfSpitTime =		hFile.GetFloat("time",				0.0);
		g_iConfSpitWalk =		hFile.GetNum("walk",				0);
		hFile.Rewind();
	}

	if( hFile.JumpToKey("Tesla") )
	{
		g_fConfTeslaDamage =	hFile.GetFloat("damage",			0.0);
		g_iConfTeslaEffects =	hFile.GetNum("effects",				0);
		g_iConfTeslaEffects =	Clamp(g_iConfTeslaEffects, 			63, 1);
		g_fConfTeslaForce =		hFile.GetFloat("force",				0.0);
		g_fConfTeslaForceZ =	hFile.GetFloat("force_z",			0.0);
		g_iConfTeslaGlow =		hFile.GetNum("glow",				0);
		hFile.GetString("glow_color", sTemp, sizeof(sTemp),			"");
		g_iConfTeslaGlowCol =	GetColor(sTemp);
		g_iConfTeslaHealth =	hFile.GetNum("health",				0);
		g_iConfTeslaLimit =		hFile.GetNum("limit",				0);
		g_iConfTeslaLimit =		Clamp(g_iConfTeslaLimit,			10);
		g_iConfTeslaRandom =	hFile.GetNum("random",				0);
		hFile.Rewind();
	}

	GetCurrentMap(sTemp, sizeof(sTemp));
	if( hFile.JumpToKey(sTemp) )
	{
		g_iConfTypes =			hFile.GetNum("types",				g_iConfTypes);
		g_iConfTypes =			Clamp(g_iConfTypes,					127);
	}

	delete hFile;

	if( !g_bLeft4Dead2 )
	{
		// Disable Spit and fix Tesla - Dragokas
		if( g_iConfTypes & TYPE_SPIT)				g_iConfTypes &= ~TYPE_SPIT;
		if( g_iConfTeslaEffects & (1<<2) )			g_iConfTeslaEffects &= ~(1<<2);
		if( g_iConfTeslaEffects & (1<<3) )			g_iConfTeslaEffects &= ~(1<<3);
		if( g_iConfTeslaEffects & (1<<4) )			g_iConfTeslaEffects &= ~(1<<4);
	}
}

int Clamp(int value, int max, int min = 0)
{
	if( value < min )
		value = min;
	else if( value > max )
		value = max;
	return value;
}

int GetColor(char[] sTemp)
{
	if( sTemp[0] == 0 )
		return 0;

	char sColors[3][4];
	int color = ExplodeString(sTemp, " ", sColors, sizeof(sColors), sizeof(sColors[]));

	if( color != 3 )
		return 0;

	color = StringToInt(sColors[0]);
	color += 256 * StringToInt(sColors[1]);
	color += 65536 * StringToInt(sColors[2]);

	return color;
}



// ====================================================================================================
//					SURVIVORS - ONTAKEDAMAGE
// ====================================================================================================
public void OnClientPutInServer(int client)
{
	if( g_bCvarAllow )
	{
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if( damagetype == DMG_CLUB && attacker > MaxClients && GetClientTeam(victim) == 2 )
	{
		int entref = EntIndexToEntRef(attacker);

		for( int i = 0; i < MAX_ENTS; i++ )
		{
			// Bomb
			if( g_iInfectedBomb[i][0] == entref )
			{
				if( GetRandomInt(1, 100) <= g_iConfBombExplodeA )
					BombDetonate(i);

				damage = g_fConfBombDamage;
				return Plugin_Changed;
			}

			// Fire
			if( g_iInfectedFire[i][0] == entref )
			{
				if( GetRandomInt(1, 100) <= g_iConfFireDrop1 )
					FireDrop(entref);

				damagetype = DMG_BURN;
				if( g_fConfFireDamage )
					damage = g_fConfFireDamage;
				return Plugin_Changed;
			}

			// Ghost
			if( g_fConfGhostDamage && g_iInfectedGhost[i] == entref )
			{
				damage = g_fConfGhostDamage;
				return Plugin_Changed;
			}

			// Mind
			if( g_fConfMindDamage && g_iInfectedMind[i][0] == entref )
			{
				damage = g_fConfMindDamage;
				return Plugin_Changed;
			}

			// Smoke
			if( g_fConfSmokeDamage && g_iInfectedSmoke[i][0] == entref )
			{
				damage = g_fConfSmokeDamage;
				return Plugin_Changed;
			}

			// Spit
			if( g_bLeft4Dead2 && g_iInfectedSpit[i][0] == entref )
			{
				HurtClient(victim, TYPE_SPIT);
				if( g_iConfSpitHurt && g_iSpitHurtCount[victim] == 0 )
					CreateTimer(g_fConfSpitTime, TimerHurt, GetClientUserId(victim), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				g_iSpitHurtCount[victim] = 1;

				// damagetype = 263168;
				if( g_fConfSpitDamage )
					damage = g_fConfSpitDamage;
				return Plugin_Changed;
			}

			// Tesla
			if( g_iInfectedTesla[i][0] == entref )
			{
				TeslaShock(entref, victim);

				if( g_fConfTeslaDamage )
					damage = g_fConfTeslaDamage;
				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}



// ====================================================================================================
//					HURT PLAYERS
// ====================================================================================================
// Spit infected hurt, repeat hurt
Action TimerHurt(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if( client && IsClientInGame(client) && IsPlayerAlive(client) )
	{
		HurtClient(client, TYPE_SPIT);

		if( GetRandomInt(0, 1) )
			EmitSoundToAll(SOUND_SPIT1, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		else
			EmitSoundToAll(SOUND_SPIT2, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);

		g_iSpitHurtCount[client]++;
		if( g_iSpitHurtCount[client] > g_iConfSpitHurt )
		{
			g_iSpitHurtCount[client] = 0;
			return Plugin_Stop;
		}
	}
	else
	{
		g_iSpitHurtCount[client] = 0;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

void HurtClient(int client, int type = 0)
{
	switch( type )
	{
		case TYPE_DROP:		SDKHooks_TakeDamage(client, 0, 0, g_fConfFireDrop3,		DMG_BURN);
		case TYPE_FIRE:		SDKHooks_TakeDamage(client, 0, 0, g_fConfFireDamage,	DMG_BURN);
		case TYPE_SPIT:		SDKHooks_TakeDamage(client, 0, 0, g_fConfSpitDamage,	DMG_GENERIC);
		case TYPE_SMOKE:	SDKHooks_TakeDamage(client, 0, 0, g_fConfSmokeDamage2,	DMG_NERVEGAS);
		case TYPE_TESLA:	SDKHooks_TakeDamage(client, 0, 0, g_fConfTeslaDamage,	DMG_SONIC);
	}

	if( type == TYPE_SPIT && GetRandomInt(0, 2) == 0 )
	{
		int particle = CreateEntityByName("info_particle_system");
		if( GetRandomInt(0, 1) == 0 )
			DispatchKeyValue(particle, "effect_name", PARTICLE_SPIT_PROJ1);
		else
			DispatchKeyValue(particle, "effect_name", PARTICLE_SPIT_PROJ2);

		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "Start");

		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", client);
		SetVariantString("forward");
		AcceptEntityInput(particle, "SetParentAttachment");
	}
}



// ====================================================================================================
//					EVENTS
// ====================================================================================================
void HookEvents(bool hook)
{
	static bool hooked;

	if( hook && !hooked )
	{
		HookEvent("round_end",					Event_RoundEnd,		EventHookMode_PostNoCopy);
		HookEvent("round_start",				Event_RoundStart,	EventHookMode_PostNoCopy);
		HookEvent("player_spawn",				Event_PlayerSpawn,	EventHookMode_PostNoCopy);
		HookEvent("player_death",				Event_PlayerDeath,	EventHookMode_Pre);
		hooked = true;
	}
	else if( !hook && hooked )
	{
		UnhookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
		UnhookEvent("round_start",				Event_RoundStart,	EventHookMode_PostNoCopy);
		UnhookEvent("player_spawn",				Event_PlayerSpawn,	EventHookMode_PostNoCopy);
		UnhookEvent("player_death",				Event_PlayerDeath,	EventHookMode_Pre);
		hooked = false;
	}
}

// Common Infected die, clean up effects
void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int common = event.GetInt("entityid");
	if( common )
	{
		int ref = EntIndexToEntRef(common);

		for( int i = 0; i < MAX_ENTS; i++ )
		{
			if( g_iInfectedBomb[i][0] == ref )
			{
				if( g_iConfBombExplodeH )
				{
					bool headshot = event.GetBool("headshot");
					if( headshot && GetRandomInt(1, 100) <= g_iConfBombExplodeH )
					{
						int attacker = event.GetInt("attacker");
						if( attacker )
							attacker = GetClientOfUserId(attacker);
						BombDetonate(i);
					}
				}

				DeleteEntity(TYPE_BOMB, i);
				return;
			}

			if( g_iInfectedFire[i][0] == ref )
			{
				DeleteEntity(TYPE_FIRE, i);
				return;
			}

			if( g_iInfectedMind[i][0] == ref )
			{
				DeleteEntity(TYPE_MIND, i);
				return;
			}

			if( g_iInfectedSmoke[i][0] == ref )
			{
				DeleteEntity(TYPE_SMOKE, i);
				return;
			}

			if( g_iInfectedSpit[i][0] == ref )
			{
				DeleteEntity(TYPE_SPIT, i);
				return;
			}

			if( g_iInfectedTesla[i][0] == ref )
			{
				DeleteEntity(TYPE_TESLA, i);
				return;
			}
		}
	}
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_iLoadStatus = 0;
	g_iPlayerSpawn = 0;
	g_iRoundStart = 0;
	g_iMindOrderGet = 2;
	ResetPlugin();
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		g_iLoadStatus = 1;
	g_iRoundStart = 1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		g_iLoadStatus = 1;
	g_iPlayerSpawn = 1;
}



// ====================================================================================================
//					COMMANDS
// ====================================================================================================
Action CmdMutantsRefresh(int client, int args)
{
	ResetPlugin(true);
	LoadDataConfig();

	if( g_bCvarAllow )
		LateLoad();

	return Plugin_Handled;
}

Action CmdMutantBomb(int client, int args)
{
	if( g_bCvarAllow == false || client == 0 ) return Plugin_Handled;
	g_bHookCommonBomb = true;
	ZSpawn(client);
	return Plugin_Handled;
}

Action CmdMutantFire(int client, int args)
{
	if( g_bCvarAllow == false || client == 0 ) return Plugin_Handled;
	g_bHookCommonFire = true;
	ZSpawn(client);
	return Plugin_Handled;
}

Action CmdMutantGhost(int client, int args)
{
	if( g_bCvarAllow == false || client == 0 ) return Plugin_Handled;
	g_bHookCommonGhost = true;
	ZSpawn(client);
	return Plugin_Handled;
}

Action CmdMutantMind(int client, int args)
{
	if( g_bCvarAllow == false || client == 0 ) return Plugin_Handled;

	// Args, spawn with specific effect
	int data = -1, type;
	if( args == 1 )
	{
		char sArg[4];
		GetCmdArg(1, sArg, sizeof(sArg));
		type = StringToInt(sArg);
		data = g_iConfMindEffects;
		g_iConfMindEffects = type;
	}
	else if( args > 1 )
	{
		ReplyToCommand(client, "[MUTANTS] Usage: sm_mutantmind <type: 1=Ghost, 2=Red, 4=Lightning, 8=Yellow, 16=Infected, 32=Intro>");
		return Plugin_Handled;
	}

	g_bHookCommonMind = true;
	ZSpawn(client);

	// Return original value.
	if( data != -1 )
		g_iConfMindEffects = data;
	return Plugin_Handled;
}

Action CmdMutantSmoke(int client, int args)
{
	if( g_bCvarAllow == false || client == 0 ) return Plugin_Handled;
	g_bHookCommonSmoke = true;
	ZSpawn(client);
	return Plugin_Handled;
}

Action CmdMutantSpit(int client, int args)
{
	if( !g_bLeft4Dead2 )
	{
		ReplyToCommand(client, "This feature is only available in L4D2.");
		return Plugin_Handled;
	}

	if( g_bCvarAllow == false || client == 0 ) return Plugin_Handled;
	g_bHookCommonSpit = true;
	ZSpawn(client);
	return Plugin_Handled;
}

Action CmdMutantTesla(int client, int args)
{
	if( g_bCvarAllow == false || client == 0 ) return Plugin_Handled;
	g_bHookCommonTesla = true;
	ZSpawn(client);
	return Plugin_Handled;
}

Action CmdMutants(int client, int args)
{
	if( g_bCvarAllow == false || client == 0 ) return Plugin_Handled;

	g_bHookCommonBomb = true;
	ZSpawn(client);

	g_bHookCommonFire = true;
	ZSpawn(client);

	g_bHookCommonGhost = true;
	ZSpawn(client);

	g_bHookCommonMind = true;
	ZSpawn(client);

	g_bHookCommonSmoke = true;
	ZSpawn(client);

	if( g_bLeft4Dead2 )
	{
		g_bHookCommonSpit = true;
		ZSpawn(client);
	}

	g_bHookCommonTesla = true;
	ZSpawn(client);
	return Plugin_Handled;
}

void ZSpawn(int client)
{
	int bits = GetUserFlagBits(client);
	int flags = GetCommandFlags("z_spawn");
	SetUserFlagBits(client, ADMFLAG_ROOT);
	SetCommandFlags("z_spawn", flags & ~FCVAR_CHEAT);
	g_bHookCommonSpawn = true;
	FakeClientCommand(client, "z_spawn");
	g_bHookCommonSpawn = false;
	SetUserFlagBits(client, bits);
	SetCommandFlags("z_spawn", flags);
}



// ====================================================================================================
//					ON ENTITY CREATED - INFECTED / SPITTER ACID
// ====================================================================================================
public void OnEntityCreated(int entity, const char[] classname)
{
	if( g_iLoadStatus == 0 || g_bCvarAllow == false ) return;

	// Common can walk in Spitter acid and mutate, detect "insect_swarm" to create the "trigger_multiple"
	if( strcmp(classname, "infected") == 0 )
	{
		// Mutant Zombie spawned by command OR random auto-spawn
		if( g_bHookCommonSpawn
		|| (g_iConfRandom		&& g_iSpawnAmount	>= g_iConfRandom)
		|| (g_iConfBombRandom	&& g_iSpawnBomb		>= g_iConfBombRandom)
		|| (g_iConfGhostRandom	&& g_iSpawnGhost	>= g_iConfGhostRandom)
		|| (g_iConfMindRandom	&& g_iSpawnMind		>= g_iConfMindRandom)
		|| (g_iConfSmokeRandom	&& g_iSpawnSmoke	>= g_iConfSmokeRandom)
		|| (g_iConfSpitRandom	&& g_iSpawnSpit		>= g_iConfSpitRandom && g_bLeft4Dead2)
		|| (g_iConfTeslaRandom	&& g_iSpawnTesla	>= g_iConfTeslaRandom ))
		{
			if( g_iConfCheck )
			{
				CreateTimer(0.2, TimerSpawnCommon, EntIndexToEntRef(entity));
			}
			else
			{
				SDKHook(entity, SDKHook_SpawnPost, OnSpawnCommon);
			}
		}
		else if( g_iConfFireRandom && g_iSpawnFire >= g_iConfFireRandom )
		{
			SDKHook(entity, SDKHook_SpawnPost, OnSpawnCommon);
		}


		// Increment random counters if allowed.
		else
		{
			g_iSpawnAmount++;

			if( g_iConfRandom == 0 )
			{
				if( g_iConfBombRandom && g_iConfTypes & TYPE_BOMB )				g_iSpawnBomb++;
				if( g_iConfFireRandom && g_iConfTypes & TYPE_FIRE )				g_iSpawnFire++;
				if( g_iConfGhostRandom && g_iConfTypes & TYPE_GHOST )			g_iSpawnGhost++;
				if( g_iConfMindRandom && g_iConfTypes & TYPE_MIND )				g_iSpawnMind++;
				if( g_iConfSmokeRandom && g_iConfTypes & TYPE_SMOKE )			g_iSpawnSmoke++;
				if( g_iConfSpitRandom && g_iConfTypes & TYPE_SPIT )				g_iSpawnSpit++;
				if( g_iConfTeslaRandom && g_iConfTypes & TYPE_TESLA )			g_iSpawnTesla++;
			}

			// "inferno" or "fire_cracker_blast" is active. We hook commons taking damage to detect if they walk in fire so they can mutate.
			if( (g_iCheckInferno > 0 || g_iConfFireIncen > 0) && IsCommonValidToUse(entity) )
			{
				SDKHook(entity, SDKHook_OnTakeDamage, OnCommonFireDamage);
				SDKHook(entity, SDKHook_SpawnPost, OnCommonFireSpawn);
			}
		}
	}

	// Detect "fire_cracker_blast" to create the "trigger_multiple" so common can walk in fire (molotovs or firework crates) and mutate.
	else if( g_iConfFireWalk && !g_iConfFireIncen && (strcmp(classname, "inferno") == 0 || strcmp(classname, "fire_cracker_blast") == 0) )
	{
		// Commons are not hooked.
		if( g_iCheckInferno == 0 )
		{
			int common = -1;

			// Loop through common infected.
			while( (common = FindEntityByClassname(common, "infected")) != INVALID_ENT_REFERENCE )
			{
				// Validate model.
				if( IsCommonValidToUse(common) )
				{
					SDKHook(common, SDKHook_OnTakeDamage, OnCommonFireDamage);
					SDKHook(entity, SDKHook_SpawnPost, OnCommonFireSpawn);
				}
			}
		}
		g_iCheckInferno++;
	}

	// Common can walk in spitter acid and mutate, detect "insect_swarm" to create the "trigger_multiple"
	else if( g_iConfSpitWalk && strcmp(classname, "insect_swarm") == 0 )
	{
		SDKHook(entity, SDKHook_Spawn, OnSpawnSwarm);
	}
}

public void OnEntityDestroyed(int entity)
{
	// Commons are hooked.
	if( g_iCheckInferno && g_bCvarAllow && entity > MaxClients && IsValidEntity(entity) )
	{
		static char classname[20];
		GetEdictClassname(entity, classname, sizeof(classname));

		// A molotov ("inferno") or firework crate ("fire_cracker_blast") as been removed.
		if( strcmp(classname, "inferno") == 0 || strcmp(classname, "fire_cracker_blast") == 0 )
		{
			g_iCheckInferno--;
			if( g_iCheckInferno < 0 ) g_iCheckInferno = 0;

			// No more "inferno" or "fire_cracker_blast". Unhook commons.
			if( g_iCheckInferno == 0 && !g_iConfFireIncen )
			{
				int common = -1;
				while( (common = FindEntityByClassname(common, "infected")) != INVALID_ENT_REFERENCE )
				{
					if( IsCommonValidToUse(common) )
					{
						SDKUnhook(common, SDKHook_OnTakeDamage, OnCommonFireDamage);
					}
				}
			}
		}
	}
}



// ====================================================================================================
//					ONSPAWN - SPITTER ACID
// ====================================================================================================
// Create a trigger which Common Infected walk through, so they can mutate to Spit Infected
void OnSpawnSwarm(int entity)
{
	int trigger = CreateEntityByName("trigger_multiple");
	DispatchKeyValue(trigger, "spawnflags", "1");
	DispatchSpawn(trigger);

	float vPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vPos);
	vPos[2] += 5.0;
	TeleportEntity(trigger, vPos, NULL_VECTOR, NULL_VECTOR);

	float vMins[3]; vMins = view_as<float>({-250.0, -250.0, 0.0});
	float vMaxs[3]; vMaxs = view_as<float>({250.0, 250.0, 50.0});
	SetEntPropVector(trigger, Prop_Send, "m_vecMins", vMins);
	SetEntPropVector(trigger, Prop_Send, "m_vecMaxs", vMaxs);
	SetEntProp(trigger, Prop_Send, "m_nSolidType", 2);

	SetVariantString("OnUser1 !self:Kill::10:1");
	AcceptEntityInput(trigger, "AddOutput");
	AcceptEntityInput(trigger, "FireUser1");

	SDKHook(trigger, SDKHook_Touch, OnTouchSwarm);
}

// A common walked through the trigger, mutate them!
void OnTouchSwarm(int entity, int common)
{
	if( common > MaxClients )
	{
		static char sTemp[10];
		GetEdictClassname(common, sTemp, sizeof(sTemp));

		if( strcmp(sTemp, "infected") == 0 && IsCommonValidToUse(common) && GetRandomInt(1, 100) <= g_iConfSpitWalk )
		{
			MutantSpitSetup(common);
		}
	}
}



// ====================================================================================================
//					ONSPAWN - COMMON INFECTED
// ====================================================================================================
// Determine which type of Zombie spawned.
Action TimerSpawnCommon(Handle timer, int entity)
{
	if( IsValidEntRef(entity) )
		SpawnCommon(EntRefToEntIndex(entity));

	return Plugin_Continue;
}

void OnSpawnCommon(int common)
{
	SDKUnhook(common, SDKHook_SpawnPost, OnSpawnCommon);

	if( IsValidEntity(common) )
		RequestFrame(OnFrameSpawn, EntIndexToEntRef(common));
}

void OnFrameSpawn(int common)
{
	common = EntRefToEntIndex(common);

	if( common != INVALID_ENT_REFERENCE )
		SpawnCommon(common);
}

void SpawnCommon(int common)
{
	if( IsCommonValidToUse(common) )
	{
		if( !g_bHookCommonBomb && !g_bHookCommonMind && !g_bHookCommonFire && !g_bHookCommonGhost && !g_bHookCommonSmoke && !g_bHookCommonSpit && !g_bHookCommonTesla )
		{
			if( g_iConfRandom )
			{
				g_iSpawnAmount = 1;

				int iCount, iArray[7], iType;

				if( g_iConfTypes & TYPE_BOMB )						iArray[iCount++] = 0;
				if( g_iConfTypes & TYPE_FIRE )						iArray[iCount++] = 1;
				if( g_iConfTypes & TYPE_GHOST )						iArray[iCount++] = 2;
				if( g_iConfTypes & TYPE_MIND )						iArray[iCount++] = 3;
				if( g_iConfTypes & TYPE_SMOKE )						iArray[iCount++] = 4;
				if( g_bLeft4Dead2 && g_iConfTypes & TYPE_SPIT )		iArray[iCount++] = 5;
				if( g_iConfTypes & TYPE_TESLA )						iArray[iCount++] = 6;

				iType = GetRandomInt(0, iCount -1);
				iType = iArray[iType];

				switch( iType )
				{
					case 0:		g_bHookCommonBomb = true;
					case 1:		g_bHookCommonFire = true;
					case 2:		g_bHookCommonGhost = true;
					case 3:		g_bHookCommonMind = true;
					case 4:		g_bHookCommonSmoke = true;
					case 5:		g_bHookCommonSpit = true;
					case 6:		g_bHookCommonTesla = true;
				}
			}
			else
			{
				if( g_iSpawnBomb >= g_iConfBombRandom )
				{
					g_bHookCommonBomb = true;
					g_iSpawnBomb = 1;
				}
				else if( g_iSpawnFire >= g_iConfFireRandom )
				{
					g_bHookCommonFire = true;
					g_iSpawnFire = 1;
				}
				else if( g_iSpawnGhost >= g_iConfGhostRandom )
				{
					g_bHookCommonGhost = true;
					g_iSpawnGhost = 1;
				}
				else if( g_iSpawnMind >= g_iConfMindRandom )
				{
					g_bHookCommonMind = true;
					g_iSpawnMind = 1;
				}
				else if( g_iSpawnSmoke >= g_iConfSmokeRandom )
				{
					g_bHookCommonSmoke = true;
					g_iSpawnSmoke = 1;
				}
				else if( g_iSpawnSpit >= g_iConfSpitRandom )
				{
					g_bHookCommonSpit = true;
					g_iSpawnSpit = 1;
				}
				else if( g_iSpawnTesla >= g_iConfTeslaRandom )
				{
					g_bHookCommonTesla = true;
					g_iSpawnTesla = 1;
				}
				else
				{
					return;
				}
			}
		}

		if( g_bHookCommonBomb )								MutantBombSetup(common);
		else if( g_bHookCommonFire )						MutantFireSetup(common, true);
		else if( g_bHookCommonGhost )						MutantGhostSetup(common);
		else if( g_bHookCommonMind )						MutantMindSetup(common);
		else if( g_bHookCommonSmoke ) 						MutantSmokeSetup(common);
		else if( g_bHookCommonSpit && g_bLeft4Dead2 )		MutantSpitSetup(common);
		else if( g_bHookCommonTesla )						MutantTeslaSetup(common);
	}
}



// ====================================================================================================
//					TYPES
// ====================================================================================================

// ====================================================================================================
//					BOMB
// ====================================================================================================
void MutantBombSetup(int common)
{
	g_bHookCommonBomb = false;

	int index = GetEntityIndex(TYPE_BOMB);
	if( index == -1 ) return;

	g_iInfectedBomb[index][0] = EntIndexToEntRef(common);
	SetEntProp(common, Prop_Data, "m_iHammerID", 66260);

	if( g_bLeft4Dead2 && g_iConfBombGlow )
	{
		SetEntProp(common, Prop_Send, "m_nGlowRange", g_iConfBombGlow);
		SetEntProp(common, Prop_Send, "m_iGlowType", 3);
		SetEntProp(common, Prop_Send, "m_glowColorOverride", g_iConfBombGlowCol);
		AcceptEntityInput(common, "StartGlowing");
	}

	if( g_iConfBombHealth )
		SetEntProp(common, Prop_Data, "m_iHealth", g_iConfBombHealth);

	if( g_iConfBombExplodeD )
		SDKHook(common, SDKHook_OnTakeDamage, OnTakeDamageBomb);

	if( g_bLeft4Dead2 )
		g_iInfectedBomb[index][1] = CreateParticle(common, ENUM_PARTICLE_BOMB);

	if( !g_bLeft4Dead2 || GetRandomInt(0,1) )
		g_iInfectedBomb[index][2] = CreateParticle(common, ENUM_PARTICLE_BOMB2);
	else
		g_iInfectedBomb[index][2] = CreateParticle(common, ENUM_PARTICLE_BOMB1);


	// PROPANE MODEL
	int entity = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(entity, MODEL_PROPANE);
	DispatchSpawn(entity);
	if( g_bLeft4Dead2 )
		SetEntPropFloat(entity, Prop_Data, "m_flModelScale", 0.60);

	int random = GetRandomInt(0, 1);
	if( random == 0 )
		SetEntityRenderColor(entity, 0, 0, 0, 255);

	// Parent attachment
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", common);
	SetVariantString("forward");
	AcceptEntityInput(entity, "SetParentAttachment");

	if( g_bLeft4Dead2 )
		TeleportEntity(entity, view_as<float>({ 1.0,-2.5,-4.0 }), view_as<float>({ 90.0,-10.0,0.0 }), NULL_VECTOR);
	else
		TeleportEntity(entity, view_as<float>({ 2.0,-8.0,2.0 }), view_as<float>({ 0.0,-10.0,0.0 }), NULL_VECTOR);
	g_iInfectedBomb[index][3] = EntIndexToEntRef(entity);
}

Action OnTakeDamageBomb(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if( attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == 2 )
	{
		if( GetRandomInt(1, 100) <= g_iConfBombExplodeD )
		{
			victim = EntIndexToEntRef(victim);

			for( int i = 0; i < MAX_ENTS; i++ )
			{
				if( g_iInfectedBomb[i][0] == victim )
				{
					SDKUnhook(victim, SDKHook_OnTakeDamage, OnTakeDamageBomb);
					BombDetonate(i);
					return Plugin_Continue;
				}
			}
		}
	}
	return Plugin_Continue;
}

void BombDetonate(int index)
{
	int common = g_iInfectedBomb[index][0];
	if( !IsValidEntRef(common) ) return;

	float vPos[3];
	char sTemp[16];
	GetEntPropVector(common, Prop_Data, "m_vecAbsOrigin", vPos);
	vPos[2] += 25.0;

	int entity = CreateEntityByName("env_explosion");
	FloatToString(g_fConfBombDamageD, sTemp, sizeof(sTemp));
	DispatchKeyValue(entity, "iMagnitude", sTemp);
	FloatToString(g_fConfBombDistance, sTemp, sizeof(sTemp));
	DispatchKeyValue(entity, "iRadiusOverride", sTemp);
	DispatchKeyValue(entity, "spawnflags", "1916");
	TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	AcceptEntityInput(entity, "explode");

	CreateParticle(common, ENUM_PARTICLE_BOMB3);

	int random = GetRandomInt(0, 2);
	switch( random )
	{
		case 0:		EmitSoundToAll(SOUND_EXPLODE3, common, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		case 1:		EmitSoundToAll(SOUND_EXPLODE4, common, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		case 2:		EmitSoundToAll(SOUND_EXPLODE5, common, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}

	if( g_iConfBombShake )
	{
		entity = CreateEntityByName("env_shake");
		if( entity != -1 )
		{
			DispatchKeyValue(entity, "spawnflags", "8");
			DispatchKeyValue(entity, "amplitude", "16.0");
			DispatchKeyValue(entity, "frequency", "1.5");
			DispatchKeyValue(entity, "duration", "0.9");
			FloatToString(g_fConfBombDistance, sTemp, sizeof(sTemp));
			DispatchKeyValue(entity, "radius", sTemp);
			DispatchSpawn(entity);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "Enable");

			TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(entity, "StartShake");
			RemoveEdict(entity);
		}
	}

	DeleteEntity(TYPE_BOMB, index);
}



// ====================================================================================================
//					FIRE
// ====================================================================================================
void MutantFireSetup(int common, bool spawn)
{
	g_bHookCommonFire = false;

	int index = GetEntityIndex(TYPE_FIRE);
	if( index == -1 ) return;

	SDKHook(common, SDKHook_OnTakeDamage, OnTakeDamageFire);

	g_iInfectedFire[index][0] = EntIndexToEntRef(common);
	SetEntProp(common, Prop_Data, "m_iHammerID", 66260);

	if( g_bLeft4Dead2 && g_iConfFireGlow )
	{
		SetEntProp(common, Prop_Send, "m_nGlowRange", g_iConfFireGlow);
		SetEntProp(common, Prop_Send, "m_iGlowType", 3);
		SetEntProp(common, Prop_Send, "m_glowColorOverride", g_iConfFireGlowCol);
		AcceptEntityInput(common, "StartGlowing");
	}

	if( spawn )
	{
		// On infected which just spawn we simply ignite. So nice, so simple, the model appears burnt as expected.
		IgniteEntity(common, 6000.0);
	}
	else
	{
		// Infected is broken and would render invisible, so don't fix them from death
		if( GetEntProp(common, Prop_Send, "m_bClientSideRagdoll") == 0 )
		{
			ReigniteCommon(common);
		}

		/* OLD METHOD:
		// Infected which walk through fire die when IgniteEntity() is used.
		// This is long winded and stupid, the model does not change appearance but it works.
		int entityflame = CreateEntityByName("entityflame");
		DispatchSpawn(entityflame);
		float vPos[3];
		GetEntPropVector(common, Prop_Data, "m_vecOrigin", vPos);
		TeleportEntity(entityflame, vPos, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(entityflame, Prop_Data, "m_flLifetime", 6000.0);
		SetEntPropEnt(entityflame, Prop_Data, "m_hEntAttached", common);
		SetEntPropEnt(entityflame, Prop_Send, "m_hEntAttached", common);
		SetEntPropEnt(common, Prop_Data, "m_hEffectEntity", entityflame);
		SetEntPropEnt(common, Prop_Send, "m_hEffectEntity", entityflame);
		ActivateEntity(entityflame);

		char sTemp[16];
		Format(sTemp, sizeof(sTemp), "fire%d%d", entityflame, common);
		DispatchKeyValue(common, "targetname", sTemp);
		SetVariantString(sTemp);
		AcceptEntityInput(entityflame, "IgniteEntity", common, common, 600);
		SetVariantString(sTemp);
		AcceptEntityInput(entityflame, "Ignite", common, common, 600);
		// */
	}

	if( g_iConfFireHealth )
	{
		SetEntProp(common, Prop_Data, "m_iHealth", g_iConfFireHealth);
		g_iFireHealth[common] = g_iConfFireHealth;
	}
	else
	{
		g_iFireHealth[common] = GetEntProp(common, Prop_Data, "m_iHealth");
	}
}

void ReigniteCommon(int common)
{
	ExtinguishEntity(common);
	DispatchSpawn(common); // Fix common randomly being killed, have to dispatch again to keep charred effect
	IgniteEntity(common, 6000.0);

	// Fix common standing still and not attacking
	CreateTimer(0.1, TimerTarget, EntIndexToEntRef(common));
	CreateTimer(0.3, TimerTarget, EntIndexToEntRef(common));
	CreateTimer(0.5, TimerTarget, EntIndexToEntRef(common));
}

Action TimerTarget(Handle timer, int common)
{
	common = EntRefToEntIndex(common);
	if( common != INVALID_ENT_REFERENCE )
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			if( IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) )
			{
				SDKHooks_TakeDamage(common, i, i, 0.0);
				break;
			}
		}
	}

	return Plugin_Continue;
}



// ====================================================================================================
//					ONTAKEDAMAGE - FROM FIRE - COMMON INFECTED
// ====================================================================================================
void OnCommonFireSpawn(int entity)
{
	SDKUnhook(entity, SDKHook_SpawnPost, OnCommonFireSpawn);
	g_iFireHealth[entity] = GetEntProp(entity, Prop_Data, "m_iHealth");
}

Action OnCommonFireDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if( (damagetype & (DMG_BULLET|DMG_BURN) == (DMG_BULLET|DMG_BURN)) && g_iConfFireIncen && GetRandomInt(1, 100) <= g_iConfFireIncen ) // Incendiary bullets
	{
		MutantFireSetup(victim, false);

		SDKUnhook(victim, SDKHook_OnTakeDamage, OnCommonFireDamage);

		return Plugin_Handled;
	}

	// DMG_BURN / (DMG_BURN|DMG_PREVENT_PHYSICS_FORCE) / (DMG_BURN|DMG_DIRECT)
	else if( damagetype == 8 || damagetype == 2056 || damagetype == 268435464 ) // Fire damage
	{
		if( g_iConfFireWalk && inflictor > MaxClients && IsValidEntity(inflictor) )
		{
			static char sTemp[20];
			GetEdictClassname(inflictor, sTemp, sizeof(sTemp));

			if( strcmp(sTemp, "inferno") && strcmp(sTemp, "fire_cracker_blast") )
			{
				SDKUnhook(victim, SDKHook_OnTakeDamage, OnCommonFireDamage);
				return Plugin_Continue;
			}
		}
		else
		{
			SDKUnhook(victim, SDKHook_OnTakeDamage, OnCommonFireDamage);
			return Plugin_Continue;
		}

		// Validate model.
		if( IsCommonValidToUse(victim) )
		{
			if( GetRandomInt(1, 100) <= g_iConfFireWalk )
			{
				MutantFireSetup(victim, false);

				SDKUnhook(victim, SDKHook_OnTakeDamage, OnCommonFireDamage);

				return Plugin_Handled;
			}
		}
	}

	SDKUnhook(victim, SDKHook_OnTakeDamage, OnCommonFireDamage);
	return Plugin_Continue;
}

Action OnTakeDamageFire(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	// Fix health bug where the game tries to kill common with a huge amount of damage, usually 10000.0 or the commons health + 1
	int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundFloat(damage);
	if( health <= 0 )
	{
		if( g_iFireHealth[victim] - damage > 0.0 )
		{
			ReigniteCommon(victim);

			g_iFireHealth[victim] -= RoundFloat(damage);
			SetEntProp(victim, Prop_Data, "m_iHealth", g_iFireHealth[victim]);
			return Plugin_Handled;
		}

		// Allow to die
		SDKUnhook(victim, SDKHook_OnTakeDamage, OnTakeDamageFire);

		return Plugin_Continue;
	}

	// Infected is broken and would render invisible, so don't fix them from death
	if( GetEntProp(victim, Prop_Send, "m_bClientSideRagdoll") != 0 )
	{
		SDKUnhook(victim, SDKHook_OnTakeDamage, OnTakeDamageFire);

		damage = 10000.0;
		return Plugin_Changed;
	}

	// Fix invincible bug
	if( GetEntProp(victim, Prop_Data, "m_lifeState") != 0 )
	{
		SetEntProp(victim, Prop_Data, "m_lifeState", 0);
	}

	// DMG_BURN or (DMG_BURN | DMG_PREVENT_PHYSICS_FORCE) or (DMG_BURN | DMG_DIRECT)
	if( damagetype == 8 || damagetype == 2056 || damagetype == 268435464 )
	{
		return Plugin_Handled;
	}

	// Drop fire on damage chance
	if( g_iConfFireDrop2 && attacker > 0 && attacker <= MaxClients && GetRandomInt(1, 100) <= g_iConfFireDrop2 )
		FireDrop(victim);

	// Store health value
	g_iFireHealth[victim] = health;

	return Plugin_Continue;
}

void FireDrop(int common)
{
	int trigger = CreateEntityByName("trigger_multiple");
	DispatchKeyValue(trigger, "spawnflags", "1");
	DispatchSpawn(trigger);

	float vPos[3];
	GetEntPropVector(common, Prop_Data, "m_vecOrigin", vPos);
	TeleportEntity(trigger, vPos, NULL_VECTOR, NULL_VECTOR);

	float vMins[3], vMaxs[3];
	int random = 0;

	if( g_bLeft4Dead2 )
		random = GetRandomInt(0,1);

	if( random )
	{
		vMins = view_as<float>({-10.0, -10.0, 0.0});
		vMaxs = view_as<float>({10.0, 10.0, 50.0});
	}
	else
	{
		vMins = view_as<float>({-20.0, -20.0, 0.0});
		vMaxs = view_as<float>({20.0, 20.0, 50.0});
	}
	SetEntPropVector(trigger, Prop_Send, "m_vecMins", vMins);
	SetEntPropVector(trigger, Prop_Send, "m_vecMaxs", vMaxs);
	SetEntProp(trigger, Prop_Send, "m_nSolidType", 2);

	char sTemp[32];
	Format(sTemp, sizeof(sTemp), "OnUser1 !self:Kill::%f:-1", g_fConfFireTime);
	SetVariantString(sTemp);
	AcceptEntityInput(trigger, "AddOutput");
	AcceptEntityInput(trigger, "FireUser1");

	SDKHook(trigger, SDKHook_Touch, OnTouchFire);

	if( random )
		CreateParticle(common, ENUM_PARTICLE_FIRE);
	else
		CreateParticle(common, ENUM_PARTICLE_FIRE2);
}

// A survivor walked through fire.
void OnTouchFire(int entity, int client)
{
	if( client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 )
	{
		float time = GetGameTime();

		if( time - g_fFireHurtCount[client] >= 1.0 )
		{
			g_fFireHurtCount[client] = time;
			HurtClient(client, TYPE_DROP);
		}
	}
}



// ====================================================================================================
//					GHOST
// ====================================================================================================
void MutantGhostSetup(int common)
{
	g_bHookCommonGhost = false;

	int index = GetEntityIndex(TYPE_GHOST);
	if( index == -1 ) return;

	g_iInfectedGhost[index] = EntIndexToEntRef(common);
	SetEntProp(common, Prop_Data, "m_iHammerID", 66260);

	if( g_bLeft4Dead2 && g_iConfGhostGlow )
	{
		SetEntProp(common, Prop_Send, "m_nGlowRange", g_iConfGhostGlow);
		SetEntProp(common, Prop_Send, "m_iGlowType", 3);
		SetEntProp(common, Prop_Send, "m_glowColorOverride", g_iConfGhostGlowCol);
		AcceptEntityInput(common, "StartGlowing");
	}

	if( g_iConfGhostHealth )
		SetEntProp(common, Prop_Data, "m_iHealth", g_iConfGhostHealth);

	SetOpacity(common, g_iConfGhostOpacity);
}

void SetOpacity(int client, int opacity)
{
	SetEntityRenderFx(client, RENDERFX_HOLOGRAM);
	SetEntityRenderColor(client, 255, 255, 255, opacity);
}



// ====================================================================================================
//					MIND
// ====================================================================================================
void MutantMindSetup(int common)
{
	g_bHookCommonMind = false;

	int index = GetEntityIndex(TYPE_MIND);
	if( index == -1 ) return;

	g_iInfectedMind[index][0] = EntIndexToEntRef(common);
	SetEntProp(common, Prop_Data, "m_iHammerID", 66260);

	if( g_bLeft4Dead2 && g_iConfMindGlow )
	{
		SetEntProp(common, Prop_Send, "m_nGlowRange", g_iConfMindGlow);
		SetEntProp(common, Prop_Send, "m_iGlowType", 3);
		SetEntProp(common, Prop_Send, "m_glowColorOverride", g_iConfMindGlowCol);
		AcceptEntityInput(common, "StartGlowing");
	}

	if( g_iConfMindHealth )
		SetEntProp(common, Prop_Data, "m_iHealth", g_iConfMindHealth);

	if( g_iMindOrderGet == 2 )
	{
		int entity = CreateEntityByName("info_gamemode");
		if( IsValidEntity(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemodeMindOrder, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemodeMindOrder, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}
	}

	if( !IsValidEntity(common) ) return; // Because after here it's been throwing errors about invalid entity, even though it's been valid until now. Wtf game.

	//  g_iMindOrderGet(1=Save, 0=Retrieve)  -OR-  if g_iMindOrderDone(total retrieved types) > g_iMindOrderCount(total saved types)
	int iType;
	if( g_iMindOrderGet != 1 || g_iMindOrderDone >= g_iMindOrderCount  )
	{
		int iCount, iArray[8];

		for( int i = 0; i <= 7; i++ )
		{
			if( g_iConfMindEffects & (1<<i) )		iArray[iCount++] = i;
		}

		iType = GetRandomInt(0, iCount -1);
		iType = iArray[iType];

		if( g_iMindOrderGet == 0 && g_iMindOrderCount < MAX_ORDER )
		{
			g_iMindOrder[g_iMindOrderCount++] = iType;
		}
	}
	else
	{
		iType = g_iMindOrder[g_iMindOrderDone++];
	}

	g_iInfectedMind[index][4] = CreateEnvSprite(common, "0 255 255");
	CreateCorrection(common, index, iType);
}

void OnGamemodeMindOrder(const char[] output, int caller, int activator, float delay)
{
	if( g_iMindOrderGet == 2 )
		g_iMindOrderGet = 1;
}

void CreateCorrection(int common, int index, int correction)
{
	char sTemp[64];
	float vPos[3];
	GetEntPropVector(common, Prop_Data, "m_vecOrigin", vPos);

	int entity = CreateEntityByName("color_correction");
	if( entity == -1 )
	{
		LogError("Failed to create 'color_correction'");
		return;
	}
	else
	{
		g_iInfectedMind[index][1] = EntIndexToEntRef(entity);

		DispatchKeyValue(entity, "spawnflags", "2");
		DispatchKeyValue(entity, "maxweight", "50.0");
		DispatchKeyValue(entity, "fadeInDuration", "3");
		DispatchKeyValue(entity, "fadeOutDuration", "1");
		DispatchKeyValue(entity, "maxfalloff", "-1");
		DispatchKeyValue(entity, "minfalloff", "-1");

		switch( correction )
		{
			case 0:		DispatchKeyValue(entity, "filename", "materials/correction/ghost.raw");
			case 1:		DispatchKeyValue(entity, "filename", "materials/correction/urban_night_red.pwl.raw");
			case 2:		DispatchKeyValue(entity, "filename", "materials/correction/lightningstrike50.pwl.raw");
			case 3:		DispatchKeyValue(entity, "filename", "materials/correction/dlc3_river03_outro.pwl.raw");
			case 4:		DispatchKeyValue(entity, "filename", "materials/correction/infected.pwl.raw");
			case 5:		DispatchKeyValue(entity, "filename", "materials/correction/thirdstrike.raw");
			case 6:		DispatchKeyValue(entity, "filename", "materials/correction/dlc3_river01_kiln.pwl.raw");
			case 7:		DispatchKeyValue(entity, "filename", "materials/correction/sunrise.pwl.raw");
		}

		DispatchSpawn(entity);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "Enable");
		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

		Format(sTemp, sizeof(sTemp), "col_cor%d%d", entity, common);
		DispatchKeyValue(entity, "targetname", sTemp);
	}

	ToggleFogVolume(false);

	entity = CreateEntityByName("fog_volume");
	if( entity == -1 )
	{
		LogError("Failed to create 'fog_volume'");
	}
	else
	{
		g_iInfectedMind[index][2] = entity;

		DispatchKeyValue(entity, "ColorCorrectionName", sTemp);
		Format(sTemp, sizeof(sTemp), "%d%d", common, entity);
		DispatchKeyValue(entity, "PostProcessName", sTemp);
		DispatchKeyValue(entity, "spawnflags", "0");

		DispatchSpawn(entity);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "Enable");
		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

		float vMins[3];
		float vMaxs[3];
		vMins[0] = -1.0 * g_fConfMindDistance;
		vMins[1] = -1.0 * g_fConfMindDistance;
		vMins[2] = 0.0;
		vMaxs[0] = g_fConfMindDistance;
		vMaxs[1] = g_fConfMindDistance;
		vMaxs[2] = 150.0;
		SetEntPropVector(entity, Prop_Send, "m_vecMins", vMins);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vMaxs);
	}

	ToggleFogVolume(true);

	CreateTimer(0.5, TimerTeleport, index, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

Action TimerTeleport(Handle timer, int index)
{
	int entity = g_iInfectedMind[index][0];

	if( IsValidEntRef(entity) )
	{
		float vPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vPos);

		entity = g_iInfectedMind[index][2];
		if( IsValidEntRef(entity) )
			TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

		return Plugin_Continue;
	}

	DeleteEntity(TYPE_MIND, index);
	return Plugin_Stop;
}

// We have to disable fog_volume when we create ours, so it has priority. Thankfully this works.
// Also saves the enabled/disabled state of fog_volume's we change to prevent visual corruption!
void ToggleFogVolume(bool enable)
{
	int entity = -1;

	if( enable == true )
	{
		for( int i = 0; i < MAX_ENTS; i++ )
		{
			entity = g_iInfectedMind[i][2];
			if( IsValidEntRef(entity) )
			{
				AcceptEntityInput(entity, "Disable");
				AcceptEntityInput(entity, "Enable");
			}
		}
	}

	int m_bDisabled, breaker;
	while( (entity = FindEntityByClassname(entity, "fog_volume")) != INVALID_ENT_REFERENCE )
	{
		breaker = 0;
		for( int i = 0; i < MAX_ENTS; i++ )
		{
			if( g_iInfectedMind[i][2] == entity )
			{
				breaker = 1;
				break;
			}

			if( breaker == 1 )
				break;
		}

		if( enable == true )
		{
			m_bDisabled = GetEntProp(entity, Prop_Data, "m_bDisabled");
			if( m_bDisabled == 0 )
				AcceptEntityInput(entity, "Enable");
		}
		else if( enable == false )
		{
			m_bDisabled = GetEntProp(entity, Prop_Data, "m_bDisabled");
			SetEntProp(entity, Prop_Data, "m_iHammerID", m_bDisabled);
			AcceptEntityInput(entity, "Disable");
		}
	}
}



// ====================================================================================================
//					SMOKE
// ====================================================================================================
void MutantSmokeSetup(int common)
{
	g_bHookCommonSmoke = false;

	int index = GetEntityIndex(TYPE_SMOKE);
	if( index == -1 ) return;

	g_iInfectedSmoke[index][0] = EntIndexToEntRef(common);
	SetEntProp(common, Prop_Data, "m_iHammerID", 66260);

	if( g_bLeft4Dead2 && g_iConfSmokeGlow )
	{
		SetEntProp(common, Prop_Send, "m_nGlowRange", g_iConfSmokeGlow);
		SetEntProp(common, Prop_Send, "m_iGlowType", 3);
		SetEntProp(common, Prop_Send, "m_glowColorOverride", g_iConfSmokeGlowCol);
		AcceptEntityInput(common, "StartGlowing");
	}

	if( g_iConfSmokeHealth )
		SetEntProp(common, Prop_Data, "m_iHealth", g_iConfSmokeHealth);

	g_iInfectedSmoke[index][1] = CreateParticle(common, ENUM_PARTICLE_SMOKE);

	CreateTimer(1.0, TimerSmokeHurt, index, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

Action TimerSmokeHurt(Handle timer, int index)
{
	int entity = g_iInfectedSmoke[index][0];
	if( !IsValidEntRef(entity) )
		return Plugin_Stop;

	float vPos[3], vOrigin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vOrigin);

	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 )
		{
			GetClientAbsOrigin(i, vPos);
			if( GetVectorDistance(vPos, vOrigin) <= g_fConfSmokeDistance && IsVisibleTo(vPos, vOrigin) )
			{
				HurtClient(i, TYPE_SMOKE);
			}
		}
	}
	return Plugin_Continue;
}

// Taken from:
// plugin = "L4D_Splash_Damage"
// author = "AtomicStryker"
bool IsVisibleTo(float position[3], float targetposition[3])
{
	float vAngles[3], vLookAt[3];

	MakeVectorFromPoints(position, targetposition, vLookAt); // compute vector from start to target
	GetVectorAngles(vLookAt, vAngles); // get angles from vector for trace

	// execute Trace
	Handle trace = TR_TraceRayFilterEx(position, vAngles, MASK_ALL, RayType_Infinite, _TraceFilter);

	bool isVisible = false;
	if( TR_DidHit(trace) )
	{
		float vStart[3];
		TR_GetEndPosition(vStart, trace); // retrieve our trace endpoint

		if( (GetVectorDistance(position, vStart, false) + 25.0 ) >= GetVectorDistance(position, targetposition) )
			isVisible = true; // if trace ray length plus tolerance equal or bigger absolute distance, you hit the target
	}
	else
		isVisible = false;

	delete trace;
	return isVisible;
}

bool _TraceFilter(int entity, int contentsMask)
{
	if( !entity || entity <= MaxClients || !IsValidEntity(entity) ) // dont let WORLD, or invalid entities be hit
		return false;
	return true;
}



// ====================================================================================================
//					SPIT
// ====================================================================================================
void MutantSpitSetup(int common)
{
	g_bHookCommonSpit = false;

	int index = GetEntityIndex(TYPE_SPIT);
	if( index == -1 ) return;

	g_iInfectedSpit[index][0] = EntIndexToEntRef(common);
	SetEntProp(common, Prop_Data, "m_iHammerID", 66260);

	if( g_bLeft4Dead2 && g_iConfSpitGlow )
	{
		SetEntProp(common, Prop_Send, "m_nGlowRange", g_iConfSpitGlow);
		SetEntProp(common, Prop_Send, "m_iGlowType", 3);
		SetEntProp(common, Prop_Send, "m_glowColorOverride", g_iConfSpitGlowCol);
		AcceptEntityInput(common, "StartGlowing");
	}

	if( g_iConfSpitHealth )
		SetEntProp(common, Prop_Data, "m_iHealth", g_iConfSpitHealth);

	// Goo Dribble
	if( g_iConfSpitEffects == 1 || g_iConfSpitEffects == 3 )
		g_iInfectedSpit[index][1] = CreateParticle(common, ENUM_PARTICLE_SPIT);

	// Smoke
	if( g_iConfSpitEffects == 2 || g_iConfSpitEffects == 3)
		g_iInfectedSpit[index][2] = CreateParticle(common, ENUM_PARTICLE_SPIT2);
}



// ====================================================================================================
//					TESLA
// ====================================================================================================
void MutantTeslaSetup(int common)
{
	g_bHookCommonTesla = false;

	int index = GetEntityIndex(TYPE_TESLA);
	if( index == -1 ) return;

	g_iInfectedTesla[index][0] = EntIndexToEntRef(common);
	SetEntProp(common, Prop_Data, "m_iHammerID", 66260);

	if( g_bLeft4Dead2 && g_iConfTeslaGlow )
	{
		SetEntProp(common, Prop_Send, "m_nGlowRange", g_iConfTeslaGlow);
		SetEntProp(common, Prop_Send, "m_iGlowType", 3);
		SetEntProp(common, Prop_Send, "m_glowColorOverride", g_iConfTeslaGlowCol);
		AcceptEntityInput(common, "StartGlowing");
	}

	if( g_iConfTeslaHealth )
		SetEntProp(common, Prop_Data, "m_iHealth", g_iConfTeslaHealth);

	g_iInfectedTesla[index][1] = CreateParticle(common, ENUM_PARTICLE_TESLA);
}

void TeslaShock(int common, int client)
{
	// TARGET
	char sTemp[32];
	int entity;
	float vAng[3];
	float vPos[3];

	if( g_bLeft4Dead2 )
	{
		entity = CreateEntityByName("info_particle_target");
		if( entity != -1 )
		{
			DispatchKeyValue(entity, "spawnflags", "0");
			Format(sTemp, sizeof(sTemp), "tesla%d%d%d", entity, common, client);
			DispatchKeyValue(entity, "targetname", sTemp);
			DispatchSpawn(entity);

			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", client);

			vPos[2] = GetRandomFloat(10.0, 60.0);
			TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

			SetVariantString("OnUser1 !self:Kill::1.5:1");
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser1");
		}
		else
			LogError("Failed to created entity 'info_particle_target'");
	}


	// PARTICLE
	entity = CreateEntityByName("info_particle_system");
	if( g_bLeft4Dead2 )
		DispatchKeyValue(entity, "cpoint1", sTemp);

	int iCount, iArray[5], iType;

	if( g_bLeft4Dead2 )
	{
		for( int i = 0; i <= 4; i++ )
		{
			if( g_iConfTeslaEffects & (1<<i) )		iArray[iCount++] = i;
		}

		iType = GetRandomInt(0, iCount -1);
		iType = iArray[iType];

		switch( iType )
		{
			case 0:			DispatchKeyValue(entity, "effect_name", PARTICLE_TESLA);
			case 1:			DispatchKeyValue(entity, "effect_name", PARTICLE_TESLA2);
			case 2:			DispatchKeyValue(entity, "effect_name", PARTICLE_TESLA3);
			case 3:			DispatchKeyValue(entity, "effect_name", PARTICLE_TESLA4);
			default:		DispatchKeyValue(entity, "effect_name", PARTICLE_TESLA5);
		}
	} else {
		if( GetRandomInt(0, 1) )
			DispatchKeyValue(entity, "effect_name", PARTICLE_TESLA6);
		else
			DispatchKeyValue(entity, "effect_name", PARTICLE_TESLA7);
	}


	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "Start");

	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", common);

	if( g_bLeft4Dead2 )
		GetEntPropVector(common, Prop_Data, "m_angRotation", vAng);
	TeleportEntity(entity, view_as<float>({ 25.0,0.0, 50.0 }), vAng, NULL_VECTOR);

	SetVariantString("OnUser1 !self:Kill::1.2:1");
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");


	// SOUND
	iType = GetRandomInt(0, 7);
	EmitSoundToAll(g_sSoundsZap[iType], client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);


	// TELEPORT
	GetEntPropVector(common, Prop_Data, "m_vecOrigin", vPos);
	GetEntPropVector(common, Prop_Data, "m_angRotation", vAng);
	GetAngleVectors(vAng, vAng, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vAng, vAng);
	ScaleVector(vAng, g_fConfTeslaForce);
	vAng[2] = g_fConfTeslaForceZ;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vAng);
}



// ====================================================================================================
//					CREATE EFFECTS - SPRITE
// ====================================================================================================
int CreateEnvSprite(int client, const char[] sColor)
{
	int entity = CreateEntityByName("env_sprite");
	if( entity == -1 )
	{
		LogError("Failed to create 'env_sprite'");
		return 0;
	}

	DispatchKeyValue(entity, "rendercolor", sColor);
	DispatchKeyValue(entity, "model", MODEL_SPRITE);
	DispatchKeyValue(entity, "spawnflags", "3");
	DispatchKeyValue(entity, "rendermode", "9");
	DispatchKeyValue(entity, "GlowProxySize", "0.1");
	DispatchKeyValue(entity, "renderamt", "175");
	DispatchKeyValue(entity, "scale", "0.1");
	DispatchSpawn(entity);

	// Attach
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", client);
	SetVariantString("mouth");
	AcceptEntityInput(entity, "SetParentAttachment");

	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);
	return EntIndexToEntRef(entity);
}



// ====================================================================================================
//					CREATE EFFECTS - PARTICLES
// ====================================================================================================
int CreateParticle(int client, int type)
{
	int entity = CreateEntityByName("info_particle_system");

	switch( type )
	{
		case ENUM_PARTICLE_SPIT:	DispatchKeyValue(entity, "effect_name", PARTICLE_SPIT);		// Spit - Goo Dribble
		case ENUM_PARTICLE_SPIT2:	DispatchKeyValue(entity, "effect_name", PARTICLE_SPIT2);	// Spit - Smoke
		case ENUM_PARTICLE_FIRE:	DispatchKeyValue(entity, "effect_name", PARTICLE_FIRE);		// Fire
		case ENUM_PARTICLE_FIRE2:	DispatchKeyValue(entity, "effect_name", PARTICLE_FIRE2);	// Fire sparks
		case ENUM_PARTICLE_BOMB:	DispatchKeyValue(entity, "effect_name", PARTICLE_BOMB);		// Bomb
		case ENUM_PARTICLE_BOMB1:	DispatchKeyValue(entity, "effect_name", PARTICLE_BOMB1);	// Bomb flare
		case ENUM_PARTICLE_BOMB2:	DispatchKeyValue(entity, "effect_name", PARTICLE_BOMB2);	// Bomb flare
		case ENUM_PARTICLE_BOMB3:	DispatchKeyValue(entity, "effect_name", PARTICLE_BOMB3);	// Bomb explosion
		case ENUM_PARTICLE_SMOKE:	DispatchKeyValue(entity, "effect_name", PARTICLE_SMOKE);	// Smoke
		case ENUM_PARTICLE_TESLA:
		{
			if( g_bLeft4Dead2 )
				DispatchKeyValue(entity, "effect_name", PARTICLE_DEFIB);	// Tesla
			else
				DispatchKeyValue(entity, "effect_name", PARTICLE_ELMOS);
		}
	}

	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "Start");

	if( type == ENUM_PARTICLE_BOMB3 )
	{
		float vPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);

		vPos[2] += 35.0;

		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	}
	else if( type == ENUM_PARTICLE_FIRE || type == ENUM_PARTICLE_FIRE2 )
	{
		float vPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);

		vPos[2] += 10.0;

		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	}
	else
	{
		// Parent attachment
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", client);

		if( type == ENUM_PARTICLE_SPIT || type == ENUM_PARTICLE_TESLA )
			SetVariantString("mouth");
		else
			SetVariantString("forward");
		AcceptEntityInput(entity, "SetParentAttachment");

		// Position particles
		float vPos[3];

		switch( type )
		{
			case ENUM_PARTICLE_SPIT:			vPos[2] = 2.0;
			case ENUM_PARTICLE_SPIT2:			vPos[2] = -2.0;
			case ENUM_PARTICLE_BOMB:			vPos[2] = 0.0;
			case ENUM_PARTICLE_SMOKE:			vPos[0] = -50.0;
			case ENUM_PARTICLE_BOMB1, ENUM_PARTICLE_BOMB2:
			{
				if( g_bLeft4Dead2 )
				{
					vPos[0] = 8.5;
					vPos[1] = 0.5;
					vPos[2] = -0.3;
				} else {
					vPos[0] = -4.0;
					vPos[1] = 0.5;
					vPos[2] = 7.0;
				}
			}
		}

		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
	}

	switch( type )
	{
		case ENUM_PARTICLE_BOMB3:
		{
			SetVariantString("OnUser1 !self:Kill::2:-1");
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser1");
		}
		case ENUM_PARTICLE_FIRE, ENUM_PARTICLE_FIRE2:
		{
			char sTemp[32];
			Format(sTemp, sizeof(sTemp), "OnUser1 !self:Kill::%f:-1", g_fConfFireTime);
			SetVariantString(sTemp);
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser1");
		}
		case ENUM_PARTICLE_SMOKE:
		{
			CreateTimer(2.9, TimerRefireSmoke, EntIndexToEntRef(entity));

			// Refire
			// SetVariantString("OnUser1 !self:Stop::2.9:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// SetVariantString("OnUser1 !self:FireUser2::3:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// AcceptEntityInput(entity, "FireUser1");

			// SetVariantString("OnUser2 !self:Start::0:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// SetVariantString("OnUser2 !self:FireUser1::0:-1");
			// AcceptEntityInput(entity, "AddOutput");
		}
		case ENUM_PARTICLE_SPIT2:
		{
			CreateTimer(5.0, TimerRefireSpit, EntIndexToEntRef(entity));

			// Refire - 5 seconds
			// SetVariantString("OnUser1 !self:Stop::5:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// SetVariantString("OnUser1 !self:FireUser2::6:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// AcceptEntityInput(entity, "FireUser1");

			// SetVariantString("OnUser2 !self:Start::0:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// SetVariantString("OnUser2 !self:FireUser1::0:-1");
			// AcceptEntityInput(entity, "AddOutput");
		}
		case ENUM_PARTICLE_TESLA:
		{
			CreateTimer(0.9, TimerRefireTesla, EntIndexToEntRef(entity));

			// Refire
			// SetVariantString("OnUser1 !self:Stop::0.9:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// SetVariantString("OnUser1 !self:FireUser2::1:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// AcceptEntityInput(entity, "FireUser1");

			// SetVariantString("OnUser2 !self:Start::0:-1");
			// AcceptEntityInput(entity, "AddOutput");
			// SetVariantString("OnUser2 !self:FireUser1::0:-1");
			// AcceptEntityInput(entity, "AddOutput");
		}
	}

	return EntIndexToEntRef(entity);
}

Action TimerRefireTesla(Handle timer, int entity)
{
	if( IsValidEntRef(entity) )
	{
		AcceptEntityInput(entity, "Stop");

		CreateTimer(0.1, TimerRefireTesla2, entity);
	}

	return Plugin_Stop;
}

Action TimerRefireTesla2(Handle timer, int entity)
{
	if( IsValidEntRef(entity) )
	{
		AcceptEntityInput(entity, "Start");

		CreateTimer(0.9, TimerRefireTesla, entity);
	}

	return Plugin_Stop;
}

Action TimerRefireSmoke(Handle timer, int entity)
{
	if( IsValidEntRef(entity) )
	{
		AcceptEntityInput(entity, "Stop");

		CreateTimer(1.0, TimerRefireSmoke2, entity);
		return Plugin_Continue;
	}

	return Plugin_Stop;
}

Action TimerRefireSmoke2(Handle timer, int entity)
{
	if( IsValidEntRef(entity) )
	{
		AcceptEntityInput(entity, "Start");

		CreateTimer(2.9, TimerRefireSmoke, entity);
		return Plugin_Continue;
	}

	return Plugin_Stop;
}

Action TimerRefireSpit(Handle timer, int entity)
{
	if( IsValidEntRef(entity) )
	{
		AcceptEntityInput(entity, "Stop");

		CreateTimer(1.0, TimerRefireSpit2, entity);
		return Plugin_Continue;
	}

	return Plugin_Stop;
}

Action TimerRefireSpit2(Handle timer, int entity)
{
	if( IsValidEntRef(entity) )
	{
		AcceptEntityInput(entity, "Start");

		CreateTimer(5.0, TimerRefireSpit, entity);
		return Plugin_Continue;
	}

	return Plugin_Stop;
}



// ====================================================================================================
//					STUFF
// ====================================================================================================
int GetEntityIndex(int type)
{
	int count, limit, global, index = -1;

	switch( type )
	{
		case TYPE_BOMB:		limit = g_iConfBombLimit;
		case TYPE_FIRE:		limit = g_iConfFireLimit;
		case TYPE_GHOST:	limit = g_iConfGhostLimit;
		case TYPE_MIND:		limit = g_iConfMindLimit;
		case TYPE_SMOKE:	limit = g_iConfSmokeLimit;
		case TYPE_SPIT:		limit = g_iConfSpitLimit;
		case TYPE_TESLA:	limit = g_iConfTeslaLimit;
	}

	for( int i = 0; i < MAX_ENTS; i++ )
	{
		if( g_iConfLimit == 0 )
		{
			if( ( type == TYPE_BOMB && IsValidEntRef(g_iInfectedBomb[i][0]) )
			||  ( type == TYPE_FIRE && IsValidEntRef(g_iInfectedFire[i][0]) )
			||  ( type == TYPE_GHOST && IsValidEntRef(g_iInfectedGhost[i]) )
			||  ( type == TYPE_MIND && IsValidEntRef(g_iInfectedMind[i][0]) )
			||  ( type == TYPE_SMOKE && IsValidEntRef(g_iInfectedSmoke[i][0]) )
			||  ( type == TYPE_SPIT && IsValidEntRef(g_iInfectedSpit[i][0]) )
			||  ( type == TYPE_TESLA && IsValidEntRef(g_iInfectedTesla[i][0]) )
			)
			{
				count++;
				if( count == limit )
				{
					return -1;
				}
			}
			else if( index == -1 )
			{
				index = i;
				if( limit == 0 ) break; // No point going through all arrays if no set limit, lets save that extra handful of CPU cycles
			}
		}
		else
		{
			if( IsValidEntRef(g_iInfectedBomb[i][0]) )
			{
				global++;
				if( type == TYPE_BOMB ) count++;
			}
			else if( type == TYPE_BOMB && index == -1 )
				index = i;

			if( IsValidEntRef(g_iInfectedFire[i][0]) )
			{
				global++;
				if( type == TYPE_FIRE ) count++;
			}
			else if( type == TYPE_FIRE && index == -1 )
				index = i;

			if( IsValidEntRef(g_iInfectedGhost[i]) )
			{
				global++;
				if( type == TYPE_GHOST ) count++;
			}
			else if( type == TYPE_GHOST && index == -1 )
				index = i;

			if( IsValidEntRef(g_iInfectedMind[i][0]) )
			{
				global++;
				if( type == TYPE_MIND ) count++;
			}
			else if( type == TYPE_MIND && index == -1 )
				index = i;

			if( IsValidEntRef(g_iInfectedSmoke[i][0]) )
			{
				global++;
				if( type == TYPE_SMOKE ) count++;
			}
			else if( type == TYPE_SMOKE && index == -1 )
				index = i;

			if( IsValidEntRef(g_iInfectedSpit[i][0]) )
			{
				global++;
				if( type == TYPE_SPIT ) count++;
			}
			else if( type == TYPE_SPIT && index == -1 )
				index = i;

			if( IsValidEntRef(g_iInfectedTesla[i][0]) )
			{
				global++;
				if( type == TYPE_TESLA ) count++;
			}
			else if( type == TYPE_TESLA && index == -1 )
				index = i;

			if( count == limit || global == g_iConfLimit )
				return -1;
		}
	}

	return index;
}

bool IsCommonValidToUse(int entity)
{
	// Ignore affecting Mutant Zombies
	if( GetEntProp(entity, Prop_Data, "m_iHammerID") == 66260 )
		return false;

	// Ignore affecting scaled zombies.
	if( g_bLeft4Dead2 && g_iConfCheck && GetEntPropFloat(entity, Prop_Send, "m_flModelScale") != 1.0 )
		return false;

	// Ignore affecting Uncommon common.
	if( !g_iConfUncommon && g_bLeft4Dead2 )
	{
		static char sTemp[48];
		GetEntPropString(entity, Prop_Data, "m_ModelName", sTemp, sizeof(sTemp));

		if( strcmp(sTemp, "models/infected/common_male_") == 0 &&
			(
			strcmp(sTemp[28], "ceda.mdl") == 0 ||
			strcmp(sTemp[28], "clown.mdl") == 0 ||
			strcmp(sTemp[28], "fallen_survivor.mdl") == 0 ||
			strcmp(sTemp[28], "jimmy.mdl") == 0 ||
			strcmp(sTemp[28], "mud.mdl") == 0 ||
			strcmp(sTemp[28], "riot.mdl") == 0 ||
			strcmp(sTemp[28], "roadcrew.mdl") == 0
			)
		)
		{
			return false;
		}
	}

	return true;
}

void StrToLowerCase(const char[] input, char[] output, int maxlength)
{
	int pos;
	while( input[pos] != 0 && pos < maxlength )
	{
		output[pos] = CharToLower(input[pos]);
		pos++;
	}

	output[pos] = 0;
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

void PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	if( FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
}