AddCSLuaFile()

ENT.Base = "cc_shield"

if CLIENT then
	function ENT:GetShieldColor()
		return Vector(0.2, 0.4, 0.85)
	end
end
