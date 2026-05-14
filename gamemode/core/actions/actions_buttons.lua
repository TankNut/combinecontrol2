local validation = {
	validate.Max(32)
}

Action.Add("SetButtonName", {
	Name = "Set Button Name...",

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply)
		return self:IsMapButton()
	end,
	Validate = function(self, ply, name)
		return validate.Value(name, validation)
	end,
	Client = function(self)
		return true, ui.Open("Input", "string", "Change Button Name", {
			Default = self:ButtonName(),
			Validate = validation,
			Name = "Button names"
		})
	end,
	Callback = function(self, ply, name)
		self:SetButtonName(name)
	end
})

Action.Add("SetButtonType", {
	Name = "Set Button Type...",

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply)
		return self:IsMapButton()
	end,
	SubOptions = function(self)
		local tab = {}

		for _, index in ipairs(Buttons.TypeList) do
			table.insert(tab, {
				Name = Buttons.AccessTypes[index].Name,
				Value = index
			})
		end

		return tab
	end,
	Validate = function(self, ply, index)
		return validate.Value(index, validate.InLookup(Buttons.AccessTypes))
	end,
	Callback = function(self, ply, value)
		self:SetButtonType(value)
	end
})
