BINDING_HEADER_SCREENSHOT = "Screenshoter"
BINDING_NAME_SCREENSHOTER_TAKE = "Take screenshot"

local hash = "1ZdcYdHyjP"

local window = CreateFrame("FRAME", "EventFrame");

local events = {}
local settings = {
    names = {},
    graphics = {}
}

local isScreenshoting = false

local names = {
    --FRIENDLY NAMES
    {
        key = "UnitNameFriendlyPlayerName",
        name = "Friendly Player Names",
        desc = "Toggle Friendly Player Names"
    },
    {
        key = "UnitNameFriendlyPetName",
        name = "Friendly Pet Names",
        desc = "Toggle Friendly Pet Names"
    },
    {
        key = "UnitNameFriendlySpecialNPCName",
        name = "Friendly Special NPC Names",
        desc = "Toggle Friendly Special NPC Names"
    },
    {
        key = "UnitNameFriendlyTotemName",
        name = "Friendly Totem Names",
        desc = "Toggle Friendly Totem Names"
    },
    {
        key = "UnitNameFriendlyGuardianName",
        name = "Friendly Guardian Names",
        desc = "Toggle Friendly Guardian Names"
    },
    --ENEMY NAMES
    {
        key = "UnitNameEnemyPlayerName",
        name = "Enemy Player Names",
        desc = "Toggle Enemy Player Names"
    },
    {
        key = "UnitNameEnemyPetName",
        name = "Enemy Pet Names",
        desc = "Toggle Enemy Pet Names"
    },
    {
        key = "UnitNameEnemyTotemName",
        name = "Enemy Totem Names",
        desc = "Toggle Enemy Totem Names"
    },
    {
        key = "UnitNameEnemyGuardianName",
        name = "Enemy Guardian Names",
        desc = "Toggle Enemy Guardian Names"
    },
    --MISC
    {
        key = "UnitNameGuildTitle",
        name = "Guild Titles",
        desc = "Toggle Guild Titles in Player Names"
    },
    {
        key = "UnitNameNonCombatCreatureName",
        name = "Non-Combat Creature Names",
        desc = "Toggle Non-Combat Creature Names"
    },
    {
        key = "UnitNameNPC",
        name = "NPC Names",
        desc = "Toggle NPC Names"
    },
    {
        key = "UnitNameOwn",
        name = "Own Name",
        desc = "Toggle Own Name"
    },
    {
        key = "UnitNamePlayerGuild",
        name = "Guild Tags",
        desc = "Toggle Guild Tags"
    },
    {
        key = "UnitNamePlayerPVPTitle",
        name = "PVP Titles",
        desc = "Toggle PVP Titles"
    },
    {
        key = "UnitNameInteractiveNPC",
        name = "Interactive NPC Names",
        desc = "Toggle Interactive NPC Names"
    }
}

local graphics = {
    {
        key = "graphicsViewDistance",
        value = "10"
    },
    {
        key = "graphicsEnvironmentDetail",
        value = "10"
    },
    {
        key = "graphicsGroundClutter",
        value = "10"
    },
    {
        key = "graphicsShadowQuality",
        value = "6"
    },
    {
        key = "graphicsParticleDensity",
        value = "4"
    },
}

local bugs = {
    "- Names of players and NPCs are always hidden on screenshots if ElvUI is enabled",
    "- Some name options are not available in settings yet",
    "- Maximizer is not maximizing all graphics settings yet"
}

window:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...);
end);

function events:SCREENSHOT_SUCCEEDED()
	ShowUI()
end

function events:VARIABLES_LOADED()
	LoadSettings()
	LoadWindow()
end

function LoadSettings()
	if SCR_HASH == nil or SCR_HASH ~= hash then
        SCR_HASH = hash
		SCR_QUALITY = {
			hideui = true,
			enabled = true
        }
        SCR_MAXIMIZER = {
            enabled = false,
            seconds = 3
        }
        SCR_NAMES = {}
		for key in ipairs(names) do
			SCR_NAMES[key] = false
		end
	end
end

