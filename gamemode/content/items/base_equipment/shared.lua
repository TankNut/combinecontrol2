DEFINE_BASECLASS("item_base")

ITEM.Internal = true

ITEM.EquipmentSlots = {}

ITEM.Armor = 0

GM:Include("sh_actions.lua")
GM:Include("sh_equipment.lua")
GM:Include("sh_permissions.lua")
GM:Include("sh_triggers.lua")

function ITEM:Initialize()
	BaseClass.Initialize(self)

	self.EquipmentLookup = table.Lookup(self.EquipmentSlots)
end

function ITEM:GetArmor()
	return self:IsEquipped() and self.Armor or 0
end

if CLIENT then
	local equip = Color(100, 160, 210, 25)

	function ITEM:GetHighlightColor()
		if self:IsEquipped() then
			return equip
		end

		return BaseClass.GetHighlightColor(self)
	end
end
