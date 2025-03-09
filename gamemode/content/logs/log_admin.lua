Log.AddType("admin_item_create", function(ply, item)
	return string.format("%s has created a %s", ply:Nick(), item.ClassName), {
		Log.Admin(ply),
		Log.Item(item)
	}
end)

Log.AddType("admin_item_give", function(ply, item, target)
	return string.format("%s has given a %s to %s", ply:Nick(), item.ClassName, target:Nick()), {
		Log.Admin(ply),
		Log.Item(item),
		Log.Character(target)
	}
end)

Log.AddType("admin_misc_restart", function(ply)
	return string.format("%s has restarted the server", ply:Nick()), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_misc_changelevel", function(ply, map)
	return string.format("%s has changed the server's map to %s", ply:Nick(), map), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_misc_setvariable", function(ply, variable, value)
	return string.format("%s has set the %s variable to %s", ply:Nick(), variable, value), {
		Log.Admin(ply),
		VariableName = variable,
		VariableValue = value
	}
end)

Log.AddType("admin_misc_yell", function(ply, message)
	return string.format("%s has broadcasted the following message: %s", ply:Nick(), message), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_misc_stopsound", function(ply)
	return string.format("%s has stopped sounds for all players", ply:Nick()), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_misc_togglesaved", function(ply, model, saved)
	return string.format("%s has %s a %s", ply:Nick(), saved and "saved" or "unsaved", model), {
		Log.Admin(ply),
		Saved = saved and 1 or 0
	}
end)
