function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal()

	local emitter = ParticleEmitter(pos)

	local function getNormal()
		local dir = Vector(normal)
		dir:Rotate(Angle(math.Rand(-45, 45), math.Rand(-45, 45), math.Rand(-45, 45)))

		return dir
	end

	for i = 1, 7 do
		local particle = emitter:Add("effects/draconic_halo/flash_large", pos)

		if particle then
			particle:SetDieTime(.2)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(10)
			particle:SetEndSize(20)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetAngleVelocity(Angle(15))

			particle:SetColor(0, 255, 50)

			particle:SetGravity(Vector(0, 0, 0))
			particle:SetAirResistance(-68.167394537726)

			particle:SetCollide(true)
			particle:SetBounce(0.1419790559388)
		end
	end

	for i = 1, 3 do
		local dir = getNormal()
		local particle = emitter:Add("effects/draconic_halo/flash_soft", pos + dir * 6)

		if particle then
			particle:SetVelocity(dir * math.Rand(250, 500))

			particle:SetLifeTime(math.Rand(0.05, 0.5))
			particle:SetDieTime(math.Rand(1, 3))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(1)
			particle:SetEndSize(0)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetAngleVelocity(AngleRand(-20, 20))

			particle:SetColor(0, 255, 0)

			particle:SetGravity(Vector(0, 0, -400))
			particle:SetAirResistance(0)

			particle:SetCollide(true)
			particle:SetBounce(0)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
