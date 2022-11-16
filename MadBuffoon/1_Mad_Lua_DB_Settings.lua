--[[
Name: Mad's SQL Checker
Version: 1.0.0
Made by: MadBuffoon
Notes: This is to check DP changes to allow my other 

]]
local lua_settings_save = [[ CREATE TABLE IF NOT EXISTS lua_settings_save
(`entry` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `LuaScriptName` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `VariableName` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `TrueFalse` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `Value` int(10) unsigned NULL DEFAULT NULL,
  `Text` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  PRIMARY KEY (`entry`) USING BTREE);]]
WorldDBExecute(lua_settings_save)
