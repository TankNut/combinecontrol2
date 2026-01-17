Log.AddType("admin_item_create", function(ply, item)
	return string.format("%s has created a %s", Log.AdminName(ply), item.ClassName), {
		Log.Admin(ply),
		Log.Item(item)
	}
end)

Log.AddType("admin_item_give", function(ply, item, target)
	return string.format("%s has given a %s to %s", Log.AdminName(ply), item.ClassName, target:Nick()), {
		Log.Admin(ply),
		Log.Item(item),
		Log.Player(target)
	}
end)

Log.AddType("admin_item_take", function(ply, item, target, storeType)
	return string.format("%s has taken %s from %s's %s", Log.AdminName(ply), item, target:Nick(), storeType == INV_PLAYER and "inventory" or "stash"), {
		Log.Admin(ply),
		Log.Item(item),
		Log.Player(target)
	}
end)

Log.AddType("admin_item_destroy", function(ply, item, target, storeType)
	return string.format("%s has destroyed %s in %s's %s", Log.AdminName(ply), item, target:Nick(), storeType == INV_PLAYER and "inventory" or "stash"), {
		Log.Admin(ply),
		Log.Item(item),
		Log.Player(target)
	}
end)

Log.AddType("admin_restart", function(ply)
	return string.format("%s has restarted the server", Log.AdminName(ply)), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_changelevel", function(ply, map)
	return string.format("%s has changed the server's map to %s", Log.AdminName(ply), map), {
		Log.Admin(ply),
		From = game.GetMap(),
		To = map
	}
end)

Log.AddType("admin_variable_set", function(ply, variable, value)
	return string.format("%s has set the %s variable to %s", Log.AdminName(ply), variable, value), {
		Log.Admin(ply),
		VariableName = variable,
		VariableValue = value
	}
end)

Log.AddType("admin_hideteam", function(ply, enum, hidden)
	return string.format("%s has %s the %s team from the scoreboard", Log.AdminName(ply), hidden and "hidden" or "unhidden", Team.Get(enum).Name), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_yell", function(ply, message)
	return string.format("%s has broadcasted the following message: %s", Log.AdminName(ply), message), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_stopsound", function(ply)
	return string.format("%s has stopped sounds for all players", Log.AdminName(ply)), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_killambience", function(ply)
	return string.format("%s has stopped ambience for all players", Log.AdminName(ply)), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_playmusic", function(ply, level, path, volume)
	return string.format("%s has played a %s music track '%s' at volume %s", Log.AdminName(ply), level, path, volume), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_playeffect", function(ply, level, path, volume)
	return string.format("%s has played an %s effect '%s' at volume %s", Log.AdminName(ply), level, path, volume), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_togglesaved", function(ply, model, saved)
	return string.format("%s has %s a %s", Log.AdminName(ply), saved and "saved" or "unsaved", model), {
		Log.Admin(ply),
		Saved = saved
	}
end)

