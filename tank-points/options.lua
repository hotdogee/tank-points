local addon = TankPoints
local L = LibStub("AceLocale-3.0"):GetLocale("TankPoints") --Get the localization for our addon

local profileDB --TankPoints.db.profile, set during :SetupOptions()

--console/config options
local options = nil; --initialize to nil, so we can populate on demand in getOptions()


local function getOptions()

	--[[
		Slash Command Options
		Setup a description of our slash commands. This is a format defined by WowAce.
	--]]

	if not options then
		options = { 
			type = "group",
			args = {
				general = {
					type = "group",
					name = "TankPoints Options",
					desc = "Change general TankPoints options",
					cmdInline = true,
					args = {
						diff = {
							type = 'toggle',
							name = L["Show TankPoints Difference"],
							desc = L["Show TankPoints difference in item tooltips"],
							order = 0,
							get = function(info)
								local result = profileDB.showTooltipDiff;
								return result; --profileDB.showTooltipDiff 
								end,
							set = function(info, value)
								profileDB.showTooltipDiff = value
								TankPointsTooltips.ClearCache()
							end,
						},
						total = {
							type = 'toggle',
							name = L["Show TankPoints Total"],
							desc = L["Show TankPoints total in item tooltips"],
							order = 1,
							get = function(info) return profileDB.showTooltipTotal end,
							set = function(info, value)
								profileDB.showTooltipTotal = value
								TankPointsTooltips.ClearCache()
							end,
						},
						drdiff = {
							type = 'toggle',
							name = L["Show Melee DR Difference"],
							desc = L["Show Melee Damage Reduction difference in item tooltips"],
							order = 2,
							get = function(info) return profileDB.showTooltipDRDiff end,
							set = function(info, value)
								profileDB.showTooltipDRDiff = value
								TankPointsTooltips.ClearCache()
							end,
						},
						drtotal = {
							type = 'toggle',
							name = L["Show Melee DR Total"],
							desc = L["Show Melee Damage Reduction total in item tooltips"],
							order = 3,
							get = function(info) return profileDB.showTooltipDRTotal end,
							set = function(info, value)
								profileDB.showTooltipDRTotal = value
								TankPointsTooltips.ClearCache()
							end,
						},
						ehdiff = {
							type = 'toggle',
							name = L["Show Effective Health Difference"],
							desc = L["Show Effective Health difference in item tooltips"],
							order = 4,
							get = function(info) return profileDB.showTooltipEHDiff end,
							set = function(info, value)
								profileDB.showTooltipEHDiff = value
								TankPointsTooltips.ClearCache()
							end,
						},
						ehtotal = {
							type = 'toggle',
							name = L["Show Effective Health Total"],
							desc = L["Show Effective Health total in item tooltips"],
							order = 5,
							get = function(info) return profileDB.showTooltipEHTotal end,
							set = function(info, value)
								profileDB.showTooltipEHTotal = value
								TankPointsTooltips.ClearCache()
							end,
						},
						ehbdiff = {
							type = 'toggle',
							name = L["Show Effective Health (with Block) Difference"],
							desc = L["Show Effective Health (with Block) difference in item tooltips"],
							order = 6,
							get = function(info) return profileDB.showTooltipEHBDiff end,
							set = function(info, value)
								profileDB.showTooltipEHBDiff = value
								TankPointsTooltips.ClearCache()
							end,
						},
						ehbtotal = {
							type = 'toggle',
							name = L["Show Effective Health (with Block) Total"],
							desc = L["Show Effective Health (with Block) total in item tooltips"],
							order = 7,
							get = function(info) return profileDB.showTooltipEHBTotal end,
							set = function(info, value)
								profileDB.showTooltipEHBTotal = value
								TankPointsTooltips.ClearCache()
							end,
						},
						calc = {
							type = "execute",
							name = L["TankPoints Calculator"],
							desc = L["Shows the TankPoints Calculator"],
							order = 51,
							func = function()
								if(TankPointsCalculatorFrame:IsVisible()) then
									TankPointsCalculatorFrame:Hide()
								else
									TankPointsCalculatorFrame:Show()

								end
								TankPoints:UpdateTankPoints("TankPoints calc option exeucted")
							end,
						}, --calc
						dumptable = {
							type = "execute",
							name = "Dump TankPoints table",
							desc = "Print the TankPoints calculations table to the console",
							order = 52,
							func = function()
									TankPoints:DumpTable(TankPoints.resultsTable);
							end;
						},
						dumptableraw = {
							type = "execute",
							name = "Dump raw TankPoints table",
							desc = "Print the raw unformatted tankpoints calculation table to the console",
							order = 55,
							func = function()
									addon:DumpTableRaw(TankPoints.resultsTable);
							end;
						},
						config = {
							type = "execute",
							name = L["Options Window"],
							desc = L["Shows the Options Window"],
							order = 53,
							guiHidden = true,
							func = function()
								addon:ShowConfig()
							end,
						}, --config
						debug = {
							type = 'toggle',
							name = L["Enable Debugging"],
							desc = L["Toggle the display of debug messages"],
							order = 60,
							get = function(info) return addon:IsDebugging() end,
							set = function(info, value)
								addon:SetDebugging(value);
							end,
						},
						purgestats = {
							type = "execute",
							name = L["Purge Player Stats"],
							desc = L["Purge collected set of historical player stats"],
							order = 51,
							func = function()
								addon:PurgePlayerStats()
							end,
						}, --calc


					}, --general group entries
				}, --general group
				player = {
						type = "group",
						name = L["Player Stats"],
						desc = L["Change default player stats"],
						args = {
							sbfreq = {
								type = "range",
								name = L["Shield Block Key Press Delay"],
								desc = L["Sets the time in seconds after Shield Block finishes cooldown"],
								get = function(info) return profileDB.shieldBlockDelay end,
								set = function(info, value)
									profileDB.shieldBlockDelay = value
									TankPoints:UpdateTankPoints("Shield block delay option")
									-- Update Calculator
									if TankPointsCalculatorFrame:IsVisible() then
										TPCalc:UpdateResults()
									end
								end,
								min = 0,
								max = 1000,
							},
						}, --player Group Args
				}, --player Group
				mob = {
						type = "group",
						name = L["Mob Stats"],
						desc = L["Change default mob stats"],
						args = {
							level = {
								type = "range",
								name = L["Mob Level"],
								desc = L["Sets the level difference between the mob and you"],
								get = function(info) return profileDB.mobLevelDiff end,
								set = function(info, value)
									profileDB.mobLevelDiff = value
									TankPoints:UpdateTankPoints("Mob level difference");
									-- Update Calculator
									if TankPointsCalculatorFrame:IsVisible() then
										TPCalc:UpdateResults()
									end
								end,
								min = -20,
								max = 20,
								step = 1,
								order = 1,
							},
							default = {
								type = "execute",
								name = L["Restore Default"],
								desc = L["Restores default mob stats"],
								func = function()
									addon:SetDefaultMobStats()
								end,
								order = 2,
							},
							advanced = {
								type = "group",
								name = L["Mob Stats Advanced Settings"],
								desc = L["Change advanced mob stats"],
								inline = true,
								order = 10,
								args = {
									crit = {
										type = "range",
										name = L["Mob Melee Crit"],
										desc = L["Sets mob's melee crit chance"],
										get = function(info) return profileDB.mobCritChance end,
										set = function(info, value)
											profileDB.mobCritChance = value
											TankPoints:UpdateTankPoints("Mob melee crit chance");
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 1,
										isPercent = true,
									},
									critbonus = {
										type = "range",
										name = L["Mob Melee Crit Bonus"],
										desc = L["Sets mob's melee crit bonus"],
										get = function(info) return profileDB.mobCritBonus end,
										set = function(info, value)
											profileDB.mobCritBonus = value
											TankPoints:UpdateTankPoints("Mob melee crit bonus");
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 2,
									},
									miss = {
										type = "range",
										name = L["Mob Melee Miss"],
										desc = L["Sets mob's melee miss chance"],
										get = function(info) return profileDB.mobMissChance end,
										set = function(info, value)
											profileDB.mobMissChance = value
											TankPoints:UpdateTankPoints("Mob melee miss chance");
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 1,
										isPercent = true,
									},
									spellcrit = {
										type = "range",
										name = L["Mob Spell Crit"],
										desc = L["Sets mob's spell crit chance"],
										get = function(info) return profileDB.mobSpellCritChance end,
										set = function(info, value)
											profileDB.mobSpellCritChance = value
											TankPoints:UpdateTankPoints("Mob spell crit chance");
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 1,
										isPercent = true,
									},
									spellcritbonus = {
										type = "range",
										name = L["Mob Spell Crit Bonus"],
										desc = L["Sets mob's spell crit bonus"],
										get = function(info) return profileDB.mobSpellCritBonus end,
										set = function(info, value)
											profileDB.mobSpellCritBonus = value
											TankPoints:UpdateTankPoints("Mob spell crit bonus");
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 2,
									},
									spellmiss = {
										type = "range",
										name = L["Mob Spell Miss"],
										desc = L["Sets mob's spell miss chance"],
										get = function(info) return profileDB.mobSpellMissChance end,
										set = function(value)
											profileDB.mobSpellMissChance = value
											TankPoints:UpdateTankPoints("Mob spell miss chance");
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 1,
										isPercent = true,
									},
								}, --advanced group args
							}, --advanced
						}, --mob Group Entries
				}, --mob Group
				tooltips = {
					type = "group",
					name = L["Tooltip options"],
					desc = L["Change TankPoints tooltip options"],
					args = {
						ignoreGems = {
							type = "toggle",
							name = L["Ignore Gems"],
							desc = L["Ignore gems when comparing items"],
							order = 0,
							get = function(info) return profileDB.ignoreGemsInTooltipDiff end,
							set = function(info, value)
								profileDB.ignoreGemsInTooltipDiff = value
								TankPointsTooltips.ClearCache()
							end,
						},
						ignoreEnchants = {
							type = 'toggle',
							name = L["Ignore Enchants"],
							desc = L["Ignore enchants when comparing items"],
							order = 1,
							get = function(info) return profileDB.ignoreEnchantsInTooltipDiff end,
							set = function(info, value)
								profileDB.ignoreEnchantsInTooltipDiff = value
								TankPointsTooltips.ClearCache()
							end,
						},
						ignorePrismatic = {
							type = 'toggle',
							name = L["Ignore Prismatic"],
							desc = L["Igmore prismatic sockets when comparing items"],
							order = 2,
							get = function(info) return profileDB.ignorePrismaticInTooltipDiff end,
							set = function(info, value)
								profileDB.ignorePrismaticInTooltipDiff = value
								TankPointsTooltips.ClearCache()
							end,
						},
					}, --tooltip group entries
				
				}, --tooltips Group
				
			}, --options group entries
		} --options group
	end;

	return options;
