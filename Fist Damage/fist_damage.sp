#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define CFG_NAME "fist_damage"

ConVar g_forcegivefist;
ConVar g_damage;

new	Handle:g_removebuyzone = INVALID_HANDLE;

char CfgFile[PLATFORM_MAX_PATH];
	
public Plugin:myinfo = 
{
	name = "fist_damage",
	author = "Gold_KingZ",
	description = "Spawn With Fist + Modify Damage",
	version = "1.0.0",
	url = "https://steamcommunity.com/id/oQYh"
}

public OnPluginStart()
{
	Format(CfgFile, sizeof(CfgFile), "sourcemod/%s.cfg", CFG_NAME);
	
	g_forcegivefist = CreateConVar( "sm_force_give_fist", "1", "Spawn With Fist || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_damage = CreateConVar( "sm_fist_damage", "300", "Damage Fist Deal  || 0= No Damage || 1= Lowest Damage || 300= 1 Hit");
	g_removebuyzone = CreateConVar( "sm_disable_buyzone", "1", "Disable Buy Zone || 1= Yes || 0= No", _, true, 0.0, true, 1.0);

	for (int i = 1; i < MaxClients; ++i)
		{
			if (IsClientInGame(i))
			{
				SDKHook(i, SDKHook_OnTakeDamage, OneHitDamage);
			}
		}
		
	HookEvent( "player_spawn",	Event_PlayerSpawn);
	LoadCfg();
}

void LoadCfg()
{
	AutoExecConfig(true, CFG_NAME);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
	SDKHook(client, SDKHook_OnTakeDamage, OneHitDamage);
}


public void Hook_PostThinkPost(int entity)
{
	if( !GetConVarBool( g_removebuyzone ) )
		return;
	
	SetEntProp(entity, Prop_Send, "m_bInBuyZone", 0);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
    CreateTimer(1.6, Timer_Delay, GetClientUserId(client));
}  

stock void StripWeapons(int client)
{
	int index;
	int weapon;
	
	while((weapon = GetNextWeapon(client, index)) != -1)
	{
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");
	}
}

stock int GetNextWeapon(int client, int &weaponIndex)
{
	static int weaponsOffset = -1;
	if (weaponsOffset == -1)
		weaponsOffset = FindDataMapInfo(client, "m_hMyWeapons");
	
	int offset = weaponsOffset + (weaponIndex * 4);
	
	int weapon;
	while (weaponIndex < 48) 
	{
		weaponIndex++;
		
		weapon = GetEntDataEnt2(client, offset);
		
		if (IsValidEdict(weapon)) 
			return weapon;
		
		offset += 4;
	}
	
	return -1;
} 

public Action Timer_Delay(Handle timer, int id)
{
	if( GetConVarBool( g_forcegivefist ) )
	{
		int client = GetClientOfUserId(id);
		if(!client || !IsClientInGame(client) || !IsPlayerAlive(client) || (4 < 4 && 4 != GetClientTeam(client)))
			return Plugin_Continue;
			
		StripWeapons(client);
		int iMelee;
		iMelee = GivePlayerItem(client, "weapon_fists");
		EquipPlayerWeapon(client, iMelee);
		
		return Plugin_Continue;
		}
	return Plugin_Handled;
}

public Action OneHitDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!attacker || attacker > MaxClients || !IsClientInGame(attacker))
    {
        return Plugin_Continue;
    }
    char sWeapon[32];
    GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
    if(StrContains(sWeapon, "fists", false) != -1)
    {
        damage = g_damage.FloatValue;
		
        return Plugin_Changed;
    }
    return Plugin_Continue;
}