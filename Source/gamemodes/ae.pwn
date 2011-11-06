/*

The 'odometer' code lags the gameplay MUCH. I recommend you to fix it.

~ Robin.

------------------------------------------------------------------------------
	Andreas Everything
	coded by:
	Steven82, Dowster, Famalamalam

	Thanks to Incognito - Streamer
	Thanks to Y_Less - sscanf, foreach
	Thanks to Slice - BUD(Blazing User Database)
	Thanks to G-sTyLeZzZ - MySQL Plugin
------------------------------------------------------------------------------*/
// MySQL Stuff (For people other than the coders) -- Uncomment to use
/*
#define mysql
#define DB_PASSWORD ""
#define DB_USERNAME ""
#define DATA_BASE ""
*/

// MySQL Stuff (For the coders) -- Again, Uncomment to use
/*
#if !defined mysql
#tryinclude <mysql_info>
#endif
*/

// The above code trys to include the database info for the coders)
#include <a_samp>
#define BUD_MAX_COLUMNS 50
#define BUD_USE_WHIRLPOOL false
#include <bud>
#include <zcmd>
#include <YSI/y_ini>
#include <sscanf2>
#include <arrays>
#include <streamer>
#include <foreach>
#include <a_mysql>
// Server/Script Defines
#define BETA_BUILD 1                    // Set to 1 to activate beta features.
#define DEBUG 0                         // Set to 1 to enable debugging in console
#define SCRIPT_MODE "AE v1.0"
#define SCRIPT_WEB "forum.sa-mp.com"
#define MAX_SKINS 300
#pragma tabsize 0
#define GetName GetPlayerNameEx // I am used to GetName in my GM, so I use this it's much easier
// Macros
#define INI_Exist(%0) fexist(%0)
#define DISTANCE(%1,%2,%3,%4,%5,%6) floatsqroot((%1-%4)*(%1-%4) + (%2-%5)*(%2-%5) + (%3-%6)*(%3-%6))
//Virtual World Defines
#define LOBBY_VW 0
#define DEATHMATCH_VW 5
#define FREEROAM_VW 10
#define CNR_VW 15
#define ADMIN_LOUNGE_VW 20
// Objects Include
#include <objects> //This is below the VW defines because it uses them to know which VWs objects go in
// Color Defines
#define COLOR_GRAD1 0xB4B5B7FF
#define COLOR_GRAD2 0xBFC0C2FF
#define COLOR_GRAD3 0xCBCCCEFF
#define COLOR_GRAD4 0xD8D8D8FF
#define COLOR_GRAD5 0xE3E3E3FF
#define COLOR_GRAD6 0xF0F0F0FF
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_LIGHTRED 0xFF6347AA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_YELLOW2 0xF5DEB3AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_MAGENTA 0xFF00FFFF
#define COLOR_FADE1 0xE6E6E6E6
#define COLOR_FADE2 0xC8C8C8C8
#define COLOR_FADE3 0xAAAAAAAA
#define COLOR_FADE4 0x8C8C8C8C
#define COLOR_FADE5 0x6E6E6E6E
#define COLOR_PURPLE 0xC2A2DAAA
#define COLOR_DBLUE 0x2641FEAA
#define COLOR_ALLDEPT 0xFF8282AA
#define COLOR_COMMAND_SYNTAX 0x33AA33AA
#define COLOR_BETA_MESSAGE 0xFF6600FF
// Dialog Defines
#define DIALOG_BLANK 100
#define DIALOG_REGISTER 101
#define DIALOG_LOGIN 102
#define DIALOG_HELP 103
#define DIALOG_MODE_SELECT 104
#define DIALOG_COMMANDS 105
#define DIALOG_COMMAND_DESCRIPTION 106
#define ADMIN_VEHICLE_MENU 107
#define ADD_VEHICLE_DIALOG 108
#define DELETE_VEHICLE_DIALOG 109
#define VEHICLE_COLOR_CHANGE_DIALOG 110
//Mode Defines
#define MAX_MODES 5
#define MODE_DEATHMATCH 0
#define MODE_FREE_ROAM 1
#define MODE_CNR 2
#define MODE_LOBBY 3
#define MODE_ADMIN_LOUNGE 4
//CnR Class Defines
#define CLASS_COP 0
#define CLASS_ROBBER 1
// Vehicle Defines
#define VEHICLE_RESPAWN_DELAY ((24)*(60)*(60)) // One Day, Real Time
// Variables
new
	LoggedIn[MAX_PLAYERS];
// Menu Variables
new
	Menu:CnRselect,
	Menu:CnRClassSelect;
// Enums
enum pData
{
    MODE,
	CLASS,
	SKIN,
	Adminlevel,
	Muted,
 	Money,
 	Score,
 	Float:Health,
 	Float:Armour
}
//Arrays
new
	PlayerData[MAX_PLAYERS][pData],
	IPADDRESSES[MAX_PLAYERS][18],
	Float:old_veh_pos[MAX_VEHICLES + 1][3],
	Float:vehicle_odometers[MAX_VEHICLES + 1];

new CnRSkins[2][5] =
{	{280, 281, 282, 283, 288},
	{122, 247, 254, 111, 124}
};

new MODES[MAX_MODES][2][17] =
{
	{"Deathmatch", 0},
	{"Free Roam", 0},
	{"Cops n' Robbers", 1},
	{"Lobby", 1},
	{"Admin Lounge", 1}
};
//============================================================================//
main()
{
	print("\n----------------------------------");
	print(" Andreas Everything ");
	print(" Script Lines: ~1000 ");
	print(" Coded by: SA-MP Community ");
	print("----------------------------------\n");
}

