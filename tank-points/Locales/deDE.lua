-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
	Name: TankPoints deDE locale
	Revision: $Revision: 50 $
Translated by: 
- AbbedieD
]]

local L = LibStub("AceLocale-3.0"):NewLocale("TankPoints", "deDE")
if not L then return end

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



	L["Block Value"] = "Blockwert"

--------------------
-- Character Info --
--------------------
-- Stats



	L[" DR"] = " SR" -- concatenated after a school name for Damage Reductions, ex: "Nature DR"

-- TankPoints Stat Tooltip



	L["Mob Damage"] = "Mob Schaden"
	L["Mob Crit"] = "Mob kritisch"
	L["Mob Miss"] = "Mob verfehlt"





-- Melee Reduction Tooltip
	L[" Damage Reduction"] = " Schadensreduzierung" -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	L["Player Level"] = "Spieler Level"
	L["Combat Table"] = "Kampftabelle"
	L["Crit"] = "Kritisch"
	L["Crushing"] = "Schmetternd"
	L["Hit"] = "Treffer"



-- Block Value Tooltip
	L["Mob Damage before DR"] = "Mob Schaden vor SR"
	L["Mob Damage after DR"] = "Mob Schaden nach SR"
	L["Blocked Percentage"] = "Prozentual geblockt"
	--L["Equivalent Block Mitigation"] = true
-- Spell TankPoints Tooltip
	L["Melee/Spell Damage Ratio"] = "Nahkampf-/Zauberschadensverhältnis"
	L["Left click: Show next school"] = "Linksklick: Zeige nächste Magieschule"
	L["Right click: Show strongest school"] = "Rechtsklick: Zeige stärkste Magieschule"


-- Spell Reduction Tooltip
-- Toggle Calculator
	L["Open Calculator"] = "\195\150ffne Rechner"
	L["Close Calculator"] = "Schliesse Rechner"

-- talent names

---------------------------
-- Slash Command Options --
---------------------------
-- /tp config
-- /tp calc
	L["TankPoints Calculator"] = "TankPoints Rechner"
	L["Shows the TankPoints Calculator"] = "Zeigt den TankPoints Rechner an"
-- /tp debug
-- /tp tooltip
-- /tp tooltip diff
-- /tp tooltip total
-- /tp tooltip drdiff
-- /tp tooltip drtotal
-- /tp tooltip ehdiff
-- /tp tooltip ehtotal
-- /tp tooltip ehbdiff
-- /tp tooltip ehbtotal
-- /tp player
-- /tp player sbfreq
-- /tp mob
	--L["Mob Stats"] = true
	L["Change default mob stats"] = "\195\132ndern der Standard Mob Stats"
-- /tp mob level
	--L["Mob Level"] = true
	L["Sets the level difference between the mob and you"] = "Setzt den Levelunterschied zwischen dem Mob und dir"
-- /tp mob damage
-- /tp mob drdamage
	L["Mob Damage"] = "Mob Schaden"
	L["Sets mob's damage before damage reduction"] = "Schaden des Mobs vor der Schadensreduzierung \195\164ndern"
-- /tp mob speed
-- /tp mob default
	L["Restore Default"] = "Standard wiederherstellen"
	L["Restores default mob stats"] = "Stellt die Standard Mob Stats wieder her"
	L["Restored Mob Stats Defaults"] = "Mob Standard Stats wiederhergestellt" -- command feedback
-- /tp mob advanced
	L["Mob Stats Advanced Settings"] = "Erweiterte Mobs Stats Einstellungen"
	L["Change advanced mob stats"] = "\195\132ndern der erweiterten Mob Stats"
-- /tp mob advanced crit
	L["Mob Melee Crit"] = "Mob Nahkampf Kritisch"
	L["Sets mob's melee crit chance"] = "\195\132ndern der Mob Nahkampf Krit Chance"
-- /tp mob advanced critbonus
	L["Mob Melee Crit Bonus"] = "Mob Nahkampf Krit Bonus"
	L["Sets mob's melee crit bonus"] = "\195\132ndern des Mob Nahkampf Krit Bonus"
-- /tp mob advanced miss
	L["Mob Melee Miss"] = "Mob Nahkampf Verfehlt"
	L["Sets mob's melee miss chance"] = "\195\132ndern der Mob Nahkampf Verfehl Chance"
-- /tp mob advanced spellcrit
	L["Mob Spell Crit"] = "Mob Zauber Kritsch"
	L["Sets mob's spell crit chance"] = "\195\132ndern der Mob Zauber Krit Chance"
-- /tp mob advanced spellcritbonus
	L["Mob Spell Crit Bonus"] = "Mob Zauber Krit Bonus"
	L["Sets mob's spell crit bonus"] = "\195\132ndern des Mob Zauber Krit Bonus"
-- /tp mob advanced spellmiss
	L["Mob Spell Miss"] = "Mob Zauber Verfehlt"
	L["Sets mob's spell miss chance"] = "\195\132ndern der Mob Zauber Verfehl Chance"

----------------------
-- GetDodgePerAgi() --
----------------------
	L["Cat Form"] = "Katzengestalt"

---------------------------
-- GetTalantBuffEffect() --
---------------------------
	L["Soul Link"] = "Seelenverbindung"
	L["Voidwalker"] = "Leerwandler"
	L["Righteous Fury"] = "Zorn der Gerechtigkeit"
	L["Pain Suppression"] = "Schmerzunterdrückung"
	L["Shield Wall"] = "Schildwall"
	L["Death Wish"] = "Todeswunsch"
	L["Recklessness"] = "Tollkühnheit"
	L["Cloak of Shadows"] = "Mantel der Schatten"

-----------------------
-- AlterSourceData() --
-----------------------
	L["Bear Form"] = "Bärengestalt"
	L["Dire Bear Form"] = "Terrorbärengestalt"
	L["Moonkin Form"] = "Moonkingestalt"

-----------------------
-- PlayerHasShield() --
-----------------------
	L["Shields"] = "Schilde"

---------------------
-- GetBlockValue() --
---------------------
	L["^(%d+) Block$"] = "^(%d+) Blocken"

------------------------
-- Item Scan Patterns --
------------------------
	L["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"Erh\195\182ht den Blockwert Eures Schildes um (%d+)"},
			{"Erh\195\182ht den Blockwert Eures Schilds um (%d+)"},
			{"Blockwert %+(%d+)"},
		}
	}

---------------------------
-- TankPoints Calculator --
---------------------------
-- Title
	L["TankPoints Calculator"] = "TankPoints Rechner"
	L["Left click to drag\nRight click to reset position"] = "Links klick zum ziehen\nRechtsklick um die Position zur\195\188ckzusetzen"

-- Buttons
	--L["Reset"] = true
	L["Close"] = "Schliessen"

-- Option frame box title
	L["Results"] = "Ergebnis"
	L["Player Stats"] = "Spieler Stats"
	L["Total Reduction"] = "Endg\195\188ltige Reduzierung"
	--L["(%)"] = true
	L["Max Health"] = "Max Leben"

-------------------------
-- TankPoints Tooltips --
-------------------------

---------------
-- Waterfall --
---------------

-------------------------
-- Calculator tooltips --
-------------------------
