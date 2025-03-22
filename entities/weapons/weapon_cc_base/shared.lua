AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.m_WeaponDeploySpeed = 10

SWEP.Category = "CombineControl"
SWEP.NPCCategory = nil

SWEP.BobScale = 0 -- Don't change this
SWEP.ViewModelFOV = 54

SWEP.UseHands   = true
SWEP.ViewModel  = Model("models/weapons/c_irifle.mdl")
SWEP.WorldModel = Model("models/weapons/w_irifle.mdl")

SWEP.Settings = {
	LowerHoldType = "passive", -- Holstered/lowered
	BaseHoldType = "ar2", -- Default

	UseHolsterAnimations = false, -- Hides the viewmodel when holstered
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

SWEP.Sounds = {}

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
	}
}

include("sh_animations.lua")
include("sh_holdtype.lua")
include("sh_utils.lua")
include("sh_view.lua")

function SWEP:Initialize()
	self.Primary.ClipSize = self.Settings.ClipSize
	self.OrigViewModelFOV = self.ViewModelFOV
end

function SWEP:Deploy()
	self:SetHolstered(true)

	if self.Settings.UseHolsterAnimations then
		self:PlayAnimation("Holster")
		self:SetDeployed(true)
	else
		local delay = CurTime() + self:PlayAnimation("Deploy")

		self:SetNextPrimaryFire(delay)
	end

	return true
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "Holstered")
	self:NetworkVar("Bool", "Deployed")

	self:NetworkVar("Float", "NextIdle")
end

function SWEP:Think()
	self:UpdateHoldType()

	local idle = self:GetNextIdle()

	if idle > 0 and idle <= CurTime() then
		self:PlayAnimation("Idle")
		self:SetNextIdle(0)
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

if SERVER then
	function SWEP:OwnerChanged()
		if self:GetOwner() == NULL then
			self:Remove()
		end
	end
end

function SWEP:OnReloaded()
	self:SetHoldType("pistol")
end

function SWEP:ToggleHolster()
	local state = not self:GetHolstered()

	self:SetDeployed(false)
	self:SetHolstered(state)
	self:PlayAnimation("Holster")

	if state then
		self:SetNextIdle(0)
	end
end

function SWEP:GetZoom()
	return 1
end
