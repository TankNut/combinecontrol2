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

Log.AddType("superadmin_setusergroup", function(ply, target, usergroup)
	local name = IsValid(ply) and ply:Nick() or "CONSOLE"

	target = Log.Player(target)

	return string.format("%s has set %s's usergroup to %s", name, target.Player or target.SteamID, usergroup), {
		Log.Admin(ply),
		target,
		UserGroup = usergroup
	}
end)

Log.AddType("superadmin_player_set", function(ply, target, variable, value)
	local name = IsValid(ply) and ply:Nick() or "CONSOLE"

	return string.format("%s has set %s's %s to %s", name, target:Nick(), variable, value), {
		Log.Admin(ply),
		Log.Player(target),
		VariableName = variable,
		VariableValue = value
	}
end)
