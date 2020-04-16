TankPointsCalculator = {};

local TankPoints = TankPoints;


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


--[[
	Calculate the TankPoints gained per point of attributes
		strength
		agility
		stamina
		armor
		dodge
		parry
		block
		mastery
	returns
		strengthValue
		agilityValue
		staminaValue
		armorValue
		dodgeValue
		parryValue
		blockValue
		masteryValue
--]]
function TankPointsCalculator:ComputeTankPointsDelta(currentStats, delta)
	--TankPoints:UpdateDataTable()
	
	--self:Debug(motion)
	--local time = GetTime() -- Performance Analysis
	
	local strengthValue = 0;
	local agilityValue = 0;
	local staminaValue = 0;
	local armorValue = 0;
	local dodgeValue = 0;
	local parryValue = 0;
	--local blockValue = -999;
	local masteryValue = 0;
	if delta == nil then
		delta = 10;
	end;

	-----------------------
	-- Initialize Tables --
	-----------------------
	local sourceDT = TankPoints.sourceTable; --the player's current stats
	local resultsDT = TankPoints.resultsTable; --the player's current TankPoints
	local changesDT = {}; --the changes we wish to apply
	local newDT = {}; --the players updated TankPoints after the changes are applied
	

	--------------
	-- Strength --
	--------------
	-- 1 Str = StatLogic:GetStatMod("ADD_PARRY_RATING_MOD_STR") Parry%
	copyTable(newDT, sourceDT) -- load default data
	--newDT.parryChance = newDT.parryChance + StatLogic:GetAvoidanceGainAfterDR("PARRY", StatLogic:GetEffectFromRating(StatLogic:GetStatMod("ADD_PARRY_RATING_MOD_STR"), CR_PARRY, newDT.playerLevel)) * 0.01
	TankPoints:AlterSourceData(newDT, {str=delta});
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	strengthValue = (newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE])

	-------------
	-- Agility --
	-------------
	copyTable(newDT, sourceDT) -- load default data
	--newDT.dodgeChance = newDT.dodgeChance + StatLogic:GetAvoidanceGainAfterDR("DODGE", StatLogic:GetStatMod("MOD_AGI") * StatLogic:GetDodgePerAgi()) * 0.01
	TankPoints:AlterSourceData(newDT, {agi=delta});
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	agilityValue = (newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE]);

	-------------
	-- Stamina --
	-------------
	copyTable(newDT, sourceDT) -- load default data
	--newDT.playerHealth = newDT.playerHealth + 1 * 10 * StatLogic:GetStatMod("MOD_HEALTH");
	TankPoints:AlterSourceData(newDT, {sta=delta});
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	staminaValue = (newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE]);

	-----------
	-- Armor --
	-----------
	copyTable(newDT, sourceDT) -- load default data
--	local armorMod = StatLogic:GetStatMod("MOD_ARMOR")
--	newDT.armor = newDT.armor + 1 * armorMod
	--changesDT = { armorFromItems=1; };
	TankPoints:AlterSourceData(newDT, {armorFromItems=delta});
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	armorValue = (newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE]);

	------------------
	-- Dodge Rating --
	------------------
	copyTable(newDT, sourceDT) -- load default data
	--newDT.dodgeChance = newDT.dodgeChance + StatLogic:GetAvoidanceGainAfterDR("DODGE", StatLogic:GetEffectFromRating(1, CR_DODGE, newDT.playerLevel)) * 0.01;
	--changesDT = { dodgeChance=1; };
	TankPoints:AlterSourceData(newDT, { dodgeRating=delta } );
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	dodgeValue = (newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE]);

	------------------
	-- Parry Rating --
	------------------
	copyTable(newDT, sourceDT) -- load default data
	--newDT.parryChance = newDT.parryChance + StatLogic:GetAvoidanceGainAfterDR("PARRY", StatLogic:GetEffectFromRating(1, CR_PARRY, newDT.playerLevel)) * 0.01;
	TankPoints:AlterSourceData(newDT, {parryRating=delta} );
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	parryValue = (newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE]);

	------------------
	-- Block Rating -- was removed in 4.0.1
	------------------
	--copyTable(newDT, sourceDT) -- load default data
	--newDT.blockChance = newDT.blockChance + StatLogic:GetEffectFromRating(1, CR_BLOCK, newDT.playerLevel) * 0.01
	--TankPoints:GetTankPoints(newDT, TP_MELEE)
	--blockRating = (newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE]);

	--------------------
	-- Mastery Rating --
	--------------------
	copyTable(newDT, sourceDT) -- load default data
	TankPoints:AlterSourceData(newDT, {masteryRating=delta} );
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	masteryValue = (newDT.tankPoints[TP_MELEE] - resultsDT.tankPoints[TP_MELEE]);

	return strengthValue, agilityValue, staminaValue, armorValue, dodgeValue, parryValue, 0, masteryValue;
end