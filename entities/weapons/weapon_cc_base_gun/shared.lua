DEFINE_BASECLASS("weapon_cc_base")
AddCSLuaFile()

SWEP.Base = "weapon_cc_base"

SWEP.Category = "CombineControl"
SWEP.NPCCategory = nil

SWEP.InfoText = [[Primary: Fire Weapon
Secondary: Aim Down Sights
Secondary + Scroll: Zoom]]

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
	NPCHoldType = nil, -- If set, overrides the NPC hold type

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
	ScopeIndex = nil, -- If set, the index of Zoom at which point you're considered scoped

	UseHolsterAnimations = false, -- Hides the viewmodel when holstered

	NoNPC = false, -- If set, disables NPC support
	NPCBurst = {2, 5}, -- Burst size
	NPCRest = nil, -- If set, overrides standard rest times between bursts
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

include("sh_attack.lua")
include("sh_holdtype.lua")
include("sh_recoil.lua")
include("sh_stats.lua")
include("sh_view.lua")

if SERVER then
	include("sv_npc.lua")
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Int", "FiremodeIndex")
	self:NetworkVar("Int", "BurstIndex")

	self:NetworkVar("Float", "AimState")

	self:NetworkVar("Angle", "RecoilPunch")
	self:NetworkVar("Angle", "RecoilVelocity")

	self:SetFiremodeIndex(1)
end

function SWEP:Think()
	BaseClass.Think(self)

	self:DoRecoilDecay()
	self:SetAimState(math.Approach(self:GetAimState(), self:ShouldAim() and 1 or 0, FrameTime() / self:GetAimTime()))
end

if SERVER then
	function SWEP:OwnerChanged()
		local owner = self:GetOwner()

		if IsValid(owner) and owner:IsNPC() then
			self:SetHoldType(self:GetNPCHoldType())
		end

		BaseClass.OwnerChanged(self)
	end
end

function SWEP:ShouldAim()
	if self:ShouldLower() or self:GetHolstered() then
		return false
	end

	return self:GetOwner():KeyDown(IN_ATTACK2)
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
