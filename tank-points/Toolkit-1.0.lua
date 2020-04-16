local MAJOR,MINOR = "Toolkit-1.0", 2
local Toolkit, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not Toolkit then return end -- no upgrade needed

--[[
	Convert a table to string
--]]
local function tableToString(tbl, recurseDepth)

	recurseDepth = (recurseDepth or 0) + 1;
	if (recurseDepth > 3) then
		return "(recurse depth limit reached)";
	end;

	local function val_to_str(v)
		if "string" == type(v) then
			v = string.gsub(v, "\n", "\\n" )
			if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
				return "'" .. v .. "'"
			end
			return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
		else
			return "table" == type(v) and tableToString(v, recurseDepth) or tostring(v)
		end
	end

	local function key_to_str(k)
		if "string" == type(k) and string.match( k, "^[_%a][_%a%d]*$" ) then
			return k
		else
			return "[" .. val_to_str( k ) .. "]"
		end
	end

	local result, done = {}, {}
	for k, v in ipairs(tbl) do
		table.insert( result, val_to_str(v) )
		done[ k ] = true
	end
	for k, v in pairs(tbl) do
		if not done[ k ] then
			table.insert( result, key_to_str(k) .. "=" .. val_to_str(v) )
		end
	end
	return "{" .. table.concat( result, ", " ) .. "}"
end


--[[
	Convert a value to a string
	@param value The value to convert to a string

	Some types in LUA refuse to be converted to a string, so we have to do it for it.
	This function is intended to do the work that LUA was too lazy to do. 
	This is the "go to" function you can use to ensure that the variable you want to print will be printed.
--]]
function Toolkit:VarAsString(value)
	--[[
	The LUA built-in type() function returns a lowercase string that contains one of the following:
	- "nil"			we must manually return "nil"
	- "boolean"		we must manually convert to "true" or "false"
	- "number"
	- "string"
	- "function"
	- "userdata"
	- "thread"
	- "table"		we must manually convert to a string
	--]]

	local result = ""; 
	--result = result.."["..type(value).."] = "
	
	if (value == nil) then
		result = result.."nil"
	elseif (type(value) == "table") then
		result = result..tableToString(value)
	elseif (type(value) == "boolean") then
		if (value) then
			result = result.."true"
		else
			result = result.."false"
		end
	else
		result = result..value
	end
	
	return result;
end

--[[
	Return a number formatted with color codes.
	The number is positive it will be colored green. 
	If the number is negative it will be colored red.
	If the number is zero it will contain no coloring (e.g. black)
	@remarks This function is almost identical to Toolkit.ColorText(format("%5.0f", number), number)
		Except ColorNumber returns no coloring information if number is zero,
		while ColorText colors "zero-value" text the "highlight" color.
--]]
function Toolkit:ColorNumber(number)
	local v = format("%5.0f", number);
	
	if (value == 0) then
		return v;
	elseif (value > 0) then
		return GREEN_FONT_COLOR_CODE..v..FONT_COLOR_CODE_CLOSE;
		else
			return RED_FONT_COLOR_CODE..v..FONT_COLOR_CODE_CLOSE;
		end
end

--[[
	Colorizes the supplied text red or green, based on number being positive or negative.
	@param textToShow A string to be colorized red or green
	@param number A number that decides how textToShow will be colored.
			Text will be green if number is positive.
			Text will be red if number is negative.
			Text will be "highlight" color if number is zero.
	@example Print(Toolkit.ColorText("Mallet of Zul'Farak", pointsDifference));
--]]
function Toolkit:ColorText(textToShow, number)
	if number > 0 then
		return GREEN_FONT_COLOR_CODE..textToShow..FONT_COLOR_CODE_CLOSE
	elseif number < 0 then
		return RED_FONT_COLOR_CODE..textToShow..FONT_COLOR_CODE_CLOSE
	else
		return HIGHLIGHT_FONT_COLOR_CODE..textToShow..FONT_COLOR_CODE_CLOSE
	end
end

--[[
	Return the font color code for an arbitrary rgb color
	
--]]
function Toolkit:MakeFontColorCode(r, g, b)
	--[[
	|cffffff00(bright yellow)|r
	--]]
	local s = string.format("|cff%02x%02x%02x", r*255, g*255, b*255);
	return s;
end

