ITEM.Category       = "Grunt Armor"

ITEM.Model          = Model("models/props_junk/cardboard_box001a.mdl")

ITEM.EquipmentSlots = {"grunt"}

ItemDataFunc("IsHonorGuard", false)

ItemDataFunc("PlayerColor")

ItemDataFunc("GruntSkin", 2)
ItemDataFunc("GruntBackpack", 1)
ItemDataFunc("GruntHelmet", 0)

if SERVER then
	function ITEM:GetModelData(ply, clothing)
		if not self:IsEquipped() then
			return
		end

		return {
			_base = {
				Skin = self:GetGruntSkin(),
				Color = self:GetPlayerColor(),
				Bodygroups = {
					Backpack = self:GetGruntBackpack(),
					BackPack = self:GetGruntBackpack(),
					Helmet = self:GetGruntHelmet()
				}
			}
		}
	end
end
