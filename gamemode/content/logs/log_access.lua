Log.AddType("access_deny", function(nick, steamID, reason)
	return string.format("%s denied access: %s", nick, reason), {
		Player = nick,
		SteamID = steamID,
		Reason = reason
	}
end)

Log.AddType("access_kick", function(admin, ply, reason)
	return string.format("%s has kicked %s (%s)", Log.AdminName(admin), ply:Nick(), reason), {
		Log.Admin(admin),
		Log.Player(ply)
	}
end)

Log.AddType("access_ban", function(admin, steamID, nick, length, reason)
	local format
	local args = {
		Log.AdminName(admin),
		nick
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
		SteamID = steamID,
		Permanent = length == 0
	}
end)

Log.AddType("access_unban", function(admin, steamID, nick)
	return string.format("%s has unbanned %s", Log.AdminName(admin), nick), {
		Log.Admin(admin),
		Player = nick,
		SteamID = steamID
	}
end)
