GM.DefaultFlag = "citizen"
GM.DefaultAnimationController = "gmod_player"

GM.EquipmentNames = {
	test = "Test Slot"
}

TEAM_CITIZEN = Team.Add("citizens", "Citizens", Color(0, 120, 0))

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
	Lang("rus", "Russian"),
	Lang("chi", "Chinese"),
	Lang("jpn", "Japanese"),
	Lang("spa", "Spanish"),
	Lang("fre", "French"),
	Lang("ger", "German"),
	Lang("ita", "Italian")
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

-- Badges are displayed right to left based on this order
GM.Badges = {
	Badge("bot",        "Bot",             "icon16/server.png",        function(ply) return ply:IsBot() end),
	Badge("developer",  "Developer",       "icon16/tag.png",           function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "developer" end),
	Badge("superadmin", "Superadmin",      "icon16/shield_add.png",    function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "superadmin" end),
	Badge("admin",      "Admin",           "icon16/shield.png",        function(ply) return canSeeAdminBadge(ply) and ply:GetUserGroup() == "admin" end),
	Badge("tempadmin",  "Temporary Admin", "icon16/shield_delete.png", function(ply) return ply:TempAdmin() end),

	Badge("bannedtt",   "Banned Tooltrust",    "icon16/key_delete.png",    function(ply) return canSeePrivateBadge(ply) and ply:GetToolTrust() == TOOLTRUST_BANNED end),
	Badge("advancedtt", "Advanced Tooltrust",  "icon16/key_add.png",       function(ply) return canSeePrivateBadge(ply) and ply:GetToolTrust() == TOOLTRUST_ADVANCED end),
	Badge("oocmuted",   "OOC Muted",           "icon16/keyboard_mute.png", function(ply) return canSeePrivateBadge(ply) and ply:OOCMuted() == 1 end),
	Badge("hidden",     "Manually Hidden",     "icon16/contrast_low.png",  function(ply) return canSeePrivateBadge(ply) and ply:CharacterHidden() == 1 end),

	Badge("betatest",   "Beta Tester", "icon16/controller.png"),
	Badge("bughunter",  "Bug Hunter",  "icon16/bug.png"),

	Badge("newbie",     "Inexperienced Roleplayer", "icon16/new.png", function(ply) return ply:GetSetting("Newbie") end)
}
