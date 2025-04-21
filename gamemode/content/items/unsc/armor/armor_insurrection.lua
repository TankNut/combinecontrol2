ITEM.Base = "base_unsc_armor"

ITEM.Name        = "Insurrectionist Armor"
ITEM.Description = "A set of UNSC combat gear that's been modified by the URF."

ITEM.Tags        = {"Insurrectionists"}

ITEM.ModelGroups = {"Insurrection"}

ITEM.Actions = {}

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 1, "Set Collar Style", "Collar", {
	{Name = "Normal", Value = 0},
	{Name = "Shawl", Value = 1},
	{Name = "Open Shawl", Value = 2},
	{Name = "A/X Shawl", Value = 3},
	{Name = "Assault Armor", Value = 4},
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 2, "Set Cuff Style", "Cuffs", {
	{Name = "Normal", Value = 0},
	{Name = "Combat", Value = 1},
	{Name = "Recon", Value = 2}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 3, "Set Shoulder Pads", "ShoulderPads", {
	{Name = "None", Value = 0},
	{Name = "Armored", Value = 1},
	{Name = "Heavy", Value = 2},
	{Name = "Recon", Value = 3},
	{Name = "A/X Security", Value = 4},
	{Name = "ODST", Value = 5},
	{Name = "Assault", Value = 6}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 4, "Set Chest Packs", "ChestPacks", {
	{Name = "None", Value = 0},
	{Name = "Gunner", Value = 1},
	{Name = "Infantry", Value = 2},
	{Name = "Grenadier", Value = 3}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 5, "Set Thigh Pads", "ThighPads", {
	{Name = "None", Value = 0},
	{Name = "Armored", Value = 1},
	{Name = "Utility Pouch", Value = 2}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 6, "Set Legs", "Legs", {
	{Name = "Kneepads", Value = 0},
	{Name = "Combat", Value = 1},
	{Name = "UA%Combat", Value = 3}
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
