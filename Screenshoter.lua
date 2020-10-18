BINDING_NAME_SCREENSHOTER_TAKE = "Take screenshot"
BINDING_NAME_SCREENSHOTER_TAKE_MAXIMIZER = "Take screenshot with Maximizer" 

local Window = LibStub("LibWindow-1.1")

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
            transform = {
                x = -10,
                y = -10,
                sizeX = 150,
                sizeY = 50,
                scale = 1,
                point = "TOPRIGHT"
            },
            color = {r = 255, g = 255, b = 255, a = 1},
            font = "Fonts\\FRIZQT__.TTF",
            size = 10
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

    self:LoadFrames()
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
        
        if position == nil then
            result = string.gsub(result, "{x}", "0")
            result = string.gsub(result, "{y}", "0")
        else
            result = string.gsub(result, "{x}", format("%d", position.x * 100.0))
            result = string.gsub(result, "{y}", format("%d", position.y * 100.0))
        end

        self:RedrawWatermark(result)
        self:ShowWatermark(false)
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
        self:HideWatermark()
    end

    self.cache.working = false
end

function Screenshoter:ShowWatermark(background)
    local watermark = self.frames.watermark

    if background then 
        watermark.background:Show() 
    else
        watermark.background:Hide() 
    end

    watermark:Show()
end

function Screenshoter:HideWatermark()
    local watermark = self.frames.watermark

    watermark.background:Hide()
    watermark:Hide()
end

function Screenshoter:RedrawWatermark(text)
    local watermark = self.frames.watermark

    local _, _, flags = watermark.text:GetFont() 
    watermark.text:SetFont(self.database.watermark.font, self.database.watermark.size, flags)

    local color = self.database.watermark.color
    watermark.text:SetTextColor(color.r, color.g, color.b, color.a)

    if text ~= nil then
        watermark.text:SetText(text)
    end

    watermark:SetSize(watermark.text:GetStringWidth(), watermark.text:GetStringHeight())
end

function Screenshoter:LoadFrames()
    local watermark = CreateFrame("Frame", nil)
    watermark:SetFrameStrata("DIALOG")

    watermark.background = watermark:CreateTexture(nil, "OVERLAY")
    watermark.background:SetColorTexture(0, 0, 0, 0.5)
    watermark.background:SetAllPoints(watermark)
    watermark.background:Hide()

    watermark.text = watermark:CreateFontString(nil, "OVERLAY", "GameFontGreen")
    watermark.text:SetAllPoints(watermark)

    Window.RegisterConfig(watermark, self.database.watermark.transform)
    Window.RestorePosition(watermark)

    watermark:Hide()
    watermark:SetClampedToScreen(true)
    watermark:EnableMouse(true)
    watermark:SetMovable(true)
    watermark:RegisterForDrag("LeftButton")
    watermark:SetScript("OnDragStart", function() watermark:StartMoving() end)
    watermark:SetScript("OnDragStop", function()
        watermark:StopMovingOrSizing()
        Window.SavePosition(watermark)
    end)

    self.frames = {
        watermark = watermark
    }
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
                    header1 = {
                        order = 2,
                        name = "Key bindings",
                        type = "header"
                    },
                    take = {
                        order = 3,
                        name = "Take screenshot",
                        type = "keybinding",
                        set = function(_, val) SetBinding(val, "SCREENSHOTER_TAKE") end,
                        get = function() return GetBindingKey("SCREENSHOTER_TAKE") end
                    },
                    take_maximizer = {
                        order = 4,
                        name = "Take with Maximizer",
                        type = "keybinding",
                        set = function(_, val) SetBinding(val, "SCREENSHOTER_TAKE_MAXIMIZER") end,
                        get = function() return GetBindingKey("SCREENSHOTER_TAKE_MAXIMIZER") end
                    },
                    header2 = {
                        order = 5,
                        name = "Quality",
                        type = "header"
                    },
                    quality = {
                        order = 6,
                        name = "Quality",
                        type = "range",
                        min = 0,
                        max = 10,
                        step = 1,
                        set = function(_, val) SetCVar("screenshotQuality", val) end,
                        get = function() return tonumber(GetCVar("screenshotQuality")) end
                    },
                    format = {
                        order = 7,
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
                    move = {
                        order = 1,
                        type = "execute",
                        name = "Toggle widget",
                        func = function() 
                            local watermark = self.frames.watermark

                            if watermark:IsShown() then
                                self:HideWatermark()
                            else 
                                self:RedrawWatermark(self.database.watermark.format)
                                self:ShowWatermark(true)
                            end
                        end
                    },
                    header1 = {
                        order = 2,
                        name = "Settings",
                        type = "header"
                    },
                    format = {
                        order = 3,
                        width = "full",
                        name = "Format",
                        multiline = true,
                        type = "input",
                        set = function(_, val) 
                            self:RedrawWatermark(val)
                            self.database.watermark.format = val 
                        end,
                        get = function() return self.database.watermark.format end
                    },
                    variables = {
                        order = 4,
                        name = "\nAvailable variables: \n\n {char} - Character`s name\n {x} - Position X\n {y} - Position Y\n {zone} - Zone",
                        type = "description"
                    },
                    header2 = {
                        order = 5,
                        name = "Customization",
                        type = "header"
                    },
                    size = {
                        order = 6,
                        name = "Size",
                        type = "range",
                        min = 8,
                        max = 20,
                        step = 1,
                        set = function(_, val) 
                            self.database.watermark.size = val 
                            self:RedrawWatermark(nil)
                        end,
                        get = function() return self.database.watermark.size end
                    },
                    font = {
                        order = 7,
                        name = "Font",
                        type = "select",
                        values = {
                            ["Fonts\\FRIZQT__.TTF"] = "Frizqt"
                        },
                        set = function(_, val) 
                            self.database.watermark.font = val 
                            self:RedrawWatermark(nil)
                        end,
                        get = function() return self.database.watermark.font end
                    },
                    color = {   
                        order = 8,
                        name = "Color",
                        type = "color",
                        hasAlpha = true,
                        set = function(_, r, g, b, a)
                            if r == nil or g == nil or b == nil or a == nil then return end
                            self.database.watermark.color = {r = r, g = g, b = b, a = a}
                            self:RedrawWatermark(nil)
                        end,
                        get = function()
                            local color = self.database.watermark.color
                            return color.r , color.g, color.b, color.a
                        end
                    }
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
