AddCSLuaFile()

function SWEP:FireProjectile(owner)
	if CLIENT then
		return
	end

	local ent = ents.Create(self.Stats.Class)

	local spread = self:GetSpread()
	spread = AngleRand(-spread, spread)
	spread.r = 0

	local pos = self.Stats.Offset or vector_origin
	local ang = self.Stats.Angle or angle_zero

	pos, ang = LocalToWorld(pos, ang + spread, owner:GetShootPos(), self:GetShootDir():Angle())

	ent:SetPos(pos)
	ent:SetAngles(ang)

	ent:SetOwner(owner)
	ent:Spawn()
end
