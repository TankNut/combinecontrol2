ITEM.Name = "Unnamed item"
ITEM.Description = "Whoever made this item forgot to add a description!"

ITEM.Rarity = RARITY_COMMON

ITEM.Internal = true

ITEM.Model = Model("models/props_lab/cactus.mdl")
ITEM.Skin = 0

ITEM.Scale = 1

ITEM.Weight = 1

ITEM.EquipmentSlots = {}

ITEM.Armor = 0

GM:Include("cl_networking.lua")
GM:Include("cl_ui.lua")

GM:Include("sh_actions.lua")
GM:Include("sh_data.lua")
GM:Include("sh_equipment.lua")
GM:Include("sh_helpers.lua")
GM:Include("sh_inventory.lua")
GM:Include("sh_permissions.lua")
GM:Include("sh_triggers.lua")

GM:Include("sv_database.lua")
GM:Include("sv_networking.lua")

GM:Include("actions/actions_base.lua")
GM:Include("actions/actions_equipment.lua")

function ITEM:Initialize()
	self.EquipmentLookup = table.Lookup(self.EquipmentSlots)

	if CLIENT then
		self.Panels = {}
	end
end

function ITEM:Remove()
	self:OnRemove()

	Item.All[self.ID] = nil
end
