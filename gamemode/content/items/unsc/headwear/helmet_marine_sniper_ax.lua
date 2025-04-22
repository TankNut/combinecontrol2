ITEM.Base = "helmet_marine_ax"

ITEM.Name        = "ECH252 Sharpshooter Helmet"
ITEM.Description = [[A variation of the standard CH252 combat helmet that can be fully enclosed and enviromentally sealed when combined with an A/X BDU. Comes packaged with a balaclava

Sharpshooter version: Equipped with an O/I optics device]]

ITEM.HelmetIndex = 3

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
					Helmet_Visor = self:GetHelmet() and 0 or (self:GetVisor() and 5 or 3),
					Helmet_Attatchment = 1
				}
			}
		}
	end
end
