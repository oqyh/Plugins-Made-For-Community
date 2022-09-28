#include <zombiereloaded>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

#include <sdktools_entinput>
#include <sdktools_functions>
#include <sdkhooks>

static const char
	PL_NAME[]	= "[ZR] Prop Health",
	PL_VER[]	= "1.0.0";

public Plugin myinfo =
{
	name		= PL_NAME,
	version		= PL_VER,
	description	= "Props Health",
	author		= "Gold KingZ",
	url			= "https://github.com/oqyh"
}

bool
	bColor,
	bDebug;
int
	iHealth[2049],
	iColor[4],
	iTeam,
	iType;
float
	fMult;
char
	sCfg[PLATFORM_MAX_PATH],
	sLog[PLATFORM_MAX_PATH];

public void OnPluginStart()
{
	CreateConVar("sm_ph_version", PL_VER, PL_NAME);

	ConVar cvar;
	cvar = CreateConVar("sm_ph_cfg_path", "configs/prophealth.props.cfg", "The path to the Prop Health config.");
	cvar.AddChangeHook(CVarChanged_CfgPath);
	cvar.GetString(sCfg, sizeof(sCfg));

	cvar = CreateConVar("sm_ph_def_health", "-1", "A prop's default health if not defined in the config file. -1 = Doesn't break.", _, true, -1.0);
	cvar.AddChangeHook(CVarChanged_Health);
	iHealth[0] = cvar.IntValue;

	cvar = CreateConVar("sm_ph_def_mult", "325.0", "Default multiplier based on the player count(for zombies/humans). Default: 65 * 5(65 damage by right-click knife with 5 hits)", _, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Mult);
	fMult = cvar.FloatValue;

	cvar = CreateConVar("sm_ph_color", "255 0 0 255", "If a prop has a color, set it to this color. -1 = no color. uses RGBA.", FCVAR_PRINTABLEONLY);
	cvar.AddChangeHook(CVarChanged_Color);
	CVarChanged_Color(cvar, NULL_STRING, NULL_STRING);

	cvar = CreateConVar("sm_ph_team", "2", "What team are allowed to destroy props? 0 = no restriction, 1 = humans, 2 = zombies.", _, true, _, true, 2.0);
	cvar.AddChangeHook(CVarChanged_Team);
	iTeam = cvar.IntValue;

	cvar = CreateConVar("sm_ph_print", "3", "The print to the: 0 - nowhere, 1 - chat, 2 - center, 3 - hint", _, true, _, true, 3.0);
	cvar.AddChangeHook(CVarChanged_Type);
	iType = cvar.IntValue;

	cvar = CreateConVar("sm_ph_debug", "0", "Enable debugging (logs will saved to the file 'logs/prop_health.log')", _, true, _, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Debug);
	bDebug = cvar.BoolValue;

	AutoExecConfig(true, "plugin.prop_health");

	BuildPath(Path_SM, sLog, sizeof(sLog), "logs/prop_health.log");

	RegConsoleCmd("sm_getpropinfo", Command_GetPropInfo);

	LoadTranslations("prophealth.phrases.txt");
}

public void CVarChanged_CfgPath(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	cvar.GetString(sCfg, sizeof(sCfg));
}

public void CVarChanged_Health(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iHealth[0] = cvar.IntValue;
}

public void CVarChanged_Mult(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	fMult = cvar.FloatValue;
}

public void CVarChanged_Color(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	char clr[16];
	cvar.GetString(clr, sizeof(clr));

	if(!(bColor = clr[0] && clr[0] != '-')) return;

	iColor[0] = iColor[1] = iColor[2] = iColor[3] = 255;
	char buffer[4][4];
	int num = ExplodeString(clr, " ", buffer, 4, 4);
	for(int i; i < num; i++) iColor[i] = StringToInt(buffer[i]);
}

public void CVarChanged_Team(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iTeam = cvar.IntValue;
}

public void CVarChanged_Type(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iType = cvar.IntValue;
}

public void CVarChanged_Debug(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	bDebug = cvar.BoolValue;
}

public void OnEntityCreated(int iEnt, const char[] cls)
{
	if(iEnt > MaxClients && (StrEqual(cls, "prop_physics", false) || StrEqual(cls, "prop_physics_override", false)
	|| StrEqual(cls, "prop_physics_multiplayer", false)))
		SDKHook(iEnt, SDKHook_SpawnPost, OnEntitySpawned);
}

