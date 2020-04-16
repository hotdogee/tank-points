-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
	Name: TankPoints frFR locale
	Revision: $Revision: 58 $
Translated by: 
- Tixu@Curse
]]

local L = LibStub("AceLocale-3.0"):NewLocale("TankPoints", "frFR")
if not L then return end

-- To translate AceLocale strings, replace true with the translation string
-- Before: ["Show Item ID"] = true
-- After: ["Show Item ID"] = "顯示物品編號"

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



	L["Block Value"] = "blocage" 

--------------------
-- Character Info --
--------------------
-- Stats


	L[" TP"] = " TP"  -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	L[" DR"] = "-"  -- concatenated after a school name for Damage Reductions, ex: "Nature DR"

-- TankPoints Stat Tooltip
	L["In "] = "En "  -- concatenated before stance name, ex: "In Battle Stance"
	L["Mob Stats"] = "Stats opposant" 
	L["Mob Level"] = "Niveau opposant" 
	L["Mob Damage"] = "Dommage" 
	L["Mob Crit"] = "Critique opposant" 
	L["Mob Miss"] = "Rat\195\169 opposant" 
	L["Per StatValue"] = "Par score" 
	L["Per Stat"] = "Par pourcentage" 
        --["Click: show Per StatValue TankPoints"] = "" 
        --["Click: show Per Stat TankPoints"] = "" 

-- Melee Reduction Tooltip
	L[" Damage Reduction"] = ": r\195\169duction des dommages"  -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	L["Player Level"] = "Niveau du joueur" 
	L["Combat Table"] = "Stats de combat" 
	L["Crit"] = "Critique" 
	L["Crushing"] = "D\195\169vastateur (\195\169crase)" 
	L["Hit"] = "Toucher" 



-- Block Value Tooltip
	L["Mob Damage before DR"] = "Dommages entrants avant r\195\169duction" 
	L["Mob Damage after DR"] = "Dommages par\195\168s r\195\169duction" 
	L["Blocked Percentage"] = "Pourcentage bloqu\195\169s" 
	L["Equivalent Block Mitigation"] = "Equivalence de r\195\169duction" 


-- Spell TankPoints Tooltip
	L["Melee/Spell Damage Ratio"] = "Ratio m\195\169l\195\169e/sort" 
	L["Left click: Show next school"] = "Click gauche: afficher l'\195\169cole suivante" 
	L["Right click: Show strongest school"] = "Click droit: afficher la meilleure \195\169cole " 


-- Spell Reduction Tooltip
-- Toggle Calculator
	L["Open Calculator"] = "Ouvrir Calculatrice" 
	L["Close Calculator"] = "Fermer Calculatrice" 

-- talent names

-- Effective Health stuff

-- an array with lines to be put at the bottom of the Effective Health Tooltip
-- saying what EH is
        
---------------------------
-- Slash Command Options --
---------------------------
-- /tp config
-- /tp calc
	-- ["TankPoints Calculator"] = true,
	L["Shows the TankPoints Calculator"] = "Ouvre le calculateur de TankPoints" 
-- /tp debug
-- /tp tooltip
	L["Tooltip Options"] = "Option Infobulle" 
	L["TankPoints tooltip options"] = "Options pour les infobulles" 
-- /tp tooltip diff
	L["Show TankPoints Difference"] = "Afficher les diff\195\169rences" 
	L["Show TankPoints difference in item tooltips"] = "Afficher les diff\195\169rences entre objets dans les infobulles" 
-- /tp tooltip total
	L["Show TankPoints Total"] = "Afficher total" 
	L["Show TankPoints total in item tooltips"] = "Afficher le TankPoint total des objets dans les infobulles" 
-- /tp mob
	-- ["Mob Stats"] = true,
	L["Change default mob stats"] = "Changer les statistiques de votre opposant" 
-- /tp mob level
	-- ["Mob Level"] = true,
	L["Sets the level difference between the mob and you"] = "D\195\169finir la diff\195\169rence de niveau entre vous et votre opposant" 
-- /tp mob damage
-- /tp mob drdamage
	-- ["Mob Damage"] = true,
	L["Sets mob's damage before damage reduction"] = "D\195\169finir les dommages moyens de votre opposant" 
