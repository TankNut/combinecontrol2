module("door", package.seeall)

local types = table.Lookup({
	"prop_door_rotating",
	"func_door_rotating",
	"func_door"
})

function Is(ent)
	return tobool(types[ent:GetClass()])
end

function IsProp(ent)
	return ent:GetClass() == "prop_door_rotating"
end

function GetMaster(ent)
	local owner = ent:GetOwner()

	return IsValid(owner) and owner or ent
end

function GetOther(ent)
	local owner = ent:GetOwner()

	return IsValid(owner) and owner or ent:GetNWEntity("DoorChild", NULL)
end

if SERVER then
	-- Open states
	local isOpenCallbacks = {
		["prop_door_rotating"] = function(self) return self:GetInternalVariable("m_eDoorState") != 0 end,
		["func_door_rotating"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end,
		["func_door"] = function(self) return self:GetInternalVariable("m_toggle_state") == 0 end
	}

	function IsOpen(ent)
		return isOpenCallbacks[ent:GetClass()](ent)
	end

	function SetOpen(ent, bool, ply)
		if bool then
			Open(ent, ply)
		else
			Close(ent)
		end
	end

	function Open(ent, ply)
		if IsProp(ent) and IsValid(ply) then
			GetMaster(ent):Fire("openawayfrom", "!activator", 0, ply)
		else
			ent:Fire("open", nil, 0, ply)
		end
	end

	function Close(ent)
		ent = IsProp(ent) and GetMaster(ent) or ent
		ent:Fire("close")
	end

	function Toggle(ent, ply)
		ent = IsProp(ent) and GetMaster(ent) or ent
		ent:Fire("toggle", nil, 0, ply)
	end

	-- Locking
	function IsLocked(ent)
		ent = IsProp(ent) and GetMaster(ent) or ent
		return ent:GetInternalVariable("m_bLocked")
	end

	function SetLocked(ent, bool)
		if bool then
			Lock(ent)
		else
			Unlock(ent)
		end
	end

	function Lock(ent)
		ent = IsProp(ent) and GetMaster(ent) or ent
		ent:Fire("lock")
	end

	function Unlock(ent)
		ent = IsProp(ent) and GetMaster(ent) or ent
		ent:Fire("unlock")
	end

	-- Parameters
	function GetAutoClose(ent) return ent:GetInternalVariable(IsProp(ent) and "returndelay" or "m_flWait") end
	function SetAutoClose(ent, val)
		local name = IsProp(ent) and "returndelay" or "wait"

		ent:SetKeyValue(name, val)

		if IsProp(ent) then
			local other = GetOther(ent)

			if IsValid(other) then
				other:SetKeyValue(name, val)
			end
		end
	end

	function GetSpeed(ent) return ent:GetInternalVariable("speed") end
	function SetSpeed(ent, val)
		ent:SetKeyValue("speed", val)

		if IsProp(ent) then
			local other = GetOther(ent)

			if IsValid(other) then
				other:SetKeyValue("speed", val)
			end
		end
	end

	function GetForceClose(ent) return ent:GetInternalVariable("forceclosed") end
	function SetForceClose(ent, val)
		val = val and 1 or 0

		ent:SetKeyValue("forceclosed", val)

		if IsProp(ent) then
			local other = GetOther(ent)

			if IsValid(other) then
				other:SetKeyValue("forceclosed", val)
			end
		end
	end

	function GetDamage(ent) return ent:GetInternalVariable("dmg") end
	function SetDamage(ent, val)
		ent:SetKeyValue("dmg", val)

		if IsProp(ent) then
			GetOther(ent):SetKeyValue("dmg", val)
		end
	end

	function SetTouchable(ent, bool)
		local func = bool and ent.AddSpawnFlags or ent.RemoveSpawnFlags

		func(ent, DOOR_SF_TOUCHABLE)

		if IsProp(ent) then
			local other = GetOther(ent)

			if IsValid(other) then
				func(other, DOOR_SF_TOUCHABLE)
			end
		end
	end

	function SetToggle(ent, bool)
		ent = IsProp(ent) and GetMaster(ent) or ent

		local flag = IsProp(ent) and DOOR_SF_TOGGLE_PROP or DOOR_SF_TOGGLE

		if bool then
			ent:AddSpawnFlags(flag)
		else
			ent:RemoveSpawnFlags(flag)
		end
	end

	function SetUsable(ent, bool)
		ent = IsProp(ent) and GetMaster(ent) or ent

		if bool then
			ent:AddSpawnFlags(DOOR_SF_USABLE)
		else
			ent:RemoveSpawnFlags(DOOR_SF_USABLE)
		end
	end

	-- Special funcs
	OldAutoClose = OldAutoClose or {}

	function LockOpen(ent, ply)
		OldAutoClose[ent] = GetAutoClose(ent)

		SetAutoClose(ent, -1)
		Unlock(ent)
		Open(ent, ply)
		Lock(ent)
	end

	function ResetLockOpen(ent)
		if not OldAutoClose[ent] then
			return
		end

		SetAutoClose(ent, OldAutoClose[ent])
		Unlock(ent)
		Close(ent)

		OldAutoClose[ent] = nil
	end

	hook.Add("OnEntityCreated", "tacolib.door", function(ent)
		if not IsProp(ent) then
			return
		end

		jank(function()
			if not IsValid(ent) then
				return
			end

			local owner = ent:GetOwner()

			if IsValid(owner) then
				owner:SetNWEntity("DoorChild", ent)
			end
		end)
	end)
end