#if !defined mysql
public OnGameModeInit()
{
	SetGameModeText(SCRIPT_MODE);
	SendRconCommand(SCRIPT_WEB);
	DisableInteriorEnterExits();
	// SQLite
	BUD::Setting(opt.Database, "AE.db");
	BUD::Setting(opt.KeepAliveTime, 3000);
	BUD::Setting(opt.CheckForUpdates, true);
	BUD::Initialize();
	BUD::VerifyColumn("mode", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("adminlevel", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("muted", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("money", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("score", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("interior", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("virtualwolrd", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("health", BUD::TYPE_FLOAT);
	BUD::VerifyColumn("armour", BUD::TYPE_FLOAT);
	// Objects
	LobbyObjects();
	AdminAreaObjects();
	// Menus
	CnRselect = CreateMenu("Skin", 1, 200.0, 100.0, 100.0, 0.0);
	AddMenuItem(CnRselect, 0, "Next");
	AddMenuItem(CnRselect, 0, "Previous");
	AddMenuItem(CnRselect, 0, "Select");
	CnRClassSelect = CreateMenu("Class", 1, 200, 100.0, 100.0, 0.0);
	AddMenuItem(CnRClassSelect, 0, "Cops");
	AddMenuItem(CnRClassSelect, 0, "Robbers");
	return 1;
}
#endif

#if !defined mysql
public OnGameModeExit() 
{
    BUD::Exit();
	mysql_close();
    #if DEBUG == 1
    print("Executed OnGameModeExit");
    #endif
	return 1;
}
#endif
forward SkipClassSelection(playerid);
public SkipClassSelection(playerid)
{
	SpawnPlayer(playerid);
	SetPlayerPos(playerid, 0, 0, 0);
	TogglePlayerControllable(playerid, 0);
	SetPlayerCameraPos(playerid, 2358.5310,1028.9342,114.8779);
	SetPlayerCameraLookAt(playerid, 2281.2681,1069.3523,96.7904);
	
			new
				string[512],
				firstActiveMode;
			for(new i = 0; i < MAX_MODES; i++)
			{
				if(MODES[i][1][0] == 0) format(string, sizeof(string), "%s %s: {FF0000} Inactive\r\n", string, MODES[i][0]);
				else
				{
					new players = 0;
					foreach(Player, p)
					{
						if(PlayerData[p][MODE] == i) players++;
					}
					if(firstActiveMode == 0) format(string, sizeof(string), "%s %s: {00FF00} Active{FFFFFF} - Players: %i\r\n", string, MODES[i][0], players), firstActiveMode = 1;
					else format(string, sizeof(string), "%s %s: {00FF00} Active{FFFFFF} - Players: %i\r\n", string, MODES[i][0], players);
				}
			}
			
			format(string, sizeof(string), "%s Leave\r\n", string);
			ShowPlayerDialog(playerid, DIALOG_MODE_SELECT, DIALOG_STYLE_LIST, "Please select a mode to play", string, "Enter", "Refresh");
	
}
public OnPlayerRequestClass(playerid, classid)
{
    #if DEBUG == 1
    print("Executed OnPlayerRequestClass");
    #endif
	
	SetTimerEx("SkipClassSelection",1,0,"d",playerid);return 1;
}

#if !defined mysql
public OnPlayerConnect(playerid)
{
	// User Account System
	if(BUD::IsNameRegistered(GetPlayerNameEx(playerid)))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Welcome back to Andreas Everything!",
		"Please enter your desired password below, and click 'Login'.\nIf you wish to leave, click 'Leave'.", "Login", "Leave");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Welcome to Andreas Everything!",
		"Please enter your password below, and click 'Register'.\nIf you wish to leave, click 'Leave'.", "Register", "Leave");
	// Misc
	TogglePlayerClock(playerid, 0);
	SetPlayerScore(playerid, 0);
	GetPlayerIp(playerid, IPADDRESSES[playerid], 18);
	PlayerData[playerid][MODE] = 100;

	#if DEBUG == 1
    print("Executed OnPlayerConnect");
    #endif
	return 1;
}
#endif

#if !defined mysql
public OnPlayerDisconnect(playerid, reason)
{
	// User Account System
	SaveAccount(playerid);
	//Disconnect Log
	new hour, minute, second, month, year, day, name[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gettime(hour, minute, second);
	getdate(year, month, day);
	format(string, sizeof(string), "[%s %2i, %2i] - [%2i:%2i:%2i] User: %s disconnected from %s\r\n", Months[month], day, year, hour, minute, second, name, IPADDRESSES[playerid]);
	new File:disconnectlog = fopen( "Logs/Disconnects.txt", io_append);
	fwrite( disconnectlog, string);
	fclose(disconnectlog);

    #if DEBUG == 1
    print("Executed OnPlayerDisconnect");
    #endif
	return 1;
}
#endif

#if !defined mysql
public OnPlayerSpawn(playerid) 
{
	// User Account System
	if(LoggedIn[playerid] == 1) {}
	else
	{
	    if(BUD::IsNameRegistered(GetPlayerNameEx(playerid)))
    	{
        	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Welcome back to Andreas Everything!",
			"Please enter your desired password below, and click 'Login'.\nIf you wish to leave, click 'Leave'.", "Login", "Leave");
    	}
    	else
    	{
        	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Welcome to Andreas Everything!",
			"Please enter your password below, and click 'Register'.\nIf you wish to leave, click 'Leave'.", "Register", "Leave");
		}
	}
	// Misc

	#if DEBUG == 1
    print("Executed OnPlayerSpawn");
    #endif
	return 1;
}
#endif

public OnPlayerDeath(playerid, killerid, reason)
{
	new string[96], deadplayer[MAX_PLAYER_NAME], killer[MAX_PLAYER_NAME], hour, minute, second, year, month, day;
	gettime( hour, minute, second);
	getdate( year, month, day);
	GetPlayerName( playerid, deadplayer, sizeof(deadplayer));
	if (IsPlayerConnected(killerid))
	{
		GetPlayerName( killerid, killer, sizeof(killer));
		format(string, sizeof(string), "[%s %i, %i] - [%i:%i:%i] - %s killed %s, with a %s\r\n", Months[month], day, year, hour, minute, second, killer, deadplayer, DeathReason[reason]);
	}
	else
	{
		format(string, sizeof(string), "[%s %i, %i] - [%i:%i:%i] - %s has died from %s\r\n", Months[month], day, year, hour, minute, second, deadplayer, DeathReason[reason]);
	}
	new File:deathlog = fopen("Logs/Death Log.txt", io_append);
	fwrite(deathlog, string);
	fclose(deathlog);

	#if DEBUG == 1
    print("Executed OnPlayerDeath");
    #endif
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	GetVehiclePos(vehicleid, old_veh_pos[vehicleid][0], old_veh_pos[vehicleid][1], old_veh_pos[vehicleid][2]);
    #if DEBUG == 1
    print("Executed OnVehicleSpawn");
    #endif
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
    #if DEBUG == 1
    print("Executed OnVehicleDeath");
    #endif
	return 1;
}

public OnPlayerText(playerid, text[])
{
    #if DEBUG == 1
    print("Executed OnPlayerText"); // This could become spammy, we'll see..
    #endif
	return 1;
}

//============================================================================//
// ZCMD Commands
CMD:help(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "Andreas Everything - Help List",
	"Rules\nCommands\nServer Info", "Ok", "Close");
	return 1;
}
//Lobby Commands
CMD:modeselect(playerid) // Untested -dowster
{
	if(PlayerData[playerid][MODE] != MODE_LOBBY) return SendClientMessage(playerid, COLOR_RED, "This command only availible in lobby mode");
	new
		string[512];
	for(new i = 0; i < MAX_MODES; i++)
	{
		if(MODES[i][1][0] == 0) format(string, sizeof(string), "%s %s: {FF0000} Inactive\r\n", string, MODES[i][0]);
		else
		{
			new players = 0;
			foreach(Player, p)
			{
				if(PlayerData[p][MODE] == i) players++;
			}
			format(string, sizeof(string), "%s %s: {00FF00} Active{FFFFFF} - Players: %i\r\n", string, MODES[i][0], players);
		}
	}
	return 1;
}
new LobbyCommands[][2][40] = {
	{"/modeselect", "Shows the dialog to switch modes"}
};
// CnR Mini Mode Commands
CMD:cuff(playerid, params[])
{
	return 1;
}

CMD:uncuff(playerid, params[])
{
	return 1;
}

CMD:ticket(playerid, params[])
{
	return 1;
}

CMD:arrest(playerid, params[])
{
	return 1;
}
new CnRCommands[][2][40] = {
	{"/help", "Displays the help dialog"},
	{"/cuff", "Cop only command to cuff a player"},
	{"/uncuff", "Cop only command to uncuff a player"},
	{"/ticket", "Cop only command to ticket a player"},
	{"/arrest", "Cop only command to arrest a player"}
};
//Debug Commands
#if DEBUG == 1
CMD:vw(playerid)
{
	new vw = GetPlayerVirtualWorld(playerid), string[32];
	format(string, sizeof(string), "VW = %i", vw);
	SendClientMessage(playerid, COLOR_MAGENTA, string);
	return 1;
}
#endif
// Beta commands
#if BETA_BUILD == 1
CMD:bug(playerid, params[]) // Will eventually be able to view bugs through an in-game dialog... in theory XD
{
    new ID, string[128], Float:Angle, pInterior, name[128], pWorld, Float:X, Float:Y, Float:Z, vID, logged[4], query[512];
	if(!sscanf(params, "s[128]", name))
	{
	    new DB:bugdb = db_open("bugs.db");
		// Get some player stuff
		GetPlayerFacingAngle(playerid, Angle);
		GetPlayerPos(playerid, X, Y, Z);
		pInterior = GetPlayerInterior(playerid);
		pWorld = GetPlayerVirtualWorld(playerid);
		if(LoggedIn[playerid]) format(logged, sizeof(logged), "yes");
		else format(logged, sizeof(logged), "no");
		format(query, sizeof(query), "INSERT INTO bugs (description, posx, posy, posz, angle, interior, world, reporter, logged, vehicleid, modelid, modelname) VALUES ('%e', %f, %f, %f, %f, %i, %i, '%s', '%s', %i, %i, '%s')", name, X, Y, Z, Angle, pInterior, pWorld, GetPlayerNameEx(playerid), logged, GetPlayerVehicleID(playerid), GetVehicleModel(vID), GetVehicleName(vID));
		db_query(bugdb, query);
		format(string, sizeof(string), "*Thanks for reporting this issue, it will be reviewed shortly.", ID);
		SendClientMessage(playerid, COLOR_YELLOW, string);
		format(string, sizeof(string), "%s[%d] has reported a bug, please check it out.", GetPlayerNameEx(playerid), playerid, ID);
		MessageToAdminsEx( COLOR_WHITE, string); // Created in the admin stock area, currently at the bottom of the script
		db_close(bugdb);
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "USAGE: /bug [Short description]");
	}
	return 1;
}
#endif
// Admin Commands
CMD:mute(playerid, params[])
{
	new targetid, string[128];
    if(PlayerData[playerid][Adminlevel] <= 1) return SendClientMessage( playerid, COLOR_RED, "This is an admin only command!");
	else
	{
	    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_GRAD1, "SYNTAX: /mute [playerid]");
		else
		{
		    format(string, sizeof(string), "Adm: You have muted %s(%d).", GetPlayerNameEx(targetid), targetid);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Adm: You have been muted  by %s(%d).", GetPlayerNameEx(playerid), playerid);
			SendClientMessage(targetid, COLOR_YELLOW, string);
			PlayerData[targetid][Muted] = 1;
		}
	}
	return 1;
}
CMD:veh(playerid, params[]) //In-Progress - dowster
{
	if(PlayerData[playerid][Adminlevel] <= 1) return SendClientMessage( playerid, COLOR_RED, "This is an admin only command!");
	new vehid, string[9];
	if(!sscanf(params, "si", string, vehid) & (strcmp(string, "create", false, 6) == 0)) {
		new pint = GetPlayerInterior(playerid), pvw = GetPlayerVirtualWorld(playerid);
		new Float:ppx, Float:ppy, Float:ppz;
		GetPlayerPos( playerid, ppx, ppy, ppz);
		new veh = CreateVehicle( vehid, ppx+2, ppy+2, ppz+2, 0, -1, -1, VEHICLE_RESPAWN_DELAY);
		GetVehiclePos(veh, old_veh_pos[veh][0], old_veh_pos[veh][1], old_veh_pos[veh][2]);
		SetVehicleVirtualWorld(veh, pvw), LinkVehicleToInterior(veh, pint); }
	else if((strcmp(params, "create", false, 6) == 0)) SendClientMessage(playerid, COLOR_GRAD1, "Syntax: /veh [create] [Vehicle ID]");
	else if(strcmp(params, "menu", false, 4) == 0) {
		ShowPlayerDialog(playerid, ADMIN_VEHICLE_MENU, DIALOG_STYLE_LIST, "**Admin Vehicle Menu**", "Add Vehicle\r\nDelete Vehicle\r\nChange Vehicle Colors\r\nSave All Vehicles\r\nReload All Vehicles\r\nSave Vehicles In Current Mode\r\nReload Vehicles In Current Mode",  "Accept", "Cancel");
		SendClientMessage(playerid, COLOR_RED, "Menu not implemented yet"); }
	else return SendClientMessage( playerid, COLOR_GRAD1, "Syntax:  /veh [create/menu]");
	return 1;
}
CMD:unmute(playerid, params[])
{
    new targetid, string[128];
    if(PlayerData[playerid][Adminlevel] <= 1) return SendClientMessage( playerid, COLOR_RED, "This is an admin only command!");
	else
	{
	    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_GRAD1, "SYNTAX: /unmute [playerid]");
		else
		{
            format(string, sizeof(string), "Adm: You have unmuted %s(%d).", GetPlayerNameEx(targetid), targetid);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Adm: You have been unmuted  by %s(%d).", GetPlayerNameEx(playerid), playerid);
			SendClientMessage(targetid, COLOR_YELLOW, string);
			PlayerData[targetid][Muted] = 0;
		}
	}
	return 1;
}

