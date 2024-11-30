local meta = FindMetaTable("Player")

function GM:PlayerAppearanceChanged(ply, old, new, loaded)
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
		local appearance = self:RunCharFlag("GetModelData")

		-- Item GetModelData

		self:RunCharFlag("PostModelData", appearance)

		-- Item PostModelData

		local base = assert(appearance._base, "UpdateAppearance somehow ended up without _base model data!")

		self:ApplyModel(base)

		appearance._base = nil

		self:SetAppearance(appearance)
	end
end
