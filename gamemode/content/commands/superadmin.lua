local setUserGroup = console.AddCommand("rpa_setusergroup", function(ply, steamId, usergroup)
	if IsValid(ply) and (usergroup == "superadmin" or usergroup == "developer") then
		console.Feedback(ply, "ERROR", "Elevated access must be set from the server console")

		return
	end

	local target = player.GetBySteamID(steamId)

	if target then
		target:SetUserGroup(usergroup)
		target:SetTempAdmin(false)

		console.Feedback(target, "NOTICE", "%s has set your usergroup to %s", ply, usergroup)
	else
		local query = GAMEMODE.Database:Select("rp_players")
			query:Select("UserGroup")
			query:WhereEqual("SteamID", steamId)
		local data = query:Execute()
		data = data[1] and data[1] or nil

		if data and data.UserGroup and not ply:CanTargetUserGroup(data.UserGroup, true) then
			console.Feedback(ply, "ERROR", "You cannot modify %s's %s usergroup", steamId, data.UserGroup)

			return
		end

		local upsert = GAMEMODE.Database:Upsert("rp_players")
		upsert:Insert("SteamID", steamId)

		if usergroup == "user" then
			upsert:InsertRaw("UserGroup", "NULL")
		else
			upsert:Insert("UserGroup", usergroup)
		end

		upsert:Execute()
	end

	console.Feedback(ply, "NOTICE", "You've set %s's usergroup to %s", target and target:Nick() or steamId, usergroup)
	-- TODO: Log this, one of the logging system is setup.
end)

setUserGroup:SetCategory("Superadmin Commands")
setUserGroup:SetDescription("Updates a player's assigned permission group")
setUserGroup:SetExecutionContext(console.Server)
setUserGroup:SetAccess(console.IsSuperAdmin)

setUserGroup:AddParameter(console.SteamID({
	SingleTarget = true,
	StrictImmunity = true,
	NoSelfTarget = true,
	Online = false
}))

setUserGroup:AddParameter(console.String({
	validate.InList({"user", "admin", "superadmin", "developer"})
}))

local setUserAlias = console.AddCommand("rpa_setuseralias", function(ply, steamId, alias)
	local target = player.GetBySteamID(steamId)
	local name = target and target:Nick() or steamId

	if target then
		target:SetUserAlias(alias)
	else
		local query = GAMEMODE.Database:Upsert("rp_players")
			query:Insert("SteamID", steamId)
			query:Insert("UserAlias", alias)
		query:Execute()
	end

	console.Feedback(ply, "NOTICE", "You've set %s's user alias to %s", name, alias)
end)

setUserAlias:SetCategory("Superadmin Commands")
setUserAlias:SetDescription("Updates a player's alias on the admin roster")
setUserAlias:SetExecutionContext(console.Server)
setUserAlias:SetAccess(console.IsSuperAdmin)

setUserAlias:AddParameter(console.SteamID({
	SingleTarget = true,
	StrictImmunity = true,
	NoSelfTarget = false,
	Online = false
}))

setUserAlias:AddParameter(console.String({
	validate.Max(32),
}))

local giveBadge = console.AddCommand("rpa_givebadge", function(ply, target, badge)
	if target:HasBadge(badge) then
		console.Feedback(ply, "ERROR", "%s already has this badge", target)

		return
	end

	target:GiveBadge(badge)

	console.Feedback(ply, "NOTICE", "You've given %s the %s badge", target, badge)
	console.Feedback(target, "NOTICE", "%s has given you the %s badge", ply, badge)
end)

giveBadge:SetCategory("Superadmin Commands")
giveBadge:SetDescription("Assigns a scoreboard badge to a player")
giveBadge:SetExecutionContext(console.Server)
giveBadge:SetAccess(console.IsSuperAdmin)

giveBadge:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

giveBadge:AddParameter(console.Badge())

local takeBadge = console.AddCommand("rpa_takebadge", function(ply, target, badge)
	if not target:HasBadge(badge) then
		console.Feedback(ply, "ERROR", "%s does not have this badge", target)

		return
	end

	target:TakeBadge(badge)

	console.Feedback(ply, "NOTICE", "You've taken %s's %s badge", target, badge)
	console.Feedback(target, "NOTICE", "%s has taken your %s badge", ply, badge)
end)

takeBadge:SetCategory("Superadmin Commands")
takeBadge:SetDescription("Removes a scoreboard badge from a player")
takeBadge:SetExecutionContext(console.Server)
takeBadge:SetAccess(console.IsSuperAdmin)

takeBadge:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

takeBadge:AddParameter(console.Badge())

local explode = console.AddCommand("rpa_explode", function(ply, target)
	target:Kill()

	local explosion = ents.Create("env_explosion")
	explosion:SetPos(target:GetPos())
	explosion:SetKeyValue("iMagnitude", 0)
	explosion:Spawn()
	explosion:Activate()
	explosion:Fire("Explode")

	GAMEMODE:WriteLog("admin_explode", {Admin = GAMEMODE:LogPlayer(ply), Ply = GAMEMODE:LogPlayer(target), Char = GAMEMODE:LogCharacter(target)})
	Chat.Send("NOTICE", ply:Nick() .. " exploded " .. target:Nick())
end)

explode:SetCategory("Superadmin Commands")
explode:SetDescription("Explodes a player for some reason")
explode:SetExecutionContext(console.Server)
explode:SetAccess(console.IsSuperAdmin)

explode:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = false
}))

local giveTempAdmin = console.AddCommand("rpa_givetempadmin", function(ply, target)
	if target:IsAdmin() then
		console.Feedback(ply, "ERROR", "%s already has administrator access", target)

		return
	end

	target:SetTempAdmin(true)

	Chat.Send("NOTICE", string.format("%s has given temporary admin to %s.", IsValid(ply) and ply:Nick() or "CONSOLE", target:Nick()), player.GetAdmins())
end)

giveTempAdmin:SetCategory("Superadmin Commands")
giveTempAdmin:SetDescription("Gives a player temporary admin access")
giveTempAdmin:SetExecutionContext(console.Server)
giveTempAdmin:SetAccess(console.IsSuperAdmin)

giveTempAdmin:AddParameter(console.Player({
	SingleTarget = true,
	StrictImmunity = true,
	NoSelfTarget = true
}))

local takeTempAdmin = console.AddCommand("rpa_taketempadmin", function(ply, target)
	if not target:TempAdmin() then
		console.Feedback(ply, "ERROR", "%s is not a temporary administrator", target)

		return
	end

	target:SetTempAdmin(false)

	Chat.Send("NOTICE", string.format("%s has taken temporary admin from %s.", IsValid(ply) and ply:Nick() or "CONSOLE", target:Nick()), player.GetAdmins())
end)

takeTempAdmin:SetCategory("Superadmin Commands")
takeTempAdmin:SetDescription("Revokes a player's temporary admin access")
takeTempAdmin:SetExecutionContext(console.Server)
takeTempAdmin:SetAccess(console.IsSuperAdmin)

takeTempAdmin:AddParameter(console.Player({
	SingleTarget = true,
	StrictImmunity = true,
	NoSelfTarget = true
}))
