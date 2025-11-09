AddCSLuaFile()
DEFINE_BASECLASS("weapon_cc_base_gun")

SWEP.Base = "weapon_cc_base_gun"

SWEP.Heat = {
	CoolDelay = 0.4, -- Time to wait before cooling starts

	HeatRate = 4, -- Heat added per attack
	CoolRate = 40, -- Heat removed per second when not firing

	Max = 100, -- Overheat threshold
	ForceOverheat = true, -- Whether the gun forces itself into overheat mode when above max
	AllowManual = false -- Whether reload allows the user to manually go into overheat mode
}

SWEP.Animations = {
	OverheatStart = ACT_SHOTGUN_RELOAD_START,
	OverheatIdle = ACT_VM_RELOAD,
	OverheatFinish = ACT_SHOTGUN_RELOAD_FINISH
}

SWEP.Sounds = {
	OverheatStart = "Weapon_Plasma.Overheat",
	OverheatFinish = "Weapon_Plasma.OverheatFinish",
	Vent = "Weapon_Plasma.Vent"
}

function SWEP:SetupDataTables()
	self:NetworkVar("Float", "CurrentHeat")
	self:NetworkVar("Bool", "Overheating")

	BaseClass.SetupDataTables(self)
end

function SWEP:Holster()
	if self:GetOverheating() then
		return false
	end

	return BaseClass.Holster(self)
end

function SWEP:GetHeat()
	return self:GetCurrentHeat() / self.Heat.Max
end

function SWEP:Think()
	self:HeatThink()

	BaseClass.Think(self)
end

function SWEP:HeatThink()
	local heat = self.Heat
	local current = self:GetCurrentHeat()

	if heat.ForceOverheat and current >= heat.Max and not self:GetOverheating() then
		self:SetOverheating(true)
		self:OnOverheatStart()
	end

	if CurTime() - self:GetLastAttack() < heat.CoolDelay then
		return
	end

	local new = math.max(current - FrameTime() * heat.CoolRate, 0)

	self:SetCurrentHeat(new)

	if self:GetOverheating() and new == 0 then
		self:SetOverheating(false)
		self:OnOverheatEnd()
	end
end

function SWEP:CanFire(quiet)
	if self:GetOverheating() then
		return false
	end

	return BaseClass.CanFire(self, quiet)
end

function SWEP:PrimaryPlayer()
	BaseClass.PrimaryPlayer(self)

	self:SetCurrentHeat(self:GetCurrentHeat() + self.Heat.HeatRate)
end

function SWEP:SelectIdleAnimation()
	return self:GetOverheating() and "OverheatIdle" or BaseClass.SelectIdleAnimation(self)
end

function SWEP:OnOverheatStart(manual)
	self:EmitSound(manual and self.Sounds.Vent or self.Sounds.OverheatStart)
	self:PlayAnimation(manual and "OverheatIdle" or "OverheatStart")
end

function SWEP:OnOverheatEnd()
	self:EmitSound(self.Sounds.OverheatFinish)
	self:PlayAnimation("OverheatFinish")
end

sound.Add({
	name = "Weapon_Plasma.Overheat",
	channel = CHAN_AUTO,
	volume = 0.92,
	level = 76,
	pitch = 100,
	sound = ")vuthakral/halo/weapons/plasmarifle/plasrifle_overheat.wav"
})

sound.Add({
	name = "Weapon_Plasma.OverheatFinish",
	channel = CHAN_AUTO,
	volume = 0.92,
	level = 56,
	pitch = 100,
	sound = ")vuthakral/halo/weapons/plasmarifle/plasrifle_oh_exit.wav"
})

sound.Add({
	name = "Weapon_Plasma.Vent",
	channel = CHAN_AUTO,
	volume = 0.165,
	level = 56,
	pitch = {98.5, 101.5},
	sound = {
		")vuthakral/halo/weapons/plasmarepeater/vent_open0.wav",
		")vuthakral/halo/weapons/plasmarepeater/vent_open1.wav",
		")vuthakral/halo/weapons/plasmarepeater/vent_open2.wav"
	}
})
