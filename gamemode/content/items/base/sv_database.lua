function ITEM:SaveData()
	if self:IsTemporaryItem() then
		return
	end

	local query = GAMEMODE.Database:Update("rp_items")
		query:Update("CustomData", sfs.encode(self.Data))
		query:WhereEqual("id", self.ID)
	query:Execute()
end

function ITEM:SaveLocation()
	if self:IsTemporaryItem() then
		return
	end

	local ent = self.Entity
	local inventory = self.Inventory

	if IsValid(ent) then
		local query = GAMEMODE.Database:Update("rp_items")

		query:Update("StoreType", INV_WORLD)
		query:Update("StoreID", game.GetMap())

		query:Update("MapData", sfs.encode({
			Pos = ent:GetPos(),
			Ang = ent:GetAngles(),
			Frozen = not ent:GetPhysicsObject():IsMotionEnabled()
		}))

		query:Execute()
	elseif inventory then
		local query = GAMEMODE.Database:Update("rp_items")

		query:Update("StoreType", inventory.StoreType)
		query:Update("StoreID", inventory.StoreID)
		query:UpdateRaw("MapData", "NULL")

		query:Execute()
	end
end

function ITEM:Delete()
	Item.Delete(self.ID)
end
