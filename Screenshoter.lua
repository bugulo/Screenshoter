BINDING_HEADER_SCREENSHOT = "Screenshoter"
BINDING_NAME_SCREENSHOTER_TAKE = "Take screenshot"

local window = CreateFrame("FRAME", "EventFrame");
local events = {}

window:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...);
end);

function events:SCREENSHOT_SUCCEEDED()
	ShowUI()
end

function events:VARIABLES_LOADED()
	if SCR_CVARS == nil then
		Reset()
	end
	Load()
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Screenshoter", "Screenshoter")
end

function Reset()
	SCR_OTHER = {
		hideui = true,
		enabled = true
	}
	SCR_CVARS = {
		{
			name = "UnitNameFriendlyPetName",
			enabled = LoadCVar("UnitNameFriendlyPetName"),
			scr_enabled = LoadCVar("UnitNameFriendlyPetName")
		},
		{
			name = "UnitNameFriendlyPlayerName",
			enabled = LoadCVar("UnitNameFriendlyPlayerName"),
			scr_enabled = LoadCVar("UnitNameFriendlyPlayerName")
		}, 
		{
			name = "UnitNameFriendlyGuardianName",
			enabled = LoadCVar("UnitNameFriendlyGuardianName"),
			scr_enabled = LoadCVar("UnitNameFriendlyGuardianName")
		},
		{
			name = "UnitNameFriendlySpecialNPCName",
			enabled = LoadCVar("UnitNameFriendlySpecialNPCName"),
			scr_enabled = LoadCVar("UnitNameFriendlySpecialNPCName")
		},
		{
			name = "UnitNameFriendlyTotemName",
			enabled = LoadCVar("UnitNameFriendlyTotemName"),
			scr_enabled = LoadCVar("UnitNameFriendlyTotemName")
		},
		{
			name = "UnitNameGuildTitle",
			enabled = LoadCVar("UnitNameGuildTitle"),
			scr_enabled = LoadCVar("UnitNameGuildTitle")
		},
		{
			name = "UnitNameOwn",
			enabled = LoadCVar("UnitNameOwn"),
			scr_enabled = LoadCVar("UnitNameOwn")
		},
		{
			name = "UnitNameNPC",
			enabled = LoadCVar("UnitNameNPC"),
			scr_enabled = LoadCVar("UnitNameNPC")
		},
		{
			name = "UnitNameNonCombatCreatureName",
			enabled = LoadCVar("UnitNameNonCombatCreatureName"),
			scr_enabled = LoadCVar("UnitNameNonCombatCreatureName")
		}, 
		{
			name = "UnitNamePlayerGuild",
			enabled = LoadCVar("UnitNamePlayerGuild"),
			scr_enabled = LoadCVar("UnitNamePlayerGuild")
		},
		{
			name = "UnitNamePlayerPVPTitle",
			enabled = LoadCVar("UnitNamePlayerPVPTitle"),
			scr_enabled = LoadCVar("UnitNamePlayerPVPTitle")
		},
		{
			name = "UnitNameEnemyPetName",
			enabled = LoadCVar("UnitNameEnemyPetName"),
			scr_enabled = LoadCVar("UnitNameEnemyPetName")
		},
		{
			name = "UnitNameEnemyGuardianName",
			enabled = LoadCVar("UnitNameEnemyGuardianName"),
			scr_enabled = LoadCVar("UnitNameEnemyGuardianName")
		}, 
		{
			name = "UnitNameEnemyTotemName",
			enabled = LoadCVar("UnitNameEnemyTotemName"),
			scr_enabled = LoadCVar("UnitNameEnemyTotemName")
		},
		{
			name = "UnitNameEnemyPlayerName",
			enabled = LoadCVar("UnitNameEnemyPlayerName"),
			scr_enabled = LoadCVar("UnitNameEnemyPlayerName")
		}, 
		{
			name = "UnitNameInteractiveNPC",
			enabled = LoadCVar("UnitNameInteractiveNPC"),
			scr_enabled = LoadCVar("UnitNameInteractiveNPC")
		}
	}
end

function LoadCVar(name)
	if GetCVar(name) == "0" then return false
	else return true
	end
end

