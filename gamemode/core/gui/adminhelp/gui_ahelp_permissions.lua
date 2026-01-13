local func = function()
	local str = ""

	str = str .. "<giant><b>Permissions:</b></giant>"
	str = str .. "\n\tCC2 has a permissions system designed for handling access on a per-player basis. Currently it is only used for access to character creation options but it will almost certainly be expanded later on. You can give, take and list permissions using the <dark>rpa_permissions</dark> commands.\n\n\tOnly permissions you can assign are listed here, there may be others that are only available to people with higher admin ranks or permissions that are assigned automatically."

	str = str .. "\n\n<giant><b>Assignable Permissions:</b></giant>"

	for id, perm in SortedPairs(Permissions.List) do
		if perm.Callback or (perm.CanAssign and not perm.CanAssign(lp)) then
			continue
		end

		str = str .. string.format("\n\t%s - <dark>%s</dark>", id, perm.Description)
	end

	return str
end

hook.Add("PopulateHelpMenu", "admin_perms", function(panel)
	panel:AddAdminMenu(3, "Permissions", func)
end)

