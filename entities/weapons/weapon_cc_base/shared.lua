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

SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0

SWEP.Settings = {
	LowerHoldType = "passive", -- Holstered/lowered
	BaseHoldType = "ar2", -- Default

	AimTime = 0.35,

	UseHolsterAnimations = false -- Hides the viewmodel when holstered
}

SWEP.Animations = {
	Draw = ACT_VM_DRAW,
	Holster = ACT_VM_HOLSTER,

	Deploy = ACT_VM_DRAW,
	Idle = ACT_VM_IDLE,

	Primary = ACT_VM_PRIMARYATTACK,
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
	self.OrigViewModelFOV = self.ViewModelFOV
end

function SWEP:Deploy()
	self:SetHolstered(true)
	self:SetDeployed(true)

	if self.Settings.UseHolsterAnimations then
		self:SetNextPrimaryFire(CurTime() + 0.1)
		self:PlayAnimation("Holster")
		self:SetNextIdle(0)
	else
		self:SetNextPrimaryFire(CurTime() + self:PlayAnimation("Deploy"))
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
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

local phys_pushscale = GetConVar("phys_pushscale")

function SWEP:TryShove()
	local ply = self:GetOwner()

	if not ply:IsPlayer() or not ply:KeyDown(IN_USE) then
		return
	end

	local tr = self:GetMeleeTrace(48)
	local ent = tr.Entity

	if IsValid(ent) then
		if ent:IsPlayer() then
			local dir = ent:GetPos()

			dir:Sub(ply:GetPos())
			dir:SetZ(0)
			dir:Normalize()

			ent:SetVelocity(dir * 300)
		else
			local scale = phys_pushscale:GetFloat()
			local phys = ent:GetPhysicsObject()

			if IsValid(phys) then
				local force = ply:GetAimVector()
				force:Mul(scale * 3000)

				phys:ApplyForceOffset(force, tr.HitPos)
			end
		end

		self:EmitSound("NPC_Metropolice.Shove")
	end

	self:SetNextPrimaryFire(CurTime() + 1)

	return true
end

if SERVER then
	function SWEP:OwnerChanged()
		if self:GetOwner() == NULL then
			self:Remove()
		end
	end
end

function SWEP:ToggleHolster()
	local state = not self:GetHolstered()

	self:SetDeployed(false)
	self:SetHolstered(state)

	if self.Settings.UseHolsterAnimations then
		self:PlayAnimation(state and "Holster" or "Draw")

		if state then
			self:SetNextIdle(0)
		end
	end
end

function SWEP:GetZoom()
	return 1
end

if CLIENT then
	function SWEP:GetHUDLines()
		return
	end
end
