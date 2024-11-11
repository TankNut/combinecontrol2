function VARCHAR(length)
	return {
		DataType = string.format("VARCHAR(%s)", length),
		Validate = function(val) return isstring(val) and utf8.len(val) <= length end
	}
end

function INT()
	return {
		DataType = "INT",
		Validate = function(val) return isnumber(val) and val % 1 == 0 end
	}
end

function BLOB()
	return {DataType = "BLOB"}
end
