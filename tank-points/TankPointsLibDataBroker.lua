local addon = TankPoints

local L = LibStub("AceLocale-3.0"):GetLocale("TankPoints") --Get the localization for our addon
local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true);
local Toolkit = LibStub("Toolkit-1.0", 2);

local dataObject;

if (ldb == nil) then
	--if we couldn't load LibDataBroker then don't bother continuing
	return;
end;

dataObject = ldb:NewDataObject("TankPoints", {
		type = "data source",
		text = "This text is required but never used",
		value = "-",
		suffix = "TP", --abbreviation of TankPoints
		label = "TankPoints",
		icon = "Interface\\Icons\\INV_Shield_06",
		OnClick = function(clickedframe, button)
			--if (button == "right") then
				--InterfaceOptionsFrame_OpenToFrame(myconfigframe)
			--else
				addon:ToggleCalculator();
			--end
		end,
})

--[[
	Return the current TankPoints values
			tankPoints
			effectiveHealth
			totalReduction
			guaranteedReduction
--]]
local function GetTankPointsValues()
	--[[Return four numbers:
			TankPoints
			EffectiveHealth
			Total Reduction
			Guaranteed Reduction
			
		e.g.
			432148
			218226
			76.289323898619
			53.332898649843
	]]--
		
	local tankPoints, effectiveHealth, totalReduction, guaranteedReduction;
	
	tankPoints = 0;
	effectiveHealth = 0;
	totalReduction = 0;
	guaranteedReduction = 0;
	
	local TP = addon; --get ahold of the global TankPoints addon
	
	--write our own tonumber function; the built-in one doesn't behave as expected
	local function ToNumberEx(v)
		local result = tonumber(v);

		if (result == nil) then
			result = 0;
		end;
		
		return result;
	end

	if (TP) and (TP.resultsTable) then
		local results = TankPoints.resultsTable;

		if (results ~= nil) then
			if (results.tankPoints ~= nil) then
				tankPoints = ToNumberEx(results.tankPoints[TP_MELEE]);
				effectiveHealth = ToNumberEx(results.effectiveHealth[TP_MELEE]);
				totalReduction = ToNumberEx(results.totalReduction[TP_MELEE])*100;
				guaranteedReduction = ToNumberEx(results.guaranteedReduction[TP_MELEE])*100;
			end;
		end;
	end;
	
	return tankPoints, effectiveHealth, totalReduction, guaranteedReduction;
end;

function dataObject:OnTooltipShow()
	self:AddLine(HIGHLIGHT_FONT_COLOR_CODE..L["TankPoints"]..FONT_COLOR_CODE_CLOSE); --|cffffcc00|r

	local tankPoints, effectiveHealth, totalReduction, guaranteedReduction = GetTankPointsValues();

	self:AddDoubleLine("TankPoints"..":", HIGHLIGHT_FONT_COLOR_CODE..Toolkit:IntToStrLocale(tankPoints)..FONT_COLOR_CODE_CLOSE);
	self:AddDoubleLine("Effective Health:", HIGHLIGHT_FONT_COLOR_CODE..Toolkit:IntToStrLocale(effectiveHealth)..FONT_COLOR_CODE_CLOSE);
	self:AddDoubleLine("Total Reduction (%):", HIGHLIGHT_FONT_COLOR_CODE..format("%.2f%%", totalReduction)..FONT_COLOR_CODE_CLOSE);
	self:AddDoubleLine("Guaranteed Reduction (%):", HIGHLIGHT_FONT_COLOR_CODE..format("%.2f%%", guaranteedReduction)..FONT_COLOR_CODE_CLOSE);

	--sometimes adding only +1 to a stat has no effect due to rounding, and it takes a few for the value to jump
	--So we'll assume a jump by 10 and then normalize it back to per 1
	local factor = 10;
	local str, agi, sta, ar, dodge, parry, _, mastery = TankPointsCalculator:ComputeTankPointsDelta(nil, factor);

	str = str / factor;
	agi = agi / factor;
	sta = sta / factor;
	ar = ar / factor;
	dodge = dodge / factor;
	parry = parry / factor;
	mastery = mastery / factor;

	local minRel = math.min(str, agi, sta, ar, dodge, parry, mastery);
	local maxRel = math.max(str, agi, sta, ar, dodge, parry, mastery);

	assert(minRel);
	assert(maxRel);

	local function getStatText(hpFromStat)
		assert(hpFromStat);

		--TankPoints:Print(string.format("stat=%.2f, min=%.2f, max=%.2f", hpFromStat, minRel, maxRel));

		local s = Toolkit:RangeColorText(
			string.format("%.2f", hpFromStat),
			hpFromStat,
			minRel, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 
			maxRel, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);

			--s = GREEN_FONT_COLOR_CODE..string.format("%.2f", hpFromStat)..FONT_COLOR_CODE_CLOSE;
			--s = string.gsub(s, "|", "||")
		return s;
	end;

	self:AddLine(" ");
	self:AddDoubleLine(L["Relative Stat Values"], L["TankPoints"], 
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
		HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	self:AddDoubleLine("1.00 Strength"..":",       getStatText(str)); 
	self:AddDoubleLine("1.00 Agility"..":",        getStatText(agi)); 
	self:AddDoubleLine("1.00 Stamina"..":",        getStatText(sta)); 
	self:AddDoubleLine("1.00 Armor"..":",          getStatText(ar)); 
	self:AddDoubleLine("1.00 Dodge Rating"..":",   getStatText(dodge)); 
	self:AddDoubleLine("1.00 Parry Rating"..":",   getStatText(parry)); 
	--self:AddDoubleLine("1.00 Block Rating"..":",   getStatText(block)); block rating was removed in 4.0.1
	self:AddDoubleLine("1.00 Mastery Rating"..":", getStatText(mastery)); 

	self:AddLine(" ");
	self:AddLine(GREEN_FONT_COLOR_CODE.."Hint: Left-click to show the TankPoints calculator"..FONT_COLOR_CODE_CLOSE);
	--self:AddLine(GREEN_FONT_COLOR_CODE..L["Right-click to open the options menu"]..FONT_COLOR_CODE_CLOSE)
end;

function addon:UpdateLDBDataObjects()
	if (dataObject == nil) then
		return;
	end;

	local tankPoints, effectiveHealth, totalReduction, guaranteedReduction = GetTankPointsValues();
	if (tankPoints == 0) then
		dataObject.value = "n/a";
	else
		dataObject.value = Toolkit:IntToStrLocale(tankPoints or 0);
	end;


--	local currentStats = { tankPoints = 1234567.89012; }; --HealPointsCalculator:GetCurrentHealPoints();
--	if (currentStats) then
		--dataObject.value = Toolkit:IntToStrLocale(currentStats.tankPoints or 0);
	--end;
end;
	
function addon:RegisterLDBDataObjects()
	self:UpdateLDBDataObjects();
end;