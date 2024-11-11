local meta = FindMetaTable("Player")

PlayerVars.Add("UserGroup", {
	Default = "user",
	ServerOnly = true,
	Persist = true,
	DataType = Type.VARCHAR(64)
})

function meta:IsAdmin()
	return self:IsDeveloper() or self:IsSuperAdmin() or self:IsUserGroup("admin")
end

function meta:IsSuperAdmin()
	return self:IsDeveloper() or self:IsUserGroup("superadmin")
end

function meta:IsDeveloper()
	return self:IsUserGroup("developer")
end

if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
	hook.Add("PlayerUserGroupChanged", "admin", function(ply, old, new, loading)
		ply:SetNWString("UserGroup", new)
	end)
end
