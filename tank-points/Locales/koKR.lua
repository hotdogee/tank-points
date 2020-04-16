-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
	Name: TankPoints koKR locale
	Revision: $Revision: 84 $
Translated by: 
- fenlis(jungseop.park@gmail.com)
]]

local L = LibStub("AceLocale-3.0"):NewLocale("TankPoints", "koKR")
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


-------------
-- General --
-------------
	L["TankPoints"] = "탱킹점수" 
	L["EH"] = "EH"  -- "Effective Health" is a long phrase
	L["EHB"] = "EHB"  -- "Effective Health with Block" is a very long phrase
	L["Block Value"] = "피해 방어량" 

--------------------
-- Character Info --
--------------------
-- Stats
	L["EH Block"] = "EH 방어도" 
	L[" EH"] = " EH" 
	L[" TP"] =" TP"  -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	L[" DR"] = " DR"  -- concatenated after a school name for Damage Reductions, ex: "Nature DR"

-- TankPoints Stat Tooltip
	L["In "] = "상태: "  -- concatenated before stance name, ex: "In Battle Stance"
	L["Mob Stats"] = "몹 능력치" 
	L["Mob Level"] = "몹 레벨" 
	L["Mob Damage"] = "몹 공격력" 
	L["Mob Crit"] = "몹 치명타" 
	L["Mob Miss"] = "몹 회피" 
	L["Per StatValue"] = "능력치값 당" 
	L["Per Stat"] = "능력치 당" 
	L["Click: show Per StatValue TankPoints"] = "클릭: 능력치당 탱킹점수 표시" 
	L["Click: show Per Stat TankPoints"] = "클릭: 능력당 탱킹점수 표시" 

-- Melee Reduction Tooltip
	L[" Damage Reduction"] = " 피해 감소량"  -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	L["Player Level"] = "플레이어 레벨" 
	L["Combat Table"] = "전투표" 
	L["Crit"] = "치명타" 
	L["Crushing"] = "강타" 
	L["Hit"] = "적중" 

-- Block Value Tooltip
	L["Mob Damage before DR"] = "DR 적용 전 몹 피해랑" 
	L["Mob Damage after DR"] = "DR 적용 후 몹 피해랑" 
	L["Blocked Percentage"] = "방어율" 
	L["Equivalent Block Mitigation"] = "동등한 방어 감소" 
	L["Shield Block Up Time"] = "방패 막기 사용 시간" 

-- Spell TankPoints Tooltip
	L["Melee/Spell Damage Ratio"] = "근접/주문 피해율" 
	L["Left click: Show next school"] = "좌클릭: 다음 속성 표시" 
	L["Right click: Show strongest school"] = "우클릭: 최강 속성 표시" 
	L[" resist "] = " 저항 " 

-- Spell Reduction Tooltip
-- Toggle Calculator
	L["Open Calculator"] = "계산기 열기" 
	L["Close Calculator"] = "계산기 닫기" 

-- talent names
	L["imp. Shield Block"] = "막패 막기 연마"  -- short for Improved Shield Block

-- Effective Health stuff
	L["Effective Health"] = "유효 생명력" 
	L["Effective Health vs %s %s"] = "유효 생명력 vs %s %s"  -- Melee/Nature/Fire followed by EH
	L["Effective Health (with Block) vs Melee "] = "유효 생명력 (방어도 포함) vs 근접 "  -- followed by EHB
	L["Effective Health with Block"] = "유효 생명력(방어도 포함)" 
	L["Effective Health - All Schools"] = "유효 생명력 - 모든 속성"  -- heading for the all schools of damage tooltip
	L["Health"] = "생명력"  -- player health
	L["Armor Reduction"] = "방어도 감소"  -- how much armor reduces damage
	L["Resistance Reduction"] = "저항력 감소"  -- reduction due to elemental resist (nature, etc)
	--L["Talent/Buff/Stance Reductions"] = "기타 감소"  -- things like stances, talents
	L["Your Reductions"] = "당신의 감소"  -- section header
	L["Guaranteed Reduction"] = "보증 감소"  -- how much damage you're guaranteed to mitigate
	L["Mob attacks can critically hit"] = "몹 공격이 치명타일 수 있습니다." 
	L["Mob attacks cannot critically hit"] = "몹 공격이 치명타가 아닐 수 있습니다." 
	L["Mob attacks will crush"] = "몹 공격이 강타일 것입니다." 
	L["Mob attacks should not crush"] = "몹 공격이 강타가 아닐 것입니다." 

