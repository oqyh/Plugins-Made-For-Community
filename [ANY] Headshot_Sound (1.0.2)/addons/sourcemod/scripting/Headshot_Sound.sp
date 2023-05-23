#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#define PLUGIN_VERSION    "1.0.2"

ConVar Sound;
ConVar Soundvolume;

int bSound = 0;
float bSoundvolume = 0.00;
bool g_bLateLoaded = false;

Handle SoundPath        = INVALID_HANDLE;

public Plugin myinfo = 
{
    name = "[ANY] Headshot Sound",
    author = "Gold KingZ",
    description = "Headshot Kill Sound",
    version     = PLUGIN_VERSION,
    url = "https://github.com/oqyh"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int length)
{
	g_bLateLoaded = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
    CreateConVar("hs_sound_version", PLUGIN_VERSION, "[ANY] Headshot Sound Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
    
    Sound        =    CreateConVar( "hs_sound_enable",     "1",    "Enable HeadShot Sound? || 2= Yes After Every Headshot || 1= Yes After Kill || 0= No", _, true, 0.0, true, 2.0);
    Soundvolume        =    CreateConVar( "hs_sound_volume",     "0.30",    "Volume of the Sound From 0.00 To 1.00 || 1.00 is the hightest", _, true, 0.00, true, 1.00);
    SoundPath    =    CreateConVar( "hs_sound_file",    "training/bell_normal.wav","if hs_sound_enable 1 or 2 Where is Sound Location Without Sound/ beginning" );
    
    HookEvent("player_death", Event_PlayerDeath_Pre, EventHookMode_Pre);
    
    if (g_bLateLoaded) 
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i)) 
            {
                OnClientPutInServer(i);
            }
        }
    }
    
    HookConVarChange(Sound, OnSettingsChanged);
    HookConVarChange(Soundvolume, OnSettingsChanged);
    
    AutoExecConfig(true, "Headshot_Sound");
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OneHitDamage);
}

public void OnConfigsExecuted()
{
    bSound = GetConVarInt(Sound);
    bSoundvolume = GetConVarFloat(Soundvolume);
    
    if(bSound == 1 || bSound == 2)
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
        bSound = Sound.IntValue;
    }
    
    if(convar == Soundvolume)
    {
        bSoundvolume = Soundvolume.FloatValue;
    }
    
    return 0;
}

public Action Event_PlayerDeath_Pre(Handle event, const char[] name, bool dontBroadcast)
{
    
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    bool headshot = GetEventBool(event, "headshot");
    
    if (bSound != 1 || !IsValidClient(attacker))
    {
        return Plugin_Continue;
    }
    
    char iFileSound[PLATFORM_MAX_PATH];
    GetConVarString(SoundPath, iFileSound, sizeof(iFileSound));
    
    if(IsValidClient(attacker) && headshot)
    {
        EmitSoundToClient(attacker, iFileSound, _, _, _, _, bSoundvolume);
    }
    
    return Plugin_Continue;
}


public Action OneHitDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (bSound != 2 || !IsValidClient(attacker))
    {
        return Plugin_Continue;
    }
    
    char iFileSound[PLATFORM_MAX_PATH];
    GetConVarString(SoundPath, iFileSound, sizeof(iFileSound));
    
    if (IsValidClient(attacker) && (damagetype &= CS_DMG_HEADSHOT))
    {
        EmitSoundToClient(attacker, iFileSound, _, _, _, _, bSoundvolume);
    }
    
    return Plugin_Continue;
}


stock bool IsValidClient(int iClient)
{
    return (1 <= iClient <= MaxClients && IsClientInGame(iClient)) ? true : false;
} 