/*----------------------------------------------------------------------------*\
					==============================
					 y_als - Useful codes for ALS
					==============================
Description:
	Provides a number of macros for making ALS (Advanced Library System)
	callback hooking simpler.
Legal:
	Version: MPL 1.1
	
	The contents of this file are subject to the Mozilla Public License Version 
	1.1 (the "License"); you may not use this file except in compliance with 
	the License. You may obtain a copy of the License at 
	http://www.mozilla.org/MPL/
	
	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.
	
	The Original Code is the YSI ALS include.
	
	The Initial Developer of the Original Code is Alex "Y_Less" Cole.
	Portions created by the Initial Developer are Copyright (C) 2011
	the Initial Developer. All Rights Reserved.
	
	Contributors:
		ZeeX, koolk, JoeBullet/Google63, g_aSlice/Slice
	
	Thanks:
		JoeBullet/Google63 - Handy arbitrary ASM jump code using SCTRL.
		ZeeX - Very productive conversations.
		koolk - IsPlayerinAreaEx code.
		TheAlpha - Danish translation.
		breadfish - German translation.
		Fireburn - Dutch translation.
		yom - French translation.
		50p - Polish translation.
		Zamaroht - Spanish translation.
		Dracoblue, sintax, mabako, Xtreme, other coders - Producing other modes
			for me to strive to better.
		Pixels^ - Running XScripters where the idea was born.
		Matite - Pestering me to release it and using it.
	
	Very special thanks to:
		Thiadmer - PAWN, whose limits continue to amaze me!
		Kye/Kalcor - SA:MP.
		SA:MP Team past, present and future - SA:MP.
	
Version:
	1.0
Changelog:
	29/04/11:
		Added "call" macro to make testing easier.
	21/10/10:
		First version
\*----------------------------------------------------------------------------*/

#include <YSI\internal\y_version>
#include <YSI\y_amx>

// Allow multiple inclusions.
#undef _inc_y_als

