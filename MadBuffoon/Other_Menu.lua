--[[
Name: Other Menu
Version: 1.1.2
Made by: MadBuffoon
Notes: Other Functions

]]

local enabled = true
local MenuMenus = true
local ReCustomize_Character = true
-- DB Stuff -- Dont Change
local Settings = {
		["Main"] ={
			--{VariableName, TrueFalse, Value, Text},
			{"ReCustomize_Character", "MenuMenus", 0, 0}
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

-- Do not change or remove
local Gold = 10000
local GuidN = 0


local NPC_Entry = 900001
local Q = WorldDBQuery(string.format("SELECT * FROM creature_template WHERE entry="..NPC_Entry..""))
local createnpc = [[INSERT INTO creature_template
(entry, difficulty_entry_1, difficulty_entry_2, difficulty_entry_3, KillCredit1, KillCredit2, modelid1, modelid2, modelid3, modelid4, name, subname, IconName, gossip_menu_id, minlevel, maxlevel, `exp`, faction, npcflag, speed_walk, speed_run, `scale`, `rank`, dmgschool, BaseAttackTime, RangeAttackTime, BaseVariance, RangeVariance, unit_class, unit_flags, unit_flags2, dynamicflags, family, `type`, type_flags, lootid, pickpocketloot, skinloot, PetSpellDataId, VehicleId, mingold, maxgold, AIName, MovementType, HoverHeight, HealthModifier, ManaModifier, ArmorModifier, DamageModifier, ExperienceModifier, RacialLeader, movementId, RegenHealth, mechanic_immune_mask, spell_school_immune_mask, flags_extra, ScriptName, VerifiedBuild)
VALUES(]]..NPC_Entry..[[, 0, 0, 0, 0, 0, 19627, 0, 0, 0, 'Vender & Repair', '', NULL, 0, 83, 83, 0, 35, 4224, 1.1, 1.17, 1, 3, 0, 1500, 2000, 1, 1, 1, 0, 0, 1, 0, 7, 134217792, 0, 0, 0, 0, 0, 0, 0, 'NullAI', 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 2, '', 0);]]

if not Q then
WorldDBExecute(createnpc)
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
function OtherMenuGossip(event, player)
	GuidN = getPlayerCharacterGUID(player)
	Gossipintid_Use = 100
	Gossipintid_Delete = 1000
	player:GossipClearMenu()
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_letter_05:34|t Mail Box", 0, 1)
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_crate_04:34|t Personal Bank", 0, 2)
	--player:GossipMenuAddItem(3, "|TInterface\\Icons\\inv_misc_rune_01:34|t Guild Bank", 0, 3)
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Trade_blacksmithing:34|t Vender & Repair NPC", 0, 4)
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_letter_18:34|t Hire NPC", 0, 5)
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Spell_arcane_portaldalaran:34|t Pocket Portal", 0, 6)	
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_gizmo_thebiggerone:34|t Reset Raids", 0, 10, false, "Note: Leave group before using this!")	
	if ReCustomize_Character then
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\achievement_boss_mutanus_the_devourer:34|t ReCustomize Character", 0, 20)
	end
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Trade_engraving:34|t Enchant Items", 0, 30)	
	if (MenuMenus ~= true) then
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\achievement_bg_hld4bases_eos:34|t [Exit Menu]", 0, 99)
	else	
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 97)
	end
	player:GossipSendMenu(1, player, 900003)

end
--(End)

--(Start)
local function OnSelect(event, player, _, sender, intid, code)
local PlayerName = player:GetName()
	Gossipintid_Use = 100
	Gossipintid_Delete = 1000
	local currentgold = player:GetCoinage()
	
	local x = player:GetX()
	local y = player:GetY()
	local z = player:GetZ()
	local o = player:GetO()
	local map = player:GetMap()
	local mapID = map:GetMapId()
	local areaId = map:GetAreaId( x, y, z )
	
	if(intid == 1) then -- Mail	
		player:SendShowMailBox( GuidN )
	end	
	if(intid == 2) then -- Personal Bank	
		player:SendShowBank( player )
	end	
	if(intid == 3) then -- Guild Bank	
		guild = player:GetGuild()
		player:SendShowBank( guild )
	end		
	if(intid == 4) then -- Vender & Repair NPC
		local VenderNPCnear = player:GetNearestCreature( 80, 900001 )
		local VenderSpawned
		if VenderNPCnear == nil then
			VenderSpawned = player:SpawnCreature( 900001, x+1, y+1, z+0.5, o-3.5, 1, 60000 )
			else
			player:SendAreaTriggerMessage("|cffff3347Note: |cffffd000Vender & Repair NPC is already nearby!")
		end
	player:GossipComplete()
	end	
	if(intid== 5) then -- Hire NPC Bots 128
		local HireNPCnear = player:GetNearestCreature( 80, 70000 )
		local spawnedHire
		if HireNPCnear == nil then
			spawnedHire = player:SpawnCreature( 70000, x+1, y+1, z+0.5, o-3.5, 1, 60000 )
			else
			player:SendAreaTriggerMessage("|cffff3347Note: |cffffd000Hire NPC is already nearby!")
		end
		player:GossipComplete()
	end
	if(intid== 6) then -- Pocket Portal 
		local HireNPCnear = player:GetNearestCreature( 80, 900002 )
		local spawnedHire
		if HireNPCnear == nil then
			spawnedHire = player:SpawnCreature( 900002, x+1, y+1, z+0.5, o-3.5, 1, 60000 )
			else
			player:SendAreaTriggerMessage("|cffff3347Note: |cffffd000A Pocket Portal is already nearby!")
			player:SendBroadcastMessage("|cffff3347Note: |cffffd000A Pocket Portal is already nearby!")
		end
		player:GossipComplete()
	end	
	if(intid== 10) then -- Reset Instances/Raids
		player:UnbindAllInstances()
		player:SendBroadcastMessage("|cffff3347Notice: |cffffd000Instances/Raids have been Reseted.")
		player:GossipComplete()
	end	
	if(intid == 20) then --ReCustomize Character
		ChangeMenuGossip(event, player)
	end	
	if(intid == 30) then --Enchant Items
		enchanterG_Enchanter(event, player)
	end	
	if(intid == 97) then --Back
		MenuMenusGossip(event, player)
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

if enabled then
RegisterPlayerEvent(30, OnFirstLogin)
RegisterPlayerEvent(3, OnLogin)
RegisterPlayerGossipEvent(900003, 2, OnSelect)
end
