local PLAYER = FindMetaTable("Player")

if CLIENT then
	netstream.Hook("AppearanceChanged", function(ply)
		hook.Run("AppearanceChanged", ply)
	end)
else
	function GM:GetBaseAppearance(ply)
		if not ply:HasCharacter() then
			return {
				_base = {
					Model = table.Random({"models/crow.mdl", "models/pigeon.mdl", "models/seagull.mdl"})
				}
			}, true
		end

		local override = ply:AppearanceOverride()

		if override then
			return override, true
		end

		return ply:RunCharFlag("GetModelData"), false
	end

	function PLAYER:UpdateAppearance()
		local appearance, hasOverride = hook.Run("GetBaseAppearance", self)

		if not hasOverride then
			local clothing = self:RunCharFlag("Clothing")
			local items = self:GetItems()

			for _, item in pairs(items) do
				if not item.GetModelData then
					continue
				end

				local data = item:GetModelData(self, clothing)

				if data then
					table.Merge(appearance, data)
				end
			end

			for _, item in pairs(items) do
				if not item.PostModelData then
					continue
				end

				item:PostModelData(self, appearance, clothing)
			end

			self:RunCharFlag("PostModelData", appearance)
		end

		assert(appearance._base, "UpdateAppearance somehow ended up without _base model data!")

		if not appearance._base.Color then
			appearance._base.Color = team.GetColor(self:Team())
		end

		self:ApplyModel(appearance._base)
		self:ClearAttachments()

		for k, data in pairs(appearance) do
			if k == "_base" then
				continue
			end

			local attachType = data.Attach or ATTACH_BONEMERGE

			if attachType == ATTACH_FOLLOW then
				self:AddAttachmentFollower(data, data.Attachment, data.Pos, data.Ang)
			elseif attachType == ATTACH_FOLLOW_BONE then
				self:AddBoneFollower(data, data.Bone, data.Pos, data.Ang)
			elseif attachType == ATTACH_BONEMERGE then
				self:AddBonemerge(data)
			end
		end

		self:SetupHands()
		self:UpdateHull()

		netstream.Broadcast("AppearanceChanged", self)
	end

	function GM:GetHandAppearance(ply)
		local base = ModelData.GetHands(ply:GetModel())

		if not ply:HasCharacter() or ply:AppearanceOverride() then
			return base, true
		end

		return ply:RunCharFlag("GetHandData", base), false
	end

	function GM:PlayerSetHandsModel(ply, ent)
		local hands, hasOverride = hook.Run("GetHandAppearance", ply)

		if not hasOverride then
			local clothing = ply:RunCharFlag("Clothing")
			local items = ply:GetItems()

			for _, item in pairs(items) do
				if not item.GetHandData then
					continue
				end

				local data = item:GetHandData(ply, clothing)

				if data then
					table.Merge(hands, data)
				end
			end

			for _, item in pairs(items) do
				if not item.PostHandData then
					continue
				end

				item:PostHandData(ply, hands, clothing)
			end

			ply:RunCharFlag("PostHandData", hands)
		end

		ent:ApplyModel(hands)
	end
end
