module("Doors", package.seeall)

Vars = Vars or {}

AccessTypes = AccessTypes or {}
TypeList = {}

EntityVar.Add("IsDoorOpen", {Default = false})
EntityVar.Add("IsDoorLocked", {Default = false})

GlobalVar.Add("DoorData", {
	Default = {},
	ServerOnly = true,
	Persist = true,
	Mode = GLOBALVAR_MAP_NO_OVERRIDE
})

local ENTITY = FindMetaTable("Entity")

EntityCache.Add("doors", function(ent) return door.Is(ent) end)

function AddAccessType(name, data)
	local color = Color(data.Color) or util.GetSeededColor(name, 0.5, 1)
	color.a = 50

	AccessTypes[name] = {
		Name = data.Name or name,
		Color = color,
		CanAccess = data.CanAccess or function(ent, ply) return true end,
		CanLock = data.CanLock or function(ent, ply) return false end,
		OnAccessGranted = data.OnAccessGranted or function(ent, ply) end,
		OnAccessDenied = data.OnAccessDenied or function(ent, ply, reason) end,
		OnDoorLocked = data.OnDoorLocked or function(ent, ply) end,
		PreUseCallback = data.PreUseCallback or function(ent, ply) end,
		PostUseCallback = data.PostUseCallback or function(ent, ply) end
	}

	table.insert(TypeList, name)
end

function AddVar(name, data)
	Vars[name] = {
		NoProp = tobool(data.NoProp),
		Saved = tobool(data.Saved)
	}

	local var = "_Door" .. name

	if data.Define then
		EntityVar.Add(var, {
			Default = data.Default
		})
	end

	if not data.Get then
		data.Get = function(self) return self[var](self) end
	end

	if not data.Set then
		data.Set = function(self, val) end
	end

	ENTITY["Door" .. name] = function(self)
		if door.IsProp(self) then
			return data.Get(door.GetMaster(self))
		else
			return data.Get(self)
		end
	end

	if SERVER then
		ENTITY["SetDoor" .. name] = function(self, val, noSave)
			assert(not data.NoProp or not door.IsProp(self), "Attempt to set NoProp var on a prop_door_rotating")

			if door.IsProp(self) then
				local master = door.GetMaster(self)

				if not data.Set(master, val) then
					master["Set" .. var](self, val)
				end
			else
				if not data.Set(self, val) then
					self["Set" .. var](self, val)
				end
			end

			if data.Saved and not noSave then
				deferred.Call("doors.save", 60, Save)
			end
		end
	end
end

function GetAccessType(ent)
	return AccessTypes[ent:DoorType()]
end

function Iterator()
	return pairs(EntityCache.Get("doors"))
end

if SERVER then
	function ENTITY:DoorGroupCall(func, ...)
		local group = self:DoorGroup()

		if #group > 0 then
			for ent in Iterator() do
				if ent:DoorGroup() == group then
					func(ent, ...)
				end
			end
		else
			func(self, ...)
		end
	end

	function GM:OnDoorDataChanged(old, new, loaded)
		if not loaded then
			return -- We only care about this when GlobalVars are loading in.
		end

		Load()
	end

	function Load()
		local doorData = GAMEMODE:DoorData()

		for ent in Iterator() do
			local id = ent:MapCreationID()

			if id == -1 then
				continue
			end

			local initial = {}
			local data = doorData[id]

			for key in pairs(Vars) do
				initial[key] = ent["Door" .. key](ent)
			end

			if data then
				for key in pairs(Vars) do
					if data[key] then
						ent["SetDoor" .. key](ent, data[key])
					end
				end
			end

			ent.InitialDoorValues = initial

			if not door.IsProp(ent) then
				door.SetUsable(ent, false)
			end
		end
	end

	function Save()
		local doorData = {}

		for ent in Iterator() do
			if not ent:CreatedByMap() then
				continue
			end

			if door.IsProp(ent) and door.GetMaster(ent) != ent then
				continue
			end

			for name, data in pairs(Vars) do
				if not data.Saved then
					continue
				end

				if data.Saved then
					local get = ent["Door" .. name](ent)
					local id = ent:MapCreationID()

					if get != ent.InitialDoorValues[name] then
						if not doorData[id] then
							doorData[id] = {}
						end

						doorData[id][name] = get
					end
				end
			end
		end

		GAMEMODE:SetDoorData(doorData)
	end

	function UpdateDoors()
		for ent in Iterator() do
			local open = door.IsOpen(ent)

			if ent:IsDoorOpen() != open then
				ent:SetIsDoorOpen(open)
			end

			local locked = door.IsLocked(ent)

			if ent:IsDoorLocked() != locked then
				ent:SetIsDoorLocked(locked)
			end
		end
	end

	function OnUse(ply, ent)
		if not door.Is(ent) or door.IsProp(ent) then
			return
		end

		ply:ConCommand("-use")

		local define = GetAccessType(ent)
		local allowed, reason = define.CanAccess(ent, ply)

		if not allowed then
			define.OnAccessDenied(ent, ply, reason)

			return false
		end

		if ent:IsDoorLocked() then
			define.OnDoorLocked(ent, ply)

			return false
		end

		define.OnAccessGranted(ent, ply)
		define.PreUseCallback(ent, ply)

		if ent:DoorToggle() then
			ent:DoorGroupCall(door.SetOpen, ply, not ent:IsDoorOpen())
		else
			ent:DoorGroupCall(door.Open, ply)
		end

		define.PostUseCallback(ent, ply)

		return false
	end

	function EntityKeyValue(ent, key, value)
		if not door.Is(ent) then
			return
		end

		key = string.lower(key)

		if key == "spawnflags" then
			ent:Set_DoorLocked(bit.Check(value, DOOR_SF_LOCKED), true)
			ent:Set_DoorToggle(door.IsProp(ent) and bit.Check(value, DOOR_SF_TOGGLE_PROP) or bit.Check(value, DOOR_SF_TOGGLE), true)

			if not door.IsProp(ent) then
				ent:Set_DoorTouchable(bit.Check(value, DOOR_SF_TOUCHABLE), true)
			end
		elseif key == "returndelay" or key == "wait" then
			ent:Set_DoorAutoClose(tonumber(value), true)
		elseif key == "speed" then
			ent:Set_DoorSpeed(tonumber(value), true)
		elseif key == "forceclosed" then
			ent:Set_DoorForceClose(tobool(value), true)
		elseif key == "dmg" then
			ent:Set_DoorDamage(tonumber(value), true)
		end
	end
end

function GM:CanLockDoor(ply, ent)
	if ply:IsAdmin() then
		return true
	end

	return GetAccessType(ent).CanLock(ent, ply)
end
