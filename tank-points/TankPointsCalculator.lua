-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints Calculator
Description: Interactive Calculator for TankPoints
Revision: $Revision: 192 $
Author: Whitetooth
Email: hotdogee [at] gmail [dot] com
LastUpdate: $Date: 2012-09-20 20:08:08 +0800 (Thu, 20 Sep 2012) $
]]

---------------
-- Libraries --
---------------
local StatLogic = LibStub:GetLibrary("LibStatLogic-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("TankPoints") --Get the localization for our addon
local TankPoints = TankPoints

--------------------
-- Initialization --
--------------------
TPCalc = {}
TPCalc.sourceDT = {}
TPCalc.resultsDT = {}
local TPCalc = TPCalc


---------------------
-- Local Variables --
---------------------
-- Localize Lua globals
local _G = getfenv(0)
local pairs = pairs
local ipairs = ipairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local tinsert = tinsert
local tostring = tostring
local select = select


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

-------------------------------
-- TankPointsCalculatorFrame --
-------------------------------
--[[
	Runs when the frame is created.
	Arguments:
		self - Reference to the widget for which the script was run (frame)
--]]
function TankPointsCalculatorFrame_OnLoad(self)
	-- Esc closes the window
	tinsert(UISpecialFrames, self:GetName())
	
	-- Set title text
	TankPointsCalculatorFrame_HeaderText:SetText(L["TankPoints Calculator"])

	-- Set drag frame tooltip
	TankPointsCalculatorFrame_DragFrame.tooltip = L["Left click to drag\nRight click to reset position"]

	-- Set button text
	TankPointsCalculatorFrame_ResetButton:SetText(L["Reset"])
	TankPointsCalculatorFrame_CloseButton:SetText(L["Close"])
	
	-- Set option frame box title
	TPCResultsFrameTitle:SetText(L["Results"])
	TPCCombatTableFrameTitle:SetText(L["Combat Table"])
	TPCPlayerStatsFrameTitle:SetText(L["Player Stats"])
	TPCMobStatsFrameTitle:SetText(L["Mob Stats"])

--	TPCResults1.tooltip = "asdfasfsdf" --TankPoints is a measure of your theoretical\nmitigation (dodge, parry, etc) in proportion\nto your health."

	-- Set label text
	TPCalc.playerClass = select(2, UnitClass("player"))
	TPCalc:SetLabels()
	TPCalc:AdjustResultFrameSize()
	
	------------------
	-- Set tooltips --
	------------------
	--Results
	TPCResults3:SetScript("OnEnter", TPCResults3_OnEnter); --Total Reduction
	TPCResults3:SetScript("OnLeave", TPCResults3_OnLeave); --Total Reduction


	--Player Stats
	TPCPlayerStats1.tooltip =  L["Increases attack power and chance to parry an attack"] --Strength
	TPCPlayerStats5.tooltip =  L["Armor reduces physical damage taken"] --Armor (Items)
	TPCPlayerStats6.tooltip =  L["Armor reduces physical damage taken"] --Armor
	TPCPlayerStats7.tooltip =  L["TPCalc_PlayerStatsTooltip_MasteryRating"] --Mastery Rating
	TPCPlayerStats8.tooltip =  L["TPCalc_PlayerStatsTooltip_Mastery"] --Mastery
	TPCPlayerStats9.tooltip =  L["Dodge rating improves your chance to dodge. A dodged attack does no damage"] --Dodge rating
	TPCPlayerStats10.tooltip = L["Your chance to dodge an attack. A dodged attack does no damage"] --Dodge rating
	TPCPlayerStats11.tooltip = L["Parry rating improves your chance to parry. When you parry an attack, it and the next attack, will each hit for 50% less damage"] --Parry Rating
	TPCPlayerStats12.tooltip = L["Your chance to parry an attack. When you parry an attack, it and the next attack, will each hit for 50% less damage"] --Parry Rating
	TPCPlayerStats13.tooltip = L["Block rating improves your chance to block. Blocked attacks hit for 30% less damage"] --Block Rating
	TPCPlayerStats14.tooltip = L["Your chance to block an attack. Blocked attacks hit for 30% less damage."] --Block(%)
	TPCPlayerStats15.tooltip = L["(removed) Block value was removed from the game in patch 4.0.1. All blocked attacks hit for 30% less damage"] --Block value
	
	--Mob Stats
	TPCMobStats2.tooltip = L["Mob Damage before DR"]

	-- Register events
	self:RegisterEvent("UNIT_LEVEL")
	self:RegisterEvent("UNIT_RESISTANCES")
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("UNIT_MASTERY") --renamed from UNIT_DEFENSE; i have no idea if there even *is* a UNIT_MASTERY event
	self:RegisterEvent("UNIT_MAXHEALTH")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function TPCResults3_OnEnter(self) 
	local tooltip = "one\r\n"..
			"two\r\n"..
			"three\r\n"..
			"four\r\n"..
			"tell me that you love me...at all";
	tooltip = TPCalc.resultsDT.damageTakenCalculationDetails;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(tooltip, nil, nil, nil, nil, true);
	GameTooltip:Show();
end;

function TPCResults3_OnLeave(self) 
	GameTooltip_Hide();
end;

function TankPointsCalculatorFrame_OnEvent(self, event, ...)
--[[
	Description
		Run whenever an event fires for which the frame is registered. 
		In order for this script to be run, the frame must be registered for at least one event via its :RegisterEvent() method
	Arguments
		self	Reference to the widget for which the script was run (frame)
		event	Name of the event (string)
		...	Arguments specific to the event (list)
--]]

	--TankPoints:Print(tostring(self)..", "..event..", "..select(1, ...))
	-- Do nothing if Calculator frame is not visable
	if (not self:IsVisible()) then
		return
	end
	-- Do nothing if event target is not player
	if (not select(1, ...) == "player") then
		return
	end
	-- Update stuff
	TPCalc:UpdateResults()
end

function TankPointsCalculatorFrame_OnShow()
	TPCalc:UpdateResults()
end

-- VariableFrame
function TankPointsCalculatorVariables_IncrementButton_OnClick(self, button, down)
	--TankPoints:Print(tostring(self)..", "..tostring(button)..", "..tostring(self)..", "..tostring(down))
	local inputBox = _G[self:GetParent():GetName().."_InputEditBox"]
	inputBox:SetNumber(inputBox:GetNumber() + 1)
	inputBox:ClearFocus()
end

function TankPointsCalculatorVariables_DecrementButton_OnClick(self, button, down)
	local inputBox = _G[self:GetParent():GetName().."_InputEditBox"]
	inputBox:SetNumber(inputBox:GetNumber() - 1)
	inputBox:ClearFocus()
end

function TankPointsCalculatorVariables_InputEditBox_OnTextChanged(self, isUserInput)
--	TankPoints:Print(tostring(this)..", "..tostring(self))
--	local self = this   20101017: Removed, since self is now a paramater --Ian
	if (self:GetNumber() > 0) then
		self:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (self:GetNumber() < 0) then
		self:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		self:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	TPCalc:UpdateResults()
end

TPCalc.LabelText = {
	{-- TPCResults1 (also see TPCalc:SetLabels())
		L["TankPoints"],
		L["Effective Health"],
		L["Total Reduction"]..L["(%)"],
		L["Guaranteed Reduction"]..L["(%)"],
	},
	{-- TPCCombatTable1
		MISS..L["(%)"],
		DODGE..L["(%)"],
		PARRY..L["(%)"],
		BLOCK..L["(%)"],
		L["Crit"]..L["(%)"],
		L["Crushing"]..L["(%)"],
		L["Hit"]..L["(%)"],
	},
	{-- TPCPlayerStats1
		SPELL_STAT1_NAME, -- "Strength" (Hidden ability "Forceful Deflection" gives 0.25 parry per strength)
		SPELL_STAT2_NAME, -- "Agility"
		SPELL_STAT3_NAME, -- "Stamina"
		L["Max Health"],
		"["..ARMOR.." - "..L["Items"].."]",
		"["..ARMOR.."]",
		"["..ITEM_MOD_MASTERY_RATING_SHORT.."]", -- GlobalStrings.ITEM_MOD_MASTERY_RATING_SHORT "Mastery Rating"
		"["..STAT_MASTERY..L["(%)"].."]", --GlobalStrings.STAT_MASTERY "Mastery"
		"["..COMBAT_RATING_NAME3.."]", -- "Dodge Rating"
		"["..DODGE..L["(%)"].."]",
		"["..COMBAT_RATING_NAME4.."]", -- "Parry Rating"
		"["..PARRY..L["(%)"].."]",
		"["..COMBAT_RATING_NAME5.."]", -- "Block Rating"
		"["..BLOCK..L["(%)"].."]",
		L["Block Value"],
		COMBAT_RATING_NAME15, -- "Resilience"
	},
	{-- TPCMobStats1
		L["Mob Level"],
		L["Mob Damage"],
	},
}


--[[ 
	Set label text
	
	LabelText is a member variable that contains all the text to show in the calculator.
	This function copies all the strings into TankPointsCalculatorFrame
	
	20101213: Where are the labels set!?
--]]
function TPCalc:SetLabels()
	if self:ShouldShowEHB() then
		if self.LabelText[1][3] ~= L["Effective Health with Block"] then
			table.insert(self.LabelText[1], 3, L["Effective Health with Block"])
		end
	end
	for i, text in ipairs(self.LabelText[1]) do
		_G["TPCResults"..i.."_LabelText"]:SetText(text)
	end
	for i, text in ipairs(self.LabelText[2]) do
		_G["TPCCombatTable"..i.."_LabelText"]:SetText(text)
	end
	for i, text in ipairs(self.LabelText[3]) do
		_G["TPCPlayerStats"..i.."_LabelText"]:SetText(text)
	end
	for i, text in ipairs(self.LabelText[4]) do
		_G["TPCMobStats"..i.."_LabelText"]:SetText(text)
	end
end

function TPCalc:AdjustResultFrameSize()
	if self:ShouldShowEHB() then
		-- see TankPointsCalculator.xml for the origin of these constants!
		TPCResultsFrame:SetHeight(TPCResultsFrame:GetHeight() + 22)
		TankPointsCalculatorFrame:SetHeight(TankPointsCalculatorFrame:GetHeight() + 22)
		TPCResults5:Show()
	end
end

function TPCalc:ShouldShowEHB()
	if self.playerClass == "WARRIOR" then
		return true
	end
end

function TankPointsCalculatorFrame_ResetButton_OnClick(self, button, down)
	for i, _ in ipairs(TPCalc.LabelText[3]) do
		local inputBox = _G["TPCPlayerStats"..i.."_InputEditBox"]
		inputBox:SetText("0")
		inputBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	for i, _ in ipairs(TPCalc.LabelText[4]) do
		local inputBox = _G["TPCMobStats"..i.."_InputEditBox"]
		inputBox:SetText("0")
		inputBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
end

local round = function(n, decimal_places)
	decimal_places = decimal_places or 0
	local factor = 10^decimal_places;

	return floor(n*factor + 0.5) / factor;
end



--[[
	This function is the one responsible for filling in all the values on the calculator screen.
	- start with the sourceDT
	- copy it to a resultsDT
	- apply TankPoints calculations to resultsDT
--]]
function TPCalc:UpdateResults()
	--TankPoints:Debug("TPCalc:UpdateResults()")

	-- Update base data
	TankPoints:GetSourceData(self.sourceDT) --sourceDT holds our initial real stats

	--TankPoints:Debug("TPCalc:UpdateResults() - inital values: "..TankPoints:VarAsString(self.sourceDT))
	--TankPoints:Debug("1. sourceDT.mobMissChance = "..self.sourceDT.mobMissChance);
	
	copyTable(self.resultsDT, self.sourceDT) --perform TankPoints calculations on a resultsDT table (we want a copy because it applies modifiers to things like stamina and health)
	--TankPoints:Debug("2. resultsDT.mobMissChance = "..self.resultsDT.mobMissChance);

	TankPoints:GetTankPoints(self.resultsDT) --this will hold our "before" tankpoints and effective health, as opposed to newDT, which will hold the "after" tankpoints and effective health

	--And since this is a what-if calculation screen, we constuct another table (newDT) that we apply our sandbox calculations to
	local newDT = {}

	assert(self.sourceDT.parryChance, "sourceDT.parryChance is nil");
	copyTable(newDT, self.sourceDT)
	assert(newDT.parryChance, "newDT.parryChance is nil");
	--TankPoints:Debug("3. newDT.mobMissChance = "..newDT.mobMissChance);
	
	--TankPoints:Debug(table.tostring(newDT))

	--TankPoints:Debug("4. sourceDT.mobMissChance = "..self.sourceDT.mobMissChance);
	--TankPoints:Debug("5. resultsDT.mobMissChance = "..self.resultsDT.mobMissChance);
	--TankPoints:Debug("6. newDT.mobMissChance = "..newDT.mobMissChance);
	

	--------------------
	-- Get input data --
	--------------------
	-- input data is writen in the changes table
	local prefix
	local changes = {}
	local inputEditBox = "_InputEditBox"
	local currentText = "_CurrentText"
	local resultText = "_ResultText"
	local differenceText = "_DifferenceText"
	local originalStatText = "_OriginalStatText"
	local newStatText = "_NewStatText"
	
	local current, new, diff
	
	--[[
		Pull any numbers the user may have entered out of the edit boxes, and put them in the "changes" table
	--]]
	prefix = "TPCPlayerStats"
	local i = 1
	-- Strength
	changes.str = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Agility
	changes.agi = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Stamina
	changes.sta = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Max Health
	changes.playerHealth = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Armor (Items)
	changes.armorFromItems = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Armor
	changes.armor = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1

	-- Mastery Rating
	changes.masteryRating = _G[prefix..i..inputEditBox]:GetNumber();
	i = i + 1
	-- Mastery
	changes.mastery = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	
	-- Dodge Rating
	changes.dodgeChance = 0
	diff = _G[prefix..i..inputEditBox]:GetNumber()
	if diff then
		--changes.dodgeChance = StatLogic:GetAvoidanceGainAfterDR("DODGE", StatLogic:GetEffectFromRating(diff, CR_DODGE, newDT.playerLevel)) * 0.01
		changes.dodgeRating = diff;
	end
	i = i + 1
	-- Dodge
	changes.dodgeChance = 0;
	diff = _G[prefix..i..inputEditBox]:GetNumber();
	if diff then
		changes.dodgeChance = changes.dodgeChance + diff*0.01;
	end;
	i = i + 1


	-- Parry Rating
	changes.parryRating = 0;
	diff = _G[prefix..i..inputEditBox]:GetNumber()
	if diff then
		--changes.parryChance = StatLogic:GetAvoidanceGainAfterDR("PARRY", StatLogic:GetEffectFromRating(diff, CR_PARRY, newDT.playerLevel)) * 0.01
		changes.parryRating = diff;
	end
	i = i + 1
	-- Parry
	changes.parryChance = 0;
	diff = _G[prefix..i..inputEditBox]:GetNumber();
	if diff then
		changes.parryChance = changes.parryChance + diff*0.01;
	end;
	i = i + 1


	-- Block Rating
	changes.blockChance = 0
	diff = _G[prefix..i..inputEditBox]:GetNumber()
	if diff then
		changes.blockChance = StatLogic:GetEffectFromRating(diff, CR_BLOCK, newDT.playerLevel) * 0.01
	end
	i = i + 1
	-- Block
	changes.blockChance = changes.blockChance + _G[prefix..i..inputEditBox]:GetNumber() * 0.01
	i = i + 1
	-- Block Value
	changes.blockValue = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Resilience
	--Removed 20120804  5.0.1  Resilience does nothing for tanks
	--changes.resilience = _G[prefix..i..inputEditBox]:GetNumber()
	
	prefix = "TPCMobStats"
	i = 1

	-- mobLevel
	changes.mobLevel = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1

	-- mobDamage
	changes.mobDamage = _G[prefix..i..inputEditBox]:GetNumber()
	
	----------------
	-- AlterTable --
	----------------
	--Takes a table of stats (newDT) and applies the "changes" we've asked for.

	TankPoints:AlterSourceData(newDT, changes)
	
	------------------------------
	-- Calculate new TankPoints --
	------------------------------
	TankPoints:GetTankPoints(newDT, TP_MELEE)

	--assert(newDT.tankPoints, "newDT.tankPoints is not assigned after calling GetTankPoints(newDT)");


--	TankPoints:Debug("Done calling GetTankPoints")
--	TankPoints:Debug("newDT.dodgeChance after getting tankpoints = "..newDT.dodgeChance)

	
	------------------
	-- Display data --
	------------------
	--TPCPlayerStats1_OriginalStatText
	--TPCPlayerStats1_NewStatText
	--TPCResults1_CurrentText
	--TPCResults1_DifferenceText
	--TPCResults1_ResultText
	
	
	-------------------
	-- Results Frame --
	-------------------
	prefix = "TPCResults"
	local function paint_result_line(nformat)
		_G[prefix..i..currentText]:SetText(format(nformat, current))
		_G[prefix..i..resultText]:SetText(format(nformat, new))
		_G[prefix..i..differenceText]:SetText(format(nformat, (new - current)))
		if (new > current) then
			_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
			_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		elseif (new < current) then
			_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		else
			_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	end

	-- TankPoints
	i = 1;
	current = floor(self.resultsDT.tankPoints[TP_MELEE]);
	new = floor(newDT.tankPoints[TP_MELEE]);
	paint_result_line("%.0f");

	-- Effective Health
	i = i + 1;
	current = round(self.resultsDT.effectiveHealth[TP_MELEE]);
	new = round(newDT.effectiveHealth[TP_MELEE]);
	paint_result_line("%.0f");

	-- Effective Health with Block
	if self:ShouldShowEHB() then
		i = i + 1
		current = floor(self.resultsDT.effectiveHealthWithBlock[TP_MELEE])
		new = floor(newDT.effectiveHealthWithBlock[TP_MELEE])
		paint_result_line("%.0f")
	end
	
	-- Damage Reduction
	i = i + 1
	current = round(self.resultsDT.totalReduction[TP_MELEE]*100, 2);
	new = round(newDT.totalReduction[TP_MELEE]*100, 2);
	paint_result_line("%.02f")

	-- Guaranteed Reduction
	i = i + 1
	current = round(self.resultsDT.guaranteedReduction[TP_MELEE]*100, 2)
	new = round(newDT.guaranteedReduction[TP_MELEE]*100, 2)
	paint_result_line("%.02f")

	------------------------
	-- Combat Table Frame --
	------------------------
	prefix = "TPCCombatTable"
	-- mobMissChance
	i = 1
	current = round(self.resultsDT.mobMissChance*100, 2);
	new = round(newDT.mobMissChance*100, 2);
	_G[prefix..i..currentText]:SetText(format("%.02f", current))
	_G[prefix..i..resultText]:SetText(format("%.02f", new))
	_G[prefix..i..differenceText]:SetText(format("%.02f", (new - current)))
	if (new > current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- dodgeChance
	i = i + 1
	current = round(self.resultsDT.dodgeChance*100, 2);
	new = round(newDT.dodgeChance*100, 2);
	_G[prefix..i..currentText]:SetText(format("%.02f", current))
	_G[prefix..i..resultText]:SetText(format("%.02f", new))
	_G[prefix..i..differenceText]:SetText(format("%.02f", (new - current)))
	if (new > current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- parryChance
	i = i + 1
	current = round(self.resultsDT.parryChance*100, 2);
	new = round(newDT.parryChance*100, 2);
	_G[prefix..i..currentText]:SetText(format("%.02f", current))
	_G[prefix..i..resultText]:SetText(format("%.02f", new))
	_G[prefix..i..differenceText]:SetText(format("%.02f", (new - current)))
	if (new > current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- blockChance
	i = i + 1
	current = round(self.resultsDT.blockChance*100, 2);
	new = round(newDT.blockChance*100, 2);
	_G[prefix..i..currentText]:SetText(format("%.02f", current))
	_G[prefix..i..resultText]:SetText(format("%.02f", new))
	_G[prefix..i..differenceText]:SetText(format("%.02f", (new - current)))
	if (new > current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobCritChance
	i = i + 1
	current = round(self.resultsDT.mobCritChance*100, 2);
	new = round(newDT.mobCritChance*100, 2);
	_G[prefix..i..currentText]:SetText(format("%.02f", current))
	_G[prefix..i..resultText]:SetText(format("%.02f", new))
	_G[prefix..i..differenceText]:SetText(format("%.02f", (new - current)))
	if (new < current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new > current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobCrushChance
	i = i + 1
	current = round(self.resultsDT.mobCrushChance*100, 2);
	new = round(newDT.mobCrushChance*100, 2);
	_G[prefix..i..currentText]:SetText(format("%.02f", current))
	_G[prefix..i..resultText]:SetText(format("%.02f", new))
	_G[prefix..i..differenceText]:SetText(format("%.02f", (new - current)))
	if (new < current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new > current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobHitChance
	i = i + 1
	current = max(0, (1 - self.resultsDT.mobCrushChance - self.resultsDT.mobCritChance - self.resultsDT.blockChance - self.resultsDT.parryChance - self.resultsDT.dodgeChance - self.resultsDT.mobMissChance));
	new = max(0, (1 - newDT.mobCrushChance - newDT.mobCritChance - newDT.blockChance - newDT.parryChance - newDT.dodgeChance - newDT.mobMissChance));
	_G[prefix..i..currentText]:SetText(format("%.02f", current))
	_G[prefix..i..resultText]:SetText(format("%.02f", new))
	_G[prefix..i..differenceText]:SetText(format("%.02f", (new - current)))
	if (new < current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new > current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end

	------------------------
	-- Player Stats Frame --
	------------------------
	prefix = "TPCPlayerStats"
	-- Strength
	i = 1
	_, current = UnitStat("player", 1)
	new = floor(current + changes.str)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Agility
	i = i + 1
	_, current = UnitStat("player", 2)
	new = floor(current + changes.agi)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Stamina
	i = i + 1
	_, current = UnitStat("player", 3)
	new = floor(current + changes.sta)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Max Health
	i = i + 1
	current = floor(self.resultsDT.playerHealth)
	new = floor(newDT.playerHealth)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Armor (Items)
	i = i + 1
	current = self.resultsDT.armor
	new = floor(newDT.armor)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Armor
	i = i + 1
	current = self.resultsDT.armor
	new = floor(newDT.armor)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	--[[
		Mastery 14.20 (8.00+6.20)
		Mastery Rating 645 (+6.20 mastery)
		
		GetCombatRating(CR_MASTERY) = 645
		GetCombatRatingBonus(CR_MASTERY) = 6.2027794493839
		GetMastery() = 14.202779769897
	--]]
	-- Mastery Rating
	i = i + 1
	current = GetCombatRating(CR_MASTERY)
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Mastery
	i = i + 1
	current = floor(self.resultsDT.mastery * 100) / 100 --round to two decimal places, and show as a percentage
	new = floor(newDT.mastery * 100) / 100
	_G[prefix..i..originalStatText]:SetText(format("%.2f", current))
	_G[prefix..i..newStatText]:SetText(format("%.2f", new))
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Dodge Rating
	i = i + 1
	current = GetCombatRating(CR_DODGE)
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Dodge
	--TankPoints:Debug("newDT.dodgeChance = "..newDT.dodgeChance)
	i = i + 1
	current = floor(self.resultsDT.dodgeChance * 100 * 100) / 100
	new = floor(newDT.dodgeChance * 100 * 100) / 100
	_G[prefix..i..originalStatText]:SetText(format("%.2f", current))
	_G[prefix..i..newStatText]:SetText(format("%.2f", new))
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Parry Rating
	i = i + 1
	current = GetCombatRating(CR_PARRY)
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Parry
	i = i + 1
	current = floor(self.resultsDT.parryChance * 100 * 100) / 100
	new = floor(newDT.parryChance * 100 * 100) / 100
	_G[prefix..i..originalStatText]:SetText(format("%.2f", current))
	_G[prefix..i..newStatText]:SetText(format("%.2f", new))
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Block Rating
	i = i + 1
	current = GetCombatRating(CR_BLOCK)
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Block
	i = i + 1
	current = floor(self.resultsDT.blockChance * 100 * 100) / 100
	new = floor(newDT.blockChance * 100 * 100) / 100
	_G[prefix..i..originalStatText]:SetText(format("%.2f", current))
	_G[prefix..i..newStatText]:SetText(format("%.2f", new))
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Block Value
	i = i + 1
	current = 0 --self.resultsDT.blockValue
	new = 0; --floor(newDT.blockValue)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Resilience
	--[[
	Removed 20120804  5.0.1  Resilience does nothing for tanks
	i = i + 1
	current = self.resultsDT.resilience
	new = floor(newDT.resilience)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	--]]
	
	---------------------
	-- Mob Stats Frame --
	---------------------
	prefix = "TPCMobStats"
	-- mobLevel
	i = 1
	current = self.resultsDT.mobLevel
	new = floor(newDT.mobLevel)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobDamage
	i = i + 1
	current = 0; --floor(TankPoints:GetMobDamage(self.resultsDT.mobLevel))
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	--------------
	-- Clean up --
	--------------
end
