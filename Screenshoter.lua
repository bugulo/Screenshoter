local Screenshoter = LibStub("AceAddon-3.0"):NewAddon("Screenshoter", "AceEvent-3.0")

local defaults = {
    global = {
        general = {
            enabled = true,
            hideui = true,
            hide_character = false
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

local names = {
    --FRIENDLY NAMES
    {key="UnitNameFriendlyPlayerName",      name="Friendly Player Names"},
    {key="UnitNameFriendlyPetName",         name="Friendly Pet Names"},
    {key="UnitNameFriendlySpecialNPCName",  name="Friendly Special NPC Names"},
    {key="UnitNameFriendlyTotemName",       name="Friendly Totem Names"},
    {key="UnitNameFriendlyGuardianName",    name="Friendly Guardian Names"},
    --ENEMY NAMES
    {key="UnitNameEnemyPlayerName",         name="Enemy Player Names"},
    {key="UnitNameEnemyPetName",            name="Enemy Pet Names"},
    {key="UnitNameEnemyTotemName",          name="Enemy Totem Names"},
    {key="UnitNameEnemyGuardianName",       name="Enemy Guardian Names"},
    --MISC
    {key="UnitNameGuildTitle",              name="Guild Titles"},
    {key="UnitNameNonCombatCreatureName",   name="Non-Combat Creature Names"},
    {key="UnitNameNPC",                     name="NPC Names"},
    {key="UnitNameOwn",                     name="Own Name"},
    {key="UnitNamePlayerGuild",             name="Guild Tags"},
    {key="UnitNamePlayerPVPTitle",          name="PVP Titles"},
    {key="UnitNameInteractiveNPC",          name="Interactive NPC Names"}
}

local graphics = {
    --DISPLAY
    {key="MSAAQuality",                 value="3"},
    --TEXTURES
    {key="graphicsTextureFiltering",    value="6"},
    {key="graphicsProjectedTextures",   value="2"},
    --ENVIROMENT
    {key="graphicsViewDistance",        value="10"},
    {key="graphicsEnvironmentDetail",   value="10"},
    {key="graphicsGroundClutter",       value="10"},
    --EFFECTS
    {key="graphicsShadowQuality",       value="6"},
    {key="graphicsLiquidDetail",        value="4"},
    {key="graphicsSunshafts",           value="3"},
    {key="graphicsParticleDensity",     value="4"},
    {key="graphicsSSAO",                value="4"},
    {key="graphicsDepthEffects",        value="4"},
    {key="graphicsLightingQuality",     value="3"},
    {key="graphicsOutlineMode",         value="3"},
    {key="ffxGlow",                     value="1"},
}

function Screenshoter:OnInitialize()
    self.database = LibStub("AceDB-3.0"):New("ScreenshoterDB", defaults, true).global

    self.cache = {
        working = false,
        uistate = false,
        names = {},
        graphics = {}
    }

    self:RegisterEvent("SCREENSHOT_SUCCEEDED", "Stop")

    self:LoadConfig()
end

function Screenshoter:Take()
    if self.cache.working or not self.database.general.enabled then return end

    self.cache.working = true

    self:Start()
    Screenshot()
end

function Screenshoter:Maximizer()
    if self.cache.working or not self.database.maximizer.enabled or not self.database.general.enabled then return end

    self.cache.working = true

    for key, cvar in ipairs(graphics) do
        self.cache.graphics[key] = GetCVar(cvar.key)
        SetCVar(cvar.key, cvar.value)
    end

    self:Start()

    C_Timer.After(self.database.maximizer.seconds, function() Screenshot() end)
end

function Screenshoter:Start()
    for key, cvar in ipairs(names) do
        self.cache.names[key] = GetCVar(cvar.key)
        SetCVar(cvar.key, self.database.names[key].enabled)
    end

    self.cache.uistate = UIParent:IsVisible()

    if self.database.general.hideui then
        UIParent:Hide()
    else
        UIParent:Show()
    end

    if self.database.general.hide_character then
        ConsoleExec("showplayer 0")
    end

    if self.database.watermark.enabled then
        local mapID = C_Map.GetBestMapForUnit("player")
        local position = C_Map.GetPlayerMapPosition(mapID, "player")

        local result = self.database.watermark.format
        result = string.gsub(result, "{zone}", GetMinimapZoneText())
        result = string.gsub(result, "{char}", UnitName("player"))
        result = string.gsub(result, "{x}", format("%d", position.x * 100.0))
        result = string.gsub(result, "{y}", format("%d", position.y * 100.0))

        Screenshoter_Watermark_Text:SetText(result)
        Screenshoter_Watermark_Text:Show()
    end
end

function Screenshoter:Stop()
    if not self.cache.working then return end

    for key, value in ipairs(self.cache.names) do
        SetCVar(names[key].key, value)
    end

    if self.database.maximizer.enabled then
        for key, value in ipairs(self.cache.graphics) do
            SetCVar(graphics[key].key, value)
        end
    end

    if self.cache.uistate then
        UIParent:Show()
    else
        UIParent:Hide()
    end

    if self.database.general.hide_character then
        ConsoleExec("showplayer 1")
    end

    if self.database.watermark.enabled then
        Screenshoter_Watermark_Text:Hide()
    end

    self.cache.working = false
end

function Screenshoter:LoadConfig()
    local args = {
        description = {
            order = 0,
            name = "You can select which names you want to have on screenshot\n",
            type = "description"
        }
    }

    for key, cvar in ipairs(names) do
        args[cvar.key] = {
            order = key,
            name = cvar.name,
            type = "toggle",
            set = function(_, val) self.database.names[key].enabled = val end,
            get = function() return self.database.names[key].enabled end
        }
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Screenshoter", {
        type = "group",
        args = {
            enable = {
                order = 0,
                name = "Enabled",
                type = "toggle",
                set = function(_, val) self.database.general.enabled = val end,
                get = function() return self.database.general.enabled end
            },
            hideui = {
                order = 1,
                name = "Hide UI on screenshot",
                desc = "Does not work in/during combat",
                type = "toggle",
                set = function(_, val) self.database.general.hideui = val end,
                get = function() return self.database.general.hideui end
            },
            hide_character = {
                order = 2,
                name = "Hide character on screenshot",
                type = "toggle",
                set = function(_, val) self.database.general.hide_character = val end,
                get = function() return self.database.general.hide_character end
            },
            names = {
                order = 3,
                name = "Names",
                type = "group",
                args = args
            },
            watermark = {
                order = 1,
                name = "Watermark",
                type = "group",
                args = {
                    enabled = {
                        order = 0,
                        name = "Enable Watermark",
                        type = "toggle",
                        set = function(_, val) self.database.watermark.enabled = val end,
                        get = function() return self.database.watermark.enabled end
                    },
                    format = {
                        order = 1,
                        width = "full",
                        name = "Format",
                        multiline = true,
                        type = "input",
                        set = function(_, val) self.database.watermark.format = val end,
                        get = function() return self.database.watermark.format end
                    },
                    format_desc = {
                        order = 2,
                        name = "\nAvailable variables: \n\n {char} - Character`s name\n {x} - Position X\n {y} - Position Y\n {zone} - Zone",
                        type = "description"
                    },
                }
            },
            maximizer = {
                order = 2,
                name = "Maximizer",
                type = "group",
                args = {
                    enabled = {
                        order = 0,
                        name = "Enable Maximizer",
                        type = "toggle",
                        set = function(_, val) self.database.maximizer.enabled = val end,
                        get = function() return self.database.maximizer.enabled end
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
                        set = function(_, val) self.database.maximizer.seconds = val end,
                        get = function() return self.database.maximizer.seconds end
                    },
                    stw_desc = {
                        order = 3,
                        name = "\nSeconds to wait is option that will set how many seconds will Screenshoter wait before taking screenshot. If you don't have Maximizer enabled, screenshots are taken instantly. In Maximizer no, why? If you change any graphics settings, it takes some time before these changes are applied to your GPU and rendered. There has to be some 'wait time' that will ensure that all settings are applied and rendered before taking screenshots. Default 'wait time' is 3 seconds but you can change it as you want (from 2 seconds to 10 seconds)",
                        type = "description"
                    },
                }
            },
            other = {
                order = 3,
                name = "Other",
                type = "group",
                args = {
                    quality = {
                        order = 0,
                        name = "Screenshot quality",
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
                        type = "select",
                        values = { "jpg", "tga" },
                        set = function(_, val) SetCVar("screenshotFormat", val == 1 and "jpg" or "tga") end,
                        get = function() return GetCVar("screenshotFormat") == "jpg" and 1 or 2 end
                    }
                }
            }
        }
    })
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Screenshoter", "Screenshoter")
end
