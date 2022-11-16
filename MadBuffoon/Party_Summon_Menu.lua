--[[
Name: Party Summon Menu
Version: 1.5.0
Made by: MadBuffoon
Notes: This lets you summon party members to you. You can change it so only leader/Assistants can summon.


]]
local enabled = true
local MenuMenus = true
local commandline1 = "menuparty"
local LeaderOnly = false

-- DB Stuff -- Dont Change
local LuaName = "Party_Summon_Menu"
local Settings = {
		["Main"] ={
			--{VariableName, TrueFalse, Value, Text},
			{"enabled", enabled, 0, 0},
			{"MenuMenus", MenuMenus, 0, 0},
			{"commandline1", 0, 0, commandline1},
			{"LeaderOnly", LeaderOnly, 0, 0}
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
		local query = WorldDBQuery(string.format("SELECT * FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", LuaName, v[1]))
		if not query then
			local Input = [[INSERT INTO `lua_settings_save` (`LuaScriptName`, `VariableName`, `TrueFalse`, `Value`, `Text`) VALUES (']]..LuaName..[[', ']]..tostring(v[1])..[[', ']]..tostring(v[2])..[[', ']]..tostring(v[3])..[[', ']]..tostring(v[4])..[[');]]		
			WorldDBExecute(Input)
		else
			
			local query_TrueFalse = WorldDBQuery(string.format("SELECT TrueFalse FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", LuaName, v[1])):GetString(0)
			local query_Value = WorldDBQuery(string.format("SELECT Value FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", LuaName, v[1])):GetString(0)
			local query_Text = WorldDBQuery(string.format("SELECT Text FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", LuaName, v[1])):GetString(0)
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

-- Do not change or remove
local Gold = 10000
local GuidN = 0
local Gossipintid_Use = 100
local Gossipintid_Delete = 1000
local InParty
local group
local groupPlayers

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
function PartyTPMenuGossip(event, player)
	GuidN = getPlayerCharacterGUID(player)
	Gossipintid_Use = 100 -- A Reset
	Gossipintid_Delete = 1000 -- A Reset
	InParty = player:IsInGroup()	
	
	player:GossipClearMenu()
	
	if (InParty == true) then	
	group = player:GetGroup()
	groupPlayers = group:GetMembers()
	local isLeader = group:IsLeader(GuidN)
	local isAssistant = group:IsAssistant(GuidN)
		if (isLeader == LeaderOnly) or (isAssistant == LeaderOnly) or (LeaderOnly == false) then
			player:GossipMenuAddItem(3, "|TInterface\\Icons\\achievement_boss_cthun:34|t Summon List", 0, 1)
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\achievement_bg_3flagcap_nodeaths:34|t Summon Party", 0, 2, false, "Are you sure you want to summon the party?")
		else		
		player:GossipMenuAddItem(3, "|TInterface\\Icons\\achievement_bg_masterofallbgs:34|t Only Leader/Assistants Can Summon.", 0, 0)
		end
	else	
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\achievement_bg_kill_flag_carrierwsg:34|t Your not in a group.", 0, 0)
	end
	
	if (MenuMenus ~= true) then
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\achievement_bg_hld4bases_eos:34|t [Exit Menu]", 0, 99)
	else	
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 97)
	end
	player:GossipSendMenu(1, player, 900002)

end
--(End)
--(Start) The Gossip Menu that shows the List of players you can summon
local function PartyTPListGossip(event, player)
	Gossipintid_Use = 100 -- A Reset
	Gossipintid_Delete = 1000 -- A Reset	
	group = player:GetGroup()
	groupPlayers = group:GetMembers()	
	
	player:GossipClearMenu()
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\achievement_boss_cthun:34|t Summon List", 0, 1)
		
	for k,v in pairs(groupPlayers) do
			local Name = groupPlayers[k]:GetName()
			Gossipintid_Use = Gossipintid_Use + 1
			if (player:GetName() ~= Name) then 
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Inv_ammo_snowball:22|t "..Name.."", 0, Gossipintid_Use, false, "Summon request "..Name.."?")
			end
	end
	
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 98)
	player:GossipSendMenu(1, player, 900002)

end
--(End)

--(Start)
local function OnSelect(event, player, _, sender, intid, code)
	local PlayerName = player:GetName()
	Gossipintid_Use = 100
	Gossipintid_Delete = 1000	
	if (InParty == true) then	
		group = player:GetGroup()
		groupPlayers = group:GetMembers()
	end
	
	if(intid == 0) then --List
		PartyTPMenuGossip(event, player)
	end
	if(intid == 1) then --List
		PartyTPListGossip(event, player)
	end
	if (InParty == true) then	
		group = player:GetGroup()
		groupPlayers = group:GetMembers()
	
		if(intid == 2) then --Summon the whole party
			for k,v in pairs(groupPlayers) do
				local Name = groupPlayers[k]:GetName()
				if (player:GetName() ~= Name) then
					groupPlayers[k]:SummonPlayer(player)	
					player:SendBroadcastMessage("|cff00cc00A summon request was sent to |cff3399FF"..Name.."|cff00cc00.")
				end
			end		
			player:GossipComplete()
		end
		--(Start) Funtion for the summon request list.	
		for k,v in pairs(groupPlayers) do
			local Name = groupPlayers[k]:GetName()
			Gossipintid_Use = Gossipintid_Use + 1
			if (player:GetName() ~= Name) then
				if(intid == Gossipintid_Use) then
					groupPlayers[k]:SummonPlayer(player)	
					player:SendBroadcastMessage("|cff00cc00A summon request was sent to |cff3399FF"..Name.."|cff00cc00.")
					PartyTPListGossip(event, player)
				end
			end
		end
		--(End)
	end
	
	if(intid == 97) then --Back
		MenuMenusGossip(event, player)
	end
	if(intid == 98) then --Back
		PartyTPMenuGossip(event, player)
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
local mingmrank = 3
local IsGM = (player:GetGMRank() >= mingmrank)
if not GMonly or IsGM then
		if (MenuMenus ~= true) then
			player:SendBroadcastMessage("|cff3399FFYou can open a summon party members menu by typing |cff00cc00 ."..commandline1.." |cff3399FF in chat.")
		end
	end
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
		PartyTPMenuGossip(event, player)
		return false
	end
end
--(end)

if enabled then
RegisterPlayerEvent(30, OnFirstLogin)
RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(42, PrintChangeMenuCheck)
RegisterPlayerGossipEvent(900002, 2, OnSelect)
end
