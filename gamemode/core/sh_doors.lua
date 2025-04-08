module("Doors", package.seeall)

Vars = Vars or {}

AccessTypes = AccessTypes or {}
TypeList = {}

EntityVar.Add("IsDoorOpen", {Default = false})

EntityVar.Add("_DoorLocked", {Default = false})
EntityVar.Add("_DoorUsable", {Default = false})
EntityVar.Add("_DoorTouchable", {Default = false})
EntityVar.Add("_DoorToggle", {Default = false})
EntityVar.Add("_DoorAutoClose", {Default = -1})
EntityVar.Add("_DoorSpeed", {Default = 0})
EntityVar.Add("_DoorForceClose", {Default = false})
EntityVar.Add("_DoorDamage", {Default = 0})

EntityVar.Add("_DoorGroup", {Default = ""})
EntityVar.Add("_DoorType", {Default = "default"})

GlobalVar.Add("DoorData", {
	Default = {},
	ServerOnly = true,
	Persist = true,
	Mode = GLOBALVAR_MAP_NO_OVERRIDE
})

local types = table.Lookup({
	"prop_door_rotating",
	"func_door_rotating",
	"func_door"
})

local ENTITY = FindMetaTable("Entity")

EntityCache.Add("doors", function(ent) return tobool(types[ent:GetClass()]) end)

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
		Mode = data.Mode,
		NoProp = tobool(data.NoProp),
		Saved = tobool(data.Saved)
	}

	ENTITY["Door" .. name] = function(self)
		if data.Mode == DOOR_MASTER then
			return data.Get(self:GetMasterDoor())
		else
			return data.Get(self)
		end
	end

	if SERVER then
		ENTITY["SetDoor" .. name] = function(self, value)
			assert(not data.NoProp or not self:IsPropDoor(), "Attempt to set NoProp var on a prop_door_rotating")

			if data.Mode == DOOR_SEPARATE then
				data.Set(self, value)
			elseif data.Mode == DOOR_MASTER then
				data.Set(self:GetMasterDoor(), value)
			elseif data.Mode == DOOR_BOTH then
				data.Set(self, value)

				local other = self:GetOtherDoor()

				if IsValid(other) and other != self then
					data.Set(other, value)
				end
			end

			if data.Saved then
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

function ENTITY:IsDoor()
	return EntityCache.Contains("doors", self)
end

function ENTITY:IsPropDoor()
	return self:GetClass() == "prop_door_rotating"
end

function ENTITY:GetMasterDoor()
	if self:IsPropDoor() then
		local owner = self:GetOwner()

		return IsValid(owner) and owner or self
	end

	return self
end

function ENTITY:GetOtherDoor()
	if self:IsPropDoor() then
		local owner = self:GetOwner()

		return IsValid(owner) and owner or self:GetNWEntity("DoorChild", NULL)
	end

	return self
end

function ENTITY:DoorAutoCloses()
	return self:DoorAutoClose() == -1
end

