GM.DefaultFlag = "unsc"
GM.DefaultAnimationController = "gmod_player"

GM.EquipmentNames = {
	unsc_headwear = "headwear",
	unsc_back = "backpack",
	unsc_armor = "armor",
	unsc_undersuit = "undersuit",
	spartan = "armor",
	spartan_arm = "prosthetic",
	elite = "elite armor"
}

TEAM_UNSC     = Team.Add("unsc",     "UNSC",                   Color(0, 120, 0))
TEAM_SPARTAN  = Team.Add("spartan",  "SPARTAN",                Color(33, 106, 196))
TEAM_AI       = Team.Add("ai",       "Artifical Intelligence", Color(0, 191, 255))
TEAM_COVENANT = Team.Add("covenant", "Covenant",               Color(110, 76, 170))

local function Lang(command, name, unknown, default, override)
	return {
		Command = command,
		Name = name,
		Unknown = unknown or name,
		Default = default,
		Override = override
	}
end

GM.Languages = {
	Lang("eng", "English", nil, true),
	Lang("spa", "Spanish"),
	Lang("chi", "Chinese"),
	Lang("hin", "Hindi"),
	Lang("por", "Portugese"),
	Lang("rus", "Russian"),
	Lang("ger", "German"),
	Lang("jpn", "Japanese"),
	Lang("fra", "French"),
	Lang("kor", "Korean"),
	Lang("hun", "Hungarian"),
	Lang("swa", "Swahili")
}

local function canSeeAdminBadge(ply)
	if SERVER then
		return true
	end

	return lp:IsAdmin() or not ply:GetSetting("HideAdminBadge")
end

local function canSeePrivateBadge(ply)
	if SERVER then
		return true
	end

	return lp:IsAdmin() or lp == ply
end

Badge.Add("admin_bot",       "Bot",                      1000, "icon16/monkey.png",        function(ply) return ply:IsBot() end)
Badge.Add("admin_developer", "Developer",                100,  "icon16/tag.png",           function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "developer" end)
Badge.Add("admin_super",     "Superadmin",               100,  "icon16/shield_add.png",    function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "superadmin" end)
Badge.Add("admin",           "Admin",                    100,  "icon16/shield.png",        function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "admin" end)
Badge.Add("admin_temp",      "Temporary Admin",          99,   "icon16/shield_delete.png", function(ply) return canSeeAdminBadge(ply) and ply:TempAdmin() end)

Badge.Add("tt_banned",       "Banned Tooltrust",         60,   "icon16/key_delete.png",    function(ply) return canSeePrivateBadge(ply) and ply:GetToolTrust() == TOOLTRUST_BANNED end)
Badge.Add("tt_advanced",     "Advanced Tooltrust",       60,   "icon16/key_add.png",       function(ply) return canSeePrivateBadge(ply) and ply:GetToolTrust() == TOOLTRUST_ADVANCED end)
Badge.Add("ooc_muted",       "OOC Muted",                55,   "icon16/keyboard_mute.png", function(ply) return canSeePrivateBadge(ply) and ply:OOCMuted() end)
Badge.Add("char_hidden",     "Character Hidden",         54,   "icon16/contrast_low.png",  function(ply) return canSeePrivateBadge(ply) and ply:CharacterHidden() end)

Badge.Add("betatest",        "Beta Tester",              41,   "icon16/controller.png")
Badge.Add("bughunter",       "Bug Hunter",               40,   "icon16/bug.png")

Badge.Add("misc_event",      "Event Character",          21,   "icon16/vcard.png",         function(ply) return ply:IsEventCharacter() end)
Badge.Add("misc_newbie",     "Inexperienced Roleplayer", 20,   "icon16/new.png",           function(ply) return ply:GetSetting("Newbie") end)

-- RADIO_PRESET = Radio.AddPreset("radiogroup", "presetname")

COVENANT_MAIN = Radio.AddPreset("covenant", "COVENANT-MAIN")
COVENANT_TAC1 = Radio.AddPreset("covenant", "COVENANT-TAC1")
COVENANT_TAC2 = Radio.AddPreset("covenant", "COVENANT-TAC2")

UNSC_SATCOM = Radio.AddPreset("unsc", "UNSC-SATCOM")
UNSC_TACCOM = Radio.AddPreset("unsc", "UNSC-TACCOM")
