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
