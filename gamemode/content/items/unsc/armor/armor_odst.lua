ITEM.Base = "base_unsc_armor"

ITEM.Name        = "ODST Armor"
ITEM.Description = [[A customizable set of ODST combat gear

Atmospheric/Exoatmospheric: Sealed against environmental hazards and rated for use during extra-vehicular activity]]

ITEM.Rarity      = RARITY_RARE
ITEM.Tags        = {"ODST"}

ITEM.ModelGroups = {"ODST"}

ITEM.Actions = {}

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 1, "Toggle Cuffs", "Cuffs")

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 2, "Set Chest Packs", "ChestPacks", {
	{Name = "None", Value = 0},
	{Name = "Gunner", Value = 1},
	{Name = "Assault", Value = 2},
	{Name = "Grenadier", Value = 3},
	{Name = "Infantry", Value = 4}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 3, "Set Thigh Pads", "ThighPads", {
	{Name = "None", Value = 0},
	{Name = "Armored", Value = 1},
	{Name = "Utility Pouch", Value = 2}
})

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 4, "Set Legs", "Legs", {
	{Name = "Medium", Value = 0},
	{Name = "Heavy", Value = 1},
	{Name = "Security", Value = 2}
})

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Bodygroups = {
					Collar = 2,
					Cuffs = self:GetCuffs() and 1 or 0,
					Chestplate = 1,
					Shoulderpads = 5,
					Chest_Packs = self:GetChestPacks(),
					Thighpads = self:GetThighPads(),
					Legs = self:GetLegs()
				}
			}
		}
	end
end
