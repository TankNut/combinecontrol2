local BaseClass = inherit.Get("item", "base_container")

ITEM.Base           = "base_container"

ITEM.Name           = "Backpack (Light)"
ITEM.Description    = "A light assault pack for carrying combat gear"

ITEM.Rarity         = RARITY_UNCOMMON
ITEM.Category       = "UNSC Backpack"

ITEM.Model          = Model("models/valk/h3/unsc/props/crates/case.mdl")

ITEM.EquipmentSlots = {"unsc_back"}

ITEM.IconAngle      = Angle(30, 0, 0)
ITEM.IconFOV        = 25

ITEM.BaseWeight     = 1
ITEM.MaxWeight      = 10

ITEM.ModelGroups    = {"Off-Duty", "Marine", "ODST", "Insurrection"}

function ITEM:IsCompatible(ply, group)
	return table.HasValue(self.ModelGroups, group or self:GetModelGroup(ply))
end

function ITEM:GetDescription()
	local description = BaseClass.GetDescription(self)

	if CLIENT and #self:GetCompatibleSlots() > 0 and not self:IsCompatible(lp) then
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

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Bodygroups = {
					Backpacks = 1
				}
			}
		}
	end
end
