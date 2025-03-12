local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

PlayerVar.Add("ToolTrust", {Default = TOOLTRUST_UNTRUSTED, Persist = true, DataType = TINYINT()})

EntityVar.Add("PropDescription", {})

function GM:GetToolTrust(ply)
	if ply:IsDeveloper() then
		return TOOLTRUST_DEVELOPER
	end

	if ply:IsAdmin() then
		return TOOLTRUST_ADMIN
	end

	return ply:ToolTrust()
end

function PLAYER:GetToolTrust()
	return hook.Run("GetToolTrust", self)
end

function GM:IsProtectedEntity(ent)
	local class = ent:GetClass()

	for _, v in ipairs(Config.Get("ProtectedEntities")) do
		if string.find(class, v) then
			return true
		end
	end

	return false
end

function ENTITY:IsProtectedEntity()
	return hook.Run("IsProtectedEntity", self)
end

function GM:CanUseTool(ply, tool)
	local convar = GetConVar("toolmode_allow_" .. tool)

	if convar and not convar:GetBool() then
		return false, "#spawnmenu.tools.disabled"
	end

	local config = Config.Get("ToolTrust")
	local requirement = config.Tools[tool] or config.ToolFallback

	return ply:GetToolTrust() >= requirement, "You're not allowed to use this tool!z"
end

function GM:CanTool(ply, tr, tool)
	if not hook.Run("CanUseTool", ply, tool) then
		return false
	end

	local config = Config.Get("ToolTrust")
	local trust = ply:GetToolTrust()

	local ent = tr.Entity

	if IsValid(ent) then
		if ent:IsPlayer() and trust < config.ToolgunPlayers then
			return false
		end

		if ent:IsProtectedEntity() or (ent.CanTool and not ent:CanTool(ply, tool)) then
			return false
		end

		if trust < config.IgnoreOwnership and not ply:IsCreator(ent) then
			return false
		end

		if SERVER then
			Log.Write("sandbox_tool", ply, tool, ent:GetClass())
		end
	elseif SERVER then
		Log.Write("sandbox_tool", ply, tool, "worldspawn")
	end

	return true
end

function GM:PhysgunPickup(ply, ent)
	if ent:IsProtectedEntity() or (ent.CanPhys and not ent:CanPhys(ply)) then
		return false
	end

	local config = Config.Get("ToolTrust")
	local trust = ply:GetToolTrust()

	if ent:IsPlayer() then
		if trust >= config.PhysgunPlayers and ply:CanTarget(ent) then
			ent:SetMoveType(MOVETYPE_NONE)

			return true
		end

		return false
	end

	if trust < config.IgnoreOwnership and not ply:IsCreator(ent) and not ent.AllowPhys then
		return false
	end

	return true
end

function GM:PhysgunDrop(ply, ent)
	if ply:GetToolTrust() < Config.Get("ToolTrust").FlingEntities then
		ent:SetVelocity(vector_origin)
	end

	if ent:IsPlayer() then
		ent:SetMoveType(MOVETYPE_WALK)
	end
end

if SERVER then
	function GM:CanPlayerUnfreeze(ply, ent, phys)
		if ent:IsProtectedEntity() or (ent.CanPhys and not ent:CanPhys(ply)) then
			return false
		end

		if ply:GetToolTrust() < Config.Get("ToolTrust").IgnoreOwnership and not ply:IsCreator(ent) then
			return false
		end

		return true
	end

	function GM:PlayerSpawnObject(ply, mdl, skin)
		mdl = string.lower(mdl)

		if ply:GetToolTrust() >= Config.Get("ToolTrust").BypassBlacklist then
			return true
		end

		for _, v in ipairs(Config.Get("ToolTrust")) do
			if string.find(mdl, v) then
				return false
			end
		end

		return true
	end

	local function checkToolTrust(key)
		return function(_, ply)
			return ply:GetToolTrust() >= Config.Get("ToolTrust")[key]
		end
	end

	GM.PlayerGiveSWEP = checkToolTrust("WeaponSpawning")
	GM.PlayerSpawnSWEP = checkToolTrust("WeaponSpawning")
	GM.PlayerSpawnNPC = checkToolTrust("NPCSpawning")
	GM.PlayerSpawnSENT = checkToolTrust("EntitySpawning")
	GM.PlayerSpawnVehicle = checkToolTrust("VehicleSpawning")

	hook.Add("PlayerSpawnedProp", "sandbox", function(ply, model, ent)
		if ply:GetToolTrust() < Config.Get("ToolTrust").SolidProps then
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		end

		Log.Write("sandbox_spawn_prop", ply, model)
	end)

	hook.Add("PlayerSpawnedEffect", "sandbox", function(ply, model, ent)
		if ply:GetToolTrust() < Config.Get("ToolTrust").SolidProps then
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		end

		Log.Write("sandbox_spawn_prop", ply, model)
	end)

	hook.Add("PlayerSpawnedRagdoll", "sandbox", function(ply, model, ent)
		-- Eternity does this by default? Should we undo that?
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)

		Log.Write("sandbox_spawn_prop", ply, model)
	end)

	local function logEntitySpawn(key)
		return function(ply, ent)
			Log.Write("sandbox_spawn_" .. key, ply, ent:GetClass())
		end
	end

	hook.Add("PlayerSpawnedSWEP", "sandbox", logEntitySpawn("weapon"))
	hook.Add("PlayerSpawnedNPC", "sandbox", logEntitySpawn("npc"))
	hook.Add("PlayerSpawnedVehicle", "sandbox", logEntitySpawn("vehicle"))
	hook.Add("PlayerSpawnedSENT", "sandbox", logEntitySpawn("entity"))
end

function GM:CanArmDupe(ply)
	return false
end

function GM:PlayerCheckLimit(ply, name, current, default)
	local limit = Config.Get("Limits")[name] or default or 0
	local multiplier = Config.Get("LimitMultipliers")[ply:GetToolTrust()]

	if limit == -1 or multiplier == -1 then
		return true
	end

	return current < math.floor(limit * multiplier)
end

function GM:CanDrive(ply, ent)
	return false
end

local blacklist = {
	["persist"] = true,
	["drive"] = true,
	["bonemanipulate"] = true,
	["remove"] = true,
	["npc_bigger"] = true,
	["npc_smaller"] = true
}

function GM:CanProperty(ply, prop, ent)
	if not ply:IsAdmin() then
		return false
	end

	if ent:IsProtectedEntity() then
		return false
	end

	if blacklist[prop] then
		return false
	end

	return true
end

if CLIENT then
	-- Remove the halo effect
	function GM:DrawPhysgunBeam(ply, weapon, bOn, target, boneid, pos)
		return true
	end
else
	function GM:GetPropInfo(ply, ent)
		local info = {
			"<c=white>-- General info --</c>",
			"  Type: " .. ent:GetClass(),
			"  Model: " .. ent:GetModel()
		}

		local owner = ent:OwnerID()

		if owner then
			table.insert(info, "  Created by: " .. string.format("%s (%s)", ent:OwnerName(), owner))
		end

		return info
	end
end
