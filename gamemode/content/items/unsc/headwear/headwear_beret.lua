ITEM.Base = "base_unsc_headwear"

ITEM.Name        = "Beret"
ITEM.Description = "A plain beret"

ITEM.Model       = Model("models/props_junk/cardboard_box004a.mdl")

ITEM.Weight      = 0.2

ITEM.Armor       = 0

ITEM.IconAngle   = Angle(80, 90, 0)
ITEM.IconFOV     = 12

ITEM.ModelGroups = {"Off-Duty", "Marine", "Insurrection"}

if SERVER then
	local indices = {
		["Off-Duty"] = 3,
		["Marine"] = 1,
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
