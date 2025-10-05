local CLASS = CustomMetaTable("Transition")

AccessorFunc(CLASS, "StartPoint", "StartPoint")
AccessorFunc(CLASS, "EndPoint", "EndPoint")

AccessorFunc(CLASS, "StartTime", "StartTime")
AccessorFunc(CLASS, "EndTime", "EndTime")

AccessorFunc(CLASS, "Ease", "Ease")
AccessorFunc(CLASS, "Lerp", "Lerp")

AccessorFunc(CLASS, "ConstantRate", "ConstantRate")

-- Uncapped lerp
local function lerp(fraction, from, to)
	return from + (to - from) * fraction
end

local function lerpColor(fraction, from, to)
	return Color(
		lerp(fraction, from.r, to.r),
		lerp(fraction, from.g, to.g),
		lerp(fraction, from.b, to.b),
		lerp(fraction, from.a, to.a)
	)
end

function CLASS:Initialize()
	self.StartPoint = 0
	self.EndPoint = 1

	self.StartTime = CurTime()
	self.EndTime = CurTime() + 1

	self.Ease = nil
	self.Lerp = nil

	self.Duration = 1
	self.Range = {0, 1}
	self.ConstantRate = 0

	self.Drift = false
	self.Finished = false
end

function CLASS:SetVectorMode()
	self.StartPoint = Vector()
	self.EndPoint = Vector(0, 0, 1)

	self.Range = {Vector(), Vector(0, 0, 1)}
end

function CLASS:SetAngleMode()
	self.StartPoint = Angle()
	self.EndPoint = Angle(0, 360, 0)

	self.Range = {Angle(), Angle(0, 360, 0)}
end

function CLASS:SetColorMode()
	self.StartPoint = Color(0, 0, 0)
	self.EndPoint = Color(255, 255, 255)

	self.Range = {Color(0, 0, 0), Color(255, 255, 255)}
end

function CLASS:Get()
	local time = CurTime()
	local fraction = math.TimeFraction(self.StartTime, self.EndTime, time)

	if self.Drift then
		while fraction >= 1 do
			self:SetStartPoint(self:GetEndPoint())
			self:SetEndPoint(self:GetNextTarget())

			local duration = self:ApplyConstantRate(self:GetNextDuration())

			self:SetStartTime(time)
			self:SetEndTime(time + duration)

			fraction = fraction - 1

			self.Finished = true
		end
	else
		fraction = math.Clamp(fraction, 0, 1)
	end

	local lerpFunction = self.Lerp

	if lerpFunction == nil then
		if isvector(self.StartPoint) then
			lerpFunction = LerpVector
		elseif isangle(self.StartPoint) then
			lerpFunction = LerpAngle
		elseif IsColor(self.StartPoint) then
			lerpFunction = lerpColor
		else
			lerpFunction = lerp
		end
	end

	if isfunction(self.Ease) then
		return lerpFunction(self.Ease(fraction), self.StartPoint, self.EndPoint)
	elseif self.Ease == false then
		return self.EndPoint
	else
		return lerpFunction(fraction, self.StartPoint, self.EndPoint)
	end
end

function CLASS:GoalReached()
	local value = CurTime() >= self.EndTime

	if self.Drift and value == false then
		value = self.Finished
	end

	self.Finished = false

	return value
end

function CLASS:Update(target, duration)
	if target == nil then
		target = self:GetNextTarget()
	end

	if duration == nil then
		duration = self:GetNextDuration()
	end

	duration = self:ApplyConstantRate(duration)

	local time = CurTime()

	self:SetStartPoint(self:Get())
	self:SetEndPoint(target)

	self:SetStartTime(time)
	self:SetEndTime(time + duration)
end

function CLASS:EnableDrift(bool)
	self.Drift = bool
end

function CLASS:SetConstantRate(mult)
	self.ConstantRate = mult

	self:Update(self.EndPoint, self:GetRemainingTime())
end

function CLASS:ApplyConstantRate(duration)
	if self.ConstantRate == 0 then
		return duration
	end

	local range = math.Distance(self.Range[1], self.Range[2])
	local distance = math.Distance(self:GetStartPoint(), self:GetEndPoint())

	return duration * (distance / range) / self.ConstantRate
end

function CLASS:GetRemainingTime()
	return self.EndTime - CurTime()
end

function CLASS:GetDuration()
	return self.EndTime - self.StartTime
end

function CLASS:GetNextDuration()
	return istable(self.Duration) and math.Rand(self.Duration[1], self.Duration[2]) or self.Duration
end

function CLASS:GetNextTarget()
	if isvector(self.StartPoint) then
		return Vector(
			math.Rand(self.Range[1].x, self.Range[2].x),
			math.Rand(self.Range[1].y, self.Range[2].y),
			math.Rand(self.Range[1].z, self.Range[2].z)
		)
	elseif isangle(self.StartPoint) then
		return Angle(
			math.Rand(self.Range[1].p, self.Range[2].p),
			math.Rand(self.Range[1].y, self.Range[2].y),
			math.Rand(self.Range[1].r, self.Range[2].r)
		)
	elseif IsColor(self.StartPoint) then
		return Color(
			math.random(self.Range[1].r, self.Range[2].r),
			math.random(self.Range[1].g, self.Range[2].g),
			math.random(self.Range[1].b, self.Range[2].b),
			math.random(self.Range[1].a, self.Range[2].a)
		)
	else
		return math.Rand(self.Range[1], self.Range[2])
	end
end

function CLASS:SetPoints(startpoint, endpoint)
	self:SetStartPoint(startpoint)
	self:SetEndPoint(endpoint)
end

function CLASS:SetDuration(min, max)
	if max == nil then
		self.Duration = min
	else
		self.Duration = {min, max}
	end
end

function CLASS:SetRange(min, max)
	self.Range = {min, max}
end

function util.Transition()
	local instance = setmetatable({}, CLASS)
	instance:Initialize()

	return instance
end