--[[
	Range color text
	Color some text between a range of colors
--]]
function Toolkit:RangeColorText(szText, value, minValue, minRed, minGreen, minBlue, maxValue, maxRed, maxGreen, maxBlue)
	
	assert(szText,   "RangeColorText: szText is nil");
	assert(value,    "RangeColorText: value is nil");
	assert(minValue, "RangeColorText: minValue is nil");
	assert(minRed,   "RangeColorText: minRed is nil");
	assert(minGreen, "RangeColorText: minGreen is nil");
	assert(minBlue,  "RangeColorText: minBlue is nil");
	assert(maxValue, "RangeColorText: maxValue is nil");
	assert(maxRed,   "RangeColorText: maxRed is nil");
	assert(maxGreen, "RangeColorText: maxGreen is nil");
	assert(maxBlue,  "RangeColorText: maxBlue is nil");
	

	local r, g, b, t, ti;
	th = (value - minValue) / (maxValue - minValue); --parameterized 0..1 
	tl = (1-th);
	
	r = (minRed*tl + maxRed*th);
	g = (minGreen*tl + maxGreen*th);
	b = (minBlue*tl + maxBlue*th);

	local s;
	s = Toolkit:MakeFontColorCode(r, g, b)..szText..FONT_COLOR_CODE_CLOSE; --e.g. |cFFrrggbbThe quick brown fox|r
	--s = Toolkit:MakeFontColorCode(minRed, minGreen, minBlue)..szText..FONT_COLOR_CODE_CLOSE; --e.g. |cFFrrggbbThe quick brown fox|r
	--s = Toolkit:MakeFontColorCode(maxRed, maxGreen, maxBlue)..szText..FONT_COLOR_CODE_CLOSE; --e.g. |cFFrrggbbThe quick brown fox|r
	--local s = "|cffffffff"..szText.."|r";
	return s;
end;


--[[
	Convert an integer into a localized string (i.e. one containing comma separators)
	@param integer An integer to be converted to a string
	@returns A string containing a localized version of the number
	@example IntToStrLocale(1234567890) returns "1,234,567,890"
--]]
function Toolkit:IntToStrLocale(integer)
	local s = format("%5.0f", integer)
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

--[[
	Find the index of entry in the table t.
	@param t A table to search through
	@param entry The entry in the table to look for
	@returns The index index of entry in table t. If entry is not in the table then the results are undefined
--]]
function Toolkit:GetTableIndex(t, entry)
	--TODO: switch to for x, element in pairs(table) do  to speed it up (http://lua-users.org/wiki/OptimisationCodingTips)
	for i = 1, table.getn(t), 1 do
		if (t[i] == entry) then
			return i;
		end
	end
end

--[[
	Round a number to the nearing integer using Symmetric (i.e. "point five up") rounding
	@param num  A numeric value to round to be rounded (e.g. 3.5)
	@returns  The passed number rounded to the nearest integer (e.g. 4)
	@remarks This function perform symmetric rounding, which has a bias towards larger numbers.
		Unbiased rounding requires this Bankers Rounding algorithm.
--]]
function Toolkit:Round(num)
	return math.floor((num or 0) + 0.5);
end

--[[
	Tests whether the player currently has the specified buff
	@buffName  The name of a buff to look for 
	@returns  Returns true if the player has the specified, otherwise false
	@remarks This function can only be used to check for the presence of a Buff, and not a Debuff.
	@example local hasKings = Toolkit:IsPlayerBuffUp("Blessing of Kings");
--]]
function Toolkit:IsPlayerBuffUp(buffName)
	local iIterator = 1
	while (UnitBuff("player", iIterator)) do
		if (string.find(UnitBuff("player", iIterator), buffName)) then
			return true
		end
		iIterator = iIterator + 1
	end
	return false
end;

--[[
	Clone a table
	@param source A variable containing a table to be copied
	@param destination An option table that will be recycled to contain a copy of the source table
	@returns The a copy of the source table
	@remarks The reason we pass an optional "destionation" table (rather than simply returning a new table) is that
		recycling an existing table saves excess garbage being generated (emptying an existing table and recycling it
		for new contents is more efficient that throwing an unneeded table and allocating a new one. 	
		Too many allocated tables cause memory pressure while we wait for a garbage collection cycle
	@example local tempstats = Toolkit.CopyTable(currentStats);
	@example local newStats = Toolkit.CopyTable(currentStats, tempstats)
--]]
function Toolkit:CopyTable(source, destinaton)

	--If we were supplied a destination table, then use it to store our copy (rather than allocating a whole new table)
	if destinaton then
		--empty out destination, getting it ready to receive our data
		for k in pairs(destinaton) do
			destinaton[k] = nil
		end
		setmetatable(destinaton, nil)
	else
		destinaton = {}
	end
	
	--Recursively copy all the guts of source into destination
	for k,v in pairs(source) do
		if type(k) == "table" then
			k = CopyTable(k, {})
		end
		if type(v) == "table" then
			v = CopyTable(v, {})
		end
		destinaton[k] = v
	end
	setmetatable(destinaton, getmetatable(source))
	
	return destinaton
end

function Toolkit:ClearTable(aTable)

	local result = aTable;

	--If we were supplied aTable, then clear it out (rather than allocating a whole new table)
	if result then
		--empty out aTable, getting it ready to receive our data
		for k in pairs(result) do
			result[k] = nil
		end
		setmetatable(result, nil)
	else
		result = {}
	end

	return result;
end;

--[[
	Check if two numbers are equal, within floating point epsilon
--]]
function Toolkit:NearlyEqual(value1, value2)
	local epsilon = 0.001;

	if math.abs(value2-value1) < epsilon then
		return true;
	else
		return false;
		end;
end;

