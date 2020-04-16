-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints
Description: Calculates and shows your TankPoints in the PaperDall Frame
Revision: $Revision: 238 $
Author: Whitetooth
Email: hotdogee [at] gmail [dot] com
LastUpdate: $Date: 2014-09-01 09:06:30 +0800 (Mon, 01 Sep 2014) $
]]

---------------
-- Libraries --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("TankPoints"); --Get the localization for our addon
local StatLogic = LibStub("LibStatLogic-1.2");

--------------------
-- AceAddon Setup --
--------------------
-- AceAddon Initialization
TankPoints = LibStub("AceAddon-3.0"):NewAddon("TankPoints", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "SpaceDebug-3.0");
local TankPoints = TankPoints;

TankPoints.version = "5.1.0 (r"..gsub("$Revision: 238 $", "$Revision: (%d+) %$", "%1")..")";
--Append "a" (alpha) to revision if it's alpha. The wowace packager will convert alpha..end-alpha into a block level comment
--@alpha@
TankPoints.version = "5.1.0 (r"..gsub("$Revision: 238 $", "$Revision: (%d+) %$", "%1").."a)";
--@end-alpha@
TankPoints.date = gsub("$Date: 2014-09-01 09:06:30 +0800 (Mon, 01 Sep 2014) $", "^.-(%d%d%d%d%-%d%d%-%d%d).-$", "%1");


--[[
	The TankPoints has 3 main methods that do the bulk of the work
		- GetSourceData(TP_MELEE) retrieves the players current stats and attributes
		- AlterSourceData(dataTable, changesTable) applies any desired changes (stored in changesTable) to dataTable
		- GetTankPoints(dataTable, TP_MELEE) calculates the various TankPoints values and stores it in dataTable

	GetSourceData(TP_MELEE, [schoolOfMagic], [forceShield]) 
		This function is normally only ever called by the helper function UpdateDataTable.
		This method determintes the various attributes of the player (health, dodge, block chance, etc)
		and stores it in the passed table. 
		This this function is normally called by UpdateDataTable, which uses it to update the
		member varialbe TP_MELEE. Because of this, TP_MELEE is the variable that is understood to hold
		the player's current unmodified attributes.
		
	AlterSourceData(tpTable, changes, [forceShield])
		This function is used to apply changes to tpTable. The desired changes are specified in changes
		and alter the values in tpTable. forceShield is used to override if the player has a shield equipped or not
		
	GetTankPoints(dataTable, TP_MELEE)
		


	UpdateDataTable()
	=================
	UpdateDataTable is used to refresh information about the player held in member sourceTable, 
	and recalculate tankpoints held in member resultsTable.

	UpdateDataTable is called whenever something about the player changes (buffs, mounted, aura, etc).
	Internally it uses GetSourceData, passing sourceTable as the table to fill, e.g.:

		self:GetSourceData(self.sourceTable)
		CopyTable(self.resultsTable, self.sourceTable) --make a copy of sourceTable
		self:GetTankPoints(self.resultsTable)

	
-- 1. Players current DataTable is obtained from TP_Table = TankPoints:GetSourceData(newDT, TP_MELEE)
-- 2. Target stat changes are written in the changes table
-- 3. These 2 tables are passed in TankPoints:AlterSourceData(TP_Table, changes), and it makes changes to TP_Table
-- 4. TP_Table is then passed in TankPoints:GetTankPoints(TP_Table, TP_MELEE), and the results are writen in TP_Table
-- 5. Read the results from TP_Table
--]]


------------------------------
-- AceDebug-2.0 compat shim --
------------------------------
--[[
TankPoints.debugging = nil

function TankPoints:Debug(...)
	if self.debugging then
		DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff7fff7f(DEBUG) TankPoints:[%s.%3d]|r %s", date("%H:%M:%S"), (GetTime() % 1) * 1000, table.concat(tostringall(...), " ")))
	end
end

function TankPoints:IsDebugging()
	return self.debugging
end

function TankPoints:SetDebugging(value)
	self.debugging = value
end
]]--

--[[
	20120901  The Combat table changed in Mists of Panderia
			http://wow.joystiq.com/2012/03/01/ghostcrawler-explains-stat-changes-in-mists-of-pandaria/
			http://us.battle.net/wow/en/blog/4544194/Dev_Watercooler_%E2%80%93_Mists_of_Pandaria_Stat_Changes-3_1_2012

	Any attack that is not completely avoided (i.e. was not a miss, dodged or parried)
	then goes through a separate roll to decide if it will be blocked or not.
	
	The old notion of "pushing miss and crit off the combat table" is gone.
			
	An attack can be either:
		Missed   (e.g. 3%)
		Dodged   (e.g. 3%)
		Parried  (e.g. 3%)
		Hit      (e.g. 91%)
		
	If it is a hit then the strike has a chance to be blocked, this is done on a separate roll:

		====+==== 3% ==> Missed ====> 0% damage
			|=== 14% ==> Dodged ====> 0% damage
			|=== 28% ==> Parried ===> 0% damage
			|=== 55% ==> Hit ===+=== 35% ===> Blocked ==+=== 5% ==> Crit (Blocked)
								|						|== 95% ==> Hit (Blocked)
								|=== 65% ===> Hit ======+=== 5% ==> Crit
														|== 95% ==> Hit

	Giving a schmorasboard:
	
		Miss
		Dodge
		Parry
		Hit
		Hit (Blocked)
		Crit
		Crit (Blocked)

	But really it means that you'll now *always* be hit, and you'll *always* be crit.
	Adding mastery increases your chance to block, but there's nothing that can reduce your chance to be crit.
	The only way to mitigate damage from hits (and crits) is to block more often (and have more armor).
	
	So the net damage formula is
		(1 - M - D - P) * ( Bc*(1-Br) + (1-Bc) ) * (1+Cc) * (1-Ar)
		
	where
			M  : miss chance (e.g. 0.03)
			D  : dodge chance (e.g. 0.1373)
			P  : parry chance (e.g. 0.2769)
			Bc : block chance (e.g. 0.3302)
			Br : block reduction (e.g. 0.31) (everyone blocks for 30%, but meta gem adds +1%)
			Cc : crit chance (e.g. 0.05)
			Ar : armor reduction (e.g. 0.5046)
			H  : health (e.g. 201939)

		= (1 - 0.03 - 0.1373 - 0.2769) * ( 0.3302*(1-0.31) + (1-0.35) ) * (1+0.05) * (1-0.5046)
		= (0.5558)                     * ( 0.3302*0.69     +  0.65    ) * (1.05)   * (0.4954)
		= 0.5558                       * ( 0.2278          +  0.65    ) *  1.05    *  0.4954
		= 0.5558 * 0.8778 * 1.05 * 0.4954
		  ======   ======   ====   ====== 
		    ^---------------------------- damage reduction from avoidance
		             ^------------------- damage reduction from blocking
		                     ^----------- increased damage from crit
		                             ^--- reduction from armor
		= 0.25378
		
	TP = H / 0.25378
	   = 201939 / 0.25378
	   = 201939 / 0.74622
	   = 795724
	   
	TP'(H)  =      1 / (    (1-M-D-P)   * (  Bc*(1-Br)+ (1-Bc) ) *  (1+Cc) * (1-Ar)  )
	TP'(D)  =      H / (  ( (1-M-D-P)^2 * ( (Bc*(1-Br)+1-Bc)     * ((1+Cc) * (1-Ar)) ))  )
	TP'(P)  =      P / (  ( (1-M-D-P)^2 * ( (Bc*(1-Br)+1-Bc)     * ((1+Cc) * (1-Ar))))   )
	TP'(Bc) = Br * H / (  ( (1-M-D-P)   * ( (Bc*(1-Br)+1-Bc)^2   * ((1+Cc) * (1-Ar)) )   )
	TP'(Ar) =      H / (  ( (1-M-D-P)   * ( (Bc*(1-Br)+1-Bc)     * ((1+Cc) * (1-Ar)^2))) )
--]]


----------------------
-- Global Variables --
----------------------
--Enumeration of the various kinds of damage the player can take
TP_RANGED = 0;
TP_MELEE = 1;
TP_HOLY = 2;
TP_FIRE = 3;
TP_NATURE = 4;
TP_FROST = 5;
TP_SHADOW = 6;
TP_ARCANE = 7;

--Initialize various sets of damage
TankPoints.ElementalSchools = { }; 
    --{TP_HOLY, TP_FIRE, TP_NATURE, TP_FROST, TP_SHADOW, TP_ARCANE}

-- schools you can get resist gear for
TankPoints.ResistableElementalSchools = { };
    --{TP_FIRE, TP_NATURE, TP_FROST, TP_SHADOW, TP_ARCANE}

--GlobalStrings are strings made availabe by Wow, they're localized too!
--see http://wowprogramming.com/utils/xmlbrowser/diff/FrameXML/GlobalStrings.lua
--Note: The "cap" version of spell schools means capitalized (i.e. "Fire" vs "fire")
TankPoints.SchoolName = {
	[TP_RANGED] = PLAYERSTAT_RANGED_COMBAT,		--"Ranged"
	[TP_MELEE] = PLAYERSTAT_MELEE_COMBAT,		--"Melee"
	[TP_HOLY] = SPELL_SCHOOL1_CAP,				--"Holy"
	[TP_FIRE] = SPELL_SCHOOL2_CAP,				--"Fire"
	[TP_NATURE] = SPELL_SCHOOL3_CAP,			--"Nature"
	[TP_FROST] = SPELL_SCHOOL4_CAP,				--"Frost"
	[TP_SHADOW] = SPELL_SCHOOL5_CAP,			--"Shadow"
	[TP_ARCANE] = SPELL_SCHOOL6_CAP,			--"Arcane"
}

--LibStatLogic uses hard-coded strings as a lookup if a player takes a particular kind of damage
--This lookup translates our constants to those used by LibStatLogic
local schoolIDToString = {
	[TP_RANGED] = "RANGED",
	[TP_MELEE] = "MELEE",
	[TP_HOLY] = "HOLY",
	[TP_FIRE] = "FIRE",
	[TP_NATURE] = "NATURE",
	[TP_FROST] = "FROST",
	[TP_SHADOW] = "SHADOW",
	[TP_ARCANE] = "ARCANE",
}

-- SpellInfo
local SI = {
--	["Holy Shield'] = GetSpellInfo(48951),
	--["Holy Shield"] = GetSpellInfo(20925), --Removed in 5.0.4: Paladin: Using Shield of the Righteous or Inquisition increases your block chance by 15% for 20 sec.
	["Sacred Shield"] = GetSpellInfo(20925), --Added in 5.0.4: Paladin: Protects the target with a shield of Holy Light for 30 sec. The shield absorbs up to (30 + 1.17 * holy spell power) damage every 6 sec.
	["Shield Block"] = GetSpellInfo(2565), --Warrior: Increases your chance to block by 100% for 10 sec.
}

---------------------
-- Local Variables --
---------------------
local profileDB; -- Initialized in :OnInitialize()

-- Localize Lua globals
local _;
local _G = getfenv(0); --returns the global environment (Lua standard)
local strfind = strfind;
local strlen = strlen;
local gsub = gsub;
local pairs = pairs;
local ipairs = ipairs;
local type = type;
local tinsert = tinsert;
local tremove = tremove;
local unpack = unpack;
local max = max;
local min = min;
local floor = floor;
local ceil = ceil;
local round = function(n) return floor(n + 0.5) end;
local loadstring = loadstring;
local tostring = tostring;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local format = format;

-- Localize WoW globals
local GameTooltip = GameTooltip;
local CreateFrame = CreateFrame;
local UnitClass = UnitClass;
local UnitRace = UnitRace;
local UnitLevel = UnitLevel;
local UnitStat = UnitStat;
--local UnitDefense = UnitDefense	20101018: defense removed from game in patch 4.0.1
local UnitHealthMax = UnitHealthMax;
local UnitArmor = UnitArmor;
local UnitResistance = UnitResistance;
local IsEquippedItemType = IsEquippedItemType;
local GetTime = GetTime;
local GetInventorySlotInfo = GetInventorySlotInfo;
local GetTalentInfo = GetTalentInfo;
local GetShapeshiftForm = GetShapeshiftForm;
local GetShapeshiftFormInfo = GetShapeshiftFormInfo;
local GetDodgeChance = GetDodgeChance;
local GetParryChance = GetParryChance;
local GetBlockChance = GetBlockChance;
local GetMastery = GetMastery;
local GetCombatRating = GetCombatRating;
local GetPlayerBuffName = GetPlayerBuffName;
local GetShieldBlock = GetShieldBlock;

---------------
-- Constants --
---------------
--HEALTH_PER_STAMINA = 10 --removed 20101211: It's wrong after level 80. At best it's not used. At worst it was overwriting a global in Bliz FrameXml
--BLOCK_DAMAGE_REDUCTION = 0.30 --blocked attacks reduce damage by 30%, unless you have a meta, in which case it's 31%



-----------
-- Tools --
-----------
-- clear "to", and copy "from"
local function copyTable(to, from)
	if to then
		for k in pairs(to) do
			to[k] = nil
		end
		setmetatable(to, nil)
	else
		to = {}
	end
	for k,v in pairs(from) do
		if type(k) == "table" then
			k = copyTable({}, k)
		end
		if type(v) == "table" then
			v = copyTable({}, v)
		end
		to[k] = v
	end
	setmetatable(to, getmetatable(from))
	return to
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, ", " ) .. "}"
end

function TankPoints:VarAsString(value)
--[[Convert a variable to a string
--]]

	local Result = "["..type(value).."] = "
	
	--[[
		Some types in LUA refuse to be converted to a string, so we have to do it for it.
	
		LUA type() function returns a lowercase string that contains one of the following:
			- "nil"			we must manually return "nil"
			- "boolean"		we must manually convert to "true" or "false"
			- "number"
			- "string"
			- "function"
			- "userdata"
			- "thread"
			- "table"		we must manually convert to a string
			
	]]--
	
	if (value == nil) then
		Result = Result.."nil"
	elseif (type(value) == "table") then
		Result = Result..table.tostring(value)
	elseif (type(value) == "boolean") then
		if (value) then
			Result = Result.."true"
		else
			Result = Result.."false"
		end
	else
		Result = Result..value
	end
	
	return Result;
