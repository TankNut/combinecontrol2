ITEM.Base = "base_unsc_headwear"

ITEM.Name        = "ODST Helmet"
ITEM.Description = "A standard ODST helmet meant to fulfill a variety of combat roles. Comes packaged with a balaclava"

ITEM.ModelGroups = {"ODST"}

ITEM.Armor = 20
-- ITEM.Buffs = {"buff_visr"}

ITEM.HelmetIndex = 2

ITEM.Actions = {}

ItemCustomization(ITEM_ACTION_CUSTOMIZE - 1, "Toggle Balaclava", "Balaclava")
ItemCustomization(ITEM_ACTION_CUSTOMIZE - 2, "Toggle Visor", "Visor")

ITEM.Actions.CustomizeVisor.Name = "Toggle Visor"
ITEM.Actions.CustomizeVisor.Priority = ITEM_ACTION_CUSTOMIZE + 2
ITEM.Actions.CustomizeVisor.Context = table.Lookup({"EquipmentContext", "RightClick", "Examine"})

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		local data = {
			_base = {
				Bodygroups = {
					["Helmet&Hair"] = self.HelmetIndex,
					Face = self:GetBalaclava() and 1 or 0
				}
			}
		}

		if self:GetVisor() then
			data._base.Materials = {
				["models/ishis_garage/halo_rebirth/marines/odst/odst_helmets_visor"] = "models/props_combine/citadel_cable_b"
			}
		end

		return data
	end
end
