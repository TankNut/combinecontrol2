ITEM.Base = "base_unsc_armor"

ITEM.Name        = "Marine Armor"
ITEM.Description = "A customizable set of UNSC combat gear"

ITEM.Tags        = {"Marine"}

ITEM.ModelGroups = {"Marine"}

ITEM.Actions = {}

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 1, "Set Collar Style", "Collar", {
	{Name = "Normal", Value = 0},
	{Name = "Hoodie", Value = 1},
	{Name = "A%X", Value = 2}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 2, "Set Shoulder Pads", "ShoulderPads", {
	{Name = "None", Value = 0},
	{Name = "Light", Value = 1},
	{Name = "Armored", Value = 2},
	{Name = "Heavy", Value = 3},
	{Name = "Recon", Value = 4},
	{Name = "A%X Security", Value = 5}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 3, "Set Chest Packs", "ChestPacks", {
	{Name = "None", Value = 0},
	{Name = "Gunner", Value = 1},
	{Name = "Infantry", Value = 2},
	{Name = "Assault", Value = 3}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 4, "Set Thigh Pads", "ThighPads", {
	{Name = "None", Value = 0},
	{Name = "Armored", Value = 1},
	{Name = "Utility Pouch", Value = 2}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 5, "Set Legs", "Legs", {
	{Name = "None", Value = 0},
	{Name = "Kneepads", Value = 1},
	{Name = "Combat", Value = 2},
	{Name = "Recon", Value = 3}
})

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Bodygroups = {
					Collar = self:GetCollar(),
					Shoulderpads = self:GetShoulderPads(),
					Chest_Packs = self:GetChestPacks(),
					Thighpads = self:GetThighPads(),
					Legs = self:GetLegs()
				}
			}
		}
	end
end
