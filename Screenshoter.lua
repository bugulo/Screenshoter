BINDING_HEADER_SCREENSHOT = "Screenshoter"

BINDING_NAME_SCREENSHOTER_TAKE = "Take screenshot"
BINDING_NAME_SCREENSHOTER_TAKE_MAXIMIZER = "Take screenshot with Maximizer"

local window = CreateFrame("FRAME", "EventFrame");

local watermark = CreateFrame("Frame", "Watermark", nil)
watermark:SetSize(200,100)
watermark:SetPoint("TOPLEFT", 0, -10)
watermark.text = watermark:CreateFontString(nil, "ARTWORK", "GameFontGreen")
watermark.text:SetAllPoints(true)
watermark.text:SetJustifyH("CENTER")
watermark.text:SetJustifyV("TOP") 

local cache =
{
    events = {},
    names = {},
    graphics = {},
    wasUiVisible = false,
    isScreenshoting = false
}

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")

local database

local names = {
    --FRIENDLY NAMES
    { key = "UnitNameFriendlyPlayerName", name = "Friendly Player Names", desc = "Toggle Friendly Player Names" },
    { key = "UnitNameFriendlyPetName", name = "Friendly Pet Names", desc = "Toggle Friendly Pet Names" },
    { key = "UnitNameFriendlySpecialNPCName", name = "Friendly Special NPC Names", desc = "Toggle Friendly Special NPC Names" },
    { key = "UnitNameFriendlyTotemName", name = "Friendly Totem Names", desc = "Toggle Friendly Totem Names" },
    { key = "UnitNameFriendlyGuardianName", name = "Friendly Guardian Names", desc = "Toggle Friendly Guardian Names"
    },
    --ENEMY NAMES
    { key = "UnitNameEnemyPlayerName", name = "Enemy Player Names", desc = "Toggle Enemy Player Names" },
    { key = "UnitNameEnemyPetName", name = "Enemy Pet Names", desc = "Toggle Enemy Pet Names" },
    { key = "UnitNameEnemyTotemName", name = "Enemy Totem Names", desc = "Toggle Enemy Totem Names" },
    { key = "UnitNameEnemyGuardianName", name = "Enemy Guardian Names", desc = "Toggle Enemy Guardian Names" },
    --MISC
    { key = "UnitNameGuildTitle", name = "Guild Titles", desc = "Toggle Guild Titles in Player Names" },
    { key = "UnitNameNonCombatCreatureName", name = "Non-Combat Creature Names", desc = "Toggle Non-Combat Creature Names" },
    { key = "UnitNameNPC", name = "NPC Names", desc = "Toggle NPC Names" },
    { key = "UnitNameOwn", name = "Own Name", desc = "Toggle Own Name" },
    { key = "UnitNamePlayerGuild", name = "Guild Tags", desc = "Toggle Guild Tags" },
    { key = "UnitNamePlayerPVPTitle", name = "PVP Titles", desc = "Toggle PVP Titles" },
    { key = "UnitNameInteractiveNPC", name = "Interactive NPC Names", desc = "Toggle Interactive NPC Names" }
}

local graphics = {
    --DISPLAY
    { key = "MSAAQuality", value = "3" },
    --TEXTURES
    { key = "graphicsTextureFiltering", value = "6" },
    { key = "graphicsProjectedTextures", value = "2" },
    --ENVIROMENT
    { key = "graphicsViewDistance", value = "10" },
    { key = "graphicsEnvironmentDetail", value = "10" },
    { key = "graphicsGroundClutter", value = "10" },
    --EFFECTS
    { key = "graphicsShadowQuality", value = "6" },
    { key = "graphicsLiquidDetail", value = "4" },
    { key = "graphicsSunshafts", value = "3" },
    { key = "graphicsParticleDensity", value = "4" },
    { key = "graphicsSSAO", value = "4" },
    { key = "graphicsDepthEffects", value = "4" },
    { key = "graphicsLightingQuality", value = "3" },
    { key = "graphicsOutlineMode", value = "3" },
    { key = "ffxGlow", value = "1" },
}

local issues = {
    "- Possible incompatibility with some addons",
    "- Some name options are not available in settings yet",
    "- Maximizer is not changing texture resolution yet"
}

window:SetScript("OnEvent", function(self, event, ...)
    cache.events[event](self, ...);
end);

function cache.events:SCREENSHOT_SUCCEEDED()
    Screenshoter_Stop()
end

function cache.events:VARIABLES_LOADED()
    local defaults = {
        global = {
            general = {
                hideui = true,
                enabled = true,
            },
            watermark = {
                enabled = false,
                format = "{char}\n{x}:{y} , {zone}",
            },
            maximizer = {
                enabled = false, 
                seconds = 3,
            },
            names = {
                ['*'] = {
                  enabled = false,
                }
            }
        }
    }

    database = AceDB:New("SCR_CONFIG", defaults, true)
    Screenshoter_LoadConfig()
end

for k in pairs(cache.events) do
    window:RegisterEvent(k);
end

function Screenshoter_PrepareNames()
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
            set = function(_, val) database.global.names[key].enabled = val end,
            get = function() return database.global.names[key].enabled end
        }
    end
    return args
end

function Screenshoter_Take()
    if cache.isScreenshoting or not database.global.general.enabled then return end

    cache.isScreenshoting = true
    Screenshoter_Start()
    Screenshot()
end

