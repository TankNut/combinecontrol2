ITEM.Name = "Unnamed item"

ITEM.Model = Model("models/props_lab/cactus.mdl")
ITEM.Skin = 0

ITEM.Scale = 1

ITEM.Weight = 1

GM:Include("sh_data.lua")

GM:Include("sv_database.lua")
GM:Include("sv_inventory.lua")

function ITEM:IsTemporaryItem()
	return self.ID < 0
end

function ITEM:SetItemAppearance(ent)
	ent:SetModel(self:GetModel())
	ent:SetSkin(self:GetSkin())

	local scale = self:GetData("Scale", self.Scale)

	if scale != 1 then
		ent:SetModelScale(scale, 0.0001)
	end
end

if SERVER then
	function ITEM:OnWorldUse(ply)
		local ok, err = hook.Run("CanTakeItem", ply, self)

		if not ok then
			ply:SendChat(nil, "ERROR", err)

			return
		end

		self:MoveTo(ply:GetInventory())
	end
end
