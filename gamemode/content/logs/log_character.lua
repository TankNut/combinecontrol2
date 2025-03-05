Log.AddType("character_load", function(ply)
	return string.format("%s has swapped characters to %s", ply:Nick(), ply:VisibleRPName()), {
		Log.Character(ply)
	}
end)

Log.AddType("character_create", function(ply, charType)
	return string.format("%s has created a new %s character: %s", ply:Nick(), charType.Name, ply:VisibleRPName()), {
		Log.Character(ply),
		CharType = charType.ClassName
	}
end)

Log.AddType("character_generate", function(ply, generator)
	return string.format("%s has generated a %s%s character: %s", ply:Nick(), ply:IsTemporaryCharacter() and "temporary " or "", generator.Name, ply:VisibleRPName()), {
		Log.Character(ply),
		Generator = generator.ClassName
	}
end)

Log.AddType("character_delete", function(ply, id)
	return string.format("%s has deleted a %scharacter with ID: %s", ply:Nick(), id < 0 and "temporary " or "", id), {
		Log.Player(ply),
		CharID = id
	}
end)

Log.AddType("character_set_name", function(ply, new)
	return string.format("%s has changed their character name to %s", ply:VisibleRPName(), new), {
		Log.Character(ply)
	}
end)

Log.AddType("character_set_description", function(ply, new)
	-- Log values have a limit of 512 characters, we can't put actual descriptions in key values, not that we'd want to
	return string.format("%s has changed their character description to '%s'", ply:VisibleRPName(), new), {
		Log.Character(ply)
	}
end)
