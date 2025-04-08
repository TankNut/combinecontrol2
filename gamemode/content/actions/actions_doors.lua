Action.Add("SetDoorType", {
	Name = "Set Door Type...",

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply)
		return self:IsDoor() and self:CreatedByMap()
	end,
	SubOptions = function(self)
		local tab = {}

		for _, index in ipairs(Doors.TypeList) do
			table.insert(tab, {
				Name = Doors.AccessTypes[index].Name,
				Value = index
			})
		end

		return tab
	end,
	Validate = function(self, ply, index)
		return validate.Value(index, validate.InLookup(Doors.AccessTypes))
	end,
	Callback = function(self, ply, value)
		self:SetDoorType(value)
	end
})