end

---------------------
-- Initializations --
---------------------
--[[ Loading Process Event Reference
{
ADDON_LOADED - When this addon is loaded (exposed as :OnInitialize)
VARIABLES_LOADED - When all addons are loaded
PLAYER_LOGIN - Most information about the game world should now be available to the UI (exposed as :OnEnable)
}
--]]

-- Default values
local defaults = {
	profile = {
		showTooltipDiff = true,
		showTooltipTotal = false,
		showTooltipDRDiff = false,
		showTooltipDRTotal = false,
		showTooltipEHDiff = false,
		showTooltipEHTotal = false,
		showTooltipEHBDiff = false,
		showTooltipEHBTotal = false,
		mobLevelDiff = 3,
		mobDamage = 20000,
		mobCritChance = 0.05,
		mobCritBonus = 1,
		mobMissChance = 0.05,
		mobSpellCritChance = 0,
		mobSpellCritBonus = 1, --5.0.4: Melee and Spells now both crit for double damage
		mobSpellMissChance = 0,
		shieldBlockDelay = 2, --TODO: Remove. shield block was removed in 5.0.4
		ignoreGemsInTooltipDiff = false,
		ignoreEnchantsInTooltipDiff = false,
		ignorePrismaticInTooltipDiff = false,
	},
}

-- OnInitialize(name) called at ADDON_LOADED by WowAce 
function TankPoints:OnInitialize()
	self:Debug("TankPoints:OnInitialize()");
	self.db = LibStub("AceDB-3.0"):New("TankPointsDB", defaults);

	-- Initialize profileDB
	profileDB = self.db.profile
	self:InitializePlayerStats();
	
	-- OnUpdate Frame
	self.OnUpdateFrame = CreateFrame("Frame")
	self.OnUpdateFrame:SetScript("OnUpdate", self.OnUpdate)

	-- Player TankPoints table
	self.sourceTable = {}	--holds the current raw stats and attributes of the player. Populated by called UpdateDataTable, which calls GetSourceData(sourceTable)
	self.resultsTable = {}	--holds the adjusted and calculated stats as well as the calcualted TankPoints and EffectiveHealth

	-- Set player class, race, level
	TankPoints.playerClass = select(2, UnitClass("player"))
	TankPoints.playerRace = select(2, UnitRace("player"))

	--Call SetupOptions if we've included the options file. (Not like there's any reason not to include it, its not like you can use the addon. But it's modular, helps with testing)
	if (self.SetupOptions) then
		self:SetupOptions() --in options.lua
	end
	
	--Register LibDataBroker objects if we've included the file. Modularity!
	if (self.RegisterLDBDataObjects) then
		self:RegisterLDBDataObjects(); --in TankPointsLibDataBroker
	end;
end

function TankPoints:ShowPerStat()
	return self.tpPerStat
end
function TankPoints:SetShowPerStat(x)
	self.tpPerStat = x
end

-- OnEnable() called at PLAYER_LOGIN by WowAce
function TankPoints:OnEnable()
	self:Debug("TankPoints:OnEnable()")
--	self:RegisterEvent("UNIT_AURA", "UnitStatsChanged");
--	self:RegisterEvent("UNIT_AURA", "UnitStatsChanged"); 
			--fires before the effect is in place. 
			--But we have to use it because things like Blessing of Might (which gives +mana/5) doesn't count as a stat change
			--and there is no event for regen changing

			--To get the event after the effect has happened track the real event 
			--e.g. UNIT_STATS, UNIT_ATTACK_POWER
	--self:RegisterEvent("UNIT_LEVEL", "UnitStatsChanged"); --use PLAYER_LEVEL_UP instead; it's only for the player (faster)
	self:RegisterEvent("PLAYER_LEVEL_UP");
	--self:RegisterEvent("UNIT_MAXMANA", "UnitStatsChanged"); event removed in 4.3
	self:RegisterEvent("UNIT_STATS", "UnitStatsChanged"); --Strength, Spirit, Stamina, Agility, Intellect
	self:RegisterEvent("UNIT_SPELL_HASTE", "UnitStatsChanged"); --Spell Haste
	self:RegisterEvent("LEARNED_SPELL_IN_TAB", "SpellsChanged");
	--self:RegisterEvent("CHARACTER_POINTS_CHANGED", "TalentsChanged");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "TalentsChanged"); --when you switch talent specs
	--self:RegisterEvent("PLAYER_TALENT_UPDATE", "TalentsChanged"); --when you gain or spend talent points
	self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS", "UnitStatsChanged"); --finally i can record Spell Healing
	self:RegisterEvent("SPELL_POWER_CHANGED", "OnSpellPowerChanged");

	-- Initialize TankPoints.playerLevel
	self.playerLevel = UnitLevel("player")
	-- by default don't show tank points per stat
	self.tpPerStat = nil
	-- Calculate TankPoints
	self:UpdateDataTable()

	-- Add "TankPoints" to playerstat drop down list
	self:AddStatFrames()
end

------------
-- Events --
------------
--- This method is called whenever one of the player's stats changes.
function TankPoints:UnitStatsChanged(event, unitID) -- UNIT_AURA, UNIT_LEVEL, UNIT_MAXMANA, UNIT_STATS
	if (unitID == nil) or (unitID == "") then
		error(string.format("TankPoints:StatsChanged(event=%s, unitID=%s) unitID is empty or nil", event or "nil", unitID or "nil"), 2);
		return;
	end;

	if (UnitIsUnit(unitID, "player")) then
		self:UpdateTankPoints(event or "");
	end
end

function TankPoints:PLAYER_LEVEL_UP(_, level)
	self.playerLevel = level;
	self:UpdateTankPoints("PLAYER_LEVEL_UP")
end

function TankPoints:FORGE_MASTER_ITEM_CHANGED()
	self:UpdateTankPoints("FORGE_MASTER_ITEM_CHANGED");
end;


function TankPoints:OnSpellPowerChanged(event, b, c, d) --SPELL_POWER_CHANGED
	--print(string.format("TankPoints:SpellPowerChanged(event=%s, b=%s, c=%s, d=%s)", event or "nil", b or "nil", c or "nil", d or "nil"));

	self:UpdateTankPoints((event or ""));
end;

function TankPoints:SpellsChanged(spellID, tabID) -- LEARNED_SPELL_IN_TAB
	self:UpdateTankPoints("SpellChanged");
end

function TankPoints:TalentsChanged(delta) -- CHARACTER_POINTS_CHANGED
	self:UpdateTankPoints("TalentsChanged");
end

function TankPoints:GearChanged()
	self:UpdateTankPoints("GearChanged");
end

local tmrUpdate = nil;
function TankPoints:UpdateTankPoints(sender)
	self:RecordStats(sender); --something about recording stats 0.1 seconds later caused them to record mostly nonsnse


	if tmrUpdate then
		--print('Cancelling timer');
		self:CancelTimer(tmrUpdate);
		tmrUpdate = nil;
	end;

	if (tmrUpdate == nil) then
		--print('Scheduling time to fire in 4 seconds');
		tmrUpdate = self:ScheduleTimer("EndUpdateTankPoints", 0.200, sender); --100ms = 10fps. 50ms = 20fps.  16.666ms = 60fps
	end;
end;


-------------------------
-- Updating TankPoints --
-------------------------
-- Update TankPoints panal stats if selected
function TankPoints:EndUpdateTankPoints(sender)
	tmrUpdate = nil;
	--print("Timer fired");
	
	self:UpdateDataTable();

	PaperDollFrame_UpdateStats();
	