-- an array with lines to be put at the bottom of the Effective Health Tooltip
-- saying what EH is
	L["TP_EXPLANATION"] = {"TankPoints is a measure of your theoretical", "mitigation (dodge, parry, etc) in proportion", "to your health."}
	L["EH_EXPLANATION"] = {"Effective Health is how much raw", "damage you can take without", "a miss/block/dodge/parry."}
	L["EHB_EXPLANATION"] = {"Effective Health with Block is how much raw", "damage you can take without a miss/dodge/parry", "and only guaranteed blocks. Dependant", "on mob stats and you being able to block."}
	L["See /tp optionswin to turn on tooltip."] = "See /tp optionswin to turn on tooltip." 
        
---------------------------
-- Slash Command Options --
---------------------------
-- /tp config
	L["Options Window"] = "설정창" 
	L["Shows the Options Window"] = "설정창을 표시합니다." 
-- /tp calc
	L["TankPoints Calculator"] = "탱킹점수 계산기" 
	L["Shows the TankPoints Calculator"] = "탱킹점수 계산기를 표시합니다." 
-- /tp debug
-- /tp tooltip
	L["Tooltip Options"] = "툴팁 설정" 
	L["TankPoints tooltip options"] = "탱킹점수 툴팁 설정입니다." 
-- /tp tooltip diff
	L["Show TankPoints Difference"] = "탱킹점수 차이 표시" 
	L["Show TankPoints difference in item tooltips"] = "아이템 툴팁에 탱킹점수 차이를 표시합니다." 
-- /tp tooltip total
	L["Show TankPoints Total"] = "탱킹점수 합계 표시" 
	L["Show TankPoints total in item tooltips"] = "아이템 툴팁에 탱킹점수 합계를 표시합니다." 
-- /tp tooltip drdiff
	L["Show Melee DR Difference"] = "근접 피해 감소량 차이 표시" 
	L["Show Melee Damage Reduction difference in item tooltips"] = "아이템 툴팁에 근접 피해 감소량 차이를 표시합니다." 
-- /tp tooltip drtotal
	L["Show Melee DR Total"] = "근접 총 피해 감소량 표시" 
	L["Show Melee Damage Reduction total in item tooltips"] = "아이템 툴팁에 근접 총 피해 감소량을 표시합니다." 
-- /tp tooltip ehdiff
	L["Show Effective Health Difference"] = "유효 생명력 차이 표시" 
	L["Show Effective Health difference in item tooltips"] = "아이템 툴팁에 유효 생명력 차이를 표시합니다." 
-- /tp tooltip ehtotal
	L["Show Effective Health Total"] = "유효 생명력 합계 표시" 
	L["Show Effective Health total in item tooltips"] = "아이템 툴팁에 유효 생명력 합계를 표시합니다." 
-- /tp tooltip ehbdiff
	L["Show Effective Health (with Block) Difference"] = "유효 생명력(방어도 포함) 차이 표시" 
	L["Show Effective Health (with Block) difference in item tooltips"] = "아이템 툴팁에 유효 생명력(방어도 포함)을 표시합니다." 
-- /tp tooltip ehbtotal
	L["Show Effective Health (with Block) Total"] = "유효 생명력(방어도 포함) 합계 표시" 
	L["Show Effective Health (with Block) total in item tooltips"] = "아이템 툴팁에 유효 생명력(방어도 포함) 합계를 표시합니다." 
-- /tp player
	L["Player Stats"] = "플레이어 능력치" 
	L["Change default player stats"] = "기본 플레이어 능력치를 변경합니다." 
-- /tp player sbfreq
	--["Shield Block Key Press Delay"] = "방패 막기 누름 빈도" 
	--["Sets the time in seconds after Shield Block finishes cooldown"] = "방패 막기 버튼을 누르는 초단위 간격을 설정합니다." 
-- /tp mob
	L["Mob Stats"] = "몹 능력치" 
	L["Change default mob stats"] = "기본 몹 능력치를 변경합니다." 
-- /tp mob level
	L["Mob Level"] = "몹 레벨" 
	L["Sets the level difference between the mob and you"] = "몹과의 레벨 차이를 설정합니다." 
-- /tp mob damage
-- /tp mob drdamage
	L["Mob Damage"] = "몹 공격력" 
	L["Sets mob's damage before damage reduction"] = "피해 감소 전 몹의 공격력을 설정합니다." 
	L["Sets mob's damage after melee damage reduction"] = "근접 피해 감소 후 몹의 공격력을 설정합니다." 
