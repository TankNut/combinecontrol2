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
	return {DataType = "BLOB"}
end

if CLIENT then
	netstream.Hook("SelectWeapon", function(class)
		input.SelectWeapon(lp:GetWeapon(class))
	end)
end
