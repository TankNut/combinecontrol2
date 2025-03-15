AddCSLuaFile()
DEFINE_BASECLASS("cc_spawnpoint")

ENT.Base = "cc_spawnpoint"

ENT.PrintName = "Spawn Override"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Spawnpoints"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Mode = SPAWN_OVERRIDE

if CLIENT then
	function ENT:GetModelColor()
		if self:IsBlocked() then
			return self.BadColor
		end

		return color_white
	end

	function ENT:GetLabel()
		return "Override"
	end
end
