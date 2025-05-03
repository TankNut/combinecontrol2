local scaleValidation = {
	validate.Min(0.1),
	validate.Max(1.2)
}

Action.Add("SetAIScale", {
	Name = "AI Options\tSet Scale",
	Priority = 5,

	Target = ACTION_SELF,
	Context = "SelfContext",
	CanRun = function(self)
		return self:Team() == TEAM_AI
	end,

	SubOptions = function(self)
		return {
			{Name = "0.2", Value = 0.2},
			{Name = "0.5", Value = 0.5},
			{Name = "0.8", Value = 0.8},
			{Name = "1", Value = 1},
			{Name = "1.2", Value = 1.2},
			{Name = "Custom", Value = nil}
		}
	end,
	Validate = function(self, ply, scale)
		return validate.Value(scale, scaleValidation)
	end,
	Client = function(self, _, scale)
		if scale then
			return true, scale
		else
			return true, GUI.Open("Input", "number", "Set Character Scale", {
				Default = self:Scale(),
				Validate = scaleValidation,
				Name = "Character scale"
			})
		end
	end,
	Callback = function(self, ply, scale)
		self:SetScale(scale)
	end
})
