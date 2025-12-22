AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base")

SWEP.Base = "weapon_cc_base"

SWEP.Slot = 2
SWEP.SlotPos = 20

SWEP.Settings = {
	LowerHoldType = "normal",
	BaseHoldType = "grenade",
	IdleHoldType = "slam",

	CanRoll = true,

	UseHolsterAnimations = true,
	ReverseHolsterAnimations = true
}

SWEP.Animations = {
	Holster = ACT_VM_DRAW,

	PullbackHigh = ACT_VM_PULLBACK_HIGH,
	PullbackLow = ACT_VM_PULLBACK_LOW,

	Throw = ACT_VM_THROW,
	Lob = ACT_VM_HAULBACK,
	Roll = ACT_VM_SECONDARYATTACK
}

SWEP.THROW = 1
SWEP.LOB   = 2
SWEP.ROLL  = 3

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Int", "ThrowMode")
	self:NetworkVar("Float", "FinishThrow")
	self:NetworkVar("Float", "FinishReload")
end

function SWEP:PrimaryAttack()
	if not self:CanThrow() then
		return
	end

	self:SetThrowMode(self.THROW)
	self:SetFinishThrow(CurTime() + self:PlayAnimation("PullbackHigh"))

	self:SetNextIdle(0)
end

function SWEP:SecondaryAttack()
	if not self:CanThrow() then
		return
	end

	self:SetThrowMode(self.LOB)
	self:SetFinishThrow(CurTime() + self:PlayAnimation("PullbackLow"))

	self:SetNextIdle(0)
end

function SWEP:IsReloading()
	return self:GetFinishReload() != 0
end

function SWEP:IsThrowing()
	return self:GetFinishThrow() != 0
end

function SWEP:CanThrow()
	if self:GetHolstered() then
		return false
	end

	if self:IsReloading() or self:IsThrowing() then
		return false
	end

	return true
end

function SWEP:Think()
	BaseClass.Think(self)

	if self:IsThrowing() and self:GetFinishThrow() <= CurTime() then
		self:Throw()
	elseif self:IsReloading() and self:GetFinishReload() <= CurTime() then
		self:FinishReload()
	end
end

function SWEP:Throw()
	local ply = self:GetOwner()
	local mode = self:GetThrowMode()
	local key = mode == self.THROW and IN_ATTACK or IN_ATTACK2

	if ply:KeyDown(key) then
		return
	end

	ply:SetAnimation(PLAYER_ATTACK1)

	self:EmitSound("WeaponFrag.Throw")

	self:SetThrowMode(0)
	self:SetFinishThrow(0)

	if mode == self.LOB and ply:Crouching() and self.Settings.CanRoll then
		mode = self.ROLL
	end

	if SERVER then
		self:ThrowEntity(mode)
	end

	local animation

	if mode == self.THROW then
		animation = "Throw"
	elseif mode == self.LOB then
		animation = "Lob"
	elseif mode == self.ROLL then
		animation = "Roll"
	end

	self:SetFinishReload(CurTime() + self:PlayAnimation(animation))
end

function SWEP:FinishReload()
	self:SetFinishReload(0)

	local time = CurTime() + self:PlayAnimation("Deploy")

	self:SetNextPrimaryFire(time)
	self:SetNextSecondaryFire(time)
end

function SWEP:GetIdleHoldType()
	return self.Settings.IdleHoldType
end

function SWEP:UpdateHoldType()
	local old = self:GetHoldType()
	local holdType = self:GetBaseHoldType()

	if self:GetHolstered() then
		holdType = self:GetLoweredHoldType()
	elseif not self:IsThrowing() and not self:IsReloading() then
		holdType = self:GetIdleHoldType()
	end

	if holdType != old then
		self:SetHoldType(holdType)
	end
end

function SWEP:OverridePrintName()
	return self.PrintName
end

if CLIENT then
	function SWEP:DoDrawCrosshair(x, y)
		return not self:IsThrowing()
	end
else
	function SWEP:GetThrowPosition(pos)
		local ply = self:GetOwner()

		local tr = util.TraceHull({
			start = ply:GetShootPos(),
			endpos = pos,
			mins = Vector(-4, -4, -4),
			maxs = Vector(4, 4, 4),
			filter = ply
		})

		return tr.Hit and tr.HitPos or pos
	end

	function SWEP:CreateEntity()
	end

	function SWEP:ThrowEntity(mode)
		local ent = self:CreateEntity()
		local ply = self:GetOwner()

		if not IsValid(ent) then
			return
		end

		ent:SetCreator(ply)

		local phys = ent:GetPhysicsObject()

		if not IsValid(phys) then
			return
		end

		local pos, ang = ply:GetShootPos(), Angle()
		local vel, angVel

		if mode == self.THROW then
			pos = LocalToWorld(Vector(18, -8, 0), angle_zero, ply:GetShootPos(), ply:GetAimVector():Angle())

			vel = (ply:GetForward() + Vector(0, 0, 0.1)) * 1200
			angVel = Vector(600, math.random(-1200, 1200), 0)
		elseif mode == self.LOB then
			pos = LocalToWorld(Vector(18, -8, 0), angle_zero, ply:GetShootPos(), ply:GetAimVector():Angle())

			vel = (ply:GetForward() * 350) + Vector(0, 0, 50)
			angVel = Vector(200, math.random(-600, 600), 0)
		elseif mode == self.ROLL then
			pos = ply:GetPos() + Vector(0, 0, 4)

			local facing = ply:GetAimVector()
			facing.z = 0
			facing:Normalize()

			local tr = util.TraceLine({
				start = pos,
				endpos = pos + Vector(0, 0, -16),
				filter = ply
			})

			if tr.Fraction != 1 then
				facing = tr.Normal:Cross(facing:Cross(tr.Normal))
			end

			pos:Add(facing * 18)
			ang = Angle(0, ply:GetAngles().y, -90)

			vel = ply:GetForward() * 700
			angVel = Vector(0, 0, 720)
		end

		ent:SetPos(self:GetThrowPosition(pos))
		ent:SetAngles(ang)

		phys:SetVelocity(ply:GetVelocity() + vel)
		phys:AddAngleVelocity(angVel)
	end
end
