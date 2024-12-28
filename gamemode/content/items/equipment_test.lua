ITEM.Model = Model("models/props_junk/cardboard_box004a.mdl")

ITEM.Weight = 1
ITEM.EquipmentSlots = {
	"test"
}

ITEM.Armor = 50

function ITEM:GetModelData(ply)
	if not self:IsEquipped() then
		return
	end

	return {
		head = {
			Model = Model("models/nova/w_headcrab.mdl")
		}
	}
end
