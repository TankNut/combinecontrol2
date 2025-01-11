GM.EquipmentNames = {
	test = "Test Slot"
}

local function Lang(command, name, unknown, default)
	return {
		Command = command,
		Name = name,
		Unknown = unknown or name,
		Default = default
	}
end

GM.Languages = {
	Lang("eng", "English", nil, true),
	Lang("rus", "Russian")
}
