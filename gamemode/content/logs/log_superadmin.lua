Log.AddType("superadmin_givetempadmin", function(ply, target)
	return string.format("%s has given %s temporary admin", IsValid(ply) and ply:Nick() or "CONSOLE", target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("superadmin_taketempadmin", function(ply, target)
	return string.format("%s has taken %s's temporary admin", IsValid(ply) and ply:Nick() or "CONSOLE", target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("superadmin_setusergroup", function(ply, target, usergroup)
	return string.format("%s has set %s's usergroup to %s", IsValid(ply) and ply:Nick() or "CONSOLE", target:Nick(), usergroup), {
		Log.Admin(ply),
		Log.Player(target),
		UserGroup = usergroup
	}
end)

Log.AddType("superadmin_player_set", function(ply, target, variable, value)
	return string.format("%s has set %s's %s to %s", ply:Nick(), target:Nick(), variable, value), {
		Log.Admin(ply),
		Log.Player(target),
		VariableName = variable,
		VariableValue = value
	}
end)
