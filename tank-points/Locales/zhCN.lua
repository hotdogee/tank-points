--[[
Name: TankPoints zhCN locale
Revision: $Revision: 84 $
Translated by: 
- 自由之名@白银之手
]]

local L = LibStub("AceLocale-3.0"):NewLocale("TankPoints", "zhCN")
if not L then return end

-- To translate AceLocale strings, replace true with the translation string
-- Before: ["Show Item ID"] = true
-- After:  ["Show Item ID"] = "显示物品编号"

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
	L["TankPoints"] = "坦点" 
	L["EH"] = "实命"  -- "Effective Health" is a long phrase
	L["EHB"] = "计挡实命"  -- "Effective Health with Block" is a very long phrase
	L["Block Value"] = "格挡值" 

--------------------
-- Character Info --
--------------------
-- Stats
	L["EH Block"] = "计挡实命" 
	L[" EH"] = "实命" 
	L[" TP"] = "坦点"  -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	L[" DR"] = "免伤"  -- concatenated after a school name for Damage Reductions, ex: "Nature DR"

-- TankPoints Stat Tooltip
	L["In "] = "在"  -- concatenated before stance name, ex: "In Battle Stance"
	L["Mob Stats"] = "怪物属性" 
	L["Mob Level"] = "怪物等级" 
	L["Mob Damage"] = "怪物伤害" 
	L["Mob Crit"] = "怪物爆击" 
	L["Mob Miss"] = "怪物未击中" 
	L["Per StatValue"] = "每等值属性坦点" 
	L["Per Stat"] = "每点属性坦点" 
	L["Click: show Per StatValue TankPoints"] = "点击：显示每等值属性坦点" 
	L["Click: show Per Stat TankPoints"] = "点击：显示每点属性坦点" 

-- Melee Reduction Tooltip
	L[" Damage Reduction"] = "物免"  -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	L["Player Level"] = "玩家等级" 
	L["Combat Table"] = "战斗数据表" 
	L["Crit"] = "被爆" 
	L["Crushing"] = "被碾" 
	L["Hit"] = "被击中" 

-- Block Value Tooltip
	L["Mob Damage before DR"] = "物免前伤害" 
	L["Mob Damage after DR"] = "物免后伤害" 
	L["Blocked Percentage"] = "格档单次免伤" 
	L["Equivalent Block Mitigation"] = "格档全程免伤" 
	L["Shield Block Up Time"] = "盾牌格挡有效时间" 

-- Spell TankPoints Tooltip
	L["Melee/Spell Damage Ratio"] = "近战/法术伤害比" 
	L["Left click: Show next school"] = "左键: 显示下一个属性" 
	L["Right click: Show strongest school"] = "右键: 显示最强的属性" 
	L[" resist "] = "抗性" 

-- Spell Reduction Tooltip
-- Toggle Calculator
	L["Open Calculator"] = "开启计算器" 
	L["Close Calculator"] = "关闭计算器" 

-- talent names
	L["imp. Shield Block"] = "强化盾挡"  -- short for Improved Shield Block

-- Effective Health stuff
	L["Effective Health"] = "实命" 
	L["Effective Health vs %s %s"] = "实命：%s %s"  -- Melee/Nature/Fire followed by EH
	L["Effective Health (with Block) vs Melee "] = "实命(计格挡)：近战"  -- followed by EHB
	L["Effective Health with Block"] = "实命(计格档)" 
	L["Effective Health - All Schools"] = "实命：所有抗性"  -- heading for the all schools of damage tooltip
	L["Health"] = "生命值"  -- player health
	L["Armor Reduction"] = "护甲减免"  -- how much armor reduces damage
	L["Resistance Reduction"] = "抗性减免"  -- reduction due to elemental resist (nature, etc)
	--["Talent/Buff/Stance Reductions"] = "其它减免"  -- things like stances, talents
	L["Your Reductions"] = "你的减免"  -- section header
	L["Guaranteed Reduction"] = "实际减免"  -- how much damage you're guaranteed to mitigate
	L["Mob attacks can critically hit"] = "怪物能爆击" 
	L["Mob attacks cannot critically hit"] = "怪物不能爆击" 
	L["Mob attacks will crush"] = "怪物能碾压" 
	L["Mob attacks should not crush"] = "怪物不能碾压" 

-- an array with lines to be put at the bottom of the Effective Health Tooltip
-- saying what EH is
	L["TP_EXPLANATION"] = {"坦点是计算几率属性的生命值。"}
	L["EH_EXPLANATION"] = {"实命是不计未命中/格档/躲闪/招架", "时能承受的原始伤害。"}
	L["EHB_EXPLANATION"] = {"计格挡的实命是不计未命中/躲闪/", "招架时能承受的原始伤害，取决于", "怪物类型并要求能格挡。"}
	L["See /tp optionswin to turn on tooltip."] = "查看 /tp optionswin 打开提示" 
        