-- /tp mob speed
	L["Mob Attack Speed"] = "몹 공격 속도" 
	L["Sets mob's attack speed"] = "몹의 공격 속도를 설정합니다." 
-- /tp mob default
	L["Restore Default"] = "기본값 복원" 
	L["Restores default mob stats"] = "기본 몹 능력치를 되돌립니다." 
	L["Restored Mob Stats Defaults"] = "몹 능력치가 기본값으로 복원되었습니다."  -- command feedback
-- /tp mob advanced
	L["Mob Stats Advanced Settings"] = "몹 능력치 고급 설정" 
	L["Change advanced mob stats"] = "몹 능력치에 대한 고급 설정을 변경합니다." 
-- /tp mob advanced crit
	L["Mob Melee Crit"] = "몹 근접 치명타" 
	L["Sets mob's melee crit chance"] = "몹의 근접 치명타율을 설정하세요." 
-- /tp mob advanced critbonus
	L["Mob Melee Crit Bonus"] = "몹 근접 치명타 보너스" 
	L["Sets mob's melee crit bonus"] = "몹의 근접 치명타 보너스를 설정하세요." 
-- /tp mob advanced miss
	L["Mob Melee Miss"] = "몹 근접 회피" 
	L["Sets mob's melee miss chance"] = "몹의 근접 회피율을 설정하세요." 
-- /tp mob advanced spellcrit
	L["Mob Spell Crit"] = "몹 주문 극대화" 
	L["Sets mob's spell crit chance"] = "몹의 주문 극대화율을 설정하세요." 
-- /tp mob advanced spellcritbonus
	L["Mob Spell Crit Bonus"] = "몹 주문 극대화 보너스" 
	L["Sets mob's spell crit bonus"] = "몹의 주문 극대화 보너스를 설정하세요." 
-- /tp mob advanced spellmiss
	L["Mob Spell Miss"] = "몹 주문 회피" 
	L["Sets mob's spell miss chance"] = "몹의 주문 회피율을 설정하세요." 

----------------------
-- GetDodgePerAgi() --
----------------------
	L["Cat Form"] = "표범 변신" 

---------------------------
-- GetTalantBuffEffect() --
---------------------------
	L["Soul Link"] = "영혼의 고리" 
	L["Voidwalker"] = "보이드워커" 
	L["Righteous Fury"] = "정의의 격노" 
	L["Pain Suppression"] = "고통 억제" 
	L["Shield Wall"] = "방패의 벽" 
	L["Death Wish"] = "죽음의 소원" 
	L["Recklessness"] = "무모한 희생" 
	L["Cloak of Shadows"] = "그림자 망토" 

----------------------
-- AlterSourceData() --
----------------------
	L["Bear Form"] = "곰 변신" 
	L["Dire Bear Form"] = "광포한 곰 변신" 
	L["Moonkin Form"] = "달빛야수 변신" 

-----------------------
-- PlayerHasShield() --
-----------------------
	L["Shields"] = "방패" 

---------------------
-- GetBlockValue() --
---------------------
	L["^(%d+) Block$"] = "^(%d+)의 피해 방어$" 

------------------------
-- Item Scan Patterns --
------------------------
	L["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"방패의 피해 방어량이 (%d+)만큼 증가합니다."},
			{"피해 방어량 %+(%d+)"},
		}
	}

---------------------------
-- TankPoints Calculator --
---------------------------
-- Title
	L["TankPoints Calculator"] = "탱킹점수 계산기" 
	L["Left click to drag\nRight click to reset position"] = "이동하려면 좌클릭\n위치를 초기화하려면 우클릭하세요." 

-- Buttons
	L["Reset"] = "초기화" 
	L["Close"] = "닫기" 

-- Option frame box title
	L["Results"] = "결과" 
	L["Player Stats"] = "플레이어 능력치" 
	L["Total Reduction"] = "총 감소량" 
	L["(%)"] = "(%)" 
	L["Max Health"] = "최대 생명력" 
	L["Items"] = "아이템" 

-------------------------
-- TankPoints Tooltips --
-------------------------
	L[" (Top/Bottom):"] = " (위/아래):" 
	L[" (Main/Off):"] = " (주/보조):" 
	L[" (Main+Off):"] = " (주+보조):" 
	L["Gems"] = "보석" 

---------------
-- Waterfall --
---------------
	L["TankPoints Options"] = "TankPoints 설정" 	

-------------------------
-- Calculator tooltips --
-------------------------
