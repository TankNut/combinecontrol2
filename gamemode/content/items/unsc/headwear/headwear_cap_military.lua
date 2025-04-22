ITEM.Base = "base_unsc_headwear"

ITEM.Name        = "Patrol Cap"
ITEM.Description = "A standard UNSC Patrol cap"

ITEM.Tags        = RARITY_UNCOMMON

ITEM.Model       = Model("models/props_junk/cardboard_box004a.mdl")

ITEM.Weight      = 0.2

ITEM.Armor       = 0

ITEM.IconAngle   = Angle(80, 90, 0)
ITEM.IconFOV     = 12

ITEM.ModelGroups = {"Off-Duty", "Marine", "ODST", "Insurrection"}

if SERVER then
	local indices = {
		["Off-Duty"] = 4,
		["Marine"] = 2,
		["ODST"] = 1,
		["Insurrection"] = 1
	}

	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Bodygroups = {
					["Helmet&Hair"] = indices[self:GetModelGroup(ply)]
				}
			}
		}
	end
end
