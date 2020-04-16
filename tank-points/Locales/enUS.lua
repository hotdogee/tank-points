-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
	Name: TankPoints enUS locale
	Revision: $Revision: 113 $
Translated by: 
- Whitetooth@Cenarius (hotdogee@bahamut.twbbs.org)
]]

local debug = false
--[===[@debug@
--debug = true
--@end-debug@]===]
local L = LibStub("AceLocale-3.0"):NewLocale("TankPoints", "enUS", true, debug) --true=this is the default locale

-- To translate AceLocale strings, replace true with the translation string
-- Before: ["Show Item ID"] = true
-- After:  ["Show Item ID"] = "顯示物品編號"

-- Global Strings that don't need translations
--[[
PLAYERSTAT_MELEE_COMBAT = "Melee"
SPELL_SCHOOL0_CAP = "Physical"
SPELL_SCHOOL0_NAME = "physical"
SPELL_SCHOOL1_CAP = "Holy"
SPELL_SCHOOL1_NAME = "holy"
SPELL_SCHOOL2_CAP = "Fire"
SPELL_SCHOOL2_NAME = "fire"
SPELL_SCHOOL3_CAP = "Nature"
SPELL_SCHOOL3_NAME = "nature"
SPELL_SCHOOL4_CAP = "Frost"
SPELL_SCHOOL4_NAME = "frost"
SPELL_SCHOOL5_CAP = "Shadow"
SPELL_SCHOOL5_NAME = "shadow"
SPELL_SCHOOL6_CAP = "Arcane"
SPELL_SCHOOL6_NAME = "arcane"
SPELL_STAT1_NAME = "Strength"
SPELL_STAT2_NAME = "Agility"
SPELL_STAT3_NAME = "Stamina"
SPELL_STAT4_NAME = "Intellect"
SPELL_STAT5_NAME = "Spirit"
COMBAT_RATING_NAME1 = "Weapon Skill"
COMBAT_RATING_NAME2 = "Defense Rating"
COMBAT_RATING_NAME3 = "Dodge Rating"
COMBAT_RATING_NAME4 = "Parry Rating"
COMBAT_RATING_NAME5 = "Block Rating"
COMBAT_RATING_NAME6 = "Hit Rating"
COMBAT_RATING_NAME7 = "Hit Rating" -- Ranged hit rating
COMBAT_RATING_NAME8 = "Hit Rating" -- Spell hit rating
COMBAT_RATING_NAME9 = "Crit Rating" -- Melee crit rating
COMBAT_RATING_NAME10 = "Crit Rating" -- Ranged crit rating
COMBAT_RATING_NAME11 = "Crit Rating" -- Spell Crit Rating
COMBAT_RATING_NAME15 = "Resilience"
ARMOR = "Armor"
DEFENSE = "Defense"
DODGE = "Dodge"
PARRY = "Parry"
BLOCK = "Block"
--]]

TP_STR = 1
TP_AGI = 2
TP_STA = 3
TP_HEALTH = 4
TP_ARMOR = 5
TP_DEFENSE = 6
TP_DODGE = 7
TP_PARRY = 8
TP_BLOCK = 9
TP_BLOCKVALUE = 10
TP_RESILIENCE = 11

-------------
-- General --
-------------
	L["TankPoints"] = true
	L["EH"] = true -- "Effective Health" is a long phrase
	L["EHB"] = true -- "Effective Health with Block" is a very long phrase
	L["Block Value"] = true

--------------------
-- Character Info --
--------------------
-- Stats
	L["EH Block"] = true
	L[" EH"] = true
	L[" TP"] = true -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	L[" DR"] = true -- concatenated after a school name for Damage Reductions, ex: "Nature DR"

-- TankPoints Stat Tooltip
	L["In "] = true -- concatenated before stance name, ex: "In Battle Stance"
	L["Mob Stats"] = true
	L["Mob Level"] = true
	L["Mob Damage"] = true
	L["Mob Crit"] = true
	L["Mob Miss"] = true
	L["Per StatValue"] = true
	L["Per Stat"] = true
	L["Click: show Per StatValue TankPoints"] = true
	L["Click: show Per Stat TankPoints"] = true
	L["Relative Stat Values"] = true

-- Melee Reduction Tooltip
	L[" Damage Reduction"] = true -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	L["Player Level"] = true
	L["Combat Table"] = true
	L["Crit"] = true
	L["Crushing"] = true
	L["Hit"] = true
	L["Avoidance Diminishing Returns"] = true
	L["Only includes Dodge, Parry, and Missed"] = true

-- Block Value Tooltip
	L["Mob Damage before DR"] = true
	L["Mob Damage after DR"] = true
	L["Blocked Percentage"] = true
	L["Equivalent Block Mitigation"] = true
	L["Shield Block Up Time"] = true

