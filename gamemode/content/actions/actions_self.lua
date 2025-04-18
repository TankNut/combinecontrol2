Action.Add("Voicelines", {
	Name = "Voicelines",
	Priority = 2,

	Target = ACTION_SELF,
	Context = "Self",

	CanRun = function(self)
		return self:CanPlayVoicelines()
	end,

	SubOptions = function(self)
		local options = {}
		local categories = {}

		for id, category in SortedPairsByMemberValue(Voicelines.Categories, "Name") do
			if not category.CanAccess(self) then
				continue
			end

			table.insert(categories, category)
		end

		local plural = #categories > 1

		for _, category in pairs(categories) do
			local baseName = plural and category.Name .. "/" or ""

			for id, voiceline in pairs(category.Options) do
				table.insert(options, {
					Name = baseName .. voiceline.Text,
					Value = {
						Category = category.ID,
						Index = id
					}
				})
			end
		end

		return options
	end,

	Validate = function(self, ply, voiceline)
		return ply:CanPlayVoicelines(voiceline.Category)
	end,

	Callback = function(self, ply, voiceline)
		ply:PlayVoiceline(voiceline.Category, voiceline.Index)
	end
})
