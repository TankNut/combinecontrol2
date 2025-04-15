local setUserGroup = console.AddCommand("rpa_setusergroup", function(ply, steamID, usergroup)
	if IsValid(ply) and IsElevatedUserGroup(usergroup) then
		console.Feedback(ply, "ERROR", "Elevated access can only be changed from the server console")

		return
	end

	local target = player.GetBySteamID(steamID)

	if target then
		target:SetUserGroup(usergroup)

		console.Feedback(target, "NOTICE", "%s has set your usergroup to %s", ply, usergroup)
	else
		if IsElevatedUserGroup(PlayerVar.GetOffline(steamID, "UserGroup")) then
			console.Feedback(ply, "ERROR", "Elevated access can only be changed from the server console")

			return
		end

		PlayerVar.SetOffline(steamID, "UserGroup", usergroup)
	end

	console.Feedback(ply, "NOTICE", "You've set %s's usergroup to %s", target and target:Nick() or steamID, usergroup)

	Log.Write("superadmin_setusergroup",
		ply,
		target or {
			Nick = function() return steamID end,
			SteamID = function() return steamID end,
		},
		usergroup)
end)

setUserGroup:SetCategory("Superadmin Commands")
setUserGroup:SetDescription("Updates a player's assigned permission group")
setUserGroup:SetExecutionContext(console.Server)
setUserGroup:SetAccess(console.IsSuperAdmin)

setUserGroup:AddParameter(console.SteamID({
	StrictImmunity = true,
	NoSelfTarget = true
}))

setUserGroup:AddParameter(console.String({
	validate.InList({"user", "admin", "superadmin", "developer"})
}))

local setUserAlias = console.AddCommand("rpa_setuseralias", function(ply, steamID, alias)
	local target = player.GetBySteamID(steamID)
	local name = target and target:Nick() or steamID

	PlayerVar.SetOffline(steamID, "Alias", alias)

	if alias == "" then
		console.Feedback(ply, "NOTICE", "You've removed %s's alias", name)
	else
		console.Feedback(ply, "NOTICE", "You've set %s's alias to %s", name, alias)
	end
end)

setUserAlias:SetCategory("Superadmin Commands")
setUserAlias:SetDescription("Updates a player's alias on the admin roster")
setUserAlias:SetExecutionContext(console.Server)
setUserAlias:SetAccess(console.IsSuperAdmin)

setUserAlias:AddParameter(console.SteamID({
	StrictImmunity = true
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
	CheckImmunity = true
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
	CheckImmunity = true
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

	Chat.Send("NOTICE", ply:Nick() .. " exploded " .. target:Nick())
end)

explode:SetCategory("Superadmin Commands")
explode:SetDescription("Explodes a player for some reason")
explode:SetExecutionContext(console.Server)
explode:SetAccess(console.IsSuperAdmin)

explode:AddParameter(console.Player({
	SingleTarget = true
}))

local giveTempAdmin = console.AddCommand("rpa_givetempadmin", function(ply, target)
	if target:IsAdmin() then
		console.Feedback(ply, "ERROR", "%s already has administrator access", target)

		return
	end

	Log.Write("superadmin_givetempadmin", ply, target)

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

	Log.Write("superadmin_taketempadmin", ply, target)

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

local noDamage = console.AddCommand("rpa_nodamage", function(ply, targets, bool)
	local action = bool and "given you godmode" or "taken your godmode"
	local feedback = bool and "given godmode to" or "taken godmode from"

	for _, target in ipairs(targets) do
		target:SetNoDamage(bool)

		console.Feedback(target, "NOTICE", "%s has %s", ply, action)

		Log.Write("superadmin_player_set", ply, target, "NoDamage", tostring(bool))
	end

	if #targets > 1 then
		console.Feedback(ply, "NOTICE", "You've %s %d players", feedback, #targets)
	else
		console.Feedback(ply, "NOTICE", "You've %s %s", feedback, targets[1])
	end
end)

noDamage:SetCategory("Superadmin Commands")
noDamage:SetDescription("Enables or disables a player's godmode")
noDamage:SetExecutionContext(console.Server)
noDamage:SetAccess(console.IsSuperAdmin)

noDamage:AddParameter(console.Player())
noDamage:AddOptional(console.Bool(), false)

local setOwner = console.AddCommand("rpa_setcharowner", function(ply, id, steamid)
	local data = Character.Fetch(id)

	if not data then
		console.Feedback(ply, "ERROR", "That character doesn't exist")

		return
	end

	if data.SteamID == steamid then
		console.Feedback(ply, "ERROR", "That character is already owned by that player")

		return
	end

	-- if Character.GetByID(id) then inform them
	-- if player.GetBySteamID then also inform

	Character.SetOwner(id, steamid)
end)

setOwner:SetCategory("Superadmin Commands")
setOwner:SetDescription("Changes ownership of an character")
setOwner:SetExecutionContext(console.Server)
setOwner:SetAccess(console.IsSuperAdmin)
