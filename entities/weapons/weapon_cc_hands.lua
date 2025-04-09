DEFINE_BASECLASS("weapon_cc_base")
AddCSLuaFile()

SWEP.Base = "weapon_cc_base"

SWEP.PrintName = "Hands"

SWEP.InfoText = [[Lowered - Primary: Knock on doors

Raised - Primary: Punch
Raised - Secondary: Block]]

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.Weight = 100

SWEP.ViewModelFOV = 54
SWEP.DrawCrosshair = false

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

SWEP.Damage = {8, 12}
SWEP.DamageTimer = 1

SWEP.Reach = 32
SWEP.HitDelay = 0.15
SWEP.HitForce = 80

SWEP.HitCooldown = 0.4
SWEP.MissCooldown = 0.9

SWEP.BlockMultiplier = Config.Get("FistBlockMultiplier")

SWEP.Settings = {
	LowerHoldType = "normal",
	BaseHoldType = "fist",

	UseHolsterAnimations = true
}

SWEP.Animations = {
	Draw = "fists_draw",
	Holster = "fists_holster",

	Idle = {"fists_idle_01", "fists_idle_02"},
	Primary = {"fists_left", "fists_right"}
}

SWEP.Sounds = {
	Swing = Sound("WeaponFrag.Throw"),
	Hit = Sound("Flesh.ImpactHard"),
	Knock = Sound("physics/wood/wood_crate_impact_hard2.wav")
}

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Float", "HitDelay")
	self:NetworkVar("Float", "BlockState")
end

function SWEP:Deploy()
	BaseClass.Deploy(self)

	self:SetHitDelay(0)

	return true
end

function SWEP:ShouldLower()
	return false
end

function SWEP:PrimaryAttack()
	if self:TryShove() then
		return
	end

	self:PrimeRandomSeed()

	if self:GetHolstered() then
		local ent = self:GetOwner():GetUseEntity()

		-- Todo: Door check
		if IsValid(ent) and ent:IsDoor() then
			self:PlaySound("Knock", 70, math.random(95, 105))
			self:SetNextPrimaryFire(CurTime() + 0.2)
		end

		self.Primary.Automatic = false
	elseif self:GetBlockState() == 0 then
		self:PlayAnimation("Primary")
		self:PlayerAnimation(PLAYER_ATTACK1)

		self:PlaySound("Swing")

		self:SetHitDelay(CurTime() + self.HitDelay)
		self:SetNextPrimaryFire(math.huge)

		self.Primary.Automatic = true
	end
end

function SWEP:ShouldBlock()
	if self:GetHolstered() or self:GetHitDelay() != 0 then
		return false
	end

	return self:GetOwner():KeyDown(IN_ATTACK2)
end

function SWEP:Think()
	BaseClass.Think(self)

	local hitDelay = self:GetHitDelay()

	if hitDelay != 0 and hitDelay <= CurTime() then
		self:SetHitDelay(0)
		self:PerformSwing()
	end

	self:SetBlockState(math.Approach(self:GetBlockState(), self:ShouldBlock() and 1 or 0, FrameTime() / 0.2))
end

function SWEP:GetDamage()
	local fraction = math.Clamp(math.TimeFraction(self:GetNextPrimaryFire(), self:GetNextPrimaryFire() + self.DamageTimer, CurTime()), 0, 1)

	return Lerp(fraction, self.Damage[1], self.Damage[2])
end

local phys_pushscale = GetConVar("phys_pushscale")
local damageForce = {
	["fists_left"] = Vector(999, -491, 0),
	["fists_right"] = Vector(999, 491, 0)
}

function SWEP:PerformSwing()
	local ply = self:GetOwner()
	local vm = ply:GetViewModel()
	local anim = vm:GetSequenceName(vm:GetSequence())

	local tr, line = self:GetMeleeTrace(self.Reach)

	if tr.Hit then
		self:PlaySound("Hit")
	end

	local scale = phys_pushscale:GetFloat()
	local ent = tr.Entity

	local damage = self:GetDamage()

	if SERVER and IsValid(ent) and (ent:IsNPC() or ent:IsPlayer() or ent:Health() > 0) then
		local dmginfo = DamageInfo()

		dmginfo:SetAttacker(ply)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamagePosition(line.HitPos)

		local force = Vector(damageForce[anim])

		force:Mul(scale)
		force:Rotate(self:GetShootDir():Angle())

		dmginfo:SetDamageForce(force)
		dmginfo:SetDamage(damage)
		dmginfo:SetDamageType(DMG_CLUB)

		SuppressHostEvents(NULL)
			ent:TakeDamageInfo(dmginfo)
		SuppressHostEvents(ply)
	end

	if IsValid(ent) then
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:ApplyForceOffset(ply:GetAimVector() * damage * 250 * scale, tr.HitPos)
		end
	end

	local delay = tr.Hit and self.HitCooldown or self.MissCooldown

	self:SetNextPrimaryFire(CurTime() + delay - self.HitDelay)
end

if CLIENT then
	local blockPos = Vector(-3, 3, -3)
	local blockAng = Angle(0, 0, 0)

	function SWEP:GetViewModelTarget()
		local targetPos = Vector()
		local targetAng = Angle()

		if self:ShouldBlock() then
			targetPos:Add(blockPos)
			targetAng:Add(blockAng)
		end

		return targetPos, targetAng
	end
end

function SWEP:SetupMove(ply, mv, cmd)
	if not self:ShouldBlock() then
		return
	end

	mv:LimitSpeed(Lerp(self:GetBlockState(), ply:GetWalkSpeed(), ply:GetWalkSpeed() * 0.75))
end
