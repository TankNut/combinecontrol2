hook.Add("LoadContent", "broken_legs", function()
	-- Why do we have to navigate from _core.lua...
	buff.RegisterFile("plugins/broken_legs/buff_broken_legs.lua")
end)

if SERVER then
	hook.Add("OnTakeFallDamage", "broken_legs", function(ply, damage)
		ply:AddBuff("broken_legs", {
			Duration = math.min(damage, 20)
		})
	end)

	hook.Add("PostEntityTakeDamage", "broken_legs", function(ply, dmg, took)
		if not ply:IsPlayer() or not took or not bit.Check(dmg:GetDamageType(), DMG_BULLET) then
			return
		end

		local hitgroup = ply:LastHitGroup()

		if hitgroup != HITGROUP_LEFTLEG and hitgroup != HITGROUP_RIGHTLEG then
			return
		end

		ply:AddBuff("broken_legs", {
			Duration = math.min(dmg:GetDamage(), 10)
		})
	end)
end
