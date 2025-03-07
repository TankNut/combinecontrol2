Log.AddType("security_denied_password", function(ply)
	return string.format("%s denied access: bad password", ply:Nick()), {
		Log.Player(ply)
	}
end)

Log.AddType("security_denied_banned", function(ply)
	return string.format("%s denied access: banned", ply:Nick()), {
		Log.Player(ply)
	}
end)

Log.AddType("security_kicked", function(admin, ply, reason)
	admin = Log.Admin(admin)
	ply = Log.Player(ply)

	return string.format("%s has kicked %s (%s)", admin.Admin, ply.Player, reason), {admin, ply}
end)

Log.AddType("security_banned", function(admin, ply, length, reason)
	admin = Log.Admin(admin)
	ply = Log.Player(ply)

	local format
	local args = {admin.Admin, ply.Player or ply.SteamID}

	if length == 0 then
		format = "%s has permanently banned %s (%s)"
	else
		table.insert(args, string.NiceTime(length))

		format = "%s has banned %s for %s (%s)"
	end

	table.insert(args, reason)

	return string.format(format, unpack(args)), {admin, ply}
end)
