--- AceDebug-3.0 simplified addon debugging.
--
-- @class file
-- @name AceDebug-3.0
-- @release $Id: AceDebug-3.0.lua 975 2010-10-23 11:26:18Z nevcairiel $
local MAJOR, MINOR = "spAceDebug-3.0", 3
local AceDebug, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceDebug then return end

--[[
	function Debug(...)
		Does something
	
	function SetDebugging(debugging)
		Set whether debugging is enabled
				true to enable debugging
				

	function IsDebugging()
		Gets whether debugging is enabled
		
	function SetDebugLevel(level)
		Set the current debugging level
				level 1: Critical messages that every user should receive
				level 2: Should be used for local debugging (function calls, etc)
				level 3: Very verbose debugging, will dump everything and anything
				nil: receive no debug information

	function GetDebugLevel()				
		Gets the current debug level
				nil: receive no debug information
				level 1: Critical messages that every user should receive
				level 2: Should be used for local debugging (function calls, etc)
				level 3: Very verbose debugging, will dump everything and anything

	function LevelDebug(level, ...)
		Writes a debug message that is for a specific debug level
				level 1: Critical messages that every user should receive
				level 2: Should be used for local debugging (function calls, etc)
				level 3: Very verbose debugging, will dump everything and anything
				
	function CustomDebug(r, g, b, frame, delay, a1, ...)
		Does something


--]]

-- Lua APIs
local pairs = pairs

local function safecall(func,...)
	local success, err = pcall(func,...)
	if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("\n(.-: )in.-\n") or "") .. err) end
end

local DEBUGGING, TOGGLE_DEBUGGING
if GetLocale() == "frFR" then
	DEBUGGING = "D\195\169boguage"
	TOGGLE_DEBUGGING = "Activer/d\195\169sactiver le d\195\169boguage"
elseif GetLocale() == "deDE" then
	DEBUGGING = "Debuggen"
	TOGGLE_DEBUGGING = "Aktiviert/Deaktiviert Debugging."
elseif GetLocale() == "koKR" then
	DEBUGGING = "디버깅"
	TOGGLE_DEBUGGING = "디버깅 기능 사용함/사용안함"
elseif GetLocale() == "zhTW" then
	DEBUGGING = "除錯"
	TOGGLE_DEBUGGING = "啟用/停用除錯功能。"
elseif GetLocale() == "zhCN" then
	DEBUGGING = "\232\176\131\232\175\149"
	TOGGLE_DEBUGGING = "\229\144\175\231\148\168/\231\166\129\231\148\168 \232\176\131\232\175\149."
elseif GetLocale() == "esES" then
	DEBUGGING = "Debugging"
	TOGGLE_DEBUGGING = "Activar/desactivar Debugging."
elseif GetLocale() == "ruRU" then
	DEBUGGING = "Отладка"
	TOGGLE_DEBUGGING = "Вкл/Выкл отладку для этого аддона."
else -- enUS
	DEBUGGING = "Debugging"
	TOGGLE_DEBUGGING = "Toggle debugging for this addon."
end

local function print(text, r, g, b, frame, delay)
	(frame or DEFAULT_CHAT_FRAME):AddMessage(text, r, g, b, 1, delay or 5)
end

local tmp = {}

function AceDebug:CustomDebug(r, g, b, frame, delay, a1, ...)
	if not self.debugging then
		return
	end

	local output = self:GetDebugPrefix()
	
	a1 = tostring(a1)
	if a1:find("%%") and select('#', ...) >= 1 then
		for i = 1, select('#', ...) do
			tmp[i] = tostring((select(i, ...)))
		end
		output = output .. " " .. a1:format(unpack(tmp))
		for i = 1, select('#', ...) do
			tmp[i] = nil
		end
	else
		-- This block dynamically rebuilds the tmp array stopping on the first nil.
		tmp[1] = output
		tmp[2] = a1
		for i = 1, select('#', ...) do
			tmp[i+2] = tostring((select(i, ...)))
		end
		
		output = table.concat(tmp, " ")
		
		for i = 1, select('#', ...) + 2 do
			tmp[i] = nil
		end
	end

	print(output, r, g, b, frame or self.debugFrame, delay)
end

function AceDebug:Debug(...)
	AceDebug.CustomDebug(self, nil, nil, nil, nil, nil, ...)
end

function AceDebug:IsDebugging()
	return self.debugging
end

function AceDebug:SetDebugging(debugging)
	if debugging then
		self.debugging = debugging;
		print("Debugging enabled");

		if type(self.OnDebugEnable) == "function" then
			safecall(self.OnDebugEnable, self)
		end
	else
		if type(self.OnDebugDisable) == "function" then
			safecall(self.OnDebugDisable, self)
		end
		self.debugging = debugging;
		print("Debugging disabled");
	end
end

