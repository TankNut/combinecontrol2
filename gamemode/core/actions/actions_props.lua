local validation = {
	validate.Max(255)
}

Action.Add("Describe", {
	Name = "Describe...",

	Target = ACTION_INTERACT,
	Filter = FILTER_PROPS,

	CanRun = function(self, ply)
		return not self:IsProtectedEntity()
	end,
	Validate = function(self, ply, desc)
		return validate.Value(desc, validation)
	end,
	Client = function(self)
		return true, ui.Open("Input", "string", "Change Prop Description", {
			Default = self:PropDescription(),
			Validate = validation,
			Name = "Prop descriptions"
		})
	end,
	Callback = function(self, ply, desc)
		self:SetPropDescription(desc)
	end
})
