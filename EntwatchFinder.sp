#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
    name = "Entwatch Finder",
    author = "Walderr, koen",
    description = "Plugin for assisting in the creation of entwatch configs",
    version = "1.2",
    url = "http://jaze.ru/ & https://github.com/notkoen"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_itemlist", Command_FindEnts, "List all weapon_* entities in the map");
    RegConsoleCmd("sm_envmakers", Command_FindMakers, "List all env_entity_maker entities in the map");
    RegConsoleCmd("sm_spawnmaker", Command_Spawn, "Force spawn an env_entity_maker");
    RegConsoleCmd("sm_gotoent", Command_Goto, "Teleport yourself to the location of an entity");
}

public Action Command_FindEnts(int client, int args)
{
    PrintToConsole(client, "------------------------< Map Weapons & Items >------------------------");
    
    for (int i = 1; i <= GetEntityCount(); i++)
    {
        if (!IsValidEdict(i))
        {
            continue;
        }
        
        int hid = GetEntProp(i, Prop_Data, "m_iHammerID");
        if (!hid)
        {
            continue;
        }
        
        char class[MAX_NAME_LENGTH];
        GetEdictClassname(i, class, sizeof(class));
        
        if (StrContains(class, "weapon_") != -1)
        {
            char name[MAX_NAME_LENGTH];
            GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
            
            float origin[3];
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", origin);
            
            PrintToConsole(client, "ID: %i | Hammer ID: %i | Classname: %s | Targetname: %s | Origin: %.1f %.1f %.1f", i, hid, class, name, origin[0], origin[1], origin[2]);
        }
    }
    
    PrintToConsole(client, "-----------------------------------------------------------------------");
    PrintToChat(client, "[EW-Help] Check console for the output!");
    return Plugin_Handled;
}

public Action Command_FindMakers(int client, int args)
{
    PrintToConsole(client, "------------------------< List of entity makers >------------------------");
    
    for (int i = 1; i <= GetEntityCount(); i++)
    {
        if (!IsValidEdict(i))
        {
            continue;
        }
        
        int hid = GetEntProp(i, Prop_Data, "m_iHammerID");
        if (!hid)
        {
            continue;
        }
        
        char class[MAX_NAME_LENGTH];
        GetEdictClassname(i, class, sizeof(class));
        
        if (StrEqual(class, "env_entity_maker"))
        {
            char name[MAX_NAME_LENGTH];
            GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
            
            float origin[3];
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", origin);
            
            PrintToConsole(client, "ID: %i | Hammer ID: %i | Targetname: %s | Origin: %.1f %.1f %.1f", i, hid, name, origin[0], origin[1], origin[2]);
        }
    }
    
    PrintToConsole(client, "-------------------------------------------------------------------------");
    PrintToChat(client, "[EW-Help] Check console for the output!");
    return Plugin_Handled;
}

public Action Command_Spawn(int client, int args)
{
    char arg1[16];
    GetCmdArgString(arg1, sizeof(arg1));

    int index = StringToInt(arg1);
    
    if (!IsValidEdict(index))
    {
        PrintToChat(client, "[EW-Help] ERROR! Invalid entity index!");
        return Plugin_Handled;
    }
    
    int hid = GetEntProp(index, Prop_Data, "m_iHammerID");
    
    char name[MAX_NAME_LENGTH];
    GetEntPropString(index, Prop_Data, "m_iName", name, sizeof(name));
    
    float origin[3];
    GetEntPropVector(index, Prop_Send, "m_vecOrigin", origin);
    
    AcceptEntityInput(index, "ForceSpawn");
    
    PrintToConsole(client, "[EW-Help] Spawned %s (ID: %i | Hammer ID: %i) at %.1f %.1f %.1f", name, index, hid, origin[0], origin[1], origin[2]);
    return Plugin_Handled;
}

public Action Command_Goto(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[EW-Help] Usage: sm_gotoent <Entity Index>");
        return Plugin_Handled;
    }
    
    char arg1[256];
    GetCmdArgString(arg1, sizeof(arg1));

    if (StrEqual(arg1, ""))
    {
        ReplyToCommand(client, "[EW-Help] Usage: sm_gotoent <Entity Index>");
        return Plugin_Handled;
    }
    
    int index = StringToInt(arg1);
    
    if (!IsValidEdict(index))
    {
        ReplyToCommand(client, "[EW-Help] ERROR! Invalid entity index");
        return Plugin_Handled;
    }

    float pos[3];
    GetEntPropVector(index, Prop_Send, "m_vecOrigin", pos);
    TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
    
    ReplyToCommand(client, "[EW-Help] Teleported you to entity %i at %.1f %.1f %.1f!", index, pos[0], pos[1], pos[2]);

    return Plugin_Handled;
}