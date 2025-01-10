BUFF.RemoveOnDeath = false
BUFF.RemoveOnHeal = false -- Not yet implemented

function BUFF:Initialize(data)
	self.Timers = {}
	self.Stacks = 0
end

function BUFF:OnDuplicate(data)
end

function BUFF:OnStacksAdded(amount)
end

function BUFF:AddStacks(amount)
	self.Stacks = self.Stacks + amount
	self:OnStacksAdded(amount)
end

function BUFF:OnStacksRemoved(amount)
end

function BUFF:OnStacksDepleted()
	self:Remove()
end

function BUFF:RemoveStacks(amount)
	self.Stacks = self.Stacks - amount
	self:OnStacksRemoved(amount)

	if self.Stacks == 0 then
		self:OnStacksDepleted()
	end
end

-- Mini metatable for some timer-related helpers
local meta = {}
meta.__index = meta

function meta:TimeElapsed()
	return CurTime() - self.Start
end

function meta:TimeLeft()
	if not self.Duration then
		return
	end

	return self.Duration - self:TimeElapsed()
end

function meta:TimeFraction()
	if not self.Duration then
		return
	end

	return math.TimeFraction(self.Start, self.Start + self.Duration, CurTime())
end

function meta:IntervalElapsed()
	return CurTime() - self.LastTick
end

function meta:IntervalLeft()
	if not self.TickInterval then
		return
	end

	return self.TickInterval - self:IntervalElapsed()
end

function meta:IntervalFraction()
	if not self.TickInterval then
		return
	end

	return math.TimeFraction(self.LastTick, self.LastTick + self.TickInterval, CurTime())
end

function BUFF:AddTimer(name, start, duration, tickInterval, data)
	local index = name or #self.Timers + 1

	self.Timers[index] = setmetatable({
		Index = index,

		Start = start,
		Duration = duration,

		LastTick = start,
		TickInterval = tickInterval,

		Data = data or {}
	}, meta)

	return index
end

function BUFF:GetTimer(name)
	return self.Timers[name]
end

function BUFF:RemoveTimer(name)
	self.Timers[name] = nil
end

function BUFF:OnTimer(index, data)
end

function BUFF:OnTick(index, data)
end

function BUFF:CheckTimers()
	for k, data in pairs(self.Timers) do
		if data.TickInterval and CurTime() - data.LastTick >= data.TickInterval then
			data.LastTick = data.LastTick + data.TickInterval
			self:OnTick(data.Index, data.Data)
		end

		if data.Duration and CurTime() - data.Start >= data.Duration then
			self.Timers[k] = nil
			self:OnTimer(data.Index, data.Data)
		end
	end
end

function BUFF:Think()
	self:CheckTimers()
end

function BUFF:OnExpire()
end

function BUFF:OnRemove()
end

function BUFF:Remove(force)
	if not force then
		self:OnExpire()
	end

	self:OnRemove()
	self.Player:GetBuffs()[self.ClassName] = nil
end
