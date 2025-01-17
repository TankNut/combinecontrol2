local meta = FindMetaTable("Player")

function GM:OnAppearanceChanged(ply, old, new, loaded)
	ply:UpdateHull()

	if CLIENT then
		part.Clear(ply)

		for name, data in pairs(new) do
			local partType = data._type or "ModelPart"; data._type = nil

			if partType == "ModelPart" and data.Bonemerge == nil then
				data.Bonemerge = true
			end

			part.Add(ply, partType, name, data)
		end

		return
	end

	if SERVER then
		ply:SetupHands()
		self:PlayerSetHandsModel(ply, ply:GetHands())
	end
end

if SERVER then
	function meta:UpdateAppearance()
		local appearance = {}

		if not self:HasCharacter() then
			appearance._base = {
				Model = table.Random({"models/crow.mdl", "models/pigeon.mdl", "models/seagull.mdl"})
			}
		else
			appearance = self:RunCharFlag("GetModelData")

			local items = self:GetItems()

			for _, item in pairs(items) do
				if not item.GetModelData then
					continue
				end

				local data = item:GetModelData(self)

				if data then
					table.Merge(appearance, data)
				end
			end

			self:RunCharFlag("PostModelData", appearance)

			for _, item in pairs(items) do
				if not item.PostModelData then
					continue
				end

				item:PostModelData(self, appearance)
			end
		end

		local base = assert(appearance._base, "UpdateAppearance somehow ended up without _base model data!")

		self:ApplyModel(base)

		appearance._base = nil

		self:SetAppearance(appearance)
	end
end
