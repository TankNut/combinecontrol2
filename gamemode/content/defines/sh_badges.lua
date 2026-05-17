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

Badge.Add("misc_event",      "Event Character",          21,   "icon16/vcard.png",         function(ply) return ply:IsEventCharacter() end)
