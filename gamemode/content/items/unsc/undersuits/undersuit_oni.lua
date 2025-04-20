ITEM.Base = "base_unsc_undersuit"

ITEM.Name         = "Off-Duty Uniform (ONI)"
ITEM.Description  = "An off-duty uniform belonging to the Office of Naval Intelligence."

ITEM.Rarity       = RARITY_UNCOMMON
ITEM.Tags         = {"ONI"}

ITEM.ModelPattern = "models/ishi/halo_rebirth/player/offduty/%s/offduty_%s.mdl"
ITEM.ModelGroup   = "Off-Duty"

if SERVER then
	function ITEM:GetModelData(ply)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Model = self:GetPlayerModel(ply),
				Skin = self.ModelSkin,
				Bodygroups = {
					Torso = 1,
					Legs = 1
				}
			}
		}
	end
end
