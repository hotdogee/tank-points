local TankPoints = TankPoints
local L = LibStub("AceLocale-3.0"):GetLocale("TankPoints")
local StatLogic = LibStub("LibStatLogic-1.2")

--locals
local _G = _G
local floor = math.floor
local format = string.format

local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local GRAY_FONT_COLOR = GRAY_FONT_COLOR
local GRAY_FONT_COLOR_CODE = GRAY_FONT_COLOR_CODE
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local GREEN_FONT_COLOR_CODE = GREEN_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local GameTooltip = GameTooltip


-- util
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

local function stableSort(sortme, cmp)
	local swap = nil
	for i = 1, #sortme, 1 do
		for j = #sortme, i+1, -1 do
			if cmp(sortme[j], sortme[j-1]) then
				swap = sortme[j]
				sortme[j] = sortme[j-1]
				sortme[j-1] = swap
			end
		end
	end
end


--------------------------
-- TankPoints StatGroup

--updaters
local function TP_SetTankPoints(statFrame, unit)
-- Line 1:  TankPoints 
	TankPoints:GetTankPointsIfNotFilled(TankPoints.resultsTable, nil)
	-- Line1: TankPoints
	local tankpoints = commaValue(floor(TankPoints.resultsTable.tankPoints[TP_MELEE]))
	PaperDollFrame_SetLabelAndText(statFrame, L["TankPoints"], tankpoints)
	
	statFrame:SetScript("OnEnter", TankPoints.TankPointsFrame_OnEnter)
	statFrame:SetScript("OnMouseUp", TankPoints.TankPointsFrame_OnMouseUp)
	
	statFrame:Show()
end

local function TP_SetMeleeReduction(statFrame, unit)
-- Line 2: Melee DR

	TankPoints:GetTankPointsIfNotFilled(TankPoints.resultsTable, nil)
	-- Line2: MeleeDR
	local meleeReduction = TankPoints.resultsTable.totalReduction[TP_MELEE] * 100
	PaperDollFrame_SetLabelAndText(statFrame, TankPoints.SchoolName[TP_MELEE]..L[" DR"], meleeReduction, true)
	
	statFrame:SetScript("OnEnter", TankPoints.MeleeReductionFrame_OnEnter)
	
	statFrame:Show()
end

local function TP_SetSpellTankPoints(statFrame, unit)
	-- Line4: SpellTankPoints

	TankPoints:GetTankPointsIfNotFilled(TankPoints.resultsTable, nil)
	if TankPoints.setSchool then
		TankPoints.currentSchool = TankPoints.setSchool
	else
		-- Find highest SpellTankPoints school
		TankPoints.currentSchool = TP_FIRE
		if not TankPoints.resultsTable.tankPoints[TP_FIRE] then
			TankPoints:UpdateDataTable()
		end
		for _, s in ipairs(TankPoints.ResistableElementalSchools) do
			if not TankPoints.resultsTable.tankPoints[s] then
				TankPoints:UpdateDataTable()
			end
			if TankPoints.resultsTable.tankPoints[s] > TankPoints.resultsTable.tankPoints[TankPoints.currentSchool] then
				TankPoints.currentSchool = s
			end
		end
	end
	local spellTankPoints = commaValue(floor(TankPoints.resultsTable.tankPoints[TankPoints.currentSchool]))
	PaperDollFrame_SetLabelAndText(statFrame, TankPoints.SchoolName[TankPoints.currentSchool]..L[" TP"], spellTankPoints)
	
	statFrame:SetScript("OnEnter", TankPoints.SpellTankPointsFrame_OnEnter)
	statFrame:SetScript("OnMouseUp", TankPoints.SpellTankPointsFrame_OnMouseUp)
	
	statFrame:Show()
end

local function TP_SetSpellReduction(statFrame, unit)
	-- Line5: SpellReduction

	TankPoints:GetTankPointsIfNotFilled(TankPoints.resultsTable, nil)
	if TankPoints.setSchool then
		TankPoints.currentSchool = TankPoints.setSchool
	else
		-- Find highest SpellTankPoints school
		TankPoints.currentSchool = TP_FIRE
		if not TankPoints.resultsTable.tankPoints[TP_FIRE] then
			TankPoints:UpdateDataTable()
		end
		for _, s in ipairs(TankPoints.ResistableElementalSchools) do
			if not TankPoints.resultsTable.tankPoints[s] then
				TankPoints:UpdateDataTable()
			end
			if TankPoints.resultsTable.tankPoints[s] > TankPoints.resultsTable.tankPoints[TankPoints.currentSchool] then
				TankPoints.currentSchool = s
			end
		end
	end

	local spellReduction = TankPoints.resultsTable.totalReduction[TankPoints.currentSchool] * 100        
	PaperDollFrame_SetLabelAndText(statFrame, TankPoints.SchoolName[TankPoints.currentSchool]..L[" DR"], spellReduction, true)
	
	statFrame:SetScript("OnEnter", TankPoints.SpellTankPointsFrame_OnEnter)
	statFrame:SetScript("OnMouseUp", TankPoints.SpellReductionFrame_OnMouseUp)
	
	statFrame:Show()
end

local function TP_SetCalculator(statFrame, unit)
	 -- Line6: TankPointsCalculator
	local label = TankPointsCalculatorFrame:IsVisible() and L["Close Calculator"] or L["Open Calculator"]
	_G[statFrame:GetName().."Label"]:SetFormattedText("%s%s%s", HIGHLIGHT_FONT_COLOR_CODE, label, FONT_COLOR_CODE_CLOSE)
	_G[statFrame:GetName().."StatText"]:SetText("")
	
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..label..FONT_COLOR_CODE_CLOSE
	statFrame:SetScript("OnMouseUp", TankPoints.TankPointsCalculatorStat_OnMouseUp)
	statFrame:SetScript("OnEnter", TankPoints.TankPointsCalculatorStat_OnEnter)
	statFrame:SetScript("OnLeave", TankPoints.TankPointsCalculatorStat_OnLeave)
	
	statFrame:Show()
end

--StatGroup definition
local function AddTPStatFrame()
	local id = #PAPERDOLL_STATCATEGORY_DEFAULTORDER + 1; --highest entry+1

	local frame = CreateFrame("Frame", "CharacterStatsPaneCategory"..id, CharacterStatsPaneScrollChild, "StatGroupTemplate")

