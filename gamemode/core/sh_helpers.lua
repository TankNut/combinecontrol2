function BOOL()
	return {
		DataType = "TINYINT(1)",
		Validate = function(val) return isbool(val) end,
		Encode = function(val) return val and 1 or 0 end,
		Decode = function(val) return tobool(val) end
	}
end

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
	return GAMEMODE.EquipmentNames[slot] or slot
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

function ItemDataFunc(key, default)
	if default then
		ITEM[key] = default
	end

	ITEM["Get" .. key] = function(self)
		return self:GetData(key, self[key])
	end
end

function ItemCustomization(priority, name, var, options)
	local action = {
		Name = "Customize\t" .. name,
		Priority = priority,

		Context = table.Lookup({"RightClick", "Examine"}),
		CanRun = function(self, ply) return self:IsEquipped() and self:CanInteract(ply) end,
	}

	if options then
		ItemDataFunc(var, options[1].Value)

		action.SubOptions = options

		local validation = {validate.InList(table.Map(options, function(val) return val.Value end))}

		action.Validate = function(self, ply, index)
			return validate.Value(index, validation)
		end

		action.Callback = function(self, ply, index)
			self:SetData(var, index)
			ply:UpdateAppearance()
		end
	else
		ItemDataFunc(var, false)

		action.Callback = function(self, ply)
			self:SetData(var, not self["Get" .. var](self))
			ply:UpdateAppearance()
		end
	end

	ITEM.Actions["Customize" .. var] = action
end
