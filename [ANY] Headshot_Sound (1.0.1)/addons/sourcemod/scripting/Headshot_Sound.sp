#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION	"1.0.1"

ConVar Sound;
ConVar Soundvolume;

bool bSound = false;
float bSoundvolume = 0.00;

Handle SoundPath		= INVALID_HANDLE;

public Plugin myinfo = 
{
	name = "[ANY] Headshot Sound",
	author = "Gold KingZ",
	description = "Headshot Kill Sound",
	version     = PLUGIN_VERSION,
	url = "https://github.com/oqyh"
}

public void OnPluginStart()
{
	CreateConVar("hs_sound_version", PLUGIN_VERSION, "[ANY] Headshot Sound Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	Sound		=	CreateConVar( "hs_sound_enable", 	"1",	"Enable HeadShot Sound || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	Soundvolume		=	CreateConVar( "hs_sound_volume", 	"0.30",	"Volume of the Sound From 0.00 To 1.00 || 1.00 is the hightest", _, true, 0.00, true, 1.00);
	SoundPath	=	CreateConVar( "hs_sound_file",	"training/bell_normal.wav","if hs_sound_enable 1 Where is Sound Location Without Sound/ beginning" );
	
	HookEvent("player_death", Event_PlayerDeath_Pre, EventHookMode_Pre);
	
	HookConVarChange(Sound, OnSettingsChanged);
	HookConVarChange(Soundvolume, OnSettingsChanged);
	
	AutoExecConfig(true, "Headshot_Sound");
}

public void OnConfigsExecuted()
{
	bSound = GetConVarBool(Sound);
	bSoundvolume = GetConVarFloat(Soundvolume);
	
	if(GetConVarInt(Sound) == 1)
	{
		char iFileSound[PLATFORM_MAX_PATH];
		GetConVarString(SoundPath, iFileSound, sizeof(iFileSound));
		if(!StrEqual(iFileSound, ""))
		{
			char download[PLATFORM_MAX_PATH];
			Format(download, sizeof(download), "sound/%s", iFileSound);
			AddFileToDownloadsTable(download);
			PrecacheSound(iFileSound);
		}
	}
	
}
public int OnSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == Sound)
	{
		bSound = Sound.BoolValue;
	}
	
	if(convar == Soundvolume)
	{
		bSoundvolume = Soundvolume.FloatValue;
	}
	
	return 0;
}

public Action Event_PlayerDeath_Pre(Event event, const char[] name, bool dontBroadcast)
{
	if(!bSound)return Plugin_Continue;
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	bool headshot = GetEventBool(event, "headshot");
	
	char iFileSound[PLATFORM_MAX_PATH];
	GetConVarString(SoundPath, iFileSound, sizeof(iFileSound));
	
	if(IsValidClient(attacker))
	{
		if(headshot)
		{
			EmitSoundToClient(attacker, iFileSound, _, _, _, _, bSoundvolume);
		}
	}
	return Plugin_Continue;
}

stock bool IsValidClient(int iClient)
{
	return (1 <= iClient <= MaxClients && IsClientInGame(iClient)) ? true : false;
}