Action.Add("Voicelines", {
	Name = "Voicelines",
	Priority = 3,

	Target = ACTION_SELF,
	Context = "Self",

	CanRun = function(self, ply)
		return ply:CanPlayVoiceline()
	end,

	SubOptions = function(self)
		local options = {}
		local groups = {}

		for id, group in SortedPairsByMemberValue(Voicelines.Groups, "Name") do
			if not group.CanAccess(self) then
				continue
			end

			table.insert(groups, group)
		end

		local plural = #groups > 1

		for _, group in pairs(groups) do
			local baseName = plural and group.Name .. "\t" or ""

			for id, voiceline in pairs(group.Options) do
				table.insert(options, {
					Name = baseName .. voiceline.Name,
					Value = {
						Group = group.ID,
						Index = id
					}
				})
			end
		end

		return options
	end,

	Validate = function(self, ply, voiceline)
		return ply:CanPlayVoiceline(voiceline.Group)
	end,

	Callback = function(self, ply, voiceline)
		ply:PlayVoiceline(voiceline.Group, voiceline.Index)
	end
})


Action.Add("OpenStash", {
	Name = "Stash\tOpen",
	Priority = 2,

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
	Name = "Stash\tPlace Here",
	Priority = 1,

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

Action.Add("ArmorRepair", {
	Name = "Patch Armor",

	Target = ACTION_SELF,
	Context = "SelfContext",

	CanRun = function(self, ply)
		return self:Armor() < self:GetMaxArmor()
	end,

	Progress = function(self, ply)
		local missing = self:GetMaxArmor() - self:Armor()
		local time = math.Round(missing / 5, 2)

		return {
			Name = "Patching armor...",
			EndTime = CurTime() + time,
			Validate = {progress.Player(ply, {Alive = true})},
			Callback = function(fraction)
				if SERVER then
					self:SetArmor(self:Armor() + math.floor(fraction * missing))
				end
			end
		}
	end,

	Callback = function(target, ply)
	end
})
