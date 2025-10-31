AddCSLuaFile()

function SWEP:FireProjectile(owner)
	if CLIENT then
		return
	end

	local ent = ents.Create(self.Stats.Class)

	local spread = self:GetSpread()
	spread = AngleRand(-spread, spread)
	spread.r = 0

	ent:SetPos(owner:GetShootPos())
	ent:SetAngles(self:GetShootDir():Angle() + spread)

	ent:SetOwner(owner)
	ent:Spawn()
end
