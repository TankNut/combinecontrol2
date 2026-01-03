local BUFF = {}

BUFF.RemoveOnDeath = false
BUFF.RemoveOnHeal = false -- Not yet implemented

BUFF.Duration = 0 -- If set, removes a stack every X seconds
BUFF.Interval = 0 -- If set, calls BUFF:OnTick every X seconds

function BUFF:Initialize()
end

function BUFF:Duplicate(stacks, time)
	self:AddStacks(stacks)
end

function BUFF:OnStacksAdded(amount)
end

function BUFF:OnStacksRemoved(amount)
end

function BUFF:AddStacks(amount)
	self.Stacks = self.Stacks + amount
	self:OnStacksAdded(amount)
end

function BUFF:RemoveStacks(amount)
	self.Stacks = self.Stacks - amount
	self:OnStacksRemoved(amount)

	if self.Stacks <= 0 then
		self:Remove()
	end
end

function BUFF:OnTick()
end

function BUFF:OnExpire()
	self:RemoveStacks(1)
end

function BUFF:Think()
	self:CheckTimers()
end

function BUFF:TimeLeft()
	if self.Duration > 0 then
		local time = CurTime() - self.LastTimer

		return self.Duration - time
	end

	return 0
end

function BUFF:TickTimeLeft()
	if self.Interval > 0 then
		local time = CurTime() - self.LastTimer

		return self.Interval - time
	end

	return 0
end

function BUFF:CheckTimers()
	if self.Interval > 0 and CurTime() - self.LastTick >= self.Interval then
		self.LastTick = CurTime()
		self:OnTick()
	end

	if self.Duration > 0 and CurTime() - self.LastTimer >= self.Duration then
		self.LastTimer = CurTime()
		self:OnExpire()
	end
end

function BUFF:OnRemove()
end

function BUFF:Remove()
	self:OnRemove()
	self.Player:GetBuffs()[self.ClassName] = nil
end

inherit.Register("buff", "base", BUFF)
