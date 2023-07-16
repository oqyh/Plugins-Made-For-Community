#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <multicolors>

ConVar
	g_enable,
	g_money;
	

bool
	g_benable = false;

int 
	g_bmoney = 0;

public Plugin myinfo =
{
	name = "Punishment Suicide",
	author = "Gold KingZ",
	description = "Punishment Suicide Money",
	version = "1.0.0",
	url = "https://github.com/oqyh"
}

public void OnPluginStart()
{
	LoadTranslations( "Punishment-Suicide.phrases" );
	
	g_enable = CreateConVar("ps_enable_plugin", "1", "Punishment Suicide Plugin?\n1= Enable \n0= Disable", _, true, 0.0, true, 1.0);
	
	g_money = CreateConVar("ps_money", "2400", "how much do you want to Punishment Suicide money");
	
	HookEvent("player_death", Event_player_death, EventHookMode_Pre);
	
	HookConVarChange(g_enable, OnSettingsChanged);
	HookConVarChange(g_money, OnSettingsChanged);
	
	AutoExecConfig(true, "Punishment-Suicide");
}

public void OnConfigsExecuted()
{
	g_benable = GetConVarBool(g_enable);
	g_bmoney = GetConVarInt(g_money);
}

public int OnSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == g_enable)
	{
		g_benable = g_enable.BoolValue;
	}
	
	if(convar == g_money)
	{
		g_bmoney = g_money.IntValue;
	}
	
	return 0;
}

public Action Event_player_death(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_benable)return Plugin_Continue;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(!IsPlayerValid(client))return Plugin_Continue;
	
	if(client == attacker)
	{
		SetEntProp(client, Prop_Send, "m_iAccount", GetEntProp(client, Prop_Send, "m_iAccount") - g_bmoney);
		
		CPrintToChat(client, " %t", "Suicide", g_bmoney);
	}
	return Plugin_Continue;
}


static bool IsPlayerValid( int client ) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client))
        return false; 
     
    return true; 
}