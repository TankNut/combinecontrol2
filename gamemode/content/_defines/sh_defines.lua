TEAM_CITIZEN = Team.Add("Citizens", Color(0, 120, 0))

GM.DefaultFlag = "citizen"

GM.EquipmentNames = {
	test = "Test Slot"
}

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

local function ShowToAdminsOrSelf(ply)
	if SERVER then
		return true
	end

	return lp:IsAdmin() or lp == ply
end

-- Badges are displayed right to left based on this order
GM.Badges = {
	Badge("bot",        "Bot",             "icon16/monkey.png",        function(ply) return ply:IsBot() end),
	Badge("developer",  "Developer",       "icon16/tag.png",           function(ply) return ply:GetUserGroup() == "developer" end),
	Badge("superadmin", "Superadmin",      "icon16/shield_add.png",    function(ply) return ply:GetUserGroup() == "superadmin" end),
	Badge("admin",      "Admin",           "icon16/shield.png",        function(ply) return ply:GetUserGroup() == "admin" end),
	Badge("tempadmin",  "Temporary Admin", "icon16/shield.png",        function(ply) return ply:TempAdmin() end),

	Badge("bannedtt",   "Banned Tooltrust",    "icon16/key_delete.png",    function(ply) return ShowToAdminsOrSelf(ply) and ply:GetToolTrust() == TOOLTRUST_BANNED end),
	Badge("advancedtt", "Advanced Tooltrust",  "icon16/key_add.png",       function(ply) return ShowToAdminsOrSelf(ply) and ply:GetToolTrust() == TOOLTRUST_ADVANCED end),
	Badge("oocmuted",   "Muted from OOC Chat", "icon16/keyboard_mute.png", function(ply) return ShowToAdminsOrSelf(ply) and ply:OOCMuted() == 1 end),

	Badge("betatest",   "Beta Tester", "icon16/controller.png"),
	Badge("bughunter",  "Bug Hunter",  "icon16/bug.png"),

	Badge("newbie",     "Inexperienced Roleplayer", "icon16/new.png", function(ply) return ply:GetSetting("Newbie") end)
}