-- Spell TankPoints Tooltip
	L["Melee/Spell Damage Ratio"] = true
	L["Left click: Show next school"] = true
	L["Right click: Show strongest school"] = true
	L[" resist "] = true

-- Spell Reduction Tooltip
-- Toggle Calculator
	L["Open Calculator"] = true
	L["Close Calculator"] = true

-- talent names
	L["imp. Shield Block"] = true -- short for Improved Shield Block

-- Effective Health stuff
	L["Effective Health"] = true
	L["Effective Health vs %s %s"] = true -- Melee/Nature/Fire followed by EH
	L["Effective Health (with Block) vs Melee "] = true -- followed by EHB
	L["Effective Health with Block"] = "Effective Health w/ Block"
	L["Effective Health - All Schools"] = true -- heading for the all schools of damage tooltip
	L["Health"] = true -- player health
	L["Armor Reduction"] = true -- how much armor reduces damage
	L["Resistance Reduction"] = true -- reduction due to elemental resist (nature, etc)
	L["Talent/Buff/Stance Reductions"] = true -- things like stances, talents
	L["Your Reductions"] = true -- section header
	L["Guaranteed Reduction"] = true -- how much damage you're guaranteed to mitigate
	L["Mob attacks can critically hit"] = true
	L["Mob attacks cannot critically hit"] = true
	L["Mob attacks will crush"] = true
	L["Mob attacks should not crush"] = true

-- an array with lines to be put at the bottom of the Effective Health Tooltip
-- saying what EH is
	L["TP_EXPLANATION"] = {"TankPoints is a measure of your theoretical", "mitigation (dodge, parry, etc) in proportion", "to your health."}
	L["EH_EXPLANATION"] = {"Effective Health is how much raw", "damage you can take without", "a miss/block/dodge/parry."}
	L["EHB_EXPLANATION"] = {"Effective Health with Block is how much raw", "damage you can take without a miss/dodge/parry", "and only guaranteed blocks. Dependant", "on mob stats and you being able to block."}
	L["See /tp optionswin to turn on tooltip."] = true
        
---------------------------
-- Slash Command Options --
---------------------------
-- /tp config
	L["Options Window"] = true
	L["Shows the Options Window"] = true
-- /tp calc
	L["TankPoints Calculator"] = true
	L["Shows the TankPoints Calculator"] = true
-- /tp debug
	L["Enable Debugging"] = true
	L["Toggle the display of debug messages"] = true
-- /tp tooltip
	L["Tooltip Options"] = true
	L["TankPoints tooltip options"] = true
-- /tp tooltip diff
	L["Show TankPoints Difference"] = true
	L["Show TankPoints difference in item tooltips"] = true
-- /tp tooltip total
	L["Show TankPoints Total"] = true
	L["Show TankPoints total in item tooltips"] = true
-- /tp tooltip drdiff
	L["Show Melee DR Difference"] = true
	L["Show Melee Damage Reduction difference in item tooltips"] = true
-- /tp tooltip drtotal
	L["Show Melee DR Total"] = true
	L["Show Melee Damage Reduction total in item tooltips"] = true
-- /tp tooltip ehdiff
	L["Show Effective Health Difference"] = true
	L["Show Effective Health difference in item tooltips"] = true
-- /tp tooltip ehtotal
	L["Show Effective Health Total"] = true
	L["Show Effective Health total in item tooltips"] = true
-- /tp tooltip ehbdiff
	L["Show Effective Health (with Block) Difference"] = true
	L["Show Effective Health (with Block) difference in item tooltips"] = true
-- /tp tooltip ehbtotal
	L["Show Effective Health (with Block) Total"] = true
	L["Show Effective Health (with Block) total in item tooltips"] = true
-- /tp player
	L["Player Stats"] = true
	L["Change default player stats"] = true
-- /tp player sbfreq
	L["Shield Block Key Press Delay"] = true
	L["Sets the time in seconds after Shield Block finishes cooldown"] = true
-- /tp mob
	L["Mob Stats"] = true
	L["Change default mob stats"] = true
-- /tp mob level
	L["Mob Level"] = true
	L["Sets the level difference between the mob and you"] = true
-- /tp mob damage
-- /tp mob drdamage
	L["Mob Damage"] = true
	L["Sets mob's damage before damage reduction"] = true
	L["Sets mob's damage after melee damage reduction"] = true
-- /tp mob speed
	L["Mob Attack Speed"] = true
	L["Sets mob's attack speed"] = true
-- /tp mob default
	L["Restore Default"] = true
	L["Restores default mob stats"] = true
	L["Restored Mob Stats Defaults"] = true -- command feedback
-- /tp mob advanced
	L["Mob Stats Advanced Settings"] = true
	L["Change advanced mob stats"] = true
