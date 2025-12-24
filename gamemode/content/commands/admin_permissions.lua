local listPermissions = console.AddCommand("rpa_permissions_list", function(ply, target)
	local permissions = target:Permissions()
	local lines = {string.format("<c=white>-- Permissions for: %s (%s) --</c>", target:Nick(), target:SteamID())}

	local manual = {}
	local automatic = {}

	for id, data in SortedPairs(Permissions.List) do
		local text = string.format("  %s - %s", id, data.Description)

		if target:IsSuperAdmin() or (data.Callback and data.Callback(target)) then
			table.insert(automatic, text)
		elseif permissions[id] then
			table.insert(manual, text)
		end
	end

	if #manual == 0 and #automatic == 0 then
		table.insert(lines, "<c=red>This player does not have any permissions assigned</c>")
	end

	if #manual > 0 then
		table.insert(lines, "<c=lime>Assigned Permissions:</c>")
		table.Add(lines, manual)
	end

	if #automatic > 0 then
		table.insert(lines, "<c=yellow>Automatic Permissions:</c>")
		table.Add(lines, automatic)
	end

	console.Feedback(ply, "CONSOLE", table.concat(lines, "\n"))
end)

listPermissions:SetCategory("Permissions")
listPermissions:SetDescription("Lists all of the permissions a player has")
listPermissions:SetExecutionContext(console.Server)
listPermissions:SetAccess(console.IsAdmin)

listPermissions:AddParameter(console.Player({SingleTarget = true}))





local addPermission = console.AddCommand("rpa_permissions_add", function(ply, target, permission)
	if target:HasPermission(permission.ID) then
		console.Feedback(ply, "ERROR", "They already has this permission!")

		return
	end

	local permissions = target:Permissions()
	permissions[permission.ID] = true

	target:SetPermissions(permissions)

	Log.Write("admin_permission_add", ply, target, permission.id)

	console.Feedback(target, "NOTICE", "%s has given you the %s permission", ply, permission.ID)
	console.Feedback(ply, "NOTICE", "You've given %s the %s permission", ply, permission.ID)
end)

addPermission:SetCategory("Permissions")
addPermission:SetDescription("Gives a permission to a player")
addPermission:SetExecutionContext(console.Server)
addPermission:SetAccess(console.IsAdmin)

addPermission:AddParameter(console.Player({SingleTarget = true}))
addPermission:AddParameter(console.Permission({Assignable = true}))





local removePermission = console.AddCommand("rpa_permissions_remove", function(ply, target, permission)
	if target:IsSuperAdmin() or (permission.Callback and permission.Callback(target)) then
		console.Feedback(ply, "ERROR", "You can't take this permission from them!")

		return
	end

	local permissions = target:Permissions()
	permissions[permission.ID] = nil

	target:SetPermissions(permissions)

	Log.Write("admin_permission_remove", ply, target, permission.id)

	console.Feedback(target, "NOTICE", "%s has taken the %s permission from you", ply, permission.ID)
	console.Feedback(ply, "NOTICE", "You've taken the %s permission from %s", permission.ID, ply)
end)

removePermission:SetCategory("Permissions")
removePermission:SetDescription("Takes a permission from a player")
removePermission:SetExecutionContext(console.Server)
removePermission:SetAccess(console.IsAdmin)

removePermission:AddParameter(console.Player({SingleTarget = true}))
removePermission:AddParameter(console.Permission({Assignable = true}))
