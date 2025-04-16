Log.AddType("admin_item_create", function(ply, item)
	return string.format("%s has created a %s", Log.Nick(ply), item.ClassName), {
		Log.Admin(ply),
		Log.Item(item)
	}
end)

Log.AddType("admin_item_give", function(ply, item, target)
	return string.format("%s has given a %s to %s", Log.Nick(ply), item.ClassName, target:Nick()), {
		Log.Admin(ply),
		Log.Item(item),
		Log.Character(target)
	}
end)

Log.AddType("admin_restart", function(ply)
	return string.format("%s has restarted the server", Log.Nick(ply)), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_changelevel", function(ply, map)
	return string.format("%s has changed the server's map to %s", Log.Nick(ply), map), {
		Log.Admin(ply),
		From = game.GetMap(),
		To = map
	}
end)

Log.AddType("admin_variable_set", function(ply, variable, value)
	return string.format("%s has set the %s variable to %s", Log.Nick(ply), variable, value), {
		Log.Admin(ply),
		VariableName = variable,
		VariableValue = value
	}
end)

Log.AddType("admin_hideteam", function(ply, enum, hidden)
	return string.format("%s has %s the %s team from the scoreboard", Log.Nick(ply), hidden and "hidden" or "unhidden", Team.Get(enum).Name), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_yell", function(ply, message)
	return string.format("%s has broadcasted the following message: %s", Log.Nick(ply), message), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_stopsound", function(ply)
	return string.format("%s has stopped sounds for all players", Log.Nick(ply)), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_killambience", function(ply)
	return string.format("%s has stopped ambience for all players", Log.Nick(ply)), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_playmusic", function(ply, level, path, volume)
	return string.format("%s has played a %s music track '%s' at volume %s", Log.Nick(ply), level, path, volume), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_playeffect", function(ply, level, path, volume)
	return string.format("%s has played an %s effect '%s' at volume %s", Log.Nick(ply), level, path, volume), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_togglesaved", function(ply, model, saved)
	return string.format("%s has %s a %s", Log.Nick(ply), saved and "saved" or "unsaved", model), {
		Log.Admin(ply),
		Saved = saved and 1 or 0
	}
end)

Log.AddType("admin_teleport_goto", function(ply, target)
	return string.format("%s has teleported to %s", Log.Nick(ply), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_teleport_bring", function(ply, target)
	return string.format("%s has brought %s to themself", Log.Nick(ply), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_teleport_send", function(ply, from, to)
	return string.format("%s has sent %s to %s", Log.Nick(ply), from:Nick(), to:Nick()), {
		Log.Admin(ply),
		Log.Player(from),
		Log.Player(to)
	}
end)

Log.AddType("admin_character_set", function(ply, target, variable, value)
	return string.format("%s has updated %s's %s to %s", Log.Nick(ply), target:VisibleRPName(), variable, value), {
		Log.Admin(ply),
		Log.Character(target),
		VariableName = variable,
		VariableValue = value
	}
end)

Log.AddType("admin_character_givelang", function(ply, target, lang, speak)
	return string.format("%s gave %s the ability to %s %s", ply:Nick(), target:VisibleRPName(), speak and "speak" or "understand", lang), {
		Log.Admin(ply),
		Log.Character(target)
	}
end)

Log.AddType("admin_character_takelang", function(ply, target, lang, speak)
	return string.format("%s took %s's ability to %s %s", ply:Nick(), target:VisibleRPName(), speak and "speak" or "understand", lang), {
		Log.Admin(ply),
		Log.Character(target)
	}
end)

Log.AddType("admin_player_set", function(ply, target, variable, value)
	return string.format("%s has set %s's %s to %s", ply:Nick(), target:Nick(), variable, value), {
		Log.Admin(ply),
		Log.Player(target),
		VariableName = variable,
		VariableValue = value
	}
end)

Log.AddType("admin_player_heal", function(ply, target)
	return string.format("%s healed %s", ply:Nick(), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_player_kill", function(ply, target)
	return string.format("%s killed %s", ply:Nick(), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_player_slap", function(ply, target)
	return string.format("%s slapped %s", ply:Nick(), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)
