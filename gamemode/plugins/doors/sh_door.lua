local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

GM.DoorAccessors = {
	{"Type", 			"Float",	DOOR_UNBUYABLE},
	{"OriginalName",	"String",	""},
	{"Name",			"String",	""},
	{"Price", 			"Float",	0},
	{"Building", 		"String",	""},
	{"Owners",			"Table",	{}},
	{"IsPlanted",		"Float",	0},
}

for _, v in pairs(GM.DoorAccessors) do
	local name, vartype, default = v[1], v[2], v[3]

	ENTITY["SetDoor" .. name] = function(self, val)
		if CLIENT then
			return
		end

		if self["Door" .. name .. "Val"] == val then
			return
		end

		self["Door" .. name .. "Val"] = val

		net.Start("nSetDoor" .. name)
			net.WriteEntity(self)
			net["Write" .. vartype](val)
		net.Broadcast()
	end

	ENTITY["Door" .. name] = function(self)
		if self["Door" .. name .. "Val"] == false then
			return false
		end

		return self["Door" .. name .. "Val"] or default
	end

	if SERVER then
		util.AddNetworkString("nSetDoor" .. name)
	else
		local function nRecvData(len)
			local door = net.ReadEntity()
			local val = net["Read" .. vartype]()

			if IsValid(door) then
				door["Door" .. name .. "Val"] = val
			end
		end

		net.Receive("nSetDoor" .. name, nRecvData)
	end
end

function ENTITY:InitializeDoorAccessors()
	for _, v in pairs(GAMEMODE.DoorAccessors) do
		local name, default = v[1], v[3]

		self[name .. "Val"] = default
	end
end

function ENTITY:SyncDoorData(ply)
	for _, v in pairs(GAMEMODE.DoorAccessors) do
		local name, vartype = v[1], v[2]

		net.Start("nSetDoor" .. name)
			net.WriteEntity(self)
			net["Write" .. vartype](self["Door" .. name](self))
		net.Send(ply)
	end
end

function PLAYER:OwnedBuildings()
	local tab = {}

	for _, v in pairs(game.GetDoors()) do
		if table.HasValue(v:DoorOwners(), self:CharID()) and not table.HasValue(tab, v:DoorBuilding()) then
			table.insert(tab, v:DoorBuilding())
		end
	end

	return tab
end

function PLAYER:AddDoorOwner(ent)
	local tab = ent:DoorOwners()
	local ntab = {}

	for k, v in pairs(tab) do
		ntab[k] = v
	end

	table.insert(ntab, self:CharID())

	ent:SetDoorOwners(ntab)

	if ent:DoorBuilding() != "" then
		for _, v in pairs(game.GetDoors()) do
			if ent:DoorBuilding() == v:DoorBuilding() then
				v:SetDoorOwners(ntab)
			end
		end
	end
end

function PLAYER:RemoveDoorOwner(ent)
	local ntab = ent:DoorOwners()
	local tab = {}

	for _, v in pairs(ntab) do
		if v != self:CharID() then
			table.insert(tab, v)
		end
	end

	ent:SetDoorOwners(tab)

	if ent:DoorBuilding() != "" then
		for _, v in pairs(game.GetDoors()) do
			if ent:DoorBuilding() == v:DoorBuilding() then
				v:SetDoorOwners(tab)
			end
		end
	end
end

function PLAYER:CanLock(ent)
	if self:IsAdmin() then
		return true
	end

	if table.HasValue(ent:DoorOwners(), self:CharID()) then
		return true
	end

	return false
end
