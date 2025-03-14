AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.IsCCEntity = true

ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true

function ENT:PhysicsInitCustom(mins, maxs)
	self:EnableCustomCollisions(true)
	self.PhysCollide = CreatePhysCollideBox(mins, maxs)

	if SERVER then
		self:PhysicsInitBox(mins, maxs)
		self:SetSolid(SOLID_VPHYSICS)
	end
end

function ENT:TestCollision(start, delta, isbox, extends)
	if not IsValid(self.PhysCollide) then
		return
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), start, start + delta, min, max)

	if not hit then
		return
	end

	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac
	}
end

function ENT:OnRemove()
	local phys = self.PhysCollide

	timer.Simple(0, function()
		if not IsValid(self) then
			phys:Destroy()
		end
	end)
end
