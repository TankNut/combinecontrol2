local colorTable = {
	-- Plasma Rifle
	[1] = {Color(0, 125, 255), Color(0, 150, 200), Color(0, 180, 200)},
	-- Brute Plasma Rifle
	[2] = {Color(255, 90, 0), Color(255, 150, 0), Color(200, 80, 0)}
}

function EFFECT:Init(data)
	self:SetRenderMode(RENDERMODE_WORLDGLOW)

	local pos = data:GetOrigin()
	local normal = data:GetNormal()
	local colors = colorTable[data:GetFlags()] or colorTable[1]
	local scale = data:GetScale()

	local emitter = ParticleEmitter(pos)

	local function getNormal()
		local dir = Vector(normal)
		dir:Rotate(Angle(math.Rand(-45, 45), math.Rand(-45, 45), math.Rand(-45, 45)))

		return dir
	end

	for i = 1, 7 do
		local particle = emitter:Add("effects/draconic_halo/energy/energy_plasmaimpact0", pos)

		if particle then
			particle:SetDieTime(.2)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(math.Rand(15,30) * scale)
			particle:SetEndSize(math.Rand(2, 5) * scale)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetAngleVelocity(Angle(15))

			particle:SetColor(colors[1]:Unpack())

			particle:SetGravity(Vector(0, 0, 0))
			particle:SetAirResistance(-68.167394537726)

			particle:SetCollide(true)
			particle:SetBounce(0.1419790559388)
		end
	end

	for i = 1, 3 do
		local dir = getNormal()
		local particle = emitter:Add("effects/draconic_halo/flash_soft", pos + dir * 6 * scale)

		if particle then
			particle:SetVelocity(dir * math.Rand(250, 500) * scale)

			particle:SetLifeTime(math.Rand(0.05, 0.5))
			particle:SetDieTime(math.Rand(1, 6))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(2 * scale)
			particle:SetEndSize(0)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetAngleVelocity(AngleRand(-20, 20))

			particle:SetColor(colors[2]:Unpack())

			particle:SetGravity(Vector(0, 0, -600))
			particle:SetAirResistance(50)

			particle:SetCollide(true)
			particle:SetBounce(0)
		end
	end

	for i = 1, math.random(7) do
		local dir = getNormal()
		local particle = emitter:Add("effects/draconic_halo/energy/energy_plasmaimpactlong1", pos + dir * 6 * scale)

		if particle then
			particle:SetVelocity(dir * math.Rand(35, 225) * scale)

			particle:SetLifeTime(math.Rand(0.05, 0.5))
			particle:SetDieTime(math.Rand(1, 3))

			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)

			particle:SetStartSize(2 * scale)
			particle:SetEndSize(0)

			particle:SetStartLength(math.Rand(15, 35) * scale)
			particle:SetEndLength(math.Rand(3, 6) * scale)

			particle:SetColor(colors[3]:Unpack())

			particle:SetGravity(Vector(0, 0, math.Rand(-700, -900)))
			particle:SetAirResistance(0)

			particle:SetCollide(true)
			particle:SetBounce(0.8)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
