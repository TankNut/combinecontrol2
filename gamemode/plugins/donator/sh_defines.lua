Config.Register("DonatorLimits", {})

-- Permissions

Permissions.Add("donator_basic", {Description = "This person is a basic donator", Callback = function(ply) return ply:IsDonator() end})
Permissions.Add("donator_advanced", {Description = "This person is an advanced donator", Callback = function(ply) return ply:IsDonator(true) end})

-- Badges

BADGE_DONATOR = 80

Badge.Add("donator",    "Contributor",          BADGE_DONATOR, "icon16/medal_gold_1.png",      function(ply) return ply:DonationLevel() == DONATOR_BASIC and ply:GetSetting("ShowDonatorBadge") end)
Badge.Add("advdonator", "Advanced Contributor", BADGE_DONATOR, "icon16/award_star_gold_1.png", function(ply) return ply:DonationLevel() == DONATOR_ADVANCED and ply:GetSetting("ShowDonatorBadge") end)

-- Logs

Log.AddType("donator_set", function(ply, target, duration, advanced)
	local name = IsValid(ply) and ply:Nick() or "CONSOLE"

	target = Log.Player(target)

	if duration then -- Set
		return string.format("%s has given %s %s contributor status for %s", name, target.Player or target.SteamID, advanced and "advanced" or "basic", string.NiceTime(duration)), {
			Log.Admin(ply),
			target,
			Advanced = advanced,
			Duration = string.NiceTime(duration),
			Seconds = duration
		}
	else -- Clear
		return string.format("%s has taken %s's contributor status", name, target.Player or target.SteamID), {
			Log.Admin(ply),
			target
		}
	end
end)

Log.AddType("donator_expire", function(ply)
	return string.format("%s's donator status has expired", ply:Nick()), {
		Log.Player(ply)
	}
end)
