ITEM.Name = "Unnamed item"
ITEM.Description = "Whoever made this item forgot to add a description!"

ITEM.Model = Model("models/props_lab/cactus.mdl")
ITEM.Skin = 0

ITEM.Scale = 1

ITEM.Weight = 1

ITEM.Actions = {}

GM:Include("cl_ui.lua")

GM:Include("sh_actions.lua")
GM:Include("sh_equipment.lua")
GM:Include("sh_data.lua")

GM:Include("sv_database.lua")
GM:Include("sv_inventory.lua")

function ITEM:IsTemporaryItem()
	return self.ID < 0
end

function ITEM:IsOwner(ply)
	if CLIENT then
		return tobool(ply:GetItems()[self.ID])
	else
		return self.Inventory == ply:GetInventory()
	end
end

function ITEM:SetItemAppearance(ent)
	ent:SetSkin(self:GetSkin())

	local scale = self:GetData("Scale", self.Scale)

	if scale != 1 then
		ent:SetModelScale(scale, 0.0001)
	end
end
