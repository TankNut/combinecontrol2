local metatables = {
	"Entity", "Player", "Weapon", "NPC", "Vehicle", "CSEnt", "NextBot",
	"Vector", "Angle", "PhysObj", "ISave", "IRestore", "CTakeDamageInfo",
	"CEffectData", "CMoveData", "CRecipientFilter", "CUserCmd", "IMaterial",
	"Panel", "CLuaParticle", "CLuaEmitter", "ITexture", "ConVar", "IMesh",
	"VMatrix", "CSoundPatch", "IVideoWriter", "File", "CLuaLocomotion",
	"PathFollower", "CNavArea", "IGModAudioChannel", "CNavLadder", "CNewParticlEffect",
	"ProjectedTexture", "PhysCollide", "SurfaceInfo", "Color"
}

function GetGlobalLookupTable()
	local data = {}

	for key, value in pairs(_G) do
		if isfunction(value) or istable(value) then
			data[key] = "f"
		elseif isnumber(value) and key == string.upper(key) then
			data[key] = "e"
		end

		if istable(value) then
			for subKey, subValue in pairs(value) do
				if isfunction(subValue) then
					data[subKey] = "f"
				end
			end
		end
	end

	for _, name in pairs(metatables) do
		local meta = FindMetaTable(name)

		if not meta then
			continue
		end

		for key, value in pairs(meta) do
			if string.Left(key, 2) == "__" then
				continue
			end

			if isfunction(value) then
				data[key] = "m"
			end
		end
	end

	return data
end

if CLIENT then
	local function msg(str)
		MsgC(color_white, str, "\n")
	end

	netstream.Hook("generate_global_lookup", function(serverData)
		local clientData = GetGlobalLookupTable()
		local handle = file.Open("_editor_server_globals.txt", "wb", "DATA")

		handle:Write("SERVER_GLOBALS = {\n")

		local i = 0

		for key, identifier in SortedPairs(serverData) do
			if not clientData[key] then
				handle:Write(string.format("\t[\"%s\"] = \"%s\",\n", key, identifier))
				i = i + 1
			end
		end

		handle:Write("}")
		handle:Close()

		msg(string.format("Wrote %s identifiers to data/_editor_server_globals.txt", i))
	end)
else
	concommand.Add("generate_global_lookup", function(ply)
		if not IsValid(ply) or not ply:IsSuperAdmin() then
			return
		end

		netstream.Send(ply, "generate_global_lookup", GetGlobalLookupTable())
	end)
end
