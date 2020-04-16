-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints Tooltips
Description: Displays TankPoints difference in item tooltips
Revision: $Revision: 214 $
Author: Whitetooth
Email: hotdogee [at] gmail [dot] com
LastUpdate: $Date: 2013-06-16 11:42:03 +0800 (Sun, 16 Jun 2013) $
]]

---------------
-- Libraries --
---------------
local TipHooker = LibStub:GetLibrary("LibTipHooker-1.1")
local StatLogic = LibStub:GetLibrary("LibStatLogic-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("TankPoints") --Get the localization for our addon


--------------------
-- Initialization --
--------------------
TankPointsTooltips = {}
local TPTips = TankPointsTooltips
local TP = TankPoints


---------------------
-- Local Variables --
---------------------
local DEBUG = true

-- Localize Lua globals
local pairs = pairs
local ipairs = ipairs
local strsplit = strsplit
local floor = floor
local setmetatable = setmetatable
local getmetatable = getmetatable

-- Localize WoW globals
local IsEquippableItem = IsEquippableItem
local IsEquippedItemType = IsEquippedItemType
local GetCombatRating = GetCombatRating


-----------
-- Cache --
-----------
local cache = {}
setmetatable(cache, {__mode = "kv"}) -- weak table to enable garbage collection

function TPTips.ClearCache()
	for k in pairs(cache) do
		cache[k] = nil
	end
end


-------------------
-- General Tools --
-------------------
-- copyTable
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

local function commaValue(integer)
	local s = tostring(integer)
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

-- Color Numbers
local GREEN_FONT_COLOR_CODE = GREEN_FONT_COLOR_CODE -- "|cff20ff20" Green
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE -- "|cffffffff" White
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE -- "|cffffffff" White
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE -- "|r"
local function colorNum(text, num)
	if num > 0 then
		return GREEN_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE
	elseif num < 0 then
		return RED_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE
	else
		return HIGHLIGHT_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE
	end
end


----------------------
-- TankPoints Tools --
----------------------
-- TPTips:GetItemSubType(itemID|"name"|"itemlink")
function TPTips:GetItemSubType(item)
	local _, _, _, _, _, _, itemSubType = GetItemInfo(item)
	return itemSubType
end
-- TPTips:IsShield(itemID|"name"|"itemlink")
function TPTips:IsShield(item)
	return GetItemEquipLoc(item) == "INVTYPE_SHIELD"
end
-- TPTips:GetItemEquipLoc(itemID|"name"|"itemlink")
function TPTips:GetItemEquipLoc(item)
	local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(item)
	return itemEquipLoc
	--[[
	INVTYPE_AMMO           = 0,
	INVTYPE_GUNPROJECTILE  = 0,
	INVTYPE_BOWPROJECTILE  = 0,
	INVTYPE_HEAD           = 1,
	INVTYPE_NECK           = 2,
	INVTYPE_SHOULDER       = 3,
	INVTYPE_BODY           = 4,
	INVTYPE_CHEST          = 5,
	INVTYPE_ROBE           = 5,
	INVTYPE_WAIST          = 6,
	INVTYPE_LEGS           = 7,
	INVTYPE_FEET           = 8,
	INVTYPE_WRIST          = 9,
	INVTYPE_HAND           = 10,
	INVTYPE_FINGER         = {11,12},
	INVTYPE_TRINKET        = {13,14},
	INVTYPE_CLOAK          = 15,
	INVTYPE_WEAPON         = {16,17},
	INVTYPE_2HWEAPON       = 16+17,
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_WEAPONOFFHAND  = 17,
	INVTYPE_SHIELD         = 17,
	INVTYPE_HOLDABLE       = 17,
	INVTYPE_RANGED         = 18,
	INVTYPE_RANGEDRIGHT    = 18,
	INVTYPE_RELIC          = 18,
	INVTYPE_GUN            = 18,
	INVTYPE_CROSSBOW       = 18,
	INVTYPE_WAND           = 18,
	INVTYPE_THROWN         = 18,
	INVTYPE_TABARD         = 19,
	--]]
end

----------
-- Core --
----------
-- Build changes table for TP:AlterSourceData from StatLogic:GetDiff table
function TPTips:BuildChanges(reserved, table)
	TP:Debug("TPTips:BuildChanges()  StatLogic changes table="..TP:VarAsString(table))

	local changes = {}
	changes.str = table.STR
	changes.agi = table.AGI
	changes.sta = table.STA
	changes.playerHealth = table.HEALTH
	changes.armorFromItems = table.ARMOR
	changes.armor = table.ARMOR_BONUS
	changes.defenseRating = table.DEFENSE_RATING
	changes.dodgeRating = table.DODGE_RATING;
	changes.parryRating = table.PARRY_RATING;
	changes.blockRating = table.BLOCK_RATING;
	changes.masteryRating = table.MASTERY_RATING;
	changes.blockValue = table.BLOCK_VALUE

	--Removed 20120804  5.0.1  Resilience does nothing for tanks
	--changes.resilience = table.RESILIENCE_RATING
	return changes
end

local function set_cache(link,tpleft,tpright,ehleft,ehright,ehbleft,ehbright,drleft,drright)
	local cacheValue = ""
	if tpright then
		cacheValue = cacheValue..format("%s@%s",tpleft,tpright)
	end
	cacheValue = cacheValue .. "$"
	if ehright then
		cacheValue = cacheValue..format("%s@%s",ehleft,ehright)
	end
	cacheValue = cacheValue .. "$"
	if ehbright then
		cacheValue = cacheValue..format("%s@%s",ehbleft,ehbright)
	end
	cacheValue = cacheValue .. "$"
	if drright then
		cacheValue = cacheValue..format("%s@%s",drleft,drright)
	end
	cache[link] = cacheValue
end

local function exist_cache_entry(link)
	return cache[link]
end

local function get_cache(link)
	local tp,eh,ehb,dr = strsplit("$",cache[link])
	local tpleft,tpright,ehleft,ehright,ehbleft,ehbright,drleft,drright
	if tp then
		tpleft,tpright = strsplit("@",tp)
	end
	if eh then
		ehleft,ehright = strsplit("@",eh)
	end
	if ehb then
		ehbleft,ehbright = strsplit("@",ehb)
	end
	if dr then
		drleft,drright = strsplit("@",dr)
	end
	return tpleft,tpright,ehleft,ehright,ehbleft,ehbright,drleft,drright
end

-- Debug
-- TankPointsTooltips:BuildChanges({}, StatLogic:GetDiff(24396))
function TPTips.ProcessTooltip(tooltip, name, link)
--[[
	tooltip: A game tooltip window object that we should add our TankPoints calculations to.
	name: reserved (not used)
	link: an ItemLink of the item being inspected
--]]

	--TP:Debug("(TPTips.ProcessTooltip)");

	if not (TP.resultsTable and TP.resultsTable.tankPoints) then
		TP:Debug("(TPTips.ProcessTooltip) TP:resultsTable or TP:resultsTable.tankPoints is nil; building with call to TP:ProcessTooltip");
		TP:Debug("(TPTips.ProcessTooltip) TP:resultsTable = "..TP:VarAsString(TP.resultsTable));
		TP:Debug("(TPTips.ProcessTooltip) TP:resultsTable = "..TP:VarAsString(TP.resultsTable.tankPoints));
		TP:UpdateDataTable()
	end

	assert(TP)
	assert(TP.resultsTable)
	assert(TP.resultsTable.tankPoints, "TP.resultsTable.tankpoints is not assigned")	
	
	local profile = TankPoints.db.profile
	
	-- Check if option is enabled
	if not (profile.showTooltipDiff or profile.showTooltipTotal or
			profile.showTooltipDRDiff or profile.showtooltipDRTotal or
			profile.showTooltipEHDiff or profile.showTooltipEHTotal or
			profile.showTooltipEHBDiff or profile.showTooltipEHBTotal) then 
		TP:Debug("TPTips:ProcessTooltip: No option to show toolsips enabled. Exiting");
		return 
	end
			
	-- Check if item is equippable, bags will still pass through
	if not (IsEquippableItem(link) or (TPTips:GetItemSubType(link) == L["Gems"])) then return end
	
	local suppressEnchants;
	if TP:IsSuppressKeyPressed() then
		suppressEnchants = true
	else
		suppressEnchants = false;
	end;
	
	-- Get data from cache if available
	-- We can't be checking the cache if they're asking for a temporary alternate form (suppressEnchants)
	if (not suppressEnchants) and exist_cache_entry(link) then
		local tpleft,tpright, ehleft,ehright, ehbleft,ehbright,drleft,drright = get_cache(link)
		if tpleft then
			tooltip:AddDoubleLine(tpleft,tpright)
		end
		if drleft then
			tooltip:AddDoubleLine(drleft,drright)
		end
		if ehleft then
			tooltip:AddDoubleLine(ehleft,ehright)
		end
		if ehbleft then
			tooltip:AddDoubleLine(ehbleft,ehbright)
		end
		tooltip:Show()
		return
	end
	
	--[[
	if (suppressEnchants) then
		tooltip:AddDoubleLine("Suppressing enchants", suppressEnchants);	
	end;

	if (not suppressEnchants) then
		tooltip:AddDoubleLine("Not suppressing enchants", suppressEnchants);	
	end;
	--]]

	-- Get diff tables
	local diffTable1, diffTable2
	if TPTips:GetItemSubType(link) == L["Gems"] then
		diffTable1 = StatLogic:GetSum(link)
	else
		local ignoreEnchants = profile.ignoreGemsInTooltipDiff;
		local ignoreGems = profile.ignoreEnchantsInTooltipDiff;
		local ignorePrismatic = profile.ignorePrismaticInTooltipDiff;
		
		if suppressEnchants then
			if (not ignoreEnchants) or (not ignoreGems) or (not ignorePrismatic) then
				ignoreEnchants = true;
				ignoreGems = true;
				ignorePrismatic = true;
				--tooltip:AddDoubleLine("Ignoring enchants", suppressEnchants);	
			else
				ignoreEnchants = false;
				ignoreGems = false;
				ignorePrismatic = false;
				--tooltip:AddDoubleLine("Including enchants", suppressEnchants);
			end;
		end;

		
		diffTable1, diffTable2 = StatLogic:GetDiff(link, nil, nil, ignoreEnchants, ignoreGems, nil, nil, nil, nil, ignorePrismatic)
	end
	
	-- Check for bags
	if not diffTable1 then
		return
	end
	
	-- Item type
	local itemType = diffTable1.itemType
	local tpRight, ehRight, ehbRight, drRight
	
	-- Calculate current TankPoints
	local tpSource = {}
	TP:GetSourceData(tpSource, TP_MELEE)
	
	local tpResults = {}
	copyTable(tpResults, tpSource)
	TP:GetTankPoints(tpResults, TP_MELEE)
	
	-- Update and ClearCache if different
	assert(TP)
	assert(TP.resultsTable)
	assert(TP.resultsTable.tankPoints)
	assert(tpResults)
	assert(tpResults.tankPoints)
	
	if floor(TP.resultsTable.tankPoints[TP_MELEE]) ~= floor(tpResults.tankPoints[TP_MELEE]) then
		copyTable(TP.sourceTable, tpSource)
		copyTable(TP.resultsTable, tpResults)
		TPTips.ClearCache()
	end
	----------------------------------------------------
	-- Calculate TP difference with 1st equipped item --
	----------------------------------------------------
	local tpTable = {}

	-- Set the forceShield arg
	local forceShield
	-- if not equipped shield and item is shield then force on
	-- if not equipped shield and item is not shield then nil
	-- if equipped shield and item is shield then nil
	-- if equipped shield and item is not shield then force off
	if ((diffTable1.diffItemType1 ~= "INVTYPE_SHIELD") and (diffTable1.diffItemType2 ~= "INVTYPE_SHIELD")) and (itemType == "INVTYPE_SHIELD") then
		forceShield = true
	elseif ((diffTable1.diffItemType1 == "INVTYPE_SHIELD") or (diffTable1.diffItemType2 == "INVTYPE_SHIELD")) and (itemType ~= "INVTYPE_SHIELD") then
		forceShield = false
	end
	-- Get the tp table
	TP:GetSourceData(tpTable, TP_MELEE, forceShield)
	
	-- Build changes table
	local changes = TPTips:BuildChanges({}, diffTable1)
	
	-- Alter tp table
	--TP:Debug("Data before changes: "..TP:VarAsString(tpTable));
	TP:Debug("TPTips.ProcessChanges(): Changes= "..TP:VarAsString(changes))
	TP:AlterSourceData(tpTable, changes, forceShield)
	--TP:Debug("Data after changes: "..TP:VarAsString(tpTable));	
	
	-- Calculate TankPoints from tpTable
	TP:GetTankPoints(tpTable, TP_MELEE, forceShield)
	--TP:Debug("Data with TankPoints calculations: "..TP:VarAsString(tpTable));	
	
	-- Calculate tp difference
	local function rightFromDifference(before, after, diffp, totalp, diff_format, tot_format)
		local suffix = "";

		diff_format = diff_format or "%+d"
		tot_format = tot_format or "%d"
		local diff = before - after
		if TPTips:GetItemSubType(link) == L["Gems"] and diff == 0 then
			return nil
		end
		local str = nil
		if diffp then
			str = colorNum(commaValue(format(diff_format,diff)), diff)
		end
		if totalp then
			if diffp then
				str = str.."("..colorNum(commaValue(format(tot_format, after)), diff)..")"
			else
				str = colorNum(commaValue(format(tot_format, after)), diff)
			end
		end
		if suffix and str then
			str = str..suffix;
		end
		return str
	end
	tpRight = rightFromDifference(tpTable.tankPoints[TP_MELEE], TP.resultsTable.tankPoints[TP_MELEE], profile.showTooltipDiff, profile.showTooltipTotal)
	drRight = rightFromDifference(tpTable.totalReduction[TP_MELEE]*100, TP.resultsTable.totalReduction[TP_MELEE]*100, profile.showTooltipDRDiff, profile.showTooltipDRTotal,"%+.2f %%","%.2f %%")
	ehRight = rightFromDifference(tpTable.effectiveHealth[TP_MELEE], TP.resultsTable.effectiveHealth[TP_MELEE], profile.showTooltipEHDiff, profile.showTooltipEHTotal)
	if TankPoints.playerClass == "WARRIOR" then
		ehbRight = rightFromDifference(tpTable.effectiveHealthWithBlock[TP_MELEE], TP.resultsTable.effectiveHealthWithBlock[TP_MELEE], profile.showTooltipEHBDiff, profile.showTooltipEHBTotal)
	end
	
	--------------------------------------------------------------
	-- Calculate TP difference with 2nd equipped item if needed --
	--------------------------------------------------------------
	if diffTable2 then
		local tpTable = {}
		local forceShield
		if (diffTable2.diffItemType1 ~= "INVTYPE_SHIELD") and (itemType == "INVTYPE_SHIELD") then
			forceShield = true
		elseif (diffTable2.diffItemType1 == "INVTYPE_SHIELD") and (itemType ~= "INVTYPE_SHIELD") then
			forceShield = false
		end
		TP:GetSourceData(tpTable, TP_MELEE, forceShield)
		local changes = TPTips:BuildChanges({}, diffTable2)
		TP:AlterSourceData(tpTable, changes, forceShield)
		TP:GetTankPoints(tpTable, TP_MELEE, forceShield)
		if tpRight then
			tpRight = tpRight.."/"..rightFromDifference(tpTable.tankPoints[TP_MELEE], TP.resultsTable.tankPoints[TP_MELEE], profile.showTooltipDiff, profile.showTooltipTotal)
		end
		if drRight then
			drRight = drRight.."/"..rightFromDifference(tpTable.totalReduction[TP_MELEE]*100, TP.resultsTable.totalReduction[TP_MELEE]*100, profile.showTooltipDRDiff, profile.showTooltipDRTotal,"%+.2f %%","%.2f %%")
		end
		if ehRight then
			ehRight = ehRight.."/"..rightFromDifference(tpTable.effectiveHealth[TP_MELEE], TP.resultsTable.effectiveHealth[TP_MELEE], profile.showTooltipEHDiff, profile.showTooltipEHTotal)
		end
		if TankPoints.playerClass == "WARRIOR" and ehbRight then
			ehbRight = ehbRight.."/"..rightFromDifference(tpTable.effectiveHealthWithBlock[TP_MELEE], TP.resultsTable.effectiveHealthWithBlock[TP_MELEE], profile.showTooltipEHBDiff, profile.showTooltipEHBTotal)
		end
	end
	-----------------
	-- Append Text --
	-----------------
	local tpLeft, ehLeft, ehbLeft, drLeft
	if tpRight or ehRight or ehbRight or drRight then
		-- Build left
		local location = nil
		if itemType == "INVTYPE_FINGER" or itemType == "INVTYPE_TRINKET" then
			location = L[" (Top/Bottom):"]
		elseif itemType == "INVTYPE_WEAPON" then
			location = L[" (Main/Off):"]
		elseif itemType == "INVTYPE_2HWEAPON" then
			location = L[" (Main+Off):"]
		else
			location = ":"
		end
		
		local ignoreSuffix = "";
		if (suppressEnchants) then
			ignoreSuffix = "*"
		end;
		
		-- Add double line
		if tpRight then
			tpLeft = L["TankPoints"]..location
			tooltip:AddDoubleLine(tpLeft, tpRight..ignoreSuffix)
		end
		if drRight then
			drLeft = TP.SchoolName[TP_MELEE]..L[" DR"]..location
			tooltip:AddDoubleLine(drLeft, drRight..ignoreSuffix)
		end
		if ehRight then
			ehLeft = L["EH"]..location
			tooltip:AddDoubleLine(ehLeft, ehRight..ignoreSuffix)
		end
		if ehbRight then
			ehbLeft = L["EHB"]..location
			tooltip:AddDoubleLine(ehbLeft, ehbRight..ignoreSuffix)
		end
		tooltip:Show()
		
		--If we're looking at a temporary variation (suppressEnchants) then it can't go into the cache
		if (not suppressEnchants) then
			set_cache(link,tpLeft,tpRight,ehLeft,ehRight,ehbLeft,ehbRight,drLeft,drRight)
		end;
	end
	-- Cleanup
	StatLogic.StatTable.del(diffTable1)
	StatLogic.StatTable.del(diffTable2)
end

TipHooker:Hook(TPTips.ProcessTooltip, "item")