-- /tp mob advanced crit
	L["Mob Melee Crit"] = true
	L["Sets mob's melee crit chance"] = true
-- /tp mob advanced critbonus
	L["Mob Melee Crit Bonus"] = true
	L["Sets mob's melee crit bonus"] = true
-- /tp mob advanced miss
	L["Mob Melee Miss"] = true
	L["Sets mob's melee miss chance"] = true
-- /tp mob advanced spellcrit
	L["Mob Spell Crit"] = true
	L["Sets mob's spell crit chance"] = true
-- /tp mob advanced spellcritbonus
	L["Mob Spell Crit Bonus"] = true
	L["Sets mob's spell crit bonus"] = true
-- /tp mob advanced spellmiss
	L["Mob Spell Miss"] = true
	L["Sets mob's spell miss chance"] = true
	
	--/tp purgeplayerstats
	L["Purge Player Stats"] = true;
	L["Purge collected set of historical player stats"] = true;
	
	--Tooltips Options group
	L["Tooltip options"] = true
	L["Change TankPoints tooltip options"] = true
	L["Ignore Gems"] = true
	L["Ignore gems when comparing items"] = true
	L["Ignore Enchants"] = true
	L["Ignore enchants when comparing items"] = true
	L["Ignore Prismatic"] = true
	L["Igmore prismatic sockets when comparing items"] = true

----------------------
-- GetDodgePerAgi() --
----------------------
	L["Cat Form"] = true

---------------------------
-- GetTalantBuffEffect() --
---------------------------
	L["Soul Link"] = true
	L["Voidwalker"] = true
	L["Righteous Fury"] = true
	L["Pain Suppression"] = true
	L["Shield Wall"] = true
	L["Death Wish"] = true
	L["Recklessness"] = true
	L["Cloak of Shadows"] = true

----------------------
-- AlterSourceData() --
----------------------
	L["Bear Form"] = true
	L["Dire Bear Form"] = true
	L["Moonkin Form"] = true

-----------------------
-- PlayerHasShield() --
-----------------------
	L["Shields"] = true

---------------------
-- GetBlockValue() --
---------------------
	L["^(%d+) Block$"] = true

------------------------
-- Item Scan Patterns --
------------------------
	L["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"Increases the block value of your shield by (%d+)"},
			{"%+(%d+) Block Value"},
		}
	}

---------------------------
-- TankPoints Calculator --
---------------------------
-- Title
	L["TankPoints Calculator"] = true
	L["Left click to drag\nRight click to reset position"] = true

-- Buttons
	L["Reset"] = true
	L["Close"] = true

-- Option frame box title
	L["Results"] = true
	L["Player Stats"] = true
	L["Total Reduction"] = true
	L["(%)"] = true
	L["Max Health"] = true
	L["Items"] = true

-------------------------
-- TankPoints Tooltips --
-------------------------
	L[" (Top/Bottom):"] = true
	L[" (Main/Off):"] = true
	L[" (Main+Off):"] = true
	L["Gems"] = true

---------------
-- Waterfall --
---------------
	L["TankPoints Options"] = true

-------------------------
-- Calculator tooltips --
-------------------------
	L["Increases attack power and chance to parry an attack"] = true;
	L["Armor reduces physical damage taken"] = true
	L["TPCalc_PlayerStatsTooltip_MasteryRating"] = "Mastery Rating increases your Mastery.\nMastery increases your chance to block an attack."
	L["TPCalc_PlayerStatsTooltip_Mastery"] = "Mastery increases your chance to block an attack."

	L["Dodge rating improves your chance to dodge. A dodged attack does no damage"] = "Dodge rating improves your chance to dodge.\nA dodged attack does no damage"
	L["Your chance to dodge an attack. A dodged attack does no damage"] = "Your chance to dodge an attack.\nA dodged attack does no damage"
	L["Parry rating improves your chance to parry. When you parry an attack, it and the next attack, will each hit for 50% less damage"] = "Parry rating improves your chance to parry.\nWhen you parry an attack it, and the next attack,\nwill each hit for 50% less damage"
	L["Your chance to parry an attack. When you parry an attack, it and the next attack, will each hit for 50% less damage"] = "Your chance to parry an attack.\nWhen you parry an attack, it and the next attack,\nwill each hit for 50% less damage"
	L["Block rating improves your chance to block. Blocked attacks hit for 30% less damage"] = "Block rating improves your chance to block.\nBlocked attacks hit for 30% less damage"
	L["Your chance to block an attack. Blocked attacks hit for 30% less damage."] = "Your chance to block an attack.\nBlocked attacks hit for 30% less damage."
	L["(removed) Block value was removed from the game in patch 4.0.1. All blocked attacks hit for 30% less damage"] = "Blocked attacks hit for 30% less damage"

