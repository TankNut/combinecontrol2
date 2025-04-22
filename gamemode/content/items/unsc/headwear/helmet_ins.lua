ITEM.Base = "base_unsc_headwear"

ITEM.Name        = "CH252 Helmet (URF)"
ITEM.Description = "A UNSC standard issue combat helmet. Comes packaged with a balaclava and a set of ballistic goggles"

ITEM.Rarity      = RARITY_RARE
ITEM.Tags        = {"Insurrectionists"}

ITEM.ModelGroups = {"Insurrection"}

ITEM.HelmetIndex = 3

ITEM.Actions = {}

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 1, "Toggle Balaclava", "Balaclava")

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Bodygroups = {
					["Helmet&Hair"] = self.HelmetIndex,
					Face = self:GetBalaclava() and 1 or 0,
				}
			}
		}
	end
end
