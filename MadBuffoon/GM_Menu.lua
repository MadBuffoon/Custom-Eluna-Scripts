--[[
Name: Menus Menu
Version: 1.5.0
Made by: MadBuffoon
Notes: Opens the a menu for other menus from a item.

]]
local enabled = true
local MenuMenus = true

local WhatLua
local SetIcon
local WhatColumn

local ListOfLua = {
	{"|TInterface\\Icons\\Ability_spy:34|t ", "Binding_Menu", 10},
	{"|TInterface\\Icons\\Spell_shadow_demoniccirclesummon:34|t ", "Party_Summon_Menu", 11},
	{"|TInterface\\Icons\\achievement_boss_mutanus_the_devourer:34|t ", "ReCustomize_Character", 13}
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

function GMSettingsMenuGossip(event, player)
	player:GossipClearMenu()
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Mail_gmicon:34|t GM Settings Menu", 0, 98)
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_letter_06:34|t List Of Lua Scripts", 0, 1)
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Inv_gizmo_supersappercharge:34|t Reload Eluna", 0, 95, false, "Are you sure?")
	if (MenuMenus ~= true) then
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\achievement_bg_hld4bases_eos:34|t [Exit Menu]", 0, 99)
	else	
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 97)
	end
	
	player:GossipSendMenu(1, player, 900004)

end

function ListLuaScriptsGossip(event, player)
	player:GossipClearMenu()
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Mail_gmicon:34|t List Of Lua Scripts", 0, 1)
		
	for event, v in ipairs(ListOfLua) do
		player:GossipMenuAddItem(0, v[1]..""..v[2].."", 0, v[3])
	end
	
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 98)
	player:GossipSendMenu(1, player, 900004)

end

function GenListOfSettingsGossip(event, player)
	player:GossipClearMenu()
	player:GossipMenuAddItem(3, "|TInterface\\Icons\\Mail_gmicon:34|t "..WhatLua.." Settings", 0, 1)
		
		
	local query1 = WorldDBQuery(string.format("SELECT VariableName FROM lua_settings_save WHERE LuaScriptName='%s'", WhatLua))
	if query1 then
		repeat
			local VariableName = query1:GetString(0)
			local entryNumber = WorldDBQuery(string.format("SELECT entry FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", WhatLua, VariableName))
			local entryNumber_Use = tonumber(entryNumber:GetInt32(0)) + 100
			
			local query_TrueFalse = WorldDBQuery(string.format("SELECT TrueFalse FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", WhatLua, VariableName)):GetString(0)
			local query_Value = WorldDBQuery(string.format("SELECT Value FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", WhatLua, VariableName)):GetString(0)
			local query_Text = WorldDBQuery(string.format("SELECT Text FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", WhatLua, VariableName)):GetString(0)
			TempVariableName = VariableName
			if (query_TrueFalse == "true") then
				_G[TempVariableName] = true
				SetIcon = "|TInterface\\Icons\\Inv_misc_key_01:26|t True/False:"
			elseif (query_TrueFalse == "false") then
				_G[TempVariableName] = false
				SetIcon = "|TInterface\\Icons\\Inv_misc_key_01:26|t True/False:"
			elseif (query_Value ~= "0") then
				_G[TempVariableName] = tonumber(query_Value)
				SetIcon = "|TInterface\\Icons\\Ability_hunter_pathfinding:26|t Number:"
			elseif (query_Text ~= "Null") then
				_G[TempVariableName] = tostring(query_Text)
				SetIcon = "|TInterface\\Icons\\Inv_misc_note_03:26|t Text:"
			else
				_G[TempVariableName] = 0
				SetIcon = "|TInterface\\Icons\\Ability_hunter_pathfinding:26|t Number:"
			end
			local TempVariableValue = load("return " .. TempVariableName)()
			player:GossipMenuAddItem(0,SetIcon.." "..VariableName.." > "..tostring(TempVariableValue), 0, entryNumber_Use, true, "Type what you want to set the Variable "..VariableName.." to.")
		until not query1:NextRow()
	end
	
	player:GossipMenuAddItem(4, "|TInterface\\Icons\\Achievement_bg_returnxflags_def_wsg:34|t [Back]", 0, 1)
	player:GossipSendMenu(1, player, 900004)

