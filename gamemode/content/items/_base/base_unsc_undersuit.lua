local BaseClass = inherit.Get("item", "base")

ITEM.Internal       = true

ITEM.Rarity         = RARITY_COMMON
ITEM.Category       = "Undersuit"

ITEM.Model          = Model("models/valk/h3/unsc/props/crates/case.mdl")

ITEM.Weight         = 3

ITEM.IconAngle      = Angle(30, 0, 0)
ITEM.IconFOV        = 25

ITEM.EquipmentSlots = {
	"unsc_undersuit"
}

ITEM.ModelPattern   = ""
ITEM.ModelSkin      = 0
ITEM.ModelGroup     = ""

function ITEM:GetDescription()
	local description = BaseClass.GetDescription(self)

	if CLIENT and #self:GetEquipmentSlots() > 0 and not self:IsCompatible(lp) then
		description = description .. "\n\n<c=red>This undersuit isn't compatible with your model!</c>"
	end

	return description
end

function ITEM:IsCompatible(ply)
	return file.Exists(self:GetPlayerModel(ply), "GAME")
end

function ITEM:GetModelGroup(ply)
	return string.match(ply:CharacterModel(), "^.+/[^_]+_(.+).mdl")
end

function ITEM:GetPlayerModel(ply)
	return string.format(self.ModelPattern, util.GetModelGender(ply:CharacterModel()), self:GetModelGroup(ply))
end

-- Check whether all equipped items support this undersuit
function ITEM:CheckModelGroups(ply, group)
	for _, item in pairs(ply:GetEquipment()) do
		if not inherit.IsType(item, "item", "base_unsc_clothing") then
			continue
		end

		if not table.HasValue(item.ModelGroups, group) then
			return false
		end
	end

	return true
end

function ITEM:CanEquip(ply)
	return self:IsCompatible(ply) and self:CheckModelGroups(ply, self.ModelGroup)
end

function ITEM:CanUnequip(ply)
	return self:CheckModelGroups(ply, "Off-Duty")
end

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Model = self:GetPlayerModel(ply),
				Skin = self.ModelSkin
			}
		}
	end
end