function Screenshoter_Maximizer()
    if cache.isScreenshoting or not database.global.maximizer.enabled or not database.global.general.enabled then return end

    cache.isScreenshoting = true
    for key, cvar in ipairs(graphics) do
        cache.graphics[key] = GetCVar(cvar.key)
        SetCVar(cvar.key, cvar.value)
    end

    Screenshoter_Start()

    if database.global.maximizer.enabled then
        C_Timer.After(database.global.maximizer.seconds, function() Screenshot() end)
    end
end

function Screenshoter_Start()
    for key, cvar in ipairs(names) do
        cache.names[key] = GetCVar(cvar.key)
    end

    for key, value in ipairs(database.global.names) do
        SetCVar(names[key].key, value.enabled)
    end

    cache.wasUiVisible = UIParent:IsVisible()
    if database.global.general.hideui then
        UIParent:Hide()
    else
        UIParent:Show()
    end

    if database.global.watermark.enabled then
        mapID = C_Map.GetBestMapForUnit("player")
        position = C_Map.GetPlayerMapPosition(mapID,"player")

        result = database.global.watermark.format
        result = string.gsub(result, "{zone}", GetMinimapZoneText())
        result = string.gsub(result, "{char}", UnitName("player"))
        result = string.gsub(result, "{x}", format("%d", position.x * 100.0))
        result = string.gsub(result, "{y}", format("%d", position.y * 100.0))

        watermark.text:SetText(result)
        watermark:Show()
    end
end

function Screenshoter_Stop()
    if not cache.isScreenshoting then return end

    for key, value in ipairs(cache.names) do
        SetCVar(names[key].key, value)
    end

    if database.global.maximizer.enabled then
        for key, value in ipairs(cache.graphics) do
            SetCVar(graphics[key].key, value)
        end
    end

    if cache.wasUiVisible then
        UIParent:Show()
    else
        UIParent:Hide()
    end

    if database.global.watermark.enabled then
        watermark:Hide()
    end

    cache.isScreenshoting = false
end

function Screenshoter_LoadConfig()
    AceConfig:RegisterOptionsTable("Screenshoter", {
        type = "group",
        args = {
            enable = {
                order = 0,
                name = "Enable",
                desc = "Enables / disables the addon",
                type = "toggle",
                set = function(_, val) database.global.general.enabled = val end,
                get = function() return database.global.general.enabled end
            },
            hideui = {
                order = 1,
                name = "Hide UI on screenshot",
                desc = "Enables / disables UI on screenshot. Does not apply to screenshot that was taken during combat",
                type = "toggle",
                set = function(_, val) database.global.general.hideui = val end,
                get = function() return database.global.general.hideui end
            },
            names = {
                order = 0,
                name = "Names",
                type = "group",
                args = Screenshoter_PrepareNames()
            },
            watermark = {
                order = 1,
                name = "Watermark",
                type = "group",
                args = {
                    enabled = {
                        order = 0,
                        name = "Enable Watermark",
                        desc = "Enables / disables the Watermark feature",
                        type = "toggle",
                        set = function(_, val) database.global.watermark.enabled = val end,
                        get = function() return database.global.watermark.enabled end
                    },
                    format = {
                        order = 1,
                        width = "full",
                        name = "Format",
                        multiline = true,
                        desc = "Customize watermark format",
                        type = "input",
                        set = function(_, val) database.global.watermark.format = val end,
                        get = function() return database.global.watermark.format end
                    },
                    format_desc = {
                        order = 3,
                        name = "\nAvailable variables: \n\n {char} - Character`s name\n {x} - Position X\n {y} - Position Y\n {zone} - Zone",
                        type = "description"
                    },
                }
            },
            other = {
                order = 2,
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
                        values = { "jpg", "tga" },
                        set = function(_, val) SetCVar("screenshotFormat", val == 1 and "jpg" or "tga") end,
                        get = function() return GetCVar("screenshotFormat") == "jpg" and 1 or 2 end
                    }
                }
            },
            maximizer = {
                order = 3,
                name = "Maximizer",
                type = "group",
                args = {
                    enabled = {
                        order = 0,
                        name = "Enable Maximizer",
                        desc = "Enables / disables the Maximizer feature",
                        type = "toggle",
                        set = function(_, val) database.global.maximizer.enabled = val end,
                        get = function() return database.global.maximizer.enabled end
                    },
                    description = {
                        order = 1,
                        name = "\nNotice: Maximizer can maximize graphics settings just before taking screenshot to make it look awesome and revert these changes just after taking screenshot. It is mostly for players that want to make their screenshots beautiful even though they are playing on low or medium settings. If you want to enable this feature, you can simply check Enable option above this notice",
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
                        set = function(_, val) database.global.maximizer.seconds = val end,
                        get = function() return database.global.maximizer.seconds end
                    },
                    stw_desc = {
                        order = 3,
                        name = "\nSeconds to wait is option that will set how many seconds will Screenshoter wait before taking screenshot. If you don't have Maximizer enabled, screenshots are taken instantly. In Maximizer no, why? If you change any graphics settings, it takes some time before these changes are applied to your GPU and rendered. There has to be some 'wait time' that will ensure that all settings are applied and rendered before taking screenshots. Default 'wait time' is 3 seconds but you can change it as you want (from 2 seconds to 10 seconds)",
                        type = "description"
                    },
                }
            },
            issues = {
                order = 3,
                name = "Known/possible issues",
                type = "group",
                args = {
                    text = {
                        order = 0,
                        name = table.concat(issues, "\n"),
                        type = "description"
                    },
                }
            }
        }
    })
    AceConfigDialog:AddToBlizOptions("Screenshoter", "Screenshoter")
end