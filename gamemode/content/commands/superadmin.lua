local setUserGroup = console.AddCommand("rpa_setusergroup", function(ply, target, usergroup)
	if IsValid(ply) and (usergroup == "superadmin" or usergroup == "developer") then
		console.Feedback(ply, "ERROR", "Elevated access must be set from the server console")

		return
	end

	target:SetUserGroup(usergroup)

	console.Feedback(ply, "WARNING", "You've set %s's usergroup to %s", target, usergroup)
	console.Feedback(target, "WARNING", "%s has set your usergroup to %s", ply, usergroup)

	-- TODO: Log this, one of the logging system is setup.
end)

setUserGroup:SetDescription("Updates a player's assigned permission group")
setUserGroup:SetExecutionContext(console.Server)
setUserGroup:SetAccess(console.IsSuperAdmin)

setUserGroup:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = true
}))

setUserGroup:AddParameter(console.String({
	validate.InList({"user", "admin", "superadmin", "developer"})
}))

local giveBadge = console.AddCommand("rpa_givebadge", function(ply, target, badge)
	local badgeId = _G["BADGE_" .. string.upper(badge)]

	if target:HasBadge(badgeId) then
		console.Feedback(ply, "ERROR", "%s already has this badge", target)

		return
	end

	target:SetScoreboardBadges(target:ScoreboardBadges() + badgeId)

	console.Feedback(ply, "WARNING", "You've given %s the %s badge", target, badge)
	console.Feedback(target, "WARNING", "%s has given you the %s badge", ply, badge)
end)

giveBadge:SetDescription("Assigns a scoreboard badge to a player")
giveBadge:SetExecutionContext(console.Server)
giveBadge:SetAccess(console.IsSuperAdmin)

giveBadge:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

giveBadge:AddParameter(console.String({
	validate.InList({"betatest", "betascr", "bugger"})
}))

local takeBadge = console.AddCommand("rpa_takebadge", function(ply, target, badge)
	local badgeId = _G["BADGE_" .. string.upper(badge)]

	if not target:HasBadge(badgeId) then
		console.Feedback(ply, "ERROR", "%s does not have this badge", target)

		return
	end

	target:SetScoreboardBadges(target:ScoreboardBadges() - badgeId)

	console.Feedback(ply, "WARNING", "You've taken %s's %s badge", target, badge)
	console.Feedback(target, "WARNING", "%s has taken your %s badge", ply, badge)
end)

takeBadge:SetDescription("Removes a scoreboard badge from a player")
takeBadge:SetExecutionContext(console.Server)
takeBadge:SetAccess(console.IsSuperAdmin)

takeBadge:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

takeBadge:AddParameter(console.String({
	validate.InList({"betatest", "betascr", "bugger"})
}))

local explode = console.AddCommand("rpa_explode", function(ply, target)
	target:Kill()

	local explosion = ents.Create("env_explosion")
	explosion:SetPos(target:GetPos())
	explosion:SetKeyValue("iMagnitude", 0)
	explosion:Spawn()
	explosion:Activate()
	explosion:Fire("Explode")

	GAMEMODE:WriteLog("admin_explode", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target)})
	Chat.Send(player.GetAll(), "WARNING", ply:Nick() .. " exploded " .. target:Nick())
end)

explode:SetDescription("Explodes a player for some reason")
explode:SetExecutionContext(console.Server)
explode:SetAccess(console.IsSuperAdmin)

explode:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))