function LoadWindow()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Screenshoter", {
		type = "group",
		args = {
			enable = {
                order = 0,
				name = "Enable",
				desc = "Enables / disables the addon",
				type = "toggle",
				set = function(_, val) SCR_QUALITY.enabled = val end,
				get = function() return SCR_QUALITY.enabled end
			},
            hideui = {
                order = 1,
                name = "Hide UI on screenshot",
                desc = "Enables / disables UI on screenshot",
                type = "toggle",
                set = function(_, val) SCR_QUALITY.hideui = val end,
                get = function() return SCR_QUALITY.hideui end
            },
			names = {
                order = 0,
				name = "Names",
				type = "group",
				args = PrepareNames()
			},
			other = {
                order = 1,
				name = "Other",
				type = "group",
				args = {
					quality = {
                        order = 0,
						name = "Screenshot quality",
						desc = "Change screenshot quality",
						type = "range",
						min = 0,
						max = 10,
						step = 1,
						set = function(_, val) SetCVar("screenshotQuality", val) end,
						get = function() return tonumber(GetCVar("screenshotQuality")) end
					},
					imgformat = {
                        order = 1,
						name = "Image format",
						desc = "Change image format",
						type = "select",
						values = {"jpg", "tga"},
						set = function(_, val) SetCVar("screenshotFormat", val == 1 and "jpg" or "tga") end,
						get = function() return GetCVar("screenshotFormat") == "jpg" and 1 or 2 end
					}
				}
			},
            maximizer_experimental = {
                order = 2,
                name = "Maximizer - Experimental",
                type = "group",
                args = {
                    enabled = {
                        order = 0,
                        name = "Enable Maximizer",
                        desc = "Enables / disables the Maximizer feature",
                        type = "toggle",
                        set = function(_, val) SCR_MAXIMIZER.enabled = val end,
                        get = function() return SCR_MAXIMIZER.enabled end
                    },
                    description = {
                        order = 1,
                        name = "\nNotice: Maximizer is new experimental feature. This feature can maximize graphics settings just before taking screenshot to make it look awesome and revert these changes just after taking screenshot. If you want to enable this feature, you can simply check Enable option above this notice",
                        type = "description"
                    },
                    seconds = {
                        order = 2,
                        name = "Seconds to wait",
                        desc = "Set how many seconds will Screenshoter wait before taking screenshot. This option is there because when you change some graphics settings, it takes some time before game is rendered in higher quality, so Screenshoter has to wait until all settings are visible",
                        type = "range",
                        min = 2,
                        max = 10,
                        step = 1,
                        set = function(_, val) SCR_MAXIMIZER.seconds = val end,
                        get = function() return SCR_MAXIMIZER.seconds end
                    },
                    stw_desc = {
                        order = 3,
                        name = "\nSeconds to wait is option that will set how many seconds will Screenshoter wait before taking screenshot. If you don't have Maximizer enabled, screenshots are taken instantly. In Maximizer no, why? If you change any graphics settings, it takes some time before these changes are applied to your GPU and rendered. There has to be some 'wait time' that will ensure that all settings are applied and rendered before taking screenshots. Default 'wait time' is 3 seconds but you can change it as you want (from 2 seconds to 10 seconds)",
                        type = "description"
                    },
                }
            },
            bugs = {
                order = 3,
                name = "Known bugs/Problems",
                type = "group",
                args = {
                    text = {
                        order = 0,
                        name = table.concat(bugs, "\n"),
                        type = "description"
                    },
                }
            }
		}
	})
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Screenshoter", "Screenshoter")
end

function PrepareNames()
    local args = {}
    args.description = {
        order = 0,
        name = "You can select which names you want to have on screenshot\n",
        type = "description"
    }
    for key, cvar in ipairs(names) do
        args[cvar.key] = {
            order = key,
            name = cvar.name,
            desc = cvar.desc,
            type = "toggle",
            set = function(_, val) SCR_NAMES[key] = val end,
            get = function() return SCR_NAMES[key] end
        }
    end
    return args
end

function TakeScreenshot()
    if not isScreenshoting then
        isScreenshoting = true
        if SCR_QUALITY.enabled then
            HideUI()
            if SCR_MAXIMIZER.enabled then
                C_Timer.After(SCR_MAXIMIZER.seconds, function() Screenshot() end)
            else
                Screenshot()
            end
        end
    end
end

function HideUI()
    for key, cvar in ipairs(names) do
        settings.names[key] = GetCVar(cvar.key)
    end

    if SCR_MAXIMIZER.enabled then
        for key, cvar in ipairs(graphics) do
            settings.graphics[key] = GetCVar(cvar.key)
            SetCVar(cvar.key, cvar.value)
        end
    end

	for key, value in ipairs(SCR_NAMES) do
        SetCVar(names[key].key, value)
    end

	if SCR_QUALITY.hideui then ToggleFrame(UIParent) end
end

function ShowUI()
    for key, value in ipairs(settings.names) do
        SetCVar(names[key].key, value)
    end

    if SCR_MAXIMIZER.enabled then
        for key, value in ipairs(settings.graphics) do
           SetCVar(graphics[key].key, value)
        end
    end

	if isScreenshoting then
        if SCR_QUALITY.hideui then
            ToggleFrame(UIParent)
        end
        isScreenshoting = false
    end
end

for k in pairs(events) do
	window:RegisterEvent(k);
end
