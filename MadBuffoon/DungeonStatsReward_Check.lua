--[[
Name: Dungeon Stats Reward Check
Version: 2.5.0
Made by: MadBuffoon
Notes: This is for the wow repack from Skuly link: https://discord.gg/ecTCrDkEwK
		lets you reset, buy and trade the bonus stat points.
]]
local enabled = true
local MenuMenus = true
local commandline1 = "drstats"
local StatChangeNotice = "|cffff3347Note: |cffffd000Stats changes won't be updated until the next time you login."

--Cost
local BuyStats = true
local MainStatCost = 25

--Trade
local TradeStats = true
local StatTradeRate = 2


-- DP Settings
local LuaName = "DungeonStatsReward_Check"
local Settings = {
		["Main"] ={
			--{VariableName, TrueFalse, Value, Text},
			{"enabled", enabled, 0, 0},
			{"MenuMenus", MenuMenus, 0, 0},
			{"commandline1", 0, 0, commandline1},
			{"StatChangeNotice", 0, 0, StatChangeNotice},
			{"BuyStats", BuyStats, 0, 0},
			{"MainStatCost", 0, MainStatCost, 0},
			{"TradeStats", TradeStats, 0, 0},
			{"StatTradeRate", 0, StatTradeRate, 0}
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
			local Input = [[INSERT INTO `lua_settings_save` (`LuaScriptName`, `VariableName`, `TrueFalse`, `Value`, `Text`) VALUES (']]..LuaName..[[', ']]..tostring(v[1])..[[', ']]..tostring(v[2])..[[', ']]..tostring(v[3])..[[', "]]..tostring(v[4])..[[");]]		
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
local StrengthN = 0
local AgilityN= 0
local StaminaN = 0
local IntellectN = 0
local SpiritN = 0
local SpellPowerN = 0
local AttackPowerN = 0
local RangedAttackPowerN = 0
local ChangeStat_1 = "GUID"
local ChangeStat_1_Text = "na"
local ChangeStat_2 = "GUID"
local ChangeStat_2_Text = "na"
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
function DRStatsGossip(event, player)
	GuidN = getPlayerCharacterGUID(player)
	StrengthN = CharDBQuery(string.format("SELECT Strength FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	AgilityN= CharDBQuery(string.format("SELECT Agility FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	StaminaN = CharDBQuery(string.format("SELECT Stamina FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	IntellectN = CharDBQuery(string.format("SELECT Intellect FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	SpiritN = CharDBQuery(string.format("SELECT Spirit FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	SpellPowerN = CharDBQuery(string.format("SELECT SpellPower FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	AttackPowerN = CharDBQuery(string.format("SELECT AttackPower FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	RangedAttackPowerN = CharDBQuery(string.format("SELECT RAttackPower FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	
	ChangeStat_1 = "GUID"
	ChangeStat_2 = "GUID"
	ChangeStat_1_Text = "na"
	ChangeStat_2_Text = "na"
	
	player:GossipClearMenu()
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t Check or Reset Dungeon Stats", 0, 1)
	if(BuyStats == true) then
		player:GossipMenuAddItem(1, "|TInterface\\Icons\\inv_misc_coin_17:34|t Buy Stats", 0, 2)
	end
	if(TradeStats == true) then
	player:GossipMenuAddItem(8, "|TInterface\\Icons\\Ability_dualwield:34|t Trade current stats for more useful stats", 0, 3)
	end	
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t Inspect Target", 0, 4)
	if (MenuMenus ~= true) then
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\achievement_bg_hld4bases_eos:34|t [Exit Menu]", 0, 99)
	else	
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 97)
	end
	player:GossipSendMenu(1, player, 1775)

end
--(End)
--(Start) The Gossip Menu that shows the stats  
local function DRStatsGossipShow(event, player)	
		local totalStats = tonumber(StrengthN:GetInt32(0)) + tonumber(AgilityN:GetInt32(0)) + tonumber(StaminaN:GetInt32(0)) + tonumber(IntellectN:GetInt32(0)) + tonumber(SpiritN:GetInt32(0)) +tonumber(SpellPowerN:GetInt32(0)) + tonumber(AttackPowerN:GetInt32(0)) + tonumber(RangedAttackPowerN:GetInt32(0))
		player:GossipClearMenu()
		player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t If you click on a stat it will ask you if you want to reset it.", 0, 1)
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Ability_warrior_secondwind:22|t Strength "..tonumber(StrengthN:GetInt32(0)).."", 0, 20, false, "Do you want to reset Strength?")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Ability_rogue_masterofsubtlety:22|t Agility "..tonumber(AgilityN:GetInt32(0)).."", 0, 21, false, "Do you want to reset Agility?")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_holy_divinespirit:22|t Stamina "..tonumber(StaminaN:GetInt32(0)).."", 0, 22, false, "Do you want to reset Stamina?")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_arcane_focusedpower:22|t Intellect "..tonumber(IntellectN:GetInt32(0)).."", 0, 23, false, "Do you want to reset Intellect?")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_unused2:22|t Spirit "..tonumber(SpiritN:GetInt32(0)).."", 0, 24, false, "Do you want to reset Spirit?")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_shaman_spectraltransformation:22|t Spell Power "..tonumber(SpellPowerN:GetInt32(0)).."", 0, 25, false, "Do you want to reset Spell Power?")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Ability_thunderclap:22|t Attack Power "..tonumber(AttackPowerN:GetInt32(0)).."", 0, 26, false, "Do you want to reset Attack Power?")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Ability_hunter_focusedaim:22|t Ranged Attack Power "..tonumber(RangedAttackPowerN:GetInt32(0)).."", 0, 27, false, "Do you want to reset Ranged Attack Power?")		
		player:GossipMenuAddItem(9, "|TInterface\\Icons\\achievement_arena_2v2_7:28|t Total Bonus "..totalStats.."", 0, 1)
		player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 98)
		player:GossipSendMenu(1, player, 1775)

end
--(End)
--(Start) The Gossip Menu that shows Buy 
local function DRStatsGossipBuy(event, player)	
		local currentgold = math.floor(player:GetCoinage() / 10000)
		local maxtobuy = math.floor(currentgold / MainStatCost)
		player:GossipClearMenu()
		player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t Select the stat you want to buy. Points Cost: "..MainStatCost.."g each.", 0, 2)
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargepositive:22|t Strength", 0, 30, true, "Type in how many points of Strength.\nYou currently have "..currentgold.."g and can buy up too "..maxtobuy.." points")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargepositive:22|t Agility", 0, 31, true, "Type in how many points of Agility.\nYou currently have "..currentgold.."g and can buy up too "..maxtobuy.." points")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargepositive:22|t Stamina", 0, 32, true, "Type in how many points of Stamina.\nYou currently have "..currentgold.."g and can buy up too "..maxtobuy.." points")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargepositive:22|t Intellect", 0, 33, true, "Type in how many points of Intellect.\nYou currently have "..currentgold.."g and can buy up too "..maxtobuy.." points")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargepositive:22|t Spirit", 0, 34, true, "Type in how many points of Spirit.\nYou currently have "..currentgold.."g and can buy up too "..maxtobuy.." points")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargepositive:22|t Spell Power", 0, 35, true, "Type in how many points of Spell Power.\nYou currently have "..currentgold.."g and can buy up too "..maxtobuy.." points")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargepositive:22|t Attack Power", 0, 36, true, "Type in how many points of Attack Power.\nYou currently have "..currentgold.."g and can buy up too "..maxtobuy.." points")
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargepositive:22|t Ranged Attack Power", 0, 37, true, "Type in how many points of Ranged Attack Power.\nYou currently have "..currentgold.."g and can buy up too "..maxtobuy.." points")	
		player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 98)
		player:GossipSendMenu(1, player, 1775)

