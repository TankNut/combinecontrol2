ITEM.Base = "base_unsc_armor"

ITEM.Name        = "Armor Vest (Light)"
ITEM.Description = "A set of armor to be worn over plain clothes"

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
					Combat_Vest = 1
				}
			}
		}
	end
end
