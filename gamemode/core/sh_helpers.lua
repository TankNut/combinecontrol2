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

function TIMESTAMP()
	return {
		DataType = "TIMESTAMP",
		Validate = function(val) return isnumber(val) and val > 0 end,
		Encode = function(val) return os.date("%Y-%m-%d %H:%M:%S", val) end,
		Decode = function(val)
			local parts = string.Explode("[-: ]", val, true)

			return os.time({
				year = parts[1],
				month = parts[2],
				day = parts[3],
				hour = parts[4],
				min = parts[5],
				sec = parts[6]
			})
		end,
	}
end

function EquipmentSlot(slot)
	return GAMEMODE.EquipmentNames[slot]
end

ContentFolder = engine.ActiveGamemode() .. "/gamemode/content/"
DataFolder = "combinecontrol/" .. Config.Get("InternalName") .. "/"
