AddCSLuaFile()

ENT.Type = "anim"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Material = "taconbanana/halo/models/effects/shield"

ENT.BaseShield = 100
ENT.RechargeDelay = 5
ENT.RechargeTime = 4

ENT.RechargeSound = Sound("cc2.ShieldRecharge.Spartan")
ENT.LowAlertSound = Sound("taconbanana/halo/shield/alert_low_spartan.wav")
ENT.BreakAlertSound = Sound("taconbanana/halo/shield/alert_break_spartan.wav")

function ENT:Initialize()
	local parent = self:GetParent()

	self:SetLocalPos(vector_origin)
	self:DrawShadow(false)
	self:SetModel(parent:GetModel())

	if CLIENT and parent == lp then
		self.LowAlertSoundPatch = CreateSound(self, self.LowAlertSound)
		self.BreakAlertSoundPatch = CreateSound(self, self.BreakAlertSound)
	elseif SERVER then
		self.CanPlayRechargeSound = true

		if parent:IsPlayer() then
			hook.Add("PlayerSpawn", self, self.PlayerSpawn)
		end
	end

	if CLIENT then
		self:SetNoDraw(true)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", "Shield")
	self:NetworkVar("Float", "LastPing")

	self:SetShield(0)
	self:SetLastPing(CurTime() - self.RechargeDelay)
end

function ENT:TimeSinceLastHit()
	return CurTime() - self:GetLastPing()
end

function ENT:GetShieldValue()
	local time = self:TimeSinceLastHit()
	local shield = self:GetShield()

	-- We haven't started recharging
	if time < self.RechargeDelay then
		return shield
	else
		time = time - self.RechargeDelay

		local missingFraction = 1 - (shield / self.BaseShield)
		local rechargeTimer = missingFraction * self.RechargeTime

		if time >= rechargeTimer then
			return self.BaseShield
		else
			return math.Remap(time, 0, rechargeTimer, shield, self.BaseShield), true
		end
	end
end

function ENT:OnRemove()
	self:StopSound(self.RechargeSound)

	if CLIENT then
		if self.BreakAlertSoundPatch then self.BreakAlertSoundPatch:Stop() end
		if self.LowAlertSoundPatch then self.LowAlertSoundPatch:Stop() end
	end
end

function ENT:IsWorking()
	local parent = self:GetParent()

	if parent.Alive and not parent:Alive() then
		return false
	end

	return true
end

if SERVER then
	function ENT:Think()
		local parent = self:GetParent()

		if not IsValid(parent) then
			self:Remove()

			return
		end

		if not self:IsWorking() then
			return
		end

		if self:GetModel() != parent:GetModel() then
			self:SetModel(parent:GetModel())
		end

		if self:TimeSinceLastHit() >= self.RechargeDelay and self.CanPlayRechargeSound then
			self.CanPlayRechargeSound = false
			self:EmitSound(self.RechargeSound)
		end
	end

	function ENT:TakeShieldDamage(dmg)
		if dmg:IsFallDamage() or not self:IsWorking() then
			return
		end

		local shield = self:GetShieldValue()

		self:SetLastPing(CurTime())

		if shield <= 0 then
			return
		end

		self.CanPlayRechargeSound = true
		self:StopSound(self.RechargeSound)

		shield = math.max(shield - dmg:GetDamage(), 0)

		if shield == 0 then
			self:EmitSound("cc2.ShieldBreak")
		else
			local damage = dmg:GetDamage()
			local snd = "cc2.ShieldImpact.Light"

			if damage >= 25 then
				snd = "cc2.ShieldImpact.Heavy"
			elseif damage >= 10 then
				snd = "cc2.ShieldImpact.Medium"
			end

			self:EmitSound(snd)
		end

		self:SetShield(shield)

		return true
	end

	function ENT:PlayerSpawn(ply)
		if ply != self:GetParent() then
			return
		end

		self:SetShield(0)
		self:SetLastPing(CurTime() - self.RechargeDelay)

		self.CanPlayRechargeSound = true
	end
end