#if !defined _Y_ALS_INCLUDED
	// This is an include guard with a purpose - we need more control than the
	// standard include guards give.
	#define _Y_ALS_INCLUDED
	
	#include <YSI\y_bit>
	#include <YSI\internal\y_shortfunc>
	
	enum ALS
	{
		//Bit:ALS_OnAnyScriptInit,
		//Bit:ALS_OnAnyScriptExit,
		Bit:ALS_OnScriptInit,
		Bit:ALS_OnScriptExit,
		Bit:ALS_OnGameModeInit,
		Bit:ALS_OnGameModeExit,
		Bit:ALS_OnFilterScriptInit,
		Bit:ALS_OnFilterScriptExit,
		Bit:ALS_OnPlayerConnect,
		Bit:ALS_OnPlayerDisconnect,
		Bit:ALS_OnPlayerSpawn,
		Bit:ALS_OnPlayerDeath,
		Bit:ALS_OnVehicleSpawn,
		Bit:ALS_OnVehicleDeath,
		Bit:ALS_OnPlayerText,
		Bit:ALS_OnPlayerCommandText,
		Bit:ALS_OnPlayerRequestClass,
		Bit:ALS_OnPlayerEnterVehicle,
		Bit:ALS_OnPlayerExitVehicle,
		Bit:ALS_OnPlayerStateChange,
		Bit:ALS_OnPlayerEnterCheckpoint,
		Bit:ALS_OnPlayerLeaveCheckpoint,
		Bit:ALS_OnPlayerEnterRaceCheckpoint,
		Bit:ALS_OnPlayerLeaveRaceCheckpoint,
		Bit:ALS_OnRconCommand,
		Bit:ALS_OnPlayerRequestSpawn,
		Bit:ALS_OnObjectMoved,
		Bit:ALS_OnPlayerObjectMoved,
		Bit:ALS_OnPlayerPickUpPickup,
		Bit:ALS_OnVehicleMod,
		Bit:ALS_OnEnterExitModShop,
		Bit:ALS_OnVehiclePaintjob,
		Bit:ALS_OnVehicleRespray,
		Bit:ALS_OnVehicleDamageStatusUpdate,
		Bit:ALS_OnPlayerSelectedMenuRow,
		Bit:ALS_OnPlayerExitedMenu,
		Bit:ALS_OnPlayerInteriorChange,
		Bit:ALS_OnPlayerKeyStateChange,
		Bit:ALS_OnRconLoginAttempt,
		Bit:ALS_OnPlayerUpdate,
		Bit:ALS_OnPlayerStreamIn,
		Bit:ALS_OnPlayerStreamOut,
		Bit:ALS_OnVehicleStreamIn,
		Bit:ALS_OnVehicleStreamOut,
		Bit:ALS_OnDialogResponse,
		Bit:ALS_OnPlayerClickPlayer,
		Bit:ALS_OnPlayerLogin,
		Bit:ALS_OnPlayerLogout
	}
	
	#define ALS_DATA<> static stock BitArray:gs_ALS<_:ALS>;
	
	#define ALS_DETECT<%0> if(funcidx(#ALS_PREFIX"_On"#%0)!=-1)Bit_Let(gs_ALS,_:ALS_On%0);
	
	//#define ALS_DETECT_SHORT<On%0> if(funcidx(#ALS_PREFIX"_"#%0)!=-1)Bit_Let(gs_ALS,_:ALS_On%0);
	
	//#define ALS_CALL_INT<%0,%2>(%3) return Bit_GetBit(Bit:gs_ALS,_:ALS_On%0)?P@(#ALS_PREFIX"_On"#%0,#%2#x,%3):1;
	
	// ALS Callback.
	#define ALS_C_INT<%0,%1,%2>(%3) return Bit_GetBit(Bit:gs_ALS,_:ALS_On%0)?P@(#ALS_PREFIX"_On"#%0,#%2#x,%3):%1;
	// ALS Forward.
	#define ALS_F_INT<%0>(%1) forward On%0(%1);
	// ALS Go.
	#define ALS_G_INT<%0,%1>(%2) W@(#On#%0,#%1#x,%2)
	
	// Forward declarations.
	//#define ALS_F_AnyScriptInit             ALS_F_INT<AnyScriptInit            >()
	//#define ALS_F_AnyScriptExit             ALS_F_INT<AnyScriptExit            >()
	#define ALS_F_ScriptInit                ALS_F_INT<ScriptExit               >()
	#define ALS_F_ScriptExit                ALS_F_INT<ScriptExit               >()
	#define ALS_F_GameModeInit              ALS_F_INT<GameModeInit             >()
	#define ALS_F_GameModeExit              ALS_F_INT<GameModeExit             >()
	#define ALS_F_FilterScriptInit          ALS_F_INT<FilterScriptInit         >()
	#define ALS_F_FilterScriptExit          ALS_F_INT<FilterScriptExit         >()
	#define ALS_F_PlayerConnect             ALS_F_INT<PlayerConnect            >(playerid)
	#define ALS_F_PlayerDisconnect          ALS_F_INT<PlayerDisconnect         >(playerid,reason)
	#define ALS_F_PlayerSpawn               ALS_F_INT<PlayerSpawn              >(playerid)
	#define ALS_F_PlayerDeath               ALS_F_INT<PlayerDeath              >(playerid,killerid,reason)
	#define ALS_F_VehicleSpawn              ALS_F_INT<VehicleSpawn             >(vehicleid)
	#define ALS_F_VehicleDeath              ALS_F_INT<VehicleDeath             >(vehicleid,killerid)
	#define ALS_F_PlayerText                ALS_F_INT<PlayerText               >(playerid,text[])
	#define ALS_F_PlayerCommandText         ALS_F_INT<PlayerCommandText        >(playerid,cmdtext[])
	#define ALS_F_PlayerRequestClass        ALS_F_INT<PlayerRequestClass       >(playerid,classid)
	#define ALS_F_PlayerEnterVehicle        ALS_F_INT<PlayerEnterVehicle       >(playerid,vehicleid,ispassenger)
	#define ALS_F_PlayerExitVehicle         ALS_F_INT<PlayerExitVehicle        >(playerid,vehicleid)
	#define ALS_F_PlayerStateChange         ALS_F_INT<PlayerStateChange        >(playerid,newstate,oldstate)
	#define ALS_F_PlayerEnterCheckpoint     ALS_F_INT<PlayerEnterCheckpoint    >(playerid)
	#define ALS_F_PlayerLeaveCheckpoint     ALS_F_INT<PlayerLeaveCheckpoint    >(playerid)
	#define ALS_F_PlayerEnterRaceCheckpoint ALS_F_INT<PlayerEnterRaceCheckpoint>(playerid)
	#define ALS_F_PlayerLeaveRaceCheckpoint ALS_F_INT<PlayerLeaveRaceCheckpoint>(playerid)
	#define ALS_F_RconCommand               ALS_F_INT<RconCommand              >(cmd[])
	#define ALS_F_PlayerRequestSpawn        ALS_F_INT<PlayerRequestSpawn       >(playerid)
	#define ALS_F_ObjectMoved               ALS_F_INT<ObjectMoved              >(objectid)
	#define ALS_F_PlayerObjectMoved         ALS_F_INT<PlayerObjectMoved        >(playerid,objectid)
	#define ALS_F_PlayerPickUpPickup        ALS_F_INT<PlayerPickUpPickup       >(playerid,pickupid)
	#define ALS_F_VehicleMod                ALS_F_INT<VehicleMod               >(playerid,vehicleid,componentid)
	#define ALS_F_EnterExitModShop          ALS_F_INT<EnterExitModShop         >(playerid,enterexit,interiorid)
	#define ALS_F_VehiclePaintjob           ALS_F_INT<VehiclePaintjob          >(playerid,vehicleid,paintjobid)
	#define ALS_F_VehicleRespray            ALS_F_INT<VehicleRespray           >(playerid,vehicleid,color1,color2)
	#define ALS_F_VehicleDamageStatusUpdate ALS_F_INT<VehicleDamageStatusUpdate>(playerid,vehicleid)
	#define ALS_F_PlayerSelectedMenuRow     ALS_F_INT<PlayerSelectedMenuRow    >(playerid,row)
	#define ALS_F_PlayerExitedMenu          ALS_F_INT<PlayerExitedMenu         >(playerid)
	#define ALS_F_PlayerInteriorChange      ALS_F_INT<PlayerInteriorChange     >(playerid,newinteriorid,oldinteriorid)
	#define ALS_F_PlayerKeyStateChange      ALS_F_INT<PlayerKeyStateChange     >(playerid,newkeys,oldkeys)
	#define ALS_F_RconLoginAttempt          ALS_F_INT<RconLoginAttempt         >(ip[],password[],success)
	#define ALS_F_PlayerUpdate              ALS_F_INT<PlayerUpdate             >(playerid)
	#define ALS_F_PlayerStreamIn            ALS_F_INT<PlayerStreamIn           >(playerid,forplayerid)
	#define ALS_F_PlayerStreamOut           ALS_F_INT<PlayerStreamOut          >(playerid,forplayerid)
	#define ALS_F_VehicleStreamIn           ALS_F_INT<VehicleStreamIn          >(vehicleid,forplayerid)
	#define ALS_F_VehicleStreamOut          ALS_F_INT<VehicleStreamOut         >(vehicleid,forplayerid)
	#define ALS_F_DialogResponse            ALS_F_INT<DialogResponse           >(playerid,dialogid,response,listitem,inputtext[])
	#define ALS_F_PlayerClickPlayer         ALS_F_INT<PlayerClickPlayer        >(playerid,clickedplayerid,source)
	#define ALS_F_PlayerLogin               ALS_F_INT<PlayerLogin              >(playerid,uid)
	#define ALS_F_PlayerLogout              ALS_F_INT<PlayerLogout             >(playerid,uid)
	
	// Default return value definitions.
	//#define ALS_R_AnyScriptInit             1
	//#define ALS_R_AnyScriptExit             1
	#define ALS_R_ScriptInit                1
	#define ALS_R_ScriptExit                1
	#define ALS_R_GameModeInit              1
	#define ALS_R_GameModeExit              1
	#define ALS_R_FilterScriptInit          1
	#define ALS_R_FilterScriptExit          1
	#define ALS_R_PlayerConnect             1
	#define ALS_R_PlayerDisconnect          1
	#define ALS_R_PlayerSpawn               1
	#define ALS_R_PlayerDeath               1
	#define ALS_R_VehicleSpawn              1
	#define ALS_R_VehicleDeath              1
	#define ALS_R_PlayerText                1
	#define ALS_R_PlayerCommandText         0
	#define ALS_R_PlayerRequestClass        1
	#define ALS_R_PlayerEnterVehicle        1
	#define ALS_R_PlayerExitVehicle         1
	#define ALS_R_PlayerStateChange         1
	#define ALS_R_PlayerEnterCheckpoint     1
	#define ALS_R_PlayerLeaveCheckpoint     1
	#define ALS_R_PlayerEnterRaceCheckpoint 1
	#define ALS_R_PlayerLeaveRaceCheckpoint 1
	#define ALS_R_RconCommand               1
	#define ALS_R_PlayerRequestSpawn        1
	#define ALS_R_ObjectMoved               1
	#define ALS_R_PlayerObjectMoved         1
	#define ALS_R_PlayerPickUpPickup        1
	#define ALS_R_VehicleMod                1
	#define ALS_R_EnterExitModShop          1
	#define ALS_R_VehiclePaintjob           1
	#define ALS_R_VehicleRespray            1
	#define ALS_R_VehicleDamageStatusUpdate 1
	#define ALS_R_PlayerSelectedMenuRow     1
	#define ALS_R_PlayerExitedMenu          1
	#define ALS_R_PlayerInteriorChange      1
	#define ALS_R_PlayerKeyStateChange      1
	#define ALS_R_RconLoginAttempt          1
	#define ALS_R_PlayerUpdate              1
	#define ALS_R_PlayerStreamIn            1
	#define ALS_R_PlayerStreamOut           1
	#define ALS_R_VehicleStreamIn           1
	#define ALS_R_VehicleStreamOut          1
	//#define ALS_R_DialogResponse            1
	#define ALS_R_PlayerClickPlayer         1
	#define ALS_R_PlayerLogin               1
	#define ALS_R_PlayerLogout              1
	#define ALS_R_DialogResponse            1
	
	// Chain call declarations.
	//#define ALS_C_AnyScriptInit             ALS_C_INT<AnyScriptInit            ,ALS_R_AnyScriptInit,>()
	//#define ALS_C_AnyScriptExit             ALS_C_INT<AnyScriptExit            ,ALS_R_AnyScriptExit,>()
	#define ALS_C_ScriptInit                ALS_C_INT<ScriptInit               ,ALS_R_ScriptInit,>()
	#define ALS_C_ScriptExit                ALS_C_INT<ScriptExit               ,ALS_R_ScriptExit,>()
	#define ALS_C_GameModeInit              ALS_C_INT<GameModeInit             ,ALS_R_GameModeInit,>()
	#define ALS_C_GameModeExit              ALS_C_INT<GameModeExit             ,ALS_R_GameModeExit,>()
	#define ALS_C_FilterScriptInit          ALS_C_INT<FilterScriptInit         ,ALS_R_FilterScriptInit,>()
	#define ALS_C_FilterScriptExit          ALS_C_INT<FilterScriptExit         ,ALS_R_FilterScriptExit,>()
	#define ALS_C_PlayerConnect             ALS_C_INT<PlayerConnect            ,ALS_R_PlayerConnect,i>(playerid)
	#define ALS_C_PlayerDisconnect          ALS_C_INT<PlayerDisconnect         ,ALS_R_PlayerDisconnect,ii>(playerid,reason)
	#define ALS_C_PlayerSpawn               ALS_C_INT<PlayerSpawn              ,ALS_R_PlayerSpawn,i>(playerid)
	#define ALS_C_PlayerDeath               ALS_C_INT<PlayerDeath              ,ALS_R_PlayerDeath,iii>(playerid,killerid,reason)
	#define ALS_C_VehicleSpawn              ALS_C_INT<VehicleSpawn             ,ALS_R_VehicleSpawn,i>(vehicleid)
	#define ALS_C_VehicleDeath              ALS_C_INT<VehicleDeath             ,ALS_R_VehicleDeath,ii>(vehicleid,killerid)
	#define ALS_C_PlayerText                ALS_C_INT<PlayerText               ,ALS_R_PlayerText,is>(playerid,text)
	#define ALS_C_PlayerCommandText         ALS_C_INT<PlayerCommandText        ,ALS_R_PlayerCommandText,is>(playerid,cmdtext)
	#define ALS_C_PlayerRequestClass        ALS_C_INT<PlayerRequestClass       ,ALS_R_PlayerRequestClass,ii>(playerid,classid)
	#define ALS_C_PlayerEnterVehicle        ALS_C_INT<PlayerEnterVehicle       ,ALS_R_PlayerEnterVehicle,iii>(playerid,vehicleid,ispassenger)
	#define ALS_C_PlayerExitVehicle         ALS_C_INT<PlayerExitVehicle        ,ALS_R_PlayerExitVehicle,ii>(playerid,vehicleid)
	#define ALS_C_PlayerStateChange         ALS_C_INT<PlayerStateChange        ,ALS_R_PlayerStateChange,iii>(playerid,newstate,oldstate)
	#define ALS_C_PlayerEnterCheckpoint     ALS_C_INT<PlayerEnterCheckpoint    ,ALS_R_PlayerEnterCheckpoint,i>(playerid)
	#define ALS_C_PlayerLeaveCheckpoint     ALS_C_INT<PlayerLeaveCheckpoint    ,ALS_R_PlayerLeaveCheckpoint,i>(playerid)
	#define ALS_C_PlayerEnterRaceCheckpoint ALS_C_INT<PlayerEnterRaceCheckpoint,ALS_R_PlayerEnterRaceCheckpoint,i>(playerid)
	#define ALS_C_PlayerLeaveRaceCheckpoint ALS_C_INT<PlayerLeaveRaceCheckpoint,ALS_R_PlayerLeaveRaceCheckpoint,i>(playerid)
	#define ALS_C_RconCommand               ALS_C_INT<RconCommand              ,ALS_R_RconCommand,s>(cmd)
	#define ALS_C_PlayerRequestSpawn        ALS_C_INT<PlayerRequestSpawn       ,ALS_R_PlayerRequestSpawn,i>(playerid)
	#define ALS_C_ObjectMoved               ALS_C_INT<ObjectMoved              ,ALS_R_ObjectMoved,i>(objectid)
	#define ALS_C_PlayerObjectMoved         ALS_C_INT<PlayerObjectMoved        ,ALS_R_PlayerObjectMoved,ii>(playerid,objectid)
	#define ALS_C_PlayerPickUpPickup        ALS_C_INT<PlayerPickUpPickup       ,ALS_R_PlayerPickUpPickup,ii>(playerid,pickupid)
	#define ALS_C_VehicleMod                ALS_C_INT<VehicleMod               ,ALS_R_VehicleMod,iii>(playerid,vehicleid,componentid)
	#define ALS_C_EnterExitModShop          ALS_C_INT<EnterExitModShop         ,ALS_R_EnterExitModShop,iii>(playerid,enterexit,interiorid)
	#define ALS_C_VehiclePaintjob           ALS_C_INT<VehiclePaintjob          ,ALS_R_VehiclePaintjob,iii>(playerid,vehicleid,paintjobid)
	#define ALS_C_VehicleRespray            ALS_C_INT<VehicleRespray           ,ALS_R_VehicleRespray,iiii>(playerid,vehicleid,color1,color2)
	#define ALS_C_VehicleDamageStatusUpdate ALS_C_INT<VehicleDamageStatusUpdate,ALS_R_VehicleDamageStatusUpdate,ii>(playerid,vehicleid)
	#define ALS_C_PlayerSelectedMenuRow     ALS_C_INT<PlayerSelectedMenuRow    ,ALS_R_PlayerSelectedMenuRow,ii>(playerid,row)
	#define ALS_C_PlayerExitedMenu          ALS_C_INT<PlayerExitedMenu         ,ALS_R_PlayerExitedMenu,i>(playerid)
	#define ALS_C_PlayerInteriorChange      ALS_C_INT<PlayerInteriorChange     ,ALS_R_PlayerInteriorChange,iii>(playerid,newinteriorid,oldinteriorid)
	#define ALS_C_PlayerKeyStateChange      ALS_C_INT<PlayerKeyStateChange     ,ALS_R_PlayerKeyStateChange,iii>(playerid,newkeys,oldkeys)
	#define ALS_C_RconLoginAttempt          ALS_C_INT<RconLoginAttempt         ,ALS_R_RconLoginAttempt,ssi>(ip,password,success)
	#define ALS_C_PlayerUpdate              ALS_C_INT<PlayerUpdate             ,ALS_R_PlayerUpdate,i>(playerid)
	#define ALS_C_PlayerStreamIn            ALS_C_INT<PlayerStreamIn           ,ALS_R_PlayerStreamIn,ii>(playerid,forplayerid)
	#define ALS_C_PlayerStreamOut           ALS_C_INT<PlayerStreamOut          ,ALS_R_PlayerStreamOut,ii>(playerid,forplayerid)
	#define ALS_C_VehicleStreamIn           ALS_C_INT<VehicleStreamIn          ,ALS_R_VehicleStreamIn,ii>(vehicleid,forplayerid)
	#define ALS_C_VehicleStreamOut          ALS_C_INT<VehicleStreamOut         ,ALS_R_VehicleStreamOut,ii>(vehicleid,forplayerid)
	//#define ALS_C_DialogResponse            ALS_C_INT<DialogResponse           ,ALS_R_DialogResponse,ii>(playerid,dialogid,response,listitem,inputtext)
	#define ALS_C_PlayerClickPlayer         ALS_C_INT<PlayerClickPlayer        ,ALS_R_PlayerClickPlayer,iii>(playerid,clickedplayerid,source)
	#define ALS_C_PlayerLogin               ALS_C_INT<PlayerLogin              ,ALS_R_PlayerLogin,ii>(playerid,uid)
	#define ALS_C_PlayerLogout              ALS_C_INT<PlayerLogout             ,ALS_R_PlayerLogout,ii>(playerid,uid)
	#define ALS_C_DialogResponse if(inputtext[0]){ALS_C_INT<DialogResponse,ALS_R_DialogResponse,iiiis>(playerid,dialogid,response,listitem,inputtext)}else{ALS_C_INT<DialogResponse,ALS_R_DialogResponse,iiiis>(playerid,dialogid,response,listitem,NULL)}
	
	// Chain call declarations.
	//#define ALS_G_AnyScriptInit             ALS_G_INT<AnyScriptInit            ,>
	//#define ALS_G_AnyScriptExit             ALS_G_INT<AnyScriptExit            ,>
	#define ALS_G_ScriptInit                ALS_G_INT<ScriptInit               ,>
	#define ALS_G_ScriptExit                ALS_G_INT<ScriptExit               ,>
	#define ALS_G_GameModeInit              ALS_G_INT<GameModeInit             ,>
	#define ALS_G_GameModeExit              ALS_G_INT<GameModeExit             ,>
	#define ALS_G_FilterScriptInit          ALS_G_INT<FilterScriptInit         ,>
	#define ALS_G_FilterScriptExit          ALS_G_INT<FilterScriptExit         ,>
	#define ALS_G_PlayerConnect             ALS_G_INT<PlayerConnect            ,i>
	#define ALS_G_PlayerDisconnect          ALS_G_INT<PlayerDisconnect         ,ii>
	#define ALS_G_PlayerSpawn               ALS_G_INT<PlayerSpawn              ,i>
	#define ALS_G_PlayerDeath               ALS_G_INT<PlayerDeath              ,iii>
	#define ALS_G_VehicleSpawn              ALS_G_INT<VehicleSpawn             ,i>
	#define ALS_G_VehicleDeath              ALS_G_INT<VehicleDeath             ,ii>
	#define ALS_G_PlayerText                ALS_G_INT<PlayerText               ,is>
	#define ALS_G_PlayerCommandText         ALS_G_INT<PlayerCommandText        ,is>
	#define ALS_G_PlayerRequestClass        ALS_G_INT<PlayerRequestClass       ,ii>
	#define ALS_G_PlayerEnterVehicle        ALS_G_INT<PlayerEnterVehicle       ,iii>
	#define ALS_G_PlayerExitVehicle         ALS_G_INT<PlayerExitVehicle        ,ii>
	#define ALS_G_PlayerStateChange         ALS_G_INT<PlayerStateChange        ,iii>
	#define ALS_G_PlayerEnterCheckpoint     ALS_G_INT<PlayerEnterCheckpoint    ,i>
	#define ALS_G_PlayerLeaveCheckpoint     ALS_G_INT<PlayerLeaveCheckpoint    ,i>
	#define ALS_G_PlayerEnterRaceCheckpoint ALS_G_INT<PlayerEnterRaceCheckpoint,i>
	#define ALS_G_PlayerLeaveRaceCheckpoint ALS_G_INT<PlayerLeaveRaceCheckpoint,i>
	#define ALS_G_RconCommand               ALS_G_INT<RconCommand              ,s>
	#define ALS_G_PlayerRequestSpawn        ALS_G_INT<PlayerRequestSpawn       ,i>
	#define ALS_G_ObjectMoved               ALS_G_INT<ObjectMoved              ,i>
	#define ALS_G_PlayerObjectMoved         ALS_G_INT<PlayerObjectMoved        ,ii>
	#define ALS_G_PlayerPickUpPickup        ALS_G_INT<PlayerPickUpPickup       ,ii>
	#define ALS_G_VehicleMod                ALS_G_INT<VehicleMod               ,iii>
	#define ALS_G_EnterExitModShop          ALS_G_INT<EnterExitModShop         ,iii>
	#define ALS_G_VehiclePaintjob           ALS_G_INT<VehiclePaintjob          ,iii>
	#define ALS_G_VehicleRespray            ALS_G_INT<VehicleRespray           ,iiii>
	#define ALS_G_VehicleDamageStatusUpdate ALS_G_INT<VehicleDamageStatusUpdate,ii>
	#define ALS_G_PlayerSelectedMenuRow     ALS_G_INT<PlayerSelectedMenuRow    ,ii>
	#define ALS_G_PlayerExitedMenu          ALS_G_INT<PlayerExitedMenu         ,i>
	#define ALS_G_PlayerInteriorChange      ALS_G_INT<PlayerInteriorChange     ,iii>
	#define ALS_G_PlayerKeyStateChange      ALS_G_INT<PlayerKeyStateChange     ,iii>
	#define ALS_G_RconLoginAttempt          ALS_G_INT<RconLoginAttempt         ,ssi>
	#define ALS_G_PlayerUpdate              ALS_G_INT<PlayerUpdate             ,i>
	#define ALS_G_PlayerStreamIn            ALS_G_INT<PlayerStreamIn           ,ii>
	#define ALS_G_PlayerStreamOut           ALS_G_INT<PlayerStreamOut          ,ii>
	#define ALS_G_VehicleStreamIn           ALS_G_INT<VehicleStreamIn          ,ii>
	#define ALS_G_VehicleStreamOut          ALS_G_INT<VehicleStreamOut         ,ii>
	//#define ALS_G_DialogResponse            ALS_G_INT<DialogResponse           ,ii>
	#define ALS_G_PlayerClickPlayer         ALS_G_INT<PlayerClickPlayer        ,iii>
	#define ALS_G_PlayerLogin               ALS_G_INT<PlayerLogin              ,ii>
	#define ALS_G_PlayerLogout              ALS_G_INT<PlayerLogout             ,ii>
	#define ALS_G_DialogResponse            ALS_G_INT<DialogResponse           ,iiiis>
	
	#define ALS_CALL<%0> ALS_C_%0
	#define ALS_FORWARD<%0> ALS_F_%0
	
	#define call%0On%1(%2) ALS_G_%1(%2)
	
	/*ALS_DoDetect(const str[]);
	public ALS_DoDetect(const str[])
	{
		new
			addr;
		addr = funcidx(str);
		if (addr != -1)
		{
			// Get the actual function address, not just the structure offset.
			addr *= 8;
			addr += AMX_HEADER_PUBLICS;
			#emit LREF.S.pri addr
			#emit STOR.S.pri addr
		}
		return addr;
	}*/
	
#endif

#if !defined ALS_PREFIX
	//#error You must define a callback prefix before including y_als.
	#define ALS_PREFIX Mode
#endif
