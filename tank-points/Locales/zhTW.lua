-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints zhTW locale
Revision: $Revision: 95 $
Translated by: 
- CuteMiyu@bahamut.twbbs.org
- Whitetooth@Cenarius (hotdogee@bahamut.twbbs.org)
- 楓之刃@米奈希爾 (s8095324@yahoo.com.tw)
]]

local L = LibStub("AceLocale-3.0"):NewLocale("TankPoints", "zhTW")
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
	L["TankPoints"] = "TankPoints坦克點"
	L["EH"] = "EH"  -- "Effective Health" is a long phrase
	L["EHB"] = "EHB"  -- "Effective Health with Block" is a very long phrase
	L["Block Value"] = "格擋值" 

--------------------
-- Character Info --
--------------------
-- Stats
	L["EH Block"] = "EH Block" 
	L[" EH"] = "EH" 
	L[" TP"] = " TP"  -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	L[" DR"] = " 減傷"  -- concatenated after a school name for Damage Reductions, ex: "Nature DR"

-- TankPoints Stat Tooltip
	L["In "] = "在"  -- concatenated before stance name, ex: "In Battle Stance"
	L["Mob Stats"] = "怪物狀態" 
	L["Mob Level"] = "怪物等級" 
	L["Mob Damage"] = "怪物傷害" 
	L["Mob Crit"] = "怪物致命" 
	L["Mob Miss"] = "怪物未擊中" 
	L["Per StatValue"] = "每等價屬性的坦克點數" 
	L["Per Stat"] = "每一點屬性的坦克點數" 
	L["Click: show Per StatValue TankPoints"] = "點擊: 顯示每等價屬性坦克點" 
	L["Click: show Per Stat TankPoints"] = "點擊: 顯示每一點屬性坦克點" 

-- Melee Reduction Tooltip
	L[" Damage Reduction"] = "傷害減免"  -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	L["Player Level"] = "玩家等級" 
	L["Combat Table"] = "戰鬥列表" 
	L["Crit"] = "致命" 
	L["Crushing"] = "輾壓" 
	L["Hit"] = "命中" 
	L["Avoidance Diminishing Returns"] = "閃避數值遞減計算" 
	L["Only includes Dodge, Parry, and Missed"] = "只含閃躲、招架、未擊中" 

-- Block Value Tooltip
	L["Mob Damage before DR"] = "減傷前怪物傷害" 
	L["Mob Damage after DR"] = "減傷後怪物傷害" 
	L["Blocked Percentage"] = "格檔率" 
	L["Equivalent Block Mitigation"] = "等值格檔減傷" 
	L["Shield Block Up Time"] = "盾牌格檔作用時間" 

-- Spell TankPoints Tooltip
	L["Melee/Spell Damage Ratio"] = "近戰/法術 傷害比率" 
	L["Left click: Show next school"] = "左鍵: 顯示下一個屬性" 
	L["Right click: Show strongest school"] = "右鍵: 顯示最強的屬性" 
	L[" resist "] = "抗性" 

-- Spell Reduction Tooltip
-- Toggle Calculator
	L["Open Calculator"] = "開啟計算機" 
	L["Close Calculator"] = "關閉計算機" 

-- talent names
	L["imp. Shield Block"] = "強化盾牌格擋"  -- short for Improved Shield Block

-- Effective Health stuff
--	L["Effective Health"] = true
--	L["Effective Health vs %s %s"] = true -- Melee/Nature/Fire followed by EH
--	L["Effective Health (with Block) vs Melee "] = true -- followed by EHB
--	L["Effective Health with Block"] = "Effective Health w/ Block"
--	L["Effective Health - All Schools"] = true -- heading for the all schools of damage tooltip
	L["Health"] = "生命值"  -- player health
	L["Armor Reduction"] = "護甲減傷"  -- how much armor reduces damage
	L["Resistance Reduction"] = "抗性減傷"  -- reduction due to elemental resist (nature, etc)
	L["Talent/Buff/Stance Reductions"] = "天賦/Buff/形態 減傷"  -- things like stances, talents
	L["Your Reductions"] = "你的減傷量"  -- section header
	L["Guaranteed Reduction"] = "必定減傷"  -- how much damage you're guaranteed to mitigate
	L["Mob attacks can critically hit"] = "怪物攻擊可造成致命一擊" 
	L["Mob attacks cannot critically hit"] = "怪物攻擊無法造成致命一擊" 
	L["Mob attacks will crush"] = "怪物攻擊有可能造成碾壓" 
	L["Mob attacks should not crush"] = "怪物攻擊無法造成碾壓" 

-- an array with lines to be put at the bottom of the Effective Health Tooltip
-- saying what EH is
	L["TP_EXPLANATION"] = {"坦克點數為測量相對於你的生命值的", "理論減傷程度 (閃躲、招架...等)。"}