if SERVER then
	local function wrap(ent, force, name, param, activator)
		ent = ent:GetMasterDoor()

		if force and ent:DoorLocked() then
			ent:SetDoorLocked(false)
			ent:Fire(name, param, 0, activator)
			ent:SetDoorLocked(true)
		else
			ent:Fire(name, param, 0, activator)
		end
	end

	function ENTITY:SetDoorOpen(bool, force, awayFrom) if bool then self:OpenDoor(force, awayFrom) else self:CloseDoor(force) end end
	function ENTITY:OpenDoor(ply, force) wrap(self, force, "open", nil, ply) end
	function ENTITY:CloseDoor(ply, force) wrap(self, force, "close", nil, ply) end
	function ENTITY:ToggleDoor(ply, force) wrap(self, force, "toggle", nil, ply) end

	function ENTITY:LockDoor() self:SetDoorLocked(true) end
	function ENTITY:UnlockDoor() self:SetDoorLocked(false) end
	function ENTITY:ToggleDoorLocked() self:SetDoorLocked(not self:DoorLocked()) end

	function ENTITY:ResetDoor()
		for key in pairs(Vars) do
			if key == "Usable" then
				continue
			end

			self["SetDoor" .. key](self, self.InitialValues[key])
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

		for door in Iterator() do
			local id = door:MapCreationID()

			if id == -1 then
				continue
			end

			local initial = {}
			local data = doorData[id]

			for key in pairs(Vars) do
				initial[key] = door["Door" .. key](door)
			end

			if data then
				for key in pairs(Vars) do
					if data[key] then
						door["SetDoor" .. key](door, data[key])
					end
				end
			end

			door.InitialValues = initial

			if not door:IsPropDoor() then
				door:SetDoorUsable(false)
			end
		end
	end

	function Save()
		local doorData = {}

		for door in Iterator() do
			if not door:CreatedByMap() then
				continue
			end

			local master = door:GetMasterDoor()

			for name, data in pairs(Vars) do
				if not data.Saved then
					continue
				end

				local ent = (data.Mode == DOOR_MASTER or data.Mode == DOOR_BOTH) and master or door

				if data.Saved and ent:CreatedByMap() then
					local get = ent["Door" .. name](ent)
					local id = ent:MapCreationID()

					if get != ent.InitialValues[name] then
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

	local isOpenCallbacks = {
		["prop_door_rotating"] = function(self) return self:GetInternalVariable("m_eDoorState") != 0 end,
		["func_door_rotating"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end,
		["func_door"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end
	}

	function UpdateOpenDoors()
		for door in Iterator() do
			local open = isOpenCallbacks[door:GetClass()](door)

			if door:IsDoorOpen() != open then
				door:SetIsDoorOpen(open)
			end
		end
	end

	function OnUse(ply, ent)
		if not ent:IsDoor() or ent:IsPropDoor() then
			return
		end

		local define = GetAccessType(ent)
		local allowed, reason = define.CanAccess(ent, ply)

		if not allowed then
			define.OnAccessDenied(ent, ply, reason)

			return false
		end

		if ent:DoorLocked() then
			define.OnDoorLocked(ent, ply)

			return false
		end

		define.OnAccessGranted(ent, ply)
		define.PreUseCallback(ent, ply)

		if ent:DoorToggle() then
			ent:ToggleDoor(ply)
		else
			ent:OpenDoor(ply)
		end

		define.PostUseCallback(ent, ply)

		return false
	end

	function AcceptInput(ent, name, activator, caller, value)
		if not ent:IsDoor() then
			return
		end

		name = string.lower(name)

		if name == "lock" or name == "unlock" then
			ent:Set_DoorLocked(name == "lock")
		elseif name == "use" and not ent:IsPropDoor() and value != true then
			local group = ent:DoorGroup()

			if group != "" then
				for door in Iterator() do
					if door != ent and door:DoorGroup() == group then
						door:Fire("Use", true, 0, activator, caller)
					end
				end
			end
		elseif name == "setspeed" then
			ent:Set_DoorSpeed(tonumber(value))
		end
	end

	function EntityKeyValue(ent, key, value)
		if not ent:IsDoor() then
			return
		end

		key = string.lower(key)

		if key == "spawnflags" then
			ent:Set_DoorLocked(bit.Check(value, 2048))
			ent:Set_DoorUsable(ent:IsPropDoor() or bit.Check(value, 256))
			ent:Set_DoorToggle(ent:IsPropDoor() and bit.Check(value, 8192) or bit.Check(value, 32))

			if not ent:IsPropDoor() then
				ent:Set_DoorTouchable(bit.Check(value, 1024))
			end
		elseif key == "returndelay" or key == "wait" then
			ent:Set_DoorAutoClose(tonumber(value))
		elseif key == "speed" then
			ent:Set_DoorSpeed(tonumber(value))
		elseif key == "forceclosed" then
			ent:Set_DoorForceClose(tobool(value))
		elseif key == "dmg" then
			ent:Set_DoorDamage(tonumber(value))
		end
	end
end
