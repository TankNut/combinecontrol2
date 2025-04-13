DEFINE_BASECLASS("weapon_cc_base_melee")
AddCSLuaFile()

SWEP.Base = "weapon_cc_base_melee"

SWEP.Slot = 2

SWEP.InfoText = [[Primary: Light Attack
Hold Primary: Heavy Attack
Primary + Use: Shove

Hold Secondary: Block]]

SWEP.ViewModelFOV = 54
SWEP.DrawCrosshair = false

SWEP.Stats = {
	Damage = {8, 12}, -- Damage ramps up between the different hold times

	Reach = 48, -- How far away you can hit someone
	Hold = {0.15, 0.5}, -- First number determines how long it takes for you to swing, second number how long you can hold to reach full damage

	Delay = 0.5, -- Cooldown between swings
	Block = Config.Get("MeleeBlockMultiplier")
}

SWEP.Settings = {
	LowerHoldType = "normal", -- Holstered/lowered
	BaseHoldType = "melee2", -- Default
	SwingHoldType = "melee", -- When swinging

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
	Swing = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	},
	Block = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	}
}

include("sh_swing.lua")

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Float", "SwingStart")
	self:NetworkVar("Float", "HoldTypeReset")
end

function SWEP:Deploy()
	BaseClass.Deploy(self)

	self:SetSwingStart(0)
	self:SetHoldTypeReset(0)

	return true
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

	if self:GetHolstered() or self:GetBlockState() > 0 then
		return
	end

	self:SetSwingStart(CurTime())
	self:SetNextPrimaryFire(math.huge)
end

function SWEP:ShouldBlock()
	if self:GetSwingStart() != 0 then
		return false
	end

	return BaseClass.ShouldBlock(self)
end

function SWEP:Think()
	BaseClass.Think(self)

	if self:GetSwingStart() != 0 and self:GetSwingPower() > 0 and not self:GetOwner():KeyDown(IN_ATTACK) then
		self:PerformSwing()
		self:SetSwingStart(0)
		self:SetHoldTypeReset(CurTime() + 0.25)
	end
end

function SWEP:GetSwingHoldType()
	return self.Settings.SwingHoldType or self:GetBaseHoldType()
end

function SWEP:UpdateHoldType()
	local old = self:GetHoldType()
	local holdType = self:GetBaseHoldType()

	if self:GetSwingStart() != 0 or self:GetHoldTypeReset() >= CurTime() then
		holdType = self:GetSwingHoldType()
	elseif self:ShouldLower() or self:GetHolstered() then
		holdType = self:GetLoweredHoldType()
	end

	if holdType != old then
		self:SetHoldType(holdType)
	end
end

function SWEP:SetupMove(ply, mv, cmd)
	if not self:ShouldBlock() and (self.Settings.IsLightWeapon or self:GetSwingStart() == 0) then
		return
	end

	local state = self:GetBlockState()

	if not self.Settings.IsLightWeapon then
		state = math.max(state, self:GetSwingTime())
	end

	mv:LimitSpeed(Lerp(state, ply:GetWalkSpeed(), ply:GetWalkSpeed() * 0.75))
end
