function EFFECT:Init(data)
	self.Ent = data:GetEntity()

	if not IsValid(self.Ent) then
		return
	end

	self.Emitter = ParticleEmitter(self.Ent:WorldSpaceCenter())
	self.NextParticle = CurTime()
end

function EFFECT:Think()
	local ent = self.Ent

	if not IsValid(ent) then
		if self.Emitter then
			self.Emitter:Finish()
		end

		return false
	end

	local pos = ent:WorldSpaceCenter()

	self.Emitter:SetPos(pos)

	if self.NextParticle <= CurTime() then
		for i = 1, 3 do
			local particle = self.Emitter:Add("effects/draconic_halo/energy/energy_electricarc", pos)

			particle:SetRoll(math.Rand(0, 360))

			particle:SetLifeTime(math.Rand(0.05, 0.5))
			particle:SetDieTime(math.Rand(0.1, 1.2))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(math.random(3, 15))
			particle:SetEndSize(0)

			particle:SetColor(0, 255, 0)

			particle:SetVelocity(VectorRand() * math.Rand(35, 125))
			particle:SetAngleVelocity(Angle(4.3, 14.1, 0.2))
			particle:SetAirResistance(0)

			particle:SetCollide(true)
		end

		self.NextParticle = CurTime() + 0.066
	end

	return true
end

function EFFECT:Render()
end