CMD:kick(playerid, params[])
{
 	new targetid, reason[128], string[128];
    if(PlayerData[playerid][Adminlevel] <= 1) return SendClientMessage( playerid, COLOR_RED, "This is an admin only command!");
	else
    {
  		if(sscanf(params, "us[128]", targetid, reason)) return SendClientMessage(playerid, COLOR_GRAD1, "SYNTAX: /kick [playerid] [reason]");
		else
		{
			format(string, sizeof(string), "Adm: You have kicked %s(%d) from the server.", GetPlayerNameEx(targetid), targetid);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Reason: %s", reason);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Adm: You have been kicked from the server by %s(%d)", GetPlayerNameEx(playerid), playerid);
			SendClientMessage(targetid, COLOR_YELLOW, string);
            format(string, sizeof(string), "Reason: %s", reason);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			Kick(targetid);
		}
	}
	return 1;
}

CMD:ban(playerid, params[])
{
    new targetid, reason[128], string[128];
    if(PlayerData[playerid][Adminlevel] <= 1) return SendClientMessage( playerid, COLOR_RED, "This is an admin only command!");
	else
    {
		if(sscanf(params, "us", targetid, reason)) return SendClientMessage(playerid, COLOR_GRAD1, "SYNTAX: /ban [playerid] [reason]");
		else
		{
			format(string, sizeof(string), "Adm: You have banned %s(%d) from the server.", GetPlayerNameEx(targetid), targetid);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Reason: %s", reason);
			SendClientMessage(targetid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Adm: You have been banned from the server by %s(%d).", GetPlayerNameEx(playerid), playerid);
			SendClientMessage(targetid, COLOR_YELLOW, string);
			format(string, sizeof(string), "Reason: %s", reason);
			SendClientMessage(targetid, COLOR_YELLOW, string);
			Ban(targetid);
		}
	}
	return 1;
}
//============================================================================//
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    #if DEBUG == 1
    print("Executed OnPlayerEnterVehicle");
    #endif
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    #if DEBUG == 1
    print("Executed OnPlayerExitVehicle");
    #endif
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    #if DEBUG == 1
    print("Executed OnPlayerStateChange");
    #endif
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    #if DEBUG == 1
    print("Executed OnPlayerEnterCheckpoint");
    #endif
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
    #if DEBUG == 1
    print("Executed OnPlayerLeaveCheckpoint");
    #endif
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    #if DEBUG == 1
    print("Executed OnPlayerEnterRaceCheckpoint");
    #endif
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
    #if DEBUG == 1
    print("Executed OnPlayerLeaveRaceCheckpoint");
    #endif
	return 1;
}