---------------------------
-- Slash Command Options --
---------------------------
-- /tp config
	L["Options Window"] = "选项窗口" 
	L["Shows the Options Window"] = "显示选项窗口" 
-- /tp calc
	L["TankPoints Calculator"] = "坦点计算器" 
	L["Shows the TankPoints Calculator"] = "显示坦点计算器" 
-- /tp debug


-- /tp tooltip
	L["Tooltip Options"] = "提示框选项" 
	L["TankPoints tooltip options"] = "坦点提示框选项" 
-- /tp tooltip diff
	L["Show TankPoints Difference"] = "显示坦点差值" 
	L["Show TankPoints difference in item tooltips"] = "在物品提示框中显示坦点差值" 
-- /tp tooltip total
	L["Show TankPoints Total"] = "显示坦点总值" 
	L["Show TankPoints total in item tooltips"] = "在物品提示框中显示坦点总值" 
-- /tp tooltip drdiff
	L["Show Melee DR Difference"] = "显示近战物免差值" 
	L["Show Melee Damage Reduction difference in item tooltips"] = "在物品提示框中显示近战物免差值" 
-- /tp tooltip drtotal
	L["Show Melee DR Total"] = "显示近战物免总值" 
	L["Show Melee Damage Reduction total in item tooltips"] = "在物品提示框中显示近战物免总值" 
-- /tp tooltip ehdiff
	L["Show Effective Health Difference"] = "显示实际生命差值" 
	L["Show Effective Health difference in item tooltips"] = "在物品提市框中显示实际生命差值" 
-- /tp tooltip ehtotal
	L["Show Effective Health Total"] = "显示实际生命总值" 
	L["Show Effective Health total in item tooltips"] = "在物品提示框中显示实际生命总值" 
-- /tp tooltip ehbdiff
	L["Show Effective Health (with Block) Difference"] = "显示计算格挡的实际生命差值" 
	L["Show Effective Health (with Block) difference in item tooltips"] = "在物品提示框中显示计算格挡的实际生命差值" 
-- /tp tooltip ehbtotal
	L["Show Effective Health (with Block) Total"] = "显示计算格挡的实际生命总值" 
	L["Show Effective Health (with Block) total in item tooltips"] = "在物品提示框中显示计算格挡的实际生命总值" 
-- /tp player
	L["Player Stats"] = "玩家属性" 
	L["Change default player stats"] = "改变玩家默认属性" 
-- /tp player sbfreq
	--L["Shield Block Key Press Delay"] = "盾牌格挡按键频率" 
	--L["Sets the time in seconds after Shield Block finishes cooldown"] = "设定盾牌格挡技能按键的间隔时间" 
-- /tp mob
	L["Mob Stats"] = "怪物属性" 
	L["Change default mob stats"] = "改变怪物默认属性" 
-- /tp mob level
	L["Mob Level"] = "怪物等级" 
	L["Sets the level difference between the mob and you"] = "设定你和怪物的等级差距" 
-- /tp mob damage
-- /tp mob drdamage
	L["Mob Damage"] = "怪物伤害" 
	L["Sets mob's damage before damage reduction"] = "设定物免之前的怪物伤害" 
	L["Sets mob's damage after melee damage reduction"] = "设定怪物物免之后的怪物伤害" 
-- /tp mob speed
	L["Mob Attack Speed"] = "怪物攻击速度" 
	L["Sets mob's attack speed"] = "设定怪物的攻击速度" 
-- /tp mob default
	L["Restore Default"] = "还原为默认值" 
	L["Restores default mob stats"] = "还原默认怪物状态" 
	L["Restored Mob Stats Defaults"] = "怪物状态已经还原为默认值"  -- command feedback
-- /tp mob advanced
	L["Mob Stats Advanced Settings"] = "怪物状态高级设定" 
	L["Change advanced mob stats"] = "更进一步更改怪物状态" 
-- /tp mob advanced crit
	L["Mob Melee Crit"] = "怪物爆击" 
	L["Sets mob's melee crit chance"] = "设定怪物的爆击几率" 
-- /tp mob advanced critbonus
	L["Mob Melee Crit Bonus"] = "怪物爆击伤害加成" 
	L["Sets mob's melee crit bonus"] = "设定怪物的爆击伤害加成" 
-- /tp mob advanced miss
	L["Mob Melee Miss"] = "怪物未击中" 
	L["Sets mob's melee miss chance"] = "设定怪物的未击中几率" 
