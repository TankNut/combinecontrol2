local validation = {
	validate.Max(255)
}

Action.Add("Describe", {
	Name = "Describe...",

	Interaction = true,
	Filter = function(class) return tobool(PROP_CLASSES[class]) end,

	CanRun = function(self, ply)
		return not self:IsProtectedEntity()
	end,
	Validate = function(self, ply, desc)
		return validate.Value(desc, validation)
	end,
	Client = function(self)
		return true, GUI.Open("Input", "string", "Change Prop Description", {
			Default = self:PropDescription(),
			Validate = validation,
			Name = "Prop descriptions"
		})
	end,
	Callback = function(self, ply, desc)
		self:SetPropDescription(desc)
	end
})
