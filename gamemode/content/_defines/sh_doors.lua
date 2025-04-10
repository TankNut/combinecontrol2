Doors.AddAccessType("default", {
	Name = "Default",
	Color = Color(100, 100, 100),
	CanAccess = function(ent, ply)
		return ent.InitialDoorValues.Usable
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

-- Door vars

Doors.AddVar("Title", {
	Saved = true,
	Define = true,
	Default = "",
})

-- You shouldn't touch these, they contain most of the source features doors have and are tracked/updated manually within the doors library itself
Doors.AddVar("Locked", {
	Saved = true,
	Define = true,
	Default = false,
	Set = function(self, val)
		door.SetLocked(self, val)
	end
})

Doors.AddVar("Touchable", {
	NoProp = true,
	Saved = true,
	Define = true,
	Default = false,
	Set = function(self, val)
		door.SetTouchable(self, tobool(val))
	end
})

Doors.AddVar("Toggle", {
	NoProp = true,
	Saved = true,
	Define = true,
	Default = false,
	Set = function(self, val)
		val = tobool(val)

		door.SetToggle(self, val)
		self:Set_DoorToggle(val)
	end
})

Doors.AddVar("AutoClose", {
	Saved = true,
	Define = true,
	Default = -1,
	Set = function(self, val)
		if val == false then
			val = -1
		end

		door.SetAutoClose(self, val)
		self:Set_DoorAutoClose(val)

		return true
	end
})

Doors.AddVar("Speed", {
	Saved = true,
	Define = true,
	Default = 0,
	Set = function(self, val)
		door.SetSpeed(self, val)
	end
})

Doors.AddVar("ForceClose", {
	NoProp = true,
	Saved = true,
	Define = true,
	Default = false,
	Set = function(self, val)
		door.SetForceClose(self, val)
	end
})

Doors.AddVar("Damage", {
	Saved = true,
	Define = true,
	Default = 0,
	Set = function(self, val)
		door.SetDamage(self, val)
	end
})

Doors.AddVar("Group", {
	Saved = true,
	Define = true,
	Default = "",
	Set = function(self, val)
		self:Set_DoorGroup(string.Trim(val))

		return true
	end,
})

Doors.AddVar("Type", {
	Saved = true,
	Define = true,
	Default = "default",
	Set = function(self, val)
		self:Set_DoorType(string.Trim(val))

		return true
	end,
})

Doors.AddVar("StartOpen", {
	Saved = true,
	Define = true,
	Default = false,
	Set = function(self, val)
		if val then
			door.LockOpen(self)
		else
			door.ResetLockOpen(self)
		end
	end
})
