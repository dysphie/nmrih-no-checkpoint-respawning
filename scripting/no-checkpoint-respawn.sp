#include <sourcemod>
#include <sdktools>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define GAMECONF "norespawn.games"

ConVar canRespawn;

public Plugin myinfo = {
    name        = "[NMRiH] No Checkpoint Respawning",
    author      = "Dysphie",
    description = "Toggle player respawning at checkpoints",
    version     = "1.0.2",
    url         = ""
};

enum DetourMode
{
	DetourMode_Pre,
	DetourMode_Post
}

public void OnPluginStart()
{
    GameData gamedata = new GameData(GAMECONF);
    if (!gamedata)
        SetFailState("Failed to get gamedata: " ... GAMECONF);

    RegDetour(gamedata, "CNMRiH_GameRules::RespawnDeadPlayers", OnRespawnDeadPlayers, DetourMode_Pre);
    delete gamedata;

    canRespawn = CreateConVar("sm_allow_checkpoint_respawning", "0", "Allow players to respawn at checkpoints");
}

public MRESReturn OnRespawnDeadPlayers()
{
    return canRespawn.BoolValue ? MRES_Ignored : MRES_Supercede;
}

stock Handle RegDetour(Handle gameconf, const char[] name, DHookCallback callback, DetourMode mode = DetourMode_Post)
{
    Handle hDetour = DHookCreateFromConf(gameconf, name);
    if (!hDetour)
        SetFailState("Failed to setup detour for %s", name);

    if (!DHookEnableDetour(hDetour, !!mode, callback))
        SetFailState("Failed to detour %s.", name);

    return hDetour;
}