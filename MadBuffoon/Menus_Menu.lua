--[[
Name: Menus Menu
Version: 1.5.0
Made by: MadBuffoon
Notes: Opens the a menu for other menus from a item.

]]
local enabled = true
local Binding_Menu = true
local Party_Summon_Menu = true
local DungeonStatsReward_Check = true
local Other = true

-- Do not change or remove
local Gold = 10000
local GuidN = 0

-- DB Stuff -- Dont Change
local Settings = {
		["Main"] ={
			--{VariableName, TrueFalse, Value, Text},
			{"Binding_Menu", "MenuMenus", 0, 0},
			{"Party_Summon_Menu", "MenuMenus", 0, 0},
			{"DungeonStatsReward_Check", "MenuMenus", 0, 0}
		}
}

local function setLocal(name, val)
    local index = 1
    while true do
        local var_name, var_value = debug.getlocal(2, index)
        if not var_name then break end
        if var_name == name then 
            debug.setlocal(2, index, val)
        end
        index = index + 1
    end
end

for event, v in ipairs(Settings["Main"]) do
		local query = WorldDBQuery(string.format("SELECT * FROM lua_settings_save WHERE LuaScriptName='%s'", v[1]))
		if query then
			local query_TrueFalse = WorldDBQuery(string.format("SELECT TrueFalse FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", v[1], v[2])):GetString(0)
			local query_Value = WorldDBQuery(string.format("SELECT Value FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", v[1], v[2])):GetString(0)
			local query_Text = WorldDBQuery(string.format("SELECT Text FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", v[1], v[2])):GetString(0)
			TempVariableName = v[1]
			if (query_TrueFalse == "true") then
				_G[TempVariableName] = true
			elseif (query_TrueFalse == "false") then
				_G[TempVariableName] = false
			elseif (query_Value ~= "0") then
				_G[TempVariableName] = tonumber(query_Value)
			elseif (query_Text ~= "Null") then
				_G[TempVariableName] = tostring(query_Text)
			else
				_G[TempVariableName] = 0
			end
			--SendWorldMessage(tostring(load("return " .. TempVariableName)()))
			local query_Variable = load("return " .. TempVariableName)()
			
			setLocal(TempVariableName, query_Variable)
		end
end

--(Start) Pulles for the guid for the player
local function getPlayerCharacterGUID(player)
    local query = CharDBQuery(string.format("SELECT guid FROM characters WHERE name='%s'", player:GetName()))

    if query then 
      local row = query:GetRow()

      return tonumber(row["guid"])
    end

    return nil
  end
--(End)
--(Start) The Gossip Menu that shows Main Menu
function MenuMenusGossip(event, player)
	GuidN = getPlayerCharacterGUID(player)
	Gossipintid_Use = 100
	Gossipintid_Delete = 1000
	player:GossipClearMenu()
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\inv_misc_rune_01:34|t Use HearthStone", 0, 1)
	if Binding_Menu then
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Ability_spy:34|t Bind Menu", 0, 10)
	end
	if Party_Summon_Menu then
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Spell_shadow_demoniccirclesummon:34|t Summon Menu", 0, 20)
	end
	if DungeonStatsReward_Check then
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t Dungeon Stats Check", 0, 30)
	end
	if Other then
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Mail_gmicon:34|t Other", 0, 90)
	end
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\achievement_bg_hld4bases_eos:34|t [Exit Menu]", 0, 99)
	if (player:GetGMRank() >= 3) then
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Mail_gmicon:34|t GM Menu", 0, 95)
	end
	player:GossipSendMenu(1, player, 899999)

end
--(End)

--(Start)
local function OnSelect(event, player, _, sender, intid, code)
local PlayerName = player:GetName()
	Gossipintid_Use = 100
	Gossipintid_Delete = 1000
	
	if(intid == 1) then --Use HearthStone	
		player:ResetSpellCooldown( 8690, true )
		player:CastSpell(player, 8690, false)
		player:GossipComplete()
	end	
	if(intid == 10) then --Bind Menu
		BindMenuGossip(event, player)
	end	
	if(intid == 20) then --Summon Menu
		PartyTPMenuGossip(event, player)
	end	
	if(intid == 30) then --Dungeon Stats Check
		DRStatsGossip(event, player)
	end		
	if(intid == 90) then --Other Menu
		OtherMenuGossip(event, player)
	end		
	if(intid == 95) then --GM Menu
		GMSettingsMenuGossip(event, player)
	end
	if(intid == 98) then --Back
		MenuMenusGossip(event, player)
		return false
	end
	if(intid == 99) then --Close
		player:SendAreaTriggerMessage("Good Bye!")
		player:GossipComplete()
	end
end
--(End)


--(Start) Part of start up.
local function BootMSG(eventid, delay, repeats, player)
   -- player:SendBroadcastMessage("|cff3399FFYou can open a bind menu by typing |cff00cc00 ."..commandline1.." |cff3399FF in chat.")
end
local firstlogin = false
local function OnFirstLogin(event, player)
	if event == 30 then
	firstlogin = true
	end
	
	player:RegisterEvent(BootMSG, 60000, 1, player)
end
local function OnLogin(event, player)
	if not firstlogin then
	player:RegisterEvent(BootMSG, 20000, 1, player)
	else
	firstlogin = false
	end
end
--(end)

--(Start) Command: Check
local function PrintChangeMenuCheck(event, player, command)
	if (command == commandline1) then
		BindMenuGossip(event, player)
		return false
	end
end
--(end)

if enabled then
RegisterPlayerEvent(30, OnFirstLogin)
RegisterPlayerEvent(3, OnLogin)
RegisterPlayerGossipEvent(899999, 2, OnSelect)
--RegisterItemEvent(900504, 2, MenuMenusGossip )
RegisterItemEvent(6948, 2, MenuMenusGossip )
end
