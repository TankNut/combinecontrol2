local setUserGroup = console.AddCommand("rpa_setusergroup", function(ply, target, usergroup)
	if IsValid(ply) and (usergroup == "superadmin" or usergroup == "developer") then
		console.PrintError(ply, "Elevated access must be set from the server console")

		return
	end

	target:SetUserGroup(usergroup)

	console.PrintMessage(ply, "You've set %s's usergroup to %s", target, usergroup)
	console.PrintMessage(target, "%s has set your usergroup to %s", ply, usergroup)

	-- TODO: Log this, one of the logging system is setup.
end)
setUserGroup:SetAccess(console.IsSuperAdmin)
setUserGroup:SetExecutionContext(console.Server)
setUserGroup:SetDescription("Updates a player's assigned permission group")
setUserGroup:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = true,
}))
setUserGroup:AddParameter(console.String({
	validate.InList({ "user", "admin", "superadmin", "developer" })
}))