end;

function addon:SetupOptions()
	addon:Debug("addon:SetupOptions()");

	--[[20101226 
			i don't know which RegisterOptionsTable method to use, it's not documented. 	
			i tried it both ways, and both seem to work. No guarantees that i'm supposed to use 
			one over the other though.
			
			i asked which is the correct one on the wowace forums 
				http://forums.wowace.com/showthread.php?p=313189
				AceConfig vs AceConfigRegistry :RegisterOptionsTable
	]]--
	--LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(optionsTableRegistrationName, getOptions)
	
	--Register options table
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TankPoints", getOptions, {"tp", "tankpoints"} ); --tp and tankpoints are our slash commands (i.e. /tp or /tankpoints)

	-- Setup Blizzard option frames
	addon.optionsFrames = {}
	local aceConfigDialog = LibStub("AceConfigDialog-3.0");
	local rootNodeName = L["TankPoints"]; --we need to use the same localized parent caption because children are placed under a parent node by caption
	addon.optionsFrames.general =  aceConfigDialog:AddToBlizOptions("TankPoints", rootNodeName,         nil,          "general") --options.args.general
	addon.optionsFrames.mob =      aceConfigDialog:AddToBlizOptions("TankPoints", L["Mob Stats"],       rootNodeName, "mob") --options.args.mob
	addon.optionsFrames.player =   aceConfigDialog:AddToBlizOptions("TankPoints", L["Player Stats"],    rootNodeName, "player") --options.args.player
	addon.optionsFrames.tooltips = aceConfigDialog:AddToBlizOptions("TankPoints", L["Tooltip Options"], rootNodeName, "tooltips") --options.args.tooltips
	
	addon.optionsFrames.general.default = function() addon:SetDefaultGeneralOptions() end;
	addon.optionsFrames.mob.default = function() addon:SetDefaultMobStats() end;

	profileDB = addon.db.profile;