if CLIENT then
	function ENT:Think()
		if self:GetParent() != lp then
			return
		end

		local shieldFraction = self:GetShieldValue() / self.BaseShield

		local breakSound = false
		local lowSound = false

		if self:IsWorking() then
			breakSound = shieldFraction == 0
			lowSound = not breakSound and shieldFraction <= 0.2
		end

		if breakSound != self.BreakAlertSoundPatch:IsPlaying() then
			self.BreakAlertSoundPatch[breakSound and "Play" or "Stop"](self.BreakAlertSoundPatch)
		end

		if lowSound != self.LowAlertSoundPatch:IsPlaying() then
			self.LowAlertSoundPatch[lowSound and "Play" or "Stop"](self.LowAlertSoundPatch)
		end
	end

	function ENT:GetShieldColor()
		return Vector(1, 0.75, 0)
	end

	function ENT:GetShieldScale()
		return math.Remap(self:GetShieldValue(), 0, self.BaseShield, 1.2, 1.05)
	end

	function ENT:GetShieldVisibility()
		local shield, recharging = self:GetShieldValue()

		if shield == 0 then
			return 0
		end

		if recharging then
			return math.Remap(shield, 0, self.BaseShield, 1, 0)
		end

		local maxAlpha = math.Remap(shield, 0, self.BaseShield, 1, 0.2)
		local time = self:TimeSinceLastHit() - 0.5

		if time <= 0 then
			return maxAlpha
		end

		local fade = math.Remap(shield, 0, self.BaseShield, 1, 0.5)

		return math.ClampedRemap(time, 0, fade, maxAlpha, 0)
	end

	function ENT:Draw()
		local parent = self:GetParent()

		if not IsValid(parent) or parent:GetNoDraw() then return end
		if not self:IsWorking() then return end
		if parent == lp and not parent:ShouldDrawLocalPlayer() then return end

		local rt = render.GetRenderTarget()

		if rt != nil and string.lower(rt:GetName()) == "_rt_shadowdummy" then
			return
		end

		self:SetPos(parent:GetPos())
		self:SetModelScale(parent:GetModelScale())

		self:SetupBones()

		local scale = Vector(1, 1, 1)
		scale:Mul(self:GetShieldScale() * parent:GetModelScale())

		for i = 0, self:GetBoneCount() - 1 do
			local matrix = parent:GetBoneMatrix(i)

			if self:GetBoneName(i) == "__INVALIDBONE__" then
				continue
			end

			if matrix then
				matrix:SetScale(scale)
				self:SetBoneMatrix(i, matrix)
			end
		end

		for i = 1, #self:GetBodyGroups() do
			self:SetBodygroup(i, parent:GetBodygroup(i))
		end

		render.SetBlend(0)

		self:SetMaterial(self.Material)
		self:DrawModel()

		render.SetBlend(1)
	end
end

sound.Add({
	name = "cc2.ShieldImpact.Light",
	channel = CHAN_AUTO,
	volume = 1,
	level = 80,
	sound = {
		")taconbanana/halo/shield/hit_light1.wav",
		")taconbanana/halo/shield/hit_light2.wav",
		")taconbanana/halo/shield/hit_light3.wav",
		")taconbanana/halo/shield/hit_light4.wav",
		")taconbanana/halo/shield/hit_light5.wav",
		")taconbanana/halo/shield/hit_light6.wav",
		")taconbanana/halo/shield/hit_light7.wav"
	}
})

sound.Add({
	name = "cc2.ShieldImpact.Medium",
	channel = CHAN_AUTO,
	volume = 1,
	level = 80,
	sound = {
		")taconbanana/halo/shield/hit_medium1.wav",
		")taconbanana/halo/shield/hit_medium2.wav",
		")taconbanana/halo/shield/hit_medium3.wav",
		")taconbanana/halo/shield/hit_medium4.wav",
		")taconbanana/halo/shield/hit_medium5.wav",
		")taconbanana/halo/shield/hit_medium6.wav",
		")taconbanana/halo/shield/hit_medium7.wav"
	}
})

sound.Add({
	name = "cc2.ShieldImpact.Heavy",
	channel = CHAN_AUTO,
	volume = 1,
	level = 80,
	sound = {
		")taconbanana/halo/shield/hit_heavy1.wav",
		")taconbanana/halo/shield/hit_heavy2.wav",
		")taconbanana/halo/shield/hit_heavy3.wav",
		")taconbanana/halo/shield/hit_heavy4.wav",
		")taconbanana/halo/shield/hit_heavy5.wav",
		")taconbanana/halo/shield/hit_heavy6.wav",
		")taconbanana/halo/shield/hit_heavy7.wav"
	}
})

sound.Add({
	name = "cc2.ShieldBreak",
	channel = CHAN_AUTO,
	volume = 1,
	level = 90,
	sound = {
		")taconbanana/halo/shield/break1.wav",
		")taconbanana/halo/shield/break2.wav",
		")taconbanana/halo/shield/break3.wav"
	}
})

sound.Add({
	name = "cc2.ShieldRecharge.Spartan",
	channel = CHAN_AUTO,
	volume = 1,
	level = 80,
	sound = ")taconbanana/halo/shield/recharge_spartan.wav"
})
