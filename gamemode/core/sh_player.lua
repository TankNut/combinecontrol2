local meta = FindMetaTable("Player")

PlayerVar.Add("ScoreboardTitle", {Default = ""})
PlayerVar.Add("ScoreboardTitleC", {Default = Vector(255, 255, 255)})

PlayerVar.Add("ScoreboardBadges", {Default = 0})

PlayerVar.Add("DonatorActive", {Default = false})
PlayerVar.Add("Appearance", {Default = {}})

function meta:UpdateHull()
	local config = GAMEMODE.HullData
	local hull = config.Default

	for k, v in pairs(config) do
		if string.find(string.lower(self:GetModel()), k, 1, true) then
			hull = v

			break
		end
	end

	local scale = self:PlayerScale()

	self:SetModelScale(scale, 0.0001)

	timer.Simple(0, function()
		if not IsValid(self) then
			return
		end

		if hull.Standing then
			self:SetHull(hull.Standing[1], hull.Standing[2])
			self:SetHullDuck(hull.Crouching and hull.Crouching[1] or hull.Standing[1], hull.Crouching and hull.Crouching[2] or hull.Standing[2])

			self:SetViewOffset(hull.ViewOffset * scale)
			self:SetViewOffsetDucked((hull.DuckedViewOffset or hull.ViewOffset) * scale)
		else
			self:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72))
			self:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 36))

			self:SetViewOffset(Vector(0, 0, 64) * scale)
			self:SetViewOffsetDucked(Vector(0, 0, 28) * scale)
		end
	end)
end