public OnRconCommand(cmd[])
{
    #if DEBUG == 1
    print("Executed OnRconCommand");
    #endif
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    #if DEBUG == 1
    print("Executed OnPlayerRequestSpawn");
    #endif
	return 1;
}

public OnObjectMoved(objectid)
{
    #if DEBUG == 1
    print("Executed OnObjectMoved");
    #endif
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
    #if DEBUG == 1
    print("Executed OnPlayerObjectMoved");
    #endif
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) // Should maybe deprecate this, in favour of Incognitos plug-in(?)
//In response to above, do not delete this, since Incognito's doesn't stream pickups(?) and it might be neccecary later. - Robin
{
    #if DEBUG == 1
    print("Executed OnPlayerPickUpPickup");
    #endif
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
    #if DEBUG == 1
    print("Executed OnVehicleMod");
    #endif
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
    #if DEBUG == 1
    print("Executed OnVehiclePaintjob");
    #endif
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    #if DEBUG == 1
    print("Executed OnVehicleRespray");
    #endif
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
    new Menu:CurrentMenu = GetPlayerMenu(playerid);
	// CnR Class Selection
	if(CurrentMenu == CnRselect)
	{
		switch(row)
		{
			case 0: // Next
			{
				if(PlayerData[playerid][SKIN] == 4) // 4 is the last part of the array so we need to set their skin back to zero so they don't crash the game
				{
					PlayerData[playerid][SKIN] = 0;
				}
				else PlayerData[playerid][SKIN]++;
				SetPlayerSkin(playerid, CnRSkins[PlayerData[playerid][CLASS]][PlayerData[playerid][SKIN]]);
				ShowMenuForPlayer(CnRselect, playerid);
			}
			case 1: // Previous
			{
				if(PlayerData[playerid][SKIN] == 0) // 0 is the first part so we need to reset them at the end
				{
					PlayerData[playerid][SKIN] = 4;
				}
				else PlayerData[playerid][SKIN]--;
				SetPlayerSkin(playerid, CnRSkins[PlayerData[playerid][CLASS]][PlayerData[playerid][SKIN]]);
				ShowMenuForPlayer(CnRselect, playerid);
			}
			case 2: // Select
			{
				SendClientMessage(playerid, COLOR_YELLOW, "You have pressed select.");
				TogglePlayerControllable( playerid, 1);
				if(PlayerData[playerid][CLASS] == CLASS_COP) SetSpawnInfo( playerid, 0, CnRSkins[PlayerData[playerid][CLASS]][PlayerData[playerid][SKIN]],2339.9080,2456.2988,14.9688,179.5063,0,0,0,0,0,0);
				SpawnPlayer(playerid);
			}
		}
	}
	if(CurrentMenu == CnRClassSelect)
	{
		switch(row)
		{
			case 0: //Cop
			{
				ShowMenuForPlayer(CnRselect, playerid);
				PlayerData[playerid][CLASS] = CLASS_COP;
				SetPlayerSkin(playerid, CnRSkins[PlayerData[playerid][CLASS]][PlayerData[playerid][SKIN]]);
				SetPlayerPos(playerid, 1958.5851, 1343.0352, 15.3746);
				SetPlayerFacingAngle(playerid, 89.1425);
			}
			case 1: //Robber
			{
				ShowMenuForPlayer( CnRselect, playerid);
				PlayerData[playerid][CLASS] = CLASS_ROBBER;
				SetPlayerSkin(playerid, CnRSkins[PlayerData[playerid][CLASS]][PlayerData[playerid][SKIN]]);
				SetPlayerPos(playerid, 1958.5851, 1343.0352, 15.3746);
				SetPlayerFacingAngle(playerid, 89.1425);
			}
		}
	}

	#if DEBUG == 1
    print("Executed OnPlayerSelectedMenuRow");
    #endif
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
    #if DEBUG == 1
    print("Executed OnPlayerExitedMenu");
    #endif
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    #if DEBUG == 1
    print("Executed OnPlayerInteriorChange");
    #endif
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    #if DEBUG == 1
    print("Executed OnPlayerKeyStateChange");
    #endif
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
    #if DEBUG == 1
    print("Executed OnRconLoginAttempt");
    #endif
	return 1;
}