end

-- Set Default Mob Stats
function addon:SetDefaultMobStats()
	--called when user clicks "Restore Default" in mob stats configuration pane
	--or from /tp mob default
	
	profileDB.mobLevelDiff = 3;
	profileDB.mobDamage = 0;
	profileDB.mobMissChance = 0.05;
	profileDB.mobCritChance = 0.05;
	profileDB.mobCritBonus = 1.0;
	profileDB.mobSpellCritChance = 0;
	profileDB.mobSpellCritBonus = 0.5;
	profileDB.mobSpellMissChance = 0;
	self:UpdateTankPoints("Reset mob stats to default");
	
	-- Update Calculator
	if TankPointsCalculatorFrame:IsVisible() then
		TPCalc:UpdateResults()
	end
	
	LibStub("AceConfigRegistry-3.0"):NotifyChange("TankPoints");

	TankPoints:Print(L["Restored Mob Stats Defaults"])
end

function addon:SetDefaultGeneralOptions()
--	self:Print("Resetting all TankPoints options to defaults");

--	addon:ResetDB('profile');

	profileDB.showTooltipDiff = true
	profileDB.showTooltipTotal = false
	profileDB.showTooltipDRDiff = false
	profileDB.showTooltipDRTotal = false
	profileDB.showTooltipEHDiff = false
	profileDB.showTooltipEHTotal = false
	profileDB.showTooltipEHBDiff = false
	profileDB.showTooltipEHBTotal = false

	TankPointsTooltips.ClearCache();

	LibStub("AceConfigRegistry-3.0"):NotifyChange("TankPoints");
	self:Print("Reset general TankPoints options to default");
end;

function addon:ShowConfig()
	--called by /tp config console option
	
	-- Open a child item first, so the menu expands
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.mob) --a child item
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.general) --now show the real thing we want to show
end