Log.AddType("admin_teleport_goto", function(ply, target)
	return string.format("%s has teleported to %s", Log.AdminName(ply), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_teleport_bring", function(ply, target)
	return string.format("%s has brought %s to themselves", Log.AdminName(ply), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_teleport_look", function(ply, target)
	return string.format("%s has sent %s to the point they're looking at", Log.AdminName(ply), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_teleport_send", function(ply, from, to)
	return string.format("%s has sent %s to %s", Log.AdminName(ply), from:Nick(), to:Nick()), {
		Log.Admin(ply),
		Log.Player(from),
		Log.Player(to)
	}
end)

local function addCharSetLog(var, key)
	key = key or var

	local format = "%s has set %s's " .. string.lower(var) .. " to %s"

	Log.AddType("admin_character_" .. string.lower(var), function(ply, target, val)
		return string.format(format, Log.AdminName(ply), target:VisibleRPName(), val), {
			Log.Admin(ply),
			Log.Player(target),
			[key] = val
		}
	end)
end

addCharSetLog("Model")
addCharSetLog("Skin")
addCharSetLog("Name")
addCharSetLog("Scale")
addCharSetLog("Hidden")
addCharSetLog("Flag")

Log.AddType("admin_character_model_override", function(ply, target, val)
	if val then
		return string.format("%s has set %s's model override to %s", Log.AdminName(ply), target:VisibleRPName(), val), {
			Log.Admin(ply),
			Log.Player(target),
			Model = val
		}
	else
		return string.format("%s has cleared %s's model override", Log.AdminName(ply), target:VisibleRPName()), {
			Log.Admin(ply),
			Log.Player(target)
		}
	end
end)

Log.AddType("admin_character_name_override", function(ply, target, val)
	if val then
		return string.format("%s has set %s's name override to %s", Log.AdminName(ply), target:VisibleRPName(), val), {
			Log.Admin(ply),
			Log.Player(target),
			Name = val
		}
	else
		return string.format("%s has cleared %s's name override", Log.AdminName(ply), target:VisibleRPName()), {
			Log.Admin(ply),
			Log.Player(target)
		}
	end
end)

local function addPlySetLog(var, key)
	key = key or var

	local format = "%s has set %s's " .. string.lower(var) .. " to %s"

	Log.AddType("admin_player_" .. string.lower(var), function(ply, target, val)
		return string.format(format, Log.AdminName(ply), target:Nick(), val), {
			Log.Admin(ply),
			Log.Player(target),
			[key] = val
		}
	end)
end

addPlySetLog("ToolTrust")
addPlySetLog("Health")
addPlySetLog("Armor")
addPlySetLog("Scale")

Log.AddType("admin_mute", function(ply, target, bool)
	return string.format("%s has %s %s from OOC", Log.AdminName(ply), bool and "muted" or "unmuted", target:Nick()), {
		Log.Admin(ply),
		Log.Player(target),
		Muted = bool
	}
end)

Log.AddType("admin_player_heal", function(ply, target)
	return string.format("%s has healed %s", Log.AdminName(ply), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_player_heal_all", function(ply, target)
	return string.format("%s has healed everyone", Log.AdminName(ply)), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_player_kill", function(ply, target)
	return string.format("%s killed %s", Log.AdminName(ply), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_player_slap", function(ply, target)
	return string.format("%s slapped %s", Log.AdminName(ply), target:Nick()), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_stash_clear", function(ply)
	return string.format("%s has cleared all stashes on the map", Log.AdminName(ply)), {
		Log.Admin(ply)
	}
end)

Log.AddType("admin_language_give", function(ply, target, lang, speak)
	return string.format("%s gave %s the ability to %s %s", Log.AdminName(ply), target:VisibleRPName(), speak and "speak" or "understand", lang), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_language_take", function(ply, target, lang, speak)
	return string.format("%s took %s's ability to %s %s", Log.AdminName(ply), target:VisibleRPName(), speak and "speak" or "understand", lang), {
		Log.Admin(ply),
		Log.Player(target)
	}
end)

Log.AddType("admin_permission_add", function(ply, target, permission)
	return string.format("%s has given %s to the %s permission", Log.AdminName(ply), target:Nick(), permission), {
		Log.Admin(ply),
		Log.Player(target),
		Permission = permission
	}
end)

Log.AddType("admin_permission_remove", function(ply, target, permission)
	return string.format("%s has taken the %s permission from %s", Log.AdminName(ply), permission, target:Nick()), {
		Log.Admin(ply),
		Log.Player(target),
		Permission = permission
	}
end)

Log.AddType("admin_character_create", function(ply, target, class)
	return string.format("%s has created an %s character for %s", Log.AdminName(ply), class, target:Nick()), {
		Log.Admin(ply),
		Log.Player(target),
		Type = class
	}
end)

Log.AddType("admin_character_create_event", function(ply, target, class)
	return string.format("%s has created an %s event character for %s", Log.AdminName(ply), class, target:Nick()), {
		Log.Admin(ply),
		Log.Player(target),
		Type = class
	}
end)

Log.AddType("admin_radio_jam", function(ply, action, subject)
	return string.format("%s has %s %s", Log.AdminName(ply), action, subject), {
		Log.Admin(ply)
	}
end)