--	STAT_CATEGORY_TANKPOINTS = L["TankPoints"]
	PAPERDOLL_STATCATEGORIES["TANKPOINTS"] = {
		["id"] = id,
		stats = {
			"TP_TANKPOINTS",
			"TP_MELEEDR",
			--"TP_SPELLTP",
			--"TP_SPELLDR",
			"TP_CALC",
		}
	}
	PAPERDOLL_STATCATEGORY_DEFAULTORDER[id] = "TANKPOINTS"
	PAPERDOLL_STATINFO["TP_TANKPOINTS"] = { updateFunc = function(statFrame, unit) TP_SetTankPoints(statFrame, unit) end }
	PAPERDOLL_STATINFO["TP_MELEEDR"]    = { updateFunc = function(statFrame, unit) TP_SetMeleeReduction(statFrame, unit) end }
	--PAPERDOLL_STATINFO["TP_SPELLTP"]    = { updateFunc = function(statFrame, unit) TP_SetSpellTankPoints(statFrame, unit) end }
	--PAPERDOLL_STATINFO["TP_SPELLDR"]    = { updateFunc = function(statFrame, unit) TP_SetSpellReduction(statFrame, unit) end }
	PAPERDOLL_STATINFO["TP_CALC"]       = { updateFunc = function(statFrame, unit) TP_SetCalculator(statFrame, unit) end }
end

--------------------------------------
-- TankPoints PaperdollStats Events --
--------------------------------------

function TankPoints.TankPointsCalculatorStat_OnMouseUp(frame, button)
	if(TankPointsCalculatorFrame:IsVisible()) then
		TankPointsCalculatorFrame:Hide()
		_G[frame:GetName().."Label"]:SetText(L["Open Calculator"])
	else
		TankPointsCalculatorFrame:Show()
		_G[frame:GetName().."Label"]:SetText(L["Close Calculator"])
	end
end

function TankPoints.TankPointsCalculatorStat_OnEnter(frame)
	local label = TankPointsCalculatorFrame:IsVisible() and L["Close Calculator"] or L["Open Calculator"]
	_G[frame:GetName().."Label"]:SetFormattedText("%s%s%s", GREEN_FONT_COLOR_CODE, label, FONT_COLOR_CODE_CLOSE)
end

function TankPoints.TankPointsCalculatorStat_OnLeave(frame)
	local label = TankPointsCalculatorFrame:IsVisible() and L["Close Calculator"] or L["Open Calculator"]
	_G[frame:GetName().."Label"]:SetFormattedText("%s%s%s", HIGHLIGHT_FONT_COLOR_CODE, label, FONT_COLOR_CODE_CLOSE)
end

function TankPoints.SpellTankPointsFrame_OnMouseUp(frame, button)
	TankPoints.SpellFrame_OnMouseUp(frame, button)
	local spellTankPoints = commaValue(floor(TankPoints.resultsTable.tankPoints[TankPoints.currentSchool]))
	PaperDollFrame_SetLabelAndText(frame, TankPoints.SchoolName[TankPoints.currentSchool]..L[" TP"], spellTankPoints)
end

function TankPoints.SpellReductionFrame_OnMouseUp(frame, button)
	TankPoints.SpellFrame_OnMouseUp(frame, button)
	local spellReduction = TankPoints.resultsTable.totalReduction[TankPoints.currentSchool] * 100        
	PaperDollFrame_SetLabelAndText(frame, TankPoints.SchoolName[TankPoints.currentSchool]..L[" DR"], spellReduction, true)
end

-- Cycle through schools OnClick left, Reset to strongest school OnClick right
-- Holy(2) -> Fire(3) -> Nature(4) -> Frost(5) -> Shadow(6) -> Arcane(7)
function TankPoints.SpellFrame_OnMouseUp(frame, button)
	-- Set School
	if button == "LeftButton" then
		if not TankPoints.setSchool then
			TankPoints.setSchool = TankPoints.currentSchool + 1
		else
			TankPoints.setSchool = TankPoints.setSchool + 1
		end
		if TankPoints.setSchool > 7 then
			TankPoints.setSchool = 2
		end
		TankPoints.currentSchool = TankPoints.setSchool
		frame:GetScript("OnEnter")(frame)
		TankPoints:UpdateTankPoints("spell frame left mouse up");
	-- Reset school
	elseif button == "RightButton" then
		TankPoints.setSchool = nil
		-- Find highest SpellTankPoints school
		TankPoints.currentSchool = TP_FIRE
		for _,s in ipairs(TankPoints.ResistableElementalSchools) do
			if TankPoints.resultsTable.tankPoints[s] > TankPoints.resultsTable.tankPoints[TankPoints.currentSchool] then
				TankPoints.currentSchool = s
			end
		end
		frame:GetScript("OnEnter")(frame)
		TankPoints:UpdateTankPoints("spell frame right mouse up");
	end
end

function TankPoints.TankPointsFrame_OnMouseUp(frame, button)
	TankPoints:SetShowPerStat(not TankPoints:ShowPerStat())
	TankPoints:UpdateTankPoints("TankPointsFrame_OnMouseUp")
end

