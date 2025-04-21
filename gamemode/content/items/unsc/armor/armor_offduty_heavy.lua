ITEM.Base = "base_unsc_armor"

ITEM.Name        = "Armor Vest (Heavy)"
ITEM.Description = "A set of armor and other protective gear to be worn over plain clothes"

ITEM.Tags        = {"Marine"}

ITEM.ModelGroups = {"Off-Duty"}

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Bodygroups = {
					Combat_Vest = 1,
					Shoulder_Pads = 3,
					Legs = 2
				}
			}
		}
	end
end
