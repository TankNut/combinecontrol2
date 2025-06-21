PlayerVar.Add("Appearance", {Default = {}})

local PLAYER = FindMetaTable("Player")

function GM:OnAppearanceChanged(ply, old, new, loaded)
	ply:UpdateHull()

	if CLIENT then
		local outfit = {}

		for name, data in pairs(new) do
			if name == "_base" then
				continue
			end

			if data.Bonemerge == nil then
				data.Bonemerge = true
			end

			outfit[name] = data
		end

		part.Add(ply, "appearance", outfit)
	else
		ply:ApplyModel(new._base)

		ply:SetupHands()
		self:PlayerSetHandsModel(ply, ply:GetHands())

		if ply:IsRagdolled() then
			ply:GetRagdoll():SetFakeAppearance(new)
		end
	end
end

if SERVER then
	function GM:GetBaseAppearance(ply)
		if not ply:HasCharacter() then
			return {
				_base = {
					Model = table.Random({"models/crow.mdl", "models/pigeon.mdl", "models/seagull.mdl"})
				}
			}, false
		end

		local override = ply:CharacterModelOverride()

		if #override > 0 then
			return {
				_base = {
					Model = override,
					Skin = ply:CharacterSkin()
				}
			}, true
		end

		return ply:RunCharFlag("GetModelData"), false
	end

	function PLAYER:UpdateAppearance()
		local appearance, hasOverride = hook.Run("GetBaseAppearance", self)

		if self:HasCharacter() then
			local clothing = self:RunCharFlag("Clothing")
			local items = self:GetItems()

			for _, item in pairs(items) do
				if not item.GetModelData or (hasOverride and not item.IgnoreModelOverride) then
					continue
				end

				local data = item:GetModelData(self, clothing)

				if data then
					table.Merge(appearance, data)
				end
			end

			for _, item in pairs(items) do
				if not item.PostModelData or (hasOverride and not item.IgnoreModelOverride) then
					continue
				end

				item:PostModelData(self, appearance, clothing)
			end

			if not hasOverride then
				self:RunCharFlag("PostModelData", appearance)
			end
		end

		assert(appearance._base, "UpdateAppearance somehow ended up without _base model data!")

		if not appearance._base.Color then
			appearance._base.Color = team.GetColor(self:Team())
		end

		self:SetAppearance(appearance)
	end
end