----------------------------------------
-- TankPoints PaperdollStats Tooltips --
----------------------------------------
--[[
-- Reference --
Font Color Codes:
NORMAL_FONT_COLOR_CODE = "|cffffd200" -- Yellow
HIGHLIGHT_FONT_COLOR_CODE = "|cffffffff" -- White
FONT_COLOR_CODE_CLOSE = "|r"

Font Colors:
NORMAL_FONT_COLOR = {r = 1, g = 0.82, b = 0} -- Yellow
HIGHLIGHT_FONT_COLOR = {r = 1, g = 1, b = 1} -- White

-- TankPoints Tooltip --
in what stance
Mob Stats
Mob Level: 60, Mob Damage: 2000
Mob Crit: 5%, Mob Miss: 5%
1 change in each stat = how many TankPoints
-- Reduction Tooltip --
Armor Damage Reduction
MobLevel, PlayerLevel
Combat Table
-- Block Value --
Mob Damage(Raw)
Mob Damage(DR)
Blocked Percentage
Equivalent Block Mitigation(Block% * BlockMod)
-- Spell TP --
Damage Taken Percentage
25%Melee 75%Spell
50%Melee 50%Spell
75%Melee 25%Spell
-- Spell Reduction --
Improved Defense Stance
Reduction for all schools
--]]
-- TankPoints Stat Tooltip
------------------------------------------------------------------------------------------
--[[
-- Static
mobLevel, mobDamage
mobCritChance, mobMissChance

-- Dynamic
-- stat name, increase by statValue, increase by 1
-- strength, 1, 1 -- no strength cause it only increases block value by 0.05
agility, 1, 1
stamina, 1, 1
armor, 10, 1
resilience, 1, 1
defenseRating, 1, 1
dodgeRating, 1, 1
parryRating, 1, 1
blockRating, 1, 1
blockValue, 2/0.65, 1
--
TankPoints.MeleePerStatTable = {
	-- stat name, increase by statValue
	-- {SPELL_STAT1_NAME, 1}, -- strength
	{SPELL_STAT2_NAME, 1}, -- agility
	{SPELL_STAT3_NAME, 1}, -- stamina
	{ARMOR, 10}, -- armor
	{COMBAT_RATING_NAME15, 1}, -- resilience
	{COMBAT_RATING_NAME2, 10}, -- defenseRating
	{COMBAT_RATING_NAME3, 1}, -- dodgeRating
	{COMBAT_RATING_NAME4, 1}, -- parryRating
	{COMBAT_RATING_NAME5, 1}, -- blockRating
	{L["Block Value"], 2/0.65}, -- blockValue
}
--]]
function TankPoints.TankPointsFrame_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	TankPoints:UpdateDataTable()
	--self:Debug(motion)
	--local time = GetTime() -- Performance Analysis
	-----------------------
	-- Initialize Tables --
	-----------------------
	local sourceDT = TankPoints.sourceTable; --the player's current stats
	local resultsDT = TankPoints.resultsTable; --the player's current TankPoints
	local changesDT = {}; --the changes we wish to apply
	local newDT = {}; --the players updated TankPoints after the changes are applied
	
	------------------------
	-- Initialize Tooltip --
	------------------------
	local textL, textR
	-------------
	-- Title Line
	textL = format("%s %d", L["TankPoints"], resultsDT.tankPoints[TP_MELEE])
	GameTooltip:SetText(textL, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	---------
	-- Stance
	local currentStance = GetShapeshiftForm()
	if currentStance ~= 0 then
		local _, stanceName = GetShapeshiftFormInfo(currentStance)
		if stanceName then
			textL = L["In "]..stanceName
			textR = format("%d%%", resultsDT.damageTakenMod[TP_MELEE] * 100)
			GameTooltip:AddDoubleLine(textL, textR, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	end
	------------
	-- Mob Stats
	textL = L["Mob Stats"]
	GameTooltip:AddLine(textL, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	-- Mob Level: 60, Mob Damage: 2000
	textL = L["Mob Level"]..": "..resultsDT.mobLevel..", "..L["Mob Damage"]..": "..commaValue(floor(resultsDT.mobDamage or 0))
	GameTooltip:AddLine(textL, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	-- Mob Crit: 5%, Mob Miss: 5%
	textL = L["Mob Crit"]..": "..format("%.2f", resultsDT.mobCritChance * 100).."%, "..L["Mob Miss"]..": "..format("%.2f", resultsDT.mobMissChance * 100).."%"
	GameTooltip:AddLine(textL, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	--[[
	TankPoints Per StatValue
	1 Agility =
	1 Stamina =
	10 Armor =
	1 Resilience =
	1 Defense Rating =
	1 Dodge Rating =
	1 Parry Rating =
	1 Block Rating =
	2/0.65 Block Value =
	TankPoints.MeleePerStatTable = {
		-- stat name, increase by statValue
		-- {SPELL_STAT1_NAME, 1}, -- strength
		{SPELL_STAT2_NAME, 1}, -- agility
		{SPELL_STAT3_NAME, 1}, -- stamina
		{ARMOR, 10}, -- armor
		{COMBAT_RATING_NAME15, 1}, -- resilience
		{COMBAT_RATING_NAME2, 1}, -- defenseRating
		{COMBAT_RATING_NAME3, 1}, -- dodgeRating
		{COMBAT_RATING_NAME4, 1}, -- parryRating
		{COMBAT_RATING_NAME5, 1}, -- blockRating
		{L["Block Value"], 2/0.65}, -- blockValue
	}
	TankPoints:GetSourceData([TP_Table], [school])
	TankPoints:GetTankPoints([TP_Table], [school])
	--]]
	------------------------------
	-- TankPoints Per StatValue --
	------------------------------
	local per_stat = TankPoints.tpPerStat
	if per_stat then
		textL = L["Per Stat"]
	else
		textL = L["Per StatValue"]
	end
	textR = L["TankPoints"]
	GameTooltip:AddDoubleLine(textL, textR, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)


	--20101017: Patch 4.0.1 strength no longer affects blocked amount. Blocked attacks are reduced by 30%
--		Note: There *might* be talents that affect this number (i.e. the % amount blocked)
--	20110103: Can't remove strength entirely, it still increases the chance to Parry (although the tooltip doesn't say so?)
	--------------
	-- Strength --
	--------------
	-- 1 Str = StatLogic:GetStatMod("ADD_PARRY_RATING_MOD_STR") Parry%
	copyTable(newDT, sourceDT) -- load default data
	textL = "1 "..SPELL_STAT1_NAME.." = "
	newDT.parryChance = newDT.parryChance + StatLogic:GetAvoidanceGainAfterDR("PARRY", StatLogic:GetEffectFromRating(StatLogic:GetStatMod("ADD_PARRY_RATING_MOD_STR"), CR_PARRY, newDT.playerLevel)) * 0.01
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	textR = format("%.1f", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE])..L[" TP"]
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-------------
	-- Agility --
	-------------
	-- 1 Agi = 2 Armor         20110818 i don't see this happening anymore --Ian
	-- 1 Agi = StatLogic:GetDodgePerAgi() Dodge%
	copyTable(newDT, sourceDT) -- load default data
	textL = "1 "..SPELL_STAT2_NAME.." = "
	--newDT.armor = newDT.armor + 2
	newDT.dodgeChance = newDT.dodgeChance + StatLogic:GetAvoidanceGainAfterDR("DODGE", StatLogic:GetStatMod("MOD_AGI") * StatLogic:GetDodgePerAgi()) * 0.01
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	textR = format("%.1f%s", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE], L[" TP"])
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	-------------
	-- Stamina --
	-------------
	-- 1 Sta = 10 * StatLogic:GetStatMod("MOD_HEALTH") HP
	copyTable(newDT, sourceDT) -- load default data
	if per_stat then
		textL = "1 "..SPELL_STAT3_NAME.." = "
		newDT.playerHealth = newDT.playerHealth + 10 * StatLogic:GetStatMod("MOD_HEALTH")
	else
		textL = "1 "..SPELL_STAT3_NAME.." = "
		newDT.playerHealth = newDT.playerHealth + 1 * 10 * StatLogic:GetStatMod("MOD_HEALTH")
	end
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	textR = format("%.1f%s", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE], L[" TP"])
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	-----------
	-- Armor --
	-----------
	copyTable(newDT, sourceDT) -- load default data
	local armorMod = StatLogic:GetStatMod("MOD_ARMOR")
	if per_stat then
		textL = "1 "..ARMOR.." = "
		newDT.armor = newDT.armor + 1 * armorMod
	else
		textL = "1 "..ARMOR.." = "
		newDT.armor = newDT.armor + 1 * armorMod
	end
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	textR = format("%.1f%s", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE], L[" TP"])
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	------------------
	-- Dodge Rating --
	------------------
	copyTable(newDT, sourceDT) -- load default data
	if per_stat then
		textL = "1% "..DODGE.." = "
		newDT.dodgeChance = newDT.dodgeChance + 0.01
	else
		textL = "1 "..COMBAT_RATING_NAME3.." = "
		newDT.dodgeChance = newDT.dodgeChance + StatLogic:GetAvoidanceGainAfterDR("DODGE", StatLogic:GetEffectFromRating(1, CR_DODGE, newDT.playerLevel)) * 0.01
	end
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	textR = format("%.1f%s", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE], L[" TP"])
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	------------------
	-- Parry Rating --
	------------------
	copyTable(newDT, sourceDT) -- load default data
	if per_stat then
		textL = "1% "..PARRY.." = "
		newDT.parryChance = newDT.parryChance + 0.01
	else
		textL = "1 "..COMBAT_RATING_NAME4.." = "
		newDT.parryChance = newDT.parryChance + StatLogic:GetAvoidanceGainAfterDR("PARRY", StatLogic:GetEffectFromRating(1, CR_PARRY, newDT.playerLevel)) * 0.01
	end
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	textR = format("%.1f%s", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE], L[" TP"])
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	
	------------------
	-- Block Rating -- was removed in patch 4.0.1
	------------------
	--copyTable(newDT, sourceDT) -- load default data
	--if per_stat then