-- /tp mob speed
-- /tp mob default
	L["Restore Default"] = "R\195\169initialiser" 
	L["Restores default mob stats"] = "R\195\169initialiser les statistiques de votre opposant" 
	L["Restored Mob Stats Defaults"] = "Statistiques de votre opposant r\195\169initilis\195\169es"  -- command feedback
-- /tp mob advanced
	-- ["Mob Stats Advanced Settings"] = true,
	L["Change advanced mob stats"] = "Modifier les statistiques avanc\195\169es pour l'opposant" 
-- /tp mob advanced crit
	-- ["Mob Melee Crit"] = true,
	L["Sets mob's melee crit chance"] = "D\195\169finir les chances de coup critique en m\195\169l\195\169e de l'opposant" 
-- /tp mob advanced critbonus
	-- ["Mob Melee Crit Bonus"] = true,
	L["Sets mob's melee crit bonus"] = "D\195\169finir le bonus de coup critique en m\195\169l\195\169e de l'opposant" 
-- /tp mob advanced miss
	-- ["Mob Melee Miss"] = true,
	L["Sets mob's melee miss chance"] = "D\195\169finir les chances de rat\195\169 en m\195\169l\195\169e de l'opposant" 
-- /tp mob advanced spellcrit
	-- ["Mob Spell Crit"] = true,
	L["Sets mob's spell crit chance"] = "D\195\169finir les chances de critique des sorts de l'opposant" 
-- /tp mob advanced spellcritbonus
	-- ["Mob Spell Crit Bonus"] = true,
	L["Sets mob's spell crit bonus"] = "D\195\169finir le bonus de critique des sorts de l'opposant" 
-- /tp mob advanced spellmiss
	-- ["Mob Spell Miss"] = true,
	L["Sets mob's spell miss chance"] = "D\195\169finir les chances de l'opposant de rater son sort" 

----------------------
-- GetDodgePerAgi() --
----------------------
	L["Cat Form"] = "Forme de félin" 

---------------------------
-- GetTalantBuffEffect() --
---------------------------
	L["Soul Link"] = "Lien spirituel" 
	L["Voidwalker"] = "Marcheur du Vide" 
	L["Righteous Fury"] = "Fureur vertueuse" 
	L["Pain Suppression"] = "Suppression de la douleur" 
	L["Shield Wall"] = "Mur protecteur" 
	L["Death Wish"] = "Souhait mortel" 
	L["Recklessness"] = "Témérité" 
	L["Cloak of Shadows"] = "Cape d'ombre" 

-----------------------
-- AlterSourceData() --
-----------------------
	L["Bear Form"] = "Forme d’ours" 
	L["Dire Bear Form"] = "Forme d’ours redoutable" 
	L["Moonkin Form"] = "Forme de sélénien" 

-----------------------
-- PlayerHasShield() --
-----------------------
	L["Shields"] = "Boucliers" 

---------------------
-- GetBlockValue() --
---------------------
	L["^(%d+) Block$"] = "Bloquer.- (%d+)" 

------------------------
-- Item Scan Patterns --
------------------------
	L["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"Augmente la valeur de blocage de votre bouclier de (%d+)"},
			{"+(%d+) Valeur de blocage"},
			{"+(%d+) \195\160 la valeur de blocage"},
		}
	}

---------------------------
-- TankPoints Calculator --
---------------------------
-- Title
	L["TankPoints Calculator"] = "Calculatrice TankPoint" 
	L["Left click to drag\nRight click to reset position"] = "Click-gauche pour d\195\169placer\nClick-droit pour initialiser la position" 

-- Buttons
	L["Reset"] = "R\195\169initialiser" 
	L["Close"] = "Fermer" 

-- Option frame box title
	L["Results"] = "R\195\169sultats" 
	L["Player Stats"] = "Statistiques du joueur" 
	L["Total Reduction"] = "R\195\169duction totale" 
	--["(%)"] = true,
	L["Max Health"] = "Vie max" 
	L["Items"] = "Objets" 

-------------------------
-- TankPoints Tooltips --
-------------------------
	L[" (Top/Bottom):"] = " (Haut/Bas):" 
	L[" (Main/Off):"] = " (Main droite/gauche):" 
	L[" (Main+Off):"] = " (Main droite+gauche):" 
	L["Gems"] = "Gemmes" 

---------------
-- Waterfall --
---------------

-------------------------
-- Calculator tooltips --
-------------------------
