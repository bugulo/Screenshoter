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
            name = "Select which names would you like to have visible on the screenshot\n",
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
            general = {
                order = 1,
                name = "General",
                type = "group",
                args = {
                    hideui = {
                        order = 0,
                        name = "Hide UI on screenshot",
                        desc = "Does not work in/during combat",
                        type = "toggle",
                        set = function(_, val) self.database.general.hideui = val end,
                        get = function() return self.database.general.hideui end
                    },
                    hide_character = {
                        order = 1,
                        name = "Hide character on screenshot",
                        type = "toggle",
                        set = function(_, val) self.database.general.hide_character = val end,
                        get = function() return self.database.general.hide_character end
                    },
                    header = {
                        order = 2,
                        name = "Quality",
                        type = "header"
                    },
                    quality = {
                        order = 3,
                        name = "Quality",
                        type = "range",
                        min = 0,
                        max = 10,
                        step = 1,
                        set = function(_, val) SetCVar("screenshotQuality", val) end,
                        get = function() return tonumber(GetCVar("screenshotQuality")) end
                    },
                    format = {
                        order = 4,
                        name = "Format",
                        type = "select",
                        values = {"jpg", "tga"},
                        set = function(_, val) SetCVar("screenshotFormat", val == 1 and "jpg" or "tga") end,
                        get = function() return GetCVar("screenshotFormat") == "jpg" and 1 or 2 end
                    }
                }
            },
            names = {
                order = 2,
                name = "Names",
                type = "group",
                args = args
            },
            watermark = {
                order = 3,
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
                    header = {
                        order = 1,
                        name = "Settings",
                        type = "header"
                    },
                    format = {
                        order = 2,
                        width = "full",
                        name = "Format",
                        multiline = true,
                        type = "input",
                        set = function(_, val) self.database.watermark.format = val end,
                        get = function() return self.database.watermark.format end
                    },
                    variables = {
                        order = 3,
                        name = "\nAvailable variables: \n\n {char} - Character`s name\n {x} - Position X\n {y} - Position Y\n {zone} - Zone",
                        type = "description"
                    },
                }
            },
            maximizer = {
                order = 4,
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
                    header1 = {
                        order = 1,
                        name = "Description",
                        type = "header"
                    },
                    description = {
                        order = 2,
                        name = "Maximizer can maximize your graphics settings just before taking the screenshot to make it look awesome and revert them immediately after. It is mostly for players that want to make their screenshots look beautiful even if they do not play on high graphic settings.",
                        type = "description"
                    },
                    header2 = {
                        order = 3,
                        name = "Settings",
                        type = "header"
                    },
                    seconds = {
                        order = 4,
                        name = "Seconds to wait",
                        desc = "Set how many seconds will Screenshoter wait before taking the screenshot. This delay ensures that all graphics settings are applied and rendered.",
                        type = "range",
                        min = 2,
                        max = 10,
                        step = 1,
                        set = function(_, val) self.database.maximizer.seconds = val end,
                        get = function() return self.database.maximizer.seconds end
                    }
                }
            }
        }
    })
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Screenshoter", "Screenshoter")
end