function Load()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Screenshoter", {
		type = "group",
		args	 = {
			enable = {
				name = "Enable",
				desc = "Enables / disables the addon",
				type = "toggle",
				set = function(_, val) SCR_OTHER.enabled = val end,
				get = function() return SCR_OTHER.enabled end
			},
			names = {
				name = "Names",
				type = "group",
				args = {
					FriendlyPetName = {
						name = "Friendly Pet Name",
						desc = "Enables / disables friendly pet name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[1].scr_enabled = val end,
						get = function() return SCR_CVARS[1].scr_enabled end
					},
					FriendlyPlayerName = {
						name = "Friendly Player Name",
						desc = "Enables / disables friendly player name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[2].scr_enabled = val end,
						get = function() return SCR_CVARS[2].scr_enabled end
					},
					FriendlyGuardianName = {
						name = "Friendly Guardian Name",
						desc = "Enables / disables friendly guardian name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[3].scr_enabled = val end,
						get = function() return SCR_CVARS[3].scr_enabled end
					},
					FriendlySpecialNPCName = {
						name = "Friendly Special NPC Name",
						desc = "Enables / disables friendly special NPC name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[4].scr_enabled = val end,
						get = function() return SCR_CVARS[4].scr_enabled end
					},
					FriendlyTotemName = {
						name = "Friendly Totem Name",
						desc = "Enables / disables friendly totem name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[5].scr_enabled = val end,
						get = function() return SCR_CVARS[5].scr_enabled end
					},
					GuildTitle = {
						name = "Guild Title",
						desc = "Enables / disables guild title on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[6].scr_enabled = val end,
						get = function() return SCR_CVARS[6].scr_enabled end
					},
					Own = {
						name = "Own Name",
						desc = "Enables / disables own name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[7].scr_enabled = val end,
						get = function() return SCR_CVARS[7].scr_enabled end
					},
					NPC = 
					{
						name = "NPC Name",
						desc = "Enables / disables NPC name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[8].scr_enabled = val end,
						get = function() return SCR_CVARS[8].scr_enabled end
					},
					NonCombatCreatureName = 
					{
						name = "Non Combat Creature Name",
						desc = "Enables / disables non combat creature name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[9].scr_enabled = val end,
						get = function() return SCR_CVARS[9].scr_enabled end
					},
					PlayerGuild = 
					{
						name = "Player Guild Name",
						desc = "Enables / disables player guild name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[10].scr_enabled = val end,
						get = function() return SCR_CVARS[10].scr_enabled end
					},
					PlayerPVPTitle = 
					{
						name = "Player PvP Title",
						desc = "Enables / disables player PvP title on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[11].scr_enabled = val end,
						get = function() return SCR_CVARS[11].scr_enabled end
					},
					EnemyPetName = 
					{
						name = "Enemy Pet Name",
						desc = "Enables / disables enemy pet name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[12].scr_enabled = val end,
						get = function() return SCR_CVARS[12].scr_enabled end
					},
					EnemyGuardianName = 
					{
						name = "Enemy Guardian Name",
						desc = "Enables / disables enemy guardian name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[13].scr_enabled = val end,
						get = function() return SCR_CVARS[13].scr_enabled end
					},
					EnemyTotemName = 
					{
						name = "Enemy Totem Name",
						desc = "Enables / disables enemy totem name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[14].scr_enabled = val end,
						get = function() return SCR_CVARS[14].scr_enabled end
					},
					EnemyPlayerName = 
					{
						name = "Enemy Player Name",
						desc = "Enables / disables enemy player name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[15].scr_enabled = val end,
						get = function() return SCR_CVARS[15].scr_enabled end
					},
					InteractiveNPC = 
					{
						name = "Interactive NPC Name",
						desc = "Enables / disables interactive NPC name on screenshot",
						type = "toggle",
						set = function(_, val) SCR_CVARS[16].scr_enabled = val end,
						get = function() return SCR_CVARS[16].scr_enabled end
					}
				}
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
						set = function(_, val) SCR_OTHER.hideui = val end,
						get = function() return SCR_OTHER.hideui end
					}
				}
			}
		}
	})
end

function TakeScreenshot()
	if SCR_OTHER.enabled
	then
		HideUI()
		Screenshot()
	end
end

function HideUI()
	for _, cvar in ipairs(SCR_CVARS) do
		if cvar.enabled 
		then
			SetCVar(cvar.name, cvar.scr_enabled)
		end
	end
	if SCR_OTHER.hideui then 
		ToggleFrame(UIParent)
	end
end

function ShowUI()
	for _, cvar in ipairs(SCR_CVARS) do
		if cvar.enabled 
		then
			SetCVar(cvar.name, cvar.enabled)
		end
	end
	if SCR_OTHER.hideui then 
		ToggleFrame(UIParent)
	end
end

for k, _ in pairs(events) do
	window:RegisterEvent(k); 
end