end
--(End)

--(Start) The Gossip Menu that shows Trade  
local function DRStatsGossipTrade(event, player)		
		player:GossipClearMenu()
		if(ChangeStat_1== "GUID")then
			player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t Select the stat you want to change.", 0, 3)
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargenegative:22|t Strength", 0, 50, false, "Select Strength?")	
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargenegative:22|t Agility", 0, 51, false, "Select Agility?")				
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargenegative:22|t Stamina", 0, 52, false, "Select Stamina?")	
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargenegative:22|t Intellect", 0, 53, false, "Select Intellect?")				
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargenegative:22|t Spirit", 0, 54, false, "Select Spirit?")	
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargenegative:22|t Spell Power", 0, 55, false, "Select Spell Power?")				
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargenegative:22|t Attack Power", 0, 56, false, "Select Attack Power?")
			player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_chargenegative:22|t Ranged Attack Power", 0, 57, false, "Select Ranged Attack Power?")
		else
				player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t Select the stat you want to change "..ChangeStat_1_Text.." to.", 0, 3)
			if (ChangeStat_1 ~= "Strength") then
				player:GossipMenuAddItem(7, "|TInterface\\Icons\\Spell_chargepositive:22|t Strength", 0, 50, false, "Select Strength?")	
			end
			if (ChangeStat_1 ~= "Agility") then	
				player:GossipMenuAddItem(7, "|TInterface\\Icons\\Spell_chargepositive:22|t Agility", 0, 51, false, "Select Agility?")	
			end
			if (ChangeStat_1 ~= "Stamina") then				
				player:GossipMenuAddItem(7, "|TInterface\\Icons\\Spell_chargepositive:22|t Stamina", 0, 52, false, "Select Stamina?")
			end
			if (ChangeStat_1 ~= "Intellect") then		
				player:GossipMenuAddItem(7, "|TInterface\\Icons\\Spell_chargepositive:22|t Intellect", 0, 53, false, "Select Intellect?")
			end
			if (ChangeStat_1 ~= "Spirit") then			
				player:GossipMenuAddItem(7, "|TInterface\\Icons\\Spell_chargepositive:22|t Spirit", 0, 54, false, "Select Spirit?")		
			end
			if (ChangeStat_1 ~= "Spell Power") then
				player:GossipMenuAddItem(7, "|TInterface\\Icons\\Spell_chargepositive:22|t Spell Power", 0, 55, false, "Select Spell Power?")
			end
			if (ChangeStat_1 ~= "Attack Power") then				
				player:GossipMenuAddItem(7, "|TInterface\\Icons\\Spell_chargepositive:22|t Attack Power", 0, 56, false, "Select Attack Power?")
			end
			if (ChangeStat_1 ~= "Ranged Attack Power") then
				player:GossipMenuAddItem(7, "|TInterface\\Icons\\Spell_chargepositive:22|t Ranged Attack Power", 0, 57, false, "Select Ranged Attack Power?")
			end
		end
		player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 98)
		player:GossipSendMenu(1, player, 1775)