--	L["EH_EXPLANATION"] = {"Effective Health 為在沒有任何減傷的情況下", "(未命中/閃躲/招架/格擋)，", "你能承受的最大傷害值。"}
	L["EHB_EXPLANATION"] = {"Effective Health with Block 為在接受格擋減傷後，", "你能承受的最大傷害值。"}
	L["See /tp optionswin to turn on tooltip."] = "請參考 /tp optionswin 來設定提示訊息" 
        
---------------------------
-- Slash Command Options --
---------------------------
-- /tp config
	L["Options Window"] = "選項視窗" 
	L["Shows the Options Window"] = "顯示選項視窗" 
-- /tp calc
	L["TankPoints Calculator"] = "TankPoints坦克點計算機" 
	L["Shows the TankPoints Calculator"] = "顯示坦克點計算機" 
-- /tp debug
	L["Enable Debugging"] = "啟用偵錯"
	L["Toggle the display of debug messages"] = "切換顯示偵錯訊息"
-- /tp tooltip
	L["Tooltip Options"] = "工具提示選項" 
	L["TankPoints tooltip options"] = "坦克點工具提示選項" 
-- /tp tooltip diff
	L["Show TankPoints Difference"] = "顯示工具提示差異" 
	L["Show TankPoints difference in item tooltips"] = "在物品工具提示中顯示坦克點差值" 
-- /tp tooltip total
	L["Show TankPoints Total"] = "顯示工具提示總共" 
	L["Show TankPoints total in item tooltips"] = "在物品工具提示中顯示坦克點總值" 
-- /tp tooltip drdiff
	L["Show Melee DR Difference"] = "顯示近戰減傷差異" 
	L["Show Melee Damage Reduction difference in item tooltips"] = "在物品提示顯示近戰減傷差異" 
-- /tp tooltip drtotal
	L["Show Melee DR Total"] = "顯示近戰減傷總值" 
	L["Show Melee Damage Reduction total in item tooltips"] = "在物品提示顯示近戰減傷總值" 
-- /tp tooltip ehdiff
	L["Show Effective Health Difference"] = "顯示 EH 差異" 
	L["Show Effective Health difference in item tooltips"] = "在物品提示顯示 EH 差異" 
-- /tp tooltip ehtotal
	L["Show Effective Health Total"] = "顯示 EH 總量" 
	L["Show Effective Health total in item tooltips"] = "在物品提示顯示 EH 總量" 
-- /tp tooltip ehbdiff
	L["Show Effective Health (with Block) Difference"] = "顯示 EH (有格擋) 差異" 
	L["Show Effective Health (with Block) difference in item tooltips"] = "在物品提示顯示 EH (有格擋) 差異" 
-- /tp tooltip ehbtotal
	L["Show Effective Health (with Block) Total"] = "顯示 EH (有格擋) 總量" 
	L["Show Effective Health (with Block) total in item tooltips"] = "在物品提示顯示 EH (有格擋) 總量" 
-- /tp player
	L["Player Stats"] = "玩家狀態" 
	L["Change default player stats"] = "改變預設玩家狀態" 
-- /tp player sbfreq
	L["Shield Block Key Press Delay"] = "盾牌格擋使用延遲" 
	L["Sets the time in seconds after Shield Block finishes cooldown"] = "設定盾牌格擋冷卻完成後幾秒才按" 
-- /tp mob
	L["Mob Stats"] = "怪物狀態" 
	L["Change default mob stats"] = "改變預設怪物狀態" 
-- /tp mob level
	L["Mob Level"] = "怪物等級" 
	L["Sets the level difference between the mob and you"] = "設定你和怪物的等級差距" 
-- /tp mob damage
-- /tp mob drdamage
	L["Mob Damage"] = "怪物傷害" 
	L["Sets mob's damage before damage reduction"] = "設定減傷之前的怪物傷害" 
	L["Sets mob's damage after melee damage reduction"] = "設定近戰減傷之後的怪物傷害" 
-- /tp mob speed
	L["Mob Attack Speed"] = "怪物攻速" 
	L["Sets mob's attack speed"] = "設定怪物攻速" 
-- /tp mob default
	L["Restore Default"] = "還原為預設值" 
	L["Restores default mob stats"] = "還原預設怪物狀態" 
	L["Restored Mob Stats Defaults"] = "怪物狀態已經還原為預設值"  -- command feedback
-- /tp mob advanced
	L["Mob Stats Advanced Settings"] = "怪物狀態進階設定" 
	L["Change advanced mob stats"] = "更進一步更改怪物狀態" 
-- /tp mob advanced crit
	L["Mob Melee Crit"] = "怪物近戰致命" 
	L["Sets mob's melee crit chance"] = "設定怪物近戰的致命一擊機率" 
-- /tp mob advanced critbonus
	L["Mob Melee Crit Bonus"] = "怪物近戰致命傷害加成" 
	L["Sets mob's melee crit bonus"] = "設定怪物近戰的致命一擊傷害加成" 
