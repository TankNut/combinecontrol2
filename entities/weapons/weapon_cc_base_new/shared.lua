AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.m_WeaponDeploySpeed = 10

SWEP.Category = "CombineControl"

SWEP.InfoText = [[Primary: Fire Weapon
Secondary: Aim Down Sights
Secondary + Scroll: Zoom]]

SWEP.BobScale = 0 -- Don't change this
SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/c_irifle.mdl")
SWEP.WorldModel = Model("models/weapons/w_irifle.mdl")

SWEP.Stats = {
	Type = "Bullet", -- Used to determine what swep base function is called
	Count = 1, -- Amount of bullets to fire

	Damage = 11, -- Per bullet
	DamageFalloff = 0.98, -- Damage percentage per 1000 units

	FixedRange = false, -- For shotguns, overrides Settings.Range and forces it to use only Accuracy
	Accuracy = {12, 2}, -- Hip vs aimed

	Tracer = "Tracer", -- The tracer effect, do not leave empty
	TracerCount = 1, -- Fire a tracer every X bullets

	Impact = nil -- Optional impact effect that is layered on top of the default
}

SWEP.Recoil = {
	-- The base recoil value
	Value = 0.6,

	-- How the recoil value is applied to the viewmodel
	PosMult = Vector(0, 0, 0),
	AngMult = Angle(0, 0),

	-- The amount of recoil that's applied to the player's eyeangles
	Punch = 0.6
}

SWEP.Settings = {
	LowerHoldType = "passive", -- Holstered/lowered
	BaseHoldType = "ar2", -- Default
	AimHoldType = nil, -- If set, aiming

	AutoBurst = false, -- Automatic cycling between bursts
	Firemodes = {-1}, -- -1 = automatic, 0 = semi, 1+ = burst

	FireRate = 600, -- Rounds per minute, -1 = animation time
	BurstDelay = 0, -- Delay between bursts, -1 = animation time

	ClipSize = 30,
	ReloadTime = -1, -- -1 = animation time
	ReloadAmount = -1, -- -1 = everything

	Range = 400, -- Range in units at which the weapon hits the accuracy stat exactly
	ScopedRange = nil, -- Range when scoped, otherwise Range

	AimTime = 0.35, -- Seconds

	Zoom = {1.25}, -- Scrollwheel to switch between zoom levels
	ScopeIndex = nil -- If set, the index of Zoom at which point you're considered scoped
}

SWEP.Animations = {
	Deploy = ACT_VM_DRAW,
	Idle = ACT_VM_IDLE,

	Attack = ACT_VM_PRIMARYATTACK,
	Secondary = ACT_VM_SECONDARYATTACK,

	Reload = ACT_VM_RELOAD,
	ReloadEmpty = ACT_VM_RELOAD,

	ReloadStart = ACT_VM_RELOAD,
	ReloadSingle = ACT_VM_RELOAD_INSERT,
	ReloadFinish = ACT_VM_RELOAD_END
}

SWEP.Sounds = {
	Empty = Sound("weapons/ar2/ar2_empty.wav"),
	Primary = Sound("Weapon_AR2.Single"),
	Reload = nil
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
	Aiming = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	}
}

include("sh_animations.lua")
include("sh_attack.lua")
include("sh_recoil.lua")
include("sh_stats.lua")
include("sh_utils.lua")
include("sh_view.lua")

function SWEP:Initialize()
	self.Primary.ClipSize = self.Settings.ClipSize
	self.OrigViewModelFOV = self.ViewModelFOV
end

function SWEP:Deploy()
	self:SetHolstered(true)

	local delay = CurTime() + self:PlayAnimation("Deploy")

	self:SetNextPrimaryFire(delay)
	self:SetNextIdle(delay)

	return true
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "Holstered")

	self:NetworkVar("Int", "FiremodeIndex")
	self:NetworkVar("Int", "BurstIndex")

	self:NetworkVar("Float", "NextIdle")
	self:NetworkVar("Float", "AimState")

	self:NetworkVar("Angle", "RecoilPunch")
	self:NetworkVar("Angle", "RecoilVelocity")

	self:SetHolstered(true)
	self:SetFiremodeIndex(1)
end

function SWEP:Think()
	local idle = self:GetNextIdle()

	if idle > 0 and idle <= CurTime() then
		self:PlayAnimation("Idle")
		self:SetNextIdle(0)
	end

	self:DoRecoilDecay()
	self:SetAimState(math.Approach(self:GetAimState(), self:ShouldAim() and 1 or 0, FrameTime() / self:GetAimTime()))
end

function SWEP:ToggleHolster()
	self:SetHolstered(not self:GetHolstered())
end

function SWEP:SetupMove(ply, mv, cmd)
	if not self:ShouldAim() then
		return
	end

	local aimSlow = Lerp(self:GetAimState(), ply:GetWalkSpeed(), ply:GetWalkSpeed() * 0.75)

	if mv:GetMaxSpeed() < aimSlow then
		return
	end

	mv:SetMaxSpeed(aimSlow)
	mv:SetMaxClientSpeed(aimSlow)
end
