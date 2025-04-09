Doors.AddAccessType("default", {
	Name = "Default",
	Color = Color(100, 100, 100),
	CanAccess = function(ent, ply)
		return ent.InitialValues.Usable
	end
})

Doors.AddAccessType("public", {
	Name = "Public",
	Color = Color("green")
})

Doors.AddAccessType("disabled", {
	Name = "Disabled",
	Color = Color("red"),
	CanAccess = function(ent, ply)
		return false
	end
})

-- You shouldn't touch these vars, they contain most of the source features doors have and are tracked/updated manually within the doors library itself
Doors.AddVar("Locked", {
	Saved = true,
	Get = function(self) return self:_DoorLocked() end,
	Set = function(self, val)
		door.SetLocked(self, val)
		self:Set_DoorLocked(val)
	end
})

Doors.AddVar("Touchable", {
	NoProp = true,
	Saved = true,
	Get = function(self) return self:_DoorTouchable() end,
	Set = function(self, val)
		val = tobool(val)

		door.SetTouchable(self, val)
		self:Set_DoorTouchable(val)
	end
})

Doors.AddVar("Toggle", {
	NoProp = true,
	Saved = true,
	Get = function(self) return self:_DoorToggle() end,
	Set = function(self, val)
		val = tobool(val)

		door.SetToggle(self, val)
		self:Set_DoorToggle(val)
	end
})

Doors.AddVar("AutoClose", {
	Saved = true,
	Get = function(self) return self:_DoorAutoClose() end,
	Set = function(self, val)
		if val == false then
			val = -1
		end

		door.SetAutoClose(self, val)
		self:Set_DoorAutoClose(val)
	end
})

Doors.AddVar("Speed", {
	Saved = true,
	Get = function(self) return self:_DoorSpeed() end,
	Set = function(self, val)
		door.SetSpeed(self, val)
		self:Set_DoorSpeed(val)
	end
})

Doors.AddVar("ForceClose", {
	NoProp = true,
	Saved = true,
	Get = function(self) return self:_DoorForceClose() end,
	Set = function(self, val)
		val = tobool(val)

		door.SetForceClose(self, val)
		self:Set_DoorForceClose(val)
	end
})

Doors.AddVar("Damage", {
	Saved = true,
	Get = function(self) return self:_DoorDamage() end,
	Set = function(self, val)
		door.SetDamage(self, val)
		self:Set_DoorDamage(val)
	end
})

Doors.AddVar("Group", {
	Saved = true,
	Get = function(self) return self:_DoorGroup() end,
	Set = function(self, val)
		self:Set_DoorGroup(string.Trim(val))
	end,
})

Doors.AddVar("Type", {
	Saved = true,
	Get = function(self) return self:_DoorType() end,
	Set = function(self, val)
		self:Set_DoorType(string.Trim(val))
	end,
})

Doors.AddVar("StartOpen", {
	Mode = DOOR_BOTH,
	Saved = true,
	Get = function(self) return self:_DoorStartOpen() end,
	Set = function(self, val)
		if val then
			door.LockOpen(self)
		else
			door.ResetLockOpen(self)
		end

		self:Set_DoorStartOpen(val)
	end
})