-- /tp mob advanced spellcrit
	L["Mob Spell Crit"] = "怪物法爆" 
	L["Sets mob's spell crit chance"] = "设定怪物法术的爆击几率" 
-- /tp mob advanced spellcritbonus
	L["Mob Spell Crit Bonus"] = "怪物法爆伤害奖励" 
	L["Sets mob's spell crit bonus"] = "设定怪物法术的爆击伤害奖励" 
-- /tp mob advanced spellmiss
	L["Mob Spell Miss"] = "怪物法术未击中" 
	L["Sets mob's spell miss chance"] = "设定怪物的法术未击中率" 

----------------------
-- GetDodgePerAgi() --
----------------------
	L["Cat Form"] = "猎豹形态" 

---------------------------
-- GetTalantBuffEffect() --
---------------------------
	L["Soul Link"] = "灵魂联结" 
	L["Voidwalker"] = "虚空行者" 
	L["Righteous Fury"] = "正义之怒" 
	L["Pain Suppression"] = "痛苦镇压" 
	L["Shield Wall"] = "盾墙" 
	L["Death Wish"] = "死亡之愿" 
	L["Recklessness"] = "鲁莽" 
	L["Cloak of Shadows"] = "暗影步" 

----------------------
-- AlterSourceData() --
----------------------
	L["Bear Form"] = "熊形态" 
	L["Dire Bear Form"] = "巨熊形态" 
	L["Moonkin Form"] = "枭兽形态" 

-----------------------
-- PlayerHasShield() --
-----------------------
	L["Shields"] = "盾" 

---------------------
-- GetBlockValue() --
---------------------
	L["^(%d+) Block$"] = "^(%d+)格挡$" 

------------------------
-- Item Scan Patterns --
------------------------
	L["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"使你的盾牌格挡值提高(%d+)点。"},
			{"%+(%d+) 格挡值"},
		}
	}

---------------------------
-- TankPoints Calculator --
---------------------------
-- Title
	L["TankPoints Calculator"] = "坦点计算器" 
	L["Left click to drag\nRight click to reset position"] = "左键点击以拖曳\n右键点击以重置位置" 

-- Buttons
	L["Reset"] = "重置" 
	L["Close"] = "关闭" 

-- Option frame box title
	L["Results"] = "结果" 
	L["Player Stats"] = "玩家属性" 
	L["Total Reduction"] = "总物免" 
	L["(%)"] = "(%)" 
	L["Max Health"] = "生命值" 
	L["Items"] = "物品" 

-------------------------
-- TankPoints Tooltips --
-------------------------
	L[" (Top/Bottom):"] = " (上/下):" 
	L[" (Main/Off):"] = " (主/副):" 
	L[" (Main+Off):"] = " (主+副):" 
	L["Gems"] = "珠宝" 

---------------
-- Waterfall --
---------------
	L["TankPoints Options"] = "坦点选项" 	

-------------------------
-- Calculator tooltips --
-------------------------
	L["Armor reduces physical damage taken"] = "护甲降低的物理伤害"
	L["TPCalc_PlayerStatsTooltip_MasteryRating"] = "精通等级会增加你的精通效果。\n精通将增加你格挡的机率。"
	L["TPCalc_PlayerStatsTooltip_Mastery"] = "精通将增加你格挡的机率。"

	L["Dodge rating improves your chance to dodge. A dodged attack does no damage"] = "闪躲等级提高你的闪躲机率。\n闪躲攻击不会受到伤害"
	L["Your chance to dodge an attack. A dodged attack does no damage"] = "你闪躲攻击的机率。\n闪躲攻击不会受到伤害"
	L["Parry rating improves your chance to parry. When you parry an attack, it and the next attack, will each hit for 50% less damage"] = "招架等级提高你招架的机率。\n当你招架一次攻击，他这次和下一次攻击，\n将减少50％的伤害"
	L["Your chance to parry an attack. When you parry an attack, it and the next attack, will each hit for 50% less damage"] = "招架攻击的机率。\n当你招架一次攻击，他这次和下一次攻击，\n将减少50％的伤害"
	L["Block rating improves your chance to block. Blocked attacks hit for 30% less damage"] = "格挡等级提高你的格挡机率。\n格挡攻击可减少命中的30%伤害"
	L["Your chance to block an attack. Blocked attacks hit for 30% less damage."] = "你格挡攻击的机率。\n格挡攻击命中可减少的30%伤害。"
	L["(removed) Block value was removed from the game in patch 4.0.1. All blocked attacks hit for 30% less damage"] = "格挡攻击可减少命中的30%伤害"
