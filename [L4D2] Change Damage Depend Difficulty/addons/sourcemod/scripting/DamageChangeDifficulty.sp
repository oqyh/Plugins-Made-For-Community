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
    name = "[L4D2] Change Any Weapon Damage Difficulty",
    author = "Gold KingZ",
    description = "Change Any Weapon Damage Depend On Difficulty",
    version = "1.0.0",
    url = "https://github.com/oqyh"
}

public OnPluginStart()
{
    g_modifyw = CreateConVar("sm_dmg_weapon", "weapon_tank_claw", "which weapon do you want to modify damage https://github.com/oqyh/Plugins-Made-For-Community/blob/main/%5BL4D2%5D%20Change%20Damage%20Depend%20Difficulty/weapon_ids_L4D2.txt");
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
    
    char GameDiff[32];
    GetConVarString(c_difficulty, GameDiff, sizeof(GameDiff));
    if (StrEqual(GameDiff, "easy", false)) //easy
    {
		char sWeapon[32],zweapon[128];
		GetConVarString(g_modifyw, zweapon, sizeof(zweapon));
		GetClientWeapon(attacker, sWeapon, sizeof(sWeapon)); //check attacker weapon
		
		if(StrContains(sWeapon, zweapon, false) != -1)
		{
			damage *= GetConVarFloat(g_clawdamageOnEasy); // change his damage on easy
			return Plugin_Changed;
		}
    }else if (StrEqual(GameDiff, "normal", false)) //normal
    {
		char sWeapon[32],zweapon[128];
		GetConVarString(g_modifyw, zweapon, sizeof(zweapon));
		GetClientWeapon(attacker, sWeapon, sizeof(sWeapon)); //check attacker weapon
		
		if(StrContains(sWeapon, zweapon, false) != -1)
		{
			damage *= GetConVarFloat(g_clawdamageOnNormal); 
			return Plugin_Changed;
		}
    }else if (StrEqual(GameDiff, "hard", false)) //hard
    {
		char sWeapon[32],zweapon[128];
		GetConVarString(g_modifyw, zweapon, sizeof(zweapon));
		GetClientWeapon(attacker, sWeapon, sizeof(sWeapon)); //check attacker weapon
		
		if(StrContains(sWeapon, zweapon, false) != -1)
		{
			damage *= GetConVarFloat(g_clawdamageOnHard); 
			return Plugin_Changed;
		}
    }else if (StrEqual(GameDiff, "impossible", false)) //impossible
    {
		char sWeapon[32],zweapon[128];
		GetConVarString(g_modifyw, zweapon, sizeof(zweapon));
		GetClientWeapon(attacker, sWeapon, sizeof(sWeapon)); //check attacker weapon
		
		if(StrContains(sWeapon, zweapon, false) != -1)
		{
			damage *= GetConVarFloat(g_clawdamageOnImpossible);
			return Plugin_Changed;
		}
    }
    return Plugin_Continue;
} 