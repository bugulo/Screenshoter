BINDING_HEADER_SCREENSHOT = "Screenshoter"
BINDING_NAME_SCREENSHOTER_TAKE = "Take screenshot"

local hash = "YqrsLSQzDa"

local window = CreateFrame("FRAME", "EventFrame");

local events = {}
local settings = {}

local isScreenshoting = false

local cvars = {
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
        SCR_NAMES = {}
		for key in ipairs(cvars) do
			SCR_NAMES[key] = false
		end
	end
end

function LoadWindow()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Screenshoter", {
		type = "group",
		args = {
			enable = {
				name = "Enable",
				desc = "Enables / disables the addon",
				type = "toggle",
				set = function(_, val) SCR_QUALITY.enabled = val end,
				get = function() return SCR_QUALITY.enabled end
			},
			names = {
				name = "Names",
				type = "group",
				args = PrepareArgs()
			},
			other = {
				name = "Other",
				type = "group",
				args = {
					quality = {
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
						name = "Image format",
						desc = "Change image format",
						type = "select",
						values = {"jpg", "tga"},
						set = function(_, val) SetCVar("screenshotFormat", val == 1 and "jpg" or "tga") end,
						get = function() return GetCVar("screenshotFormat") == "jpg" and 1 or 2 end
					},
					hideui =
					{
						name = "Hide UI on screenshot",
						desc = "Enables / disables UI on screenshot",
						type = "toggle",
						set = function(_, val) SCR_QUALITY.hideui = val end,
						get = function() return SCR_QUALITY.hideui end
					}
				}
			}
		}
	})
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Screenshoter", "Screenshoter")
end

function PrepareArgs()
    local args = {}
    for key, cvar in ipairs(cvars) do
        args[cvar.key] = {
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
            Screenshot()
        end
    end
end

function HideUI()
    for key, cvar in ipairs(cvars)  do
        settings[key] = GetCVar(cvar.key)
    end

	for key, value in ipairs(SCR_NAMES) do
        SetCVar(cvars[key].key, value, cvars[key].key)
    end

	if SCR_QUALITY.hideui then ToggleFrame(UIParent) end
end

function ShowUI()
    for key, value in ipairs(settings) do
        SetCVar(cvars[key].key, value, cvars[key].key)
    end

	if SCR_QUALITY.hideui and isScreenshoting then
        ToggleFrame(UIParent)
        isScreenshoting = false
    end
end

for k in pairs(events) do
	window:RegisterEvent(k);
end
