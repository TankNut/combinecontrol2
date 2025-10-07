local BaseClass = inherit.Get("buff", "base")

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

	mv:LimitSpeed(Lerp(fraction, crouchSpeed, self.Player:GetRunSpeed()))
end

-- if SERVER then
-- 	hook.Add("OnTakeFallDamage", "cc2.BrokenLegs", function(ply, damage)
-- 		ply:AddBuff("broken_legs", {
-- 			Duration = math.min(damage, 20)
-- 		})
-- 	end)

-- 	hook.Add("PostEntityTakeDamage", "cc2.BrokenLegs", function(ply, dmg, took)
-- 		if not ply:IsPlayer() or not took or not bit.Check(dmg:GetDamageType(), DMG_BULLET) then
-- 			return
-- 		end

-- 		local hitgroup = ply:LastHitGroup()

-- 		if hitgroup != HITGROUP_LEFTLEG and hitgroup != HITGROUP_RIGHTLEG then
-- 			return
-- 		end

-- 		ply:AddBuff("broken_legs", {
-- 			Duration = math.min(dmg:GetDamage(), 10)
-- 		})
-- 	end)
-- end