-- /tp mob advanced miss
	L["Mob Melee Miss"] = "怪物近戰未擊中" 
	L["Sets mob's melee miss chance"] = "設定怪物近戰的未擊中機率" 
-- /tp mob advanced spellcrit
	L["Mob Spell Crit"] = "怪物法術致命" 
	L["Sets mob's spell crit chance"] = "設定怪物法術的致命一擊機率" 
-- /tp mob advanced spellcritbonus
	L["Mob Spell Crit Bonus"] = "怪物法術致命傷害加成" 
	L["Sets mob's spell crit bonus"] = "設定怪物法術的致命一擊傷害加成" 
-- /tp mob advanced spellmiss
	L["Mob Spell Miss"] = "怪物法術未擊中" 
	L["Sets mob's spell miss chance"] = "設定怪物的法術未擊中率" 

----------------------
-- GetDodgePerAgi() --
----------------------
	L["Cat Form"] = "獵豹形態" 

---------------------------
-- GetTalantBuffEffect() --
---------------------------
	L["Soul Link"] = "靈魂鏈結" 
	L["Voidwalker"] = "虛空行者" 
	L["Righteous Fury"] = "正義之怒" 
	L["Pain Suppression"] = "痛苦鎮壓" 
	L["Shield Wall"] = "盾牆" 
	L["Death Wish"] = "死亡之願" 
	L["Recklessness"] = "魯莽" 
	L["Cloak of Shadows"] = "暗影披風" 

----------------------
-- AlterSourceData() --
----------------------
	L["Bear Form"] = "熊形態" 
	L["Dire Bear Form"] = "巨熊形態" 
	L["Moonkin Form"] = "梟獸形態" 

-----------------------
-- PlayerHasShield() --
-----------------------
	L["Shields"] = "盾" 

---------------------
-- GetBlockValue() --
---------------------
	L["^(%d+) Block$"] = "^(%d+)格擋$" 

------------------------
-- Item Scan Patterns --
------------------------
	L["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"使你盾牌的格擋值提高(%d+)點。"},
			{"%+(%d+) 格擋值"},
		}
	}

---------------------------
-- TankPoints Calculator --
---------------------------
-- Title
	L["TankPoints Calculator"] = "TankPoints坦克點計算機" 
	L["Left click to drag\nRight click to reset position"] = "左鍵點擊以拖曳\n右鍵點擊以重置位置" 

-- Buttons
	L["Reset"] = "重置" 
	L["Close"] = "關閉" 

-- Option frame box title
	L["Results"] = "計算結果" 
	L["Player Stats"] = "玩家狀態" 
	L["Total Reduction"] = "總共減傷" 
	L["(%)"] = "(%)" 
	L["Max Health"] = "最大生命力" 
	L["Items"] = "物品" 

-------------------------
-- TankPoints Tooltips --
-------------------------
	L[" (Top/Bottom):"] = " (上面/下面):" 
	L[" (Main/Off):"] = " (主手/副手):" 
	L[" (Main+Off):"] = " (主手+副手):" 
	L["Gems"] = "寶石" 

---------------
-- Waterfall --
---------------
	L["TankPoints Options"] = "TankPoints選項" 

-------------------------
-- Calculator tooltips --
-------------------------
	L["Armor reduces physical damage taken"] = "護甲降低的物理傷害"
	L["TPCalc_PlayerStatsTooltip_MasteryRating"] = "精通等級會增加你的精通效果。\n精通將增加你格擋的機率。"
	L["TPCalc_PlayerStatsTooltip_Mastery"] = "精通將增加你格擋的機率。"

	L["Dodge rating improves your chance to dodge. A dodged attack does no damage"] = "閃躲等級提高你的閃躲機率。\n閃躲攻擊不會受到傷害"
	L["Your chance to dodge an attack. A dodged attack does no damage"] = "你閃躲攻擊的機率。\n閃躲攻擊不會受到傷害"
	L["Parry rating improves your chance to parry. When you parry an attack, it and the next attack, will each hit for 50% less damage"] = "招架等級提高你招架的機率。\n當你招架一次攻擊，他這次和下一次攻擊，\n將減少50％的傷害"
	L["Your chance to parry an attack. When you parry an attack, it and the next attack, will each hit for 50% less damage"] = "招架攻擊的機率。\n當你招架一次攻擊，他這次和下一次攻擊，\n將減少50％的傷害"
	L["Block rating improves your chance to block. Blocked attacks hit for 30% less damage"] = "格擋等級提高你的格擋機率。\n格擋攻擊可減少命中的30%傷害"
	L["Your chance to block an attack. Blocked attacks hit for 30% less damage."] = "你格擋攻擊的機率。\n格擋攻擊命中可減少的30%傷害。"
	L["(removed) Block value was removed from the game in patch 4.0.1. All blocked attacks hit for 30% less damage"] = "格擋攻擊可減少命中的30%傷害"
