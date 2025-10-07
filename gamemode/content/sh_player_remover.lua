Config.Fallback("RemovePlayers", TOOLTRUST_DEVELOPER)

function RemovePlayer(target, ply, tr)
	-- Since the remover tool blocks internally on players, we have to re-create the effects ourselves
	local effectData = EffectData()
		effectData:SetOrigin(target:GetPos())
		effectData:SetEntity(target)

	util.Effect("entity_remove", effectData, true, true)

	-- Putting this behind a check so we can call RemovePlayer(target, ply) from other contexts
	if tr then
		local weapon = ply:GetActiveWeapon()

		if IsValid(weapon) and weapon:GetClass() == "gmod_tool" then
			weapon:DoShootEffect(tr.HitPos, tr.HitNormal, target, tr.PhysicsBone, IsFirstTimePredicted())
		end
	end

	if SERVER then
		local name = console.PlayerName(ply)
		local targetName = console.RPName(target)

		target:Kick("Kicked by " .. name)

		Chat.Send("NOTICE", string.format("%s has removed %s.", name, targetName))
	end
end

-- Want this to run after permission checks but before any logging hooks so we can block the normal toolgun log
hook.Add("CanTool", "cc2.PlayerRemover", function(args, ply, tr, tool)
	local ok = args[2]
	local ent = tr.Entity

	if not ok or tool != "remover" then
		return
	end

	if ply:GetToolTrust() < Config.Get("RemovePlayers") then
		return
	end

	if not IsValid(ent) or not ent:IsPlayer() then
		return
	end

	RemovePlayer(ent, ply, tr)

	-- Return false to pretend our toolgun got blocked for logging purposes
	return false
end, POST_HOOK_RETURN)
