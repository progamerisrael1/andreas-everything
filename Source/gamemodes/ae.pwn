/*------------------------------------------------------------------------------
	Andreas Everything
	coded by:
	Steven82, *add credits here*
	
	Thanks to Incognito - Streamer
	Thanks to Y_Less - sscanf
	Thanks to Splice - BUD(Blazing User Database)
------------------------------------------------------------------------------*/
#include <a_samp>
#define BUD_MAX_COLUMNS 50
#define BUD_USE_WHIRLPOOL false
#include <bud>
#include <zcmd>
#include <sscanf2>
// Server/Script Defines
#define SCRIPT_MODE "AE v1.0"
#define SCRIPT_WEB "forum.sa-mp.com"
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
// Dialog Defines
#define DIALOG_BLANK 100
#define DIALOG_REGISTER 101
#define DIALOG_LOGIN 102
#define DIALOG_HELP 103
// Variables
new
	LoggedIn[MAX_PLAYERS];
// Enums
enum pData
{
	Adminlevel,
	Muted,
 	Money,
 	Score,
 	Float:Health,
 	Float:Armour
}
new
	PlayerData[MAX_PLAYERS][pData];
//============================================================================//
main()
{
	print("\n----------------------------------");
	print(" Andreas Everything ");
	print(" Script Lines: 393 ");
	print(" Coded by: SA-MP Community ");
	print("----------------------------------\n");
}

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
	BUD::VerifyColumn("adminlevel", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("muted", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("money", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("score", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("interior", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("virtualwolrd", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("health", BUD::TYPE_FLOAT);
	BUD::VerifyColumn("armour", BUD::TYPE_FLOAT);
	// Player Class
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
    BUD::Exit();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

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
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	// User Account System
	SaveAccount(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	// User Account System
	if(LoggedIn[playerid] == 1)
	{

	}
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
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
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
//============================================================================//
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
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
        BUD::MultiSet(userid, "iiiiff",
        "adminlevel", 0,
        "muted", 0,
        "money", 0,
        "score", 0,
        "health", 100.0,
        "armour", 0.0
    	);
	}
	if(dialogid == DIALOG_LOGIN)
	{
	    new
			userid = BUD::GetNameUID(GetPlayerNameEx(playerid));
	    if(!response)
	        return SendClientMessage(playerid, COLOR_LIGHTRED, "Info: You have decided to leave the server, goodbye."), Kick(playerid);
		//
		if(BUD::CheckAuth(GetPlayerNameEx(playerid), inputtext))
		{
			PlayerData[playerid][Adminlevel] = BUD::GetIntEntry(userid, "adminlevel");
			PlayerData[playerid][Muted] = BUD::GetIntEntry(userid, "muted");
			PlayerData[playerid][Money] = BUD::GetIntEntry(userid, "money");
			PlayerData[playerid][Score] = BUD::GetIntEntry(userid, "score");
			PlayerData[playerid][Health] = BUD::GetFloatEntry(userid, "health");
			PlayerData[playerid][Armour] = BUD::GetFloatEntry(userid, "armour");
			LoggedIn[playerid] = 1;
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
		            "Andreas Everything rules comming soon.", "Ok", "");
		    	}
		    	case 1: // Commands
		    	{
		    	    ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything - Commands",
		            "Andreas Everything rules comming soon.", "Ok", "");
		    	}
				case 2: // Server Info
				{
				    ShowPlayerDialog(playerid, DIALOG_BLANK, DIALOG_STYLE_MSGBOX, "Andreas Everything - Server Info",
		            "Andreas Everything rules comming soon.", "Ok", "");
				}
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
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
    BUD::SetIntEntry(userid, "adminlevel", PlayerData[playerid][Adminlevel]);
	BUD::SetIntEntry(userid, "muted", PlayerData[playerid][Muted]);
	BUD::SetIntEntry(userid, "money", GetPlayerMoney(playerid));
	BUD::SetIntEntry(userid, "score", GetPlayerScore(playerid));
	BUD::SetFloatEntry(userid, "health", health);
	BUD::SetFloatEntry(userid, "armour", armour);
	return 1;
}
// stocks
stock GetPlayerNameEx(playerid)
{
	new pName[MAX_PLAYER_NAME];
	if(IsPlayerConnected(playerid))
	{
	    GetPlayerName(playerid, pName, sizeof(pName));
	}
	else pName = "Unknow";
	return pName;
}
