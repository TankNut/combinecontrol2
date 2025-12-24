module("Permissions", package.seeall)

List = List or {}

local PLAYER = FindMetaTable("Player")

PlayerVar.Add("Permissions", {
	Default = {},
	Persist = true,
	DataType = BLOB()
})

function Add(id, data)
	List[id] = {
		ID = id,
		Description = data.Description or "No description specified",
		Callback = data.Callback,
		CanAssign = data.CanAssign
	}
end

function PLAYER:HasPermission(id)
	assert(List[id], "Attempt to check undefined permission: " .. id)

	if self:IsSuperAdmin() then
		return true
	end

	local callback = List[id].Callback

	if callback and callback(self) then
		return true
	end

	return self:Permissions()[id]
end
