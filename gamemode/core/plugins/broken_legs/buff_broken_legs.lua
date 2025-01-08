DEFINE_BASECLASS("buff_base")

BUFF.RemoveOnDeath = true
BUFF.Duration = 10

function BUFF:Initialize(data)
	BaseClass.Initialize(self, data)

	self:BreakLegs(data)
end

function BUFF:OnDuplicate(data)
	self:BreakLegs(data)
end

function BUFF:BreakLegs(data)
	if SERVER then
		self.Player:EmitSound("Flesh.Break")
	end

	local time = self:GetTimer(1)
	local duration = data.Duration or self.Duration

	-- Only reset the timer if the new length is longer than the old
	if time and time:TimeLeft() > duration then
		return
	end

	self:AddTimer(1, data.CurTime, duration)
end

function BUFF:OnTimer(index, data)
	self:Remove()
end

function BUFF:Move(mv)
	local data = self:GetTimer(1)

	local fraction = data:TimeFraction()
	local crouchSpeed = self.Player:GetWalkSpeed() * self.Player:GetCrouchedWalkSpeed()
	local maxSpeed = Lerp(fraction, crouchSpeed, self.Player:GetRunSpeed())

	local speed = math.min(mv:GetMaxSpeed(), maxSpeed)

	mv:SetMaxSpeed(speed)
	mv:SetMaxClientSpeed(speed)
end
