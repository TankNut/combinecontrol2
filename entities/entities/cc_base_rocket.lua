AddCSLuaFile()
DEFINE_BASECLASS("cc_base_ent")

ENT.Base = "cc_base_ent"

ENT.Model = Model("models/weapons/w_missile_launch.mdl")

ENT.Velocity = 0
ENT.Gravity = 0

-- Trace masks
ENT.Mask = MASK_SOLID
ENT.CollisionGroup = COLLISION_GROUP_NONE

function ENT:Initialize()
	self:SetModel(self.Model)
	self:AddEffects(EF_NOSHADOW)

	if SERVER then
		self.LastMove = CurTime()
		self.Weapon = self:GetOwner():GetActiveWeapon()

		self:SetOrigin(self:GetPos())
		self:SetProjectileVelocity(self:GetForward() * self.Velocity)
		self:NextThink(CurTime())
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Vector", "Origin")
	self:NetworkVar("Vector", "Impact")

	self:NetworkVar("Vector", "ProjectileVelocity")
end

if SERVER then
	function ENT:UpdateVelocity(vel, delta)
		if self.Gravity != 0 then
			vel = vel + (physenv.GetGravity() * self.Gravity * delta)
		end

		return vel
	end

	function ENT:GetTraceFilter()
		return {self, self:GetOwner()}
	end

	function ENT:ProcessMovement()
		-- We've hit something and shouldn't be moving anymore
		if self:GetImpact() != vector_origin then
			return
		end

		local delta = CurTime() - self.LastMove

		self.LastMove = CurTime()

		local vel = self:UpdateVelocity(self:GetProjectileVelocity(), delta)

		if vel == true then
			return
		end

		if isvector(vel) then
			self:SetProjectileVelocity(vel)
		end

		local tr = util.TraceLine({
			start = self:GetPos(),
			endpos = self:GetPos() + vel * delta,
			filter = self:GetTraceFilter(),
			mask = self.Mask,
			collisiongroup = self.CollisionGroup,
		})

		self:SetPos(tr.HitPos)
		self:SetAngles(vel:Angle())

		if tr.Fraction != 1 then
			self:OnHit(tr)
		end
	end

	function ENT:Think()
		self:NextThink(CurTime())
		self:ProcessMovement()

		return true
	end

	function ENT:OnHit(tr)
		self:SetImpact(tr.HitPos)

		SafeRemoveEntityDelayed(self, 1)
	end
end
