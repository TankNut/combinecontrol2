local BaseClass = inherit.Get("item", "base")

ITEM.Internal       = true

ITEM.Rarity         = RARITY_COMMON
ITEM.Category       = "UNSC Undersuit"

ITEM.Model          = Model("models/valk/h4/unsc/props/sandbags/sandbags_single.mdl")

ITEM.Weight         = 3

ITEM.EquipmentSlots = {"unsc_undersuit"}

ITEM.IconAngle      = Angle(50, 90, 0)
ITEM.IconFOV        = 25

ITEM.EquipTime      = 3
ITEM.UnequipTime    = 3

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
	return string.match(ply:CharacterModel(), "^.+/[^_]+_g?_?(.+).mdl")
end

function ITEM:GetPlayerModel(ply)
	return string.format(self.ModelPattern, util.GetModelGender(ply:CharacterModel()), self:GetModelGroup(ply))
end

function ITEM:CanEquip(ply)
	return self:IsCompatible(ply)
end

function ITEM:OnEquipped(ply)
	for _, item in pairs(ply:GetEquipment()) do
		if item:IsType("base_unsc_clothing") and not item:IsCompatible(ply, self.ModelGroup) then
			item:SetEquipmentSlot(nil)
		end
	end

	BaseClass.OnEquipped(self, ply)
end

function ITEM:OnUnequipped(ply)
	for _, item in pairs(ply:GetEquipment()) do
		if item:IsType("base_unsc_clothing") and not item:IsCompatible(ply, "Off-Duty") then
			item:SetEquipmentSlot(nil)
		end
	end

	BaseClass.OnUnequipped(self, ply)
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
