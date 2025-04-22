ITEM.Base = "base_unsc_headwear"

ITEM.Name        = "CH252 Helmet"
ITEM.Description = "A UNSC standard issue combat helmet. Comes packaged with a balaclava and a set of ballistic goggles"

ITEM.Rarity      = RARITY_UNCOMMON
ITEM.Tags        = {"Marine"}

ITEM.ModelGroups = {"Marine"}

ITEM.HelmetIndex = 3

ITEM.Actions = {}

ItemCustomization(ITEM_ACTION_CUSTOMIZE + 2, "Toggle Helmet", "Helmet")

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 1, "Toggle Balaclava", "Balaclava")
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 2, "Toggle Goggles", "Goggles")

ITEM.Actions.CustomizeHelmet.Name = "Toggle Helmet"
ITEM.Actions.CustomizeHelmet.Context = table.Lookup({"EquipmentContext", "RightClick", "Examine"})

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Bodygroups = {
					["Helmet&Hair"] = self:GetHelmet() and 0 or self.HelmetIndex,
					Face = self:GetBalaclava() and 1 or 0,
					Helmet_Visor = self:GetGoggles() and 1 or 0
				}
			}
		}
	end
end