end


--(Start)
local function OnSelect(event, player, _, sender, intid, code)
local PlayerName = player:GetName()
	
	if(intid == 1) then --List
		ListLuaScriptsGossip(event, player)
	end	
	if(intid == 95) then --Back	
		player:SendBroadcastMessage("|cffff3347Note: |cffffd000Reloading Eluna")
		player:GossipComplete()
		ReloadEluna()		
	end
	if(intid == 97) then --Back
		MenuMenusGossip(event, player)
	end
	if(intid == 98) then --Back
		GMSettingsMenuGossip(event, player)
	end
	if(intid == 99) then --Close
		player:SendAreaTriggerMessage("Good Bye!")
		player:GossipComplete()
	end
	for event, v in ipairs(ListOfLua) do	
		if(intid == v[3]) then
			WhatLua = v[2]
			GenListOfSettingsGossip(event, player)
		end
	end
for event, v in ipairs(ListOfLua) do
	local query1 = WorldDBQuery(string.format("SELECT VariableName FROM lua_settings_save WHERE LuaScriptName='%s'", v[2]))
		if query1 then
		repeat
			local VariableName = query1:GetString(0)
			local entryNumber = WorldDBQuery(string.format("SELECT entry FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", v[2], VariableName))
			local entryNumber_Use = tonumber(entryNumber:GetInt32(0)) + 100
			
			local query_TrueFalse = WorldDBQuery(string.format("SELECT TrueFalse FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", v[2], VariableName)):GetString(0)
			local query_Value = WorldDBQuery(string.format("SELECT Value FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", v[2], VariableName)):GetString(0)
			local query_Text = WorldDBQuery(string.format("SELECT Text FROM lua_settings_save WHERE LuaScriptName='%s' and VariableName='%s'", v[2], VariableName)):GetString(0)
			if (query_TrueFalse == "true") then
				WhatColumn = "TrueFalse"
			elseif (query_TrueFalse == "false") then
				WhatColumn = "TrueFalse"
			elseif (query_Value ~= "0") then
				WhatColumn = "Value"
			elseif (query_Text ~= "Null") then
				WhatColumn = "Text"
			else
				WhatColumn = "Value"
			end
			if(intid == entryNumber_Use) then
				local CanInput = false
				if (WhatColumn == "TrueFalse") then
					if (tostring(code) == "true" or tostring(code) == "false") then
						CanInput = true
					else					
						player:SendBroadcastMessage("|cffff3347Note: |cffffd000You can only enter true or false in that variable.")
						ListLuaScriptsGossip(event, player)
					end
				elseif (WhatColumn == "Value") then
					if (tonumber(code) ~= nil) then
						if (tonumber(code) >= 0) then
							CanInput = true
						else					
							player:SendBroadcastMessage("|cffff3347Note: |cffffd000You can only enter a number value in that variable.")
							ListLuaScriptsGossip(event, player)
						end
					else 				
						player:SendBroadcastMessage("|cffff3347Note: |cffffd000You can only enter a number value in that variable.")
						ListLuaScriptsGossip(event, player)
					end
				else
					CanInput = true
					player:SendBroadcastMessage("|cffff3347Note: |cffffd000You can only enter true or false in that variable.")
					ListLuaScriptsGossip(event, player)
					
				end
				if CanInput then
					player:SendBroadcastMessage("|cffff3347Note: |r"..v[2].."|cff00cc00 Type: |cff3399FF"..WhatColumn.."|cff00cc00 Input: |cff3399FF"..tostring(code).."|cff00cc00 Entry: |cff3399FF"..entryNumber:GetInt32(0))
					WorldDBExecute(string.format("UPDATE lua_settings_save SET %s='%s' WHERE entry='%i'", WhatColumn, tostring(code), entryNumber:GetInt32(0)))
					ListLuaScriptsGossip(event, player)
					--player:GossipComplete()
				end
			end
		until not query1:NextRow()
		end
end
end
--(End)
if enabled then
RegisterPlayerGossipEvent(900004, 2, OnSelect)
end