-- Takes a number 1-3
-- Level 1: Critical messages that every user should receive
-- Level 2: Should be used for local debugging (function calls, etc)
-- Level 3: Very verbose debugging, will dump everything and anything
-- If set to nil, you will receive no debug information
function AceDebug:SetDebugLevel(level)
	AceDebug:argCheck(level, 1, "number", "nil")
	if not level then
		self.debuglevel = nil
		return
	end
	if level < 1 or level > 3 then
		AceDebug:error("Bad argument #1 to `SetDebugLevel`, must be a number 1-3")
	end
	self.debuglevel = level
end

-- Taken from LibStatLogic, which took it from AceLibrary
function AceDebug:argCheck(arg, num, kind, kind2, kind3, kind4, kind5)
	if type(num) ~= "number" then
		return error(string.format("Bad argument #3 to `argCheck' (number expected, got %s)", type(num)), 2);
	elseif type(kind) ~= "string" then
		return error(string.format("Bad argument #4 to `argCheck' (string expected, got %s)", type(kind)), 2);
	end
	arg = type(arg)
	if arg ~= kind and arg ~= kind2 and arg ~= kind3 and arg ~= kind4 and arg ~= kind5 then
		local stack = debugstack()
		local func = stack:match("`argCheck'.-([`<].-['>])")
		if not func then
			func = stack:match("([`<].-['>])")
		end
		if kind5 then
			return error(string.format("Bad argument #%s to %s (%s, %s, %s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, kind4, kind5, arg), 2);
		elseif kind4 then
			return error(string.format("Bad argument #%s to %s (%s, %s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, kind4, arg), 2);
		elseif kind3 then
			return error(string.format("Bad argument #%s to %s (%s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, arg), 2);
		elseif kind2 then
			return error(string.format("Bad argument #%s to %s (%s or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, arg), 2);
		else
			return error(string.format("Bad argument #%s to %s (%s expected, got %s)", tonumber(num) or 0/0, func, kind, arg), 2);
		end
	end
end


function AceDebug:GetDebugPrefix()
	return ("|cff7fff7f(DEBUG) %s:[%s.%3d]|r"):format( tostring(self), date("%H:%M:%S"), (GetTime() % 1) * 1000)
end

function AceDebug:GetDebugLevel()
	return self.debuglevel
end

function AceDebug:CustomLevelDebug(level, r, g, b, frame, delay, a1, ...)
	if not self.debugging or not self.debuglevel then return end
	AceDebug:argCheck(level, 1, "number")
	if level < 1 or level > 3 then
		AceDebug:error("Bad argument #1 to `LevelDebug`, must be a number 1-3")
	end
	if level > self.debuglevel then return end

	local output = self:GetDebugPrefix()

	a1 = tostring(a1)
	if a1:find("%%") and select('#', ...) >= 1 then
		for i = 1, select('#', ...) do
			tmp[i] = tostring((select(i, ...)))
		end
		output = output .. " " .. a1:format(unpack(tmp))
		for i = 1, select('#', ...) do
			tmp[i] = nil
		end
	else
		-- This block dynamically rebuilds the tmp array stopping on the first nil.
		tmp[1] = output
		tmp[2] = a1
		for i = 1, select('#', ...) do
			tmp[i+2] = tostring((select(i, ...)))
		end
		
		output = table.concat(tmp, " ")
		
		for i = 1, select('#', ...) + 2 do
			tmp[i] = nil
		end
	end

	print(output, r, g, b, frame or self.debugFrame, delay)
end

function AceDebug:LevelDebug(level, ...)
	if not self.debugging or not self.debuglevel then return end
	AceDebug:argCheck(level, 1, "number")
	if level < 1 or level > 3 then
		AceDebug:error("Bad argument #1 to `LevelDebug`, must be a number 1-3")
	end
	if level > self.debuglevel then return end

	AceDebug.CustomLevelDebug(self, level, nil, nil, nil, nil, nil, ...)
end


local options
function AceDebug:GetAceOptionsDataTable(target)
	if not options then
		options = {
			debug = {
				name = DEBUGGING,
				desc = TOGGLE_DEBUGGING,
				type = "toggle",
				get = "IsDebugging",
				set = "SetDebugging",
				order = -2,
			}
		}
	end
	return options
end


AceDebug.embeds = AceDebug.embeds or {}

--- embedding and embed handling
local mixins = {
	"Debug",
	"CustomDebug",
	"IsDebugging",
	"SetDebugging",
	"SetDebugLevel",
	"LevelDebug",
	"CustomLevelDebug",
	"GetDebugLevel",
	"GetDebugPrefix",
}

-- Embeds AceDebug into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceDebug in
function AceDebug:Embed(target)
	AceDebug.embeds[target] = true
	for _, v in pairs(mixins) do
		target[v] = self[v]
	end
	return target
end

for addon in pairs(AceDebug.embeds) do
	AceDebug:Embed(addon)
end



