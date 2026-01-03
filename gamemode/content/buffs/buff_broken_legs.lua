BUFF.RemoveOnDeath = true

BUFF.Duration = 10

function BUFF:Initialize()
	if SERVER then
		self.Player:EmitSound("Flesh.Break")
	end
end

function BUFF:Duplicate(stacks, time)
	if SERVER then
		self.Player:EmitSound("Flesh.Break")
	end

	self.LastTimer = time
end

function BUFF:SetupMove(mv, cmd)
	local ply = self.Player
	local fraction = 1 - (self:TimeLeft() / self.Duration)

	mv:LimitSpeed(Lerp(fraction, ply:GetWalkSpeed() * ply:GetCrouchedWalkSpeed(), ply:GetRunSpeed()))
end

-- if SERVER then
-- 	hook.Add("OnTakeFallDamage", "cc2.BrokenLegs", function(ply, damage)
-- 		ply:AddBuff("broken_legs")
-- 	end)

-- 	hook.Add("PostEntityTakeDamage", "cc2.BrokenLegs", function(ply, dmg, took)
-- 		if not ply:IsPlayer() or not took or not bit.Check(dmg:GetDamageType(), DMG_BULLET) then
-- 			return
-- 		end

-- 		local hitgroup = ply:LastHitGroup()

-- 		if hitgroup != HITGROUP_LEFTLEG and hitgroup != HITGROUP_RIGHTLEG then
-- 			return
-- 		end

-- 		ply:AddBuff("broken_legs")
-- 	end)
-- end