end

--(Start) The Gossip Menu that shows the stats  
local function DRStatsGossipShow_Target(event, player)	
		local OG_Player = player
		local player = player:GetSelection()
		local GuidN = nil
	if (player ~= nil) then	
		GuidN = getPlayerCharacterGUID(player)
		end
	if (player ~= nil and GuidN ~= nil) then	
		local StrengthN = CharDBQuery(string.format("SELECT Strength FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
		local AgilityN= CharDBQuery(string.format("SELECT Agility FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
		local StaminaN = CharDBQuery(string.format("SELECT Stamina FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
		local IntellectN = CharDBQuery(string.format("SELECT Intellect FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
		local SpiritN = CharDBQuery(string.format("SELECT Spirit FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
		local SpellPowerN = CharDBQuery(string.format("SELECT SpellPower FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
		local AttackPowerN = CharDBQuery(string.format("SELECT AttackPower FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
		local RangedAttackPowerN = CharDBQuery(string.format("SELECT RAttackPower FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
	
		local totalStats = tonumber(StrengthN:GetInt32(0)) + tonumber(AgilityN:GetInt32(0)) + tonumber(StaminaN:GetInt32(0)) + tonumber(IntellectN:GetInt32(0)) + tonumber(SpiritN:GetInt32(0)) +tonumber(SpellPowerN:GetInt32(0)) + tonumber(AttackPowerN:GetInt32(0)) + tonumber(RangedAttackPowerN:GetInt32(0))

		OG_Player:GossipClearMenu()
		OG_Player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t Inspecting Target: "..player:GetName().."", 0, 4)
		OG_Player:GossipMenuAddItem(0, "|TInterface\\Icons\\Ability_warrior_secondwind:22|t Strength "..tonumber(StrengthN:GetInt32(0)).."", 0, 4)
		OG_Player:GossipMenuAddItem(0, "|TInterface\\Icons\\Ability_rogue_masterofsubtlety:22|t Agility "..tonumber(AgilityN:GetInt32(0)).."", 0, 4)
		OG_Player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_holy_divinespirit:22|t Stamina "..tonumber(StaminaN:GetInt32(0)).."", 0, 4)
		OG_Player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_arcane_focusedpower:22|t Intellect "..tonumber(IntellectN:GetInt32(0)).."", 0, 4)
		OG_Player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_unused2:22|t Spirit "..tonumber(SpiritN:GetInt32(0)).."", 0, 4)
		OG_Player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_shaman_spectraltransformation:22|t Spell Power "..tonumber(SpellPowerN:GetInt32(0)).."", 0, 4)
		OG_Player:GossipMenuAddItem(0, "|TInterface\\Icons\\Ability_thunderclap:22|t Attack Power "..tonumber(AttackPowerN:GetInt32(0)).."", 0, 4)
		OG_Player:GossipMenuAddItem(0, "|TInterface\\Icons\\Ability_hunter_focusedaim:22|t Ranged Attack Power "..tonumber(RangedAttackPowerN:GetInt32(0)).."", 0, 4)		
		OG_Player:GossipMenuAddItem(9, "|TInterface\\Icons\\achievement_arena_2v2_7:28|t Total Bonus "..totalStats.."", 0, 4)
		OG_Player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 98)
		OG_Player:GossipSendMenu(1, OG_Player, 1775)
	else
		OG_Player:GossipClearMenu()
		OG_Player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_misc_grouplooking:34|t No target", 0, 4)
		OG_Player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 98)
		OG_Player:GossipSendMenu(1, OG_Player, 1775)
	end
end
--(End)
local function DRStatsGossipTrade_Complet(event, player)
		local GuidN = getPlayerCharacterGUID(player)
		local ChangeStat_1_Value= CharDBQuery(string.format("SELECT "..ChangeStat_1.." FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
		local MaxTrade = math.floor(tonumber(ChangeStat_1_Value:GetInt32(0)) / StatTradeRate)
		player:GossipMenuAddItem(0, "|TInterface\\Icons\\Spell_arcane_mindmastery:34|t Trading "..ChangeStat_1_Text.." For "..ChangeStat_2_Text.."", 0, 58, true, "Type in how many "..ChangeStat_2_Text.." points that you want. \nThe Max you can do is "..MaxTrade..".")	
		player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 98)
		player:GossipSendMenu(1, player, 1775)

end
local function DRStatsGossip_More(event, player)
		player:GossipMenuAddItem(3, "This menu just gives a chance for the values to change, but I would still relog after your done doing changes.", 0, 96)
		player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back to Menu]", 0, 98)
		player:GossipMenuAddItem(4, "|TInterface\\Icons\\achievement_bg_hld4bases_eos:34|t [Exit Menu]", 0, 99)
		player:GossipSendMenu(1, player, 1775)

end
--(End)

--(Start)
local function OnSelect(event, player, _, sender, intid, code)
local GuidN = getPlayerCharacterGUID(player)
local currentgold = player:GetCoinage()
	if(intid == 1) then --View
		DRStatsGossipShow(event, player)
	end
	if(intid == 2) then --Buy
		DRStatsGossipBuy(event, player)
	end
	if(intid == 3) then --Trade		
		DRStatsGossipTrade(event, player)
	end
	if(intid == 4) then --Trade		
		DRStatsGossipShow_Target(event, player)
	end
	--Reset
	if(intid == 20) then 
		CharDBExecute(string.format("UPDATE stats_from_dungeons SET Strength=0 WHERE GUID=%i", GuidN))
		player:GossipComplete()
		player:SendBroadcastMessage("|cff3399FFStrength is now reset to|cff00cc00 0|cff3399FF.")
		player:SendBroadcastMessage(StatChangeNotice)
	end

	if(intid == 21) then
		CharDBExecute(string.format("UPDATE stats_from_dungeons SET Agility=0 WHERE GUID=%i", GuidN))
		player:GossipComplete()
		player:SendBroadcastMessage("|cff3399FFAgility is now reset to|cff00cc00 0|cff3399FF.")
		player:SendBroadcastMessage(StatChangeNotice)
	end

	if(intid == 22) then
		CharDBExecute(string.format("UPDATE stats_from_dungeons SET Stamina=0 WHERE GUID=%i", GuidN))
		player:GossipComplete()
		player:SendBroadcastMessage("|cff3399FFStamina is now reset to|cff00cc00 0|cff3399FF.")
		player:SendBroadcastMessage(StatChangeNotice)
	end

	if(intid == 23) then
		CharDBExecute(string.format("UPDATE stats_from_dungeons SET Intellect=0 WHERE GUID=%i", GuidN))
		player:GossipComplete()
		player:SendBroadcastMessage("|cff3399FFIntellect is now reset to|cff00cc00 0|cff3399FF.")
		player:SendBroadcastMessage(StatChangeNotice)
	end

	if(intid == 24) then
		CharDBExecute(string.format("UPDATE stats_from_dungeons SET Spirit=0 WHERE GUID=%i", GuidN))
		player:GossipComplete()
		player:SendBroadcastMessage("|cff3399FFSpirit is now reset to|cff00cc00 0|cff3399FF.")
		player:SendBroadcastMessage(StatChangeNotice)
	end

	if(intid == 25) then
		CharDBExecute(string.format("UPDATE stats_from_dungeons SET SpellPower=0 WHERE GUID=%i", GuidN))
		player:GossipComplete()
		player:SendBroadcastMessage("|cff3399FFSpell Power is now reset to|cff00cc00 0|cff3399FF.")
		player:SendBroadcastMessage(StatChangeNotice)
	end

	if(intid == 26) then
		CharDBExecute(string.format("UPDATE stats_from_dungeons SET AttackPower=0 WHERE GUID=%i", GuidN))
		player:GossipComplete()
		player:SendBroadcastMessage("|cff3399FFAttack Power is now reset to|cff00cc00 0|cff3399FF.")
		player:SendBroadcastMessage(StatChangeNotice)
	end

	if(intid == 27) then
		CharDBExecute(string.format("UPDATE stats_from_dungeons SET RAttackPower=0 WHERE GUID=%i", GuidN))
		player:GossipComplete()
		player:SendBroadcastMessage("|cff3399FFRange Attack Power is now reset to|cff00cc00 0|cff3399FF.")
		player:SendBroadcastMessage(StatChangeNotice)
	end
	--end
	
	--(Start) Buy
	if(intid == 30) then 
		local cost = ((code * MainStatCost)*Gold)
		local Tgold = code * MainStatCost
		if (currentgold >= cost) then
			local newstatnumber = tonumber(StrengthN:GetInt32(0)) + code
			CharDBExecute(string.format("UPDATE stats_from_dungeons SET Strength="..newstatnumber.." WHERE GUID=%i", GuidN))
			player:ModifyMoney(-cost)
			player:GossipComplete()
			player:SendBroadcastMessage("|cff3399FFStrength: |cff00cc00"..tonumber(StrengthN:GetInt32(0)).."|cff3399FF >> |cff00cc00"..newstatnumber.."|cff3399FF Costed: |cfffca726"..Tgold.."g")
			player:SendBroadcastMessage(StatChangeNotice)
			DRStatsGossip_More(event, player)				
		else
			player:SendBroadcastMessage("|cffff3347You don't have the gold. You need |cfffca726"..Tgold.."g")
			DRStatsGossip(event, player)
		end
	end

	if(intid == 31) then 
		local cost = ((code * MainStatCost)*Gold)
		local Tgold = code * MainStatCost
		if (currentgold >= cost) then
			local newstatnumber = tonumber(AgilityN:GetInt32(0)) + code
			CharDBExecute(string.format("UPDATE stats_from_dungeons SET Agility="..newstatnumber.." WHERE GUID=%i", GuidN))
			player:ModifyMoney(-cost)
			player:GossipComplete()
			player:SendBroadcastMessage("|cff3399FFAgility: |cff00cc00"..tonumber(AgilityN:GetInt32(0)).."|cff3399FF >> |cff00cc00"..newstatnumber.."|cff3399FF Costed: |cfffca726"..Tgold.."g")
			player:SendBroadcastMessage(StatChangeNotice)			
			DRStatsGossip_More(event, player)				
		else
			player:SendBroadcastMessage("|cffff3347You don't have the gold. You need |cfffca726"..Tgold.."g")
			DRStatsGossip(event, player)
		end
	end

	if(intid == 32) then 
		local cost = ((code * MainStatCost)*Gold)
		local Tgold = code * MainStatCost
		if (currentgold >= cost) then
			local newstatnumber = tonumber(StaminaN:GetInt32(0)) + code
			CharDBExecute(string.format("UPDATE stats_from_dungeons SET Stamina="..newstatnumber.." WHERE GUID=%i", GuidN))
			player:ModifyMoney(-cost)
			player:GossipComplete()
			player:SendBroadcastMessage("|cff3399FFStamina: |cff00cc00"..tonumber(StaminaN:GetInt32(0)).."|cff3399FF >> |cff00cc00"..newstatnumber.."|cff3399FF Costed: |cfffca726"..Tgold.."g")
			player:SendBroadcastMessage(StatChangeNotice)			
			DRStatsGossip_More(event, player)				
		else
			player:SendBroadcastMessage("|cffff3347You don't have the gold. You need |cfffca726"..Tgold.."g")
			DRStatsGossip(event, player)
		end
	end

	if(intid == 33) then 
		local cost = ((code * MainStatCost)*Gold)
		local Tgold = code * MainStatCost
		if (currentgold >= cost) then
			local newstatnumber = tonumber(IntellectN:GetInt32(0)) + code
			CharDBExecute(string.format("UPDATE stats_from_dungeons SET Intellect="..newstatnumber.." WHERE GUID=%i", GuidN))
			player:ModifyMoney(-cost)
			player:GossipComplete()
			player:SendBroadcastMessage("|cff3399FFIntellect: |cff00cc00"..tonumber(IntellectN:GetInt32(0)).."|cff3399FF >> |cff00cc00"..newstatnumber.."|cff3399FF Costed: |cfffca726"..Tgold.."g")
			player:SendBroadcastMessage(StatChangeNotice)			
			DRStatsGossip_More(event, player)
		else
			player:SendBroadcastMessage("|cffff3347You don't have the gold. You need |cfffca726"..Tgold.."g")
			DRStatsGossip(event, player)
		end
	end

	if(intid == 34) then 
		local cost = ((code * MainStatCost)*Gold)
		local Tgold = code * MainStatCost
		if (currentgold >= cost) then
			local newstatnumber = tonumber(SpiritN:GetInt32(0)) + code
			CharDBExecute(string.format("UPDATE stats_from_dungeons SET Spirit="..newstatnumber.." WHERE GUID=%i", GuidN))
			player:ModifyMoney(-cost)
			player:GossipComplete()
			player:SendBroadcastMessage("|cff3399FFSpirit: |cff00cc00"..tonumber(SpiritN:GetInt32(0)).."|cff3399FF >> |cff00cc00"..newstatnumber.."|cff3399FF Costed: |cfffca726"..Tgold.."g")
			player:SendBroadcastMessage(StatChangeNotice)			
			DRStatsGossip_More(event, player)
		else
			player:SendBroadcastMessage("|cffff3347You don't have the gold. You need |cfffca726"..Tgold.."g")
			DRStatsGossip(event, player)
		end
	end

	if(intid == 35) then 
		local cost = ((code * MainStatCost)*Gold)
		local Tgold = code * MainStatCost
		if (currentgold >= cost) then
			local newstatnumber = tonumber(SpellPowerN:GetInt32(0)) + code
			CharDBExecute(string.format("UPDATE stats_from_dungeons SET SpellPower="..newstatnumber.." WHERE GUID=%i", GuidN))
			player:ModifyMoney(-cost)
			player:GossipComplete()
			player:SendBroadcastMessage("|cff3399FFSpell Power: |cff00cc00"..tonumber(SpellPowerN:GetInt32(0)).."|cff3399FF >> |cff00cc00"..newstatnumber.."|cff3399FF Costed: |cfffca726"..Tgold.."g")
			player:SendBroadcastMessage(StatChangeNotice)			
			DRStatsGossip_More(event, player)
		else
			player:SendBroadcastMessage("|cffff3347You don't have the gold. You need |cfffca726"..Tgold.."g")
			DRStatsGossip(event, player)
		end
	end

	if(intid == 36) then 
		local cost = ((code * MainStatCost)*Gold)
		local Tgold = code * MainStatCost
		if (currentgold >= cost) then
			local newstatnumber = tonumber(AttackPowerN:GetInt32(0)) + code
			CharDBExecute(string.format("UPDATE stats_from_dungeons SET AttackPower="..newstatnumber.." WHERE GUID=%i", GuidN))
			player:ModifyMoney(-cost)
			player:GossipComplete()
			player:SendBroadcastMessage("|cff3399FFAttack Power: |cff00cc00"..tonumber(AttackPowerN:GetInt32(0)).."|cff3399FF >> |cff00cc00"..newstatnumber.."|cff3399FF Costed: |cfffca726"..Tgold.."g")
			player:SendBroadcastMessage(StatChangeNotice)			
			DRStatsGossip_More(event, player)
		else
			player:SendBroadcastMessage("|cffff3347You don't have the gold. You need |cfffca726"..Tgold.."g")
			DRStatsGossip(event, player)
		end
	end

	if(intid == 37) then 
		local cost = ((code * MainStatCost)*Gold)
		local Tgold = code * MainStatCost
		if (currentgold >= cost) then
			local newstatnumber = tonumber(RangedAttackPowerN:GetInt32(0)) + code
			CharDBExecute(string.format("UPDATE stats_from_dungeons SET RAttackPower="..newstatnumber.." WHERE GUID=%i", GuidN))
			player:ModifyMoney(-cost)
			player:GossipComplete()
			player:SendBroadcastMessage("|cff3399FFRanged Attack Power: |cff00cc00"..tonumber(RangedAttackPowerN:GetInt32(0)).."|cff3399FF >> |cff00cc00"..newstatnumber.."|cff3399FF Costed: |cfffca726"..Tgold.."g")
			player:SendBroadcastMessage(StatChangeNotice)			
			DRStatsGossip_More(event, player)
		else
			player:SendBroadcastMessage("|cffff3347You don't have the gold. You need |cfffca726"..Tgold.."g")
			DRStatsGossip(event, player)
		end
	end
	--(End)
	--(Start) Trade
	if(intid == 50) then
		if(ChangeStat_1 == "GUID")then
			ChangeStat_1 = "Strength"
			ChangeStat_1_Text = "Strength"
			DRStatsGossipTrade(event, player)
		else
			ChangeStat_2 = "Strength"
			ChangeStat_2_Text = "Strength"
			DRStatsGossipTrade_Complet(event, player)
		end		
	end
	
	if(intid == 51) then
		if(ChangeStat_1 == "GUID")then
			ChangeStat_1 = "Agility"
			ChangeStat_1_Text = "Agility"
			DRStatsGossipTrade(event, player)
		else
			ChangeStat_2 = "Agility"
			ChangeStat_2_Text = "Agility"
			DRStatsGossipTrade_Complet(event, player)
		end		
	end
	if(intid == 52) then
		if(ChangeStat_1 == "GUID")then
			ChangeStat_1 = "Stamina"
			ChangeStat_1_Text = "Stamina"
			DRStatsGossipTrade(event, player)
		else
			ChangeStat_2 = "Stamina"
			ChangeStat_2_Text = "Stamina"
			DRStatsGossipTrade_Complet(event, player)
		end
	end
	if(intid == 53) then
		if(ChangeStat_1 == "GUID")then
			ChangeStat_1 = "Intellect"
			ChangeStat_1_Text = "Intellect"
			DRStatsGossipTrade(event, player)
		else
			ChangeStat_2 = "Intellect"
			ChangeStat_2_Text = "Intellect"
			DRStatsGossipTrade_Complet(event, player)
		end
	end
	if(intid == 54) then
		if(ChangeStat_1 == "GUID")then
			ChangeStat_1 = "Spirit"
			ChangeStat_1_Text = "Spirit"
			DRStatsGossipTrade(event, player)
		else
			ChangeStat_2 = "Spirit"
			ChangeStat_2_Text = "Spirit"
			DRStatsGossipTrade_Complet(event, player)
		end
	end
	if(intid == 55) then
		if(ChangeStat_1 == "GUID")then
			ChangeStat_1 = "SpellPower"
			ChangeStat_1_Text = "Spell Power"
			DRStatsGossipTrade(event, player)
		else
			ChangeStat_2 = "SpellPower"
			ChangeStat_2_Text = "Spell Power"
			DRStatsGossipTrade_Complet(event, player)
		end
	end
	if(intid == 56) then
		if(ChangeStat_1 == "GUID")then
			ChangeStat_1 = "AttackPower"
			ChangeStat_1_Text = "Attack Power"
			DRStatsGossipTrade(event, player)
		else
			ChangeStat_2 = "AttackPower"
			ChangeStat_2_Text = "Attack Power"
			DRStatsGossipTrade_Complet(event, player)
		end
	end
	if(intid == 57) then
		if(ChangeStat_1 == "GUID")then
			ChangeStat_1 = "RAttackPower"			
			ChangeStat_1_Text = "Ranged Attack Power"
			DRStatsGossipTrade(event, player)
		else
			ChangeStat_2 = "RAttackPower"	
			ChangeStat_2_Text = "Ranged Attack Power"
			DRStatsGossipTrade_Complet(event, player)
		end
	end
	if(intid == 58) then
		if(ChangeStat_1 == "GUID" and ChangeStat_2 == "GUID") then	
		
			player:SendBroadcastMessage("No stats were selected")
			player:SendBroadcastMessage(""..ChangeStat_1.." + "..ChangeStat_2"")
			DRStatsGossip(event, player)
		else
			local codeNumber = tonumber(code)
			local ChangeStat_1_Value= CharDBQuery(string.format("SELECT "..ChangeStat_1.." FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
			local ChangeStat_2_Value= CharDBQuery(string.format("SELECT "..ChangeStat_2.." FROM stats_from_dungeons WHERE GUID='%s'", GuidN))
			local MaxTrade = math.floor(tonumber(ChangeStat_1_Value:GetInt32(0)) / StatTradeRate)	
			local TradeCost = math.floor(codeNumber * StatTradeRate)

			--player:SendBroadcastMessage(""..ChangeStat_1_Text.." "..tonumber(ChangeStat_1_Value:GetInt32(0)).." + "..ChangeStat_2_Text.." "..tonumber(ChangeStat_2_Value:GetInt32(0)).."")
			--player:SendBroadcastMessage("Code "..codeNumber.." MaxTrade "..MaxTrade.." + TradeCost "..TradeCost.."" )
			if(codeNumber <= MaxTrade) then
				local newstatnumber1 = math.floor(tonumber(ChangeStat_1_Value:GetInt32(0)) - TradeCost)
				local newstatnumber2 = math.floor(tonumber(ChangeStat_2_Value:GetInt32(0)) + codeNumber)
			
				CharDBExecute(string.format("UPDATE stats_from_dungeons SET "..ChangeStat_1.."="..newstatnumber1.." WHERE GUID=%i", GuidN))
				CharDBExecute(string.format("UPDATE stats_from_dungeons SET "..ChangeStat_2.."="..newstatnumber2.." WHERE GUID=%i", GuidN))
				player:SendBroadcastMessage("|cff3399FF You traded |cff00cc00"..TradeCost.."|cff3399FF "..ChangeStat_1_Text.." for |cff00cc00"..code.."|cff3399FF "..ChangeStat_2_Text..".")			
				player:SendBroadcastMessage(StatChangeNotice)
				DRStatsGossip_More(event, player)				
			else
				player:SendBroadcastMessage("|cffff3347 You don't have the stat points to do that.")
				DRStatsGossip(event, player)
			end	
		end
	end
	--(End)
	if(intid == 96) then --Back
		DRStatsGossip_More(event, player)
	end
	if(intid == 97) then --Back
		MenuMenusGossip(event, player)
	end
	if(intid == 98) then --Back
		DRStatsGossip(event, player)
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
		player:SendBroadcastMessage("|cff3399FFYou can see your current Bouns Stats by typing |cff00cc00 .drstats |cff3399FF in chat.")
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
local function PrintRewardStatsCheck(event, player, command)
	if (command == commandline1) then
		DRStatsGossip(event, player)
		return false
	end
end
--(end)

if enabled then
RegisterPlayerEvent(30, OnFirstLogin)
RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(42, PrintRewardStatsCheck)
RegisterPlayerGossipEvent(1775, 2, OnSelect)
end
