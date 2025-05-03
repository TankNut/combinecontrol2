local BaseClass = inherit.Get("item", "base")

ITEM.Internal    = true

ITEM.Category    = "UNSC Clothing"

ITEM.Model       = Model("models/valk/h3/unsc/props/crates/case.mdl")

ITEM.IconAngle   = Angle(30, 0, 0)
ITEM.IconFOV     = 25

ITEM.ModelGroups = {}

function ITEM:IsCompatible(ply, group)
	return table.HasValue(self.ModelGroups, group or self:GetModelGroup(ply))
end

function ITEM:GetDescription()
	local description = BaseClass.GetDescription(self)

	if CLIENT and #self:GetEquipmentSlots() > 0 and not self:IsCompatible(lp) then
		description = description .. "\n\n<c=red>This isn't compatible with your current undersuit!</c>"
	end

	return description
end

function ITEM:GetModelGroup(ply)
	local undersuit = ply:GetEquipment("unsc_undersuit")

	return undersuit and undersuit.ModelGroup or "Off-Duty"
end

function ITEM:CanEquip(ply)
	return self:IsCompatible(ply)
end

function ITEM:CheckEquipmentSlot()
	local ply = self:GetPlayer()
	local group = self:GetModelGroup(ply)

	if not self:IsCompatible(ply, group) then
		self:SetEquipmentSlot(nil)

		return
	end

	BaseClass.CheckEquipmentSlot()
end