public OnPlayerUpdate(playerid)
{
	// I guess it's not a good idea to add a debug option here as it will be spammed every 30ms or something - Famalam
	// Correct @ above - Robin
	
	if(IsPlayerInAnyVehicle(playerid)) {
        if(GetPlayerVehicleSeat(playerid) == 0) {
			new vehid = GetPlayerVehicleID(playerid);
            vehicle_odometers[vehid] += GetPlayerDistanceFromPoint(playerid, old_veh_pos[vehid][0], old_veh_pos[vehid][1], old_veh_pos[vehid][2]);
			GetVehiclePos( vehid, old_veh_pos[vehid][0], old_veh_pos[vehid][1], old_veh_pos[vehid][2]);
        }
		#if BETA_BUILD == 1
		new string[32], vehid2 = GetPlayerVehicleID(playerid); format(string, sizeof(string), "Vehicle Odometer: %.1f", vehicle_odometers[vehid2]); SendClientMessage(playerid, COLOR_BETA_MESSAGE, string);
		#endif
    }
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
    #if DEBUG == 1
    print("Executed OnPlayerStreamIn");
    #endif
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
    #if DEBUG == 1
    print("Executed OnPlayerStreamOut");
    #endif
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
    #if DEBUG == 1
    print("Executed OnVehicleStreamIn");
    #endif
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
    #if DEBUG == 1
    print("Executed OnVehicleStreamOut");
    #endif
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	// User Account System
	if(dialogid == DIALOG_REGISTER)
	{
	    if(!response)
	        return SendClientMessage(playerid, COLOR_LIGHTRED, "Info: You have decided to leave the server, goodbye."), Kick(playerid);
		//
		BUD::RegisterName(GetPlayerNameEx(playerid), inputtext);
        new
			userid = BUD::GetNameUID(GetPlayerNameEx(playerid));
        BUD::MultiSet(userid, "iiiiiff",
        "mode", 0,
        "adminlevel", 0,
        "muted", 0,
        "money", 0,
        "score", 0,
        "health", 100.0,
        "armour", 0.0
    	);
    	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Welcome back to Andreas Everything!",
		"Please enter your desired password below, and click 'Login'.\nIf you wish to leave, click 'Leave'.", "Login", "Leave");

	}
	if(dialogid == DIALOG_LOGIN)
	{
	    if(!response)
	        return SendClientMessage(playerid, COLOR_LIGHTRED, "Info: You have decided to leave the server, goodbye."), Kick(playerid);
		//
		if(BUD::CheckAuth(GetPlayerNameEx(playerid), inputtext))
		{
		    LoginPlayer(playerid);
		}
		else
		    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Welcome back to Andreas Everything!",
			"Please enter your desired password below, and click 'Login'.\nIf you wish to leave, click 'Leave'.", "Login", "Leave");
  	}
  	// Help Dialog
  	if(dialogid == DIALOG_HELP)
  	{
  	    if(response)
  	    {
			switch(listitem)
			{
		    	case 0: // Rules
		    	{
		            ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything - Rules",
		            "Andreas Everything rules coming soon.", "Ok", "");
		    	}
		    	case 1: // Commands
		    	{
					switch (PlayerData[playerid][MODE])
					{
						case MODE_CNR:
						{
							new string[455];
							for(new i = 0; i < sizeof(CnRCommands); i++)
							{
								format(string, sizeof(string), "%s %s\r\n", string, CnRCommands[i][0]);
							}
							ShowPlayerDialog(playerid, DIALOG_COMMANDS, DIALOG_STYLE_LIST, "Andreas Everything",
							string, "Ok", "Cancel");
							TogglePlayerControllable(playerid, 1);
							SetCameraBehindPlayer(playerid);
						}
						case MODE_DEATHMATCH:
						{
							ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything",
							"Deathmatch mode coming soon", "Ok", "");
							TogglePlayerControllable(playerid, 1);
							SetCameraBehindPlayer(playerid);
						}
						case MODE_FREE_ROAM:
						{
							ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything",
							"Free Roam coming soon", "Ok", "");
							TogglePlayerControllable(playerid, 1);
							SetCameraBehindPlayer(playerid);
						}
						case MODE_LOBBY:
						{
							new string[455];
							for(new i = 0; i < sizeof(LobbyCommands); i++)
							{
								format(string, sizeof(string), "%s %s\r\n", string, LobbyCommands[i][0]);
							}
							ShowPlayerDialog(playerid, DIALOG_COMMANDS, DIALOG_STYLE_LIST, "Andreas Everything",
							string, "Ok", "Cancel");
							TogglePlayerControllable(playerid, 1);
							SetCameraBehindPlayer(playerid);
						}
					}
		    	}
				case 2: // Server Info
				{
				    ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything - Server Info",
		            "Andreas Everything rules coming soon.", "Ok", "");
				}
			}
		}
	}
	//Commands Help Dialog
	if(dialogid == DIALOG_COMMANDS)
	{
		if(!response) return 1;
		else
		{
			switch (PlayerData[playerid][MODE])
			{
				case MODE_CNR:
				{
					ShowPlayerDialog(playerid, DIALOG_COMMAND_DESCRIPTION, DIALOG_STYLE_MSGBOX, CnRCommands[listitem][0],
					CnRCommands[listitem][1], "Ok", "");
				}
				case MODE_DEATHMATCH:
				{
					ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything",
					"Deathmatch mode coming soon", "Ok", "");
				}
				case MODE_FREE_ROAM:
				{
					ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything",
					"Free Roam coming soon", "Ok", "");
				}
				case MODE_LOBBY:
				{
					ShowPlayerDialog(playerid, DIALOG_COMMAND_DESCRIPTION, DIALOG_STYLE_MSGBOX, LobbyCommands[listitem][0],
					LobbyCommands[listitem][1], "Ok", "");
				}
			}
		}
	}
	//Mode Selection Dialog
	if(dialogid == DIALOG_MODE_SELECT)
	{
		if(!response)
		{
			new
				string[512];
			for(new i = 0; i < MAX_MODES; i++)
			{
				if(MODES[i][1][0] == 0) format(string, sizeof(string), "%s %s: {FF0000} Inactive\r\n", string, MODES[i][0]);
				else
				{
					new players = 0;
					foreach(Player, p)
					{
						if(PlayerData[p][MODE] == i) players++;
					}
					format(string, sizeof(string), "%s %s: {00FF00} Active{FFFFFF} - Players: %i\r\n", string, MODES[i][0], players);
				}
			}
			format(string, sizeof(string), "%s Leave\r\n", string);
			ShowPlayerDialog(playerid, DIALOG_MODE_SELECT, DIALOG_STYLE_LIST, "Please select a mode to play", string, "Enter", "Refresh");
		}
		else
		{
			switch(listitem)
			{
				case MODE_DEATHMATCH: //Deathmatch
				{
					DeathMatch(playerid);
				}
				case MODE_FREE_ROAM: //Free Roam
				{
					FreeRoam(playerid);
				}
				case MODE_CNR: //CNR
				{
					CNR(playerid);
				}
				case MODE_LOBBY:
				{
					Lobby(playerid);
				}
				case MODE_ADMIN_LOUNGE:
				{
					ALounge(playerid);
				}
				case MAX_MODES:
				{
					SendClientMessage(playerid, COLOR_RED, "Goodbye");
					Kick(playerid);
				}
			}
		}
	}
	if(dialogid == ADMIN_VEHICLE_MENU) {
		switch(listitem) {
			case 0: return ShowPlayerDialog( playerid, ADD_VEHICLE_DIALOG, DIALOG_STYLE_INPUT, "**Add A Vehicle**", "Enter the vehicle model to create", "Create", "Cancel");
			case 1: return ShowPlayerDialog( playerid, DELETE_VEHICLE_DIALOG, DIALOG_STYLE_INPUT, "**Delete A Vehicle**", "Enter the vehicle ID to delete", "Delete", "Cancel");
			case 2: return ShowPlayerDialog( playerid, VEHICLE_COLOR_CHANGE_DIALOG, DIALOG_STYLE_INPUT, "**Change A Vehicle's Color**", "Enter the desired vehicle ID followed by the color codes\r\nExample: 4, 3, 3", "Apply", "Cancel");
			case 3: return SaveVehicles(playerid, MAX_MODES);
			case 4: return ReloadVehicles(playerid, MAX_MODES);
			case 5: return SaveVehicles(playerid, PlayerData[playerid][MODE]);
			case 6: return ReloadVehicles(playerid, PlayerData[playerid][MODE]); }}
	if(dialogid == ADD_VEHICLE_DIALOG) {
		new vehid;
		if(sscanf(inputtext, "i", vehid)) return ShowPlayerDialog( playerid, ADD_VEHICLE_DIALOG, DIALOG_STYLE_INPUT, "**Add A Vehicle**", "Enter the vehicle {FF0000}model{FFFFFF} to create", "Create", "Cancel");
		else {
			new pint = GetPlayerInterior(playerid), pvw = GetPlayerVirtualWorld(playerid);
			new Float:ppx, Float:ppy, Float:ppz;
			GetPlayerPos( playerid, ppx, ppy, ppz);
			new veh = CreateVehicle( vehid, ppx+2, ppy+2, ppz+2, 0, -1, -1, VEHICLE_RESPAWN_DELAY);
			GetVehiclePos(veh, old_veh_pos[veh][0], old_veh_pos[veh][1], old_veh_pos[veh][2]);
			SetVehicleVirtualWorld(veh, pvw), LinkVehicleToInterior(veh, pint); }}
	if(dialogid == DELETE_VEHICLE_DIALOG) {
		new vehid;
		if(sscanf(inputtext, "i", vehid)) return ShowPlayerDialog( playerid, ADD_VEHICLE_DIALOG, DIALOG_STYLE_INPUT, "**Add A Vehicle**", "Enter the vehicle {FF0000}ID{FFFFFF} to delete", "Delete", "Cancel");
		else if(GetVehicleModel(vehid) == 0) return ShowPlayerDialog( playerid, ADD_VEHICLE_DIALOG, DIALOG_STYLE_INPUT, "**Add A Vehicle**", "{FF0000}VEHICLE DOES NOT EXIST!{FFFFFF}\r\nEnter the vehicle {FF0000}ID{FFFFFF} to delete", "Delete", "Cancel");
		else if(GetVehicleVirtualWorld(vehid) != GetPlayerVirtualWorld(playerid)) return ShowPlayerDialog( playerid, ADD_VEHICLE_DIALOG, DIALOG_STYLE_INPUT, "**Add A Vehicle**", "{FF0000}YOU ARE NOT IN THE SAME VIRTUAL WORLD AS THIS VEHICLE!{FFFFFF}\r\nEnter the vehicle {FF0000}ID{FFFFFF} to delete", "Delete", "Cancel");
		else return DestroyVehicle(vehid); }
	if(dialogid == VEHICLE_COLOR_CHANGE_DIALOG) {
		new vehid, col1, col2;
		if(sscanf(inputtext, "p<,>iii", vehid, col1, col2)) return ShowPlayerDialog( playerid, VEHICLE_COLOR_CHANGE_DIALOG, DIALOG_STYLE_INPUT, "**Change A Vehicle's Color**", "Enter the desired vehicle ID followed by the color codes\r\n{FF0000}Example: 4, 3, 3", "Apply", "Cancel");
		else if(GetVehicleModel(vehid) == 0) return ShowPlayerDialog( playerid, VEHICLE_COLOR_CHANGE_DIALOG, DIALOG_STYLE_INPUT, "**Change A Vehicle's Color**", "{FF0000}VEHICLE DOES NOT EXIST!{FFFFFF}\r\nEnter the desired vehicle ID followed by the color codes\r\nExample: 4, 3, 3", "Apply", "Cancel");
		else if(GetVehicleVirtualWorld(vehid) != GetPlayerVirtualWorld(playerid)) return ShowPlayerDialog( playerid, VEHICLE_COLOR_CHANGE_DIALOG, DIALOG_STYLE_INPUT, "**Change A Vehicle's Color**", "{FF0000}YOU ARE NOT IN THE SAME VIRTUAL WORLD AS THIS VEHICLE!{FFFFFF}\r\nEnter the desired vehicle ID followed by the color codes\r\nExample: 4, 3, 3", "Apply", "Cancel");
		else return ChangeVehicleColor(vehid, col1, col2); }
	#if DEBUG == 1
    print("Executed OnDialogResponse");
    #endif
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    #if DEBUG == 1
    print("Executed OnPlayerClickPlayer");
    #endif
	return 1;
}
//============================================================================//
//forwards
forward SaveAccount(playerid);
public SaveAccount(playerid)
{
    new Float:health, Float:armour, userid;
    GetPlayerHealth(playerid, health);
    GetPlayerArmour(playerid, armour);
    userid = BUD::GetNameUID(GetPlayerNameEx(playerid));
    //
    BUD::SetIntEntry(userid, "mode", PlayerData[playerid][MODE]);
    BUD::SetIntEntry(userid, "adminlevel", PlayerData[playerid][Adminlevel]);
	BUD::SetIntEntry(userid, "muted", PlayerData[playerid][Muted]);
	BUD::SetIntEntry(userid, "money", GetPlayerMoney(playerid));
	BUD::SetIntEntry(userid, "score", GetPlayerScore(playerid));
	BUD::SetFloatEntry(userid, "health", health);
	BUD::SetFloatEntry(userid, "armour", armour);

	#if DEBUG == 1
    print("Executed SaveAccount");
    #endif
	return 1;
}
stock LoginPlayer(playerid)
{
	new userid;
	userid = BUD::GetNameUID(GetPlayerNameEx(playerid));
	PlayerData[playerid][MODE] = BUD::GetIntEntry(userid, "mode");
	PlayerData[playerid][Adminlevel] = BUD::GetIntEntry(userid, "adminlevel");
	PlayerData[playerid][Muted] = BUD::GetIntEntry(userid, "muted");
	PlayerData[playerid][Money] = BUD::GetIntEntry(userid, "money");
	PlayerData[playerid][Score] = BUD::GetIntEntry(userid, "score");
	PlayerData[playerid][Health] = BUD::GetFloatEntry(userid, "health");
	PlayerData[playerid][Armour] = BUD::GetFloatEntry(userid, "armour");
	LoggedIn[playerid] = 1;
	return 1;
}
// stocks
stock GetVehicleName(vehicleid)
{
	new vn[50];
	if(GetVehicleModel(vehicleid) == 0) format(vn, sizeof(vn), "Invalid VehicleID");
	else format(vn,sizeof(vn),"%s",VehicleNames[GetVehicleModel(vehicleid)-400]);
	return vn;
}