--	self:Print("UpdateStats() - "..self.resultsTable.tankPoints[TP_MELEE]);
--	self:Debug("UpdateStats() - "..self.resultsTable.tankPoints[TP_MELEE]);

	--Synchronize the LibDataBroker dataObjects (if we've included that source file)
	if (self.UpdateLDBDataObjects) then
		self:UpdateLDBDataObjects();
	end;
end

function TankPoints:RecordStats(reason)
	local PlayerLevel = UnitLevel("player");
	local _, PlayerClass, _ = UnitClass("player");
	local _, PlayerRace = UnitRace("player");

	local specializationIndex = GetSpecialization()
	local masterySpell;
	if (specializationIndex) then
		masterySpell = GetSpecializationMasterySpells(specializationIndex);
	else
		masterySpell = 0;
	end;

	local shapeshiftFormID = (GetShapeshiftFormID() or 0);

	Strength, _, posBuff, negBuff = UnitStat("player", 1); --strength
	local BaseStrength = Strength - posBuff + negBuff;

	Agility, _, posBuff, negBuff = UnitStat("player", 2); --agility
	local BaseAgility = Agility - posBuff + negBuff;

	Stamina, _, posBuff, negBuff = UnitStat("player", 3); --stamina
	local BaseStamina = Stamina - posBuff + negBuff;

	Intellect, _, posBuff, negBuff = UnitStat("player", 4); --intellect
	local BaseIntellect = Intellect - posBuff + negBuff;

	local baseArmor = UnitArmor("player");

	local DodgeRating = GetCombatRating(CR_DODGE);
	local DodgeRatingBonus = GetCombatRatingBonus(CR_DODGE);
	local DodgeChance = GetDodgeChance();

	local ParryRating = GetCombatRating(CR_PARRY);
	local ParryRatingBonus = GetCombatRatingBonus(CR_PARRY);
	local ParryChance = GetParryChance();

	local CritRating = GetCombatRating(CR_CRIT_MELEE);
	local CritRatingBonus = GetCombatRatingBonus(CR_CRIT_MELEE);
	local CritChance = GetCritChance();

	local spellCritChance = GetSpellCritChance(1);
	local rangedCritChance = GetRangedCritChance();
	local spellCritChanceFromIntellect = GetSpellCritChanceFromIntellect("player");
	local critChanceFromAgility = GetCritChanceFromAgility("player");

	local BlockRating = GetCombatRating(CR_BLOCK);
	local BlockRatingBonus = GetCombatRatingBonus(CR_BLOCK);
	local BlockChance = GetBlockChance();

	local MasteryRating = GetCombatRating(CR_MASTERY);
	local MasteryRatingBonus = GetCombatRatingBonus(CR_MASTERY);
	local Mastery = GetMastery();
	local MasteryEffect, MasteryFactor = GetMasteryEffect();

	local MeleeHitRating = GetCombatRating(CR_HIT_MELEE);
	local MeleeHitRatingBonus = GetCombatRatingBonus(CR_HIT_MELEE);
	local MeleeHitChance = GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier();

--	local SpellHitRating = GetCombatRating(CR_HIT_SPELL);
--	local SpellHitRatingBonus = GetCombatRatingBonus(CR_HIT_SPELL);
--	local SpellHitChance = GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier();

	local meleeHasteRating = GetCombatRating(CR_HASTE_MELEE);
	local meleeHasteRatingBonus = GetCombatRatingBonus(CR_HASTE_MELEE);
	local meleeHaste = GetMeleeHaste();

	local expertiseRating = GetCombatRating(CR_EXPERTISE);
	local expertiseRatingBonus = GetCombatRatingBonus(CR_EXPERTISE);
	local expertise = GetExpertise();

	local csv = string.format(
			"%d,%s,%s,".. --PlayerLevel,PlayerClass,PlayerRace
			"%d,%d,".. --SpecializationIndex,MasterySpell
			"%d,".. --ShapeshiftFormID
			"%d,%d,".. --Strength, BaseStrength
			"%d,%d,".. --Agility, BaseAgility
			"%d,%d,".. --Stamina,BaseStamina
			"%d,%d,".. --Intellect,BaseIntellect
			"%d,".. --Armor
			"%d,%s,%s,".. --DodgeRating,DodgeRatingBonus,DodgeChance
			"%d,%s,%s,".. --ParryRating,ParryRatingBonus,ParryChance
			"%d,%s,%s,".. --CritRating,CritRatingBonus,CritChance
			"%s,%s,".. --SpellCritChance, RangedCritChance
			"%s,%s,".. --SpellCritChanceFromIntellect, CritChanceFromAgility
			"%d,%s,%s,".. --BlockRating,BlockRatingBonus,BlockChance
			"%d,%s,%s,%s,%s,".. --MasteryRating,MasteryRatingBonus,Mastery,MasteryEffect,MasteryFactor
			"%d,%s,%s,".. --MeleeHitRating,MeleeHitRatingBonus,MeleeHitChance
			"%d,%s,%s,".. --MeleeHasteRating,MeleeHasteRatingBonus,MeleeHaste
			"%d,%s,%s", --expertiseRating, expertiseRatingBonus, expertise
   
			PlayerLevel,PlayerClass,PlayerRace,
			specializationIndex, masterySpell,
			shapeshiftFormID,
			Strength, BaseStrength,
			Agility, BaseAgility,
			Stamina,BaseStamina,
			Intellect,BaseIntellect,
			baseArmor,
			DodgeRating,DodgeRatingBonus,DodgeChance,
			ParryRating,ParryRatingBonus,ParryChance,
			CritRating,CritRatingBonus,CritChance,
			spellCritChance, rangedCritChance, 
			spellCritChanceFromIntellect, critChanceFromAgility,
			BlockRating,BlockRatingBonus,BlockChance,
			MasteryRating,MasteryRatingBonus,Mastery,MasteryEffect,MasteryFactor,
			MeleeHitRating,MeleeHitRatingBonus,MeleeHitChance,
			meleeHasteRating,meleeHasteRatingBonus,meleeHaste,
			expertiseRating, expertiseRatingBonus, expertise
	);

	self:Debug("Recording player stats: %s", reason or "nil");
	PlayerStats[csv] = true;
	--print(csv);
end

function TankPoints:PurgePlayerStats()
	PlayerStats = nil;
	self:InitializePlayerStats();
	self:Print("Purged historical player statistics");
end;

local playerStatsVersion = 9;
function TankPoints:InitializePlayerStats()
	if (self.db.global.PlayerStatsVersion or 0) < playerStatsVersion then
		PlayerStats = nil;
		self.db.global.PlayerStatsVersion = playerStatsVersion;
		self:Print(string.format("Deleted player stats to use new version %d", playerStatsVersion));
	end;

	if PlayerStats == nil then

		local header = string.format(
				"%s,%s,%s,".. --PlayerLevel,PlayerClass,PlayerRace
				"%s,%s,".. --SpecializationIndex,MasterySpell
				"%s,".. --ShapeshiftFormID
				"%s,%s,".. --Strength, BaseStrength
				"%s,%s,".. --Agility, BaseAgility
				"%s,%s,".. --Stamina,BaseStamina
				"%s,%s,".. --Intellect,BaseIntellect
				"%s,".. --Armor
				"%s,%s,%s,".. --DodgeRating,DodgeRatingBonus,DodgeChance
				"%s,%s,%s,".. --ParryRating,ParryRatingBonus,ParryChance
				"%s,%s,%s,".. --CritRating,CritRatingBonus,CritChance
				"%s,%s,".. --SpellCritChance, RangedCritChance
				"%s,%s,".. --SpellCritChanceFromIntellect, CritChanceFromAgility
				"%s,%s,%s,".. --BlockRating,BlockRatingBonus,BlockChance
				"%s,%s,%s,%s,%s,".. --MasteryRating,MasteryRatingBonus,Mastery,MasteryEffect,MasteryFactor
				"%s,%s,%s,".. --MeleeHitRating,MeleeHitRatingBonus,MeleeHitChance
				"%s,%s,%s,".. --MeleeHasteRating,MeleeHasteRatingBonus,MeleeHaste
				"%s,%s,%s", --expertiseRating, expertiseRatingBonus, expertise

   
				"PlayerLevel","PlayerClass","PlayerRace",
				"SpecializationIndex","MasterySpell",
				"ShapeshiftForm",
				"Strength", "BaseStrength",
				"Agility", "BaseAgility",
				"Stamina","BaseStamina",
				"Intellect","BaseIntellect",
				"Armor",
				"DodgeRating","DodgeRatingBonus","DodgeChance",
				"ParryRating","ParryRatingBonus","ParryChance",
				"CritRating","CritRatingBonus","CritChance",
				"SpellCritChance", "RangedCritChance",
				"SpellCritChanceFromIntellect", "CritChanceFromAgility",
				"BlockRating","BlockRatingBonus","BlockChance",
				"MasteryRating","MasteryRatingBonus","Mastery","MasteryEffect","MasteryFactor",
				"MeleeHitRating","MeleeHitRatingBonus","MeleeHitChance",
				"MeleeHasteRating","MeleeHasteRatingBonus","MeleeHaste",
				"ExpertiseRating","ExpertiseRatingBonus","Expertise"
				);

		PlayerStats = {};
		PlayerStats[header] = true;
	else
		TankPoints:Print("PlayerStats loaded. Be sure to dump them into Excel");
	end;	
end;


-- Update sourceTable, recalculate TankPoints, and store it in resultsTable
function TankPoints:UpdateDataTable()
	--self:Print("TankPoints:UpdateDataTable()");
	self:GetSourceData(self.sourceTable)

	copyTable(self.resultsTable, self.sourceTable) --destination, source
	self:GetTankPoints(self.resultsTable)

	if (TankPointsTooltips) then
		TankPointsTooltips.ClearCache();
	end;
	--print(self.resultsTable.tankPoints[TP_MELEE], StatLogic:GetStatMod("MOD_ARMOR"), self.sourceTable.armor, UnitArmor("player"))
end

---------------------
-- TankPoints Core --
---------------------
--[[
armorReductionTemp = armor / ((85 * levelModifier) + 400)
armorReduction = armorReductionTemp / (armorReductionTemp + 1)
defenseEffect = (defense - attackerLevel * 5) * 0.04 * 0.01
blockValueFromStrength = (strength * 0.05) - 1
[removed] blockValue = floor(blockValueFromStrength) + floor((blockValueFromItems + blockValueFromShield) * blockValueMod)
[removed]mobDamage = (levelModifier * 55) * meleeTakenMod * (1 - armorReduction)
resilienceEffect = StatLogic:GetEffectFromRating(resilience, playerLevel) * 0.01
mobCritChance = max(0, 0.05 - defenseEffect - resilienceEffect)
mobCritBonus = 1
mobMissChance = max(0, 0.05 + defenseEffect)
mobCrushChance = 0.15 + max(0, (playerLevel * 5 - defense) * 0.02) (if mobLevel is +3)
mobCritDamageMod = max(0, 1 - resilienceEffect * 2)
blockedMod = 30/40/30*crit
mobSpellCritChance = max(0, 0 - resilienceEffect)
mobSpellCritBonus = 0.5
mobSpellMissChance = 0
mobSpellCritDamageMod = max(0, 1 - resilienceEffect * 2)
schoolReduction[SCHOOL] = 0.75 * (resistance[SCHOOL] / (mobLevel * 5))
totalReduction[MELEE] = 1 - ((mobCritChance * (1 + mobCritBonus) * mobCritDamageMod) + (mobCrushChance * 1.5) + (1 - mobCrushChance - mobCritChance - blockChance * blockedMod - parryChance - dodgeChance - mobMissChance)) * (1 - armorReduction) * meleeTakenMod
totalReduction[SCHOOL] = 1 - ((mobSpellCritChance * (1 + mobSpellCritBonus) * mobSpellCritDamageMod) + (1 - mobSpellCritChance - mobSpellMissChance)) * (1 - schoolReduction[SCHOOL]) * spellTakenMod
tankPoints = playerHealth / (1 - totalReduction)
effectiveHealth = playerHealth * 1/reduction (armor, school, etc) - this is by Ciderhelm. http://www.theoryspot.com/forums/theory-articles-guides/1060-effective-health-theory.html
effectiveHealthWithBlock = effectiveHealth modified by expected guaranteed blocks. This is done through simulation using the mob attack speed, etc. See GetEffectiveHealthWithBlock.
--]]
function TankPoints:GetArmorReduction(armor, attackerLevel)
	--Use LibStatLogic, it's been updated for Mists
	return StatLogic:GetReductionFromArmor(armor, attackerLevel)

	--[[ Following hasn't been updated for Cataclysm. LibStatLogic is right.
	local levelModifier = attackerLevel
	if ( levelModifier > 59 ) then
		levelModifier = levelModifier + (4.5 * (levelModifier - 59))
	end
	local temp = armor / (85 * levelModifier + 400)
	local armorReduction = temp / (1 + temp)
	-- caps at 75%
	if armorReduction > 0.75 then
		armorReduction = 0.75
	end
	if armorReduction < 0 then
		armorReduction = 0
	end
	return armorReduction
	]]--
end

--[[
	20101018: Defense removed from game in patch 4.0.1 
function TankPoints:GetDefense()
	local base, modifier = UnitDefense("player");
	return base + modifier
end
--]]

function TankPoints:ShieldIsEquipped()
	--local _, _, _, _, _, _, itemSubType = GetItemInfo(GetInventoryItemLink("player", 17) or "")
	--return itemSubType == L["Shields"]
	return IsEquippedItemType("INVTYPE_SHIELD"); --WoWApi
end

--[[
	Returns your shield block value, Whitetooth@Cenarius (hotdogee@bahamut.twbbs.org)
	If you don't have a shield equipped (or you force it false), then your blocked amount is zero
function TankPoints:GetBlockValue(mobDamageDepricated, forceShield)
	-- Block from Strength
	-- Talents: Pal, War
	-- (%d+) Block (on shield)
	-- %+(%d+) Block Value (ZG enchant)
	-- Equip: Increases the block value of your shield by (%d+)
	-- Set: Increases the block value of your shield by (%d+)
	-------------------------------------------------------
	-- Get Block Value from shield if shield is equipped --
	-------------------------------------------------------
	--self:Debug("TankPoints:GetBlockValue(mobDamage="..(mobDamage or "nil")..", forceShield="..(forceShield or "nil")..")")
	
	if (mobDamage == nil) then
		error("GetBlockValue: mobDamage cannot be nil")
	end
	
	if (not self:ShieldIsEquipped()) and (forceShield ~= true) then -- doesn't have shield equipped
		return 0
	end
	--return GetShieldBlock() --a built-in WoW api
	
	--As of patch 4.0.1 all blocked attacks are a straight 30% reduction
	--Note: paladin's HolyShield talent, when active, increases the amount blocked by 10%. But we don't handle that here
	return round(mobDamageDepricated * BLOCK_DAMAGE_REDUCTION);
end
--]]
------------------
-- GetMobDamage --
------------------
------------------------------------
-- mobDamage, for factoring in block
-- I designed this formula with the goal to model the normal damage of a raid boss at your level
-- the level modifier was taken from the armor reduction formula to base the level effects
-- at level 63 mobDamage is 4455, this is what Nefarian does before armor reduction
-- at level 73 mobDamage is 6518, which matches TBC raid bosses
-- at level 83 mobDamage is 10000 (todo: get a real Marrowgar number, 10/25/10H/25H)
-- at level 88 mobDamage is 20000 (todo: get a real number from something)
function TankPoints:GetMobDamage(mobLevel)
	--self:Debug("TankPoints:GetMobDamage(mobLevel="..(mobLevel or "nil")..")")

	if profileDB.mobDamage and profileDB.mobDamage ~= 0 then
		self:Debug("TankPoints:GetMobDamage: Using profile mob damage value of "..profileDB.mobDamage);
		return profileDB.mobDamage
	end
	local levelMod = mobLevel
	if ( levelMod > 80 ) then
		levelMod = levelMod + (30 * (levelMod - 59))
	elseif ( levelMod > 70 ) then
		levelMod = levelMod + (15 * (levelMod - 59))
	elseif ( levelMod > 59 ) then
		levelMod = levelMod + (4.5 * (levelMod - 59))
	end
	return levelMod * 55 -- this is the value before mitigation, which we will do in GetTankPoints
end

------------------------
-- Shield Block Skill --
------------------------
--[[ deprecated in WotLK
-- TankPoints:GetShieldBlockOnTime(4, 1, 70, nil)
function TankPoints:GetShieldBlockOnTime(atkCount, mobAtkSpeed, blockChance, talant)
	local time = 0
	if blockChance > 1 then
		blockChance = blockChance * 0.01
	end
	if not talant then
		-- Block =    70.0% = 50.0%
		-- ------------
		-- NNNN = 4 =  2.7% = 12.5% = 4 下平均是 3.5 * mobAtkSpeed秒
		-- NNB  = 3 =  6.3% = 12.5% = 3 下平均是 2.5 * mobAtkSpeed秒
		-- NB   = 2 = 21.0% = 25.0% = 2 下平均是 1.5 * mobAtkSpeed秒
		-- B    = 1 = 70.0% = 50.0% = 1 下平均是 0.5 * mobAtkSpeed秒
		if ((atkCount - 1) * mobAtkSpeed) > 5 then
			atkCount = ceil(5 / mobAtkSpeed)
		end
		for c = 1, atkCount do
			if c == atkCount then
				time = time + ((1 - blockChance) ^ (c - 1)) * (c - 0.5) * mobAtkSpeed
				--TankPoints:Print((((1 - blockChance) ^ (c - 1)) * 100).."%")
			else
				time = time + blockChance * ((1 - blockChance) ^ (c - 1)) * (c - 0.5) * mobAtkSpeed
				--TankPoints:Print((blockChance * ((1 - blockChance) ^ (c - 1)) * 100).."%")
			end
		end
		if atkCount <= 0 then
			time = 5
		end
	else
		-- Block =     70.0% = 50.0%
		-- ------------
		-- NNN   = 4 =  2.7% = 12.5%
		-- BNN   = 4 =  6.3% = 12.5%
		-- NBN   = 4 =  6.3% = 12.5%
		-- NNB   = 4 =  6.3% = 12.5%
		-- BNB   = 3 = 14.7% = 12.5%
		-- NBB   = 3 = 14.7% = 12.5%
		-- BB    = 2 = 49.0% = 24.0%
		if ((atkCount - 1) * mobAtkSpeed) > 6 then
			atkCount = ceil(6 / mobAtkSpeed)
		end
		for c = 2, atkCount do
			if c == atkCount then
				time = time + ((blockChance * ((1 - blockChance) ^ (c - 2)) * (c - 1)) + ((1 - blockChance) ^ (c - 1))) * (c - 0.5) * mobAtkSpeed
				--TankPoints:Print((((blockChance * ((1 - blockChance) ^ (c - 2)) * (c - 1)) + ((1 - blockChance) ^ (c - 1))) * 100).."%")
			else
				time = time + blockChance * blockChance * ((1 - blockChance) ^ (c - 2)) * (c - 1) * (c - 0.5) * mobAtkSpeed
				--TankPoints:Print((blockChance * blockChance * ((1 - blockChance) ^ (c - 2)) * (c - 1) * 100).."%")
			end
		end
		if atkCount <= 1 then
			time = 6
		end
	end
	return time
end

-- TankPoints:GetshieldBlockUpTime(10, 2, 55, 1)
function TankPoints:GetshieldBlockUpTime(timeBetweenPresses, mobAtkSpeed, blockChance, talant)
	local shieldBlockDuration = 5
	if talant then
		shieldBlockDuration = 6
	end
	local avgAttackCount = shieldBlockDuration / mobAtkSpeed
	local min = floor(avgAttackCount)
	local percentage = avgAttackCount - floor(avgAttackCount)
	local avgOnTime = self:GetShieldBlockOnTime(min, mobAtkSpeed, blockChance, talant) * (1 - percentage) + 
	                  self:GetShieldBlockOnTime(min + 1, mobAtkSpeed, blockChance, talant) * percentage
	return avgOnTime / timeBetweenPresses
end
--]]

-- mobContactChance is both regular hits, crits, and crushes
-- This works through simulation. Each mob attack until you run out of health
-- is evaluated for whether or not you can expect to have a guaranteed block.
-- 
-- Ciderhelm makes reference to how this would be calculated at http://www.theoryspot.com/forums/theory-articles-guides/1060-effective-health-theory.html
--
-- EHB (Effective Health w/ Block) will change depending upon how often you
-- press the shield block button, the mob attack speed, and mob damage.
-- This is not gear dependent.
-- mobDamage is after damage reductions
function TankPoints:GetEffectiveHealthWithBlock(TP_Table, mobDamage)

	local effectiveHealth = TP_Table.effectiveHealth[TP_MELEE]
	-- Check for shield
	local blockValue = 0; --floor(TP_Table.blockValue)
	if blockValue == 0 then
		return effectiveHealth
	end
	local mobContactChance = TP_Table.mobContactChance
	local sbCoolDown, sbDuration, sbDuration

	-- Check for guaranteed block
	if self.playerClass == "PALADIN" then
		--5.0.4: Removed Paladin Holy Shield (2,17) talent
		return effectiveHealth;
		
		--[[
		if not (select(5, GetTalentInfo(2, 17)) > 0) then -- Holy Shield: Increases the amount your shield blocks by an additional 20% for 10 sec.
			return effectiveHealth
		end
		if ((10 / (8 + TP_Table.shieldBlockDelay) >= 1) and not UnitBuff("player", SI["Holy Shield"])) and mobContactChance > 0 then -- If Holy Shield has 100% uptime
			return effectiveHealth
		elseif UnitBuff("player", SI["Holy Shield"]) and mobContactChance > 0 then -- If Holy Shield is already up
			return effectiveHealth
		elseif mobContactChance > 30 then
			return effectiveHealth
		end
		sbCoolDown = 8
		sbDuration = 10
		sbCharges = 8
		--]]
	elseif self.playerClass == "WARRIOR" then
		--5.0.4 Removed shield block altogether (i assume, since my Pally no longer has one)
		--[[
		if not UnitBuff("player", SI["Shield Block"]) then
			blockValue = blockValue * 2
		end
		local _, _, _, _, r = GetTalentInfo(3, 8); --Shield Mastery: Reduces the cooldown of your Shield Block by 10 sec
		sbCoolDown = 60 - r * 10
		sbDuration = 10
		sbCharges = 100

		mobDamage = ceil(mobDamage)
		local shieldBlockDelay = TP_Table.shieldBlockDelay
		local timeBetweenPresses = sbCoolDown + shieldBlockDelay
		return effectiveHealth * mobDamage / ((mobDamage * (timeBetweenPresses - sbDuration) / timeBetweenPresses) + ((mobDamage - blockValue) * sbDuration / timeBetweenPresses))
		--]]
		return effectiveHealth;
	else -- neither Paladin or Warrior
		return effectiveHealth
	end

end

----------------
-- TankPoints --
----------------
--[[
TankPoints:GetSourceData([TP_Table], [school], [forceShield])
TankPoints:AlterSourceData(TP_Table, changes, [forceShield])
TankPoints:CheckSourceData(TP_Table, [school], [forceShield])
TankPoints:GetTankPoints([TP_Table], [school], [forceShield])

-- school
TP_RANGED = 0
TP_MELEE = 1
TP_HOLY = 2
TP_FIRE = 3
TP_NATURE = 4
TP_FROST = 5
TP_SHADOW = 6
TP_ARCANE = 7

-- TP_Table Inputs
{
	playerLevel = ,
	playerHealth = ,
	playerClass = ,
	mobLevel = ,
	resilience = ,
	-- Melee
	mobCritChance = 0.05, -- talant effects
	mobCritBonus = 1,
	mobMissChance = 0.05,
	armor = ,
	defense = ,
	dodgeChance = ,
	parryChance = ,
	blockChance = ,
	blockValue = ,
	mobDamage = ,
	mobCritDamageMod = , -- from talants
	-- Spell
	mobSpellCritChance = 0, -- talant effects
	mobSpellCritBonus = 0.5,
	mobSpellMissChance = 0, -- this should change with mobLevel, but we don't have enough data yet
	resistance = {
		[TP_HOLY] = 0,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	mobSpellCritDamageMod = , -- from talants
	-- All
	damageTakenMod = {
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
}
-- TP_Table Output adds calculated fields to the table
{
	resilienceEffect = ,
	-- Melee - Added
	armorReduction = ,
	defenseEffect = ,
	mobCrushChance = ,
	mobCritDamageMod = , -- from resilience
	blockedMod = ,
	-- Melee - Changed
	mobMissChance = ,
	dodgeChance = ,
	parryChance = ,
	blockChance = ,
	mobHitChance = , -- chance for a mob to non-crit, non-crush, non-blocked hit you (regular hit)
	mobCritChance = ,
	mobCrushChance =,
	mobContactChance =, -- the chance for a mob to hit/crit/crush you
	mobDamage = ,
	-- Spell - Added
	mobSpellCritDamageMod = ,
	-- Spell - Changed
	mobSpellCritChance = ,
	-- Results
	schoolReduction = {
		[TP_MELEE] = , -- armorReduction
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	guaranteedReduction = { -- armor/resist + talent + stance
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	totalReduction = {
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	tankPoints = {
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	-- how much raw damage you can take without a block/dodge/miss/parry
	effectiveHealth = {
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	-- how much raw damage you can take without a dodge/miss/parry and only caunting
	-- guaranteed blocks.
	effectiveHealthWithBlock = {
		[TP_MELEE] = ,
	},
}
--]]

--[[---------------------------------
{	:GetSourceData(TP_Table, school, forceShield)
-------------------------------------
-- Description
	GetSourceData is the slowest function here, dont call it unless you are sure the stats have changed.
-- Arguments
	[TP_Table]
	    table - obtained data is to be stored in this table
	[school]
	    number - specify a school id to get only data for that school
			TP_RANGED = 0
			TP_MELEE = 1
			TP_HOLY = 2
			TP_FIRE = 3
			TP_NATURE = 4
			TP_FROST = 5
			TP_SHADOW = 6
			TP_ARCANE = 7
	[forceShield]
		bool - arg added for tooltips
			true: force shield on
			false: force shield off
			nil: check if user has shield equipped
-- Returns
	TP_Table
	    table - obtained data is to be stored in this table
		
		{
			playerLevel=83,
			playerHealth = 66985,
			playerClass="PALADIN",
			mobLevel=86,
			resilience=0
			
			--Melee data
			mobCritChance=0.05,
			mobCritBonus=1,
			mobMissChance=0.05,
			armor=23576,
			defense=0,
			defenseRating=0,
			dodgeChance = 0.1197537982178,
			parryChance = 0.13563053131104,
			shieldBlockDelay=2,
			blockChance=0.26875,
			damageTakenMod={0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9),
			mobCritDamageMod=1,

			--Spell Data
			mobSpellCritChance = 0,
			mobSpellCritBonus = 0.5, 
			mobSpellMissChance = 0,
			resistance = { 
				[2]=0,
				[3]=15,
				[4]=0,
				[5]=0
				[6]=0,
				[7]=0},
			mobSpellCritDamageMod = 1,
		}
		
-- Examples
}
-----------------------------------]]
function TankPoints:GetSourceData(TP_Table, school, forceShield)
	--self:Print("TankPoints:GetSourceData");

	if not TP_Table then
		-- Acquire temp table
		TP_Table = {}
	end

	-- Unit
	local unit = "player"
	TP_Table.playerLevel = UnitLevel(unit)
	TP_Table.playerHealth = UnitHealthMax(unit)
	TP_Table.playerClass = self.playerClass
	TP_Table.mobLevel = UnitLevel(unit) + self.db.profile.mobLevelDiff

	-- Resilience
	--Removed 20120804 (5.0.1) Resilience does nothing for tanks
	--TP_Table.resilience = GetCombatRating(COMBAT_RATING_RESILIENCE_CRIT_TAKEN) --20101017: Changed in Patch4.0 from CR_CRIT_TAKEN_MELEE --Ian

	TP_Table.damageTakenMod = {}
	TP_Table.mobSpellCritDamageMod = {} --20101213 added initialziation
	----------------
	-- Melee Data --
	----------------
--	if (not school) or school == TP_MELEE then
		-- Mob's Default Crit and Miss Chance
		TP_Table.mobCritChance = self.db.profile.mobCritChance --mob's melee crit change (e.g. 0.05 ==> 5%)
		TP_Table.mobCritBonus = self.db.profile.mobCritBonus		--mob's melee crit bonus (e.g. 1 ==> 200% damage, 0.5 ==> 150% damage)
		TP_Table.mobMissChance = self.db.profile.mobMissChance - StatLogic:GetStatMod("ADD_HIT_TAKEN", "MELEE")

		-- Armor
		_, TP_Table.armor = UnitArmor(unit)

		--[[
			Defense removed from game in patch 4.0.1
			TODO: 20101018: remove these lines entirely, and remove checks from CheckSourceTable
		--]]
		-- Defense
		TP_Table.defense = 0 --self:GetDefense()
		-- Defense Rating also needed because direct Defense gains are not affected by DR
		TP_Table.defenseRating = 0 --GetCombatRating(CR_DEFENSE_SKILL)
		--]]
		
		-- Mastery
		TP_Table.mastery = GetMastery(); --Mastery is a value, e.g. 14.16. (i.e. It isn't a percentage or a fraction)
		TP_Table.masteryRating = GetCombatRating(CR_MASTERY);

		-- Dodge, Parry
		TP_Table.dodgeRating = GetCombatRating(CR_DODGE);
		TP_Table.dodgeChance = GetDodgeChance() * 0.01;
		TP_Table.parryRating = GetCombatRating(CR_PARRY);
		TP_Table.parryChance = GetParryChance() * 0.01;
		TP_Table.str = UnitStat("player", 1); --1=Strength
		TP_Table.agi = UnitStat("player", 2); --2=Agility

		-- Shield Block key press delay
		TP_Table.shieldBlockDelay = self.db.profile.shieldBlockDelay

		-- Block Chance, Block Value
		-- Check if player has shield or forceShield is set to true
		if (forceShield == true) or ((forceShield == nil) and self:ShieldIsEquipped()) then
			TP_Table.blockChance = GetBlockChance() * 0.01-- + TP_Table.defenseEffect
		else
			TP_Table.blockChance = 0
		end

		-- Melee Taken Mod
		TP_Table.damageTakenMod[TP_MELEE] = StatLogic:GetStatMod("MOD_DMG_TAKEN", "MELEE")
		-- mobCritDamageMod from talants
		TP_Table.mobCritDamageMod = StatLogic:GetStatMod("MOD_CRIT_DAMAGE_TAKEN", "MELEE")
--	end

	----------------
	-- Spell Data --
	----------------
--	if (not school) or school > TP_MELEE then
		TP_Table.mobSpellCritChance = self.db.profile.mobSpellCritChance
		TP_Table.mobSpellCritBonus = self.db.profile.mobSpellCritBonus
		TP_Table.mobSpellMissChance = self.db.profile.mobSpellMissChance - StatLogic:GetStatMod("ADD_HIT_TAKEN", "HOLY")
		-- Resistances
		TP_Table.resistance = {}
		if not school then
			for _, s in ipairs(self.ResistableElementalSchools) do
				_, TP_Table.resistance[s] = UnitResistance(unit, s - 1)
			end
			-- Holy Resistance always 0
			TP_Table.resistance[TP_HOLY] = 0
		else
			_, TP_Table.resistance[school] = UnitResistance(unit, school - 1)
		end
		-- Spell Taken Mod
		for _,s in ipairs(self.ElementalSchools) do
			TP_Table.damageTakenMod[s] = StatLogic:GetStatMod("MOD_DMG_TAKEN", schoolIDToString[s])
		end
		-- mobSpellCritDamageMod from talants
		TP_Table.mobSpellCritDamageMod = StatLogic:GetStatMod("MOD_CRIT_DAMAGE_TAKEN", TP_HOLY)
--	end

	------------------
	-- Return table --
	------------------
	return TP_Table
end

--[[
	AlterSourceData(source, changes, [forceShield])
	
	Arguments
	@param source A data table that contains the values to be modified
	@param changes
			A data table that contains the changes to be applied to tpTable
			The changes that can be applied are the following members:					
				changes = {
					-- player stats
					str = ,
					agi = ,
					sta = ,
					playerHealth = ,
					armor = ,
					armorFromItems = ,
					defense = ,
					dodgeChance = ,
					parryChance = ,
					blockChance = ,
					resilience = ,
					-- mob stats
					mobLevel = ,
					mastery = ,
					masteryRating = ,
				}
		
		forceShield
			An optional boolean value indicating whether to assume a shield is equipped or not (to perform blocks)
			true	block calculations will be applied
			false	block calculations will not be applied
			omitted	block calculations will depend if the player has a shield equipped
--]]
-- 1. Player's current DataTable is obtained from TP_Table = TankPoints:GetSourceData(newDT, TP_MELEE)
-- 2. Target stat changes are written in the changes table
-- 3. These 2 tables are passed in TankPoints:AlterSourceData(TP_Table, changes), and it makes changes to TP_Table
-- 4. TP_Table is then passed in TankPoints:GetTankPoints(TP_Table, TP_MELEE), and the results are writen in TP_Table
-- 5. Read the results from TP_Table
function TankPoints:AlterSourceData(tpTable, changes, forceShield)
	assert(tpTable, "AlterSourceData: argument 1 'tpTable' is nil");
	assert(tpTable, "AlterSourceData: argument 2 'changes' is nil");

	self:Debug("AlterSourceData(): changes="..self:VarAsString(changes));

	--self:Debug("AlterSourceData(): tpTable="..self:VarAsString(tpTable));

	--Record our current mastery spell, as it decides what we need to do with Mastery
	local masterySpellID;
	local specIndex = GetSpecialization();
	if specIndex then --GetSpecializationMasterySpells only works if they're in spec
		masterySpellID = GetSpecializationMasterySpells(specIndex);
	else
		masterySpellID = 0;
	end;	
	
	local calculateParry = false;
	local calculateDodge = false;
	
	if changes.str and changes.str ~= 0 then
		------- Formulas -------
		-- totalStr = floor(baseStr * strMod) + floor(bonusStr * strMod)
		------- Talants -------
		-- StatLogic:GetStatMod("MOD_STR")
		-- ADD_PARRY_RATING_MOD_STR (formerly ADD_CR_PARRY_MOD_STR)
		------------------------
		local totalStr, _, bonusStr = UnitStat("player", 1); --1=Strength

		local strMod = StatLogic:GetStatMod("MOD_STR");
		if strMod ~= 1 then
			-- WoW floors numbers after being multiplied by stat mods, so to obtain the original value, you need to ceil it after dividing it with the stat mods
			changes.str = max(0, floor((ceil(bonusStr / strMod) + changes.str) * strMod)) - bonusStr;
			self:Debug(string.format("    Modifying strength by %.2f to %.2f due to MOD_STR", strMod, changes.str));
			
		end;

		local newStrength = tpTable.str + changes.str;
		self:Debug(string.format("    Adding %d strength to existing %d strength.", changes.str, tpTable.str));
		tpTable.str = newStrength;
		
		local addParryModStr = StatLogic:GetStatMod("ADD_PARRY_MOD_STR");
		if (addParryModStr ~= 0) then
			--[[
			local parryRatingIncrease = floor((bonusStr + changes.str) * addParryRatingModStr) - floor(bonusStr * addParryRatingModStr)
			
			local parry = StatLogic:GetEffectFromRating(parryRatingIncrease, CR_PARRY, tpTable.playerLevel); --GetEffectFromRating returns as percentage rather than fraction
			parry = StatLogic:GetAvoidanceGainAfterDR("PARRY", parry) * 0.01; --apply diminishing returns, and convert percentage to fraction
			--]]
			self:Debug(string.format("    Strength changing by %d, and ADD_PARRY_MOD_STR=%d. Will recalculate Parry Chance", changes.str, addParryModStr));
			calculateParry = true;
		end
	end
	
	if (changes.agi and changes.agi ~= 0) then
		--self:Debug("TankPoints:AlterSourceData: altering agility by "..changes.agi)
		------- Formulas -------
		-- agi = floor(agi * agiMod)
		-- dodgeChance = baseDodge + dodgeFromRating + dodgeFromAgi + dodgeFromRacial + dodgeFromTalant + dodgeFromDefense
		-- armor = floor((armorFromItem * armorMod) + 0.5) + agi * 2 + posArmorBuff - negArmorBuff
		------- Talants -------
		-- Rogue: Vitality (Rank 2) - 2,20
		--        Increases your total Stamina by 2%/4% and your total Agility by 1%/2%.
		-- Rogue: Sinister Calling (Rank 5) - 3,21
		--        Increases your total Agility by 3%/6%/9%/12%/15%.
		-- Hunter: Combat Experience (Rank 2) - 2,14
		--         Increases your total Agility by 1%/2% and your total Intellect by 3%/6%.
		-- Hunter: Lightning Reflexes (Rank 5) - 3,18
		--         Increases your Agility by 3%/6%/9%/12%/15%.
		------------------------
		local _, _, agility = UnitStat("player", 2); --2=Agility
		local agiMod = StatLogic:GetStatMod("MOD_AGI")
		
		if (agiMod ~= 1.0) then
			changes.agi = max(0, floor((ceil(agility / agiMod) + changes.agi) * agiMod)) - agility
			self:Debug(string.format("   Adjusting agility change to %d because of MOD_AGI %.2f", changes.agi, agiMod));
		end
		
		tpTable.agi = tpTable.agi + changes.agi;

		self:Debug(string.format("    Agility changing by %d. Will recalculate Dodge Chance", changes.agi));
		calculateDodge = true;
		
		-- Armor mods don't effect armor from agi
		--20110103: Agility no longer affects armor (at least it doesn't affect mine)
		--tpTable.armor = tpTable.armor + changes.agi * 2
	end
	
	if (changes.sta and changes.sta ~= 0) then
		------- Formulas -------
		-- sta = floor(sta * staMod)
		-- By testing with the hunter talants: Endurance Training and Survivalist,
		-- I found that the healthMods are mutiplicative instead of additive, this is the same as armor mod
		-- playerHealth = round((baseHealth + addedHealth + addedSta * 10) * healthMod)
		------- Talants -------
		-- Warrior: Vitality (Rank 3) - 3,20
		--          Increases your total Strength and Stamina by 2%/4%/6%
		-- Warrior: Strength of Arms (Rank 2) - 1,22
		--          Increases your total Strength and Stamina by 2%/4%
		-- Warlock: Demonic Embrace (Rank 5) - 2,3
		--          Increases your total Stamina by 2%/4%/6%/8%/10%.
		-- Priest: Enlightenment (Rank 5) - 1,17
		--         Increases your total Stamina and Spirit by 1%/2%/3%/4%/5%
		-- Druid: Bear Form - buff (didn't use stance because Bear Form and Dire Bear Form has the same icon)
		--        Shapeshift into a bear, increasing melee attack power by 30, armor contribution from items by 180%, and stamina by 25%.
		-- Druid: Dire Bear Form - buff
		--        Shapeshift into a dire bear, increasing melee attack power by 120, armor contribution from items by 400%, and stamina by 25%.
		-- Paladin: Sacred Duty (Rank 2) - 2,14
		--          Increases your total Stamina by 3%/6%
		-- Paladin: Combat Expertise (Rank 3) - 2,19
		--          Increases your total Stamina by 2%/4%/6%.
		-- Hunter: Survivalist (Rank 5) - 3,8
		--         Increases your Stamina by 2%/4%/6%/8%/10%.
		-- Death Knight: Veteran of the Third War (Rank 3) - 1,14
		--               Increases your total Strength by 2%/4%/6% and your total Stamina by 1%/2%/3%.
		-- Death Knight: Shadow of Death - 3,13
		--               Increases your total Strength and Stamina by 2%.
		------------------------
		local _, _, bonusSta = UnitStat("player", 3) --WoW api. 3=stamina
		local staMod = StatLogic:GetStatMod("MOD_STA")
		--self:Debug("AlterSourceData() LibStatLogic:GetStatMod(\"MOD_STA\") = "..staMod)

		--20101213 Updated to LibStatLogic1.2, it's returning real values. Hack removed
		--20101117 MOD_STA is temporarily returning 1.0. Let's force it a reasonable paladin default
		--staMod = staMod * 1.05 * 1.15 * 1.05 --Kings 5% * Touched by the Light 15% * Plate specialization 5%
		--self:Debug("AlterSourceData() [temp hack] setting staMod = "..staMod)

		
		--[[this floor/ceil contraption isn't working for a case i found:
				Protection paladin with 15% stamina bonus
					Paperdoll stamina before: 2548
					Equip item with stamina (listed in tooltip): 228
					Paperdoll stamina after: 2811 (increase of 263)
				
				Assume 15% applies to item: 228 * 1.15 = 262.2
				
		--]]
		if (staMod ~= 1.0) then
			changes.sta = max(0, round((ceil(bonusSta / staMod) + changes.sta) * staMod)) - bonusSta --20101213 Changed to ceil, from round, to make example i found work
			self:Debug(string.format("   Adjusting Stamina change to %d because of MOD_STA %.4f", changes.sta, staMod));
		end

		-- Calculate player health
		local healthMod = StatLogic:GetStatMod("MOD_HEALTH");
		--self:Debug("AlterSourceData()[modify stamina] GetStatMod(\"MOD_HEALTH\") = "..healthMod)

	
		local playerHealthWithoutModifiers = round(tpTable.playerHealth / healthMod);
		local healthFromStaminaWithoutModifiers = StatLogic:GetHealthFromSta(changes.sta); --20120916: 1 stamina no longer grants 10 healthWe will later reapply the MOD_HEALTH
		
		self:Debug(string.format("   Adding %.2f Health from %.2f Stamina (%d before health modifier of %.4f%%) to existing %d Health",
				healthFromStaminaWithoutModifiers*healthMod, changes.sta, healthFromStaminaWithoutModifiers, healthMod*100, tpTable.playerHealth));
		
		tpTable.playerHealth = round((playerHealthWithoutModifiers + healthFromStaminaWithoutModifiers) * healthMod)
--		self:Print("changes.sta = "..(changes.sta or "0")..", newHealth = "..(tpTable.playerHealth or "0"))
		--self:Debug("AlterSourceData()[modify stamina] Changing stamina by "..(changes.sta or "0")..", newHealth = "..(tpTable.playerHealth or "0"))
	end
	
	if (changes.playerHealth and changes.playerHealth ~= 0) then
		------- Formulas -------
		-- By testing with the hunter talants: Endurance Training and Survivalist,
		-- I found that the healMods are mutiplicative instead of additive, this is the same as armor mod
		-- playerHealth = round((baseHealth + addedHealth + addedSta * 10) * healthMod)
		------- Talants -------
		-- Warlock: Fel Vitality (Rank 3) - 2,6
		--          Increases your maximum health and mana by 1%/2%/3%.
		-- Hunter: Endurance Training (Rank 5) - 1,2
		--         Increases the Health of your pet by 2%/4%/6%/8%/10% and your total health by 1%/2%/3%/4%/5%.
		-- Death Knight: Frost Presence - Stance
		--               Increasing total health by 10%
		------------------------
		local healthMod = StatLogic:GetStatMod("MOD_HEALTH");
		--self:Debug("AlterSourceData()[modify health] GetStatMod(\"MOD_HEALTH\") = "..healthMod)
		
		self:Debug(string.format("   Adding %.2f Health (%.2f before health modifier of %.4f%%) to existing %d Health",
				changes.playerHealth*healthMod, changes.playerHealth, healthMod*100, tpTable.playerHealth));
		
		tpTable.playerHealth = round((round(tpTable.playerHealth / healthMod) + changes.playerHealth) * healthMod)

		--self:Debug("changes.playerHealth = "..(changes.playerHealth or "0")..", newHealth = "..(tpTable.playerHealth or "0"))
	end
	
	-- *** +Parry Rating --> Parry Chance
	if (changes.parryRating and changes.parryRating ~= 0) then
		tpTable.parryRating = tpTable.parryRating or 0;

		local newParryRating = tpTable.parryRating + changes.parryRating;
		self:Debug(string.format("   Adding %d Parry Rating to existing %d Parry Rating. New ParryRating = %d. Will recalculate Parry Chance", 
				changes.parryRating, tpTable.parryRating, newParryRating));
		tpTable.parryRating = newParryRating;
		calculateParry = true;
	end;
	
	-- *** +Parry Chance --> Parry Chance
	if (changes.parryChance and changes.parryChance ~= 0) then
		self:Debug(string.format("   Parry Chance changing by %.4f%%. Will recalculate Parry Chance", changes.parryChance));
		calculateParry = true;
	end;
	
	if calculateParry then
		local strength = tpTable.str;
		self:Debug(string.format("AlterSourceData: calculateParry, tpTable.parryRating = %d", tpTable.parryRating));

		local parryRating = tpTable.parryRating;
		
		local addParryModStr = StatLogic:GetStatMod("ADD_PARRY_MOD_STR");
		--if (addParryModStr == 0) then
--			strength = 0;
		--end

		local newParryChance = StatLogic:GetParryChance(parryRating, strength);		
		self:Debug(string.format("   Making Parry Chance %.4f%% from Parry Rating=%d and Strength=%d",
				newParryChance, parryRating, strength));
		tpTable.parryChance = newParryChance*0.01;

		if (changes.parryChance and changes.parryChance ~= 0) then
			tpTable.parryChance = (tpTable.parryChance or 0);

			newParryChance = tpTable.parryChance + changes.parryChance;
			self:Debug(string.format("   Setting Parry Chance to %.4f%% by adding %.4f%% Parry Chance to existing %.4f%% Parry Chance",
				newParryChance, changes.parryChance, tpTable.parryChance));

			tpTable.parryChance = newParryChance;
		end;
	end;

	-- *** Dodge Rating --> Dodge Chance
	if (changes.dodgeRating and changes.dodgeRating ~= 0) then
		tpTable.dodgeRating = tpTable.dodgeRating or 0;

		local newDodgeRating = tpTable.dodgeRating + changes.dodgeRating;
		self:Debug(string.format("   Adding %d Dodge Rating to existing %d Dodge Rating. New DodgeRating = %d. Will recalculate Dodge Chance", 
				changes.dodgeRating, tpTable.dodgeRating, newDodgeRating));
		tpTable.dodgeRating = newDodgeRating;
		calculateDodge = true;
	end;
	
	-- *** +Dodge Chance --> Dodge Chance
	if (changes.dodgeChance and changes.dodgeChance ~= 0) then
		self:Debug(string.format("   Dodge Chance changing by %.4f%%. Will recalculate Dodge Chance", changes.dodgeChance));
		calculateDodge = true;
	end;
	
	if calculateDodge then
		local dodgeRating = tpTable.dodgeRating;
		local agility = tpTable.agi;

		local newDodgeChance = StatLogic:GetDodgeChance(dodgeRating, agility);		
		self:Debug(string.format("   Making Dodge Chance %.4f%% from Dodge Rating=%d and Agility=%d",
				newDodgeChance, dodgeRating, agility));
		tpTable.dodgeChance = newDodgeChance*0.01;

		if (changes.dodgeChance and changes.dodgeChance ~= 0) then
			tpTable.dodgeChance = (tpTable.dodgeChance or 0);

			newDodgeChance = tpTable.dodgeChance + changes.dodgeChance;
			self:Debug(string.format("   Setting Dodge Chance to %.4f%% by adding %.4f%% Dodge Chance to existing %.4f%% Dodge Chance",
				newDodgeChance, changes.dodgeChance, tpTable.dodgeChance));

			tpTable.dodgeChance = newDodgeChance;
		end;
	end;

	local doBlock = (forceShield == true) or ((forceShield == nil) and self:ShieldIsEquipped())

	--Convert Mastery Rating & Mastery into Block (paladins and warriors)
	--And into Armor for druids
	--self:Debug("changes.masteryRating="..self:VarAsString(changes.masteryRating));
	if (changes.masteryRating and changes.masteryRating ~= 0) then
		if (not changes.mastery) then --initialize mastery if needed
			changes.mastery = 0;
		end;

		local masteryFromRating = StatLogic:GetEffectFromRating(changes.masteryRating, CR_MASTERY, tpTable.playerLevel); --Mastery is not a percentage, or a fraction; it's a number, e.g. 1159 Mastery Rating grants +6.46 Mastery.
				
		self:Debug("   Adding %.4f Mastery (from %d Mastery Rating) to existing %.4f Mastery", masteryFromRating, changes.masteryRating, tpTable.mastery);
			
		changes.mastery = changes.mastery + masteryFromRating;
	end
	
	local recalculateArmor = false;

	if (changes.mastery and changes.mastery ~= 0) then
	
		local effectiveMastery, masteryEffect = GetMasteryEffect();
	
		tpTable.mastery = tpTable.mastery + changes.mastery*masteryEffect;	
	
		--Mastery affect Block Chance?
		--	Warror Protection.  SpellID: 76857  Mastery: Critical Block
		--	Paladin Protection. SpellID: 76671  Mastery: Divine Bulwark
		--	Druid Guardian.     SpellID: 77494  Mastery: Nature's Guardian. Increases armor by x%
		if (masterySpellID == 76857) or (masterySpellID == 76671) then
			local newBlockChance = StatLogic:GetBlockChance(tpTable.mastery, tpTable.playerClass);
			self:Debug("    Setting Block Chance to %.4f (from %.4f Mastery, and using mastery spell %d)", newBlockChance, tpTable.mastery, masterySpellID);
			tpTable.blockChance = newBlockChance/100;
		elseif (masterySpellID == 77494) then
			recalculateArmor = true;
		end;
	end

	if (changes.armorFromItems and changes.armorFromItems ~= 0) or (changes.armor and changes.armor ~= 0) or recalculateArmor then
		------- Talants -------
		-- Hunter: Thick Hide (Rank 3) - 1,5
		--         Increases the armor rating of your pets by 20% and your armor contribution from items by 4%/7%/10%.
		-- Druid: Thick Hide (Rank 3) - 2,5
		--        Increases your Armor contribution from items by 4%/7%/10%.
		-- Druid: Bear Form - buff (didn't use stance because Bear Form and Dire Bear Form has the same icon)
		--        Shapeshift into a bear, increasing melee attack power by 30, armor contribution from items by 180%, and stamina by 25%.
		-- Druid: Dire Bear Form - buff
		--        Shapeshift into a dire bear, increasing melee attack power by 120, armor contribution from items by 400%, and stamina by 25%.
		-- Druid: Moonkin Form - buff
		--        While in this form the armor contribution from items is increased by 400%, attack power is increased by 150% of your level and all party members within 30 yards have their spell critical chance increased by 5%.
		-- Shaman: Toughness (Rank 5) - 2,11
		--          Increases your armor value from items by 2%/4%/6%/8%/10%.
		-- Warrior: Toughness (Rank 5) - 3,5
		--          Increases your armor value from items by 2%/4%/6%/8%/10%.
		------------------------
		-- Make sure armorFromItems and armor aren't nil
		changes.armorFromItems = changes.armorFromItems or 0
		changes.armor = changes.armor or 0
		
		local armorMod = StatLogic:GetStatMod("MOD_ARMOR");
		local effectiveMastery, masteryEffect = GetMasteryEffect();

		--Guardian Druid: Mastery: Nature's Guardian. Increases your armor by Mastery %
		--if (IsSpellKnown(77494)) then
--			armorMod = armorMod * (1+GetMastery()

		--[[
		local _, _, _, pos, neg = UnitArmor("player")
		local _, agility = UnitStat("player", 2)
		if changes.agi then
			agility = agility + changes.agi
		end
		-- Armor is treated different then stats, 小數點採四捨五入法
		--local armorFromItem = floor(((tpTable.armor - agility * 2 - pos + neg) / armorMod) + 0.5)
		--tpTable.armor = floor(((armorFromItem + changes.armor) * armorMod) + 0.5) + agility * 2 + pos - neg
		--(floor((ceil(stamina / staMod) + changes.sta) * staMod) - stamina)
		local armorBefore = tpTable.armor or 0;
		
		tpTable.armor = 
				round(
					( round((tpTable.armor - agility * 2 - pos + neg) / armorMod) + changes.armorFromItems )*armorMod
				) + agility*2 + pos - neg + changes.armor
		--self:Print(tpTable.armor.." = floor(((floor((("..tpTable.armor.." - "..agility.." * 2 - "..pos.." + "..neg..") / "..armorMod..") + 0.5) + "..changes.armor..") * "..armorMod..") + 0.5) + "..agility.." * 2 + "..pos.." - "..neg)
		--]]
		
		local newArmorFromItemsChanges;
		if (changes.armorFromItems ~= 0) and (armorMod ~= 0) and (armorMod ~= 1) then
			newArmorFromItemsChanges = changes.armorFromItems*armorMod;
			self:Debug(string.format("   Adjusting %d armor from items by %.4f%%, to %d", changes.armorFromItems, armorMod, newArmorFromItemsChanges));
			changes.armorFromItems = newArmorFromItemsChanges;
		end;
		
		--	Druid Guardian.     SpellID: 77494  Mastery: Nature's Guardian. Increases armor by x%
		if (masterySpellID == 77494) and (masteryEffect ~= 1) then
			newArmorFromItemsChanges = changes.armorFromItems*masteryEffect;
			self:Debug(string.format("   Adjusting %d armor from items by %.4f%%, to %d due to Mastery Effect", 
					changes.armorFromItems, masteryEffect, newArmorFromItemsChanges));
			changes.armorFromItems = newArmorFromItemsChanges;
		end;		

		local newArmor = floor(tpTable.armor + changes.armor + changes.armorFromItems);
		self:Debug(string.format("   Adding %d Armor, %d Armor From Items, to existing %d Armor, giving %d Armor",
				changes.armor, changes.armorFromItems, tpTable.armor, newArmor));
		tpTable.armor = newArmor;
	end


	if changes.blockChance and changes.blockChance ~= 0 then
		--self:Debug("Apply blockChance change "..changes.blockChance);
		if doBlock then
			tpTable.blockChance = tpTable.blockChance + changes.blockChance
		end
	end
	
	--Removed 20120804 (5.0.1) Resilience does nothing for tanks
	--if changes.resilience and changes.resilience ~= 0 then
	--	tpTable.resilience = tpTable.resilience + changes.resilience
	--end
	if changes.mobLevel and changes.mobLevel ~= 0 then
		tpTable.mobLevel = tpTable.mobLevel + changes.mobLevel
	end
	if changes.mobDamage and changes.mobDamage ~= 0 then
		tpTable.mobDamage = (tpTable.mobDamage or 0) + changes.mobDamage
	end
	if changes.shieldBlockDelay and changes.shieldBlockDelay ~= 0 then
		tpTable.shieldBlockDelay = tpTable.shieldBlockDelay + changes.shieldBlockDelay
	end
	-- debug
	--self:Print("changes.str = "..(changes.str or "0")..", changes.sta = "..(changes.sta or "0"))
end

--[[
	Validate the passed dataTable ensuring that all required fields are present.
	If the table is valid and complete the function returns true. 
	If the table has missing or invalid values the function returns false,
	and additional error information can be obtained from the member field TankPoints.noTPReason.
	
	Sample usage:
	
		if (not TankPoints:CheckSourceData(dt)) then
			error('Data table "dt" is invalid: '..TankPoints.noTPReason);
		end
--]]
function TankPoints:CheckSourceData(dataTable, school, forceShield)
	local result = true
	
	self.noTPReason = "should have TankPoints"
	
	local function cmax(var, maxi)
		if result then
			if nil == dataTable[var] then
				local msg = var.." is nil"
				self.noTPReason = msg
				--self:Print(msg)
				result = nil
			else
				--self:Print("cmax("..var..")");
				dataTable[var] = max(maxi, dataTable[var])
			end
		end
	end
	local function cmax2(var1, var2, maxi)
		if result then
			if nil == dataTable[var1][var2] then
				local msg = format("dataTable[%s][%s] is nil", tostring(var1), tostring(var2))
				self.noTPReason = msg
				--self:Print(msg)
				result = nil
			else
				dataTable[var1][var2] = max(maxi, dataTable[var1][var2])
			end
		end
	end
	
	-- Check for nil
	-- Fix values that are below minimum
	cmax("playerLevel",1)
	cmax("playerHealth",0)
	cmax("mobLevel",1)
	--cmax("resilience",0)
	
	-- Melee
	if (not school) or school == TP_MELEE then
		cmax("mobCritChance",0)
		cmax("mobCritBonus",0)
		cmax("mobMissChance",0)
		cmax("armor",0)
		--cmax("defense",0)
		--cmax("defenseRating",0)
		cmax("dodgeChance",0)
		if GetParryChance() == 0 then
			dataTable.parryChance = 0
		end
		cmax("parryChance",0);
		if (forceShield == true) or ((forceShield == nil) and self:ShieldIsEquipped()) then
			cmax("blockChance",0)
			--cmax("blockValue",0)
		else
			dataTable.blockChance = 0
			--dataTable.blockValue = 0
		end
		--cmax("mobDamage",0)
		cmax2("damageTakenMod",TP_MELEE,0)
		cmax("shieldBlockDelay",0)
	end
	
	-- Spell
	if (not school) or school > TP_MELEE then
		cmax("mobSpellCritChance",0)
		cmax("mobSpellCritBonus",0)
		cmax("mobSpellMissChance",0)
		-- Negative resistances don't work anymore?
		if not school then
			for _,s in ipairs(self.ElementalSchools) do
				cmax2("resistance", s, 0)
				cmax2("damageTakenMod", s, 0)
			end
		else
			cmax2("resistance", school, 0)
			cmax2("damageTakenMod", school, 0)
		end
	end
	
	--force a display of the bad reason
	if (not result) then
		self:Debug("CheckSourceData: Source table is invalid ("..self.noTPReason..")")
	end
	return result
end

local shieldBlockChangesTable = {}

-- sometimes we only need to get TankPoints if there's nothing already there
-- sooooo....
function TankPoints:GetTankPointsIfNotFilled(table, school)
	if not table.effectiveHealth or not table.tankPoints then
		return self:GetTankPoints(table, school)
	else
		if school then
			if table.effectiveHealth[school] and table.tankPoints then
				return table
			else
				return self:GetTankPoints(table, school)
			end
		else
			for _, s in ipairs(self.ElementalSchools) do
				if not table.effectiveHealth[s] or not table.tankPoints[s] then
					return self:GetTankPoints(table, nil)
				end
			end
			return table
		end
	end
end

--local ArdentDefenderRankEffect = {0.07, 0.13, 0.2}  20101017 Removed in patch 4.0.1

function TankPoints:GetBlockedMod(forceShield)
	--[[
		5.0.4: Blocking an attack happens on a separate roll. 
			So the chance on blocking an attack depends first on the odds of an attack not being
				- Missed
				- Dodged
				- Parried
			only then can we figure out your actual chance of blocking.

		GetBlockedMod returns the average damage reduction due to a shield.
		
		Arguments
			forceShield: Forces the calculation to assume that a shield is equipped. The default
				behaviour is to check if the player has a shield equipped.
				If the player has no shield equipped then GetBlockdMod returns zero (since nothing can be blocked)

		Returns
			The amount of damage blocked by a shield
			
			e.g. Warrior: 30%
			     Warrior reduction due to blocking attacks. For example: 
			
			A block chance of 36%, with paladin's shield blocking 40% of the damage the shield reduces damage by 14.4%. (36% * 40% = 14.4%)
	--]]

	if (not self:ShieldIsEquipped()) and (forceShield ~= true) then -- doesn't have shield equipped
		return 0
	end

	--local result = 0.30; --by default all blocked attacks block a flat 30% of incoming damage
	local result = GetShieldBlock(); --base 30%, will return 31% if you have the meta gem

	--TODO: There is a Meta gem that incrases block amount by an extra 1%, meaning 0.31 should be returned
		
	if self.playerClass == "WARRIOR" then
		--4.0.3 Critical Block removed
		--[[
		if select(5, GetTalentInfo(3, 24)) > 0 then 
			-- Warrior Talent: Critical Block (Rank 3) - 3,24
			--  Your successful blocks have a 20/40/60% chance to block double the normal amount
			local critBlock = 1 + select(5, GetTalentInfo(3, 24)) * 0.2
			result = result * critBlock
		end
		--]]
	elseif (self.playerClass == "PALADIN") then
		--5.0.4 Removed Holy Shield
		--[[
		-- Paladin Talent: Holy Shield - 2,15
		--2011-08-19: Now 20% for 10 seconds, cooldown 30s. Old way: 10% for 20 seconds, cooldown 20s.
		-- 	Shield blocks for an additional 20% for 10 sec. 30 second cooldown
		local holyShieldTalentRank = select(5, GetTalentInfo(2, 15));

		--self:Debug("GetBlockedMod: Paladin has "..holyShieldTalentRank.." points in Holy Shield");
		if (holyShieldTalentRank > 0) then
			result = result + 0.20*10/30  --  So it blocks for an additional 20% 1/3 of the time. So lets call it can extra 6.66%
		end;
		--]]
	end;
	
	return result
end;


function TankPoints:CalculateTankPoints(TP_Table, school, forceShield)
	--Called by GetTankPoints(...)

	------------------
	-- Check Inputs --
	------------------
	if not self:CheckSourceData(TP_Table, school, forceShield) then 
		error("TankPoints:CalculateTankPoints: supplied dataTable is invalid: "..TankPoints.noTPReason);
		return 
	end

	-----------------
	-- Caculations --
	-----------------
	--[[
		Paldin Talent: Ardent Defender
			Reduces all damage by 20% for 10 seconds, with a 3 minute cooldown.
			We model this as a health increase of 1.01111% (1 + 0.2*(10s/180s))
	--]]
	if self.playerClass == "PALADIN" then
		--[[
			5.0.4 (2012/08/03) - Ardent Defender is now native to all Protection paladins (no longer a talent)
				Protection: Reduce damage taken by 20% for 10 seconds. 3 min cooldown

			4.1 (2011-08-19)
				Ardent Defender is on talent page 2, 20
				Paladin Talent: Ardent Defender - 2,20
				Reduce damage taken by 20% for 10 seconds. 3 min cooldown

			Pre-patch 4.0.1
				Paladin Talent: Ardent Defender (Rank 3) - 2,18
				Damage that takes you below 35% health is reduced by 7/13/20%

				Note: Ardent Defender used to be page 2, talent 18 (i.e. GetTalentInfo(2,18))
				
				local _, _, _, _, r = GetTalentInfo(2, 20) --page 2, talent 20
		--]]

		--self:Debug("Ardent Defender points = "..r)

		local knowsArdentDefender = IsSpellKnown(31850); --31850: Ardent Defender - Reduce damage taken by 20% for 10 sec. 3 minute cooldown
		local includeArdentDefender = false

		if (knowsArdentDefender) and (includeArdentDefender) then
			--local inc = 0.35 / (1 - ArdentDefenderRankEffect[r]) - 0.35 -- 8.75% @ rank3    20101017: Old model, when ardent defender was passive

			local ARDENT_DEFENDER_DAMAGE_REDUCTION  = 0.20 --Paladin Ardent Defender ability reduces all damage by 20% for 10 seconds. 3 minute cooldown

			local inc = round(TP_Table.playerHealth * ARDENT_DEFENDER_DAMAGE_REDUCTION * (10/180)); --20% increase for some fraction of the time

			--TP_Table.playerHealth = TP_Table.playerHealth + inc

			self:Debug("TankPoints:CalculateTankPoints(): Applied Ardent Defender health effective increase of "..inc..". New health = "..TP_Table.playerHealth)
		end
	end
	
	-- Resilience Mod
	--Removed 20120804 (5.0.1) Resilience does nothing for tanks
	--TP_Table.resilienceEffect = StatLogic:GetEffectFromRating(TP_Table.resilience, COMBAT_RATING_RESILIENCE_CRIT_TAKEN, TP_Table.playerLevel) * 0.01;  --GetEffectFromRating returns as percentage rather than fraction (GRRRRRRRR!)

	if (not school) or school == TP_MELEE then
		-- Armor Reduction
		TP_Table.armorReduction = self:GetArmorReduction(TP_Table.armor, TP_Table.mobLevel)
		
		--[[20110108: The game no longer has defense
		-- Defense Mod (may return negative)
		--self:Debug("TP_Table.defense = "..TP_Table.defense)
		
		--local defenseFromDefenseRating = floor(StatLogic:GetEffectFromRating(TP_Table.defenseRating, CR_DEFENSE_SKILL))
		--self:Debug("defenseFromDefenseRating = "..defenseFromDefenseRating)
		
		--local drFreeDefense = TP_Table.defense - defenseFromDefenseRating - TP_Table.mobLevel * 5 -- negative for mobs higher level then player
		--self:Debug("drFreeDefense = "..drFreeDefense)
		--]]
		local drFreeAvoidance = 0; --drFreeDefense * 0.0004
		

		--[[
		From http://maintankadin.failsafedesign.com/forum/viewtopic.php?f=4&t=25714
		For each level above 85 the boss gains 0.2% in miss, dodge, parry, block
			-0.2% chance to be missed
			-0.2% chance to dodge
			-0.2% chance to parry
			-0.2% chance to block
			+0.2% chance to be critted
		
		For a mob +3 levels above you
			miss = 5% - 0.6% = 4.4%
			dodge = dodge - 0.6%
			parry = parry - 0.6%
			block = block - 0.6%
			crit = 5% + 0.6% = 5.6%
		--]]
		
		local levelDiff = TP_Table.mobLevel - TP_Table.playerLevel;
		local diffFromLevel = max(0, levelDiff * 0.002)

		
		-- Mob's Crit, Miss
		--self:Debug("todo: figure out how levels affect a mob's crit chance")
		--TP_Table.mobCritChance = max(0, TP_Table.mobCritChance - (TP_Table.defense - TP_Table.mobLevel * 5) * 0.0004 - TP_Table.resilienceEffect + StatLogic:GetStatMod("ADD_CRIT_TAKEN", "MELEE"))
		TP_Table.mobCritChance = max(0, TP_Table.mobCritChance + diffFromLevel); --
		TP_Table.mobCritChance = max(0, TP_Table.mobCritChance + StatLogic:GetStatMod("ADD_CRIT_TAKEN", "MELEE"))
		
		--local bonusDefense = TP_Table.defense - TP_Table.playerLevel * 5
		
		--self:Debug("before miss chance calc. mobMissChance = "..TP_Table.mobMissChance)
--		self:Debug("drFreeAvoidance = "..drFreeAvoidance)
		
		--self:Debug("todo: figure out what affects a mob's miss chance")
		--TP_Table.mobMissChance = max(0, TP_Table.mobMissChance + drFreeAvoidance + StatLogic:GetAvoidanceAfterDR("MELEE_HIT_AVOID", defenseFromDefenseRating * 0.04) * 0.01)
		TP_Table.mobMissChance = max(0, TP_Table.mobMissChance - diffFromLevel);
--		self:Debug("after miss chance calc. TP_Table.mobMissChance = "..TP_Table.mobMissChance)
		
		
		-- Dodge, Parry, Block
		TP_Table.dodgeChance = max(0, TP_Table.dodgeChance - diffFromLevel)
		TP_Table.parryChance = max(0, TP_Table.parryChance - diffFromLevel)
		
		-- Block Chance, Block Value
		-- Check if player has shield or forceShield is set to true
		if (forceShield == true) or ((forceShield == nil) and self:ShieldIsEquipped()) then
			TP_Table.blockChance = max(0, TP_Table.blockChance - diffFromLevel)
		else
			TP_Table.blockChance = 0
		end
		
		-- Crushing Blow Chance
		TP_Table.mobCrushChance = 0
		if (TP_Table.mobLevel - TP_Table.playerLevel) > 3 then -- if mob is 4 levels or above crushing blow will happen
			-- The chance is 10% per level difference minus 15%
			TP_Table.mobCrushChance = (TP_Table.mobLevel - TP_Table.playerLevel) * 0.1 - 0.15
		end
		
		-- Mob's Crit Damage Mod
		--Removed 20120804 (5.0.1) Resilience does nothing for tanks
		TP_Table.mobCritDamageMod = 1; --max(0, 1 - TP_Table.resilienceEffect * 2)
		
		--Get the percentage of an attack that is blocked, if it is blocked
		TP_Table.blockedMod = self:GetBlockedMod(forceShield)/100; --31 --> 0.31
	end
	if (not school) or school > TP_MELEE then
		-- Mob's Spell Crit
		TP_Table.mobSpellCritChance = max(0, TP_Table.mobSpellCritChance + StatLogic:GetStatMod("ADD_CRIT_TAKEN", "HOLY"))

		-- Mob's Spell Crit Damage Mod
		--20120804 5.0.1  Resilience does nothing for tanks
		TP_Table.mobSpellCritDamageMod = 1; --max(0, 1 - TP_Table.resilienceEffect * 2)
	end
	---------------------
	-- High caps check --
	---------------------
	if (not school) or school == TP_MELEE then
		-- Hit < Crushing < Crit < Block < Parry < Dodge < Miss
		local combatTable = {}
		-- build total sums
		local total = TP_Table.mobMissChance
		tinsert(combatTable, total)
		total = total + TP_Table.dodgeChance
		tinsert(combatTable, total)
		total = total + TP_Table.parryChance
		tinsert(combatTable, total)
		total = total + TP_Table.blockChance
		tinsert(combatTable, total)
		total = total + TP_Table.mobCritChance
		tinsert(combatTable, total)
		total = total + TP_Table.mobCrushChance
		tinsert(combatTable, total)
		-- check caps
		
		if combatTable[1] > 1 then
			TP_Table.mobMissChance = 1
		end
		if combatTable[2] > 1 then
			TP_Table.dodgeChance = max(0, 1 - combatTable[1])
		end
		if combatTable[3] > 1 then
			TP_Table.parryChance = max(0, 1 - combatTable[2])
		end
		if combatTable[4] > 1 then
			TP_Table.blockChance = max(0, 1 - combatTable[3])
		end
		if combatTable[5] > 1 then
			TP_Table.mobCritChance = max(0, 1 - combatTable[4])
		end
		if combatTable[6] > 1 then
			TP_Table.mobCrushChance = max(0, 1 - combatTable[5])
		end
		-- Regular Hit Chance (non-crush, non-crit)
		
		TP_Table.mobHitChance = 1 - (TP_Table.mobCrushChance + TP_Table.mobCritChance + TP_Table.blockChance + TP_Table.parryChance + TP_Table.dodgeChance + TP_Table.mobMissChance)
		-- Chance mob will make contact with you that is not blocked/dodged/parried
		TP_Table.mobContactChance = TP_Table.mobHitChance + TP_Table.mobCrushChance + TP_Table.mobCritChance
	end
	if (not school) or school > TP_MELEE then
		-- Hit < Crit < Miss
		local combatTable = {}
		-- build total sums
		local total = TP_Table.mobSpellMissChance
		tinsert(combatTable, total)
		total = total + TP_Table.mobSpellCritChance
		tinsert(combatTable, total)
		-- check caps
		if combatTable[1] > 1 then
			TP_Table.mobSpellMissChance = 1
		end
		if combatTable[2] > 1 then
			TP_Table.mobSpellCritChance = max(0, 1 - combatTable[1])
		end
	end

	--self:Debug("TankPoints:CalculateTankPoints(): "..TP_Table.mobMissChance, TP_Table.dodgeChance, TP_Table.parryChance, TP_Table.blockChance, TP_Table.mobCritChance, TP_Table.mobCrushChance)
	
	------------------------
	-- Final Calculations --
	------------------------
	if type(TP_Table.schoolReduction) ~= "table" then
		TP_Table.schoolReduction = {}
	end
	if type(TP_Table.totalReduction) ~= "table" then
		TP_Table.totalReduction = {}
	end
	if type(TP_Table.tankPoints) ~= "table" then
		TP_Table.tankPoints = {}
	end
	if type(TP_Table.effectiveHealth) ~= "table" then
		TP_Table.effectiveHealth = {}
	end
	if type(TP_Table.effectiveHealthWithBlock) ~= "table" then
		TP_Table.effectiveHealthWithBlock = {}
	end
	if type(TP_Table.guaranteedReduction) ~= "table" then
		TP_Table.guaranteedReduction = {}
	end
	
	local function calc_melee()
		-- School Reduction
		TP_Table.schoolReduction[TP_MELEE] = TP_Table.armorReduction
		
		local avoidance = 1 - (TP_Table.mobMissChance+TP_Table.dodgeChance+TP_Table.parryChance);
		--self:Debug(string.format("(avoidance%s) = 1 - (mobMissChance:%s) - (dodgeChance:%s) - (parryChance:%s)", 
				--avoidance, TP_Table.mobMissChance, TP_Table.dodgeChance, TP_Table.parryChance));
		assert(avoidance >= 0, "Avoidance must be positive");

		--fraction of damage taken (e.g. 0.8701 = 87.01%)
		local reductionFromBlock = 1 - TP_Table.blockChance*TP_Table.blockedMod;
		assert(reductionFromBlock >= 0, "reductionFromBlock must be positive");

		--self:Debug(string.format("(reductionFromBlock:%s) = (blockChance:%s)*(1 - blockedMod:%s) * (1 - blockChance)",
				--reductionFromBlock, TP_Table.blockChance, TP_Table.blockedMod, TP_Table.blockChance));

		local increaseFromCrit = 
				(1 + TP_Table.mobCritChance*TP_Table.mobCritBonus*TP_Table.mobCritDamageMod); --crit damage
				--(1 + 0.03*1*1 ) = 1.03
		assert(increaseFromCrit >= 0, "reductionFromBlock is negative");

		local reductionFromArmor = 
				(1-TP_Table.armorReduction);
				--(1 - 0.598366969650285) = 0.401633030349715
		assert(reductionFromArmor >= 0, "reductionFromArmor must be positive");

		local damageTaken = 
				avoidance* --0.53735492229 
				reductionFromBlock * --0.90094236755371
				increaseFromCrit* --1.03
				reductionFromArmor* --0.401633030349715
				TP_Table.damageTakenMod[TP_MELEE]; --0.85
		assert(damageTaken >= 0, "damageTaken must be positive");

		local damageTakenCalculationDetails = string.format(
				"DamageTaken: %.4f%% = \r\n"..
				"   Avoidance: %.4f%% * \r\n"..
				"   Block: %.4f%% * \r\n"..
				"   Crit: %.2f%% * \r\n"..
				"   Armor: %.4f%% * \r\n"..
				"   Damage Taken Modifier: %.4f%%",
				damageTaken*100, avoidance*100, reductionFromBlock*100, increaseFromCrit*100, reductionFromArmor*100, TP_Table.damageTakenMod[TP_MELEE]*100
				);

		TP_Table.damageTaken = damageTaken;
		TP_Table.damageTakenCalculationDetails = damageTakenCalculationDetails;

		--print(damageTakenCalculationDetails);

		--assert(damageTaken, "damageTaken is nil");
		--self:Debug(string.format("damageTaken: %s", damageTaken));
				

		-- Total Reduction (e.g. 0.753 = 75.3%)
		TP_Table.totalReduction[TP_MELEE] = (1 - damageTaken);
		--[[
		TP_Table.totalReduction[TP_MELEE] = 1 - 
			(
				--this is the heart of the combat table
				1 
				- TP_Table.mobMissChance
				- TP_Table.dodgeChance 
				- TP_Table.parryChance 
				- TP_Table.blockChance * TP_Table.blockedMod 
				+ (TP_Table.mobCritChance * TP_Table.mobCritBonus * TP_Table.mobCritDamageMod)
				+ (TP_Table.mobCrushChance * 0.5)
			) * (1 - TP_Table.armorReduction) * TP_Table.damageTakenMod[TP_MELEE]
		--]]
		-- TankPoints
		TP_Table.tankPoints[TP_MELEE] = TP_Table.playerHealth / (1 - TP_Table.totalReduction[TP_MELEE])
		self:Debug(string.format("(tankPoints:%s) = (playerHealth:%s) / (1 - (totalReduction:%s)",
				TP_Table.tankPoints[TP_MELEE], TP_Table.playerHealth, TP_Table.totalReduction[TP_MELEE]));

		-- Guaranteed Reduction
		TP_Table.guaranteedReduction[TP_MELEE] = 1 - ((1 - TP_Table.armorReduction) * TP_Table.damageTakenMod[TP_MELEE])
		-- Effective Health
		TP_Table.effectiveHealth[TP_MELEE] = TP_Table.playerHealth / (1 - TP_Table.guaranteedReduction[TP_MELEE])
		-- Effective Health with Block
		TP_Table.effectiveHealthWithBlock[TP_MELEE] = self:GetEffectiveHealthWithBlock(TP_Table, TP_Table.mobDamage or 0)
	end
	local function calc_spell_school(s)
		-- Resistance Reduction = 0.75 (resistance / (mobLevel * 5))
		TP_Table.schoolReduction[s] = 0.75 * (TP_Table.resistance[s] / (max(TP_Table.mobLevel, 20) * 5))
		-- Total Reduction
		TP_Table.totalReduction[s] = 1 - (1 - TP_Table.mobSpellMissChance + (TP_Table.mobSpellCritChance * TP_Table.mobSpellCritBonus * TP_Table.mobSpellCritDamageMod)) * (1 - TP_Table.schoolReduction[s]) * TP_Table.damageTakenMod[s]
		TP_Table.guaranteedReduction[s] = 1-((1 - TP_Table.schoolReduction[s]) * TP_Table.damageTakenMod[s])
		TP_Table.effectiveHealth[s] = TP_Table.playerHealth / (1 - TP_Table.guaranteedReduction[s])
		-- TankPoints
		TP_Table.tankPoints[s] = TP_Table.playerHealth / (1 - TP_Table.totalReduction[s])
	end
	
	--self:Debug("TankPoints:CalculateTankPoints: Preparing final calculations.")
	
	if not school then
		calc_melee()
		for _,s in ipairs(self.ElementalSchools) do
			calc_spell_school(s)
		end
	else
		if school == TP_MELEE then
			calc_melee()
		else
			calc_spell_school(school)
		end
	end
	
--	if (TP_Table.tankPoints == nil) then
		--self:Debug("TankPoints:CalcualteTankPoints: TP_Table.tankPoints is not assigned")
	--end
	
	return TP_Table
end

function TankPoints:GetTankPoints(TP_Table, school, forceShield)

	--self:Debug("TankPoints:GetTankPoints(...)");

	-----------------
	-- Aquire Data --
	-----------------
	-- Set true if temp table is created
	local tempTableFlag
	if not TP_Table then
		self:Debug("TankPoints:GetTankPoints(): Passed TP_Table is nil, constructing local copy")
		tempTableFlag = true
		-- Fill table with player values
		TP_Table = self:GetSourceData(nil, school)
	end
	
	------------------
	-- Check Inputs --
	------------------
	if (not self:CheckSourceData(TP_Table, school, forceShield)) then 
		self:Debug("TankPoints:GetTankPoints: CheckSourceData failed ("..self.noTPReason.."). Returning pre-maturely")
		error("TankPoints:GetTankPoints: supplied dataTable is invalid: "..TankPoints.noTPReason);
		return 
	end

	-----------------
	-- Caculations --
	-----------------
	--[[
	--5.0.4 20120803 - Shield Block removed in Mists

	-- Warrior Skill: Shield Block - 1 min cooldown
	-- 	Increases your chance to block and block value by 100% for 10 sec.
	-- Warrior Talent: Shield Mastery (Rank 2) - 3,8
	--	Increases your block value by 15%/30% and reduces the cooldown of your Shield Block ability by 10/20 sec.
	-- GetSpellInfo(2565) = "Shield Block"

	if self.playerClass == "WARRIOR" and (not school or school == TP_MELEE) and not UnitBuff("player", SI["Shield Block"]) then

		-- Get a copy for Shield Block skill calculations
		local inputCopy = {}
		copyTable(inputCopy, TP_Table)

		-- Build shieldBlockChangesTable
		shieldBlockChangesTable.blockChance = 1 -- 100%
		shieldBlockChangesTable.blockValue = 0 --inputCopy.blockValue -- +100%
		-- Calculate TankPoints assuming shield block is always up
		self:AlterSourceData(inputCopy, shieldBlockChangesTable, forceShield)
		self:CalculateTankPoints(inputCopy, TP_MELEE, forceShield)
		self:CalculateTankPoints(TP_Table, school, forceShield)
		-- Calculate Shield Block up time
		local _, _, _, _, r = GetTalentInfo(3, 8)
		local shieldBlockCoolDown = 60 - r * 10
		local shieldBlockUpTime = 10 / (shieldBlockCoolDown + inputCopy.shieldBlockDelay)
		TP_Table.totalReduction[TP_MELEE] = TP_Table.totalReduction[TP_MELEE] * (1 - shieldBlockUpTime) + inputCopy.totalReduction[TP_MELEE] * shieldBlockUpTime
		TP_Table.tankPoints[TP_MELEE] = TP_Table.tankPoints[TP_MELEE] * (1 - shieldBlockUpTime) + inputCopy.tankPoints[TP_MELEE] * shieldBlockUpTime
		TP_Table.shieldBlockUpTime = shieldBlockUpTime
		inputCopy = nil

	--20120803 - 5.0.4 - Holy Shield removed in Mists
	-- Paladin Talent: Holy Shield - 2,15
	-- 	Shield blocks for an additional 10% for 20 sec.
	elseif (self.playerClass == "PALADIN") and (select(5, GetTalentInfo(2, 15)) > 0)
			and (not school or school == TP_MELEE) and not UnitBuff("player", SI["Holy Shield"]) then

		--self:Debug("TankPoints:GetTankPoints: Player is a paladin who has Holy Shield talent, but it's not active. Increasing block by 10%")
		--normally all blocked attacks are reduced by a fixed 30%. Holy shield increases the blocked amount by 10%

		--Assume 100% uptime on Holy Shield
		
		--self:Debug("TankPoints:GetTankPoints: Calling paladin version of TankPoints:CalculateTankPoints")
		self:CalculateTankPoints(TP_Table, school, forceShield)
	else
		--self:Debug("TankPoints:GetTankPoints: Player is someone who doesn't need to have a block ability manually added")
		self:CalculateTankPoints(TP_Table, school, forceShield)
	end
	--]]
	
	self:CalculateTankPoints(TP_Table, school, forceShield)


	-------------
	-- Cleanup --
	-------------
	if tempTableFlag then
		local tankPoints, totalReduction, schoolReduction = TP_Table.tankPoints[school or TP_MELEE], TP_Table.totalReduction[school or TP_MELEE], TP_Table.schoolReduction[school or TP_MELEE]
		TP_Table = nil
		return tankPoints, totalReduction, schoolReduction
	end
	return TP_Table
end

function TankPoints:IntToStr(value)
	local s = tostring(value)
	local length = strlen(s)
	if length < 4 then
		return s
	elseif length < 7 then
		return (gsub(s, "^([+-]?%d%d?%d?)(%d%d%d)$", "%1,%2", 1))
	elseif length < 10 then
		return (gsub(s, "^([+-]?%d%d?%d?)(%d%d%d)(%d%d%d)$", "%1,%2,%3", 1))
	else
		return s
	end
end

function TankPoints:DumpTableRaw(tpTable)

	if not (tpTable) then
		self:Print("TankPoints table is empty");
		return;
	end

	self:Print(self:VarAsString(tpTable));
end;

--[[
Returns true if the user is pressing the configured "Suppress all the things!" key
--]]
function TankPoints:IsSuppressKeyPressed()
	return IsControlKeyDown();
end;


function TankPoints:DumpTable(tpTable)

--	self:UpdateDataTable();

	if not (tpTable) then
		self:Print("TankPoints table is empty");
		return;
	end

	--self:Print(self:VarAsString(tpTable));
	
	--see UpdateDataTable for TP clculation
	
	local function IntToStr(value)
		return self:IntToStr(value)
	end;
	
	local function PercentToStr(value)
		value = tonumber(value);
		if (value == nil) then
			value = 0;
		end;
			
		return string.format("%.4f%%", value*100)
	end;
	
	self:Print("TankPoints table:");
	self:Print("   playerHealth: "..IntToStr(tpTable.playerHealth));
	self:Print("   playerLevel: "..IntToStr(tpTable.playerLevel));
	self:Print("   mobLevel: "..IntToStr(tpTable.mobLevel));
	self:Print("   armor: "..IntToStr(tpTable.armor));
	self:Print("   mobMissChance: "..PercentToStr(tpTable.mobMissChance));
	self:Print("   dodgeChance: "..PercentToStr(tpTable.dodgeChance));
	self:Print("   parryChance: "..PercentToStr(tpTable.parryChance));
	self:Print("   blockChance: "..PercentToStr(tpTable.blockChance));
	self:Print(string.format("   mastery: %.2f", tpTable.mastery)); --Mastery isn't a percentage, it's a real number, e.g. 14.46
	self:Print("   mobCritChance: "..PercentToStr(tpTable.mobCritChance));
	self:Print("   mobCritBonus: "..PercentToStr(tpTable.mobCritBonus));
	self:Print("   mobCritDamageMod: "..PercentToStr(tpTable.mobCritDamageMod));
	self:Print("   mobCrushChance: "..PercentToStr(tpTable.mobCrushChance));
	self:Print("   armorReduction: "..PercentToStr(tpTable.armorReduction));
	self:Print("   blockedMod: "..PercentToStr(tpTable.blockedMod));
	self:Print("   mobHitChance: "..PercentToStr(tpTable.mobHitChance));
	self:Print("   mobContactChance: "..PercentToStr(tpTable.mobContactChance));
	self:Print("   guaranteedReduction: "..PercentToStr(tpTable.guaranteedReduction[TP_MELEE]));
	self:Print("   effectiveHealth: "..IntToStr(tpTable.effectiveHealth[TP_MELEE]));
	self:Print("   effectiveHealthWithBlock: "..IntToStr(tpTable.effectiveHealthWithBlock[TP_MELEE]));
	self:Print("   totalReduction: "..PercentToStr(tpTable.totalReduction[TP_MELEE]));
	self:Print("   tankPoints: "..IntToStr(tpTable.tankPoints[TP_MELEE]));

end;


---------------------------------------------------------
-- Toggle the TankPoints calculator, if it's available --
---------------------------------------------------------
function TankPoints:ToggleCalculator()
	local tpc = TankPointsCalculatorFrame;
	if (tpc) then
		if(tpc:IsVisible()) then
			tpc:Hide()
		else
			tpc:Show()
		end
		self:UpdateTankPoints("Toggle_Calculator")
	end
end;


------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
if (WoWUnit) then

local function checkEquals(expected, actual, message)
	--print("LibStatLogic:checkEquals");
	--print("1-->expected: "..(expected or "nil"));
	--print("1-->actual: "..(actual or "nil"));
	--print("1-->message: "..(message or "nil"));
	
	return WoWUnit.CheckEquals(expected, actual, message);
end;

local LibStatLogicTests = {

	mocks = {
		UnitName = function(arg)
			return "Soandso";
		end;
	};
	
	setUp = function()
		return {};
	end;
	tearDown = function()
		-- no tear down required
	end;
	
	testExample = function()
		assert(UnitName("player") == "Soandso", "Expected player name to be 'Soandso'");
	end;
	
	--testFailure = function()
	--	assert(UnitName("player") == "Feithar", "Expected player name to be 'Feithar'");
	--end;
	
	testGetSpecializationWithNoActiveSpecialization = function()
		TankPoints:RecordStats();
	end;

	testMasteryAndArmorChange = function()

		-- Initialize Tables --
		local sourceDT = TankPoints.sourceTable; --the player's current stats
		local resultsDT = TankPoints.resultsTable; --the player's current TankPoints
		local changesDT = {}; --the changes we wish to apply
		local newDT = {}; --the players updated TankPoints after the changes are applied
	
		copyTable(newDT, sourceDT) -- load default data
		TankPoints:AlterSourceData(newDT, {armorFromItems=500, masteryRating=50});
	end;
	
};	

WoWUnit:AddTestSuite("tp", LibStatLogicTests);
print("Registered TankPoints unit tests. Run the tests using: /wu tp");
else
	--no WoWUnit
	--print("LibStatLogic: Could not register TankPoints unit tests");
end; --if (WoWUnit)
