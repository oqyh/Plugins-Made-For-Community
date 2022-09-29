#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#pragma newdecls required

#define NONE 
#define	HiderHUD_WEAPONSELECTION		( 1<<0 )	// Hide ammo count & weapon selection
#define	HiderHUD_FLASHLIGHT			( 1<<1 )
#define	HiderHUD_ALL					( 1<<2 )
#define HiderHUD_HEALTH				( 1<<3 )	// Hide health & armor / suit battery
#define HiderHUD_PLAYERDEAD			( 1<<4 )	// Hide when local player's dead
#define HiderHUD_NEEDSUIT			( 1<<5 )	// Hide when the local player doesn't have the HEV suit
#define HiderHUD_MISCSTATUS			( 1<<6 )	// Hide miscellaneous status elements (trains, pickup history, death notices, etc)
#define HiderHUD_CHAT				( 1<<7 )	// Hide all communication elements (saytext, voice icon, etc)
#define	HiderHUD_CROSSHAIR			( 1<<8 )	// Hide crosshairs
#define	HiderHUD_VEHICLE_CROSSHAIR	( 1<<9 )	// Hide vehicle crosshair
#define HiderHUD_INVEHICLE			( 1<<10 )
#define HiderHUD_BONUS_PROGRESS		( 1<<11 )	// Hide bonus progress display (for bonus map challenges)
#define HiderHUD_BITCOUNT			12
#define HiderHUD_CSGO_RADAR                    ( 1<<12 )

public Plugin myinfo = 
{
	name = "[CSGO] Hud Hider",
	author = "Gold KingZ",
	description = "Csgo Hide Hud Any",
	version = "1.0.0",
	url = "https://github.com/oqyh"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_hud", Command_Hud);
	RegConsoleCmd("sm_HiderHUD", Command_Hud);
}

public Action Command_Hud(int client, int args)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		DisplayHUD(client);
	}
	return Plugin_Continue;
}

stock void DisplayHUD(int client, int iItem = 0)
{
	Menu g_hMenuHUD = new Menu(MenuHUDHandler);
	g_hMenuHUD.SetTitle("HUD Hider : Select which elements to Display / Hide\n ");
	g_hMenuHUD.AddItem("HiderHUD_WEAPONSELECTION",  IsFlagSet(client, HiderHUD_WEAPONSELECTION)   ? "✓ WEAPONSELECTION"   : "WEAPONSELECTION");
	g_hMenuHUD.AddItem("HiderHUD_FLASHLIGHT",  IsFlagSet(client, HiderHUD_FLASHLIGHT)        ? "✓ FLASHLIGHT"        : "FLASHLIGHT");
	g_hMenuHUD.AddItem("HiderHUD_ALL",  IsFlagSet(client, HiderHUD_ALL)               ? "✓ ALL"               : "ALL");
	g_hMenuHUD.AddItem("HiderHUD_HEALTH",  IsFlagSet(client, HiderHUD_HEALTH)            ? "✓ HEALTH"            : "HEALTH");
	g_hMenuHUD.AddItem("HiderHUD_PLAYERDEAD",  IsFlagSet(client, HiderHUD_PLAYERDEAD)        ? "✓ PLAYERDEAD"        : "PLAYERDEAD");
	g_hMenuHUD.AddItem("HiderHUD_NEEDSUIT",  IsFlagSet(client, HiderHUD_NEEDSUIT)          ? "✓ NEEDSUIT"          : "NEEDSUIT");
	g_hMenuHUD.AddItem("HiderHUD_MISCSTATUS",  IsFlagSet(client, HiderHUD_MISCSTATUS)        ? "✓ MISCSTATUS"        : "MISCSTATUS");
	g_hMenuHUD.AddItem("HiderHUD_CHAT",  IsFlagSet(client, HiderHUD_CHAT)              ? "✓ CHAT"              : "CHAT");
	g_hMenuHUD.AddItem("HiderHUD_CROSSHAIR",  IsFlagSet(client, HiderHUD_CROSSHAIR)         ? "✓ CROSSHAIR"         : "CROSSHAIR");
	g_hMenuHUD.AddItem("HiderHUD_VEHICLE_CROSSHAIR",  IsFlagSet(client, HiderHUD_VEHICLE_CROSSHAIR) ? "✓ VEHICLE_CROSSHAIR" : "VEHICLE_CROSSHAIR");
	g_hMenuHUD.AddItem("HiderHUD_INVEHICLE", IsFlagSet(client, HiderHUD_INVEHICLE)         ? "✓ INVEHICLE"         : "INVEHICLE");
	g_hMenuHUD.AddItem("HiderHUD_BONUS_PROGRESS", IsFlagSet(client, HiderHUD_BONUS_PROGRESS)    ? "✓ BONUS_PROGRESS"    : "BONUS_PROGRESS");
	g_hMenuHUD.AddItem("HiderHUD_BITCOUNT", IsFlagSet(client, HiderHUD_BITCOUNT)    ? "✓ BITCOUNT"    : "BITCOUNT");
	g_hMenuHUD.AddItem("HiderHUD_CSGO_RADAR", IsFlagSet(client, HiderHUD_CSGO_RADAR)    ? "✓ RADAR"    : "RADAR");
	g_hMenuHUD.DisplayAt(client, iItem, MENU_TIME_FOREVER);
}

stock bool IsFlagSet(int client, int iFlag)
{
	int HiderHUD = GetEntProp(client, Prop_Send, "m_iHideHUD");
	
	if(HiderHUD & iFlag)
		return true;
		
	return false;
}

public int MenuHUDHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		int HiderHUD = GetEntProp(param1, Prop_Send, "m_iHideHUD");
	
		switch (param2)
		{
			case 0:  HiderHUD ^= HiderHUD_WEAPONSELECTION;
			case 1:  HiderHUD ^= HiderHUD_FLASHLIGHT;
			case 2:  HiderHUD ^= HiderHUD_ALL;
			case 3:  HiderHUD ^= HiderHUD_HEALTH;
			case 4:  HiderHUD ^= HiderHUD_PLAYERDEAD;
			case 5:  HiderHUD ^= HiderHUD_NEEDSUIT;
			case 6:  HiderHUD ^= HiderHUD_MISCSTATUS;
			case 7:  HiderHUD ^= HiderHUD_CHAT;
			case 8:  HiderHUD ^= HiderHUD_CROSSHAIR;
			case 9:  HiderHUD ^= HiderHUD_VEHICLE_CROSSHAIR;
			case 10: HiderHUD ^= HiderHUD_INVEHICLE;
			case 11: HiderHUD ^= HiderHUD_BONUS_PROGRESS;
			case 12: HiderHUD ^= HiderHUD_BITCOUNT;
			case 13: HiderHUD ^= HiderHUD_CSGO_RADAR;
		}
		
		SetEntProp(param1, Prop_Send, "m_iHideHUD", HiderHUD);

		DisplayHUD(param1, GetMenuSelectionPosition());
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
	return 0;	
}