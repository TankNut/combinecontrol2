ITEM.Base = "helmet_marine"

ITEM.Name        = "CH252 Sharpshooter Helmet"
ITEM.Description = [[A UNSC standard issue combat helmet. Comes packaged with a balaclava and a set of ballistic goggles

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
					Helmet_Visor = self:GetGoggles() and 1 or 0,
					Helmet_Attatchment = 1
				}
			}
		}
	end
end
