Log.AddType("security_deny_password", function(nick, steamid)
	return string.format("%s denied access: bad password", nick), {
		Player = nick,
		SteamID = steamid
	}
end)

Log.AddType("security_deny_banned", function(nick, steamid)
	return string.format("%s denied access: banned", nick), {
		Player = nick,
		SteamID = steamid
	}
end)

Log.AddType("security_kick", function(admin, ply, reason)
	return string.format("%s has kicked %s (%s)", IsValid(admin) and admin:Nick() or "CONSOLE", ply:Nick(), reason), {
		Log.Admin(admin),
		Log.Player(ply)
	}
end)

Log.AddType("security_ban", function(admin, nick, steamid, length, reason, offline)
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
		Offline = offline and 1 or 0
	}
end)
