Log.AddType("superadmin_tempadmin", function(ply, target, bool)
	local name = IsValid(ply) and ply:Nick() or "CONSOLE"
	local str

	if bool then
		str = string.format("%s has given temporary admin to %s", name, target:Nick())
	else
		str = string.format("%s has taken temporary admin from %s", name, target:Nick())
	end

	return str, {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("superadmin_usergroup", function(ply, steamID, nick, usergroup)
	return string.format("%s has set %s's usergroup to %s", Log.AdminName(ply), nick, usergroup), {
		Log.Admin(ply),
		SteamID = steamID,
		Player = nick,
		UserGroup = usergroup
	}
end)

Log.AddType("superadmin_nodamage", function(ply, target, bool)
	if bool then
		return string.format("%s has enabled nodamage for %s", Log.AdminName(ply), target:Nick()), {
			Log.Admin(ply),
			Log.Player(target)
		}
	else
		return string.format("%s has disabled nodamage for %s", Log.AdminName(ply), target:Nick()), {
			Log.Admin(ply),
			Log.Player(target)
		}
	end
end)
