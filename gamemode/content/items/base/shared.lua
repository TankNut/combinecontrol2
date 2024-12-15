ITEM.Name = "Unnamed item"
ITEM.Description = "Whoever made this item forgot to add a description!"

ITEM.Rarity = RARITY_COMMON

ITEM.Internal = true

ITEM.Model = Model("models/props_lab/cactus.mdl")
ITEM.Skin = 0

ITEM.Scale = 1

ITEM.Weight = 1
ITEM.WeightMultiplier = 0.2

ITEM.EquipmentSlots = {}
ITEM.Actions = {}

ITEM.Armor = 0

GM:Include("cl_ui.lua")

GM:Include("sh_actions.lua")
GM:Include("sh_data.lua")
GM:Include("sh_equipment.lua")
GM:Include("sh_helpers.lua")
GM:Include("sh_permissions.lua")

GM:Include("sv_database.lua")
GM:Include("sv_inventory.lua")

function ITEM:Initialize()
	self.EquipmentLookup = table.Lookup(self.EquipmentSlots)
end

function ITEM:SetItemAppearance(ent)
	ent:SetSkin(self:GetSkin())

	local scale = self:GetData("Scale", self.Scale)

	if scale != 1 then
		ent:SetModelScale(scale, 0.0001)
	end
end