stock GetPlayerNameEx(playerid)
{
	new pName[MAX_PLAYER_NAME];
	if(IsPlayerConnected(playerid))
	{
	    GetPlayerName(playerid, pName, sizeof(pName));
	}
	else pName = "Unknown";
	return pName;
}

stock IsCopSkin(playerid)
{
	new skinid = GetPlayerSkin(playerid);
	switch(skinid)
	{
		case 0: return false;
	}
	return skind;
}
// Mode Stocks
stock CNR(playerid)
{
	SetPlayerVirtualWorld(playerid, CNR_VW);
	TogglePlayerControllable(playerid, 0);
	SpawnPlayer(playerid);
    ShowMenuForPlayer(CnRClassSelect, playerid);
	PlayerData[playerid][MODE] = MODE_CNR;

	#if DEBUG == 1
    print("Executed CNR()");
    #endif
	return 1;
}

stock DeathMatch(playerid)
{
	TogglePlayerControllable(playerid, 1);
	SetCameraBehindPlayer(playerid);
    #if DEBUG == 1
    print("Executed DeathMatch()");
    #endif
	return 1;
}

stock FreeRoam(playerid)
{
	TogglePlayerControllable(playerid, 1);
	SetCameraBehindPlayer(playerid);
	#if DEBUG == 1
    print("Executed FreeRoam()");
    #endif
	return 1;
}
stock Lobby(playerid)
{
	TogglePlayerControllable(playerid, 1);
	SetCameraBehindPlayer(playerid);
	SetPlayerVirtualWorld( playerid, LOBBY_VW);
	SetPlayerInterior( playerid, 18);
	SetPlayerPos( playerid, 1727.328125, -1639.4775390625, 20.223743438721);
	PlayerData[playerid][MODE] = MODE_LOBBY;
	#if DEBUG == 1
    print("Executed Lobby()");
    #endif
	return 1;
}
stock ALounge(playerid)
{
	TogglePlayerControllable(playerid, 1);
	SetCameraBehindPlayer(playerid);
	SetPlayerPos( playerid, -2157.6730957031, 642.63775634766, 1052.375);
	SetPlayerInterior(playerid, 1);
	SetPlayerVirtualWorld(playerid, ADMIN_LOUNGE_VW);
	PlayerData[playerid][MODE] = MODE_ADMIN_LOUNGE;
	ObjectFreeze(playerid);
	#if DEBUG == 1
	print("Executed ALounge()");
	#endif
	return 1;
}
stock ObjectFreeze(playerid) //When teleporting a player to a place with custom objects, insert this line so the player has time to load the objects and does not fall
{
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("UnFreeze", 2000, false, "i", playerid);
	GameTextForPlayer(playerid, "~r~Objects Loading", 2000, 4);
	#if DEBUG == 1
	print("Executed ObjectFreeze()");
	#endif
	return 1;
}
forward UnFreeze(playerid);
public UnFreeze(playerid)
{
	TogglePlayerControllable(playerid, 1);
	#if DEBUG == 1
	print("Executed UnFreeze()");
	#endif
	return 1;
}
// Admin Related Stocks
stock MessageToAdminsEx( color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(PlayerData[i][Adminlevel] > 0) SendClientMessage( i, color, string);
	}
	return 1;
}
stock SaveVehicles(playerid, mode)
{
	#pragma unused playerid
	#pragma unused mode
	return 1;
}
stock ReloadVehicles(playerid, mode)
{
	#pragma unused playerid
	#pragma unused mode
	return 1;
}