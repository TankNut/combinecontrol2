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
	local define = assert(List[id], "Attempt to check undefined permission: " .. id)

	if define.Callback and define.Callback(self) then
		return true
	end

	return tobool(self:Permissions()[id])
end
