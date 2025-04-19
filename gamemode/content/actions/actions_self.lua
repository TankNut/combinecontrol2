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


Action.Add("OpenStash", {
	Name = "Stash/Open",
	Priority = 1,

	Target = ACTION_SELF,
	Context = "SelfContext",

	Callback = function(self)
		local ok, err = self:CanAccessStash()

		if not ok then
			self:SendChat("ERROR", err)

			return
		end

		self:OpenGUI("InventoryPopup", self:GetStash().ID)
	end
})

Action.Add("PlaceStash", {
	Name = "Stash/Place Here",

	Target = ACTION_SELF,
	Context = "SelfContext",

	Callback = function(self)
		local tr = self:GetEyeTrace()
		local pos = tr.HitPos

		if not tr.Hit or pos:Distance(self:EyePos()) > MAX_USE_DISTANCE then
			self:SendChat("ERROR", "Get a bit closer!")

			return
		end

		if self:HasStash() then
			local cooldown = string.NiceTime(Config.Get("StashCooldown"))

			self:SendChat("NOTICE", string.format("You've moved your stash, you'll be able to access it %s from now.", cooldown))
		else
			self:SendChat("NOTICE", "You've placed down your stash.")
		end

		Stash.Set(self, pos, Angle(0, math.Snap(self:EyeAngles().y, 5), 0))
	end
})
