#include <sourcemod>
#include <sdkhooks>

Handle c_difficulty;
Handle g_modifyw;
Handle g_clawdamageOnEasy = INVALID_HANDLE;
Handle g_clawdamageOnNormal = INVALID_HANDLE;
Handle g_clawdamageOnHard = INVALID_HANDLE;
Handle g_clawdamageOnImpossible = INVALID_HANDLE;

public Plugin myinfo = 
{
    name = "[L4D/L4D2] Change Any Weapon Damage Difficulty",
    author = "Gold KingZ",
    description = "Change Any Weapon Damage Depend On Difficulty",
    version = "1.0.0",
    url = "https://github.com/oqyh"
}

public OnPluginStart()
{
    g_modifyw = CreateConVar("sm_dmg_weapon", "weapon_tank_claw", "Which weapon do you want to modify damage check link for info https://github.com/oqyh/Plugins-Made-For-Community/tree/main/%5BL4D2%5D%20Change%20Damage%20Depend%20Difficulty/weapons_ids");
    g_clawdamageOnEasy = CreateConVar("sm_dmg_easy", "10.0", "Damage on Easy");
    g_clawdamageOnNormal = CreateConVar("sm_dmg_normal", "30.0", "Damage on Normal");
    g_clawdamageOnHard = CreateConVar("sm_dmg_hard", "60.0", "Damage on Hard");
    g_clawdamageOnImpossible = CreateConVar("sm_dmg_impossible", "100.0", "Damage on Impossible");
    
    c_difficulty = FindConVar("z_difficulty"); //difficulty convar
    
    AutoExecConfig(true, "DamageChangeDifficulty");
}

public OnClientPutInServer(client)
{
    if(IsClientInGame(client))
    {
        SDKHook(client, SDKHook_OnTakeDamage, OneHitDamage);
    }
}
	
public Action OneHitDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if(!attacker || attacker == victim || attacker > MaxClients || !IsClientInGame(attacker) && GetClientTeam(victim) == GetClientTeam(attacker))
    return Plugin_Continue;
    
    char GameDiff1[32],GameDiff2[32],GameDiff3[32],GameDiff4[32];
    char sWeapon1[32],zweapon1[128],sWeapon2[32],zweapon2[128],sWeapon3[32],zweapon3[128],sWeapon4[32],zweapon4[128];
	
    GetConVarString(c_difficulty, GameDiff1, sizeof(GameDiff1));
    if (StrEqual(GameDiff1, "easy", false)) //easy
    {
		GetConVarString(g_modifyw, zweapon1, sizeof(zweapon1));
		GetClientWeapon(attacker, sWeapon1, sizeof(sWeapon1)); //check attacker weapon
		
		if(StrContains(sWeapon1, zweapon1, false) != -1)
		{
			damage *= GetConVarFloat(g_clawdamageOnEasy); // change his damage on easy
			return Plugin_Changed;
		}
    }else if (StrEqual(GameDiff2, "normal", false)) //normal
    {
		GetConVarString(g_modifyw, zweapon2, sizeof(zweapon2));
		GetClientWeapon(attacker, sWeapon2, sizeof(sWeapon2));
		
		if(StrContains(sWeapon2, zweapon2, false) != -1)
		{
			damage *= GetConVarFloat(g_clawdamageOnNormal); 
			return Plugin_Changed;
		}
    }else if (StrEqual(GameDiff3, "hard", false)) //hard
    {
		GetConVarString(g_modifyw, zweapon3, sizeof(zweapon3));
		GetClientWeapon(attacker, sWeapon3, sizeof(sWeapon3));
		
		if(StrContains(sWeapon3, zweapon3, false) != -1)
		{
			damage *= GetConVarFloat(g_clawdamageOnHard); 
			return Plugin_Changed;
		}
    }else if (StrEqual(GameDiff4, "impossible", false)) //impossible
    {
		GetConVarString(g_modifyw, zweapon4, sizeof(zweapon4));
		GetClientWeapon(attacker, sWeapon4, sizeof(sWeapon4));
		
		if(StrContains(sWeapon4, zweapon4, false) != -1)
		{
			damage *= GetConVarFloat(g_clawdamageOnImpossible);
			return Plugin_Changed;
		}
    }
    return Plugin_Continue;
} 