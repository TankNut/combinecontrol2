GM:RegisterLogType("character_loaded", LOG_CHARACTER, function(data)
	return string.format("%s loaded %s", GAMEMODE:FormatPlayer(data.Ply), GAMEMODE:FormatCharacter(data.Char))
end)

GM:RegisterLogType("character_setname", LOG_CHARACTER, function(data)
	return string.format("%s changed their name to %s", GAMEMODE:FormatCharacter(data.Char), data.Name)
end)

GM:RegisterLogType("character_setdesc", LOG_CHARACTER, function(data)
	return string.format("%s changed their description", GAMEMODE:FormatCharacter(data.Char))
end)

GM:RegisterLogType("character_givemoney", LOG_CHARACTER, function(data)
	return string.format("%s gave %s to %s", GAMEMODE:FormatCharacter(data.Char), util.FormatCurrency(data.Amount), GAMEMODE:FormatCharacter(data.TargetChar))
end)

GM:RegisterLogType("character_buy_license", LOG_CHARACTER, function(data)
	return string.format("%s bought a '%s' license", GAMEMODE:FormatCharacter(data.Char), data.License)
end)
