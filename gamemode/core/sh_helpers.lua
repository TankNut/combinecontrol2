function INT()
	return {
		DataType = "INT(11)",
		Validate = function(val) return isnumber(val) and val % 1 == 0 end
	}
end

function TINYINT()
	return {
		DataType = "TINYINT(4)",
		Validate = function(val) return isnumber(val) and val % 1 == 0 and val <= 255 end
	}
end

function UINT()
	return {
		DataType = "INT(11) UNSIGNED",
		Validate = function(val) return isnumber(val) and val % 1 == 0 and val > 0 end,
	}
end

function VARCHAR(length)
	return {
		DataType = string.format("VARCHAR(%s)", length),
		Validate = function(val) return isstring(val) and #val <= length end
	}
end

function TEXT()
	return {
		DataType = "TEXT",
		Validate = function(val) return isstring(val) and #val <= 65535 end
	}
end

function BLOB()
	return {
		DataType = "BLOB",
		Encode = function(val) return sfs.encode(val) end,
		Decode = function(val) return sfs.decode(val) end,
	}
end

function FLOAT()
	return {
		DataType = "FLOAT",
		Validate = function(val) return isnumber(val) end
	}
end

function EquipmentSlot(slot)
	return GAMEMODE.EquipmentNames[slot]
end

local elevated = table.Lookup({
	"superadmin", "developer"
})

function IsElevatedUserGroup(usergroup)
	return tobool(elevated[usergroup])
end

ContentFolder = engine.ActiveGamemode() .. "/gamemode/content/"
DataFolder = "cc2/" .. Config.Get("InternalName") .. "/"

function FILTER_PROPS(class) return tobool(PROP_CLASSES[class]) end
function FILTER_PLAYER(class) return class == "player" end