--		textL = "1% "..BLOCK.." = "
		--newDT.blockChance = newDT.blockChance + 0.01
	--else
--		textL = "1 "..COMBAT_RATING_NAME5.." = "
		--newDT.blockChance = newDT.blockChance + StatLogic:GetEffectFromRating(1, CR_BLOCK, newDT.playerLevel) * 0.01
	--end
	--TankPoints:GetTankPoints(newDT, TP_MELEE)
	--textR = format("%.1f %s", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE], L[" TP"])
	--GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

--[[
	Patch 4.0.0 Changed block to be a flat 30% reduction (40% with some talents)
			So there is no such thing as block value.
	-----------------
	-- Block Value --
	-----------------
	copyTable(newDT, sourceDT) -- load default data
	if per_stat then
		textL = "1 "..L["Block Value"].." = "
		newDT.blockValue = (newDT.blockValue or 0) + StatLogic:GetStatMod("MOD_BLOCK_VALUE")
	else
		textL = format("%.2f %s = ", 2/0.65, L["Block Value"])
		newDT.blockValue = (newDT.blockValue or 0) + 2/0.65 * StatLogic:GetStatMod("MOD_BLOCK_VALUE")
	end
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	textR = format("%.1f%s", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE], L[" TP"])
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
--]]

	--------------------
	-- Mastery Rating --
	--------------------
	copyTable(newDT, sourceDT) -- load default data
	changesDT = {} --clear out the changes table
	if per_stat then
		textL = "1% "..STAT_MASTERY.." = " --FrameXML\GlobalStrings.lua\STAT_MASTERY = "Mastery";
		changesDT.mastery = 1
	else
		textL = "1 "..ITEM_MOD_MASTERY_RATING_SHORT.." = " --FrameXML\GlobalStrings.lua\ITEM_MOD_MASTERY_RATING_SHORT = "Mastery Rating";
		changesDT.masteryRating = 1
	end
	TankPoints:AlterSourceData(newDT, changesDT)
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	textR = format("%.1f%s", newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE], L[" TP"])
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	------------------------------------
	if per_stat then
		textL = L["Click: show Per StatValue TankPoints"]
	else
		textL = L["Click: show Per Stat TankPoints"]
	end
	GameTooltip:AddLine(textL, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)

	for _,line in ipairs(L["TP_EXPLANATION"]) do
		GameTooltip:AddLine(line, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
	
	GameTooltip:Show()

	-- Performance Analysis
	-- Before copyTable: 0.25 sec
	-- After copyTable: 0.03 sec
	--self:Debug(format("%.4f", GetTime() - time))
end

------------------------------------------------------------------------------------------
--[[
Melee Damage Reduction
Armor Damage Reduction
MobLevel, PlayerLevel
Combat Table
--]]
function TankPoints.MeleeReductionFrame_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	TankPoints:UpdateDataTable() --will update member variables sourceTable and resultsTable
	local resultsDT = TankPoints.resultsTable
	local textL, textR
	-------------
	-- Title Line
	textL = TankPoints.SchoolName[TP_MELEE]..L[" Damage Reduction"].." "..format("%.2f%%", resultsDT.totalReduction[TP_MELEE] * 100)
	GameTooltip:SetText(textL, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

	-------------------------
	-- Armor Damage Reduction
	textL = ARMOR..L[" Damage Reduction"]..":"
	textR = format("%.2f%%", resultsDT.armorReduction * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- Mob Level: 60, Player Level: 60
	textL = L["Mob Level"]..": "..resultsDT.mobLevel..", "..L["Player Level"]..": "..format("%d", resultsDT.playerLevel)
	GameTooltip:AddLine(textL, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	---------------
	-- Combat Table
	textL = L["Combat Table"]
	GameTooltip:AddLine(textL, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

	-- Miss --
	textL = MISS..":"
	textR = format("%.2f%%", resultsDT.mobMissChance * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- Dodge --
	textL = DODGE..":"
	textR = format("%.2f%%", resultsDT.dodgeChance * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- Parry --
	textL = PARRY..":"
	textR = format("%.2f%%", resultsDT.parryChance * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- Block --
	textL = BLOCK..":"
	textR = format("%.2f%%", resultsDT.blockChance * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- Spacer -- everything below here is the mob hitting you
	GameTooltip:AddLine("---", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- Crit --
	textL = L["Crit"]..":"
	textR = format("%.2f%%", resultsDT.mobCritChance * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- Crushing --
	textL = L["Crushing"]..":"
	textR = format("%.2f%%", resultsDT.mobCrushChance * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- Hit --
	textL = L["Hit"]..":"
	textR = format("%.2f%%", resultsDT.mobHitChance * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	---------------
	-- Avoidance Diminishing Returns
	textL = L["Avoidance Diminishing Returns"]
	GameTooltip:AddLine(textL, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

	-- +16 Strength --
	if TankPoints.playerClass == "DEATHKNIGHT" or TankPoints.playerClass == "WARRIOR" then
		textL = "+16 "..SPELL_STAT1_NAME..":"
		textR = format("%.2f%%", StatLogic:GetAvoidanceGainAfterDR("PARRY", StatLogic:GetEffectFromRating(16 * StatLogic:GetStatMod("ADD_PARRY_RATING_MOD_STR"), CR_PARRY, TankPoints.playerLevel)))
		GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end
	
	-- +16 Agility --
	textL = "+16 "..SPELL_STAT2_NAME..":"
	textR = format("%.2f%%", StatLogic:GetAvoidanceGainAfterDR("DODGE", 16 * StatLogic:GetStatMod("MOD_AGI") * StatLogic:GetDodgePerAgi()))
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	
	-- +16 Dodge Rating --
	textL = "+16 "..COMBAT_RATING_NAME3..":"
	textR = format("%.2f%%", StatLogic:GetAvoidanceGainAfterDR("DODGE", StatLogic:GetEffectFromRating(16, CR_DODGE, TankPoints.playerLevel)))
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	
	-- +16 Parry Rating --
	if GetParryChance() ~= 0 then
		textL = "+16 "..COMBAT_RATING_NAME4..":"
		textR = format("%.2f%%", StatLogic:GetAvoidanceGainAfterDR("PARRY", StatLogic:GetEffectFromRating(16, CR_PARRY, TankPoints.playerLevel)))
		GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end
	
	GameTooltip:AddLine(L["Only includes Dodge, Parry, and Missed"], GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	
	GameTooltip:Show()
end

------------------------------------------------------------------------------------------
--[[
Mob Damage(Raw):
Mob Damage(DR):
Blocked Percentage:
Equivalent Block Mitigation:
--]]
function TankPoints.BlockValueFrame_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	TankPoints:UpdateDataTable()
	local resultsDT = TankPoints.resultsTable
	local textL, textR
	-------------
	-- Title Line
	textL = format("%s %d", L["Block Value"], resultsDT.blockValue or 0)
	GameTooltip:SetText(textL, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

	-----------------------
	-- Mob Damage before DR
	--textL = L["Mob Damage before DR"]..":"
	--textR = format("%d", TankPoints:GetMobDamage(resultsDT.mobLevel))
	--GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	----------------------
	-- Mob Damage after DR
	textL = L["Mob Damage after DR"]..":"
	textR = format("%d", resultsDT.mobDamage or 0)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	---------------------
	-- Blocked Percentage
	textL = L["Blocked Percentage"]..":"
	textR = format("%.2f%%", resultsDT.blockedMod * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	---------------
	-- Block Chance
	textL = BLOCK_CHANCE..":"
	textR = format("%.2f%%", resultsDT.blockChance * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	------------------------------
	-- Equivalent Block Mitigation
	textL = L["Equivalent Block Mitigation"]..":"
	textR = format("%.2f%%", resultsDT.blockChance * resultsDT.blockedMod * 100)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	-----------------------
	-- Shield Block Up Time
	if TankPoints.playerClass == "WARRIOR" then
		textL = L["Shield Block Up Time"]..":"
		textR = format("%.2f%%", (resultsDT.shieldBlockUpTime or 0) * 100)
		GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end

	GameTooltip:Show()
end

------------------------------------------------------------------------------------------
--[[
TankPoints Considering Melee/Spell Damage Ratio
25% Melee Damage + 75% Spell Damage:
50% Melee Damage + 50% Spell Damage:
75% Melee Damage + 25% Spell Damage:
--]]
function TankPoints.SpellTankPointsFrame_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	TankPoints:UpdateDataTable()
	--TankPoints:Debug("SpellTankPointsFrame_OnEnter")
	local resultsDT = TankPoints.resultsTable
	local textL, textR
	-------------------
	-- Spell TankPoints
	textL = TankPoints.SchoolName[TankPoints.currentSchool].." "..L["TankPoints"].." "..format("%d", resultsDT.tankPoints[TankPoints.currentSchool])
	GameTooltip:SetText(textL, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	---------
	-- Stance
	local currentStance = GetShapeshiftForm()
	if currentStance ~= 0 then
		local _, stanceName = GetShapeshiftFormInfo(currentStance)
		if stanceName then
			textL = L["In "]..stanceName
			textR = format("%d%%", resultsDT.damageTakenMod[TankPoints.currentSchool] * 100)
			GameTooltip:AddDoubleLine(textL, textR, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	end
	--------------------------------------------------
	-- TankPoints Considering Melee/Spell Damage Ratio
	textL = L["Melee/Spell Damage Ratio"]
	textR = L["TankPoints"]
	GameTooltip:AddDoubleLine(textL, textR, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	--------------------------------------
	-- 25% Melee Damage + 75% Spell Damage
	textL = "25% "..TankPoints.SchoolName[TP_MELEE].." + 75% "..TankPoints.SchoolName[TankPoints.currentSchool]..":"
	textR = format("%d", resultsDT.tankPoints[TP_MELEE] * 0.25 + resultsDT.tankPoints[TankPoints.currentSchool] * 0.75)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	--------------------------------------
	-- 50% Melee Damage + 50% Spell Damage
	textL = "50% "..TankPoints.SchoolName[TP_MELEE].." + 50% "..TankPoints.SchoolName[TankPoints.currentSchool]..":"
	textR = format("%d", resultsDT.tankPoints[TP_MELEE] * 0.50 + resultsDT.tankPoints[TankPoints.currentSchool] * 0.50)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	--------------------------------------
	-- 75% Melee Damage + 25% Spell Damage
	textL = "75% "..TankPoints.SchoolName[TP_MELEE].." + 25% "..TankPoints.SchoolName[TankPoints.currentSchool]..":"
	textR = format("%d", resultsDT.tankPoints[TP_MELEE] * 0.75 + resultsDT.tankPoints[TankPoints.currentSchool] * 0.25)
	GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	---------------------------------
	-- Left click: Show next school
	textL = L["Left click: Show next school"]
	GameTooltip:AddLine(textL, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	---------------------------------
	-- Right click: Show strongest school
	textL = L["Right click: Show strongest school"]
	GameTooltip:AddLine(textL, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	-----------------
	-- Current School
	textL = ""
	local color
	if TP_HOLY == TankPoints.currentSchool then
		color = HIGHLIGHT_FONT_COLOR_CODE
	else
		color = GRAY_FONT_COLOR_CODE
	end
	textL = textL..color..TankPoints.SchoolName[TP_HOLY]..FONT_COLOR_CODE_CLOSE
	for s = TP_FIRE, TP_ARCANE do
		if s == TankPoints.currentSchool then
			color = HIGHLIGHT_FONT_COLOR_CODE
		else
			color = GRAY_FONT_COLOR_CODE
		end
		textL = textL.."->"..color..TankPoints.SchoolName[s]..FONT_COLOR_CODE_CLOSE
	end
	--textL = textL..FONT_COLOR_CODE_CLOSE
	GameTooltip:AddLine(textL)
	
	GameTooltip:Show()
end

------------------------------------------------------------------------------------------
--[[
Improved Defense Stance
Reduction for all schools
--]]
function TankPoints.SpellReductionFrame_OnEnter(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	TankPoints:UpdateDataTable()
	local resultsDT = TankPoints.resultsTable
	local textL, textR
	-------------
	-- Title Line
	textL = TankPoints.SchoolName[TankPoints.currentSchool]..L[" Damage Reduction"].." "..format("%.2f%%", resultsDT.totalReduction[TankPoints.currentSchool] * 100)
	GameTooltip:SetText(textL, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	----------------------------
	-- Reduction for all schools
	for _,s in ipairs(TankPoints.ElementalSchools) do
		textL = _G["DAMAGE_SCHOOL"..s]
		textR = format("%.2f%%", resultsDT.totalReduction[s] * 100)
		GameTooltip:AddDoubleLine(textL, textR, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..s);
	end
	
	---------------------------------
	-- Left click: Show next school
	textL = L["Left click: Show next school"]
	GameTooltip:AddLine(textL, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	---------------------------------
	-- Right click: Show strongest school
	textL = L["Right click: Show strongest school"]
	GameTooltip:AddLine(textL, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	-----------------
	-- Current School
	textL = ""
	local color
	if TP_HOLY == TankPoints.currentSchool then
		color = HIGHLIGHT_FONT_COLOR_CODE
	else
		color = GRAY_FONT_COLOR_CODE
	end
	textL = textL..color..TankPoints.SchoolName[TP_HOLY]..FONT_COLOR_CODE_CLOSE
	for s = TP_FIRE, TP_ARCANE do
		if s == TankPoints.currentSchool then
			color = HIGHLIGHT_FONT_COLOR_CODE
		else
			color = GRAY_FONT_COLOR_CODE
		end
		textL = textL.."->"..color..TankPoints.SchoolName[s]..FONT_COLOR_CODE_CLOSE
	end
	--textL = textL..FONT_COLOR_CODE_CLOSE
	GameTooltip:AddLine(textL)
	
	GameTooltip:Show()
end


------------------------------------------------------
-- Effective Health StatGroup

--updaters
local function EH_SetEffectiveHealth(statFrame, unit)
	TankPoints:GetTankPointsIfNotFilled(TankPoints.resultsTable, nil)
	local value = commaValue(floor(TankPoints.resultsTable.effectiveHealth[TP_MELEE]))
	PaperDollFrame_SetLabelAndText(statFrame, L["EH"], value)
	
	statFrame:SetScript("OnEnter", TankPoints.EffectiveHealth_EffectiveHealthTooltip)
	
	statFrame:Show()
end

local function EH_SetEffectiveHealthWithBlock(statFrame, unit)
	TankPoints:GetTankPointsIfNotFilled(TankPoints.resultsTable, nil)
	local value = commaValue(floor(TankPoints.resultsTable.effectiveHealth[TP_MELEE]))
	if TankPoints.playerClass == "WARRIOR" or TankPoints.playerClass == "PALADIN" then
		value = commaValue(floor(TankPoints.resultsTable.effectiveHealthWithBlock[TP_MELEE]))
	end
	PaperDollFrame_SetLabelAndText(statFrame,  L["EH Block"], value)
	
	statFrame:SetScript("OnEnter", TankPoints.EffectiveHealth_EffectiveHealthWithBlockTooltip)
	
	statFrame:Show()
end

local function EH_SetSpellEffectiveHealth(statFrame, unit)
	TankPoints:GetTankPointsIfNotFilled(TankPoints.resultsTable, nil)
	for _, s in ipairs(TankPoints.ResistableElementalSchools) do
		if not TankPoints.resultsTable.effectiveHealth[s] then
			TankPoints:UpdateDataTable()
		end
	end
	if TankPoints.setEHSchool then
		TankPoints.currentEHSchool = TankPoints.setEHSchool
	else
		-- Find highest SpellTankPoints school
		TankPoints.currentEHSchool = TP_FIRE
		for _, s in ipairs(TankPoints.ResistableElementalSchools) do
			if TankPoints.resultsTable.effectiveHealth[s] > TankPoints.resultsTable.effectiveHealth[TankPoints.currentEHSchool] then
				TankPoints.currentEHSchool = s
			end
		end
	end
	if TankPoints.currentEHSchool == TP_FIRE then
		TankPoints.penultimateEHSchool = TP_ARCANE
	else
		TankPoints.penultimateEHSchool = TP_FIRE
	end
	for _,s in ipairs(TankPoints.ResistableElementalSchools) do
		if TankPoints.resultsTable.effectiveHealth[TankPoints.currentEHSchool] > TankPoints.resultsTable.effectiveHealth[s] and
			TankPoints.resultsTable.effectiveHealth[s] > TankPoints.resultsTable.effectiveHealth[TankPoints.penultimateEHSchool] then
			TankPoints.penultimateEHSchool = s
		end
	end
	
	local value = commaValue(floor(TankPoints.resultsTable.effectiveHealth[TankPoints.currentEHSchool]))
	PaperDollFrame_SetLabelAndText(statFrame, TankPoints.SchoolName[TankPoints.currentEHSchool]..L[" EH"], value)
	
	statFrame:SetScript("OnEnter", TankPoints.EffectiveHealth_SpellEffectiveHealthTooltip)
	
	statFrame:Show()
end

local function EH_SetSpellEffectiveHealthAllSchools(statFrame, unit)
	TankPoints:GetTankPointsIfNotFilled(TankPoints.resultsTable, nil)
	for _, s in ipairs(TankPoints.ResistableElementalSchools) do
		if not TankPoints.resultsTable.effectiveHealth[s] then
			TankPoints:UpdateDataTable()
		end
	end
	if TankPoints.setEHSchool then
		TankPoints.currentEHSchool = TankPoints.setEHSchool
	else
		-- Find highest SpellTankPoints school
		TankPoints.currentEHSchool = TP_FIRE
		for _, s in ipairs(TankPoints.ResistableElementalSchools) do
			if TankPoints.resultsTable.effectiveHealth[s] > TankPoints.resultsTable.effectiveHealth[TankPoints.currentEHSchool] then
				TankPoints.currentEHSchool = s
			end
		end
	end
	if TankPoints.currentEHSchool == TP_FIRE then
		TankPoints.penultimateEHSchool = TP_ARCANE
	else
		TankPoints.penultimateEHSchool = TP_FIRE
	end
	for _,s in ipairs(TankPoints.ResistableElementalSchools) do
		if TankPoints.resultsTable.effectiveHealth[TankPoints.currentEHSchool] > TankPoints.resultsTable.effectiveHealth[s] and
			TankPoints.resultsTable.effectiveHealth[s] > TankPoints.resultsTable.effectiveHealth[TankPoints.penultimateEHSchool] then
			TankPoints.penultimateEHSchool = s
		end
	end
	
	local value = commaValue(floor(TankPoints.resultsTable.effectiveHealth[TankPoints.penultimateEHSchool]))
	PaperDollFrame_SetLabelAndText(statFrame, TankPoints.SchoolName[TankPoints.penultimateEHSchool]..L[" EH"], value)
	
	statFrame:SetScript("OnEnter", TankPoints.EffectiveHealth_AllSchoolsEffectiveHealthTooltip)
	
	statFrame:Show()
end

--StatGroup definition
local function AddEHStatFrame()
	local id = #PAPERDOLL_STATCATEGORY_DEFAULTORDER + 1
	local frame = CreateFrame("Frame", "CharacterStatsPaneCategory"..id, CharacterStatsPaneScrollChild, "StatGroupTemplate")

	STAT_CATEGORY_EFFECTIVEHEALTH = L["Effective Health"]
	PAPERDOLL_STATCATEGORIES["EFFECTIVEHEALTH"] = {
		["id"] = id,
		stats = {
			"EH_EFFECTIVEHEALTH",
			"EH_EHBLOCK",
			--"EH_SPELLEH",
			--"EH_SPELLEHALL",
		}
	}
	PAPERDOLL_STATCATEGORY_DEFAULTORDER[id] = "EFFECTIVEHEALTH"
	PAPERDOLL_STATINFO["EH_EFFECTIVEHEALTH"] = { updateFunc = function(statFrame, unit) EH_SetEffectiveHealth(statFrame, unit) end }
	PAPERDOLL_STATINFO["EH_EHBLOCK"] = { updateFunc = function(statFrame, unit) EH_SetEffectiveHealthWithBlock(statFrame, unit) end }
	--PAPERDOLL_STATINFO["EH_SPELLEH"] = { updateFunc = function(statFrame, unit) EH_SetSpellEffectiveHealth(statFrame, unit) end }
	--PAPERDOLL_STATINFO["EH_SPELLEHALL"] = { updateFunc = function(statFrame, unit) EH_SetSpellEffectiveHealthAllSchools(statFrame, unit) end }
end

--tooltips
local function addline(GameTooltip, a, b)
	GameTooltip:AddDoubleLine(a, b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end

function TankPoints.EffectiveHealth_EffectiveHealthTooltip(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	TankPoints:UpdateDataTable()
	local newDT = {}
	local sourceDT = TankPoints.sourceTable
	local resultDT = TankPoints.resultsTable

	-------------
	-- Title Line
	GameTooltip:SetText(format(L["Effective Health vs %s %s"], TankPoints.SchoolName[TP_MELEE], commaValue(floor(resultDT.effectiveHealth[TP_MELEE]))),
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	---------
	-- Stance
	local currentStance = GetShapeshiftForm()
	if currentStance ~= 0 then
		local _, stanceName = GetShapeshiftFormInfo(currentStance)
		if stanceName then
			textL = L["In "]..stanceName
			textR = format("%d%%", resultDT.damageTakenMod[TP_MELEE] * 100)
			GameTooltip:AddDoubleLine(textL, textR, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	end
	------------
	-- Mob Stats
	textL = L["Mob Level"]..": "..resultDT.mobLevel
	GameTooltip:AddLine(textL, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	-----------
	-- Your Stats
	GameTooltip:AddLine(L["Your Reductions"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	addline(GameTooltip, L["Health"], commaValue(resultDT.playerHealth))
	addline(GameTooltip, L["Armor Reduction"], format("%.2f%%", 100 * resultDT.armorReduction))
	addline(GameTooltip, L["Talent/Buff/Stance Reductions"], format("%.2f%%", 100 * (1 - StatLogic:GetStatMod("MOD_DMG_TAKEN","MELEE"))))
	addline(GameTooltip, L["Guaranteed Reduction"], format("%.2f%%", 100 * resultDT.guaranteedReduction[TP_MELEE]))
	if resultDT.mobCritChance > 0 then
		GameTooltip:AddLine(L["Mob attacks can critically hit"], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		GameTooltip:AddLine(L["Mob attacks cannot critically hit"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end

	-- What Ifs
	GameTooltip:AddDoubleLine(L["Per StatValue"],L["Effective Health"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	-------------
	-- Agility --
	-------------
	copyTable(newDT, sourceDT)
	newDT.armor = newDT.armor + 2
	--newDT.dodgeChance = newDT.dodgeChance + StatLogic:GetStatMod("MOD_AGI") * StatLogic:GetDodgePerAgi() * 0.01
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	addline(GameTooltip, "1 "..SPELL_STAT2_NAME.." = ", format("%.1f%s", newDT.effectiveHealth[TP_MELEE] - resultDT.effectiveHealth[TP_MELEE], L[" EH"]))
	-------------
	-- Stamina --
	-------------
	copyTable(newDT, sourceDT)
	newDT.playerHealth = newDT.playerHealth + floor(1.0 * 10 * StatLogic:GetStatMod("MOD_HEALTH")) --20101213: found exampe where wow is doing ceil on statmod
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	addline(GameTooltip, "1 "..SPELL_STAT3_NAME.." = ", format("%.1f%s", newDT.effectiveHealth[TP_MELEE] - resultDT.effectiveHealth[TP_MELEE], L[" EH"]))
	-----------
	-- Armor --
	-----------
	copyTable(newDT, sourceDT)
	newDT.armor = newDT.armor + 1 * StatLogic:GetStatMod("MOD_ARMOR")
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	addline(GameTooltip, "1 "..ARMOR.." = ", format("%.1f%s", newDT.effectiveHealth[TP_MELEE] - resultDT.effectiveHealth[TP_MELEE], L[" EH"]))

	for _,line in ipairs(L["EH_EXPLANATION"]) do
		GameTooltip:AddLine(line, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
	
	GameTooltip:Show()
end

function TankPoints.EffectiveHealth_EffectiveHealthWithBlockTooltip(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	-- show creature attack speed, damage, block value, etc
	-- note typical situation EHB comes into play (no stun, etc)
	-- note crushability, critability
	TankPoints:UpdateDataTable()
	local newDT = {}
	local sourceDT = TankPoints.sourceTable
	local resultDT = TankPoints.resultsTable
	
	-------------
	-- Title Line
	GameTooltip:SetText(L["Effective Health (with Block) vs Melee "]..commaValue(floor(resultDT.effectiveHealthWithBlock[TP_MELEE])), 
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	---------
	-- Stance
	local currentStance = GetShapeshiftForm()
	if currentStance ~= 0 then
		local _, stanceName = GetShapeshiftFormInfo(currentStance)
		if stanceName then
			textL = L["In "]..stanceName
			textR = format("%d%%", resultDT.damageTakenMod[TP_MELEE] * 100)
			GameTooltip:AddDoubleLine(textL, textR, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	end
	------------
	-- Mob Stats
	textL = L["Mob Level"]..": "..resultDT.mobLevel..", "..L["Mob Damage after DR"]..": "..commaValue(floor(resultDT.mobDamage or 0))
	GameTooltip:AddLine(textL, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-----------
	-- Your Stats
	GameTooltip:AddLine(L["Your Reductions"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	addline(GameTooltip, L["Health"],commaValue(resultDT.playerHealth))
	addline(GameTooltip, L["Block Value"], 0) --resultDT.blockValue)
	addline(GameTooltip, L["Armor Reduction"], format("%.2f%%", 100 * resultDT.armorReduction))
	addline(GameTooltip, L["Talent/Buff/Stance Reductions"], format("%.2f%%", 100 * (1 - StatLogic:GetStatMod("MOD_DMG_TAKEN","MELEE"))))
	addline(GameTooltip, L["Guaranteed Reduction"], format("%.2f%%", 100 * resultDT.guaranteedReduction[TP_MELEE]))
	if resultDT.mobCritChance > 0 then
		GameTooltip:AddLine(L["Mob attacks can critically hit"], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		GameTooltip:AddLine(L["Mob attacks cannot critically hit"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end

	-- What Ifs
	GameTooltip:AddDoubleLine(L["Per StatValue"], L["Effective Health with Block"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	-------------
	-- Agility --
	-------------
	copyTable(newDT, sourceDT)
	newDT.armor = newDT.armor + 2
	--newDT.dodgeChance = newDT.dodgeChance + StatLogic:GetStatMod("MOD_AGI") * StatLogic:GetDodgePerAgi() * 0.01
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	addline(GameTooltip, "1 "..SPELL_STAT2_NAME.." = ", format("%.1f%s", newDT.effectiveHealthWithBlock[TP_MELEE] - resultDT.effectiveHealthWithBlock[TP_MELEE], L[" EH"]))
	-------------
	-- Stamina --
	-------------
	copyTable(newDT, sourceDT)
	newDT.playerHealth = newDT.playerHealth + 1.0 * 10 * StatLogic:GetStatMod("MOD_HEALTH")
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	addline(GameTooltip, "1 "..SPELL_STAT3_NAME.." = ", format("%.1f%s", newDT.effectiveHealthWithBlock[TP_MELEE] - resultDT.effectiveHealthWithBlock[TP_MELEE], L[" EH"]))
	-----------
	-- Armor --
	-----------
	copyTable(newDT, sourceDT)
	newDT.armor = newDT.armor + 1 * StatLogic:GetStatMod("MOD_ARMOR")
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	addline(GameTooltip, "1 "..ARMOR.." = ", format("%.1f%s", newDT.effectiveHealthWithBlock[TP_MELEE] - resultDT.effectiveHealthWithBlock[TP_MELEE], L[" EH"]))
	-----------------
	-- Block Value --
	-----------------
	copyTable(newDT, sourceDT) -- load default data
	newDT.blockValue = 0; --newDT.blockValue + 2/0.65 * StatLogic:GetStatMod("MOD_BLOCK_VALUE")
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	addline(GameTooltip, format("%.2f", 2/0.65).." "..L["Block Value"].." = ", format("%.1f%s", newDT.effectiveHealthWithBlock[TP_MELEE] - resultDT.effectiveHealthWithBlock[TP_MELEE], L[" EH"]))
	--[[
	if TankPoints.playerClass == "WARRIOR" and not hasImprovedShieldBlock() then
		-----------------------
		-- Imp. Shield Block --
		-----------------------
		copyTable(newDT, sourceDT) -- load default data
		newDT.forceImprovedShieldBlock_True = true
		TankPoints:GetTankPoints(newDT, TP_MELEE)
		addline(L["imp. Shield Block"], format("%.1f", newDT.effectiveHealthWithBlock[TP_MELEE] - resultDT.effectiveHealthWithBlock[TP_MELEE]).." EH")
	end
	--]]
	for _,line in ipairs(L["EHB_EXPLANATION"]) do
		GameTooltip:AddLine(line, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
	if not (TankPoints.db.profile.showTooltipEHBTotal or TankPoints.db.profile.showTooltipEHBDiff) then
		GameTooltip:AddLine(L["See /tp optionswin to turn on tooltip."], GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
	
	GameTooltip:Show()
end

function TankPoints.EffectiveHealth_SpellEffectiveHealthTooltip(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	TankPoints:UpdateDataTable()
	local newDT = {}
	local sourceDT = TankPoints.sourceTable
	local resultDT = TankPoints.resultsTable
	
	local s = TankPoints.currentEHSchool
	-------------
	-- Title Line
	GameTooltip:SetText(format(L["Effective Health vs %s %s"], TankPoints.SchoolName[s], commaValue(floor(resultDT.effectiveHealth[s])), 
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	---------
	-- Stance
	local currentStance = GetShapeshiftForm()
	if currentStance ~= 0 then
		local _, stanceName = GetShapeshiftFormInfo(currentStance)
		if stanceName then
			textL = L["In "]..stanceName
			textR = format("%d%%", resultDT.damageTakenMod[s] * 100)
			GameTooltip:AddDoubleLine(textL, textR, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	end
	
	addline(GameTooltip, L["Health"], commaValue(resultDT.playerHealth))
	addline(GameTooltip, L["Resistance Reduction"], format("%.2f%%", 100 * resultDT.schoolReduction[s]))
	addline(GameTooltip, L["Talent/Buff/Stance Reductions"], format("%.2f%%", 100 * (1 - resultDT.damageTakenMod[s])))
	addline(GameTooltip, L["Guaranteed Reduction"], format("%.2f%%", 100 * resultDT.guaranteedReduction[s]))

	GameTooltip:AddDoubleLine(L["Per StatValue"],L["Effective Health"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	------------
	-- Resist --
	------------
	copyTable(newDT, sourceDT)
	newDT.resistance[s] = newDT.resistance[s] + 3
	TankPoints:GetTankPoints(newDT, s)
	addline(GameTooltip, "3 "..TankPoints.SchoolName[s]..L[" resist "].." = ", format("%.1f%s", newDT.effectiveHealth[s] - resultDT.effectiveHealth[s], L[" EH"]))
	-------------
	-- Stamina --
	-------------
	copyTable(newDT, sourceDT)
	newDT.playerHealth = newDT.playerHealth + 1 * 10 * StatLogic:GetStatMod("MOD_HEALTH")
	TankPoints:GetTankPoints(newDT, s)
	addline(GameTooltip, "1 "..SPELL_STAT3_NAME.." = ", format("%.1f%s", newDT.effectiveHealth[s] - resultDT.effectiveHealth[s], L[" EH"]))
	
	GameTooltip:Show()
end

function TankPoints.EffectiveHealth_AllSchoolsEffectiveHealthTooltip(statFrame)
	if (MOVING_STAT_CATEGORY) then return end
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
	
	TankPoints:UpdateDataTable()
	local resultDT = TankPoints.resultsTable
	GameTooltip:SetText(L["Effective Health - All Schools"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	
	local schools = {}
	copyTable(schools, TankPoints.ResistableElementalSchools)
	stableSort(schools, function(a,b)
		return resultDT.effectiveHealth[a] > resultDT.effectiveHealth[b]
	end)
	for _,s in ipairs(schools) do
		GameTooltip:AddDoubleLine(_G["DAMAGE_SCHOOL"..s], commaValue(floor(resultDT.effectiveHealth[s])))
		GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..s)
	end
	
	GameTooltip:Show()
end


------------------------------------------------------
-- Aaaaaaaaaannnnnnnnddd add them

function TankPoints:AddStatFrames()
	AddTPStatFrame();
	AddEHStatFrame();
end
