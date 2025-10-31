DEFINE_BASECLASS("weapon_cc_base")
AddCSLuaFile()

SWEP.Base = "weapon_cc_base"

SWEP.Category = "CombineControl"
SWEP.NPCCategory = nil

SWEP.Slot = 2

SWEP.InfoText = [[Primary: Fire Weapon
Primary + Use: Shove

Secondary: Aim Down Sights
Secondary + Scroll: Zoom]]

SWEP.Dangerous = true

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
	Firemodes = {-1}, -- See enums.lua
	FiremodeOverride = "",
	FireRate = 600, -- Rounds per minute, -1 = animation time
	BurstDelay = 0, -- Delay between bursts, -1 = animation time

	AmmoCost = 1, -- How much ammo is taken every time the weapon fires
	ClipSize = 30, -- Self-explanatory
	ReloadTime = -1, -- -1 = animation time
	ReloadAmount = -1, -- -1 = everything

	PumpAction = false, -- Uses shotgun pump animations/mechanics
	PumpTime = -1, -- How much of a delay pumping adds
	ShotgunReload = false, -- Uses shotgun reload mechanics/animations

	Range = 400, -- Range in units at which the weapon hits the accuracy stat exactly
	ScopedRange = nil, -- Range when scoped, otherwise Range
	Zoom = {1.25}, -- Scrollwheel to switch between zoom levels
	ScopeIndex = nil, -- If set, the index of Zoom at which point you're considered scoped

	AimTime = 0.35, -- Seconds

	UseHolsterAnimations = false, -- Hides the viewmodel when holstered

	NoNPC = false, -- If set, disables NPC support
	NPCBurst = {2, 5}, -- Burst size
	NPCRest = nil, -- If set, overrides standard rest times between bursts
}

SWEP.Animations = {
	Draw = ACT_VM_DRAW,
	Holster = ACT_VM_HOLSTER,

	Deploy = ACT_VM_DRAW,
	Idle = ACT_VM_IDLE,

	Primary = ACT_VM_PRIMARYATTACK,
	Secondary = ACT_VM_SECONDARYATTACK,
	Pump = ACT_SHOTGUN_PUMP,

	Reload = ACT_VM_RELOAD,
	ReloadEmpty = ACT_VM_RELOAD,

	ReloadStart = ACT_SHOTGUN_RELOAD_START,
	ReloadFinish = ACT_SHOTGUN_RELOAD_FINISH
}

SWEP.Sounds = {
	Empty = Sound("weapons/ar2/ar2_empty.wav"),
	Primary = Sound("Weapon_AR2.Single"),
	Reload = nil,
	Pump = Sound("Weapon_Shotgun.Special1")
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
include("sh_reload.lua")
include("sh_stats.lua")
include("sh_view.lua")

include("attacks/sh_bullet.lua")
include("attacks/sh_projectile.lua")

AddCSLuaFile("cl_hud.lua")

if CLIENT then
	include("cl_hud.lua")
else
	include("sv_npc.lua")
end

function SWEP:Initialize()
	BaseClass.Initialize(self)

	self.Primary.ClipSize = self.Settings.ClipSize
	self:SetClip1(self.Primary.ClipSize)
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", "ToggleAim")
	self:NetworkVar("Bool", "ShouldPump")
	self:NetworkVar("Bool", "FirstReload")
	self:NetworkVar("Bool", "CancelReload")

	self:NetworkVar("Int", "FiremodeIndex")
	self:NetworkVar("Int", "BurstIndex")

	self:NetworkVar("Float", "AimState")
	self:NetworkVar("Float", "AimStart")
	self:NetworkVar("Float", "FinishReload")

	self:NetworkVar("Angle", "RecoilPunch")
	self:NetworkVar("Angle", "RecoilVelocity")

	self:SetFiremodeIndex(1)
end

function SWEP:Think()
	self:ReloadThink()
	self:PumpThink()

	BaseClass.Think(self)

	self:DoRecoilDecay()
	self:AimThink()
end

function SWEP:PumpThink()
	if not self:GetShouldPump() or self:IsReloading() then
		return
	end

	if self:GetNextPrimaryFire() <= CurTime() then
		local anim = self:PlayAnimation("Pump")
		local time = self.Settings.PumpTime

		self:SetNextPrimaryFire(CurTime() + (time == -1 and anim or time))
		self:PlaySound("Pump")

		self:SetShouldPump(false)
	end
end

function SWEP:AimThink()
	self:SetAimState(math.Approach(self:GetAimState(), self:ShouldAim() and 1 or 0, FrameTime() / self.Settings.AimTime))

	local ply = self:GetOwner()

	if ply:GetSetting("SmartAim") and ply:KeyReleased(IN_ATTACK2) then
		if self:GetToggleAim() then
			self:SetToggleAim(false)
		elseif CurTime() - self:GetAimStart() < ply:GetSetting("KeySensitivity") then
			self:SetToggleAim(true)
		end
	end
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

function SWEP:OnReloaded()
	self.Primary.ClipSize = self.Settings.ClipSize
end

function SWEP:SecondaryAttack()
	self:SetAimStart(CurTime())
end

function SWEP:ShouldAim()
	if self:GetHolstered() then
		return false
	end

	return self:GetToggleAim() or self:GetOwner():KeyDown(IN_ATTACK2)
end

function SWEP:SetupMove(ply, mv, cmd)
	if not self:ShouldAim() then
		return
	end

	mv:LimitSpeed(Lerp(self:GetAimState(), ply:GetWalkSpeed(), ply:GetWalkSpeed() * 0.75))
end

if SERVER then
	function SWEP:LoadItemState(data)
		if data.Firemode then
			self:SetFiremodeIndex(math.Clamp(data.Firemode, 1, #self.Settings.Firemodes))
		end

		if data.Clip then
			self:SetClip1(math.Clamp(data.Clip, 0, self.Primary.ClipSize))
		end
	end

	function SWEP:SaveItemState()
		local data = {
			Firemode = self:GetFiremodeIndex()
		}

		local clip = self:Clip1()

		if clip > -1 then
			data.Clip = clip
		end

		return data
	end
end
