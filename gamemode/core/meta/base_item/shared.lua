ITEM = {}

local logger = log.Create("items")

-- Internal data
ITEM.Base                = nil
ITEM.Internal            = true

-- General info
ITEM.Name                = nil
ITEM.Description         = "Whoever made this item forgot to add a description!"

ITEM.Rarity              = RARITY_COMMON
ITEM.Category            = "Misc"
ITEM.Tags                = {}

ITEM.Unique              = false -- Don't collapse duplicate entries for item actions
ITEM.Customizable        = true -- Allow players with ItemCustomization access to edit this item

-- Appearance
ITEM.Model               = Model("models/props_lab/cactus.mdl")
ITEM.Skin                = 0

ITEM.Color               = color_white
ITEM.Scale               = 1

ITEM.Material            = ""

-- Inventory data
ITEM.Weight              = 1
ITEM.WeightMultiplier    = 0.2

-- Equipment data
ITEM.EquipmentSlots      = {}
ITEM.IgnoreModelOverride = false

ITEM.EquipTime           = 1
ITEM.UnequipTime         = 1

ITEM.Armor               = 0
ITEM.Buffs               = {}

-- Icon data
ITEM.IconAngle           = Angle()
ITEM.IconFOV             = 14

GM:Include("cl_networking.lua")
GM:Include("cl_ui.lua")

GM:Include("sh_actions.lua")
GM:Include("sh_appearance.lua")
GM:Include("sh_data.lua")
GM:Include("sh_equipment.lua")
GM:Include("sh_helpers.lua")
GM:Include("sh_inventory.lua")
GM:Include("sh_permissions.lua")
GM:Include("sh_triggers.lua")

GM:Include("sv_database.lua")
GM:Include("sv_networking.lua")

GM:Include("actions/actions_admin.lua")
GM:Include("actions/actions_base.lua")
GM:Include("actions/actions_customization.lua")
GM:Include("actions/actions_equipment.lua")
GM:Include("actions/actions_store.lua")

ItemDataFunc("Rarity")
ItemDataFunc("Category")

ItemDataFunc("EquipTime")
ItemDataFunc("UnequipTime")

if SERVER then
	ItemDataFunc("GetBuffs")
end

function ITEM:Initialize()
	self.EquipmentLookup = table.Lookup(self.EquipmentSlots)

	if CLIENT then
		self.Panels = {}
	end
end

function ITEM:Remove()
	logger:Debug("Remove: %s", self)

	self:OnRemove()

	Item.All[self.ID] = nil
end

function ITEM:IsType(name)
	return inherit.IsType(self, "item", name)
end

inherit.Register("item", "base", ITEM)

ITEM = nil