public void OnEntitySpawned(int iEnt)
{
	if(!IsValidEntity(iEnt)) return;

	iHealth[iEnt] = -1;

	char sFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sFile, sizeof(sFile), sCfg);

	KeyValues hKV = new KeyValues("Props");
	FileToKeyValues(hKV, sFile);

	char mdl[PLATFORM_MAX_PATH];
	GetEntPropString(iEnt, Prop_Data, "m_ModelName", mdl, sizeof(mdl));
	if(bDebug) LogToFile(sLog, "Prop model found!(Prop: %i)(Prop Model: %s)", iEnt, mdl);

	int num, add;
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && GetClientTeam(i) > 1) num++;

	if(KvGotoFirstSubKey(hKV))
	{
		int mult;
		char sBuffer[PLATFORM_MAX_PATH];
		do
		{
			KvGetSectionName(hKV, sBuffer, sizeof(sBuffer));
			if(bDebug) LogToFile(sLog, "Checking prop model.(Prop: %i)(Prop Model: %s)(Section Model: %s)", iEnt, mdl, sBuffer);

			if(StrEqual(sBuffer, mdl, false))
			{
				if(bDebug) LogToFile(sLog, "Prop model matches.(Prop: %i)(Prop Model: %s)", iEnt, mdl);

				mult = RoundToZero(KvGetFloat(hKV, "multiplier"));
				add = num * mult;
				iHealth[iEnt] = KvGetNum(hKV, "health") + add;

				if(bDebug) LogToFile(sLog, "Custom prop's health set.(Prop: %i)(Prop Health: %i)(Multiplier: %f)(Added Health: %i)(Client Count: %i)", iEnt, iHealth[iEnt], mult, add, num);
			}
		} while(KvGotoNextKey(hKV));
	}

	if(hKV) delete hKV;
	else if(bDebug) LogToFile(sLog, "hKV was never valid.");

	if(iHealth[iEnt] < 1)
	{
		add = num * RoundToZero(fMult);
		iHealth[iEnt] = iHealth[0] + add;
		if(bDebug) LogToFile(sLog, "Prop is being set to default health.(Prop: %i)(O - Default Health: %i)(Default Multiplier: %f)(Added Health: %i)(Health: %i)(Client Count: %i)", iEnt, iHealth[0], fMult, add, iHealth[iEnt], num);
	}
	else if(bDebug)
		LogToFile(sLog, "Prop already has a health value!(Prop: %i)(Health: %i)", iEnt, iHealth[iEnt]);

	if(bColor && iHealth[iEnt] > 0)
	{
		if(bDebug) LogToFile(sLog, "Prop is being colored!(Prop: %i). Color is: '%d %d %d %d'", iEnt, iColor[0], iColor[1], iColor[2], iColor[3]);
		SetEntityRenderColor(iEnt, iColor[0], iColor[1], iColor[2], iColor[3]);
	}

	if(iHealth[iEnt] > 0) SDKHook(iEnt, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

public Action Hook_OnTakeDamage(int iEnt, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType)
{
	if(!iAttacker || iAttacker > MaxClients || !IsClientInGame(iAttacker))
	{
		if(bDebug) LogToFile(sLog, "Prop %i returned. Attacker(%i) not valid.", iEnt, iAttacker);
		return Plugin_Continue;
	}

	if(iHealth[iEnt] < 0)
	{
		if(bDebug) LogToFile(sLog, "Prop %i returned. Prop health under 0.", iEnt, iAttacker);
		return Plugin_Continue;
	}

	if(iTeam == 1 && ZR_IsClientZombie(iAttacker) || iTeam == 2 && ZR_IsClientHuman(iAttacker))
	{
		if(bDebug) LogToFile(sLog, "Prop %i returned. Attacker(%i) not on the right team.", iEnt, iAttacker);
		return Plugin_Continue;
	}

	iHealth[iEnt] -= RoundToZero(fDamage);

	if(bDebug) LogToFile(sLog, "Prop Damaged (Id: %i, Dmg: %f, HP: %i)", iEnt, fDamage, iHealth[iEnt]);

	if(iHealth[iEnt] < 1)
	{

		if(bDebug) LogToFile(sLog, "Prop Destroyed(Prop: %i)", iEnt);

		AcceptEntityInput(iEnt, "kill");

		iHealth[iEnt] = -1;
	}


	if(iType && iHealth[iEnt] > 0) switch(iType)
	{

		case 1:	CPrintToChat(iAttacker, "%t%t", "Tag", "PrintMessage", iHealth[iEnt]);

		case 2:	PrintCenterText(iAttacker, "%t%t", "Tag", "PrintMessage", iHealth[iEnt]);

		case 3:	PrintHintText(iAttacker, "%t%t", "Tag", "PrintMessage", iHealth[iEnt]);
	}

	return Plugin_Continue;
}

public Action Command_GetPropInfo(int iClient, int iArgs)
{
	int iEnt = GetClientAimTarget(iClient, false);
	if(iEnt > MaxClients && IsValidEntity(iEnt))
	{
		char sModelName[PLATFORM_MAX_PATH];
		GetEntPropString(iEnt, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
		CPrintToChat(iClient, "%t%t", "Tag", "PropInfo", sModelName, iHealth[iEnt], iEnt);
	}
	else PrintToChat(iClient, "%t%t", "Tag", "PropInvalid", iEnt);

	return Plugin_Handled;
}