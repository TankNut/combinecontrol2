Log.AddType("access_deny", function(nick, steamid, reason)
	return string.format("%s denied access: %s", nick, reason), {
		Player = nick,
		SteamID = steamid,
		Reason = reason
	}
end)

Log.AddType("access_kick", function(admin, ply, reason)
	return string.format("%s has kicked %s (%s)", IsValid(admin) and admin:Nick() or "CONSOLE", ply:Nick(), reason), {
		Log.Admin(admin),
		Log.Player(ply)
	}
end)

Log.AddType("access_ban", function(admin, nick, steamid, length, reason, offline)
	local format
	local args = {
		IsValid(admin) and admin:Nick() or "CONSOLE",
		nick or steamid
	}

	if length == 0 then
		format = "%s has permanently banned %s (%s)"
	else
		table.insert(args, string.NiceTime(length))

		format = "%s has banned %s for %s (%s)"
	end

	table.insert(args, reason)

	return string.format(format, unpack(args)), {
		Log.Admin(admin),
		Player = nick,
		SteamID = steamid,
		Offline = offline and 1 or 0,
		Permanent = length == 0 and 1 or 0
	}
end)

Log.AddType("access_unban", function(admin, steamid)
	return string.format("%s has unbanned %s", IsValid(admin) and admin:Nick() or "CONSOLE", steamid), {
		Log.Admin(admin),
		SteamID = steamid
	}
end)
