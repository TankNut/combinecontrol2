local validateChangeName = {
	validate.Max(32)
}

local validateChangeDescription = {
	validate.Max(256)
}

ITEM.Actions.CustomizeName = {
	Name = "Customization/Change Name",
	Priority = 90,

	Context = table.Lookup({
		"Examine"
	}),

	CanRun = function(self, ply)
		return hook.Run("CanCustomizeItem", ply, self)
	end,

	Validate = function(self, ply, name)
		return validate.Value(name, validateChangeName)
	end,

	Client = function(self, ply)
		return true, GUI.Open("Input", "string", "Change Item Name", {
			Default = self:GetData("CustomName") or "",
			Validate = validateChangeName,
			Name = "Item name"
		})
	end,
	Callback = function(self, ply, name)
		Log.Write("item_set_name", ply, self, name)

		self:SetData("CustomName", #name > 0 and string.Escape(name) or nil)
	end
}

ITEM.Actions.CustomizeDescription = {
	Name = "Customization/Change Description",
	Priority = 80,

	Context = table.Lookup({
		"Examine"
	}),

	CanRun = function(self, ply)
		return hook.Run("CanCustomizeItem", ply, self)
	end,

	Validate = function(self, ply, name)
		return validate.Value(name, validateChangeDescription)
	end,

	Client = function(self, ply)
		return true, GUI.Open("Input", "multiline", "Change Item Description", {
			Default = self:GetData("CustomDescription") or "",
			Validate = validateChangeDescription,
			Name = "Item description"
		})
	end,
	Callback = function(self, ply, description)
		Log.Write("item_set_description", ply, self, description)

		self:SetData("CustomDescription", #description > 0 and description or nil)
	end
}
