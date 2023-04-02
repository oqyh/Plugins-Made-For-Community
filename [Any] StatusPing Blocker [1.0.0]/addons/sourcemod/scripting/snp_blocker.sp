#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <PTaH>
#include <multicolors>

#define PLUGIN_VERSION	"1.0.0"

ConVar h_enable_plugin;
ConVar g_hAdmFlag;
ConVar h_admins;
ConVar h_chat;
ConVar h_log;
ConVar h_kickplayer;

bool bh_enable_plugin = false;
bool bh_admins = false;
bool bh_log = false;
bool bh_kickplayer = false;

int bh_chat = 0;

char g_sLogs[PLATFORM_MAX_PATH + 1];

public Plugin myinfo = 
{
	name = "[Any] Status/Ping Blocker",
	author = "Gold KingZ",
	description = "Log + block Who Tries Ping Or Status Console",
	version     = PLUGIN_VERSION,
	url = "https://github.com/oqyh"
}

public void OnPluginStart()
{
	LoadTranslations( "snp_blocker.phrases" );
	
	CreateConVar("snp_blocker_version", PLUGIN_VERSION, "[Any] Status/Ping Blocker Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	h_enable_plugin =  CreateConVar("snp_blocker_enable", "1", "Enable Status/Ping Blocker Plugin\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	
	h_kickplayer =  CreateConVar("snp_blocker_kick", "0", "Kick Player Who Status Or Ping?\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	
	h_admins =  CreateConVar("snp_ignore_admins", "0", "Ignore Admins?\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	
	h_chat =  CreateConVar("snp_enable_printchat", "0", "Print To Chat Who Typed Status Or Ping? \n2= Yes + Private Notification To Admins in the game Only \n1= Yes + Announce To All \n0= No", _, true, 0.0, true, 2.0);
	
	g_hAdmFlag = CreateConVar("snp_admins_flag",	"z",	"if snp_enable_printchat 2 which flag is admin");
	
	h_log =  CreateConVar("snp_log_enable", "0", "Enable + Send Logs To [addons/sourcemod/logs] ?\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	
	PTaH(PTaH_ExecuteStringCommandPre, Hook, ExecuteString);
	
	HookConVarChange(h_enable_plugin, OnSettingsChanged);
	HookConVarChange(h_admins, OnSettingsChanged);
	HookConVarChange(h_chat, OnSettingsChanged);
	HookConVarChange(h_log, OnSettingsChanged);
	HookConVarChange(h_kickplayer, OnSettingsChanged);
	
	AutoExecConfig(true, "snp_blocker");
	
	char sDate[18];
	FormatTime(sDate, sizeof(sDate), "%y-%m-%d");
	BuildPath(Path_SM, g_sLogs, sizeof(g_sLogs), "logs/snp_blocker[%s].log", sDate);

}

public void OnConfigsExecuted()
{
	bh_enable_plugin = GetConVarBool(h_enable_plugin);
	bh_admins = GetConVarBool(h_admins);
	bh_chat = GetConVarInt(h_chat);
	bh_log = GetConVarBool(h_log);
	bh_kickplayer = GetConVarBool(h_kickplayer);
}

public int OnSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == h_enable_plugin)
	{
		bh_enable_plugin = h_enable_plugin.BoolValue;
	}
	
	if(convar == h_admins)
	{
		bh_admins = h_admins.BoolValue;
	}
	
	if(convar == h_chat)
	{
		bh_chat = h_chat.IntValue;
	}
	
	if(convar == h_log)
	{
		bh_log = h_log.BoolValue;
	}
	
	if(convar == h_kickplayer)
	{
		bh_kickplayer = h_kickplayer.BoolValue;
	}
	
	return 0;
}

public Action ExecuteString(int client, char sCommandString[512]) 
{
	if(!bh_enable_plugin || !IsClientValid(client))return Plugin_Continue; 
	
	if (IsClientValid(client))
	{
		char message[512],gAuth[21];
		strcopy(message, sizeof(message), sCommandString);
		TrimString(message);
		GetClientAuthId(client, AuthId_Steam2, gAuth, sizeof(gAuth));
		
		if(StrContains(message, "ping") == 0)
		{
			if (bh_admins && CheckCommandAccess(client, "Generic_admin", ADMFLAG_GENERIC, true))
			{
				return Plugin_Continue;
			}
			
			if(bh_chat == 1)
			{
				CPrintToChatAll(" %t","printclientblocker", client, gAuth);
			}else if(bh_chat == 2)
			{
				PrintToAdmins(" %t","printclientblocker", client, gAuth);
			}
			
			if(bh_kickplayer)
			{
				KickClient(client, " %t","kickblockerping");
			}
			
			if(bh_log)
			{
				LogToFile(g_sLogs, "\"%L\" Tried to [ping] in console", client);
			}
			return Plugin_Handled;
		}
		
		if(StrContains(message, "status") == 0)
		{
			if (bh_admins && CheckCommandAccess(client, "Generic_admin", ADMFLAG_GENERIC, true))
			{
				return Plugin_Continue;
			}
			
			if(bh_chat == 1)
			{
				CPrintToChatAll(" %t","statusclientblocker", client, gAuth);
			}else if(bh_chat == 2)
			{
				PrintToAdmins(" %t","statusclientblocker", client, gAuth);
			}
			
			if(bh_kickplayer)
			{
				KickClient(client, " %t","kickblockerstatus");
			}
			
			if(bh_log)
			{
				LogToFile(g_sLogs, "\"%L\" Tried to [status] in console", client);
			}
			return Plugin_Handled;
		}
	}
	return Plugin_Continue; 
}

void PrintToAdmins(char[] format, any ...)
{
	char buff[256];
	VFormat(buff, sizeof(buff), format, 2);

	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsValidClient(i) && IsValidAdmin(i, g_hAdmFlag) )
		{
			CPrintToChat(i, buff);
		}
	}
}

bool IsValidClient(int client)
{
	if( client <= 0 || client > MaxClients || !IsClientInGame(client) || (IsFakeClient(client)) )
	{
		return false;
	}
	return true;
}

bool IsValidAdmin(int client, ConVar cvar)
{
	char flags[24];
	cvar.GetString(flags, sizeof(flags));

	int ibFlags = ReadFlagString(flags);
	int iFlags = GetUserFlagBits(client);

	if( iFlags & ibFlags || iFlags & ADMFLAG_ROOT )
	{
		return true;
	}
	return false;
}

bool IsClientValid(int client)
{
    if (client > 0 && client <= MaxClients)
    {
        if (IsClientInGame(client) && !IsFakeClient(client) && !IsClientSourceTV(client))
        {
            return true;
        }
    }
    return false;
}
