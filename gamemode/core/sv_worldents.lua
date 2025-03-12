module("WorldEnts", package.seeall)

function LoadEntities()
	local query = GAMEMODE.Database:Select("rp_worldents")
		query:WhereEqual("Map", game.GetMapOverride())

	local loadOrder = {}

	for _, data in ipairs(query:Execute()) do
		local class = scripted_ents.Get(data.Class)

		-- We don't have this entity (removed or errored during load)
		if not class then
			continue
		end

		local priority = class.LoadOrder or 0

		if not loadOrder[priority] then
			loadOrder[priority] = {}
		end

		table.insert(loadOrder[priority], data)
	end

	for _, priority in SortedPairs(loadOrder, true) do
		for _, data in ipairs(tab) do
			Load(data)
		end
	end
end

function Load(data)
	local ent = ents.Create(data.Class)

	if not IsValid(ent) then
		return
	end

	local mapData = sfs.decode(data.MapData)

	ent:SetPos(mapData.Pos)
	ent:SetAngles(mapData.Ang)

	ent:Spawn()
	ent:Activate()

	ent:SetEntityID(data.id)
	ent:LoadSaveData(sfs.decode(data.CustomData))

	local phys = ent:GetPhysicsObject()

	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	ent:PostInitData()
	ent:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
end

function Save(ent)
	local data = sfs.encode(ent:GetSaveData())
	local mapData = sfs.encode({
		Pos = ent:GetPos(),
		Ang = ent:GetAngles()
	})

	if ent:IsSaved() then
		async.Start(function()
			local query = GAMEMODE.Database:Select("rp_worldents")
				query:Update("MapData", mapData)
				query:Update("CustomData", data)
				query:WhereEqual("id", ent:EntityID())
			query:Execute()
		end)
	else
		async.Start(function()
			local query = GAMEMODE.Database:Insert("rp_worldents")
				query:Insert("Class", ent:GetClass())
				query:Insert("Map", game.GetMapOverride())
				query:Insert("MapData", mapData)
				query:Insert("CustomData", data)
			local _, id = query:Execute()

			ent:SetEntityID(id)
			ent:PostInitData()
			ent:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
		end)
	end
end

function Delete(ent)
	if not ent:IsSaved() then
		ent:Remove()

		return
	end

	async.Start(function()
		local query = GAMEMODE.Database:Delete("rp_worldents")
			query:WhereEqual("id", ent:EntityID())
		query:Execute()

		ent:Remove()
	end)
end
