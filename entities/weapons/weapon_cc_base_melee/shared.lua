DEFINE_BASECLASS("weapon_cc_base")
AddCSLuaFile()

SWEP.Base = "weapon_cc_base"

SWEP.Slot = 2

SWEP.InfoText = [[Primary: Attack
Primary + Use: Shove

Hold Secondary: Block]]

SWEP.ViewModelFOV = 54
SWEP.DrawCrosshair = false

SWEP.Primary.Automatic = true

SWEP.Dangerous = true

SWEP.Stats = {
	Damage = {8, 12}, -- Damage ramps up between the different hold times

	Reach = 48, -- How far away you can hit someone

	Delay = 0.5, -- Cooldown between swings
	Block = Config.Get("MeleeBlockMultiplier")
}

SWEP.Settings = {
	LowerHoldType = "normal", -- Holstered/lowered
	BaseHoldType = "melee2", -- Default

	AimTime = 0.35,

	UseHolsterAnimations = false, -- Hides the viewmodel when holstered
	IsLightWeapon = false -- If true, can sprint without the weapon lowering
}

SWEP.Animations = {
	Draw = ACT_VM_DRAW,
	Holster = ACT_VM_HOLSTER,

	Deploy = ACT_VM_DRAW,
	Idle = ACT_VM_IDLE,

	MeleeHit = ACT_VM_HITCENTER,
	MeleeMiss = ACT_VM_MISSCENTER
}

SWEP.Sounds = {
	Hit = Sound("Weapon_Crowbar.Melee_Hit"),
	HitWorld = nil,
	Miss = Sound("Weapon_Crowbar.Single")
}

SWEP.Offsets = {
	Default = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	},
	Holster = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	},
	Sprint = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	},
	Block = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	}
}

include("sh_attack.lua")

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Float", "BlockState")
end

function SWEP:ShouldLower()
	if self.Settings.IsLightWeapon then
		return false
	end

	return BaseClass.ShouldLower(self)
end

function SWEP:PrimaryAttack()
	if self:TryShove() then
		return
	end

	if self:GetHolstered() or self:ShouldLower() or self:GetBlockState() > 0 then
		return
	end

	self:PerformSwing()
end

function SWEP:ShouldBlock()
	if self:GetHolstered() then
		return false
	end

	return self:GetOwner():KeyDown(IN_ATTACK2)
end

function SWEP:Think()
	BaseClass.Think(self)

	self:SetBlockState(math.Approach(self:GetBlockState(), self:ShouldBlock() and 1 or 0, FrameTime() / 0.2))
end

function SWEP:GetSwingHoldType()
	return self.Settings.SwingHoldType or self:GetBaseHoldType()
end

function SWEP:SetupMove(ply, mv, cmd)
	if not self:ShouldBlock() then
		return
	end

	mv:LimitSpeed(Lerp(self:GetBlockState(), ply:GetWalkSpeed(), ply:GetWalkSpeed() * 0.75))
end

if CLIENT then
	function SWEP:GetViewModelTarget()
		local offsets = self.Offsets
		local targetPos = Vector(offsets.Default[1])
		local targetAng = Angle(offsets.Default[2])

		if self:GetHolstered() then
			targetPos:Add(offsets.Holster[1])
			targetAng:Add(offsets.Holster[2])
		elseif self:ShouldLower() then
			targetPos:Add(offsets.Sprint[1])
			targetAng:Add(offsets.Sprint[2])
		elseif self:ShouldBlock() then
			targetPos:Add(offsets.Block[1])
			targetAng:Add(offsets.Block[2])
		end

		return targetPos, targetAng
	end
end
