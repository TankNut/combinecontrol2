module("netvar", package.seeall)

Defines = Defines or {}
GlobalDefines = GlobalDefines or {}

Vars = Vars or {}
Globals = Globals or {}

local logger = log.Create("netvar")

local function format(value)
	return isstring(value) and "\"" .. value .. "\"" or value
end

function Add(key, data)
	logger:Info("Defining %s netvar: %s", (data.ServerOnly and "server") or (data.Private and "private") or "public", key)

	local networkKey = "v_" .. key

	Defines[key] = {
		Key = key,
		NetworkKey = networkKey,
		Default = data.Default,
		Private = tobool(data.Private),
		ServerOnly = tobool(data.ServerOnly),
		Hook = "On" .. key .. "Changed"
	}

	if CLIENT then
		netstream.Hook(networkKey, function(...)
			Receive(key, ...)
		end)
	end
end

function AddGlobal(key, data)
	logger:Info("Defining %s global netvar: %s", (data.ServerOnly and "server") or "public", key)

	local networkKey = "g_" .. key

	GlobalDefines[key] = {
		Key = key,
		NetworkKey = networkKey,
		Default = data.Default,
		ServerOnly = tobool(data.ServerOnly),
		Hook = "On" .. key .. "Changed"
	}

	if CLIENT then
		netstream.Hook(networkKey, function(...)
			Receive(key, nil, ...)
		end)
	end
end

function GetGlobal(key, raw)
	local var = assert(GlobalDefines[key], "Attempt to get undefined global var: " .. key)
	local value = Globals[key]

	if raw then
		return value
	elseif value == nil then
		return util.SafeCopy(var.Default)
	end

	return value
end

function Get(entIndex, key, raw)
	if isentity(entIndex) then
		entIndex = entIndex:EntIndex()
	end

	local var = assert(Defines[key], "Attempt to get undefined var: " .. key)
	local value = Vars[entIndex] and Vars[entIndex][key]

	if raw then
		return value
	elseif value == nil then
		return util.SafeCopy(var.Default)
	end

	return value
end

function Set(entIndex, key, value, loading)
	assert(not isentity(value), "The var system does not support entities, use Get/SetNWEntity instead")

	if isentity(entIndex) then
		entIndex = entIndex:EntIndex()
	end

	assert(entIndex > 0, "Attempt to set var on non-networked entity")

	local var = assert(Defines[key], "Attempt to get undefined var: " .. key)

	if not istable(value) and value == var.Default then
		value = nil
	end

	if CLIENT then
		assert(not var.ServerOnly, "Attempt to set server-only var on the client: " .. key)
	end

	local old = Get(entIndex, key)

	if not Vars[entIndex] then
		Vars[entIndex] = {}
	end

	Vars[entIndex][key] = value

	local new = Get(entIndex, key)

	if not istable(old) and new == old then
		return true
	end

	local ent = Entity(entIndex)

	logger:Info("%s.%s = %s", IsValid(ent) and ent or "Entity(" .. entIndex .. ")", key, format(new))

	if IsValid(ent) then
		hook.Run(var.Hook, ent, old, new, loading)
	end

	if SERVER and not var.ServerOnly then
		if var.Private and IsValid(ent) and ent:IsPlayer() then
			netstream.Send(ent, var.NetworkKey, entIndex, value, loading)
		else
			netstream.Broadcast(var.NetworkKey, entIndex, value, loading)
		end
	end
end

function SetGlobal(key, value, loading)
	assert(not isentity(value), "The var system does not support entities, use Get/SetNWEntity instead")

	local var = assert(GlobalDefines[key], "Attempt to get undefined global var: " .. key)

	if CLIENT then
		assert(not var.ServerOnly, "Attempt to set server-only global var on the client: " .. key)
	end

	if not istable(value) and value == var.Default then
		value = nil
	end

	local old = GetGlobal(key)

	Globals[key] = value

	local new = GetGlobal(key)

	if not istable(old) and new == old then
		return true
	end

	logger:Info("Global.%s = %s", key, format(new))

	hook.Run(var.Hook, old, new, loading)

	if SERVER and not var.ServerOnly then
		netstream.Broadcast(var.NetworkKey, value, loading)
	end
end

if CLIENT then
	function Receive(key, entIndex, value, loaded)
		if entIndex == nil then
			SetGlobal(key, value, loaded)
		else
			Set(entIndex, key, value, loaded)
		end
	end

	netstream.Hook("ClearVars", function(index)
		logger:Debug("Clear vars: %s", index)

		Vars[index] = nil
	end)

	netstream.Hook("SyncVars", function(data)
		logger:Info("Received server sync")

		for key, value in pairs(data.Globals) do
			logger:Debug("Global sync: Global[%s] = %s", key, format(value))

			SetGlobal(key, value, true)
		end

		for entIndex, vars in pairs(data.Entities) do
			for key, value in pairs(vars) do
				logger:Debug("Entity sync: Entity(%s)[%s] = %s", entIndex, key, format(value))

				Set(entIndex, key, value, true)
			end
		end
	end)

	hook.Add("NetworkEntityCreated", "cc2.Netvars", function(ent)
		local vars = Vars[ent:EntIndex()]

		if vars then
			local count = table.Count(vars)

			logger:Debug("Late calling hooks for %s (%s var%s)", ent, count, count > 1 and "s" or "")

			for key, var in pairs(Defines) do
				if vars[key] == nil then
					continue
				end

				hook.Run(var.Hook, ent, util.SafeCopy(var.Default), Get(ent, key), true)
			end
		end
	end)
else
	function Clear(ent)
		if IsShuttingDown then
			return
		end

		local index = ent:EntIndex()

		if index > 0 and Vars[index] then
			Vars[index] = nil

			logger:Debug("Clear vars: %s", ent)
			netstream.Broadcast("ClearVars", index)
		end
	end

	function Sync(ply)
		logger:Info("Sync request from %s", ply)

		local globals = {}
		local entities = {}

		for key, var in pairs(GlobalDefines) do
			if var.ServerOnly then
				continue
			end

			globals[key] = Globals[key]
		end

		for entIndex, vars in pairs(Vars) do
			for key, var in pairs(Defines) do
				if var.ServerOnly or (var.Private and entIndex != ply:EntIndex()) then
					continue
				end

				if not entities[entIndex] then
					entities[entIndex] = {}
				end

				entities[entIndex][key] = vars[key]
			end
		end

		netstream.Send(ply, "SyncVars", {
			Globals = globals,
			Entities = entities
		})
	end

	hook.Add("PlayerInitialSpawn", "cc2.Netvars", Sync)
	hook.Add("EntityRemoved", "cc2.Netvars", Clear)
end
