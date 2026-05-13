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

local function Badge(id, name, material, callback)
	return {
		ID = id,
		Name = name,
		Material = Material(material),
		Callback = callback,
		Automated = tobool(callback)
	}
end

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

Badge.Add("bot",        "Bot",                      BADGE_ADMIN + 3,    "icon16/monkey.png",        function(ply) return ply:IsBot() end)
Badge.Add("developer",  "Developer",                BADGE_ADMIN + 2,    "icon16/tag.png",           function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "developer" end)
Badge.Add("superadmin", "Superadmin",               BADGE_ADMIN + 1,    "icon16/shield_add.png",    function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "superadmin" end)
Badge.Add("admin",      "Admin",                    BADGE_ADMIN,        "icon16/shield.png",        function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "admin" end)
Badge.Add("tempadmin",  "Temporary Admin",          BADGE_ADMIN - 1,    "icon16/shield_delete.png", function(ply) return canSeeAdminBadge(ply) and ply:TempAdmin() end)

Badge.Add("bannedtt",   "Banned Tooltrust",         BADGE_PRIVATE,      "icon16/key_delete.png",    function(ply) return canSeePrivateBadge(ply) and ply:GetToolTrust() == TOOLTRUST_BANNED end)
Badge.Add("advancedtt", "Advanced Tooltrust",       BADGE_PRIVATE,      "icon16/key_add.png",       function(ply) return canSeePrivateBadge(ply) and ply:GetToolTrust() == TOOLTRUST_ADVANCED end)
Badge.Add("oocmuted",   "OOC Muted",                BADGE_PRIVATE - 1,  "icon16/keyboard_mute.png", function(ply) return canSeePrivateBadge(ply) and ply:OOCMuted() end)
Badge.Add("hidden",     "Character Hidden",         BADGE_PRIVATE - 2,  "icon16/contrast_low.png",  function(ply) return canSeePrivateBadge(ply) and ply:CharacterHidden() end)

Badge.Add("betatest",   "Beta Tester",              BADGE_ASSIGNED + 1, "icon16/controller.png")
Badge.Add("bughunter",  "Bug Hunter",               BADGE_ASSIGNED,     "icon16/bug.png")

Badge.Add("event",      "Event Character",          BADGE_MISC + 1,     "icon16/vcard.png", function(ply) return ply:IsEventCharacter() end)
Badge.Add("newbie",     "Inexperienced Roleplayer", BADGE_MISC,         "icon16/new.png",   function(ply) return ply:GetSetting("Newbie") end)

-- RADIO_PRESET = Radio.AddPreset("radiogroup", "presetname")

COVENANT_MAIN = Radio.AddPreset("covenant", "COVENANT-MAIN")
COVENANT_TAC1 = Radio.AddPreset("covenant", "COVENANT-TAC1")
COVENANT_TAC2 = Radio.AddPreset("covenant", "COVENANT-TAC2")

UNSC_SATCOM = Radio.AddPreset("unsc", "UNSC-SATCOM")
UNSC_TACCOM = Radio.AddPreset("unsc", "UNSC-TACCOM")
